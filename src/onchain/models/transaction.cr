module OnChain
  
  struct Transaction
  
    property confirmations : Int32
    property time : Int64
    property amount : BigInt
    property human_amount : Float64
    property address : String
    property deposit : Bool
    
    def initialize(
      @confirmations : Int32,
      @time : Int64, 
      @amount : BigInt, 
      @human_amount : Float64, 
      @address : String,
      @deposit : Bool)
    end
    
    def to_json(json)
      json.object do
        json.field "confirmations", @confirmations
        json.field "time", @time
        json.field "amount", @amount
        json.field "human_amount", @human_amount
        json.field "address", @address
        json.field "is_deposit", @deposit
      end
    end
    
    def self.from_blockcypher_json(tx : JSON::Any, addresses : Array(String))
    
      confirmations = tx["block_height"] != nil ? tx["block_height"].as_i : 0
      
      time = tx["confirmed"] != nil ? tx["confirmed"].as_s : ""
      dt = Time.parse time, "%FT%X%z" 
      
      usd_balance = 0.0.to_f64
      amount = BigInt.new tx["value"] != nil ? tx["value"].to_s : "0"
      
      address = addresses.first
      
      is_deposit = false
      
      tx_input_n = tx["tx_input_n"] != nil ? tx["tx_input_n"].as_i : 0
      is_deposit = true if tx_input_n == -1
      
      hbal = amount.to_f64 / OnChain::WEI_PER_ETHER.to_f64
      
      return Transaction.new(confirmations, dt.epoch, amount, hbal, address, is_deposit)
      
    end
    
    def self.from_etherscan_json(tx : JSON::Any, addresses : Array(String))
    
      confirmations = tx["blockNumber"] != nil ? tx["blockNumber"].as_i : 0
      
      time = 0
      
      amount = BigInt.new tx["value"] != nil ? tx["value"].as_i : 0
      
      address = vin["to"] != nil ? vin["to"].as_s : ""
      
      is_deposit = true
      
      hbal = amount.to_f64 / 1_00_000_000.0
      
      return Transaction.new(confirmations, time, amount, hbal, address, is_deposit)
      
    end
    
    def self.from_insight_json(tx : JSON::Any, addresses : Array(String))
    
      confirmations = tx["blockheight"] != nil ? tx["blockheight"].as_i : 0
      
      time = tx["time"] != nil ? tx["time"].as_i64 : 0.to_i64
      
      deposit = true
      amount = BigInt.new 0
      address = "Not Found"
      
      tx["vin"].each do |vin|
        addr = vin["addr"] != nil ? vin["addr"].as_s : ""
        am = vin["valueSat"] != nil ? vin["valueSat"].as_i : 0
        
        if addresses.includes? addr
          # Then this is a TX sent out from the wallet
          deposit = false
          address = addr
          amount = BigInt.new am
        end
      end
      
      tx["vout"].each do |vout|
      
        am = vout["value"] != nil ? 
          (Float32.new(vout["value"].as_s) * 100_000_000).to_i : 0
        
        addr = vout["scriptPubKey"]? != nil && 
          vout["scriptPubKey"]["addresses"]? != nil &&
          vout["scriptPubKey"]["addresses"][0]? != nil ?
            vout["scriptPubKey"]["addresses"][0].as_s : ""
            
        # If this is not a deposit assume the first out is what the user
        # wanted to send and to where
        if ! deposit
          address = addr
          amount = BigInt.new am
          break
        end
        
        if addresses.includes? addr 
          address = addr
          amount = BigInt.new am
        end
      end
      
      hbal = amount.to_f64 / 1_00_000_000.0
      
      return Transaction.new(confirmations, time, amount, hbal, address, deposit)
    end
  end
end