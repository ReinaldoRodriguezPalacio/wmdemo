//
//  InvoiceComplementViewController.swift
//  WalMart
//
//  Created by Alonso Salcido on 29/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//


import Foundation

class InvoiceComplementViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate,UIScrollViewDelegate {
    let headerHeight: CGFloat = 46
    let fheight: CGFloat = 40.0
    let lheight: CGFloat = 25.0
    let margin: CGFloat = 15.0
    
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
        
        let width = self.view.frame.width - (2*margin)
        let widthLessMargin = self.view.frame.width - margin
        let checkTermEmpty : UIImage = UIImage(named:"check_empty")!
        let checkTermFull : UIImage = UIImage(named:"check_full")!
        
        
        //Inician secciones
        self.sectionIEPS = self.buildSectionTitle("Declaro IEPS (Aplica solo para vinos y licores)", frame: CGRectMake(margin, headerHeight, width, lheight))
        self.view.addSubview(sectionIEPS)
        
        iepsYesSelect = UIButton(frame: CGRectMake(margin,sectionIEPS.frame.maxY,45,fheight))
        iepsYesSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        iepsYesSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        iepsYesSelect!.addTarget(self, action: "checkIEPS:", forControlEvents: UIControlEvents.TouchUpInside)
        iepsYesSelect!.setTitle("Sí", forState: UIControlState.Normal)
        iepsYesSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        iepsYesSelect!.titleLabel?.textAlignment = .Left
        iepsYesSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        iepsYesSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        self.view.addSubview(self.iepsYesSelect!)
        
        self.iepsNoSelect = UIButton(frame: CGRectMake(iepsYesSelect!.frame.maxX + 31,sectionIEPS.frame.maxY,50,fheight))
        iepsNoSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        iepsNoSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        iepsNoSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        iepsNoSelect!.addTarget(self, action: "checkIEPS:", forControlEvents: UIControlEvents.TouchUpInside)
        iepsNoSelect!.setTitle("No", forState: UIControlState.Normal)
        iepsNoSelect!.titleLabel?.textAlignment = .Left
        iepsNoSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        iepsNoSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        iepsNoSelect!.selected = true
        self.view.addSubview(self.iepsNoSelect!)
        
        self.sectionTouristInfo = self.buildSectionTitle("¿Eres turista, pasajero en tránsito o extranjero?", frame: CGRectMake(margin, self.iepsYesSelect!.frame.maxY + 5.0, width, lheight))
        self.view.addSubview(sectionTouristInfo)
        
        touristYesSelect = UIButton(frame: CGRectMake(margin,sectionTouristInfo.frame.maxY,45,fheight))
        touristYesSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        touristYesSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        touristYesSelect!.addTarget(self, action: "checkTourist:", forControlEvents: UIControlEvents.TouchUpInside)
        touristYesSelect!.setTitle("Sí", forState: UIControlState.Normal)
        touristYesSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        touristYesSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        touristYesSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        touristYesSelect!.titleLabel?.textAlignment = .Left
        self.view.addSubview(self.touristYesSelect!)
        
        self.touristNoSelect = UIButton(frame: CGRectMake(touristYesSelect!.frame.maxX + 31,sectionTouristInfo.frame.maxY,50,fheight))
        touristNoSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        touristNoSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        touristNoSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        touristNoSelect!.addTarget(self, action: "checkTourist:", forControlEvents: UIControlEvents.TouchUpInside)
        touristNoSelect!.setTitle("No", forState: UIControlState.Normal)
        touristNoSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        touristNoSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        touristNoSelect!.selected = true
        touristNoSelect!.titleLabel?.textAlignment = .Left
        self.view.addSubview(self.touristNoSelect!)
        
        self.sectionSocialReason = self.buildSectionTitle("Razón Social", frame: CGRectMake(margin, self.touristYesSelect!.frame.maxY + 5.0, width, lheight))
        self.view.addSubview(sectionSocialReason)
        
        addressFiscalPersonSelect = UIButton(frame: CGRectMake(margin,sectionSocialReason.frame.maxY,113,fheight))
        addressFiscalPersonSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        addressFiscalPersonSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        addressFiscalPersonSelect!.addTarget(self, action: "checkAddress:", forControlEvents: UIControlEvents.TouchUpInside)
        addressFiscalPersonSelect!.setTitle("Persona Física", forState: UIControlState.Normal)
        addressFiscalPersonSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        addressFiscalPersonSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        addressFiscalPersonSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        addressFiscalPersonSelect!.selected = true
        addressFiscalPersonSelect!.titleLabel?.textAlignment = .Left
        self.view.addSubview(self.addressFiscalPersonSelect!)
        
        self.addressFiscalMoralSelect = UIButton(frame: CGRectMake(addressFiscalPersonSelect!.frame.maxX + 31,sectionSocialReason.frame.maxY,123,fheight))
        addressFiscalMoralSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        addressFiscalMoralSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        addressFiscalMoralSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        addressFiscalMoralSelect!.addTarget(self, action: "checkAddress:", forControlEvents: UIControlEvents.TouchUpInside)
        addressFiscalMoralSelect!.setTitle("Persona Moral", forState: UIControlState.Normal)
        addressFiscalMoralSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        addressFiscalMoralSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        addressFiscalMoralSelect!.titleLabel?.textAlignment = .Left
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.buildView()
    }

    //Marck Build
    func buildView(){
        let width = self.view.frame.width - (2*margin)
        let widthLessMargin = self.view.frame.width - margin
        
        //Inician secciones
        self.sectionIEPS.frame = CGRectMake(margin, headerHeight, width, lheight)
        self.iepsYesSelect!.frame = CGRectMake(margin,sectionIEPS.frame.maxY,45,fheight)
        self.iepsNoSelect!.frame = CGRectMake(iepsYesSelect!.frame.maxX + 31,sectionIEPS.frame.maxY,50,fheight)
        let posYsection = buildSectionTourist()
        self.sectionSocialReason.frame = CGRectMake(margin, posYsection + 5.0, width, lheight)
        self.addressFiscalPersonSelect!.frame = CGRectMake(margin,sectionSocialReason.frame.maxY,113,fheight)
        self.addressFiscalMoralSelect!.frame = CGRectMake(addressFiscalPersonSelect!.frame.maxX + 31,sectionSocialReason.frame.maxY,123,fheight)
        self.sectionAddress.frame = CGRectMake(margin, self.addressFiscalPersonSelect!.frame.maxY + 5.0, width, lheight)
        self.address!.frame = CGRectMake(margin, self.sectionAddress!.frame.maxY + 5.0, width, fheight)
        self.returnButton!.frame = CGRectMake(margin, self.address!.frame.maxY + 25.0, 140.0, fheight)
        self.finishButton!.frame = CGRectMake(widthLessMargin - 140 , self.address!.frame.maxY + 25.0, 140.0, fheight)
    }
    
    func buildSectionTourist() -> CGFloat{
        var posY = self.iepsYesSelect!.frame.maxY
        let width = self.view.frame.width - (2*margin)
        self.sectionTouristInfo.hidden = self.iepsYesSelect!.selected
        self.touristYesSelect!.hidden = self.iepsYesSelect!.selected
        self.touristNoSelect!.hidden = self.iepsYesSelect!.selected
        if(self.iepsNoSelect!.selected){
            self.sectionTouristInfo.frame = CGRectMake(margin, self.iepsYesSelect!.frame.maxY + 5.0, width, lheight)
            self.touristYesSelect!.frame = CGRectMake(margin,sectionTouristInfo.frame.maxY,45,fheight)
            self.touristNoSelect!.frame = CGRectMake(touristYesSelect!.frame.maxX + 31,sectionTouristInfo.frame.maxY,50,fheight)
            posY = self.touristYesSelect!.frame.maxY
        }
        
        return  posY
    }
    
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.listAddressHeaderSectionColor
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
    
    func checkIEPS(sender:UIButton) {
        self.checkSelected(sender, yesButton: self.iepsYesSelect!, noButton: self.iepsNoSelect!)
        self.buildView()
    }
    
    func checkTourist(sender:UIButton) {
        self.checkSelected(sender, yesButton: self.touristYesSelect!, noButton: self.touristNoSelect!)
        if sender == self.touristYesSelect!{
            showTouristForm()
        }
    }
    
    func checkAddress(sender:UIButton) {
        self.checkSelected(sender, yesButton: self.addressFiscalPersonSelect!, noButton: self.addressFiscalMoralSelect!)
    }
    
    func checkSelected(sender:UIButton, yesButton: UIButton, noButton:UIButton) {
        if sender.selected{
            return
        }
        if sender == yesButton{
            noButton.selected = false
        }else{
            yesButton.selected = false
        }
        sender.selected = !(sender.selected)
    }
    
    func showTouristForm(){
        let touristView = TouristInformationForm(frame: CGRectMake(0, 0,  288, 465))
        let modalView = AlertModalView.initModalWithView("Tipo de Tránsito",innerView: touristView)
        modalView.showPicker()
    }
    
}

