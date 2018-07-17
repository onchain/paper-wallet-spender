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
  
end
