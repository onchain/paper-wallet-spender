module OnChain
  module Protocol
  
    class Network
    
      NETWORKS = {
        OnChain::CoinType::Bitcoin => {
         :pubKeyHash => "00",
          :p2sh_version => "05"
        },
        OnChain::CoinType::Testnet3 => {
          :pubKeyHash => "6f",
          :p2sh_version => "c4"
        },
        OnChain::CoinType::Bitcoin_Cash => {
          :pubKeyHash => "00",
          :p2sh_version => "05"
        },
        OnChain::CoinType::Bitcoin_Gold => {
          :pubKeyHash => "26",
          :p2sh_version => "17",
          :fork_id => "79"
        } ,
        OnChain::CoinType::Litecoin => {
          :pubKeyHash => "30",
          :p2sh_version => "32"
        },
        OnChain::CoinType::Dash => {
          :pubKeyHash => "4C",
          :p2sh_version => "10"
        },
        OnChain::CoinType::Doge => {
          :pubKeyHash => "1E",
          :p2sh_version => "16"
        },
        OnChain::CoinType::Bitcoin_Private => {
          :pubKeyHash => "1325",
          :p2sh_version => "13AF"
        },
        OnChain::CoinType::ZCash => {
          :pubKeyHash => "1CB8",
          :p2sh_version => "1CBD"
        },
        OnChain::CoinType::ZClassic => {
          :pubKeyHash => "1CB8",
          :p2sh_version => "1CBD"
        }
      }
      
      def self.address_to_hash160(coin : OnChain::CoinType, 
        network_address : String) : String
        
        chars_to_miss = OnChain.to_bytes(NETWORKS[coin][:pubKeyHash]).size * 2
        
        return decode58(network_address).to_s(16)[chars_to_miss..-9]
        
      end
  
      def self.pubhex_to_hash160(pub_hex : String) : String
      
        data = OnChain.to_bytes(pub_hex)
        hash = OpenSSL::Digest.new("SHA256")
        hash.update(data)
        hash1 = hash.digest
        
        hash = OpenSSL::Digest.new("RIPEMD160")
        hash.update(hash1)
        hash2 = hash.digest
        
        return OnChain.to_hex hash2
      end
  
      def self.pubhex_to_address(coin : OnChain::CoinType, 
        pub_hex : String) : String
      
        data = OnChain.to_bytes(pub_hex)
        hash = OpenSSL::Digest.new("SHA256")
        hash.update(data)
        hash1 = hash.digest
        
        hash = OpenSSL::Digest.new("RIPEMD160")
        hash.update(hash1)
        hash2 = hash.digest
        
        io = IO::Memory.new
        io.write OnChain.to_bytes(NETWORKS[coin][:pubKeyHash])
        io.write(hash2)
        with_version_byte = io.to_slice
        
        return encode_with_checksum(with_version_byte)
      end
        
      def self.encode_with_checksum(buffer : Bytes) : String
        
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
        
        base58 = prefix +  encode58(i)
      
        return base58
      end
      
      ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
      BASE = ALPHABET.size
    
      def self.encode58(int_val : Number) : String
        base58_val = ""
        while int_val >= BASE
          mod = int_val % BASE
          base58_val = ALPHABET[mod, 1] + base58_val
          int_val = (int_val - mod) / BASE
        end
        ALPHABET[int_val, 1] + base58_val
      end
    
      def self.decode58(base58_val : String) : Number
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