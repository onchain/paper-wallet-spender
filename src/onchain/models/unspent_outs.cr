module OnChain
  struct UnspentOuts
    
    getter total_input_value : BigInt
    getter unspent_outs : Array(UnspentOut)
    getter pub_hex_keys : Array(String)
    
    def initialize(
      @total_input_value : BigInt,
      @unspent_outs : Array(UnspentOut),
      @pub_hex_keys : Array(String))
    end
  end
end