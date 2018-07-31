require "./spec_helper"
  
describe OnChain::Protocol do

  it "should correctly hash a bitcoin gold tx" do
  
    tx_hex = (<<-TX
      010000000153a20637bf666c28ceeb8142de0de72da5833de04223e1a51e83cc499ec35957
      000000001976a9148ac7591107aec68c282488cd74096014108844dd88acffffffff024042
      0f00000000001976a914e342b95d1a6391d1ecc04fe31d5e9655984ab8b888ac1655b74900
      0000001976a9148ac7591107aec68c282488cd74096014108844dd88ac00000000
    TX
    ).gsub(/\s+/, "")
    
    tx = OnChain::Protocol::BitcoinCashTransaction.new(tx_hex)
    
    tx.to_hex.should eq(tx_hex)
    
    tx.signature_hash_for_bitcoin_cash(0.to_u64, 
      BigInt.new(1237761638), 79.to_u32).should eq(
      "595f50b91736b0b883cb45591e849be51b112443fc10d7e8e84307d99c6e31a0")
  end
  
end
