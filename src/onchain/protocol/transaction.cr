module OnChain
  module Protocol
    abstract class Transaction
    
      abstract def to_hex(coin : CoinType) : String
      abstarct def from_hex(coin : CoinType, hex_tx : String)
      
      def create(coin : CoinType, from : String, to : String, amount : BigInt)
      end
      
    end
  end
end