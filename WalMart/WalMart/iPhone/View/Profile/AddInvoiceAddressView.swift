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
    var typeAddress: TypeAddress = TypeAddress.FiscalPerson
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
        self.heightView = (typeAddress == TypeAddress.FiscalMoral ? 500 : 550)
        self.scrollForm!.contentSize = CGSizeMake(self.frame.width,heightView)
        self.addSubview(scrollForm!)
        
        switch (typeAddress ) {
        case .FiscalPerson:
            self.viewAddressFisical = FiscalAddressPersonF(frame:CGRectMake(0, 78, self.bounds.width , 480), isLogin: false , isIpad: false, typeAddress: typeAddress)
            self.viewAddressFisical!.usePopupPicker = false
            self.viewAddressFisical!.allAddress = self.allAddress
            self.scrollForm!.addSubview(self.viewAddressFisical!)
            self.viewAddressFisical?.defaultPrefered = false
            self.viewAddressFisical!.typeAddress = typeAddress
            self.viewAddressFisical!.delegate = self
            
        case .FiscalMoral:
            self.viewAddressMoral = FiscalAddressPersonM(frame:CGRectMake(0, 78, self.bounds.width , 432),  isLogin: false, isIpad:false, typeAddress: typeAddress)
            self.viewAddressMoral!.usePopupPicker = false
            self.viewAddressMoral!.allAddress = self.allAddress
            self.viewAddressMoral?.defaultPrefered = false
            self.scrollForm!.addSubview(self.viewAddressMoral!)
            self.viewAddressMoral!.typeAddress = typeAddress
            self.viewAddressMoral!.delegate = self
        default:
            self.viewAddressFisical = FiscalAddressPersonF(frame:CGRectMake(0, 78, self.bounds.width , 480), isLogin: false , isIpad: false, typeAddress: typeAddress)
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
            viewTypeAdressFiscal = UIView(frame:CGRectMake(0, 0 , self.bounds.width , 78))
            
            let checkTermOff : UIImage = UIImage(named:"checkTermOff")!
            let checkTermOn : UIImage = UIImage(named:"check_full")!
            
            var titleLabel: UILabel? = nil
            var viewButton : UIView? = nil
            
            addressFiscalPersonButton = UIButton()
            addressFiscalPersonButton!.setImage(checkTermOff, forState: UIControlState.Normal)
            addressFiscalPersonButton!.setImage(checkTermOn, forState: UIControlState.Selected)
            addressFiscalPersonButton!.addTarget(self, action: #selector(AddInvoiceAddressView.checkSelectedFisical(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            addressFiscalPersonButton!.setTitle(NSLocalizedString("profile.address.person",  comment: ""), forState: UIControlState.Normal)
            addressFiscalPersonButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalPersonButton!.titleLabel?.textColor = WMColor.reg_gray
            addressFiscalPersonButton!.setTitleColor(WMColor.reg_gray, forState: UIControlState.Normal)
            addressFiscalPersonButton!.setTitleColor(WMColor.light_gray, forState: UIControlState.Disabled)
            addressFiscalPersonButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
            
            addressFiscalMoralButton = UIButton()
            addressFiscalMoralButton!.setImage(checkTermOff, forState: UIControlState.Normal)
            addressFiscalMoralButton!.setImage(checkTermOn, forState: UIControlState.Selected)
            addressFiscalMoralButton!.addTarget(self, action: #selector(AddInvoiceAddressView.checkSelectedFisical(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            addressFiscalMoralButton!.setTitle(NSLocalizedString("profile.address.corporate",  comment: ""), forState: UIControlState.Normal)
            addressFiscalMoralButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalMoralButton!.titleLabel?.textColor = WMColor.reg_gray
            addressFiscalMoralButton!.setTitleColor(WMColor.reg_gray, forState: UIControlState.Normal)
            addressFiscalMoralButton!.setTitleColor(WMColor.light_gray, forState: UIControlState.Disabled)
            addressFiscalMoralButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
            
            if typeAddress == TypeAddress.FiscalMoral{
                self.addressFiscalMoralButton!.selected = true
            }else{
                addressFiscalPersonButton!.selected = true
            }
            
            titleLabel = UILabel()
            titleLabel!.textColor = WMColor.light_blue
            titleLabel!.font = WMFont.fontMyriadProLightOfSize(14)
            titleLabel!.text =  NSLocalizedString("profile.address.fiscal.section", comment: "")
            titleLabel!.backgroundColor = UIColor.whiteColor()
            
            viewButton = UIView(frame: CGRectMake(30,  32 , self.bounds.width - 60, 45))
            
            viewButton!.addSubview(addressFiscalPersonButton!)
            viewButton!.addSubview(addressFiscalMoralButton!)
            
            self.viewTypeAdressFiscal!.addSubview(titleLabel!)
            self.viewTypeAdressFiscal!.addSubview(viewButton!)
            
            titleLabel!.frame = CGRectMake(16, 0, self.bounds.width - 20, 35 )
            self.viewTypeAdressFiscal!.backgroundColor = UIColor.whiteColor()
            
            addressFiscalPersonButton!.frame = CGRectMake(0, 0, 107 , 45)
            addressFiscalMoralButton!.frame = CGRectMake((viewButton!.frame.width / 2), 0, 107 , 45)
            self.scrollForm!.addSubview(self.viewTypeAdressFiscal!)
        } else {
            self.scrollForm!.addSubview(self.viewTypeAdressFiscal!)
            self.viewTypeAdressFiscal!.frame = CGRectMake(0, 0, self.bounds.width, 78)
        }
    }

    
    override func layoutSubviews() {
        self.scrollForm?.frame = CGRectMake(0,0,self.frame.width,self.frame.height - 66)
        self.layerLine.frame = CGRectMake(0,self.frame.height - 66,self.frame.width, 1)
        
        if self.showCancelButton {
            self.saveButton?.frame = CGRectMake((self.frame.width/2) + 8 , self.layerLine.frame.maxY + 16, 125, 34)
            self.cancelButton?.frame = CGRectMake((self.frame.width/2) - 133 , self.layerLine.frame.maxY + 16, 125, 34)
            self.cancelButton!.hidden = false
        }else{
            self.saveButton?.frame = CGRectMake((self.frame.width/2) - 63 , self.layerLine.frame.maxY + 16, 125, 34)
            self.cancelButton?.frame = CGRectMake((self.frame.width/2) - 63 , self.layerLine.frame.maxY + 16, 125, 34)
            self.cancelButton!.hidden = true
        }
    }
    
    override func save() {
        self.saveBock(self.saveButton!, successBlock: nil)
    }
    
    func saveBock(sender:UIButton?,successBlock:((Bool) -> Void)?) {
        var params : NSDictionary? = nil
        var service :  BaseService!
        
        switch (typeAddress) {
        case .FiscalPerson:
            if self.viewAddressFisical!.validateAddress(){
                params = self.viewAddressFisical?.getParams()
                service = AddFiscalAddressService()
            }
        case .FiscalMoral:
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
            
            if addressShippingCont >= 12 && typeAddress == .Shiping {
                self.alertView!.setMessage(NSLocalizedString("profile.address.shipping.error.max",comment:""))
                self.alertView!.showErrorIcon("OK")
                self.cancel()
                return
            }
            
            if addressFiscalCount >= 12 && (typeAddress == .FiscalPerson || typeAddress == .FiscalMoral) {
                self.alertView!.setMessage(NSLocalizedString("profile.address.fiscal.error.max",comment:""))
                self.alertView!.showErrorIcon("OK")
                self.cancel()
                return
            }
            
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            
            service.callPOSTService(params!, successBlock:{ (resultCall:NSDictionary?) in
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
    override func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        return CGSizeMake(self.scrollForm!.frame.width, heightView)
    }
    
    func checkSelectedFisical(sender:UIButton) {
        if sender.selected{
            return
        }
        if sender == self.addressFiscalPersonButton{
            typeAddress = TypeAddress.FiscalPerson
            self.addressFiscalMoralButton!.selected = false
        }else{
            typeAddress = TypeAddress.FiscalMoral
            self.addressFiscalPersonButton!.selected = false
        }
        sender.selected = !(sender.selected)
        self.scrollForm!.removeFromSuperview()
        setup()
    }
    
    
    //MARK: - AddressViewDelegate
    func setContentSize(){
        let bounds = self.bounds
        switch (typeAddress ) {
        case .FiscalPerson:
            self.setupViewFiscal()
            let height: CGFloat =  698
            self.heightView =  height + 40
            self.viewAddressFisical?.frame = CGRectMake(0.0, self.viewTypeAdressFiscal!.frame.maxY, bounds.width , self.heightView)
            self.scrollForm!.contentSize = CGSize(width: bounds.width, height:self.heightView )
            self.scrollForm!.bringSubviewToFront(self.viewTypeAdressFiscal!)
            self.scrollForm!.bringSubviewToFront(self.viewAddressFisical!)
        case .FiscalMoral:
            self.setupViewFiscal()
            let height: CGFloat = 650
            self.heightView =  height + 40
            self.viewAddressMoral?.frame = CGRectMake(0.0,  self.viewTypeAdressFiscal!.frame.maxY, bounds.width , self.heightView)
            self.scrollForm!.contentSize = CGSize(width: bounds.width, height: self.heightView)
            self.scrollForm!.bringSubviewToFront(self.viewTypeAdressFiscal!)
            self.scrollForm!.bringSubviewToFront(self.viewAddressMoral!)
            
        default:
            break
        }
    }

}