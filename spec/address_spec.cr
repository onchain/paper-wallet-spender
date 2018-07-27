require "./spec_helper"

describe OnChain do

  it "should parse and create vaid addresses" do
  
    addr = OnChain::Protocol::Address.new(OnChain::CoinType::Bitcoin,
      "17iESYBf7CQMxCxdabiMfjZRDniGDZkyX3")
    
    addr.to_s.should eq("17iESYBf7CQMxCxdabiMfjZRDniGDZkyX3")
    
  
    addr = OnChain::Protocol::Address.new(OnChain::CoinType::Bitcoin,
      "36owNcemLHrqW6XXFWyXeedQoErSBWTQFE")
    
    addr.to_s.should eq("36owNcemLHrqW6XXFWyXeedQoErSBWTQFE")
  end
end