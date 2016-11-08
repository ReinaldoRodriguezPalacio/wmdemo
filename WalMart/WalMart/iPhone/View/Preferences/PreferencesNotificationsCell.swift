//
//  PreferencesNotificationsCell.swift
//  WalMart
//
//  Created by Joel Juarez on 05/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

protocol PreferencesNotificationsCellDelegate {
    func changeStatus(_ row:Int,value:Bool)
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
        descriptionBlock!.lineBreakMode = .byWordWrapping
        
        switchBlock = CMSwitchView(frame: CGRect(x: self.frame.width - (16 + 34), y: descriptionBlock!.frame.midY - 17  , width: 54, height: 34))
        switchBlock!.borderWidth = 0
        switchBlock!.dotColor = UIColor.white
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
        switchBlock!.frame =  CGRect(x: self.frame.width - (32 + 34), y: descriptionBlock!.frame.midY - 17  , width: 54, height: 34)
        self.separator!.frame =  CGRect(x: 0.0, y: self.bounds.height - 1, width: bounds.width, height: 1.0)
    }
    
    func setValues(_ title:String,description:String,isOn:Bool,contenField:Bool,position:Int,phone:String){
        
        self.titleBlock?.text = title
        self.descriptionBlock?.text = description
        switchBlock!.drawSelected(isOn)
        switchBlock!.borderColor = isOn ? WMColor.green :  WMColor.reg_gray
        self.separator?.isHidden = position == 2
        self.switchBlock?.tag = position
       
        
        if contenField {
            let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44), inputViewStyle: .keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
                self.delegate.editPhone(inEdition: false,field: self.phoneField!)
                self.endEditing(true)
            })
            if self.phoneField == nil {
                self.phoneField = FormFieldView(frame: CGRect(x: 16, y: descriptionBlock!.frame.maxY - 16.0, width: self.frame.width - 32, height: 44))
            }
            self.phoneField!.isRequired = isOn
            self.phoneField!.typeField = TypeField.phone
            self.phoneField!.nameField = "Teléfono"
            self.phoneField!.maxLength = 10
            self.phoneField!.minLength = 10
            self.phoneField!.text = phone
            self.phoneField!.disablePaste = true
            self.phoneField!.keyboardType = UIKeyboardType.numberPad
            self.phoneField!.isHidden =  !isOn
            self.phoneField!.inputAccessoryView = viewAccess
            self.phoneField!.delegate = self
            self.addSubview(self.phoneField!)
            self.phoneSelected = isOn
            
        }
        
        
    }
    
    
    //MARK:CMSwitchViewDelegate
    func switchValueChanged(_ sender: Any!, andNewValue value: Bool) {
        switchBlock!.borderColor = value ? WMColor.green :  WMColor.reg_gray
        if (sender as AnyObject).tag == 2 {
            self.phoneField!.isRequired = value
            self.phoneField?.isHidden =  !value
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
        
        self.delegate.changeStatus((sender as AnyObject).tag, value: value)
    }
    
    func validate(_ cell:PreferencesNotificationsCell) -> Bool{
        
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
    
    func viewError(_ field: FormFieldView)-> Bool{
        let message = field.validate()
        return self.viewError(field,message: message)
    }
    
    func viewError(_ field: FormFieldView,message:String?)-> Bool{
        
        if message != nil {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field, nameField:field.nameField, message: message! ,errorView:self.errorView!,  becomeFirstResponder: true )
            return false
        }
        
        if errorView != nil {
            self.errorView?.removeFromSuperview()
        }
        
        return true
    }
    
    //MARK: UITextFieldDelegate
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.delegate.editPhone(inEdition: true,field: self.phoneField!)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        let fieldString = strNSString.replacingCharacters(in: range, with: string)
        
        if fieldString.characters.count == 11{
                return false
        }
        
         return true
    }
    


    func textFieldDidEndEditing(_ textField: UITextField) {
         self.delegate.editPhone(inEdition: false,field: self.phoneField!)
    }
    
    
    
}
