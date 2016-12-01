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
    var layerLine: CALayer!
    
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
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(layerLine, at: 0)
        
        self.scrollForm = TPKeyboardAvoidingScrollView()
        self.scrollForm.delegate = self
        self.scrollForm.scrollDelegate = self
        self.scrollForm.backgroundColor = UIColor.white
        self.addSubview(self.scrollForm)
        
        //Address Super
        self.titleName = UILabel()
        self.titleName!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleName!.text =  "Nombre"
        self.titleName!.textColor = WMColor.light_blue
        self.scrollForm.addSubview(self.titleName!)
        
        self.nameLabel = UILabel()
        self.nameLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.nameLabel!.text =  "Gerardo"
        self.nameLabel!.textColor = WMColor.dark_gray
        self.scrollForm.addSubview(self.nameLabel!)
        
        self.titleRfc = UILabel()
        self.titleRfc!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleRfc!.text =  "RFC"
        self.titleRfc!.textColor = WMColor.light_blue
        self.scrollForm.addSubview(self.titleRfc!)
        
        self.rfcLabel = UILabel()
        self.rfcLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.rfcLabel!.text =  "SAML900410MZ5"
        self.rfcLabel!.textColor = WMColor.dark_gray
        self.scrollForm.addSubview(self.rfcLabel!)
        
        self.titleTicketNumber = UILabel()
        self.titleTicketNumber!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleTicketNumber!.text =  "Número de ticket"
        self.titleTicketNumber!.textColor = WMColor.light_blue
        self.scrollForm.addSubview(self.titleTicketNumber!)
        
        self.ticketNumberLabel = UILabel()
        self.ticketNumberLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.ticketNumberLabel!.text =  "749 4667 32567 1234"
        self.ticketNumberLabel!.textColor = WMColor.dark_gray
        self.scrollForm.addSubview(self.ticketNumberLabel!)
        
        self.titleTransactionNumber = UILabel()
        self.titleTransactionNumber!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleTransactionNumber!.text =  "Número de transacción"
        self.titleTransactionNumber!.textColor = WMColor.light_blue
        self.scrollForm.addSubview(self.titleTransactionNumber!)
        
        self.transactionNumberLabel = UILabel()
        self.transactionNumberLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.transactionNumberLabel!.text =  "3456"
        self.transactionNumberLabel!.textColor = WMColor.dark_gray
        self.scrollForm.addSubview(self.transactionNumberLabel!)
        
        self.titleIEPS = UILabel()
        self.titleIEPS!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleIEPS!.text =  "Declaro IEPS"
        self.titleIEPS!.textColor = WMColor.light_blue
        self.scrollForm.addSubview(self.titleIEPS!)
        
        self.iepsLabel = UILabel()
        self.iepsLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.iepsLabel!.text =  "Sí declaro"
        self.iepsLabel!.textColor = WMColor.dark_gray
        self.scrollForm.addSubview(self.iepsLabel!)
        
        self.titleSocialReason = UILabel()
        self.titleSocialReason!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleSocialReason!.text =  "Razon social"
        self.titleSocialReason!.textColor = WMColor.light_blue
        self.scrollForm.addSubview(self.titleSocialReason!)
        
        self.socialReasonLabel = UILabel()
        self.socialReasonLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.socialReasonLabel!.text =  "Persona Fisica"
        self.socialReasonLabel!.textColor = WMColor.dark_gray
        self.scrollForm.addSubview(self.socialReasonLabel!)
        
        self.titleAddress = UILabel()
        self.titleAddress!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleAddress!.text =  "Dirección de Facturación"
        self.titleAddress!.textColor = WMColor.light_blue
        self.scrollForm.addSubview(self.titleAddress!)
        
        self.addressLabel = UILabel()
        self.addressLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.addressLabel!.text =  "Casa de la Abuela \n Avenida de los Insurgentes #1432"
        self.addressLabel!.numberOfLines = 2
        self.addressLabel!.textColor = WMColor.dark_gray
        self.scrollForm.addSubview(self.addressLabel!)
        
        self.editButton = UIButton()
        self.editButton!.setTitle("Editar", for:UIControlState())
        self.editButton!.titleLabel!.textColor = UIColor.white
        self.editButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.editButton!.backgroundColor = WMColor.light_blue
        self.editButton!.layer.cornerRadius = 17
        //self.editButton!.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(editButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Generar Factura", for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(FMResultSet.next), for: UIControlEvents.touchUpInside)
        self.addSubview(saveButton!)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let widthLessMargin = self.frame.width - leftRightPadding
        let rightPadding = leftRightPadding * 2
        self.scrollForm.frame = CGRect(x: 0, y: 46, width: self.frame.width , height: self.frame.height - 112)
        self.titleName.frame = CGRect(x: leftRightPadding, y: 16, width: self.frame.width - rightPadding , height: fieldHeight)
        self.nameLabel.frame = CGRect(x: leftRightPadding, y: self.titleName.frame.maxY , width: self.frame.width - rightPadding , height: fieldHeight)
        self.titleRfc!.frame = CGRect(x: leftRightPadding, y: self.nameLabel.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.rfcLabel!.frame = CGRect(x: leftRightPadding, y: self.titleRfc.frame.maxY , width: self.frame.width - rightPadding , height: fieldHeight)
        self.titleTicketNumber.frame = CGRect(x: leftRightPadding, y: self.rfcLabel.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.ticketNumberLabel.frame = CGRect(x: leftRightPadding, y: self.titleTicketNumber.frame.maxY, width: self.frame.width - rightPadding , height: fieldHeight)
        self.titleTransactionNumber.frame = CGRect(x: leftRightPadding, y: self.ticketNumberLabel.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.transactionNumberLabel.frame = CGRect(x: leftRightPadding, y: self.titleTransactionNumber.frame.maxY , width: self.frame.width - rightPadding , height: fieldHeight)
        self.titleIEPS.frame = CGRect(x: leftRightPadding, y: self.transactionNumberLabel.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.iepsLabel!.frame = CGRect(x: leftRightPadding, y: self.titleIEPS.frame.maxY, width: self.frame.width - rightPadding , height: fieldHeight)
        self.titleSocialReason.frame = CGRect(x: leftRightPadding, y: self.iepsLabel.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.socialReasonLabel.frame = CGRect(x: leftRightPadding, y: self.titleSocialReason.frame.maxY, width: self.frame.width - rightPadding , height: fieldHeight)
        self.titleAddress.frame = CGRect(x: leftRightPadding, y: self.socialReasonLabel.frame.maxY + separatorField, width: self.frame.width - rightPadding , height: fieldHeight)
        self.addressLabel.frame = CGRect(x: leftRightPadding, y: self.titleAddress.frame.maxY, width: self.frame.width - rightPadding , height: fieldHeight * 2)
        self.scrollForm.contentSize = CGSize(width: self.frame.width,height: self.addressLabel.frame.maxY)
        self.layerLine.frame = CGRect(x: 0, y: self.scrollForm!.frame.maxY,  width: self.frame.width, height: 1)
        self.editButton!.frame = CGRect(x: leftRightPadding, y: self.scrollForm!.frame.maxY + 13.0, width: 125, height: 34)
        self.saveButton!.frame = CGRect(x: widthLessMargin - 125 , y: self.scrollForm!.frame.maxY + 13.0, width: 125, height: 34)
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
