require "./provider"

module OnChain

  abstract class UTXOProvider < Provider
    
    abstract def get_unspent_outs(coin : CoinType, addresses : Array(String))
    
    protected def make_request(path : String, url : String)
    
      response = HTTP::Client.get url + path
      if response.status_code == 200
      puts response.body
        return response.body
      end
      return response.status_code
    end
    
  end
  
end