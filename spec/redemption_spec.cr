require "./spec_helper"

describe OnChain do

  it "generate correct redemption scripts and addresses" do
  
    pk1 = "02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4"
    pk2 = "0396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf99"
    
    rs = OnChain::Protocol::RedemptionScript.new(2, [pk1, pk2])
    
    buffer = IO::Memory.new
    rs.to_buffer(buffer)
    
    rs_hex = OnChain.to_hex(buffer.to_slice)
    
    redemption_script = (<<-REDEMPTION_SCRIPT
      522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc42103
      96e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952ae
    REDEMPTION_SCRIPT
    ).gsub(/\s+/, "") 
    
    rs_hex.should eq(redemption_script)
    
    rs.to_address(OnChain::CoinType::Bitcoin).should eq(
      "34rNLSmvXiHqQAGJfAeGF7bxoYj8KYfLvU")
  end
end