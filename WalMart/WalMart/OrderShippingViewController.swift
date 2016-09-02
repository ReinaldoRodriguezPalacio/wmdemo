//
//  OrderShippingViewController.swift
//  WalMart
//
//  Created by Daniel V on 26/08/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

class OrderShippingViewController: NavigationViewController, UITableViewDataSource,UITableViewDelegate {
    
    var trackingNumber = ""
    var status = ""
    var colorHeader = WMColor.yellow
    var itemDetail : NSDictionary! = [:]
    var shippingAll : NSArray! = []
    var detailsOrder : [AnyObject]!
    
    var type : ResultObjectType!
    var showFedexGuide : Bool = true
    
    var tableOrders : UITableView!
    var viewLoad : WMLoadingView!
    var emptyView : IPOOrderEmptyView!
    var isShowingTabBar : Bool = true
    var isShowingButtonFactura : Bool = false
    
    var viewStatus : UIView!
    var statusLabel : UILabel!
    
    var viewFooter : UIView!
    var shareButton: UIButton?
    var addToCartButton: UIButton?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREVIOUSORDERS.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewLoad = WMLoadingView(frame:CGRectZero)
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.titleLabel!.text = trackingNumber
        
        self.viewStatus = UIView(frame: CGRectMake(0.0, 46.0, self.titleLabel!.frame.width, 24.0))
        let backColor = PreviousOrdersTableViewCell.setColorStatus(status)
        self.viewStatus.backgroundColor = backColor
        self.statusLabel = UILabel(frame: CGRectMake(0.0, 0.0, self.titleLabel!.frame.width, 24.0))
        self.statusLabel.text = status //trackingNumber
        self.statusLabel.textColor = UIColor.whiteColor()
        self.statusLabel.textAlignment = .Center
        self.statusLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.viewStatus.addSubview(self.statusLabel)
        
        self.viewFooter = UIView(frame:CGRectMake(0, self.view.bounds.maxY - 72, self.view.frame.width, 46))
        
        tableOrders = UITableView()
        tableOrders.dataSource = self
        tableOrders.delegate = self
        
        tableOrders.registerClass(PreviousDetailTableViewCell.self, forCellReuseIdentifier: "detailOrder")
        tableOrders.registerClass(OrderShippingTotalTableViewCell.self, forCellReuseIdentifier: "totals")
        
        tableOrders.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.view.addSubview(tableOrders)
        
        emptyView = IPOOrderEmptyView(frame: CGRectZero)
        emptyView.returnAction = {() in
            self.back()
        }
        self.view.addSubview(emptyView)
        self.viewFooter!.backgroundColor = UIColor.whiteColor()
        
        let y = (self.viewFooter!.frame.height - 34.0)/2
        
        let xShare = (self.viewFooter!.frame.width - 239 - 34 - 16) / 2
        self.shareButton = UIButton(frame: CGRectMake(IS_IPAD ? xShare : 16.0, y, 34.0, 34.0))
        self.shareButton!.setImage(UIImage(named: "detail_shareOff"), forState: .Normal)
        self.shareButton!.setImage(UIImage(named: "detail_share"), forState: .Selected)
        self.shareButton!.setImage(UIImage(named: "detail_share"), forState: .Highlighted)
        self.shareButton!.addTarget(self, action: #selector(OrderShippingViewController.shareList), forControlEvents: .TouchUpInside)
        self.viewFooter!.addSubview(self.shareButton!)
        
        let x = self.shareButton!.frame.maxX + 16.0
        
        let toCartBtnWidth = IS_IPAD ? 239 : (self.viewFooter!.frame.width - (x + 16.0)) - 32
        self.addToCartButton = UIButton(frame: CGRectMake(x, y, toCartBtnWidth, 34.0))
        self.addToCartButton!.backgroundColor = WMColor.green
        self.addToCartButton!.layer.cornerRadius = 17.0
        
        self.addToCartButton?.setTitle(NSLocalizedString("order.shop.title.btn", comment: ""), forState: .Normal)
        self.addToCartButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.addToCartButton?.titleLabel?.textColor = UIColor.whiteColor()
        //self.addToCartButton?.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0);
        self.addToCartButton!.addTarget(self, action: #selector(OrderShippingViewController.addListToCart), forControlEvents: .TouchUpInside)
        self.viewFooter!.addSubview(self.addToCartButton!)
        
        self.view.addSubview(self.viewStatus)
        self.view.addSubview(viewFooter)
        
        showLoadingView()
        reloadPreviousOrderDetail()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        isShowingTabBar = !TabBarHidden.isTabBarHidden
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.viewStatus.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, 24.0)
        self.statusLabel.frame = CGRectMake(0.0, 0.0, self.viewStatus.frame.width, 24.0)
        
        self.emptyView.frame = CGRectMake(0, 71, self.view.frame.width, self.view.frame.height - 71)
        self.tableOrders.frame = CGRectMake(0, 71, self.view.bounds.width, self.view.bounds.height - 71)
        
        self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64 , self.view.frame.width, 64)
        
        let y = (self.viewFooter!.frame.height - 34.0)/2
        let xShare = (self.viewFooter!.frame.width - 239 - 34 - 16) / 2
        self.shareButton!.frame = CGRectMake(IS_IPAD ? xShare : 16.0, y, 34.0, 34.0)
        
        let toCartBtnWidth = IS_IPAD ? 239 : (self.viewFooter!.frame.width - (self.shareButton!.frame.maxX + 16.0)) - 16.0
        self.addToCartButton!.frame = CGRectMake(self.shareButton!.frame.maxX + 16.0, y, toCartBtnWidth, 34.0)
        
        if isShowingTabBar {
            self.self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64  - (IS_IPAD ? 0 : 45), self.view.frame.width, 64)
        }else{
            self.self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64, self.view.frame.width, 64)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadPreviousOrderDetail() {
        let servicePrev = PreviousOrderDetailService()
        servicePrev.callService(trackingNumber, successBlock: { (result:NSDictionary) -> Void in
            
            self.itemDetail = result
            self.shippingAll = result["Shipping"] as! NSArray
            
            self.emptyView.hidden = self.shippingAll.count > 0
            self.tableOrders.reloadData()
            self.removeLoadingView()
        }) { (error:NSError) -> Void in
            self.back()
            self.removeLoadingView()
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
        
        self.viewLoad = WMLoadingView(frame: CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
        self.viewLoad!.backgroundColor = UIColor.whiteColor()
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
    
    //MARK:TableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.shippingAll.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == (self.shippingAll.count - 1) {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame:CGRectMake(0, 0, self.view.frame.width, 40))
        headerView.backgroundColor = WMColor.light_light_gray
        
        let textOrder = "Envio \((section + 1)) de \(self.shippingAll.count)"
        let titleShipping = UILabel(frame:CGRectMake(16, 0, self.view.frame.width / 2, 40))
        titleShipping.font = WMFont.fontMyriadProRegularOfSize(16)
        titleShipping.textColor = WMColor.dark_gray
        titleShipping.text = textOrder
        headerView.addSubview(titleShipping)
        
        var showDetailButton: UIButton?
        showDetailButton = UIButton(frame: CGRectMake(self.view.frame.width - 84.0, 9.0, 68.0, 22.0))
        showDetailButton!.backgroundColor = WMColor.light_blue
        showDetailButton!.layer.cornerRadius = 10.0
        showDetailButton!.setTitle(NSLocalizedString("previousorder.showDetail", comment: ""), forState: .Normal)
        showDetailButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        showDetailButton!.titleLabel?.textColor = UIColor.whiteColor()
        showDetailButton?.tag = section
        showDetailButton!.addTarget(self, action: #selector(OrderShippingViewController.showShippingDetail(_:)), forControlEvents: .TouchUpInside)
        headerView.addSubview(showDetailButton!)

        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row != self.shippingAll.count {
            if indexPath.section == (self.shippingAll.count - 1) && indexPath.row == 1{
                return 63.0
            } else {
                let cellDetail = tableView.dequeueReusableCellWithIdentifier("detailOrder") as! PreviousDetailTableViewCell
                var valuesDetail : NSDictionary = [:]
                let shipping = self.shippingAll[indexPath.section] as! NSDictionary
                valuesDetail = ["name":self.itemDetail["name"] as! String, "deliveryType": shipping["deliveryType"] as! String, "deliveryAddress": shipping["deliveryAddress"] as! String, "paymentType": shipping["paymentType"] as! String, "items": shipping["items"] as! NSArray]
                let size = cellDetail.sizeCell(self.view.frame.width, values: valuesDetail, showHeader: true)
                return size
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        
        if indexPath.row != self.shippingAll.count {
            
            if indexPath.section == (self.shippingAll.count - 1) && indexPath.row == 1{
                let totalCell = tableView.dequeueReusableCellWithIdentifier("totals", forIndexPath: indexPath) as! OrderShippingTotalTableViewCell
                //let total = self.calculateTotalAmount()
                totalCell.setValues("790", totalSaving: "50")
                totalCell.selectionStyle = .None
                cell = totalCell
            } else {
                let cellDetail = tableOrders.dequeueReusableCellWithIdentifier("detailOrder") as! PreviousDetailTableViewCell
                cellDetail.frame = CGRectMake(0, 0, self.tableOrders.frame.width, cellDetail.frame.height)
                
                var valuesDetail : NSDictionary = [:]
                
                let name = self.itemDetail["name"] as! String
                
                let shipping = self.shippingAll[indexPath.section] as! NSDictionary
                let deliveryType = shipping["deliveryType"] as! String
                let deliveryAddress = shipping["deliveryAddress"] as! String
                let paymentType = shipping["paymentType"] as! String
                let itemsShipping = shipping["items"] as! NSArray
                
                valuesDetail = ["name":name, "deliveryType": deliveryType, "deliveryAddress": deliveryAddress, "paymentType": paymentType, "items": itemsShipping]
                cellDetail.setValuesDetail(valuesDetail)
                cellDetail.selectionStyle = .None
                cell = cellDetail
            }
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func willShowTabbar() {
        isShowingTabBar = true
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64  - 45 , self.view.frame.width, 64)
            self.tableOrders!.contentInset = UIEdgeInsetsMake(0, 0, 109, 0)
            self.tableOrders!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 109, 0)
        })
    }
    
    override func willHideTabbar() {
        isShowingTabBar = false
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64  , self.view.frame.width, 64)
            self.tableOrders!.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
            self.tableOrders!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 64, 0)
        })
    }
    
    func showShippingDetail(sender:UIButton){
        let detailController = OrderDetailViewController()
        
        var valuesDetail : NSDictionary = [:]
        
        let name = self.itemDetail["name"] as! String
        let shipping = self.shippingAll[sender.tag] as! NSDictionary
        let deliveryType = shipping["deliveryType"] as! String
        let deliveryAddress = shipping["deliveryAddress"] as! String
        let paymentType = shipping["paymentType"] as! String
        let itemsShipping = shipping["items"] as! NSArray
        
        valuesDetail = ["name":name, "deliveryType": deliveryType, "deliveryAddress": deliveryAddress, "paymentType": paymentType, "items": itemsShipping]
        detailController.shipping = "Envio \((sender.tag + 1)) de \(self.shippingAll.count)"
        detailController.detailsOrderGroceries = valuesDetail
        detailController.type = ResultObjectType.Mg //
        detailController.itemDetailProducts = shipping["items"] as! NSArray
        self.navigationController!.pushViewController(detailController, animated: true)
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_SHOW_ORDER_DETAIL.rawValue, label: "")
    }
    
    func addListToCart (){
        
        if self.shippingAll != nil && self.shippingAll.count > 0 {
            var upcs: [AnyObject] = []
            if !showFedexGuide {
                for item in self.shippingAll! {
                    upcs.append(getItemToShoppingCart(item as! NSDictionary))
                }
            } else {
                for item in self.shippingAll! {
                    let itmProdVal = item["items"] as! [[String:AnyObject]]
                    for itemProd in itmProdVal {
                        upcs.append(getItemToShoppingCart(itemProd as NSDictionary))
                        
                    }
                }
            }
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddItemsToShopingCart.rawValue, object: self, userInfo: ["allitems":upcs, "image": "alert_cart"])
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
        if let imgResult = self.imageToShareWishList() {
            let controller = UIActivityViewController(activityItems: [imgResult], applicationActivities: nil)
            self.navigationController?.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject{
        return "Walmart"
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        if activityType == UIActivityTypeMail {
            return "Hola,\nMira estos productos que encontré en Walmart. ¡Te los recomiendo!"
        }
        return ""
    }
    
    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        if activityType == UIActivityTypeMail {
            if UserCurrentSession.sharedInstance().userSigned == nil {
                return "Hola te quiero enseñar mi lista de www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance().userSigned!.profile.name) \(UserCurrentSession.sharedInstance().userSigned!.profile.lastName) te quiere enseñar su lista de www.walmart.com.mx"
            }
        }
        return ""
    }
    
    func imageToShareWishList() -> UIImage? {
        
        var unifiedImage : UIImage? = nil
        var ixYSpace : CGFloat = 0
        
        let totalImageSize = self.getImageWislistShareSize()
        UIGraphicsBeginImageContextWithOptions(totalImageSize, false, 2.0);
        
        for section in 0...shippingAll.count - 1 {
            let shippingSect = self.shippingAll[section] as! NSDictionary
            let itemsShipping = shippingSect["items"] as! NSArray
            
            let cellDetail = tableOrders.dequeueReusableCellWithIdentifier("detailOrder") as! PreviousDetailTableViewCell
            var valuesDetail : NSDictionary = [:]
            let shipping = itemsShipping[section] as! NSDictionary
            valuesDetail = ["name":self.itemDetail["name"] as! String, "deliveryType": shippingSect["deliveryType"] as! String, "deliveryAddress": shippingSect["deliveryAddress"] as! String, "paymentType": shippingSect["paymentType"] as! String, "items": shipping]
            let sizeCellFirst = cellDetail.sizeCell(self.view.frame.width, values: valuesDetail, showHeader: true)
            
            cellDetail.frame = CGRectMake(0, 0, totalImageSize.width, sizeCellFirst)
            loadShippingViewCellCollection(cellDetail,indexPath:NSIndexPath(forRow: 0, inSection: section))
            cellDetail.drawViewHierarchyInRect(CGRectMake(0.0, ixYSpace,totalImageSize.width, sizeCellFirst), afterScreenUpdates: true)
            ixYSpace = ixYSpace + sizeCellFirst
            
            for ixItem  in 0...itemsShipping.count - 1 {
                tableOrders.registerClass(OrderProductTableViewCell.self, forCellReuseIdentifier: "orderCell")
                let cellItems = tableOrders.dequeueReusableCellWithIdentifier("orderCell") as! OrderProductTableViewCell
                cellItems.frame = CGRectMake(0, 0, totalImageSize.width, 109)
                loadItemsViewCellCollection(cellItems, indexPath: NSIndexPath(forRow: ixItem, inSection: section))
                cellItems.drawViewHierarchyInRect(CGRectMake(0.0, ixYSpace,totalImageSize.width, 109), afterScreenUpdates: true)

                ixYSpace = ixYSpace + 109
            }
        }
        
        unifiedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return unifiedImage!
    }
    
    func loadShippingViewCellCollection(shippingCell:PreviousDetailTableViewCell,indexPath:NSIndexPath) {
        shippingCell.frame = CGRectMake(0, 0, self.tableOrders.frame.width, shippingCell.frame.height)
        
        var valuesDetail : NSDictionary = [:]
        
        let name = self.itemDetail["name"] as! String
        
        let shipping = self.shippingAll[indexPath.section] as! NSDictionary
        let deliveryType = shipping["deliveryType"] as! String
        let deliveryAddress = shipping["deliveryAddress"] as! String
        let paymentType = shipping["paymentType"] as! String
        let itemsShipping = shipping["items"] as! NSArray
        
        valuesDetail = ["name":name, "deliveryType": deliveryType, "deliveryAddress": deliveryAddress, "paymentType": paymentType, "items": itemsShipping]
        shippingCell.setValuesDetail(valuesDetail)
    }
    
    func loadItemsViewCellCollection(productCell:OrderProductTableViewCell,indexPath:NSIndexPath) {
        productCell.frame = CGRectMake(0, 0, self.tableOrders.frame.width, 109)
        
        productCell.type = self.type
        let dictSect = self.shippingAll[indexPath.section] as! NSDictionary
        let items = dictSect["items"] as! NSArray
        
        let dictProduct = items[indexPath.row] as! NSDictionary
        
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
        
        productCell.setValues(upcProduct,productImageURL:urlImage,productShortDescription:descript,productPrice:priceStr,quantity:quantityStr , type: self.type, pesable:isPesable, onHandInventory: onHandDefault, isActive:isActive,isPreorderable:isPreorderable)
    }
    
    func getImageWislistShareSize() -> CGSize {
        
        var height : CGFloat = 0.0
        for ixItem  in 0...self.shippingAll.count - 1 {
            
            let cellDetail = tableOrders.dequeueReusableCellWithIdentifier("detailOrder") as! PreviousDetailTableViewCell
            var valuesDetail : NSDictionary = [:]
            let shipping = self.shippingAll[ixItem] as! NSDictionary
            let items = shipping["items"] as! NSArray
            
            valuesDetail = ["name":self.itemDetail["name"] as! String, "deliveryType": shipping["deliveryType"] as! String, "deliveryAddress": shipping["deliveryAddress"] as! String, "paymentType": shipping["paymentType"] as! String, "items": items]
            let sizeCellFirst = cellDetail.sizeCell(self.view.frame.width, values: valuesDetail, showHeader: true)
            
            height = height + sizeCellFirst + (CGFloat(items.count) * 109)
        }

        let widthItem : CGFloat = self.tableOrders.frame.width
        return CGSize(width:widthItem, height: height)
    }
    
    /*func buildImageToShare() -> UIImage? {
        let oldFrame : CGRect = self.tableOrders!.frame
        var frame : CGRect = self.tableOrders!.frame
        frame.size.height = self.tableOrders!.contentSize.height
        self.tableOrders!.frame = frame
        
        UIGraphicsBeginImageContextWithOptions(self.tableOrders!.bounds.size, false, 2.0)
        self.tableOrders!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let saveImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.tableOrders!.frame = oldFrame
        return saveImage
    }*/
    
    override func back() {
        super.back()
    }
    
}
