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
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = WMColor.light_light_gray
        
        
        self.titleLabel?.text = "Tipo de envío"
        
        
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
         let items =   dic["items"] as! NSArray

        return items.count + 1
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 56
    }
    

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let content : UIView = UIView(frame: CGRectMake(0.0, 0.0 , self.view.frame.width, 56))
        content.backgroundColor = WMColor.green
      
        let headerView : UIView = UIView(frame: CGRectMake(0.0, 8.0, self.view.frame.width, 40))
        headerView.backgroundColor = WMColor.light_gray
      
        
        let titleLabel = UILabel(frame: CGRectMake(15.0, 0.0, self.view.frame.width, 40))
        
        titleLabel.text = "Envío 1 de 2"
        titleLabel.textColor = WMColor.light_blue
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        
        headerView.addSubview(titleLabel)
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
            cell.setValues("este producto no puede ser entregado en un solo envío \n selecciona un tipo de envío para cada artículo", hiddenDelimiter: true)
            return cell
        }

        let cellText = tableProductsCheckout.dequeueReusableCellWithIdentifier("productShippingCell", forIndexPath: indexPath) as! CheckOutShippingCell
        
            if indexPath.row == 0 {
                cellText.setValues("Producto", quanty:"0")
            }else {
                let dic = self.shippingAll[indexPath.section - 1] as! NSDictionary
                let items =  dic["items"] as! NSArray
                let dicItem =  items[indexPath.row - 1] as! NSDictionary
                
                cellText.setValues(dicItem["description"] as! String, quanty: dicItem["quantity"] as! String)
            }
        
        
        cell = cellText
        
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell!
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 56
        }
        else {
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
            
            self.tableProductsCheckout.reloadData()
            }) { (error:NSError) -> Void in
            //self.back()
        }
    }
    
    

    

}
