use std::str::FromStr;

use itertools::Itertools;

use bitcoin::bip32::DerivationPath;
use khodpay_bip32::{PublicKey};

// use hex::{ToHex};

use crate::coincrypto::{
    escrow_kind::EscrowKind,
    helpers::RubyErrorConvertible,
    blockchain_network::BlockchainNetwork
};

use magnus::{function, method, prelude::*, typed_data::Inspect, Error, RClass, Ruby, Symbol};

type Xfp = String;

type XpubData = Vec<(PublicKey, (Xfp, DerivationPath))>;
type XpubDataRuby = Vec<(String, String, String)>;

#[magnus::wrap(class = "CoinCrypto::Escrow")]
pub struct Escrow {
    blockchain_network: BlockchainNetwork,
    kind: EscrowKind,
    m: u8,
    public_keys: Vec<PublicKey>,
    xpub_data: XpubData,
    sort_public_keys: bool
}

impl Escrow {
    fn new(
        ruby: &Ruby,
        blockchain_network: Symbol,
        kind: Symbol,
        m: u8,
        public_keys: Vec<String>,
        xpub_data: Option<XpubDataRuby>,
        sort_public_keys: bool
    ) -> Result<Self, Error> {
        let mut parsed_xpub_data = Vec::new();
        if let Some(data) = xpub_data {
            validate_xpub_data(&public_keys, &data)
                .map_err_to_ruby(ruby.exception_arg_error())?;

            for (pk_hex, xfp, derivation_path) in data.iter().unique_by(|d| &d.0) {
                let parsed_pk = parse_public_key_hex(pk_hex)
                    .map_err_to_ruby(ruby.exception_arg_error())?;

                let derivation_path = DerivationPath::from_str(derivation_path)
                    .map_err_to_ruby(ruby.exception_arg_error())?;

                if xfp.len() != 8 || hex::decode(xfp).is_err() {
                    return Err(Error::new(ruby.exception_arg_error(), "invalid masterkey fingerprint"))
                }

                parsed_xpub_data.push((parsed_pk, (xfp.to_lowercase(), derivation_path)));
            }
        }

        let mut parsed_public_keys = Vec::new();
        for pk in public_keys.iter() {
            let parsed_pk = parse_public_key_hex(pk)
                .map_err_to_ruby(ruby.exception_arg_error())?;

            parsed_public_keys.push(parsed_pk);
        }


        let blockchain_network =
            BlockchainNetwork::try_from(&blockchain_network.to_string())
                .map_err_to_ruby(ruby.exception_arg_error())?;

        let kind =
            EscrowKind::try_from(&kind.to_string())
                .map_err_to_ruby(ruby.exception_arg_error())?;

        Ok(
            Self {
                blockchain_network,
                kind,
                m,
                sort_public_keys,
                public_keys: parsed_public_keys,
                xpub_data: parsed_xpub_data
            }
        )
    }

    fn blockchain_network(ruby: &Ruby, self_rb: &Self) -> Symbol {
        ruby.to_symbol(self_rb.blockchain_network.to_string())
    }

    fn public_keys(&self) -> Vec<String> {
        self.public_keys.iter().map(|pk| hex::encode(pk.to_bytes())).collect()
    }
}

fn validate_xpub_data<'a>(
    public_keys: &Vec<String>, xpub_data: &'a XpubDataRuby
) -> Result<&'a XpubDataRuby, String> {
    let unknown_public_keys: Vec<_> = xpub_data.iter().filter(|data| !public_keys.contains(&data.0)).collect();

    if unknown_public_keys.is_empty() {
        Ok(xpub_data)
    } else {
        Err(format!("xpub_data public keys ({unknown_public_keys:?}) were not described in public_keys"))
    }
}

const PUBLIC_KEY_ERROR_PREFIX: &str = "Public key parse error";

fn parse_public_key_hex(public_key: &str) -> Result<PublicKey, String> {
    let decoded_pk = hex::decode(public_key)
        .map_err(|e| format!("{PUBLIC_KEY_ERROR_PREFIX} ({public_key:?}): {} - {e}", e.inspect()))?;

    PublicKey::from_bytes(&decoded_pk)
        .map_err(|e| format!("{PUBLIC_KEY_ERROR_PREFIX} ({decoded_pk:?}): {} - {e}", e.inspect()))
}

pub fn init(_ruby: &Ruby, coincrypto_class: RClass) -> Result<(), Error> {
    let mnemonic_coincrypto_class = coincrypto_class.define_class("Escrow", coincrypto_class)?;

    mnemonic_coincrypto_class.define_singleton_method(
        "new",
        function!(Escrow::new, 6),
    )?;

    mnemonic_coincrypto_class.define_method(
        "blockchain_network",
        method!(Escrow::blockchain_network, 0),
    )?;

    mnemonic_coincrypto_class.define_method(
        "public_keys",
        method!(Escrow::public_keys, 0),
    )?;

    Ok(())
}
