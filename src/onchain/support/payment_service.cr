module OnChain

  class PaymentService
  
    def self.create(coin : CoinType, pub_hex_keys : Array(String),
      dest_addr : String, amount : BigInt, fee_satoshi : BigInt,
      fee_addr : String, miners_fee : UInt64) : UnsignedTransaction | NodeStatus
    
    
      unspent_outs = get_unspent_for_amount(coin, pub_hex_keys, amount)
      
      case unspent_outs
      when Array(UnspentOut)
      
        tx = Protocol::Transaction.create(coin, unspent_outs)
        
        hashes_to_sign = Array(HashToSign).new
        return UnsignedTransaction.new(tx.to_hex, 0, hashes_to_sign)
        
        
      else
        return unspent_outs
      end
    
    end
    
    private def self.get_unspent_for_amount(
      coin : CoinType, 
      pub_hex_keys : Array(String), 
      amount : BigInt) : Array(UnspentOut) | NodeStatus
      
      # Convert the public keys to network addresses
      keys = pub_hex_keys.map{ |key| 
        Protocol::Network.pubhex_to_address(coin, key)
      }
      
      unspents = PROVIDERS[coin].get_unspent_outs(coin, keys)
      
      case unspents
      when Array(UnspentOut)
        just_the_ones_we_need = Array(UnspentOut).new
        total = BigInt.new 
        
        unspents.each do |unspent|
          just_the_ones_we_need << unspent
          total = total + unspent.amount
          if total >= amount
            return just_the_ones_we_need
          end
        end
        
        return just_the_ones_we_need
        
      else
        # It failed so returnt he node status
        return unspents
      end
      
    end
    
  end
  
end # end module