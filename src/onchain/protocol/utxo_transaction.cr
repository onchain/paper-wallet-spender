module OnChain
  module Protocol
    class UTXOTransaction < Transaction
    
      property ver : UInt8
    
      def to_hex : String
      end
      
      def initialize(hex_tx : String)
      
        slice = OnChain.to_bytes hex_tx
        
        buffer = IO::Memory.new(slice)
        
        v = buffer.read_byte
        b : UInt8 = if v
          v
        else
          0.to_u8
        end
        @ver = b
      end
      
    end
  end
end