require "http/web_socket.cr"
require "json"
require "http/client"
require "./support/**"
require "./models/**"
require "./providers/**"

# TODO: Write documentation for `BalanceEngine`
module OnChain

  enum CoinType 
    Bitcoin
    Testnet3
    Bitcoin_Cash
    Bitcoin_Gold
    Litecoin
    Dash
    Bitcoin_Private
    ZCash
    ZCashTestnet
    ZClassic
    Ethereum
  end
  
  BLOCKCYPHER_API_TOKEN = ENV["BLOCKCYPHER_API_TOKEN"]
  
  SATOSHI_PER_BITCOIN = 1_00_000_000
  WEI_PER_ETHER = 1_000_000_000_000_000_000 # Pronounced Way apparently.
  
  TICKERS = {
    CoinType::Bitcoin => "BTC",
    CoinType::Bitcoin_Cash => "BCH",
    CoinType::Bitcoin_Gold => "BTG",
    CoinType::Litecoin => "LTC",
    CoinType::Dash => "DASH",
    CoinType::Bitcoin_Private => "BTCP",
    CoinType::ZCash => "ZCH",
    CoinType::ZClassic => "ZCL",
    CoinType::Ethereum => "ETH"
  }
  
  # We've only got one
  RATE_PROVIDER = CoinMarketCapRateProvider.new
  
  ETHEREUM_PROVIDER = BlockCypherEthereumProvider.new(RATE_PROVIDER)
  
  PROVIDERS = {
    CoinType::Bitcoin => InsightProvider.new(
      "https://insight.bitpay.com/api/", RATE_PROVIDER),
      
    CoinType::Testnet3 => InsightProvider.new(
      "https://test-insight.bitpay.com/api/", RATE_PROVIDER),
      
    CoinType::Bitcoin_Cash => InsightProvider.new(
      "https://cashexplorer.bitcoin.com/api/", RATE_PROVIDER),
    CoinType::Bitcoin_Gold => InsightProvider.new(
      "https://explorer.bitcoingold.org/insight-api/", RATE_PROVIDER),
    #CoinType::Litecoin => InsightProvider.new(
    #  "https://ltc-bitcore2.trezor.io/api/"
    #],
    CoinType::Litecoin => InsightProvider.new(
      "https://insight.litecore.io/api/", RATE_PROVIDER),
    CoinType::Dash => InsightProvider.new(
      "https://insight.dash.org/insight-api-dash/", RATE_PROVIDER),
    CoinType::Bitcoin_Private => InsightProvider.new(
      "https://explorer.btcprivate.org/api/", RATE_PROVIDER),
    #CoinType::ZCash => [
    #  "https://zec-bitcore2.trezor.io/api/"
    #],
    #CoinType::ZCash => [
    #  "https://zcash.blockexplorer.com/api/"
    #],
    CoinType::ZCash => InsightProvider.new(
      "https://zcashnetwork.info/api/", RATE_PROVIDER),
    CoinType::ZCashTestnet => InsightProvider.new(
      "https://explorer.testnet.z.cash/api/", RATE_PROVIDER),
    CoinType::ZClassic => InsightProvider.new(
      "http://explorer.zclassicblue.org:3001/insight-api-zcash/", RATE_PROVIDER)
    #CoinType::Ethereum => BlockCProvider.new(
    #  "https://api.blockcypher.com/v1/eth/main/"
    #]
  }
  
  def self.make_request(url : String)
  
    response = HTTP::Client.get url
    if response.status_code == 200
      return response.body
    end
    return response.status_code
  end
  
  def self.create_sign( data, secret )
    encoded_data = HTTP::Params.encode( data )
    OpenSSL::HMAC.hexdigest(:sha512 , secret, encoded_data)
  end
  
  def self.poloniex_signed_request(command, params = {} of String => String)
  
    secret_key = ENV["POLONIEX_SECRET"]
    public_key = ENV["POLONIEX_PUBLIC"]
    
    params["command"] = command
    params["nonce"]   = Time.now.epoch_ms.to_s
  
    signed_data = create_sign( params, secret_key )
    
    headers = HTTP::Headers.new
    headers.add("Key", public_key)
    headers.add("Sign", signed_data)
    
    form_data = HTTP::Params.encode( params )
    
    url = "https://www.poloniex.com/tradingApi"
    
    response = HTTP::Client.post url, form: form_data, headers: headers
    
    if response.status_code == 200
      return response.body
    end
    return response.status_code
  end
end
