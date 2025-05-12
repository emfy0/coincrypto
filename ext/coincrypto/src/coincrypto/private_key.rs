use bitcoin::hex::DisplayHex;
use magnus::{function, prelude::*, Error, Ruby, RClass};
use openssl::{hash::MessageDigest, pkey::PKey, sign::Signer};

const HMAC_RESULT_SIZE: usize = 64;

pub fn hmac_512(key: &[u8], messages: &str) -> [u8; HMAC_RESULT_SIZE] {
    let pkey = PKey::hmac(&key).unwrap();
    let mut signer = Signer::new(MessageDigest::sha512(), &pkey).unwrap();
    let mut result = [0u8; HMAC_RESULT_SIZE];

    signer.sign_oneshot(&mut result, messages.as_bytes()).unwrap();

    result
}

// private fun getSeed(curve: String): String {
//     return when (curve) {
//         "secp256k1" -> SECP256K1_SEED_KEY
//         "prime256v1" -> NIST256P1_SEED_KEY
//         "ed25519" -> ED25519_SEED_KEY
//         else -> ""
//     }
// }

// @JvmStatic
// fun fromSeed(seed: ByteArray, curve: String): ExtendedPrivateKey {
//     var bs = getSeed(curve).encodeToByteArray()
//     val hmac = Crypto.hmac512(bs, seed)
//     val privateKey = hmac.take(32).toByteArray()
//     val chainCode = hmac.takeLast(32).toByteArray()
//     return ExtendedPrivateKey(privateKey, chainCode, curve, 0, KeyPath.empty, 0)
// }

fn test(seed_hex: String) -> String {
    let seed = hex::decode(seed_hex).unwrap();

    let hmac_result = hmac_512(&seed, "secp256k1");
    let private_key = &hmac_result[..32];
    let chain_code = &hmac_result[HMAC_RESULT_SIZE - 32..];

    hmac_result.to_lower_hex_string() + "|" +
        &private_key.to_lower_hex_string() + "|" +
        &chain_code.to_lower_hex_string()
}


pub fn init(_ruby: &Ruby, coincrypto_class: RClass) -> Result<(), Error> {
    let mnemonic_coincrypto_class = coincrypto_class.define_class("PrivateKey", coincrypto_class)?;

    mnemonic_coincrypto_class.define_singleton_method("test", function!(test, 1))?;
    // mnemonic_coincrypto_class.define_singleton_method("seed", function!(seed, 2))?;

    Ok(())
}
