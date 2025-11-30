# frozen_string_literal: true

class CoinCrypto
  class ExtendedPrivateKey
    def self.from_seed(seed_hex, network)
      key = Bindings::ExtendedPrivateKey.from_seed(seed_hex, network.to_s)
      new(key)
    end

    def self.from_base58(key_base58)
      key = Bindings::ExtendedPrivateKey.from_base58(key_base58)
      new(key)
    end

    def self.valid?(key_base58)
      Bindings::ExtendedPrivateKey.valid?(key_base58)
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

    def private_key_hex
      @raw.private_key_hex
    end

    def public_key_hex
      @raw.public_key_hex
    end

    def fingerprint
      @raw.fingerprint
    end

    def extended_public_key
      ExtendedPublicKey.new(@raw.extended_public_key)
    end
  end
end
