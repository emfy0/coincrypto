use std::{fmt, convert::TryFrom};

pub enum EscrowKind {
    P2WSH
}

const P2WSH: &str = "p2wsh";

impl fmt::Display for EscrowKind {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let string_repr = match self {
            &EscrowKind::P2WSH => P2WSH,
        };

        write!(f, "{}", string_repr)
    }
}

impl TryFrom<&str> for EscrowKind {
    type Error = String;

    fn try_from(s: &str) -> Result<Self, Self::Error> {
        match s {
            P2WSH => Ok(EscrowKind::P2WSH),
            rest => Err(format!("unknown escrow kind: {rest}"))
        }
    }
}

impl TryFrom<&String> for EscrowKind {
    type Error = String;

    fn try_from(s: &String) -> Result<Self, Self::Error> {
        EscrowKind::try_from(s.as_str())
    }
}
