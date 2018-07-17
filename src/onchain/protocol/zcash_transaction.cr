module OnChain
  module Protocol
    class ZCashTransaction < UTXOTransaction
    
      property version_group_id : UInt32
      property join_split_size : UInt64
      property expiry_height : UInt32
      
      def initialize(hex_tx : String)
      
        slice = OnChain.to_bytes hex_tx
        
        buffer = IO::Memory.new(slice)
        
        @ver = Transaction.readUInt32(buffer)
        @version_group_id = Transaction.readUInt32(buffer)
        @inputs = parse_inputs(buffer)
        @outputs = parse_outputs(buffer)
        @lock_time = Transaction.readUInt32(buffer)
        @expiry_height = Transaction.readUInt32(buffer)
        
        @join_split_size = Transaction.parse_var_int(buffer)
        
      end
      
      # Implementation of ZIP143
      # https://github.com/zcash/zips/blob/master/zip-0143.rst
      
      def signature_hash_for_zcash(input_idx : UInt64, prev_out_value : UInt64)
        
        buffer = IO::Memory.new
        
        # 1. nVersion | fOverwintered
        buffer.write_bytes(ver, IO::ByteFormat::LittleEndian)
        
        # 2. nVersionGroupId
        buffer.write_bytes(version_group_id, IO::ByteFormat::LittleEndian)
        
        # 3. hashPrevouts
        buffer.write(zcash_hash_outputs)
        
        # 4. hashSequence
        
        # 5. hashOutputs
        buffer.write(zcash_hash_outputs)
        
        # 6. hashJoinSplits
        buffer.write(OnChain.to_bytes("00000000000000000000000000000000000000" +
          "00000000000000000000000000"))
        
        # 7. nLockTime
        buffer.write_bytes(lock_time, IO::ByteFormat::LittleEndian)
        
        # 8. expiryHeight
        buffer.write_bytes(expiry_height, IO::ByteFormat::LittleEndian)
        
        # 9. nHashType
        buffer.write_bytes(0.to_u32, IO::ByteFormat::LittleEndian)
        
        # 10a. outpoint
        buffer.write(inputs[input_idx].prev_out_hash)
        buffer.write_bytes(inputs[input_idx].prev_out_index, 
          IO::ByteFormat::LittleEndian)
        
        # 10b. scriptCode
        buffer.write(inputs[input_idx].script_sig)
        
        # 10c. value
        buffer.write_bytes(prev_out_value, IO::ByteFormat::LittleEndian)
        
        # 10d. nSequence
        buffer.write_bytes(inputs[input_idx].sequence, 
          IO::ByteFormat::LittleEndian)
          
        return OnChain.to_hex buffer.to_slice
      end
    
      def to_hex : String
      
        buffer = IO::Memory.new
        
        buffer.write_bytes(ver, IO::ByteFormat::LittleEndian)
        buffer.write_bytes(version_group_id, IO::ByteFormat::LittleEndian)
        
        Transaction.write_var_int(buffer, inputs.size.to_u64)
        inputs.each do |input|
          input.to_buffer(buffer)
        end
        
        Transaction.write_var_int(buffer, outputs.size.to_u64)
        outputs.each do |output|
          output.to_buffer(buffer)
        end
        
        buffer.write_bytes(lock_time, IO::ByteFormat::LittleEndian)
        buffer.write_bytes(expiry_height, IO::ByteFormat::LittleEndian)
        
        Transaction.write_var_int(buffer, join_split_size.to_u64)
      
        return OnChain.to_hex buffer.to_slice
      end
      
      # Zcash Personalisation of blake.
      ZCASH_PREVOUTS_HASH_PERSONALIZATION   = "ZcashPrevoutHash"
      ZCASH_SEQUENCE_HASH_PERSONALIZATION   = "ZcashSequencHash"
      ZCASH_OUTPUTS_HASH_PERSONALIZATION    = "ZcashOutputsHash"
      ZCASH_JOINSPLITS_HASH_PERSONALIZATION = "ZcashJSplitsHash"
      ZCASH_SIG_HASH_PERSONALIZATION        = "ZcashSigHash"
      
      def zcash_prev_outs : Bytes
        
        buffer = IO::Memory.new
        
        inputs.each do |input|
          buffer.write(input.prev_out_hash)
          buffer.write_bytes(input.prev_out_index, IO::ByteFormat::LittleEndian)
        end
        
        return buffer.to_slice
        
      end
      
      def zcash_hash_outputs : Bytes
        
        buffer = IO::Memory.new
        
        outputs.each do |output|
          output.to_buffer(buffer)
        end
        
        buffer.to_slice
      end
    
    end
    
  end
end