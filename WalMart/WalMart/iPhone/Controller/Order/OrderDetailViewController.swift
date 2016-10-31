//
//  OrderDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/23/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class OrderDetailViewController : NavigationViewController,UITableViewDataSource,UITableViewDelegate { //ListSelectorDelegate
    
    var shipping = ""
    var viewLoad : WMLoadingView!
    var tableDetailOrder : UITableView!
    
    var isShowingTabBar : Bool = true
    var showFedexGuide : Bool = true
    
    var itemDetailProducts : NSArray!
    var type : ResultObjectType!
    
    var detailsOrder : [AnyObject]!
    var detailsOrderGroceries : NSDictionary!
    
    var alertView: IPOWMAlertViewController?
    var timmer : Timer!

    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREVIOUSORDERDETAIL.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.titleLabel!.text = shipping
        
        tableDetailOrder = UITableView()
       
        tableDetailOrder.register(PreviousDetailTableViewCell.self, forCellReuseIdentifier: "detailOrder")
        tableDetailOrder.register(ProductDetailLabelCollectionView.self, forCellReuseIdentifier: "labelCell")
        tableDetailOrder.register(OrderProductTableViewCell.self, forCellReuseIdentifier: "orderCell")
        tableDetailOrder.separatorStyle = UITableViewCellSeparatorStyle.none
    
        self.view.addSubview(tableDetailOrder)
        
        self.tableDetailOrder!.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.tableDetailOrder!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        showLoadingView()
        
        self.tableDetailOrder.dataSource = self
        self.tableDetailOrder.delegate = self
        
        self.tableDetailOrder.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.tableDetailOrder.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isShowingTabBar = !TabBarHidden.isTabBarHidden
        //NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
        self.tableDetailOrder.reloadData()
        self.removeLoadingView()
    }
    
    func showProducDetail(_ indexPath: IndexPath){
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = getUPCItems((indexPath as NSIndexPath).section) as [AnyObject]
        controller.ixSelected = (indexPath as NSIndexPath).row
        if !showFedexGuide {
            controller.ixSelected = (indexPath as NSIndexPath).row - 2
        }
        self.navigationController!.delegate = nil
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    //MARK:TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if showFedexGuide {
            return self.itemDetailProducts.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showFedexGuide {
            if section == 0 {
                return 1
            }
            return self.itemDetailProducts.count
        }
        return 2 + self.itemDetailProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
            case (0,0):
                let cellDetail = tableDetailOrder.dequeueReusableCell(withIdentifier: "detailOrder") as! PreviousDetailTableViewCell
                cellDetail.frame = CGRect(x: 0, y: 0, width: self.tableDetailOrder.frame.width, height: cellDetail.frame.height)
                cellDetail.setValuesDetail(self.detailsOrderGroceries)
                cell = cellDetail
            case (0,1):
                let cellCharacteristicsTitle = tableDetailOrder.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as? ProductDetailLabelCollectionView
                cellCharacteristicsTitle!.setValues("Artículos de mi compra", font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.light_blue, padding: 12,align:NSTextAlignment.left)
                cell = cellCharacteristicsTitle
            default:
                let cellOrderProduct = tableDetailOrder.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderProductTableViewCell
                cellOrderProduct.frame = CGRect(x: 0, y: 0, width: self.tableDetailOrder.frame.width, height: cellOrderProduct.frame.height)
                cellOrderProduct.type = self.type
                var dictProduct = [:]
                if showFedexGuide {
                    dictProduct = (itemDetailProducts[(indexPath as NSIndexPath).row ] as! NSDictionary) as! [AnyHashable : Any]
                } else {
                    dictProduct = (itemDetailProducts[(indexPath as NSIndexPath).row - 2] as! NSDictionary) as! [AnyHashable : Any]
                }
                
                let itemShow = OrderDetailViewController.prepareValuesItems(dictProduct as NSDictionary)
                let valuesItems = itemShow[0] as NSDictionary
                
                //valuesItems["skuId"] as! String
                let pesableValue = valuesItems["pesable"] as! String == "true" ? true : false
                let isActiveValue = valuesItems["isActive"] as! String == "true" ? true : false
                
                cellOrderProduct.setValues("",upc:valuesItems["upc"] as! String, productImageURL:valuesItems["imageUrl"] as! String,productShortDescription:valuesItems["description"] as! String, productPrice:valuesItems["price"] as! String,quantity:valuesItems["quantity"] as! NSString, type: self.type, pesable:pesableValue, onHandInventory: valuesItems["onHandDefault"] as! String, isActive:isActiveValue, isPreorderable:valuesItems["isPreorderable"] as! String)
                cell = cellOrderProduct

        }
        cell!.selectionStyle = UITableViewCellSelectionStyle.none

        return cell!
    }
    
    class func prepareValuesItems (_ itemDetail : NSDictionary) -> [[String:String]]  {
        var upcItems : [[String:String]] = []
        
        let upcProduct = itemDetail["upc"] as! String
        let descript = itemDetail["description"] as! String
        var quantityStr = ""
        if let quantityProd = itemDetail["quantity"] as? String {
            quantityStr = quantityProd
        }
        if let quantityProd = itemDetail["quantity"] as? NSNumber {
            quantityStr = quantityProd.stringValue
        }
        var urlImage = ""
        if let imageURLArray = itemDetail["imageUrl"] as? NSArray {
            if imageURLArray.count > 0 {
                urlImage = imageURLArray[0] as! String
            }
        }
        if let imageURLArray = itemDetail["imageUrl"] as? NSString {
            urlImage = imageURLArray as String
        }
        var priceStr = ""
        if let price = itemDetail["price"] as? NSString {
            priceStr = price as String
        }
        if let price = itemDetail["price"] as? NSNumber {
            priceStr = price.stringValue
        }
        
        var isPesable : Bool = false
        if let pesable = itemDetail["type"] as?  NSString {
            isPesable = pesable.intValue == 1
        }
        
        var onHandDefault = "10"
        if let onHandInventory = itemDetail["onHandInventory"] as? NSString {
            onHandDefault = onHandInventory as String
        }
        
        var isPreorderable = "false"
        if let isPreorderableVal = itemDetail["isPreorderable"] as? String {
            isPreorderable = isPreorderableVal
        }
        
        var isActive = true
        if let stockSvc = itemDetail["stock"] as?  Bool {
            isActive = stockSvc
        }
        
        upcItems.append(["upc":upcProduct,"description":descript,"quantity":quantityStr, "imageUrl": urlImage, "price": priceStr, "pesable": String(isPesable), "onHandDefault": onHandDefault, "isPreorderable": isPreorderable,"isActive": String(isActive)])
        
        return upcItems
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0{
            let cellDetail = tableDetailOrder.dequeueReusableCell(withIdentifier: "detailOrder") as! PreviousDetailTableViewCell
            let size = cellDetail.sizeCell(self.view.frame.width, values: self.detailsOrderGroceries, showHeader: false)
            return size
        }else{
            return 109
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !showFedexGuide {
            switch (indexPath as NSIndexPath).row {
            case 0:
                return
            case 1:
                return
            default:
                print("Detail product")
                self.showProducDetail(indexPath)
            }
        }
        if (indexPath as NSIndexPath).section > 0 {
            self.showProducDetail(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 44
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 0 {
            
            let arrayProductsFed = itemDetailProducts[section - 1] as! [String:AnyObject]
            let guide = arrayProductsFed["fedexGuide"] as! String
            let guideurl = arrayProductsFed["urlfedexGuide"] as! String
            let viewFedex = UIView()
            viewFedex.backgroundColor = WMColor.light_light_gray
            
            let lblGuide = UILabel(frame: CGRect(x: 16, y: 0, width: 200, height: 44))
            lblGuide.text = "Guía: \(guide)"
            lblGuide.textColor = WMColor.light_blue
            lblGuide.font = WMFont.fontMyriadProRegularOfSize(14)
            
            if guideurl != "" {
                let iconImage = UIImage(color: WMColor.light_blue, size: CGSize(width: 68, height: 22), radius: 10)
                let iconSelected = UIImage(color: WMColor.dark_gray, size: CGSize(width: 68, height: 22), radius: 10)
                
                let btnGoToGuide = UIButton(frame:CGRect(x: self.view.frame.width - 84 , y: 11, width: 68, height: 22))
                btnGoToGuide.setTitle("Rastrear", for: UIControlState())
                btnGoToGuide.setBackgroundImage(iconSelected, for: .selected)
                btnGoToGuide.setBackgroundImage(iconImage, for: UIControlState())
                btnGoToGuide.setTitleColor(UIColor.white, for: UIControlState())
                btnGoToGuide.layer.cornerRadius = btnGoToGuide.frame.height / 2
                btnGoToGuide.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
                btnGoToGuide.addTarget(self, action: #selector(OrderDetailViewController.didSelectItem(_:)), for: UIControlEvents.touchUpInside)
                btnGoToGuide.tag = section
                if guide != "No disponible" {
                    viewFedex.addSubview(btnGoToGuide)
                }
            }
            viewFedex.addSubview(lblGuide)
            return viewFedex
        }
        return UIView()
    }
    
    func didSelectItem(_ sender:UIButton) {
        let arrayProductsFed = itemDetailProducts[sender.tag - 1] as! [String:AnyObject]
        let guideurl = arrayProductsFed["urlfedexGuide"] as! String
        
        
        let webCtrl = IPOWebViewController()
        if let url = URL(string: guideurl) {
            if UIApplication.shared.canOpenURL(url){
                webCtrl.openURL(guideurl)
                self.present(webCtrl,animated:true,completion:nil)
            }
        }
    }
    
    func getUPCItems() -> [[String:String]] {
        var upcItems : [[String:String]] = []
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue, label: itemDetailProducts[0]["description"] as! String)
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
        let shoppingCartProduct  =   itemDetailProducts[section - 1] as! [String:AnyObject]
        if let  listUPCItems =  shoppingCartProduct["items"] as? NSArray {
             BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue, label: listUPCItems[0]["description"] as! String)
            
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

    //MARK: - Actions List Selector
    /*
    func addCartToList() {
        if self.listSelectorController == nil {
            self.addToListButton!.selected = true
            let frame = self.view.frame
            
            if type == ResultObjectType.Mg {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_OPEN_ADD_TO_LIST.rawValue, label: "")
            }else {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_OPEN_ADD_TO_LIST.rawValue, label: "")
            }
            self.listSelectorController = ListsSelectorViewController()
            self.listSelectorController!.delegate = self
            //self.listSelectorController!.productUpc = self.upc
            self.addChildViewController(self.listSelectorController!)
            self.listSelectorController!.view.frame = CGRectMake(0.0, frame.height, frame.width, frame.height)
            self.view.insertSubview(self.listSelectorController!.view, belowSubview: self.viewFooter!)
            self.listSelectorController!.titleLabel!.text = NSLocalizedString("gr.addtolist.super", comment: "")
            self.listSelectorController!.didMoveToParentViewController(self)
            self.listSelectorController!.view.clipsToBounds = true
            
            self.listSelectorController!.generateBlurImage(self.view, frame: CGRectMake(0, 0, frame.width, frame.height))
            self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, -frame.height, frame.width, frame.height)
            
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.listSelectorController!.view.frame = CGRectMake(0, 0, frame.width, frame.height)
                    self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, 0, frame.width, frame.height)
                },
                completion: { (finished:Bool) -> Void in
                    if finished {
                        let footerFrame = self.viewFooter!.frame
                        self.listSelectorController!.tableView!.contentInset = UIEdgeInsetsMake(0, 0, footerFrame.height, 0)
                        self.listSelectorController!.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, footerFrame.height, 0)
                    }
                }
            )
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.listSelectorController!.view.frame = CGRectMake(0, 0, frame.width, frame.height)
                self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, 0, frame.width, frame.height)
            })
        }
        else {
            self.removeListSelector(action: nil)
        }
    }*/
    
    /*
    func removeListSelector(action action:(()->Void)?) {
        if self.listSelectorController != nil {
            UIView.animateWithDuration(0.5,
                delay: 0.0,
                options: .LayoutSubviews,
                animations: { () -> Void in
                    let frame = self.view.frame
                    self.listSelectorController!.view.frame = CGRectMake(0, frame.height, frame.width, 0.0)
                    self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, -frame.height, frame.width, frame.height)
                }, completion: { (complete:Bool) -> Void in
                    if complete {
                        if self.listSelectorController != nil {
                            self.listSelectorController!.willMoveToParentViewController(nil)
                            self.listSelectorController!.view.removeFromSuperview()
                            self.listSelectorController!.removeFromParentViewController()
                            self.listSelectorController = nil
                        }
                        self.addToListButton!.selected = false
                        
                        action?()
                    }
                }
            )
        }
    }
    */
    
    
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


    //MARK: - ListSelectorDelegate
    /*
    func listSelectorDidClose() {
        self.removeListSelector(action: nil)
    }
    
    func listSelectorDidAddProduct(inList listId:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRAddItemListService()
        var products: [AnyObject] = []
        for idx in 0 ..< self.itemDetailProducts.count {
            let item = self.itemDetailProducts[idx] as! [String:AnyObject]
            
            let upc = item["upc"] as! String
            var quantity: Int = 0
            if  let qIntProd = item["quantity"] as? Int {
                quantity = qIntProd
            }
            if  let qIntProd = item["quantity"] as? NSString {
                quantity = qIntProd.integerValue
            }
            
            var pesable = "0"
            if  let pesableP = item["type"] as? String {
                pesable = pesableP
            }
            var active = true
            if let stock = item["stock"] as? Bool {
                active = stock
            }
            
            products.append(service.buildProductObject(upc: upc, quantity: quantity,pesable:pesable,active:active))
        }
        
        service.callService(service.buildParams(idList: listId, upcs: products),
            successBlock: { (result:NSDictionary) -> Void in
                self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToListDone", comment:""))
                self.alertView!.showDoneIcon()
                self.alertView!.afterRemove = {
                    self.removeListSelector(action: nil)
                }
            }, errorBlock: { (error:NSError) -> Void in
                print("Error at add product to list: \(error.localizedDescription)")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
                self.alertView!.afterRemove = {
                    self.removeListSelector(action: nil)
                }
            }
        )
    }
    
    func listSelectorDidAddProductLocally(inList list:List) {
    }
    
    func listSelectorDidDeleteProductLocally(product:Product, inList list:List) {
    }
    
    func listSelectorDidDeleteProduct(inList listId:String) {
    }
    
    func listSelectorDidShowList(listId: String, andName name:String) {
        let storyboard = self.loadStoryboardDefinition()
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? UserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func listSelectorDidShowListLocally(list: List) {
        let storyboard = self.loadStoryboardDefinition()
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? UserListDetailViewController {
            vc.listEntity = list
            vc.listName = list.name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func shouldDelegateListCreation() -> Bool {
        return true
    }
    
    func listSelectorDidCreateList(name:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRSaveUserListService()
        
        var products: [AnyObject] = []
        for idx in 0 ..< self.itemDetailProducts.count {
            let item = self.itemDetailProducts[idx] as! [String:AnyObject]
            
            let upc = item["upc"] as! String
            var quantity: Int = 0
            if  let qIntProd = item["quantity"] as? NSNumber {
                quantity = qIntProd.integerValue
            }
            else if  let qIntProd = item["quantity"] as? NSString {
                quantity = qIntProd.integerValue
            }
            var price: String? = nil
            if  let priceNum = item["price"] as? NSNumber {
                price = "\(priceNum)"
            }
            else if  let priceTxt = item["price"] as? String {
                price = priceTxt
            }
            
            let imgUrl = item["imageUrl"] as? String
            let description = item["description"] as? String
            let type = item["type"] as? String
            
            var  nameLine = ""
            if let line = item["line"] as? NSDictionary {
                nameLine = line["name"] as! String
            }
            
            
            let serviceItem = service.buildProductObject(upc: upc, quantity: quantity, image: imgUrl, description: description, price: price, type: type,nameLine: nameLine)
            products.append(serviceItem)
        }
        
        service.callService(service.buildParams(name, items: products),
            successBlock: { (result:NSDictionary) -> Void in
                self.listSelectorController!.loadLocalList()
                self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToListDone", comment:""))
                self.alertView!.showDoneIcon()
            },
            errorBlock: { (error:NSError) -> Void in
                print(error)
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
            }
        )
    }*/
    
    override func back() {
        if type == ResultObjectType.Mg {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_PREVIOUS_ORDER.rawValue, label: "")
        }else {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_PREVIOUS_ORDER.rawValue, label: "")
        }
        super.back()
    }

}
