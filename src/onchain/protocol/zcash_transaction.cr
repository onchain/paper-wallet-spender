module OnChain
  module Protocol
    class ZCashTransaction < UTXOTransaction
    
      property version_group_id : UInt32
      property join_split_size : UInt64
    
      def to_hex : String
      
        buffer = IO::Memory.new
        
        buffer.write_bytes(ver, IO::ByteFormat::LittleEndian)
        buffer.write_bytes(version_group_id, IO::ByteFormat::LittleEndian)
      
        return OnChain.to_hex buffer.to_slice
      end
      
      def initialize(hex_tx : String)
      
        slice = OnChain.to_bytes hex_tx
        
        buffer = IO::Memory.new(slice)
        
        @ver = Transaction.readUInt32(buffer)
        @version_group_id = Transaction.readUInt32(buffer)
        @inputs = parse_inputs(buffer)
        @outputs = parse_outputs(buffer)
        
        @join_split_size = Transaction.parse_var_int(buffer)
        
      end
    
    end
    
  end
end