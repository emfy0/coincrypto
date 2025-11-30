use std::{fmt, convert::TryFrom};

#[derive(Clone, Copy)]
pub enum BlockchainNetwork {
    BtcTestnet,
    BtcMainnet,
}

const BTC_MAINNET: &str = "btc_mainnet";
const BTC_TESTNET: &str = "btc_testnet";

impl fmt::Display for BlockchainNetwork {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let string_repr = match self {
            &BlockchainNetwork::BtcTestnet => BTC_TESTNET,
            &BlockchainNetwork::BtcMainnet => BTC_MAINNET,
        };

        write!(f, "{}", string_repr)
    }
}

impl TryFrom<&str> for BlockchainNetwork {
    type Error = String;

    fn try_from(s: &str) -> Result<Self, Self::Error> {
        match s {
            BTC_TESTNET => Ok(BlockchainNetwork::BtcTestnet),
            BTC_MAINNET => Ok(BlockchainNetwork::BtcMainnet),
            rest => Err(format!("unknown blockchain_network: {rest}"))
        }
    }
}

impl TryFrom<&String> for BlockchainNetwork {
    type Error = String;

    fn try_from(s: &String) -> Result<Self, Self::Error> {
        BlockchainNetwork::try_from(s.as_str())
    }
}

impl TryFrom<bitcoin::Network> for BlockchainNetwork {
    type Error = String;

    fn try_from(network: bitcoin::Network) -> Result<Self, Self::Error> {
        match network {
            bitcoin::Network::Bitcoin => Ok(BlockchainNetwork::BtcMainnet),
            _ => Ok(BlockchainNetwork::BtcTestnet)
        }
    }
}

impl From<BlockchainNetwork> for bitcoin::Network {
    fn from(value: BlockchainNetwork) -> Self {
        match value {
            BlockchainNetwork::BtcTestnet => bitcoin::Network::Testnet,
            BlockchainNetwork::BtcMainnet => bitcoin::Network::Bitcoin,
        }
    }
}
