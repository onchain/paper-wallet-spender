module OnChain
  module Protocol
    class ZCashTransaction < UTXOTransaction
    
      property version_group_id : UInt32
      property join_split_size : UInt64
      property expiry_height : UInt32
      
      def initialize(hex_tx : String)
      
        slice = OnChain.to_bytes hex_tx
        
        buffer = IO::Memory.new(slice)
        
        @ver = Transaction.readUInt32(buffer)
        @version_group_id = Transaction.readUInt32(buffer)
        @inputs = parse_inputs(buffer)
        @outputs = parse_outputs(buffer)
        @lock_time = Transaction.readUInt32(buffer)
        @expiry_height = Transaction.readUInt32(buffer)
        
        @join_split_size = Transaction.parse_var_int(buffer)
        
      end
    
      def to_hex : String
      
        buffer = IO::Memory.new
        
        buffer.write_bytes(ver, IO::ByteFormat::LittleEndian)
        buffer.write_bytes(version_group_id, IO::ByteFormat::LittleEndian)
        
        Transaction.write_var_int(buffer, inputs.size.to_u64)
        inputs.each do |input|
          input.to_buffer(buffer)
        end
        
        Transaction.write_var_int(buffer, outputs.size.to_u64)
        outputs.each do |output|
          output.to_buffer(buffer)
        end
        
        buffer.write_bytes(lock_time, IO::ByteFormat::LittleEndian)
        buffer.write_bytes(expiry_height, IO::ByteFormat::LittleEndian)
        
        # Always write zero join splits as we don't support them.
        Transaction.write_var_int(buffer, 0.to_u64)
      
        return OnChain.to_hex buffer.to_slice
      end
    
    end
    
  end
end