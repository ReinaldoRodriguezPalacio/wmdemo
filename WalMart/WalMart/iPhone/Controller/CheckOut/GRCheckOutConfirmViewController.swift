//
//  GRCheckOutConfirmViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/18/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRCheckOutConfirmViewController : NavigationViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    let PERSONALCELL_ID = "personalDataCell"
    let ADDRESSCELL_ID = "adreessCell"
    let TOTALSL_ID = "totalsCell"
    
    var contentTableView: UITableView!
    var viewFooter : UIView?
    var labelName :UILabel?
    var name :UILabel?
    var phone :UILabel?
    
  
    
    let shoppingsAddres : [[String: String]] = [["type": "1","address": "Lithuania","phone": "5512345678"], ["type": "2","address": "Lithuania","phone": "5512345678"], ["type": "1","address": "Lithuania","phone": "5512345678"]]

     let shoppings : [[String: String]] = [["description": "Envio Estandar - hasta 5 dias "], ["description": "Recoger en tienda (Fecha y hora seleccionada)"], ["description": "Envio Estandar - hasta 5 dias "]]
    
    let dataUser = ["name:":"Daniel Lopez","phone":"5566123456","invoice":"RFC ASDM334F\nRazon Social Casa SA.\n direccion de las casa benito juarez ciudad de mexico 03100 "]

    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = "Confirmación del pedido"
        
        self.contentTableView = UITableView(frame: CGRectMake(0.0, headerHeight, self.view.bounds.width, self.view.bounds.height - (headerHeight + 120)))
        self.contentTableView.backgroundColor = UIColor.whiteColor()
        self.contentTableView.delegate =  self
        self.contentTableView.dataSource =  self
        self.view.addSubview(self.contentTableView)
        
        self.contentTableView!.registerClass(ComfirmViewCell.self, forCellReuseIdentifier: self.PERSONALCELL_ID)
        //self.contentTableView!.registerClass(NewListTableViewCell.self, forCellReuseIdentifier: self.NEWCELL_ID)
        
        /*self.labelName  =  UILabel(frame: CGRect(x: 16, y:16 , width:self.content.frame.width - 32 , height:12))
        labelName!.text = "Nombre:"
        labelName!.font = WMFont.fontMyriadProRegularOfSize(12)
        labelName!.textColor =  WMColor.light_blue
        self.content.addSubview(labelName!)
        
        self.name  =  UILabel(frame: CGRect(x: 16, y:labelName!.frame.maxY + 8 , width:self.content.frame.width - 32 , height:12))
        name!.text = "David Castillo"
        name!.font = WMFont.fontMyriadProRegularOfSize(14)
        name!.textColor =  WMColor.gray_reg
        self.content.addSubview(name!)
        
        self.phone  =  UILabel(frame: CGRect(x: 16, y:name!.frame.maxY + 8 , width:self.content.frame.width - 32 , height:12))
        phone!.text = "Tel. 5523400901"
        phone!.font = WMFont.fontMyriadProRegularOfSize(14)
        phone!.textColor =  WMColor.gray_reg
        self.content.addSubview(phone!)*/
        
        
        
        self.viewFooter =  UIView(frame:CGRect(x:0 , y:self.contentTableView!.frame.maxY, width:self.view.bounds.width , height: 64 ))
        self.viewFooter?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(viewFooter!)
        
        let layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        viewFooter!.layer.insertSublayer(layerLine, atIndex: 1000)
        layerLine.frame = CGRectMake(0, 0, self.viewFooter!.frame.width, 2)
        
        let cancelButton = UIButton(frame: CGRect(x:16 , y:16 , width: (self.view.frame.width - 40) / 2  , height:34))
        cancelButton.setTitle("Cancelar", forState: .Normal)
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancelButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        cancelButton.backgroundColor =  WMColor.empty_gray
        cancelButton.layer.cornerRadius =  17
        self.viewFooter?.addSubview(cancelButton)
        
        let confirmButton = UIButton(frame: CGRect(x:cancelButton.frame.maxX + 8 , y:cancelButton.frame.minY , width: cancelButton.frame.width , height:cancelButton.frame.height))
        confirmButton.setTitle("Confirmar", forState: .Normal)
        confirmButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        confirmButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        confirmButton.backgroundColor =  WMColor.light_blue
        confirmButton.layer.cornerRadius =  17
        
        self.viewFooter?.addSubview(confirmButton)
        
       // createViewTotals()
    }
    

    override func viewDidLayoutSubviews() {
        
    }
    
    //MARK: UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 1 ||  section == 2{
          return  self.shoppingsAddres.count
        }else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 ||  indexPath.section == 2 {
            return  72.0
        }else if indexPath.section == self.shoppingsAddres.count {
            return  122.0
        }else{
            return 130.0
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if indexPath.section == self.shoppingsAddres.count  {
            let totals = TotalView(frame: CGRect(x:0, y:0, width:self.view.frame.width , height: 122))
            totals.setValues(articles: "16", subtotal: "500", shippingCost: "50", iva: "20", saving: "100", total: "470")
            cell.addSubview(totals)
            cell.backgroundColor =  UIColor.redColor()
            return cell
        }
        
        if  indexPath.section == 0 {
            
            let confirmCell = tableView.dequeueReusableCellWithIdentifier(self.PERSONALCELL_ID) as! ComfirmViewCell
            confirmCell.setValues("nombre", description: "David", detailDesc: "")
            confirmCell.backgroundColor =  UIColor.blueColor()
            
            return confirmCell
        }else if indexPath.section == 1 {
            let confirmCell = tableView.dequeueReusableCellWithIdentifier(self.PERSONALCELL_ID) as! ComfirmViewCell
            confirmCell.setValues("Recoger", description: "Walmart Felix cuevas", detailDesc: "5512312312")
            confirmCell.backgroundColor =  UIColor.yellowColor()
            
            return confirmCell
        
        
        }else if indexPath.section == 2{
            let confirmCell = tableView.dequeueReusableCellWithIdentifier(self.PERSONALCELL_ID) as! ComfirmViewCell
            confirmCell.setValues("Envio 1 de 2", description: "Estandar Hasta 5 dias ", detailDesc: "")
             confirmCell.backgroundColor =  UIColor.greenColor()
            return confirmCell
        
        }else{
            
            let confirmCell = tableView.dequeueReusableCellWithIdentifier(self.PERSONALCELL_ID) as! ComfirmViewCell
            confirmCell.setValues("Faacturacion", description: "mis datos de factura", detailDesc: "5533323333")
            confirmCell.backgroundColor =  UIColor.grayColor()
            return confirmCell
        
        }
        
        
        
        
    }
    
    
    
}