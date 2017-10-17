/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var networkState;
var db;
var counter=0;
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady(), false);
        
        
    },
    
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');
        document.addEventListener("offline", function() {
        networkState = navigator.connection && navigator.connection.type;
            navigator.notification.alert(
                    'No internet connection state: ' + networkState,  // message
                    alertDismissed,         // callback
                    'the network is not avaliable', // title
                    'Done'                  // buttonName
                );
    }, false);
         
   /*      document.addEventListener("online", function() {
        networkState = navigator.connection && navigator.connection.type;
        navigator.notification.alert(
                    'Connection type : ' + networkState,  // message
                    alertDismissed,             // callback
                    'the network is connected', // title
                    'Done'                      // buttonName
                );
    }, false);*/
      //  document.addEventListener('backbutton', this.onBackButton(), false);
         
    },
    
    
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');
        
        console.log('Received Event: ' + id);
       
        db= window.openDatabase("localDB", "1.0", "CookSaveBD", 200000);
        db.transaction(setupDB, errorCB, successCB);
        checkConnection();
        localStorage.setItem('ProdRec',null);
        $(document).ajaxStart(function() {
                $('.loading').css('display', 'flex');
            });

            $(document).ajaxComplete(function() {
                $('.loading').css('display', 'none');
            });
        
    },
    
    onBackButton: function(){
        
        if($.mobile.activePage.is('index.html')){
                    navigator.app.exitApp();
            }
            else {
                    history.go(-1);
                    navigator.app.backHistory();
            }
    }

};

function checkConnection() {
    networkState = navigator.connection && navigator.connection.type;

    setTimeout(function(){
        networkState = navigator.connection && navigator.connection.type;

        var states = {};
        states[Connection.UNKNOWN]  = 'Unknown connection';
        states[Connection.ETHERNET] = 'Ethernet connection';
        states[Connection.WIFI]     = 'WiFi connection';
        states[Connection.CELL_2G]  = 'Cell 2G connection';
        states[Connection.CELL_3G]  = 'Cell 3G connection';
        states[Connection.CELL_4G]  = 'Cell 4G connection';
        states[Connection.NONE]     = 'No network connection';
   
        //alert('Connection type: ' + states[networkState] + ' idState: '+ networkState + ' idProd: ' + localStorage.getItem('ProdRec'));
        
        if(networkState!=Connection.NONE){
            cargaInicial();    
          }else{
              navigator.notification.alert(
                    'Connection unavailable , try again later',  // message
                    alertDismissed,             // callback
                    'the network is not avaliable', // title
                    'Done'                      // buttonName
                );   
          }
    }, 500);
}

// Populate the database 
    //
    function setupDB(tx) {
        //tx.executeSql('DROP TABLE IF EXISTS tblListaCompra');
        // SE INICIALIZA LA TABLA DE REGISTRO DE COMPRAS
        tx.executeSql('CREATE TABLE IF NOT EXISTS tblRegCompra (idRegCompra INTEGER PRIMARY KEY AUTOINCREMENT, idProducto INTEGER, Cantidad REAL, Peso REAL, Precio REAL, FechaCompra DATE, FechaExpira DATE, FotoProd TEXT, statusFinal INTEGER)');
        // SE INICIALIZA LA TABLA DE PRODUCTOS
        tx.executeSql('CREATE TABLE IF NOT EXISTS tblProductos (idProducto INTEGER PRIMARY KEY, nombreProducto TEXT, idGrupoProductos INTEGER, beneficiosProducto TEXT)');
        tx.executeSql('CREATE TABLE IF NOT EXISTS tblListaCompra (idListaCompra INTEGER PRIMARY KEY AUTOINCREMENT, descripcion_compra TEXT, fecha DATE)');

    }

    // Query the database
    //
    function cargaInicial() {
        
        $.getJSON("http://"+localStorage.getItem('IPSERVER')+"/Foodsave_php/listaProds.php", function(data) {
                $(data).each(function(index, data) {
                    db.transaction(function(tx){
                    tx.executeSql('INSERT OR REPLACE INTO tblProductos (idProducto, nombreProducto,idGrupoProductos, beneficiosProducto) VALUES (?,?,?,?)',[data.IDPRODUCTO,data.PRODUCTO, data.IDGRUPOPRODUCTOS, data.BENEFICIOSPRODUCTO],SuccessInsert,errorInsert);    
                    }, errorCB, successCB);
                });
            });
          
    }

function SuccessInsert(tx,result){
          console.log("Last inserted ID = " + result.insertId);
        counter++;
          
}
 
function errorInsert(error){
    console.log("Error processing SQL: "+error.code);
}

function errorCB(err) {
        console.log("Error processing SQL: "+err.code);
    }


    // Transaction success callback
    //
    function successCB() {
        console.log("CREACION DE TABLAS, OK counter: " +counter);
    localStorage.setItem('numProds',counter)
        //var db = window.openDatabase("Database", "1.0", "PhoneGap Demo", 200000);
    } 

function alertDismissed(){
    
}
