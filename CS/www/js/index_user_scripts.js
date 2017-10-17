/*jshint browser:true */
/*global $ */(function()
{
 "use strict";
 /*
   hook up event handlers 
 */
 function register_event_handlers()
 {
     
     /* graphic button  .uib_w_13 */
    $(document).on("click", ".uib_w_13", function(evt)
    {
         /*global uib_sb */
         /* Other possible functions are: 
           uib_sb.open_sidebar($sb)
           uib_sb.close_sidebar($sb)
           uib_sb.toggle_sidebar($sb)
            uib_sb.close_all_sidebars()
          See js/sidebar.js for the full sidebar API */
        
         uib_sb.toggle_sidebar($("#menuLat"));  
    });
     
    
    $(document).on("click", "#btnBusca", function(evt)
    {
         /*global uib_sb */
         /* Other possible functions are: 
           uib_sb.open_sidebar($sb)
           uib_sb.close_sidebar($sb)
           uib_sb.toggle_sidebar($sb)
            uib_sb.close_all_sidebars()
          See js/sidebar.js for the full sidebar API */
        
         search();
         $("#modalSearch").modal('hide');
    });
     
     $(document).on("click", "#btnAddProd", function(evt)
    {
         /*global uib_sb */
         /* Other possible functions are: 
           uib_sb.open_sidebar($sb)
           uib_sb.close_sidebar($sb)
           uib_sb.toggle_sidebar($sb)
            uib_sb.close_all_sidebars()
          See js/sidebar.js for the full sidebar API */
        
         $("#modalSearch").modal('show');
    });
    
        /* button  .uib_w_4 */
    $(document).on("click", ".uib_w_4", function(evt)
    {
         /*global activate_page */
         activate_page("#addProduct"); 
    });
    
        /* graphic button  Button */
    $(document).on("click", ".uib_w_12", function(evt)
    {
         /*global uib_sb */
         /* Other possible functions are: 
           uib_sb.open_sidebar($sb)
           uib_sb.close_sidebar($sb)
           uib_sb.toggle_sidebar($sb)
            uib_sb.close_all_sidebars()
          See js/sidebar.js for the full sidebar API */
        
         uib_sb.toggle_sidebar($(".uib_w_11"));  
         return false;
    });
     
     $(document).on("click","#tabBarcode", function(evt){
         $('#selectProdCode').css('display','block');
         $('#selectProdMan').css('display','none');
     });
     
     $(document).on("click","#tabManual", function(evt){
         $('#selectProdCode').css('display','none');
         $('#selectProdMan').css('display','block');
     });
    
        /* button  .uib_w_6 */
    $(document).on("click", ".uib_w_6", function(evt)
    {
         /*global activate_page */
         activate_page("#cook"); 
        cargaRecetas();
         return false;
    });
     
    $("#txtTextoProducto").on("select2:selecting",function(evt){
        $("#txtDetalles").text('');
        var selected = $(this).find('option:selected');
        var marca = selected.data('brand'); 
        $("#txtDetalles").html(marca);
    });
     
        /* button  .uib_w_9 */
    $(document).on("click", ".uib_w_9", function(evt)
    {
         /*global activate_page */
         activate_page("#tips"); 
        cargaTips();
         return false;
    });
    
        /* button  .uib_w_30 */
    
    
        /* button  .uib_w_31 */
    $(document).on("click", ".uib_w_31", function(evt)
    {
         /*global activate_page */
         activate_page("#mainpage"); 
         return false;
    });
    
        /* button  .uib_w_32 */
    $(document).on("click", ".uib_w_32", function(evt)
    {
         /*global uib_sb */
         /* Other possible functions are: 
           uib_sb.open_sidebar($sb)
           uib_sb.close_sidebar($sb)
           uib_sb.toggle_sidebar($sb)
            uib_sb.close_all_sidebars()
          See js/sidebar.js for the full sidebar API */
        
         uib_sb.toggle_sidebar($(".uib_w_11"));  
         return false;
    });
    
        /* listitem  Inventory Status */
    $(document).on("click", ".uib_w_47", function(evt)
    {
        /* your code goes here */ 
         return false;
    });
    
        /* listitem  Inventory Status */
    $(document).on("click", ".uib_w_47", function(evt)
    {
         /*global uib_sb */
         /* Other possible functions are: 
           uib_sb.open_sidebar($sb)
           uib_sb.close_sidebar($sb)
           uib_sb.toggle_sidebar($sb)
            uib_sb.close_all_sidebars()
          See js/sidebar.js for the full sidebar API */
        
         uib_sb.toggle_sidebar($(".uib_w_11"));  
         return false;
    });
    
        /* listitem  Cook */
    $(document).on("click", ".uib_w_43", function(evt)
    {
         /*global uib_sb */
         /* Other possible functions are: 
           uib_sb.open_sidebar($sb)
           uib_sb.close_sidebar($sb)
           uib_sb.toggle_sidebar($sb)
            uib_sb.close_all_sidebars()
          See js/sidebar.js for the full sidebar API */
        
         uib_sb.toggle_sidebar($(".uib_w_11"));  
         return false;
    });
    
        /* listitem  Save */
    $(document).on("click", ".uib_w_44", function(evt)
    {
         /*global uib_sb */
         /* Other possible functions are: 
           uib_sb.open_sidebar($sb)
           uib_sb.close_sidebar($sb)
           uib_sb.toggle_sidebar($sb)
            uib_sb.close_all_sidebars()
          See js/sidebar.js for the full sidebar API */
        
         uib_sb.toggle_sidebar($(".uib_w_11"));  
         return false;
    });
    
        /* listitem  Information */
    $(document).on("click", ".uib_w_45", function(evt)
    {
         /*global uib_sb */
         /* Other possible functions are: 
           uib_sb.open_sidebar($sb)
           uib_sb.close_sidebar($sb)
           uib_sb.toggle_sidebar($sb)
            uib_sb.close_all_sidebars()
          See js/sidebar.js for the full sidebar API */
        
         uib_sb.toggle_sidebar($(".uib_w_11"));  
         return false;
    });
    
        /* listitem  Shopping List */
    $(document).on("click", ".uib_w_46", function(evt)
    {
         /*global uib_sb */
         /* Other possible functions are: 
           uib_sb.open_sidebar($sb)
           uib_sb.close_sidebar($sb)
           uib_sb.toggle_sidebar($sb)
            uib_sb.close_all_sidebars()
          See js/sidebar.js for the full sidebar API */
        
         uib_sb.toggle_sidebar($(".uib_w_11"));  
         return false;
    });
    
        /* button  .uib_w_30 */

    
        /* button  .uib_w_30 */
/************+ ACA VOY *********************/
   /*  $("#frmCompra").submit(function(e) {
        e.preventDefault();
        $('#loading').css('display', 'flex');
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO tblRegCompra (idProducto, Cantidad, Peso, Precio, FechaCompra, FechaExpira, FotoProd, statusFinal) VALUES (?,?,?,?,?,?,?,?)', [$('#txtTextoProducto').val(), $('#txtCantidad').val(), $('#txtPeso').val(), $('#txtPrecio').val(), $('#txtFechaCompra').val(), $('#txtFechaExpira').val(), null, 0], SuccessInsert, errorInsert);
        }, errorCB, okRegCompra);

    });*/
     
     
    $(document).on("click",".thumbReceta",function(evt){
        var idrec=$(this).data('idrec');
        $('#recTitle').html("<h3><strong>"+$("#tituloReceta"+idrec).html()+"</strong></h3>");
        $('#recContent').html($(this).data('contenido'));
        $("#modalReceta").modal('show');
        return false;
    });
     
    $(document).on("click",".thumbTip",function(evt){
        var idtip=$(this).data('idtip');
        $('#tipTitle').html("<h3><strong>"+$("#tituloTip"+idtip).html()+"</strong></h3>");
        $('#tipContent').html($(this).data('contenido'));
        $("#modalTip").modal('show');
        return false;
    });
     
        /* button  .uib_w_48 */
    
    
        /* button  .uib_w_48 */
    $(document).on("click", ".uib_w_48", function(evt)
    {
        /* your code goes here */ 
         return false;
    });
    
        /* button  .uib_w_48 */
    $(document).on("click", ".uib_w_48", function(evt)
    {
         /*global activate_page */
         activate_page("#mainpage"); 
         return false;
    });
    
        /* button  .uib_w_30 */
    $(document).on("click", ".uib_w_30", function(evt)
    {
         /*global activate_page */
         activate_page("#mainpage"); 
         return false;
    });
    
    }
 document.addEventListener("app.Ready", register_event_handlers, false);
    
})();
