require 'time'

class HomeController < ApplicationController


  def index
    @crypto_prices = read_data_from_api
  end


  def export
    puts "PARAMS: #{params}"


    return unless params[:commit].include? 'Exportar'

    btc_price = params['btc_price_export']
    eth_price = params['eth_price_export']
    ada_price = params['ada_price_export']
    crypto_prices = { btc_price: btc_price, eth_price: eth_price, ada_price: ada_price }


    case params[:commit]
    when 'Exportar EXCEL'
      csv_file = make_content("\t", crypto_prices)
      export_file(csv_file, 'xls')
    when 'Exportar CSV'
      csv_file = make_content(',', crypto_prices)
      export_file(csv_file, 'csv')
    when 'Exportar JSON'
      csv_file = make_content_json(crypto_prices)
      export_file(csv_file, 'json')
    end
  end


  private
  def read_data_from_api
    url_crypto_values = 'https://data.messari.io/api/v1/assets?fields=id,slug,symbol,metrics/market_data/price_usd'



    response = RestClient.get url_crypto_values


    result = JSON.parse response.to_s

    bitcoin_price = result['data'][0]['metrics']['market_data']['price_usd'].round(2)
    ethereum_price = result['data'][1]['metrics']['market_data']['price_usd'].round(2)
    cardano_price = result['data'][4]['metrics']['market_data']['price_usd'].round(2)

    { bitcoin_price: bitcoin_price, ethereum_price: ethereum_price, cardano_price: cardano_price }
  end


  def export_file(file, formato)
    time_now = Time.now
    segundos = time_now.strftime('%s')[0..1]

    time_now_formated = time_now.strftime("%H_%M_#{segundos}_%d-%h-%Y_UTC-0")


    send_data(file,
              type: "text/#{formato}", disposition: 'attachment',
              filename: "crypto_prices_#{time_now_formated}.#{formato}")
  end



  def make_content(symbol, crypto_prices)
    "##{symbol}ASSET#{symbol}PRICE(USD)
    1#{symbol}Bitcoin - BTC#{symbol}#{crypto_prices[:btc_price]}
    2#{symbol}Ethereum - ETH#{symbol}#{crypto_prices[:eth_price]}
    3#{symbol}Cardano - ADA#{symbol}#{crypto_prices[:ada_price]}"
  end

  
  def make_content_json(crypto_prices)
    '{"data":
    [
      {
        "#":1,
        "ASSET":"Bitcoin - BTC",
        "PRICE(USD)":' + (crypto_prices[:btc_price]).to_s + '
      },
      {
        "#":2,
        "ASSET":"Ethereum - ETH",
        "RICE(USD)":' + (crypto_prices[:eth_price]).to_s + '
      },
      {
        "#":3,
        "ASSET":"Cardano - ADA",
        "PRICE(USD)":' + (crypto_prices[:ada_price]).to_s + '
      }
    ]
  }'
  end
end
