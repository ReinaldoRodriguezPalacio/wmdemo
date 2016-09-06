//
//  CheckOutProductShipping.swift
//  WalMart
//
//  Created by Everardo Garcia on 01/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
//import Tune

class CheckOutProductShipping: NavigationViewController, UITableViewDelegate,UITableViewDataSource {

    var tableProductsCheckout : UITableView!
    var shippingAll : NSArray! = []
    var itemDetail : NSDictionary! = [:]
    var shipping : [Int:AnyObject] = [:]
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = WMColor.light_light_gray
        
        
        self.titleLabel?.text = "Tipo de envio envío"
        
        
        tableProductsCheckout = UITableView(frame:CGRectMake(0, 46 , self.view.frame.width, self.view.frame.height - 46))
        tableProductsCheckout.clipsToBounds = false
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
        
        let cancelButton = UIButton(frame: CGRect(x:16 , y:16 , width: (self.view.frame.width - 40) / 2  , height:34))
        cancelButton.setTitle("continuar", forState: .Normal)
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancelButton.addTarget(self, action: #selector(CheckOutProductShipping.next), forControlEvents: .TouchUpInside)
        cancelButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        cancelButton.backgroundColor =  WMColor.empty_gray
        cancelButton.layer.cornerRadius =  17
        self.view.addSubview(cancelButton)

        //tableProductsCheckout.reloadData()
        self.service()
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        let dic = self.shippingAll[section - 1] as! NSDictionary
        var sending = false
        
        if let shippingDic = self.shipping[section - 1] as? NSDictionary{
            sending = true
        }
        
         let items =   dic["items"] as! NSArray

        return items.count + 1 + (sending ? 1 : 0)
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 56
    }
    

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let content : UIView = UIView(frame: CGRectMake(0.0, 0.0 , self.view.frame.width, 56))
        content.backgroundColor = UIColor.whiteColor()
      
        let headerView : UIView = UIView(frame: CGRectMake(0.0, 8.0, self.view.frame.width, 40))
        headerView.backgroundColor = WMColor.light_gray
      
        let titleLabel = UILabel(frame: CGRectMake(15.0, 0.0, 100, 40))
        
        titleLabel.text = "Envio \(section+1) de \(self.shippingAll.count)"

        titleLabel.textColor = WMColor.dark_gray
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        
        let button = UILabel(frame: CGRectMake(self.view.frame.width - 150, 0.0, 150, 40))
        button.text = "Selecciona tipo de envío "
        button.textColor = WMColor.regular_blue
        button.font = WMFont.fontMyriadProRegularOfSize(12)
        
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(button)
        content.addSubview(headerView)
        
        return content
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.shippingAll.count + 1
    }
    
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        
        if indexPath.section  == 0  {
            let cell = tableProductsCheckout.dequeueReusableCellWithIdentifier("textCheckoutCell", forIndexPath: indexPath) as! ShoppingCartTextViewCell
            cell.setValues("Este producto no puede ser entregado en un solo envío \n selecciona un tipo de envío para cada artículo", hiddenDelimiter: true)
            return cell
        }

        var shippingtype : NSDictionary = [:]
        var configshiping = false
        var index = 0
        
        if let shippingDic = self.shipping[indexPath.section - 1] as? NSDictionary{
            shippingtype = shippingDic
            configshiping = true
        }
        
        if configshiping && indexPath.row == 0 {
            let cellText = tableProductsCheckout.dequeueReusableCellWithIdentifier("textCheckoutDetailCell", forIndexPath: indexPath) as! CheckOutShippingDetailCell
            
            cellText .setValues(shippingtype["type"] as! String, util: shippingtype["util"] as! String, date: shippingtype["date"] as! String)
            cell = cellText

        }else
        if !configshiping && indexPath.row == 0 || (configshiping && indexPath.row == 1)  {
        
            let cellText = tableProductsCheckout.dequeueReusableCellWithIdentifier("productShippingCell", forIndexPath: indexPath) as! CheckOutShippingCell
            cellText.setValues("Producto", quanty:"")

             cell = cellText
        }
        else {
            
            let cellText = tableProductsCheckout.dequeueReusableCellWithIdentifier("productShippingCell", forIndexPath: indexPath) as! CheckOutShippingCell
      
            let dic = self.shippingAll[indexPath.section -  1] as! NSDictionary
            let items =  dic["items"] as! NSArray
            let dicItem =  items[indexPath.row - (configshiping ? 2 : 1)] as! NSDictionary
                cellText.setValues(dicItem["description"] as! String, quanty: dicItem["quantity"] as! String)
         
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
            if let shippingDic = self.shipping[indexPath.section - 1] as? NSDictionary{
                configshiping = true
            }

            if configshiping && indexPath.row == 0 {
             return 114 / 2
            }
            
            return 30
            
            
        }
    }
    
    
    func next(){

        let nextController = GRCheckOutCommentsViewController()
        self.navigationController?.pushViewController(nextController, animated: true)
        
    }
    
    
    
    func service() {
        let servicePrev = PreviousOrderDetailService()
        servicePrev.callService("test", successBlock: { (result:NSDictionary) -> Void in
            self.itemDetail = result
            self.shippingAll = result["Shipping"] as! NSArray
            
            self.setTypeShipping()
            
            self.tableProductsCheckout.reloadData()
            }) { (error:NSError) -> Void in
            //self.back()
        }
    }
    
    
    func setTypeShipping(){
        var dic = self.shippingAll[0] as![String:AnyObject]
        
        let shippingDic = ["type":"Envío normal" ,"util":"Hasta 7 días" ,"date":"(Fecha estimada de entrega 08/03/2016)" ]
        
        dic.updateValue(shippingDic, forKey: "shipping")
        
        shipping.updateValue(shippingDic, forKey: 0)
        
       
    }

    

}
