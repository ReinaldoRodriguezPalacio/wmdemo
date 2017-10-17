// ********************SET YOUR API KEY HERE****************************
// Insert your FoodEssentials API key here.
var apiKey = '6rktg3m7uv2hmfktn2ryhura';
// *********************************************************************

// Check if valid API Key
function checkKeyValidity() {
  var url = 'http://api.foodessentials.com/createsession?uid=demoUID_01&devid=demoDev_01&appid=demoApp_01&f=json&api_key=' + apiKey + '&c=?';
  invalidKey = false;
  session_id = '';
  
  $.ajax({
    url: url,
    jsonp: 'c',
    dataType: 'jsonp',
    success: function(data) {
      session_id = data.session_id;
      console.log(session_id);
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
    alert('aca');
  $.mobile.loading( 'show', {
    text: 'Searching...',
    textVisible: true,
    theme: 'b',
    html: ""
  });
    
  var url = "http://api.foodessentials.com/searchprods?";

  url += "q=" + encodeURI($("#search_query").val());
  url += "&sid=" + session_id;
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
    success: searchCallback
  });
}

function searchCallback(data) {
  $.mobile.loading('hide');
    
  if (data.numFound == 0) {
    alert('No products found with that search query.');
    return;
  }
  productsArray = data.productsArray;
  var item = "";
  for (x = 0; x < productsArray.length; x++) {
    item += "<option value=" + productsArray[x].upc + ">" + productsArray[x].product_name + "</option>";
  }
    $("#txtTextoProducto").append(item);
    $.mobile.navigate('#search_results', { transition: "slide" });
}

function getIngredients(upc) {
  $.mobile.loading( 'show', {
    text: 'Fetching ingredients...',
    textVisible: true,
    theme: 'b',
    html: ""
  });
    
  var url = "http://api.foodessentials.com/label?";
  url += "u=" + upc;
  url += "&sid=" + session_id;
  url += "&appid=demoApp_01";
  url += "&f=json";
  url += "&api_key="+ apiKey;
  url += "&c=getIngredientsCallback";
  
  $.ajax({
    url: url,
    jsonp: 'c',
    crossDomain: true,
    dataType: 'jsonp',
    success: getIngredientsCallback
  });
}

function getIngredientsCallback(data) {
  $.mobile.loading('hide');
    
  $("#product_name").html(data.product_name);
  $("#ingredients_list").html(data.ingredients);
  $.mobile.navigate('#ingredients', { transition: "slide" });
}

function prueba(){
    alert('aqui estoy');
}

