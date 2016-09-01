//
//  GRCheckOutDeliveryViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
//import Tune

class GRCheckOutDeliveryViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate, AlertPickerViewDelegate {

    let secSep: CGFloat = 30.0
    let titleSep: CGFloat = 15.0
    let fieldSep: CGFloat = 10.0
    let headerHeight: CGFloat = 46
    var content: TPKeyboardAvoidingScrollView!
    var scrollForm : TPKeyboardAvoidingScrollView!
    var viewLoad : WMLoadingView!
    var picker : AlertPickerView!
    var sAddredssForm : FormSuperAddressView!
    var alertView : IPOWMAlertViewController? = nil
    var errorView : FormFieldErrorView? = nil
    var address: FormFieldView?
    var addressInvoice: FormFieldView?
    var addressItems: [AnyObject]?
    var addressDesccription: String? = nil
    var selectedAddress: String? = nil
    var selectedAddressHasStore: Bool = true
    var selectedAddressIx : NSIndexPath!
    var addressInvoiceItems: [AnyObject]?
    var addressInvoiceDesccription: String? = nil
    var selectedAddressInvoice: String? = nil
    var selectedAddressInvoiceIx : NSIndexPath!
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var stepLabel: UILabel!
    var sectionTitle: UILabel!
    var sectionTitleInvoice: UILabel!
    var invoiceButton: UIButton!
    var paramsToOrder : NSMutableDictionary?
    var paramsToConfirm : NSMutableDictionary?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel?.text = "Dirección de envío"
        self.view.backgroundColor = UIColor.whiteColor()
        
        if IS_IPAD {
            self.backButton?.hidden = true
        }
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRectMake(0.0, headerHeight, self.view.bounds.width, self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content)
        
        self.stepLabel = UILabel()
        self.stepLabel.textColor = WMColor.gray
        self.stepLabel.text = "1 de 4"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        let margin: CGFloat = 16.0
        let width =  IS_IPAD ? 301.0 : self.view.frame.width - (2*margin)
        let fheight: CGFloat = 40.0
        let lheight: CGFloat = 15.0
        
        self.sectionTitle = self.buildSectionTitle(NSLocalizedString("checkout.field.address", comment:""), frame: CGRectMake(margin, margin, width, lheight))
        self.content.addSubview(sectionTitle)
        
        self.address = FormFieldView(frame: CGRectMake(margin, sectionTitle.frame.maxY + margin, width, fheight))
        self.address!.setCustomPlaceholder(NSLocalizedString("checkout.field.address", comment:""))
        self.address!.isRequired = true
        self.address!.typeField = TypeField.List
        self.address!.setImageTypeField()
        self.address!.nameField = NSLocalizedString("checkout.field.address", comment:"")
        self.content.addSubview(self.address!)
        
        self.sectionTitleInvoice = self.buildSectionTitle("Facturación", frame: CGRectMake(margin, self.address!.frame.maxY + 28, width, lheight))
        self.content.addSubview(sectionTitleInvoice)
        
        self.invoiceButton = UIButton()
        self.invoiceButton?.setTitle("Requiero factura", forState: UIControlState.Normal)
        self.invoiceButton!.setImage(UIImage(named:"check_empty"), forState: UIControlState.Normal)
        self.invoiceButton!.setImage(UIImage(named:"check_full"), forState: UIControlState.Selected)
        self.invoiceButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.invoiceButton?.addTarget(self, action: #selector(GRCheckOutDeliveryViewController.shoInvoiceAddress(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.invoiceButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.invoiceButton!.setTitleColor(WMColor.dark_gray, forState: UIControlState.Normal)
        self.invoiceButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.content?.addSubview(self.invoiceButton!)

        self.addressInvoice = FormFieldView(frame: CGRectMake(margin, sectionTitleInvoice.frame.maxY + margin, width, fheight))
        self.addressInvoice!.setCustomPlaceholder("Dirección de facturación")
        self.addressInvoice!.isRequired = true
        self.addressInvoice!.typeField = TypeField.List
        self.addressInvoice!.setImageTypeField()
        self.addressInvoice!.nameField = NSLocalizedString("checkout.field.shipmentType", comment:"")
        self.addressInvoice!.enabled = false
        self.addressInvoice!.hidden = true
        self.content.addSubview(self.addressInvoice!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.view!.layer.insertSublayer(layerLine, atIndex: 1000)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: Selector("back"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("profile.create.an.continue", comment:""), forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.light_blue
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(GRCheckOutDeliveryViewController.next), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(saveButton!)
        
        self.selectedAddress = ""
        picker = AlertPickerView.initPickerWithLeftButton()
        picker.setLeftButtonStyle(WMColor.light_blue,titleText: "Nueva Direccion", titleColor:UIColor.whiteColor())
        self.addViewLoad()
        self.reloadUserAddresses()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let margin: CGFloat = 16.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 40.0
        let lheight: CGFloat = 28.0
        
        self.stepLabel!.frame = CGRectMake(self.view.bounds.width - 51.0,8.0, self.titleLabel!.bounds.height, 35)
        self.sectionTitle.frame = CGRectMake(margin, 0, width, lheight)
        self.address!.frame = CGRectMake(margin, sectionTitle.frame.maxY + 8, width, fheight)
        self.sectionTitleInvoice.frame = CGRectMake(margin, self.address!.frame.maxY + 32, width, lheight)
        self.invoiceButton!.frame = CGRectMake(margin, sectionTitleInvoice.frame.maxY, width, fheight)
        self.addressInvoice!.frame = CGRectMake(margin, invoiceButton.frame.maxY + 8, width, fheight)
        
        self.content!.contentSize = CGSize(width: width, height: self.addressInvoice!.frame.maxY)
        self.content!.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, self.view.bounds.height - 110)
        self.layerLine.frame = CGRectMake(0, self.content!.frame.maxY,  self.view.frame.width, 1)
        self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148,self.content!.frame.maxY + 16, 140, 34)
        self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.content!.frame.maxY + 16, 140, 34)
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            let bounds = IS_IPAD ? CGRectMake(0, 0, 341, 768) : self.view.bounds
            viewLoad = WMLoadingView(frame: bounds)
            viewLoad.backgroundColor = UIColor.whiteColor()
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
    
    /**
     Builds UILabel with section title
     
     - parameter title: section title
     - parameter frame: frame
     
     - returns: UILabel
     */
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
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
        
        self.picker!.setValues(self.address!.nameField, values: itemsAddress)
        self.picker!.cellType = TypeField.Check
        if !self.selectedAddressHasStore {
            self.picker!.onClosePicker = {
                //--self.removeViewLoad()
                self.picker!.onClosePicker = nil
                self.navigationController?.popViewControllerAnimated(true)
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
                            self.selectedAddressIx = NSIndexPath(forRow: ixSelected, inSection: 0)
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
                            self.selectedAddressIx = NSIndexPath(forRow: ixSelected, inSection: 0)
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
    func parseDateString(dateStr:String, format:String="dd/MM/yyyy") -> NSDate {
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        return dateFmt.dateFromString(dateStr)!
    }
    
    
    func getAddressDescription(addressId: String){
        let serviceAddress = GRAddressesByIDService()
        serviceAddress.addressId = self.selectedAddress!
        serviceAddress.callService([:], successBlock: { (result:NSDictionary) -> Void in
            self.addressDesccription = "\(result["street"] as! String!) \(result["outerNumber"] as! String!) \n\(result["county"] as! String!) \(result["city"] as! String!)"
            }) { (error:NSError) -> Void in
            self.addressDesccription = ""
            }
        
    }
    /**
     Sent to the following page only if the data is valid
     */
    func next(){
        if !self.validate() {
            return
        }
        
        let nextController = GRCheckOutCommentsViewController()
        
        self.paramsToOrder = ["comments":"", "AddressID":self.selectedAddress!, "pickingInstruction":""]
        self.paramsToConfirm = ["address":self.addressDesccription!.capitalizedString,"pickingInstruction":""]
        nextController.paramsToOrder = self.paramsToOrder
        nextController.paramsToConfirm = self.paramsToConfirm
        self.navigationController?.pushViewController(nextController, animated: true)
    }
 
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        if let scroll = sender as? TPKeyboardAvoidingScrollView {
            if scrollForm != nil {
                if scroll == scrollForm {
                    return CGSizeMake(self.scrollForm.frame.width, self.scrollForm.contentSize.height)
                }
            }
        }
        return CGSizeMake(self.view.frame.width, self.content.contentSize.height)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
    }
    
     //MARK: AlertPickerViewDelegate
    func didSelectOption(picker:AlertPickerView,indexPath: NSIndexPath,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.address! {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_ADDRES_DELIVERY.rawValue , label: "")
                self.address!.text = selectedStr
                var option = self.addressItems![indexPath.row] as! [String:AnyObject]
                if let addressId = option["id"] as? String {
                    print("Asigned AddresID :::\(addressId) ---")
                    self.selectedAddress = addressId
                    self.getAddressDescription(addressId)
                }
                self.selectedAddressIx = indexPath
            }
            if formFieldObj ==  self.addressInvoice! {
                self.addressInvoice!.text = selectedStr
                var option = self.addressInvoiceItems![indexPath.row] as! [String:AnyObject]
                if let addressId = option["id"] as? String {
                    print("Asigned AddresID :::\(addressId) ---")
                    self.selectedAddressInvoice = addressId
                }
                self.selectedAddressInvoiceIx = indexPath
            }
        }
    }
    
    func didDeSelectOption(picker:AlertPickerView) {
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
    
    func buttomViewSelected(sender: UIButton) {
        
    }
    /**
     Returns the view to replace in popup
     
     - parameter frame: view frame
     
     - returns:UIView
     */
    func viewReplaceContent(frame:CGRect) -> UIView! {
        scrollForm = TPKeyboardAvoidingScrollView(frame: frame)
        self.scrollForm.scrollDelegate = self
        scrollForm.contentSize = CGSizeMake(frame.width, 720)
        if sAddredssForm == nil {
            sAddredssForm = FormSuperAddressView(frame: CGRectMake(scrollForm.frame.minX, 0, scrollForm.frame.width, 700))
        }
        sAddredssForm.allAddress = self.addressItems
        sAddredssForm.idAddress = ""
        self.picker!.closeButton!.hidden =  true
        if !self.selectedAddressHasStore{
            self.picker!.closeButton!.hidden =  false
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
        }
        
        scrollForm.addSubview(sAddredssForm)
        self.picker!.titleLabel.text = NSLocalizedString("checkout.field.new.address", comment:"")
        return scrollForm
    }
    /**
     Saves action of new view
     */
    func saveReplaceViewSelected() {
        self.picker!.onClosePicker = nil
        let service = GRAddressAddService()
        let dictSend = sAddredssForm.getAddressDictionary(sAddredssForm.idAddress, delete: false)
        if dictSend != nil {
            
            self.scrollForm.resignFirstResponder()
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            if self.addressItems?.count < 12 {
                service.callService(requestParams: dictSend!, successBlock: { (resultCall:NSDictionary) -> Void  in
                    //--self.addViewLoad()
                    print("Se realizao la direccion")
                    self.picker!.closeNew()
                    self.picker!.closePicker()
                    
                    self.selectedAddress = resultCall["addressID"] as! String!
                    print("saveReplaceViewSelected Address ID \(self.selectedAddress)---")
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
        }
    }

    //MARK: Services
    /**
     Gets the user addresses
     */
    func reloadUserAddresses(){
        self.invokeAddressInvoiceUserService({ () -> Void in
            self.addressInvoice!.onBecomeFirstResponder = {() in
                let itemsAddress : [String] = self.getItemsToSelectInvoiceAddres()
                self.picker!.selected = self.selectedAddressInvoiceIx
                self.picker!.sender = self.addressInvoice!
                self.picker!.delegate = self
                
                self.picker!.setValues(self.addressInvoice!.nameField, values: itemsAddress)
                self.picker!.cellType = TypeField.Check
                if !self.selectedAddressHasStore {
                    self.picker!.onClosePicker = {
                        //--self.removeViewLoad()
                        self.picker!.onClosePicker = nil
                        self.navigationController?.popViewControllerAnimated(true)
                        self.picker!.closePicker()
                    }
                }
                self.removeViewLoad()
                self.picker!.showPicker()
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
        
        self.selectedAddressIx = NSIndexPath(forRow: 0, inSection: 0)
        self.selectedAddressInvoiceIx = NSIndexPath(forRow: 0, inSection: 0)
    }
    /**
     Gets the user addresses service
     */
    func invokeAddressUserService(endCallAddress:(() -> Void)) {
        //TODO: Implementar validacion de direccion.
        
        let service = ShippingAddressByUserService()
        service.callService(
            { (result:NSDictionary) -> Void in
                if let items = result["responseArray"] as? NSArray {
                    self.addressItems = items as [AnyObject]
                    if items.count > 0 {
                        let ixCurrent = 0
                        for dictDir in items {
                            if let preferred = dictDir["preferred"] as? NSNumber {
                                if self.selectedAddress == nil {
                                    if preferred.boolValue == true {
                                        self.selectedAddressIx = NSIndexPath(forRow: ixCurrent, inSection: 0)
                                        if let nameDict = dictDir["name"] as? String {
                                            self.address?.text =  nameDict
                                        }
                                        if let idDir = dictDir["id"] as? String {
                                            print("invokeAddressUserService idAdress \(idDir)")
                                            self.selectedAddress = idDir
                                            
                                        }
                                        if let isAddressOK = dictDir["isAddressOk"] as? String {
                                            self.selectedAddressHasStore = !(isAddressOK == "False")
                                            if !self.selectedAddressHasStore{
                                                self.showAddressPicker()
                                                self.picker!.newItemForm()
                                                self.picker!.viewButtonClose.hidden = true
                                                let delay = 0.7 * Double(NSEC_PER_SEC)
                                                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                                                dispatch_after(time, dispatch_get_main_queue()) {
                                                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"user_error"),imageError:UIImage(named:"user_error"))
                                                    self.alertView!.setMessage(NSLocalizedString("gr.address.field.addressNotOk",comment:""))
                                                    self.alertView!.showDoneIconWithoutClose()
                                                    self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
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
    
    func invokeAddressInvoiceUserService(endCallAddress:(() -> Void)) {
        let addressService = InvoiceAddressByUserService()
        addressService.callService({ (resultCall:NSDictionary) -> Void in
            self.addressInvoiceItems = []
            
            if let fiscalAddress = resultCall["responseArray"] as? [AnyObject] {
                self.addressInvoiceItems = fiscalAddress
            }
            self.removeViewLoad()
            endCallAddress()
            }, errorBlock: { (error:NSError) -> Void in
                self.removeViewLoad()
                endCallAddress()
            })
    }
    
    func shoInvoiceAddress(sender:UIButton){
        self.invoiceButton!.selected = !self.invoiceButton!.selected
        self.addressInvoice!.hidden =  !self.invoiceButton!.selected
        self.addressInvoice!.enabled = self.invoiceButton!.selected
    }
    
    
    func viewError(field: FormFieldView)-> Bool{
        let message = field.validate()
        return self.viewError(field,message: message)
    }
    
    func viewError(field: FormFieldView,message:String?)-> Bool{
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
        return true
    }

    
}
