use khodpay_bip39::{Mnemonic, WordCount, Language};
use magnus::{function, prelude::*, Error, Ruby, RClass};
use hex::{ToHex};

use crate::coincrypto::helpers::RubyErrorConvertible;

fn generate() -> String {
    Mnemonic::generate(WordCount::Twelve, Language::English).unwrap().phrase().to_string()
}

fn seed(ruby: &Ruby, mnemonic: String, password: String) -> Result<String, magnus::Error> {
    let mnemonic =
        Mnemonic::from_phrase(&mnemonic, Language::English)
            .map_err_to_ruby(ruby.exception_arg_error())?;

    let seed = mnemonic.to_seed(&password).unwrap();

    Ok(seed.encode_hex())
}

pub fn init(_ruby: &Ruby, coincrypto_class: RClass) -> Result<(), Error> {
    let mnemonic_coincrypto_class = coincrypto_class.define_class("Mnemonic", coincrypto_class)?;

    mnemonic_coincrypto_class.define_singleton_method("generate", function!(generate, 0))?;
    mnemonic_coincrypto_class.define_singleton_method("seed", function!(seed, 2))?;

    Ok(())
}
