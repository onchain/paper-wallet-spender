require "./spec_helper"
  
describe OnChain::Protocol do

  it "should parse and re-generate utxo p2sh transaction" do
  
    # Bitcoin with one output a p2sh
    tx_hex = (<<-TX
      0100000001acc6fb9ec2c3884d3a12a89e7078c83853d9b7912281cefb14bac00a2737d33a
      000000008a47304402204e63d034c6074f17e9c5f8766bc7b5468a0dce5b69578bd08554e8
      f21434c58e0220763c6966f47c39068c8dcd3f3dbd8e2a4ea13ac9e9c899ca1fbc00e2558c
      bb8b01410431393af9984375830971ab5d3094c6a7d02db3568b2b06212a7090094549701b
      bb9e84d9477451acc42638963635899ce91bacb451a1bb6da73ddfbcf596bddfffffffff01
      400001000000000017a9141a8b0026343166625c7475f01e48b5ede8c0252e8700000000 
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::UTXOTransaction.new(tx_hex)
  
    tx.class.should eq(OnChain::Protocol::UTXOTransaction)
    
    tx.ver.should eq(1)
    
    tx.inputs.size.should eq(1)
    
    tx.outputs.size.should eq(1)
    
    tx.outputs[0].value.should eq(65600)
    
    tx_hex.should eq(tx.to_hex)
  end
  
end
