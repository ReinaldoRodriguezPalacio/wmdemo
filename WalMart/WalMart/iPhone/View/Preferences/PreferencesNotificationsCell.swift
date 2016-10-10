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
    func editPhone(inEdition edition:Bool,field:FormFieldView)
}

class PreferencesNotificationsCell: UITableViewCell,CMSwitchViewDelegate,UITextFieldDelegate {
    
    var delegate : PreferencesNotificationsCellDelegate!
    var viewblock : UIView?
    var titleBlock : UILabel?
    var descriptionBlock : UILabel?
    var switchBlock : CMSwitchView?
    var phoneField: FormFieldView?
    var errorView : FormFieldErrorView? = nil
    
    var phoneSelected = false
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
        descriptionBlock!.text = description
        descriptionBlock!.numberOfLines =  0
        descriptionBlock!.lineBreakMode = .ByWordWrapping
        
        switchBlock = CMSwitchView(frame: CGRectMake(self.frame.width - (16 + 34), descriptionBlock!.frame.midY - 17  , 54, 34))
        switchBlock!.borderWidth = 0
        switchBlock!.dotColor = UIColor.whiteColor()
        switchBlock!.dotBorderColor = WMColor.light_gray
        switchBlock!.color = WMColor.empty_gray
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
        descriptionBlock!.frame = CGRect(x:16 , y:titleBlock!.frame.maxY + 8 , width:self.frame.width - (28 + 60) , height: 0)
        descriptionBlock!.sizeToFit()
        descriptionBlock!.frame.size = descriptionBlock!.bounds.size
        switchBlock!.frame =  CGRectMake(self.frame.width - (32 + 34), descriptionBlock!.frame.midY - 17  , 54, 34)
        self.separator!.frame =  CGRectMake(0.0, self.bounds.height - 1, bounds.width, 1.0)
    }
    
    func setValues(title:String,description:String,isOn:Bool,contenField:Bool,position:Int,phone:String){
        
        self.titleBlock?.text = title
        self.descriptionBlock?.text = description
        switchBlock!.drawSelected(isOn)
        switchBlock!.borderColor = isOn ? WMColor.green :  WMColor.reg_gray
        self.separator?.hidden = position == 2
        self.switchBlock?.tag = position
       
        
        if contenField {
            let viewAccess = FieldInputView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44), inputViewStyle: .Keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
                self.delegate.editPhone(inEdition: false,field: self.phoneField!)
                self.endEditing(true)
            })
            if self.phoneField == nil {
                self.phoneField = FormFieldView(frame: CGRectMake(16, descriptionBlock!.frame.maxY + 8.0, self.frame.width - 32, 44))
            }
            self.phoneField!.isRequired = isOn
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
            self.phoneSelected = isOn
            
        }
        
        
    }
    
    
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
        switchBlock!.drawSelected(value)
        
        self.delegate.changeStatus(sender.tag, value: value)
    }
    
    func validate(cell:PreferencesNotificationsCell) -> Bool{
        
        if self.phoneSelected {
            return viewError(cell.phoneField!)
        }
        if cell.switchBlock!.isSelected {
             return viewError(cell.phoneField!)
        }
        if cell.phoneField!.text != "" {
            return viewError(cell.phoneField!)
        }
        
        self.errorView?.removeFromSuperview()
        self.errorView = nil
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
            return false
        }
        return true
    }
    
    //MARK: UITextFieldDelegate
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.delegate.editPhone(inEdition: true,field: self.phoneField!)
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text!
        let fieldString = strNSString.stringByReplacingCharactersInRange(range, withString: string)
        
        if fieldString.characters.count == 11{
                return false
        }
        
         return true
    }
    


    func textFieldDidEndEditing(textField: UITextField) {
         self.delegate.editPhone(inEdition: false,field: self.phoneField!)
    }
    
    
    
}