//
//  ReferedForm.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol ReferedFormDelegate: class {
    func selectSaveButton(_ name: String, mail: String)
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
    weak var delegate: ReferedFormDelegate?
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
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(layerLine, at: 0)
        
        self.scrollForm = TPKeyboardAvoidingScrollView(frame: self.frame)
        self.scrollForm.delegate = self
        self.scrollForm.scrollDelegate = self
        self.scrollForm.backgroundColor = UIColor.white
        self.addSubview(self.scrollForm)
        
        self.titleSection = UILabel()
        self.titleSection!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleSection!.text =  NSLocalizedString("refered.form.title", comment: "")
        self.titleSection!.textColor = WMColor.light_blue
        self.titleSection!.textAlignment = .left
        self.scrollForm.addSubview(self.titleSection!)
        
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: vc!.view.frame.width , height: 30), inputViewStyle: .keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            if field != nil {
                field?.resignFirstResponder()
            }
        })
        
        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder(NSLocalizedString("refered.input.name", comment: ""))
        self.name!.typeField = TypeField.name
        self.name!.nameField = NSLocalizedString("refered.input.name", comment: "")
        self.name!.minLength = 3
        self.name!.maxLength = 25
        self.name!.inputAccessoryView = viewAccess
        self.scrollForm.addSubview(self.name!)
        
        self.email = FormFieldView()
        self.email!.isRequired = true
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.email",comment:""))
        self.email!.keyboardType = UIKeyboardType.emailAddress
        self.email!.typeField = TypeField.email
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.email!.maxLength = 45
        self.email!.autocapitalizationType = UITextAutocapitalizationType.none
        self.email!.inputAccessoryView = viewAccess
        self.scrollForm.addSubview(self.email!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("refered.button.send",comment:""), for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(ReferedForm.save), for: UIControlEvents.touchUpInside)
        self.scrollForm.addSubview(saveButton!)
        
        self.confirmLabel = UILabel()
        self.confirmLabel!.font = WMFont.fontMyriadProLightOfSize(14)
        self.confirmLabel!.text =  NSLocalizedString("refered.label.confirm",comment:"")
        self.confirmLabel!.textColor = WMColor.dark_gray
        self.confirmLabel!.textAlignment = .center
        self.confirmLabel!.isHidden = true
        self.scrollForm.addSubview(self.confirmLabel!)
        
        self.layer.insertSublayer(layerLine, at: 0)
        self.addHeaderAndTitle(NSLocalizedString("refered.title.showrefered",comment:""))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollForm.frame = CGRect(x: 0, y: 0, width: self.frame.width , height: self.frame.height)
        self.titleSection.frame = CGRect(x: leftRightPadding,y: 58,width: self.frame.width - leftRightPadding,height: 16)
        self.name.frame = CGRect(x: leftRightPadding,y: titleSection.frame.maxY + separatorField,width: self.frame.width - (leftRightPadding * 2),height: fieldHeight)
        self.email.frame = CGRect(x: leftRightPadding,y: name.frame.maxY + separatorField,width: self.frame.width - (leftRightPadding * 2),height: fieldHeight)
        self.scrollForm.contentSize = CGSize(width: self.frame.width,height: email.frame.maxY + separatorField - 2)
        self.layerLine.frame = CGRect(x: 0,y: email.frame.maxY + separatorField,width: self.frame.width,height: 1)
        self.saveButton!.frame = CGRect(x: (self.frame.width - 98) / 2,y: layerLine.frame.maxY + 12,width: 98,height: 34)
        self.confirmLabel!.frame = CGRect(x: (self.frame.width - 98) / 2,y: layerLine.frame.maxY + 12,width: 98,height: 34)
    }
    /**
     Validates the form data
     
     - returns: Bool returns true if the form data is complete and valid
     */
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
    
    /**
     Adds and error message
     
     - parameter field: field to validate
     
     - returns: Bool returns true if exist an error
     */
    func viewError(_ field: FormFieldView)-> Bool{
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
    
    func contentSizeForScrollView(_ sender:Any) -> CGSize {
        let val = CGSize(width: self.frame.width, height: self.scrollForm.contentSize.height)
        return val
    }

    /**
     Calls the delegate to save the refered
     */
    func save(){
        if self.validate(){
            delegate?.selectSaveButton(name.text!, mail: email.text!)
        }
    }
    /**
     Calls the delegate to close the popup view
     */
    func close(){
        delegate?.selectCloseButton()
    }
    /**
     Adds a header view with title
     
     - parameter title: view title
     */
    func addHeaderAndTitle(_ title:String){
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 46))
        headerView.backgroundColor = WMColor.light_light_gray
        self.scrollForm.addSubview(headerView)
        
        let titleLabel = UILabel(frame: headerView.bounds)
        titleLabel.textColor =  WMColor.light_blue
        titleLabel.textAlignment = .center
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.numberOfLines = 2
        titleLabel.text = title
        titleLabel.textAlignment = .center
        
        let viewButton = UIButton(frame: CGRect(x: 6, y: 3, width: 40, height: 40))
        viewButton.addTarget(self, action: #selector(ReferedForm.close), for: UIControlEvents.touchUpInside)
        viewButton.setImage(UIImage(named: "detail_close"), for: UIControlState())
        headerView.addSubview(viewButton)
        headerView.addSubview(titleLabel)
    }
    
    /**
     Shows the refered data, the fields can not be edited
     
     - parameter name: refered name
     - parameter mail: refered mail
     */
    func showReferedUser(_ name:String,mail:String){
        self.email.text = mail
        self.name.text = name
        self.email.isEnabled = false
        self.name.isEnabled = false
        self.saveButton?.isHidden = true
        self.confirmLabel?.isHidden = false
    }
}
