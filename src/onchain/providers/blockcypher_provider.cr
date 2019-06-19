require "./utxo_provider"
require "./rate_provider"

module OnChain

  class BlockcypherProvider < UTXOProvider

    def initialize(url : String, rate_provider : RateProvider, history_limit = 20)
      @url = url
      @rate_provider = rate_provider
      @history_limit = history_limit
    end

    def get_balance(coin : CoinType, address : String, set_rate = true)

      balance = make_request("addrs/#{address}", @url)

      case balance
      when String
        json = JSON.parse(balance)

        bal = json["total_received"].as_i64
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

        comma_addresses = addresses.join(",")
      
        txs = make_request("addrs/#{comma_addresses}?limit=#{@history_limit}", @url)

        case txs
        when String
          json = JSON.parse(txs)
          return OnChain::History.from_blockcypher_json(json, addresses)
        end
        return NodeStatus.new txs, "Error retrieving history"
    end

    def get_unspent_outs(coin : CoinType, addresses : Array(String)) : Array(UnspentOut) | NodeStatus

        comma_addresses = addresses.join(",")
      
        utxos = make_request("addrs/#{comma_addresses}?unspentOnly=true&includeScript=true", @url)
        
        case utxos
        when String
          utxo = [] of UnspentOut
          json = JSON.parse utxos
          json["txrefs"].as_a.each do |j|
            utxo << OnChain::UnspentOut.from_blockcypher_json(j)
          end
          return utxo
        end
        return NodeStatus.new utxos, "Error retrieving unspent outs"

    end

    def push_tx(coin : CoinType, tx_hex : String) : NodeStatus

      tx = "{\"tx\":[\"" + tx_hex + "\"]}"
      response = HTTP::Client.post(@url + "txs/push", 
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