# frozen_string_literal: true

class CoinCrypto
  class EscrowWithdrawalTransaction
    attr_reader :raw

    def self.from_escrow(escrow:, recipients:, utxos:)
      ewtx = Bindings::EscrowWithdrawalTransaction.from_escrow(
        escrow.raw, recipients, utxos.map { it.values_at(:hash, :amount, :output_index) }
      )

      new(ewtx)
    end

    def self.from_psbt(psbt, blockchain_network:)
      ewtx = Bindings::EscrowWithdrawalTransaction.from_psbt(
        psbt, blockchain_network
      )

      new(ewtx)
    end

    def self.valid?(data)
      from_psbt(data, blockchain_network: :btc_mainnet)
      true
    rescue
      false
    end

    def initialize(ewtx)
      @raw = ewtx
    end

    def sign!(private_key)
      @raw.sign(private_key)
    end

    def combine!(another_ewt)
      @raw.combine(another_ewt.raw)
    end

    def to_psbt
      @raw.to_psbt
    end

    def to_signed_tx
      @raw.to_signed_tx
    end

    def size(denomination = :vbytes)
      @raw.size(denomination)
    end

    def escrow
      Escrow.new(@raw.escrow)
    end

    def txid
      @raw.txid
    end

    def signed_by
      @raw.signed_by
    end

    def recipients
      @raw.recipients
    end

    def utxos
      @raw.utxos
    end
  end
end
