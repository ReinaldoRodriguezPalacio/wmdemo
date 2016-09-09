//
//  CheckOutProductShipping.swift
//  WalMart
//
//  Created by Everardo Garcia on 01/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class CheckOutProductShipping: NavigationViewController, UITableViewDelegate,UITableViewDataSource, CheckOutShippingDelegate, CheckOutShippingSelectionDelegate {

    var tableProductsCheckout : UITableView!
    var shippingAll : NSArray! = []
    var itemDetail : NSDictionary! = [:]
    var shipping : [Int:AnyObject] = [:]
    var cancelButton : UIButton?
    var nextButton : UIButton?
    var itemSelected : Int = -1
    var paramsToOrder : NSMutableDictionary?
    var shippingsToOrder : NSMutableArray?
    
    var viewHeader :  UIView?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.titleLabel?.text = "Tipo de envío"
        
        self.viewHeader =  UIView(frame:CGRectMake(0, 46 , self.view.frame.width, 62))
        self.viewHeader!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.viewHeader!)
        
        let descriptionTitle = UILabel(frame:CGRectMake(16, 16 , self.viewHeader!.frame.width - 32, 30))
        descriptionTitle.numberOfLines = 2
        descriptionTitle.textAlignment = .Left
        descriptionTitle.backgroundColor = UIColor.clearColor()
        descriptionTitle.textColor = WMColor.gray_reg
        descriptionTitle.font = WMFont.fontMyriadProRegularOfSize(12)
        descriptionTitle.text = "Este pedido no puede ser entregado en un solo envío.\nSelecciona un tipo de envío para cada grupo de artículos"
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
        self.cancelButton!.addTarget(self, action: #selector(CheckOutProductShipping.next), forControlEvents: .TouchUpInside)
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
        self.service()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewHeader!.frame = CGRectMake(0, 46 , self.view.frame.width, 62)
        self.tableProductsCheckout.frame = CGRectMake(0, self.viewHeader!.frame.maxY , self.view.frame.width, self.view.frame.height - (124 + self.headerHeight))
        self.cancelButton!.frame =  CGRectMake(16 , self.view.frame.height - 52 , (self.view.frame.width - 40) / 2  , 34)
        self.nextButton!.frame =  CGRectMake(self.view.frame.width - self.cancelButton!.frame.width - 16  , self.view.frame.height - 52 , (self.view.frame.width - 40) / 2  , 34)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dic = self.shippingAll[section]["items"] as! NSArray
        
        print("numberOfRowsInSection ::: \(dic.count) section \(section)")
        return dic.count + 1
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.shippingAll.count == 1 {
            return 0
        }
        return 56
    }
    
    

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let content : UIView = UIView(frame: CGRectMake(0.0, 0.0 , self.view.frame.width, 56))
        content.backgroundColor = UIColor.whiteColor()
        var configshiping = false
        if ((self.shipping[section - 1] as? NSDictionary) != nil){
            configshiping = true
        }
      
        let headerView : UIView = UIView(frame: CGRectMake(0.0,0.0, self.view.frame.width, 40))
        headerView.backgroundColor = WMColor.light_light_gray
      
        let titleLabel = UILabel(frame: CGRectMake(15.0, 0.0, 100, 40))
        titleLabel.text = "Envio \(section + 1) de \(self.shippingAll.count)"
        titleLabel.textColor = WMColor.dark_gray
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        
        let imageDisclousure = UIImageView(image: UIImage(named: "disclosure"))
        imageDisclousure.contentMode = UIViewContentMode.Center
        imageDisclousure.frame = CGRectMake(self.view.frame.width - 30 , 10 , 20, 20)
        
        let labelShipping = UILabel(frame: CGRectMake(imageDisclousure.frame.minX - 158, 0.0, 150, 40))
        labelShipping.text = configshiping ? "Cambiar tipo de envio" : "Selecciona tipo de envío"
        labelShipping.textColor = WMColor.light_blue
        labelShipping.font = WMFont.fontMyriadProRegularOfSize(12)
        labelShipping.textAlignment = .Right
     
        headerView.addSubview(imageDisclousure)
        headerView.addSubview(titleLabel)
        headerView.addSubview(labelShipping)
        content.addSubview(headerView)
        
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
        
        if let shippingDic = self.shipping[indexPath.section - 1] as? NSDictionary{
            shippingtype = shippingDic
            configshiping = true
        }
        
        if configshiping && indexPath.row == 0 {
            let cellText = tableProductsCheckout.dequeueReusableCellWithIdentifier("textCheckoutDetailCell", forIndexPath: indexPath) as! CheckOutShippingDetailCell
            cellText .setValues(shippingtype["type"] as! String, util: shippingtype["util"] as! String, date: shippingtype["date"] as! String)
            cell = cellText

        }
        
            
        if indexPath.row == 0 {
            let cellText = tableProductsCheckout.dequeueReusableCellWithIdentifier("productShippingCell", forIndexPath: indexPath) as! CheckOutShippingCell
            cellText.setValues("Productos", quanty:"")
            cell = cellText
        }
        else {
            let cellText = tableProductsCheckout.dequeueReusableCellWithIdentifier("productShippingCell", forIndexPath: indexPath) as! CheckOutShippingCell
            let dic = self.shippingAll[indexPath.section ] as! NSDictionary
            let items =  dic["items"] as! NSArray
            cellText.setValues(items[indexPath.row - 1]["description"] as? String ?? "", quanty: items[indexPath.row - 1]["quantity"] as? String ?? "")
            cellText.cartButton?.hidden = true
            cellText.separator?.hidden = true
            cellText.delegate = self
            
            if indexPath.section ==  shippingAll.count {
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
        if indexPath.section == 0 {
            return 56
        }
        else {
            var configshiping = false
            if let _ = self.shipping[indexPath.section - 1] as? NSDictionary{
                configshiping = true
            }
            if configshiping && indexPath.row == 0 {
             return 114 / 2
            }
            if indexPath.section ==  shippingAll.count {
                let dic = self.shippingAll[indexPath.section - 1] as! NSDictionary
                let items =   dic["items"] as! NSArray
                if (items.count  + (configshiping ? 1 : 0)) == indexPath.row {
                    return 85
                }
            }
            return 30
        }
    }
    
    func next(){
        let nextController = GRCheckOutCommentsViewController()
        self.paramsToOrder?.setValue(self.shippingsToOrder, forKey: "shipping")
        nextController.paramsToOrder =  self.paramsToOrder
        self.navigationController?.pushViewController(nextController, animated: true)
    }
    
    func service() {
        let servicePrev = PreviousOrderDetailService()
        servicePrev.callService("test", successBlock: { (result:NSDictionary) -> Void in
            self.itemDetail = result
            self.shippingAll = result["Shipping"] as! NSArray
            //self.setTypeShipping()
            self.tableProductsCheckout.bringSubviewToFront(self.view)
            self.tableProductsCheckout.reloadData()
            }) { (error:NSError) -> Void in
            //self.back()
        }
    }
    
    
    func gotoShoppingCart(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    func tapOnSection(sender:UITapGestureRecognizer) {
        let selectedItem = sender.view!.tag
        if selectedItem == 1 {
            let controller =  CheckOutShippingSelectionController()
            itemSelected = selectedItem - 1
            
            if let dic = self.shipping[itemSelected] as? NSDictionary{
                let selected = dic["rowSelected"] as! Int
                controller.rowSelected = selected
            }
            controller.delegate = self
            controller.titleString =  "Envio \(selectedItem) de \(self.shippingAll.count)"
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let controller = CheckOutProductTypeShipping()
            
            
            self.navigationController?.pushViewController(controller, animated: true)
            
            
        }
    }

    
    func selectDataTypeShipping(envio: String, util: String, date: String, rowSelected: Int){
        if  self.paramsToOrder?.objectForKey("shipping") == nil{
            self.paramsToOrder?.addEntriesFromDictionary(["shipping":[]])
        }
        
        if itemSelected >= 0 {
            
            let shippingDic = ["type":envio ,"util":util,"date":date , "rowSelected":rowSelected ]
            //self.paramsToOrder?.setValue(shippingDic, forKey: "shipping")
            if shippingsToOrder ==  nil {
                self.shippingsToOrder = [["type":envio ,"util":util,"date":date , "rowSelected":rowSelected]]
            }else{
                shippingsToOrder?.addObject(["type":envio ,"util":util,"date":date , "rowSelected":rowSelected])
            }
            //self.paramsToOrder?.objectForKey("shipping")?.addEntriesFromDictionary(shippingDic as [NSObject : AnyObject])
            
            shipping.updateValue(shippingDic, forKey: itemSelected)
            self.tableProductsCheckout.reloadData()
        }
        
    }
    
    
}
