//
//  ReferedForm.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol ReferedFormDelegate {
    func selectSaveButton(name: String, mail: String)
    func selectCloseButton()
}

class ReferedForm: UIView,TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate {
    
    var headerView: UIView!
    var titleSection : UILabel!
    var errorView: FormFieldErrorView!
    var scrollForm: TPKeyboardAvoidingScrollView!
    var confirmLabel: UILabel!
    var name : FormFieldView!
    var email : FormFieldView!
    var saveButton: UIButton?
    var delegate: ReferedFormDelegate?
    var layerLine: CALayer!
    let leftRightPadding  : CGFloat = CGFloat(16)
    let errorLabelWidth  : CGFloat = CGFloat(150)
    let fieldHeight  : CGFloat = CGFloat(40)
    let separatorField  : CGFloat = CGFloat(12)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.layer.insertSublayer(layerLine, atIndex: 0)
        
        self.scrollForm = TPKeyboardAvoidingScrollView(frame: self.frame)
        self.scrollForm.delegate = self
        self.scrollForm.scrollDelegate = self
        self.scrollForm.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.scrollForm)
        
        self.titleSection = UILabel()
        self.titleSection!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleSection!.text =  NSLocalizedString("refered.form.title", comment: "")
        self.titleSection!.textColor = WMColor.light_blue
        self.titleSection!.textAlignment = .Left
        self.scrollForm.addSubview(self.titleSection!)
        
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, vc!.view.frame.width , 30), inputViewStyle: .Keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            if field != nil {
                field?.resignFirstResponder()
            }
        })
        
        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder(NSLocalizedString("refered.input.name", comment: ""))
        self.name!.typeField = TypeField.Name
        self.name!.nameField = NSLocalizedString("refered.input.name", comment: "")
        self.name!.minLength = 3
        self.name!.maxLength = 25
        self.name!.inputAccessoryView = viewAccess
        self.scrollForm.addSubview(self.name!)
        
        self.email = FormFieldView()
        self.email!.isRequired = true
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.email",comment:""))
        self.email!.keyboardType = UIKeyboardType.EmailAddress
        self.email!.typeField = TypeField.Email
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.email!.maxLength = 45
        self.email!.autocapitalizationType = UITextAutocapitalizationType.None
        self.email!.inputAccessoryView = viewAccess
        self.scrollForm.addSubview(self.email!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("refered.button.send",comment:""), forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(ReferedForm.save), forControlEvents: UIControlEvents.TouchUpInside)
        self.scrollForm.addSubview(saveButton!)
        
        self.confirmLabel = UILabel()
        self.confirmLabel!.font = WMFont.fontMyriadProLightOfSize(14)
        self.confirmLabel!.text =  NSLocalizedString("refered.label.confirm",comment:"")
        self.confirmLabel!.textColor = WMColor.dark_gray
        self.confirmLabel!.textAlignment = .Center
        self.confirmLabel!.hidden = true
        self.scrollForm.addSubview(self.confirmLabel!)
        
        self.layer.insertSublayer(layerLine, atIndex: 0)
        self.addHeaderAndTitle(NSLocalizedString("refered.title.showrefered",comment:""))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollForm.frame = CGRectMake(0, 0, self.frame.width , self.frame.height)
        self.titleSection.frame = CGRectMake(leftRightPadding,58,self.frame.width - leftRightPadding,16)
        self.name.frame = CGRectMake(leftRightPadding,titleSection.frame.maxY + separatorField,self.frame.width - (leftRightPadding * 2),fieldHeight)
        self.email.frame = CGRectMake(leftRightPadding,name.frame.maxY + separatorField,self.frame.width - (leftRightPadding * 2),fieldHeight)
        self.scrollForm.contentSize = CGSize(width: self.frame.width,height: email.frame.maxY + separatorField - 2)
        self.layerLine.frame = CGRectMake(0,email.frame.maxY + separatorField,self.frame.width,1)
        self.saveButton!.frame = CGRectMake((self.frame.width - 98) / 2,layerLine.frame.maxY + 12,98,34)
        self.confirmLabel!.frame = CGRectMake((self.frame.width - 98) / 2,layerLine.frame.maxY + 12,98,34)
    }
    
    func validate() -> Bool{
        var error = viewError(name!)
        if !error{
            error = viewError(email!)
        }
        if error{
            return false
        }
        return true
    }
    
    func viewError(field: FormFieldView)-> Bool{
        let message = field.validate()
        if message != nil  {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field, nameField:field.nameField, message: message! ,errorView:self.errorView!, becomeFirstResponder: true)
            return true
        }
        return false
    }
    
    //MARK: TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        let val = CGSizeMake(self.frame.width, self.scrollForm.contentSize.height)
        return val
    }

    
    func save(){
        if self.validate(){
            delegate?.selectSaveButton(name.text!, mail: email.text!)
        }
    }
    
    func close(){
        delegate?.selectCloseButton()
    }
    
    func addHeaderAndTitle(title:String){
        headerView = UIView(frame: CGRectMake(0, 0, self.frame.width, 46))
        headerView.backgroundColor = WMColor.light_light_gray
        self.scrollForm.addSubview(headerView)
        
        let titleLabel = UILabel(frame: headerView.bounds)
        titleLabel.textColor =  WMColor.light_blue
        titleLabel.textAlignment = .Center
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.numberOfLines = 2
        titleLabel.text = title
        titleLabel.textAlignment = .Center
        
        let viewButton = UIButton(frame: CGRectMake(6, 3, 40, 40))
        viewButton.addTarget(self, action: #selector(ReferedForm.close), forControlEvents: UIControlEvents.TouchUpInside)
        viewButton.setImage(UIImage(named: "detail_close"), forState: UIControlState.Normal)
        headerView.addSubview(viewButton)
        headerView.addSubview(titleLabel)
    }
    
    func showReferedUser(name:String,mail:String){
        self.email.text = mail
        self.name.text = name
        self.email.enabled = false
        self.name.enabled = false
        self.saveButton?.hidden = true
        self.confirmLabel?.hidden = false
    }
}