module OnChain
  struct UnsignedEthereum
    
    def initialize(
      @txhex : String,
      @hash_to_sign : String)
    end
    
    def to_json(json)
      json.object do
        json.field "tx", @txhex
        json.field "hash_to_sign", @hash_to_sign
      end
    end
    
    def to_json
       string = JSON.build do |json|
        to_json(json)
       end
    end
  end
end