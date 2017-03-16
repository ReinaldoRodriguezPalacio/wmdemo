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
    var items : [[String:Any]] = []
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
        
        self.emptyView = IPOOrderEmptyView(frame: CGRect.zero)
        self.emptyView.returnAction = {() in
            self.back()
        }
        self.view.addSubview(self.emptyView)
        tabFooterView()
        self.reloadPreviousOrders()
        BaseController.setOpenScreenTagManager(titleScreen:  NSLocalizedString("profile.myOrders", comment: ""), screenName: self.getScreenGAIName())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isShowingTabBar = !TabBarHidden.isTabBarHidden
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var heightEmptyView = self.view.bounds.height
        var widthEmptyView = self.view.bounds.width
        let model =  UIDevice.current.modelName
        
        if !model.contains("Plus") && !model.contains("4") && !model.contains("5") {
            heightEmptyView -= 46
        }
        if IS_IPHONE_6P {
            heightEmptyView -= 14
        }
        if IS_IPAD || model.contains("iPad") {
            widthEmptyView = 681.5
        }
        
        self.emptyView!.frame = CGRect(x: 0, y: 46, width: widthEmptyView, height: heightEmptyView)
        if model.contains("5") || model.contains("4") {
            self.emptyView!.paddingBottomReturnButton += 24
        } else if IS_IPAD || model.contains("iPad") {
            self.emptyView!.showReturnButton = false
        }
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableOrders.dequeueReusableCell(withIdentifier: "prevousOrder") as! PreviousOrdersTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if !(indexPath.row > self.items.count) && self.items.count > 0 {
            let item = self.items[indexPath.row] 
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row] 
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
            
            ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_SHOW_ORDER_DETAIL.rawValue, label: "")
            
            
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
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_SHOW_ORDER_DETAIL.rawValue, label: "")
        }
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
        servicePrev.callService({ (previous:[Any]) -> Void in
            for orderPrev in previous {
                var dictMGOrder = orderPrev as! [String:Any]
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
        servicePrev.callService({ (previous:[Any]) -> Void in
            for orderPrev in previous {
                var dictGROrder = orderPrev as! [String:Any]
                dictGROrder["type"] =  ResultObjectType.Groceries.rawValue
                self.items.append(dictGROrder)
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
        })
    }
    
    
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
    
       
    
    
    override func back() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
        super.back()
    }
    
    override func swipeHandler(swipe: UISwipeGestureRecognizer) {
        self.back()
    }
    
}
