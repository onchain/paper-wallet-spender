require "./utxo_provider"
require "./rate_provider"

module OnChain
  
  class InsightProvider < UTXOProvider
  
    def initialize(url : String, rate_provider : RateProvider)
      @url = url
      @rate_provider = rate_provider
    end
  
    def get_balance(coin : CoinType, address : String, set_rate = true)
    
      balance = make_request("addr/#{address}/balance", @url)
      
      case balance
      when String
        bal = balance.to_u64
        hbal = bal / 1_00_000_000.0
        usd_balance = 0.0.to_f64
        
        if set_rate
          rate = @rate_provider.get_rate(coin)
          usd_balance = (hbal * rate).to_f64
        end
        
        return Balance.new BigInt.new(bal),  BigInt.new(bal), hbal, hbal, usd_balance
      end
      return NodeStatus.new balance, "Error retrieving address"
    end
    
    def address_history(coin : CoinType, addresses : Array(String))
    
      comma_addresses = addresses.join(",")
      
      history = make_request("addrs/#{comma_addresses}/txs?from=0&to=10", @url)
      
      case history
      when String
        return OnChain::History.from_insight_json(JSON.parse(history), addresses)
      end
      return NodeStatus.new history, "Error retrieving history"
    
    end
    
    def get_unspent_outs(coin : CoinType, addresses : Array(String))
    
      comma_addresses = addresses.join(",")
      
      utxos = make_request("addrs/#{comma_addresses}/utxo", @url)
      
      case utxos
      when String
        utxo = [] of UnspentOut
        json = JSON.parse utxos
        json.each do |j|
          utxo << OnChain::UnspentOut.from_insight_json(j)
        end
        return utxo
      end
      return NodeStatus.new utxos, "Error retrieving unspent outs"
      
    end
    
    def push_tx(coin : CoinType, tx_hex : String)
      return post_request(coin, "/tx/send", tx_hex)
    end
    
    private def post_request(coin, path : String, data : String,
      form_param = "rawtx")
    
      response = HTTP::Client.post @url + path, form: "rawtx=#{data}"
      return NodeStatus.new response.status_code, response.body
    end
    
  end
  
end