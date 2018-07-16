require "./spec_helper"

describe OnChain::Protocol do

  it "should parse a hex zcash transaction" do
  
    # Normal Zcash spend transaction.
    tx_hex = (<<-TX
      030000807082c4030138e86e187f471ce1ebbaf30463d9995bd56fdd49a25ed5269b148f30
      6245e06f010000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88acffffff
      ff03c0c62d00000000001976a914cfa26596e91ba32e19b0c448523058059841cf8788ac30
      750000000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88accb6a0700
      000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88ac00000000000000
      0000
    TX
    ).gsub(/\s+/, "")
  
    tx = OnChain::Protocol::Transaction.create(OnChain::CoinType::ZCash, tx_hex)
  
    tx.class.should eq(OnChain::Protocol::UTXOTransaction)
    
    tx.ver.should eq(3)
  end
  
end
