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
        self.name!.typeField = TypeField.Name
        self.name!.nameField = NSLocalizedString("profile.address.shiping.name",comment:"")
        self.name!.minLength = 2
        self.name!.maxLength = 25
        
        self.lastName = FormFieldView()
        self.lastName!.isRequired = true
        self.lastName!.setCustomPlaceholder(NSLocalizedString("profile.address.shiping.lastname",comment:""))
        self.lastName!.typeField = TypeField.String
        self.lastName!.nameField = NSLocalizedString("profile.address.shiping.lastname",comment:"")
        self.lastName!.minLength = 2
        self.lastName!.maxLength = 25
        
        self.titleLabelShiping = UILabel()
        
        self.titleLabelShiping!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabelShiping!.text =  NSLocalizedString("profile.address.personal.data", comment: "")
        
        //if !isLogin {
            self.titleLabelShiping!.textColor = WMColor.light_blue
            self.titleLabelShiping!.backgroundColor = UIColor.whiteColor()
        /*}else {
            self.titleLabelShiping!.backgroundColor = UIColor.clearColor()
            self.titleLabelShiping.textColor = UIColor.whiteColor()
        }*/
        
        self.addSubview(name!)
        self.addSubview(lastName!)
        self.addSubview(telephone!)
        self.addSubview(titleLabelShiping!)
        
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
        self.titleLabelShiping?.frame = CGRectMake(leftRightPadding,  0, self.bounds.width - (leftRightPadding*2), fieldHeight)
        /*if !isLogin {
            self.lineViewShiping?.frame = CGRectMake(0,0,self.bounds.width,1)
        }
        else {
            self.lineViewShiping?.frame = CGRectMake(leftRightPadding, 0, self.bounds.width - (leftRightPadding*2), 1)
        }*/
        self.name?.frame = CGRectMake(leftRightPadding,  self.titleLabelShiping!.frame.maxY , self.bounds.width - (leftRightPadding*2), fieldHeight)
        self.lastName?.frame = CGRectMake(leftRightPadding, self.name!.frame.maxY + 8, self.shortNameField!.frame.width, fieldHeight)
         self.telephone?.frame = CGRectMake(leftRightPadding,  lastName!.frame.maxY + 8, self.shortNameField!.frame.width, fieldHeight)
        self.viewAddress.frame = CGRectMake(0, self.telephone!.frame.maxY + 8, self.bounds.width, showSuburb == true ? self.store!.frame.maxY : self.zipcode!.frame.maxY )
    }
    
    
    override func setItemWithDictionary(itemValues: NSDictionary) {
        super.setItemWithDictionary(itemValues)
        if self.item != nil && self.idAddress != nil {
            self.name!.text = self.item!["firstName"] as? String
            self.lastName!.text = self.item!["lastName"] as? String
            self.telephone!.text = self.item!["phoneNumber"] as? String
        }
    }
    
    override func validateAddress() -> Bool{
        var error = viewError(name!)
        if !error{
            error = viewError(lastName!)
        }
        if !error{
            error = viewError(telephone!)
            let toValidate : NSString = telephone!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if toValidate.length > 2 {
                if toValidate == "0000000000" || toValidate.substringToIndex(2) == "00" {
                    error = self.viewError(telephone!, message: NSLocalizedString("field.validate.telephone.invalid",comment:""))
                }
            }
        }
        if error{
            return false
        }
        return super.validateAddress()
    }
    
    override func getParams() -> [String:AnyObject]{
        var paramsAddress : [String:AnyObject] =   super.getParams()
        let userParams: [String:AnyObject] = ["profile":["lastName2":"" ,"name":self.name!.text! ,"lastName":self.lastName!.text! ]] as [String:AnyObject]
        paramsAddress.updateValue(userParams as AnyObject, forKey: "user")
        paramsAddress.updateValue(self.telephone!.text!, forKey: "TelNumber")
        return paramsAddress
    }
    
    
}
