//
//  OrderShippingViewController.swift
//  WalMart
//
//  Created by Daniel V on 26/08/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

class OrderShippingViewController: NavigationViewController, ProductDetailCharacteristicsTableViewCellDelegate, UITableViewDataSource,UITableViewDelegate {
    
    var trackingNumber = ""
    var status = ""
    var colorHeader = WMColor.yellow
    var itemDetail : NSDictionary! = [:]
    var shippingAll : NSArray! = []
    var itemDetailProducts : NSArray!
    var detailsOrder : [AnyObject]!
    
    var type : ResultObjectType!
    var showFedexGuide : Bool = true
    
    var tableOrders : UITableView!
    var viewLoad : WMLoadingView!
    var emptyView : IPOOrderEmptyView!
    var isShowingTabBar : Bool = true
    var isShowingButtonFactura : Bool = false
    
    var viewStatus : UIView!
    
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
        
        self.viewStatus = UIView(frame: CGRectMake(0.0, 46.0, self.view.frame.width, 24.0))
        let backColor = PreviousOrdersTableViewCell.setColorStatus(status)
        self.viewStatus.backgroundColor = backColor
        let titleLabel = UILabel(frame: CGRectMake(0.0, 0.0, self.view.frame.width, 24.0))
        
        titleLabel.text = status //trackingNumber
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.viewStatus.addSubview(titleLabel)
        
        self.viewFooter = UIView(frame:CGRectMake(0, self.view.bounds.maxY - 72, self.view.bounds.width, 46))
        
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
        
        self.shareButton = UIButton(frame: CGRectMake(16.0, y, 34.0, 34.0))
        self.shareButton!.setImage(UIImage(named: "detail_shareOff"), forState: .Normal)
        self.shareButton!.setImage(UIImage(named: "detail_share"), forState: .Selected)
        self.shareButton!.setImage(UIImage(named: "detail_share"), forState: .Highlighted)
        self.shareButton!.addTarget(self, action: #selector(OrderShippingViewController.shareList), forControlEvents: .TouchUpInside)
        self.viewFooter!.addSubview(self.shareButton!)
        
        let x = self.shareButton!.frame.maxX + 16.0
        
        self.addToCartButton = UIButton(frame: CGRectMake(x, y, (self.viewFooter!.frame.width - (x + 16.0)) - 32, 34.0))
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
        self.emptyView!.frame = CGRectMake(0, 71, self.view.bounds.width, self.view.bounds.height - 71)
        self.tableOrders.frame = CGRectMake(0, 71, self.view.bounds.width, self.view.bounds.height - 71)
        
        self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64 , self.view.frame.width, 64)
        
        let y = (self.viewFooter!.frame.height - 34.0)/2
        self.shareButton!.frame = CGRectMake(16.0, y, 34.0, 34.0)
        
        self.addToCartButton!.frame = CGRectMake(self.shareButton!.frame.maxX + 16.0, y, (self.viewFooter!.frame.width - (self.shareButton!.frame.maxX + 16.0)) - 16.0, 34.0)
        
        if isShowingTabBar {
            self.self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64  - 45 , self.view.frame.width, 64)
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.shippingAll.count + 1)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row != self.shippingAll.count {
            let cellDetail = tableView.dequeueReusableCellWithIdentifier("detailOrder") as! PreviousDetailTableViewCell
            var valuesDetail : NSDictionary = [:]
            let shipping = self.shippingAll[indexPath.row] as! NSDictionary
            valuesDetail = ["order": "", "name":self.itemDetail["name"] as! String, "deliveryType": shipping["deliveryType"] as! String, "deliveryAddress": shipping["deliveryAddress"] as! String, "paymentType": shipping["paymentType"] as! String, "items": shipping["items"] as! NSArray]
            let size = cellDetail.sizeCell(self.view.frame.width, values: valuesDetail, showHeader: true)
            return size
        } else {
            return 63.0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        
        if indexPath.row != self.shippingAll.count {
            let cellDetail = tableOrders.dequeueReusableCellWithIdentifier("detailOrder") as! PreviousDetailTableViewCell
            cellDetail.isHeaderView = true
            cellDetail.frame = CGRectMake(0, 0, self.tableOrders.frame.width, cellDetail.frame.height)
            
            var valuesDetail : NSDictionary = [:]
            let textOrder = "Envio \((indexPath.row + 1)) de \(self.shippingAll.count)"
            
            let name = self.itemDetail["name"] as! String
            
            let shipping = self.shippingAll[indexPath.row] as! NSDictionary
            let deliveryType = shipping["deliveryType"] as! String
            let deliveryAddress = shipping["deliveryAddress"] as! String
            let paymentType = shipping["paymentType"] as! String
            let itemsShipping = shipping["items"] as! NSArray
            
            
            valuesDetail = ["order": textOrder, "name":name, "deliveryType": deliveryType, "deliveryAddress": deliveryAddress, "paymentType": paymentType, "items": itemsShipping]
            cellDetail.setValuesDetail(valuesDetail)
            cellDetail.selectionStyle = .None
            cellDetail.delegateDetail = self
            cell = cellDetail
        } else {
            
            let totalCell = tableView.dequeueReusableCellWithIdentifier("totals", forIndexPath: indexPath) as! OrderShippingTotalTableViewCell
            //let total = self.calculateTotalAmount()
            totalCell.setValues("790", totalSaving: "50")
            totalCell.selectionStyle = .None
            cell = totalCell
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
    
    func showShippingDetail(shippingDetail: NSDictionary){
        let detailController = OrderDetailViewController()
        
        detailController.shipping = shippingDetail["order"] as! String
        //detailController.status = self.status
        detailController.detailsOrderGroceries = shippingDetail
        detailController.type = ResultObjectType.Mg //
        detailController.itemDetailProducts = shippingDetail["items"] as! NSArray
        self.navigationController!.pushViewController(detailController, animated: true)
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_SHOW_ORDER_DETAIL.rawValue, label: "")
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
        
    }
    
    override func back() {
        super.back()
    }
    
}
