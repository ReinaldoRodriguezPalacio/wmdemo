//
//  GRCheckOutConfirmViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/18/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRCheckOutConfirmViewController : NavigationViewController, OrderConfirmDetailViewDelegate, UITableViewDelegate,UITableViewDataSource {
    
    
    let PERSONALCELL_ID = "personalDataCell"
    let ADDRESSCELL_ID = "adreessCell"
    let TOTALSL_ID = "totalsCell"
    
    //Confirmation view
    var serviceDetail : OrderConfirmDetailView? = nil
    
    var contentTableView: UITableView!
    var viewFooter : UIView?
    var labelName :UILabel?
    var name :UILabel?
    var phone :UILabel?
    
    var items = "16"
    var subtotal = "500"
    var shippingCost = "50"
    var iva = "20"
    var saving = "100"
    var total = "470"
    
    
  
    
    let shoppingsAddres : [[String: String]] = [["type": "1","address": "Casa de la abuela\nAv.San francisco no.1298 Del valle\nBenito Juarez Ciudad de Mexico 03100","phone": "5512345678"],["type": "2","address": "Walmart Felix Cuevas\nAv.San francisco no.1298 Del valle\nBenito Juarez Ciudad de Mexico 03100","phone": "553332345"]]

     let shoppings : [[String: String]] = [["description": "Envío Estandar - hasta 5 dias\nFecha estimada de entrega 98/98/12 "],["description": "Recoger en tienda \n fecha seleccionada (12/12/12 14:00)"]]
    
    let dataUser = ["name":"Juan Javier Ramirez Herrera","phone":"5566123456","invoice":"RFC ASDM334F\nRazon Social Casa SA \n direccion de las casa benito juarez ciudad de mexico 03100 "]

    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = NSLocalizedString("checkout.confirm.title", comment: "")
        
        self.contentTableView = UITableView(frame: CGRectMake(0.0, headerHeight, self.view.bounds.width, self.view.bounds.height - (headerHeight + 120 + (IS_IPAD ? 64.0 : 0))))
        self.contentTableView.backgroundColor = UIColor.whiteColor()
        self.contentTableView.separatorStyle =  .None
        self.contentTableView.delegate =  self
        self.contentTableView.dataSource =  self
        self.view.addSubview(self.contentTableView)
        
        self.contentTableView!.registerClass(ComfirmViewCell.self, forCellReuseIdentifier: self.PERSONALCELL_ID)
        
        self.viewFooter =  UIView(frame:CGRect(x:0 , y:self.contentTableView!.frame.maxY, width:self.view.bounds.width , height: 64 ))
        self.viewFooter?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(viewFooter!)
        
        let layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        viewFooter!.layer.insertSublayer(layerLine, atIndex: 1000)
        layerLine.frame = CGRectMake(0, 0, self.viewFooter!.frame.width, 2)

        let cancelButton = UIButton(frame: CGRect(x:16 , y:16 , width: IS_IPAD ? 148.0 : ((self.view.frame.width - 40) / 2), height:34))
        cancelButton.setTitle(NSLocalizedString("checkout.confirm.cancel", comment: ""), forState: .Normal)
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancelButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        cancelButton.backgroundColor =  WMColor.empty_gray
        cancelButton.layer.cornerRadius =  17
        cancelButton.addTarget(self, action: #selector(GRCheckOutConfirmViewController.cancelORder), forControlEvents: .TouchUpInside)
        self.viewFooter?.addSubview(cancelButton)
        
        let confirmButton = UIButton(frame: CGRect(x:cancelButton.frame.maxX + 8 , y:cancelButton.frame.minY , width: cancelButton.frame.width , height:cancelButton.frame.height))
        confirmButton.setTitle(NSLocalizedString("checkout.confirm.btn", comment: ""), forState: .Normal)
        confirmButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        confirmButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        confirmButton.backgroundColor =  WMColor.green
        confirmButton.addTarget(self, action: #selector(GRCheckOutConfirmViewController.continueOrder), forControlEvents: .TouchUpInside)
        confirmButton.layer.cornerRadius =  17
        
        self.viewFooter?.addSubview(confirmButton)
        
    }
    

    override func viewDidLayoutSubviews() {
        
    }
    
    //MARK: UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 || section == 2 {
            return self.shoppingsAddres.count
        } else {
            return 1
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 ||  indexPath.section == 2 {
            return  72.0
        }else if indexPath.section == 1 ||  indexPath.section == 3 {
            return  90.0
        }else{
            return 122.0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            
            let confirmCell = tableView.dequeueReusableCellWithIdentifier(self.PERSONALCELL_ID) as! ComfirmViewCell
            confirmCell.setValues(NSLocalizedString("checkout.confirm.name", comment: ""),name: dataUser["name"]! as String, description:"", detailDesc: dataUser["phone"]! as String)
            return confirmCell
            
        case 1:
        
            let type  = shoppingsAddres[indexPath.row]["type"]! as String
            let confirmCell = tableView.dequeueReusableCellWithIdentifier(self.PERSONALCELL_ID) as! ComfirmViewCell
            confirmCell.setValues(type == "1" ? NSLocalizedString("checkout.confirm.send", comment: ""):NSLocalizedString("checkout.confirm.collect", comment: ""),name: "", description: shoppingsAddres[indexPath.row]["address"]! as String, detailDesc: shoppingsAddres[indexPath.row]["phone"]! as String)
            return confirmCell
            
        case 2:
            let confirmCell = tableView.dequeueReusableCellWithIdentifier(self.PERSONALCELL_ID) as! ComfirmViewCell
            confirmCell.setValues("\(NSLocalizedString("checkout.confirm.send", comment: "")) \(indexPath.row + 1) \(NSLocalizedString("checkout.confirm.to", comment: "")) \(shoppings.count)",name: "", description: shoppings[indexPath.row]["description"]!, detailDesc: "")
            return confirmCell
            
        case 3:
            
            let confirmCell = tableView.dequeueReusableCellWithIdentifier(self.PERSONALCELL_ID) as! ComfirmViewCell
            confirmCell.setValues(NSLocalizedString("checkout.confirm.invoice", comment: ""),name: "", description: dataUser["invoice"]! as String, detailDesc: "")
            return confirmCell
            
        case 4:
            let totals = TotalView(frame: CGRect(x:0, y:0, width:self.view.frame.width , height: 122))
            totals.setValues(articles: self.items, subtotal: self.subtotal, shippingCost: self.shippingCost, iva: self.iva, saving: self.saving, total: self.total)
            cell.addSubview(totals)
            cell.selectionStyle = .None
            
        default:
            break
        }
        
        return cell
    }
    
    func cancelORder(){
         self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    func continueOrder(){
        /*
        let cont = LoginController.showLogin()
        var user = ""
        if UserCurrentSession.hasLoggedUser() {
            cont!.noAccount?.hidden = true
            cont!.registryButton?.hidden = true
            cont!.valueEmail = UserCurrentSession.sharedInstance().userSigned!.email as String
            cont!.email?.text = UserCurrentSession.sharedInstance().userSigned!.email as String
            cont!.email!.enabled = false
            user = UserCurrentSession.sharedInstance().userSigned!.email as String
        }
        cont!.okCancelCallBack = {() in
            print("cancel")
        }*/
        
        //CONFIRM
        serviceDetail = OrderConfirmDetailView.initDetail()
        serviceDetail?.delegate = self
        serviceDetail!.showDetail()
        
        let formatedSubotal = CurrencyCustomLabel.formatString("10500")
        let formatedShippingCost = CurrencyCustomLabel.formatString("200")
        let formatedTxes = CurrencyCustomLabel.formatString("200")
        let formatedDiscount = CurrencyCustomLabel.formatString("5000")
        let formatedTotal = CurrencyCustomLabel.formatString("5900")
        
        self.serviceDetail?.completeOrder("12345678912345", subtotal:formatedSubotal,shippingCost:formatedShippingCost, taxes:formatedTxes,discount:formatedDiscount,total: formatedTotal)
    }
    
    /**
     Close OrderConfirmDetailView delegate
     */
    func didFinishConfirm() {
        print("Close")
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    func didErrorConfirm() {
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    
    
}