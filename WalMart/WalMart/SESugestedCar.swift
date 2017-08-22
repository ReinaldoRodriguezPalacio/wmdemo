//
//  SESugestedCar.swift
//  WalMart
//
//  Created by Vantis on 17/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

protocol SESugestedCarDelegate{
    func closeViewController()
}


class SESugestedCar: NavigationViewController, UITableViewDataSource, UITableViewDelegate, SESugestedRowDelegate{

    var alertView : IPOWMAlertViewController? = nil
    var viewLoad : WMLoadingView!
    var collection: UICollectionView?
    var sugestedCarTableView: UITableView!
    
    var allProducts: [[String:Any]]? = []
    var productsBySection : [String:Any]? = [:]
    var searchWordBySection : [String]! = []
    var params: [String:Any] = [:]
    var itemsSelected: [[String:Any]]! = []
    var selectedItemsbyRow : [Bool]! = []
    var searchWords: [String]! = []
    var titleHeader: String?
    
    var firstOpen  = true
    var isLoading  = false
    var hasEmptyView = false
    var isNewSection = false
    var numberOfNewSection : Int! = -1
    var isEditSection = false
    var numberOfEditSection : Int! = -1
    var viewFooter: UIView!
    var lblItemsCount: UILabel!
    var btnAddToCart: UIButton?
    var btnAddItem: UIButton?
    var delegate : SESearchViewController!
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
        
        self.btnAddItem = UIButton(frame:.zero)
        btnAddItem!.addTarget(self, action: #selector(self.addNewItem(_:)), for: .touchUpInside)
        self.btnAddItem?.setImage(UIImage(named: "ver_todo"), for: UIControlState())
        self.btnAddItem?.backgroundColor = WMColor.light_gray
        self.btnAddItem?.layer.cornerRadius = 15
        
        self.viewFooter.addSubview(btnAddToCart!)
        self.viewFooter.addSubview(btnAddItem!)
        self.view.addSubview(viewFooter)
        
        lblItemsCount = UILabel()
        lblItemsCount.font = WMFont.fontMyriadProRegularOfSize(12)
        lblItemsCount.textColor = WMColor.dark_gray
        lblItemsCount.text = "0 artículos"
        
        self.view.addSubview(lblItemsCount)
        cargaProductos()
        //self.invokeMultisearchService()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            UIView.animate(withDuration: 0.2, animations: {
                self.sugestedCarTableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.sugestedCarTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        })
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
        self.btnAddToCart?.frame = CGRect(x: self.viewFooter.frame.size.width / 2, y: 5, width: 0.8 * self.viewFooter.frame.size.width / 2, height: 30)
        self.btnAddItem?.frame = CGRect(x: self.viewFooter.frame.size.width / 4 - 15, y: 5, width: 30, height: 30)
    }
    
    override func back(){
        if self.navigationController != nil {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
        
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! SESugestedRowTitleViewCell
        cell.setValues(searchWordBySection[section], section: section, newSect: isNewSection, newSectNumber: numberOfNewSection, editSect: isEditSection, editSectNumber: numberOfEditSection)
        cell.delegate = self
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
        self.obtainSelectedItemsByRow(section: indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SESugestedRow
        cell.delegate = self
        if isNewSection && indexPath.section == numberOfNewSection{
            cell.setValues((allProducts![indexPath.section]["products"] as? [[String:Any]])!, section: indexPath.section, widthScreen: self.view.frame.width, isNewSect: true,selectedItems: selectedItemsbyRow)
        }else{
            cell.setValues((allProducts![indexPath.section]["products"] as? [[String:Any]])!, section: indexPath.section, widthScreen: self.view.frame.width, isNewSect: false,selectedItems: selectedItemsbyRow)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func cargaProductos(){
        
        let respuestaSESEarch = "{\"responseArray\":[{\"term\":\"agua\",\"products\":[{\"field\":\"19.0\",\"displayName\":\"Agua Gerber  4 l\",\"upc\":\"00750100098477\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100098477s.jpg\",\"baseUomcd\":\"EA\",\"quantity\":\"1\"},{\"field\":\"17.3\",\"displayName\":\"Agua Bonafont  6 l\",\"upc\":\"00075810400317\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00075810400317s.jpg\",\"baseUomcd\":\"EA\",\"quantity\":\"1\"},{\"field\":\"8.0\",\"displayName\":\"Agua Bonafont  1.5 l\",\"upc\":\"00075810400015\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00075810400015s.jpg\"},{\"field\":\"10.0\",\"displayName\":\"Agua Bonafont  2 l\",\"upc\":\"00075810400197\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00075810400197s.jpg\"},{\"field\":\"6.8\",\"displayName\":\"Agua Bonafont  1 l\",\"upc\":\"00075810410042\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00075810410042s.jpg\"},{\"field\":\"23.0\",\"displayName\":\"Agua Evian  1.5 l\",\"upc\":\"00006131400001\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00006131400001s.jpg\"},{\"field\":\"13.0\",\"displayName\":\"Agua Evian  500 ml\",\"upc\":\"00006131400003\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00006131400003s.jpg\"},{\"field\":\"18.0\",\"displayName\":\"Agua Evian  1 l\",\"upc\":\"00006131400007\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00006131400007s.jpg\"},{\"field\":\"53.0\",\"displayName\":\"TermÃ³metro Digital Omron  Contra Agua\",\"upc\":\"00007379624594\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00007379624594s.jpg\"},{\"field\":\"38.0\",\"displayName\":\"Agua Fiji  1 l\",\"upc\":\"00063256500002\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00063256500002s.jpg\"}]},{\"term\":\"pollo\",\"products\":[{\"field\":\"134.0\",\"displayName\":\"Alitas de pollo Tyson  sabor BBQ 700 g\",\"upc\":\"00750110069682\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750110069682s.jpg\",\"baseUomcd\":\"EA\",\"quantity\":\"1\"},{\"field\":\"92.0\",\"displayName\":\"Pechuga de pollo Tyson  sin hueso y sin piel 700 g\",\"upc\":\"00750110060603\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750110060603s.jpg\",\"baseUomcd\":\"EA\",\"quantity\":\"1\"},{\"field\":\"13.0\",\"displayName\":\"Caldo de pollo Knorr Suiza con cilantro 8 cubos\",\"upc\":\"00750100511987\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100511987s.jpg\"},{\"field\":\"17.9\",\"displayName\":\"Caldo de pollo Knorr Suiza 12 cubos\",\"upc\":\"00750100519649\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100519649s.jpg\"},{\"field\":\"17.0\",\"displayName\":\"Caldo de pollo Iberia  450 g\",\"upc\":\"00750100511234\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100511234s.jpg\"},{\"field\":\"14.0\",\"displayName\":\"Consomate  con pollo sabor original 12 cubos\",\"upc\":\"00750105921671\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750105921671s.jpg\"},{\"field\":\"29.0\",\"displayName\":\"Caldo de pollo Knorr Suiza 24 cubos\",\"upc\":\"00750100519929\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100519929s.jpg\"},{\"field\":\"72.0\",\"displayName\":\"Flautas de pollo El Cazo  24 pzas\",\"upc\":\"00750104001741\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750104001741s.jpg\"},{\"field\":\"89.5\",\"displayName\":\"Tenders de pollo Tyson  empanizados 700 g\",\"upc\":\"00750110064796\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750110064796s.jpg\"},{\"field\":\"62.0\",\"displayName\":\"Taquitos de pollo Alamesa  congelados 24 pzas\",\"upc\":\"00750300491139\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750300491139s.jpg\"}]},{\"term\":\"leche\",\"products\":[{\"field\":\"15.2\",\"displayName\":\"Leche Lala Light 1 l\",\"upc\":\"00750102051535\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750102051535s.jpg\",\"baseUomcd\":\"EA\",\"quantity\":\"1\"},{\"field\":\"7.2\",\"displayName\":\"Leche Alpura  sabor fresa 250 ml\",\"upc\":\"00000007500208\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007500208s.jpg\",\"baseUomcd\":\"EA\",\"quantity\":\"1\"},{\"field\":\"7.2\",\"displayName\":\"Leche Alpura  sabor vainilla 250 ml\",\"upc\":\"00000007500209\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007500209s.jpg\"},{\"field\":\"7.2\",\"displayName\":\"Leche Alpura  sabor chocolate 250 ml\",\"upc\":\"00000007500210\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007500210s.jpg\"},{\"field\":\"5.0\",\"displayName\":\"Gelatina de leche Danette  sabor fresa 100 g\",\"upc\":\"00000007503639\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007503639s.jpg\"},{\"field\":\"5.0\",\"displayName\":\"Gelatina de leche Danette  sabor vainilla 100 g\",\"upc\":\"00000007503640\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007503640s.jpg\"},{\"field\":\"6.0\",\"displayName\":\"Leche Lala entera 250 ml\",\"upc\":\"00000007504266\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007504266s.jpg\"},{\"field\":\"6.5\",\"displayName\":\"Leche Lala Yomi sabor chocolate 250 ml\",\"upc\":\"00000007504267\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007504267s.jpg\"},{\"field\":\"6.5\",\"displayName\":\"Leche Lala Yomi sabor fresa 250 ml\",\"upc\":\"00000007504268\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007504268s.jpg\"},{\"field\":\"6.5\",\"displayName\":\"Leche Lala Yomi sabor vainilla 250 ml\",\"upc\":\"00000007504269\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007504269s.jpg\"}]}]}"
        
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
        
        params["upc"] = producto["upc"] as? String
        params["quantity"] = producto["quantity"] as? String
        params["baseUomcd"] = producto["baseUomcd"] as? String
        params["desc"] = producto["displayName"] as? String
        params["imgUrl"] = producto["url"] as? String
        params["price"] = producto["field"] as? String
        params["pesable"] = "0"
        params["type"] = ResultObjectType.Groceries.rawValue
        params["comments"] = ""
        params["orderByPiece"] = "EA"
        params["pieces"] = "1"
        params["onHandInventory"] = "99"
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
    
    func itemDeSelectedAllBySection(seccion:Int){
        
            let productos = allProducts![seccion]["products"] as! [[String:Any]]
            
            for a in 0..<productos.count{
                for idxVal in 0..<self.itemsSelected!.count{
                    let item = self.itemsSelected![idxVal]
                    if (productos[a]["upc"] as! String == item["upc"] as! String){
                        itemsSelected.remove(at: idxVal)
                        break
                    }
                }
            }
            actualizaNumItems()
        
    }

    
    func actualizaNumItems(){
    lblItemsCount.text = "\(itemsSelected.count) artículos"
    }
    
    func invokeMultisearchService() {
        view.endEditing(true)
        //self.showLoadingView()
        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"superExpress"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("superExpress.message.createSugestedCart", comment:""))
        
        if UserCurrentSession.hasLoggedUser(){
            
            let multipleSearchService = SEmultipleSearchListService()
            multipleSearchService.callService(params: searchWords,
                                         successBlock: { (response:[String:Any]) -> Void in
                                            print("Call multiSearchService success")
                                            alertView!.setMessage("Listo")
                                            alertView!.showDoneIcon()
                                            self.getProductosBySearch(arrayProductos: response["responseArray"] as! [[String : Any]])
            },
                                         errorBlock: { (error:NSError) -> Void in
                                            print("Call multiSearchService error \(error)")
                                            alertView!.setMessage(NSLocalizedString("superExpress.message.createSugestedCart.error", comment:""))
                                            alertView!.showErrorIcon("Ok")
            }
            )
            
        }else{
            
            let multipleSearchService = SEmultipleSearchService()
            multipleSearchService.callService(params: searchWords,
                                         successBlock: { (response:[String:Any]) -> Void in
                                            print("Call multiSearchService success")
                                            alertView!.setMessage("Listo")
                                            alertView!.showDoneIcon()
                                            self.getProductosBySearch(arrayProductos: response["responseArray"] as! [[String : Any]])
            },
                                         errorBlock: { (error:NSError) -> Void in
                                            print("Call multiSearchService error \(error)")
                                            alertView!.setMessage(NSLocalizedString("superExpress.message.createSugestedCart.error", comment:""))
                                            alertView!.showErrorIcon("Ok")
            }
            )
        }
        
    }
    
    func invokeEditWordMultisearchService(newWord:String, section:Int) {
        searchWords = []
        searchWords.append(newWord)
        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"superExpress"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("superExpress.message.updateSugestedCart", comment:""))
        if UserCurrentSession.hasLoggedUser(){
            
            let multipleSearchService = SEmultipleSearchListService()
            multipleSearchService.callService(params: searchWords,
                                              successBlock: { (response:[String:Any]) -> Void in
                                                print("Call multiSearchService success")
                                                alertView!.setMessage("Listo")
                                                alertView!.showDoneIcon()
                                                self.getProductosBySearchOneProd(arrayProductos: response["responseArray"] as! [[String : Any]], section:section)
            },
                                              errorBlock: { (error:NSError) -> Void in
                                                print("Call multiSearchService error \(error)")
                                                alertView!.setMessage(NSLocalizedString("superExpress.message.updateSugestedCart.error", comment:""))
                                                alertView!.showErrorIcon("Ok")
                                                if self.isNewSection{
                                                    self.searchWordBySection.remove(at: section)
                                                    self.allProducts?.remove(at: section)
                                                    self.isNewSection = false
                                                    self.numberOfNewSection = -1
                                                    self.sugestedCarTableView.reloadData()
                                                }
            }
            )
            
        }else{
            
            let multipleSearchService = SEmultipleSearchService()
            multipleSearchService.callService(params: searchWords,
                                              successBlock: { (response:[String:Any]) -> Void in
                                                print("Call multiSearchService success")
                                                alertView!.setMessage("Listo")
                                                alertView!.showDoneIcon()
                                                self.getProductosBySearchOneProd(arrayProductos: response["responseArray"] as! [[String : Any]], section:section)
            },
                                              errorBlock: { (error:NSError) -> Void in
                                                print("Call multiSearchService error \(error)")
                                                alertView!.setMessage(NSLocalizedString("superExpress.message.updateSugestedCart.error", comment:""))
                                                alertView!.showErrorIcon("Ok")
                                                if self.isNewSection{
                                                    self.searchWordBySection.remove(at: section)
                                                    self.allProducts?.remove(at: section)
                                                    self.isNewSection = false
                                                    self.numberOfNewSection = -1
                                                    self.sugestedCarTableView.reloadData()
                                                }
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

    func getProductosBySearchOneProd(arrayProductos:[[String:Any]], section: Int){
        let products = arrayProductos
        
        if products.count > 0{
        
            for i in 0..<products.count{
                for (key, value) in products[i] {
                    if key == "products"{
                    allProducts![section]["products"] = products[i]["products"] as! [[String:Any]]
                    }
                }
            }
        }else{
        searchWordBySection.remove(at: section)
        allProducts?.remove(at: section)
        }
        isNewSection = false
        numberOfNewSection = -1
        isEditSection = false
        numberOfEditSection = -1

        sugestedCarTableView.reloadData()
        
    }

    
    func addListToCart(_ sender:UIButton) {
        
        
        if itemsSelected.count > 0 {
            
            let serviceAddProduct = SEaddToCartListService()
            var paramsitems: [[String:Any]] = []
            var parameters: [String:Any] = [:]
            
            if UserCurrentSession.hasLoggedUser(){
                
                for itemToShop in itemsSelected {
                    
                    let param = serviceAddProduct.buildParamitemsSuperMinutos(itemToShop["quantity"] as! String, upc: itemToShop["upc"] as! String, comments: itemToShop["comments"] as! String, baseUomcd: itemToShop["baseUomcd"] as! String)
                    
                    paramsitems.append(param)
                }
                if IS_IPAD{
                    parameters = serviceAddProduct.buildParametersSuperMinutos(busqueda: "", channel: "ipad")
                }else{
                    parameters = serviceAddProduct.buildParametersSuperMinutos(busqueda: "", channel: "iphone")
                }
                
                let parametros = serviceAddProduct.buildProductObjectSuperMinutos(paramsitems, parameter: parameters)

                let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"cart_loading"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
                alertView!.setMessage(NSLocalizedString("shoppingcart.additemswishlist", comment:""))

                serviceAddProduct.callService(params: parametros, successBlock: { (result:[String:Any]) -> Void in
                    BaseController.sendAnalyticsAddOrRemovetoCart(self.itemsSelected, isAdd: true) //360 multiple add
                    alertView!.setMessage(NSLocalizedString("superExpress.message.add.ok", comment:""))
                    alertView!.showDoneIcon()
                    NotificationCenter.default.post(name: .successUpdateItemsInShoppingCart, object: nil)
                    NotificationCenter.default.post(name: .reloadWishList, object: nil)
                    
                    
                    alertView?.afterRemove = {
                        UserCurrentSession.sharedInstance.loadGRShoppingCart({ () -> Void in
                            UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
                        })
                        if IS_IPAD{
                            //self.showShoppingCart()
                            self.cierraModal()
                            
                        }else{
                            self.back()
                            self.delegate?.closeViewController()
                        }

                    }

                }, errorBlock: { (error:NSError) -> Void in
                    alertView!.setMessage(NSLocalizedString("superExpress.message.add.error", comment:""))
                    alertView!.showErrorIcon("Ok")
                    if error.code != -100 {
                        
                        //self.spinImage.layer.removeAllAnimations()
                        //self.spinImage.isHidden = true
                        //self.titleLabel.sizeToFit()
                        //self.titleLabel.frame = CGRect(x: (self.view.frame.width / 2) - 116, y: self.titleLabel.frame.minY,  width: 232, height: 60)
                    }
                    
                    if error.code == 1 || error.code == 999 {
                        
                        //self.titleLabel.text = error.localizedDescription
                    } else if error.code != -100 {
                        
                        //self.titleLabel.text = error.localizedDescription
                        //self.imageProduct.image = UIImage(named:"alert_ups")
                        //self.viewBgImage.backgroundColor = WMColor.light_light_blue
                        //self.closeButton.isHidden = false
                    }
                        //self.closeButton.isHidden = false
                    
                })
            }
        else{
                for itemToShop in itemsSelected {
                    
                    let param = serviceAddProduct.builParamsCoreData(itemToShop["upc"] as! String, quantity: itemToShop["quantity"] as! String, comments: itemToShop["comments"] as! String, desc: itemToShop["desc"] as! String, price: itemToShop["price"] as! String, imageURL: itemToShop["imgUrl"] as! String, onHandInventory: itemToShop["onHandInventory"] as! String, pesable: itemToShop["pesable"] as! String, orderByPieces: itemToShop["orderByPiece"] as! String, pieces: itemToShop["pieces"] as! String)
                    paramsitems.append(param)
                }
                
                let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"cart_loading"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
                alertView!.setMessage(NSLocalizedString("shoppingcart.additemswishlist", comment:""))

                
            serviceAddProduct.callCoreDataService (paramsitems, successBlock: { (result:[String:Any]) -> Void in
                BaseController.sendAnalyticsAddOrRemovetoCart(self.itemsSelected, isAdd: true) //360 multiple add
                delay(0.5, completion: {
                    alertView!.setMessage(NSLocalizedString("superExpress.message.add.ok", comment:""))
                    alertView!.showDoneIcon()
                    alertView?.afterRemove = {
                        if IS_IPAD{
                            
                            self.cierraModal()
                            
                        }else{
                            self.back()
                            self.delegate?.closeViewController()
                        }
                        
                    }
                })
                
            }, errorBlock: { (error:NSError) -> Void in
                alertView!.setMessage(NSLocalizedString("superExpress.message.add.error", comment:""))
                alertView!.showErrorIcon("Ok")
                if error.code != -100 {
                    //self.spinImage.layer.removeAllAnimations()
                    //self.spinImage.isHidden = true
                    //self.titleLabel.sizeToFit()
                    //self.titleLabel.frame = CGRect(x: (self.view.frame.width / 2) - 116, y: self.titleLabel.frame.minY,  width: 232, height: 60)
                }
                
                if error.code == 1 || error.code == 999 {
                    //self.titleLabel.text = error.localizedDescription
                } else if error.code != -100 {
                    //self.titleLabel.text = error.localizedDescription
                    //self.imageProduct.image = UIImage(named:"alert_ups")
                    //self.viewBgImage.backgroundColor = WMColor.light_light_blue
                    //self.closeButton.isHidden = false
                }
                //self.closeButton.isHidden = false
                
            })
        }
        }
    }

    func noProductsAvailableAlert(){
        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
        let msgInventory = "No existen productos disponibles para agregar al carrito"
        alert!.setMessage(msgInventory)
        alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
    }
    
    func delSection(section:Int){
        
        if !isEditSection{
            if !isNewSection{
                self.itemDeSelectedAllBySection(seccion: section)
                print(searchWordBySection)
                searchWordBySection.remove(at: section)
                print(searchWordBySection)
                print(allProducts)
                allProducts?.remove(at: section)
                print(allProducts)
                let indexSet = NSMutableIndexSet()
                indexSet.add(section)
                sugestedCarTableView.deleteSections(indexSet as IndexSet, with: .automatic)
            }else{
                searchWordBySection.remove(at: section)
                allProducts?.remove(at: section)
            }
        }
        
        isNewSection = false
        numberOfNewSection = -1
        isEditSection = false
        numberOfEditSection = -1
        sugestedCarTableView.reloadData()
        
    }
    
    func editSection(section:Int){
        isEditSection = true
        numberOfEditSection = section
        isNewSection = false
        numberOfNewSection = -1
        sugestedCarTableView.reloadData()
        
    }

    func updateSection(section:Int,newSection:String){
        if !isNewSection{
            self.itemDeSelectedAllBySection(seccion: section)
        }
        searchWordBySection[section] = newSection
        allProducts![section]["term"] = newSection
        isEditSection = false
        numberOfEditSection = -1
        isNewSection = false
        numberOfNewSection = -1

        sugestedCarTableView.beginUpdates()
        self.invokeEditWordMultisearchService(newWord: newSection, section: section)
        sugestedCarTableView.endUpdates()

    }
    
    func addNewItem(_ sender:UIButton){
        let indexSet = NSMutableIndexSet()
        indexSet.add(sugestedCarTableView.numberOfSections)
        searchWordBySection.append("nueva búsqueda")
        allProducts?.append(["term":"nueva búsqueda", "products": [[:]]])
        isNewSection = true
        numberOfNewSection = searchWordBySection.count - 1
        isEditSection = false
        numberOfEditSection = -1
        
        sugestedCarTableView.reloadData()
    }
    
    func cierraModal(){
    
    }
    
    func obtainSelectedItemsByRow(section:Int){
    
        self.selectedItemsbyRow = []
        let productos = allProducts![section]["products"] as! [[String:Any]]
        if (isNewSection && section == numberOfNewSection) || self.itemsSelected!.count == 0{
            for _ in 0..<productos.count{
                    selectedItemsbyRow.append(false)
                }
            }else{
            for a in 0..<productos.count{
                for idxVal in 0..<self.itemsSelected!.count{
                    let item = self.itemsSelected![idxVal]
                    if (productos[a]["upc"] as! String == item["upc"] as! String){
                        selectedItemsbyRow.append(true)
                    }else{
                        selectedItemsbyRow.append(false)
                    }
                }
            }
        }
        
    }
    
}
