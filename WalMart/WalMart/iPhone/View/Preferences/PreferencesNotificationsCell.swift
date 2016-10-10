//
//  PreferencesNotificationsCell.swift
//  WalMart
//
//  Created by Joel Juarez on 05/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

protocol PreferencesNotificationsCellDelegate {
    func changeStatus(row:Int,value:Bool)
    func editPhone(inEdition edition:Bool)
}

class PreferencesNotificationsCell: UITableViewCell,CMSwitchViewDelegate,UITextFieldDelegate {
    
    var delegate : PreferencesNotificationsCellDelegate!
    var viewblock : UIView?
    var titleBlock : UILabel?
    var descriptionBlock : UILabel?
    var switchBlock : CMSwitchView?
    var phoneField: FormFieldView?
    var errorView : FormFieldErrorView? = nil
    
    var validatePhone : (() -> Void)? = nil

    var separator : UIView?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    
    
    func setup(){
        print("setup : setup")
        
        
        titleBlock =  UILabel(frame: CGRect(x:16 , y:0 , width:self.frame.width - 32 , height: 46))
        titleBlock!.font = WMFont.fontMyriadProLightOfSize(14)
        titleBlock!.textColor =  WMColor.light_blue
        
        descriptionBlock =  UILabel(frame: CGRect(x:16 , y:titleBlock!.frame.maxY + 16 , width:self.frame.width - (28 + 60) , height: 48))
        descriptionBlock!.font = WMFont.fontMyriadProRegularOfSize(14)
        descriptionBlock!.textColor =  WMColor.reg_gray
        descriptionBlock!.text =  description
        descriptionBlock!.numberOfLines =  3
        
        switchBlock = CMSwitchView(frame: CGRectMake(self.frame.width - (16 + 34), descriptionBlock!.frame.midY - 17  , 54, 34))
        switchBlock!.borderWidth = 1
        switchBlock!.borderColor = WMColor.reg_gray
        switchBlock!.dotColor = UIColor.whiteColor()
        switchBlock!.dotBorderColor = WMColor.light_gray
        switchBlock!.color = WMColor.reg_gray
        switchBlock!.tintColor = WMColor.green
        switchBlock!.delegate =  self
        switchBlock!.dotWeight = 32.0
        separator = UIView()
        separator!.backgroundColor = WMColor.light_gray
        
        self.addSubview(self.separator!)
        self.addSubview(titleBlock!)
        self.addSubview(descriptionBlock!)
        self.addSubview(switchBlock!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleBlock!.frame = CGRect(x:16 , y:0 , width:self.frame.width - 32 , height: 46)
        descriptionBlock!.frame = CGRect(x:16 , y:titleBlock!.frame.maxY + 16 , width:self.frame.width - (28 + 60) , height: 48)
        switchBlock!.frame =  CGRectMake(self.frame.width - (32 + 34), descriptionBlock!.frame.midY - 17  , 54, 34)

        
        self.separator!.frame =  CGRectMake(0.0, self.bounds.height - 1, bounds.width, 1.0)
    }
    
    func setValues(title:String,description:String,isOn:Bool,contenField:Bool,position:Int,phone:String){
        self.titleBlock?.text = title
        self.descriptionBlock?.text = description
        switchBlock!.drawSelected(isOn)
        switchBlock!.borderColor = isOn ? WMColor.green :  WMColor.reg_gray
        
        self.switchBlock?.tag = position
        if contenField {
            let viewAccess = FieldInputView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44), inputViewStyle: .Keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
                self.delegate.editPhone(inEdition: false)
                self.phoneField!.resignFirstResponder()
            })
            self.phoneField = FormFieldView(frame: CGRectMake(16, descriptionBlock!.frame.maxY + 8.0, self.frame.width - 32, 44))
            self.phoneField!.isRequired = false
            self.phoneField!.typeField = TypeField.Phone
            self.phoneField!.nameField = "Teléfono"
            self.phoneField!.maxLength = 10
            self.phoneField!.minLength = 10
            self.phoneField!.text = phone
            self.phoneField!.disablePaste = true
            self.phoneField!.keyboardType = UIKeyboardType.NumberPad
            self.phoneField!.hidden =  !isOn
            self.phoneField!.inputAccessoryView = viewAccess
            self.phoneField!.delegate = self
            self.addSubview(self.phoneField!)
        }
    }
    var phoneSelected = false
    
    //MARK:CMSwitchViewDelegate
    func switchValueChanged(sender: AnyObject!, andNewValue value: Bool) {
        switchBlock!.borderColor = value ? WMColor.green :  WMColor.reg_gray
        if sender.tag == 2 {
            self.phoneField!.isRequired = value
            self.phoneField?.hidden =  !value
            if !value {
                self.phoneField!.text = ""
                self.errorView?.removeFromSuperview()
                self.errorView = nil
               phoneSelected = false
            }else{
                phoneSelected = true
            }
        }
        
        self.delegate.changeStatus(sender.tag, value: value)
    }
    
    func validate() -> Bool{
        if self.phoneSelected  {
            return self.viewError(self.phoneField!,message: NSLocalizedString("Es requerido para recibir información SMS",comment:""))
        }
        return true
    }
    
    func viewError(field: FormFieldView)-> Bool{
        let message = field.validate()
        return self.viewError(field,message: message)
    }
    
    func viewError(field: FormFieldView,message:String?)-> Bool{
        if message != nil {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field, nameField:field.nameField, message: message! ,errorView:self.errorView!,  becomeFirstResponder: true )
            return true
        }
        return false
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        print("textFieldDidBeginEditing")
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
     print("textFieldShouldBeginEditing")
        self.delegate.editPhone(inEdition: true)
        return true
    }
    
    
    
    
}