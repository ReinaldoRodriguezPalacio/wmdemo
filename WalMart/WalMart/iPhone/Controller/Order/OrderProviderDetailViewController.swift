//
//  OrderProviderDetailViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 07/06/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class OrderProviderDetailViewController : NavigationViewController {
    
    var trackingNumber = ""
    var status = ""
    var date = ""
    var viewLoad : WMLoadingView!
    var tableDetailOrder : UITableView!
    
    var viewFooter : UIView!
    var shareButton: UIButton?
    var addToCartButton: UIButton?
    var optionsButton: UIButton?
    var showFedexGuide : Bool = false
    
    var itemDetail : [String:Any]!
    var itemDetailProducts : [[String:Any]]!
    var type : ResultObjectType!
    var detailsOrder : [Any]!

    var alertView: IPOWMAlertViewController?
    var emptyOrder: IPOSearchResultEmptyView!
    var timmer : Timer!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREVIOUSORDERDETAIL.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //viewLoad = WMLoadingView(frame:CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
        
        self.viewFooter = UIView(frame:CGRect(x: 0, y: self.view.bounds.maxY - 64, width: self.view.bounds.width, height: 46))
        
        self.view.backgroundColor = UIColor.white
        self.titleLabel!.text = "Envío 1 de 1"
        
        tableDetailOrder = UITableView()
        
        tableDetailOrder.register(PreviousDetailTableViewCell.self, forCellReuseIdentifier: "detailOrder")
        tableDetailOrder.register(ProductDetailLabelCollectionView.self, forCellReuseIdentifier: "labelCell")
        tableDetailOrder.register(OrderProductTableViewCell.self, forCellReuseIdentifier: "orderCell")
        tableDetailOrder.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.viewFooter!.backgroundColor = UIColor.white
        
        let y = (self.viewFooter!.frame.height - 34.0)/2
        
        self.shareButton = UIButton(frame: CGRect(x: 16.0, y: y, width: 34.0, height: 34.0))
        self.shareButton!.setImage(UIImage(named: "detail_shareOff"), for: UIControlState())
        self.shareButton!.setImage(UIImage(named: "detail_share"), for: .selected)
        self.shareButton!.setImage(UIImage(named: "detail_share"), for: .highlighted)
        self.shareButton!.addTarget(self, action: #selector(OrderDetailViewController.shareList), for: .touchUpInside)
        self.viewFooter!.addSubview(self.shareButton!)
        
        let x = self.shareButton!.frame.maxX + 16.0
        
        self.addToCartButton = UIButton(frame: CGRect(x: x, y: y, width: (self.viewFooter!.frame.width - (x + 16.0)) - 32, height: 34.0))
        self.addToCartButton!.backgroundColor = WMColor.green
        self.addToCartButton!.layer.cornerRadius = 17.0
        
        self.addToCartButton?.setTitle(NSLocalizedString("order.shop.title.btn", comment: ""), for: UIControlState())
        self.addToCartButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.addToCartButton?.titleLabel?.textColor = UIColor.white
        //self.addToCartButton?.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0);
        self.addToCartButton!.addTarget(self, action: #selector(OrderDetailViewController.addListToCart), for: .touchUpInside)
        self.viewFooter!.addSubview(self.addToCartButton!)
        
        self.view.addSubview(tableDetailOrder)
        self.view.addSubview(viewFooter)
        
        self.tableDetailOrder!.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.tableDetailOrder!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.optionsButton = UIButton()
        self.optionsButton?.setTitleColor(UIColor.white, for: .normal)
        self.optionsButton?.setTitle("opciones", for: .normal)
        self.optionsButton?.layer.cornerRadius = 11
        self.optionsButton?.backgroundColor = WMColor.light_blue
        self.optionsButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        self.optionsButton?.addTarget(self, action: #selector(showOptionsView), for: .touchUpInside)
        self.header?.addSubview(optionsButton!)
        
        showLoadingView()
        
        UserCurrentSession.sharedInstance.nameListToTag = NSLocalizedString("profile.myOrders", comment: "")
        BaseController.setOpenScreenTagManager(titleScreen: "Pedido \(trackingNumber)", screenName: self.getScreenGAIName())
        
        NotificationCenter.default.addObserver(self, selector: #selector(OrderDetailViewController.reloadViewDetail), name: .successUpdateItemsInShoppingCart, object: nil)
        
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableDetailOrder.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 154)
        self.viewFooter.frame = CGRect(x: 0, y: self.tableDetailOrder.frame.maxY , width: self.view.frame.width, height: 64)
        let y = (self.viewFooter!.frame.height - 34.0)/2
        self.shareButton!.frame = CGRect(x: 16.0, y: y, width: 34.0, height: 34.0)
        self.addToCartButton!.frame = CGRect(x: self.shareButton!.frame.maxX + 16.0, y: y, width: (self.viewFooter!.frame.width - (self.shareButton!.frame.maxX + 16.0)) - 16.0, height: 34.0)
        self.optionsButton!.frame = CGRect(x: self.view.frame.width - 84, y: 12, width: 68, height: 22)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadPreviousOrderDetail()
        
        if itemDetailProducts != nil {
            if itemDetailProducts.count == 0 {
                
                var maxY = self.tableDetailOrder!.frame.maxY
                let height = self.view.bounds.height
                var width = self.view.bounds.width
                
                if IS_IPAD {
                    maxY = maxY + 140
                    width -= 342.5
                } else {
                    maxY = maxY + 120
                }
                
                if self.emptyOrder == nil {
                    self.emptyOrder = IPOSearchResultEmptyView(frame:CGRect(x: 0, y: maxY, width: width, height: height - maxY))
                    self.emptyOrder.bgImageView.contentMode = .scaleAspectFill
                    self.emptyOrder.bgImageView.image = UIImage(named:"bg_pedidos_empty")
                    self.emptyOrder.returnButton.removeFromSuperview()
                }
                
                self.emptyOrder.descLabel.text = "No se encontraron artículos"
                self.tableDetailOrder.isScrollEnabled = false
                
                self.view.addSubview(self.emptyOrder)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableDetailOrder.reloadData()
    }
    
    func showProducDetail(_ indexPath: IndexPath){
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = getUPCItems(indexPath.section) as [Any]
        controller.ixSelected = indexPath.row
        if !showFedexGuide {
            controller.ixSelected = indexPath.row - 2
        }
        controller.detailOf = "Order"
        self.navigationController!.delegate = nil
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    func getUPCItems() -> [[String:String]] {
        var upcItems : [[String:String]] = []
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue, label: itemDetailProducts[0]["description"] as! String)
        for shoppingCartProduct in  itemDetailProducts {
            let upc = shoppingCartProduct["upc"] as! String
            let desc = shoppingCartProduct["description"] as! String
            let type = self.type.rawValue
            upcItems.append(["upc":upc,"description":desc,"type":type])
        }
        return upcItems
    }
    
    func getUPCItems(_ section:Int) -> [[String:String]] {
        var upcItems : [[String:String]] = []
        if !showFedexGuide {
            return getUPCItems()
        }
        let shoppingCartProduct  =   itemDetailProducts[section - 1]
        if let  listUPCItems =  shoppingCartProduct["items"] as? [[String:Any]] {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue, label: listUPCItems[0]["description"] as! String)
            
            for shoppingCartProductDetail in  listUPCItems {
                let upc = shoppingCartProductDetail["upc"] as! String
                let desc = shoppingCartProductDetail["description"] as! String
                let type = self.type.rawValue
                upcItems.append(["upc":upc,"description":desc,"type":type])
            }
        } else {
            return getUPCItems()
        }
        
        return upcItems
    }
    
    func reloadPreviousOrderDetail() {
        let servicePrev = PreviousOrderDetailService()
        servicePrev.callService(trackingNumber, successBlock: { (result:[String:Any]) -> Void in
                
            self.tableDetailOrder.dataSource = self
            self.tableDetailOrder.delegate = self
                
            self.itemDetail = result
                
            var details : [[String:String]] = []
            let deliveryType = result["deliveryType"] as? String ?? ""
            let name = result["name"] as! String
            let address = result["deliveryAddress"] as! String
                
            let statusLbl = NSLocalizedString("previousorder.status",comment:"")
            let dateLbl = NSLocalizedString("previousorder.date",comment:"")
            let nameLbl = NSLocalizedString("previousorder.name",comment:"")
            let deliveryTypeLbl = NSLocalizedString("previousorder.deliverytype",comment:"")
            let addressLbl = NSLocalizedString("previousorder.address",comment:"")
            //let fedexLbl = NSLocalizedString("previousorder.fedex",comment:"")
        
            var providerName = ""
            let resultsProducts =  result["items"] as! [[String:Any]]
            var itemsFedex : [[String:Any]] = []
            
            for itemProduct in resultsProducts {
                let guide = itemProduct["fedexGuide"] as! String
                let urlGuide = itemProduct["urlfedexGuide"] as! String
                
                var itemFedexFound = itemsFedex.filter({ (itemFedexFilter) -> Bool in
                    let itemTwo =  itemFedexFilter["fedexGuide"] as! String
                    return guide == itemTwo
                })
                
                if self.status == "" {
                    self.status = itemProduct["status"] as? String ?? ""
                }
                
                if providerName == "" {
                    providerName = itemProduct["sellerName"] as? String ?? ""
                }

            if itemFedexFound.count == 0 {
                    var itmNewProduct : [String:Any] = [:]
                    itmNewProduct["fedexGuide"] = guide
                    itmNewProduct["urlfedexGuide"] = urlGuide
                    itmNewProduct["items"] = [itemProduct]
                    itemsFedex.append(itmNewProduct)
                } else {
                    let index = itemsFedex.index(where: { (itemFedexFilter) -> Bool in
                        let itemTwo =  itemFedexFilter["fedexGuide"] as! String
                        return guide == itemTwo
                    })
                    var itemFound = itemFedexFound[0] as  [String:Any]
                    var itemsFound = itemFound["items"] as!  [Any]
                    itemsFound.append(itemProduct)
                    itemsFedex.remove(at: index!)
                    var itmNewProduct : [String:Any] = [:]
                    itmNewProduct["fedexGuide"] = guide
                    itmNewProduct["urlfedexGuide"] = urlGuide
                    itmNewProduct["items"] = itemsFound
                    itemsFedex.append(itmNewProduct)
                
                }
            }
            
            details.append(["label":statusLbl,"value":self.status])
            details.append(["label":dateLbl,"value":self.date])
            details.append(["label":nameLbl,"value":name])
            details.append(["label":deliveryTypeLbl,"value":deliveryType])
            details.append(["label":addressLbl,"value":address])
            details.append(["label":"Proveedor","value":providerName])
            //details.append(["label":fedexLbl,"value":guide])
            self.detailsOrder = details
            
            self.showFedexGuide = true
            self.itemDetailProducts = itemsFedex
            
            self.tableDetailOrder.reloadData()
            self.removeLoadingView()
        }) { (error:NSError) -> Void in
            //
            self.back()
            self.removeLoadingView()
        }
    }
    
    func addListToCart (){
        
        if self.itemDetailProducts != nil && self.itemDetailProducts!.count > 0 {
            
            var upcs: [[String:Any]] = []
            if !showFedexGuide {
                for item in self.itemDetailProducts! {
                    upcs.append(getItemToShoppingCart(item))
                }
            } else {
                for item in self.itemDetailProducts! {
                    let itmProdVal = item["items"] as! [[String:Any]]
                    for itemProd in itmProdVal {
                        upcs.append(getItemToShoppingCart(itemProd as [String:Any]))
                        
                    }
                }
            }
            NotificationCenter.default.post(name: .addItemsToShopingCart, object: self, userInfo: ["allitems":upcs, "image": "alert_cart"])
            delay(0.5, completion: {
                //                self.showLoadingView()
                //                self.reloadPreviousOrderDetail()
                self.reloadViewDetail()
            })
        }
        
    }
    
    func getItemToShoppingCart(_ item:[String:Any]) ->  [String:Any] {
        
        var params: [String:Any] = [:]
        params["upc"] = item["upc"] as! String
        params["desc"] = item["description"] as! String
        
        
        if let images = item["imageUrl"] as? [Any] {
            params["imgUrl"] = images[0] as! String
        }else
        {
            params["imgUrl"] = item["imageUrl"] as! String
        }
        if let price = item["price"] as? NSNumber {
            params["price"] = "\(price)"
        }
        else if let price = item["price"] as? String {
            params["price"] = price
        }
        
        if let quantity = item["quantity"] as? Int {
            params["quantity"] = "\(quantity)"
        }else if let quantity = item["quantity"] as? NSNumber {
            params["quantity"] = "\(quantity.intValue)"
        }
        else if let quantity = item["quantity"] as? NSString {
            params["quantity"] = "\(quantity.integerValue)"
        }
        
        var baseUomcd = "EA"
        if let baseUomcdItem = item["baseUomcd"] as? String {
            baseUomcd = baseUomcdItem
        }
        params["baseUomcd"] = baseUomcd
        
        params["orderByPiece"] = baseUomcd == "EA"
        params["wishlist"] = false
        params["type"] = type.rawValue
        params["comments"] = ""
        if let type = item["type"] as? String {
            if Int(type)! == 0 { //Piezas
                params["onHandInventory"] = "99"
            }
            else { //Gramos
                params["onHandInventory"] = "20000"
            }
        }
        return params
    }
    
    func shareList() {
        if type == ResultObjectType.Mg {
            ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: "")
        }else {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: "")
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.header!.frame.width, height: 70.0))
        let image = UIImage(named: "detail_HeaderMail")
        imageView.image = image
        var imageHead = UIImage(from: imageView) //(named:"detail_HeaderMail") //
        self.backButton?.isHidden = true
        var headerCapture = UIImage(from: header)
        self.backButton?.isHidden = false
        
        if let image = self.tableDetailOrder!.screenshot() {
            let imgResult = UIImage.verticalImage(from: [imageHead!, headerCapture!, image])
            imageHead = nil
            headerCapture = nil
            
            let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx")
            
            let controller = UIActivityViewController(activityItems: [self, imgResult, urlWmart!], applicationActivities: nil)
            self.navigationController?.present(controller, animated: true, completion: nil)
            
            controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        }
    }
    /**
     Present loader in screen list
     */
    func showLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46))
        self.viewLoad!.backgroundColor = UIColor.white
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(self.isVisibleTab)
    }
    
    /**
     Remove loader from screen list
     */
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    func reloadViewDetail() {
        self.tableDetailOrder.reloadData()
    }
    
    func showOptionsView() {
        let controller = OrderMoreOptionsViewController()
        let arrayProductsFed = itemDetailProducts[0]
        let productsArray = arrayProductsFed["items"] as! [[String:Any]]
        
        controller.orderItems = productsArray
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func back() {
        if type == ResultObjectType.Mg {
            ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_PREVIOUS_ORDER.rawValue, label: "")
        }else {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_PREVIOUS_ORDER.rawValue, label: "")
        }
        super.back()
    }
    
    override func swipeHandler(swipe: UISwipeGestureRecognizer) {
        self.back()
    }
    
}

//MARK: UITableViewDataSource
extension OrderProviderDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if showFedexGuide {
            return self.itemDetailProducts.count + 1
        }
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if showFedexGuide {
            if section == 0 {
                return 1
            }
            let arrayProds = self.itemDetailProducts[section - 1]
            let arrayProdsItems = arrayProds["items"] as! [Any]
            return arrayProdsItems.count
        }
        
        return 2 + self.itemDetailProducts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = nil
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            let cellDetail = tableDetailOrder.dequeueReusableCell(withIdentifier: "detailOrder") as! PreviousDetailTableViewCell
            cellDetail.frame = CGRect(x: 0, y: 0, width: self.tableDetailOrder.frame.width, height: cellDetail.frame.height)
            cellDetail.setValuesProvider(self.detailsOrder)
            cell = cellDetail
        case (0,1):
            let cellCharacteristicsTitle = tableDetailOrder.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as? ProductDetailLabelCollectionView
            cellCharacteristicsTitle!.setValues("Artículos de mi compra", font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.light_blue, padding: 12,align:NSTextAlignment.left)
            cell = cellCharacteristicsTitle
        default:
            
            let cellOrderProduct = tableDetailOrder.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderProductTableViewCell
            cellOrderProduct.frame = CGRect(x: 0, y: 0, width: self.tableDetailOrder.frame.width, height: cellOrderProduct.frame.height)
            cellOrderProduct.type = self.type
            
            var dictProduct: [String:Any] = [:]
            
            if showFedexGuide {
                let arrayProductsFed = itemDetailProducts[indexPath.section - 1]
                let productsArray = arrayProductsFed["items"] as! [Any]
                dictProduct = productsArray[indexPath.row] as! [String:Any]
            } else {
                dictProduct = itemDetailProducts[indexPath.row - 2]
            }
            
            let upcProduct = dictProduct["upc"] as! String
            let descript = dictProduct["description"] as! String
            var quantityStr = ""
            if let quantityProd = dictProduct["quantity"] as? String {
                quantityStr = quantityProd
            }
            if let quantityProd = dictProduct["quantity"] as? NSNumber {
                quantityStr = quantityProd.stringValue
            }
            var urlImage = ""
            if let imageURLArray = dictProduct["imageUrl"] as? [Any] {
                if imageURLArray.count > 0 {
                    urlImage = imageURLArray[0] as! String
                }
            }
            if let imageURLArray = dictProduct["imageUrl"] as? NSString {
                urlImage = imageURLArray as String
            }
            var priceStr = ""
            if let price = dictProduct["price"] as? NSString {
                priceStr = price as String
            }
            if let price = dictProduct["price"] as? NSNumber {
                priceStr = price.stringValue
            }
            
            var isPesable : Bool = false
            if let pesable = dictProduct["type"] as?  NSString {
                isPesable = pesable.intValue == 1
            }
            if let pesable = dictProduct["pesable"] as?  String {
                isPesable = (pesable == "true")
            }
            
            var onHandDefault = "10"
            if let onHandInventory = dictProduct["onHandInventory"] as? NSString {
                onHandDefault = onHandInventory as String
            }
            
            var isPreorderable = "false"
            if let isPreorderableVal = dictProduct["isPreorderable"] as? String {
                isPreorderable = isPreorderableVal
            }
            
            var isActive = true
            if let stockSvc = dictProduct["stock"] as?  Bool {
                isActive = stockSvc
            }
            
            cellOrderProduct.setValues(upcProduct,productImageURL:urlImage,productShortDescription:descript,productPrice:priceStr,quantity:quantityStr as NSString , type: self.type, pesable:isPesable, onHandInventory: onHandDefault, isActive:isActive,isPreorderable:isPreorderable)
            cell = cellOrderProduct
            
        }
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 0 {
            
            let arrayProductsFed = itemDetailProducts[section - 1]
            let guide = arrayProductsFed["fedexGuide"] as! String
            let guideurl = arrayProductsFed["urlfedexGuide"] as! String
            let viewFedex = UIView()
            viewFedex.backgroundColor = WMColor.light_light_gray
            
            let lblGuide = UILabel(frame: CGRect(x: 16, y: 0, width: 200, height: 44))
            lblGuide.text = "Guia: \(guide)"
            lblGuide.textColor = WMColor.light_blue
            lblGuide.font = WMFont.fontMyriadProRegularOfSize(14)
            
            if guideurl != "" {
                let btnGoToGuide = UIButton(frame:CGRect(x: self.view.frame.width - 84 , y: 11, width: 68, height: 22))
                btnGoToGuide.setTitle("rastrear", for: UIControlState())
                btnGoToGuide.backgroundColor = WMColor.light_blue
                btnGoToGuide.setTitleColor(UIColor.white, for: UIControlState())
                btnGoToGuide.layer.cornerRadius = btnGoToGuide.frame.height / 2
                btnGoToGuide.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
                btnGoToGuide.addTarget(self, action: #selector(OrderDetailViewController.didSelectItem(_:)), for: UIControlEvents.touchUpInside)
                btnGoToGuide.tag = section
                if guide == "No disponible" {
                    viewFedex.addSubview(btnGoToGuide)
                }
            }
            viewFedex.addSubview(lblGuide)
            return viewFedex
        }
        return UIView()
    }
}

//MARK: UITableViewDelegate
extension OrderProviderDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 0{
            let size = PreviousDetailTableViewCell.sizeForCell(self.view.frame.width, values: self.detailsOrder)
            return size
        }else{
            return 109
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !showFedexGuide {
            switch indexPath.row {
            case 0:
                return
            case 1:
                return
            default:
                print("Detail product")
                self.showProducDetail(indexPath)
            }
        }
        if indexPath.section > 0 {
            self.showProducDetail(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 44
        }
        return 0
    }
    
    func didSelectItem(_ sender:UIButton) {
        let arrayProductsFed = itemDetailProducts[sender.tag - 1]
        let guideurl = arrayProductsFed["urlfedexGuide"] as! String
        
        
        let webCtrl = IPOWebViewController()
        if let url = URL(string: guideurl) {
            if UIApplication.shared.canOpenURL(url){
                webCtrl.openURL(guideurl)
                self.present(webCtrl,animated:true,completion:nil)
            }
        }
        
        
    }
}

//MARK: UIActivityItemSource
extension OrderProviderDetailViewController: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any{
        return "Walmart"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        if activityType == UIActivityType.mail {
            return "Hola, encontré estos productos en Walmart.¡Te los recomiendo!\n\nSiempre encuentra todo y pagas menos."
        }
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        if activityType == UIActivityType.mail {
            if UserCurrentSession.sharedInstance.userSigned == nil {
                return "Hola te quiero enseñar una compra que hice en www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance.userSigned!.profile.name) \(UserCurrentSession.sharedInstance.userSigned!.profile.lastName) hizo una compra que te puede interesar en walmart.com.mx"
            }
        }
        return ""
    }
    
}

