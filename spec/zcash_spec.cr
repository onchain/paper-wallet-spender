require "./spec_helper"

describe OnChain::Protocol do

  it "should parse and re-generate zcash transaction" do
  
    # Normal Zcash spend transaction.
    tx_hex = (<<-TX
      030000807082c4030138e86e187f471ce1ebbaf30463d9995bd56fdd49a25ed5269b148f30
      6245e06f010000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88acffffff
      ff03c0c62d00000000001976a914cfa26596e91ba32e19b0c448523058059841cf8788ac30
      750000000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88accb6a0700
      000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88ac00000000000000
      0000
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::Transaction.create(OnChain::CoinType::ZCash, tx_hex)
  
    tx.class.should eq(OnChain::Protocol::ZCashTransaction)
    
    tx.ver.should eq(2147483651)
    
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
      030000807082c40300028f739811893e0000095200ac6551ac636565b1a45a080575020002
      5151481cdd86b3cc431800
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::Transaction.create(OnChain::CoinType::ZCash, tx_hex)
  
    tx.class.should eq(OnChain::Protocol::ZCashTransaction)
    
    tx.ver.should eq(2147483651)
    
    tx.inputs.size.should eq(0)
    
    tx.outputs.size.should eq(2)
    
    tx.join_split_size.should eq(0)
    
    generated_tx = tx.to_hex
    
    tx.zcash_prev_outs.size.should eq(0)
    
    OnChain.to_hex(tx.zcash_hash_outputs).should eq("8f739811893e0000095200ac" +
      "6551ac636565b1a45a0805750200025151")
    
    tx_hex.should eq(generated_tx)
  end
  
  it "should work for zip143 test vector 2" do
  
    # Normal Zcash spend transaction.
    tx_hex = (<<-TX
      030000807082c403024201cfb1cd8dbf69b8250c18ef41294ca97993db546c1fe01f7e9c8e
      36d6a5e29d4e30a703ac6a0098421c69378af1e40f64e125946f62c2fa7b2fecbcb64b6968
      912a6381ce3dc166d56a1d62f5a8d7056363635353e8c7203d026af786387ae60100080063
      656a63ac520023752997f4ff0400075151005353656597b0e4e4c705fc0502
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::Transaction.create(OnChain::CoinType::ZCash, tx_hex)
  
    tx.class.should eq(OnChain::Protocol::ZCashTransaction)
    
    tx.ver.should eq(2147483651)
    
    tx.inputs.size.should eq(2)
    
    tx.outputs.size.should eq(2)
    
    tx.join_split_size.should eq(2)
    
    generated_tx = tx.to_hex
    
    OnChain.to_hex(tx.zcash_prev_outs).should eq("4201cfb1cd8dbf69b8250c18ef4" +
      "1294ca97993db546" +
      "c1fe01f7e9c8e36d6a5e29d4e30a7378af1e40f64e125946f62c2fa7b2fecbcb64b696" +
      "8912a6381ce3dc166d56a1d62f5a8d7")
    
    #puts tx.signature_hash_for_zcash(1, 365293780370497)
    
    tx_hex.should eq(generated_tx)
  end
  
  # https://raw.githubusercontent.com/zcash/zcash/master/src/test/data/sighash.json
  it "should work for zip143 test case" do
  
    # Normal Zcash spend transaction.
    tx_hex = (<<-TX
      030000807082c40302342847519a9e4b61b1cce0f76eae46c1a77dfe985e94285eed691faf
      36ebda1d01000000035352653387b4d6cc97bb48c00f6f31fd66c36452b4fbd9fd4d458fe3
      fbd5e6783f4794dc1ea9d80100000007ac5163ac006553ffffffff037bd1fe010000000003
      656553e5502c0200000000003203cb040000000003005163000000000000000000
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::Transaction.create(OnChain::CoinType::ZCash, tx_hex)
  
    tx.class.should eq(OnChain::Protocol::ZCashTransaction)
    
    tx.ver.should eq(2147483651)
    
    tx.inputs.size.should eq(2)
    
    tx.outputs.size.should eq(3)
    
    tx.join_split_size.should eq(0)
    
    generated_tx = tx.to_hex
    
    tx_hex.should eq(generated_tx)
  end
  
  it "should work for a tx we built" do
  
    tx_hex = (<<-TX
      030000807082c40301f293c1b1d289fba09d0eb40a622a69f70f7b0e5bc3c77bca6ff6db54
      3ce0a209010000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388acffffff
      ff03a0860100000000001976a914cfa26596e91ba32e19b0c448523058059841cf8788ac80
      1a0600000000001976a914b705b67a8c0caeb68bbafe8377da8c19aff1e2e788ac64952e00
      000000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac00000000000000
      0000
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::Transaction.create(OnChain::CoinType::ZCash, tx_hex)
    
    tx.ver.should eq(2147483651)
    
    generated_tx = tx.to_hex
    
    tx_hex.should eq(generated_tx)
    
  end
  
  it "should work for a tx we built with a hash we know works" do
  
    # From onchain-gem 
    tx_hex = (<<-TX
      030000807082c4030138e86e187f471ce1ebbaf30463d9995bd56fdd49a25ed5269b148f30
      6245e06f010000006a4730440220678a2c855cc6beead81aa3c3ddec2e465e9bc8f914cb1b
      49d7c4cea06f5bb7fd022037eca68d0e7515ca560f2cb98ca6f8973eaf4b140eda206c13fa
      565c8c116e8f012102a8c45cc289f1a2707f7df4ca5f12348d56e8f48ee9abe86d3b9213e1
      7922cbc8ffffffff03c0c62d00000000001976a914cfa26596e91ba32e19b0c44852305805
      9841cf8788ac30750000000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae6
      1c88accb6a0700000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88ac
      000000000000000000
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::Transaction.create(OnChain::CoinType::ZCash, tx_hex)
    
    tx.ver.should eq(2147483651)
    
    generated_tx = tx.to_hex
    
    tx_hex.should eq(generated_tx)
    
    #puts tx.signature_hash_for_zcash(1, 365293780370497)
    
  end
  
end
