require "./utxo_provider"
require "./rate_provider"

module OnChain

  class BlockchaininfoProvider < UTXOProvider

    def initialize(rate_provider : RateProvider, testnet = false, 
      history_limit = 20)
      
      @url = testnet ? "https://testnet.blockchain.info/" : 
        "https://blockchain.info/"
      @rate_provider = rate_provider
      @history_limit = history_limit
    end

    def get_balance(coin : CoinType, address : String, set_rate = true)

      balance = make_request("address/#{address}?format=json&limit=0", @url)

      case balance
      when String
        json = JSON.parse(balance)

        bal = json["final_balance"].as_i64
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

      comma_addresses = addresses.join("|")

      history = make_request(
        "multiaddr?active=#{comma_addresses}&n=#{@history_limit}", @url)

      case history
      when String
        json = JSON.parse(history)
        return OnChain::History.from_blockinfo_json(json, addresses)
      end
      return NodeStatus.new history, "Error retrieving history"

    end

    def get_unspent_outs(coin : CoinType, addresses : Array(String))

      comma_addresses = addresses.join(",")

      utxos = make_request("unspent?active=#{comma_addresses}", @url)

      case utxos
      when String
        utxo = [] of UnspentOut
        json = JSON.parse utxos
        if json["unspent_outputs"]? != nil
          json["unspent_outputs"].as_a.each do |j|
            utxo << OnChain::UnspentOut.from_blockinfo_json(j)
          end
        end
        return utxo
      end
      return NodeStatus.new utxos, "Error retrieving unspent outs"

    end

    def get_all_balances(coin : CoinType, addresses : Array(String), set_rate = true)

      pipe_addresses = addresses.join("|")

      all_balances = make_request(
        "multiaddr?active=#{pipe_addresses}", @url)

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

    def push_tx(coin : CoinType, tx_hex : String)
      return post_request(coin, "pushtx", tx_hex)
    end

    private def post_request(coin, path : String, data : String,
       form_param = "tx")

       response = HTTP::Client.post @url + path, form: "tx=#{data}"
       return NodeStatus.new response.status_code, response.body
    end

  end

end
