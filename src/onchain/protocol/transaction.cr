module OnChain
  module Protocol
    abstract class Transaction
    
      abstract def to_hex : String
      
      def self.create(coin : CoinType, from : String, to : String, 
        amount : BigInt)
      end
      
      def self.create(coin : CoinType, hex : String)
        
        tx = case coin
        when CoinType::ZCash
          UTXOTransaction.new(hex)
        else
          raise "Currency not supported"
        end
        
        return tx
          
      end
      
    end
  end
end