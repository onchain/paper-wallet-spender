require "big"

module OnChain
  struct Balance
    getter balance : BigInt
    getter unconfirmed_balance : BigInt
    setter address : String?
    
    def initialize(
      @balance : BigInt, 
      @unconfirmed_balance : BigInt, 
      @human_balance : Float64, 
      @human_unconfirmed_balance : Float64, 
      @usd_balance : Float64,
      @address : String? = nil)
    end
    
    def to_json(json)
      json.object do
        json.field "balance", @balance
        json.field "unconfirmed_balance", @unconfirmed_balance
        json.field "human_balance", @human_balance
        json.field "human_unconfirmed_balance", @human_unconfirmed_balance
        json.field "usd_balance", @usd_balance
        if @address != nil
          json.field "address", @address
        end
      end
    end
    
    def to_json
       string = JSON.build do |json|
        to_json(json)
       end
    end
  end
end