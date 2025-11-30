# frozen_string_literal: true

class CoinCrypto
  class ExtendedPublicKey
    def self.from_base58(key_base58)
      key = Bindings::ExtendedPublicKey.from_base58(key_base58)
      new(key)
    end

    def self.valid?(key_base58)
      Bindings::ExtendedPublicKey.valid?(key_base58)
    end

    def initialize(key)
      @raw = key
    end

    def derive(path)
      self.class.new(@raw.derive(path))
    end

    def encode
      @raw.encode
    end

    def public_key_hex
      @raw.public_key_hex
    end

    def fingerprint
      @raw.fingerprint
    end
  end
end
