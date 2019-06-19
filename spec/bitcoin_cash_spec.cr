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

  
  it "should get a bitcoin cash balances for a number of addresses" do

    balance = OnChain::AddressService.get_balance(
      OnChain::CoinType::Bitcoin_Cash, ["38ty1qB68gHsiyZ8k3RPeCJ1wYQPrUCPPr",
        "bitcoincash:pqkh9ahfj069qv8l6eysyufazpe4fdjq3u4hna323j"])
    
    case balance
    when NamedTuple(totals: OnChain::Balance, addresses: Array(OnChain::Balance))
      balance[:totals].balance.should be > 10020000
    else
      true.should eq(false)
    end
  end
  
  it "should get bitcoin cash unspent ous" do

    unspents = OnChain::PROVIDERS[OnChain::CoinType::Bitcoin_Cash].get_unspent_outs(
      OnChain::CoinType::Bitcoin_Cash, 
      ["38ty1qB68gHsiyZ8k3RPeCJ1wYQPrUCPPr"])
    
    case unspents
    when Array(OnChain::UnspentOut)
      unspents.size.should be > 1
    else
      puts unspents
      true.should eq(false)
    end
  end
  
  it "should get bitcoin cash tx history" do

    history = OnChain::PROVIDERS[OnChain::CoinType::Bitcoin_Cash].address_history(
      OnChain::CoinType::Bitcoin_Cash, 
      [
        "bitcoincash:qzs02v05l7qs5s24srqju498qu55dwuj0cx5ehjm2c",
        "bitcoincash:qrehqueqhw629p6e57994436w730t4rzasnly00ht0"
      ])
    
    case history
    when OnChain::History
      history.txs.size.should be > 1
    else
      puts history
      true.should eq(false)
    end
  end
  
  it "should send a tx" do

    tx_hex = (<<-TX
      01000000013ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a
      000000006a4730440220540986d1c58d6e76f8f05501c520c38ce55393d0ed7ed3c3a82c69
      af04221232022058ea43ed6c05fec0eccce749a63332ed4525460105346f11108b9c26df93
      cd72012103083dfc5a0254613941ddc91af39ff90cd711cdcde03a87b144b883b524660c39
      ffffffff01807c814a000000001976a914d7e7c4e0b70eaa67ceff9d2823d1bbb9f6df9a51
      88ac00000000
    TX
    ).gsub(/\s+/, "")
    
    push_tx = OnChain::PROVIDERS[OnChain::CoinType::Bitcoin_Cash].push_tx(
      OnChain::CoinType::Bitcoin_Cash, tx_hex)
    
    push_tx.to_json.should eq("{\"status_code\":400,\"message\":\"{\\\"error\\\":\\\"Missing inputs\\\"}\"}")
  end
  
end
