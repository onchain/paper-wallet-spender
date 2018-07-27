module OnChain
  module Protocol
    abstract class Transaction
    
      abstract def to_hex : String
      
      def self.create(coin : CoinType, unspents : UnspentOuts,
        outputs : Array(UTXOOutput)) : UnsignedTransaction
      
        tx = case coin
        when CoinType::ZCash
        
          zcash_tx = ZCashTransaction.new(unspents.unspent_outs, outputs)
          hashes_to_sign = Array(HashToSign).new
          
          unspents.unspent_outs.each_with_index do |unspent, i|
            blake_hash = zcash_tx.signature_hash_for_zcash(
              i.to_u64, unspent.amount)
            hashes_to_sign << HashToSign.new(
              blake_hash, unspents.pub_hex_keys[i], i)
          end
          
          return UnsignedTransaction.new(zcash_tx.to_hex, 
            unspents.total_input_value, hashes_to_sign)
          
        else
        
          # Create a muylti sig or normal transaction?
          utxo_tx = if unspents.redemption_scripts.size == 0 
            UTXOTransaction.new(unspents.unspent_outs, outputs)
          else
            UTXOTransaction.new(unspents.unspent_outs, outputs, 
              unspents.redemption_scripts)
          end
          
          hashes_to_sign = Array(HashToSign).new
          
          # For each unspent out we need the hash and a list
          # of public keys that need to sign it.
          unspents.unspent_outs.each_with_index do |unspent, i|
          
            bitcoin_hash = utxo_tx.hash_signature_for_input(i)
            
            unspents.redemption_scripts[i].public_keys.each do |pk|
              hashes_to_sign << HashToSign.new( bitcoin_hash, pk, i)
            end
            
          end
          
          
          return UnsignedTransaction.new(utxo_tx.to_hex, 
            unspents.total_input_value, hashes_to_sign)
        end
        
        return tx
        
      end
      
      # Helpers for reading Bitcoin protocol messages
      
      def self.readUInt32(buffer : IO::Memory) : UInt32
      
        v = buffer.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
        
        b : UInt32 = if v
          v
        else
          0.to_u32
        end
        return b
        
      end
      
      def self.readUInt16(buffer : IO::Memory) : UInt16
      
        v = buffer.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
        
        b : UInt16 = if v
          v
        else
          0.to_u16
        end
        return b
        
      end
      
      def self.readUInt64(buffer : IO::Memory) : UInt64
      
        v = buffer.read_bytes(UInt64, IO::ByteFormat::LittleEndian)
        
        b : UInt64 = if v
          v
        else
          0.to_u64
        end
        return b
        
      end
      
      def self.readUInt8(buffer : IO::Memory) : UInt8
      
        v = buffer.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
        
        b : UInt8 = if v
          v
        else
          0.to_u8
        end
        return b
        
      end
      
      def self.parse_var_int(buffer : IO::Memory) : UInt64
      
        size = readUInt8(buffer)
        
        if size < 253
          return size.to_u64
        elsif size == 253
          return readUInt16(buffer).to_u64
        elsif size == 254
          return readUInt32(buffer).to_u64
        elsif size == 255
          return readUInt64(buffer)
        else
          return 0.to_u64
        end
      end
      
      def self.write_var_int(buffer : IO::Memory, value : UInt64)
      
        if value < 253
          buffer.write_byte(value.to_u8)
        elsif value >= 253 && value < 65536
          buffer.write_byte(253.to_u8)
          buffer.write_bytes(value.to_u16, IO::ByteFormat::LittleEndian)
        elsif value >= 65536 && value < 4294967296
          buffer.write_byte(254.to_u8)
          buffer.write_bytes(value.to_u32, IO::ByteFormat::LittleEndian)
        else
          buffer.write_byte(255.to_u8)
          buffer.write_bytes(value, IO::ByteFormat::LittleEndian)
        end
      
      end
      
    end
  end
end