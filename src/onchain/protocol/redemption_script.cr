module OnChain
  module Protocol
    struct RedemptionScript
    
      getter min_signers : UInt8
      getter public_keys : Array(String)
      
      def initialize(@min_signers : UInt8, @public_keys : Array(String))
      end
      
      def to_address(coin : CoinType) : Address
      
        buffer = IO::Memory.new
        to_buffer(buffer)
        
        hash = OpenSSL::Digest.new("SHA256")
        hash.update(buffer.to_slice)
        hash1 = hash.digest
        
        # has160 the buffer
        hash = OpenSSL::Digest.new("RIPEMD160")
        hash.update(hash1)
        hash2 = hash.digest
        
        return Address.new(coin, hash2, true)
      end
      
      def to_hex
      
        buffer = IO::Memory.new
        
        to_buffer(buffer)
        
        return OnChain.to_hex(buffer.to_slice)
      end
      
      def to_buffer(buffer : IO::Memory)
      
        buffer.write_bytes(min_signers + 80)
        
        public_keys.each do |key|
          length : UInt8 = (key.size / 2).to_u8
          buffer.write_bytes(length)
          buffer.write(OnChain.to_bytes(key))
        end
        
        buffer.write_bytes((public_keys.size + 80).to_u8)
        
        ending : UInt8 = 0xae
        
        buffer.write_bytes(ending)
      
      end
      
      def to_json
         string = JSON.build do |json|
          to_json(json)
         end
      end
    end
  end
end