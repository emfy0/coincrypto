# frozen_string_literal: true

class CoinCrypto
  class Mnemonic
    def self.generate
      Bindings::Mnemonic.generate
    end

    def self.seed(seed_hex, password)
      Bindings::Mnemonic.seed(seed_hex, password)
    end
  end
end
