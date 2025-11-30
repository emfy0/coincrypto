# # frozen_string_literal: true
#
# RSpec.describe CoinCrypto::EscrowWithdrawalTransaction do
#   let(:user1_xpriv) do
#     'tprv8iiGRargcFzZDXZgguATATVrbcgftzJjpava2GztcV5SFWhT4ejtQkWE5CJAux3ccQPqzpn75bzs2ZFX6VzENip75vJ2VnSfwZsPdD6xkaV'
#   end
#   let(:user2_xpriv) do
#     'tprv8iKeQfbSV9XnyCLR78VoNeEwaqphXyNyoYAjNYrVBsMbAxyLamjtTkrJ9w6ppJ3UPYn8AbuUr8ceGot3LgcipqGzCa8bBiNMkcMYdGdnbAC'
#   end
#   let(:user3_xpriv) do
#     'tprv8hoNGLWRLYipDwob2Ysyk6UouxVdDdEnBGXaDhHdPjwzmorxmvvTEV2UnTZ9JpBcVeUgf12BSkbPCQpmz7wrofsDhCQtFuqcTL8az3Hq65p'
#   end
#
#   let(:user1_xpub) do
#     'tpubDFQJZztvkdgE6zbUaYq3Zs9yAeCc4KVePtXMJo3C2ksq5zxDh3ZUbF86FKWHVD69JLCS31LMXZe1iXJ5tAMTHXDpm51JdArpNF5ax7Fq2BB'
#   end
#   let(:user2_xpub) do
#     'tpubDF1gZ5dgdXDTrfNCznAPn3u49sLdhJZtNqmWf4tnc99z1TE7DAZUeFUAL4kX91rJAFU3Qd1xUtwTjbWpntK4z1oeGhvpKQrcF5dxXNizx3x'
#   end
#   let(:user3_xpub) do
#     'tpubDEVQQkYfUvQV7QqNvCYa9W8vUz1ZNxRgka8MWDKvp1kPcJ7jQKk3QyeLxaozdjMom4zCKvxQD6f8qSGjbuko9Uy5Y28BecLhrMCQoK1SfcJ'
#   end
#   let(:user4_xpub) do
#     'tpubDErih8jxp6U4Gp2gora8F9iW9iVfTvup8tSMogWtBZhxvwkHmbyvxuU9qqfNCVcn5uUSExE7twwp5b5HdeLiNNLKxaCUW5aAxcd1hNSAgnx'
#   end
#
#   let(:user1_pubkey) { '027effe510fafd1c3d2db0b2b2e9f7916ea2be5f94e20f75a9ba9e2b683917b8fd' }
#   let(:user2_pubkey) { '031a964279e91262f089de0a5d4e5a715277c3a3eb24dd943b503f638cf5d399b0' }
#   let(:user3_pubkey) { '0313d2db5889e2fa5452857e9b2ddae829a19585e598c0a1277eb56ddf66877130' }
#   let(:user4_pubkey) { '0283936a022bd9bbf9088394246154653be0174eca7a46fc69e58add9a936b3ec7' }
#
#   let(:derivation) { 'm/48\'/1\'/0\'/1\'' }
#
#   let(:user1_fingerprint) { '33ddd5eb' }
#   let(:user2_fingerprint) { '2fedf9d4' }
#   let(:user3_fingerprint) { '67e886f3' }
#   let(:user4_fingerprint) { '59145cd8' }
#
#   let(:withdraw_addresses) do
#     [['moqvBr25tH164P1S7xePahYiwkdCwHT5CR', 25_000],
#       [escrow.address, 806_000]]
#   end
#
#   let(:utxos) do
#     [
#       {
#         hash: '9e0af3eebdff63e368d6fc3b985cb420068fb71e1d1123dca6458c0add11b153',
#         amount: 25_000,
#         output_index: 0,
#       },
#       {
#         hash: 'fa0f544042dbac7c94a0b51af10945acf5924589e88cc4afb2005e1c47e27951',
#         amount: 25_000,
#         output_index: 0,
#       },
#       {
#         hash: 'c4f2aa5985156deeca30abd84c7ee01ba5c5fcee4788c82fe103902b7eafa90a',
#         amount: 200_000,
#         output_index: 1,
#       },
#       {
#         hash: 'd8d2c29e97b11ac60ff0aa87aed2900b9d3e7ef82e829d43d4515c0eb2b17139',
#         amount: 500_000,
#         output_index: 0,
#       },
#       {
#         hash: '747d4b13341ef7bd91362ab96e12e2eaeb87f93c4c6cb5a5537bcb1c0962fd48',
#         amount: 89_000,
#         output_index: 1,
#       },
#     ]
#   end
#
#   context 'when 3 of 4 keys' do
#     let(:pubkeys) do
#       [
#         user1_pubkey,
#         user2_pubkey,
#         user3_pubkey,
#         user4_pubkey,
#       ]
#     end
#
#     let(:xpubs_data) do
#       [
#         [user1_xpub, user1_fingerprint, derivation],
#         [user2_xpub, user2_fingerprint, derivation],
#         [user3_xpub, user3_fingerprint, derivation],
#         [user4_xpub, user4_fingerprint, derivation],
#       ]
#     end
#
#     let(:escrow) do
#       CoinCrypto::Escrow.create(
#         blockchain_network: :btc_testnet,
#         kind: :p2wsh, m: 3,
#         public_keys: pubkeys,
#         extended_public_keys_with_master_fingerprint: xpubs_data,
#         sort_public_keys: true
#       )
#     end
#
#     let(:escrow_legacy) do
#       CoinCrypto::Escrow.create(
#         blockchain_network: :btc_testnet,
#         kind: :p2sh_p2wsh,
#         m: 3,
#         public_keys: pubkeys,
#         extended_public_keys_with_master_fingerprint: xpubs_data,
#         sort_public_keys: true
#       )
#     end
#
#     it 'creates an escrow withdrawal transaction' do
#       ewtx = described_class.from_escrow(escrow:,
#         recipients: withdraw_addresses,
#         utxos:)
#
#       expect(ewtx.escrow.address).to eq(escrow.address)
#       expect(ewtx.escrow.blockchain_network).to eq(escrow.blockchain_network)
#       expect(ewtx.escrow).to eq(escrow)
#
#       expect(ewtx.utxos.size).to eq(utxos.size)
#       utxos.length.times do |i|
#         expect(ewtx.utxos[i][:hash]).to eq(utxos[i][:hash])
#         expect(ewtx.utxos[i][:amount]).to eq(utxos[i][:amount])
#         expect(ewtx.utxos[i][:output_index]).to eq(utxos[i][:output_index])
#       end
#
#       # Save an unsigned transaction as hex for sharing with parties
#       psbt_hex = ewtx.dump(:btc_psbt_hex)
#
#       # User1 gets the transaction and signs it, then sends it back
#       u1_ewtx = described_class.load(psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet)
#       expect(ewtx.escrow.sorted_public_keys?).to eq(true)
#       u1_ewtx.sign!(CoinCrypto::ExtendedPrivateKey.from_base58(user1_xpriv, 'secp256k1').private_key_hex)
#       u1_psbt_hex = u1_ewtx.dump(:btc_psbt_hex)
#
#       # User2 gets the transaction and signs it, then sends it back
#       u2_ewtx = described_class.load(psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet)
#       expect(ewtx.escrow.sorted_public_keys?).to eq(true)
#       u2_ewtx.sign!(CoinCrypto::ExtendedPrivateKey.from_base58(user2_xpriv, 'secp256k1').private_key_hex)
#       u2_psbt_hex = u2_ewtx.dump(:btc_psbt_hex)
#
#       # User3 gets the transaction and signs it, then sends it back
#       u3_ewtx = described_class.load(psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet)
#       expect(ewtx.escrow.sorted_public_keys?).to eq(true)
#       u3_ewtx.sign!(CoinCrypto::ExtendedPrivateKey.from_base58(user3_xpriv, 'secp256k1').private_key_hex)
#       u3_psbt_hex = u3_ewtx.dump(:btc_psbt_hex)
#
#       # Server reads all transactions received from users and combines them
#       ewtx.combine!(described_class.load(u1_psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet))
#       ewtx.combine!(described_class.load(u2_psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet))
#       ewtx.combine!(described_class.load(u3_psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet))
#
#       # Server generates a signed transaction
#       tx = ewtx.dump(:tx_hex)
#       expect(tx).to eq(
#         '010000000001059e0af3eebdff63e368d6fc3b985cb420068fb71' \
#         'e1d1123dca6458c0add11b1530000000000fffffffffa0f544042' \
#         'dbac7c94a0b51af10945acf5924589e88cc4afb2005e1c47e2795' \
#         '10000000000ffffffffc4f2aa5985156deeca30abd84c7ee01ba5' \
#         'c5fcee4788c82fe103902b7eafa90a0100000000ffffffffd8d2c' \
#         '29e97b11ac60ff0aa87aed2900b9d3e7ef82e829d43d4515c0eb2' \
#         'b171390000000000ffffffff747d4b13341ef7bd91362ab96e12e' \
#         '2eaeb87f93c4c6cb5a5537bcb1c0962fd480100000000ffffffff' \
#         '02a8610000000000001976a9145b572692f0929939afb3a6b6b76' \
#         '7776ebe26fb8988ac704c0c0000000000220020c6ac4fc8b673d5' \
#         'c192f749824896611c12f5c00ea140a9038ccad7e64c9b68c4050' \
#         '047304402201683904208110ff72232e3db1fa2eb71f5a727bb75' \
#         'a0899ab88b026832365d4202202a49e9d361f989700198d60b19f' \
#         'e77e572295813e028e9d71bea202fd08304d30148304502210089' \
#         'f83914149b12cb11b53271b5afc61654587b6c2b1bd3bb49a43f6' \
#         'b5a893a7902205f27959dea090cfed01c36534852322c4429ade9' \
#         'f418660e8b34aa2b58e60b4001483045022100ed0883f2029f661' \
#         '3c107f2818f0039340ab4584634bd9d4866342c36109907cc0220' \
#         '5d14464b856a3b58e90cbcf60ba5c8ea96d31e964460775674dff' \
#         '6017755693e018b5321027effe510fafd1c3d2db0b2b2e9f7916e' \
#         'a2be5f94e20f75a9ba9e2b683917b8fd210283936a022bd9bbf90' \
#         '88394246154653be0174eca7a46fc69e58add9a936b3ec7210313' \
#         'd2db5889e2fa5452857e9b2ddae829a19585e598c0a1277eb56dd' \
#         'f6687713021031a964279e91262f089de0a5d4e5a715277c3a3eb' \
#         '24dd943b503f638cf5d399b054ae0500483045022100c4d9bd0ef' \
#         '6790cf212b310cef6f591ded71d4f11f0f4b74cc6bd8e4c2aa1a2' \
#         'd302202dd37b2c8f9ff4a6ec11f152c3088593d9ec68b96ff9b45' \
#         '462a6faa36a31c0650147304402207fd5fddd46e60ce269d2bb43' \
#         'b94464725ce5bead936c670842a84313e2e6f0330220468e34f07' \
#         '0c0ffc62d1b061627c66cdfd789d474c27fed175bb68d52f3827c' \
#         '2c0147304402205bd4c7511eb19c7729ba36c6deda8c1ac795e03' \
#         '2a6818f0e4b654e2699136fe80220507c5cb46d939f4034d8a670' \
#         'ca23c787eee83e13319f884a1627983bb7825128018b5321027ef' \
#         'fe510fafd1c3d2db0b2b2e9f7916ea2be5f94e20f75a9ba9e2b68' \
#         '3917b8fd210283936a022bd9bbf9088394246154653be0174eca7' \
#         'a46fc69e58add9a936b3ec7210313d2db5889e2fa5452857e9b2d' \
#         'dae829a19585e598c0a1277eb56ddf6687713021031a964279e91' \
#         '262f089de0a5d4e5a715277c3a3eb24dd943b503f638cf5d399b0' \
#         '54ae0500483045022100d2438e7e475f33ccf21ef4dfbf1e2aa96' \
#         '3e8e3936fa71881671c063b52f97a6c0220401c074158098f46ec' \
#         '4fea2dce58447135f6a717a9a30bcff45e71cb6fb7b48d0148304' \
#         '5022100d80c5baeacde2c904a22521f2b9f084171c8570962d4a4' \
#         'ff4a5da9fcab26ea51022016cda045032c2cb16e3d9a939221af2' \
#         '8984f79eb2dd5685dd3d5fd4fe36f80050147304402207fae304e' \
#         'a43b73868ce58752bd609f1f1ca0db385c82a599fe1851237eb22' \
#         '41702207bc854af22f329c8c37656d837d6ae54cb99b2cdbc10b6' \
#         '7442a1250fdf6bbc63018b5321027effe510fafd1c3d2db0b2b2e' \
#         '9f7916ea2be5f94e20f75a9ba9e2b683917b8fd210283936a022b' \
#         'd9bbf9088394246154653be0174eca7a46fc69e58add9a936b3ec' \
#         '7210313d2db5889e2fa5452857e9b2ddae829a19585e598c0a127' \
#         '7eb56ddf6687713021031a964279e91262f089de0a5d4e5a71527' \
#         '7c3a3eb24dd943b503f638cf5d399b054ae0500473044022041a5' \
#         '2405ff5f784f172da80c36e5ec16a5a465685a96a9e2a694d1845' \
#         '22f4472022026d70205cedabb02282b70b79679af15929ec57624' \
#         'ed5ac4d604e923404532dd0147304402207f882fa63c3f4cc67f7' \
#         '72d10b0d24bda94dbe2424decd9fd08ae5f7f178a2f9502207fb2' \
#         'd9b7f73c5e06a3534575314004367498c075889ce9d29305463a6' \
#         '9fc85d8014830450221008c461db9c16b10e92ffc13a0164a6ab5' \
#         'dfb2ee549d02f68b90da841894aa6610022009c55855d3cd64a51' \
#         'cdf03c58225ec96b3d724f61d87c2ba6fdc47e924c00f89018b53' \
#         '21027effe510fafd1c3d2db0b2b2e9f7916ea2be5f94e20f75a9b' \
#         'a9e2b683917b8fd210283936a022bd9bbf9088394246154653be0' \
#         '174eca7a46fc69e58add9a936b3ec7210313d2db5889e2fa54528' \
#         '57e9b2ddae829a19585e598c0a1277eb56ddf6687713021031a96' \
#         '4279e91262f089de0a5d4e5a715277c3a3eb24dd943b503f638cf' \
#         '5d399b054ae0500473044022023f7a9bd7f61a45650fa851d688e' \
#         '1685993c6ea6b3aa2e603aead92cc89b25ac02207e044a87a41f6' \
#         '7a80f87d4c7411c8b557d928f919831bd1d4643c9143ea6382801' \
#         '47304402206bddbf9f8b16f00353cdfbf3737dcae3f5d6872594a' \
#         'da318b0be2507aceee02e0220177ad2661c2d28b5552271dfc820' \
#         'f9a4a6cd81157502cb03fe69eb4a944d2a7001473044022072653' \
#         'cfd679c224c38e5e5a12e1a8ec46bd2ca1db7726479690cc5875c' \
#         '2bc19102203ab2e4200b5b8ddd526d9abb262aba43e63010f7f6a' \
#         'c5456e78436c2dee41f6e018b5321027effe510fafd1c3d2db0b2' \
#         'b2e9f7916ea2be5f94e20f75a9ba9e2b683917b8fd210283936a0' \
#         '22bd9bbf9088394246154653be0174eca7a46fc69e58add9a936b' \
#         '3ec7210313d2db5889e2fa5452857e9b2ddae829a19585e598c0a' \
#         '1277eb56ddf6687713021031a964279e91262f089de0a5d4e5a71' \
#         '5277c3a3eb24dd943b503f638cf5d399b054ae00000000'
#       )
#       expect(ewtx.txid).to eq('d7506609b6a3f026baab79a738c36240d1022adf94f7685c85356405d6829abd')
#       expect(ewtx.size).to eq(742)
#     end
#
#     it 'creates an escrow withdrawal transaction for p2sh_p2wsh' do
#       ewtx = described_class.from_escrow(escrow: escrow_legacy,
#         recipients: withdraw_addresses,
#         utxos:)
#
#       expect(escrow_legacy.address).to eq('2N5SPWhdq5tBRjz79K21muMEJxtQvvHqhoe')
#       expect(ewtx.escrow.address).to eq(escrow_legacy.address)
#       expect(ewtx.escrow.blockchain_network).to eq(escrow_legacy.blockchain_network)
#       expect(ewtx.escrow).to eq(escrow_legacy)
#
#       expect(ewtx.utxos.size).to eq(utxos.size)
#       utxos.length.times do |i|
#         expect(ewtx.utxos[i][:hash]).to eq(utxos[i][:hash])
#         expect(ewtx.utxos[i][:amount]).to eq(utxos[i][:amount])
#         expect(ewtx.utxos[i][:output_index]).to eq(utxos[i][:output_index])
#       end
#
#       # Save an unsigned transaction as hex for sharing with parties
#       psbt_hex = ewtx.dump(:btc_psbt_hex)
#
#       # User1 gets the transaction and signs it, then sends it back
#       u1_ewtx = described_class.load(psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet)
#       u1_ewtx.sign!(CoinCrypto::ExtendedPrivateKey.from_base58(user1_xpriv, 'secp256k1').private_key_hex)
#       u1_psbt_hex = u1_ewtx.dump(:btc_psbt_hex)
#
#       # User2 gets the transaction and signs it, then sends it back
#       u2_ewtx = described_class.load(psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet)
#       u2_ewtx.sign!(CoinCrypto::ExtendedPrivateKey.from_base58(user2_xpriv, 'secp256k1').private_key_hex)
#       u2_psbt_hex = u2_ewtx.dump(:btc_psbt_hex)
#
#       # User3 gets the transaction and signs it, then sends it back
#       u3_ewtx = described_class.load(psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet)
#       u3_ewtx.sign!(CoinCrypto::ExtendedPrivateKey.from_base58(user3_xpriv, 'secp256k1').private_key_hex)
#       u3_psbt_hex = u3_ewtx.dump(:btc_psbt_hex)
#
#       # Server reads all transactions received from users and combines them
#       ewtx.combine!(described_class.load(u1_psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet))
#       ewtx.combine!(described_class.load(u2_psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet))
#       ewtx.combine!(described_class.load(u3_psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet))
#
#       # Server generates a signed transaction
#       tx = ewtx.dump(:tx_hex)
#       expect(tx).to eq(
#         '010000000001059e0af3eebdff63e368d6fc3b985cb420068fb71' \
#         'e1d1123dca6458c0add11b1530000000023220020c6ac4fc8b673' \
#         'd5c192f749824896611c12f5c00ea140a9038ccad7e64c9b68c4f' \
#         'ffffffffa0f544042dbac7c94a0b51af10945acf5924589e88cc4' \
#         'afb2005e1c47e279510000000023220020c6ac4fc8b673d5c192f' \
#         '749824896611c12f5c00ea140a9038ccad7e64c9b68c4ffffffff' \
#         'c4f2aa5985156deeca30abd84c7ee01ba5c5fcee4788c82fe1039' \
#         '02b7eafa90a0100000023220020c6ac4fc8b673d5c192f7498248' \
#         '96611c12f5c00ea140a9038ccad7e64c9b68c4ffffffffd8d2c29' \
#         'e97b11ac60ff0aa87aed2900b9d3e7ef82e829d43d4515c0eb2b1' \
#         '71390000000023220020c6ac4fc8b673d5c192f749824896611c1' \
#         '2f5c00ea140a9038ccad7e64c9b68c4ffffffff747d4b13341ef7' \
#         'bd91362ab96e12e2eaeb87f93c4c6cb5a5537bcb1c0962fd48010' \
#         '0000023220020c6ac4fc8b673d5c192f749824896611c12f5c00e' \
#         'a140a9038ccad7e64c9b68c4ffffffff02a861000000000000197' \
#         '6a9145b572692f0929939afb3a6b6b767776ebe26fb8988ac704c' \
#         '0c0000000000220020c6ac4fc8b673d5c192f749824896611c12f' \
#         '5c00ea140a9038ccad7e64c9b68c4050047304402201683904208' \
#         '110ff72232e3db1fa2eb71f5a727bb75a0899ab88b026832365d4' \
#         '202202a49e9d361f989700198d60b19fe77e572295813e028e9d7' \
#         '1bea202fd08304d30148304502210089f83914149b12cb11b5327' \
#         '1b5afc61654587b6c2b1bd3bb49a43f6b5a893a7902205f27959d' \
#         'ea090cfed01c36534852322c4429ade9f418660e8b34aa2b58e60' \
#         'b4001483045022100ed0883f2029f6613c107f2818f0039340ab4' \
#         '584634bd9d4866342c36109907cc02205d14464b856a3b58e90cb' \
#         'cf60ba5c8ea96d31e964460775674dff6017755693e018b532102' \
#         '7effe510fafd1c3d2db0b2b2e9f7916ea2be5f94e20f75a9ba9e2' \
#         'b683917b8fd210283936a022bd9bbf9088394246154653be0174e' \
#         'ca7a46fc69e58add9a936b3ec7210313d2db5889e2fa5452857e9' \
#         'b2ddae829a19585e598c0a1277eb56ddf6687713021031a964279' \
#         'e91262f089de0a5d4e5a715277c3a3eb24dd943b503f638cf5d39' \
#         '9b054ae0500483045022100c4d9bd0ef6790cf212b310cef6f591' \
#         'ded71d4f11f0f4b74cc6bd8e4c2aa1a2d302202dd37b2c8f9ff4a' \
#         '6ec11f152c3088593d9ec68b96ff9b45462a6faa36a31c0650147' \
#         '304402207fd5fddd46e60ce269d2bb43b94464725ce5bead936c6' \
#         '70842a84313e2e6f0330220468e34f070c0ffc62d1b061627c66c' \
#         'dfd789d474c27fed175bb68d52f3827c2c0147304402205bd4c75' \
#         '11eb19c7729ba36c6deda8c1ac795e032a6818f0e4b654e269913' \
#         '6fe80220507c5cb46d939f4034d8a670ca23c787eee83e13319f8' \
#         '84a1627983bb7825128018b5321027effe510fafd1c3d2db0b2b2' \
#         'e9f7916ea2be5f94e20f75a9ba9e2b683917b8fd210283936a022' \
#         'bd9bbf9088394246154653be0174eca7a46fc69e58add9a936b3e' \
#         'c7210313d2db5889e2fa5452857e9b2ddae829a19585e598c0a12' \
#         '77eb56ddf6687713021031a964279e91262f089de0a5d4e5a7152' \
#         '77c3a3eb24dd943b503f638cf5d399b054ae0500483045022100d' \
#         '2438e7e475f33ccf21ef4dfbf1e2aa963e8e3936fa71881671c06' \
#         '3b52f97a6c0220401c074158098f46ec4fea2dce58447135f6a71' \
#         '7a9a30bcff45e71cb6fb7b48d01483045022100d80c5baeacde2c' \
#         '904a22521f2b9f084171c8570962d4a4ff4a5da9fcab26ea51022' \
#         '016cda045032c2cb16e3d9a939221af28984f79eb2dd5685dd3d5' \
#         'fd4fe36f80050147304402207fae304ea43b73868ce58752bd609' \
#         'f1f1ca0db385c82a599fe1851237eb2241702207bc854af22f329' \
#         'c8c37656d837d6ae54cb99b2cdbc10b67442a1250fdf6bbc63018' \
#         'b5321027effe510fafd1c3d2db0b2b2e9f7916ea2be5f94e20f75' \
#         'a9ba9e2b683917b8fd210283936a022bd9bbf9088394246154653' \
#         'be0174eca7a46fc69e58add9a936b3ec7210313d2db5889e2fa54' \
#         '52857e9b2ddae829a19585e598c0a1277eb56ddf6687713021031' \
#         'a964279e91262f089de0a5d4e5a715277c3a3eb24dd943b503f63' \
#         '8cf5d399b054ae0500473044022041a52405ff5f784f172da80c3' \
#         '6e5ec16a5a465685a96a9e2a694d184522f4472022026d70205ce' \
#         'dabb02282b70b79679af15929ec57624ed5ac4d604e923404532d' \
#         'd0147304402207f882fa63c3f4cc67f772d10b0d24bda94dbe242' \
#         '4decd9fd08ae5f7f178a2f9502207fb2d9b7f73c5e06a35345753' \
#         '14004367498c075889ce9d29305463a69fc85d801483045022100' \
#         '8c461db9c16b10e92ffc13a0164a6ab5dfb2ee549d02f68b90da8' \
#         '41894aa6610022009c55855d3cd64a51cdf03c58225ec96b3d724' \
#         'f61d87c2ba6fdc47e924c00f89018b5321027effe510fafd1c3d2' \
#         'db0b2b2e9f7916ea2be5f94e20f75a9ba9e2b683917b8fd210283' \
#         '936a022bd9bbf9088394246154653be0174eca7a46fc69e58add9' \
#         'a936b3ec7210313d2db5889e2fa5452857e9b2ddae829a19585e5' \
#         '98c0a1277eb56ddf6687713021031a964279e91262f089de0a5d4' \
#         'e5a715277c3a3eb24dd943b503f638cf5d399b054ae0500473044' \
#         '022023f7a9bd7f61a45650fa851d688e1685993c6ea6b3aa2e603' \
#         'aead92cc89b25ac02207e044a87a41f67a80f87d4c7411c8b557d' \
#         '928f919831bd1d4643c9143ea638280147304402206bddbf9f8b1' \
#         '6f00353cdfbf3737dcae3f5d6872594ada318b0be2507aceee02e' \
#         '0220177ad2661c2d28b5552271dfc820f9a4a6cd81157502cb03f' \
#         'e69eb4a944d2a7001473044022072653cfd679c224c38e5e5a12e' \
#         '1a8ec46bd2ca1db7726479690cc5875c2bc19102203ab2e4200b5' \
#         'b8ddd526d9abb262aba43e63010f7f6ac5456e78436c2dee41f6e' \
#         '018b5321027effe510fafd1c3d2db0b2b2e9f7916ea2be5f94e20' \
#         'f75a9ba9e2b683917b8fd210283936a022bd9bbf9088394246154' \
#         '653be0174eca7a46fc69e58add9a936b3ec7210313d2db5889e2f' \
#         'a5452857e9b2ddae829a19585e598c0a1277eb56ddf6687713021' \
#         '031a964279e91262f089de0a5d4e5a715277c3a3eb24dd943b503' \
#         'f638cf5d399b054ae00000000'
#       )
#       expect(ewtx.txid).to eq('b67204530f149cf1a4b97155cf9d1b760e7bd2a09728bd0edee9a04dd55997aa')
#       expect(ewtx.size).to eq(917)
#     end
#   end
#
#   context 'when 2 of 3 keys' do
#     let(:pubkeys) do
#       [user1_pubkey, user2_pubkey, user3_pubkey]
#     end
#
#     let(:xpubs_data) do
#       [[user1_xpub, user1_fingerprint, derivation],
#         [user2_xpub, user2_fingerprint, derivation],
#         [user3_xpub, user3_fingerprint, derivation]]
#     end
#
#     let(:escrow) do
#       CoinCrypto::Escrow.create(
#         blockchain_network: :btc_testnet,
#         kind: :p2wsh, m: 2,
#         public_keys: pubkeys,
#         extended_public_keys_with_master_fingerprint: xpubs_data,
#         sort_public_keys: true
#       )
#     end
#
#     let(:escrow_legacy) do
#       CoinCrypto::Escrow.create(
#         blockchain_network: :btc_testnet,
#         kind: :p2sh_p2wsh,
#         m: 2,
#         public_keys: pubkeys,
#         extended_public_keys_with_master_fingerprint: xpubs_data,
#         sort_public_keys: true
#       )
#     end
#
#     it 'creates an escrow withdrawal transaction' do
#       ewtx = described_class.from_escrow(escrow:,
#         recipients: withdraw_addresses,
#         utxos:)
#
#       expect(ewtx.escrow.address).to eq(escrow.address)
#       expect(ewtx.escrow.blockchain_network).to eq(escrow.blockchain_network)
#       expect(ewtx.escrow).to eq(escrow)
#
#       expect(ewtx.utxos.size).to eq(utxos.size)
#       utxos.length.times do |i|
#         expect(ewtx.utxos[i][:hash]).to eq(utxos[i][:hash])
#         expect(ewtx.utxos[i][:amount]).to eq(utxos[i][:amount])
#         expect(ewtx.utxos[i][:output_index]).to eq(utxos[i][:output_index])
#       end
#
#       # Save an unsigned transaction as hex for sharing with parties
#       psbt_hex = ewtx.dump(:btc_psbt_hex)
#
#       # User1 gets the transaction and signs it, then sends it back
#       u1_ewtx = described_class.load(psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet)
#       expect(ewtx.escrow.sorted_public_keys?).to eq(true)
#       u1_ewtx.sign!(CoinCrypto::ExtendedPrivateKey.from_base58(user1_xpriv, 'secp256k1').private_key_hex)
#       u1_psbt_hex = u1_ewtx.dump(:btc_psbt_hex)
#
#       # User2 gets the transaction and signs it, then sends it back
#       u2_ewtx = described_class.load(psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet)
#       expect(ewtx.escrow.sorted_public_keys?).to eq(true)
#       u2_ewtx.sign!(CoinCrypto::ExtendedPrivateKey.from_base58(user2_xpriv, 'secp256k1').private_key_hex)
#       u2_psbt_hex = u2_ewtx.dump(:btc_psbt_hex)
#
#       # Server reads all transactions received from users and combines them
#       ewtx.combine!(described_class.load(u1_psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet))
#       ewtx.combine!(described_class.load(u2_psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet))
#
#       # Server generates a signed transaction
#       tx = ewtx.dump(:tx_hex)
#       expect(tx).to eq(
#         '010000000001059e0af3eebdff63e368d6fc3b985cb420068fb71' \
#         'e1d1123dca6458c0add11b1530000000000fffffffffa0f544042' \
#         'dbac7c94a0b51af10945acf5924589e88cc4afb2005e1c47e2795' \
#         '10000000000ffffffffc4f2aa5985156deeca30abd84c7ee01ba5' \
#         'c5fcee4788c82fe103902b7eafa90a0100000000ffffffffd8d2c' \
#         '29e97b11ac60ff0aa87aed2900b9d3e7ef82e829d43d4515c0eb2' \
#         'b171390000000000ffffffff747d4b13341ef7bd91362ab96e12e' \
#         '2eaeb87f93c4c6cb5a5537bcb1c0962fd480100000000ffffffff' \
#         '02a8610000000000001976a9145b572692f0929939afb3a6b6b76' \
#         '7776ebe26fb8988ac704c0c0000000000220020573d071ebd85fc' \
#         'da30f19fbb06d486861d368d5308413b3950251d496674e4d0040' \
#         '048304502210081877810a630471abccf8302e8b26b436718ac0d' \
#         '506fdd54c9434ea23061cacd02205d687cdae7ff391da7e1cd505' \
#         'e4c10282b97d7ce4e7af62390763666252c5d1f01473044022039' \
#         'faa43a4acd5f9b152ae9f61b5bedbdb8ecc7b6f3df418efb21242' \
#         '38e37bfec02200f3f7e39c581ea3533e40451de409c705ae8b945' \
#         '1c332563c8fcdc6213075f2d01695221027effe510fafd1c3d2db' \
#         '0b2b2e9f7916ea2be5f94e20f75a9ba9e2b683917b8fd210313d2' \
#         'db5889e2fa5452857e9b2ddae829a19585e598c0a1277eb56ddf6' \
#         '687713021031a964279e91262f089de0a5d4e5a715277c3a3eb24' \
#         'dd943b503f638cf5d399b053ae040048304502210098b2ca2eff7' \
#         'b954445c19282fc3e12d6306877ebd14009013dd9848079c09e32' \
#         '02204e9c1bbf99024751a6394473a1a48ded14c1fcd6cf8bfaf21' \
#         '316037450bc8bea0147304402204f4ba48cc91e6accb318608962' \
#         'c70239da3d5b4e8ee5c21ca323d562f69acbe702201f31b9eb779' \
#         'cecd40429e6d0bd39798ca3472d5f55b84163c84d318cb7314636' \
#         '01695221027effe510fafd1c3d2db0b2b2e9f7916ea2be5f94e20' \
#         'f75a9ba9e2b683917b8fd210313d2db5889e2fa5452857e9b2dda' \
#         'e829a19585e598c0a1277eb56ddf6687713021031a964279e9126' \
#         '2f089de0a5d4e5a715277c3a3eb24dd943b503f638cf5d399b053' \
#         'ae0400483045022100dfc3272134cbce428cbfa7aeefaca7e1e30' \
#         'c84c77a8add78e1a6998b146d99ce02207a269e6badc2d4f7c958' \
#         'af9cdec8d48f8c9fe649298268e0ce16d3c3171e5d11014730440' \
#         '2206e4ad028bbc6c4213c1cc909b73905e55ddf60f922216837c2' \
#         'e623f3f194f050022035c2792a419b2ca76bda20208e92a8778e2' \
#         '3914de6433c63fda478c14db2921401695221027effe510fafd1c' \
#         '3d2db0b2b2e9f7916ea2be5f94e20f75a9ba9e2b683917b8fd210' \
#         '313d2db5889e2fa5452857e9b2ddae829a19585e598c0a1277eb5' \
#         '6ddf6687713021031a964279e91262f089de0a5d4e5a715277c3a' \
#         '3eb24dd943b503f638cf5d399b053ae0400483045022100e6e52e' \
#         '248a18d3178567548481c567af09917bfbc83a61536eb54f9985e' \
#         'c715002207524eff8e2127af33b49c8a0abb32ca7c1a45b9d2fe7' \
#         'a595e486dcaca96dd35e01483045022100a5bea9e35ca632a2e92' \
#         'ea63a91c011e7c4f95d1f40a54ddabc9e91f112dceb4d02204712' \
#         '10dc2c99bb3e6473566fe06e4f4e2996f69a2d2e49f3087e8c8a4' \
#         '308416301695221027effe510fafd1c3d2db0b2b2e9f7916ea2be' \
#         '5f94e20f75a9ba9e2b683917b8fd210313d2db5889e2fa5452857' \
#         'e9b2ddae829a19585e598c0a1277eb56ddf6687713021031a9642' \
#         '79e91262f089de0a5d4e5a715277c3a3eb24dd943b503f638cf5d' \
#         '399b053ae0400473044022000972ceb68787dce6d36bb4eb203bc' \
#         '3b001905b1f230ae5ef016f0e08b77094b0220036a50d7bc221fd' \
#         'b51daf9448bd89a029d06da9a0949f3f772e2694a367351bf0147' \
#         '30440220784dc03a17ce55ca94ddfdb33b294fe42eebbf551af6b' \
#         '75faf93c6511ef63ce9022071739ed44b8bdd8fe522f9e21a2d49' \
#         '9e2d4e1b71f0e044379565a2729f208b1a01695221027effe510f' \
#         'afd1c3d2db0b2b2e9f7916ea2be5f94e20f75a9ba9e2b683917b8' \
#         'fd210313d2db5889e2fa5452857e9b2ddae829a19585e598c0a12' \
#         '77eb56ddf6687713021031a964279e91262f089de0a5d4e5a7152' \
#         '77c3a3eb24dd943b503f638cf5d399b053ae00000000'
#       )
#       expect(ewtx.txid).to eq('12bb6b13777155044d8db5566f3dc56184f9f838a7ea5f399ccc91ca05747b56')
#       expect(ewtx.size).to eq(609)
#     end
#
#     it 'creates an escrow withdrawal transaction for p2sh_p2wsh' do
#       ewtx = described_class.from_escrow(escrow: escrow_legacy,
#         recipients: withdraw_addresses,
#         utxos:)
#
#       expect(escrow_legacy.address).to eq('2NC8tfWG7xm14Yvm4Zf6ZwhixNmGh1XHAbb')
#       expect(ewtx.escrow.address).to eq(escrow_legacy.address)
#       expect(ewtx.escrow.blockchain_network).to eq(escrow_legacy.blockchain_network)
#       expect(ewtx.escrow).to eq(escrow_legacy)
#
#       expect(ewtx.utxos.size).to eq(utxos.size)
#       utxos.length.times do |i|
#         expect(ewtx.utxos[i][:hash]).to eq(utxos[i][:hash])
#         expect(ewtx.utxos[i][:amount]).to eq(utxos[i][:amount])
#         expect(ewtx.utxos[i][:output_index]).to eq(utxos[i][:output_index])
#       end
#
#       # Save an unsigned transaction as hex for sharing with parties
#       psbt_hex = ewtx.dump(:btc_psbt_hex)
#
#       # User1 gets the transaction and signs it, then sends it back
#       u1_ewtx = described_class.load(psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet)
#       u1_ewtx.sign!(CoinCrypto::ExtendedPrivateKey.from_base58(user1_xpriv, 'secp256k1').private_key_hex)
#       u1_psbt_hex = u1_ewtx.dump(:btc_psbt_hex)
#
#       # User2 gets the transaction and signs it, then sends it back
#       u2_ewtx = described_class.load(psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet)
#       u2_ewtx.sign!(CoinCrypto::ExtendedPrivateKey.from_base58(user2_xpriv, 'secp256k1').private_key_hex)
#       u2_psbt_hex = u2_ewtx.dump(:btc_psbt_hex)
#
#       # Server reads all transactions received from users and combines them
#       ewtx.combine!(described_class.load(u1_psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet))
#       ewtx.combine!(described_class.load(u2_psbt_hex, format: :btc_psbt_hex, blockchain_network: :btc_testnet))
#
#       # Server generates a signed transaction
#       tx = ewtx.dump(:tx_hex)
#       expect(tx).to eq(
#         '010000000001059e0af3eebdff63e368d6fc3b985cb420068fb71' \
#         'e1d1123dca6458c0add11b1530000000023220020573d071ebd85' \
#         'fcda30f19fbb06d486861d368d5308413b3950251d496674e4d0f' \
#         'ffffffffa0f544042dbac7c94a0b51af10945acf5924589e88cc4' \
#         'afb2005e1c47e279510000000023220020573d071ebd85fcda30f' \
#         '19fbb06d486861d368d5308413b3950251d496674e4d0ffffffff' \
#         'c4f2aa5985156deeca30abd84c7ee01ba5c5fcee4788c82fe1039' \
#         '02b7eafa90a0100000023220020573d071ebd85fcda30f19fbb06' \
#         'd486861d368d5308413b3950251d496674e4d0ffffffffd8d2c29' \
#         'e97b11ac60ff0aa87aed2900b9d3e7ef82e829d43d4515c0eb2b1' \
#         '71390000000023220020573d071ebd85fcda30f19fbb06d486861' \
#         'd368d5308413b3950251d496674e4d0ffffffff747d4b13341ef7' \
#         'bd91362ab96e12e2eaeb87f93c4c6cb5a5537bcb1c0962fd48010' \
#         '0000023220020573d071ebd85fcda30f19fbb06d486861d368d53' \
#         '08413b3950251d496674e4d0ffffffff02a861000000000000197' \
#         '6a9145b572692f0929939afb3a6b6b767776ebe26fb8988ac704c' \
#         '0c0000000000220020573d071ebd85fcda30f19fbb06d486861d3' \
#         '68d5308413b3950251d496674e4d0040048304502210081877810' \
#         'a630471abccf8302e8b26b436718ac0d506fdd54c9434ea23061c' \
#         'acd02205d687cdae7ff391da7e1cd505e4c10282b97d7ce4e7af6' \
#         '2390763666252c5d1f01473044022039faa43a4acd5f9b152ae9f' \
#         '61b5bedbdb8ecc7b6f3df418efb2124238e37bfec02200f3f7e39' \
#         'c581ea3533e40451de409c705ae8b9451c332563c8fcdc6213075' \
#         'f2d01695221027effe510fafd1c3d2db0b2b2e9f7916ea2be5f94' \
#         'e20f75a9ba9e2b683917b8fd210313d2db5889e2fa5452857e9b2' \
#         'ddae829a19585e598c0a1277eb56ddf6687713021031a964279e9' \
#         '1262f089de0a5d4e5a715277c3a3eb24dd943b503f638cf5d399b' \
#         '053ae040048304502210098b2ca2eff7b954445c19282fc3e12d6' \
#         '306877ebd14009013dd9848079c09e3202204e9c1bbf99024751a' \
#         '6394473a1a48ded14c1fcd6cf8bfaf21316037450bc8bea014730' \
#         '4402204f4ba48cc91e6accb318608962c70239da3d5b4e8ee5c21' \
#         'ca323d562f69acbe702201f31b9eb779cecd40429e6d0bd39798c' \
#         'a3472d5f55b84163c84d318cb731463601695221027effe510faf' \
#         'd1c3d2db0b2b2e9f7916ea2be5f94e20f75a9ba9e2b683917b8fd' \
#         '210313d2db5889e2fa5452857e9b2ddae829a19585e598c0a1277' \
#         'eb56ddf6687713021031a964279e91262f089de0a5d4e5a715277' \
#         'c3a3eb24dd943b503f638cf5d399b053ae0400483045022100dfc' \
#         '3272134cbce428cbfa7aeefaca7e1e30c84c77a8add78e1a6998b' \
#         '146d99ce02207a269e6badc2d4f7c958af9cdec8d48f8c9fe6492' \
#         '98268e0ce16d3c3171e5d110147304402206e4ad028bbc6c4213c' \
#         '1cc909b73905e55ddf60f922216837c2e623f3f194f050022035c' \
#         '2792a419b2ca76bda20208e92a8778e23914de6433c63fda478c1' \
#         '4db2921401695221027effe510fafd1c3d2db0b2b2e9f7916ea2b' \
#         'e5f94e20f75a9ba9e2b683917b8fd210313d2db5889e2fa545285' \
#         '7e9b2ddae829a19585e598c0a1277eb56ddf6687713021031a964' \
#         '279e91262f089de0a5d4e5a715277c3a3eb24dd943b503f638cf5' \
#         'd399b053ae0400483045022100e6e52e248a18d3178567548481c' \
#         '567af09917bfbc83a61536eb54f9985ec715002207524eff8e212' \
#         '7af33b49c8a0abb32ca7c1a45b9d2fe7a595e486dcaca96dd35e0' \
#         '1483045022100a5bea9e35ca632a2e92ea63a91c011e7c4f95d1f' \
#         '40a54ddabc9e91f112dceb4d0220471210dc2c99bb3e6473566fe' \
#         '06e4f4e2996f69a2d2e49f3087e8c8a4308416301695221027eff' \
#         'e510fafd1c3d2db0b2b2e9f7916ea2be5f94e20f75a9ba9e2b683' \
#         '917b8fd210313d2db5889e2fa5452857e9b2ddae829a19585e598' \
#         'c0a1277eb56ddf6687713021031a964279e91262f089de0a5d4e5' \
#         'a715277c3a3eb24dd943b503f638cf5d399b053ae040047304402' \
#         '2000972ceb68787dce6d36bb4eb203bc3b001905b1f230ae5ef01' \
#         '6f0e08b77094b0220036a50d7bc221fdb51daf9448bd89a029d06' \
#         'da9a0949f3f772e2694a367351bf014730440220784dc03a17ce5' \
#         '5ca94ddfdb33b294fe42eebbf551af6b75faf93c6511ef63ce902' \
#         '2071739ed44b8bdd8fe522f9e21a2d499e2d4e1b71f0e04437956' \
#         '5a2729f208b1a01695221027effe510fafd1c3d2db0b2b2e9f791' \
#         '6ea2be5f94e20f75a9ba9e2b683917b8fd210313d2db5889e2fa5' \
#         '452857e9b2ddae829a19585e598c0a1277eb56ddf668771302103' \
#         '1a964279e91262f089de0a5d4e5a715277c3a3eb24dd943b503f6' \
#         '38cf5d399b053ae00000000'
#       )
#       expect(ewtx.txid).to eq('3ae21371b097b050a9b8c3f650233b27aeafc839ae1069ad8aeeb3eec4f9b6fd')
#       expect(ewtx.size).to eq(784)
#     end
#   end
#
#   it 'loads a valid psbt escrow transaction' do
#     valid_psbt_tx = '70736274ff01007e0000000001747d4b13341ef7bd91362ab96e12e2eaeb87f93c4c6cb5a5537bcb1' \
#       'c0962fd480100000000a85b010002102700000000000017a914e237b2aea3ad1bd1c49857593c0f0c' \
#       'ae9824db2487b030010000000000220020fcced1916be228e09fba5b6ff35202db779e2c6fb6d6260' \
#       '69337830b10bb3ac1000000000001012ba85b010000000000220020fcced1916be228e09fba5b6ff3' \
#       '5202db779e2c6fb6d626069337830b10bb3ac101058b53210394d30868076ab1ea7736ed3bdbec994' \
#       '97a6ad30b25afd709cdf3804cd389996a21032c58bc9615a6ff24e9132cef33f1ef373d97dc6da793' \
#       '3755bc8bb86dbee9f55c2102c4d72d99ca5ad12c17c9cfe043dc4e777075e8835af96f46d8e3ccd92' \
#       '9fe19262103fbb043cb850c0bbf912edd4a51014b23c8cda31aa84b9552f4a328f06bebfb3254ae00' \
#       '0000'
#
#     expect(described_class.valid?(valid_psbt_tx, format: :psbt_hex)).to be true
#   end
#
#   it 'loads an invalid psbt escrow transaction' do
#     invalid_psbt_tx = '70736274ff01007e0000000001747d4b13341ef7bd91362ab96e12e2eaeb87f93c4c6cb5a5537bcb1' \
#       'c0962fd480100000000a85b010002102700000000000017a914e237b2aea3ad1bd1c49857593c0f0c' \
#       'ae9824db2487b030010000000000220020fcced1916be228e09fba5b6ff35202db779e2c6fb6d6260' \
#       '69337830b10bb3ac1000000000001012ba85b010000000000220020fcced1916be228e09fba5b6ff3' \
#       '5202db779e2c6fb6d626069337830b10bb3ac101058b53210394d30868076ab1ea7736ed3bdbec994' \
#       '97a6ad30b25afd709cdf3804cd38999a21032c58bc9615a6ff24e9132cef33f1ef373d97dc6da793' \
#       '3755bc8bb86dbee9f55c2102c4d72d99ca5ad12c17c9cfe043dc4e777075e8835af96f46d8e3ccd92' \
#       '9fe19262103fbb043cb850c0bbf912edd4a51014b23c8cda31aa84b9552f4a328f06bebfb3254ae00' \
#       '0000'
#
#     expect(described_class.valid?(invalid_psbt_tx, :psbt_hex)).to be false
#   end
# end
