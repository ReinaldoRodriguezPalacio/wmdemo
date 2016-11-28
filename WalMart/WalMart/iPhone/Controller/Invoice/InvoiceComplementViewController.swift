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
    var selectedAddress: [String:Any]?
    
    var modalView: AlertModalView?
    var picker: AlertPickerView!
    var viewLoad: WMLoadingView?
    var addressFormFisical: FiscalAddressPersonF?
    var addressFormMoral: FiscalAddressPersonM?
    var scrollForm : TPKeyboardAvoidingScrollView!

    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_INVOICE.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.titleLabel?.text = NSLocalizedString("moreoptions.title.Invoice",comment:"")
        
        let width = self.view.frame.width - (2*margin)
        let widthLessMargin = self.view.frame.width - margin
        let checkTermEmpty : UIImage = UIImage(named:"check_empty")!
        let checkTermFull : UIImage = UIImage(named:"check_full")!
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.white
        self.view.addSubview(self.content)
        
        //Inician secciones
        self.sectionIEPS = self.buildSectionTitle("Declaro IEPS (Aplica solo para vinos y licores)", frame: CGRect(x: margin, y: 0, width: width, height: lheight))
        self.content.addSubview(sectionIEPS)
        
        iepsYesSelect = UIButton(frame: CGRect(x: margin,y: sectionIEPS.frame.maxY,width: 45,height: fheight))
        iepsYesSelect!.setImage(checkTermEmpty, for: UIControlState())
        iepsYesSelect!.setImage(checkTermFull, for: UIControlState.selected)
        iepsYesSelect!.addTarget(self, action: #selector(InvoiceComplementViewController.checkIEPS(_:)), for: UIControlEvents.touchUpInside)
        iepsYesSelect!.setTitle("Sí", for: UIControlState())
        iepsYesSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        iepsYesSelect!.titleLabel?.textAlignment = .left
        iepsYesSelect!.setTitleColor(WMColor.gray, for: UIControlState())
        iepsYesSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        self.content.addSubview(self.iepsYesSelect!)
        
        self.iepsNoSelect = UIButton(frame: CGRect(x: iepsYesSelect!.frame.maxX + 31,y: sectionIEPS.frame.maxY,width: 50,height: fheight))
        iepsNoSelect!.setImage(checkTermEmpty, for: UIControlState())
        iepsNoSelect!.setImage(checkTermFull, for: UIControlState.selected)
        iepsNoSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        iepsNoSelect!.addTarget(self, action: #selector(InvoiceComplementViewController.checkIEPS(_:)), for: UIControlEvents.touchUpInside)
        iepsNoSelect!.setTitle("No", for: UIControlState())
        iepsNoSelect!.titleLabel?.textAlignment = .left
        iepsNoSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        iepsNoSelect!.setTitleColor(WMColor.gray, for: UIControlState())
        iepsNoSelect!.isSelected = true
        self.content.addSubview(self.iepsNoSelect!)
        
        self.sectionTouristInfo = self.buildSectionTitle("¿Eres turista, pasajero en tránsito o extranjero?", frame: CGRect(x: margin, y: self.iepsYesSelect!.frame.maxY + 5.0, width: width, height: lheight))
        self.content.addSubview(sectionTouristInfo)
        
        touristYesSelect = UIButton(frame: CGRect(x: margin,y: sectionTouristInfo.frame.maxY,width: 45,height: fheight))
        touristYesSelect!.setImage(checkTermEmpty, for: UIControlState())
        touristYesSelect!.setImage(checkTermFull, for: UIControlState.selected)
        touristYesSelect!.addTarget(self, action: #selector(InvoiceComplementViewController.checkTourist(_:)), for: UIControlEvents.touchUpInside)
        touristYesSelect!.setTitle("Sí", for: UIControlState())
        touristYesSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        touristYesSelect!.setTitleColor(WMColor.gray, for: UIControlState())
        touristYesSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        touristYesSelect!.titleLabel?.textAlignment = .left
        self.content.addSubview(self.touristYesSelect!)
        
        self.touristNoSelect = UIButton(frame: CGRect(x: touristYesSelect!.frame.maxX + 31,y: sectionTouristInfo.frame.maxY,width: 50,height: fheight))
        touristNoSelect!.setImage(checkTermEmpty, for: UIControlState())
        touristNoSelect!.setImage(checkTermFull, for: UIControlState.selected)
        touristNoSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        touristNoSelect!.addTarget(self, action: #selector(InvoiceComplementViewController.checkTourist(_:)), for: UIControlEvents.touchUpInside)
        touristNoSelect!.setTitle("No", for: UIControlState())
        touristNoSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        touristNoSelect!.setTitleColor(WMColor.gray, for: UIControlState())
        touristNoSelect!.isSelected = true
        touristNoSelect!.titleLabel?.textAlignment = .left
        self.content.addSubview(self.touristNoSelect!)
        
        self.sectionSocialReason = self.buildSectionTitle("Razón Social", frame: CGRect(x: margin, y: self.touristYesSelect!.frame.maxY + 5.0, width: width, height: lheight))
        self.content.addSubview(sectionSocialReason)
        
        addressFiscalPersonSelect = UIButton(frame: CGRect(x: margin,y: sectionSocialReason.frame.maxY,width: 113,height: fheight))
        addressFiscalPersonSelect!.setImage(checkTermEmpty, for: UIControlState())
        addressFiscalPersonSelect!.setImage(checkTermFull, for: UIControlState.selected)
        addressFiscalPersonSelect!.addTarget(self, action: #selector(InvoiceComplementViewController.checkAddress(_:)), for: UIControlEvents.touchUpInside)
        addressFiscalPersonSelect!.setTitle("Persona Física", for: UIControlState())
        addressFiscalPersonSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        addressFiscalPersonSelect!.setTitleColor(WMColor.gray, for: UIControlState())
        addressFiscalPersonSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        addressFiscalPersonSelect!.isSelected = true
        addressFiscalPersonSelect!.titleLabel?.textAlignment = .left
        self.content.addSubview(self.addressFiscalPersonSelect!)
        
        self.addressFiscalMoralSelect = UIButton(frame: CGRect(x: addressFiscalPersonSelect!.frame.maxX + 31,y: sectionSocialReason.frame.maxY,width: 123,height: fheight))
        addressFiscalMoralSelect!.setImage(checkTermEmpty, for: UIControlState())
        addressFiscalMoralSelect!.setImage(checkTermFull, for: UIControlState.selected)
        addressFiscalMoralSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        addressFiscalMoralSelect!.addTarget(self, action: #selector(InvoiceComplementViewController.checkAddress(_:)), for: UIControlEvents.touchUpInside)
        addressFiscalMoralSelect!.setTitle("Persona Moral", for: UIControlState())
        addressFiscalMoralSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 11.0, 0, 0.0)
        addressFiscalMoralSelect!.setTitleColor(WMColor.gray, for: UIControlState())
        addressFiscalMoralSelect!.titleLabel?.textAlignment = .left
        self.content.addSubview(self.addressFiscalMoralSelect!)
        
        self.sectionAddress = self.buildSectionTitle("Dirección de Facturación", frame: CGRect(x: margin, y: self.addressFiscalPersonSelect!.frame.maxY + 5.0, width: width, height: lheight))
        self.content.addSubview(sectionAddress)
        
        self.address = FormFieldView(frame: CGRect(x: margin, y: self.sectionAddress!.frame.maxY + 5.0, width: width, height: fheight))
        self.address!.isRequired = true
        self.address!.setCustomPlaceholder("Dirección")
        self.address!.typeField = TypeField.list
        self.address!.nameField = "Dirección"
        self.address!.maxLength = 6
        self.address!.setImageTypeField()
        self.content.addSubview(self.address!)
        
        self.returnButton = UIButton(frame: CGRect(x: margin, y: self.address!.frame.maxY + 25.0, width: 140.0, height: fheight))
        self.returnButton!.setTitle("Regresar", for:UIControlState())
        self.returnButton!.titleLabel!.textColor = UIColor.white
        self.returnButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.returnButton!.backgroundColor = WMColor.light_blue
        self.returnButton!.layer.cornerRadius = 20
        self.returnButton!.addTarget(self, action: Selector("back"), for: UIControlEvents.touchUpInside)
        self.view.addSubview(returnButton!)
        
        self.finishButton = UIButton(frame: CGRect(x: widthLessMargin - 140 , y: self.address!.frame.maxY + 25.0, width: 140.0, height: fheight))
        self.finishButton!.setTitle("Finalizar", for:UIControlState())
        self.finishButton!.titleLabel!.textColor = UIColor.white
        self.finishButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.finishButton!.backgroundColor = WMColor.green
        self.finishButton!.layer.cornerRadius = 20
        self.finishButton!.addTarget(self, action: #selector(InvoiceComplementViewController.confirm), for: UIControlEvents.touchUpInside)
        self.view.addSubview(finishButton!)
        
        self.picker = AlertPickerView.initPickerWithDefault()
        self.addViewLoad()
        self.callServiceAddress()
        
        self.address!.onBecomeFirstResponder = { () in
            
            let btnNewAddress = WMRoundButton()
            btnNewAddress.setTitle("nueva", for: UIControlState())
            btnNewAddress.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
            btnNewAddress.setBackgroundColor(WMColor.light_blue, size: CGSize(width: 64.0, height: 22), forUIControlState: UIControlState())
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
            self.picker!.cellType = TypeField.check
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
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.bounds.height - (headerHeight + 120))
        self.sectionIEPS.frame = CGRect(x: margin, y: 16, width: width, height: lheight)
        self.iepsYesSelect!.frame = CGRect(x: margin,y: sectionIEPS.frame.maxY,width: 45,height: fheight)
        self.iepsNoSelect!.frame = CGRect(x: iepsYesSelect!.frame.maxX + 31,y: sectionIEPS.frame.maxY,width: 50,height: fheight)
        let posYsection = buildSectionTourist()
        self.sectionSocialReason.frame = CGRect(x: margin, y: posYsection + 5.0, width: width, height: lheight)
        self.addressFiscalPersonSelect!.frame = CGRect(x: margin,y: sectionSocialReason.frame.maxY,width: 113,height: fheight)
        self.addressFiscalMoralSelect!.frame = CGRect(x: addressFiscalPersonSelect!.frame.maxX + 31,y: sectionSocialReason.frame.maxY,width: 123,height: fheight)
        self.sectionAddress.frame = CGRect(x: margin, y: self.addressFiscalPersonSelect!.frame.maxY + 5.0, width: width, height: lheight)
        self.address!.frame = CGRect(x: margin, y: self.sectionAddress!.frame.maxY + 5.0, width: width, height: fheight)
        self.content.contentSize = CGSize(width: self.view.frame.width, height: address!.frame.maxY + 5.0)
        self.returnButton!.frame = CGRect(x: margin, y: self.content!.frame.maxY - 15, width: 140.0, height: fheight)
        self.finishButton!.frame = CGRect(x: widthLessMargin - 140 , y: self.content!.frame.maxY - 15, width: 140.0, height: fheight)
    }
    
    func buildSectionTourist() -> CGFloat{
        var posY = self.iepsYesSelect!.frame.maxY
        let width = self.view.frame.width - (2*margin)
        self.sectionTouristInfo.isHidden = self.iepsYesSelect!.isSelected
        self.touristYesSelect!.isHidden = self.iepsYesSelect!.isSelected
        self.touristNoSelect!.isHidden = self.iepsYesSelect!.isSelected
        if(self.iepsNoSelect!.isSelected){
            self.sectionTouristInfo.frame = CGRect(x: margin, y: self.iepsYesSelect!.frame.maxY + 5.0, width: width, height: lheight)
            self.touristYesSelect!.frame = CGRect(x: margin,y: sectionTouristInfo.frame.maxY,width: 45,height: fheight)
            self.touristNoSelect!.frame = CGRect(x: touristYesSelect!.frame.maxX + 31,y: sectionTouristInfo.frame.maxY,width: 50,height: fheight)
            posY = self.touristYesSelect!.frame.maxY
        }
        
        return  posY
    }
    
    func buildSectionTitle(_ title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.white
        return sectionTitle
    }
    
    func confirm(){
        self.showConfirmView()
    }
    
    func checkIEPS(_ sender:UIButton) {
        self.checkSelected(sender, yesButton: self.iepsYesSelect!, noButton: self.iepsNoSelect!)
        self.buildView()
    }
    
    func checkTourist(_ sender:UIButton) {
        self.checkSelected(sender, yesButton: self.touristYesSelect!, noButton: self.touristNoSelect!)
        if sender == self.touristYesSelect!{
            showTouristForm()
        }
    }
    
    func checkAddress(_ sender:UIButton) {
        self.checkSelected(sender, yesButton: self.addressFiscalPersonSelect!, noButton: self.addressFiscalMoralSelect!)
    }
    
    func checkSelected(_ sender:UIButton, yesButton: UIButton, noButton:UIButton) {
        if sender.isSelected{
            return
        }
        if sender == yesButton{
            noButton.isSelected = false
        }else{
            yesButton.isSelected = false
        }
        sender.isSelected = !(sender.isSelected)
    }
    
    func showTouristForm(){
        let touristView = TouristInformationForm(frame: CGRect(x: 0, y: 0,  width: 288, height: 465))
        let modalView = AlertModalView.initModalWithView("Tipo de Tránsito",innerView: touristView)
        modalView.showPicker()
    }
    
    func showConfirmView(){
        let confirmView = InvoiceConfirmView(frame: CGRect(x: 0, y: 0,  width: 288, height: 465))
        let modalView = AlertModalView.initModalWithView("Confirmar Datos",innerView: confirmView)
        modalView.showPicker()
    }
    
    func callServiceAddress(){
        let addressService = AddressByUserService()
        addressService.callService({ (resultCall:[String:Any]) -> Void in
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
    
    func getAddressFiscalNames(_ fiscalAddresses:NSArray){
        for address in fiscalAddresses{
            self.arrayAddressFiscalNames?.append(address["name"] as! String)
        }
    }
    
    //MARK: TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
        let val = CGSize(width: self.view.frame.width, height: self.content.contentSize.height)
        return val
    }
    
    //MARK: AlertPickerViewDelegate
    
    func didSelectOption(_ picker:AlertPickerView,indexPath: IndexPath,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj == self.address!{
                self.selectedAddress = self.arrayAddressFiscal![indexPath.row] as? [String:Any]
                self.address?.text = selectedStr
            }
            
        }
    }
    
    func didDeSelectOption(_ picker:AlertPickerView) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj == self.address!{
                //TODO: Que hacer con la direccion
            }
            
        }
    }
    
    
    
    func buttomViewSelected(_ sender: UIButton) {
    }
    
    
    
    func viewReplaceContent(_ frame:CGRect) -> UIView! {
        scrollForm = TPKeyboardAvoidingScrollView(frame: frame)
        self.scrollForm.scrollDelegate = self
        if self.addressFiscalPersonSelect!.isSelected {
            scrollForm.contentSize = CGSize(width: frame.width, height: 490)
            scrollForm.addSubview(self.getFisicalPersonForm(CGRect(x: 0, y: 16, width: 288, height: 465)))
        }else{
            scrollForm.contentSize = CGSize(width: frame.width, height: 470)
            scrollForm.addSubview(self.getMoralPersonForm(CGRect(x: 0, y: 16, width: 288, height: 465)))
        }
        
        /*if !self.selectedAddressHasStore{
            let serviceAddress = GRAddressesByIDService()
            serviceAddress.addressId = self.selectedAddress!
            serviceAddress.callService([:], successBlock: { (result:[String:Any]) -> Void in
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
                service.callService(requestParams: dictSend!, successBlock: { (resultCall:[String:Any]) -> Void  in
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
    func didSelectOptionAtIndex(_ indexPath: IndexPath) {
       //let address = self.arrayAddressFiscal![indexPath.row] as? [String:Any]
    }
    
    func getFisicalPersonForm(_ frame:CGRect) -> FiscalAddressPersonF{
        return FiscalAddressPersonF(frame: frame, isLogin: false, isIpad: false)
    }
    
    func getMoralPersonForm(_ frame:CGRect) -> FiscalAddressPersonM{
        return FiscalAddressPersonM(frame: frame, isLogin: false, isIpad: false)
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad!.backgroundColor = UIColor.white
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

