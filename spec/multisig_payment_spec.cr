require "./spec_helper"

describe OnChain::Protocol do

  # https://www.soroushjp.com/2014/12/20/bitcoin-multisig-the-hard-way-
  # understanding-raw-multisignature-bitcoin-transactions/
  it "should agree with documented example" do
  
    key_a = "04a882d414e478039cd5b52a92ffb13dd5e6bd4515497439dffd691a0f12af95" + 
      "75fa349b5694ed3155b136f09e63975a1700c9f4d4df849323dac06cf3bd6458cd"

    key_b = "046ce31db9bdd543e72fe3039a1f1c047dab87037c36a669ff90e28da1848f64" + 
      "0de68c2fe913d363a51154a0c62d7adea1b822d05035077418267b1a1379790187"

    key_c = "0411ffd36c70776538d079fbae117dc38effafb33304af83ce4894589747aee1" + 
      "ef992f63280567f52f5ba870678b4ab4ff6c8ea600bd217870a8b4f1f09f3a8e83"
  
    rs = OnChain::Protocol::RedemptionScript.new(2, [key_a, key_b, key_c])
    
    rs.to_address(OnChain::CoinType::Bitcoin).to_s.should eq(
      "347N1Thc213QqfYCz3PZkjoJpNv5b14kBd")
     
      
    tx_from_article = (<<-TX
      01000000013dcd7d87904c9cb7f4b79f36b5a03f96e2e729284c09856238d5353e1182b002
      00000000fd5d01004730440220762ce7bca626942975bfd5b130ed3470b9f538eb2ac120c2
      043b445709369628022051d73c80328b543f744aa64b7e9ebefa7ade3e5c716eab4a09b408
      d2c307ccd701483045022100abf740b58d79cab000f8b0d328c2fff7eb88933971d1b63f8b
      99e89ca3f2dae602203354770db3cc2623349c87dea7a50cee1f78753141a5052b2d58aeb5
      92bcf50f014cc9524104a882d414e478039cd5b52a92ffb13dd5e6bd4515497439dffd691a
      0f12af9575fa349b5694ed3155b136f09e63975a1700c9f4d4df849323dac06cf3bd6458cd
      41046ce31db9bdd543e72fe3039a1f1c047dab87037c36a669ff90e28da1848f640de68c2f
      e913d363a51154a0c62d7adea1b822d05035077418267b1a1379790187410411ffd36c7077
      6538d079fbae117dc38effafb33304af83ce4894589747aee1ef992f63280567f52f5ba870
      678b4ab4ff6c8ea600bd217870a8b4f1f09f3a8e8353aeffffffff0130d900000000000019
      76a914569076ba39fc4ff6a2291d9ea9196d8c08f9c7ab88ac00000000 
    TX
    ).gsub(/\s+/, "") 
    
    tx = OnChain::Protocol::UTXOTransaction.new(tx_from_article)
    tx_from_article.should eq(tx.to_hex)
    
    # Create the outputs
    dest_addr = OnChain::Protocol::Address.new(OnChain::CoinType::Bitcoin,
      "18tiB1yNTzJMCg6bQS1Eh29dvJngq8QTfx")
    
    outputs = Array(OnChain::Protocol::UTXOOutput).new
    outputs << OnChain::PaymentService.create_output(OnChain::CoinType::Bitcoin, 
      55600.to_u64, dest_addr)
      
    unspent_out = OnChain::UnspentOut.new(
      "02b082113e35d5386285094c2829e7e2963fa0b5369fb7f4b79c4c90877dcd3d",
      BigInt.new(65600), 0, "1a8b0026343166625c7475f01e48b5ede8c0252e")
      
    unspent_outs = OnChain::UnspentOuts.new(BigInt.new(0), [unspent_out], [rs])
    
    # Create the transaction
    our_tx = OnChain::Protocol::Transaction.create(OnChain::CoinType::Bitcoin, 
      unspent_outs, outputs)
      
    sig_a = OnChain::Protocol::Signature.new(key_a, 0, 
      "30440220762ce7bca626942975bfd5b130ed3470b9f538eb2ac120c2043b4457093696" +
      "28022051d73c80328b543f744aa64b7e9ebefa7ade3e5c716eab4a09b408d2c307ccd7") 
      
    sig_c = OnChain::Protocol::Signature.new(key_a, 0, 
      "3045022100abf740b58d79cab000f8b0d328c2fff7eb88933971d1b63f8b99e89ca3f2" +
      "dae602203354770db3cc2623349c87dea7a50cee1f78753141a5052b2d58aeb592bcf5" +
      "0f") 
      
    tx_to_sign = OnChain::Protocol::UTXOTransaction.new(our_tx.txhex)
    tx_to_sign.sign([sig_a, sig_c])
    
    tx_to_sign.to_hex.should eq(tx_from_article)
    
  end
  
  it "should sign and send 2 of 2" do
  
    key_a = "02859f774e3fb7d785ddd3fd2fb89cfd6d37ce5f6db197c3c5e48bfd039c575600"

    key_b = "02119260a04662f14e584998bc384723123aa5c491501a20e150ff46445204483f"
  
    rs = OnChain::Protocol::RedemptionScript.new(2, [key_a, key_b])
    
    rs.to_address(OnChain::CoinType::Bitcoin).to_s.should eq(
      "3GXz2rrm6ftsDusn66BCRA1V4Md1Jup19U")
    
    # Create the outputs
    dest_addr = OnChain::Protocol::Address.new(OnChain::CoinType::Testnet3,
      "mwC6ZaXyTVnFMNYt1WRRh7sEwbDA3oHcRw")
    
    outputs = Array(OnChain::Protocol::UTXOOutput).new
    outputs << OnChain::PaymentService.create_output(OnChain::CoinType::Testnet3, 
      100000.to_u64, dest_addr)
      
    dest_addr = OnChain::Protocol::Address.new(OnChain::CoinType::Testnet3,
      "2N86C6bnni8QDRhWKmDo536zkGhqB5YjpPC")
      
    outputs << OnChain::PaymentService.create_output(OnChain::CoinType::Testnet3, 
      860000.to_u64, dest_addr)
     
    #puts OnChain::BlockchaininfoProvider.new(OnChain::CoinMarketCapRateProvider.new, true).get_unspent_outs(OnChain::CoinType::Testnet3, ["2N86C6bnni8QDRhWKmDo536zkGhqB5YjpPC"]) 
    unspent_out = OnChain::UnspentOut.new(
      "114f298e4a70f65f3e65843299cefad5b247343edf15cbc16698094e5b14695e",
      BigInt.new(1000000), 0, "a914a2d49082db7361042fa3fe449f4cfe3025b2929587")
      
    unspent_outs = OnChain::UnspentOuts.new(BigInt.new(0), [unspent_out], [rs])
    
    # Create the transaction
    our_tx = OnChain::Protocol::Transaction.create(OnChain::CoinType::Bitcoin, 
      unspent_outs, outputs)
    
    sig1 = <<-SIG
    304402205d8d662baab4797b8d7c50cfe73eeca807b36d6a438088f8d4e7c738b232984102
    2007ac35170fef390e04b1971308c260b1c668c03592e2a50e10e85182ec71e7c3
    SIG
    sig1 = sig1.gsub("\n", "")
    
    sig2 = <<-SIG
    3045022100e99e76523de83886c40d2fe430f4b9c0fe97ab8d7f6eea24af0279921a3b8ecc
    0220480566da0516bc066db0d094a7a1d34d1d92b03975a75971763ff6cbb048cfb3
    SIG
    sig2 = sig2.gsub("\n", "")
    
    sig_a = OnChain::Protocol::Signature.new(key_a, 0, sig1)
    sig_b = OnChain::Protocol::Signature.new(key_b, 0, sig2)
    
    
    tx_to_sign = OnChain::Protocol::UTXOTransaction.new(our_tx.txhex)
    tx_to_sign.sign([sig_a, sig_b])
    
    # This tx was signed by this code and sent. Signatures came from bitoinjs
    # running on custody.
    # https://live.blockcypher.com/btc-testnet/tx/cc453dfe3b744cb7cc9ee8f128f532
    # 2d0d723ca7232339920b64f024225d478f/
    tx_sent_with_this_code = (<<-TX
      01000000015e69145b4e099866c1cb15df3e3447b2d5face993284653e5ff6704a8e294f11
      00000000db0047304402205d8d662baab4797b8d7c50cfe73eeca807b36d6a438088f8d4e7
      c738b2329841022007ac35170fef390e04b1971308c260b1c668c03592e2a50e10e85182ec
      71e7c301483045022100e99e76523de83886c40d2fe430f4b9c0fe97ab8d7f6eea24af0279
      921a3b8ecc0220480566da0516bc066db0d094a7a1d34d1d92b03975a75971763ff6cbb048
      cfb3014c47522102859f774e3fb7d785ddd3fd2fb89cfd6d37ce5f6db197c3c5e48bfd039c
      5756002102119260a04662f14e584998bc384723123aa5c491501a20e150ff46445204483f
      52aeffffffff02a0860100000000001976a914abf102c1e98693c5949c02559a8a8b33d102
      de5b88ac601f0d000000000017a914a2d49082db7361042fa3fe449f4cfe3025b292958700
      000000
    TX
    ).gsub(/\s+/, "") 
    
    tx_to_sign.to_hex.should eq(tx_sent_with_this_code)
  end

  it "should parse and re-generate multi sig transaction" do
  
    old_provider = OnChain::PROVIDERS[OnChain::CoinType::Testnet3]
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
      
      
      
      tx_hex = (<<-TX
        0100000001bdf81543e420b7372f76f5be63e38a02f383dacc4a88eb6bdef5908f5c11ed
        0101000000db004830450221009474dc743fd0f260e1ada66f13e2d24585ff9e533af653
        2ca828b9622ce6c3d5022071b3e846858e11d5a47e6e0352ff6affbf92543abbdd609e56
        2fe7af3ae32c7e0147304402204c4abb075dad7c798ad7196dce2f1f2167a9b68e488b8e
        89496ff3b6253b4c7102207c7221098853c92c0ba80addcfa1e10db1654f2466f9df34a3
        693432ffc34d91014c47522102cc95dd4a29ccc38e46592602248e33ed56e8b3ea08d4d3
        1f5688cbc52e85e2032103fd62b002c449b4d461a8582a5dc157ffc3fa99ec1d6df0ddb5
        800610fb3e66f252aeffffffff02a0860100000000001976a914abf102c1e98693c5949c
        02559a8a8b33d102de5b88ac70f305000000000017a9147588fde54423e618415df6b792
        bdd7e2da817ac78700000000
      TX
      ).gsub(/\s+/, "")
      
      tx_to_sign.to_hex.should eq(tx_hex)
      
    else
      true.should eq false
    end
    
    OnChain::PROVIDERS[OnChain::CoinType::Testnet3] = old_provider
  
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