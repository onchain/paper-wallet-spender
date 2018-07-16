module OnChain
  class AddressService
  
    def self.get_balance(coin, address, set_rate = true, decimal_places = 0, contract_id = "")
    
      if coin != OnChain::CoinType::Ethereum
      
        return PROVIDERS[coin].get_balance(coin, address, set_rate)
      
      elsif contract_id && address && decimal_places && contract_id != ""
      
        # ERC20
      
        bal = call_ruby_token_balance(address, contract_id)
        
        case bal
        when BigInt
        
          hbal = bal.to_f64 / (10 ** decimal_places.to_f64).to_f64
          
          return Balance.new bal, bal, hbal.to_f64, hbal.to_f64, 0.0
        end
        return NodeStatus.new 0, "Error retrieving token balance"
        
      else
      
        # Ethereum
        return ETHEREUM_PROVIDER.get_balance(coin, address, set_rate)
        
      end
    end
  
    def self.get_balance(coin, addresses : Array(String), decimal_places = 0, contract_id = "")
    
      balances = [] of Balance
      
      bal = BigInt.new 0
      unconfirmed = BigInt.new 0
      
      addresses.each do |address|
        balance = get_balance(coin, address, false, decimal_places, contract_id)
        case balance
        when Balance
          balance.address = address
          balances << balance
          bal += balance.balance
          unconfirmed += balance.unconfirmed_balance
        when NodeStatus
          return balance
        end
      end
      
      hbal = if coin == OnChain::CoinType::Ethereum
        bal.to_f64 / OnChain::WEI_PER_ETHER.to_f64
      else
        bal.to_f64 / OnChain::SATOSHI_PER_BITCOIN.to_f64
      end
      
      h_unc = if coin == OnChain::CoinType::Ethereum
        unconfirmed.to_f64 / OnChain::WEI_PER_ETHER.to_f64
      else
        unconfirmed.to_f64 / OnChain::SATOSHI_PER_BITCOIN.to_f64
      end
          
      rate = contract_id != "" ? 0.0.to_f64 : RATE_PROVIDER.get_rate(coin)
      usd_balance = (rate * hbal).to_f64
      
      total_balance = Balance.new bal, unconfirmed, hbal, h_unc, usd_balance
      
      return { totals: total_balance, addresses: balances }
      
    end
    
    def self.get_history(coin, addresses : Array(String), 
      decimal_places = 0, contract_id = "")
    
      begin
      
        if coin != OnChain::CoinType::Ethereum
        
          return PROVIDERS[coin].address_history(coin, addresses)
        
        elsif contract_id && decimal_places && contract_id != ""
        
          # Tokens
          return OnChain::History.new 0, [] of Transaction
        
        else
        
          # Ethereum
          return ETHEREUM_PROVIDER.address_history(coin, addresses)
          
        end
        
      rescue e
        return NodeStatus.new 0, e.to_s + ' ' + e.backtrace.to_s
      end
    end
    
    private def self.call_ruby_token_balance(address : String, contract_id : String)
    
  
      parameters = ["exec", "ruby", "bin/token_balance.rb"]
    
      parameters << "-a"
      parameters << address
      parameters << "-c"
      parameters << contract_id
      
      puts parameters.join(' ')
      
      output = IO::Memory.new
      result = Process.run "bundle", parameters, output: output
      output.close
    
      return BigInt.new output.to_s
    end
    
    def self.get_unspent_outs(coin, addresses : Array(String))
    
      return PROVIDERS[coin].get_unspent_outs(coin, addresses)
      
    end
    
  end
end # end module