//
//  InvoiceComplementViewController.swift
//  WalMart
//
//  Created by Alonso Salcido on 29/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//


import Foundation

class InvoiceComplementViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate,UIScrollViewDelegate,AlertPickerViewDelegate, AlertPickerSelectOptionDelegate {
    let headerHeight: CGFloat = 46
    let fheight: CGFloat = 40.0
    let lheight: CGFloat = 25.0
    let margin: CGFloat = 15.0
    
    var address: FormFieldView?
    var content: TPKeyboardAvoidingScrollView!
    
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

    var arrayAddressFiscal: NSArray?
    var arrayAddressFiscalNames: [String]! = []
    var selectedAddress: NSDictionary?
    
    var modalView: AlertModalView?
    var picker: AlertPickerView!
    var viewLoad: WMLoadingView?
    var addressFormFisical: FiscalAddressPersonF?
    var addressFormMoral: FiscalAddressPersonM?
    var scrollForm : TPKeyboardAvoidingScrollView!

//    override func getScreenGAIName() -> String {
//        return WMGAIUtils.SCREEN_INVOICE.rawValue
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.titleLabel?.text = NSLocalizedString("moreoptions.title.Invoice",comment:"")
        
        let width = self.view.frame.width - (2*margin)
        let widthLessMargin = self.view.frame.width - margin
        let checkTermEmpty : UIImage = UIImage(named:"check_empty")!
        let checkTermFull : UIImage = UIImage(named:"check_full")!
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRectMake(0.0, headerHeight, self.view.bounds.width, self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content)
        
        //Inician secciones
        self.sectionIEPS = self.buildSectionTitle("Declaro IEPS (Aplica solo para vinos y licores)", frame: CGRectMake(margin, 0, width, lheight))
        self.content.addSubview(sectionIEPS)
        
        iepsYesSelect = UIButton(frame: CGRectMake(margin,sectionIEPS.frame.maxY,45,fheight))
        iepsYesSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        iepsYesSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        iepsYesSelect!.addTarget(self, action: #selector(InvoiceComplementViewController.checkIEPS(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        iepsYesSelect!.setTitle("Sí", forState: UIControlState.Normal)
        iepsYesSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        iepsYesSelect!.titleLabel?.textAlignment = .Left
        iepsYesSelect!.setTitleColor(WMColor.gray, forState: UIControlState.Normal)
        iepsYesSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        self.content.addSubview(self.iepsYesSelect!)
        
        self.iepsNoSelect = UIButton(frame: CGRectMake(iepsYesSelect!.frame.maxX + 31,sectionIEPS.frame.maxY,50,fheight))
        iepsNoSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        iepsNoSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        iepsNoSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        iepsNoSelect!.addTarget(self, action: #selector(InvoiceComplementViewController.checkIEPS(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        iepsNoSelect!.setTitle("No", forState: UIControlState.Normal)
        iepsNoSelect!.titleLabel?.textAlignment = .Left
        iepsNoSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        iepsNoSelect!.setTitleColor(WMColor.gray, forState: UIControlState.Normal)
        iepsNoSelect!.selected = true
        self.content.addSubview(self.iepsNoSelect!)
        
        self.sectionTouristInfo = self.buildSectionTitle("¿Eres turista, pasajero en tránsito o extranjero?", frame: CGRectMake(margin, self.iepsYesSelect!.frame.maxY + 5.0, width, lheight))
        self.content.addSubview(sectionTouristInfo)
        
        touristYesSelect = UIButton(frame: CGRectMake(margin,sectionTouristInfo.frame.maxY,45,fheight))
        touristYesSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        touristYesSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        touristYesSelect!.addTarget(self, action: #selector(InvoiceComplementViewController.checkTourist(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        touristYesSelect!.setTitle("Sí", forState: UIControlState.Normal)
        touristYesSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        touristYesSelect!.setTitleColor(WMColor.gray, forState: UIControlState.Normal)
        touristYesSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        touristYesSelect!.titleLabel?.textAlignment = .Left
        self.content.addSubview(self.touristYesSelect!)
        
        self.touristNoSelect = UIButton(frame: CGRectMake(touristYesSelect!.frame.maxX + 31,sectionTouristInfo.frame.maxY,50,fheight))
        touristNoSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        touristNoSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        touristNoSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        touristNoSelect!.addTarget(self, action: #selector(InvoiceComplementViewController.checkTourist(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        touristNoSelect!.setTitle("No", forState: UIControlState.Normal)
        touristNoSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        touristNoSelect!.setTitleColor(WMColor.gray, forState: UIControlState.Normal)
        touristNoSelect!.selected = true
        touristNoSelect!.titleLabel?.textAlignment = .Left
        self.content.addSubview(self.touristNoSelect!)
        
        self.sectionSocialReason = self.buildSectionTitle("Razón Social", frame: CGRectMake(margin, self.touristYesSelect!.frame.maxY + 5.0, width, lheight))
        self.content.addSubview(sectionSocialReason)
        
        addressFiscalPersonSelect = UIButton(frame: CGRectMake(margin,sectionSocialReason.frame.maxY,113,fheight))
        addressFiscalPersonSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        addressFiscalPersonSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        addressFiscalPersonSelect!.addTarget(self, action: #selector(InvoiceComplementViewController.checkAddress(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        addressFiscalPersonSelect!.setTitle("Persona Física", forState: UIControlState.Normal)
        addressFiscalPersonSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        addressFiscalPersonSelect!.setTitleColor(WMColor.gray, forState: UIControlState.Normal)
        addressFiscalPersonSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        addressFiscalPersonSelect!.selected = true
        addressFiscalPersonSelect!.titleLabel?.textAlignment = .Left
        self.content.addSubview(self.addressFiscalPersonSelect!)
        
        self.addressFiscalMoralSelect = UIButton(frame: CGRectMake(addressFiscalPersonSelect!.frame.maxX + 31,sectionSocialReason.frame.maxY,123,fheight))
        addressFiscalMoralSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        addressFiscalMoralSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        addressFiscalMoralSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        addressFiscalMoralSelect!.addTarget(self, action: #selector(InvoiceComplementViewController.checkAddress(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        addressFiscalMoralSelect!.setTitle("Persona Moral", forState: UIControlState.Normal)
        addressFiscalMoralSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        addressFiscalMoralSelect!.setTitleColor(WMColor.gray, forState: UIControlState.Normal)
        addressFiscalMoralSelect!.titleLabel?.textAlignment = .Left
        self.content.addSubview(self.addressFiscalMoralSelect!)
        
        self.sectionAddress = self.buildSectionTitle("Dirección de Facturación", frame: CGRectMake(margin, self.addressFiscalPersonSelect!.frame.maxY + 5.0, width, lheight))
        self.content.addSubview(sectionAddress)
        
        self.address = FormFieldView(frame: CGRectMake(margin, self.sectionAddress!.frame.maxY + 5.0, width, fheight))
        self.address!.isRequired = true
        self.address!.setCustomPlaceholder("Dirección")
        self.address!.typeField = TypeField.List
        self.address!.nameField = "Dirección"
        self.address!.maxLength = 6
        self.address!.setImageTypeField()
        self.content.addSubview(self.address!)
        
        self.returnButton = UIButton(frame: CGRectMake(margin, self.address!.frame.maxY + 25.0, 140.0, fheight))
        self.returnButton!.setTitle("Regresar", forState:.Normal)
        self.returnButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.returnButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.returnButton!.backgroundColor = WMColor.light_blue
        self.returnButton!.layer.cornerRadius = 20
        self.returnButton!.addTarget(self, action: Selector("back"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(returnButton!)
        
        self.finishButton = UIButton(frame: CGRectMake(widthLessMargin - 140 , self.address!.frame.maxY + 25.0, 140.0, fheight))
        self.finishButton!.setTitle("Finalizar", forState:.Normal)
        self.finishButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.finishButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.finishButton!.backgroundColor = WMColor.green
        self.finishButton!.layer.cornerRadius = 20
        self.finishButton!.addTarget(self, action: #selector(InvoiceComplementViewController.confirm), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(finishButton!)
        
        self.picker = AlertPickerView.initPickerWithDefault()
        self.addViewLoad()
        self.callServiceAddress()
        
        self.address!.onBecomeFirstResponder = { () in
            
            let btnNewAddress = WMRoundButton()
            btnNewAddress.setTitle("nueva", forState: UIControlState.Normal)
            btnNewAddress.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
            btnNewAddress.setBackgroundColor(WMColor.light_blue, size: CGSizeMake(64.0, 22), forUIControlState: UIControlState.Normal)
            btnNewAddress.layer.cornerRadius = 2.0
        
            self.picker!.addRigthActionButton(btnNewAddress)
            self.picker!.selectOptionDelegate = self
            self.picker!.selectDelegate = true
            self.picker!.sender = self.address!
            self.picker!.titleHeader = "Direcciones"
            self.picker!.delegate = self
            //self.picker!.selected = self.selectedConfirmation
            self.picker!.setValues(self.address!.nameField, values: self.arrayAddressFiscalNames!)
            self.picker!.hiddenRigthActionButton(false)
            self.picker!.cellType = TypeField.Check
            self.picker!.showPicker()
        }
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
        self.content.frame = CGRectMake(0.0, headerHeight, self.view.bounds.width, self.view.bounds.height - (headerHeight + 120))
        self.sectionIEPS.frame = CGRectMake(margin, 16, width, lheight)
        self.iepsYesSelect!.frame = CGRectMake(margin,sectionIEPS.frame.maxY,45,fheight)
        self.iepsNoSelect!.frame = CGRectMake(iepsYesSelect!.frame.maxX + 31,sectionIEPS.frame.maxY,50,fheight)
        let posYsection = buildSectionTourist()
        self.sectionSocialReason.frame = CGRectMake(margin, posYsection + 5.0, width, lheight)
        self.addressFiscalPersonSelect!.frame = CGRectMake(margin,sectionSocialReason.frame.maxY,113,fheight)
        self.addressFiscalMoralSelect!.frame = CGRectMake(addressFiscalPersonSelect!.frame.maxX + 31,sectionSocialReason.frame.maxY,123,fheight)
        self.sectionAddress.frame = CGRectMake(margin, self.addressFiscalPersonSelect!.frame.maxY + 5.0, width, lheight)
        self.address!.frame = CGRectMake(margin, self.sectionAddress!.frame.maxY + 5.0, width, fheight)
        self.content.contentSize = CGSizeMake(self.view.frame.width, address!.frame.maxY + 5.0)
        self.returnButton!.frame = CGRectMake(margin, self.content!.frame.maxY - 15, 140.0, fheight)
        self.finishButton!.frame = CGRectMake(widthLessMargin - 140 , self.content!.frame.maxY - 15, 140.0, fheight)
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
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
    
    func confirm(){
        self.showConfirmView()
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
    
    func showConfirmView(){
        let confirmView = InvoiceConfirmView(frame: CGRectMake(0, 0,  288, 465))
        let modalView = AlertModalView.initModalWithView("Confirmar Datos",innerView: confirmView)
        modalView.showPicker()
    }
    
    func callServiceAddress(){
        let addressService = AddressByUserService()
        addressService.callService({ (resultCall:NSDictionary) -> Void in
            self.arrayAddressFiscal = []
            
            if let fiscalAddress = resultCall["fiscalAddresses"] as? NSArray {
                self.arrayAddressFiscal = fiscalAddress
                self.getAddressFiscalNames(fiscalAddress)
                self.removeViewLoad()
            }
            }, errorBlock: { (error:NSError) -> Void in
                print("errorBlock")
                self.removeViewLoad()
        })
    }
    
    func getAddressFiscalNames(fiscalAddresses:NSArray){
        for address in fiscalAddresses{
            self.arrayAddressFiscalNames?.append(address["name"] as! String)
        }
    }
    
    //MARK: TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        let val = CGSizeMake(self.view.frame.width, self.content.contentSize.height)
        return val
    }
    
    //MARK: AlertPickerViewDelegate
    
    func didSelectOption(picker:AlertPickerView,indexPath: NSIndexPath,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj == self.address!{
                self.selectedAddress = self.arrayAddressFiscal![indexPath.row] as? NSDictionary
                self.address?.text = selectedStr
            }
            
        }
    }
    
    func didDeSelectOption(picker:AlertPickerView) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj == self.address!{
                //TODO: Que hacer con la direccion
            }
            
        }
    }
    
    
    
    func buttomViewSelected(sender: UIButton) {
    }
    
    
    
    func viewReplaceContent(frame:CGRect) -> UIView! {
        scrollForm = TPKeyboardAvoidingScrollView(frame: frame)
        self.scrollForm.scrollDelegate = self
        if self.addressFiscalPersonSelect!.selected {
            scrollForm.contentSize = CGSizeMake(frame.width, 490)
            scrollForm.addSubview(self.getFisicalPersonForm(CGRectMake(0, 16, 288, 465)))
        }else{
            scrollForm.contentSize = CGSizeMake(frame.width, 470)
            scrollForm.addSubview(self.getMoralPersonForm(CGRectMake(0, 16, 288, 465)))
        }
        
        /*if !self.selectedAddressHasStore{
            let serviceAddress = GRAddressesByIDService()
            serviceAddress.addressId = self.selectedAddress!
            serviceAddress.callService([:], successBlock: { (result:NSDictionary) -> Void in
                self.sAddredssForm.addressName.text = result["name"] as! String!
                self.sAddredssForm.outdoornumber.text = result["outerNumber"] as! String!
                self.sAddredssForm.indoornumber.text = result["innerNumber"] as! String!
                self.sAddredssForm.betweenFisrt.text = result["reference1"] as! String!
                self.sAddredssForm.betweenSecond.text = result["reference2"] as! String!
                self.sAddredssForm.zipcode.text = result["zipCode"] as! String!
                self.sAddredssForm.street.text = result["street"] as! String!
                let neighborhoodID = result["neighborhoodID"] as! String!
                let storeID = result["storeID"] as! String!
                self.sAddredssForm.setZipCodeAnfFillFields(self.sAddredssForm.zipcode.text!, neighborhoodID: neighborhoodID, storeID: storeID)
                self.sAddredssForm.idAddress = result["addressID"] as! String!
                }) { (error:NSError) -> Void in
            }
        }*/
        self.picker!.titleLabel.text = NSLocalizedString("checkout.field.new.address", comment:"")
        return scrollForm
    }
    
    func saveReplaceViewSelected() {
        /*self.picker!.onClosePicker = nil
        self.addViewLoad()
        let service = GRAddressAddService()
        let dictSend = sAddredssForm.getAddressDictionary(sAddredssForm.idAddress, delete: false)
        if dictSend != nil {
            
            self.scrollForm.resignFirstResponder()
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            if self.addressItems?.count < 12 {
                service.callService(requestParams: dictSend!, successBlock: { (resultCall:NSDictionary) -> Void  in
                    print("Se realizao la direccion")
                    self.picker!.closeNew()
                    self.picker!.closePicker()
                    self.selectedAddress = resultCall["addressID"] as! String!
                    if let message = resultCall["message"] as? String {
                        self.alertView!.setMessage("\(message)")
                    }
                    self.alertView!.showDoneIcon()
                    
                    self.picker!.titleLabel.textAlignment = .Center
                    self.picker!.titleLabel.frame =  CGRectMake(40, self.picker!.titleLabel.frame.origin.y, self.picker!.titleLabel.frame.width, self.picker!.titleLabel.frame.height)
                    self.picker!.isNewAddres =  false
                    self.reloadUserAddresses()
                    
                    }) { (error:NSError) -> Void in
                        self.removeViewLoad()
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                        self.alertView!.close()
                }
            }
            else{
                self.alertView!.setMessage(NSLocalizedString("profile.address.error.max",comment:""))
                self.alertView!.showErrorIcon("Ok")
            }
        }*/
    }
    
    //MARK: AlertPickerSelectOptionDelegate
    func didSelectOptionAtIndex(indexPath: NSIndexPath) {
       //let address = self.arrayAddressFiscal![indexPath.row] as? NSDictionary
    }
    
    func getFisicalPersonForm(frame:CGRect) -> FiscalAddressPersonF{
        return FiscalAddressPersonF(frame: frame, isLogin: false, isIpad: false)
    }
    
    func getMoralPersonForm(frame:CGRect) -> FiscalAddressPersonM{
        return FiscalAddressPersonM(frame: frame, isLogin: false, isIpad: false)
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad!.backgroundColor = UIColor.whiteColor()
            viewLoad!.startAnnimating(true)
            self.view.addSubview(viewLoad!)
        }
    }
    
    func removeViewLoad(){
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
}

