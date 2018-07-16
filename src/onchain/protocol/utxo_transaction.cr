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
        in_size = Transaction.parse_var_int(buffer)
        if in_size
          in_size.times{
            inputs << UTXOInput.new(buffer)
          }
        end
        return inputs
      end
      
      def parse_outputs(buffer : IO::Memory)
        outputs = [] of UTXOOutput
        out_size = Transaction.parse_var_int(buffer)
        if out_size
          out_size.times{
            outputs << UTXOOutput.new(buffer)
          }
        end
        return outputs
      end
      
    end
    
    
  end
end