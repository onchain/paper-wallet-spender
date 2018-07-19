module OnChain

  class PaymentService
  
    def self.create(coin : CoinType, pub_hex_keys : Array(String),
      dest_addr : String, amount : BigInt, fee_satoshi : BigInt,
      fee_addr : String, miners_fee : UInt64) : UnsignedTransaction
    
    
      
    
    
      tx_hex = ""
      hashes_to_sign = Array(HashToSign).new
      return UnsignedTransaction.new(tx_hex, 0, hashes_to_sign)
    
    end
    
  end
  
end # end module