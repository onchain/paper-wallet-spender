module OnChain
  module Protocol
    class UTXOInput
    
      property prev_out_hash : Bytes
      property prev_out_index : UInt32
      property script_sig_length : UInt64
      property script_sig : Bytes
      property sequence : UInt32
    
      def initialize(buffer : IO::Memory)
      
        hash_slice = Slice(UInt8).new(32)
        buffer.read(hash_slice)
        @prev_out_hash = hash_slice
        
        @prev_out_index = Transaction.readUInt32(buffer)
        
        @script_sig_length = Transaction.parse_var_int(buffer)
        sig_slice = Slice(UInt8).new(@script_sig_length)
        buffer.read(sig_slice)
        @script_sig = sig_slice
        @sequence = Transaction.readUInt32(buffer)
      end
    
    end
  end
end