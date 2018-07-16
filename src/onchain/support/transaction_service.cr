module OnChain
  class TransactionService
  
    def self.send(coin, txhex)
    
      result = if coin == CoinType::Ethereum
        ETHEREUM_PROVIDER.push_tx(coin, txhex)
      else
        PROVIDERS[coin].push_tx(coin, txhex)
      end
      
      return result
    end
    
  end
end # end module