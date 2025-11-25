# frozen_string_literal: true

RSpec.describe CoinCrypto do
  it "does something useful" do
    user1_privkey = "c0b91a94a26dc9be07374c2280e43b1de54be568b2509ef3ce1ade5c9cf9e8aa"
    user2_privkey = "5c3d081615591abce914d231ba009d8ae0174759e4a9ae821d97e28f122e2f8c"
    user3_privkey = "29322b8277c344606ba1830d223d5ed09b9e1385ed26be4ad14075f054283d8c"
    user4_privkey = "4953c83055f50e1f2eee2c6c3f6cfe28d6d919beb96f45324af34d8fd863d169"
    user1_pubkey = "0394d30868076ab1ea7736ed3bdbec99497a6ad30b25afd709cdf3804cd389996a"
    user2_pubkey = "032c58bc9615a6ff24e9132cef33f1ef373d97dc6da7933755bc8bb86dbee9f55c"
    user3_pubkey = "02c4d72d99ca5ad12c17c9cfe043dc4e777075e8835af96f46d8e3ccd929fe1926"
    user4_pubkey = "03fbb043cb850c0bbf912edd4a51014b23c8cda31aa84b9552f4a328f06bebfb32"

    public_keys = [user1_pubkey, user2_pubkey, user3_pubkey, user4_pubkey]

    withdraw_addresses = [["2NDsMRboo5eXR3YXaur8rc1MMFcDwYtCRYs", 150000]]

    escrow = CoinCrypto::Escrow.new(
      :btc_testnet, :p2wsh, 3, public_keys, nil, nil
    )

    utxos = [{
      hash: 'b885dee6e2b9d10840a0c6f0f5ccba60f57b76b2a6d27665d0c990c36053ed1b',
      amount: 187_074,
      output_index: 1,
    }]

    ewtx = CoinCrypto::EscrowWithdrawalTransaction.from_escrow(
      escrow,
      withdraw_addresses,
      utxos.map(&:values)
    )

    binding.irb

    expect(false).to eq(true)
  end
end
