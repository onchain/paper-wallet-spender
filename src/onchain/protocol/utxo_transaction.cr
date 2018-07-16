module OnChain
  module Protocol
    class UTXOTransaction
    
      def to_hex : String
      end
      
      def from_hex(hex_tx : String)
      end
      
      def initialize(hex_tx : String)
        from_hex(hex_tx)
      end
      
    end
  end
end