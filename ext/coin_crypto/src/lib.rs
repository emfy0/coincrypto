mod coin_crypto;

use magnus::{Error, Ruby};

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    coin_crypto::init(ruby)
}
