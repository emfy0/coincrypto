# frozen_string_literal: true

RSpec.describe CoinCrypto do
  it "works" do
    user1_privkey = "c0b91a94a26dc9be07374c2280e43b1de54be568b2509ef3ce1ade5c9cf9e8aa"
    user2_privkey = "5c3d081615591abce914d231ba009d8ae0174759e4a9ae821d97e28f122e2f8c"
    user3_privkey = "29322b8277c344606ba1830d223d5ed09b9e1385ed26be4ad14075f054283d8c"
    # user4_privkey = "4953c83055f50e1f2eee2c6c3f6cfe28d6d919beb96f45324af34d8fd863d169"
    user1_pubkey = "0394d30868076ab1ea7736ed3bdbec99497a6ad30b25afd709cdf3804cd389996a"
    user2_pubkey = "032c58bc9615a6ff24e9132cef33f1ef373d97dc6da7933755bc8bb86dbee9f55c"
    user3_pubkey = "02c4d72d99ca5ad12c17c9cfe043dc4e777075e8835af96f46d8e3ccd929fe1926"
    user4_pubkey = "03fbb043cb850c0bbf912edd4a51014b23c8cda31aa84b9552f4a328f06bebfb32"

    public_keys = [user1_pubkey, user2_pubkey, user3_pubkey, user4_pubkey]

    withdraw_addresses = [["2NDsMRboo5eXR3YXaur8rc1MMFcDwYtCRYs", 150000]]

    escrow = CoinCrypto::Bindings::Escrow.new(
      :btc_testnet, :p2wsh, 3, public_keys, nil, nil
    )

    utxos = [{
      hash: '1bed5360c390c9d06576d2a6b2767bf560baccf5f0c6a04008d1b9e2e6de85b8',
      amount: 187_074,
      output_index: 1,
    }]

    ewtx = CoinCrypto::Bindings::EscrowWithdrawalTransaction.from_escrow(
      escrow,
      withdraw_addresses,
      utxos.map(&:values)
    )

    psbt_hex = ewtx.to_psbt

    u1_ewtx = CoinCrypto::Bindings::EscrowWithdrawalTransaction.from_psbt(
      psbt_hex, :btc_testnet
    )
    u1_ewtx.sign(user1_privkey)
    expect(u1_ewtx.signed_by[user1_pubkey]).to eq true
    u1_psbt_hex = u1_ewtx.to_psbt

    u2_ewtx = CoinCrypto::Bindings::EscrowWithdrawalTransaction.from_psbt(
      psbt_hex, :btc_testnet
    )
    u2_ewtx.sign(user2_privkey)
    expect(u2_ewtx.signed_by[user2_pubkey]).to eq true
    u2_psbt_hex = u2_ewtx.to_psbt

    u3_ewtx = CoinCrypto::Bindings::EscrowWithdrawalTransaction.from_psbt(
      psbt_hex, :btc_testnet
    )
    u3_ewtx.sign(user3_privkey)
    expect(u3_ewtx.signed_by[user3_pubkey]).to eq true
    u3_psbt_hex = u3_ewtx.to_psbt

    expect(ewtx.signed_by.values.any?).to eq false

    ewtx.combine(CoinCrypto::Bindings::EscrowWithdrawalTransaction.from_psbt(u1_psbt_hex, :btc_testnet))
    expect(ewtx.signed_by[user1_pubkey]).to eq true

    ewtx.combine(CoinCrypto::Bindings::EscrowWithdrawalTransaction.from_psbt(u2_psbt_hex, :btc_testnet))
    expect(ewtx.signed_by[user1_pubkey]).to eq true
    expect(ewtx.signed_by[user2_pubkey]).to eq true

    ewtx.combine(CoinCrypto::Bindings::EscrowWithdrawalTransaction.from_psbt(u3_psbt_hex, :btc_testnet))
    expect(ewtx.signed_by[user1_pubkey]).to eq true
    expect(ewtx.signed_by[user2_pubkey]).to eq true
    expect(ewtx.signed_by[user3_pubkey]).to eq true

    expect(ewtx.to_signed_tx).to eq(
      '01000000000101b885dee6e2b9d10840a0c6f0f5ccba60f57b76b2a6d2' \
      '7665d0c990c36053ed1b0100000000ffffffff01f04902000000000017' \
      'a914e237b2aea3ad1bd1c49857593c0f0cae9824db2487050047304402' \
      '2100c1f6878bb6f9c65ca1a786f7aed6973fbbdb209a0b19c72dceb958' \
      'd7197a3d6f021f10942957e0e2f5cd7dadec441aa0241861a576506bbc' \
      '405a953ab78e5a120301473044022001a9b734d1973a794f2031d73360' \
      '0c4d8ed502ed121ab768e79efbccdec0f0e7022039f28e9146faf3abda' \
      '0d339cee77dd30d701058948bb007ede832bb48bcba174014830450221' \
      '00ecf17a9a51aa8a6b56c163b7ba97b5e37b072d860830bc0d98bf5744' \
      'f401eeaf02203edfe5ad69e41829fe28a5fa406d3de185336196be5c6a' \
      '41fa2e0d17e91228b4018b53210394d30868076ab1ea7736ed3bdbec99' \
      '497a6ad30b25afd709cdf3804cd389996a21032c58bc9615a6ff24e913' \
      '2cef33f1ef373d97dc6da7933755bc8bb86dbee9f55c2102c4d72d99ca' \
      '5ad12c17c9cfe043dc4e777075e8835af96f46d8e3ccd929fe19262103' \
      'fbb043cb850c0bbf912edd4a51014b23c8cda31aa84b9552f4a328f06b' \
      'ebfb3254ae00000000'
    )
  end
end
