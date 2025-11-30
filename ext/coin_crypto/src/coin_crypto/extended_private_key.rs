use std::str::FromStr;
use crate::coin_crypto::helpers::RubyErrorConvertible;
use crate::coin_crypto::extended_public_key::ExtendedPublicKeyWrapper;

use hex::{self, ToHex};
use magnus::{function, method, prelude::*, Error, RClass, Ruby};

use khodpay_bip32::{ExtendedPrivateKey, Network, DerivationPath};

#[magnus::wrap(class = "CoinCrypto::Bindings::ExtendedPrivateKey")]
pub struct ExtendedPrivateKeyWrapper {
    xpriv: ExtendedPrivateKey
}

fn unpack_newtork(network: &str) -> Result<Network, String>{
    match network {
        "btc_mainnet" => Ok(Network::BitcoinMainnet),
        "btc_testnet" => Ok(Network::BitcoinTestnet),
        _ => Err("unknown network passed, available options: `\"btc_mainnet\", \"btc_testnet\"`".to_string())
    }
}

impl ExtendedPrivateKeyWrapper {
    fn from_seed(ruby: &Ruby, seed: String, network: String) -> Result<Self, magnus::Error> {
        let network = unpack_newtork(&network).map_err_to_ruby(ruby.exception_arg_error())?;
        let seed = hex::decode(seed).map_err_to_ruby(ruby.exception_arg_error())?;

        let xpriv = ExtendedPrivateKey::from_seed(&seed, network)
            .map_err_to_ruby(ruby.exception_arg_error())?;

        Ok(Self { xpriv })
    }

    fn from_base58(ruby: &Ruby, base58_string: String, _network: String) -> Result<Self, magnus::Error> {
        let xpriv = ExtendedPrivateKey::from_str(&base58_string)
            .map_err_to_ruby(ruby.exception_arg_error())?;

        Ok(Self { xpriv })
    }

    fn is_valid(base58_string: String, _network: String) -> bool {
        ExtendedPrivateKey::from_str(&base58_string).is_ok()
    }

    fn derive(ruby: &Ruby, rb_self: &Self, path: String) -> Result<Self, magnus::Error> {
        let path = DerivationPath::from_str(&path)
            .map_err_to_ruby(ruby.exception_arg_error())?;

        let new_xpriv = rb_self.xpriv.derive_path(&path)
            .map_err_to_ruby(ruby.exception_arg_error())?;

        Ok(Self { xpriv: new_xpriv })
    }

    fn encode(&self) -> String {
        self.xpriv.to_string()
    }

    fn private_key_hex(&self) -> String {
        self.xpriv.private_key().to_bytes().encode_hex()
    }

    fn public_key_hex(&self) -> String {
        self.xpriv.private_key().public_key().to_string()
    }

    fn extended_public_key(&self) -> ExtendedPublicKeyWrapper {
        ExtendedPublicKeyWrapper { xpub: self.xpriv.to_extended_public_key() }
    }

    fn fingerprint(&self) -> String {
        self.xpriv.fingerprint().encode_hex()
    }
}

pub fn init(_ruby: &Ruby, coincrypto_class: RClass) -> Result<(), Error> {
    let mnemonic_coincrypto_class = coincrypto_class.define_class("ExtendedPrivateKey", coincrypto_class)?;

    mnemonic_coincrypto_class.define_singleton_method(
        "from_seed",
        function!(ExtendedPrivateKeyWrapper::from_seed, 2),
    )?;
    mnemonic_coincrypto_class.define_singleton_method(
        "from_base58",
        function!(ExtendedPrivateKeyWrapper::from_base58, 2),
    )?;
    mnemonic_coincrypto_class.define_singleton_method(
        "valid?",
        function!(ExtendedPrivateKeyWrapper::is_valid, 2),
    )?;

    mnemonic_coincrypto_class.define_method(
        "derive",
        method!(ExtendedPrivateKeyWrapper::derive, 1),
    )?;
    mnemonic_coincrypto_class.define_method(
        "encode",
        method!(ExtendedPrivateKeyWrapper::encode, 0),
    )?;
    mnemonic_coincrypto_class.define_method(
        "private_key_hex",
        method!(ExtendedPrivateKeyWrapper::private_key_hex, 0),
    )?;
    mnemonic_coincrypto_class.define_method(
        "public_key_hex",
        method!(ExtendedPrivateKeyWrapper::public_key_hex, 0),
    )?;
    mnemonic_coincrypto_class.define_method(
        "extended_public_key",
        method!(ExtendedPrivateKeyWrapper::extended_public_key, 0),
    )?;
    mnemonic_coincrypto_class.define_method(
        "fingerprint",
        method!(ExtendedPrivateKeyWrapper::fingerprint, 0),
    )?;

    Ok(())
}
