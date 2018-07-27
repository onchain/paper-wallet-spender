module OnChain

  class PaymentService
  
    def self.create_multi_sig(coin : CoinType, 
      redemption_scripts : Array(Protocol::RedemptionScript),
      dest_addr : Protocol::Address, 
      amount_satoshi : BigInt, 
      miners_fee : UInt64 = 40000,
      fee_satoshi : BigInt = BigInt.new(0), 
      fee_addr : Protocol::Address? = nil) : UnsignedTransaction | NodeStatus
    
      total_amount = amount_satoshi + fee_satoshi + miners_fee
      
      unspent_outs = get_unspent_for_multisig_amount(coin, 
        redemption_scripts, total_amount)
      
      case unspent_outs
      when UnspentOuts
      
        outputs = Array(Protocol::UTXOOutput).new
        
        # The spend output
        outputs << create_output(coin, amount_satoshi.to_u64, dest_addr)
          
        # Our fees
        if fee_addr && fee_satoshi > DUST_SATOSHIES
          outputs << create_output(coin, fee_satoshi.to_u64, fee_addr)
        end
        
        # The change
        change = unspent_outs.total_input_value - total_amount
        if change > DUST_SATOSHIES
        
          change_addr = redemption_scripts.first.to_address(coin)
            
          outputs << create_output(coin, change.to_u64, change_addr)
        end
      
        return Protocol::Transaction.create(coin, unspent_outs, outputs)
        
      else
        # Soemthing went wrong getting unspent outs from the network.
        return unspent_outs
      end
    
    end
    
    private def self.get_unspent_for_multisig_amount(
      coin : CoinType, 
      redemption_scripts : Array(Protocol::RedemptionScript), 
      amount : BigInt) : UnspentOuts | NodeStatus
      
      # Convert the public keys to network addresses
      keys = redemption_scripts.map{ |rs| 
        rs.to_address(coin).to_s
      }
      
      unspents = PROVIDERS[coin].get_unspent_outs(coin, keys)
      
      case unspents
      when Array(UnspentOut)
        just_the_ones_we_need = Array(UnspentOut).new
        scripts = Array(Protocol::RedemptionScript).new
        total = BigInt.new 
        
        unspents.each do |unspent|
        
          just_the_ones_we_need << unspent
          total = total + unspent.amount
          
          # Store the corresponding redemption script.
          redemption_scripts.each do |rs|
            hash160 = Protocol::Network.pubhex_to_hash160 rs.to_hex
            if "a914#{hash160}87" == unspent.script_pub_key
              scripts << rs
            end
          end
          
          if total >= amount
            return UnspentOuts.new(total, just_the_ones_we_need, scripts)
          end
        end
        
        return UnspentOuts.new(total, just_the_ones_we_need, scripts)
        
      else
        # It failed so returnt he node status
        return unspents
      end
      
    end
    
  end
  
end # end module