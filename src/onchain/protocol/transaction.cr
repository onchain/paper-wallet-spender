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
      
      # Helpers for reading Bitcoin protocol messages
      
      def self.readUInt32(buffer : IO::Memory) : UInt32
      
        v = buffer.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
        
        b : UInt32 = if v
          v
        else
          0.to_u32
        end
        return b
        
      end
      
      def self.readUInt16(buffer : IO::Memory) : UInt16
      
        v = buffer.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
        
        b : UInt16 = if v
          v
        else
          0.to_u16
        end
        return b
        
      end
      
      def self.readUInt64(buffer : IO::Memory) : UInt64
      
        v = buffer.read_bytes(UInt64, IO::ByteFormat::LittleEndian)
        
        b : UInt64 = if v
          v
        else
          0.to_u64
        end
        return b
        
      end
      
      def self.readUInt8(buffer : IO::Memory) : UInt8
      
        v = buffer.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
        
        b : UInt8 = if v
          v
        else
          0.to_u8
        end
        return b
        
      end
      
      def self.parse_var_int(buffer : IO::Memory) : UInt64
      
        size = readUInt8(buffer)
        
        if size < 253
          return size.to_u64
        elsif size == 253
          return readUInt16(buffer).to_u64
        elsif size == 254
          return readUInt32(buffer).to_u64
        elsif size == 255
          return readUInt64(buffer)
        else
          return 0.to_u64
        end
      end
      
    end
  end
end