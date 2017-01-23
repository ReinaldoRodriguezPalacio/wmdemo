//
//  EditProfileViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 22/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol EditProfileViewControllerDelegate {
    func finishSave()
}


class EditProfileViewController: NavigationViewController,  UICollectionViewDelegate , TPKeyboardAvoidingScrollViewDelegate, AlertPickerSelectOptionDelegate, UITextFieldDelegate  {

    var content: TPKeyboardAvoidingScrollView!
    var personalInfoLabel: UILabel!
    var name: FormFieldView!
    var lastName: FormFieldView!
    var email: FormFieldView!
    
    var changePasswordLabel: UILabel!
    var passwordInfoLabel: UILabel!
    var changuePasswordButton: UIButton?
    var passworCurrent: FormFieldView?
    var password: FormFieldView?
    var confirmPassword: FormFieldView?
    
    var aditionalInfoLabel: UILabel!
    var birthDate: FormFieldView!
    var inputBirthdateView: UIDatePicker?
    var gender: FormFieldView!
    var ocupation: FormFieldView!

    var phoneInformationLabel: UILabel!
    var phoneHome: FormFieldView?
    var phoneHomeExtension: FormFieldView?
    var cellPhone: FormFieldView?
    
    var associateLabel: UILabel!
    var isAssociateButton: UIButton?
    var associateNumber: FormFieldView?
    var associateDeterminant: FormFieldView?
    var associateDate: FormFieldView?
    var inputAssociateDateView: UIDatePicker?
    
    var errorView: FormFieldErrorView?
    var alertView: IPOWMAlertViewController?
    
    var layerLine: CALayer!
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var legalInformation: UIButton?
    var legalInformationLabel: UILabel?
    
    var dateFmt: DateFormatter?
    var parseFmt: DateFormatter?
    var delegate: EditProfileViewControllerDelegate!
    
    var showPasswordInfo: Bool = false
    var showAssociateInfo: Bool = false
    var showTabbar:Bool = false
    var dateSelected : Date!
    var associateDateSelected : Date!
    var picker : AlertPickerView!
    var selectedGender: IndexPath!
    var dateBriday  = ""
    var joinDate  = ""
    
    
    var occupationList: [String]! = []
    var selectedOccupation: IndexPath?

    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_EDITPROFILE.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.titleLabel!.text = NSLocalizedString("profile.title", comment: "")
        
        self.dateFmt = DateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.setValues), name: NSNotification.Name(rawValue: ProfileNotification.updateProfile.rawValue), object: nil)
        
//        if let tracker = GAI.sharedInstance().defaultTracker {
//            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_EDITPROFILE.rawValue)
//            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
//        }
        
        self.dateFmt = DateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"

        self.parseFmt = DateFormatter()
        self.parseFmt!.dateFormat = "dd/MM/yyyy"

        self.content = TPKeyboardAvoidingScrollView()
        self.content.delegate = self
        self.content.scrollDelegate = self

        self.personalInfoLabel = UILabel()
        self.personalInfoLabel.font = WMFont.fontMyriadProLightOfSize(14)
        self.personalInfoLabel.textColor = WMColor.light_blue
        self.personalInfoLabel.text = NSLocalizedString("profile.edit.title",comment:"")
        self.content?.addSubview(self.personalInfoLabel!)
        
        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder(NSLocalizedString("profile.name",comment:""))
        self.name!.typeField = TypeField.name
        self.name!.minLength = 3
        self.name!.maxLength = 25
        self.name!.nameField = NSLocalizedString("profile.name",comment:"")
        self.content?.addSubview(self.name!)
        
        self.lastName = FormFieldView()
        self.lastName!.isRequired = true
        self.lastName!.setCustomPlaceholder(NSLocalizedString("profile.lastname",comment:""))
        self.lastName!.typeField = TypeField.string
        self.lastName!.minLength = 3
        self.lastName!.maxLength = 25
        self.lastName!.nameField = NSLocalizedString("profile.lastname",comment:"")
        self.content?.addSubview(self.lastName!)
        
        self.email = FormFieldView()
        self.email!.isRequired = true
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.email",comment:""))
        self.email!.keyboardType = UIKeyboardType.emailAddress
        self.email!.typeField = TypeField.email
        self.email!.maxLength = 45
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.email!.isEnabled = false
        self.content?.addSubview(self.email!)
        
        self.changePasswordLabel = UILabel()
        self.changePasswordLabel.font = WMFont.fontMyriadProLightOfSize(14)
        self.changePasswordLabel.textColor = WMColor.light_blue
        self.changePasswordLabel.text = NSLocalizedString("profile.password",comment:"")
        self.content?.addSubview(self.changePasswordLabel!)
        
        self.passwordInfoLabel = UILabel()
        self.passwordInfoLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.passwordInfoLabel.textColor = WMColor.dark_gray
        self.passwordInfoLabel.text =  NSLocalizedString("profile.edit.password.min",comment:"")
        self.passwordInfoLabel.alpha = 0.0
        self.content?.addSubview(self.passwordInfoLabel!)
        
        self.changuePasswordButton = UIButton()
        self.changuePasswordButton?.setTitle(NSLocalizedString("profile.edit.password.button",comment:""), for: UIControlState())
        self.changuePasswordButton!.setImage(UIImage(named:"filter_check_blue"), for: UIControlState())
        self.changuePasswordButton!.setImage(UIImage(named:"check_blue"), for: UIControlState.selected)
        self.changuePasswordButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.changuePasswordButton!.setTitleColor(WMColor.dark_gray, for: UIControlState())
        self.changuePasswordButton?.addTarget(self, action: #selector(EditProfileViewController.showPasswordData(_:)), for: UIControlEvents.touchUpInside)
        self.changuePasswordButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.changuePasswordButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.content?.addSubview(self.changuePasswordButton!)
        
        self.passworCurrent = FormFieldView()
        self.passworCurrent!.isRequired = true
        self.passworCurrent!.setCustomPlaceholder(NSLocalizedString("profile.password.current",comment:""))
        self.passworCurrent!.isSecureTextEntry = true
        self.passworCurrent!.typeField = TypeField.password
        self.passworCurrent!.nameField = NSLocalizedString("profile.password.current",comment:"")
        self.passworCurrent!.alpha = 0.0
        self.content?.addSubview(self.passworCurrent!)
        
        self.password = FormFieldView()
        self.password!.isRequired = true
        self.password!.setCustomPlaceholder(NSLocalizedString("profile.newpassword",comment:""))
        self.password!.isSecureTextEntry = true
        self.password!.typeField = TypeField.password
        self.password!.nameField = NSLocalizedString("profile.newpassword",comment:"")
        self.password!.minLength = 8
        self.password!.maxLength = 20
        self.password!.alpha = 0.0
        self.content?.addSubview(self.password!)
        
        self.confirmPassword = FormFieldView()
        self.confirmPassword!.isRequired = true
        self.confirmPassword!.setCustomPlaceholder(NSLocalizedString("profile.confirmnewpassword",comment:""))
        self.confirmPassword!.isSecureTextEntry = true
        self.confirmPassword!.typeField = TypeField.password
        self.confirmPassword!.nameField = NSLocalizedString("profile.confirmnewpassword",comment:"")
        self.confirmPassword!.minLength = 8
        self.confirmPassword!.maxLength = 20
        self.confirmPassword!.alpha = 0.0
        self.content?.addSubview(self.confirmPassword!)
        
        self.aditionalInfoLabel = UILabel()
        self.aditionalInfoLabel.font = WMFont.fontMyriadProLightOfSize(14)
        self.aditionalInfoLabel.textColor = WMColor.light_blue
        self.aditionalInfoLabel.text = NSLocalizedString("profile.edit.adtionalinfo",comment:"")
        self.content?.addSubview(self.aditionalInfoLabel!)

        self.birthDate = FormFieldView()
        self.birthDate!.isRequired = true
        self.birthDate!.setCustomPlaceholder(NSLocalizedString("profile.birthDate",comment:""))
        self.birthDate!.typeField = .none
        self.birthDate!.nameField = NSLocalizedString("profile.birthDate",comment:"")
        self.birthDate!.disablePaste = true
        self.content?.addSubview(self.birthDate!)
        
        self.gender = FormFieldView(frame:CGRect(x: 16, y: 0, width: self.view.frame.width - 32, height: 40))
        self.gender!.isRequired = false
        self.gender!.setCustomPlaceholder(NSLocalizedString("profile.gender",comment:""))
        self.gender!.typeField = TypeField.list
        self.gender!.nameField = NSLocalizedString("profile.gender",comment:"")
        self.gender!.setImageTypeField()
        self.content?.addSubview(self.gender!)
        
        self.ocupation = FormFieldView(frame:CGRect(x: 16, y: 0, width: self.view.frame.width - 32, height: 40))
        self.ocupation!.isRequired = false
        self.ocupation!.setCustomPlaceholder(NSLocalizedString("profile.edit.ocupation",comment:""))
        self.ocupation!.typeField = TypeField.list
        self.ocupation!.nameField = NSLocalizedString("profile.edit.ocupation",comment:"")
        self.ocupation!.setImageTypeField()
        self.content?.addSubview(self.ocupation!)
        
        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width , height: 44), inputViewStyle: .keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            if field != nil {
                if field == self.birthDate!{
                    self.dateChanged()
                }
                else if field == self.associateDate! {
                    self.associateDateChanged()
                }
                
                field?.resignFirstResponder()
            }
        })
        
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let currentDate = Date()
        var comps = DateComponents()
        comps.year = -18
        let maxDate = (calendar as NSCalendar).date(byAdding: comps, to: currentDate, options: NSCalendar.Options())
        comps.year = -100
        let minDate = (calendar as NSCalendar).date(byAdding: comps, to: currentDate, options: NSCalendar.Options())
        
        self.inputBirthdateView = UIDatePicker()
        self.inputBirthdateView!.datePickerMode = .date
        self.inputBirthdateView!.date = Date()
        self.inputBirthdateView!.maximumDate = maxDate
        self.inputBirthdateView!.minimumDate = minDate

        self.inputBirthdateView!.addTarget(self, action: #selector(EditProfileViewController.dateChanged), for: .valueChanged)
        self.birthDate!.inputView = self.inputBirthdateView!
        self.birthDate!.inputAccessoryView = viewAccess
        
        self.phoneInformationLabel = UILabel()
        self.phoneInformationLabel.font = WMFont.fontMyriadProLightOfSize(14)
        self.phoneInformationLabel.textColor = WMColor.light_blue
        self.phoneInformationLabel.text = NSLocalizedString("profile.edit.phoneInfo",comment:"")
        self.content?.addSubview(self.phoneInformationLabel!)
        
        self.phoneHome = FormFieldView()
        self.phoneHome!.isRequired = true
        self.phoneHome!.setCustomPlaceholder(NSLocalizedString("profile.edit.phoneDesc",comment:""))
        self.phoneHome!.typeField = TypeField.number
        self.phoneHome!.nameField = NSLocalizedString("profile.address.field.telephone.house",comment:"")
        self.phoneHome!.minLength = 8
        self.phoneHome!.maxLength = 10
        self.phoneHome!.keyboardType = UIKeyboardType.numberPad
        self.phoneHome!.inputAccessoryView = viewAccess
        self.phoneHome!.delegate =  self
        self.content?.addSubview(self.phoneHome!)
        
        self.phoneHomeExtension = FormFieldView()
        self.phoneHomeExtension!.isRequired = false
        self.phoneHomeExtension!.setCustomPlaceholder(NSLocalizedString("profile.edit.extension",comment:""))
        self.phoneHomeExtension!.typeField = TypeField.number
        self.phoneHomeExtension!.nameField = NSLocalizedString("profile.edit.extension",comment:"")
        self.phoneHomeExtension!.minLength = 3
        self.phoneHomeExtension!.maxLength = 5
        self.phoneHomeExtension!.keyboardType = UIKeyboardType.numberPad
        self.phoneHomeExtension!.inputAccessoryView = viewAccess
        self.phoneHomeExtension!.delegate =  self
        self.content?.addSubview(self.phoneHomeExtension!)
        
        self.cellPhone = FormFieldView()
        self.cellPhone!.isRequired = false
        self.cellPhone!.setCustomPlaceholder(NSLocalizedString("profile.edit.cellphoneDesc",comment:""))
        self.cellPhone!.typeField = TypeField.number
        self.cellPhone!.nameField = NSLocalizedString("profile.address.field.telephone.cell",comment:"")
        self.cellPhone!.minLength = 10
        self.cellPhone!.maxLength = 15
        self.cellPhone!.keyboardType = UIKeyboardType.numberPad
        self.cellPhone!.inputAccessoryView = viewAccess
        self.cellPhone!.delegate =  self
        self.content?.addSubview(self.cellPhone!)
        
        self.associateLabel = UILabel()
        self.associateLabel.font = WMFont.fontMyriadProLightOfSize(14)
        self.associateLabel.textColor = WMColor.light_blue
        self.associateLabel.text = NSLocalizedString("profile.edit.associate",comment:"")
        self.content?.addSubview(self.associateLabel!)
        
        self.isAssociateButton = UIButton()
        self.isAssociateButton?.setTitle(NSLocalizedString("profile.edit.associate.button",comment:""), for: UIControlState())
        self.isAssociateButton!.setImage(UIImage(named:"filter_check_blue"), for: UIControlState())
        self.isAssociateButton!.setImage(UIImage(named:"check_blue"), for: UIControlState.selected)
        self.isAssociateButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.isAssociateButton?.addTarget(self, action: #selector(EditProfileViewController.showAssociateData(_:)), for: UIControlEvents.touchUpInside)
        self.isAssociateButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.isAssociateButton!.setTitleColor(WMColor.dark_gray, for: UIControlState())
        self.isAssociateButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.content?.addSubview(self.isAssociateButton!)
        
        self.associateNumber = FormFieldView()
        self.associateNumber!.isRequired = true
        self.associateNumber!.setCustomPlaceholder(NSLocalizedString("profile.edit.associateNumber",comment:""))
        self.associateNumber!.typeField = TypeField.number
        self.associateNumber!.minLength = 10
        self.associateNumber!.maxLength = 10
        self.associateNumber!.nameField = NSLocalizedString("profile.edit.associateNumber",comment:"")
        self.associateNumber!.alpha = 0.0
        self.content?.addSubview(self.associateNumber!)
        
        self.associateDeterminant = FormFieldView()
        self.associateDeterminant!.isRequired = true
        self.associateDeterminant!.setCustomPlaceholder(NSLocalizedString("profile.edit.determinant",comment:""))
        self.associateDeterminant!.typeField = TypeField.number
        self.associateDeterminant!.minLength = 5
        self.associateDeterminant!.maxLength = 5
        self.associateDeterminant!.nameField = NSLocalizedString("profile.edit.determinant",comment:"")
        self.associateDeterminant!.alpha = 0.0
        self.content?.addSubview(self.associateDeterminant!)
        
        self.associateDate = FormFieldView()
        self.associateDate!.isRequired = true
        self.associateDate!.setCustomPlaceholder(NSLocalizedString("profile.edit.dateAdmission",comment:""))
        self.associateDate!.typeField = .none
        self.associateDate!.nameField = NSLocalizedString("profile.edit.dateAdmission",comment:"")
        self.associateDate!.disablePaste = true
        self.associateDate!.alpha = 0.0
        
        self.content?.addSubview(self.associateDate!)
        
        self.inputAssociateDateView = UIDatePicker()
        self.inputAssociateDateView!.datePickerMode = .date
        self.inputAssociateDateView!.date = Date()
        
        self.inputAssociateDateView!.addTarget(self, action: #selector(EditProfileViewController.associateDateChanged), for: .valueChanged)
        self.associateDate!.inputView = self.inputAssociateDateView!
        self.associateDate!.inputAccessoryView = viewAccess
        //self.associateDateChanged()
    
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attrString = NSMutableAttributedString(string: NSLocalizedString("profile.terms", comment: ""))
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.view.layer.insertSublayer(layerLine, at: 1000)

        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(EditProfileViewController.back), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:""), for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(EditProfileViewController.save(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(saveButton!)
    
        
        let attrs: [String:Any] = [
            NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(14),
            NSForegroundColorAttributeName : WMColor.light_blue,
            NSUnderlineStyleAttributeName : 1]
        let attributedString = NSMutableAttributedString(string:"")
        let buttonTitleStr = NSMutableAttributedString(string:NSLocalizedString("profile.terms.privacy", comment: ""), attributes:attrs)
        attributedString.append(buttonTitleStr)
        
        self.legalInformation = UIButton()
        self.legalInformation!.setAttributedTitle(attributedString, for: UIControlState())
        self.legalInformation!.addTarget(self, action: #selector(EditProfileViewController.noticePrivacy), for: .touchUpInside)
        self.legalInformation!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.content?.addSubview(self.legalInformation!)
        
        self.legalInformationLabel = UILabel()
        self.legalInformationLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.legalInformationLabel!.textColor = WMColor.reg_gray
        self.legalInformationLabel!.text = NSLocalizedString("profile.legalinfo.label", comment: "")
        self.content?.addSubview(self.legalInformationLabel!)
        
        self.content.backgroundColor = UIColor.white
        
        self.view.addSubview(self.content)
        
        self.content.clipsToBounds = true
        self.view.bringSubview(toFront: self.header!)
        self.showTabbar = !TabBarHidden.isTabBarHidden
        self.getOccupationList()
        
        self.picker = AlertPickerView.initPickerWithDefault()
        self.selectedGender = IndexPath(row: 0, section: 0)
        self.gender?.onBecomeFirstResponder = { () in
            self.picker.contentHeight = 220.0
            self.picker!.selected = self.selectedGender
            self.picker!.sender = self.gender!
            self.picker!.selectOptionDelegate = self
            self.picker!.setValues(NSLocalizedString("profile.gender",comment:"") as NSString, values: [NSLocalizedString("profile.gender.female",comment:""),NSLocalizedString("profile.gender.male",comment:"")])
            self.picker!.cellType = TypeField.check
            self.picker!.showPicker()
            self.view.endEditing(true)
        }
        
        self.ocupation?.onBecomeFirstResponder = { () in
            self.picker.contentHeight = 316
            self.picker!.selected = self.selectedOccupation as IndexPath?? ?? IndexPath(row: 0, section: 0)
            self.picker!.sender = self.ocupation!
            self.picker!.selectOptionDelegate = self
            self.picker!.setValues(NSLocalizedString("profile.edit.ocupation",comment:"") as NSString, values: self.occupationList!)
            self.picker!.cellType = TypeField.check
            self.picker!.showPicker()
            self.view.endEditing(true)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.buildComponetViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CustomBarNotification.TapBarFinish.rawValue), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(UserListDetailViewController.tabBarActions),name:NSNotification.Name(rawValue: CustomBarNotification.TapBarFinish.rawValue), object: nil)
        self.setValues()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarActions()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: - Actions
    
    /**
      builds component elements
     */
    func buildComponetViews() {
        let bounds = self.view.bounds
        let topSpace: CGFloat = 8.0
        let horSpace: CGFloat = 16.0
        let fieldWidth = self.view.bounds.width - (horSpace*2)
        let fieldHeight: CGFloat = 40.0
        
        self.personalInfoLabel.frame = CGRect(x: horSpace, y: 0, width: fieldWidth, height: 28)
        self.name.frame = CGRect(x: horSpace, y: self.personalInfoLabel.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.lastName.frame = CGRect(x: horSpace, y: self.name.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.email.frame = CGRect(x: horSpace, y: self.lastName.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        
        self.changePasswordLabel.frame = CGRect(x: horSpace, y: self.email.frame.maxY + topSpace, width: fieldWidth, height: 28)
        self.changuePasswordButton!.frame = CGRect(x: horSpace, y: self.changePasswordLabel.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.passwordInfoLabel.frame = CGRect(x: horSpace, y: self.changuePasswordButton!.frame.maxY + topSpace, width: fieldWidth, height: 14)
        self.passworCurrent!.frame = CGRect(x: horSpace, y: self.passwordInfoLabel!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.password!.frame = CGRect(x: horSpace, y: self.passworCurrent!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.confirmPassword!.frame = CGRect(x: horSpace, y: self.password!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)

        if self.showPasswordInfo {
            self.aditionalInfoLabel.frame = CGRect(x: horSpace, y: self.confirmPassword!.frame.maxY + topSpace, width: fieldWidth, height: 28)
        }else{
            self.aditionalInfoLabel.frame = CGRect(x: horSpace, y: self.changuePasswordButton!.frame.maxY + topSpace, width: fieldWidth, height: 28)
        }
        
        self.gender.frame = CGRect(x: horSpace, y: self.aditionalInfoLabel.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.birthDate.frame = CGRect(x: horSpace, y: self.gender.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.ocupation.frame = CGRect(x: horSpace, y: self.birthDate.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        
        self.phoneInformationLabel.frame = CGRect(x: horSpace, y: self.ocupation.frame.maxY + topSpace, width: fieldWidth, height: 28)
        self.phoneHome!.frame = CGRect(x: horSpace, y: self.phoneInformationLabel.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.phoneHomeExtension!.frame = CGRect(x: horSpace, y: self.phoneHome!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.cellPhone!.frame = CGRect(x: horSpace, y: self.phoneHomeExtension!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        
        self.associateLabel.frame = CGRect(x: horSpace, y: self.cellPhone!.frame.maxY + topSpace, width: fieldWidth, height: 28)
        self.isAssociateButton!.frame = CGRect(x: horSpace, y: self.associateLabel.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.associateNumber!.frame = CGRect(x: horSpace, y: self.isAssociateButton!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.associateDeterminant!.frame = CGRect(x: horSpace, y: self.associateNumber!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.associateDate!.frame = CGRect(x: horSpace, y: self.associateDeterminant!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        
        if self.showAssociateInfo {
            self.legalInformationLabel!.frame = CGRect(x: horSpace, y: self.associateDate!.frame.maxY + horSpace, width: 103, height: 14)
            self.legalInformation!.frame = CGRect(x: self.legalInformationLabel!.frame.maxX, y: self.associateDate!.frame.maxY + horSpace, width: fieldWidth - 103, height: 14)
        }else{
            self.legalInformationLabel!.frame = CGRect(x: horSpace, y: self.isAssociateButton!.frame.maxY + horSpace, width: 103, height: 14)
            self.legalInformation!.frame = CGRect(x: self.legalInformationLabel!.frame.maxX, y: self.isAssociateButton!.frame.maxY + horSpace, width: fieldWidth - 103, height: 14)
        }
        
        let downSpace: CGFloat = self.showTabbar ? CGFloat(156.0) : CGFloat(110.0)
        self.content.contentSize = CGSize(width: bounds.width, height:  self.legalInformation!.frame.maxY + horSpace)
        self.content.frame = CGRect(x: 0, y: self.header!.frame.maxY , width: self.view.bounds.width , height: self.view.bounds.height - downSpace)
        
        self.layerLine.frame = CGRect(x: 0, y: self.content.frame.maxY, width: self.view.bounds.width, height: 1)
        self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148,y: self.layerLine.frame.maxY + 16, width: 140, height: 34)
        self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.layerLine.frame.maxY + 16, width: 140, height: 34)
    }
    
    /**
     Set the user profile values
     */
    func setValues() {
        if let user = UserCurrentSession.sharedInstance.userSigned {
            self.name!.text = user.profile.name as String
            self.email!.text = user.email as String
            self.lastName!.text = user.profile.lastName as String
            self.gender!.text = user.profile.sex as String
            self.selectedGender = IndexPath(row:(self.gender!.text == NSLocalizedString("profile.gender.male",comment:"") ? 1 : 0), section: 0)
            self.ocupation!.text = user.profile.profession as String
            if let date = self.parseFmt!.date(from: user.profile.birthDate as String) {
                self.birthDate!.text = self.dateFmt!.string(from: date)
                self.dateSelected = date
                self.inputBirthdateView!.date = date
            }
            self.phoneHome!.text = user.profile.phoneHomeNumber as String
            self.phoneHomeExtension!.text = user.profile.homeNumberExtension as String
            self.cellPhone!.text = user.profile.cellPhone as String
            
            if user.profile.associateNumber as String != "" {
                self.showAssociateInfo = true
                self.isAssociateButton?.isSelected = true
                self.associateNumber!.text = user.profile.associateNumber as String
                self.associateDeterminant!.text = user.profile.associateStore as String
                if let associateDate = self.parseFmt!.date(from: user.profile.joinDate as String) {
                    self.associateDate!.text = self.dateFmt!.string(from: associateDate)
                    self.associateDateSelected = associateDate
                    self.inputAssociateDateView!.date = associateDate
                }

            }
        }
    }
    
    /**
     Calls OcuppationService
     */
    func getOccupationList(){
       let occupationService = OccupationsService()
        occupationService.callService([:], successBlock: { (result) -> Void in
            print(result)
            if let code = result["codeMessage"] as? Int {
                if code == 0{
                    self.ocupation.isEnabled = true
                    //let responceObject = result["responseObject"] as! [String:Any]
                    self.occupationList = result["occupationList"] as! [String]
                }else{
                   self.occupationList = []
                   self.ocupation.isEnabled = false
                }
            }else{
                self.occupationList = []
                self.ocupation.isEnabled = false
            }
           }, errorBlock: {(error) -> Void in
               self.occupationList = []
               self.ocupation.isEnabled = false
        })
    }
    
    /**
     saves the new date from birth date field
     */
    func dateChanged() {
        let date = self.inputBirthdateView!.date
        self.birthDate!.text = self.dateFmt!.string(from: date)
        self.dateSelected = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.dateBriday = dateFormatter.string(from: date)
    }
    
    /**
     saves the associate date f¡ield
     */

    func associateDateChanged(){
        let date = self.inputAssociateDateView!.date
        self.associateDate!.text = self.dateFmt!.string(from: date)
        self.associateDateSelected = date
        //TODO: validar al entrar al perfil que se mande con el formato correcto.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.joinDate = dateFormatter.string(from: date)
       
    }
    
    //MARK: TPKeyboardAvoidingScrollViewDelegate
    func contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
        return CGSize(width: self.view.frame.width, height: content.contentSize.height)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    //MARK: - TextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        let fieldString = strNSString.replacingCharacters(in: range, with: string)
        
        if textField == self.phoneHome! && fieldString.length() > 10 {
            return false
        }
        
        if textField == self.phoneHomeExtension! && fieldString.length() > 4 {
            return false
        }
        
        if textField == self.cellPhone! && fieldString.length() > 15 {
            return false
        }
        
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if errorView != nil{
            if errorView!.focusError == textField &&  errorView?.superview != nil {
                errorView?.removeFromSuperview()
                errorView!.focusError = nil
                errorView = nil
                self.content.frame = CGRect(x: 0, y: self.header!.frame.maxY  , width: self.view.bounds.width , height: self.view.bounds.height - 110.0 )
            }
        }
    }
    /**
     Calls updatePassword service
     */
    func updatePassword(){
         self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))

        let service = UpdatePasswordService()
        
        let params = service.buildParams(self.passworCurrent!.text!,newPassword:self.password!.text!)
        service.callService(params ,  successBlock:{ (resultCall:[String : Any]?) in
           
            self.alertView!.setMessage(resultCall?["message"] as! String)
            self.alertView!.showDoneIcon()
            self.showPasswordInfo = false
            self.save(self.saveButton!)
            }, errorBlock: {(error: NSError) in
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
        })
    }
    /**
     Saves new profile settings
     
     - parameter sender: save button
     */
    func save(_ sender:UIButton) {
        if showPasswordInfo {
            self.updatePassword()
        }
        else{
            if validateUser() {
                if self.showAssociateInfo {
                    if sender.tag == 100 && self.alertView == nil {
                        self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                    }else{
                        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                    }
                    
                    self.alertView?.setMessage("Validando datos del asociado")
                    let service = ValidateAssociateService()
                    service.callService(requestParams: service.buildParams(associateNumber!.text!, determinant: associateDeterminant!.text!),
                                        succesBlock: { (response:[String:Any]) -> Void in
                                            if response["codeMessage"] as? Int == 0 {
                                                self.saveProfileService()
                                            }else{
                                                self.alertView?.setMessage("Error en los datos del asociado")
                                                self.alertView!.showErrorIcon("Ok")
                                            }
                    }) { (error:NSError) -> Void in
                        self.alertView?.setMessage("Error en los datos del asociado")
                        self.alertView!.showErrorIcon("Ok")
                    }
                }else{
                    if sender.tag == 100 {
                        self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                    }else{
                        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                    }
                    self.saveProfileService()
                }
            }
        }
    }
    
    /**
     Calls edit profile service
     
     - parameter sender: save button
     */
    func saveProfileService() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_SAVE.rawValue, label: "")
        let service = UpdateUserProfileService()
        let profileId = UserCurrentSession.sharedInstance.userSigned?.profile.idProfile as! String
        let params  = service.buildParamsWithMembership(profileId, name: self.name.text!, lastName: self.lastName!.text!, email: self.email!.text!, gender: self.gender.text!, ocupation: self.ocupation!.text!, phoneNumber: self.phoneHome!.text!, phoneExtension: self.phoneHomeExtension!.text!, mobileNumber: self.cellPhone!.text!, updateAssociate: self.showAssociateInfo, associateStore: self.associateDeterminant!.text!, joinDate: self.joinDate , associateNumber: self.associateNumber!.text!, updatePassword: self.showPasswordInfo, oldPassword: self.passworCurrent!.text!, newPassword: self.password!.text!,dateOfBird: self.dateBriday)
            
        if self.passworCurrent != nil{
            // Evente change password
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CHANGE_PASSWORD.rawValue, action: WMGAIUtils.ACTION_CHANGE_PASSWORD.rawValue, label: "")
                
        }
            
        self.view.endEditing(true)
        self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
        service.callService(params ,  successBlock:{ (resultCall:[String : Any]?) in
            if let message = resultCall!["message"] as? String {
                self.alertView!.setMessage("\(message)")
                self.alertView!.showDoneIcon()
            }
            if self.delegate == nil {
                self.navigationController!.popViewController(animated: true)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "RELOAD_PROFILE"), object: nil)
            }
            else{
                self.delegate.finishSave()
            }
            }
            , errorBlock: {(error: NSError) in
                //self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.setMessage(NSLocalizedString("conection.error", comment: ""))
                self.alertView!.showErrorIcon("Ok")
        })
    }
    
    /**
     Validates phone fields
     
     - returns: bool
     */
    func validatePhoneInfo() -> Bool{
        var error = viewError(phoneHome!)
        if !error{
            error = viewError(phoneHomeExtension!)
        }
        if !error && cellPhone!.text! != "" {
            error = viewError(cellPhone!)
        }
        if error{
            return false
        }
        return true
    }
    
    /**
     Validates associateInfo
     
     - returns: Bool
     */
    func validateAssociateInfo() -> Bool {
        var error = viewError(associateNumber!)
        if !error{
            error = viewError(associateDeterminant!)
        }
        if !error{
            error = viewError(associateDate!)
        }
        if error{
            return false
        }
        return true
    }
    
    /**
     Validates password info
     
     - returns: Bool
     */
    func validateChangePassword() -> Bool{
        var error = viewError(confirmPassword!)
        if !error{
            error = viewError(password!)
        }
        if !error{
            error = viewError(passworCurrent!)
        }
        if error{
            return false
        }
        var field = FormFieldView()
        var message = ""
        if password!.text != confirmPassword!.text{
            field = confirmPassword!
            message = NSLocalizedString("field.validate.confirmpassword.equal", comment: "")
        }
        if message.characters.count > 0 {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field,  nameField:field.nameField ,  message: message ,errorView:self.errorView!,  becomeFirstResponder: true )
            return false
        }
        return true
    }
    
    /**
     Validates user infromation
     
     - returns: Bool
     */
    func validateUser() -> Bool{
        
        var error = viewError(name!)
        if !error{
            error = viewError(lastName!)
        }
        if !error{
            error = viewError(email!)
        }
        
        if self.showPasswordInfo && !self.validateChangePassword() {
            return false
        }
        
        if !error{
            error = viewError(gender!)
        }
        if !error{
            error = viewError(birthDate!)
        }
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let currentDate = Date()
        var comps = DateComponents()
        comps.year = -18
        let maxDate = (calendar as NSCalendar).date(byAdding: comps, to: currentDate, options: NSCalendar.Options())
        
        if self.inputBirthdateView!.date > maxDate! // self.inputBirthdateView?.date .compare(maxDate!) != ComparisonResult.orderedDescending
        {
            if self.errorView == nil{
            self.errorView = FormFieldErrorView()
            }
            let message = "Fecha no valida"
            SignUpViewController.presentMessage(birthDate!,  nameField:birthDate!.nameField , message: message ,errorView:self.errorView!,  becomeFirstResponder: true )
            return false
        }

        
        if !error{
            error = viewError(ocupation!)
        }
        if error{
            return false
        }
        
        if !self.validatePhoneInfo() {
            return false
        }
        
        if self.showAssociateInfo && !self.validateAssociateInfo(){
            return false
        }
        
        return true
    }
    
    /**
     Shows the view error
     
     - parameter field: field to show error
     
     - returns: Bool
     */
    func viewError(_ field: FormFieldView)-> Bool{
        let message = field.validate()
        if message != nil{
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field,  nameField:field.nameField , message: message! ,errorView:self.errorView!,  becomeFirstResponder: true )
            
            if field == self.name {
                self.content.frame = CGRect(x: 0, y: self.header!.frame.maxY + 25 , width: self.view.bounds.width , height: self.view.bounds.height - 110.0)
            }
            return true
        }
        field.resignFirstResponder()
        return false
    }
    
    /**
     Animation to show associate fields
     
     - parameter sender: UIButton
     */
    func showAssociateData(_ sender:UIButton) {
        self.isAssociateButton!.isSelected = !self.isAssociateButton!.isSelected
        self.showAssociateInfo = self.isAssociateButton!.isSelected
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.associateNumber!.alpha = self.showAssociateInfo ? 1.0 : 0.0
            self.associateDeterminant!.alpha = self.showAssociateInfo ? 1.0 : 0.0
            self.associateDate!.alpha = self.showAssociateInfo ? 1.0 : 0.0
            self.buildComponetViews()
        })
    }
    
    /**
     Animation to show password fields
     
     - parameter sender: UIButton
     */

    func showPasswordData(_ sender:UIButton) {
        self.changuePasswordButton!.isSelected = !self.changuePasswordButton!.isSelected
        self.showPasswordInfo = self.changuePasswordButton!.isSelected
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.passwordInfoLabel.alpha = self.showPasswordInfo ? 1.0 : 0.0
            self.passworCurrent!.alpha = self.showPasswordInfo ? 1.0 : 0.0
            self.password!.alpha = self.showPasswordInfo ? 1.0 : 0.0
            self.confirmPassword!.alpha = self.showPasswordInfo ? 1.0 : 0.0
            self.buildComponetViews()
        })
    }
    
    //MARK: Tabbar Notification
    override func willShowTabbar() {
        self.showTabbar = true
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.buildComponetViews()
        })
    }
    
    override func willHideTabbar() {
        self.showTabbar = false
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.buildComponetViews()
        })
    }
    
    
    func tabBarActions(){
        if TabBarHidden.isTabBarHidden {
            self.willHideTabbar()
        }else{
            self.willShowTabbar()
        }
    }
    
    /**
     Push Notice Privacy view controller
     */
    func noticePrivacy() {
        let controller = PreviewHelpViewController()
        let name = NSLocalizedString("profile.terms.privacy", comment: "")
        controller.titleText = NSLocalizedString(name, comment: "") as NSString!
        controller.resource = "privacy"
        controller.type = "pdf"
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    /**
     Retuns to more options view controller
     */
    override func back() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
        self.view.endEditing(true)
        //NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
        super.back()
    }
    
    //MARK: - AlertPickerSelectOptionDelegate
    func didSelectOptionAtIndex(_ indexPath: IndexPath){
        if self.errorView != nil{
            self.errorView!.removeFromSuperview()
            self.errorView!.focusError = nil
            self.errorView = nil
        }
        let sender = self.picker.sender as? FormFieldView
        if sender == self.gender {
            self.selectedGender = indexPath
            self.gender?.text = (indexPath as NSIndexPath).row == 1 ? NSLocalizedString("profile.gender.male",comment:"") : NSLocalizedString("profile.gender.female",comment:"")
            self.gender?.layer.borderWidth = 0
        }
        if sender == self.ocupation {
            self.selectedOccupation = indexPath
            self.ocupation?.text = self.occupationList[(indexPath as NSIndexPath).row]
            self.ocupation?.layer.borderWidth = 0
        }
    }
    
    
}
