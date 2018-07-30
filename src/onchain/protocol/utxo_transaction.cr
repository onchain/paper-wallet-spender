module OnChain
  module Protocol
    class UTXOTransaction < Transaction
    
      property ver : UInt32
      property inputs : Array(UTXOInput)
      property outputs : Array(UTXOOutput)
      property lock_time : UInt32
      
      # Used for multi sig transactions
      def initialize(unspents : Array(UnspentOut), @outputs : Array(UTXOOutput),
        redemption_scripts : Array(RedemptionScript))
      
        @ver, @lock_time = 1.to_u32, 0.to_u32
        @inputs = Array(UTXOInput).new
        
        unspents.each_with_index do |unspent, i| 
          @inputs << UTXOInput.new(unspent, redemption_scripts[i])
        end
        
      end
      
      def initialize(unspents : Array(UnspentOut), @outputs : Array(UTXOOutput))
      
        @ver, @lock_time = 1.to_u32, 0.to_u32
        @inputs = Array(UTXOInput).new
        
        unspents.each do |unspent| 
          @inputs << UTXOInput.new(unspent)
        end
        
      end
      
      def initialize(hex_tx : String)
      
        slice = OnChain.to_bytes hex_tx
        
        buffer = IO::Memory.new(slice)
        
        @ver = Transaction.readUInt32(buffer)
        @inputs = parse_inputs(buffer)
        @outputs = parse_outputs(buffer)
        @lock_time = Transaction.readUInt32(buffer)
        
      end
    
      def to_hex : String
      
        buffer = IO::Memory.new
        
        buffer.write_bytes(ver, IO::ByteFormat::LittleEndian)
        
        Transaction.write_var_int(buffer, inputs.size.to_u64)
        inputs.each do |input|
          input.to_buffer(buffer)
        end
        
        Transaction.write_var_int(buffer, outputs.size.to_u64)
        outputs.each do |output|
          output.to_buffer(buffer)
        end
        
        buffer.write_bytes(lock_time, IO::ByteFormat::LittleEndian)
      
        return OnChain.to_hex buffer.to_slice
      end
      
      def sign(signatures : Array(Signature))
      
        inputs.each_with_index do |input, input_idx|
          
          # For every input get the relevant signatures.
          relevant_sigs = signatures.select { |sig| 
            sig.input_index == input_idx }
          
          # For single sig there will be just one entry in the array
          # for multi sig more.
          input.sign(relevant_sigs)
          
        end
      
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

      def hash_signature_for_input(input_idx : Int32) : String
        buffer = IO::Memory.new

        # 1. Version
        buffer.write_bytes(ver, IO::ByteFormat::LittleEndian)

        # 2. Input
        Transaction.write_var_int(buffer, inputs.size.to_u64)
        inputs[input_idx].to_buffer(buffer)

        # 3. Outputs
        Transaction.write_var_int(buffer, outputs.size.to_u64)
        outputs.each do |output|
          output.to_buffer(buffer)
        end

        # 4. Lock time
        buffer.write_bytes(lock_time, IO::ByteFormat::LittleEndian)

        # 5. Hash type = 1 for
        buffer.write_bytes(1.to_u32, IO::ByteFormat::LittleEndian)

        hash = OpenSSL::Digest.new("SHA256")
        hash.update(buffer.to_slice)
        hash1 = hash.digest

        hash = OpenSSL::Digest.new("SHA256")
        hash.update(hash1)
        hash2 = hash.digest

        return OnChain.to_hex(hash2)
      end
      
    end
    
    
  end
end