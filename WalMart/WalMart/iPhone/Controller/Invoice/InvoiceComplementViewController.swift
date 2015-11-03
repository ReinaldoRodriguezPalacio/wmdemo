//
//  InvoiceComplementViewController.swift
//  WalMart
//
//  Created by Alonso Salcido on 29/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//


import Foundation

class InvoiceComplementViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate,UIScrollViewDelegate {
    let secSep: CGFloat = 30.0
    let titleSep: CGFloat = 15.0
    let fieldSep: CGFloat = 10.0
    let headerHeight: CGFloat = 46
    
    var address: FormFieldView?
    
    var sectionIEPS : UILabel!
    var sectionTouristInfo : UILabel!
    var sectionSocialReason : UILabel!
    var sectionAddress : UILabel!
    
    var iepsYesSelect: UIButton?
    var iepsNoSelect: UIButton?
    var touristYesSelect: UIButton?
    var touristNoSelect: UIButton?
    var addressFiscalPersonSelect: UIButton?
    var addressFiscalMoralSelect: UIButton?
    var infoIEPSutton: UIButton?
    var finishButton: UIButton?
    var returnButton: UIButton?

    
    var modalView: AlertModalView?

    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_INVOICE.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.titleLabel?.text = NSLocalizedString("moreoptions.title.Factura",comment:"")
        
        let margin: CGFloat = 15.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 40.0
        let lheight: CGFloat = 25.0
        let widthLessMargin = self.view.frame.width - margin
        let checkTermEmpty : UIImage = UIImage(named:"check_empty")!
        let checkTermFull : UIImage = UIImage(named:"check_full")!
        
        
        //Inician secciones
        self.sectionIEPS = self.buildSectionTitle("Declaro IEPS (Aplica solo para vinos y licores)", frame: CGRectMake(margin, headerHeight, width - 24, lheight))
        self.view.addSubview(sectionIEPS)
        
        self.infoIEPSutton = UIButton(frame: CGRectMake(widthLessMargin - 16, headerHeight + 4, 16, 16))
        self.infoIEPSutton!.setBackgroundImage(UIImage(named:"invoice_info"), forState: UIControlState.Normal)
        self.infoIEPSutton!.addTarget(self, action: "infoIEPSImage:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.infoIEPSutton!)
        
        iepsYesSelect = UIButton(frame: CGRectMake(margin,sectionIEPS.frame.maxY,45,fheight))
        iepsYesSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        iepsYesSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        iepsYesSelect!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        iepsYesSelect!.setTitle("Sí", forState: UIControlState.Normal)
        iepsYesSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        iepsYesSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        iepsYesSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        iepsYesSelect!.selected = true
        self.view.addSubview(self.iepsYesSelect!)
        
        self.iepsNoSelect = UIButton(frame: CGRectMake(iepsYesSelect!.frame.maxX + 31,sectionIEPS.frame.maxY,50,fheight))
        iepsNoSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        iepsNoSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        iepsNoSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        iepsNoSelect!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        iepsNoSelect!.setTitle("No", forState: UIControlState.Normal)
        iepsNoSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        iepsNoSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        self.view.addSubview(self.iepsNoSelect!)
        
        self.sectionTouristInfo = self.buildSectionTitle("¿Eres turista, pasajero en tránsito o extranjero?", frame: CGRectMake(margin, self.iepsYesSelect!.frame.maxY + 5.0, width, lheight))
        self.view.addSubview(sectionTouristInfo)
        
        touristYesSelect = UIButton(frame: CGRectMake(margin,sectionTouristInfo.frame.maxY,45,fheight))
        touristYesSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        touristYesSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        touristYesSelect!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        touristYesSelect!.setTitle("Sí", forState: UIControlState.Normal)
        touristYesSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        touristYesSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        touristYesSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        touristYesSelect!.selected = true
        self.view.addSubview(self.touristYesSelect!)
        
        self.touristNoSelect = UIButton(frame: CGRectMake(touristYesSelect!.frame.maxX + 31,sectionTouristInfo.frame.maxY,50,fheight))
        touristNoSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        touristNoSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        touristNoSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        touristNoSelect!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        touristNoSelect!.setTitle("No", forState: UIControlState.Normal)
        touristNoSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        touristNoSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        self.view.addSubview(self.touristNoSelect!)
        
        self.sectionSocialReason = self.buildSectionTitle("Razón Social", frame: CGRectMake(margin, self.touristYesSelect!.frame.maxY + 5.0, width, lheight))
        self.view.addSubview(sectionSocialReason)
        
        addressFiscalPersonSelect = UIButton(frame: CGRectMake(margin,sectionSocialReason.frame.maxY,113,fheight))
        addressFiscalPersonSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        addressFiscalPersonSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        addressFiscalPersonSelect!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        addressFiscalPersonSelect!.setTitle("Persona Física", forState: UIControlState.Normal)
        addressFiscalPersonSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        addressFiscalPersonSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        addressFiscalPersonSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        addressFiscalPersonSelect!.selected = true
        self.view.addSubview(self.addressFiscalPersonSelect!)
        
        self.addressFiscalMoralSelect = UIButton(frame: CGRectMake(addressFiscalPersonSelect!.frame.maxX + 31,sectionSocialReason.frame.maxY,123,fheight))
        addressFiscalMoralSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        addressFiscalMoralSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        addressFiscalMoralSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        addressFiscalMoralSelect!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        addressFiscalMoralSelect!.setTitle("Persona Moral", forState: UIControlState.Normal)
        addressFiscalMoralSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        addressFiscalMoralSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        self.view.addSubview(self.addressFiscalMoralSelect!)
        
        self.sectionAddress = self.buildSectionTitle("Dirección de Facturación", frame: CGRectMake(margin, self.addressFiscalPersonSelect!.frame.maxY + 5.0, width, lheight))
        self.view.addSubview(sectionAddress)
        
        self.address = FormFieldView(frame: CGRectMake(margin, self.sectionAddress!.frame.maxY + 5.0, width, fheight))
        self.address!.isRequired = true
        self.address!.setCustomPlaceholder("Dirección")
        self.address!.typeField = TypeField.List
        self.address!.nameField = "Dirección"
        self.address!.maxLength = 6
        self.address!.setImageTypeField()
        self.view.addSubview(self.address!)
        
        self.returnButton = UIButton(frame: CGRectMake(margin, self.address!.frame.maxY + 25.0, 140.0, fheight))
        self.returnButton!.setTitle("Regresar", forState:.Normal)
        self.returnButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.returnButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.returnButton!.backgroundColor = WMColor.listAddressHeaderSectionColor
        self.returnButton!.layer.cornerRadius = 20
        self.returnButton!.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(returnButton!)
        
        self.finishButton = UIButton(frame: CGRectMake(widthLessMargin - 140 , self.address!.frame.maxY + 25.0, 140.0, fheight))
        self.finishButton!.setTitle("Finalizar", forState:.Normal)
        self.finishButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.finishButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.finishButton!.backgroundColor = WMColor.loginSignInButonBgColor
        self.finishButton!.layer.cornerRadius = 20
        self.finishButton!.addTarget(self, action: "next", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(finishButton!)
    }
    
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.listAddressHeaderSectionColor
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
}

