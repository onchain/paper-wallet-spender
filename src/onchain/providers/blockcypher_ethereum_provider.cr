require "./provider"

module OnChain

  class BlockCypherEthereumProvider < Provider
    
    def initialize(rate_provider : RateProvider)
      @rate_provider = rate_provider
    end
  
    def get_balance(coin : CoinType, address : String, set_rate = true)
    
      balance = make_request("addrs/#{address}/balance?token=#{OnChain::BLOCKCYPHER_API_TOKEN}")
      
      case balance
      when String
        bal_as_string = balance.split("\"final_balance\": ")[1].split(",")[0]
        bal = BigInt.new(bal_as_string)
        hbal = bal.to_f64 / OnChain::WEI_PER_ETHER.to_f64
        usd_balance = 0.0.to_f64
        
        if set_rate
          rate = @rate_provider.get_rate(coin)
          usd_balance = (hbal * rate).to_f64
        end
        
        return Balance.new bal, bal, hbal.to_f64, hbal.to_f64, usd_balance
      end
      return NodeStatus.new 0, "Error retrieving address"
    end
    
    def address_history(coin : CoinType, addresses : Array(String))
    
      comma_addresses = addresses.join(",")
        
      history = make_request("addrs/#{comma_addresses}?limit=10")
      
      case history
      when String
        history = convert_int_to_strings(history)
        return OnChain::History.from_blockcypher_json(JSON.parse(history), addresses)
      end
      return NodeStatus.new history, "Error retrieving history"
    
    end
    
    def push_tx(coin : CoinType, tx_hex : String)
    
      if tx_hex.starts_with? "0x"
        tx_hex = tx_hex.gsub("0x", "")
      end
    
      post_eth_request(coin, 
        "txs/push?token=#{OnChain::BLOCKCYPHER_API_TOKEN}", tx_hex)
          
    end
    
    def parse_answer(answer : String) : String
    
      json = JSON.parse answer
      
      if json["error"]? != nil
        return json["error"].as_s
      end
      
      if json["tx"]? != nil && json["tx"]["hash"]? != nil
        return json["tx"]["hash"].as_s
      end
      
      return answer
    
    end
    
    private def post_eth_request(coin, path : String, tx_hex : String)
    
      # At the moment just get the first provider. Later we can failover.
      url = "https://api.blockcypher.com/v1/eth/main/"
      
      msg = {tx: tx_hex}.to_json
      
      puts msg
    
      response = HTTP::Client.post url + path, body: msg
      
      parsed_response = parse_answer(response.body)
      
      return NodeStatus.new response.status_code, parsed_response
    end
    
    private def make_request(path : String)
    
      # At the moment just get the first provider. Later we can failover.
      url = "https://api.blockcypher.com/v1/eth/main/"
      
      puts url + path
    
      response = HTTP::Client.get url + path
      if response.status_code == 200
        return response.body
      end
      return response.status_code
    end
    
    # Values are too large for Json::Any to handle
    private def convert_int_to_strings(history : String)
    
      split = "value\":"

      new_hist = ""
      
      history.lines.each do |line|
        if line.split(split).size > 1
          val = line.split(split)[1].strip
          val = val.split(",")[0]
          new_hist = new_hist + line.gsub(val, "\"" + val + "\"")
        else
          new_hist = new_hist + line
        end
      end
      
      return new_hist
    end
    
  end
  
end