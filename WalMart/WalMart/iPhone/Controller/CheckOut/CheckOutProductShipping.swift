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
    
    var viewLoad : WMLoadingView!

    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.backButton!.hidden =  IS_IPAD
        
        self.titleLabel?.text = "Tipo de Envío"
        
        self.stepLabel = UILabel()
        self.stepLabel.textColor = WMColor.reg_gray
        self.stepLabel.text = "2 de 4"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        self.viewHeader =  UIView(frame:CGRectMake(0, 46 , self.view.frame.width, 62))
        self.viewHeader!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.viewHeader!)
        
        let descriptionTitle = UILabel(frame:CGRectMake(16, 16 , self.viewHeader!.frame.width - 32, 30))
        descriptionTitle.numberOfLines = 2
        descriptionTitle.textAlignment = .Left
        descriptionTitle.backgroundColor = UIColor.clearColor()
        descriptionTitle.textColor = WMColor.reg_gray
        descriptionTitle.font = WMFont.fontMyriadProRegularOfSize(12)
        descriptionTitle.text = "Este pedido no puede ser entregado en un solo envío.\nSelecciona un tipo de envío para cada grupo de artículos."
        self.viewHeader?.addSubview(descriptionTitle)
        
        

        tableProductsCheckout = UITableView(frame:CGRectMake(0, self.viewHeader!.frame.maxY , self.view.frame.width, self.view.frame.height - 46))
        tableProductsCheckout.clipsToBounds = true
        tableProductsCheckout.backgroundColor =  WMColor.light_light_gray
        tableProductsCheckout.backgroundColor =  UIColor.whiteColor()
        tableProductsCheckout.layoutMargins = UIEdgeInsetsZero
        tableProductsCheckout.separatorInset = UIEdgeInsetsZero
        tableProductsCheckout.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        tableProductsCheckout.delegate = self
        tableProductsCheckout.dataSource = self
        tableProductsCheckout.separatorStyle = .None
        tableProductsCheckout.registerClass(ShoppingCartTextViewCell.self, forCellReuseIdentifier: "textCheckoutCell")
        tableProductsCheckout.registerClass(CheckOutShippingDetailCell.self, forCellReuseIdentifier: "textCheckoutDetailCell")
        tableProductsCheckout.registerClass(CheckOutShippingCell.self, forCellReuseIdentifier: "productShippingCell")
        self.view.addSubview(tableProductsCheckout)
        
        self.cancelButton = UIButton(frame: CGRect(x:16 , y:16 , width: (self.view.frame.width - 40) / 2  , height:34))
        self.cancelButton!.setTitle("Cancelar", forState: .Normal)
        self.cancelButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), forControlEvents: .TouchUpInside)
        self.cancelButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor =  WMColor.empty_gray
        self.cancelButton!.layer.cornerRadius =  17
        self.view.addSubview(self.cancelButton!)

        self.nextButton = UIButton(frame: CGRect(x:16 , y:16 , width: (self.view.frame.width - 40) / 2  , height:34))
        self.nextButton!.setTitle("Continuar", forState: .Normal)
        self.nextButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.nextButton!.addTarget(self, action: #selector(CheckOutProductShipping.next), forControlEvents: .TouchUpInside)
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
            self.viewHeader!.frame = CGRectMake(0, self.headerHeight, self.view.frame.width, 62)
            self.tableProductsCheckout.frame = CGRectMake(0, self.viewHeader!.frame.maxY , self.view.frame.width, self.view.frame.height - (124 + self.headerHeight))
             self.viewHeader!.hidden =  false
        }else{
            self.viewHeader!.hidden =  true
            self.tableProductsCheckout.frame = CGRectMake(0, self.headerHeight , self.view.frame.width, self.view.frame.height - (124 ))
        }
        self.stepLabel!.frame = CGRectMake(self.view.bounds.width - 51.0,0.0, 46, self.titleLabel!.bounds.height)
        self.cancelButton!.frame =  CGRectMake(16 , self.view.frame.height - 50 , (self.view.frame.width - 40) / 2  , 34)
        self.nextButton!.frame =  CGRectMake(self.view.frame.width - self.cancelButton!.frame.width - 16  , self.view.frame.height - 52 , (self.view.frame.width - 40) / 2  , 34)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if self.shippingAll.count > 1 {
            self.viewHeader!.frame = CGRectMake(0, self.headerHeight, self.view.frame.width, 62)
            self.tableProductsCheckout.frame = CGRectMake(0, self.viewHeader!.frame.maxY , self.view.frame.width, self.view.frame.height - (124 + self.headerHeight))
        }else{
            self.tableProductsCheckout.frame = CGRectMake(0, self.headerHeight , self.view.frame.width, self.view.frame.height - (124 ))
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var sending = false
        if let _ = self.shipping[section] as? NSDictionary{
            sending = true
        }
       
        let items =   self.orderDictionary?.objectForKey("commerceItems") as! NSArray
        return items.count + 1 + (sending ? 1 : 0)
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let content : UIView = UIView(frame: CGRectMake(0.0, 0.0 , self.view.frame.width, 56))
        content.backgroundColor = UIColor.whiteColor()
        var configshiping = false
        if ((self.shipping[section - 1] as? NSDictionary) != nil){
            configshiping = true
        }
        
      
        let headerView : UIView = UIView(frame: CGRectMake(0.0,0.0, self.view.frame.width, 40))
        headerView.backgroundColor = self.shippingAll.count == 1 ? UIColor.whiteColor() : WMColor.light_light_gray
      
        let titleLabel = UILabel(frame: CGRectMake(15.0, 0.0, 100, 40))
        titleLabel.text =  self.shippingAll.count == 1 ? "Envío":"Envío \(section + 1) de \(self.shippingAll.count)"
        titleLabel.textColor = WMColor.dark_gray
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        
        let imageDisclousure = UIImageView(image: UIImage(named: "disclosure"))
        imageDisclousure.contentMode = UIViewContentMode.Center
        imageDisclousure.frame = CGRectMake(self.view.frame.width - 30 , 10 , 20, 20)
        
        let labelShipping = UILabel(frame: CGRectMake(imageDisclousure.frame.minX - 158, 0.0, 150, 40))
        labelShipping.text = configshiping ? "Cambiar tipo de envío" : "Selecciona tipo de envío"
        labelShipping.textColor = WMColor.light_blue
        labelShipping.font = WMFont.fontMyriadProRegularOfSize(12)
        labelShipping.textAlignment = .Right
     
        headerView.addSubview(imageDisclousure)
        headerView.addSubview(titleLabel)
        headerView.addSubview(labelShipping)
        content.addSubview(headerView)
        
        let separator = CALayer()
        separator.backgroundColor = WMColor.light_light_gray.CGColor
        separator.frame = CGRectMake(0,39, headerView.frame.width, 1)
        headerView.layer.insertSublayer(separator, atIndex: 100)
        
        content.tag = section
        content.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CheckOutProductShipping.tapOnSection(_:))))
        
        return content
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.shippingAll.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil

        var shippingtype : NSDictionary = [:]
        var configshiping = false
        
        if let shippingDic = self.shipping[indexPath.section] as? NSDictionary{
            shippingtype = shippingDic
            configshiping = true
        }
        
        if configshiping && indexPath.row == 0 {
            let cellText = tableProductsCheckout.dequeueReusableCellWithIdentifier("textCheckoutDetailCell", forIndexPath: indexPath) as! CheckOutShippingDetailCell
            cellText .setValues(shippingtype["type"] as! String, util: shippingtype["util"] as! String, date: shippingtype["date"] as! String)
           
            cell = cellText

        }
        
        else
        if !configshiping && indexPath.row == 0 || (configshiping && indexPath.row == 1)  {
            let cellText = tableProductsCheckout.dequeueReusableCellWithIdentifier("productShippingCell", forIndexPath: indexPath) as! CheckOutShippingCell
            cellText.setValues("Productos", quanty:0)
            cell = cellText
        }
        else {
            let cellText = tableProductsCheckout.dequeueReusableCellWithIdentifier("productShippingCell", forIndexPath: indexPath) as! CheckOutShippingCell
            let items =  self.orderDictionary?.objectForKey("commerceItems") as! NSArray
            cellText.setValues(items[indexPath.row - (configshiping ? 2 : 1)]["productDisplayName"] as? String ?? "", quanty: items[indexPath.row - (configshiping ? 2 : 1)]["quantity"] as? NSNumber ?? 0)
            cellText.cartButton?.hidden = true
            cellText.separator?.hidden = true
            cellText.delegate = self
            
            if indexPath.section ==  shippingAll.count - 1 {
                if (items.count  + (configshiping ? 1 : 0)) == indexPath.row {
                    cellText.cartButton?.hidden = false
                    cellText.separator?.hidden = false
                }
            }
            cell = cellText
        }
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

            var configshiping = false
            if let _ = self.shipping[indexPath.section] as? NSDictionary{
                configshiping = true
            }
            if configshiping && indexPath.row == 0 {
             return 114 / 2
            }
            if indexPath.section ==  shippingAll.count - 1 {
                let items =   self.orderDictionary?.objectForKey("commerceItems") as! NSArray
                if (items.count  + (configshiping ?  1 : 0)) == indexPath.row {
                    return 85
                }
            }
            return 30
        
    }
    
    func next(){
        
        let priceInfo  =  self.orderDictionary?.objectForKey("priceInfo") as! NSDictionary
        
        let nextController = GRCheckOutCommentsViewController()
        self.paramsToOrder?.setValue(self.shippingsToOrder, forKey: "shipping")
        self.paramsToOrder?.addEntriesFromDictionary(["subtotal":priceInfo["rawSubtotal"]!,"shippingCost":priceInfo["shipping"]!,"iva":"","discount":"","total":priceInfo["total"]!,"countItems":self.orderDictionary!.objectForKey("totalCommerceItemCount")! ])
        
        nextController.paramsToOrder =  self.paramsToOrder
        self.navigationController?.pushViewController(nextController, animated: true)
    }
   
    
    func invokeDetailedService() {
        
        let detailedService = DetailedService()
        detailedService.callService(requestParams: [], succesBlock: { (result: NSDictionary) in
            let response  =  result["responseObject"]  as! NSDictionary
            
            self.orderDictionary = response["order"] as? NSDictionary
            self.shippingAll = self.orderDictionary!.objectForKey("shippingGroups") as! NSArray
            
            self.tableProductsCheckout.reloadData()
            self.removeViewLoad()
        }, errorBlock: { (error:NSError) in
            print("Error al consultar servicios : DetailedService")
        })
        

    }
    
    
    func gotoShoppingCart(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    func tapOnSection(sender:UITapGestureRecognizer) {
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
            let paymentGroups = self.orderDictionary?.objectForKey("paymentGroups") as! NSArray
           
            let controller = CheckOutProductTypeShipping()
            controller.delegate = self
            controller.paymentSelected =  paymentGroups.objectAtIndex(0) as? NSDictionary
            controller.titleString =  "Envío \(selectedItem + 1) de \(self.shippingAll.count)"
            itemSelected = selectedItem
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    
    func selectDataTypeShipping(envio: String, util: String, date: String, rowSelected: Int){
        if  self.paramsToOrder?.objectForKey("shipping") == nil{
            self.paramsToOrder?.addEntriesFromDictionary(["shipping":[]])
        }
        
        if itemSelected >= 0 {
            
            let shippingDic = ["type":envio ,"util":util,"date":date , "rowSelected":rowSelected ]
            if shippingsToOrder ==  nil {
                self.shippingsToOrder = [["type":envio ,"util":util,"date":date , "rowSelected":rowSelected]]
            }else{
                shippingsToOrder?.addObject(["type":envio ,"util":util,"date":date , "rowSelected":rowSelected])
            }
            
            shipping.updateValue(shippingDic, forKey: itemSelected)
            self.tableProductsCheckout.reloadData()
        }
        
    }
    
    //MARK: CheckOutProductTypeShippingDelegate
    
    func selectDataTypeShipping(envio: String, util: String, date: String, rowSelected: Int, idSolot: String) {
        self.selectDataTypeShipping(envio, util: util, date: date, rowSelected: rowSelected)
    }

    func addViewLoad(){
        if viewLoad == nil {
            let bounds = IS_IPAD ? CGRectMake(0, 0, 341, 705) : self.view.bounds
            viewLoad = WMLoadingView(frame: bounds)
            viewLoad.backgroundColor = UIColor.whiteColor()
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
