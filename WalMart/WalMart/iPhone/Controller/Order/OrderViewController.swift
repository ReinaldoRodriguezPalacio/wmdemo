//
//  OrderViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 19/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class OrderViewController: NavigationViewController,UITableViewDataSource,UITableViewDelegate {
    
    var tableOrders : UITableView!
    var items : [AnyObject] = []
    var viewLoad : WMLoadingView!
    var emptyView : IPOOrderEmptyView!
    var facturasToolBar : UIView!
    var buttonFactura : UIButton!
    var isShowingTabBar : Bool = true
    var isShowingButtonFactura : Bool = false
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREVIOUSORDERS.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewLoad = WMLoadingView(frame:CGRectZero)
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.titleLabel!.text = NSLocalizedString("profile.myOrders", comment: "")

        tableOrders = UITableView()
        tableOrders.dataSource = self
        tableOrders.delegate = self
        
        tableOrders.registerClass(PreviousOrdersTableViewCell.self, forCellReuseIdentifier: "prevousOrder")
        
        tableOrders.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.view.addSubview(tableOrders)
        
        emptyView = IPOOrderEmptyView(frame: CGRectZero)
        emptyView.returnAction = {() in
            self.back()
        }
        self.view.addSubview(emptyView)
        tabFooterView()
        self.reloadPreviousOrders()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        isShowingTabBar = !TabBarHidden.isTabBarHidden
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.emptyView!.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        self.tableOrders.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        //self.facturasToolBar.frame = CGRectMake(0, self.view.frame.height - 64 , self.view.frame.width, 64)
        if isShowingTabBar {
            self.facturasToolBar.frame = CGRectMake(0, self.view.frame.height - 109 , self.view.frame.width, 64)
        }else{
            //self.facturasToolBar.frame = CGRectMake(0, self.view.frame.height - 64, self.view.frame.width, 64)
        }
        
        if isShowingButtonFactura {
           self.buttonFactura.frame = CGRectMake(16, 14, facturasToolBar.frame.width - 32, 34)
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableOrders.dequeueReusableCellWithIdentifier("prevousOrder") as! PreviousOrdersTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        if !(indexPath.row > self.items.count) && self.items.count > 0 {
            let item = self.items[indexPath.row] as! NSDictionary
            let dateStr = item["placedDate"] as! String
            let trackingStr = item["trackingNumber"] as! String
            var statusStr = item["status"] as! String
            if (item["type"] as! String) == ResultObjectType.Groceries.rawValue {
                statusStr = NSLocalizedString("gr.order.status.\(statusStr)", comment: "")
            }
            cell.setValues(dateStr, trackingNumber: trackingStr, status: statusStr)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.items[indexPath.row] as! NSDictionary
        let detailController = OrderDetailViewController()
        
        if (item["type"] as! String) == ResultObjectType.Mg.rawValue {
            detailController.type = ResultObjectType.Mg
            let dateStr = item["placedDate"] as! String
            let trackingStr = item["trackingNumber"] as! String
            let statusStr = item["status"] as! String
            
            

            detailController.trackingNumber = trackingStr
            detailController.status = statusStr
            detailController.date = dateStr
            self.navigationController!.pushViewController(detailController, animated: true)
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_SHOW_ORDER_DETAIL.rawValue, label: "")
            
            
        } else {
            detailController.type = ResultObjectType.Groceries
            let dateStr = item["placedDate"] as! String
            let trackingStr = item["trackingNumber"] as! String
            let statusStr = item["status"] as! String
            

            
            let statusDesc = NSLocalizedString("gr.order.status.\(statusStr)", comment: "")
            
            detailController.trackingNumber = trackingStr
            detailController.status = statusDesc
            detailController.date = dateStr
            detailController.detailsOrderGroceries = item
            self.navigationController!.pushViewController(detailController, animated: true)
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_SHOW_ORDER_DETAIL.rawValue, label: "")
        }
    }
    
    
    func reloadPreviousOrders() {
        self.items = []
        self.emptyView.frame = CGRectMake(0, 46, self.view.frame.width, self.view.frame.height - 46)
        self.viewLoad.frame = CGRectMake(0, 46, self.view.frame.width, self.view.frame.height - 46)
        //self.tableOrders.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 155)
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
        }
        viewLoad.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(viewLoad)
        viewLoad.startAnnimating(self.isVisibleTab)
        
        let servicePrev = PreviousOrdersService()
        servicePrev.callService({ (previous:NSArray) -> Void in
            for orderPrev in previous {
                let dictMGOrder = NSMutableDictionary(dictionary: orderPrev as! NSDictionary)
                dictMGOrder["type"] =  ResultObjectType.Mg.rawValue
                self.items.append(dictMGOrder)
            }
            self.loadGROrders()
            }, errorBlock: { (error:NSError) -> Void in
                self.loadGROrders()
        })
    }

    
    func loadGROrders() {
        let servicePrev = GRPreviousOrdersService()
        servicePrev.callService({ (previous:NSArray) -> Void in
            for orderPrev in previous {
                let dictGROrder = NSMutableDictionary(dictionary: orderPrev as! NSDictionary)
                dictGROrder["type"] =  ResultObjectType.Groceries.rawValue
                self.items.append(dictGROrder)
            }
            
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "dd/MM/yyyy"
            self.items.sortInPlace({
                let firstDate = $0["placedDate"] as! String
                let secondDate = $1["placedDate"] as! String
                let dateOne = dateFormat.dateFromString(firstDate)!
                let dateTwo = dateFormat.dateFromString(secondDate)!
                return dateOne.compare(dateTwo) == NSComparisonResult.OrderedDescending
            })
            
            
            self.emptyView.hidden = self.items.count > 0
            self.facturasToolBar.hidden = !(self.items.count > 0)
            if self.items.count > 0 {
                self.facturasToolBar.backgroundColor = UIColor.whiteColor()
            }
            self.tableOrders.reloadData()
            self.viewLoad.stopAnnimating()
            }, errorBlock: { (error:NSError) -> Void in
                self.viewLoad.stopAnnimating()
                self.tableOrders.reloadData()
                self.emptyView.hidden = self.items.count > 0
                self.facturasToolBar.hidden = !(self.items.count > 0)
                if self.items.count > 0 {
                    self.facturasToolBar.backgroundColor = UIColor.whiteColor()
                }
        })
    }
    
    
       func tabFooterView() {
        facturasToolBar = UIView(frame: CGRectMake(0, self.view.frame.height - 64 , self.view.bounds.width, 64))
        //facturasToolBar.backgroundColor = UIColor.whiteColor()
        facturasToolBar.backgroundColor = UIColor.clearColor()
        
        self.buttonFactura = UIButton(frame: CGRectMake(16, 14, facturasToolBar.frame.width - 32, 34))
        self.buttonFactura.backgroundColor = WMColor.light_blue
        self.buttonFactura.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.buttonFactura.layer.cornerRadius = 17
        self.buttonFactura.addTarget(self, action: #selector(OrderViewController.showWebView), forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonFactura.setTitle("Facturación electrónica",forState:UIControlState.Normal)
        
        facturasToolBar.addSubview(self.buttonFactura)
        //self.view.addSubview(facturasToolBar)
        isShowingButtonFactura = true
    }
    
    func showWebView() {
        let webCtrl = IPOWebViewController()
        webCtrl.openURLFactura()
        self.presentViewController(webCtrl,animated:true,completion:nil)
    }
    
    override func willShowTabbar() {
        isShowingTabBar = true
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.facturasToolBar.frame = CGRectMake(0, self.view.frame.height - 110 , self.view.frame.width, 64)
            self.tableOrders!.frame = CGRectMake(0, 46 , self.view.frame.width, self.view.frame.height - 109)
        })
    }
    
    override func willHideTabbar() {
        isShowingTabBar = false
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.facturasToolBar.frame = CGRectMake(0, self.view.frame.height - 64  , self.view.frame.width, 64)
            self.tableOrders!.frame = CGRectMake(0, 46 , self.view.frame.width, self.view.frame.height - 64)
        })
    }
    
    
    
    override func back() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
        super.back()
    }
    
}
