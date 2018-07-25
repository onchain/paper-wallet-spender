module OnChain
  module Protocol
    class ZCashTransaction < Transaction

      property data: String
      property gas_limit: UInt64
      property gas_price: UInt64
      property nonce: UInt32
      property to: String
      property value: BigInt
      property v: UInt32?
      property s: String?
      property r: String?

      def initialize(
       gas_limit: UInt64,
       gas_price: UInt64,
       from: String,
       to: String,
       value: BigInt
       )

        @gas_limit = gas_limit
        @gas_price = gas_price
        @from = from
        @to = to
        @value = value

      end

      def initialize(hex_tx : String)

        slice = OnChain.to_bytes hex_tx

        buffer = IO::Memory.new(slice)

        @gas_limit = Transaction.readUInt64(buffer)
        @gas_price = Transaction.readUInt64(buffer)
        @from = Transaction.readUInt64(buffer)
        @to = Transaction.readUInt64(buffer)
        @value = Transaction.readBigInt(buffer)

        @join_split_size = Transaction.parse_var_int(buffer)

      end

      # Implementation of ZIP143
      # https://github.com/zcash/zips/blob/master/zip-0143.rst

      def to_hex : String

        buffer = IO::Memory.new

        buffer.write_bytes(gas_limit, IO::ByteFormat::LittleEndian)
        buffer.write_bytes(gas_price, IO::ByteFormat::LittleEndian)

        buffer.write_bytes(from, IO::ByteFormat::LittleEndian)
        buffer.write_bytes(to, IO::ByteFormat::LittleEndian)
        buffer.write_bytes(value, IO::ByteFormat::LittleEndian)

        Transaction.write_var_int(buffer, join_split_size.to_u64)

        return OnChain.to_hex buffer.to_slice
      end

      def sign(
      gas_limit: UInt64,
             gas_price: UInt64,
             from: String,
             to: String,
             value: BigInt
             r: UInt32,
             s: UInt32,
             v: UInt32
      ) : String
        slice = OnChain.to_bytes hex_tx

        buffer = IO::Memory.new(slice)

        @gas_limit = Transaction.readUInt64(buffer)
        @gas_price = Transaction.readUInt64(buffer)
        @from = Transaction.readUInt64(buffer)
        @to = Transaction.readUInt64(buffer)
        @value = Transaction.readBigInt(buffer)
        @r = Transaction.readUInt32(buffer)
        @s = Transaction.readUInt32(buffer)
        @v = Transaction.readUInt32(buffer)

        @join_split_size = Transaction.parse_var_int(buffer)

    end

  end
