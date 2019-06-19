module OnChain
  
  struct History
  
    property total_txs : Int32
    property txs : Array(Transaction)
    
    def initialize(
      @total_txs : Int32,
      @txs : Array(Transaction))
    end
    
    def to_json
      string = JSON.build do |json|
        json.object do
          json.field "total_txs", @total_txs
          json.field "txs", @txs
        end
      end
    end
    
    def self.from_blockinfo_json(history : JSON::Any, addresses : Array(String))
    
      total_txs = history["txs"]? != nil ? history["txs"].size : 0
      
      txs = [] of Transaction
      if history["txs"]? != nil
        history["txs"].as_a.each do |tx|
          txs << Transaction.from_blockinfo_json tx, addresses
        end
      end
      
      return History.new(total_txs, txs)
    end
    
    def self.from_insight_json(history : JSON::Any, addresses : Array(String))
    
      total_txs = history["totalItems"] != nil ? history["totalItems"].as_i : 0
      
      txs = [] of Transaction
      if history["items"] != nil
        history["items"].as_a.each do |tx|
          txs << Transaction.from_insight_json tx, addresses
        end
      end
      
      return History.new(total_txs, txs)
    end
    
    def self.from_bitcoincom_json(hist : JSON::Any, addresses : Array(String))
    
      # Comes back as array so just parse first one.
      history = hist.as_a.first 

      # We don't get info about number of tx's from bitcoin.com
      total_txs = 0
      
      txs = [] of Transaction
      if history["txs"] != nil
        history["txs"].as_a.each do |tx|
          txs << Transaction.from_insight_json tx, addresses
        end
      end
      
      return History.new(total_txs, txs)
    end
    
    def self.from_blockcypher_json(history : JSON::Any, addresses : Array(String))
    
      total_txs = 0
      
      txs = [] of Transaction
      if history["txrefs"] != nil
        history["txrefs"].as_a.each do |tx|
          txs << Transaction.from_blockcypher_json tx, addresses
        end
      end
      
      return History.new(total_txs, txs)
    end
    
    def self.from_etherscan_json(history : JSON::Any, addresses : Array(String))
    
      total_txs = 0
      
      txs = [] of Transaction
      if history["result"] != nil
        history["result"].as_a.each do |tx|
          txs << Transaction.from_blockcypher_json tx, addresses
        end
      end
      
      return History.new(total_txs, txs)
    end
  end
end