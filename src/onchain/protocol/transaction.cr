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
          ZCashTransaction.new(hex)
        else
          raise "Currency not supported"
        end
        
        return tx
          
      end
      
      
      def readUInt32(buffer : IO::Memory) : UInt32
      
        v = buffer.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
        
        b : UInt32 = if v
          v
        else
          0.to_u32
        end
        return b
        
      end
      
    end
  end
end