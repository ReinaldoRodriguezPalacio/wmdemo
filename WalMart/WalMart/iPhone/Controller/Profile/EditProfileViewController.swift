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


class EditProfileViewController: NavigationViewController,  UICollectionViewDelegate , TPKeyboardAvoidingScrollViewDelegate, AlertPickerSelectOptionDelegate  {

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
    
    var dateFmt: NSDateFormatter?
    var parseFmt: NSDateFormatter?
    var delegate: EditProfileViewControllerDelegate!
    
    var showPasswordInfo: Bool = false
    var showAssociateInfo: Bool = false
    var showTabbar:Bool = false
    var dateSelected : NSDate!
    var associateDateSelected : NSDate!
    var picker : AlertPickerView!
    var selectedGender: NSIndexPath!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_EDITPROFILE.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel!.text = NSLocalizedString("profile.title", comment: "")
        
        self.dateFmt = NSDateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.setValues), name: ProfileNotification.updateProfile.rawValue, object: nil)
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_EDITPROFILE.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
        
        self.dateFmt = NSDateFormatter()
        self.dateFmt!.dateFormat = "d MMMM yyyy"

        self.parseFmt = NSDateFormatter()
        self.parseFmt!.dateFormat = "dd/MM/yyyy"

        self.content = TPKeyboardAvoidingScrollView()
        self.content.delegate = self
        self.content.scrollDelegate = self

        self.personalInfoLabel = UILabel()
        self.personalInfoLabel.font = WMFont.fontMyriadProLightOfSize(14)
        self.personalInfoLabel.textColor = WMColor.light_blue
        self.personalInfoLabel.text = "Actualiza tus datos personales"
        self.content?.addSubview(self.personalInfoLabel!)
        
        self.name = FormFieldView()
        self.name!.isRequired = true
        self.name!.setCustomPlaceholder(NSLocalizedString("profile.name",comment:""))
        self.name!.typeField = TypeField.Name
        self.name!.minLength = 3
        self.name!.maxLength = 25
        self.name!.nameField = NSLocalizedString("profile.name",comment:"")
        self.content?.addSubview(self.name!)
        
        self.lastName = FormFieldView()
        self.lastName!.isRequired = true
        self.lastName!.setCustomPlaceholder(NSLocalizedString("profile.lastname",comment:""))
        self.lastName!.typeField = TypeField.String
        self.lastName!.minLength = 3
        self.lastName!.maxLength = 25
        self.lastName!.nameField = NSLocalizedString("profile.lastname",comment:"")
        self.content?.addSubview(self.lastName!)
        
        self.email = FormFieldView()
        self.email!.isRequired = true
        self.email!.setCustomPlaceholder(NSLocalizedString("profile.email",comment:""))
        self.email!.keyboardType = UIKeyboardType.EmailAddress
        self.email!.typeField = TypeField.Email
        self.email!.maxLength = 45
        self.email!.nameField = NSLocalizedString("profile.email",comment:"")
        self.content?.addSubview(self.email!)
        
        self.changePasswordLabel = UILabel()
        self.changePasswordLabel.font = WMFont.fontMyriadProLightOfSize(14)
        self.changePasswordLabel.textColor = WMColor.light_blue
        self.changePasswordLabel.text = "Contraseña"
        self.content?.addSubview(self.changePasswordLabel!)
        
        self.passwordInfoLabel = UILabel()
        self.passwordInfoLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.passwordInfoLabel.textColor = WMColor.dark_gray
        self.passwordInfoLabel.text = "La contraseña debe contener mínimo 8 caracteres."
        self.passwordInfoLabel.alpha = 0.0
        self.content?.addSubview(self.passwordInfoLabel!)
        
        self.changuePasswordButton = UIButton()
        self.changuePasswordButton?.setTitle("Deseo modificar mi contraseña", forState: UIControlState.Normal)
        self.changuePasswordButton!.setImage(UIImage(named:"filter_check_blue"), forState: UIControlState.Normal)
        self.changuePasswordButton!.setImage(UIImage(named:"check_blue"), forState: UIControlState.Selected)
        self.changuePasswordButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.changuePasswordButton!.setTitleColor(WMColor.dark_gray, forState: UIControlState.Normal)
        self.changuePasswordButton?.addTarget(self, action: #selector(EditProfileViewController.showPasswordData(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.changuePasswordButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.changuePasswordButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.content?.addSubview(self.changuePasswordButton!)
        
        self.passworCurrent = FormFieldView()
        self.passworCurrent!.isRequired = true
        self.passworCurrent!.setCustomPlaceholder(NSLocalizedString("profile.password.current",comment:""))
        self.passworCurrent!.secureTextEntry = true
        self.passworCurrent!.typeField = TypeField.Password
        self.passworCurrent!.nameField = NSLocalizedString("profile.password.current",comment:"")
        self.passworCurrent!.alpha = 0.0
        self.content?.addSubview(self.passworCurrent!)
        
        self.password = FormFieldView()
        self.password!.isRequired = true
        self.password!.setCustomPlaceholder(NSLocalizedString("profile.password",comment:""))
        self.password!.secureTextEntry = true
        self.password!.typeField = TypeField.Password
        self.password!.nameField = NSLocalizedString("profile.password",comment:"")
        self.password!.minLength = 8
        self.password!.maxLength = 20
        self.password!.alpha = 0.0
        self.content?.addSubview(self.password!)
        
        self.confirmPassword = FormFieldView()
        self.confirmPassword!.isRequired = true
        self.confirmPassword!.setCustomPlaceholder(NSLocalizedString("profile.confirmpassword",comment:""))
        self.confirmPassword!.secureTextEntry = true
        self.confirmPassword!.typeField = TypeField.Password
        self.confirmPassword!.nameField = NSLocalizedString("profile.confirmpassword",comment:"")
        self.confirmPassword!.minLength = 8
        self.confirmPassword!.maxLength = 20
        self.confirmPassword!.alpha = 0.0
        self.content?.addSubview(self.confirmPassword!)
        
        self.aditionalInfoLabel = UILabel()
        self.aditionalInfoLabel.font = WMFont.fontMyriadProLightOfSize(14)
        self.aditionalInfoLabel.textColor = WMColor.light_blue
        self.aditionalInfoLabel.text = "Información adicional"
        self.content?.addSubview(self.aditionalInfoLabel!)

        self.birthDate = FormFieldView()
        self.birthDate!.isRequired = true
        self.birthDate!.setCustomPlaceholder(NSLocalizedString("profile.birthDate",comment:""))
        self.birthDate!.typeField = .None
        self.birthDate!.nameField = NSLocalizedString("profile.birthDate",comment:"")
        self.birthDate!.disablePaste = true
        self.content?.addSubview(self.birthDate!)
        
        self.gender = FormFieldView(frame:CGRectMake(16, 0, self.view.frame.width - 32, 40))
        self.gender!.isRequired = false
        self.gender!.setCustomPlaceholder(NSLocalizedString("Genero",comment:""))
        self.gender!.typeField = TypeField.List
        self.gender!.nameField = "Genero"
        self.gender!.setImageTypeField()
        self.content?.addSubview(self.gender!)
        
        self.ocupation = FormFieldView()
        self.ocupation!.isRequired = false
        self.ocupation!.setCustomPlaceholder(NSLocalizedString("Ocupación",comment:""))
        self.ocupation!.typeField = TypeField.String
        self.ocupation!.minLength = 3
        self.ocupation!.maxLength = 25
        self.ocupation!.nameField = "Ocupación"
        self.content?.addSubview(self.ocupation!)
        
        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, self.view.frame.width , 44), inputViewStyle: .Keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            if field != nil {
                self.dateChanged()
                self.associateDateChanged()
                field?.resignFirstResponder()
            }
        })
        
        
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let currentDate = NSDate()
        let comps = NSDateComponents()
        comps.year = -18
        let maxDate = calendar!.dateByAddingComponents(comps, toDate: currentDate, options: NSCalendarOptions())
        comps.year = -100
        let minDate = calendar!.dateByAddingComponents(comps, toDate: currentDate, options: NSCalendarOptions())
        
        self.inputBirthdateView = UIDatePicker()
        self.inputBirthdateView!.datePickerMode = .Date
        self.inputBirthdateView!.date = NSDate()
        self.inputBirthdateView!.maximumDate = maxDate
        self.inputBirthdateView!.minimumDate = minDate

        self.inputBirthdateView!.addTarget(self, action: #selector(EditProfileViewController.dateChanged), forControlEvents: .ValueChanged)
        self.birthDate!.inputView = self.inputBirthdateView!
        self.birthDate!.inputAccessoryView = viewAccess
        self.dateChanged()
        
        self.phoneInformationLabel = UILabel()
        self.phoneInformationLabel.font = WMFont.fontMyriadProLightOfSize(14)
        self.phoneInformationLabel.textColor = WMColor.light_blue
        self.phoneInformationLabel.text = "Referncia Telefónica"
        self.content?.addSubview(self.phoneInformationLabel!)
        
        self.phoneHome = FormFieldView()
        self.phoneHome!.isRequired = true
        self.phoneHome!.setCustomPlaceholder("Telefono 8-10 digitos incluyendo LADA")
        self.phoneHome!.typeField = TypeField.Phone
        self.phoneHome!.nameField = NSLocalizedString("profile.address.field.telephone.house",comment:"")
        self.phoneHome!.minLength = 10
        self.phoneHome!.maxLength = 10
        self.phoneHome!.keyboardType = UIKeyboardType.NumberPad
        self.phoneHome!.inputAccessoryView = viewAccess
        self.content?.addSubview(self.phoneHome!)
        //self.phoneHome!.delegate =  self
        
        self.phoneHomeExtension = FormFieldView()
        self.phoneHomeExtension!.isRequired = false
        self.phoneHomeExtension!.setCustomPlaceholder("Extensión")
        self.phoneHomeExtension!.typeField = TypeField.Number
        self.phoneHomeExtension!.nameField = "Extensión"
        self.phoneHomeExtension!.minLength = 3
        self.phoneHomeExtension!.maxLength = 5
        self.phoneHomeExtension!.keyboardType = UIKeyboardType.NumberPad
        self.phoneHomeExtension!.inputAccessoryView = viewAccess
        self.content?.addSubview(self.phoneHomeExtension!)
        
        self.cellPhone = FormFieldView()
        self.cellPhone!.isRequired = false
        self.cellPhone!.setCustomPlaceholder("Teléfono móvil 10-15 Dígitos")
        self.cellPhone!.typeField = TypeField.Phone
        self.cellPhone!.nameField = NSLocalizedString("profile.address.field.telephone.cell",comment:"")
        self.cellPhone!.minLength = 10
        self.cellPhone!.maxLength = 10
        self.cellPhone!.keyboardType = UIKeyboardType.NumberPad
        self.cellPhone!.inputAccessoryView = viewAccess
        self.content?.addSubview(self.cellPhone!)
        
        self.associateLabel = UILabel()
        self.associateLabel.font = WMFont.fontMyriadProLightOfSize(14)
        self.associateLabel.textColor = WMColor.light_blue
        self.associateLabel.text = "Asociado"
        self.content?.addSubview(self.associateLabel!)
        
        self.isAssociateButton = UIButton()
        self.isAssociateButton?.setTitle("Soy asociado", forState: UIControlState.Normal)
        self.isAssociateButton!.setImage(UIImage(named:"filter_check_blue"), forState: UIControlState.Normal)
        self.isAssociateButton!.setImage(UIImage(named:"check_blue"), forState: UIControlState.Selected)
        self.isAssociateButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.isAssociateButton?.addTarget(self, action: #selector(EditProfileViewController.showAssociateData(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.isAssociateButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.isAssociateButton!.setTitleColor(WMColor.dark_gray, forState: UIControlState.Normal)
        self.isAssociateButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.content?.addSubview(self.isAssociateButton!)
        
        self.associateNumber = FormFieldView()
        self.associateNumber!.isRequired = true
        self.associateNumber!.setCustomPlaceholder("Numero de asociado")
        self.associateNumber!.typeField = TypeField.String
        self.associateNumber!.minLength = 3
        self.associateNumber!.maxLength = 25
        self.associateNumber!.nameField = "Numero de asociado"
        self.associateNumber!.alpha = 0.0
        self.content?.addSubview(self.associateNumber!)
        
        self.associateDeterminant = FormFieldView()
        self.associateDeterminant!.isRequired = true
        self.associateDeterminant!.setCustomPlaceholder("Determinante")
        self.associateDeterminant!.typeField = TypeField.String
        self.associateDeterminant!.minLength = 3
        self.associateDeterminant!.maxLength = 25
        self.associateDeterminant!.nameField = "Determinante"
        self.associateDeterminant!.alpha = 0.0
        self.content?.addSubview(self.associateDeterminant!)
        
        self.associateDate = FormFieldView()
        self.associateDate!.isRequired = true
        self.associateDate!.setCustomPlaceholder("Fecha de ingreso")
        self.associateDate!.typeField = .None
        self.associateDate!.nameField = "Fecha de ingreso"
        self.associateDate!.disablePaste = true
        self.associateDate!.alpha = 0.0
        self.content?.addSubview(self.associateDate!)
        
        self.inputAssociateDateView = UIDatePicker()
        self.inputAssociateDateView!.datePickerMode = .Date
        self.inputAssociateDateView!.date = NSDate()
        self.inputAssociateDateView!.maximumDate = maxDate
        self.inputAssociateDateView!.minimumDate = minDate
        
        self.inputAssociateDateView!.addTarget(self, action: #selector(EditProfileViewController.associateDateChanged), forControlEvents: .ValueChanged)
        self.associateDate!.inputView = self.inputAssociateDateView!
        self.associateDate!.inputAccessoryView = viewAccess
        //self.associateDateChanged()
    
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attrString = NSMutableAttributedString(string: NSLocalizedString("profile.terms", comment: ""))
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.view.layer.insertSublayer(layerLine, atIndex: 1000)

        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.light_gray
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: Selector("back"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:""), forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(EditProfileViewController.save(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(saveButton!)
    
        self.legalInformation = UIButton()
        self.legalInformation!.setTitle(NSLocalizedString("profile.change.legalinfo", comment: ""), forState: UIControlState.Normal)
        self.legalInformation!.setTitleColor(WMColor.light_blue, forState: UIControlState.Normal)
        self.legalInformation!.addTarget(self, action: #selector(EditProfileViewController.infolegal), forControlEvents: .TouchUpInside)
        self.legalInformation!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.content?.addSubview(self.legalInformation!)
        
        self.content.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.content)
        
        self.content.clipsToBounds = true
        self.view.bringSubviewToFront(self.header!)
        self.showTabbar = !TabBarHidden.isTabBarHidden
        
        self.picker = AlertPickerView.initPickerWithDefaultCancelButton()
        self.selectedGender = NSIndexPath(forRow: 0, inSection: 0)
        self.gender?.onBecomeFirstResponder = { () in
            self.picker!.selected = self.selectedGender
            self.picker!.sender = self.gender!
            self.picker!.selectOptionDelegate = self
            self.picker!.setValues("Genero", values: ["Masculino","Femenino"])
            self.picker!.hiddenRigthActionButton(true)
            self.picker!.cellType = TypeField.Check
            self.picker?.tableData?.separatorStyle = .None
            self.picker!.showPicker()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.buildComponetViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomBarNotification.TapBarFinish.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(UserListDetailViewController.tabBarActions),name:CustomBarNotification.TapBarFinish.rawValue, object: nil)
        self.setValues()
    }
    override func viewDidAppear(animated: Bool) {
        self.tabBarActions()
    }
    
    //MARK: - Actions
    func buildComponetViews() {
        let bounds = self.view.bounds
        let topSpace: CGFloat = 8.0
        let horSpace: CGFloat = 16.0
        let fieldWidth = self.view.bounds.width - (horSpace*2)
        let fieldHeight: CGFloat = 40.0
        
        self.personalInfoLabel.frame = CGRectMake(horSpace, 0, fieldWidth, 28)
        self.name.frame = CGRectMake(horSpace, self.personalInfoLabel.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.lastName.frame = CGRectMake(horSpace, self.name.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.email.frame = CGRectMake(horSpace, self.lastName.frame.maxY + topSpace, fieldWidth, fieldHeight)
        
        self.changePasswordLabel.frame = CGRectMake(horSpace, self.email.frame.maxY + topSpace, fieldWidth, 28)
        self.changuePasswordButton!.frame = CGRectMake(horSpace, self.changePasswordLabel.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.passwordInfoLabel.frame = CGRectMake(horSpace, self.changuePasswordButton!.frame.maxY + topSpace, fieldWidth, 14)
        self.passworCurrent!.frame = CGRectMake(horSpace, self.passwordInfoLabel!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.password!.frame = CGRectMake(horSpace, self.passworCurrent!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.confirmPassword!.frame = CGRectMake(horSpace, self.password!.frame.maxY + topSpace, fieldWidth, fieldHeight)

        if self.showPasswordInfo {
            self.aditionalInfoLabel.frame = CGRectMake(horSpace, self.confirmPassword!.frame.maxY + topSpace, fieldWidth, 28)
        }else{
            self.aditionalInfoLabel.frame = CGRectMake(horSpace, self.changuePasswordButton!.frame.maxY + topSpace, fieldWidth, 28)
        }
        
        self.gender.frame = CGRectMake(horSpace, self.aditionalInfoLabel.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.birthDate.frame = CGRectMake(horSpace, self.gender.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.ocupation.frame = CGRectMake(horSpace, self.birthDate.frame.maxY + topSpace, fieldWidth, fieldHeight)
        
        self.phoneInformationLabel.frame = CGRectMake(horSpace, self.ocupation.frame.maxY + topSpace, fieldWidth, 28)
        self.phoneHome!.frame = CGRectMake(horSpace, self.phoneInformationLabel.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.phoneHomeExtension!.frame = CGRectMake(horSpace, self.phoneHome!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.cellPhone!.frame = CGRectMake(horSpace, self.phoneHomeExtension!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        
        self.associateLabel.frame = CGRectMake(horSpace, self.cellPhone!.frame.maxY + topSpace, fieldWidth, 28)
        self.isAssociateButton!.frame = CGRectMake(horSpace, self.associateLabel.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.associateNumber!.frame = CGRectMake(horSpace, self.isAssociateButton!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.associateDeterminant!.frame = CGRectMake(horSpace, self.associateNumber!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.associateDate!.frame = CGRectMake(horSpace, self.associateDeterminant!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        
        if self.showAssociateInfo {
            self.legalInformation!.frame = CGRectMake(horSpace, self.associateDate!.frame.maxY + horSpace, fieldWidth, 14)
        }else{
            self.legalInformation!.frame = CGRectMake(horSpace, self.isAssociateButton!.frame.maxY + horSpace, fieldWidth, 14)
        }
        
        let downSpace: CGFloat = self.showTabbar ? CGFloat(156.0) : CGFloat(110.0)
        self.content.contentSize = CGSize(width: bounds.width, height:  self.legalInformation!.frame.maxY + horSpace)
        self.content.frame = CGRectMake(0, self.header!.frame.maxY , self.view.bounds.width , self.view.bounds.height - downSpace)
        
        self.layerLine.frame = CGRectMake(0, self.content.frame.maxY, self.view.bounds.width, 1)
        self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148,self.layerLine.frame.maxY + 16, 140, 34)
        self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.layerLine.frame.maxY + 16, 140, 34)
    }
    
    func setValues() {
        if let user = UserCurrentSession.sharedInstance().userSigned {
            self.name!.text = user.profile.name as String
            self.email!.text = user.email as String
            self.lastName!.text = user.profile.lastName as String
            self.gender!.text = user.profile.sex as String
            self.selectedGender = NSIndexPath(forRow:(self.gender!.text == "Masculino" ? 0 : 1), inSection: 0)
            self.ocupation!.text = user.profile.profession as String
            if let date = self.parseFmt!.dateFromString(user.profile.birthDate as String) {
                self.birthDate!.text = self.dateFmt!.stringFromDate(date)
                self.dateSelected = date
                self.inputBirthdateView!.date = date
            }
            self.phoneHome!.text = user.profile.phoneHomeNumber as String
            self.phoneHomeExtension!.text = user.profile.homeNumberExtension as String
            self.cellPhone!.text = user.profile.cellPhone as String
            
            if user.profile.associateNumber as String != "" {
                self.showAssociateInfo = true
                self.isAssociateButton?.selected = true
                self.associateNumber!.text = user.profile.associateNumber as String
                self.associateDeterminant!.text = user.profile.associateStore as String
                if let associateDate = self.parseFmt!.dateFromString(user.profile.joinDate as String) {
                    self.associateDate!.text = self.dateFmt!.stringFromDate(associateDate)
                    self.associateDateSelected = associateDate
                    self.inputAssociateDateView!.date = associateDate
                }

            }
        }
    }

    func checkSelected(sender:UIButton) {
        sender.selected = !(sender.selected)
    }
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
          return CGSizeMake(self.view.frame.width, content.contentSize.height)
    }
    
    func dateChanged() {
        let date = self.inputBirthdateView!.date
        self.birthDate!.text = self.dateFmt!.stringFromDate(date)
        self.dateSelected = date
    }
    
    func associateDateChanged(){
        let date = self.inputAssociateDateView!.date
        self.associateDate!.text = self.dateFmt!.stringFromDate(date)
        self.associateDateSelected = date
    }
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    
    func textFieldDidEndEditing(textField: UITextField!) {
        if errorView != nil{
            if errorView!.focusError == textField &&  errorView?.superview != nil {
                errorView?.removeFromSuperview()
                errorView!.focusError = nil
                errorView = nil
                self.content.frame = CGRectMake(0, self.header!.frame.maxY  , self.view.bounds.width , self.view.bounds.height - 110.0 )
            }
        }
    }
    
    func textModify(textField: UITextField!) {
        if self.saveButton!.hidden {
            self.saveButton!.hidden = false
            UIView.animateWithDuration(0.4, animations: {
                self.saveButton!.alpha = 1.0
                }, completion: {(bool : Bool) in
                    if bool {
                        self.saveButton!.alpha = 1.0
                    }
            })
        }
    }

    func save(sender:UIButton) {
        if validateUser() {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_SAVE.rawValue, label: "")
            let service = UpdateUserProfileService()
            let profileId = UserCurrentSession.sharedInstance().userSigned?.profile.idProfile as! String
            let params  = service.buildParamsWithMembership(profileId, name: self.name.text!, lastName: self.lastName!.text!, email: self.email!.text!, gender: self.gender.text!, ocupation: self.ocupation!.text!, phoneNumber: self.phoneHome!.text!, phoneExtension: self.phoneHomeExtension!.text!, mobileNumber: self.cellPhone!.text!, updateAssociate: self.showAssociateInfo, associateStore: self.associateDeterminant!.text!, joinDate: self.associateDate!.text!, associateNumber: self.associateNumber!.text!, updatePassword: self.showPasswordInfo, oldPassword: self.passworCurrent!.text!, newPassword: self.password!.text!)
            
            if sender.tag == 100 {
                self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }else{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
            }
           
            
            if self.passworCurrent != nil{
                // Evente change password
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CHANGE_PASSWORD.rawValue, action: WMGAIUtils.ACTION_CHANGE_PASSWORD.rawValue, label: "")
                
            }
            
            self.view.endEditing(true)
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(params,  successBlock:{ (resultCall:NSDictionary?) in
                if let message = resultCall!["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                    self.alertView!.showDoneIcon()
                }//if let message = resultCall!["message"] as? String {
                self.saveButton!.hidden = true
                
                if self.delegate == nil {
                    self.navigationController!.popViewControllerAnimated(true)
                    NSNotificationCenter.defaultCenter().postNotificationName("RELOAD_PROFILE", object: nil)
                }
                else{
                    
                    if self.passworCurrent != nil{
                        self.passworCurrent!.removeFromSuperview()
                        self.password!.removeFromSuperview()
                        self.confirmPassword!.removeFromSuperview()
                    }
                    self.delegate.finishSave()
                }
                }
                , errorBlock: {(error: NSError) in
                    //self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.setMessage(NSLocalizedString("conection.error", comment: ""))
                    self.alertView!.showErrorIcon("Ok")
            })
        }
    }
    
    
    func validatePhoneInfo() -> Bool{
        var error = viewError(phoneHome!)
        if !error{
            error = viewError(phoneHomeExtension!)
        }
        if !error{
            error = viewError(cellPhone!)
        }
        if error{
            return false
        }
        return true
    }
    
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
        if !error{
            error = viewError(ocupation!)
        }
        if error{
            return false
        }
        
        if !self.validatePhoneInfo() {
            return false
        }
        
        if self.showAssociateInfo && !self.validateAssociateInfo() {
            return false
        }
        return true
    }
    
    func viewError(field: FormFieldView)-> Bool{
        let message = field.validate()
        if message != nil{
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field,  nameField:field.nameField , message: message! ,errorView:self.errorView!,  becomeFirstResponder: true )
            
            if field == self.name {
                self.content.frame = CGRectMake(0, self.header!.frame.maxY + 25 , self.view.bounds.width , self.view.bounds.height - 110.0)
            }
            return true
        }
        field.resignFirstResponder()
        return false
    }
    
    
    func showAssociateData(sender:UIButton) {
        self.isAssociateButton!.selected = !self.isAssociateButton!.selected
        
        self.showAssociateInfo = self.isAssociateButton!.selected
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.associateNumber!.alpha = self.showAssociateInfo ? 1.0 : 0.0
            self.associateDeterminant!.alpha = self.showAssociateInfo ? 1.0 : 0.0
            self.associateDate!.alpha = self.showAssociateInfo ? 1.0 : 0.0
            self.buildComponetViews()
        })
    }
    
    func showPasswordData(sender:UIButton) {
        self.changuePasswordButton!.selected = !self.changuePasswordButton!.selected
        self.showPasswordInfo = self.changuePasswordButton!.selected
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.passwordInfoLabel.alpha = self.showPasswordInfo ? 1.0 : 0.0
            self.passworCurrent!.alpha = self.showPasswordInfo ? 1.0 : 0.0
            self.password!.alpha = self.showPasswordInfo ? 1.0 : 0.0
            self.confirmPassword!.alpha = self.showPasswordInfo ? 1.0 : 0.0
            self.buildComponetViews()
        })
    }
    
    override func willShowTabbar() {
        self.showTabbar = true
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.buildComponetViews()
        })
    }
    
    override func willHideTabbar() {
        self.showTabbar = false
        UIView.animateWithDuration(0.2, animations: { () -> Void in
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

    func infolegal() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_OPEN_LEGAL_INFORMATION.rawValue , label:"")
        let changeInfoLegal = ChangeInfoLegalViewController()
        self.navigationController!.pushViewController(changeInfoLegal, animated: true)

    }
    
    
    override func back() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
        super.back()
    }
    
    //MARK: - AlertPickerSelectOptionDelegate
    func didSelectOptionAtIndex(indexPath: NSIndexPath){
        if self.errorView != nil{
            self.errorView!.removeFromSuperview()
            self.errorView!.focusError = nil
            self.errorView = nil
        }
        self.selectedGender = indexPath
        self.gender?.text = indexPath.row == 0 ? "Masculino" : "Femenino"
        self.gender?.layer.borderWidth = 0
    }
    
    
}
