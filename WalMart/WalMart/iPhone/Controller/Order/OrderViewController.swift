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
        
        viewLoad = WMLoadingView(frame:CGRect.zero)
        
        self.view.backgroundColor = UIColor.white
        self.titleLabel!.text = NSLocalizedString("profile.myOrders", comment: "")

        tableOrders = UITableView()
        tableOrders.dataSource = self
        tableOrders.delegate = self
        
        tableOrders.register(PreviousOrdersTableViewCell.self, forCellReuseIdentifier: "prevousOrder")
        
        tableOrders.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.view.addSubview(tableOrders)
        
        emptyView = IPOOrderEmptyView(frame: CGRect.zero)
        emptyView.returnAction = {() in
            self.back()
        }
        self.view.addSubview(emptyView)
        tabFooterView()
        self.reloadPreviousOrders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isShowingTabBar = !TabBarHidden.isTabBarHidden
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.emptyView!.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
        self.tableOrders.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
        //self.facturasToolBar.frame = CGRectMake(0, self.view.frame.height - 64 , self.view.frame.width, 64)
        if isShowingTabBar {
            self.facturasToolBar.frame = CGRect(x: 0, y: self.view.frame.height - 109 , width: self.view.frame.width, height: 64)
        }else{
            //self.facturasToolBar.frame = CGRectMake(0, self.view.frame.height - 64, self.view.frame.width, 64)
        }
        
        if isShowingButtonFactura {
           self.buttonFactura.frame = CGRect(x: 16, y: 14, width: facturasToolBar.frame.width - 32, height: 34)
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableOrders.dequeueReusableCell(withIdentifier: "prevousOrder") as! PreviousOrdersTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if !((indexPath as NSIndexPath).row > self.items.count) && self.items.count > 0 {
            let item = self.items[(indexPath as NSIndexPath).row] as! NSDictionary
            let dateStr = item["placedDate"] as! String
            let trackingStr = item["trackingNumber"] as! String
            var statusStr = item["status"] as! String
            if (item["type"] as! String) == ResultObjectType.Groceries.rawValue {
                statusStr = NSLocalizedString("gr.order.status.\(statusStr)", comment: "")
            }
            let countItems = item["countItems"] as! NSNumber
            cell.setValues(dateStr, trackingNumber: trackingStr, status: statusStr, countsItem: String(countItems))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[(indexPath as NSIndexPath).row] as! NSDictionary
        let detailController = OrderShippingViewController()
        
        //let dateStr = item["placedDate"] as! String
        //let statusDesc = NSLocalizedString("gr.order.status.\(statusStr)", comment: "")
        //detailController.date = dateStr
        //detailController.detailsOrderGroceries = item
        
        let trackingStr = item["trackingNumber"] as! String
        let statusStr = item["status"] as! String
        detailController.trackingNumber = trackingStr
        detailController.status = statusStr
        detailController.type = ResultObjectType.Groceries
        self.navigationController!.pushViewController(detailController, animated: true)
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_SHOW_ORDER_DETAIL.rawValue, label: "")
    }
    
    func reloadPreviousOrders() {
        self.items = []
        self.emptyView.frame = CGRect(x: 0, y: 46, width: self.view.frame.width, height: self.view.frame.height - 46)
        self.viewLoad.frame = CGRect(x: 0, y: 46, width: self.view.frame.width, height: self.view.frame.height - 46)
        //self.tableOrders.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 155)
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
        }
        viewLoad.backgroundColor = UIColor.white
        self.view.addSubview(viewLoad)
        viewLoad.startAnnimating(self.isVisibleTab)
        
        let servicePrev = PreviousOrdersService()
        servicePrev.callService({ (previous:NSArray) -> Void in
            for orderPrev in previous {
                let dictMGOrder = NSMutableDictionary(dictionary: orderPrev as! NSDictionary)
                dictMGOrder["type"] =  ""
                self.items.append(dictMGOrder)
            }
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "dd/MM/yyyy"
            self.items.sort(by: {
                let firstDate = $0["placedDate"] as! String
                let secondDate = $1["placedDate"] as! String
                let dateOne = dateFormat.date(from: firstDate)!
                let dateTwo = dateFormat.date(from: secondDate)!
                return dateOne.compare(dateTwo) == ComparisonResult.orderedDescending
            })
            
            self.emptyView.isHidden = self.items.count > 0
            self.facturasToolBar.isHidden = !(self.items.count > 0)
            if self.items.count > 0 {
                self.facturasToolBar.backgroundColor = UIColor.white
            }
            self.tableOrders.reloadData()
            self.viewLoad.stopAnnimating()
            }, errorBlock: { (error:NSError) -> Void in
                self.viewLoad.stopAnnimating()
                self.tableOrders.reloadData()
                self.emptyView.isHidden = self.items.count > 0
                self.facturasToolBar.isHidden = !(self.items.count > 0)
                if self.items.count > 0 {
                    self.facturasToolBar.backgroundColor = UIColor.white
                }
            
            //}, errorBlock: { (error:NSError) -> Void in
                //self.loadGROrders()
        })
    }

    
    /*func loadGROrders() {
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
    }*/
    
    
       func tabFooterView() {
        facturasToolBar = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 64 , width: self.view.bounds.width, height: 64))
        //facturasToolBar.backgroundColor = UIColor.whiteColor()
        facturasToolBar.backgroundColor = UIColor.clear
        
        self.buttonFactura = UIButton(frame: CGRect(x: 16, y: 14, width: facturasToolBar.frame.width - 32, height: 34))
        self.buttonFactura.backgroundColor = WMColor.light_blue
        self.buttonFactura.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.buttonFactura.layer.cornerRadius = 17
        self.buttonFactura.addTarget(self, action: #selector(OrderViewController.showWebView), for: UIControlEvents.touchUpInside)
        self.buttonFactura.setTitle("Facturación electrónica",for:UIControlState())
        
        facturasToolBar.addSubview(self.buttonFactura)
        //self.view.addSubview(facturasToolBar)
        isShowingButtonFactura = true
    }
    
    func showWebView() {
        let webCtrl = IPOWebViewController()
        webCtrl.openURLFactura()
        self.present(webCtrl,animated:true,completion:nil)
    }
    
    override func willShowTabbar() {
        isShowingTabBar = true
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.facturasToolBar.frame = CGRect(x: 0, y: self.view.frame.height - 110 , width: self.view.frame.width, height: 64)
            self.tableOrders!.frame = CGRect(x: 0, y: 46 , width: self.view.frame.width, height: self.view.frame.height - 109)
        })
    }
    
    override func willHideTabbar() {
        isShowingTabBar = false
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.facturasToolBar.frame = CGRect(x: 0, y: self.view.frame.height - 64  , width: self.view.frame.width, height: 64)
            self.tableOrders!.frame = CGRect(x: 0, y: 46 , width: self.view.frame.width, height: self.view.frame.height - 64)
        })
    }
    
    override func back() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
        super.back()
    }
    
}
