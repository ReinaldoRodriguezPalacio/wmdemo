//
//  GRCheckOutDeliveryViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class GRCheckOutDeliveryViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate, AlertPickerViewDelegate,AddressViewDelegate {

    let secSep: CGFloat = 30.0
    let titleSep: CGFloat = 15.0
    let fieldSep: CGFloat = 10.0
    var content: TPKeyboardAvoidingScrollView!
    var viewLoad : WMLoadingView!
    var picker : AlertPickerView!
    var sAddredssForm : FormSuperAddressView!
    var alertView : IPOWMAlertViewController? = nil
    var errorView : FormFieldErrorView? = nil
    var address: FormFieldView?
    var addressInvoice: FormFieldView?
    var addressItems: [[String:Any]]?
    var addressDesccription: String? = nil
    var selectedAddress: String? = nil
    var selectedAddressHasStore: Bool = true
    var selectedAddressIx : IndexPath!
    var addressInvoiceItems: [[String:Any]]?
    var addressInvoiceDesccription: String? = nil
    var selectedAddressInvoice: String? = nil
    var selectedAddressInvoiceIx : IndexPath!
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var stepLabel: UILabel!
    var sectionTitle: UILabel!
    var sectionTitleInvoice: UILabel!
    var invoiceButton: UIButton!
    var paramsToOrder : NSMutableDictionary?
    var modalView: AlertModalView?
    //var paramsToConfirm : NSMutableDictionary?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel?.text = NSLocalizedString("checkout.field.address", comment:"")
        self.view.backgroundColor = UIColor.white
        
        if IS_IPAD {
            self.backButton?.isHidden = true
        }
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.white
        self.view.addSubview(self.content)
        
        self.stepLabel = UILabel()
        self.stepLabel.textColor = WMColor.reg_gray
        self.stepLabel.text = "1 de 4"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        let margin: CGFloat = 16.0
        let width =  IS_IPAD ? 301.0 : self.view.frame.width - (2*margin)
        let fheight: CGFloat = 40.0
        let lheight: CGFloat = 15.0
        
        self.sectionTitle = self.buildSectionTitle(NSLocalizedString("checkout.field.address", comment:""), frame: CGRect(x: margin, y: margin, width: width, height: lheight))
        self.content.addSubview(sectionTitle)
        
        self.address = FormFieldView(frame: CGRect(x: margin, y: sectionTitle.frame.maxY + margin, width: width, height: fheight))
        self.address!.setCustomPlaceholder("Dirección de envío")
        self.address!.isRequired = true
        self.address!.typeField = TypeField.list
        self.address!.setImageTypeField()
        self.address!.nameField = "Dirección de Envío"
        self.content.addSubview(self.address!)
        
        self.sectionTitleInvoice = self.buildSectionTitle("Facturación", frame: CGRect(x: margin, y: self.address!.frame.maxY + 28, width: width, height: lheight))
        self.content.addSubview(sectionTitleInvoice)
        
        self.invoiceButton = UIButton()
        self.invoiceButton?.setTitle("Requiero factura", for: UIControlState())
        self.invoiceButton!.setImage(UIImage(named:"filter_check_gray"), for: UIControlState())
        self.invoiceButton!.setImage(UIImage(named:"check_blue"), for: UIControlState.selected)
        self.invoiceButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.invoiceButton?.addTarget(self, action: #selector(GRCheckOutDeliveryViewController.shoInvoiceAddress(_:)), for: UIControlEvents.touchUpInside)
        self.invoiceButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.invoiceButton!.setTitleColor(WMColor.dark_gray, for: UIControlState())
        self.invoiceButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.content?.addSubview(self.invoiceButton!)

        self.addressInvoice = FormFieldView(frame: CGRect(x: margin, y: sectionTitleInvoice.frame.maxY + margin, width: width, height: fheight))
        self.addressInvoice!.setCustomPlaceholder("Dirección de facturación")
        self.addressInvoice!.isRequired = true
        self.addressInvoice!.typeField = TypeField.list
        self.addressInvoice!.setImageTypeField()
        self.addressInvoice!.nameField = NSLocalizedString("Dirección de facturación", comment:"")
        self.addressInvoice!.isEnabled = false
        self.addressInvoice!.isHidden = true
        self.content.addSubview(self.addressInvoice!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.view!.layer.insertSublayer(layerLine, at: 1000)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("profile.create.an.continue", comment:""), for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.light_blue
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(getter: GRCheckOutDeliveryViewController.next), for: UIControlEvents.touchUpInside)
        self.view.addSubview(saveButton!)
        
        self.selectedAddress = ""
        picker = AlertPickerView.initPickerWithLeftButton()
        picker.setLeftButtonStyle(WMColor.light_blue,titleText: "Nueva Dirección", titleColor:UIColor.white)
        self.addViewLoad()
        self.reloadUserAddresses()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let margin: CGFloat = 16.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 40.0
        let lheight: CGFloat = 28.0
        
        self.stepLabel!.frame = CGRect(x: self.view.bounds.width - 51.0,y: 0.0, width: 46, height: self.titleLabel!.bounds.height)
        self.sectionTitle.frame = CGRect(x: margin, y: 0, width: width, height: lheight)
        self.address!.frame = CGRect(x: margin, y: sectionTitle.frame.maxY + 8, width: width, height: fheight)
        self.sectionTitleInvoice.frame = CGRect(x: margin, y: self.address!.frame.maxY + 32, width: width, height: lheight)
        self.invoiceButton!.frame = CGRect(x: margin, y: sectionTitleInvoice.frame.maxY, width: width, height: fheight)
        self.addressInvoice!.frame = CGRect(x: margin, y: invoiceButton.frame.maxY + 8, width: width, height: fheight)
        
        self.content!.contentSize = CGSize(width: width, height: self.addressInvoice!.frame.maxY)
        self.content!.frame = CGRect(x: 0.0, y: 46.0, width: self.view.bounds.width, height: self.view.bounds.height  - (IS_IPAD ? 0 : 110))
        self.layerLine.frame = CGRect(x: 0, y: self.content!.frame.maxY,  width: self.view.frame.width, height: 1)
        self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148,y: self.content!.frame.maxY + 16, width: 140, height: 34)
        self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.content!.frame.maxY + 16, width: 140, height: 34)
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            let bounds = IS_IPAD ? CGRect(x: 0, y: 0, width: 341, height: 768) : self.view.bounds
            viewLoad = WMLoadingView(frame: bounds)
            viewLoad.backgroundColor = UIColor.white
            viewLoad.startAnnimating(true)
            self.view.addSubview(viewLoad)
        }
    }
    
    func removeViewLoad(){
        if self.viewLoad != nil {
            self.viewLoad.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    
    func showNoAddressAlert(){
        let noAddressView = AddressNoStoreView(frame: CGRect(x: 0,y: 0,width: 290,height: 210))
        noAddressView.newAdressForm = { void in
            let finalContentHeight: CGFloat = self.view.frame.height - 80
            let finalContentFrame = CGRect(x: 0, y: 46, width: 289, height: finalContentHeight > 468 ? 468 : finalContentHeight)
            let addInvoiceAddressView = AddInvoiceAddressView(frame: finalContentFrame)
            addInvoiceAddressView.showCancelButton = true
            addInvoiceAddressView.onClose = { Void -> Void in
                self.modalView!.closeNew()
            }
            self.modalView!.resizeViewContent("Nueva Dirección de Facturación",view: addInvoiceAddressView)
        }
        self.modalView = AlertModalView.initModalWithView("Dirección de Facturación", innerView: noAddressView)
        self.modalView!.showPicker()
    }
    
    /**
     Builds UILabel with section title
     
     - parameter title: section title
     - parameter frame: frame
     
     - returns: UILabel
     */
    func buildSectionTitle(_ title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.white
        return sectionTitle
    }
    
    /**
     Shows address picker view
     */
    func showAddressPicker(){
        let itemsAddress : [String] = self.getItemsTOSelectAddres()
        self.picker!.selected = self.selectedAddressIx
        self.picker!.sender = self.address!
        self.picker!.delegate = self
        
        self.picker!.setValues(self.address!.nameField as NSString, values: itemsAddress)
        self.picker!.cellType = TypeField.check
        self.picker!.showDisclosure = true
        self.picker!.showPrefered = true
        if !self.selectedAddressHasStore {
            self.picker!.onClosePicker = {
                //--self.removeViewLoad()
                self.picker!.onClosePicker = nil
                self.navigationController?.popViewController(animated: true)
                self.picker!.closePicker()
            }
        }
        self.picker!.showPicker()
    }
    
    /**
     Gets the address options
     
     - returns: [String]
     */
    func getItemsTOSelectAddres()  -> [String]{
        var itemsAddress : [String] = []
        var ixSelected = 0
        if self.addressItems != nil {
            for option in self.addressItems! {
                if let text = option["name"] as? String {
                    itemsAddress.append(text)
                    if let id = option["addressId"] as? String {
                        if id == self.selectedAddress {
                            self.selectedAddressIx = IndexPath(row: ixSelected, section: 0)
                            self.address!.text = text
                        }
                    }
                }
                ixSelected += 1
            }
        }
        return itemsAddress
    }
    
    /**
     Gets the address options
     
     - returns: [String]
     */
    func getItemsToSelectInvoiceAddres()  -> [String]{
        var itemsAddress : [String] = []
        var ixSelected = 0
        if self.addressInvoiceItems != nil {
            for option in self.addressInvoiceItems! {
                if let text = option["name"] as? String {
                    itemsAddress.append(text)
                    if let id = option["addressId"] as? String {
                        if id == self.selectedAddress {
                            self.selectedAddressIx = IndexPath(row: ixSelected, section: 0)
                            self.address!.text = text
                        }
                    }
                }
                ixSelected += 1
            }
        }
        return itemsAddress
    }
    /**
     Returns the NSDate of string
     
     - parameter dateStr: date in string format
     - parameter format:  string format of date
     
     - returns: NSDAte
     */
    func parseDateString(_ dateStr:String, format:String="dd/MM/yyyy") -> Date {
        let dateFmt = DateFormatter()
        dateFmt.timeZone = TimeZone.current
        dateFmt.dateFormat = format
        return dateFmt.date(from: dateStr)!
    }
    
    
    func getAddressDescription(_ addressId: String){
//        let serviceAddress = GRAddressesByIDService()
//        serviceAddress.addressId = self.selectedAddress!
//        serviceAddress.callService([:], successBlock: { (result:[String:Any]) -> Void in
//            self.addressDesccription = "\(result["street"] as! String!) \(result["outerNumber"] as! String!) \n\(result["county"] as! String!) \(result["city"] as! String!)"
//            }) { (error:NSError) -> Void in
//            self.addressDesccription = ""
//            }
        
    }
    /**
     Sent to the following page only if the data is valid
     */
    func next(){
        if !self.validate() {
            return
        }
        
       /* let nextController = GRCheckOutCommentsViewController()
        
        self.paramsToOrder = ["comments":"", "AddressID":self.selectedAddress!, "pickingInstruction":""]
        self.paramsToConfirm = ["address":self.addressDesccription!.capitalizedString,"pickingInstruction":""]
        nextController.paramsToOrder = self.paramsToOrder
        nextController.paramsToConfirm = self.paramsToConfirm
        self.navigationController?.pushViewController(nextController, animated: true)*/
       
        let nextController = CheckOutProductShipping()
        nextController.paramsToOrder =  self.paramsToOrder
        self.navigationController?.pushViewController(nextController, animated: true)
        
    }
 
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    func contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.content.contentSize.height)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
    }
    
     //MARK: AlertPickerViewDelegate
    func didSelectOption(_ picker:AlertPickerView,indexPath: IndexPath,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.address! {
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_ADDRES_DELIVERY.rawValue , label: "")
                self.address!.text = selectedStr
                var option = self.addressItems![(indexPath as NSIndexPath).row] as! [String:Any]
                if let addressId = option["addressId"] as? String {
                    print("Asigned AddresID :::\(addressId) ---")
                    self.selectedAddress = addressId
                    self.getAddressDescription(addressId)
                }
                if self.paramsToOrder == nil {
                    self.paramsToOrder = [:]
                }
                self.paramsToOrder = ["addressShopping":["addressId":option["addressId"] as! String, "phoneNumberAddres":option["phoneNumber"] as? String ?? "", "nameAddres":option["name"] as! String,"storeId":option["storeId"] as! String]]
                self.address!.layer.borderColor = WMColor.light_light_gray.cgColor
                self.selectedAddressIx = indexPath
                self.errorView?.removeFromSuperview()
                self.errorView = nil
            }
            if formFieldObj ==  self.addressInvoice! {
                self.addressInvoice!.text = selectedStr
                var option = self.addressInvoiceItems![(indexPath as NSIndexPath).row] as! [String:Any]
                if let addressId = option["id"] as? String {
                    print("Asigned AddresID :::\(addressId) ---")
                    self.selectedAddressInvoice = addressId
                }
                self.paramsToOrder?.addEntries(from: ["addressInvoice":["phoneNumberAddres":option["phoneNumber"] as! String, "nameAddres":option["name"] as! String,"storeId":option["storeId"] as! String]])
                self.selectedAddressInvoiceIx = indexPath
                self.addressInvoice!.layer.borderColor = WMColor.light_light_gray.cgColor
                self.errorView?.removeFromSuperview()
                self.errorView = nil
            }
        }
    }
    
    func didDeSelectOption(_ picker:AlertPickerView) {
        //self.removeViewLoad()
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.address! {
                self.address!.text = ""
                self.selectedAddress = ""
            }
            if formFieldObj ==  self.addressInvoice! {
                self.addressInvoice!.text = ""
                self.selectedAddressInvoice = ""
            }
        }
    }
    
    func buttomViewSelected(_ sender: UIButton) {
        
    }
    /**
     Returns the view to replace in popup
     
     - parameter frame: view frame
     
     - returns:UIView
     */
    func viewReplaceContent(_ frame:CGRect) -> UIView! {
        let sender = self.picker.sender as? FormFieldView
        let typeAddress: TypeAddress = TypeAddress.shiping
        if sender == self.address {
            let addAddressView = ShippingAddress(frame: frame, isLogin: false, isIpad: IS_IPAD, typeAddress: typeAddress)
            addAddressView.delegate =  self
            //addAddressView.showCancelButton = true
            self.picker!.closeButton!.isHidden =  true
            if !self.selectedAddressHasStore{
                self.picker!.closeButton!.isHidden =  false
                let serviceAddress = GRAddressesByIDService()
                serviceAddress.addressId = self.selectedAddress!
                serviceAddress.callService([:], successBlock: { (result:[String:Any]) -> Void in
//                    addAddressView.sAddredssForm!.addressName.text = result["name"] as! String!
//                    addAddressView.sAddredssForm!.outdoornumber.text = result["outerNumber"] as! String!
//                    addAddressView.sAddredssForm!.indoornumber.text = result["innerNumber"] as! String!
//                    addAddressView.sAddredssForm!.betweenFisrt.text = result["reference1"] as! String!
//                    addAddressView.sAddredssForm!.betweenSecond.text = result["reference2"] as! String!
//                    addAddressView.sAddredssForm!.zipcode.text = result["zipCode"] as! String!
//                    addAddressView.sAddredssForm!.street.text = result["street"] as! String!
//                    let neighborhoodID = result["neighborhoodID"] as! String!
//                    let storeID = result["storeID"] as! String!
//                    addAddressView.sAddredssForm!.setZipCodeAnfFillFields(self.sAddredssForm.zipcode.text!, neighborhoodID: neighborhoodID!, storeID: storeID!)
//                    addAddressView.sAddredssForm!.idAddress = result["addressID"] as! String!
                    }) { (error:NSError) -> Void in
                }
            }
//            addAddressView.onClose = { Void -> Void in
//                self.picker!.closeNew()
//            }
            self.picker!.titleLabel.text = "Nueva Dirección"
            return addAddressView
        }
        
        let addInvoiceAddressView = AddInvoiceAddressView(frame: frame)
        addInvoiceAddressView.showCancelButton = true
        self.picker!.closeButton!.isHidden =  true
        addInvoiceAddressView.onClose = { Void -> Void in
            self.picker!.closeNew()
        }
        self.picker!.titleLabel.text = "Nueva Dirección de Facturación"
        return addInvoiceAddressView
    }
    
    //MARK: Services
    /**
     Gets the user addresses
     */
    func reloadUserAddresses(){
        self.invokeAddressInvoiceUserService({ () -> Void in
            self.addressInvoice!.onBecomeFirstResponder = {() in
                let itemsAddress : [String] = self.getItemsToSelectInvoiceAddres()
                if itemsAddress.count != 0 {
                    self.picker!.selected = self.selectedAddressInvoiceIx
                    self.picker!.sender = self.addressInvoice!
                    self.picker!.delegate = self
                    self.picker!.setValues(self.addressInvoice!.nameField as NSString, values: itemsAddress)
                    self.picker!.cellType = TypeField.check
                    self.picker!.showDisclosure = true
                    self.picker!.showPrefered = true
                    if !self.selectedAddressHasStore {
                        self.picker!.onClosePicker = {
                            //--self.removeViewLoad()
                            self.picker!.onClosePicker = nil
                            self.navigationController?.popViewController(animated: true)
                            self.picker!.closePicker()
                        }
                    }
                    self.removeViewLoad()
                    self.picker!.showPicker()
                }else{
                    self.showNoAddressAlert()
                }
            }
        })
        self.invokeAddressUserService({ () -> Void in
            self.getItemsTOSelectAddres()
            //Mustang
            self.getAddressDescription(self.selectedAddress!)
            self.address!.onBecomeFirstResponder = {() in
                self.showAddressPicker()
            }
        })
        
        self.selectedAddressIx = IndexPath(row: 0, section: 0)
        self.selectedAddressInvoiceIx = IndexPath(row: 0, section: 0)
    }
    /**
     Gets the user addresses service
     */
    func invokeAddressUserService(_ endCallAddress:@escaping (() -> Void)) {
        //TODO: Implementar validacion de direccion.
        
        let service = ShippingAddressByUserService()
        service.callService(
            { (result:[String:Any]) -> Void in
                if let items = result["responseArray"] as? [[String:Any]] {
                    self.addressItems = items
                    if items.count > 0 {
                        let ixCurrent = 0
                        for dictDir in items {
                            if self.selectedAddress == nil || self.selectedAddress == "" {
                                self.selectedAddressIx = IndexPath(row: ixCurrent, section: 0)
                                if let nameDict = dictDir["name"] as? String {
                                    self.address?.text =  nameDict
                                }
                                if let idDir = dictDir["addressId"] as? String {
                                    print("invokeAddressUserService idAdress \(idDir)")
                                    self.selectedAddress = idDir
                                }
                                if let isAddressOK = dictDir["isAddressOk"] as? String {
                                    self.selectedAddressHasStore = !(isAddressOK == "False")
                                    if !self.selectedAddressHasStore{
                                        self.showAddressPicker()
                                        self.picker!.newItemForm()
                                        self.picker!.viewButtonClose.isHidden = true
                                        let delay = 0.7 * Double(NSEC_PER_SEC)
                                        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                                        DispatchQueue.main.asyncAfter(deadline: time) {
                                            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"user_error"),imageError:UIImage(named:"user_error"))
                                            self.alertView!.setMessage(NSLocalizedString("gr.address.field.addressNotOk",comment:""))
                                            self.alertView!.showDoneIconWithoutClose()
                                            self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
                                        }
                                    }
                                }
                            }
                            break
                        }
                    }
                }
                self.removeViewLoad()
                endCallAddress()
            }, errorBlock: { (error:NSError) -> Void in
                
                self.removeViewLoad()
                print("Error at invoke address user service")
                endCallAddress()
            }
        )
    }
    
    func invokeAddressInvoiceUserService(_ endCallAddress:@escaping (() -> Void)) {
        let addressService = InvoiceAddressByUserService()
        addressService.callService({ (resultCall:[String:Any]) -> Void in
            self.addressInvoiceItems = []
            
            if let fiscalAddress = resultCall["responseArray"] as? [[String:Any]] {
                self.addressInvoiceItems = fiscalAddress
            }
            self.removeViewLoad()
            endCallAddress()
            }, errorBlock: { (error:NSError) -> Void in
                self.removeViewLoad()
                endCallAddress()
            })
    }
    
    func shoInvoiceAddress(_ sender:UIButton){
        self.invoiceButton!.isSelected = !self.invoiceButton!.isSelected
        self.addressInvoice!.isHidden =  !self.invoiceButton!.isSelected
        self.addressInvoice!.isEnabled = self.invoiceButton!.isSelected
        
        self.addressInvoice!.layer.borderColor = UIColor.clear.cgColor
        self.errorView?.removeFromSuperview()
        self.errorView = nil

    }
    
    
    func viewError(_ field: FormFieldView)-> Bool{
        let message = field.validate()
        return self.viewError(field,message: message)
    }
    
    func viewError(_ field: FormFieldView,message:String?)-> Bool{
        if message != nil {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field, nameField:field.nameField, message: message! ,errorView:self.errorView!,  becomeFirstResponder: false)
            return false
        }
        return true
    }
    
    /**
     Validates shipment items and slot items
     
     - returns: true if the data is valid
     */
    func validate() -> Bool{
        if !self.selectedAddressHasStore  {
            return self.viewError(self.address!,message: NSLocalizedString("gr.address.field.addressNotOk",comment:""))
        }
        
        if self.address!.text == "" || self.selectedAddress! == "" {
            return self.viewError(self.address!,message: "Selecciona una dirección de envío")
        }
        
        if self.invoiceButton.isSelected && (self.addressInvoice!.text == "") {
            return self.viewError(self.addressInvoice!,message: "Selecciona una dirección de facturación")
        }
        return true
    }
    
    // MARK: AddressViewDelegate
    
    func textModify(_ sender: UITextField!) {
        print("My text")
    }
    func setContentSize() {
        print("setContentSize")
    }

    
}
