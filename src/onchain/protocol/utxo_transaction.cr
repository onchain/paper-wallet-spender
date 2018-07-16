module OnChain
  module Protocol
    class UTXOTransaction
    
      def to_hex(coin : CoinType) : String
      end
      
      def from_hex(coin : CoinType, hex_tx : String)
      end
      
    end
  end
end