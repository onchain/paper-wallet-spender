require "./spec_helper"
  
describe OnChain::Protocol do

  it "should sign a single sig tx" do
  
    tx_hex = (<<-TX
      0100000001137eae1968bb544b20f6eae79272d541cee6cf71beba8020a4f971d75f6a2256
      440000001976a91463bf46a9d042006ac36b368133d01026a3d18e7888acffffffff034042
      0f00000000001976a91467268a54d6f3953811421233926cecb4f59b2e4488ac0ca8050000
      0000001976a914c040cbbcdbf5cb6a06ffd800b51990381fa8b2df88aca6efef3100000000
      1976a91463bf46a9d042006ac36b368133d01026a3d18e7888ac00000000 
    TX
    ).gsub(/\s+/, "")
  
    tx_signed = (<<-TX
      0100000001137eae1968bb544b20f6eae79272d541cee6cf71beba8020a4f971d75f6a2256
      440000006b483045022100f7c70d5678fb2322f6bce3c5d0ee2bd7a07435e22b4402aea75d
      c1e8f2d31f63022020562012d200e650c9df4d56060708c38c72ba6874f5fc3f9f88b19f6b
      434a70012103ab4284e59a1724f1f0f58114abfc4f34a98478972d5b8c67608a67a10e188b
      9affffffff0340420f00000000001976a91467268a54d6f3953811421233926cecb4f59b2e
      4488ac0ca80500000000001976a914c040cbbcdbf5cb6a06ffd800b51990381fa8b2df88ac
      a6efef31000000001976a91463bf46a9d042006ac36b368133d01026a3d18e7888ac000000
      00 
    TX
    ).gsub(/\s+/, "")
    
    tx_to_sign = OnChain::Protocol::UTXOTransaction.new(tx_hex)
    
    sig = OnChain::Protocol::Signature.new(
      "03ab4284e59a1724f1f0f58114abfc4f34a98478972d5b8c67608a67a10e188b9a",
      0, 
      "3045022100f7c70d5678fb2322f6bce3c5d0ee2bd7a07435e22b4402aea75dc1e8f2" +
      "d31f63022020562012d200e650c9df4d56060708c38c72ba6874f5fc3f9f88b19f6b" +
      "434a70")
      
    tx_to_sign.sign([sig])
    
    tx_to_sign.to_hex.should eq(tx_signed)
    
  end

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
