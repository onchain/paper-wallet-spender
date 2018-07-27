module OnChain
  module Protocol
    class Address
    
      property hash160 : Bytes
      property coin : CoinType
      property p2sh : Bool
      
      def initialize(@coin : CoinType, @hash160 : Bytes, @p2sh : Bool)
      end
      
      def initialize(@coin : CoinType, network_address : String)
      
        @p2sh = false
        
        prefix = Network::NETWORKS[coin][:pubKeyHash]
        base58 = base58_to_hex(network_address)
        
        if base58.starts_with? Network::NETWORKS[coin][:p2sh_version]
          prefix = Network::NETWORKS[coin][:p2sh_version]
          @p2sh = true
        elsif ! base58.starts_with? Network::NETWORKS[coin][:pubKeyHash]
          raise "Prefix doesn't match coin type"
        end
      
        chars_to_miss = OnChain.to_bytes(
          Network::NETWORKS[coin][:pubKeyHash]).size * 2
        
        hash160_hex = base58[chars_to_miss..-9]
        
        @hash160 = OnChain.to_bytes(hash160_hex)
      end
      
      def to_s : String
      
        io = IO::Memory.new
        
        if @p2sh
          io.write OnChain.to_bytes(Network::NETWORKS[coin][:p2sh_version])
        else
          io.write OnChain.to_bytes(Network::NETWORKS[coin][:pubKeyHash])
        end
        io.write(hash160)
        with_version_byte = io.to_slice
        
        return encode_with_checksum(@coin, with_version_byte)
      end
      
      def output_script
        if @p2sh
          return p2sh
        end
        return p2pkh
      end
      
      def p2sh : Bytes
        io = IO::Memory.new
        io.write_bytes("a9".to_i(16).to_u8) #  HASH160
        io.write_bytes("14".to_i(16).to_u8) #  length
        io.write(hash160)
        io.write_bytes("87".to_i(16).to_u8) #  OP_EQUAL
        return io.to_slice
      end
      
      def p2pkh : Bytes
        io = IO::Memory.new
        io.write_bytes("76".to_i(16).to_u8) #  DUP
        io.write_bytes("a9".to_i(16).to_u8) #  HASH160
        io.write_bytes("14".to_i(16).to_u8) #  length
        io.write(hash160)
        io.write_bytes("88".to_i(16).to_u8) #  EQUALVERIFY
        io.write_bytes("ac".to_i(16).to_u8) #  CHECKSIG
        return io.to_slice
      end
        
      def encode_with_checksum(coin : OnChain::CoinType,
        buffer : Bytes) : String
        
        hash = OpenSSL::Digest.new("SHA256")
        hash.update(buffer)
        hash3 = hash.digest
        
        hash = OpenSSL::Digest.new("SHA256")
        hash.update(hash3)
        hash4 = hash.digest
        
        io = IO::Memory.new
        io.write buffer
        io.write hash4[0, 4].to_slice
        with_checksum = io.to_slice
        
        prefix = ""
        index = 0
        while(with_checksum[index] == 0)
          prefix = prefix + "1"
          index = index + 1
        end
        
        i = BigInt.new OnChain.to_hex(with_checksum), 16
        
        base58 = prefix +  Network.encode58(i)
      
        return base58
      end
      
      ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
      BASE = ALPHABET.size
      
      private def base58_to_hex(base58_val : String) : String
      
        nzeroes = 0
        
        while base58_val.chars[nzeroes] == ALPHABET[0] && 
          nzeroes < base58_val.size
          nzeroes = nzeroes + 1
        end
        
        prefix = nzeroes == 0 ? "" : "00" * nzeroes
        hex = base58_to_int(base58_val).to_s(16)
        if hex.size % 2 != 0
          hex = "0" + hex
        end
        return prefix + hex
        
      end
      
      private def base58_to_int(base58_val : String) : Number
        int_val = BigInt.new
        base58_val.reverse.split(//).each_with_index do |char, index|
          char_index = ALPHABET.index(char)
          raise ArgumentError.new("Value passed not a valid Base58 String.") if char_index.nil?
          int_val += (char_index.to_big_i) * (BASE.to_big_i ** (index.to_big_i))
        end
        int_val
      end
      
    end
  end
end
