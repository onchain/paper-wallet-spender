module OnChain
  module Protocol
    class UTXOOutput
    
      property value : UInt8
      property pk_script : String
      property pk_script_length : UInt8
      
      def initialize(buffer : IO::Memory)
        @value = 0
        @pk_script = ""
        @pk_script_length = 0
      end
    
    end
  end
end