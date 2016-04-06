//
//  PaymentOptionsView.swift
//  WalMart
//
//  Created by Joel Juarez on 18/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation



class PaymentOptionsView : UIView {
    
    var paymentItems : [AnyObject] = []
    var afterButton :UIButton?
    var selectedOption : ((selected:String, stringSelected:String) -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    init(frame: CGRect,items: [AnyObject]) {
        super.init(frame:frame)
        self.paymentItems = items
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    func setup() {
        
        let margin: CGFloat = 16.0
        let widthField = self.frame.width - (2 * margin)
        var posY:CGFloat =  10.0
        var width = self.frame.width - 32.0
        width = (width/2) - 75.0
        
        var count =  0
        if paymentItems.count > 0 {
            
            for payment in self.paymentItems{
                let paymentTupeItem = payment as! NSDictionary
                if paymentTupeItem["paymentType"] as! String != "Paypal" {
                    let titleLabel = UILabel(frame:CGRectMake(22, 0, widthField - 22,22))
                    titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
                    titleLabel.text = paymentTupeItem["paymentType"] as? String
                    titleLabel.numberOfLines = 2
                    titleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                    titleLabel.textColor = WMColor.dark_gray
                    titleLabel.tag = count
                
                    let promSelect = UIButton(frame: CGRectMake(0,posY,widthField,22))
                    promSelect.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
                    promSelect.setImage(UIImage(named:"checkAddressOn"), forState: UIControlState.Selected)
                    promSelect.addTarget(self, action: "paymentCheckSelected:", forControlEvents: UIControlEvents.TouchUpInside)
                    promSelect.addSubview(titleLabel)
                    promSelect.selected = false
                    promSelect.tag = count
                    promSelect.imageEdgeInsets = UIEdgeInsetsMake(0,0,0,widthField - 20)
                    self.addSubview(promSelect)
                
                    let descriptionLabel = UILabel(frame:CGRectMake(22,promSelect.frame.maxY , widthField - 22,14))
                    descriptionLabel.font = WMFont.fontMyriadProRegularOfSize(12)
                    descriptionLabel.text = self.assingDescription(titleLabel.text!)
                    descriptionLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                    descriptionLabel.textColor = WMColor.light_gray
                    descriptionLabel.tag = count
                    self.addSubview(descriptionLabel)
                
                    posY +=  54
                    count += 1
                }
            }
            
            
            
            
        }
    }
    
    //Las descripciones cambiaran de acuerdo a lo que el usuario indique,
    //hasta que el servivicio regrese esas descripciones
    
    func assingDescription(value:String) -> String{
        
        var descripcion = ""
        
        switch(value){
            
        case "Efectivo":
            descripcion =  NSLocalizedString("payment.options.cash", comment:"")
            break
        case "Vales de Despensa y Electrónicos":
            descripcion = NSLocalizedString("payment.options.isnecessary.id", comment:"")
            break
        case "Tarjeta de crédito":
            descripcion = NSLocalizedString("payment.options.isnecessary.id", comment:"")
            break
        case "Tarjeta de débito":
            descripcion = NSLocalizedString("payment.options.isnecessary.id", comment:"")
            break
        case "Tarjeta de Crédito Banco Walmart":
            descripcion = NSLocalizedString("payment.options.wm.optios", comment:"")
            break
        case "Tarjeta de Débito Banco Walmart":
            descripcion = NSLocalizedString("payment.options.wm.optios", comment:"")
            break
            
        default:
            descripcion = ""
            break
        }
        return descripcion
        
    }
    
    override func layoutSubviews() {
        for viewF in self.subviews {
            if viewF.isKindOfClass(UIButton) {
                if viewF.tag == 0{
                    self.paymentCheckSelected(viewF as! UIButton)
                }
            }
            
        }
    }


    func paymentCheckSelected(sender: UIButton){
        if(sender.selected){
            sender.selected = sender == afterButton ? true : false
        }
        else{
            if afterButton != nil{
                afterButton!.selected = false
            }
            sender.selected = true
            afterButton = sender
        }
        
        let paymentItemSelect = self.paymentItems[sender.tag] as! NSDictionary
        let selected = paymentItemSelect["id"] as! String
        self.selectedOption!(selected: selected,stringSelected:paymentItemSelect["paymentType"] as! String)
       
        let btnSelected : UIButton =  sender

        
        for viewF in self.subviews {
            if viewF.isKindOfClass(UILabel) {
                let labelFont : UILabel = viewF as! UILabel
                if sender.tag  ==  labelFont.tag{
                    labelFont.textColor = WMColor.light_blue
                }else{
                     labelFont.textColor = WMColor.empty_gray
                }
            }
            if viewF.isKindOfClass(UIButton) {
                for btnView in viewF.subviews {
                    if  btnView.isKindOfClass(UILabel) {
                        let view : UILabel  = btnView as! UILabel
                        view.textColor = WMColor.dark_gray
                    }
                }
            }
        }
        
        for viewF in btnSelected.subviews {
            if  viewF.isKindOfClass(UILabel) {
                let view : UILabel  = viewF as! UILabel
                view.textColor = WMColor.light_blue
            }
        }
        
        
        print("payment:::: \(selected) :::")
    }
    
    func deselectOptions(){
        if afterButton != nil{
            afterButton!.selected = false
            
            for viewF in self.subviews {
                if viewF.isKindOfClass(UILabel) {
                    let labelFont : UILabel = viewF as! UILabel
                        labelFont.textColor = WMColor.empty_gray
                }
                if viewF.isKindOfClass(UIButton) {
                    for btnView in viewF.subviews {
                        if  btnView.isKindOfClass(UILabel) {
                            let view : UILabel  = btnView as! UILabel
                            view.textColor = WMColor.dark_gray
                        }
                    }
                }
            }
        }
    }
}