
import consumer from "./consumer"


consumer.subscriptions.create({ channel: "CryptoValueChannel" })


const sleep = (milliseconds) => {
  return new Promise(resolve => setTimeout(resolve, milliseconds))
}


const getPricesFromAPI = async () => {
  const bitcoinPrice = document.getElementById("bitcoin-price");
  const ethereumPrice = document.getElementById("ethereum-price");
  const cardanoPrice = document.getElementById("cardano-price");
  await fetch("https://data.messari.io/api/v1/assets?fields=id,slug,symbol,metrics/market_data/price_usd")
    .then(response => response.json())
    .catch(error => console.error("Error: Data was not Found", error))
    .then(data => {
        const btcPrice = data['data'][0]['metrics']['market_data']['price_usd'].toFixed(2);
        const ethPrice = data['data'][1]['metrics']['market_data']['price_usd'].toFixed(2);
        const adaPrice = data['data'][4]['metrics']['market_data']['price_usd'].toFixed(2)

        bitcoinPrice.innerText = btcPrice;
        ethereumPrice.innerText = ethPrice;
        cardanoPrice.innerText = adaPrice;

        document.getElementById("btc_price_export").value = btcPrice;
        document.getElementById("eth_price_export").value = ethPrice;
        document.getElementById("ada_price_export").value = adaPrice;;
    });
}



const printJSON = async (estado) => {
  while(estado){
    getPricesFromAPI();
    await sleep(120000);
  }
}

let conexion = 0;

consumer.subscriptions.create("CryptoValueChannel", {
  connected() {
    
    conexion += 1;
    if (conexion == 1) {
      printJSON(true);
    }
  },

  disconnected() {
   
    conexion -= 1;
    if (conexion == 0){
      printJSON(false);
    }
  },

  received(data) {
    
  }
});
