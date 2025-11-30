class CoinCrypto
  class Escrow
    attr_reader :raw

    def self.create(
      blockchain_network:,
      kind:,
      m:,
      public_keys:,
      extended_public_keys_with_master_fingerprint: [],
      sort_public_keys: false
    )

      escrow = Bindings::Escrow.create(
        blockchain_network,
        kind,
        m,
        public_keys,
        extended_public_keys_with_master_fingerprint,
        sort_public_keys
      )

      new(escrow)
    end

    def initialize(escrow)
      @raw = escrow
    end

    def address
      @raw.address
    end

    def redeem_script
      @raw.redeem_script
    end

    def quorum
      @raw.quorum
    end

    def blockchain_network
      @raw.blockchain_network
    end

    def kind
      @raw.kind
    end

    def public_keys
      @raw.publicKeys
    end

    def ==(other)
      address == other.address &&
        redeem_script == other.redeem_script &&
        blockchain_network == other.blockchain_network &&
        public_keys == other.public_keys &&
        kind == other.kind
    end
  end
end
