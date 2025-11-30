mod mnemonic;
mod extended_private_key;
mod extended_public_key;
mod escrow;
mod escrow_withdrawal_transaction;
mod blockchain_network;
mod escrow_kind;
mod helpers;

use magnus::{Error, Ruby, RClass};

pub fn init(ruby: &Ruby) -> Result<(), Error> {
    let coincrypto_bindings_class = ruby.eval::<RClass>("CoinCrypto::Bindings").unwrap();

    mnemonic::init(ruby, coincrypto_bindings_class)?;
    extended_private_key::init(ruby, coincrypto_bindings_class)?;
    extended_public_key::init(ruby, coincrypto_bindings_class)?;
    escrow::init(ruby, coincrypto_bindings_class)?;
    escrow_withdrawal_transaction::init(ruby, coincrypto_bindings_class)?;

    Ok(())
}
