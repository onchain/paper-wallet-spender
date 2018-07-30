require "./spec_helper"

describe OnChain::Protocol do

  it "should parse and re-generate multi sig transaction" do
  
    OnChain::PROVIDERS[OnChain::CoinType::Testnet3] = BitcoinTestProvider.new
    
    # pk1 = Bitcoin::Key.new "bad6e70318bc9eb421aec5696d2687fca54834b9cf695c041053c9f75f04b679"
    # pk2 = Bitcoin::Key.new "6bcc1b7643705e8bfe9a16cbb57c219210be8042e377a9ae21381e26de7f4442"
  
    pub_keys_hex = 
      ["02cc95dd4a29ccc38e46592602248e33ed56e8b3ea08d4d31f5688cbc52e85e203",
      "03fd62b002c449b4d461a8582a5dc157ffc3fa99ec1d6df0ddb5800610fb3e66f2"]
      
    rs = OnChain::Protocol::RedemptionScript.new(2, pub_keys_hex)
    
    rs.to_address(OnChain::CoinType::Testnet3).to_s.should eq(
      "2N3xhA5pEmTxZYgQxdooCoAxGoX3cGCYCsE")
      
    dest_addr = OnChain::Protocol::Address.new(OnChain::CoinType::Testnet3, 
      "mwC6ZaXyTVnFMNYt1WRRh7sEwbDA3oHcRw")
  
    unsigned_tx = OnChain::PaymentService.create_multi_sig(
      OnChain::CoinType::Testnet3, 
      [rs],
      dest_addr,
      BigInt.new(100000),
      10000.to_u64)
      
    tx_hex = (<<-TX
      0100000001bdf81543e420b7372f76f5be63e38a02f383dacc4a88eb6bdef5908f5c11ed01
      0100000047522102cc95dd4a29ccc38e46592602248e33ed56e8b3ea08d4d31f5688cbc52e
      85e2032103fd62b002c449b4d461a8582a5dc157ffc3fa99ec1d6df0ddb5800610fb3e66f2
      52aeffffffff02a0860100000000001976a914abf102c1e98693c5949c02559a8a8b33d102
      de5b88ac70f305000000000017a9147588fde54423e618415df6b792bdd7e2da817ac78700
      000000
    TX
    ).gsub(/\s+/, "")
    
      
    case unsigned_tx
    when OnChain::UnsignedTransaction
      
      unsigned_tx.txhex.should eq(tx_hex)
      
      unsigned_tx.hashes.size.should eq(2)
      
      unsigned_tx.hashes[0].hash_to_sign.should eq(
        "e8649145b8c48e74768b099ba63c51503d77edfb89875cb54cfba8d90c8f1618")
      
      unsigned_tx.hashes[1].hash_to_sign.should eq(
        "e8649145b8c48e74768b099ba63c51503d77edfb89875cb54cfba8d90c8f1618")
      
      unsigned_tx.hashes[0].public_key.should eq(pub_keys_hex[0])
      
      unsigned_tx.hashes[1].public_key.should eq(pub_keys_hex[1])
      
      tx_to_sign = OnChain::Protocol::UTXOTransaction.new(
        unsigned_tx.txhex)
        
      tx_to_sign.to_hex.should eq(unsigned_tx.txhex)
      
      # OnChain.bin_to_hex(pk1.sign(OnChain.hex_to_bin(hash_to_sign)))
      sig1 = OnChain::Protocol::Signature.new(
        "02cc95dd4a29ccc38e46592602248e33ed56e8b3ea08d4d31f5688cbc52e85e203",
        0, 
        "30450221009474dc743fd0f260e1ada66f13e2d24585ff9e533af6532ca828b9622c" +
        "e6c3d5022071b3e846858e11d5a47e6e0352ff6affbf92543abbdd609e562fe7af3a" +
        "e32c7e")
        
      sig2 = OnChain::Protocol::Signature.new(
        "03fd62b002c449b4d461a8582a5dc157ffc3fa99ec1d6df0ddb5800610fb3e66f2",
        0, 
        "304402204c4abb075dad7c798ad7196dce2f1f2167a9b68e488b8e89496ff3b6253b" +
        "4c7102207c7221098853c92c0ba80addcfa1e10db1654f2466f9df34a3693432ffc3" +
        "4d91")
        
      tx_to_sign.sign([sig1, sig2])
      
    else
      true.should eq false
    end
  
  end
  
end

# We supply the unspent outs so that we don't contatc the internet
class BitcoinTestProvider < OnChain::UTXOProvider

  def address_history(coin : CoinType, addresses : Array(String))
    return NodeStatus.new 500, "Error retrieving history"
  end
  
  def push_tx(coin : CoinType, tx : String)
    return NodeStatus.new 500, "Error retrieving history"
  end
  
  def get_unspent_outs(coin : OnChain::CoinType, addresses : Array(String))
  
    utxo = [] of OnChain::UnspentOut
    utxo << OnChain::UnspentOut.new(
      "01ed115c8f90f5de6beb884accda83f3028ae363bef5762f37b720e44315f8bd",
      BigInt.new(500000),
      1, 
      "a9147588fde54423e618415df6b792bdd7e2da817ac787")
    return utxo
    
  end
    
end