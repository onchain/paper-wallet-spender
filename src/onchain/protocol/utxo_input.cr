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
          @script_sig = buffer.to_slice
        elsif signatures.size == 1 && script_sig[0] == 118
          buffer = IO::Memory.new
          to_pubkey_script_sig(buffer, signatures[0])
          @script_sig = buffer.to_slice
        else
          raise "Not sure how to sign this."
        end
      
      end
      
      # generate input script sig spending a pubkey output with given +signature+ and +pubkey+.
      # returns a raw binary script sig of the form:
      #  <signature> [<pubkey>]
      private def to_pubkey_script_sig(buffer : IO::Memory, 
        signature : Signature)
        
        # Add on hahs type SIG_ALL
        sig_with_hash_type = signature.signature_der + "01"
        
        sig_bytes = OnChain.to_bytes(sig_with_hash_type)
        
        push_data(buffer, sig_bytes)
        
        public_key_bytes = OnChain.to_bytes(signature.public_key)
        
        push_data(buffer, public_key_bytes)
        
      end
      
      # Best example is...
      # https://www.soroushjp.com/2014/12/20/bitcoin-multisig-the-hard-way-under
      # standing-raw-multisignature-bitcoin-transactions/
      #
      private def p2sh_multisig_script_sig(buffer : IO::Memory,
        signatures : Array(Signature))
      
        buffer.write_bytes(0.to_u8)     # OP_0
        
        signatures.each do |signature|
        
          # Add on hahs type SIG_ALL
          sig_with_hash_type = signature.signature_der + "01"
        
          sig_bytes = OnChain.to_bytes(sig_with_hash_type)
          
          push_data(buffer, sig_bytes)
          
        end
        
        # Now write in the redeem script.
        buffer.write_bytes(76.to_u8)   # OP_PUSHDATA1
        Transaction.write_var_int(buffer, script_sig.size.to_u64)
        buffer.write(script_sig)
  
      end
      
      # N/A	1-75	The next opcode bytes is data to be pushed onto the stack
      #
      # OP_PUSHDATA1	76	The next byte contains the number of bytes to be 
      #   pushed onto the stack.
      #
      # OP_PUSHDATA2	77	The next two bytes contain the number of bytes 
      #   to be pushed onto the stack in little endian order.
      #
      # OP_PUSHDATA4	78	The next four bytes contain the number of bytes to 
      #   be pushed onto the stack in little endian order.
      #
      private def push_data(buffer : IO::Memory, data : Bytes)
      
        if data.size < 76
          buffer.write_bytes(data.size.to_u8, IO::ByteFormat::LittleEndian)
          buffer.write(data)
        elsif data.size <= 255
          buffer.write_bytes(76.to_u8, IO::ByteFormat::LittleEndian)
          buffer.write_bytes(data.size.to_u8, IO::ByteFormat::LittleEndian)
          buffer.write(data)
        elsif data.size <= 65536
          buffer.write_bytes(77.to_u8, IO::ByteFormat::LittleEndian)
          buffer.write_bytes(data.size.to_u16, IO::ByteFormat::LittleEndian)
          buffer.write(data)
          
          # Actually it goes even higher but we're never going to need it.
        end
      
      end
      
    end
  end
end
