// ********************SET YOUR API KEY HERE****************************
// Insert your FoodEssentials API key here.
var apiKey = '6rktg3m7uv2hmfktn2ryhura';
// *********************************************************************

function checkKeyValidity () {

var url = 'http://api.foodessentials.com/createsession?uid=demoUID_01&devid=demoDev_01&appid=demoApp_01&f=json&api_key=' + apiKey + '&c=?';
invalidKey = false;
session_id = '';
console.log(url);
$.ajax({
url: url,
jsonp: 'c',
dataType: 'jsonp',
beforeSend: function(){
$('.loading').css('display', 'flex');  
},
success: function(data) {
session_id = data.session_id;
localStorage.setItem('SESSION_ID', session_id);
$('.loading').css('display', 'none');
},
timeout: 5000,
error: function(x,t,r) {
invalidKeyAlert();
invalidKey = true; 
}
});
}

function invalidKeyAlert() {
  alert('Invalid API key or connection not available. See README and edit js/foodessentials.js file.');
}



function search() {
  if (invalidKey) {
    invalidKeyAlert();
    return false;
  }
    
  var url = "http://api.foodessentials.com/searchprods?";

  url += "q=" + encodeURI($("#search_query").val());
  url += "&sid=" + localStorage.getItem('SESSION_ID');
  url += "&f=json";
  url += "&n=50";
  url += "&s=0";
  url += "&api_key="+ apiKey;
  url += "&c=searchCallback";

  $.ajax({
    url: url,
    jsonp: 'c',
    crossDomain: true,
    dataType: 'jsonp',
    beforeSend: function(){
        $('.loading').css('display', 'flex');  
    },
    success: searchCallback
  });
}

function searchCallback(data) {

    
  if (data.numFound == 0) {
    alert('No products found with that search query.');
    $('.loading').css('display', 'none'); 
    return;
  }
    
    
  productsArray = data.productsArray;
  var item = "";
  for (x = 0; x < productsArray.length; x++) {
      item += "<option value=" + productsArray[x].upc + " data-brand='"+productsArray[x].brand+"'>" + productsArray[x].product_name + "</option>";

    $('.loading').css('display', 'none');  
    $("#txtTextoProducto").html(item);
}
}

// Transaction error callback
        function errorCB(err) {
            console.log("Error processing SQL: " + err.code);
        }

        // Transaction success callback
        function successCB() {
            console.log("PRODUCTOS CARGADOS CORRECTAMENTE");
            //var db = window.openDatabase("Database", "1.0", "PhoneGap Demo", 200000);
        }
                                                                                                                                   
function getProduct(upc) {

  var url = "http://api.foodessentials.com/productscore?";
  url += "u=" + upc;
  url += "&sid=" + session_id;
  url += "&f=json";
  url += "&api_key="+ apiKey;
  console.log(url);
  $.ajax({
    url: url,
    jsonp: 'c',
    crossDomain: true,
    dataType: 'jsonp',
    beforeSend: function(){
        $('.loading').css('display', 'flex');  
    },
    success: getProductCallback
  });
}

function getProductCallback(data) {
  $("#txtTextoCodigo").html(data.product.product_name);
  $('.loading').css('display', 'none');  
}

function prueba(){
    alert('aqui estoy');
}

function leeCodigo(){
    cordova.plugins.barcodeScanner.scan(
                function(result) {
                    console.log(result);
                    navigator.notification.alert(
                        'The code is ' + result + '. This function is not available', // message
                        getProduct(result), // callback
                        'CODE FOUND!!', // title
                        'Done' // buttonName
                    );
                },

                function(error) {
                    alert("Scanning failed: " + error);
                }
            );
}


function cargaRecetas(){
    
    var url = 'http://' + localStorage.getItem('IPSERVER')+ '/Foodsave_php/listaRecetas.php';
  
  $.ajax({
    url: url,
    type: "POST",
    beforeSend: function(){
        $('.loading').css('display', 'flex');  
    },
    success: recetaCallback
  });
}

function recetaCallback(data) {

    
  if (data.numFound == 0) {
    alert('No recipes found with that search query.');
    $('.loading').css('display', 'none'); 
    return;
  }
  recipesArray = JSON.parse(data);
  var item = "";
  for (x = 0; x < recipesArray.length; x++) {
    item += "<div style='cursor: pointer;' class='widget widget-container content-area vertical-col uib-card uib_w_28 centerCard section-dimension-32 cpad-0 thumbReceta' data-uib='layout/card' data-ver='0' data-idrec='"+recipesArray[x].idReceta+"' data-contenido='"+recipesArray[x].contenidoHTML+"'><div id='tituloReceta"+recipesArray[x].idReceta+"' style='position:absolute; z-index:1; background-color:rgba(0,0,0,0.7); color:white; width:100%; height:50px; margin-top:100px;text-align:center;'>"+recipesArray[x].titulo+"</div><div class='widget uib_w_40 d-margins scale-image' style='z-index:0;' data-uib='media/img' data-ver='0'><figure class='figure-align'><img src='http://"+localStorage.getItem('IPSERVER')+"/wp-content/uploads/"+recipesArray[x].imagenPpal+"'><figcaption data-position='bottom'></figcaption></figure></div></div>";
  }
    $('.loading').css('display', 'none');  
    $('#listaRecetas').html(item);
    console.log(recipesArray);
}

function cargaTips(){
    
    var url = 'http://' + localStorage.getItem('IPSERVER')+ '/Foodsave_php/listaTips.php';
  
  $.ajax({
    url: url,
    type: "POST",
    beforeSend: function(){
        $('.loading').css('display', 'flex');  
    },
    success: tipCallback
  });
}

function tipCallback(data) {
    
  if (data.numFound == 0) {
    alert('No tips found with that search query.');
    $('.loading').css('display', 'none'); 
    return;
  }
  tipsArray = JSON.parse(data);
  var item = "";
  for (x = 0; x < tipsArray.length; x++) {
    item += "<div style='cursor: pointer;'  class='widget widget-container content-area vertical-col uib-card uib_w_28 centerCard section-dimension-32 cpad-0 thumbTip' data-uib='layout/card' data-ver='0' data-idtip='"+tipsArray[x].idTip+"' data-contenido='"+tipsArray[x].contenido+"'><div id='tituloTip"+tipsArray[x].idTip+"' style='position:absolute; z-index:1; background-color:rgba(0,0,0,0.7); color:white; width:100%; height:50px; margin-top:100px;text-align:center;'>"+tipsArray[x].titulo+"</div><div class='widget uib_w_40 d-margins scale-image' style='z-index:0;' data-uib='media/img' data-ver='0'><figure class='figure-align'><img src='http://"+localStorage.getItem('IPSERVER')+"/wp-content/uploads/"+tipsArray[x].imagenPpal+"'><figcaption data-position='bottom'></figcaption></figure></div></div>";
  }
    $('.loading').css('display', 'none');  
    $('#listaTips').html(item);
    console.log(tipsArray);
}
