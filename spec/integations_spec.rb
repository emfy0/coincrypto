# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Integration spec' do # rubocop:disable RSpec/DescribeClass
  it 'works for mnemonic' do
    expect(CoinCrypto::Mnemonic.generate).to be_a(String)

    seed_str = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about'
    seed_hex = CoinCrypto::Mnemonic.seed(seed_str, '')

    expect(seed_hex).to eq(
      "5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a" \
      "5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4"
    )

    master_key = CoinCrypto::ExtendedPrivateKey.from_seed(seed_hex, :btc_mainnet)

    expect(master_key.private_key_hex).to eq("1837c1be8e2995ec11cda2b066151be2cfb48adf9e47b151d46adab3a21cdf67")
    expect(master_key.public_key_hex).to eq("03d902f35f560e0470c63313c7369168d9d7df2d49bf295fd9fb7cb109ccee0494")
    expect(master_key.encode).to eq(
      "xprv9s21ZrQH143K3GJpoapnV8SFfukcVBSfeCficPSGfubmSFDxo1ku" \
      "HnLisriDvSnRRuL2Qrg5ggqHKNVpxR86QEC8w35uxmGoggxtQTPvfUu"
    )

    account_key = master_key.derive("m/49'/1'/0'")

    expect(account_key.encode).to eq(
      "xprv9ykubZmk6kXo3qnexcayWc1S99ZytiuVCEZzbr1bBc" \
      "A47JcQtuKV7yG3j6RohVfuxoGoy6ZEQ3V71tAQ6GNE44PG6rfTBPB4nkSBnA1qcy5"
    )

    public_master_key = master_key.extended_public_key

    expect(public_master_key.encode).to eq(
      "xpub661MyMwAqRbcFkPHucMnrGNzDwb6teAX1RbKQmqtEF8kK3Z7LZ59q" \
      "afCjB9eCRLiTVG3uxBxgKvRgbubRhqSKXnGGb1aoaqLrpMBDrVxga8"
    )

    public_account_key = account_key.extended_public_key

    expect(public_account_key.encode).to eq(
      "xpub6CkG15Jdw866GKs84e7ysjxAhBQUJBdLZTVbQERCjwh2z6wZSSdjfmaXaMvf6Vm5s" \
      "bWemK43d7HJMicz41G3vEHA9Sa5N2J9j9vgwyiHdMj"
    )

    derived_public_key = public_account_key.derive('0')

    expect(derived_public_key.encode).to eq(
      "xpub6DcJxZBdTLVvX8uokYWoKavmzFQSwSCJ3bGXy6wqdA9XvLDg" \
      "A49N7To4Sgf2sUtzerwtJZTgSpUtVP8jHDmAutmNwnCfGgCWFEGBoiMvw4w"
    )
  end

  it 'works for escrow' do
    user1_privkey = 'c0b91a94a26dc9be07374c2280e43b1de54be568b2509ef3ce1ade5c9cf9e8aa'
    user2_privkey = '5c3d081615591abce914d231ba009d8ae0174759e4a9ae821d97e28f122e2f8c'
    user3_privkey = '29322b8277c344606ba1830d223d5ed09b9e1385ed26be4ad14075f054283d8c'
    user1_pubkey = '0394d30868076ab1ea7736ed3bdbec99497a6ad30b25afd709cdf3804cd389996a'
    user2_pubkey = '032c58bc9615a6ff24e9132cef33f1ef373d97dc6da7933755bc8bb86dbee9f55c'
    user3_pubkey = '02c4d72d99ca5ad12c17c9cfe043dc4e777075e8835af96f46d8e3ccd929fe1926'
    user4_pubkey = '03fbb043cb850c0bbf912edd4a51014b23c8cda31aa84b9552f4a328f06bebfb32'

    public_keys = [user1_pubkey, user2_pubkey, user3_pubkey, user4_pubkey]

    withdraw_addresses = [['2NDsMRboo5eXR3YXaur8rc1MMFcDwYtCRYs', 150_000]]

    # keyword args
    escrow = CoinCrypto::Escrow.create(blockchain_network: :btc_testnet, kind: :p2wsh, m: 3, public_keys:)
    expect(escrow.address).to eq 'tb1qln8dryttug5wp8a6tdhlx5szmdmeutr0kmtzvp5nx7psky9m8tqspwnpzp'

    utxos = [{
      hash: "1bed5360c390c9d06576d2a6b2767bf560baccf5f0c6a04008d1b9e2e6de85b8",
      amount: 187_074,
      output_index: 1,
    }]

    ewtx = CoinCrypto::EscrowWithdrawalTransaction.from_escrow(
      escrow:,
      recipients: withdraw_addresses,
      utxos:
    )

    # Save an unsigned transaction as hex for sharing with parties
    psbt_hex = ewtx.to_psbt

    # User1 gets the transaction and signs it, then sends it back
    u1_ewtx = CoinCrypto::EscrowWithdrawalTransaction.from_psbt(
      psbt_hex,
      blockchain_network: :btc_testnet
    )
    u1_ewtx.sign!(user1_privkey)
    expect(u1_ewtx.signed_by[user1_pubkey]).to eq true
    u1_psbt_hex = u1_ewtx.to_psbt

    # User2 gets the transaction and signs it, then sends it back
    u2_ewtx = CoinCrypto::EscrowWithdrawalTransaction.from_psbt(
      psbt_hex,
      blockchain_network: :btc_testnet
    )
    u2_ewtx.sign!(user2_privkey)
    expect(u2_ewtx.signed_by[user2_pubkey]).to eq true
    u2_psbt_hex = u2_ewtx.to_psbt

    # User3 gets the transaction and signs it, then sends it back
    u3_ewtx = CoinCrypto::EscrowWithdrawalTransaction.from_psbt(
      psbt_hex,
      blockchain_network: :btc_testnet
    )
    u3_ewtx.sign!(user3_privkey)
    expect(u3_ewtx.signed_by[user3_pubkey]).to eq true
    u3_psbt_hex = u3_ewtx.to_psbt

    # Server reads all transactions received from users and combines them
    ewtx.combine!(
      CoinCrypto::EscrowWithdrawalTransaction.from_psbt(
        u1_psbt_hex, blockchain_network: :btc_testnet
      )
    )
    expect(ewtx.signed_by[user1_pubkey]).to eq true
    ewtx.combine!(
      CoinCrypto::EscrowWithdrawalTransaction.from_psbt(
        u2_psbt_hex, blockchain_network: :btc_testnet
      )
    )
    expect(ewtx.signed_by[user1_pubkey]).to eq true
    expect(ewtx.signed_by[user2_pubkey]).to eq true
    ewtx.combine!(
      CoinCrypto::EscrowWithdrawalTransaction.from_psbt(
        u3_psbt_hex, blockchain_network: :btc_testnet
      )
    )
    expect(ewtx.signed_by[user1_pubkey]).to eq true
    expect(ewtx.signed_by[user2_pubkey]).to eq true
    expect(ewtx.signed_by[user3_pubkey]).to eq true

    # Server generates a signed transaction for broadcasting
    tx = ewtx.to_signed_tx

    expect(tx).to eq(
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
