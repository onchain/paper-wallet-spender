require "./utxo_provider"
require "./rate_provider"

module OnChain

  class BitcoincomProvider < UTXOProvider

    def initialize(rate_provider : RateProvider, history_limit = 20)
      @url = "https://rest.bitcoin.com/v2/"
      @rate_provider = rate_provider
      @history_limit = history_limit
    end

    def get_balance(coin : CoinType, address : String, set_rate = true)

      balance = make_request("address/details/#{address}", @url)

      case balance
      when String
        json = JSON.parse(balance)

        bal = json["totalReceivedSat"].as_i64
        hbal = bal / 1_00_000_000.0
        usd_balance = 0.0.to_f64

        if set_rate
          rate = @rate_provider.get_rate(coin)
          usd_balance = (hbal * rate).to_f64
        end

        return Balance.new BigInt.new(bal),  BigInt.new(bal), hbal, hbal, usd_balance, address
      end
        return NodeStatus.new balance, "Error retrieving address"
    end

    def address_history(coin : CoinType, addresses : Array(String))

      addresses_array = "{\"addresses\":[\"" + addresses.join("\",\"") + "\"]}"
      history = post_request("address/transactions", addresses_array)

      case history
      when String
        json = JSON.parse(history)
        return OnChain::History.from_bitcoincom_json(json, addresses)
      end
      return NodeStatus.new history, "Error retrieving history"

    end

    def get_unspent_outs(coin : CoinType, addresses : Array(String)) : Array(UnspentOut) | NodeStatus

      addresses_array = "{\"addresses\":[\"" + addresses.join("\",\"") + "\"]}"
      utxos = post_request("address/utxo", addresses_array)

      case utxos
      when String
        utxo = [] of UnspentOut
        json = JSON.parse utxos
        
        json.as_a.each do |j|
          if j["utxos"]? != nil
            j["utxos"].as_a.each do |ut|
              script = j["scriptPubKey"]
              utxo << UnspentOut.from_insight_json(ut, script)
            end
          end
        end
        return utxo
      end
      return NodeStatus.new utxos, "Error retrieving unspent outs"

    end

    def get_all_balances(coin : CoinType, addresses : Array(String), set_rate = true): Array(Balance) | NodeStatus

      addresses_array = "{\"addresses\":[\"" + addresses.join("\",\"") + "\"]}"
      all_balances = post_request("address/details", addresses_array)

      case all_balances
      when String
        return parse_balances(coin, all_balances, set_rate)
      end
      return NodeStatus.new all_balances, "Error retrieving addresses"

    end
    
    def parse_balances(coin : CoinType, all_balances : String, set_rate : Bool)
    
      balances = [] of OnChain::Balance
      json = JSON.parse all_balances

      if json["addresses"]? != nil
        json["addresses"].as_a.each do |j|

          address = j["address"].as_s
          bal = j["final_balance"].as_i64
          hbal = bal / 1_00_000_000.0
          usd_balance = 0.0.to_f64

          if set_rate
            rate = @rate_provider.get_rate(coin)
            usd_balance = (hbal * rate).to_f64
          end

          balances << OnChain::Balance.new(
          BigInt.new(bal),  BigInt.new(bal),
          hbal, hbal, usd_balance, address)
        end
      end
      return balances
    end

    def push_tx(coin : CoinType, tx_hex : String) : NodeStatus

      tx = "{\"hexes\":[\"" + tx_hex + "\"]}"
      response = HTTP::Client.post(@url + "rawtransactions/sendRawTransaction", 
       HTTP::Headers{"accept" => "application/json", 
         "Content-Type" => "application/json" }, 
       body: tx)

       return NodeStatus.new response.status_code, response.body
    end

    private def post_request(path : String, data : String)

       response = HTTP::Client.post(@url + path, 
        HTTP::Headers{"accept" => "application/json", 
          "Content-Type" => "application/json" }, 
        body: data)

        if response.status_code == 200
          return response.body
        end
        return response.status_code
    end

  end

end
