//
//  InvoiceNewAddressViewController.swift
//  WalMart
//
//  Created by Vantis on 25/04/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation


enum TypeFiscalAddress {
    case fiscalPerson
    case fiscalMoral
}

class InvoiceNewAddressViewController: NavigationViewController, UICollectionViewDelegate , TPKeyboardAvoidingScrollViewDelegate , AddressViewDelegate{
    
    var content: TPKeyboardAvoidingScrollView!
    var addressShipingButton: UIButton?
    var addressFiscalButton: UIButton?
    var addressFiscalPersonButton: UIButton?
    var addressFiscalMoralButton: UIButton?
    var viewAddress: AddressView? = nil
    var viewAddressFisical: AddressView? = nil
    var viewAddressMoral: AddressView? = nil
    var item: [String:Any]? = nil
    var allAddress: [Any]! = []
    var viewTypeAdress: UIView? = nil
    var viewTypeAdressFiscal: UIView? = nil
    var saveButton: UIButton?
    var deleteButton: UIButton?
    var typeAddress: TypeFiscalAddress = TypeFiscalAddress.fiscalPerson
    var idAddress: NSString? = nil
    var defaultPrefered = false
    var viewLoad : WMLoadingView!
    var successCallBack : (() -> Void)? = nil
    var successCallBackRegistry : (() -> Void)? = nil
    
    var bounds: CGRect!
    var alertView : IPOWMAlertViewController? = nil
    var isLogin : Bool = false
    var isIpad : Bool = false
    var showSaveAlert: Bool = true
    var addressShippingCont: Int! = 0
    var addressFiscalCount: Int! = 0
    var validateZip =  false
    
    var addFRomMg : Bool = false
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MGNEWADDRESSDELIVERY.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.view.addSubview(self.content)
        
        //let iconImage = UIImage(named:"button_bg")
        //let iconSelected = UIImage(named:"button_bg_active")
        
        
        self.bounds = self.view.bounds
        switch (typeAddress ) {
        case .fiscalPerson:
            self.viewAddressFisical = FiscalAddressPersonF(frame:self.bounds, isLogin: self.isLogin , isIpad: isIpad)
            self.viewAddressFisical!.allAddress = self.allAddress
            let name: FormFieldView = self.viewAddressFisical!.viewWithTag(100) as! FormFieldView
            let lastName: FormFieldView = self.viewAddressFisical!.viewWithTag(101) as! FormFieldView
            let lastName2: FormFieldView = self.viewAddressFisical!.viewWithTag(102) as! FormFieldView
            let rfc: FormFieldView = self.viewAddressFisical!.viewWithTag(103) as! FormFieldView
            let ieps: FormFieldView = self.viewAddressFisical!.viewWithTag(104) as! FormFieldView
            let email: FormFieldView = self.viewAddressFisical!.viewWithTag(105) as! FormFieldView
            
            lastName.setCustomPlaceholder(NSLocalizedString("profile.address.person.lastNameShort",comment:""))
            lastName2.setCustomPlaceholder(NSLocalizedString("profile.address.person.lastName2Short",comment:""))
            ieps.setCustomPlaceholder(NSLocalizedString("profile.address.iepsShort",comment:""))

            self.content!.addSubview(self.viewAddressFisical!)
            self.viewAddressFisical?.defaultPrefered = self.defaultPrefered
            self.viewAddressFisical!.delegate = self
            
        case .fiscalMoral:
            self.viewAddressMoral = FiscalAddressPersonM(frame:self.bounds,  isLogin: self.isLogin, isIpad:isIpad)
            self.viewAddressMoral!.allAddress = self.allAddress
            self.viewAddressMoral?.defaultPrefered = self.defaultPrefered
            self.content!.addSubview(self.viewAddressMoral!)
            self.viewAddressMoral!.delegate = self
            // default:
            //     break
        }
        
        if self.item == nil {
            self.titleLabel!.text = NSLocalizedString("profile.address.new.title", comment: "")
        }
        BaseController.setOpenScreenTagManager(titleScreen: "Direcciones", screenName: self.getScreenGAIName())
    }
    
    
    func setupViewFiscal(){
        if viewTypeAdressFiscal==nil{
            viewTypeAdressFiscal = UIView(frame:CGRect(x: 0,  y: 0 , width: self.view.bounds.width , height: 78))
            
            let checkTermOff : UIImage = UIImage(named:"checkTermOff")!
            let checkTermOn : UIImage = UIImage(named:"checkAddressOn")!
            
            var titleLabel: UILabel? = nil
            var viewButton : UIView? = nil
            
            addressFiscalPersonButton = UIButton()
            addressFiscalPersonButton!.setImage(checkTermOff, for: UIControlState())
            addressFiscalPersonButton!.setImage(checkTermOn, for: UIControlState.selected)
            addressFiscalPersonButton!.addTarget(self, action: #selector(AddressViewController.checkSelectedFisical(_:)), for: UIControlEvents.touchUpInside)
            addressFiscalPersonButton!.setTitle(NSLocalizedString("profile.address.person",  comment: ""), for: UIControlState())
            addressFiscalPersonButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalPersonButton!.titleLabel?.textColor = WMColor.gray
            addressFiscalPersonButton!.setTitleColor(WMColor.gray, for: UIControlState())
            addressFiscalPersonButton!.setTitleColor(WMColor.light_gray, for: UIControlState.disabled)
            addressFiscalPersonButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
            
            addressFiscalMoralButton = UIButton()
            addressFiscalMoralButton!.setImage(checkTermOff, for: UIControlState())
            addressFiscalMoralButton!.setImage(checkTermOn, for: UIControlState.selected)
            addressFiscalMoralButton!.addTarget(self, action: #selector(AddressViewController.checkSelectedFisical(_:)), for: UIControlEvents.touchUpInside)
            addressFiscalMoralButton!.setTitle(NSLocalizedString("profile.address.corporate",  comment: ""), for: UIControlState())
            addressFiscalMoralButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalMoralButton!.titleLabel?.textColor = WMColor.gray
            addressFiscalMoralButton!.setTitleColor(WMColor.gray, for: UIControlState())
            addressFiscalMoralButton!.setTitleColor(WMColor.light_gray, for: UIControlState.disabled)
            addressFiscalMoralButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
            
            if typeAddress == TypeFiscalAddress.fiscalMoral{
                self.addressFiscalMoralButton!.isSelected = true
                if self.idAddress != nil {
                    self.addressFiscalPersonButton!.isEnabled = false
                }
                
            }else{
                addressFiscalPersonButton!.isSelected = true
                if self.idAddress != nil {
                    self.addressFiscalMoralButton!.isEnabled = false
                }
            }
            
            titleLabel = UILabel()
            titleLabel!.textColor = WMColor.light_blue
            titleLabel!.font = WMFont.fontMyriadProLightOfSize(14)
            titleLabel!.text =  NSLocalizedString("profile.address.fiscal.section", comment: "")
            
            
            titleLabel!.backgroundColor = UIColor.white
            
            
            viewButton = UIView(frame: CGRect(x: (self.view.bounds.width - 230) / 2,  y: 32 , width: 230 , height: 45))
            
            viewButton!.addSubview(addressFiscalPersonButton!)
            viewButton!.addSubview(addressFiscalMoralButton!)
            
            self.viewTypeAdressFiscal!.addSubview(titleLabel!)
            self.viewTypeAdressFiscal!.addSubview(viewButton!)
            
            titleLabel!.frame = CGRect(x: 10, y: 0, width: self.view.bounds.width - 20, height: 35 )
            
            addressFiscalPersonButton!.frame = CGRect(x: 0, y: 0, width: 107 , height: 45)
            addressFiscalMoralButton!.frame = CGRect(x: 121, y: 0, width: 107 , height: 45)
            self.content!.addSubview(self.viewTypeAdressFiscal!)
            self.viewTypeAdressFiscal!.backgroundColor = UIColor.white
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField!) {
        switch (typeAddress ) {
        case .fiscalPerson:
            self.viewAddressFisical!.textFieldDidEndEditing(textField)
        case .fiscalMoral:
            self.viewAddressMoral!.textFieldDidEndEditing(textField)
            //default:
            //    break
        }
    }
    
    func textModify(_ textField: UITextField!) {
        if self.saveButton!.isHidden {
            self.saveButton!.isHidden = false
            self.changeTitleLabel()
        }
    }
    
    func changeTitleLabel(){
        
        UIView.animate(withDuration: 0.4, animations: {
            self.saveButton!.alpha = 1.0
            if self.deleteButton != nil {
                self.titleLabel!.frame = CGRect(x: 37 , y: 0,width: self.titleLabel!.frame.width - 13, height: self.header!.frame.maxY)
                self.titleLabel!.textAlignment = .left
            }
        }, completion: {(bool : Bool) in
            if bool {
                self.saveButton!.alpha = 1.0
            }
        })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let bounds = self.view.bounds
        //let fieldHeight  : CGFloat = CGFloat(40)
        //let leftRightPadding  : CGFloat = CGFloat(15)
        var left : CGFloat = 87
        
        if self.idAddress != nil{
            self.deleteButton!.frame = CGRect( x: bounds.maxX - 54, y: 0 , width: 54, height: self.header!.frame.height)
            left = left + 30
        }
        
        
        self.titleLabel!.frame = CGRect(x: 16, y: 0, width: (bounds.width - 32), height: self.header!.frame.maxY)
        let viewFooter = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height - 64, width: self.view.frame.size.width, height: 64))
        
        saveButton = UIButton()
        self.saveButton!.frame = CGRect(x: 0, y: 16, width: (viewFooter.frame.size.width - 20)/2, height: viewFooter.frame.size.height - 32)
        self.saveButton!.addTarget(self, action: #selector(self.save(_:)), for: UIControlEvents.touchUpInside)
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:"" ) , for: UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.center = CGPoint(x: (viewFooter.frame.width / 2) , y: 32)
        self.saveButton!.layer.cornerRadius = 16

        
        viewFooter.addSubview(self.saveButton!)
        
        
        
        self.view.addSubview(viewFooter)
        
        self.content.frame = CGRect(x: 0, y: self.header!.frame.maxY , width: bounds.width , height: bounds.height - self.header!.frame.height - viewFooter.frame.height )
        
        if self.viewTypeAdress != nil{
            self.viewTypeAdress?.frame = CGRect( x: (bounds.width - 180) / 2 , y: 0 , width: 180 , height: 45)
        }
        self.setContentSize()
        
        if self.addFRomMg{
            self.backButton?.isHidden =  true
        }
        
    }
    
    func checkSelected(_ sender:UIButton) {
        if sender.isSelected{
            return
        }
            self.addressShipingButton!.isSelected = false
            self.presentedView(TypeFiscalAddress.fiscalPerson)
        
        sender.isSelected = !(sender.isSelected)
    }
    
    func checkSelectedFisical(_ sender:UIButton) {
        if sender.isSelected{
            return
        }
        if sender == self.addressFiscalPersonButton{
            self.addressFiscalMoralButton!.isSelected = false
            self.presentedView(TypeFiscalAddress.fiscalPerson)
        }else{
            self.addressFiscalPersonButton!.isSelected = false
            self.presentedView(TypeFiscalAddress.fiscalMoral)
        }
        sender.isSelected = !(sender.isSelected)
    }
    
    func presentedView(_ typeDest:TypeFiscalAddress){
        if typeDest == self.typeAddress{
            return
        }
        
        switch (typeDest ) {
        case .fiscalPerson:
            if self.viewAddressFisical == nil{
                self.viewAddressFisical =   FiscalAddressPersonF(frame:self.bounds, isLogin: self.isLogin, isIpad: self.isIpad)
                self.viewAddressFisical!.delegate = self
            }
            self.viewAddressFisical!.allAddress = self.allAddress
            self.setupViewFiscal()
            
                self.viewAddressFisical!.allAddress = self.allAddress
                self.viewAddressFisical!.frame = CGRect(x: 0, y: self.viewTypeAdressFiscal!.frame.maxY, width: self.view.bounds.width , height: 610)
            let name: FormFieldView = self.viewAddressFisical!.viewWithTag(100) as! FormFieldView
            let lastName: FormFieldView = self.viewAddressFisical!.viewWithTag(101) as! FormFieldView
            let lastName2: FormFieldView = self.viewAddressFisical!.viewWithTag(102) as! FormFieldView
            let rfc: FormFieldView = self.viewAddressFisical!.viewWithTag(103) as! FormFieldView
            let ieps: FormFieldView = self.viewAddressFisical!.viewWithTag(104) as! FormFieldView
            let email: FormFieldView = self.viewAddressFisical!.viewWithTag(105) as! FormFieldView
            
            lastName.setCustomPlaceholder(NSLocalizedString("profile.address.person.lastNameShort",comment:""))
            lastName2.setCustomPlaceholder(NSLocalizedString("profile.address.person.lastName2Short",comment:""))
            ieps.setCustomPlaceholder(NSLocalizedString("profile.address.iepsShort",comment:""))
            
                self.content!.addSubview(self.viewAddressFisical!)
                self.content.bringSubview(toFront: self.viewAddressMoral!)
                UIView.animate(withDuration: 0.4, animations: {
                    self.viewAddressMoral!.frame =  CGRect(x: self.view.bounds.width, y: self.viewTypeAdressFiscal!.frame.maxY, width: self.view.bounds.width , height: 610 )
                }, completion: {(bool : Bool) in
                    if bool {
                        self.viewAddressMoral!.removeFromSuperview()
                        self.typeAddress = typeDest
                        self.setContentSize()
                    }
                })
            
        case .fiscalMoral:
            if self.viewAddressMoral == nil{
                self.viewAddressMoral =   FiscalAddressPersonM(frame:self.bounds,  isLogin: self.isLogin, isIpad:self.isIpad)
                self.viewAddressMoral!.delegate = self
            }
            self.viewAddressMoral!.allAddress = self.allAddress
            self.viewAddressMoral!.frame = CGRect(x: self.view.bounds.width,  y: self.viewTypeAdressFiscal!.frame.maxY  , width: self.view.bounds.width , height: 610)
            let companyName: FormFieldView = self.viewAddressMoral!.viewWithTag(100) as! FormFieldView
            let rfc: FormFieldView = self.viewAddressMoral!.viewWithTag(101) as! FormFieldView
            let ieps: FormFieldView = self.viewAddressMoral!.viewWithTag(102) as! FormFieldView
            let email: FormFieldView = self.viewAddressMoral!.viewWithTag(103) as! FormFieldView
            
            ieps.setCustomPlaceholder(NSLocalizedString("profile.address.iepsShort",comment:""))
            
            
            self.content!.addSubview(self.viewAddressMoral!)
            self.content!.bringSubview(toFront: self.viewAddressMoral!)
            
            UIView.animate(withDuration: 0.4, animations: {
                self.viewAddressMoral!.frame = CGRect(x: 0,  y: self.viewTypeAdressFiscal!.frame.maxY  , width: self.view.bounds.width , height: 610)
            }, completion: {(bool : Bool) in
                if bool {
                    self.viewAddressFisical?.removeFromSuperview()
                    self.typeAddress = typeDest
                    self.setContentSize()
                }
            })
            //default:
            //    break
        }
    }
    
    func setContentSize(){
        let bounds = self.view.bounds
        switch (typeAddress ) {
        case .fiscalPerson:
            self.setupViewFiscal()
            let height  : CGFloat = self.viewAddressFisical!.showSuburb == true ? 658 : 658-190
            self.viewAddressFisical?.frame = CGRect(x: 0.0, y: self.viewTypeAdressFiscal!.frame.maxY, width: bounds.width , height: height)
            self.content.contentSize = CGSize(width: bounds.width, height: self.viewAddressFisical!.frame.maxY + 40 )
            self.content!.bringSubview(toFront: self.viewTypeAdressFiscal!)
            self.content.bringSubview(toFront: self.viewAddressFisical!)
        case .fiscalMoral:
            self.setupViewFiscal()
            let height  : CGFloat = self.viewAddressMoral!.showSuburb == true ? 610 : 610-190
            self.viewAddressMoral?.frame = CGRect(x: 0.0,  y: self.viewTypeAdressFiscal!.frame.maxY, width: bounds.width , height: height)
            self.content.contentSize = CGSize(width: bounds.width, height: self.viewAddressMoral!.frame.maxY + 40 )
            self.content!.bringSubview(toFront: self.viewTypeAdressFiscal!)
            self.content.bringSubview(toFront: self.viewAddressMoral!)
            //default:
            //    break
        }
        
        if  isLogin {
            self.saveButton!.frame = CGRect(x: (bounds.width - 290) / 2 , y: self.viewAddress!.frame.maxY + 20, width: 290, height: 40)
            self.saveButton!.titleLabel?.textAlignment = .center
            self.content.contentSize = CGSize(width: bounds.width, height: self.viewAddress!.frame.maxY + 100 )
        }
    }
    
    func validateZip(_ isvalidate: Bool) {
        self.validateZip = isvalidate
    }
    
    func contentSizeForScrollView(_ sender:Any) -> CGSize {
        let val = CGSize(width: self.view.frame.width, height: content.contentSize.height)
        return val
    }
    
    func saveGrAddres(_ params:[String:Any],successBlock:((Bool) -> Void)?) {
        
    }
    
    func registryAddress(_ userName:String,password:String,successBlock:((Bool) -> Void)?){
        
        let grAddressAddService = GRAddressAddService()
        var params = self.viewAddress!.getParams()
        
        let paramsSend =  grAddressAddService.buildParams(params["city"] as! String, addressID: "", zipCode: params["zipCode"] as! String, street:params["street"] as! String, innerNumber:params["innerNumber"] as! String, state:params["state"] as! String , county:params["county"] as! String, neighborhoodID:params["neighborhoodID"] as! String, phoneNumber:params["TelNumber"]as! String , outerNumber:params["outerNumber"] as! String, adName:params["name"] as! String, reference1:"" , reference2:"" , storeID:"" ,storeName: "", operationType:"A" , preferred: true)
        
        grAddressAddService.callService(requestParams: paramsSend, successBlock: { (resultCall:[String:Any]) -> Void  in
            print("Se realizao la direccion")
            
            if let message = resultCall["message"] as? String {
                print("\(message)")
            }
            
            // agregar login antes de agregar la direccion
            
            let loginService = LoginService()
            let params  = loginService.buildParams(userName, password: password)
            loginService.callServiceByEmail(params: params, successBlock: { (result:[String:Any]) -> Void in
                self.saveBock(self.saveButton,successBlock:successBlock)
                successBlock!(true)
            }, errorBlock: { (error:NSError) -> Void in
                print("Error \(error)")
                successBlock!(false)
            })
            
        }) { (error:NSError) -> Void in
            successBlock!(false)
            print("Error \(error) ")
        }
    }
    
    func save(_ sender:UIButton) {
        //self.performSegue(withIdentifier: "invoiceDataController", sender: self)
        self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
        self.alertView!.setMessage(NSLocalizedString("profile.address.add.ok",comment:""))
        self.alertView!.showDoneIcon()
        self.back()
        
        
    }
    
    func saveBock(_ sender:UIButton?,successBlock:((Bool) -> Void)?) {
        var params : [String:Any]? = nil
        var addresService :  BaseService!
        
        switch (typeAddress) {
        case .fiscalPerson:
            if self.viewAddressFisical!.validateAddress(){
                params = self.viewAddressFisical?.getParams()
                if self.idAddress == nil{
                    addresService = AddFiscalAddressService()
                }else{
                    addresService = UpdateFiscalAddressService()
                }
            }
        case .fiscalMoral:
            if self.viewAddressMoral!.validateAddress(){
                params = self.viewAddressMoral?.getParams()
                if self.idAddress == nil{
                    addresService = AddFiscalAddressService()
                }else{
                    addresService = UpdateFiscalAddressService()
                }
            }
            //default:
            //    break
        }
        if params != nil{
            self.view.endEditing(true)
            if self.showSaveAlert {
                self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
                
            }
            
            if addressFiscalCount >= 12 && (typeAddress == .fiscalPerson || typeAddress == .fiscalMoral) {
                self.alertView!.setMessage(NSLocalizedString("profile.address.fiscal.error.max",comment:""))
                self.alertView!.showErrorIcon("OK")
                self.back()
                return
            }
            
            if self.showSaveAlert {
                self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            }
            
            addresService.callPOSTService(params!, successBlock:{ (resultCall:[String:Any]?) in
                if let _ = resultCall!["message"] as? String {
                    if self.showSaveAlert {
                        let addres  = params!["AddressID"] as? String
                        self.alertView!.setMessage(addres != nil ? NSLocalizedString("profile.address.update.ok",comment:"") :NSLocalizedString("profile.address.add.ok",comment:""))
                        self.alertView!.showDoneIcon()
                    }
                }
                
                if self.successCallBack == nil {
                    successBlock?(true)
                    self.closeAlert()
                    let _ = self.navigationController?.popViewController(animated: true)
                }else {
                    
                    self.successCallBack!()
                }
                
                ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_UPDATE_ADDRESS.rawValue, label:"")
                
            }
                , errorBlock: {(error: NSError) in
                    self.alertView?.setMessage(error.localizedDescription)
                    self.alertView?.showErrorIcon("Ok")
            })
        }
        
    }
    
    func closeAlert(){
        if self.alertView != nil {
            self.alertView!.showDoneIcon()
        }
    }
    
    func deleteAddress(_ sender:UIButton){
        let service = DeleteAddressesByUserService()
        service.buildParams(self.idAddress! as String)
        self.view.endEditing(true)
        if sender.tag == 100 {
            self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
        }else{
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
        }
        
        self.alertView!.setMessage(NSLocalizedString("profile.message.delete",comment:""))
        service.callService([String:Any](), successBlock:{ (resultCall:[String:Any]?) in
            if let message = resultCall!["message"] as? String {
                self.alertView!.setMessage("\(message)")
                self.alertView!.showDoneIcon()
            }//if let message = resultCall!["message"] as? String {
            self.navigationController!.popViewController(animated: true)
        }
            , errorBlock: {(error: NSError) in
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
        })
    }
    
    override func back() {
        UIView.transition(with: self.view.superview!, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromRight,
                        animations: {self.view.removeFromSuperview()}, completion: nil)
    }
    
    override func swipeHandler(swipe: UISwipeGestureRecognizer) {
        self.back()
    }
    
    
}


