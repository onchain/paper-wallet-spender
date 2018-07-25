module OnChain

  abstract class RateProvider

    abstract def get_rate(coin : CoinType) : Float64

  end
  
end
