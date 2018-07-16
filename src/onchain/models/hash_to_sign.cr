module OnChain
  struct HashToSign
    
    def initialize(
      @hash_to_sign : String,
      @public_key : String, 
      @input_index : Int32)
    end
    
    def to_json(json)
      json.object do
        json.field "hash_to_sign", @hash_to_sign
        json.field "public_key", @public_key
        json.field "input_index", @input_index
      end
    end
    
    def to_json
       string = JSON.build do |json|
        to_json(json)
       end
    end
  end
end