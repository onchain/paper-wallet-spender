require "./spec_helper"
  
describe OnChain::Protocol do

  # https://bitcoin.stackexchange.com/questions/71284/how-do-i-generate-the-bitcoin-cash-hash-preimage
  it "should correctly hash a bitcoin cash tx" do
  
    tx_hex = (<<-TX
      0100000001fb4a8e5c7ac5311f32fbe127f031134ee3e7490f3308ca19c567f78d6aa96d77
      0000000000ffffffff0100a00700000000001976a914a8e181e0847b495df439066ca8fb36
      ce093692be88ac00000000
    TX
    ).gsub(/\s+/, "")
    
    tx = OnChain::Protocol::BitcoinCashTransaction.new(tx_hex)
    
    tx.to_hex.should eq(tx_hex)
    
    tx.signature_hash_for_bitcoin_cash(0.to_u64, 
      BigInt.new(500000), 0.to_u32).should eq(
      "7bfb153ec3b8d977352e1e0c074d9552916c4d476ed7e356c94563a4085950cf")
  end

  
  it "should get a bitcoin cash balance" do

    balance = OnChain::AddressService.get_balance(
      OnChain::CoinType::Bitcoin_Cash, "38ty1qB68gHsiyZ8k3RPeCJ1wYQPrUCPPr")
    
    case balance
    when OnChain::Balance
      balance.balance.should be > 10020000
    else
      true.should eq(false)
    end
  end
  
end
