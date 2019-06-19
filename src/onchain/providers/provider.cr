module OnChain

  abstract class Provider

    abstract def get_balance(coin : CoinType, address : String, set_rate = true) : NodeStatus | Balance

    abstract def address_history(coin : CoinType, addresses : Array(String)) : NodeStatus | History

    abstract def push_tx(coin : CoinType, tx_hex : String) : NodeStatus
  end

end
