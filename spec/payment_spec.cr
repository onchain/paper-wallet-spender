require "./spec_helper"

describe OnChain::Protocol do

  it "should create a testnet3 transaction" do
  
    pub_keys_hex = 
      [OnChain::Protocol::PublicKey.new(
        "028f883177988f212f2f1b89bc0aa1fb0683899c3665b62167b0daa998018f85d7")]
      
    dest_addr = OnChain::Protocol::Address.new(OnChain::CoinType::Testnet3,
      "mwC6ZaXyTVnFMNYt1WRRh7sEwbDA3oHcRw")
    
    fee_addr = OnChain::Protocol::Address.new(OnChain::CoinType::Testnet3,
      "n28nbaep2LLs6amVjggZhfTwUzBWsrPfmq")
  
    unsigned_tx = OnChain::PaymentService.create(
      OnChain::CoinType::Testnet3, 
      pub_keys_hex,
      dest_addr,
      BigInt.new(100000),
      40000, 
      BigInt.new(400000), 
      fee_addr)
      
    # This was generated by CW, doesn't mean it's correct.
    tx_hex = (<<-TX
      0100000001952000e6051ab33ead433ce8ca3b65eda1145fe629f001d9f90575980a2f39fa
      020000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388acffffffff03a086
      0100000000001976a914abf102c1e98693c5949c02559a8a8b33d102de5b88ac801a060000
      0000001976a914e229651d1ea66dbdfc4ec59f1eb9394559c284c988ac602e3c1700000000
      1976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac00000000
    TX
    ).gsub(/\s+/, "")
      
    case unsigned_tx
    when OnChain::UnsignedTransaction
      unsigned_tx.txhex.should eq(tx_hex)
      
      unsigned_tx.hashes.size.should eq(1)
      
      unsigned_tx.hashes[0].hash_to_sign.should eq(
        "139932949635a161c31603a9889e24c5d81b163e82355beceb902eb279b96fcf")
      
      unsigned_tx.hashes[0].public_key.should eq(pub_keys_hex[0].pub_key_hex)
    else
      true.should eq false
    end
  
  end

  it "should generate a transaction with no fees" do
  
    old_provider = OnChain::PROVIDERS[OnChain::CoinType::ZCash]
    OnChain::PROVIDERS[OnChain::CoinType::ZCash] = ZCashTestProvider.new
    
    pub_keys_hex = 
      [OnChain::Protocol::PublicKey.new(
        "028f883177988f212f2f1b89bc0aa1fb0683899c3665b62167b0daa998018f85d7")]
      
    dest_addr = OnChain::Protocol::Address.new(OnChain::CoinType::ZCash,
      "t1coURaGEsTgaG6Jp8Y2rA2sUppakecfJKC")
  
    unsigned_tx = OnChain::PaymentService.create(
      OnChain::CoinType::ZCash, 
      pub_keys_hex,
      dest_addr,
      BigInt.new(100000),
      40000)
      
    # This was generated by CW, doesn't mean it's correct.
    tx_hex = (<<-TX
      030000807082c40301b512064015a7ca3080aad1b29c3c7968596a73ec01523fb0428a3f34
      34c0e9b6020000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388acffffff
      ff02a0860100000000001976a914cfa26596e91ba32e19b0c448523058059841cf8788ac95
      821b00000000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac00000000
      0000000000
    TX
    ).gsub(/\s+/, "")
      
    case unsigned_tx
    when OnChain::UnsignedTransaction
      unsigned_tx.txhex.should eq(tx_hex)
    else
      true.should eq false
    end
    
    OnChain::PROVIDERS[OnChain::CoinType::ZCash] = old_provider
  end

  it "should parse and re-generate zcash transaction" do
  
    old_provider = OnChain::PROVIDERS[OnChain::CoinType::ZCash]
    OnChain::PROVIDERS[OnChain::CoinType::ZCash] = ZCashTestProvider.new
  
    pub_keys_hex = 
      [OnChain::Protocol::PublicKey.new(
        "028f883177988f212f2f1b89bc0aa1fb0683899c3665b62167b0daa998018f85d7")]
      
    dest_addr = OnChain::Protocol::Address.new(OnChain::CoinType::ZCash,
      "t1coURaGEsTgaG6Jp8Y2rA2sUppakecfJKC")
    
    fee_addr = OnChain::Protocol::Address.new(OnChain::CoinType::ZCash,
      "t1aZLWNcFHR3apVoMuAPzEjGbdbR2qGfcAw")
  
    unsigned_tx = OnChain::PaymentService.create(
      OnChain::CoinType::ZCash, 
      pub_keys_hex,
      dest_addr,
      BigInt.new(100000),
      40000, 
      BigInt.new(400000), 
      fee_addr)
      
    # This was generated by CW, doesn't mean it's correct.
    tx_hex = (<<-TX
      030000807082c40301b512064015a7ca3080aad1b29c3c7968596a73ec01523fb0428a3f34
      34c0e9b6020000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388acffffff
      ff03a0860100000000001976a914cfa26596e91ba32e19b0c448523058059841cf8788ac80
      1a0600000000001976a914b705b67a8c0caeb68bbafe8377da8c19aff1e2e788ac15681500
      000000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac00000000000000
      0000
    TX
    ).gsub(/\s+/, "")
      
    case unsigned_tx
    when OnChain::UnsignedTransaction
      unsigned_tx.txhex.should eq(tx_hex)
      
      unsigned_tx.hashes.size.should eq(1)
      
      unsigned_tx.hashes[0].hash_to_sign.should eq(
        "11c4776527c1f3e3f02d032c08a360fce1f572a8479bcc98859fa86e75858ca0")
      
      unsigned_tx.hashes[0].public_key.should eq(pub_keys_hex[0].pub_key_hex)
    else
      true.should eq false
    end
    
    OnChain::PROVIDERS[OnChain::CoinType::ZCash] = old_provider
  
  end
  
end

# We supply the unspent outs so that we don't contatc the internet
class ZCashTestProvider < OnChain::UTXOProvider

  def address_history(coin : CoinType, addresses : Array(String))
    return NodeStatus.new 500, "Error retrieving history"
  end
  
  def push_tx(coin : CoinType, tx : String)
    return NodeStatus.new 500, "Error retrieving history"
  end
  
  def get_unspent_outs(coin : OnChain::CoinType, addresses : Array(String))
  
    utxo = [] of OnChain::UnspentOut
    utxo << OnChain::UnspentOut.new(
      "b6e9c034343f8a42b03f5201ec736a5968793c9cb2d1aa8030caa715400612b5",
      BigInt.new(1942901),
      2, 
      "76a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac")
    return utxo
    
  end
    
end