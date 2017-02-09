//
//  ShippingAddress.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 23/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class ShippingAddress: AddressView {

    var name : FormFieldView? = nil
    var lastName : FormFieldView? = nil
    var titleLabelBetween : UILabel!
    var betweenStrets : FormFieldView!
    var reference : FormFieldView!
   
    var titleLabelShiping: UILabel!
    //var lineViewShiping : UIView!

    override init(frame: CGRect, isLogin: Bool, isIpad:Bool, typeAddress: TypeAddress) {
        super.init(frame: frame, isLogin: isLogin, isIpad: isIpad, typeAddress: typeAddress )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup(){
        super.setup()
        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder(NSLocalizedString("profile.address.shiping.name",comment:""))
        self.name!.typeField = TypeField.name
        self.name!.nameField = NSLocalizedString("profile.address.shiping.name",comment:"")
        self.name!.minLength = 2
        self.name!.maxLength = 25
        
        self.lastName = FormFieldView()
        self.lastName!.isRequired = true
        self.lastName!.setCustomPlaceholder(NSLocalizedString("profile.address.shiping.lastname",comment:""))
        self.lastName!.typeField = TypeField.string
        self.lastName!.nameField = NSLocalizedString("profile.address.shiping.lastname",comment:"")
        self.lastName!.minLength = 2
        self.lastName!.maxLength = 25
        
        self.titleLabelShiping = UILabel()
        
        self.titleLabelShiping!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabelShiping!.text =  NSLocalizedString("profile.address.personal.data", comment: "")
        
        //if !isLogin {
            self.titleLabelShiping!.textColor = WMColor.light_blue
            self.titleLabelShiping!.backgroundColor = UIColor.white
        /*}else {
            self.titleLabelShiping!.backgroundColor = UIColor.clearColor()
            self.titleLabelShiping.textColor = UIColor.whiteColor()
        }*/
        
        self.addSubview(name!)
        self.addSubview(lastName!)
        self.addSubview(telephone!)
        self.addSubview(titleLabelShiping!)
        
        //Add title
        
        self.titleLabelBetween = UILabel()
        self.titleLabelBetween!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabelBetween!.text =  NSLocalizedString("gr.address.section.between.title", comment: "")
        self.titleLabelBetween!.textColor = WMColor.light_blue
        
        self.betweenStrets = FormFieldView()
        self.betweenStrets!.isRequired = false
        self.betweenStrets!.setCustomPlaceholder(NSLocalizedString("gr.address.field.betweenFisrt",comment:""))
        self.betweenStrets!.typeField = TypeField.alphanumeric
        self.betweenStrets!.nameField = NSLocalizedString("gr.address.field.betweenFisrt",comment:"")
        self.betweenStrets!.minLength = 2
        self.betweenStrets!.maxLength = 50
    
        
        self.reference = FormFieldView()
        self.reference!.isRequired = false
        self.reference!.setCustomPlaceholder(NSLocalizedString("gr.address.field.holder",comment:""))
        self.reference!.typeField = TypeField.alphanumeric
        self.reference!.nameField = NSLocalizedString("gr.address.field.betweenReference",comment:"")
        self.reference!.minLength = 2
        self.reference!.maxLength = 50
        
        self.addSubview(titleLabelBetween!)
        self.addSubview(betweenStrets!)
        self.addSubview(reference!)
        
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
        self.titleLabelShiping?.frame = CGRect(x: leftRightPadding,  y: 0, width: self.bounds.width - (leftRightPadding*2), height: fieldHeight)
        /*if !isLogin {
            self.lineViewShiping?.frame = CGRectMake(0,0,self.bounds.width,1)
        }
        else {
            self.lineViewShiping?.frame = CGRectMake(leftRightPadding, 0, self.bounds.width - (leftRightPadding*2), 1)
        }*/
        self.name?.frame = CGRect(x: leftRightPadding,  y: self.titleLabelShiping!.frame.maxY , width: self.bounds.width - (leftRightPadding*2), height: fieldHeight)
        self.lastName?.frame = CGRect(x: leftRightPadding, y: self.name!.frame.maxY + 8, width: self.shortNameField!.frame.width, height: fieldHeight)
         self.telephone?.frame = CGRect(x: leftRightPadding,  y: lastName!.frame.maxY + 8, width: self.shortNameField!.frame.width, height: fieldHeight)
        self.viewAddress.frame = CGRect(x: 0, y: self.telephone!.frame.maxY + 8, width: self.bounds.width, height: showSuburb == true ? self.store!.frame.maxY : self.zipcode!.frame.maxY )
        
        self.titleLabelBetween.frame =  CGRect(x: leftRightPadding,  y: self.viewAddress.frame.maxY , width: self.bounds.width - (leftRightPadding*2), height: fieldHeight)
        self.betweenStrets.frame =  CGRect(x: leftRightPadding,  y: self.titleLabelBetween.frame.maxY  , width: self.bounds.width - (leftRightPadding*2), height: fieldHeight)
        self.reference.frame =  CGRect(x: leftRightPadding,  y: self.betweenStrets.frame.maxY + 8, width: self.bounds.width - (leftRightPadding*2), height: fieldHeight)
        
    }
    
    
    override func setItemWithDictionary(_ itemValues: [String:Any]) {
        super.setItemWithDictionary(itemValues)
        if self.item != nil && self.idAddress != nil {
            self.name!.text = self.item!["firstName"] as? String
            self.lastName!.text = self.item!["lastName"] as? String
            self.telephone!.text = self.item!["mobileNumber"] as? String
            self.betweenStrets.text = self.item!["btwStreets"] as? String
            self.reference.text = self.item!["reference"] as? String
            
        }
    }
    
    override func validateAddress() -> Bool{
        var error = viewError(name!)
        if !error{
            error = viewError(lastName!)
        }
        if !error{
            error = viewError(telephone!)
            let toValidate : NSString = telephone!.text!.trimmingCharacters(in: CharacterSet.whitespaces) as NSString
            if toValidate.length > 2 {
                if toValidate == "0000000000" || toValidate.substring(to: 2) == "00" {
                    error = self.viewError(telephone!, message: NSLocalizedString("field.validate.telephone.invalid",comment:""))
                }
            }
        }
        if error{
            return false
        }
        return super.validateAddress()
    }
    
     override func getParams() -> [String:Any] {
        var paramsAdd : [String:Any]? = [:]
        paramsAdd!.update(from: super.getParams())
        //TODO : Agrear parametros
        paramsAdd!.update(from: ["firstName":self.name!.text! ,"lastName":self.lastName!.text!,"phoneNumber":self.telephone!.text!,"phoneExtension":"","mobileNumber":self.telephone!.text ?? "","reference":self.reference!.text ?? "","btwStreets":self.betweenStrets!.text ?? ""])
        return paramsAdd!
        
    }
}
