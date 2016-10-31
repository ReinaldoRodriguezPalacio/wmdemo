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
    let TOTALCELL_ID = "totalCell"
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
    var stepLabel: UILabel?
    var paramsToOrder : NSMutableDictionary?
    
  
    
    let shoppingsAddres : [[String: String]] = [["type": "1","address": "Casa de la abuela\nAv.San francisco no.1298 Del valle\nBenito Juarez Ciudad de Mexico 03100","phone": "5512345678"],["type": "2","address": "Walmart Felix Cuevas\nAv.San francisco no.1298 Del valle\nBenito Juarez Ciudad de Mexico 03100","phone": "553332345"]]

     let shoppings : [[String: String]] = [["description": "Envío Estandar - hasta 5 dias\nFecha estimada de entrega 98/98/12 "],["description": "Recoger en tienda \n fecha seleccionada (12/12/12 14:00)"]]
    
    let dataUser = ["name":"Juan Javier Ramirez Herrera","phone":"5566123456","invoice":"RFC ASDM334F\nRazon Social Casa SA \ndireccion de las casa benito juarez ciudad de mexico 03100 "]

    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton!.isHidden =  IS_IPAD
        self.view.backgroundColor =  UIColor.white
        self.titleLabel?.text = NSLocalizedString("checkout.confirm.title", comment: "")
        
        self.stepLabel = UILabel()
        self.stepLabel!.textColor = WMColor.reg_gray
        self.stepLabel!.text = "4 de 4"
        self.stepLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel!)
        
        self.contentTableView = UITableView(frame: CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.bounds.height - (headerHeight + 125)))
        self.contentTableView.backgroundColor = UIColor.white
        self.contentTableView.separatorStyle =  .none
        self.contentTableView.delegate =  self
        self.contentTableView.dataSource =  self
        self.view.addSubview(self.contentTableView)
        
        self.contentTableView!.register(ComfirmViewCell.self, forCellReuseIdentifier: self.PERSONALCELL_ID)
        self.contentTableView!.register(ShoppingCartTotalsTableViewCell.self, forCellReuseIdentifier: self.TOTALCELL_ID)
        
        self.viewFooter =  UIView(frame:CGRect(x:0 , y:self.contentTableView!.frame.maxY, width:self.view.bounds.width , height: 64 ))
        self.viewFooter?.backgroundColor = UIColor.white
        self.view.addSubview(viewFooter!)
        
        let layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        viewFooter!.layer.insertSublayer(layerLine, at: 1000)
        layerLine.frame = CGRect(x: 0, y: 0, width: self.viewFooter!.frame.width, height: 2)

        let cancelButton = UIButton(frame: CGRect(x:16 , y:16 , width: IS_IPAD ? 148.0 : ((self.view.frame.width - 40) / 2), height:34))
        cancelButton.setTitle(NSLocalizedString("checkout.confirm.cancel", comment: ""), for: UIControlState())
        cancelButton.setTitleColor(UIColor.white, for: UIControlState())
        cancelButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        cancelButton.backgroundColor =  WMColor.empty_gray
        cancelButton.layer.cornerRadius =  17
        cancelButton.addTarget(self, action: #selector(GRCheckOutConfirmViewController.cancelORder), for: .touchUpInside)
        self.viewFooter?.addSubview(cancelButton)
        
        let confirmButton = UIButton(frame: CGRect(x:cancelButton.frame.maxX + 8 , y:cancelButton.frame.minY , width: cancelButton.frame.width , height:cancelButton.frame.height))
        confirmButton.setTitle(NSLocalizedString("checkout.confirm.btn", comment: ""), for: UIControlState())
        confirmButton.setTitleColor(UIColor.white, for: UIControlState())
        confirmButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        confirmButton.backgroundColor =  WMColor.green
        confirmButton.addTarget(self, action: #selector(GRCheckOutConfirmViewController.continueOrder), for: .touchUpInside)
        confirmButton.layer.cornerRadius =  17
        
        self.viewFooter?.addSubview(confirmButton)
        
        
//         self.items = self.paramsToOrder!["countItems"] as! String
//         self.subtotal = self.paramsToOrder!["subtotal"] as! String
//         self.shippingCost = self.paramsToOrder!["shippingCost"] as! String
//         self.iva = self.paramsToOrder!["iva"] as! String
//         self.saving = self.paramsToOrder!["discount"] as! String
//         self.total =  self.paramsToOrder!["total"] as! String
    }
    

    override func viewDidLayoutSubviews() {
        self.stepLabel!.frame = CGRect(x: self.view.bounds.width - 51.0,y: 0.0, width: 46, height: self.titleLabel!.bounds.height)
        self.contentTableView.frame =  CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.frame.height - (headerHeight + 64))
        self.viewFooter!.frame = CGRect(x:0 , y:self.contentTableView!.frame.maxY, width:self.view.bounds.width , height: 64 )

        
    }
    
    //MARK: UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 || section == 2 {
            return self.shoppingsAddres.count
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).section == 0 {
            return  60.0
        }else if  (indexPath as NSIndexPath).section == 2 {
            return  72.0
        }else if (indexPath as NSIndexPath).section == 1 ||  (indexPath as NSIndexPath).section == 3 {
            return  90.0
        }
        return 122.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            
            let confirmCell = tableView.dequeueReusableCell(withIdentifier: self.PERSONALCELL_ID) as! ComfirmViewCell
            confirmCell.setValues(NSLocalizedString("checkout.confirm.name", comment: ""),name: dataUser["name"]! as String, description:"", detailDesc: dataUser["phone"]! as String)
            return confirmCell
            
        case 1:
        
            let type  = shoppingsAddres[(indexPath as NSIndexPath).row]["type"]! as String
            let confirmCell = tableView.dequeueReusableCell(withIdentifier: self.PERSONALCELL_ID) as! ComfirmViewCell
            confirmCell.setValues(type == "1" ? "\(NSLocalizedString("checkout.confirm.send", comment: "")):":NSLocalizedString("checkout.confirm.collect", comment: ""),name: "", description: shoppingsAddres[(indexPath as NSIndexPath).row]["address"]! as String, detailDesc: shoppingsAddres[(indexPath as NSIndexPath).row]["phone"]! as String)
            return confirmCell
            
        case 2:
            let confirmCell = tableView.dequeueReusableCell(withIdentifier: self.PERSONALCELL_ID) as! ComfirmViewCell
            confirmCell.setValues("\(NSLocalizedString("checkout.confirm.send", comment: "")) \((indexPath as NSIndexPath).row + 1) \(NSLocalizedString("checkout.confirm.to", comment: "")) \(shoppings.count)",name: "", description: shoppings[(indexPath as NSIndexPath).row]["description"]!, detailDesc: "")
            return confirmCell
            
        case 3:
            
            let confirmCell = tableView.dequeueReusableCell(withIdentifier: self.PERSONALCELL_ID) as! ComfirmViewCell
            confirmCell.setValues(NSLocalizedString("checkout.confirm.invoice", comment: ""),name: "", description: dataUser["invoice"]! as String, detailDesc: "")
            return confirmCell
            
        case 4:
            let totalCell = tableView.dequeueReusableCell(withIdentifier: self.TOTALCELL_ID) as! ShoppingCartTotalsTableViewCell
            totalCell.setValuesAll(articles: self.items, subtotal: self.subtotal, shippingCost: self.shippingCost, iva: self.iva, saving: self.saving, total: self.total)
            return totalCell
            
            
        default:
            break
        }
        
        return cell
    }
    
    func cancelORder(){
         self.navigationController!.popToRootViewController(animated: true)
    }
    
    func continueOrder(){

        //TODO: CONFIRM
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
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    func didErrorConfirm() {
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    
    
}
