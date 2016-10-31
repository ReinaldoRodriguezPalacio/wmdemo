//
//  CheckOutProductShipping.swift
//  WalMart
//
//  Created by Everardo Garcia on 01/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class CheckOutProductShipping: NavigationViewController, UITableViewDelegate,UITableViewDataSource, CheckOutShippingDelegate, CheckOutShippingSelectionDelegate,CheckOutProductTypeShippingDelegate {

    var tableProductsCheckout : UITableView!
    var shippingAll : NSArray! = []
    var itemDetail : NSDictionary! = [:]
    var shipping : [Int:AnyObject] = [:]
    var cancelButton : UIButton?
    var nextButton : UIButton?
    var itemSelected : Int = -1
    var paramsToOrder : NSMutableDictionary?
    var shippingsToOrder : NSMutableArray?
    var stepLabel: UILabel!
    var viewHeader :  UIView?
    var orderDictionary : NSDictionary?
    var alertView: IPOWMAlertViewController?
    var viewLoad : WMLoadingView!

    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.backButton!.isHidden =  IS_IPAD
        
        self.titleLabel?.text = "Tipo de Envío"
        
        self.stepLabel = UILabel()
        self.stepLabel.textColor = WMColor.reg_gray
        self.stepLabel.text = "2 de 4"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        self.viewHeader =  UIView(frame:CGRect(x: 0, y: 46 , width: self.view.frame.width, height: 62))
        self.viewHeader!.backgroundColor = UIColor.white
        self.view.addSubview(self.viewHeader!)
        
        let descriptionTitle = UILabel(frame:CGRect(x: 16, y: 16 , width: self.viewHeader!.frame.width - 32, height: 30))
        descriptionTitle.numberOfLines = 2
        descriptionTitle.textAlignment = .left
        descriptionTitle.backgroundColor = UIColor.clear
        descriptionTitle.textColor = WMColor.reg_gray
        descriptionTitle.font = WMFont.fontMyriadProRegularOfSize(12)
        descriptionTitle.text = "Este pedido no puede ser entregado en un solo envío.\nSelecciona un tipo de envío para cada grupo de artículos."
        self.viewHeader?.addSubview(descriptionTitle)
        
        

        tableProductsCheckout = UITableView(frame:CGRect(x: 0, y: self.viewHeader!.frame.maxY , width: self.view.frame.width, height: self.view.frame.height - 46))
        tableProductsCheckout.clipsToBounds = true
        tableProductsCheckout.backgroundColor =  WMColor.light_light_gray
        tableProductsCheckout.backgroundColor =  UIColor.white
        tableProductsCheckout.layoutMargins = UIEdgeInsets.zero
        tableProductsCheckout.separatorInset = UIEdgeInsets.zero
        tableProductsCheckout.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        tableProductsCheckout.delegate = self
        tableProductsCheckout.dataSource = self
        tableProductsCheckout.separatorStyle = .none
        tableProductsCheckout.register(ShoppingCartTextViewCell.self, forCellReuseIdentifier: "textCheckoutCell")
        tableProductsCheckout.register(CheckOutShippingDetailCell.self, forCellReuseIdentifier: "textCheckoutDetailCell")
        tableProductsCheckout.register(CheckOutShippingCell.self, forCellReuseIdentifier: "productShippingCell")
        self.view.addSubview(tableProductsCheckout)
        
        self.cancelButton = UIButton(frame: CGRect(x:16 , y:16 , width: (self.view.frame.width - 40) / 2  , height:34))
        self.cancelButton!.setTitle("Cancelar", for: UIControlState())
        self.cancelButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), for: .touchUpInside)
        self.cancelButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor =  WMColor.empty_gray
        self.cancelButton!.layer.cornerRadius =  17
        self.view.addSubview(self.cancelButton!)

        self.nextButton = UIButton(frame: CGRect(x:16 , y:16 , width: (self.view.frame.width - 40) / 2  , height:34))
        self.nextButton!.setTitle("Continuar", for: UIControlState())
        self.nextButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.nextButton!.addTarget(self, action: #selector(getter: CheckOutProductShipping.next), for: .touchUpInside)
        self.nextButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.nextButton!.backgroundColor =  WMColor.light_blue
        self.nextButton!.layer.cornerRadius =  17
        self.view.addSubview(self.nextButton!)
        self.addViewLoad()
        self.invokeDetailedService()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if self.shippingAll.count > 1 {
            self.viewHeader!.frame = CGRect(x: 0, y: self.headerHeight, width: self.view.frame.width, height: 62)
            self.tableProductsCheckout.frame = CGRect(x: 0, y: self.viewHeader!.frame.maxY , width: self.view.frame.width, height: self.view.frame.height - (124 + self.headerHeight))
             self.viewHeader!.isHidden =  false
        }else{
            self.viewHeader!.isHidden =  true
            self.tableProductsCheckout.frame = CGRect(x: 0, y: self.headerHeight , width: self.view.frame.width, height: self.view.frame.height - (124 ))
        }
        self.stepLabel!.frame = CGRect(x: self.view.bounds.width - 51.0,y: 0.0, width: 46, height: self.titleLabel!.bounds.height)
        self.cancelButton!.frame =  CGRect(x: 16 , y: self.view.frame.height - 50 , width: (self.view.frame.width - 40) / 2  , height: 34)
        self.nextButton!.frame =  CGRect(x: self.view.frame.width - self.cancelButton!.frame.width - 16  , y: self.view.frame.height - 52 , width: (self.view.frame.width - 40) / 2  , height: 34)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if self.shippingAll.count > 1 {
            self.viewHeader!.frame = CGRect(x: 0, y: self.headerHeight, width: self.view.frame.width, height: 62)
            self.tableProductsCheckout.frame = CGRect(x: 0, y: self.viewHeader!.frame.maxY , width: self.view.frame.width, height: self.view.frame.height - (124 + self.headerHeight))
        }else{
            self.tableProductsCheckout.frame = CGRect(x: 0, y: self.headerHeight , width: self.view.frame.width, height: self.view.frame.height - (124 ))
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var sending = false
        if let _ = self.shipping[section] as? NSDictionary{
            sending = true
        }
       
        let items =   self.orderDictionary?.object(forKey: "commerceItems") as! NSArray
        return items.count + 1 + (sending ? 1 : 0)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let content : UIView = UIView(frame: CGRect(x: 0.0, y: 0.0 , width: self.view.frame.width, height: 56))
        content.backgroundColor = UIColor.white
        var configshiping = false
        if ((self.shipping[section - 1] as? NSDictionary) != nil){
            configshiping = true
        }
        
      
        let headerView : UIView = UIView(frame: CGRect(x: 0.0,y: 0.0, width: self.view.frame.width, height: 40))
        headerView.backgroundColor = self.shippingAll.count == 1 ? UIColor.white : WMColor.light_light_gray
      
        let titleLabel = UILabel(frame: CGRect(x: 15.0, y: 0.0, width: 100, height: 40))
        titleLabel.text =  self.shippingAll.count == 1 ? "Envío":"Envío \(section + 1) de \(self.shippingAll.count)"
        titleLabel.textColor = WMColor.dark_gray
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        
        let imageDisclousure = UIImageView(image: UIImage(named: "disclosure"))
        imageDisclousure.contentMode = UIViewContentMode.center
        imageDisclousure.frame = CGRect(x: self.view.frame.width - 30 , y: 10 , width: 20, height: 20)
        
        let labelShipping = UILabel(frame: CGRect(x: imageDisclousure.frame.minX - 158, y: 0.0, width: 150, height: 40))
        labelShipping.text = configshiping ? "Cambiar tipo de envío" : "Selecciona tipo de envío"
        labelShipping.textColor = WMColor.light_blue
        labelShipping.font = WMFont.fontMyriadProRegularOfSize(12)
        labelShipping.textAlignment = .right
     
        headerView.addSubview(imageDisclousure)
        headerView.addSubview(titleLabel)
        headerView.addSubview(labelShipping)
        content.addSubview(headerView)
        
        let separator = CALayer()
        separator.backgroundColor = WMColor.light_light_gray.cgColor
        separator.frame = CGRect(x: 0,y: 39, width: headerView.frame.width, height: 1)
        headerView.layer.insertSublayer(separator, at: 100)
        
        content.tag = section
        content.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CheckOutProductShipping.tapOnSection(_:))))
        
        return content
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.shippingAll.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil

        var shippingtype : NSDictionary = [:]
        var configshiping = false
        
        if let shippingDic = self.shipping[(indexPath as NSIndexPath).section] as? NSDictionary{
            shippingtype = shippingDic
            configshiping = true
        }
        
        if configshiping && (indexPath as NSIndexPath).row == 0 {
            let cellText = tableProductsCheckout.dequeueReusableCell(withIdentifier: "textCheckoutDetailCell", for: indexPath) as! CheckOutShippingDetailCell
            cellText .setValues(shippingtype["type"] as! String, util: shippingtype["util"] as! String, date: shippingtype["date"] as! String)
           
            cell = cellText

        }
        
        else
        if !configshiping && (indexPath as NSIndexPath).row == 0 || (configshiping && (indexPath as NSIndexPath).row == 1)  {
            let cellText = tableProductsCheckout.dequeueReusableCell(withIdentifier: "productShippingCell", for: indexPath) as! CheckOutShippingCell
            cellText.setValues("Productos", quanty:0)
            cell = cellText
        }
        else {
            let cellText = tableProductsCheckout.dequeueReusableCell(withIdentifier: "productShippingCell", for: indexPath) as! CheckOutShippingCell
            let items =  self.orderDictionary?.object(forKey: "commerceItems") as! NSArray
            cellText.setValues(items[(indexPath as NSIndexPath).row - (configshiping ? 2 : 1)]["productDisplayName"] as? String ?? "", quanty: items[(indexPath as NSIndexPath).row - (configshiping ? 2 : 1)]["quantity"] as? NSNumber ?? 0)
            cellText.cartButton?.isHidden = true
            cellText.separator?.isHidden = true
            cellText.delegate = self
            
            if (indexPath as NSIndexPath).section ==  shippingAll.count - 1 {
                if (items.count  + (configshiping ? 1 : 0)) == (indexPath as NSIndexPath).row {
                    cellText.cartButton?.isHidden = false
                    cellText.separator?.isHidden = false
                }
            }
            cell = cellText
        }
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

            var configshiping = false
            if let _ = self.shipping[(indexPath as NSIndexPath).section] as? NSDictionary{
                configshiping = true
            }
            if configshiping && (indexPath as NSIndexPath).row == 0 {
             return 114 / 2
            }
            if (indexPath as NSIndexPath).section ==  shippingAll.count - 1 {
                let items =   self.orderDictionary?.object(forKey: "commerceItems") as! NSArray
                if (items.count  + (configshiping ?  1 : 0)) == (indexPath as NSIndexPath).row {
                    return 85
                }
            }
            return 30
        
    }
    
    func validate() -> Bool {
        return self.shipping.count == self.shippingAll.count
    }
    
    func next(){
        
        if !self.validate() {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage("Selecciona un tipo de envío")
            self.alertView!.showErrorIcon("Aceptar")
            return
        }
        
        let priceInfo  =  self.orderDictionary?.object(forKey: "priceInfo") as! NSDictionary
        
        let nextController = GRCheckOutCommentsViewController()
        self.paramsToOrder?.setValue(self.shippingsToOrder, forKey: "shipping")
        self.paramsToOrder?.addEntries(from: ["subtotal":priceInfo["rawSubtotal"]!,"shippingCost":priceInfo["shipping"]!,"iva":"","discount":"","total":priceInfo["total"]!,"countItems":self.orderDictionary!.object(forKey: "totalCommerceItemCount")! ])
        
        nextController.paramsToOrder =  self.paramsToOrder
        self.navigationController?.pushViewController(nextController, animated: true)
    }
   
    
    func invokeDetailedService() {
        
        let detailedService = DetailedService()
        detailedService.callService(requestParams: [], succesBlock: { (result: NSDictionary) in
            let response  =  result["responseObject"]  as! NSDictionary
            
            self.orderDictionary = response["order"] as? NSDictionary
            self.shippingAll = self.orderDictionary!.object(forKey: "shippingGroups") as! NSArray
            
            self.tableProductsCheckout.reloadData()
            self.removeViewLoad()
        }, errorBlock: { (error:NSError) in
            print("Error al consultar servicios : DetailedService")
        })
        

    }
    
    
    func gotoShoppingCart(){
        self.navigationController?.popToRootViewController(animated: true)
    }

    func tapOnSection(_ sender:UITapGestureRecognizer) {
        let selectedItem = sender.view!.tag
        if selectedItem == 1 {
            let controller =  CheckOutShippingSelectionController()
            itemSelected = selectedItem
            
            if let dic = self.shipping[itemSelected] as? NSDictionary{
                let selected = dic["rowSelected"] as! Int
                controller.rowSelected = selected
            }else{
                controller.rowSelected = 0
            }
            controller.delegate = self
            controller.titleString =  "Envío \(selectedItem + 1) de \(self.shippingAll.count)"
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let paymentGroups = self.orderDictionary?.object(forKey: "paymentGroups") as! NSArray
           
            let controller = CheckOutProductTypeShipping()
            controller.delegate = self
            controller.paymentSelected =  paymentGroups.object(at: 0) as? NSDictionary
            controller.titleString =  "Envío \(selectedItem + 1) de \(self.shippingAll.count)"
            itemSelected = selectedItem
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    
    func selectDataTypeShipping(_ envio: String, util: String, date: String, rowSelected: Int){
        if  self.paramsToOrder?.object(forKey: "shipping") == nil{
            self.paramsToOrder?.addEntries(from: ["shipping":[]])
        }
        
        if itemSelected >= 0 {
            
            let shippingDic = ["type":envio ,"util":util,"date":date , "rowSelected":rowSelected ] as [String : Any]
            if shippingsToOrder ==  nil {
                self.shippingsToOrder = [["type":envio ,"util":util,"date":date , "rowSelected":rowSelected]]
            }else{
                shippingsToOrder?.add(["type":envio ,"util":util,"date":date , "rowSelected":rowSelected])
            }
            
            shipping.updateValue(shippingDic as AnyObject, forKey: itemSelected)
            self.tableProductsCheckout.reloadData()
        }
        
    }
    
    //MARK: CheckOutProductTypeShippingDelegate
    
    func selectDataTypeShipping(_ envio: String, util: String, date: String, rowSelected: Int, idSolot: String) {
        self.selectDataTypeShipping(envio, util: util, date: date, rowSelected: rowSelected)
    }

    func addViewLoad(){
        if viewLoad == nil {
            let bounds = IS_IPAD ? CGRect(x: 0, y: 0, width: 341, height: 705) : self.view.bounds
            viewLoad = WMLoadingView(frame: bounds)
            viewLoad.backgroundColor = UIColor.white
            viewLoad.startAnnimating(true)
            self.view.addSubview(viewLoad)
        }
    }
    
    func removeViewLoad(){
        if self.viewLoad != nil {
            self.viewLoad.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    
    
}
