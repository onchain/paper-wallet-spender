module OnChain
  module Protocol
    class Signature
    
      property public_key : String
      property input_index : Int32
      property signature_der : String
      
      def initialize(@public_key : String, @input_index : Int32, 
        @signature_der : String)
      end
    
    end
  end
end