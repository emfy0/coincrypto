use std::str::FromStr;

use hex::{ToHex};
use crate::coin_crypto::helpers::RubyErrorConvertible;

use magnus::{function, method, prelude::*, Error, RClass, Ruby};

use khodpay_bip32::{ExtendedPublicKey, DerivationPath};

#[magnus::wrap(class = "CoinCrypto::Bindings::ExtendedPublicKey")]
pub struct ExtendedPublicKeyWrapper {
    pub xpub: ExtendedPublicKey
}

impl ExtendedPublicKeyWrapper {
    fn from_base58(ruby: &Ruby, base58_string: String, _network: String) -> Result<Self, magnus::Error> {
        let xpub = ExtendedPublicKey::from_str(&base58_string)
            .map_err_to_ruby(ruby.exception_arg_error())?;

        Ok(Self { xpub })
    }

    fn is_valid(base58_string: String, _network: String) -> bool {
        ExtendedPublicKey::from_str(&base58_string).is_ok()
    }

    fn derive(ruby: &Ruby, rb_self: &Self, path: String) -> Result<Self, magnus::Error> {
        let path = DerivationPath::from_str(&path)
            .map_err_to_ruby(ruby.exception_arg_error())?;

        let new_xpriv = rb_self.xpub.derive_path(&path)
            .map_err_to_ruby(ruby.exception_arg_error())?;

        Ok(Self { xpub: new_xpriv })
    }

    fn encode(&self) -> String {
        self.xpub.to_string()
    }

    fn public_key_hex(&self) -> String {
        self.xpub.public_key().to_string()
    }

    fn fingerprint(&self) -> String {
        self.xpub.fingerprint().encode_hex()
    }
}

pub fn init(_ruby: &Ruby, coincrypto_class: RClass) -> Result<(), Error> {
    let mnemonic_coincrypto_class = coincrypto_class.define_class("ExtendedPublicKey", coincrypto_class)?;

    mnemonic_coincrypto_class.define_singleton_method(
        "from_base58",
        function!(ExtendedPublicKeyWrapper::from_base58, 2),
    )?;
    mnemonic_coincrypto_class.define_singleton_method(
        "valid?",
        function!(ExtendedPublicKeyWrapper::is_valid, 2),
    )?;

    mnemonic_coincrypto_class.define_method(
        "derive",
        method!(ExtendedPublicKeyWrapper::derive, 1),
    )?;
    mnemonic_coincrypto_class.define_method(
        "encode",
        method!(ExtendedPublicKeyWrapper::encode, 0),
    )?;
    mnemonic_coincrypto_class.define_method(
        "public_key_hex",
        method!(ExtendedPublicKeyWrapper::public_key_hex, 0),
    )?;
    mnemonic_coincrypto_class.define_method(
        "fingerprint",
        method!(ExtendedPublicKeyWrapper::fingerprint, 0),
    )?;

    Ok(())
}
