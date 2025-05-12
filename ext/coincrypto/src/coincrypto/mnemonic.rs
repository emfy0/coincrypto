use bip39::{Mnemonic, MnemonicType, Language};

use bitcoin::hex::DisplayHex;
use magnus::{function, prelude::*, Error, Ruby, RClass};

use openssl::hash::MessageDigest;

const SEED_ITERATIONS: usize = 2048;
pub const SEED_KEY_LENGTH: usize = 64;

fn generate() -> String {
    Mnemonic::new(MnemonicType::Words12, Language::English).phrase().to_string()
}

fn seed(ruby: &Ruby, mnemonic: String, password: String) -> Result<String, magnus::Error> {
    Mnemonic::validate(&mnemonic, Language::English)
        .map_err(|error| magnus::Error::new(ruby.exception_arg_error(), error.to_string()))?;

    let salt = "mnemonic".to_string() + &password;

    let mut result = [0u8; SEED_KEY_LENGTH];

    openssl::pkcs5::pbkdf2_hmac(
        mnemonic.as_bytes(),
        salt.as_bytes(),
        SEED_ITERATIONS,
        MessageDigest::sha512(),
        &mut result
    ).unwrap();

    Ok(result.to_lower_hex_string())
}

pub fn init(_ruby: &Ruby, coincrypto_class: RClass) -> Result<(), Error> {
    let mnemonic_coincrypto_class = coincrypto_class.define_class("Mnemonic", coincrypto_class)?;

    mnemonic_coincrypto_class.define_singleton_method("generate", function!(generate, 0))?;
    mnemonic_coincrypto_class.define_singleton_method("seed", function!(seed, 2))?;

    Ok(())
}
