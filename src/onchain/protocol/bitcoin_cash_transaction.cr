require "./**"

module OnChain
  module Protocol
    class BitcoinCashTransaction < UTXOTransaction
    
      #  Double SHA256 of the serialization of:
      #   1. nVersion of the transaction (4-byte little endian)
      #   2. hashPrevouts (32-byte hash)
      #   3. hashSequence (32-byte hash)
      #   4. outpoint (32-byte hash + 4-byte little endian) 
      #   5. scriptCode of the input (serialized as scripts inside CTxOuts)
      #   6. value of the output spent by this input (8-byte little endian)
      #   7. nSequence of the input (4-byte little endian)
      #   8. hashOutputs (32-byte hash)
      #   9. nLocktime of the transaction (4-byte little endian)
      #  10. sighash type of the signature (4-byte little endian)
      #
      def signature_hash_for_bitcoin_cash(input_idx : UInt64, 
        prev_out_value : BigInt, fork_id : UInt32) : String
        
        buffer = IO::Memory.new
        
        # 1. nVersion of the transaction (4-byte little endian)
        buffer.write_bytes(ver, IO::ByteFormat::LittleEndian)
        
        # 2. hashPrevouts (32-byte hash)
        buffer.write(prev_outs_hash)
        
        # 3. hashSequence (32-byte hash)
        buffer.write(sequence_hash)
        
        # 4. outpoint (32-byte hash + 4-byte little endian) 
        buffer.write(inputs[input_idx].prev_out_hash)
        buffer.write_bytes(inputs[input_idx].prev_out_index, 
          IO::ByteFormat::LittleEndian)
        
        # 5. scriptCode of the input (serialized as scripts inside CTxOuts)
        Transaction.write_var_int(buffer, 
          inputs[input_idx].script_sig.size.to_u64)
        buffer.write(inputs[input_idx].script_sig)
          
        # 6. value of the output spent by this input (8-byte little endian)
        buffer.write_bytes(prev_out_value.to_u64, IO::ByteFormat::LittleEndian)
        
        # 7. nSequence of the input (4-byte little endian)
        buffer.write_bytes(inputs[input_idx].sequence, 
          IO::ByteFormat::LittleEndian)
          
        # 8. hashOutputs (32-byte hash)
        buffer.write(outputs_hash)
        
        # 9. nLocktime of the transaction (4-byte little endian)
        buffer.write_bytes(lock_time, IO::ByteFormat::LittleEndian)
        
        #  10. sighash type of the signature (4-byte little endian)
        fork_hash_type = 65 # SIGHASH_TYPE[:all] | SIGHASH_TYPE[:forkid]
        fork_hash_type |= fork_id
        buffer.write_bytes(fork_hash_type, IO::ByteFormat::LittleEndian)

        #  Double SHA256 of the serialization of:
        hash = OpenSSL::Digest.new("SHA256")
        hash.update(buffer.to_slice)
        hash1 = hash.digest

        hash = OpenSSL::Digest.new("SHA256")
        hash.update(hash1)
        hash2 = hash.digest

        return OnChain.to_hex(hash2)
      end
      
      def prev_outs_hash : Bytes
        
        buffer = IO::Memory.new
        
        inputs.each do |input|
          buffer.write(input.prev_out_hash)
          buffer.write_bytes(input.prev_out_index, IO::ByteFormat::LittleEndian)
        end

        hash = OpenSSL::Digest.new("SHA256")
        hash.update(buffer.to_slice)
        hash1 = hash.digest

        hash = OpenSSL::Digest.new("SHA256")
        hash.update(hash1)
        hash2 = hash.digest

        return hash2
        
      end
      
      def outputs_hash : Bytes
        
        buffer = IO::Memory.new
        
        outputs.each do |output|
          output.to_buffer(buffer)
        end
        
        hash = OpenSSL::Digest.new("SHA256")
        hash.update(buffer.to_slice)
        hash1 = hash.digest

        hash = OpenSSL::Digest.new("SHA256")
        hash.update(hash1)
        hash2 = hash.digest

        return hash2
      end
      
      def sequence_hash : Bytes
        
        buffer = IO::Memory.new
        
        inputs.each do |input|
          buffer.write_bytes(input.sequence, IO::ByteFormat::LittleEndian)
        end
        
        hash = OpenSSL::Digest.new("SHA256")
        hash.update(buffer.to_slice)
        hash1 = hash.digest

        hash = OpenSSL::Digest.new("SHA256")
        hash.update(hash1)
        hash2 = hash.digest

        return hash2
      end
      
    end
    
  end
end
    