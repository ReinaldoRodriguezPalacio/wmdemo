//
//  AddressViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 19/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


enum TypeAddress {
    case shiping
    case fiscalPerson
    case fiscalMoral
}

class AddressViewController: NavigationViewController, UICollectionViewDelegate , TPKeyboardAvoidingScrollViewDelegate , AddressViewDelegate{

    var content: TPKeyboardAvoidingScrollView!
    var addressShipingButton: UIButton?
    var addressFiscalButton: UIButton?
    var addressFiscalPersonButton: UIButton?
    var addressFiscalMoralButton: UIButton?
    var viewAddress: AddressView? = nil
    var viewAddressFisical: AddressView? = nil
    var viewAddressMoral: AddressView? = nil
    var item: [String:Any]? = nil
    var allAddress: NSArray! = []
    var viewTypeAdress: UIView? = nil
    var viewTypeAdressFiscal: UIView? = nil
    var saveButton: WMRoundButton?
    var deleteButton: UIButton?
    var typeAddress: TypeAddress = TypeAddress.shiping
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
       
        
        self.saveButton = WMRoundButton()
        self.saveButton?.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        self.saveButton?.setBackgroundColor(WMColor.green, size: CGSize(width: 71, height: 22), forUIControlState: UIControlState())
        self.saveButton!.addTarget(self, action: #selector(AddressViewController.save(_:)), for: UIControlEvents.touchUpInside)
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:"" ).lowercased() , for: UIControlState())
        self.saveButton!.isHidden = true
        self.saveButton!.alpha = 0
        self.saveButton!.tag = 1
        
        if !isLogin {
            self.header?.addSubview(self.saveButton!)
        }
        else {
            self.content?.addSubview(self.saveButton!)
        }
       
        
        self.bounds = self.view.bounds
        switch (typeAddress ) {
        case .shiping:
            self.viewAddress = ShippingAddress(frame:self.bounds, isLogin: self.isLogin, isIpad: self.isIpad, typeAddress: typeAddress)
            self.viewAddress!.allAddress = self.allAddress
            self.viewAddress?.defaultPrefered = self.defaultPrefered
            self.viewAddress!.delegate = self
            self.viewAddress!.typeAddress = typeAddress
            self.content!.addSubview(self.viewAddress!)
        case .fiscalPerson:
            self.viewAddressFisical = FiscalAddressPersonF(frame:self.bounds, isLogin: self.isLogin , isIpad: isIpad, typeAddress: typeAddress)
            self.viewAddressFisical!.allAddress = self.allAddress
            self.content!.addSubview(self.viewAddressFisical!)
            self.viewAddressFisical?.defaultPrefered = self.defaultPrefered
            self.viewAddressFisical!.typeAddress = typeAddress
            self.viewAddressFisical!.delegate = self
           
        case .fiscalMoral:
            self.viewAddressMoral = FiscalAddressPersonM(frame:self.bounds,  isLogin: self.isLogin, isIpad:isIpad, typeAddress: typeAddress)
            self.viewAddressMoral!.allAddress = self.allAddress
            self.viewAddressMoral?.defaultPrefered = self.defaultPrefered
            self.content!.addSubview(self.viewAddressMoral!)
            self.viewAddressMoral!.typeAddress = typeAddress
            self.viewAddressMoral!.delegate = self
        }
    
        
        if self.item == nil {
            self.setupTypeAddress()
            self.titleLabel!.text = NSLocalizedString("profile.address.new.title", comment: "")
        }else{
            //TODO:Checar por que las direcciones no traen Id
            if let id = self.item!["addressId"] as! String?{
                self.idAddress = id as NSString?
                self.titleLabel!.text = self.item!["name"] as! String?
                deleteButton = UIButton()
                deleteButton?.addTarget(self, action: #selector(AddressViewController.deleteAddress(_:)), for: .touchUpInside)
                deleteButton!.setImage(UIImage(named: "deleteAddress"), for: UIControlState())
                self.header!.addSubview(self.deleteButton!)
            }
            else{
                self.titleLabel!.text = NSLocalizedString("profile.address.new.title", comment: "")
            }
            switch (typeAddress ) {
            case .shiping:
                self.viewAddress!.setItemWithDictionary(self.item!)
            case .fiscalPerson:
                self.viewAddressFisical!.setItemWithDictionary(self.item!)
            case .fiscalMoral:
                self.viewAddressMoral!.setItemWithDictionary(self.item!)
            }
        }
        if addFRomMg {
            self.titleLabel!.text = NSLocalizedString("Es necesario capturar \n una dirección", comment: "")
        }
        
    }
    
    func setupTypeAddress (){
        if (viewTypeAdress == nil ){
            viewTypeAdress = UIView()
            addressFiscalButton = UIButton()
            addressShipingButton = UIButton()

            let checkTermOff : UIImage = UIImage(named:"checkTermOff")!
            var named = ""
            if isLogin {
                 named = "checkTermOn"
                 addressShipingButton!.setTitleColor(UIColor.white , for: UIControlState())
                 addressFiscalButton!.setTitleColor(UIColor.white , for: UIControlState())
            }else {
                named = "check_full"
                addressShipingButton!.setTitleColor(WMColor.reg_gray, for: UIControlState())
                addressFiscalButton!.setTitleColor(WMColor.reg_gray , for: UIControlState())
            }
            
            let checkTermOn : UIImage = UIImage(named:named)!
            
            //var addressShipinglabel : UILabel? = nil
            //var addressFiscallabel: UILabel? = nil
        
            addressShipingButton!.setImage(checkTermOff, for: UIControlState())
            addressShipingButton!.setImage(checkTermOn, for: UIControlState.selected)
            addressShipingButton!.addTarget(self, action: #selector(AddressViewController.checkSelected(_:)), for: UIControlEvents.touchUpInside)
            addressShipingButton!.setTitle(NSLocalizedString("profile.address.shiping",  comment: ""), for: UIControlState())
            addressShipingButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressShipingButton!.titleLabel?.textColor = WMColor.reg_gray
            addressShipingButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
           
            addressFiscalButton!.setImage(checkTermOff, for: UIControlState())
            addressFiscalButton!.setImage(checkTermOn, for: UIControlState.selected)
            
            addressFiscalButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalButton!.titleLabel?.textColor = WMColor.reg_gray
            addressFiscalButton!.addTarget(self, action: #selector(AddressViewController.checkSelected(_:)), for: UIControlEvents.touchUpInside)
          
            addressFiscalButton!.setTitle(NSLocalizedString("profile.address.fiscal",  comment: ""), for: UIControlState())
            addressFiscalButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
          
            addressFiscalButton!.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: UIControlState.disabled)
            
            if typeAddress == TypeAddress.shiping{
                addressShipingButton!.isSelected = true
            }
            else{
                addressFiscalButton!.isSelected = true
            }
            
            self.viewTypeAdress!.addSubview(addressShipingButton!)
            self.viewTypeAdress!.addSubview(addressFiscalButton!)
            
            addressShipingButton!.frame = CGRect(x: 0, y: 0, width: 92, height: 45 )
            addressFiscalButton!.frame = CGRect(x: 86, y: 0, width: 92, height: 45 )
          
            
            self.content!.addSubview(self.viewTypeAdress!)
            
            if isLogin {
                self.viewTypeAdress!.backgroundColor = UIColor.clear
            }else {
                self.viewTypeAdress!.backgroundColor = UIColor.white
            }
        }
    }
    
    
    func setupViewFiscal(){
        if viewTypeAdressFiscal==nil{
            viewTypeAdressFiscal = UIView(frame:CGRect(x: 0,  y: self.viewTypeAdress != nil ? 45 : 0 , width: self.view.bounds.width , height: 78))

            let checkTermOff : UIImage = UIImage(named:"checkTermOff")!
            let checkTermOn : UIImage = UIImage(named:"check_full")!
        
            var titleLabel: UILabel? = nil
            var viewButton : UIView? = nil
            
            addressFiscalPersonButton = UIButton()
            addressFiscalPersonButton!.setImage(checkTermOff, for: UIControlState())
            addressFiscalPersonButton!.setImage(checkTermOn, for: UIControlState.selected)
            addressFiscalPersonButton!.addTarget(self, action: #selector(AddressViewController.checkSelectedFisical(_:)), for: UIControlEvents.touchUpInside)
            addressFiscalPersonButton!.setTitle(NSLocalizedString("profile.address.person",  comment: ""), for: UIControlState())
            addressFiscalPersonButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalPersonButton!.titleLabel?.textColor = WMColor.reg_gray
            addressFiscalPersonButton!.setTitleColor(WMColor.reg_gray, for: UIControlState())
            addressFiscalPersonButton!.setTitleColor(WMColor.light_gray, for: UIControlState.disabled)
            addressFiscalPersonButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
            
            addressFiscalMoralButton = UIButton()
            addressFiscalMoralButton!.setImage(checkTermOff, for: UIControlState())
            addressFiscalMoralButton!.setImage(checkTermOn, for: UIControlState.selected)
            addressFiscalMoralButton!.addTarget(self, action: #selector(AddressViewController.checkSelectedFisical(_:)), for: UIControlEvents.touchUpInside)
            addressFiscalMoralButton!.setTitle(NSLocalizedString("profile.address.corporate",  comment: ""), for: UIControlState())
            addressFiscalMoralButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalMoralButton!.titleLabel?.textColor = WMColor.reg_gray
            addressFiscalMoralButton!.setTitleColor(WMColor.reg_gray, for: UIControlState())
            addressFiscalMoralButton!.setTitleColor(WMColor.light_gray, for: UIControlState.disabled)
            addressFiscalMoralButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
            
            if typeAddress == TypeAddress.fiscalMoral{
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
            
            titleLabel!.frame = CGRect(x: 16, y: 0, width: self.view.bounds.width - 20, height: 35 )
            
            addressFiscalPersonButton!.frame = CGRect(x: 0, y: 0, width: 107 , height: 45)
            addressFiscalMoralButton!.frame = CGRect(x: 121, y: 0, width: 107 , height: 45)
            self.content!.addSubview(self.viewTypeAdressFiscal!)
            self.viewTypeAdressFiscal!.backgroundColor = UIColor.white
        }
    }
    
   /* func textFieldDidEndEditing(textField: UITextField!) {
        switch (typeAddress ) {
        case .Shiping:
            self.viewAddress!.textFieldDidEndEditing(textField)
        case .FiscalPerson:
            self.viewAddressFisical!.textFieldDidEndEditing(textField)
        case .FiscalMoral:
            self.viewAddressMoral!.textFieldDidEndEditing(textField)
        //default:
        //    break
        }
    }*/
    
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
        
        
        self.saveButton!.frame = CGRect(x: self.view.bounds.maxX - left , y: 0 , width: 71, height: self.header!.frame.height)
        self.titleLabel!.frame = CGRect(x: 16, y: 0, width: (bounds.width - 32), height: self.header!.frame.maxY)
        
        self.content.frame = CGRect(x: 0, y: self.header!.frame.maxY , width: bounds.width , height: bounds.height - self.header!.frame.height )
        
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
        if sender == self.addressShipingButton{
            self.addressFiscalButton!.isSelected = false
            self.presentedView(TypeAddress.shiping)
        }else{
            self.addressShipingButton!.isSelected = false
            self.presentedView(TypeAddress.fiscalPerson)
        }
        sender.isSelected = !(sender.isSelected)
    }
    
    func checkSelectedFisical(_ sender:UIButton) {
        if sender.isSelected{
            return
        }
        if sender == self.addressFiscalPersonButton{
            self.addressFiscalMoralButton!.isSelected = false
             self.presentedView(TypeAddress.fiscalPerson)
        }else{
            self.addressFiscalPersonButton!.isSelected = false
             self.presentedView(TypeAddress.fiscalMoral)
        }
        sender.isSelected = !(sender.isSelected)
    }
    
    func presentedView(_ typeDest:TypeAddress){
        if typeDest == self.typeAddress{
            return
        }
        
        switch (typeDest ) {
        case .shiping:
            if  self.viewAddress == nil{
                self.viewAddress = ShippingAddress(frame:self.bounds, isLogin: self.isLogin, isIpad: self.isIpad, typeAddress: typeDest)
                //self.viewAddress!.isLogin = self.isLogin
                self.viewAddress!.delegate = self
                self.viewAddress!.typeAddress = typeDest
            }
            self.viewAddress!.allAddress = self.allAddress
            self.viewAddress!.frame = CGRect(x: 0,  y: self.viewTypeAdress!.frame.maxY  , width: self.view.bounds.width , height: 600)
            self.content!.addSubview(self.viewAddress!)
            
            if typeAddress == TypeAddress.fiscalPerson {
                self.content!.bringSubview(toFront: self.viewAddressFisical!)
            }else{
                self.content!.bringSubview(toFront: self.viewAddressMoral!)
            }
            self.content!.bringSubview(toFront: self.viewTypeAdressFiscal!)
            
            UIView.animate(withDuration: 0.4, animations: {
                
                self.viewTypeAdressFiscal!.frame = CGRect(x: self.view.bounds.width, y: self.viewTypeAdress!.frame.maxY, width: self.viewTypeAdressFiscal!.frame.width , height: self.viewTypeAdressFiscal!.frame.height)
                
                if self.typeAddress == TypeAddress.fiscalPerson {
                    self.viewAddressFisical!.frame =  CGRect(x: self.view.bounds.width, y: self.viewTypeAdressFiscal!.frame.maxY, width: self.viewAddress!.frame.width , height: self.viewAddress!.frame.height)
                }else{
                    
                    self.viewAddressMoral!.frame =  CGRect(x: self.view.bounds.width, y: self.viewTypeAdressFiscal!.frame.maxY, width: self.viewAddress!.frame.width , height: self.viewAddress!.frame.height)
                }
                
                }, completion: {(bool : Bool) in
                    if bool {
                        
                        if self.typeAddress == TypeAddress.fiscalPerson {
                            self.viewAddressFisical!.removeFromSuperview()
                        }else{
                            self.viewAddressMoral!.removeFromSuperview()
                        }
                        if self.viewTypeAdressFiscal != nil{
                            self.viewTypeAdressFiscal!.removeFromSuperview()
                            self.viewTypeAdressFiscal = nil
                        }
                       
                        self.typeAddress = typeDest
                        self.setContentSize()
                    }
            })
        case .fiscalPerson:
            if self.viewAddressFisical == nil{
                self.viewAddressFisical =   FiscalAddressPersonF(frame:self.bounds, isLogin: self.isLogin, isIpad: self.isIpad, typeAddress: typeDest)
                self.viewAddressFisical!.delegate = self
                self.viewAddressFisical!.typeAddress = typeDest
            }
             self.viewAddressFisical!.allAddress = self.allAddress
            self.setupViewFiscal()
            if (self.typeAddress == TypeAddress.shiping){
                self.viewTypeAdressFiscal!.frame = CGRect(x: self.view.bounds.width, y: self.viewTypeAdress!.frame.maxY, width: self.view.bounds.width , height: 78)
                self.viewAddressFisical!.frame =   CGRect(x: self.view.bounds.width,  y: self.viewTypeAdressFiscal!.frame.maxY  , width: self.view.bounds.width , height: 658 )
                self.content!.addSubview(self.viewAddressFisical!)
                self.content.bringSubview(toFront: self.viewAddressFisical!)
                UIView.animate(withDuration: 0.4, animations: {
                    self.viewAddressFisical!.frame =   CGRect(x: 0,  y: self.viewTypeAdressFiscal!.frame.maxY  , width: self.view.bounds.width , height: 658 )
                    self.viewTypeAdressFiscal!.frame = CGRect(x: 0, y: self.viewTypeAdress!.frame.maxY, width: self.viewTypeAdressFiscal!.frame.width , height: self.viewTypeAdressFiscal!.frame.height)
                    }, completion: {(bool : Bool) in
                        if bool {
                            self.viewAddress!.removeFromSuperview()
                            self.typeAddress = typeDest
                            self.setContentSize()
                        }
                })
            }else{
                self.viewAddressFisical!.allAddress = self.allAddress
                self.viewAddressFisical!.frame = CGRect(x: 0, y: self.viewTypeAdressFiscal!.frame.maxY, width: self.view.bounds.width , height: 610)
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
            }
        case .fiscalMoral:
            if self.viewAddressMoral == nil{
                self.viewAddressMoral =   FiscalAddressPersonM(frame:self.bounds,  isLogin: self.isLogin, isIpad:self.isIpad, typeAddress: typeDest)
                self.viewAddressMoral!.delegate = self
                self.viewAddressMoral!.typeAddress = typeDest
            }
            self.viewAddressMoral!.allAddress = self.allAddress
            self.viewAddressMoral!.frame = CGRect(x: self.view.bounds.width,  y: self.viewTypeAdressFiscal!.frame.maxY  , width: self.view.bounds.width , height: 610)
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
        case .shiping:
            let height : CGFloat = self.viewAddress!.showSuburb == true ? 640 : 600-190
            self.viewAddress?.frame = CGRect(x: 0.0, y: self.viewTypeAdress != nil ? 45 : 0 , width: bounds.width , height: height)
            self.content.contentSize = CGSize(width: bounds.width, height: self.viewAddress!.frame.maxY + 40 )
            self.content.bringSubview(toFront: self.viewAddress!)
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
    
    func contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
        let val = CGSize(width: self.view.frame.width, height: content.contentSize.height)
        return val
    }
    
    func saveGrAddres(_ params:[String:Any],successBlock:((Bool) -> Void)?) {
        
        
        
        
    }
    
    func registryAddress(_ userName:String,password:String,successBlock:((Bool) -> Void)?){
        
        let service = GRAddressAddService()
        var params = self.viewAddress!.getParams()
        
        let paramsSend =  service.buildParams("", addressID: "", zipCode: params["zipCode"] as! String, street:params["street"] as! String, innerNumber:params["innerNumber"] as! String, state:"" , county:"", neighborhoodID:params["neighborhoodID"] as! String, phoneNumber:params["TelNumber"]as! String , outerNumber:params["outerNumber"] as! String, adName:params["name"] as! String, reference1:"" , reference2:"" , storeID:"" ,storeName: "", operationType:"A" , preferred: true)
        
            service.callService(requestParams: paramsSend, successBlock: { (resultCall:[String:Any]) -> Void  in
            print("Se realizao la direccion")
            
            if let message = resultCall["message"] as? String {
                print("\(message)")
            }

            // agregar login antes de agregar la direccion 
                
                let service = LoginService()
                let params  = service.buildParams(userName, password: password)
                service.callService(params, successBlock: { (result:[String:Any]) -> Void in
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
        if successCallBackRegistry != nil {
            successCallBackRegistry?()
            return
        }
        self.saveBock(sender, successBlock: nil)
    }
 
    func saveBock(_ sender:UIButton?,successBlock:((Bool) -> Void)?) {
        var params : [String:Any]? = nil
        var service :  BaseService!
        
            switch (typeAddress) {
            case .shiping:
                if self.viewAddress!.validateAddress(){
                    params = self.viewAddress!.getParams()
                    
                    if self.idAddress == nil{
                        service = AddShippingAddressService()
                    }else{
                        service = UpdateShippingAddressService()
                    }
                    
                }
            case .fiscalPerson:
                if self.viewAddressFisical!.validateAddress(){
                    params = self.viewAddressFisical?.getParams()
                    if self.idAddress == nil{
                        service = AddFiscalAddressService()
                    }else{
                        service = UpdateFiscalAddressService()
                    }
                }
            case .fiscalMoral:
                if self.viewAddressMoral!.validateAddress(){
                    params = self.viewAddressMoral?.getParams()
                    if self.idAddress == nil{
                        service = AddFiscalAddressService()
                    }else{
                        service = UpdateFiscalAddressService()
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
                
                if addressShippingCont >= 12 && typeAddress == .shiping {
                    self.alertView!.setMessage(NSLocalizedString("profile.address.shipping.error.max",comment:""))
                    self.alertView!.showErrorIcon("OK")
                    self.back()
                    return
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
                
                service.callPOSTService(params!, successBlock:{ (resultCall:[String:Any]?) in
                    if let message = resultCall!["message"] as? String {
                         if self.showSaveAlert {
                            let addres  = params!["AddressID"] as? String
                            self.alertView!.setMessage(addres != nil ? NSLocalizedString("profile.address.update.ok",comment:"") :NSLocalizedString("profile.address.add.ok",comment:""))
                            self.alertView!.showDoneIcon()
                        }
                    }
                    
                    if self.successCallBack == nil {
                        successBlock?(true)
                        self.closeAlert()
                        self.navigationController?.popViewController(animated: true)
                    }else {
                        
                        self.successCallBack!()
                    }
                    
                    BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_UPDATE_ADDRESS.rawValue, label:"")
                    
                    }
                    , errorBlock: {(error: NSError) in
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                })
            }
        
    }

    func closeAlert(){
        if self.alertView != nil {
            self.alertView!.showDoneIcon()
        }
    }
    
    func deleteAddress(_ sender:UIButton){
       var service : DeleteAddressesByUserService? = nil
        
        if self.typeAddress == TypeAddress.shiping  {
            service = DeleteAddressesByUserService()
            
        }else {
            service = DeleteAddressesInvoiceService()
        }
        
       
        let params = service!.buildParams(self.idAddress! as String)
        self.view.endEditing(true)
        if sender.tag == 100 {
            self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
        }else{
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
        }
        
        self.alertView!.setMessage(NSLocalizedString("profile.message.delete",comment:""))
        service!.callService(params, successBlock:{ (resultCall:[String:Any]?) in
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
        
        super.back()
    }
    
    
}

