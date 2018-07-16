require "./rate_provider"

module OnChain

  class CoinMarketCapRateProvider < RateProvider
  
    def get_rate(coin : CoinType) : Float64
      ticker = coin.to_s.downcase
      ticker = ticker.gsub("_", "-")
    
      url = "https://api.coinmarketcap.com/v1/ticker/#{ticker}/"
    
      response = HTTP::Client.get url
      
      if response.status_code == 200
        price = JSON.parse(response.body)[0]["price_usd"].as_s
        return price.to_f64
      end
      return 0.0.to_f64
    end
    
  end
  
end