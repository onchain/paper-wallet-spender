require "./spec_helper"

describe OnChain do

  it "generate a bitcoin address" do
  
    address = OnChain::Protocol::Network.pubhex_to_address(
      OnChain::CoinType::Bitcoin,
      "0250863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b2352")
     
    address.should eq("1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs")
    
    address = OnChain::Protocol::Network.pubhex_to_address(
      OnChain::CoinType::Bitcoin,
      "0450863AD64A87AE8" +
      "A2FE83C1AF1A8403CB53F53E486D8511DAD8A04887E5B23522CD470243453A299FA9E7" +
      "7237716103ABC11A1DF38855ED6F2EE187E9C582BA6")
      
    address.should eq("16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM")
  end

  it "generate a zcash address" do
  
    address = OnChain::Protocol::Network.pubhex_to_address(
      OnChain::CoinType::ZCash,
      "028f883177988f212f2f1b89bc0aa1fb0683899c3665b62167b0daa998018f85d7")
     
    address.should eq("t1PBnMCVWU9GDTLpW8YTqo71MZPWRkmKidQ")
  end

  it "turn an address into a hash160" do
  
    address = OnChain::Protocol::Network.address_to_hash160(
      OnChain::CoinType::ZCash, "t1PBnMCVWU9GDTLpW8YTqo71MZPWRkmKidQ")
     
    address.should eq("b83a48bfebcdc52c7b3831eab75a1955e58744c7e3dec366f3")
  end
end