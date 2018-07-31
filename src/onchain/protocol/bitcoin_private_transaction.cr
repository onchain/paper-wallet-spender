require "./**"

module OnChain
  module Protocol
    class BitcoinPrivateTransaction < UTXOTransaction
      
      # htps://github.com/BTCPrivate/BitcoinPrivate/blob/master/src/script/interpreter.cpp#L1102
      # https://github.com/BTCGPU/BTCGPU/blob/master/src/script/interpreter.cpp#L1212
      # htttps://github.com/BTCPrivate/BitcoinPrivate/blob/master/src/script/interpreter.cpp#L1047
      #
      def signature_hash_for_bitcoin_private(input_idx : UInt64) : String
        
        buffer = IO::Memory.new
        
        # Inputs size
        write_var_int(buffer, inputs.size)
        
        # The inputs
        inputs[input_idx].to_buffer(buffer)
        
        # Outputs size
        write_var_int(buffer, outputs.size)
          
        # Outputs
        outputs.each do |output|
          output.to_buffer(buffer)
        end
        
        # Lock time
        buffer.write_bytes(lock_time, IO::ByteFormat::LittleEndian)
        
        # Fork id
        fork_hash_type = 1.to_u32
        fork_hash_type |= 0x42.to_u32 << 8.to_u32
        buffer.write_bytes(fork_hash_type, IO::ByteFormat::LittleEndian)

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
    