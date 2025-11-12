use magnus::{ExceptionClass, Error};

pub trait RubyErrorConvertible<T, E> {
    fn map_err_to_ruby(self, error_kind: ExceptionClass) -> Result<T, Error>;
}

impl<T, E> RubyErrorConvertible<T, E> for Result<T, E>
where
    E: std::fmt::Display,
{
    fn map_err_to_ruby(self, error_kind: ExceptionClass) -> Result<T, Error> {
        self.map_err(|e| Error::new(error_kind, e.to_string()))
    }
}
