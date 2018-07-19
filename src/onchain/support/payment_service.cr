module OnChain

  DUST_SATOSHIES = 548

  class PaymentService
  
    def self.create(coin : CoinType, pub_hex_keys : Array(String),
      dest_addr : String, amount_satoshi : BigInt, fee_satoshi : BigInt,
      fee_addr : String, miners_fee : UInt64) : UnsignedTransaction | NodeStatus
    
      total_amount = amount_satoshi + fee_satoshi + miners_fee
      
      unspent_outs = get_unspent_for_amount(coin, pub_hex_keys, total_amount)
      
      case unspent_outs
      when Array(UnspentOut)
      
        outputs = Array(Protocol::UTXOOutput).new
        
        total_unspent_outs = 0
        unspent_outs.each{ |unspent| 
          total_unspent_outs = total_unspent_outs + unspent.amount }
        
        # The spend output
        dest_addr_160 = Protocol::Network.address_to_hash160(coin, dest_addr)
        outputs << Protocol::UTXOOutput.new(amount_satoshi.to_u64, 
          dest_addr_160)
          
        # Our fees
        fee_addr_160 = Protocol::Network.address_to_hash160(coin, fee_addr)
        outputs << Protocol::UTXOOutput.new(fee_satoshi.to_u64, fee_addr_160)
        
        # The change
        change = total_unspent_outs - total_amount
        if change > DUST_SATOSHIES
        
          change_addr = Protocol::Network.pubhex_to_address(coin, 
            pub_hex_keys[0])
          
          change_addr_160 = 
            Protocol::Network.address_to_hash160(coin, change_addr)
            
          outputs << Protocol::UTXOOutput.new(change.to_u64, change_addr_160)
        end
      
        tx = Protocol::Transaction.create(coin, unspent_outs, outputs)
        
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