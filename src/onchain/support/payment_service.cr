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
        
        total_unspent_outs = total_of_unspent(unspent_outs)
        
        # The spend output
        outputs << create_output(coin, amount_satoshi.to_u64, dest_addr)
          
        # Our fees
        outputs << create_output(coin, fee_satoshi.to_u64, fee_addr)
        
        # The change
        change = total_unspent_outs - total_amount
        if change > DUST_SATOSHIES
        
          change_addr = Protocol::Network.pubhex_to_address(coin, 
            pub_hex_keys[0])
            
          outputs << create_output(coin, change.to_u64, change_addr)
        end
      
        tx = Protocol::Transaction.create(coin, unspent_outs, outputs)
        
        hashes_to_sign = Array(HashToSign).new
        return UnsignedTransaction.new(tx.to_hex, 0, hashes_to_sign)
        
        
      else
        return unspent_outs
      end
    
    end
    
    # Create an out with amount and address
    private def self.create_output(coin : CoinType,
      amount_satoshi : UInt64, 
      dest_addr : String)
    
      dest_addr_160 = Protocol::Network.address_to_hash160(coin, dest_addr)
      return Protocol::UTXOOutput.new(amount_satoshi, dest_addr_160)
        
    end
    
    # How much total value are we sending
    private def self.total_of_unspent(unspent_outs : Array(UnspentOut)) : UInt64
    
      total = 0.to_u64
      
      unspent_outs.each{ |unspent| total = total + unspent.amount }
        
      return total
          
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