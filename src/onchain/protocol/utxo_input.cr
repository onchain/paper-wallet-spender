module OnChain
  module Protocol
    class UTXOInput
      property prev_out_hash : Bytes
      property prev_out_index : UInt32
      property script_sig : Bytes
      property sequence : UInt32

      # For multi sig transactions we serialize the redemption script
      # as part of the inputs
      def initialize(unspent : UnspentOut, redemption_script : RedemptionScript)
        @prev_out_hash = OnChain.to_bytes(unspent.txid).reverse!
        @prev_out_index = unspent.vout.to_u32
        @script_sig = OnChain.to_bytes(redemption_script.to_hex)
        @sequence = 0xffffffff.to_u32
      end

      # Create a normal transaction input
      def initialize(unspent : UnspentOut)
        @prev_out_hash = OnChain.to_bytes(unspent.txid).reverse!
        @prev_out_index = unspent.vout.to_u32
        @script_sig = OnChain.to_bytes(unspent.script_pub_key)
        @sequence = 0xffffffff.to_u32
      end

      def initialize(buffer : IO::Memory)
        hash_slice = Slice(UInt8).new(32)
        buffer.read(hash_slice)
        @prev_out_hash = hash_slice

        @prev_out_index = Transaction.readUInt32(buffer)

        script_sig_length = Transaction.parse_var_int(buffer)
        sig_slice = Slice(UInt8).new(script_sig_length)
        buffer.read(sig_slice)
        @script_sig = sig_slice
        @sequence = Transaction.readUInt32(buffer)
      end

      def to_buffer(buffer : IO::Memory)
        buffer.write(prev_out_hash)
        buffer.write_bytes(prev_out_index, IO::ByteFormat::LittleEndian)
        Transaction.write_var_int(buffer, script_sig.size.to_u64)
        buffer.write(script_sig)
        buffer.write_bytes(sequence, IO::ByteFormat::LittleEndian)
      end
      
      # An array of signatures in DER format.
      def sign(signatures : Array(Signature))
      
        if script_sig.size == 0
          raise "Invalid script for signing"
        end
        
        if script_sig[0] == 82
          # Multi signature
          buffer = IO::Memory.new
          p2sh_multisig_script_sig(buffer, signatures)
          script_sig = buffer.to_slice
        else
          puts "Single sig signing"
        end
      
      end
      
      # Best example is...
      # https://www.soroushjp.com/2014/12/20/bitcoin-multisig-the-hard-way-under
      # standing-raw-multisignature-bitcoin-transactions/
      private def p2sh_multisig_script_sig(buffer : IO::Memory,
        signatures : Array(Signature))
      
        buffer.write_bytes(0.to_u8)     # OP_0
        
        signatures.each do |signature|
        
          sig_bytes = OnChain.to_bytes(signature.signature_der)
          buffer.write_bytes(sig_bytes.size.to_u8)  # Push (num of bytes)
          buffer.write(sig_bytes)                     # Push the sig
          buffer.write_bytes(1.to_u8)   # Hash type
          
        end
        
        # Now write in the redeem script.
        Transaction.write_var_int(buffer, script_sig.size.to_u64)
        buffer.write(script_sig)
  
      end
      
    end
  end
end
