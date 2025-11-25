use std::{str::FromStr};

use crate::coincrypto::{
    escrow::{Escrow},
    helpers::RubyErrorConvertible,
};

use bitcoin::{
    absolute::Height,
    psbt::{ Input as PsbtIn },
    Address,
    Amount,
    OutPoint,
    Psbt,
    Transaction,
    TxIn,
    TxOut,
    Txid,
};

use magnus::{function, method, prelude::*, Error, RClass, Ruby};

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

#[magnus::wrap(class = "CoinCrypto::EscrowWithdrawalTransaction")]
pub struct EscrowWithdrawalTransaction {
    escrow: Escrow,
    recipients: Vec<Recipient>,
    utxos: Vec<UtxoStruct>,
    psbt: Psbt
}

impl EscrowWithdrawalTransaction {
    fn from_escrow(ruby: &Ruby, escrow: &Escrow, recipients: Vec<Recipient>, utxos: Vec<Utxo>) -> Result<Self, Error> {
        let utxos = utxos.into_iter().map(|utxo| UtxoStruct(utxo)).collect();
        let psbt = build_p2wsh_psbt(&recipients, &utxos, escrow)
            .map_err_to_ruby(ruby.exception_arg_error())?;

        Ok(
            Self {
                psbt,
                recipients,
                utxos,
                escrow: escrow.clone(),
            }
        )
    }

    fn to_pbst(&self) -> String {
        println!("{:?}", self.psbt);
        self.psbt.serialize_hex()
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

    // ------------------------------
    // 2. Create inputs (unsigned)
    // ------------------------------
    let mut inputs = Vec::new();
    let mut psbt_inputs = Vec::new();

    let witness_script = escrow.get_witness_script();

    for u in utxos {
        let txid = Txid::from_str(u.hash())
            .map_err(|e| format!("Invalid txid: {e}"))?;

        let vout: u32 = u.output_index() as u32;
        let value_sat = u.amount();

        // Create the transaction input
        inputs.push(TxIn {
            previous_output: OutPoint { txid, vout },
            ..Default::default()
        });

        // PSBT Input for P2WSH
        psbt_inputs.push(PsbtIn {
            witness_utxo: Some(TxOut {
                value: Amount::from_sat(value_sat),
                script_pubkey: witness_script.to_p2wsh()
            }),
            witness_script: Some(witness_script.clone()),
            ..Default::default()
        });
    }

    // ------------------------------
    // 3. Build unsigned transaction
    // ------------------------------
    let unsigned_tx = Transaction {
        version: bitcoin::transaction::Version(2),
        lock_time: bitcoin::absolute::LockTime::Blocks(Height::from_consensus(0).unwrap()),
        input: inputs,
        output: outputs,
    };

    // ------------------------------
    // 4. Wrap in PSBT
    // ------------------------------
    let mut psbt = Psbt::from_unsigned_tx(unsigned_tx)
        .map_err(|e| format!("PSBT creation error: {e}"))?;

    psbt.inputs = psbt_inputs;

    Ok(psbt)
}

pub fn init(_ruby: &Ruby, coincrypto_class: RClass) -> Result<(), Error> {
    let ewtx_coincrypto_class = coincrypto_class.define_class("EscrowWithdrawalTransaction", coincrypto_class)?;

    ewtx_coincrypto_class.define_singleton_method(
        "from_escrow",
        function!(EscrowWithdrawalTransaction::from_escrow, 3),
    )?;

    ewtx_coincrypto_class.define_method(
        "to_pbst",
        method!(EscrowWithdrawalTransaction::to_pbst, 0),
    )?;
    // mnemonic_coincrypto_class.define_method(
    //     "public_keys",
    //     method!(Escrow::public_keys, 0),
    // )?;
    // mnemonic_coincrypto_class.define_method(
    //     "kind",
    //     method!(Escrow::kind, 0),
    // )?;

    Ok(())
}
