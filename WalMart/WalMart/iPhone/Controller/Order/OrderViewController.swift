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
    var viewBgSelectorBtn : UIView!
    var btnSuper : UIButton!
    var btnTech : UIButton!
    var arrayGROrders : [[String:Any]]! = []
    var arrayMGOrders : [[String:Any]]! = []
    
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
        
        self.arrayGROrders = [[String:Any]]()
        self.arrayMGOrders = [[String:Any]]()

        
        self.emptyView = IPOOrderEmptyView(frame: CGRect.zero)
        self.emptyView.returnAction = {() in
            self.back()
        }
        self.view.addSubview(self.emptyView)
        tabFooterView()
        self.reloadPreviousOrders()
        BaseController.setOpenScreenTagManager(titleScreen:  NSLocalizedString("profile.myOrders", comment: ""), screenName: self.getScreenGAIName())
        
        viewBgSelectorBtn = UIView(frame: CGRect(x: 16,  y: self.header!.frame.maxY + 16, width: 282, height: 28))
        viewBgSelectorBtn.layer.borderWidth = 1
        viewBgSelectorBtn.layer.cornerRadius = 14
        viewBgSelectorBtn.layer.borderColor = WMColor.light_blue.cgColor
        
        let titleSupper = NSLocalizedString("profile.address.super",comment:"")
        btnSuper = UIButton(frame: CGRect(x: 1, y: 1, width: (viewBgSelectorBtn.frame.width / 2) - 1, height: viewBgSelectorBtn.frame.height - 2))
        btnSuper.setImage(UIImage(color: UIColor.white, size: btnSuper.frame.size), for: UIControlState())
        btnSuper.setImage(UIImage(color: WMColor.light_blue, size: btnSuper.frame.size), for: UIControlState.selected)
        btnSuper.setTitle(titleSupper, for: UIControlState())
        btnSuper.setTitle(titleSupper, for: UIControlState.selected)
        btnSuper.setTitleColor(UIColor.white, for: UIControlState.selected)
        btnSuper.setTitleColor(WMColor.light_blue, for: UIControlState())
        btnSuper.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnSuper.isSelected = true
        btnSuper.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnSuper.frame.size.width + 1, 0, 0.0);
        btnSuper.addTarget(self, action: #selector(MyAddressViewController.changeSuperTech(_:)), for: UIControlEvents.touchUpInside)
        
        let titleTech = NSLocalizedString("profile.address.tech",comment:"")
        btnTech = UIButton(frame: CGRect(x: btnSuper.frame.maxX, y: 1, width: viewBgSelectorBtn.frame.width / 2, height: viewBgSelectorBtn.frame.height - 2))
        btnTech.setImage(UIImage(color: UIColor.white, size: btnSuper.frame.size), for: UIControlState())
        btnTech.setImage(UIImage(color: WMColor.light_blue, size: btnSuper.frame.size), for: UIControlState.selected)
        btnTech.setTitleColor(UIColor.white, for: UIControlState.selected)
        btnTech.setTitleColor(WMColor.light_blue, for: UIControlState())
        btnTech.setTitle(titleTech, for: UIControlState())
        btnTech.setTitle(titleTech, for: UIControlState.selected)
        btnTech.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnTech.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnSuper.frame.size.width + 1, 0, 0.0);
        btnTech.addTarget(self, action: #selector(MyAddressViewController.changeSuperTech(_:)), for: UIControlEvents.touchUpInside)
        
        viewBgSelectorBtn.clipsToBounds = true
        viewBgSelectorBtn.backgroundColor = UIColor.white
        viewBgSelectorBtn.addSubview(btnSuper)
        viewBgSelectorBtn.addSubview(btnTech)
        self.viewBgSelectorBtn.isHidden = true
        self.view.addSubview(viewBgSelectorBtn)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isShowingTabBar = !TabBarHidden.isTabBarHidden
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        
        let heightEmptyView = self.view.frame.height - 46
        var widthEmptyView = self.view.bounds.width
        
        if IS_IPAD {
            widthEmptyView = 681.5
        }
         self.viewBgSelectorBtn.frame =  CGRect(x: (bounds.width - 282) / 2  ,  y: self.header!.frame.maxY + 16, width: 282, height: 28)
        self.emptyView!.frame = CGRect(x: 0, y: self.header!.bounds.maxY, width: widthEmptyView, height: heightEmptyView)
        if IS_IPAD{
            self.emptyView!.showReturnButton = false
        }
        self.tableOrders.frame = CGRect(x: 0, y: viewBgSelectorBtn.frame.maxY + 10, width: self.view.bounds.width, height: self.view.bounds.height - 46 - viewBgSelectorBtn.frame.maxY)
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

        if (item["type"] as! String) == ResultObjectType.Mg.rawValue {
            
            let sendingViewController = OrderSendingViewController()
            let trackingStr = item["trackingNumber"] as! String
            let statusStr = item["status"] as! String
            
            sendingViewController.trackingNumber = trackingStr
            sendingViewController.status = statusStr
            self.navigationController!.pushViewController(sendingViewController, animated: true)
            
        } else {
            let detailController = OrderDetailViewController()
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
        self.arrayMGOrders = []
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
                self.arrayMGOrders.append(dictMGOrder)
            }
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "dd/MM/yyyy"
            self.arrayMGOrders.sort(by: {
                let firstDate = $0["placedDate"] as! String
                let secondDate = $1["placedDate"] as! String
                let dateOne = dateFormat.date(from: firstDate)!
                let dateTwo = dateFormat.date(from: secondDate)!
                return dateOne.compare(dateTwo) == ComparisonResult.orderedDescending
            })
            
            self.loadGROrders()
            }, errorBlock: { (error:NSError) -> Void in
                self.loadGROrders()
        })
    }

    
    func loadGROrders() {
        self.items = []
        self.arrayGROrders = []
        let servicePrev = GRPreviousOrdersService()
        servicePrev.callService({ (previous:[Any]) -> Void in
            for orderPrev in previous {
                var dictGROrder = orderPrev as! [String:Any]
                dictGROrder["type"] =  ResultObjectType.Groceries.rawValue
                self.arrayGROrders.append(dictGROrder)
            }
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "dd/MM/yyyy"
            self.arrayGROrders.sort(by: {
                let firstDate = $0["placedDate"] as! String
                let secondDate = $1["placedDate"] as! String
                let dateOne = dateFormat.date(from: firstDate)!
                let dateTwo = dateFormat.date(from: secondDate)!
                return dateOne.compare(dateTwo) == ComparisonResult.orderedDescending
            })
            
            if self.arrayGROrders.count == 0 && self.arrayMGOrders.count > 0{
            //self.emptyView!.descLabel.frame = CGRect(x: 0.0, y: 60, width: self.view.bounds.width, height: 16.0)
            //self.emptyView.isHidden = false
            self.viewBgSelectorBtn.isHidden = false
            self.facturasToolBar.isHidden = true
                self.btnTech.isSelected = true;
                self.btnSuper.isSelected = false
                self.items = self.arrayMGOrders
                self.tableOrders.reloadData()
                self.emptyView!.descLabel.frame = CGRect(x: 0.0, y: 60, width: self.view.bounds.width, height: 16.0)
                self.emptyView.isHidden = self.items.count > 0
            
            }else{
                self.emptyView.isHidden = self.arrayGROrders.count > 0 || self.arrayMGOrders.count > 0
                self.viewBgSelectorBtn.isHidden = !self.emptyView.isHidden
                self.facturasToolBar.isHidden = !(self.arrayGROrders.count > 0 || self.arrayMGOrders.count > 0)
                if self.arrayGROrders.count > 0 || self.arrayMGOrders.count > 0 {
                    self.facturasToolBar.backgroundColor = UIColor.white
                }
                self.items = self.arrayGROrders
                self.tableOrders.reloadData()
            }
            
            
            self.viewLoad.stopAnnimating()
            }, errorBlock: { (error:NSError) -> Void in
                self.viewLoad.stopAnnimating()
                self.tableOrders.reloadData()
                self.emptyView.isHidden = self.arrayGROrders.count > 0 || self.arrayMGOrders.count > 0
                self.viewBgSelectorBtn.isHidden = !self.emptyView.isHidden
                self.facturasToolBar.isHidden = !(self.arrayGROrders.count > 0 || self.arrayMGOrders.count > 0)
                if self.arrayGROrders.count > 0 || self.arrayMGOrders.count > 0 {
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
    
       
    //MARK: CHange Súper Tecnologia Hogar y mas
    func changeSuperTech(_ sender:UIButton) {
        self.items = []
        if sender == btnSuper &&  !sender.isSelected {
            sender.isSelected = true;
            btnTech.isSelected = false
            items = self.arrayGROrders
            tableOrders.reloadData()
             self.emptyView!.descLabel.frame = CGRect(x: 0.0, y: 60, width: self.view.bounds.width, height: 16.0)
            self.emptyView.isHidden = items.count > 0
        } else if sender == btnTech &&  !sender.isSelected {
            sender.isSelected = true;
            btnSuper.isSelected = false
            items = self.arrayMGOrders
            tableOrders.reloadData()
             self.emptyView!.descLabel.frame = CGRect(x: 0.0, y: 60, width: self.view.bounds.width, height: 16.0)
            self.emptyView.isHidden = items.count > 0
            
        }
    }

    
    override func back() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
        super.back()
    }
    
    override func swipeHandler(swipe: UISwipeGestureRecognizer) {
        self.back()
    }
    
}
