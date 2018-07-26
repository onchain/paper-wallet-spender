module OnChain
  struct UnspentOuts
    
    getter total_input_value : BigInt
    getter unspent_outs : Array(UnspentOut)
    getter pub_hex_keys : Array(String)
    getter redemption_scripts : Array(Protocol::RedemptionScript)
    
    def initialize(
      @total_input_value : BigInt,
      @unspent_outs : Array(UnspentOut),
      @pub_hex_keys : Array(String))
      @redemption_scripts = [] of Protocol::RedemptionScript
    end
    
    def initialize(
      @total_input_value : BigInt,
      @unspent_outs : Array(UnspentOut),
      @redemption_scripts : Array(Protocol::RedemptionScript))
      @pub_hex_keys = [] of String
    end
  end
end