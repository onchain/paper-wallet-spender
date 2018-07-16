module OnChain
  module Protocol
    class UTXOTransaction < Transaction
    
      property ver : UInt32
      property inputs : Array(UTXOInput)
      property outputs : Array(UTXOOutput)
    
      def to_hex : String
      end
      
      def initialize(hex_tx : String)
      
        slice = OnChain.to_bytes hex_tx
        
        buffer = IO::Memory.new(slice)
        
        @ver = readUInt32(buffer)
        @inputs = parse_inputs(buffer)
        
        @outputs = [] of UTXOOutput
        
      end
      
      def parse_inputs(buffer : IO::Memory)
        inputs = [] of UTXOInput
        in_size = buffer.read_byte
        if in_size
          in_size.times{
            inputs << UTXOInput.new(buffer)
          }
        end
        return inputs
      end
      
    end
    
    
  end
end