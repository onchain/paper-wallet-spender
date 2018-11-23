require "./spec_helper"
  
describe OnChain::Protocol do

  it "should parse and re-generate zcash transaction" do
  
    # Normal Zcash spend transaction.
    tx_hex = (<<-TX
      040000807082c4030138e86e187f471ce1ebbaf30463d9995bd56fdd49a25ed5269b148f30
      6245e06f010000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88acffffff
      ff03c0c62d00000000001976a914cfa26596e91ba32e19b0c448523058059841cf8788ac30
      750000000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88accb6a0700
      000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88ac00000000000000
      000000000000000000000000
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::ZCashTransaction.new(tx_hex)
  
    tx.class.should eq(OnChain::Protocol::ZCashTransaction)
    
    tx.ver.should eq(0x80000004)
    tx.version_group_id.should eq(63210096)
    
    tx.inputs.size.should eq(1)
    
    tx.outputs.size.should eq(3)
    
    tx.join_split_size.should eq(0)
    
    tx.outputs[0].value.should eq(3000000)
    tx.outputs[1].value.should eq(30000)
    tx.outputs[2].value.should eq(486091)
    
    generated_tx = tx.to_hex
    
    tx_hex.should eq(generated_tx)
  end
  
  it "should work for zip143 test vector 1" do
  
    # Normal Zcash spend transaction.
    tx_hex = (<<-TX
      040000807082c40300028f739811893e0000095200ac6551ac636565b1a45a080575020002
      5151481cdd86b3cc43180000000000000000000000
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::ZCashTransaction.new(tx_hex)
  
    tx.class.should eq(OnChain::Protocol::ZCashTransaction)
    
    tx.ver.should eq(0x80000004)
    
    tx.inputs.size.should eq(0)
    
    tx.outputs.size.should eq(2)
    
    tx.join_split_size.should eq(0)
    
    the_hash = tx.signature_hash_for_zcash(0, BigInt.new(0), false)
      
    the_hash.should eq(
      "9e62426d4725dab2dc339fb228e693f94942b40bde9d71308616b9453c887f56")
    
    generated_tx = tx.to_hex
    
    OnChain.to_hex(tx.zcash_outputs_hash).should eq(
      "ec55f4afc6cebfe1c35bdcded7519ff6efb381ab1d5a8dd0060c13b2a512932b")
    
    tx_hex.should eq(generated_tx)
  end
  
  it "should work for zip0243 test vector 3" do
  
    # Normal Zcash spend transaction.
    tx_hex = (<<-TX
    0400008085202f8901a8c685478265f4c14dada651969c45a65e1aeb8cd6791f2f5bb6a1d995
    2104d9010000006b483045022100a61e5d557568c2ddc1d9b03a7173c6ce7c996c4daecab007
    ac8f34bee01e6b9702204d38fdc0bcf2728a69fde78462a10fb45a9baa27873e6a5fc45fb5c7
    6764202a01210365ffea3efa3908918a8b8627724af852fc9b86d7375b103ab0543cf418bcaa
    7ffeffffff02005a6202000000001976a9148132712c3ff19f3a151234616777420a6d7ef226
    88ac8b959800000000001976a9145453e4698f02a38abdaa521cd1ff2dee6fac187188ac29b0
    040048b004000000000000000000000000
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::ZCashTransaction.new(tx_hex)
  
    tx.class.should eq(OnChain::Protocol::ZCashTransaction)
    
    tx.ver.should eq(0x80000004)
    
    tx.inputs.size.should eq(1)
    
    tx.outputs.size.should eq(2)
    
    tx.join_split_size.should eq(0)
    
    generated_tx = tx.to_hex
    
    tx_hex.should eq(generated_tx)
    
    OnChain.to_hex(tx.zcash_prev_outs_hash).should eq(
      "fae31b8dec7b0b77e2c8d6b6eb0e7e4e55abc6574c26dd44464d9408a8e33f11")
      
    the_hash = tx.signature_hash_for_zcash(0, BigInt.new(0x0000000002fa0f80))

    # Not sure if this is right. Need to find another test case.
    the_hash.should eq(
      "291014a76f55ddd0e88322156a26deb1c038afc020c0146f40beab42bbdca673")
  end
  
  # https://raw.githubusercontent.com/zcash/zcash/master/src/test/data/sighash.json
  it "should work for zip143 test case" do
  
    # Normal Zcash spend transaction.
    tx_hex = (<<-TX
      040000807082c40304334772ab2297c64a8a1ae8526c4bf136cf4f4e30206e4658eebc7c66
      0e57e3a00200000007635165636a5200ffffffffadb19de7fcdf37b02ebef327d92eef9699
      1a6cdf151d0d931161026d584321bd000000000552000052007e7ad2a4f540e8d0b4ccba4a
      fbc94d452289d7b380c8fdad7121552b3ed07740b5d21f76020000000551ac6a00004b585c
      eea4909de7ecb564f42899c0f4ccc9ebd406f0e0f19aacf83945a713158051d64d02000000
      00ffffffff0213eb07000000000001538046e20500000000026a657be3223f000000000000
      000000000000000000
    TX
    ).gsub(/\s+/, "")
    
    tx = OnChain::Protocol::ZCashTransaction.new(tx_hex)
  
    tx.class.should eq(OnChain::Protocol::ZCashTransaction)
    
    tx.ver.should eq(0x80000004)
    
    tx.inputs.size.should eq(4)
    
    tx.outputs.size.should eq(2)
    
    tx.join_split_size.should eq(0)
    
    generated_tx = tx.to_hex
    
    tx_hex.should eq(generated_tx)
  end
  
  it "should work for a tx we built" do
  
    tx_hex = (<<-TX
      040000807082c40301f293c1b1d289fba09d0eb40a622a69f70f7b0e5bc3c77bca6ff6db54
      3ce0a209010000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388acffffff
      ff03a0860100000000001976a914cfa26596e91ba32e19b0c448523058059841cf8788ac80
      1a0600000000001976a914b705b67a8c0caeb68bbafe8377da8c19aff1e2e788ac64952e00
      000000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac00000000000000
      000000000000000000000000
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::ZCashTransaction.new(tx_hex)
    
    tx.ver.should eq(0x80000004)
    
    generated_tx = tx.to_hex
    
    tx_hex.should eq(generated_tx)
    
  end
  
  it "should work for a tx we built with a hash we know works" do
  
    # From onchain-gem 
    tx_hex = (<<-TX
      040000807082c4030138e86e187f471ce1ebbaf30463d9995bd56fdd49a25ed5269b148f30
      6245e06f010000006a4730440220678a2c855cc6beead81aa3c3ddec2e465e9bc8f914cb1b
      49d7c4cea06f5bb7fd022037eca68d0e7515ca560f2cb98ca6f8973eaf4b140eda206c13fa
      565c8c116e8f012102a8c45cc289f1a2707f7df4ca5f12348d56e8f48ee9abe86d3b9213e1
      7922cbc8ffffffff03c0c62d00000000001976a914cfa26596e91ba32e19b0c44852305805
      9841cf8788ac30750000000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae6
      1c88accb6a0700000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88ac
      00000000000000000000000000000000000000
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::ZCashTransaction.new(tx_hex)
    
    tx.ver.should eq(0x80000004)
    
    generated_tx = tx.to_hex
    
    tx_hex.should eq(generated_tx)
    
    #puts tx.signature_hash_for_zcash(1, 365293780370497)
    
  end
  
end
