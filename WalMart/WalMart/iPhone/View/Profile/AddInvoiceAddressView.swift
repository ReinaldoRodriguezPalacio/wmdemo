//
//  AddInvoiceAddressView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 02/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class AddInvoiceAddressView:GRAddAddressView, AddressViewDelegate {

    var viewAddressFisical: AddressView? = nil
    var viewAddressMoral: AddressView? = nil
    var allAddress: NSArray! = []
    var typeAddress: TypeAddress = TypeAddress.fiscalPerson
    var addressFiscalPersonButton: UIButton? = nil
    var addressFiscalMoralButton: UIButton? = nil
    var viewTypeAdressFiscal: UIView? = nil
    var viewTypeAdress: UIView? = nil
    var heightView: CGFloat = 500
    var addressShippingCont = 0
    var addressFiscalCount = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func setup() {
        super.setup()
        
        self.scrollForm = TPKeyboardAvoidingScrollView()
        self.scrollForm!.scrollDelegate = self
        self.heightView = (typeAddress == TypeAddress.fiscalMoral ? 500 : 550)
        self.scrollForm!.contentSize = CGSize(width: self.frame.width,height: heightView)
        self.addSubview(scrollForm!)
        
        switch (typeAddress ) {
        case .fiscalPerson:
            self.viewAddressFisical = FiscalAddressPersonF(frame:CGRect(x: 0, y: 78, width: self.bounds.width , height: 480), isLogin: false , isIpad: false, typeAddress: typeAddress)
            self.viewAddressFisical!.usePopupPicker = false
            self.viewAddressFisical!.allAddress = self.allAddress
            self.scrollForm!.addSubview(self.viewAddressFisical!)
            self.viewAddressFisical?.defaultPrefered = false
            self.viewAddressFisical!.typeAddress = typeAddress
            self.viewAddressFisical!.delegate = self
            
        case .fiscalMoral:
            self.viewAddressMoral = FiscalAddressPersonM(frame:CGRect(x: 0, y: 78, width: self.bounds.width , height: 432),  isLogin: false, isIpad:false, typeAddress: typeAddress)
            self.viewAddressMoral!.usePopupPicker = false
            self.viewAddressMoral!.allAddress = self.allAddress
            self.viewAddressMoral?.defaultPrefered = false
            self.scrollForm!.addSubview(self.viewAddressMoral!)
            self.viewAddressMoral!.typeAddress = typeAddress
            self.viewAddressMoral!.delegate = self
        default:
            self.viewAddressFisical = FiscalAddressPersonF(frame:CGRect(x: 0, y: 78, width: self.bounds.width , height: 480), isLogin: false , isIpad: false, typeAddress: typeAddress)
            self.viewAddressFisical!.usePopupPicker = false
            self.viewAddressFisical!.allAddress = self.allAddress
            self.scrollForm!.addSubview(self.viewAddressFisical!)
            self.viewAddressFisical?.defaultPrefered = false
            self.viewAddressFisical!.typeAddress = typeAddress
        }
        
        self.setupViewFiscal()
        
    }
    
    
    func setupViewFiscal(){
        if viewTypeAdressFiscal==nil{
            viewTypeAdressFiscal = UIView(frame:CGRect(x: 0, y: 0 , width: self.bounds.width , height: 78))
            
            let checkTermOff : UIImage = UIImage(named:"checkTermOff")!
            let checkTermOn : UIImage = UIImage(named:"check_full")!
            
            var titleLabel: UILabel? = nil
            var viewButton : UIView? = nil
            
            addressFiscalPersonButton = UIButton()
            addressFiscalPersonButton!.setImage(checkTermOff, for: UIControlState())
            addressFiscalPersonButton!.setImage(checkTermOn, for: UIControlState.selected)
            addressFiscalPersonButton!.addTarget(self, action: #selector(AddInvoiceAddressView.checkSelectedFisical(_:)), for: UIControlEvents.touchUpInside)
            addressFiscalPersonButton!.setTitle(NSLocalizedString("profile.address.person",  comment: ""), for: UIControlState())
            addressFiscalPersonButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalPersonButton!.titleLabel?.textColor = WMColor.reg_gray
            addressFiscalPersonButton!.setTitleColor(WMColor.reg_gray, for: UIControlState())
            addressFiscalPersonButton!.setTitleColor(WMColor.light_gray, for: UIControlState.disabled)
            addressFiscalPersonButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
            
            addressFiscalMoralButton = UIButton()
            addressFiscalMoralButton!.setImage(checkTermOff, for: UIControlState())
            addressFiscalMoralButton!.setImage(checkTermOn, for: UIControlState.selected)
            addressFiscalMoralButton!.addTarget(self, action: #selector(AddInvoiceAddressView.checkSelectedFisical(_:)), for: UIControlEvents.touchUpInside)
            addressFiscalMoralButton!.setTitle(NSLocalizedString("profile.address.corporate",  comment: ""), for: UIControlState())
            addressFiscalMoralButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalMoralButton!.titleLabel?.textColor = WMColor.reg_gray
            addressFiscalMoralButton!.setTitleColor(WMColor.reg_gray, for: UIControlState())
            addressFiscalMoralButton!.setTitleColor(WMColor.light_gray, for: UIControlState.disabled)
            addressFiscalMoralButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
            
            if typeAddress == TypeAddress.fiscalMoral{
                self.addressFiscalMoralButton!.isSelected = true
            }else{
                addressFiscalPersonButton!.isSelected = true
            }
            
            titleLabel = UILabel()
            titleLabel!.textColor = WMColor.light_blue
            titleLabel!.font = WMFont.fontMyriadProLightOfSize(14)
            titleLabel!.text =  NSLocalizedString("profile.address.fiscal.section", comment: "")
            titleLabel!.backgroundColor = UIColor.white
            
            viewButton = UIView(frame: CGRect(x: 30,  y: 32 , width: self.bounds.width - 60, height: 45))
            
            viewButton!.addSubview(addressFiscalPersonButton!)
            viewButton!.addSubview(addressFiscalMoralButton!)
            
            self.viewTypeAdressFiscal!.addSubview(titleLabel!)
            self.viewTypeAdressFiscal!.addSubview(viewButton!)
            
            titleLabel!.frame = CGRect(x: 16, y: 0, width: self.bounds.width - 20, height: 35 )
            self.viewTypeAdressFiscal!.backgroundColor = UIColor.white
            
            addressFiscalPersonButton!.frame = CGRect(x: 0, y: 0, width: 107 , height: 45)
            addressFiscalMoralButton!.frame = CGRect(x: (viewButton!.frame.width / 2), y: 0, width: 107 , height: 45)
            self.scrollForm!.addSubview(self.viewTypeAdressFiscal!)
        } else {
            self.scrollForm!.addSubview(self.viewTypeAdressFiscal!)
            self.viewTypeAdressFiscal!.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 78)
        }
    }

    
    override func layoutSubviews() {
        self.scrollForm?.frame = CGRect(x: 0,y: 0,width: self.frame.width,height: self.frame.height - 66)
        self.layerLine.frame = CGRect(x: 0,y: self.frame.height - 66,width: self.frame.width, height: 1)
        
        if self.showCancelButton {
            self.saveButton?.frame = CGRect(x: (self.frame.width/2) + 8 , y: self.layerLine.frame.maxY + 16, width: 125, height: 34)
            self.cancelButton?.frame = CGRect(x: (self.frame.width/2) - 133 , y: self.layerLine.frame.maxY + 16, width: 125, height: 34)
            self.cancelButton!.isHidden = false
        }else{
            self.saveButton?.frame = CGRect(x: (self.frame.width/2) - 63 , y: self.layerLine.frame.maxY + 16, width: 125, height: 34)
            self.cancelButton?.frame = CGRect(x: (self.frame.width/2) - 63 , y: self.layerLine.frame.maxY + 16, width: 125, height: 34)
            self.cancelButton!.isHidden = true
        }
    }
    
    override func save() {
        self.saveBock(self.saveButton!, successBlock: nil)
    }
    
    func saveBock(_ sender:UIButton?,successBlock:((Bool) -> Void)?) {
        var params : [String:Any]? = nil
        var service :  BaseService!
        
        switch (typeAddress) {
        case .fiscalPerson:
            if self.viewAddressFisical!.validateAddress(){
                params = self.viewAddressFisical?.getParams()
                service = AddFiscalAddressService()
            }
        case .fiscalMoral:
            if self.viewAddressMoral!.validateAddress(){
                params = self.viewAddressMoral?.getParams()
                service = AddFiscalAddressService()
            }
            default:
              break
        }
        if params != nil{
            self.endEditing(true)
            self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
            
            if addressShippingCont >= 12 && typeAddress == .shiping {
                self.alertView!.setMessage(NSLocalizedString("profile.address.shipping.error.max",comment:""))
                self.alertView!.showErrorIcon("OK")
                self.cancel()
                return
            }
            
            if addressFiscalCount >= 12 && (typeAddress == .fiscalPerson || typeAddress == .fiscalMoral) {
                self.alertView!.setMessage(NSLocalizedString("profile.address.fiscal.error.max",comment:""))
                self.alertView!.showErrorIcon("OK")
                self.cancel()
                return
            }
            
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            
            service.callPOSTService(params!, successBlock:{ (resultCall:[String:Any]?) in
                if let message = resultCall!["message"] as? String {
                    let addres  = params!["AddressID"] as? String
                    self.alertView!.setMessage(NSLocalizedString("profile.address.add.ok",comment:""))
                    self.alertView!.showDoneIcon()
                }
                
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_UPDATE_ADDRESS.rawValue, label:"")
                
                }
                , errorBlock: {(error: NSError) in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            })
        }
        
    }

    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    override func contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
        return CGSize(width: self.scrollForm!.frame.width, height: heightView)
    }
    
    func checkSelectedFisical(_ sender:UIButton) {
        if sender.isSelected{
            return
        }
        if sender == self.addressFiscalPersonButton{
            typeAddress = TypeAddress.fiscalPerson
            self.addressFiscalMoralButton!.isSelected = false
        }else{
            typeAddress = TypeAddress.fiscalMoral
            self.addressFiscalPersonButton!.isSelected = false
        }
        sender.isSelected = !(sender.isSelected)
        self.scrollForm!.removeFromSuperview()
        setup()
    }
    
    
    //MARK: - AddressViewDelegate
    func setContentSize(){
        let bounds = self.bounds
        switch (typeAddress ) {
        case .fiscalPerson:
            self.setupViewFiscal()
            let height: CGFloat =  698
            self.heightView =  height + 40
            self.viewAddressFisical?.frame = CGRect(x: 0.0, y: self.viewTypeAdressFiscal!.frame.maxY, width: bounds.width , height: self.heightView)
            self.scrollForm!.contentSize = CGSize(width: bounds.width, height:self.heightView )
            self.scrollForm!.bringSubview(toFront: self.viewTypeAdressFiscal!)
            self.scrollForm!.bringSubview(toFront: self.viewAddressFisical!)
        case .fiscalMoral:
            self.setupViewFiscal()
            let height: CGFloat = 650
            self.heightView =  height + 40
            self.viewAddressMoral?.frame = CGRect(x: 0.0,  y: self.viewTypeAdressFiscal!.frame.maxY, width: bounds.width , height: self.heightView)
            self.scrollForm!.contentSize = CGSize(width: bounds.width, height: self.heightView)
            self.scrollForm!.bringSubview(toFront: self.viewTypeAdressFiscal!)
            self.scrollForm!.bringSubview(toFront: self.viewAddressMoral!)
            
        default:
            break
        }
    }

}
