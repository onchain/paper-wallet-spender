module OnChain
  module Protocol
    class UTXOInput
      property prev_out_hash : Bytes
      property prev_out_index : UInt32
      property script_sig_length : UInt64
      property script_sig : Bytes
      property sequence : UInt32

      def initialize(unspent : UnspentOut)
        @prev_out_hash = OnChain.to_bytes(unspent.txid).reverse!
        @prev_out_index = unspent.vout.to_u32
        @script_sig = OnChain.to_bytes(unspent.script_pub_key)
        @script_sig_length = @script_sig.size.to_u64
        @sequence = 0xffffffff.to_u32
      end

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

      def to_buffer(buffer : IO::Memory)
        buffer.write(prev_out_hash)
        buffer.write_bytes(prev_out_index, IO::ByteFormat::LittleEndian)
        Transaction.write_var_int(buffer, script_sig_length)
        buffer.write(script_sig)
        buffer.write_bytes(sequence, IO::ByteFormat::LittleEndian)
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
