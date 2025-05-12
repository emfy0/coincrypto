mod coincrypto;

use magnus::{Error, Ruby};

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    coincrypto::init(ruby)
}
