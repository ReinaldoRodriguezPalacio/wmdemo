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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadPreviousOrders", name: ProfileNotification.updateProfile.rawValue, object: nil)
        
        //Event recent purch
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_RECENTPURCHASES.rawValue,
                action:WMGAIUtils.EVENT_PROFILE_RECENTPURCHASES.rawValue,
                label: nil,
                value: nil).build())
        }
        
        
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
        
        self.tableOrders!.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
        self.tableOrders!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 64, 0)

        tabFooterView()


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
            self.facturasToolBar.frame = CGRectMake(0, self.view.frame.height - 64  - 45 , self.view.frame.width, 64)
        }else{
            self.facturasToolBar.frame = CGRectMake(0, self.view.frame.height - 64, self.view.frame.width, 64)
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
        let cell = tableOrders.dequeueReusableCellWithIdentifier("prevousOrder") as PreviousOrdersTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        let item = self.items[indexPath.row] as NSDictionary
        let dateStr = item["placedDate"] as NSString
        let trackingStr = item["trackingNumber"] as NSString
        var statusStr = item["status"] as NSString
        if (item["type"] as String) == ResultObjectType.Groceries.rawValue {
            statusStr = NSLocalizedString("gr.order.status.\(statusStr)", comment: "")
        }
        
        cell.setValues(dateStr, trackingNumber: trackingStr, status: statusStr)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.items[indexPath.row] as NSDictionary
        let detailController = OrderDetailViewController()
        
        if (item["type"] as String) == ResultObjectType.Mg.rawValue {
            detailController.type = ResultObjectType.Mg
            let dateStr = item["placedDate"] as NSString
            let trackingStr = item["trackingNumber"] as NSString
            let statusStr = item["status"] as NSString
            
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_RECENTPURCHASES.rawValue,
                    action:WMGAIUtils.EVENT_PROFILE_RECENTPURCHASES_DETAIL.rawValue,
                    label: trackingStr,
                    value: nil).build())
            }
            
            detailController.trackingNumber = trackingStr
            detailController.status = statusStr
            detailController.date = dateStr
            self.navigationController!.pushViewController(detailController, animated: true)
        } else {
            detailController.type = ResultObjectType.Groceries
            let dateStr = item["placedDate"] as NSString
            let trackingStr = item["trackingNumber"] as NSString
            let statusStr = item["status"] as NSString
            
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_RECENTPURCHASES.rawValue,
                    action:WMGAIUtils.EVENT_PROFILE_RECENTPURCHASES_DETAIL.rawValue,
                    label: trackingStr,
                    value: nil).build())
            }
            
            let statusDesc = NSLocalizedString("gr.order.status.\(statusStr)", comment: "")
            
            detailController.trackingNumber = trackingStr
            detailController.status = statusDesc
            detailController.date = dateStr
            detailController.detailsOrderGroceries = item
            self.navigationController!.pushViewController(detailController, animated: true)
            
        }
    }
    
    
    func reloadPreviousOrders() {
        self.items = []
        self.emptyView.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        self.viewLoad.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        self.tableOrders.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        viewLoad = WMLoadingView(frame: self.view.bounds)
        viewLoad.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(viewLoad)
        viewLoad.startAnnimating(self.isVisibleTab)
        
        let servicePrev = PreviousOrdersService()
        servicePrev.callService({ (previous:NSArray) -> Void in
            for orderPrev in previous {
                var dictMGOrder = NSMutableDictionary(dictionary: orderPrev as NSDictionary)
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
                var dictGROrder = NSMutableDictionary(dictionary: orderPrev as NSDictionary)
                dictGROrder["type"] =  ResultObjectType.Groceries.rawValue
                self.items.append(dictGROrder)
            }
            self.emptyView.hidden = self.items.count > 0
            if self.items.count > 0 {
                self.facturasToolBar.backgroundColor = WMColor.UIColorFromRGB(0xFFFFFF,alpha:0.9)
            }
            self.tableOrders.reloadData()
            self.viewLoad.stopAnnimating()
            }, errorBlock: { (error:NSError) -> Void in
                self.viewLoad.stopAnnimating()
                self.tableOrders.reloadData()
                self.emptyView.hidden = self.items.count > 0
                if self.items.count > 0 {
                    self.facturasToolBar.backgroundColor = WMColor.UIColorFromRGB(0xFFFFFF,alpha:0.9)
                }
        })
    }
    
    
    func tabFooterView() {
        facturasToolBar = UIView(frame: CGRectMake(0, self.view.frame.height - 64 , self.view.bounds.width, 64))
        //facturasToolBar.backgroundColor = WMColor.UIColorFromRGB(0xFFFFFF,alpha:0.9)
        facturasToolBar.backgroundColor = UIColor.clearColor()
        
        self.buttonFactura = UIButton(frame: CGRectMake(16, 14, facturasToolBar.frame.width - 32, 34))
        self.buttonFactura.backgroundColor = WMColor.loginProfileSaveBGColor
        self.buttonFactura.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.buttonFactura.layer.cornerRadius = 17
        self.buttonFactura.addTarget(self, action: "showWebView", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonFactura.setTitle("Facturación electrónica",forState:UIControlState.Normal)
        
        facturasToolBar.addSubview(self.buttonFactura)
        self.view.addSubview(facturasToolBar)
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
            self.facturasToolBar.frame = CGRectMake(0, self.view.frame.height - 64  - 45 , self.view.frame.width, 64)
            self.tableOrders!.contentInset = UIEdgeInsetsMake(0, 0, 109, 0)
            self.tableOrders!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 109, 0)
        })
    }
    
    override func willHideTabbar() {
        isShowingTabBar = false
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.facturasToolBar.frame = CGRectMake(0, self.view.frame.height - 64  , self.view.frame.width, 64)
            self.tableOrders!.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
            self.tableOrders!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 64, 0)
        })
    }
    
}
