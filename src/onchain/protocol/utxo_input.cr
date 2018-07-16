module OnChain
  module Protocol
    class UTXOInput
    
      property prev_out_hash : Bytes
      property prev_out_index : UInt8
      property script_sig_length : UInt8
      property script_sig : String
      property sequence : UInt8
    
      def initialize(buffer : IO::Memory)
      
        slice = Slice(UInt8).new(32)
        buffer.read(slice)
      
        @prev_out_hash = slice
        @prev_out_index = 0
        @script_sig_length = 0
        @script_sig = ""
        @sequence = 0
      end
    
    end
  end
end