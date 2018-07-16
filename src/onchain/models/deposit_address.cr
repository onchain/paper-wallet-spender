module OnChain
  struct DepositAddress
    
    def initialize(
      @deposit_address : String,
      @errors : Array(String))
    end
    
    def to_json(json)
      json.object do
        json.field "deposit_address", @deposit_address
        json.field "errors", @errors
      end
    end
    
    def to_json
       string = JSON.build do |json|
        to_json(json)
       end
    end
  end
end