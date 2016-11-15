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
    var itemDetail : [String:Any]! = [:]
    var shippingAll : NSArray! = []
    var detailsOrder : [Any]!
    
    var type : ResultObjectType!
    var showFedexGuide : Bool = true
    
    var tableOrders : UITableView!
    var viewLoad : WMLoadingView!
    var emptyView : IPOOrderEmptyView!
    var isShowingTabBar : Bool = true
    var isShowingButtonFactura : Bool = false
    
    var viewStatus : UIView!
    var statusLabel : UILabel!
    var popup : UIPopoverController?
    
    var viewFooter : UIView!
    var shareButton: UIButton?
    var addToCartButton: UIButton?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREVIOUSORDERS.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewLoad = WMLoadingView(frame:CGRect.zero)
        
        self.view.backgroundColor = UIColor.white
        self.titleLabel!.text = trackingNumber
        
        self.viewStatus = UIView(frame: CGRect(x: 0.0, y: 46.0, width: self.titleLabel!.frame.width, height: 24.0))
        let backColor = PreviousOrdersTableViewCell.setColorStatus(status)
        self.viewStatus.backgroundColor = backColor
        self.statusLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.titleLabel!.frame.width, height: 24.0))
        self.statusLabel.text = status //trackingNumber
        self.statusLabel.textColor = UIColor.white
        self.statusLabel.textAlignment = .center
        self.statusLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.viewStatus.addSubview(self.statusLabel)
        
        self.viewFooter = UIView(frame:CGRect(x: 0, y: self.view.bounds.maxY - 72, width: self.view.frame.width, height: 46))
        
        tableOrders = UITableView()
        tableOrders.dataSource = self
        tableOrders.delegate = self
        
        tableOrders.register(PreviousDetailTableViewCell.self, forCellReuseIdentifier: "detailOrder")
        tableOrders.register(ShoppingCartTotalsTableViewCell.self, forCellReuseIdentifier: "totals")
        
        tableOrders.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.view.addSubview(tableOrders)
        
        emptyView = IPOOrderEmptyView(frame: CGRect.zero)
        emptyView.returnAction = {() in
            self.back()
        }
        emptyView.returnButton.isHidden = IS_IPAD
        self.viewFooter!.backgroundColor = UIColor.white
        
        let y = (self.viewFooter!.frame.height - 34.0)/2
        
        let xShare = (self.viewFooter!.frame.width - 239 - 34 - 16) / 2
        self.shareButton = UIButton(frame: CGRect(x: IS_IPAD ? xShare : 16.0, y: y, width: 34.0, height: 34.0))
        self.shareButton!.setImage(UIImage(named: "detail_shareOff"), for: UIControlState())
        self.shareButton!.setImage(UIImage(named: "detail_share"), for: .selected)
        self.shareButton!.setImage(UIImage(named: "detail_share"), for: .highlighted)
        self.shareButton!.addTarget(self, action: #selector(OrderShippingViewController.shareList), for: .touchUpInside)
        self.viewFooter!.addSubview(self.shareButton!)
        
        let x = self.shareButton!.frame.maxX + 16.0
        
        let toCartBtnWidth = IS_IPAD ? 239 : (self.viewFooter!.frame.width - (x + 16.0)) - 32
        self.addToCartButton = UIButton(frame: CGRect(x: x, y: y, width: toCartBtnWidth, height: 34.0))
        self.addToCartButton!.backgroundColor = WMColor.green
        self.addToCartButton!.layer.cornerRadius = 17.0
        
        self.addToCartButton?.setTitle(NSLocalizedString("order.shop.title.btn", comment: ""), for: UIControlState())
        self.addToCartButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.addToCartButton?.titleLabel?.textColor = UIColor.white
        //self.addToCartButton?.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0);
        self.addToCartButton!.addTarget(self, action: #selector(OrderShippingViewController.addListToCart), for: .touchUpInside)
        self.viewFooter!.addSubview(self.addToCartButton!)
        
        self.view.addSubview(self.viewStatus)
        self.view.addSubview(viewFooter)
        self.view.addSubview(emptyView)
        
        showLoadingView()
        reloadPreviousOrderDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isShowingTabBar = !TabBarHidden.isTabBarHidden
        if !isShowingTabBar {
            self.viewFooter.frame = CGRect(x: 0, y: self.view.frame.height - 64  , width: self.view.frame.width, height: 64)
            self.tableOrders!.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
            self.tableOrders!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 64, 0)
        } else if !IS_IPAD {
            willShowTabbar()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.viewStatus.frame = CGRect(x: 0.0, y: 46.0, width: self.view.bounds.width, height: 24.0)
        self.statusLabel.frame = CGRect(x: 0.0, y: 0.0, width: self.viewStatus.frame.width, height: 24.0)
        
        self.emptyView.frame = CGRect(x: 0, y: 46.0, width: self.view.bounds.width, height: self.view.frame.height - 46.0)
        self.tableOrders.frame = CGRect(x: 0, y: 71, width: self.view.bounds.width, height: self.view.bounds.height - 71)
        
        self.viewFooter.frame = CGRect(x: 0, y: self.view.frame.height - 64 , width: self.view.frame.width, height: 64)
        
        let y = (self.viewFooter!.frame.height - 34.0)/2
        let xShare = (self.viewFooter!.frame.width - 239 - 34 - 16) / 2
        self.shareButton!.frame = CGRect(x: IS_IPAD ? xShare : 16.0, y: y, width: 34.0, height: 34.0)
        
        let toCartBtnWidth = IS_IPAD ? 239 : (self.viewFooter!.frame.width - (self.shareButton!.frame.maxX + 16.0)) - 16.0
        self.addToCartButton!.frame = CGRect(x: self.shareButton!.frame.maxX + 16.0, y: y, width: toCartBtnWidth, height: 34.0)
        
        if isShowingTabBar {
            self.self.viewFooter.frame = CGRect(x: 0, y: self.view.frame.height - 64  - (IS_IPAD ? 0 : 45), width: self.view.frame.width, height: 64)
        }else{
            self.self.viewFooter.frame = CGRect(x: 0, y: self.view.frame.height - 64, width: self.view.frame.width, height: 64)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadPreviousOrderDetail() {
        let servicePrev = PreviousOrderDetailService()
        servicePrev.callService(trackingNumber, successBlock: { (result:[String:Any]) -> Void in
            
            self.itemDetail = result
            self.shippingAll = result["Shipping"] as! NSArray
            
            self.emptyView.isHidden = self.shippingAll.count > 0
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
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 46, width: (IS_IPAD ? 681.5 : self.view.frame.width), height: self.view.frame.height - 46))
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
    
    //MARK:TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.shippingAll.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == (self.shippingAll.count - 1) {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        headerView.backgroundColor = WMColor.light_light_gray
        
        let textOrder = String(format: NSLocalizedString("previousorder.shipping", comment:""), String(section + 1), String(self.shippingAll.count))
        let titleShipping = UILabel(frame:CGRect(x: 16, y: 0, width: self.view.frame.width / 2, height: 40))
        titleShipping.font = WMFont.fontMyriadProRegularOfSize(16)
        titleShipping.textColor = WMColor.dark_gray
        titleShipping.text = self.shippingAll.count == 1 ? "Envío" : textOrder
        headerView.addSubview(titleShipping)
        
        let iconImage = UIImage(color: WMColor.light_blue, size: CGSize(width: 68, height: 22), radius: 10)
        let iconSelected = UIImage(color: WMColor.dark_gray, size: CGSize(width: 68, height: 22), radius: 10)
        
        var showDetailButton: UIButton?
        showDetailButton = UIButton(frame: CGRect(x: self.view.frame.width - 84.0, y: 9.0, width: 68.0, height: 22.0))
        showDetailButton!.setBackgroundImage(iconSelected, for: .selected)
        showDetailButton!.setBackgroundImage(iconImage, for: UIControlState())
        showDetailButton!.setTitle(NSLocalizedString("previousorder.showDetail", comment: ""), for: UIControlState())
        showDetailButton!.layer.cornerRadius = 10.0
        
        showDetailButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        showDetailButton!.titleLabel?.textColor = UIColor.white
        showDetailButton?.tag = section
        showDetailButton!.addTarget(self, action: #selector(OrderShippingViewController.showShippingDetail(_:)), for: .touchUpInside)
        headerView.addSubview(showDetailButton!)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row != self.shippingAll.count {
            if (indexPath as NSIndexPath).section == (self.shippingAll.count - 1) && (indexPath as NSIndexPath).row == 1{
                return 63.0
            } else {
                let cellDetail = tableView.dequeueReusableCell(withIdentifier: "detailOrder") as! PreviousDetailTableViewCell
                var valuesDetail : [String:Any] = [:]
                let shipping = self.shippingAll[(indexPath as NSIndexPath).section] as! [String:Any]
                valuesDetail = ["name":self.itemDetail["name"] as! String, "deliveryType": shipping["deliveryType"] as! String, "deliveryAddress": shipping["deliveryAddress"] as! String, "paymentType": shipping["paymentType"] as! String, "items": shipping["items"] as! NSArray]
                let size = cellDetail.sizeCell(self.view.frame.width, values: valuesDetail, showHeader: true)
                return size
            }
        }
        return 63.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        
       // if indexPath.row != self.shippingAll.count {
            
            if (indexPath as NSIndexPath).section == (self.shippingAll.count - 1) && (indexPath as NSIndexPath).row == 1{
                let totalCell = tableView.dequeueReusableCell(withIdentifier: "totals", for: indexPath) as! ShoppingCartTotalsTableViewCell
                //let total = self.calculateTotalAmount()
                
                var totalValue = ""
                if let total = self.itemDetail["total"] as? String{
                    totalValue = total
                }
                
                var savingValue = ""
                if let saving = self.itemDetail["saving"] as? String{
                    savingValue = saving
                }
                
                totalCell.setValuesTotalSaving(Total: totalValue, saving:savingValue)
                cell = totalCell
            } else {
                let cellDetail = tableOrders.dequeueReusableCell(withIdentifier: "detailOrder") as! PreviousDetailTableViewCell
                cellDetail.frame = CGRect(x: 0, y: 0, width: self.tableOrders.frame.width, height: cellDetail.frame.height)
                
                var valuesDetail : [String:Any] = [:]
                
                let name = self.itemDetail["name"] as! String
                
                let shipping = self.shippingAll[(indexPath as NSIndexPath).section] as! [String:Any]
                let deliveryType = shipping["deliveryType"] as! String
                let deliveryAddress = shipping["deliveryAddress"] as! String
                let paymentType = shipping["paymentType"] as! String
                let itemsShipping = shipping["items"] as! NSArray
                
                valuesDetail = ["name":name, "deliveryType": deliveryType, "deliveryAddress": deliveryAddress, "paymentType": paymentType, "items": itemsShipping]
                cellDetail.setValuesDetail(valuesDetail)
                cellDetail.selectionStyle = .none
                cell = cellDetail
            }
      //  }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func willShowTabbar() {
        isShowingTabBar = true
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.viewFooter.frame = CGRect(x: 0, y: self.view.frame.height - 64  - 45 , width: self.view.frame.width, height: 64)
            self.tableOrders!.contentInset = UIEdgeInsetsMake(0, 0, 109, 0)
            self.tableOrders!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 109, 0)
        })
    }
    
    override func willHideTabbar() {
        isShowingTabBar = false
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.viewFooter.frame = CGRect(x: 0, y: self.view.frame.height - 64  , width: self.view.frame.width, height: 64)
            self.tableOrders!.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
            self.tableOrders!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 64, 0)
        })
    }
    
    func showShippingDetail(_ sender:UIButton){
        let detailController = OrderDetailViewController()
        
        var valuesDetail : [String:Any] = [:]
        
        let name = self.itemDetail["name"] as! String
        let shipping = self.shippingAll[sender.tag] as! [String:Any]
        let deliveryType = shipping["deliveryType"] as! String
        let deliveryAddress = shipping["deliveryAddress"] as! String
        let paymentType = shipping["paymentType"] as! String
        let itemsShipping = shipping["items"] as! NSArray
        
        valuesDetail = ["name":name, "deliveryType": deliveryType, "deliveryAddress": deliveryAddress, "paymentType": paymentType, "items": itemsShipping]
        detailController.shipping = String(format: NSLocalizedString("previousorder.shipping", comment:""), String(sender.tag + 1), String(self.shippingAll.count))
        detailController.detailsOrderGroceries = valuesDetail
        detailController.type = ResultObjectType.Mg //
        detailController.itemDetailProducts = shipping["items"] as! NSArray
        self.navigationController!.pushViewController(detailController, animated: true)
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_SHOW_ORDER_DETAIL.rawValue, label: "")
    }
    
    func addListToCart (){
        
        if self.shippingAll != nil && self.shippingAll.count > 0 {
            var upcs: [Any] = []
            if !showFedexGuide {
                for item in self.shippingAll! {
                    upcs.append(getItemToShoppingCart(item as! [String:Any]) as AnyObject)
                }
            } else {
                for item in self.shippingAll! {
                    let itmProdVal = item["items"] as! [[String:Any]]
                    for itemProd in itmProdVal {
                        upcs.append(getItemToShoppingCart(itemProd as [String:Any]))
                        
                    }
                }
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddItemsToShopingCart.rawValue), object: self, userInfo: ["allitems":upcs, "image": "alert_cart"])
        }
    }
    
    func getItemToShoppingCart(_ item:[String:Any]) ->  [String:Any] {
        
        var params: [String:Any] = [:]
        params["upc"] = item["upc"] as! String as AnyObject?
        params["desc"] = item["description"] as! String as AnyObject?
        
        
        if let images = item["imageUrl"] as? NSArray {
            params["imgUrl"] = images[0] as! String as AnyObject?
        }else
        {
            params["imgUrl"] = item["imageUrl"] as! String as AnyObject?
        }
        if let price = item["price"] as? NSNumber {
            params["price"] = "\(price)" as AnyObject?
        }
        else if let price = item["price"] as? String {
            params["price"] = price as AnyObject?
        }
        
        if let quantity = item["quantity"] as? Int {
            params["quantity"] = "\(quantity)" as AnyObject?
        }else if let quantity = item["quantity"] as? NSNumber {
            params["quantity"] = "\(quantity.intValue)" as AnyObject?
        }
        else if let quantity = item["quantity"] as? NSString {
            params["quantity"] = "\(quantity.integerValue)" as AnyObject?
        }
        
        params["wishlist"] = false as AnyObject?
        params["type"] = type.rawValue as AnyObject?
        params["comments"] = "" as AnyObject?
        if let type = item["type"] as? String {
            if Int(type)! == 0 { //Piezas
                params["onHandInventory"] = "99" as AnyObject?
            }
            else { //Gramos
                params["onHandInventory"] = "20000" as AnyObject?
            }
        }
        return params
    }
    
    func shareList() {
        
        if let imgResult = self.imageToShareWishList() {
            let controller = UIActivityViewController(activityItems: imgResult, applicationActivities: nil)
            
            if IS_IPAD{
                popup = UIPopoverController(contentViewController: controller)
                popup!.present(from: CGRect(x: 65, y: 610, width: 300, height: 250), in: self.view, permittedArrowDirections: UIPopoverArrowDirection.down, animated: true)
            } else {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func imageToShareWishList() -> [Any]? {
        
        var objImages : [Any] = []
        
        for section in 0...shippingAll.count - 1 {
            var ixYSpace : CGFloat = 0
            var unifiedImage : UIImage? = nil
            let shippingSect = self.shippingAll[section] as! [String:Any]
            let itemsShipping = shippingSect["items"] as! NSArray
            
            //imageHead
            let imageHead = UIImage(named:"detail_HeaderMail")
            //imageHead?.drawInRect(CGRectMake(0, 0, imageHead!.size.width, imageHead!.size.height))
            
            //Cell envios
            var valuesDetail : [String:Any] = [:]
            let shipping = itemsShipping[section] as! [String:Any]
            valuesDetail = ["name":self.itemDetail["name"] as! String, "deliveryType": shippingSect["deliveryType"] as! String, "deliveryAddress": shippingSect["deliveryAddress"] as! String, "paymentType": shippingSect["paymentType"] as! String, "items": shipping]
            let cellDetail = tableOrders.dequeueReusableCell(withIdentifier: "detailOrder") as! PreviousDetailTableViewCell
            let sizeCellFirst = cellDetail.sizeCell(self.view.frame.width, values: valuesDetail, showHeader: true)
            
            let heighCel = CGFloat(109 * itemsShipping.count) + 40.0 + sizeCellFirst + imageHead!.size.height
            UIGraphicsBeginImageContextWithOptions(CGSize(width:imageHead!.size.width, height: CGFloat(heighCel)), false, 2.0);
            
            imageHead?.draw(in: CGRect(x: 0, y: 0, width: imageHead!.size.width, height: imageHead!.size.height))
            
            let headerView = UIView(frame:CGRect(x: 0, y: imageHead!.size.height, width: imageHead!.size.width, height: 40))
            headerView.backgroundColor = WMColor.light_light_gray
            
            //header envios
            let textOrder = String(format: NSLocalizedString("previousorder.shipping", comment:""), String(section + 1), String(self.shippingAll.count))
            let titleShipping = UILabel(frame:CGRect(x: 16, y: 0, width: self.view.frame.width / 2, height: 40))
            titleShipping.font = WMFont.fontMyriadProRegularOfSize(16)
            titleShipping.textColor = WMColor.dark_gray
            titleShipping.text = textOrder
            headerView.addSubview(titleShipping)
            headerView.drawHierarchy(in: CGRect(x: 0.0, y: imageHead!.size.height, width: imageHead!.size.width, height: 40.0), afterScreenUpdates: true)
            if IS_IPAD{
                headerView.drawHierarchy(in: CGRect(x: 0.0, y: imageHead!.size.height, width: imageHead!.size.width, height: 40.0), afterScreenUpdates: true)
            }
            //ixYSpace = ixYSpace + 40.0
            
            cellDetail.frame = CGRect(x: 0, y: 0, width: imageHead!.size.width, height: sizeCellFirst)
            loadShippingViewCellCollection(cellDetail,indexPath:IndexPath(row: 0, section: section))
            cellDetail.drawHierarchy(in: CGRect(x: 0.0, y: (40.0 + imageHead!.size.height),width: imageHead!.size.width, height: sizeCellFirst), afterScreenUpdates: true)
            
            ixYSpace = 40 + sizeCellFirst + imageHead!.size.height
            
            for ixItem  in 0...itemsShipping.count - 1 {
                //Cell items
                tableOrders.register(OrderProductTableViewCell.self, forCellReuseIdentifier: "orderCell")
                let cellItems = tableOrders.dequeueReusableCell(withIdentifier: "orderCell") as! OrderProductTableViewCell
                cellItems.frame = CGRect(x: 0, y: 0, width: imageHead!.size.width, height: 109)
                loadItemsViewCellCollection(cellItems, indexPath: IndexPath(row: ixItem, section: section))
                cellItems.drawHierarchy(in: CGRect(x: 0.0, y: ixYSpace,width: imageHead!.size.width, height: 109), afterScreenUpdates: true)

                ixYSpace = ixYSpace + 109
            }
            
            unifiedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            objImages.append(unifiedImage!)
        }
        
        return objImages
    }
    
    func loadShippingViewCellCollection(_ shippingCell:PreviousDetailTableViewCell,indexPath:IndexPath) {
        shippingCell.frame = CGRect(x: 0, y: 0, width: self.tableOrders.frame.width, height: shippingCell.frame.height)
        
        var valuesDetail : [String:Any] = [:]
        
        let name = self.itemDetail["name"] as! String
        
        let shipping = self.shippingAll[(indexPath as NSIndexPath).section] as! [String:Any]
        let deliveryType = shipping["deliveryType"] as! String
        let deliveryAddress = shipping["deliveryAddress"] as! String
        let paymentType = shipping["paymentType"] as! String
        let itemsShipping = shipping["items"] as! NSArray
        
        valuesDetail = ["name":name, "deliveryType": deliveryType, "deliveryAddress": deliveryAddress, "paymentType": paymentType, "items": itemsShipping]
        shippingCell.setValuesDetail(valuesDetail)
    }
    
    func loadItemsViewCellCollection(_ productCell:OrderProductTableViewCell,indexPath:IndexPath) {
        productCell.frame = CGRect(x: 0, y: 0, width: self.tableOrders.frame.width, height: 109)
        
        productCell.type = self.type
        let dictSect = self.shippingAll[(indexPath as NSIndexPath).section] as! [String:Any]
        let items = dictSect["items"] as! NSArray
        
        let dictProduct = items[(indexPath as NSIndexPath).row] as! [String:Any]
        let itemShow = OrderDetailViewController.prepareValuesItems(dictProduct)
        let valuesItems = itemShow[0] as [String:Any]
        //valuesItems["skuid"] as! String
        let pesableValue = valuesItems["pesable"] as! String == "true" ? true : false
        let isActiveValue = valuesItems["isActive"] as! String == "true" ? true : false
        
        productCell.setValues("", upc:valuesItems["upc"] as! String, productImageURL:valuesItems["imageUrl"] as! String,productShortDescription:valuesItems["description"] as! String, productPrice:valuesItems["price"] as! String,quantity:valuesItems["quantity"] as! NSString, type: self.type, pesable:pesableValue, onHandInventory: valuesItems["onHandDefault"] as! String, isActive:isActiveValue, isPreorderable:valuesItems["isPreorderable"] as! String)
    }
    
    override func back() {
        super.back()
    }
    
}
