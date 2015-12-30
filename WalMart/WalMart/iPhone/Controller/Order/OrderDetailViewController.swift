//
//  OrderDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/23/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class OrderDetailViewController : NavigationViewController,UITableViewDataSource,UITableViewDelegate, ListSelectorDelegate {
    
    var trackingNumber = ""
    var status = ""
    var date = ""
    var viewLoad : WMLoadingView!
    var tableDetailOrder : UITableView!
    
    var viewFooter : UIView!
    var shareButton: UIButton?
    var addToCartButton: UIButton?
    var isShowingTabBar : Bool = true
    var showFedexGuide : Bool = false
    
    var itemDetail : NSDictionary!
    var itemDetailProducts : NSArray!
    var type : ResultObjectType!
    
    var detailsOrder : [AnyObject]!
    var detailsOrderGroceries : NSDictionary!
    
    var listSelectorController: ListsSelectorViewController?
    var addToListButton: UIButton?
    var alertView: IPOWMAlertViewController?
    
    var timmer : NSTimer!

    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREVIOUSORDERDETAIL.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_MGPREVIOUSORDERSDETAIL.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
        
        viewLoad = WMLoadingView(frame:CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
        self.viewFooter = UIView(frame:CGRectMake(0, self.view.bounds.maxY - 72, self.view.bounds.width, 46))
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.titleLabel!.text = trackingNumber
        
        tableDetailOrder = UITableView()
       
        tableDetailOrder.registerClass(PreviousDetailTableViewCell.self, forCellReuseIdentifier: "detailOrder")
        tableDetailOrder.registerClass(ProductDetailLabelCollectionView.self, forCellReuseIdentifier: "labelCell")
        tableDetailOrder.registerClass(OrderProductTableViewCell.self, forCellReuseIdentifier: "orderCell")
        tableDetailOrder.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.viewFooter!.backgroundColor = WMColor.shoppingCartFooter
        
        
        let y = (self.viewFooter!.frame.height - 34.0)/2
        if self.type == ResultObjectType.Groceries {
            self.addToListButton = UIButton()
            self.addToListButton!.setImage(UIImage(named: "detail_list"), forState: .Normal)
            self.addToListButton!.setImage(UIImage(named: "detail_list_selected"), forState: .Selected)
            self.addToListButton!.addTarget(self, action: "addCartToList", forControlEvents: .TouchUpInside)
            self.viewFooter!.addSubview(self.addToListButton!)
        }

        self.shareButton = UIButton(frame: CGRectMake(16.0, y, 34.0, 34.0))
        self.shareButton!.setImage(UIImage(named: "detail_shareOff"), forState: .Normal)
        self.shareButton!.setImage(UIImage(named: "detail_share"), forState: .Selected)
        self.shareButton!.setImage(UIImage(named: "detail_share"), forState: .Highlighted)
        self.shareButton!.addTarget(self, action: "shareList", forControlEvents: .TouchUpInside)
        self.viewFooter!.addSubview(self.shareButton!)
        
        let x = self.shareButton!.frame.maxX + 16.0
        
        self.addToCartButton = UIButton(frame: CGRectMake(x, y, (self.viewFooter!.frame.width - (x + 16.0)) - 32, 34.0))
        self.addToCartButton!.backgroundColor = WMColor.shoppingCartShopBgColor
        self.addToCartButton!.layer.cornerRadius = 17.0
 
        
        self.addToCartButton?.setTitle(NSLocalizedString("order.shop.title.btn", comment: ""), forState: .Normal)
        self.addToCartButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.addToCartButton?.titleLabel?.textColor = UIColor.whiteColor()
        //self.addToCartButton?.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0);
        self.addToCartButton!.addTarget(self, action: "addListToCart", forControlEvents: .TouchUpInside)
        self.viewFooter!.addSubview(self.addToCartButton!)
        
    
        self.view.addSubview(tableDetailOrder)
        self.view.addSubview(viewFooter)
        
        
        self.tableDetailOrder!.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
        self.tableDetailOrder!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 64, 0)
        
        
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.tableDetailOrder.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)

        self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64 , self.view.frame.width, 64)
        
        let y = (self.viewFooter!.frame.height - 34.0)/2

        if self.type == ResultObjectType.Groceries {
            self.addToListButton!.frame = CGRectMake(16.0, y, 34.0, 34.0)
            self.shareButton!.frame = CGRectMake(self.addToListButton!.frame.maxX + 16.0, y, 34.0, 34.0)
        }
        else {
            self.shareButton!.frame = CGRectMake(16.0, y, 34.0, 34.0)
        }
        
        self.addToCartButton!.frame = CGRectMake(self.shareButton!.frame.maxX + 16.0, y, (self.viewFooter!.frame.width - (self.shareButton!.frame.maxX + 16.0)) - 16.0, 34.0)
  
        if isShowingTabBar {
            self.self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64  - 45 , self.view.frame.width, 64)
        }else{
            self.self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64, self.view.frame.width, 64)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        isShowingTabBar = !TabBarHidden.isTabBarHidden
        
        reloadPreviousOrderDetail()
    }
 
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if showFedexGuide {
             return self.itemDetailProducts.count + 1
        }
        return 1
        
    }
    
    func showProducDetail(indexPath: NSIndexPath){
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = getUPCItems(indexPath.section)
        controller.ixSelected = indexPath.row
        if !showFedexGuide {
            controller.ixSelected = indexPath.row - 2
        }
        self.navigationController!.delegate = nil
        self.navigationController!.pushViewController(controller, animated: true)
    
    }
    
    //MARK:TableViewDelegate
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showFedexGuide {
            if section == 0 {
                return 1
            }
            let arrayProds = self.itemDetailProducts[section - 1] as! [String:AnyObject]
            let arrayProdsItems = arrayProds["items"] as! [AnyObject]
            return arrayProdsItems.count
        }
        return 2 + self.itemDetailProducts.count
            
    }
    
   
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        
        switch (indexPath.section, indexPath.row) {
            case (0,0):
                let cellDetail = tableDetailOrder.dequeueReusableCellWithIdentifier("detailOrder") as! PreviousDetailTableViewCell
                cellDetail.frame = CGRectMake(0, 0, self.tableDetailOrder.frame.width, cellDetail.frame.height)
                cellDetail.setValues(self.detailsOrder)
                cell = cellDetail
            case (0,1):
                let cellCharacteristicsTitle = tableDetailOrder.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as? ProductDetailLabelCollectionView
                cellCharacteristicsTitle!.setValues("Artículos de mi compra", font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.productDetailTitleTextColor, padding: 12,align:NSTextAlignment.Left)
                cell = cellCharacteristicsTitle
            default:
                let cellOrderProduct = tableDetailOrder.dequeueReusableCellWithIdentifier("orderCell", forIndexPath: indexPath) as! OrderProductTableViewCell
                cellOrderProduct.frame = CGRectMake(0, 0, self.tableDetailOrder.frame.width, cellOrderProduct.frame.height)
                cellOrderProduct.type = self.type
                var dictProduct = [:]
                if showFedexGuide {
                    let arrayProductsFed = itemDetailProducts[indexPath.section - 1] as! [String:AnyObject]
                    let productsArray = arrayProductsFed["items"] as! [AnyObject]
                    dictProduct = productsArray[indexPath.row ] as! NSDictionary
                } else {
                    dictProduct = itemDetailProducts[indexPath.row - 2] as! NSDictionary
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
                if let imageURLArray = dictProduct["imageUrl"] as? NSArray {
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
                
                cellOrderProduct.setValues(upcProduct,productImageURL:urlImage,productShortDescription:descript,productPrice:priceStr,quantity:quantityStr , type: self.type, pesable:isPesable, onHandInventory: onHandDefault, isActive:isActive,isPreorderable:isPreorderable)
                cell = cellOrderProduct

        }
        cell!.selectionStyle = UITableViewCellSelectionStyle.None

        return cell!
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            let size = PreviousDetailTableViewCell.sizeForCell(self.view.frame.width, values: self.detailsOrder)
            return size
        case 1:
            return 60
        default:
            return 109
        }
    }
   
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 44
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 0 {
            
            let arrayProductsFed = itemDetailProducts[section - 1] as! [String:AnyObject]
            let guide = arrayProductsFed["fedexGuide"] as! String
            let guideurl = arrayProductsFed["urlfedexGuide"] as! String
            let viewFedex = UIView()
            viewFedex.backgroundColor = WMColor.light_light_gray
            
            let lblGuide = UILabel(frame: CGRectMake(16, 0, 200, 44))
            lblGuide.text = "Guia: \(guide)"
            lblGuide.textColor = WMColor.light_blue
            lblGuide.font = WMFont.fontMyriadProRegularOfSize(14)
            
            if guideurl != "" {
                let btnGoToGuide = UIButton(frame:CGRectMake(self.view.frame.width - 84 , 11, 68, 22))
                btnGoToGuide.setTitle("Rastrear", forState: UIControlState.Normal)
                btnGoToGuide.backgroundColor = WMColor.light_blue
                btnGoToGuide.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                btnGoToGuide.layer.cornerRadius = btnGoToGuide.frame.height / 2
                btnGoToGuide.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
                btnGoToGuide.addTarget(self, action: "didSelectItem:", forControlEvents: UIControlEvents.TouchUpInside)
                btnGoToGuide.tag = section
                viewFedex.addSubview(btnGoToGuide)
            }
            viewFedex.addSubview(lblGuide)
            return viewFedex
        }
        return UIView()
    }
    
    func didSelectItem(sender:UIButton) {
        let arrayProductsFed = itemDetailProducts[sender.tag - 1] as! [String:AnyObject]
        let guideurl = arrayProductsFed["urlfedexGuide"] as! String
        
        
        let webCtrl = IPOWebViewController()
        if let url = NSURL(string: guideurl) {
            if UIApplication.sharedApplication().canOpenURL(url){
                webCtrl.openURL(guideurl)
                self.presentViewController(webCtrl,animated:true,completion:nil)
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
    
    func getUPCItems(section:Int) -> [[String:String]] {
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
    
    func reloadPreviousOrderDetail() {
        if type == ResultObjectType.Mg {
            let servicePrev = PreviousOrderDetailService()
            servicePrev.callService(trackingNumber, successBlock: { (result:NSDictionary) -> Void in
                
                self.tableDetailOrder.dataSource = self
                self.tableDetailOrder.delegate = self
                
                self.itemDetail = result
                
                var details : [[String:String]] = []
                let deliveryType = result["deliveryType"] as! String
                let name = result["name"] as! String
                let address = result["deliveryAddress"] as! String
                
                let statusLbl = NSLocalizedString("previousorder.status",comment:"")
                let dateLbl = NSLocalizedString("previousorder.date",comment:"")
                let nameLbl = NSLocalizedString("previousorder.name",comment:"")
                let deliveryTypeLbl = NSLocalizedString("previousorder.deliverytype",comment:"")
                let addressLbl = NSLocalizedString("previousorder.address",comment:"")
                //let fedexLbl = NSLocalizedString("previousorder.fedex",comment:"")
                
                details.append(["label":statusLbl,"value":self.status])
                details.append(["label":dateLbl,"value":self.date])
                details.append(["label":nameLbl,"value":name])
                details.append(["label":deliveryTypeLbl,"value":deliveryType])
                details.append(["label":addressLbl,"value":address])
                //details.append(["label":fedexLbl,"value":guide])
                

                var itemsFedex : [[String:AnyObject]] = []
                self.detailsOrder = details
                let resultsProducts =  result["items"] as! NSArray
                
                for itemProduct in resultsProducts {
                    let guide = itemProduct["fedexGuide"] as! String
                    let urlGuide = itemProduct["urlfedexGuide"] as! String
                    
                    let itemFedexFound = itemsFedex.filter({ (itemFedexFilter) -> Bool in
                        let itemTwo =  itemFedexFilter["fedexGuide"] as! String
                        return guide == itemTwo
                    })
                    
                    if itemFedexFound.count == 0 {
                        var itmNewProduct : [String:AnyObject] = [:]
                        itmNewProduct["fedexGuide"] = guide
                        itmNewProduct["urlfedexGuide"] = urlGuide
                        itmNewProduct["items"] = [itemProduct]
                        itemsFedex.append(itmNewProduct)
                    } else {
                        var itemFound = itemFedexFound[0] as  [String:AnyObject]
                        var itemsFound = itemFound["items"] as!  [AnyObject]
                        itemsFound.append(itemProduct)
                    }
                }
                self.showFedexGuide = true
                self.itemDetailProducts = itemsFedex
                
                self.tableDetailOrder.reloadData()
                self.viewLoad.stopAnnimating()
                }) { (error:NSError) -> Void in
                    self.viewLoad.stopAnnimating()
            }
        }else {
            
            self.tableDetailOrder.dataSource = self
            self.tableDetailOrder.delegate = self
            
            var details : [[String:String]] = []
            let deliveryType = detailsOrderGroceries["deliveryType"] as! String
            let deliveryDate = detailsOrderGroceries["deliveryDate"] as! String
            //let name = detailsOrderGroceries["name"] as NSString
            
            var statusGR = detailsOrderGroceries["status"] as! String
            if (detailsOrderGroceries["type"] as! String) == ResultObjectType.Groceries.rawValue {
                statusGR = NSLocalizedString("gr.order.status.\(statusGR)", comment: "")
            }
            
            //let nameGR = detailsOrderGroceries["name"] as NSString
           // let address = detailsOrderGroceries["deliveryAddress"] as NSString

            
            let statusLbl = NSLocalizedString("previousorder.status",comment:"")
            let dateLbl = NSLocalizedString("previousorder.date",comment:"")
            //let nameLbl = NSLocalizedString("previousorder.name",comment:"")
            let deliveryTypeLbl = NSLocalizedString("previousorder.deliverytype",comment:"")
            //let addressLbl = NSLocalizedString("previousorder.address",comment:"")
            //let fedexLbl = NSLocalizedString("previousorder.fedex",comment:"")
            
            details.append(["label":statusLbl,"value":statusGR])
            details.append(["label":dateLbl,"value":deliveryDate])
            //details.append(["label":nameLbl,"value":name])
            details.append(["label":deliveryTypeLbl,"value":deliveryType])
            //details.append(["label":addressLbl,"value":address])
           // details.append(["label":fedexLbl,"value":""])
            
            self.detailsOrder = details
            self.itemDetailProducts = detailsOrderGroceries["items"] as! NSArray
            self.tableDetailOrder.reloadData()
            self.viewLoad.stopAnnimating()
            
        }
    }


    //MARK: - Actions List Selector
    
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
    }
    
    func addListToCart (){
        
        if self.itemDetailProducts != nil && self.itemDetailProducts!.count > 0 {
            if type == ResultObjectType.Mg {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_ADD_ALL_TO_SHOPPING_CART.rawValue, label: "")
            }else {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_ADD_ALL_TO_SHOPPING_CART.rawValue, label: "")
            }
            var upcs: [AnyObject] = []
            if !showFedexGuide {
                for item in self.itemDetailProducts! {
                    upcs.append(getItemToShoppingCart(item as! NSDictionary))
                }
            } else {
                for item in self.itemDetailProducts! {
                    let itmProdVal = item["items"] as! [[String:AnyObject]]
                    for itemProd in itmProdVal {
                        upcs.append(getItemToShoppingCart(itemProd as NSDictionary))

                    }
                }
            }
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddItemsToShopingCart.rawValue, object: self, userInfo: ["allitems":upcs, "image":"list_alert_addToCart"])
        }
    
    }
    
    func getItemToShoppingCart(item:NSDictionary) ->  [String:AnyObject] {

        var params: [String:AnyObject] = [:]
        params["upc"] = item["upc"] as! String
        params["desc"] = item["description"] as! String
        
        
        if let images = item["imageUrl"] as? NSArray {
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
            params["quantity"] = "\(quantity.integerValue)"
        }
        else if let quantity = item["quantity"] as? NSString {
            params["quantity"] = "\(quantity.integerValue)"
        }
        
        
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
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: "")
        }else {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: "")
        }
        if let image = self.buildImageToShare() {
            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.navigationController?.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func buildImageToShare() -> UIImage? {
        let oldFrame : CGRect = self.tableDetailOrder!.frame
        var frame : CGRect = self.tableDetailOrder!.frame
        frame.size.height = self.tableDetailOrder!.contentSize.height
        self.tableDetailOrder!.frame = frame
        
        //UIGraphicsBeginImageContext(self.tableDetailOrder!.bounds.size)
        UIGraphicsBeginImageContextWithOptions(self.tableDetailOrder!.bounds.size, false, 2.0)
        self.tableDetailOrder!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let saveImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.tableDetailOrder!.frame = oldFrame
        return saveImage

    }
    
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
    
    override func willShowTabbar() {
        isShowingTabBar = true
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64  - 45 , self.view.frame.width, 64)
            self.tableDetailOrder!.contentInset = UIEdgeInsetsMake(0, 0, 109, 0)
            self.tableDetailOrder!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 109, 0)
        })
    }
    
    override func willHideTabbar() {
        isShowingTabBar = false
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64  , self.view.frame.width, 64)
            self.tableDetailOrder!.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
            self.tableDetailOrder!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 64, 0)
        })
    }


    //MARK: - ListSelectorDelegate
    
    func listSelectorDidClose() {
        self.removeListSelector(action: nil)
    }
    
    func listSelectorDidAddProduct(inList listId:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRAddItemListService()
        var products: [AnyObject] = []
        for var idx = 0; idx < self.itemDetailProducts.count; idx++ {
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
        for var idx = 0; idx < self.itemDetailProducts.count; idx++ {
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
            
            let serviceItem = service.buildProductObject(upc: upc, quantity: quantity, image: imgUrl, description: description, price: price, type: type)
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
    }
    
    override func back() {
        if type == ResultObjectType.Mg {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MG_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_PREVIOUS_ORDER.rawValue, label: "")
        }else {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_GR_PREVIOUS_ORDER_DETAILS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_PREVIOUS_ORDER.rawValue, label: "")
        }
        super.back()
    }

}