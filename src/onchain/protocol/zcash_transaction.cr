module OnChain
  module Protocol
    class ZCashTransaction < UTXOTransaction
    
      property version_group_id : UInt32
    
      def to_hex : String
        return super.to_hex + "00"
      end
      
      def initialize(hex_tx : String)
      
        slice = OnChain.to_bytes hex_tx
        
        buffer = IO::Memory.new(slice)
        
        @ver = Transaction.readUInt32(buffer)
        @version_group_id = Transaction.readUInt32(buffer)
        @inputs = parse_inputs(buffer)
        @outputs = parse_outputs(buffer)
        
      end
    
    end
    
  end
end