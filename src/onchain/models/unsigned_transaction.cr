module OnChain
  struct UnsignedTransaction
    
    getter txhex : String
    getter total_input_value : Int64
    getter hashes : Array(HashToSign)
    
    def initialize(
      @txhex : String,
      @total_input_value : Int64,
      @hashes : Array(HashToSign))
    end
    
    def to_json(json)
      json.object do
        json.field "tx", @txhex
        json.field "total_input_value", @total_input_value
        json.field "hashes", @hashes
      end
    end
    
    def to_json
       string = JSON.build do |json|
        to_json(json)
       end
    end
  end
end