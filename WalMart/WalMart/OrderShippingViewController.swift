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
    
    var tableOrders : UITableView!
    var viewLoad : WMLoadingView!
    var emptyView : IPOOrderEmptyView!
    var isShowingTabBar : Bool = true
    var isShowingButtonFactura : Bool = false
    
    var barView: UIView?
    var repeatBuyButton: UIButton?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREVIOUSORDERS.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewLoad = WMLoadingView(frame:CGRectZero)
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.titleLabel!.text = trackingNumber
        
        tableOrders = UITableView()
        tableOrders.dataSource = self
        tableOrders.delegate = self
        
        tableOrders.registerClass(PreviousDetailTableViewCell.self, forCellReuseIdentifier: "detailOrder")
        tableOrders.registerClass(OrderShippingTotalTableViewCell.self, forCellReuseIdentifier: "totals")
        
        //Celda Envio
        //Celda Total
        
        tableOrders.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.view.addSubview(tableOrders)
        
        emptyView = IPOOrderEmptyView(frame: CGRectZero)
        emptyView.returnAction = {() in
            self.back()
        }
        self.view.addSubview(emptyView)
        
        self.barView = UIView()
        self.barView!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.barView!)
        
        self.repeatBuyButton = UIButton(type: . Custom)
        self.repeatBuyButton!.frame = CGRectMake(45.0, 12.0, 240.0, 35)
        self.repeatBuyButton!.backgroundColor = WMColor.green
        self.repeatBuyButton!.setTitle("Repetir Compra", forState: .Normal)
        self.repeatBuyButton?.titleLabel!.textColor = UIColor.whiteColor()
        //self.repeatBuyButton!.addTarget(self, action: #selector(ShoppingCartViewController.buy), forControlEvents: .TouchUpInside)
        self.repeatBuyButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.repeatBuyButton!.layer.cornerRadius = 15
        self.barView!.addSubview(self.repeatBuyButton!)
        
        showLoadingView()
        reloadPreviousOrderDetail()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        isShowingTabBar = !TabBarHidden.isTabBarHidden
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.emptyView!.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46 - 64)
        self.tableOrders.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46 - 64)
        
        self.barView!.frame = CGRectMake(0.0, self.view.bounds.height - 64, self.view.bounds.width, 64)
        self.repeatBuyButton!.frame = CGRectMake(self.barView!.frame.width - 256, 12.0, 240.0, 35)
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
            return 230.0
        } else {
            return 63.0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRectMake(0.0, 0.0, self.view.frame.width, 24.0))
        let backColor = PreviousOrdersTableViewCell.setColorStatus(status)
        headerView.backgroundColor = backColor
        let titleLabel = UILabel(frame: CGRectMake(0.0, 0.0, self.view.frame.width, 24.0))
        
        titleLabel.text = status //trackingNumber
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        
        if indexPath.row != self.shippingAll.count {
            let cellDetail = tableOrders.dequeueReusableCellWithIdentifier("detailOrder") as! PreviousDetailTableViewCell
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
            //cellDetail.setValues(self.detailsOrder)
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
    
    func showShippingDetail(shippingDetail: NSDictionary){
        let detailController = OrderDetailViewController()
        
        //let dateStr = item["placedDate"] as! String
        //let trackingStr = shippingDetail["trackingNumber"] as! String
        //let statusStr = shippingDetail["status"] as! String
        
        detailController.trackingNumber = self.trackingNumber
        //let statusDesc = NSLocalizedString("gr.order.status.\(statusStr)", comment: "")
        detailController.status = self.status
        //detailController.date = dateStr
        detailController.detailsOrderGroceries = shippingDetail
        detailController.itemDetailProducts = shippingDetail["items"] as! NSArray
        self.navigationController!.pushViewController(detailController, animated: true)
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_SHOW_ORDER_DETAIL.rawValue, label: "")
    }
    
    override func back() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
        super.back()
    }
    
}
