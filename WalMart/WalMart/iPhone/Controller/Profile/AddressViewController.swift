//
//  AddressViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 19/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


enum TypeAddress {
    case Shiping
    case FiscalPerson
    case FiscalMoral
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
    var item: NSDictionary? = nil
    var allAddress: NSArray! = []
    var viewTypeAdress: UIView? = nil
    var viewTypeAdressFiscal: UIView? = nil
    var saveButton: WMRoundButton?
    var deleteButton: UIButton?
    var typeAddress: TypeAddress = TypeAddress.Shiping
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
        
        self.view.backgroundColor = UIColor.whiteColor()

        self.content = TPKeyboardAvoidingScrollView()
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.view.addSubview(self.content)
       
        //let iconImage = UIImage(named:"button_bg")
        //let iconSelected = UIImage(named:"button_bg_active")
        
        self.saveButton = WMRoundButton()
        self.saveButton?.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        self.saveButton?.setBackgroundColor(WMColor.green, size: CGSizeMake(71, 22), forUIControlState: UIControlState.Normal)
        self.saveButton!.addTarget(self, action: #selector(AddressViewController.save(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:"" ) , forState: UIControlState.Normal)
        self.saveButton!.hidden = true
        self.saveButton!.alpha = 0
        self.saveButton!.tag = 1
        
        if !isLogin {
            self.header?.addSubview(self.saveButton!)
        }
        else {
//            self.saveButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//            self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
//            self.saveButton!.layer.cornerRadius = 4.0
            self.content?.addSubview(self.saveButton!)
        }
       
        
        self.bounds = self.view.bounds
        switch (typeAddress ) {
        case .Shiping:
            self.viewAddress = ShippingAddress(frame:self.bounds, isLogin: self.isLogin, isIpad: self.isIpad)
            self.viewAddress!.allAddress = self.allAddress
            self.viewAddress?.defaultPrefered = self.defaultPrefered
            self.viewAddress!.delegate = self
            self.content!.addSubview(self.viewAddress!)
        case .FiscalPerson:
            self.viewAddressFisical = FiscalAddressPersonF(frame:self.bounds, isLogin: self.isLogin , isIpad: isIpad)
            self.viewAddressFisical!.allAddress = self.allAddress
            self.content!.addSubview(self.viewAddressFisical!)
            self.viewAddressFisical?.defaultPrefered = self.defaultPrefered
            self.viewAddressFisical!.delegate = self
           
        case .FiscalMoral:
            self.viewAddressMoral = FiscalAddressPersonM(frame:self.bounds,  isLogin: self.isLogin, isIpad:isIpad)
            self.viewAddressMoral!.allAddress = self.allAddress
            self.viewAddressMoral?.defaultPrefered = self.defaultPrefered
            self.content!.addSubview(self.viewAddressMoral!)
            self.viewAddressMoral!.delegate = self
       // default:
       //     break
        }
    
        
        if self.item == nil {
            self.setupTypeAddress()
            self.titleLabel!.text = NSLocalizedString("profile.address.new.title", comment: "")
        }else{
            if let id = self.item!["addressID"] as! String?{
                self.idAddress = id
                self.titleLabel!.text = self.item!["name"] as! String?
                deleteButton = UIButton()
                deleteButton?.addTarget(self, action: #selector(AddressViewController.deleteAddress(_:)), forControlEvents: .TouchUpInside)
                deleteButton!.setImage(UIImage(named: "deleteAddress"), forState: UIControlState.Normal)
                self.header!.addSubview(self.deleteButton!)
            }
            else{
                self.titleLabel!.text = NSLocalizedString("profile.address.new.title", comment: "")
            }
            switch (typeAddress ) {
            case .Shiping:
                self.viewAddress!.setItemWithDictionary(self.item!)
            case .FiscalPerson:
                self.viewAddressFisical!.setItemWithDictionary(self.item!)
            case .FiscalMoral:
                self.viewAddressMoral!.setItemWithDictionary(self.item!)
          //  default:
          //      break
            }
        }
        if addFRomMg {
            self.titleLabel!.text = NSLocalizedString("Es necesario capturar \n una dirección", comment: "")
        }
        BaseController.setOpenScreenTagManager(titleScreen: "Direcciones", screenName: self.getScreenGAIName())
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
                 addressShipingButton!.setTitleColor(UIColor.whiteColor() , forState: UIControlState.Normal)
                 addressFiscalButton!.setTitleColor(UIColor.whiteColor() , forState: UIControlState.Normal)
            }else {
                named = "checkAddressOn"
                addressShipingButton!.setTitleColor(WMColor.gray, forState: UIControlState.Normal)
                addressFiscalButton!.setTitleColor(WMColor.gray , forState: UIControlState.Normal)
            }
            
            let checkTermOn : UIImage = UIImage(named:named)!
            
            //var addressShipinglabel : UILabel? = nil
            //var addressFiscallabel: UILabel? = nil
        
            addressShipingButton!.setImage(checkTermOff, forState: UIControlState.Normal)
            addressShipingButton!.setImage(checkTermOn, forState: UIControlState.Selected)
            addressShipingButton!.addTarget(self, action: #selector(AddressViewController.checkSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            addressShipingButton!.setTitle(NSLocalizedString("profile.address.shiping",  comment: ""), forState: UIControlState.Normal)
            addressShipingButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressShipingButton!.titleLabel?.textColor = WMColor.gray
            addressShipingButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
           
            addressFiscalButton!.setImage(checkTermOff, forState: UIControlState.Normal)
            addressFiscalButton!.setImage(checkTermOn, forState: UIControlState.Selected)
            
            addressFiscalButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalButton!.titleLabel?.textColor = WMColor.gray
            addressFiscalButton!.addTarget(self, action: #selector(AddressViewController.checkSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
          
            addressFiscalButton!.setTitle(NSLocalizedString("profile.address.fiscal",  comment: ""), forState: UIControlState.Normal)
            addressFiscalButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
          
            addressFiscalButton!.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.7), forState: UIControlState.Disabled)
            
            if typeAddress == TypeAddress.Shiping{
                addressShipingButton!.selected = true
            }
            else{
                addressFiscalButton!.selected = true
            }
            
            self.viewTypeAdress!.addSubview(addressShipingButton!)
            self.viewTypeAdress!.addSubview(addressFiscalButton!)
            
            addressShipingButton!.frame = CGRectMake(0, 0, 92, 45 )
            addressFiscalButton!.frame = CGRectMake(86, 0, 92, 45 )
          
            
            self.content!.addSubview(self.viewTypeAdress!)
            
            if isLogin {
                self.viewTypeAdress!.backgroundColor = UIColor.clearColor()
            }else {
                self.viewTypeAdress!.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    
    func setupViewFiscal(){
        if viewTypeAdressFiscal==nil{
            viewTypeAdressFiscal = UIView(frame:CGRectMake(0,  self.viewTypeAdress != nil ? 45 : 0 , self.view.bounds.width , 78))

            let checkTermOff : UIImage = UIImage(named:"checkTermOff")!
            let checkTermOn : UIImage = UIImage(named:"checkAddressOn")!
        
            var titleLabel: UILabel? = nil
            var viewButton : UIView? = nil
            
            addressFiscalPersonButton = UIButton()
            addressFiscalPersonButton!.setImage(checkTermOff, forState: UIControlState.Normal)
            addressFiscalPersonButton!.setImage(checkTermOn, forState: UIControlState.Selected)
            addressFiscalPersonButton!.addTarget(self, action: #selector(AddressViewController.checkSelectedFisical(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            addressFiscalPersonButton!.setTitle(NSLocalizedString("profile.address.person",  comment: ""), forState: UIControlState.Normal)
            addressFiscalPersonButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalPersonButton!.titleLabel?.textColor = WMColor.gray
            addressFiscalPersonButton!.setTitleColor(WMColor.gray, forState: UIControlState.Normal)
            addressFiscalPersonButton!.setTitleColor(WMColor.light_gray, forState: UIControlState.Disabled)
            addressFiscalPersonButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
            
            addressFiscalMoralButton = UIButton()
            addressFiscalMoralButton!.setImage(checkTermOff, forState: UIControlState.Normal)
            addressFiscalMoralButton!.setImage(checkTermOn, forState: UIControlState.Selected)
            addressFiscalMoralButton!.addTarget(self, action: #selector(AddressViewController.checkSelectedFisical(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            addressFiscalMoralButton!.setTitle(NSLocalizedString("profile.address.corporate",  comment: ""), forState: UIControlState.Normal)
            addressFiscalMoralButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalMoralButton!.titleLabel?.textColor = WMColor.gray
            addressFiscalMoralButton!.setTitleColor(WMColor.gray, forState: UIControlState.Normal)
            addressFiscalMoralButton!.setTitleColor(WMColor.light_gray, forState: UIControlState.Disabled)
            addressFiscalMoralButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
            
            if typeAddress == TypeAddress.FiscalMoral{
                self.addressFiscalMoralButton!.selected = true
                if self.idAddress != nil {
                    self.addressFiscalPersonButton!.enabled = false
                }
                
            }else{
                addressFiscalPersonButton!.selected = true
                if self.idAddress != nil {
                    self.addressFiscalMoralButton!.enabled = false
                }
            }
            
            titleLabel = UILabel()
            titleLabel!.textColor = WMColor.light_blue
            titleLabel!.font = WMFont.fontMyriadProLightOfSize(14)
            titleLabel!.text =  NSLocalizedString("profile.address.fiscal.section", comment: "")
            
            
            titleLabel!.backgroundColor = UIColor.whiteColor()
            
            
            viewButton = UIView(frame: CGRectMake((self.view.bounds.width - 230) / 2,  32 , 230 , 45))
            
            viewButton!.addSubview(addressFiscalPersonButton!)
            viewButton!.addSubview(addressFiscalMoralButton!)
            
            self.viewTypeAdressFiscal!.addSubview(titleLabel!)
            self.viewTypeAdressFiscal!.addSubview(viewButton!)
            
            titleLabel!.frame = CGRectMake(10, 0, self.view.bounds.width - 20, 35 )
            
            addressFiscalPersonButton!.frame = CGRectMake(0, 0, 107 , 45)
            addressFiscalMoralButton!.frame = CGRectMake(121, 0, 107 , 45)
            self.content!.addSubview(self.viewTypeAdressFiscal!)
            self.viewTypeAdressFiscal!.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField!) {
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
    }
    
    func textModify(textField: UITextField!) {
        if self.saveButton!.hidden {
            self.saveButton!.hidden = false
            self.changeTitleLabel()
        }
    }
    
    func changeTitleLabel(){
        
        UIView.animateWithDuration(0.4, animations: {
            self.saveButton!.alpha = 1.0
            if self.deleteButton != nil {
                self.titleLabel!.frame = CGRectMake(37 , 0,self.titleLabel!.frame.width - 13, self.header!.frame.maxY)
                self.titleLabel!.textAlignment = .Left
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
            self.deleteButton!.frame = CGRectMake( bounds.maxX - 54, 0 , 54, self.header!.frame.height)
            left = left + 30
        }
        
        
        self.saveButton!.frame = CGRectMake(self.view.bounds.maxX - left , 0 , 71, self.header!.frame.height)
        self.titleLabel!.frame = CGRectMake(16, 0, (bounds.width - 32), self.header!.frame.maxY)
        
        self.content.frame = CGRectMake(0, self.header!.frame.maxY , bounds.width , bounds.height - self.header!.frame.height )
        
        if self.viewTypeAdress != nil{
            self.viewTypeAdress?.frame = CGRectMake( (bounds.width - 180) / 2 , 0 , 180 , 45)
        }
        self.setContentSize()
        
        if self.addFRomMg{
            self.backButton?.hidden =  true
        }
        
    }
    
    func checkSelected(sender:UIButton) {
        if sender.selected{
            return
        }
        if sender == self.addressShipingButton{
            self.addressFiscalButton!.selected = false
            self.presentedView(TypeAddress.Shiping)
        }else{
            self.addressShipingButton!.selected = false
            self.presentedView(TypeAddress.FiscalPerson)
        }
        sender.selected = !(sender.selected)
    }
    
    func checkSelectedFisical(sender:UIButton) {
        if sender.selected{
            return
        }
        if sender == self.addressFiscalPersonButton{
            self.addressFiscalMoralButton!.selected = false
             self.presentedView(TypeAddress.FiscalPerson)
        }else{
            self.addressFiscalPersonButton!.selected = false
             self.presentedView(TypeAddress.FiscalMoral)
        }
        sender.selected = !(sender.selected)
    }
    
    func presentedView(typeDest:TypeAddress){
        if typeDest == self.typeAddress{
            return
        }
        
        switch (typeDest ) {
        case .Shiping:
            if  self.viewAddress == nil{
                self.viewAddress = ShippingAddress(frame:self.bounds, isLogin: self.isLogin, isIpad: self.isIpad)
                 self.viewAddress!.isLogin = self.isLogin
                self.viewAddress!.delegate = self
            }
            self.viewAddress!.allAddress = self.allAddress
            self.viewAddress!.frame = CGRectMake(0,  self.viewTypeAdress!.frame.maxY  , self.view.bounds.width , 600)
            self.content!.addSubview(self.viewAddress!)
            
            if typeAddress == TypeAddress.FiscalPerson {
                self.content!.bringSubviewToFront(self.viewAddressFisical!)
            }else{
                self.content!.bringSubviewToFront(self.viewAddressMoral!)
            }
            self.content!.bringSubviewToFront(self.viewTypeAdressFiscal!)
            
            UIView.animateWithDuration(0.4, animations: {
                
                self.viewTypeAdressFiscal!.frame = CGRectMake(self.view.bounds.width, self.viewTypeAdress!.frame.maxY, self.viewTypeAdressFiscal!.frame.width , self.viewTypeAdressFiscal!.frame.height)
                
                if self.typeAddress == TypeAddress.FiscalPerson {
                    self.viewAddressFisical!.frame =  CGRectMake(self.view.bounds.width, self.viewTypeAdressFiscal!.frame.maxY, self.viewAddress!.frame.width , self.viewAddress!.frame.height)
                }else{
                    
                    self.viewAddressMoral!.frame =  CGRectMake(self.view.bounds.width, self.viewTypeAdressFiscal!.frame.maxY, self.viewAddress!.frame.width , self.viewAddress!.frame.height)
                }
                
                }, completion: {(bool : Bool) in
                    if bool {
                        
                        if self.typeAddress == TypeAddress.FiscalPerson {
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
        case .FiscalPerson:
            if self.viewAddressFisical == nil{
                self.viewAddressFisical =   FiscalAddressPersonF(frame:self.bounds, isLogin: self.isLogin, isIpad: self.isIpad)
                self.viewAddressFisical!.delegate = self
            }
             self.viewAddressFisical!.allAddress = self.allAddress
            self.setupViewFiscal()
            if (self.typeAddress == TypeAddress.Shiping){
                self.viewTypeAdressFiscal!.frame = CGRectMake(self.view.bounds.width, self.viewTypeAdress!.frame.maxY, self.view.bounds.width , 78)
                self.viewAddressFisical!.frame =   CGRectMake(self.view.bounds.width,  self.viewTypeAdressFiscal!.frame.maxY  , self.view.bounds.width , 658 )
                self.content!.addSubview(self.viewAddressFisical!)
                self.content.bringSubviewToFront(self.viewAddressFisical!)
                UIView.animateWithDuration(0.4, animations: {
                    self.viewAddressFisical!.frame =   CGRectMake(0,  self.viewTypeAdressFiscal!.frame.maxY  , self.view.bounds.width , 658 )
                    self.viewTypeAdressFiscal!.frame = CGRectMake(0, self.viewTypeAdress!.frame.maxY, self.viewTypeAdressFiscal!.frame.width , self.viewTypeAdressFiscal!.frame.height)
                    }, completion: {(bool : Bool) in
                        if bool {
                            self.viewAddress!.removeFromSuperview()
                            self.typeAddress = typeDest
                            self.setContentSize()
                        }
                })
            }else{
                self.viewAddressFisical!.allAddress = self.allAddress
                self.viewAddressFisical!.frame = CGRectMake(0, self.viewTypeAdressFiscal!.frame.maxY, self.view.bounds.width , 610)
                self.content!.addSubview(self.viewAddressFisical!)
                self.content.bringSubviewToFront(self.viewAddressMoral!)
                UIView.animateWithDuration(0.4, animations: {
                    self.viewAddressMoral!.frame =  CGRectMake(self.view.bounds.width, self.viewTypeAdressFiscal!.frame.maxY, self.view.bounds.width , 610 )
                    }, completion: {(bool : Bool) in
                        if bool {
                            self.viewAddressMoral!.removeFromSuperview()
                            self.typeAddress = typeDest
                            self.setContentSize()
                        }
                })
            }
        case .FiscalMoral:
            if self.viewAddressMoral == nil{
                self.viewAddressMoral =   FiscalAddressPersonM(frame:self.bounds,  isLogin: self.isLogin, isIpad:self.isIpad)
                self.viewAddressMoral!.delegate = self
            }
            self.viewAddressMoral!.allAddress = self.allAddress
            self.viewAddressMoral!.frame = CGRectMake(self.view.bounds.width,  self.viewTypeAdressFiscal!.frame.maxY  , self.view.bounds.width , 610)
            self.content!.addSubview(self.viewAddressMoral!)
            self.content!.bringSubviewToFront(self.viewAddressMoral!)
            
            UIView.animateWithDuration(0.4, animations: {
                self.viewAddressMoral!.frame = CGRectMake(0,  self.viewTypeAdressFiscal!.frame.maxY  , self.view.bounds.width , 610)
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
        case .Shiping:
            let height : CGFloat = self.viewAddress!.showSuburb == true ? 600 : 600-190
            self.viewAddress?.frame = CGRectMake(0.0, self.viewTypeAdress != nil ? 45 : 0 , bounds.width , height)
            self.content.contentSize = CGSize(width: bounds.width, height: self.viewAddress!.frame.maxY + 40 )
            self.content.bringSubviewToFront(self.viewAddress!)
        case .FiscalPerson:
            self.setupViewFiscal()
            let height  : CGFloat = self.viewAddressFisical!.showSuburb == true ? 658 : 658-190
            self.viewAddressFisical?.frame = CGRectMake(0.0, self.viewTypeAdressFiscal!.frame.maxY, bounds.width , height)
            self.content.contentSize = CGSize(width: bounds.width, height: self.viewAddressFisical!.frame.maxY + 40 )
            self.content!.bringSubviewToFront(self.viewTypeAdressFiscal!)
            self.content.bringSubviewToFront(self.viewAddressFisical!)
        case .FiscalMoral:
            self.setupViewFiscal()
             let height  : CGFloat = self.viewAddressMoral!.showSuburb == true ? 610 : 610-190
            self.viewAddressMoral?.frame = CGRectMake(0.0,  self.viewTypeAdressFiscal!.frame.maxY, bounds.width , height)
            self.content.contentSize = CGSize(width: bounds.width, height: self.viewAddressMoral!.frame.maxY + 40 )
            self.content!.bringSubviewToFront(self.viewTypeAdressFiscal!)
            self.content.bringSubviewToFront(self.viewAddressMoral!)
        //default:
        //    break
        }
        
        if  isLogin {           
             self.saveButton!.frame = CGRectMake((bounds.width - 290) / 2 , self.viewAddress!.frame.maxY + 20, 290, 40)
             self.saveButton!.titleLabel?.textAlignment = .Center
             self.content.contentSize = CGSize(width: bounds.width, height: self.viewAddress!.frame.maxY + 100 )
        }
    }
    
    func validateZip(isvalidate: Bool) {
        self.validateZip = isvalidate
    }
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        let val = CGSizeMake(self.view.frame.width, content.contentSize.height)
        return val
    }
    
    func saveGrAddres(params:NSDictionary,successBlock:((Bool) -> Void)?) {
        
        
        
        
    }
    
    func registryAddress(userName:String,password:String,successBlock:((Bool) -> Void)?){
        
        let service = GRAddressAddService()
        var params = self.viewAddress!.getParams()
        
        let paramsSend =  service.buildParams("", addressID: "", zipCode: params["zipCode"] as! String, street:params["street"] as! String, innerNumber:params["innerNumber"] as! String, state:"" , county:"", neighborhoodID:params["neighborhoodID"] as! String, phoneNumber:params["TelNumber"]as! String , outerNumber:params["outerNumber"] as! String, adName:params["name"] as! String, reference1:"" , reference2:"" , storeID:"" ,storeName: "", operationType:"A" , preferred: true)
        
            service.callService(requestParams: paramsSend, successBlock: { (resultCall:NSDictionary) -> Void  in
            print("Se realizao la direccion")
            
            if let message = resultCall["message"] as? String {
                print("\(message)")
            }

            // agregar login antes de agregar la direccion 
                
                let service = LoginService()
                let params  = service.buildParams(userName, password: password)
                service.callService(params, successBlock: { (result:NSDictionary) -> Void in
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
    
    
    func save(sender:UIButton) {
        if successCallBackRegistry != nil {
            successCallBackRegistry?()
            return
        }
        self.saveBock(sender, successBlock: nil)
    }
 
    func saveBock(sender:UIButton?,successBlock:((Bool) -> Void)?) {
        var params : NSDictionary? = nil
        var service :  BaseService!
        
            switch (typeAddress) {
            case .Shiping:
                if self.viewAddress!.validateAddress(){
                    params = self.viewAddress!.getParams()
                    
                    if self.idAddress == nil{
                        service = AddShippingAddressService()
                    }else{
                        service = UpdateShippingAddressService()
                    }
                    
                }
            case .FiscalPerson:
                if self.viewAddressFisical!.validateAddress(){
                    params = self.viewAddressFisical?.getParams()
                    if self.idAddress == nil{
                        service = AddFiscalAddressService()
                    }else{
                        service = UpdateFiscalAddressService()
                    }
                }
            case .FiscalMoral:
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
                
                if addressShippingCont >= 12 && typeAddress == .Shiping {
                    self.alertView!.setMessage(NSLocalizedString("profile.address.shipping.error.max",comment:""))
                    self.alertView!.showErrorIcon("OK")
                    self.back()
                    return
                }
                
                if addressFiscalCount >= 12 && (typeAddress == .FiscalPerson || typeAddress == .FiscalMoral) {
                    self.alertView!.setMessage(NSLocalizedString("profile.address.fiscal.error.max",comment:""))
                    self.alertView!.showErrorIcon("OK")
                    self.back()
                    return
                }
                
                if self.showSaveAlert {
                    self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
                }
                
                service.callPOSTService(params!, successBlock:{ (resultCall:NSDictionary?) in
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
                        self.navigationController?.popViewControllerAnimated(true)
                    }else {
                        
                        self.successCallBack!()
                    }
                    
                    ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_UPDATE_ADDRESS.rawValue, label:"")
                    
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
    
    func deleteAddress(sender:UIButton){
        let service = DeleteAddressesByUserService()
        service.buildParams(self.idAddress! as String)
        self.view.endEditing(true)
        if sender.tag == 100 {
            self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
        }else{
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
        }
        
        self.alertView!.setMessage(NSLocalizedString("profile.message.delete",comment:""))
        service.callService(NSDictionary(), successBlock:{ (resultCall:NSDictionary?) in
            if let message = resultCall!["message"] as? String {
                self.alertView!.setMessage("\(message)")
                self.alertView!.showDoneIcon()
            }//if let message = resultCall!["message"] as? String {
            self.navigationController!.popViewControllerAnimated(true)
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

