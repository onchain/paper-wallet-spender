module OnChain
  module Protocol
    class UTXOTransaction < Transaction
    
      property ver : UInt32
      property inputs : Array(UTXOInput)
      property outputs : Array(UTXOOutput)
      property lock_time : UInt32
      
      def initialize(unspents : Array(UnspentOut), outputs : Array(UTXOOutput))
      
        @ver, @lock_time = 1.to_u32, 0.to_u32
        @inputs = Array(UTXOInput).new
        @outputs = outputs
        
        unspents.each do |unspent| 
          @inputs << UTXOInput.new(unspent)
        end
        
      end
      
      def initialize(hex_tx : String)
      
        slice = OnChain.to_bytes hex_tx
        
        buffer = IO::Memory.new(slice)
        
        @ver = readUInt32(buffer)
        @inputs = parse_inputs(buffer)
        @outputs = parse_outputs(buffer)
        @lock_time = readUInt32(buffer)
        
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

        # 2. Inputs
        Transaction.write_var_int(buffer, inputs.size.to_u64)
        inputs.each do |input|
          input.to_buffer(buffer)
        end

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

        return OnmChain.to_hex(hash2)
      end
      
    end
    
    
  end
end