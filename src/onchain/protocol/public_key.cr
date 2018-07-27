module OnChain
  module Protocol
    class PublicKey
    
      property pub_key_hex : String
      
      def initialize(@pub_key_hex)
      end
      
      def to_address(coin : OnChain::CoinType, p2sh : Bool) : Address
        return Address.new(coin, to_hash160, p2sh) 
      end
      
      def to_hash160
        hash160 = Protocol::Network.pubhex_to_hash160 pub_key_hex
        return OnChain.to_bytes(hash160)
      end
      
      def to_hash160_hex
        return Protocol::Network.pubhex_to_hash160 pub_key_hex
      end
      
    end
  end
end
