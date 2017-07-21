//
//  OrderSendingViewController.swift
//  WalMart
//
//  Created by Daniel V on 07/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit

class OrderSendingViewController: NavigationViewController,UITableViewDataSource,UITableViewDelegate, OrderSendigTableViewCellDelegate {
    var trackingNumber = ""
    var status = ""
    
    var tableOrders : UITableView!
    var items : [[String:Any]] = []
    var viewLoad : WMLoadingView!
    var emptyView : IPOOrderEmptyView!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREVIOUSORDERS.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewLoad = WMLoadingView(frame:CGRect.zero)
        
        self.view.backgroundColor = UIColor.white
        self.titleLabel!.text = self.trackingNumber
        
        tableOrders = UITableView()
        tableOrders.dataSource = self
        tableOrders.delegate = self
        
        tableOrders.register(OrderSendigTableViewCell.self, forCellReuseIdentifier: "sendingOrder")
        tableOrders.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.view.addSubview(tableOrders)
        
        self.emptyView = IPOOrderEmptyView(frame: CGRect.zero)
        self.emptyView.returnAction = {() in
            self.back()
        }
        self.view.addSubview(self.emptyView)
        self.reloadPreviousOrders()
        BaseController.setOpenScreenTagManager(titleScreen:  NSLocalizedString("profile.myOrders", comment: ""), screenName: self.getScreenGAIName())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let heightEmptyView = self.view.frame.height - 46
        var widthEmptyView = self.view.bounds.width
        
        if IS_IPAD {
            widthEmptyView = 681.5
        }
        
        self.emptyView!.frame = CGRect(x: 0, y: self.header!.bounds.maxY, width: widthEmptyView, height: heightEmptyView)
        if IS_IPAD{
            self.emptyView!.showReturnButton = false
        }
        self.tableOrders.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - (IS_IPAD ? 46.0 : 92.0))
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250//274.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableOrders.dequeueReusableCell(withIdentifier: "sendingOrder") as! OrderSendigTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.txtSendig = "Envío \(indexPath.row + 1) de \(items.count)"
        
        let item = self.items[indexPath.row]
        let status = item["status"] as! String
        let name = item["name"] as! String
        let paymentType = item["PaymentType"] as! String
        let address = item["address"] as! String
        let provider = item["Provider"] as! String
        let sellerId = item["sellerId"] as! String
        
        var  valueItem = ["statusValue": status, "nameValue": name, "PaymentTypeValue" :paymentType, "addressValue" : address, "ProviderValue":provider, "sellerId": sellerId]
        
        if let sendingNormal = item["sendingNormal"] as? String {
             valueItem["sendingNormalValue"] = sendingNormal
        }
        
        cell.orderItem = item
        cell.setValues(values: valueItem)
        cell.cellDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func reloadPreviousOrders() {
        self.items = []
        self.emptyView.frame = CGRect(x: 0, y: 46, width: self.view.frame.width, height: self.view.frame.height - 46)
        self.viewLoad.frame = CGRect(x: 0, y: 46, width: IS_IPAD ? 681.5 : self.view.frame.width, height: self.view.frame.height - 46)
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
        }
        viewLoad.backgroundColor = UIColor.white
        self.view.addSubview(viewLoad)
        viewLoad.startAnnimating(self.isVisibleTab)
        
        let servicePrev = PreviousOrderDetailService()
        servicePrev.callService(trackingNumber, successBlock: { (result:[String:Any]) -> Void in
             let deliberyType = result["deliveryType"] as! String
             let delyberyAddress = result["deliveryAddress"] as! String
             let userName = result["name"] as! String
             let paymentType = result["paymentType"] as! String
             let sellers = result["sellers"] as! [[String:Any]]
            
            var countOrder = 0
            for seller in sellers {
                let sellerName = seller["sellerName"] as! String
                let sellerId = seller["sellerId"] as! Int
                let guides = seller["guides"] as! [[String:Any]]
                for guide in guides {
                    countOrder += 1
                    let guideItems = guide["items"] as! [[String:Any]]
                    let status = guide["status"] as! String
                    let fedexGuide = guide["fedexGuide"] as! String
                    let urlGuide = guide["urlfedexGuide"] as! String
                    
                    var valueItem: [String:Any] = ["sendig":"\(countOrder)","status":status,"name":userName,"PaymentType":paymentType,"address":delyberyAddress,"Provider":sellerName, "sellerId": String(sellerId),"deliveryType": deliberyType,"fedexGuide":fedexGuide,"urlfedexGuide":urlGuide,"guideItems":guideItems]
                    
                    if let sendingNormal = guide["date"] as? String {
                        valueItem["sendingNormal"] = sendingNormal
                    }

                    self.items.append(valueItem)
                }
            }
            
            self.viewLoad.stopAnnimating()
            self.tableOrders.reloadData()
            self.emptyView.isHidden = self.items.count > 0
        }) { (error:NSError) -> Void in
            self.viewLoad.stopAnnimating()
            self.tableOrders.reloadData()
            self.emptyView.isHidden = self.items.count > 0
        }
        
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
    
    //MARK: - OrderSendigTableViewCellDelegate
    func didSelectOption(_ orderItem:[String:Any]?) {
        let controller = OrderMoreOptionsViewController()
        
        let sellerName = orderItem!["Provider"] as! String
        let sellerId = orderItem!["sellerId"] as! String
        
        let productsArray = orderItem!["guideItems"] as! [[String:Any]]
        controller.sellerName = sellerName
        controller.sellerId = sellerId
        controller.orderItems = productsArray
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func didShowDetail(_ orderItem:[String:Any]?) {
        let detailController = OrderProviderDetailViewController()
        detailController.type = ResultObjectType.Mg
        let dateStr = ""
        let trackingStr = trackingNumber
        let statusStr = orderItem!["status"] as! String
        
        detailController.trackingNumber = trackingStr
        detailController.status = statusStr
        detailController.date = dateStr
        detailController.itemDetail = orderItem!
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    
}
