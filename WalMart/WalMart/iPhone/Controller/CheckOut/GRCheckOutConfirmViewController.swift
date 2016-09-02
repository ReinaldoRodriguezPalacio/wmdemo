//
//  GRCheckOutConfirmViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/18/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRCheckOutConfirmViewController : NavigationViewController {
    
    var content: TPKeyboardAvoidingScrollView!
    var viewFooter : UIView?
    var labelName :UILabel?
    var name :UILabel?
    var phone :UILabel?
    
    var shippingsAddres = ["Casa de la abuela"]
    
    var invoiceAddres = "Addres invoice"
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = "Confirmación del pedido"
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRectMake(0.0, headerHeight, self.view.bounds.width, self.view.bounds.height - (headerHeight + 120))
        //self.content.delegate = self
        //self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content)
        
        self.labelName  =  UILabel(frame: CGRect(x: 16, y:16 , width:self.content.frame.width - 32 , height:12))
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
        self.content.addSubview(phone!)
        
        
        
        self.viewFooter =  UIView(frame:CGRect(x:0 , y:self.content!.frame.maxY, width:self.view.bounds.width , height: 64 ))
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
        
        createViewTotals()
    }
    
    
    override func viewDidLayoutSubviews() {
        
    }
    

    func createShppings(){
        
    
    }
    
    func createViewTotals() {
        let totals = TotalView(frame: CGRect(x:0, y:phone!.frame.maxY + 10, width:self.view.frame.width , height: 122))
        totals.setValues(articles: "16", subtotal: "500", shippingCost: "50", iva: "20", saving: "100", total: "470")
        
        
       self.content.addSubview(totals)
    }
    
}