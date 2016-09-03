//
//  AddInvoiceAddressView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 02/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class AddInvoiceAddressView:GRAddAddressView {

    var viewAddressFisical: AddressView? = nil
    var viewAddressMoral: AddressView? = nil
    var allAddress: NSArray! = []
    var typeAddress: TypeAddress = TypeAddress.FiscalPerson
    var addressFiscalPersonButton: UIButton? = nil
    var addressFiscalMoralButton: UIButton? = nil
    var viewTypeAdressFiscal: UIView? = nil
    var viewTypeAdress: UIView? = nil
    
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
        self.scrollForm!.contentSize = CGSizeMake(self.frame.width, 610)
        self.addSubview(scrollForm!)
        
        switch (typeAddress ) {
        case .FiscalPerson:
            self.viewAddressFisical = FiscalAddressPersonF(frame:CGRectMake(0, 78, self.bounds.width , 610), isLogin: false , isIpad: false, typeAddress: typeAddress)
            self.viewAddressFisical!.allAddress = self.allAddress
            self.scrollForm!.addSubview(self.viewAddressFisical!)
            self.viewAddressFisical?.defaultPrefered = false
            self.viewAddressFisical!.typeAddress = typeAddress
            //self.viewAddressFisical!.delegate = self
            
        case .FiscalMoral:
            self.viewAddressMoral = FiscalAddressPersonM(frame:CGRectMake(0, 78, self.bounds.width , 610),  isLogin: false, isIpad:false, typeAddress: typeAddress)
            self.viewAddressMoral!.allAddress = self.allAddress
            self.viewAddressMoral?.defaultPrefered = false
            self.scrollForm!.addSubview(self.viewAddressMoral!)
            self.viewAddressMoral!.typeAddress = typeAddress
            //self.viewAddressMoral!.delegate = self
        default:
            self.viewAddressFisical = FiscalAddressPersonF(frame:CGRectMake(0, 78, self.bounds.width , 610), isLogin: false , isIpad: false, typeAddress: typeAddress)
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
            let checkTermOn : UIImage = UIImage(named:"checkAddressOn")!
            
            var titleLabel: UILabel? = nil
            var viewButton : UIView? = nil
            
            addressFiscalPersonButton = UIButton()
            addressFiscalPersonButton!.setImage(checkTermOff, forState: UIControlState.Normal)
            addressFiscalPersonButton!.setImage(checkTermOn, forState: UIControlState.Selected)
            addressFiscalPersonButton!.addTarget(self, action: #selector(AddressViewController.checkSelectedFisical(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            addressFiscalPersonButton!.setTitle(NSLocalizedString("profile.address.person",  comment: ""), forState: UIControlState.Normal)
            addressFiscalPersonButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalPersonButton!.titleLabel?.textColor = WMColor.gray_reg
            addressFiscalPersonButton!.setTitleColor(WMColor.gray_reg, forState: UIControlState.Normal)
            addressFiscalPersonButton!.setTitleColor(WMColor.light_gray, forState: UIControlState.Disabled)
            addressFiscalPersonButton!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0);
            
            addressFiscalMoralButton = UIButton()
            addressFiscalMoralButton!.setImage(checkTermOff, forState: UIControlState.Normal)
            addressFiscalMoralButton!.setImage(checkTermOn, forState: UIControlState.Selected)
            addressFiscalMoralButton!.addTarget(self, action: #selector(AddressViewController.checkSelectedFisical(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            addressFiscalMoralButton!.setTitle(NSLocalizedString("profile.address.corporate",  comment: ""), forState: UIControlState.Normal)
            addressFiscalMoralButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
            addressFiscalMoralButton!.titleLabel?.textColor = WMColor.gray_reg
            addressFiscalMoralButton!.setTitleColor(WMColor.gray_reg, forState: UIControlState.Normal)
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
            
            
            viewButton = UIView(frame: CGRectMake(0,  32 , 230 , 45))
            
            viewButton!.addSubview(addressFiscalPersonButton!)
            viewButton!.addSubview(addressFiscalMoralButton!)
            
            self.viewTypeAdressFiscal!.addSubview(titleLabel!)
            self.viewTypeAdressFiscal!.addSubview(viewButton!)
            
            titleLabel!.frame = CGRectMake(10, 0, self.bounds.width - 20, 35 )
            
            addressFiscalPersonButton!.frame = CGRectMake(0, 0, 107 , 45)
            addressFiscalMoralButton!.frame = CGRectMake(121, 0, 107 , 45)
            self.scrollForm!.addSubview(self.viewTypeAdressFiscal!)
            self.viewTypeAdressFiscal!.backgroundColor = UIColor.whiteColor()
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
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    override func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        return CGSizeMake(self.scrollForm!.frame.width, 610)
    }



}