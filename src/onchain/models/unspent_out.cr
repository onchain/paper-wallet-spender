module OnChain

  struct UnspentOut
  
    property txid : String
    property amount : BigInt
    property vout : Int32
    property script_pub_key : String
  
    def initialize(@txid : String, @amount : BigInt, 
      @vout : Int32, @script_pub_key : String)
    end
    
    def self.from_blockinfo_json(utxo : JSON::Any)
      
      amount = utxo["value"].as_i64
      txid = utxo["tx_hash_big_endian"].as_s
      vout = utxo["tx_output_n"].as_i
      script_pub_key = utxo["script"].as_s
      
      return UnspentOut.new(txid, BigInt.new(amount), vout, script_pub_key)
    end
    
    def self.from_insight_json(utxo : JSON::Any)
      
      amount = utxo["satoshis"].as_i64
      txid = utxo["txid"].as_s
      vout = utxo["vout"].as_i
      script_pub_key = utxo["scriptPubKey"].as_s
      
      return UnspentOut.new(txid, BigInt.new(amount), vout, script_pub_key)
    end
    
    def to_json(json)
    
      json.object do
        json.field "txid", @txid
        json.field "amount", @amount
        json.field "vout", @vout
        json.field "script_pub_key", @script_pub_key
      end
    end
    
  end
end