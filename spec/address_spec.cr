require "./spec_helper"

describe OnChain do

  it "should parse and create vaid addresses" do
  
    OnChain::Protocol::Address.new(OnChain::CoinType::Bitcoin,
      "17iESYBf7CQMxCxdabiMfjZRDniGDZkyX3").to_s.should eq(
      "17iESYBf7CQMxCxdabiMfjZRDniGDZkyX3")
    
    OnChain::Protocol::Address.new(OnChain::CoinType::Bitcoin,
      "36owNcemLHrqW6XXFWyXeedQoErSBWTQFE").to_s.should eq(
      "36owNcemLHrqW6XXFWyXeedQoErSBWTQFE")
    
    OnChain::Protocol::Address.new(OnChain::CoinType::Bitcoin,
      "1BgGZ9tcN4rm9KBzDn7KprQz87SZ26SAMH").to_s.should eq(
      "1BgGZ9tcN4rm9KBzDn7KprQz87SZ26SAMH")
    
    OnChain::Protocol::Address.new(OnChain::CoinType::Bitcoin,
      "3LRW7jeCvQCRdPF8S3yUCfRAx4eqXFmdcr").to_s.should eq(
      "3LRW7jeCvQCRdPF8S3yUCfRAx4eqXFmdcr")
    
    OnChain::Protocol::Address.new(OnChain::CoinType::Litecoin,
      "MCZjFcwYJwwYqXAbd3bbnxaCVGs81cp43Z").to_s.should eq(
      "MCZjFcwYJwwYqXAbd3bbnxaCVGs81cp43Z")
    
    OnChain::Protocol::Address.new(OnChain::CoinType::Litecoin,
      "LUxXFcwXFPpRZdMv4aYu6bDwPdC2skQ5YW").to_s.should eq(
      "LUxXFcwXFPpRZdMv4aYu6bDwPdC2skQ5YW")
    
    OnChain::Protocol::Address.new(OnChain::CoinType::Testnet3,
      "mrCDrCybB6J1vRfbwM5hemdJz73FwDBC8r").to_s.should eq(
      "mrCDrCybB6J1vRfbwM5hemdJz73FwDBC8r")
    
    OnChain::Protocol::Address.new(OnChain::CoinType::Testnet3,
      "2NByiBUaEXrhmqAsg7BbLpcQSAQs1EDwt5w").to_s.should eq(
      "2NByiBUaEXrhmqAsg7BbLpcQSAQs1EDwt5w")
  end
end