mod mnemonic;
mod extended_private_key;
mod extended_public_key;
mod escrow;
mod escrow_withdrawal_transaction;
mod blockchain_network;
mod escrow_kind;
mod helpers;

use magnus::{Error, Ruby};

pub fn init(ruby: &Ruby) -> Result<(), Error> {
    let coincrypto_class = ruby.define_class("CoinCrypto", ruby.class_object())?;

    mnemonic::init(ruby, coincrypto_class)?;
    extended_private_key::init(ruby, coincrypto_class)?;
    extended_public_key::init(ruby, coincrypto_class)?;
    escrow::init(ruby, coincrypto_class)?;
    escrow_withdrawal_transaction::init(ruby, coincrypto_class)?;

    Ok(())
}
