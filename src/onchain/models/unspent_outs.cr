module OnChain
  struct UnspentOuts
    
    getter total_input_value : BigInt
    getter unspent_outs : Array(UnspentOut)
    
    def initialize(
      @total_input_value : BigInt,
      @unspent_outs : Array(UnspentOut))
    end
  end
end