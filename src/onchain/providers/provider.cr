module OnChain

  abstract class Provider
  
    abstract def get_balance(coin : CoinType, address : String, set_rate = true)
    
    abstract def address_history(coin : CoinType, addresses : Array(String))
    
    abstract def push_tx(coin : CoinType, tx_hex : String)
  end
  
end