//
//  SESugestedCar.swift
//  WalMart
//
//  Created by Vantis on 17/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation



class SESugestedCar: NavigationViewController, UITableViewDataSource, UITableViewDelegate, SESugestedRowDelegate, SESugestedRowTitleViewCellDelegate{

    var alertView : IPOWMAlertViewController? = nil
    var viewLoad : WMLoadingView!
    var collection: UICollectionView?
    var sugestedCarTableView: UITableView!
    
    var allProducts: [[String:Any]]? = []
    var productsBySection : [String:Any]? = [:]
    var searchWordBySection : [String]! = []
    var params: [String:Any] = [:]
    var itemsSelected: [[String:Any]]! = []
    var searchWords: [String]! = []
    var titleHeader: String?
    
    var firstOpen  = true
    var isLoading  = false
    var hasEmptyView = false
    
    var viewFooter: UIView!
    var lblItemsCount: UILabel!
    var btnAddToCart: UIButton?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SESEARCHRESULT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = WMColor.light_light_gray
        
        self.titleLabel?.text = titleHeader
        
        
        
        self.sugestedCarTableView = UITableView(frame:.zero)
        self.sugestedCarTableView.register(SESugestedRow.self, forCellReuseIdentifier: "cell")
        self.sugestedCarTableView.register(SESugestedRowTitleViewCell.self, forCellReuseIdentifier: "header")
        self.sugestedCarTableView.backgroundColor = WMColor.light_light_gray
        self.sugestedCarTableView.separatorStyle = .none
        self.sugestedCarTableView.allowsSelection = false

        self.sugestedCarTableView.delegate = self
        self.sugestedCarTableView.dataSource = self
        
        
        self.view.addSubview(sugestedCarTableView!)
        
        BaseController.setOpenScreenTagManager(titleScreen: self.titleHeader!, screenName: self.getScreenGAIName())
        
        self.viewFooter = UIView(frame:.zero)
        self.viewFooter.backgroundColor = UIColor.white
        
        
        self.btnAddToCart = UIButton(frame:.zero)
        btnAddToCart!.addTarget(self, action: #selector(self.addListToCart(_:)), for: .touchUpInside)
        self.btnAddToCart?.tintColor = UIColor.white
        self.btnAddToCart?.setTitle("Agregar a Carrito" , for: UIControlState.normal)
        self.btnAddToCart?.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.btnAddToCart?.backgroundColor = WMColor.green
        self.btnAddToCart?.layer.cornerRadius = 15
        
        self.viewFooter.addSubview(btnAddToCart!)
        self.view.addSubview(viewFooter)
        
        lblItemsCount = UILabel()
        lblItemsCount.font = WMFont.fontMyriadProRegularOfSize(12)
        lblItemsCount.textColor = WMColor.dark_gray
        lblItemsCount.text = "0 artículos"
        
        self.view.addSubview(lblItemsCount)
        cargaProductos()
        //self.invokeMultisearchService()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let startPoint = self.header!.frame.maxY
        
        var heightScreen = self.view.bounds.height - startPoint
        if !IS_IPAD {
            heightScreen -= 44
        }
        self.sugestedCarTableView!.frame = CGRect(x: 0, y:startPoint, width:self.view.bounds.width, height: heightScreen - 60)
        self.lblItemsCount.frame = CGRect(x: 15, y: sugestedCarTableView.frame.maxY, width: self.view.frame.size.width, height: 20)

        self.viewFooter.frame = CGRect(x: 0, y: sugestedCarTableView.frame.maxY + 20, width: self.view.frame.size.width, height: 40)
        self.btnAddToCart?.frame = CGRect(x: self.viewFooter.frame.size.width / 2 - self.viewFooter.frame.size.width / 4, y: 5, width: self.viewFooter.frame.size.width / 2, height: 30)
    }
    
    override func back(){
        if self.navigationController != nil {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! SESugestedRowTitleViewCell
        cell.setValues(searchWordBySection[section], section: section)
        cell.deleteItem.tag = section
        cell.delegate = self
        cell.deleteItem.addTarget(self, action: #selector(self.delSection(_:)), for: UIControlEvents.touchUpInside)
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchWordBySection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SESugestedRow
        cell.delegate = self
        cell.setValues((allProducts![indexPath.section]["products"] as? [[String:Any]])!, section: indexPath.section)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func cargaProductos(){
        
        let respuestaSESEarch = "{\"responseArray\":[{\"term\":\"agua\",\"products\":[{\"field\":\"19.0\",\"displayName\":\"Agua Gerber  4 l\",\"upc\":\"00750100098477\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100098477s.jpg\"},{\"field\":\"17.3\",\"displayName\":\"Agua Bonafont  6 l\",\"upc\":\"00075810400317\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00075810400317s.jpg\"},{\"field\":\"8.0\",\"displayName\":\"Agua Bonafont  1.5 l\",\"upc\":\"00075810400015\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00075810400015s.jpg\"},{\"field\":\"10.0\",\"displayName\":\"Agua Bonafont  2 l\",\"upc\":\"00075810400197\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00075810400197s.jpg\"},{\"field\":\"6.8\",\"displayName\":\"Agua Bonafont  1 l\",\"upc\":\"00075810410042\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00075810410042s.jpg\"},{\"field\":\"23.0\",\"displayName\":\"Agua Evian  1.5 l\",\"upc\":\"00006131400001\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00006131400001s.jpg\"},{\"field\":\"13.0\",\"displayName\":\"Agua Evian  500 ml\",\"upc\":\"00006131400003\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00006131400003s.jpg\"},{\"field\":\"18.0\",\"displayName\":\"Agua Evian  1 l\",\"upc\":\"00006131400007\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00006131400007s.jpg\"},{\"field\":\"53.0\",\"displayName\":\"TermÃ³metro Digital Omron  Contra Agua\",\"upc\":\"00007379624594\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00007379624594s.jpg\"},{\"field\":\"38.0\",\"displayName\":\"Agua Fiji  1 l\",\"upc\":\"00063256500002\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00063256500002s.jpg\"}]},{\"term\":\"pollo\",\"products\":[{\"field\":\"134.0\",\"displayName\":\"Alitas de pollo Tyson  sabor BBQ 700 g\",\"upc\":\"00750110069682\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750110069682s.jpg\"},{\"field\":\"92.0\",\"displayName\":\"Pechuga de pollo Tyson  sin hueso y sin piel 700 g\",\"upc\":\"00750110060603\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750110060603s.jpg\"},{\"field\":\"13.0\",\"displayName\":\"Caldo de pollo Knorr Suiza con cilantro 8 cubos\",\"upc\":\"00750100511987\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100511987s.jpg\"},{\"field\":\"17.9\",\"displayName\":\"Caldo de pollo Knorr Suiza 12 cubos\",\"upc\":\"00750100519649\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100519649s.jpg\"},{\"field\":\"17.0\",\"displayName\":\"Caldo de pollo Iberia  450 g\",\"upc\":\"00750100511234\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100511234s.jpg\"},{\"field\":\"14.0\",\"displayName\":\"Consomate  con pollo sabor original 12 cubos\",\"upc\":\"00750105921671\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750105921671s.jpg\"},{\"field\":\"29.0\",\"displayName\":\"Caldo de pollo Knorr Suiza 24 cubos\",\"upc\":\"00750100519929\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100519929s.jpg\"},{\"field\":\"72.0\",\"displayName\":\"Flautas de pollo El Cazo  24 pzas\",\"upc\":\"00750104001741\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750104001741s.jpg\"},{\"field\":\"89.5\",\"displayName\":\"Tenders de pollo Tyson  empanizados 700 g\",\"upc\":\"00750110064796\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750110064796s.jpg\"},{\"field\":\"62.0\",\"displayName\":\"Taquitos de pollo Alamesa  congelados 24 pzas\",\"upc\":\"00750300491139\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750300491139s.jpg\"}]},{\"term\":\"leche\",\"products\":[{\"field\":\"15.2\",\"displayName\":\"Leche Lala Light 1 l\",\"upc\":\"00750102051535\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750102051535s.jpg\"},{\"field\":\"7.2\",\"displayName\":\"Leche Alpura  sabor fresa 250 ml\",\"upc\":\"00000007500208\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007500208s.jpg\"},{\"field\":\"7.2\",\"displayName\":\"Leche Alpura  sabor vainilla 250 ml\",\"upc\":\"00000007500209\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007500209s.jpg\"},{\"field\":\"7.2\",\"displayName\":\"Leche Alpura  sabor chocolate 250 ml\",\"upc\":\"00000007500210\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007500210s.jpg\"},{\"field\":\"5.0\",\"displayName\":\"Gelatina de leche Danette  sabor fresa 100 g\",\"upc\":\"00000007503639\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007503639s.jpg\"},{\"field\":\"5.0\",\"displayName\":\"Gelatina de leche Danette  sabor vainilla 100 g\",\"upc\":\"00000007503640\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007503640s.jpg\"},{\"field\":\"6.0\",\"displayName\":\"Leche Lala entera 250 ml\",\"upc\":\"00000007504266\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007504266s.jpg\"},{\"field\":\"6.5\",\"displayName\":\"Leche Lala Yomi sabor chocolate 250 ml\",\"upc\":\"00000007504267\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007504267s.jpg\"},{\"field\":\"6.5\",\"displayName\":\"Leche Lala Yomi sabor fresa 250 ml\",\"upc\":\"00000007504268\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007504268s.jpg\"},{\"field\":\"6.5\",\"displayName\":\"Leche Lala Yomi sabor vainilla 250 ml\",\"upc\":\"00000007504269\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007504269s.jpg\"}]}]}"
        
        do{
        let jsonString = try JSONSerialization.jsonObject(with: respuestaSESEarch.data(using: .utf8)!, options: .allowFragments) as! [String:Any]
        
            allProducts = jsonString["responseArray"] as? [[String : Any]]
        
            searchWordBySection = []
            
            for i in 0..<allProducts!.count{
                for (key, value) in allProducts![i] {
                    // access all key / value pairs in dictionary
                    if key == "term"{
                        self.searchWordBySection.append(String(describing: value))
                    }
                    if key == "products"{
                        let productos = allProducts![i]["products"] as! [[String:Any]]
                        for a in 0..<productos.count{
                            for (key,value) in productos[a]{
                                print(key)
                                print(value)
                            }
                        }
                    }
                }
            }
        }catch{
        print("Error en el Json")
        }
    }
    
    //SESugestedRowDelegate
    func itemSelected(seccion:Int, itemSelected: Int){
        let productos = allProducts![seccion]["products"] as! [[String:Any]]
        let producto = productos[itemSelected] 
        //itemsSelected.append(productos[itemSelected]["upc"] as! String)
        
        var params: [String:Any] = [:]
        
        params["upc"] = producto["upc"] as! String
        params["desc"] = producto["displayName"] as! String
        params["imgUrl"] = producto["url"] as! String
        params["price"] = producto["field"] as! String
        params["quantity"] = "1"
        params["pesable"] = "0"
        params["wishlist"] = false
        params["type"] = ResultObjectType.Groceries.rawValue
        params["comments"] = ""
        if let type = producto["type"] as? String {
            if Int(type)! == 0 { //Piezas
                params["onHandInventory"] = "99"
            }
            else { //Gramos
                params["onHandInventory"] = "20000"
            }
        }
        params["orderByPiece"] = "EA"
        
        itemsSelected.append(params)
      /*  if upcs.count > 0 {
            NotificationCenter.default.post(name: .addItemsToShopingCart, object: self, userInfo: ["allitems":upcs, "image":"list_alert_addToCart"])
            BaseController.sendAnalyticsProductsToCart(totalPrice)
        }
        else{
            self.noProductsAvailableAlert()
            return
        }*/
        actualizaNumItems()
    }
    
    func itemDeSelected(seccion:Int, itemSelected: Int){
        let productos = allProducts![seccion]["products"] as! [[String:Any]]
        
        for idxVal in 0..<itemsSelected.count {
            let item = self.itemsSelected![idxVal]
            let buscado = productos[itemSelected]["upc"] as! String
            if item["upc"] as! String == buscado {
                itemsSelected.remove(at: idxVal)
                break
            }
        }
        actualizaNumItems()
    }
    
    func actualizaNumItems(){
    lblItemsCount.text = "\(itemsSelected.count) artículos"
    }
    
    func invokeMultisearchService() {
        
        self.showLoadingView()
        
        if UserCurrentSession.hasLoggedUser(){
            
            let multipleSearchService = SEmultipleSearchListService()
            multipleSearchService.callService(params: searchWords,
                                         successBlock: { (response:[String:Any]) -> Void in
                                            print("Call multiSearchService success")
                                            self.removeLoadingView()
                                            self.getProductosBySearch(arrayProductos: response["responseArray"] as! [[String : Any]])
            },
                                         errorBlock: { (error:NSError) -> Void in
                                            print("Call multiSearchService error \(error)")
                                            self.removeLoadingView()
            }
            )
            
        }else{
            
            let multipleSearchService = SEmultipleSearchService()
            multipleSearchService.callService(params: searchWords,
                                         successBlock: { (response:[String:Any]) -> Void in
                                            print("Call multiSearchService success")
                                            self.removeLoadingView()
                                            self.getProductosBySearch(arrayProductos: response["responseArray"] as! [[String : Any]])
            },
                                         errorBlock: { (error:NSError) -> Void in
                                            print("Call multiSearchService error \(error)")
                                            self.removeLoadingView()
            }
            )
        }
        
    }
    
    func showLoadingView() {
        
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(true)
    }
    
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    func getProductosBySearch(arrayProductos:[[String:Any]]){
        allProducts = arrayProductos
        
        searchWordBySection = []
        
        for i in 0..<allProducts!.count{
            for (key, value) in allProducts![i] {
                // access all key / value pairs in dictionary
                if key == "term"{
                    self.searchWordBySection.append(String(describing: value))
                }
                if key == "products"{
                    let productos = allProducts![i]["products"] as! [[String:Any]]
                    for a in 0..<productos.count{
                        for (key,value) in productos[a]{
                            print(key)
                            print(value)
                        }
                    }
                }
            }
        }
        sugestedCarTableView.reloadData()
    }
    
    func addListToCart(_ sender:UIButton) {
        
        if itemsSelected.count > 0 {
                NotificationCenter.default.post(name: .addItemsToShopingCart, object: self, userInfo: ["allitems":itemsSelected, "image":"list_alert_addToCart"])
                //BaseController.sendAnalyticsProductsToCart(totalPrice)
            }else{
                self.noProductsAvailableAlert()
                return
            }
    }
    
    func noProductsAvailableAlert(){
        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
        let msgInventory = "No existen productos disponibles para agregar al carrito"
        alert!.setMessage(msgInventory)
        alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
    }
    
    func delSection(_ sender:UIButton){
        sugestedCarTableView.beginUpdates()
        let indexSet = NSMutableIndexSet()
        indexSet.add(sender.tag)
        sugestedCarTableView.deleteSections(indexSet as IndexSet, with: UITableViewRowAnimation.automatic)
        searchWordBySection.remove(at: sender.tag)
        /*let productos = allProducts![sender.tag]["products"] as! [[String:Any]]
        for i in 0..<itemsSelected.count{
            let filteredData = productos.filter{
                return $0["upc"] as! String == itemsSelected[i]["upc"] as! String
            }
            if filteredData.count > 0 {
                itemsSelected.remove(at: i)
            }
        }*/
        allProducts?.remove(at: sender.tag)
        
        sugestedCarTableView.endUpdates()
        sugestedCarTableView.reloadData()
    }
    
    func updateSection(section:Int,newSection:String){
        searchWordBySection[section] = newSection
        print(searchWordBySection)
        allProducts![section]["term"] = newSection
        print(allProducts)
        
        sugestedCarTableView.reloadData()
    }
}
