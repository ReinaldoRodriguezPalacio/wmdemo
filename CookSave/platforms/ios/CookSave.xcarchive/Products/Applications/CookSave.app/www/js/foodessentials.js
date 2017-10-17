// ********************SET YOUR API KEY HERE****************************
// Insert your FoodEssentials API key here.
var apiKey = '6rktg3m7uv2hmfktn2ryhura';
// *********************************************************************
invalidKey = true;

 
 
function checkKeyValidity () {

var url = 'http://api.foodessentials.com/createsession?uid=demoUID_01&devid=demoDev_01&appid=demoApp_01&f=json&api_key=' + apiKey + '';
console.log(url);

session_id = '';
console.log(url);
$.ajax({
url: url,
jsonp: 'c',
dataType: 'jsonp',

success: function(data) {
session_id = data.session_id;
localStorage.setItem('SESSION_ID', session_id);
alert('Registro correcto');
invalidKey = false;
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

function registerPermission() {
                cordova.plugins.notification.local.registerPermission(function (granted) {
                    showToast(granted ? 'Yes' : 'No');
                });
 }
 
function cargaRecetas(){
    
    var url = 'http://' + localStorage.getItem('IPSERVER')+ '/Foodsave_php/listaRecetas.php';
  $.ajax({
    url: url,
    type: "POST",
    success: recetaCallback
    });            
}

function recetaCallback(data) {

  if (data.numFound == 0) {
    alert('No recipes found with that search query.');
    return;
  }
  recipesArray= JSON.parse(data);
 
  var item = "";
  for (x = 0; x < recipesArray.length; x++) {
    item += "<li class='collection-item'><div class='card small'><div class='card-image waves-effect waves-block waves-light'><img class='activator' height='200px' src='http://"+localStorage.getItem('IPSERVER')+"/wp-content/uploads/"+recipesArray[x].imagenPpal+"'>";
    item += "</div><div class='card-content'><span class='card-title activator grey-text text-darken-4'>"+recipesArray[x].titulo+"<i class='material-icons right'>more_vert</i></span></div><div class='card-reveal'>";
    item += "<span class='card-title grey-text text-darken-4'>"+recipesArray[x].titulo+"<i class='material-icons right'>close</i></span><p>"+recipesArray[x].contenidoHTML+"</p></div></div></li>";
                            
  } 
    $('#listaRecetas').html(item);
    console.log(recipesArray);
}

function cargaTips(){
    
    var url = 'http://' + localStorage.getItem('IPSERVER')+ '/Foodsave_php/listaTips.php';
  
  $.ajax({
    url: url,
    type: "POST",
    success: tipCallback
  });
}

function tipCallback(data) {
    
  if (data.numFound == 0) {
    alert('No tips found with that search query.');
    return;
  }
  tipsArray = JSON.parse(data);
  var item = "";
  for (x = 0; x < tipsArray.length; x++) {
    //item += "<div style='cursor: pointer;'  class='widget widget-container content-area vertical-col uib-card uib_w_28 centerCard section-dimension-32 cpad-0 thumbTip' data-uib='layout/card' data-ver='0' data-idtip='"+tipsArray[x].idTip+"' data-contenido='"+tipsArray[x].contenido+"'><div id='tituloTip"+tipsArray[x].idTip+"' style='position:absolute; z-index:1; background-color:rgba(0,0,0,0.7); color:white; width:100%; height:50px; margin-top:100px;text-align:center;'>"+tipsArray[x].titulo+"</div><div class='widget uib_w_40 d-margins scale-image' style='z-index:0;' data-uib='media/img' data-ver='0'><figure class='figure-align'><img src='http://"+localStorage.getItem('IPSERVER')+"/wp-content/uploads/"+tipsArray[x].imagenPpal+"'><figcaption data-position='bottom'></figcaption></figure></div></div>";
    item += "<li class='collection-item'><div class='card small'><div class='card-image waves-effect waves-block waves-light'><img class='activator'  height='200px' src='http://"+localStorage.getItem('IPSERVER')+"/wp-content/uploads/"+tipsArray[x].imagenPpal+"'>";
    item += "</div><div class='card-content'><span class='card-title activator grey-text text-darken-4'>"+tipsArray[x].titulo+"<i class='material-icons right'>more_vert</i></span></div><div class='card-reveal'>";
    item += "<span class='card-title grey-text text-darken-4'>"+tipsArray[x].titulo+"<i class='material-icons right'>close</i></span><p>"+tipsArray[x].contenido+"</p></div></div></li>";
      
  }
    $('#listaTips').html(item);
    console.log(tipsArray);
}

function search() {

  
    
  var url = "http://api.foodessentials.com/searchprods?";

  url += "q=" + encodeURI($("#search_query").val());
  url += "&sid=" + localStorage.getItem('SESSION_ID');
  url += "&f=json";
  url += "&n=50";
  url += "&s=0";
  url += "&api_key="+ apiKey;
  url += "&c=searchCallback";
alert(url);

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
      item += "<option value=" + productsArray[x].upc + " data-size='"+productsArray[x].product_size+"' data-description='"+productsArray[x].product_description+"' data-manufacturer='"+productsArray[x].manufacturer+"' data-brand='"+productsArray[x].brand+"'>" + productsArray[x].product_name + "</option>";

    $("#txtTextoProducto").html(item);
}

    $('.loading').css('display', 'none');  
}

function okRegCompra() {
            //alert($('#txtFechaExpira').val().toString());
            schedule('00001', 'pan de pruebas', $('#txtFechaExpira').val().toString());
            navigator.notification.alert(
                'Data saved', // message
                okCompra, // callback
                'Register Ok', // title
                'Done' // buttonName
            );
        }
        
function okCompra() {
            window.location = 'index.html';
        }
        