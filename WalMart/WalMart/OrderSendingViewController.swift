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
        self.tableOrders.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 92)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 256.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableOrders.dequeueReusableCell(withIdentifier: "sendingOrder") as! OrderSendigTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.txtSendig = "Envío \(indexPath.row + 1) de \(items.count)"
        
        let item = self.items[indexPath.row]
        let status = item["status"] as! String
        let name = item["name"] as! String
        let sendingNormal = item["sendingNormal"] as! String
        let paymentType = item["PaymentType"] as! String
        let address = item["address"] as! String
        let provider = item["Provider"] as! String
        
        let valueItem = ["statusValue": status, "nameValue": name, "sendingNormalValue": sendingNormal, "PaymentTypeValue" :paymentType, "addressValue" : address, "ProviderValue":provider]
        cell.setValues(values: valueItem)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func reloadPreviousOrders() {
        self.items = []
        self.emptyView.frame = CGRect(x: 0, y: 46, width: self.view.frame.width, height: self.view.frame.height - 46)
        self.viewLoad.frame = CGRect(x: 0, y: 46, width: self.view.frame.width, height: self.view.frame.height - 46)
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
        }
        viewLoad.backgroundColor = UIColor.white
        self.view.addSubview(viewLoad)
        viewLoad.startAnnimating(self.isVisibleTab)
        
        //********************
        self.items = [["sendig":"1","status":"Completado","name":"David Bowie","sendingNormal":"Hasta 7 dias (Fecha estimada de entrega: 08/03/2016)","PaymentType":"Pago en Linea","address":"Av San Francisco no. 1621, Del valle,Benito Juarez, Ciudad de México, 03100 \nTel 5521365678","Provider":"ACME"],["sendig":"2","status":"Completado","name":"David Bowie2","sendingNormal":"Hasta 15 dias (Fecha estimada de entrega: 08/03/2016)","PaymentType":"Efectivo","address":"Av San Francisco no. 1621, Del valle,Benito Juarez, Ciudad de México, 03100 \nTel 5521365678","Provider":"Proveedor 23"],["sendig":"3","status":"Completado","name":"3David Bowie","sendingNormal":"Hasta 1 mes (Fecha estimada de entrega: 08/03/2016)","PaymentType":"Pago en Linea y efectivo","address":"Av San Francisco no. 1621, Del valle,Benito Juarez, Ciudad de México, 03100 \nTel 5521365678","Provider":"Default"]]
        self.loadGROrders()
        //********************
        
        /*let servicePrev = PreviousOrdersService()
        servicePrev.callService({ (previous:[Any]) -> Void in
            for orderPrev in previous {
                var dictMGOrder = orderPrev as! [String:Any]
                dictMGOrder["type"] =  ResultObjectType.Mg.rawValue
                self.items.append(dictMGOrder)
            }
            self.loadGROrders()
        }, errorBlock: { (error:NSError) -> Void in
            self.loadGROrders()
        })*/
    }
    
    
    func loadGROrders() {
        let servicePrev = GRPreviousOrdersService()
        servicePrev.callService({ (previous:[Any]) -> Void in
            for orderPrev in previous {
                var dictGROrder = orderPrev as! [String:Any]
                dictGROrder["type"] =  ResultObjectType.Groceries.rawValue
                self.items.append(dictGROrder)
            }
            
            self.emptyView.isHidden = self.items.count > 0
            self.tableOrders.reloadData()
            self.viewLoad.stopAnnimating()
        }, errorBlock: { (error:NSError) -> Void in
            self.viewLoad.stopAnnimating()
            self.tableOrders.reloadData()
            self.emptyView.isHidden = self.items.count > 0
        })
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
    func didSelectOption(_ text:String?) {
        
    }
    
    func didShowDetail(_ text:String?) {
        
    }
    
    
}
