module OnChain
  module Protocol
    class UTXOOutput
    
      property value : UInt64
      property pk_script : Bytes
      property pk_script_length : UInt64
      
      def initialize(buffer : IO::Memory)
      
        @value = Transaction.readUInt64(buffer)
        @pk_script_length = Transaction.parse_var_int(buffer)
        
        pk_script_slice = Slice(UInt8).new(@pk_script_length)
        buffer.read(pk_script_slice)
        @pk_script = pk_script_slice
        
      end
    
    end
  end
end