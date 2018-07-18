require "./spec_helper"

describe OnChain::BlockchaininfoProvider do

  it "should get a balance" do
  
    provider = OnChain::BlockchaininfoProvider.new(
      OnChain::CoinMarketCapRateProvider.new)
      
    balance = provider.get_balance(OnChain::CoinType::Bitcoin,
      "16KBLs5NVpUcrhmcC7eifHuSJjKLufApak")
      
    case balance
    when OnChain::Balance
      balance.balance.should eq(16020000)
    else
      true.should eq(false)
    end
  end

  it "should parse blockinfo history json" do
  
    history_json = (<<-HISTORY
    {"recommend_include_fee":true,"info":{"nconnected":0,"conversion":100000000.
    00000000,"symbol_local":{"code":"USD","symbol":"$","name":"U.S. dollar","con
    version":13458.58792495,"symbolAppearsAfter":false,"local":true},"symbol_btc
    ":{"code":"BTC","symbol":"BTC","name":"Bitcoin","conversion":100000000.00000
    000,"symbolAppearsAfter":true,"local":false},"latest_block":{"block_index":1
    710956,"hash":"0000000000000000001a34295aa5bd9bc0836d841a7522dc52f06fb1be1dd
    ed9","height":532425,"time":1531900093}},"wallet":{"n_tx":3,"n_tx_filtered":
    3,"total_received":17400000,"total_sent":1380000,"final_balance":16020000},"
    addresses":[{"address":"16KBLs5NVpUcrhmcC7eifHuSJjKLufApak","n_tx":3,"total_
    received":17400000,"total_sent":1380000,"final_balance":16020000,"change_ind
    ex":0,"account_index":0}],"txs":[{"hash":"ee35ee032fcc1044651668559eca8c5367
    d9cf2bba853cb1a6b73dff4021c757","ver":1,"vin_sz":1,"vout_sz":3,"size":260,"w
    eight":1040,"fee":40000,"relayed_by":"0.0.0.0","lock_time":0,"tx_index":3586
    82727,"double_spend":false,"result":-840000,"balance":16020000,"time":153088
    1190,"block_height":530724,"inputs":[{"prev_out":{"value":16860000,"tx_index
    ":358445991,"n":2,"spent":true,"script":"76a9143a48bfebcdc52c7b3831eab75a195
    5e58744c7e388ac","type":0,"addr":"16KBLs5NVpUcrhmcC7eifHuSJjKLufApak"},"sequ
    ence":4294967295,"script":"483045022100e431cf3c9d3d1112932ee0b0a0290737c5600
    fcb2ecfae555e151952712383820220158fb5ced0208ed2f484eccac3931824cda6cde54074f
    13d253ff6b8e993b5240121028f883177988f212f2f1b89bc0aa1fb0683899c3665b62167b0d
    aa998018f85d7","witness":""}],"out":[{"value":400000,"tx_index":358682727,"n
    ":0,"spent":true,"script":"76a914499d074e349350d3aca6bf334b0637e5f501370788a
    c","type":0,"addr":"17iESYBf7CQMxCxdabiMfjZRDniGDZkyX3"},{"value":400000,"tx
    _index":358682727,"n":1,"spent":false,"script":"76a914b705b67a8c0caeb68bbafe
    8377da8c19aff1e2e788ac","type":0,"addr":"1HgjW3C7K6FzDrkTxjas6vAgNwDx37HTHT"
    },{"value":16020000,"tx_index":358682727,"n":2,"spent":false,"script":"76a91
    43a48bfebcdc52c7b3831eab75a1955e58744c7e388ac","type":0,"addr":"16KBLs5NVpUc
    rhmcC7eifHuSJjKLufApak"}]},{"hash":"076f6beb483fcd9b5b863e0eb871d62cae68097f
    d004a6b963bb0c9d3c3bb98f","ver":1,"vin_sz":1,"vout_sz":3,"size":258,"weight"
    :1032,"fee":40000,"relayed_by":"0.0.0.0","lock_time":0,"tx_index":358445991,
    "double_spend":false,"result":-540000,"balance":16860000,"time":1530783162,"
    block_height":530552,"inputs":[{"prev_out":{"value":17400000,"tx_index":3356
    26123,"n":17,"spent":true,"script":"76a9143a48bfebcdc52c7b3831eab75a1955e587
    44c7e388ac","type":0,"addr":"16KBLs5NVpUcrhmcC7eifHuSJjKLufApak"},"sequence"
    :4294967295,"script":"4830450221008bdcab0f919efffe216597abcf14045a86cb406369
    79d280ddd1d67b5f5f7c72022008e757ffe2cf54e222ed817e622b3550d558740c616a00518a
    fb4e7e7948e2e00121028f883177988f212f2f1b89bc0aa1fb0683899c3665b62167b0daa998
    018f85d7","witness":""}],"out":[{"value":100000,"tx_index":358445991,"n":0,"
    spent":true,"script":"a9143827bdf9ff7e34a43f4f4fbe7b5ed5049bb9ce0187","type"
    :0,"addr":"36owNcemLHrqW6XXFWyXeedQoErSBWTQFE"},{"value":400000,"tx_index":3
    58445991,"n":1,"spent":false,"script":"76a914b705b67a8c0caeb68bbafe8377da8c1
    9aff1e2e788ac","type":0,"addr":"1HgjW3C7K6FzDrkTxjas6vAgNwDx37HTHT"},{"value
    ":16860000,"tx_index":358445991,"n":2,"spent":true,"script":"76a9143a48bfebc
    dc52c7b3831eab75a1955e58744c7e388ac","type":0,"addr":"16KBLs5NVpUcrhmcC7eifH
    uSJjKLufApak"}]},{"hash":"953d3961c873e57576f94fbd19f58228773ae0e296de5ec5de
    10fb3b2b76a4f6","ver":1,"vin_sz":1,"vout_sz":18,"size":761,"weight":3044,"fe
    e":31663,"relayed_by":"0.0.0.0","lock_time":512904,"tx_index":335626123,"dou
    ble_spend":false,"result":17400000,"balance":17400000,"time":1520702252,"blo
    ck_height":512905,"inputs":[{"prev_out":{"value":1185717261,"tx_index":33561
    7066,"n":1,"spent":true,"script":"76a914aab3770dcfcb25ae72bfa7d5f6618b732e3c
    bb5988ac","type":0,"addr":"1GZas4amXvEUTNamBZU5gnAZdaLQjC8Ndt"},"sequence":4
    294967294,"script":"47304402206cf76406e855e246c536e4aff8f43529825fda1038b2e7
    6902958e6c136849db02201656dd71f0ff4b034ceb9a2cf929cbfbcd34c6310fa0df2c8ceac8
    86eef58262012102a54900f37c53d312cceb93ae6aba57e55e9968760c55582cca4b8739cfae
    2110","witness":""}],"out":[{"value":17400000,"tx_index":335626123,"n":17,"s
    pent":true,"script":"76a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac","ty
    pe":0,"addr":"16KBLs5NVpUcrhmcC7eifHuSJjKLufApak"}]}]}
    HISTORY
    ).gsub(/\s+/, "")
    
    addresses = ["16KBLs5NVpUcrhmcC7eifHuSJjKLufApak"]
    
    json = JSON.parse(history_json)
    puts OnChain::History.from_blockinfo_json(json, addresses)
  end

  it "should get a history" do
  
    provider = OnChain::BlockchaininfoProvider.new(
      OnChain::CoinMarketCapRateProvider.new)
      
    #history = provider.address_history(OnChain::CoinType::Bitcoin,
    #  ["16KBLs5NVpUcrhmcC7eifHuSJjKLufApak"])
    #  
    #case history
    #when OnChain::History
    #  history.total_txs.should eq(2)
    #else
    #  puts history
    #  true.should eq(false)
    #end
  end
  
end
