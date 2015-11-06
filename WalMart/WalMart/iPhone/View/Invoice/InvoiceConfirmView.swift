//
//  InvoiceConfirmView.swift
//  WalMart
//
//  Created by Alonso Salcido on 06/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class InvoiceConfirmView: UIView,TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate {

    var scrollForm: TPKeyboardAvoidingScrollView!
    var titleName : UILabel!
    var nameLabel: UILabel!
    var titleRfc : UILabel!
    var rfcLabel: UILabel!
    var titleTicketNumber : UILabel!
    var ticketNumberLabel: UILabel!
    var titleTransactionNumber : UILabel!
    var transactionNumberLabel: UILabel!
    var titleIEPS : UILabel!
    var iepsLabel: UILabel!
    var titleSocialReason : UILabel!
    var socialReasonLabel: UILabel!
    var titleAddress : UILabel!
    var addressLabel: UILabel!
    var saveButton: UIButton?
    var editButton: UIButton?
    
    var name: String?
    var rfc: String?
    var ticketNumber: String?
    var transactionNumber: String?
    var ieps: String?
    var socialReason: String?
    var address: String?
    
    let leftRightPadding  : CGFloat = CGFloat(16)
    let errorLabelWidth  : CGFloat = CGFloat(150)
    let fieldHeight  : CGFloat = CGFloat(14)
    let separatorField  : CGFloat = CGFloat(20)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.scrollForm = TPKeyboardAvoidingScrollView()
        self.scrollForm.delegate = self
        self.scrollForm.scrollDelegate = self
        self.scrollForm.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.scrollForm)
        
        //Address Super
        self.titleName = UILabel()
        self.titleName!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleName!.text =  "Nombre"
        self.titleName!.textColor = WMColor.listAddressHeaderSectionColor
        self.scrollForm.addSubview(self.titleName!)
        
        self.nameLabel = UILabel()
        self.nameLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.nameLabel!.text =  "Gerardo"
        self.nameLabel!.textColor = WMColor.UIColorFromRGB(0x646C79)
        self.scrollForm.addSubview(self.nameLabel!)
        
        self.titleRfc = UILabel()
        self.titleRfc!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleRfc!.text =  "RFC"
        self.titleRfc!.textColor = WMColor.listAddressHeaderSectionColor
        self.scrollForm.addSubview(self.titleRfc!)
        
        self.rfcLabel = UILabel()
        self.rfcLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.rfcLabel!.text =  "SAML900410MZ5"
        self.rfcLabel!.textColor = WMColor.UIColorFromRGB(0x646C79)
        self.scrollForm.addSubview(self.rfcLabel!)
        
        self.titleTicketNumber = UILabel()
        self.titleTicketNumber!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleTicketNumber!.text =  "Número de ticket"
        self.titleTicketNumber!.textColor = WMColor.listAddressHeaderSectionColor
        self.scrollForm.addSubview(self.titleTicketNumber!)
        
        self.ticketNumberLabel = UILabel()
        self.ticketNumberLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.ticketNumberLabel!.text =  "749 4667 32567 1234"
        self.ticketNumberLabel!.textColor = WMColor.UIColorFromRGB(0x646C79)
        self.scrollForm.addSubview(self.ticketNumberLabel!)
        
        self.titleTransactionNumber = UILabel()
        self.titleTransactionNumber!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleTransactionNumber!.text =  "Número de transacción"
        self.titleTransactionNumber!.textColor = WMColor.listAddressHeaderSectionColor
        self.scrollForm.addSubview(self.titleTransactionNumber!)
        
        self.transactionNumberLabel = UILabel()
        self.transactionNumberLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.transactionNumberLabel!.text =  "3456"
        self.transactionNumberLabel!.textColor = WMColor.UIColorFromRGB(0x646C79)
        self.scrollForm.addSubview(self.transactionNumberLabel!)
        
        self.titleIEPS = UILabel()
        self.titleIEPS!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleIEPS!.text =  "Declaro IEPS"
        self.titleIEPS!.textColor = WMColor.listAddressHeaderSectionColor
        self.scrollForm.addSubview(self.titleIEPS!)
        
        self.iepsLabel = UILabel()
        self.iepsLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.iepsLabel!.text =  "Sí declaro"
        self.iepsLabel!.textColor = WMColor.UIColorFromRGB(0x646C79)
        self.scrollForm.addSubview(self.iepsLabel!)
        
        self.titleSocialReason = UILabel()
        self.titleSocialReason!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleSocialReason!.text =  "Razon social"
        self.titleSocialReason!.textColor = WMColor.listAddressHeaderSectionColor
        self.scrollForm.addSubview(self.titleSocialReason!)
        
        self.socialReasonLabel = UILabel()
        self.socialReasonLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.socialReasonLabel!.text =  "Persona Fisica"
        self.socialReasonLabel!.textColor = WMColor.UIColorFromRGB(0x646C79)
        self.scrollForm.addSubview(self.socialReasonLabel!)
        
        self.titleAddress = UILabel()
        self.titleAddress!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleAddress!.text =  "Dirección de Facturación"
        self.titleAddress!.textColor = WMColor.listAddressHeaderSectionColor
        self.scrollForm.addSubview(self.titleAddress!)
        
        self.addressLabel = UILabel()
        self.addressLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.addressLabel!.text =  "Casa de la Abuela \n Avenida de los Insurgentes #1432"
        self.addressLabel!.numberOfLines = 2
        self.addressLabel!.textColor = WMColor.UIColorFromRGB(0x646C79)
        self.scrollForm.addSubview(self.addressLabel!)
        
        self.editButton = UIButton()
        self.editButton!.setTitle("Editar", forState:.Normal)
        self.editButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.editButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.editButton!.backgroundColor = WMColor.listAddressHeaderSectionColor
        self.editButton!.layer.cornerRadius = 17
        self.editButton!.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(editButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Generar Factura", forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.loginSignInButonBgColor
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: "next", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(saveButton!)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let widthLessMargin = self.frame.width - leftRightPadding
        let rightPadding = leftRightPadding * 2
        self.scrollForm.frame = CGRectMake(0, 46, self.frame.width , self.frame.height - 112)
        self.titleName.frame = CGRectMake(leftRightPadding, 16, self.frame.width - rightPadding , fieldHeight)
        self.nameLabel.frame = CGRectMake(leftRightPadding, self.titleName.frame.maxY , self.frame.width - rightPadding , fieldHeight)
        self.titleRfc!.frame = CGRectMake(leftRightPadding, self.nameLabel.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.rfcLabel!.frame = CGRectMake(leftRightPadding, self.titleRfc.frame.maxY , self.frame.width - rightPadding , fieldHeight)
        self.titleTicketNumber.frame = CGRectMake(leftRightPadding, self.rfcLabel.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.ticketNumberLabel.frame = CGRectMake(leftRightPadding, self.titleTicketNumber.frame.maxY, self.frame.width - rightPadding , fieldHeight)
        self.titleTransactionNumber.frame = CGRectMake(leftRightPadding, self.ticketNumberLabel.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.transactionNumberLabel.frame = CGRectMake(leftRightPadding, self.titleTransactionNumber.frame.maxY , self.frame.width - rightPadding , fieldHeight)
        self.titleIEPS.frame = CGRectMake(leftRightPadding, self.transactionNumberLabel.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.iepsLabel!.frame = CGRectMake(leftRightPadding, self.titleIEPS.frame.maxY, self.frame.width - rightPadding , fieldHeight)
        self.titleSocialReason.frame = CGRectMake(leftRightPadding, self.iepsLabel.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.socialReasonLabel.frame = CGRectMake(leftRightPadding, self.titleSocialReason.frame.maxY, self.frame.width - rightPadding , fieldHeight)
        self.titleAddress.frame = CGRectMake(leftRightPadding, self.socialReasonLabel.frame.maxY + separatorField, self.frame.width - rightPadding , fieldHeight)
        self.addressLabel.frame = CGRectMake(leftRightPadding, self.titleAddress.frame.maxY, self.frame.width - rightPadding , fieldHeight)
        self.scrollForm.contentSize = CGSize(width: self.frame.width,height: self.addressLabel.frame.maxY)
        self.editButton!.frame = CGRectMake(leftRightPadding, self.scrollForm!.frame.maxY + 13.0, 125, 34)
        self.saveButton!.frame = CGRectMake(widthLessMargin - 125 , self.scrollForm!.frame.maxY + 13.0, 125, 34)
    }
    
    func setValues(){
       self.nameLabel!.text =  self.name
        self.rfcLabel!.text =  self.rfc
        self.ticketNumberLabel!.text =  self.ticketNumber
        self.transactionNumberLabel!.text =  self.transactionNumber
        self.iepsLabel!.text =  self.ieps
        self.socialReasonLabel!.text =  self.socialReason
        self.addressLabel!.text =  self.address
    }
    
}