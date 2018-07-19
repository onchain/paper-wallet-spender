require "./spec_helper"

describe OnChain::Protocol do

  it "should parse and re-generate zcash transaction" do
  
    pub_keys_hex = 
      ["028f883177988f212f2f1b89bc0aa1fb0683899c3665b62167b0daa998018f85d7"]
      
    dest_addr = "t1coURaGEsTgaG6Jp8Y2rA2sUppakecfJKC"
    
    fee_addr = "t1aZLWNcFHR3apVoMuAPzEjGbdbR2qGfcAw"
  
    unsigned_tx = OnChain::PaymentService.create(
      OnChain::CoinType::ZCash, 
      pub_keys_hex,
      dest_addr, 
      BigInt.new(100000), 
      BigInt.new(400000), 
      fee_addr, 40000)
    
    # 030000807082c40301f293c1b1d289fba09d0eb40a622a69f70f7b0e5bc3c77bca6ff6db543ce0a209010000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388acffffffff03a0860100000000001976a914cfa26596e91ba32e19b0c448523058059841cf8788ac801a0600000000001976a914b705b67a8c0caeb68bbafe8377da8c19aff1e2e788ac64952e00000000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac000000000000000000  
    unsigned_tx.txhex.should eq("")
  
  end
  
end