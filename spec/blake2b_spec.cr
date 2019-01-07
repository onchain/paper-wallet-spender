require "./spec_helper"

describe OnChain do

  it "generate a blake2b hash" do
  
    OnChain.blake2b("", "ZcashPrevoutHash").should eq(
      "d53a633bbecf82fe9e9484d8a0e727c73bb9e68c96e72dec30144f6a84afa136")
      
    OnChain.blake2b("", "ZcashSequencHash").should eq(
      "a5f25f01959361ee6eb56a7401210ee268226f6ce764a4f10b7f29e54db37272")
    
    OnChain.blake2b(
      "8f739811893e0000095200ac6551ac636565b1a45a0805750200025151", 
      "ZcashOutputsHash").should eq(
      "ec55f4afc6cebfe1c35bdcded7519ff6efb381ab1d5a8dd0060c13b2a512932b")
    
    OnChain.blake2b("", "ZcashSigHash").should eq(
      "7a45ddd061e80077023f8ac2436d21fb19b57ce7929df4ea3fff7bceefc15360")
      
  end
end