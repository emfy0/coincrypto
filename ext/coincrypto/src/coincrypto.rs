mod mnemonic;
mod private_key;

use magnus::{Error, Ruby};

pub fn init(ruby: &Ruby) -> Result<(), Error> {
    let coincrypto_class = ruby.define_class("CoinCrypto", ruby.class_object())?;

    mnemonic::init(ruby, coincrypto_class)?;
    private_key::init(ruby, coincrypto_class)?;

    Ok(())
}
