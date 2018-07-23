require "./spec_helper"

describe OnChain::BlockCypherEthereumProvider do

  it "should get a parse the result of a posted transaction" do
  
    sent_tx_json = (<<-SENT
    {
     "tx": {
       "block_height": -1,
       "block_index": 0,
       "hash": "4a779ed5614b7e240db575067ecba9fb4d83f50a3cbff0575fc84fb79f9a080c",
       "addresses": [
         "46fc2341dc457ba023cf6d60cb0729e5928a81e6",
         "aa429fedc40eaa82894e5a9d6a678ea57ac19daf"
       ],
       "total": 1000000000000000,
       "fees": 600000000000000,
       "size": 109,
       "gas_limit": 30000,
       "gas_price": 20000000000,
       "relayed_by": "54.80.188.44",
       "received": "2018-07-23T13:36:48.666959843Z",
       "ver": 0,
       "double_spend": false,
       "vin_sz": 1,
       "vout_sz": 1,
       "confirmations": 0,
       "inputs": [
         {
           "sequence": 10,
           "addresses": [
             "46fc2341dc457ba023cf6d60cb0729e5928a81e6"
           ]
         }
       ],
       "outputs": [
         {
           "value": 1000000000000000,
           "script": "00",
           "addresses": [
             "aa429fedc40eaa82894e5a9d6a678ea57ac19daf"
           ]
         }
       ]
     }
    }
    SENT
    ).gsub(/\s+/, "")
    
    result = OnChain::ETHEREUM_PROVIDER.parse_answer(sent_tx_json)
    
    result.should eq("4a779ed5614b7e240db575067ecba9fb4d83f50a3cbff0575fc84f" +
      "b79f9a080c")
   
  end
  
end
