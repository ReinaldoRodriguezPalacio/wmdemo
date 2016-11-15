//
//  PaymentOptionsView.swift
//  WalMart
//
//  Created by Joel Juarez on 18/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation



class PaymentOptionsView : UIView {
    
    var paymentItems : [Any] = []
    var afterButton :UIButton?
    var selectedOption : ((_ selected:String, _ stringSelected:String) -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    init(frame: CGRect,items: [Any]) {
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
                let paymentTupeItem = payment as! [String:Any]
                if paymentTupeItem["paymentType"] as! String != "Paypal" {
                    let titleLabel = UILabel(frame:CGRect(x: 22, y: 0, width: widthField - 22,height: 22))
                    titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
                    titleLabel.text = paymentTupeItem["paymentType"] as? String
                    titleLabel.numberOfLines = 2
                    titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    titleLabel.textColor = WMColor.dark_gray
                    titleLabel.tag = count
                
                    let promSelect = UIButton(frame: CGRect(x: 0,y: posY,width: widthField,height: 22))
                    promSelect.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
                    promSelect.setImage(UIImage(named:"check_full"), for: UIControlState.selected)
                    promSelect.addTarget(self, action: #selector(PaymentOptionsView.paymentCheckSelected(_:)), for: UIControlEvents.touchUpInside)
                    promSelect.addSubview(titleLabel)
                    promSelect.isSelected = false
                    promSelect.tag = count
                    promSelect.imageEdgeInsets = UIEdgeInsetsMake(0,0,0,widthField - 20)
                    self.addSubview(promSelect)
                
                    let descriptionLabel = UILabel(frame:CGRect(x: 22,y: promSelect.frame.maxY , width: widthField - 22,height: 14))
                    descriptionLabel.font = WMFont.fontMyriadProRegularOfSize(12)
                    descriptionLabel.text = ""//self.assingDescription(titleLabel.text!)Se comenta descripcion por peticion de usuario
                    descriptionLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
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
    
    /**
    Get description to payment types
    
    - parameter value: Type pyment
    
    - returns:description to payment type
    */
    func assingDescription(_ value:String) -> String{
        
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
            if viewF.isKind(of: UIButton.self) {
                if viewF.tag == 0{
                    self.paymentCheckSelected(viewF as! UIButton)
                }
            }
            
        }
    }


    /**
     Select and deselect pyment type in checkout
     
     - parameter sender: payment type button
     */
    func paymentCheckSelected(_ sender: UIButton){
        if(sender.isSelected){
            sender.isSelected = sender == afterButton ? true : false
        }
        else{
            if afterButton != nil{
                afterButton!.isSelected = false
            }
            sender.isSelected = true
            afterButton = sender
        }
        
        let paymentItemSelect = self.paymentItems[sender.tag] as! [String:Any]
        let selected = paymentItemSelect["id"] as! String
        self.selectedOption!(selected,paymentItemSelect["paymentType"] as! String)
       
        let btnSelected : UIButton =  sender

        
        for viewF in self.subviews {
            if viewF.isKind(of: UILabel.self) {
                let labelFont : UILabel = viewF as! UILabel
                if sender.tag  ==  labelFont.tag{
                    labelFont.textColor = WMColor.light_blue
                }else{
                     labelFont.textColor = WMColor.empty_gray
                }
            }
            if viewF.isKind(of: UIButton.self) {
                for btnView in viewF.subviews {
                    if  btnView.isKind(of: UILabel.self) {
                        let view : UILabel  = btnView as! UILabel
                        view.textColor = WMColor.dark_gray
                    }
                }
            }
        }
        
        for viewF in btnSelected.subviews {
            if  viewF.isKind(of: UILabel.self) {
                let view : UILabel  = viewF as! UILabel
                view.textColor = WMColor.light_blue
            }
        }
        
        
        print("payment:::: \(selected) :::")
    }
    
    /**
     Cleaning options payment type, changed colors to labels
     */
    func deselectOptions(){
        if afterButton != nil{
            afterButton!.isSelected = false
            
            for viewF in self.subviews {
                if viewF.isKind(of: UILabel.self) {
                    let labelFont : UILabel = viewF as! UILabel
                        labelFont.textColor = WMColor.empty_gray
                }
                if viewF.isKind(of: UIButton.self) {
                    for btnView in viewF.subviews {
                        if  btnView.isKind(of: UILabel.self) {
                            let view : UILabel  = btnView as! UILabel
                            view.textColor = WMColor.dark_gray
                        }
                    }
                }
            }
        }
    }
}
