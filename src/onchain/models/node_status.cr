module OnChain
  struct NodeStatus
    def initialize(
      @status_code : Int32, 
      @message : String)
    end
    
    def to_json
      string = JSON.build do |json|
        json.object do
          json.field "status_code", @status_code
          json.field "message", @message
        end
      end
    end
  end
end