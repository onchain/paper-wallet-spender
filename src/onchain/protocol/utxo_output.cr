module OnChain
  module Protocol
    class UTXOOutput
    
      property value : UInt64
      property pk_script : Bytes
      property pk_script_length : UInt64
      
      def initialize(@value : UInt64, hash160 : String)
        
        io = IO::Memory.new
        io.write_bytes("76".to_i(16).to_u8) #  DUP
        io.write_bytes("a9".to_i(16).to_u8) #  HASH160
        io.write_bytes("14".to_i(16).to_u8) #  length
        io.write(OnChain.to_bytes(hash160))
        io.write_bytes("88".to_i(16).to_u8) #  EQUALVERIFY
        io.write_bytes("ac".to_i(16).to_u8) #  CHECKSIG
        pk_script = io.to_slice
        
        @pk_script = pk_script
        @pk_script_length = pk_script.size.to_u64
      end
      
      def initialize(@value : UInt64, address : Address)
        
        io = IO::Memory.new
        io.write_bytes("76".to_i(16).to_u8) #  DUP
        io.write_bytes("a9".to_i(16).to_u8) #  HASH160
        io.write_bytes("14".to_i(16).to_u8) #  length
        io.write(address.hash160)
        io.write_bytes("88".to_i(16).to_u8) #  EQUALVERIFY
        io.write_bytes("ac".to_i(16).to_u8) #  CHECKSIG
        pk_script = io.to_slice
        
        @pk_script = pk_script
        @pk_script_length = pk_script.size.to_u64
        
      end
      
      def initialize(buffer : IO::Memory)
      
        @value = Transaction.readUInt64(buffer)
        @pk_script_length = Transaction.parse_var_int(buffer)
        
        pk_script_slice = Slice(UInt8).new(@pk_script_length)
        buffer.read(pk_script_slice)
        @pk_script = pk_script_slice
        
      end
      
      def to_buffer(buffer : IO::Memory)
      
        buffer.write_bytes(value, IO::ByteFormat::LittleEndian)
        Transaction.write_var_int(buffer, pk_script_length)
        buffer.write(pk_script)
      
      end
    
    end
  end
end