use std::{cell::RefCell, str::FromStr};

use crate::coin_crypto::{
    blockchain_network::{ BlockchainNetwork },
    escrow::Escrow,
    escrow_kind::EscrowKind,
    helpers::RubyErrorConvertible,
};

use bitcoin::{
    bip32::Fingerprint,
    consensus,
    key::Secp256k1,
    opcodes,
    psbt::{ Input as PsbtIn },
    Address,
    Amount,
    OutPoint,
    PrivateKey,
    Psbt,
    PublicKey,
    Transaction,
    TxIn,
    TxOut,
    Txid,
};

use itertools::Itertools;
use magnus::{function, method, prelude::*, Error, RClass, Ruby, Symbol};

use miniscript::psbt::PsbtExt;

type Utxo = (String, u64, u64);

struct UtxoStruct(Utxo);

impl UtxoStruct {
    fn hash(&self) -> &str {
        &self.0.0
    }

    fn amount(&self) -> u64 {
        self.0.1
    }

    fn output_index(&self) -> u64 {
        self.0.2
    }
}

type Recipient = (String, u64);

pub struct EscrowWithdrawalTransaction {
    escrow: Escrow,
    recipients: Vec<Recipient>,
    utxos: Vec<UtxoStruct>,
    psbt: Psbt
}

#[magnus::wrap(class = "CoinCrypto::Bindings::EscrowWithdrawalTransaction")]
struct MutEscrowWithdrawalTransaction(RefCell<EscrowWithdrawalTransaction>);

impl MutEscrowWithdrawalTransaction {
    fn from_escrow(ruby: &Ruby, escrow: &Escrow, recipients: Vec<Recipient>, utxos: Vec<Utxo>) -> Result<Self, Error> {
        let utxos = utxos.into_iter().map(|utxo| UtxoStruct(utxo)).collect();
        let psbt = build_p2wsh_psbt(&recipients, &utxos, escrow)
            .map_err_to_ruby(ruby.exception_arg_error())?;

        Ok(Self(RefCell::new(
            EscrowWithdrawalTransaction {
                psbt,
                recipients,
                utxos,
                escrow: escrow.clone(),
            }
        )))
    }

    fn from_psbt(ruby: &Ruby, psbt_str: String, blockchain_network: Symbol) -> Result<Self, Error> {
        let blockchain_network = BlockchainNetwork::try_from(&blockchain_network.to_string())
            .map_err_to_ruby(ruby.exception_arg_error())?;

        let psbt = if let Ok(bytes) = hex::decode(&psbt_str) {
            Psbt::deserialize(&bytes)
                .map_err_to_ruby(ruby.exception_arg_error())?
        } else {
            Psbt::from_str(&psbt_str)
                .map_err_to_ruby(ruby.exception_arg_error())?
        };

        let unsigned_tx = &psbt.unsigned_tx;

        let mut recipients: Vec<Recipient> = Vec::new();

        for out in &unsigned_tx.output {
            let addr = Address::from_script(&out.script_pubkey, bitcoin::Network::from(blockchain_network))
                .map_err(|_| Error::new(ruby.exception_arg_error(), "Invalid output address"))?;

            recipients.push((addr.to_string(), out.value.to_sat()));
        }

        let mut utxos: Vec<UtxoStruct> = Vec::new();

        for (i, inp) in unsigned_tx.input.iter().enumerate() {
            let outpoint = inp.previous_output;

            let psbt_in = psbt.inputs.get(i).ok_or_else(|| {
                Error::new(ruby.exception_arg_error(), "Missing PSBT input")
            })?;

            let witness_utxo = psbt_in.witness_utxo.as_ref().ok_or_else(|| {
                Error::new(ruby.exception_arg_error(), "PSBT input missing witness_utxo")
            })?;

            utxos.push(UtxoStruct((
                outpoint.txid.to_string(),
                witness_utxo.value.to_sat(),
                outpoint.vout as u64,
            )));
        }


        let psbt_first_input = psbt.inputs.get(0)
            .ok_or_else(|| Error::new(ruby.exception_arg_error(), "PSBT has no inputs"))?;

        let witness_script = psbt_first_input.witness_script.clone()
            .ok_or_else(|| Error::new(ruby.exception_arg_error(), "PSBT missing witness script"))?;

        let instrs = witness_script.instructions();

        let mut iter = instrs.into_iter();

        // OP_M  (e.g., 2)
        let m = match iter.next() {
            Some(Ok(bitcoin::script::Instruction::PushBytes(b))) => {
                if b.len() == 1 { b[0] as usize }
                else {
                    return Err(Error::new(ruby.exception_arg_error(), "Invalid M value in witness script"))
                }
            }
            Some(Ok(bitcoin::script::Instruction::Op(op))) if op.to_u8() >= 81 && op.to_u8() <= 96 => {
                // OP_1 .. OP_16
                (op.to_u8() - 80) as usize
            }
            _ => {
                return Err(Error::new(ruby.exception_arg_error(), "Cannot parse M from witness script"));
            }
        };

        let mut public_keys = Vec::new();

        loop {
            match iter.next() {
                Some(Ok(bitcoin::script::Instruction::PushBytes(pk_bytes))) => {
                    let pk = PublicKey::from_slice(pk_bytes.as_bytes())
                        .map_err_to_ruby(ruby.exception_arg_error())?;
                    public_keys.push(pk);
                }
                Some(Ok(bitcoin::script::Instruction::Op(opcodes::all::OP_CHECKMULTISIG))) => {
                    break;
                }
                Some(Ok(_)) => continue,
                None => break,
                Some(Err(e)) => {
                    return Err(Error::new(ruby.exception_arg_error(), format!("Script parse error: {e}")));
                }
            }
        }

        if public_keys.is_empty() {
            return Err(Error::new(ruby.exception_arg_error(), "No pubkeys found in witness script"));
        }

        let mut xpub_data = Vec::new();

        for (pubkey, (xfp, path)) in psbt_first_input.bip32_derivation.iter() {
            xpub_data.push((
                PublicKey::new(*pubkey),
                (xfp.to_string(), path.clone())
            ));
        }

        let escrow = Escrow {
            blockchain_network,
            kind: EscrowKind::P2WSH,
            m,
            public_keys,
            xpub_data,
        };


        Ok(Self(RefCell::new(EscrowWithdrawalTransaction {
            escrow,
            recipients,
            utxos,
            psbt,
        })))
    }

    fn sign(ruby: &Ruby, self_rb: &Self, priv_key: String) -> Result<bool, Error> {
        use bitcoin::{
            secp256k1::{Secp256k1, Message},
            PublicKey,
            sighash::{SighashCache, EcdsaSighashType},
            ScriptBuf,
            Network
        };

        let raw = hex::decode(&priv_key)
            .map_err_to_ruby(ruby.exception_arg_error())?;

        if raw.len() != 32 {
            return Err(Error::new(
                ruby.exception_arg_error(),
                "Private key must be 32 bytes"
            ));
        }

        let secret_key = PrivateKey::from_slice(&raw, Network::Testnet)
            .map_err_to_ruby(ruby.exception_arg_error())?;

        let secp = Secp256k1::new();
        let my_pubkey = PublicKey::from_private_key(&secp, &secret_key);

        let mut inner = self_rb.0.borrow_mut();
        let psbt = &mut inner.psbt;

        let mut signed_any = false;

        for (index, input) in psbt.inputs.iter_mut().enumerate() {
            let witness_script: ScriptBuf = match &input.witness_script {
                Some(ws) => ws.clone(),
                None => continue,
            };

            if !witness_script
                .as_bytes()
                .windows(my_pubkey.to_bytes().len())
                .any(|w| w == my_pubkey.to_bytes())
            {
                continue;
            }

            let prev_out = match &input.witness_utxo {
                Some(wutxo) => wutxo,
                None => {
                    return Err(Error::new(
                        ruby.exception_runtime_error(),
                        "Missing witness_utxo in PSBT input"
                    ));
                }
            };

            let mut cache = SighashCache::new(&psbt.unsigned_tx);

            let sighash = cache
                .p2wsh_signature_hash(
                    index,
                    &witness_script,
                    prev_out.value,
                    EcdsaSighashType::All,
                )
                .map_err_to_ruby(ruby.exception_runtime_error())?;

            let msg = Message::from_digest_slice(&sighash[..])
                .map_err_to_ruby(ruby.exception_runtime_error())?;

            let sig = secp.sign_ecdsa(&msg, &secret_key.inner);

            let mut sig_bytes = sig.serialize_der().to_vec();
            sig_bytes.push(EcdsaSighashType::All as u8);

            input.partial_sigs.insert(
                my_pubkey,
                bitcoin::ecdsa::Signature::from_slice(&sig_bytes).unwrap(),
            );

            signed_any = true;
        }

        Ok(signed_any)
    }

    fn combine(&self, other: &Self) -> bool {
        let mut this = self.0.borrow_mut();
        let other = other.0.borrow();

        this.psbt.combine(other.psbt.clone()).is_ok()
    }

    fn finalize(&self) -> Result<Psbt, (Psbt, Vec<miniscript::psbt::Error>)>{
        let psbt = self.0.borrow().psbt.clone();
        let secp = Secp256k1::default();
        psbt.finalize(&secp)
    }

    fn to_signed_tx(ruby: &Ruby, self_rb: &Self) -> Result<String, Error> {
        let psbt = self_rb.finalize()
            .map_err(|ers| ers.1.into_iter().map(|e| e.to_string()).join(", "))
            .map_err_to_ruby(ruby.exception_arg_error())?;

        let tx = psbt.extract_tx()
            .map_err_to_ruby(ruby.exception_arg_error())?;

        Ok(consensus::encode::serialize_hex(&tx))
    }

    fn signed_by(&self) -> std::collections::HashMap<String, bool> {
        use std::collections::HashMap;

        let inner = self.0.borrow();

        let total_inputs = inner.psbt.inputs.len();
        let mut map: HashMap<String, usize> = HashMap::new();

        for pk in &inner.escrow.public_keys {
            map.insert(pk.to_string(), 0);
        }

        for input in &inner.psbt.inputs {
            for (pk, _sig) in &input.partial_sigs {
                let key_hex = pk.to_string();
                if let Some(count) = map.get_mut(&key_hex) {
                    *count += 1;
                }
            }
        }

        map.into_iter()
            .map(|(k, count)| (k, count == total_inputs))
            .collect()
    }

    fn to_psbt(&self) -> String {
        self.0.borrow().psbt.serialize_hex()
    }

    fn escrow(&self) -> Escrow {
        self.0.borrow().escrow.to_owned()

    }

    fn recipients(&self) -> Vec<Recipient> {
        self.0.borrow().recipients.to_owned()
    }

    fn utxos(&self) -> Vec<Utxo> {
        self.0.borrow().utxos.iter().map(|utxo| utxo.0.to_owned()).collect()
    }
}

fn build_p2wsh_psbt(
    recipients: &Vec<Recipient>, utxos: &Vec<UtxoStruct>, escrow: &Escrow
) -> Result<Psbt, String> {
    let mut outputs = Vec::new();

    for (addr_str, amount) in recipients {
        let addr = Address::from_str(addr_str)
            .map_err(|e| format!("Invalid recipient address: {e}"))?;

        outputs.push(TxOut {
            value: Amount::from_sat(*amount),
            script_pubkey:
                addr
                    .require_network(escrow.btc_blockchain_network())
                    .map_err(|e| format!("Invalid recipient address: {e}"))?
                    .script_pubkey(),
        });
    }

    let mut inputs = Vec::new();
    let mut psbt_inputs = Vec::new();

    let witness_script = escrow.get_witness_script();

    for u in utxos {
        let txid = Txid::from_str(u.hash())
            .map_err(|e| format!("Invalid txid: {e}"))?;

        let vout: u32 = u.output_index() as u32;
        let value_sat = u.amount();

        inputs.push(TxIn {
            previous_output: OutPoint { txid, vout },
            ..Default::default()
        });

        let mut psbt_input = PsbtIn {
            witness_utxo: Some(TxOut {
                value: Amount::from_sat(value_sat),
                script_pubkey: witness_script.to_p2wsh()
            }),
            witness_script: Some(witness_script.clone()),
            ..Default::default()
        };

        for (pubkey, (xfp_hex, derivation_path)) in &escrow.xpub_data {
            psbt_input
                .bip32_derivation
                .insert(
                    pubkey.inner, (Fingerprint::from_hex(xfp_hex).unwrap(), derivation_path.clone()),
                );
        }

        psbt_inputs.push(psbt_input);
    }

    let unsigned_tx = Transaction {
        version: bitcoin::transaction::Version(1),
        lock_time: bitcoin::absolute::LockTime::ZERO,
        input: inputs,
        output: outputs,
    };

    let mut psbt = Psbt::from_unsigned_tx(unsigned_tx)
        .map_err(|e| format!("PSBT creation error: {e}"))?;

    psbt.inputs = psbt_inputs;

    Ok(psbt)
}

pub fn init(_ruby: &Ruby, coincrypto_class: RClass) -> Result<(), Error> {
    let ewtx_coincrypto_class = coincrypto_class.define_class("EscrowWithdrawalTransaction", coincrypto_class)?;

    ewtx_coincrypto_class.define_singleton_method(
        "from_escrow",
        function!(MutEscrowWithdrawalTransaction::from_escrow, 3),
    )?;

    ewtx_coincrypto_class.define_singleton_method(
        "from_psbt",
        function!(MutEscrowWithdrawalTransaction::from_psbt, 2),
    )?;

    ewtx_coincrypto_class.define_method(
        "to_psbt",
        method!(MutEscrowWithdrawalTransaction::to_psbt, 0),
    )?;
    ewtx_coincrypto_class.define_method(
        "escrow",
        method!(MutEscrowWithdrawalTransaction::escrow, 0),
    )?;
    ewtx_coincrypto_class.define_method(
        "recipients",
        method!(MutEscrowWithdrawalTransaction::recipients, 0),
    )?;
    ewtx_coincrypto_class.define_method(
        "utxos",
        method!(MutEscrowWithdrawalTransaction::utxos, 0),
    )?;
    ewtx_coincrypto_class.define_method(
        "sign",
        method!(MutEscrowWithdrawalTransaction::sign, 1),
    )?;
    ewtx_coincrypto_class.define_method(
        "combine",
        method!(MutEscrowWithdrawalTransaction::combine, 1),
    )?;
    ewtx_coincrypto_class.define_method(
        "to_signed_tx",
        method!(MutEscrowWithdrawalTransaction::to_signed_tx, 0),
    )?;
    ewtx_coincrypto_class.define_method(
        "signed_by",
        method!(MutEscrowWithdrawalTransaction::signed_by, 0),
    )?;

    Ok(())
}
