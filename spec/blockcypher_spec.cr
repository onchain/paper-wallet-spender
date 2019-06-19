require "./spec_helper"
  
describe OnChain::Protocol do

  it "should correctly retrieve a bitcoin testnet balance" do
    balance = OnChain::AddressService.get_balance(
      OnChain::CoinType::Testnet3, "mtXWDB6k5yC5v7TcwKZHB89SUp85yCKshy")
    
    case balance
    when OnChain::Balance
      balance.balance.should be > 10020000
    else
    puts balance
      true.should eq(false)
    end
  end
  
  it "should get bitcoin testnet unspent ous" do

    unspents = OnChain::PROVIDERS[OnChain::CoinType::Testnet3].get_unspent_outs(
      OnChain::CoinType::Testnet3, 
      ["mtXWDB6k5yC5v7TcwKZHB89SUp85yCKshy"])
    
    case unspents
    when Array(OnChain::UnspentOut)
      unspents.size.should be > 1
    else
      puts unspents
      true.should eq(false)
    end

  end
  
  it "should get bitcoin testnet tx history" do

    history = OnChain::PROVIDERS[OnChain::CoinType::Testnet3].address_history(
      OnChain::CoinType::Testnet3, 
      ["mtXWDB6k5yC5v7TcwKZHB89SUp85yCKshy"])
    
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
    
    push_tx = OnChain::PROVIDERS[OnChain::CoinType::Testnet3].push_tx(
      OnChain::CoinType::Testnet3, tx_hex)
    
    push_tx.to_json.should eq("{\"status_code\":400,\"message\":\"{\\\"error\\\":\\\"Missing inputs\\\"}\"}")


  end
  
end
