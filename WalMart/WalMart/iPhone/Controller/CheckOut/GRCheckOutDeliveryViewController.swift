//
//  GRCheckOutDeliveryViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
import Tune

class GRCheckOutDeliveryViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate, AlertPickerViewDelegate,UITableViewDataSource, UITableViewDelegate {

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
    var shipmentType: FormFieldView?
    var deliveryDate: FormFieldView?
    var timeSlotsTable: UITableView?
    var addressItems: [AnyObject]?
    var shipmentItems: [AnyObject]?
    var slotsItems: [AnyObject]? = []
    var datesItems: [AnyObject]?
    var datesToShow: [String]?
    var dateFmt: NSDateFormatter?
    var addressDesccription: String? = nil
    var selectedAddress: String? = nil
    var selectedAddressHasStore: Bool = true
    var selectedDate : NSDate!
    var selectedAddressIx : NSIndexPath!
    var selectedShipmentTypeIx : NSIndexPath!
    var selectedTimeSlotTypeIx : NSIndexPath!
    var selectedDateTypeIx : NSIndexPath!
    var shipmentAmount: Double!
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var stepLabel: UILabel!
    var sectionTitle: UILabel!
    var sectionTitleShipment: UILabel!
    var sectionTitleDate: UILabel!
    var toolTipLabel: UILabel!
    var imageView : UIView?
    var viewContents : UIView?
    var lblInfo : UILabel?
    var imageIco : UIImageView?
    var paramsToOrder : NSMutableDictionary?
    var paramsToConfirm : NSMutableDictionary?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel?.text = "Detalles de Entrega"
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
        self.stepLabel.text = "1 de 3"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        self.dateFmt = NSDateFormatter()
        self.dateFmt!.dateFormat =  "EEEE dd, MMMM"
        
        let margin: CGFloat = 16.0
        let width = self.view.frame.width - (2*margin)
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
        
        self.sectionTitleShipment = self.buildSectionTitle(NSLocalizedString("checkout.field.shipmentType", comment:""), frame: CGRectMake(margin, self.address!.frame.maxY + 28, width, lheight))
        self.content.addSubview(sectionTitleShipment)

        self.shipmentType = FormFieldView(frame: CGRectMake(margin, sectionTitleShipment.frame.maxY + margin, width, fheight))
        self.shipmentType!.setCustomPlaceholder(NSLocalizedString("checkout.field.shipmentType", comment:""))
        self.shipmentType!.isRequired = true
        self.shipmentType!.typeField = TypeField.List
        self.shipmentType!.setImageTypeField()
        self.shipmentType!.nameField = NSLocalizedString("checkout.field.shipmentType", comment:"")
        self.content.addSubview(self.shipmentType!)

        self.sectionTitleDate = self.buildSectionTitle(NSLocalizedString("checkout.title.date", comment:""), frame: CGRectMake(margin, self.shipmentType!.frame.maxY + 28, width, lheight))
        self.content!.addSubview(sectionTitleDate)
        
        self.deliveryDate = FormFieldView(frame: CGRectMake(margin, self.sectionTitleDate!.frame.maxY + 5.0, width, fheight))
        self.deliveryDate!.setCustomPlaceholder(NSLocalizedString("checkout.field.deliveryDate", comment:""))
        self.deliveryDate!.isRequired = true
        self.deliveryDate!.typeField = TypeField.List
        self.deliveryDate!.setImageTypeField()
        self.deliveryDate!.nameField = NSLocalizedString("checkout.field.deliveryDate", comment:"")
        self.deliveryDate!.disablePaste = true
        self.content.addSubview(self.deliveryDate!)
        
        self.timeSlotsTable = UITableView()
        self.timeSlotsTable!.delegate = self
        self.timeSlotsTable!.dataSource = self
        self.timeSlotsTable!.backgroundColor = UIColor.whiteColor()
        self.timeSlotsTable!.separatorStyle = .None
        self.timeSlotsTable!.registerClass(SelectItemTableViewCell.self, forCellReuseIdentifier: "cellSelItem")
        self.timeSlotsTable!.scrollEnabled = false
        self.content.addSubview(self.timeSlotsTable!)
        
        self.toolTipLabel = UILabel()
        self.toolTipLabel!.text = NSLocalizedString("checkout.title.tooltip", comment:"")
        self.toolTipLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.toolTipLabel!.textColor = WMColor.empty_gray
        self.toolTipLabel!.textAlignment = .Right
        self.toolTipLabel!.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "showTooltip")
        self.toolTipLabel!.addGestureRecognizer(tapGesture)
        self.content.addSubview(self.toolTipLabel!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.view!.layer.insertSublayer(layerLine, atIndex: 1000)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("profile.create.an.continue", comment:""), forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.light_blue
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: "next", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(saveButton!)
        
        self.imageView =  UIView()
        self.viewContents = UIView()
        self.viewContents!.layer.cornerRadius = 5.0
        self.viewContents!.backgroundColor = WMColor.light_blue
        
        self.lblInfo = UILabel()
        self.lblInfo!.font = WMFont.fontMyriadProRegularOfSize(12)
        
        self.lblInfo!.textColor = UIColor.whiteColor()
        self.lblInfo!.backgroundColor = UIColor.clearColor()
        self.lblInfo!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.lblInfo!.textAlignment = NSTextAlignment.Left
        self.lblInfo!.numberOfLines = 10
    
        self.imageIco = UIImageView(image:UIImage(named:"tooltip_cart"))
        
        self.picker = AlertPickerView.initPickerWithDefault()
        self.addViewLoad()
        self.reloadUserAddresses()
        
        self.deliveryDate!.onBecomeFirstResponder = {() in
            self.picker!.selected = self.selectedDateTypeIx
            self.picker!.sender = self.deliveryDate!
            self.picker!.delegate = self
            self.picker!.setValues(NSLocalizedString("checkout.title.deliverySchedule", comment:""), values: self.datesToShow!)
            self.picker!.hiddenRigthActionButton(true)
            self.picker!.cellType = TypeField.Check
            self.picker!.showPicker()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let margin: CGFloat = 16.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 40.0
        let lheight: CGFloat = 15.0
        let tableHeight: CGFloat = self.slotsItems!.count > 0 ? CGFloat(self.slotsItems!.count) * 46 : (46 * 2)
        
        self.stepLabel!.frame = CGRectMake(self.view.bounds.width - 51.0,8.0, self.titleLabel!.bounds.height, 35)
        self.sectionTitle.frame = CGRectMake(margin, margin, width, lheight)
        self.address!.frame = CGRectMake(margin, sectionTitle.frame.maxY + margin, width, fheight)
        self.sectionTitleShipment.frame = CGRectMake(margin, self.address!.frame.maxY + 28, width, lheight)
        self.shipmentType!.frame = CGRectMake(margin, sectionTitleShipment.frame.maxY + margin, width, fheight)
        self.sectionTitleDate.frame = CGRectMake(margin, self.shipmentType!.frame.maxY + 28, width, lheight)
        self.deliveryDate!.frame = CGRectMake(margin, self.sectionTitleDate!.frame.maxY + margin, width, fheight)
        self.timeSlotsTable!.frame = CGRectMake(margin, self.deliveryDate!.frame.maxY, width, tableHeight)
        self.toolTipLabel!.frame =  CGRectMake(margin,self.timeSlotsTable!.frame.maxY,width,34)
        self.content!.contentSize = CGSize(width: width, height: self.toolTipLabel!.frame.maxY)
        self.content!.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, self.view.bounds.height - 111)
        self.layerLine.frame = CGRectMake(0, self.content!.frame.maxY,  self.view.frame.width, 1)
        self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148,self.content!.frame.maxY + 16, 140, 34)
        self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.content!.frame.maxY + 16, 140, 34)
        self.lblInfo!.frame = CGRectMake (8 , 8, self.toolTipLabel.frame.width - 16, 108)
        self.imageView!.frame = CGRectMake(16 , self.toolTipLabel.frame.minY - 124, self.toolTipLabel.frame.width, 124)
        self.viewContents!.frame = imageView!.bounds
        self.imageIco!.frame = CGRectMake(self.toolTipLabel.frame.width - 24 , viewContents!.frame.maxY - 1, 8, 6)
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            let bounds = IS_IPAD ? CGRectMake(0, 0, 341, 705) : self.view.bounds
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
    
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
    
    func showAddressPicker(){
        let itemsAddress : [String] = self.getItemsTOSelectAddres()
        self.picker!.selected = self.selectedAddressIx
        self.picker!.sender = self.address!
        self.picker!.delegate = self
        
        let btnNewAddress = WMRoundButton()
        btnNewAddress.setTitle("nueva", forState: UIControlState.Normal)
        btnNewAddress.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        btnNewAddress.setBackgroundColor(WMColor.light_blue, size: CGSizeMake(64.0, 22), forUIControlState: UIControlState.Normal)
        btnNewAddress.layer.cornerRadius = 2.0
        
        self.picker!.addRigthActionButton(btnNewAddress)
        self.picker!.setValues(self.address!.nameField, values: itemsAddress)
        self.picker!.hiddenRigthActionButton(false)
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
    
    func getItemsTOSelectAddres()  -> [String]{
        var itemsAddress : [String] = []
        var ixSelected = 0
        if self.addressItems != nil {
            for option in self.addressItems! {
                if let text = option["name"] as? String {
                    itemsAddress.append(text)
                    if let id = option["id"] as? String {
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
    
    func parseDateString(dateStr:String, format:String="dd/MM/yyyy") -> NSDate {
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        return dateFmt.dateFromString(dateStr)!
    }
    
    func getAviableDates(){
        self.datesItems = []
        self.datesToShow = []
        self.selectedDateTypeIx = NSIndexPath(forItem: 0, inSection: 0)
        for index in 0...5{
            let date = NSDate()
            let newDate = date.dateByAddingTimeInterval(60 * 60 * 24 * Double(index))
            let dateFmt = NSDateFormatter()
            dateFmt.timeZone = NSTimeZone.defaultTimeZone()
            dateFmt.dateFormat = "EEEE dd, MMMM"
            var stringDate = dateFmt.stringFromDate(newDate).capitalizedString
            if index == 0{
                stringDate = "Hoy \(stringDate)"
            }else if index == 1{
                stringDate = "Mañana \(stringDate)"
            }
            
            let dateItem = ["dateString":stringDate,"date":newDate]
            self.datesItems!.append(dateItem)
            self.datesToShow!.append(stringDate)
        }
    }
    
    func returnAviableDate(date:NSDate) -> [String: AnyObject]{
        var aviableDate = self.datesItems!.last!
        var row = 0
        for item in self.datesItems! {
            let itemDate = item["date"] as! NSDate
            if #available(iOS 8.0, *) {
                if NSCalendar.currentCalendar().compareDate(itemDate, toDate: date,
                    toUnitGranularity: .Day) == NSComparisonResult.OrderedSame {
                    aviableDate = item
                    break
                }
            } else {
                let dateFmt = NSDateFormatter()
                dateFmt.timeZone = NSTimeZone.defaultTimeZone()
                dateFmt.dateFormat = "EEEE dd, MMMM"
                aviableDate =  ["dateString":dateFmt.stringFromDate(date).capitalizedString,"date":date]
                break
            }
            row += 1
        }
        self.selectedDateTypeIx = NSIndexPath(forRow: row, inSection: 0)
        return aviableDate as! [String : AnyObject]
    }
    
    func getHourToShow(hour:String) -> String{
        var cellText = hour
        let firstRange = cellText.rangeOfString("(")
        cellText = cellText.substringFromIndex(firstRange!.startIndex.advancedBy(1))
        cellText = cellText.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        cellText = cellText.stringByReplacingOccurrencesOfString("-", withString: "y", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return "Entre \(cellText)"
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
    
    func next(){
        if !self.validate() {
            return
        }
        let nextController = GRCheckOutCommentsViewController()
        let components : NSDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.NSYearCalendarUnit, NSCalendarUnit.NSMonthCalendarUnit, NSCalendarUnit.NSDayCalendarUnit], fromDate: self.selectedDate)
        let dateMonth = components.month
        let dateYear = components.year
        let dateDay = components.day
        let slotSel = self.slotsItems![selectedTimeSlotTypeIx.row]  as! NSDictionary
        let slotSelectedId = slotSel["id"] as! Int
        let slotHour = slotSel["displayText"] as! String
        let shipmentTypeSel = self.shipmentItems![selectedShipmentTypeIx.row] as! NSDictionary
        let shipmentType = shipmentTypeSel["key"] as! String
        self.shipmentAmount = shipmentTypeSel["cost"] as! Double
        self.paramsToOrder = ["month":dateMonth, "year":dateYear, "day":dateDay, "comments":"", "AddressID":self.selectedAddress!,  "slotId":slotSelectedId, "deliveryType":shipmentType, "hour":slotHour, "pickingInstruction":"", "deliveryTypeString":self.shipmentType!.text!,"shipmentAmount":self.shipmentAmount]
        self.paramsToConfirm = ["address":self.addressDesccription!.capitalizedString,"date":self.deliveryDate!.text!,"hour":self.getHourToShow(slotHour),"shipmentAmount":"\(self.shipmentAmount)","pickingInstruction":""]
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
        self.animationClose()
    }
     //MARK: AlertPickerViewDelegate
    func didSelectOption(picker:AlertPickerView,indexPath: NSIndexPath,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.address! {
                self.addViewLoad()
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_ADDRES_DELIVERY.rawValue , label: "")
                self.address!.text = selectedStr
                var option = self.addressItems![indexPath.row] as! [String:AnyObject]
                if let addressId = option["id"] as? String {
                    print("Asigned AddresID :::\(addressId) ---")
                    self.selectedAddress = addressId
                    self.getAddressDescription(addressId)
                }
                self.selectedAddressIx = indexPath
                self.buildAndConfigureDeliveryType()
 
            }
            if formFieldObj ==  self.shipmentType! {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_OK.rawValue , label: "")
                self.shipmentType!.text = selectedStr
                self.selectedShipmentTypeIx = indexPath
                let shipment: AnyObject = self.shipmentItems![indexPath.row]
                self.shipmentAmount = shipment["cost"] as! Double
            }
            if formFieldObj ==  self.deliveryDate! {
                self.addViewLoad()
                self.selectedDateTypeIx = indexPath
                let selectedItem = self.datesItems![indexPath.row] as! [String:AnyObject]
                self.selectedDate = selectedItem["date"] as! NSDate
                self.buildSlotsPicker(self.selectedDate)
            }
        }
    }
    
    func didDeSelectOption(picker:AlertPickerView) {
        //self.removeViewLoad()
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.address! {
                self.address!.text = ""
                self.selectedAddress = ""
                buildAndConfigureDeliveryType()
            }
            if formFieldObj ==  self.shipmentType! {
                self.shipmentType!.text = ""
            }
            if formFieldObj ==  self.deliveryDate! {
                self.deliveryDate!.text = ""
            }
        }
    }
    
    func buttomViewSelected(sender: UIButton) {
        
    }
    
    func viewReplaceContent(frame:CGRect) -> UIView! {
        scrollForm = TPKeyboardAvoidingScrollView(frame: frame)
        self.scrollForm.scrollDelegate = self
        scrollForm.contentSize = CGSizeMake(frame.width, 720)
        sAddredssForm = FormSuperAddressView(frame: CGRectMake(scrollForm.frame.minX, 0, scrollForm.frame.width, 700))
        sAddredssForm.allAddress = self.addressItems
        sAddredssForm.idAddress = ""
        if !self.selectedAddressHasStore{
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
        self.picker!.closeButton.hidden =  false
        return scrollForm
        
        
    }
    
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
    
    func reloadUserAddresses(){
        self.invokeAddressUserService({ () -> Void in
            self.getItemsTOSelectAddres()
            self.getAddressDescription(self.selectedAddress!)
            self.address!.onBecomeFirstResponder = {() in
                self.showAddressPicker()
            }
            //TODO
            self.getAviableDates()
            self.selectedDate = self.datesItems!.first!["date"] as! NSDate
            self.deliveryDate!.text = self.datesToShow!.first!
            self.buildAndConfigureDeliveryType()
        })
    }
    
    func invokeAddressUserService(endCallAddress:(() -> Void)) {
        //--self.addViewLoad()
        let service = GRAddressByUserService()
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
                //--self.removeViewLoad()
                endCallAddress()
            }, errorBlock: { (error:NSError) -> Void in
                
                self.removeViewLoad()
                print("Error at invoke address user service")
                endCallAddress()
            }
        )
    }
    
    func buildAndConfigureDeliveryType() {
        if self.selectedAddress != nil {
            self.invokeDeliveryTypesService({ () -> Void in
                self.shipmentType!.onBecomeFirstResponder = {() in
                    BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_ADDRES_DELIVERY.rawValue , label: "")
                    var itemsShipment : [String] = []
                    if self.shipmentItems?.count > 1{
                        for option in self.shipmentItems! {
                            if let text = option["name"] as? String {
                                itemsShipment.append(text)
                            }
                        }
                        self.picker!.selected = self.selectedShipmentTypeIx
                        self.picker!.sender = self.shipmentType!
                        self.picker!.delegate = self
                        self.picker!.setValues(self.shipmentType!.nameField, values: itemsShipment)
                        self.picker!.hiddenRigthActionButton(true)
                        self.picker!.cellType = TypeField.Check
                        self.picker!.showPicker()
                    }
                }
                
                self.buildSlotsPicker(self.selectedDate)
            })
        }
    }
    
    func invokeDeliveryTypesService(endCallTypeService:(() -> Void)) {
        //--self.addViewLoad()
        let service = GRDeliveryTypeService()
        //Validar self.selectedAddress != nil
        if self.selectedAddress != nil {
            service.setParams("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())", addressId: self.selectedAddress!,isFreeShiping:"false")
            service.callService(requestParams: [:],
                successBlock: { (result:NSDictionary) -> Void in
                    self.shipmentItems = []
                    if let fixedDelivery = result["fixedDelivery"] as? String {
                        //self.shipmentType!.text = fixedDelivery
                        var fixedDeliveryCostVal = 0.0
                        if let fixedDeliveryCost = result["fixedDeliveryCost"] as? NSString {
                            fixedDeliveryCostVal = fixedDeliveryCost.doubleValue
                        }
                        self.shipmentItems!.append(["name":fixedDelivery, "key":"3","cost":fixedDeliveryCostVal])
                    }
                    
                    if let pickUpInStore = result["pickUpInStore"] as? String {
                        var pickUpInStoreCostVal = 0.0
                        if let pickUpInStoreCost = result["pickUpInStoreCost"] as? NSString {
                            pickUpInStoreCostVal = pickUpInStoreCost.doubleValue
                        }
                        self.shipmentItems!.append(["name":pickUpInStore, "key":"4","cost":pickUpInStoreCostVal])
                    }
                    if let normalDelivery = result["normalDelivery"] as? String {
                        var normalDeliveryCostVal = 0.0
                        if let normalDeliveryCost = result["normalDeliveryCost"] as? NSString {
                            normalDeliveryCostVal = normalDeliveryCost.doubleValue
                        }
                        self.shipmentItems!.append(["name":normalDelivery, "key":"1","cost":normalDeliveryCostVal])
                    }
                    if let expressDelivery = result["expressDelivery"] as? String {
                        var expressDeliveryCostVal = 0.0
                        if let expressDeliveryCost = result["expressDeliveryCost"] as? NSString {
                            expressDeliveryCostVal = expressDeliveryCost.doubleValue
                        }
                        self.shipmentItems!.append(["name":expressDelivery, "key":"2","cost":expressDeliveryCostVal])
                    }
                    if self.shipmentItems!.count > 0 {
                        let shipName = self.shipmentItems![0] as! NSDictionary
                        self.selectedShipmentTypeIx = NSIndexPath(forRow: 0, inSection: 0)
                        self.shipmentType!.text = shipName["name"] as? String
                    }
                    //--self.removeViewLoad()//ok
                    endCallTypeService()
                },
                errorBlock: { (error:NSError) -> Void in
                    self.removeViewLoad()
                    print("Error at invoke delivery type service")
                    endCallTypeService()
                }
            )
        }
    }
    
    func buildSlotsPicker(date:NSDate?) {
        //self.addViewLoad()
        var strDate = ""
        if date != nil {
            let formatService  = NSDateFormatter()
            formatService.dateFormat = "dd/MM/yyyy"
            strDate = formatService.stringFromDate(date!)
        }
        self.invokeTimeBandsService(strDate, endCallTypeService: { () -> Void in
            if  self.slotsItems?.count > 0 {
                if self.errorView != nil {
                    self.errorView!.removeFromSuperview()
                    self.errorView!.focusError = nil
                    self.errorView = nil
                    self.deliveryDate?.layer.borderColor =   UIColor.whiteColor().CGColor
                }
                self.selectedTimeSlotTypeIx = NSIndexPath(forRow: 0, inSection: 0)
            }
            self.timeSlotsTable!.reloadData()
            self.removeViewLoad()//ok
        })
    }
    
    func invokeTimeBandsService(date:String,endCallTypeService:(() -> Void)) {
        let service = GRTimeBands()
        let params = service.buildParams(date, addressId: self.selectedAddress!)
        service.callService(requestParams: params, successBlock: { (result:NSDictionary) -> Void in
            if let day = result["day"] as? String {
            if let month = result["month"] as? String {
                if let year = result["year"] as? String {
                    let dateSlot = "\(day)/\(month)/\(year)"
                    let aviableDate = self.returnAviableDate(self.parseDateString(dateSlot))
                    self.deliveryDate!.text = aviableDate["dateString"] as? String
                    self.selectedDate = aviableDate["date"] as! NSDate
                }
            }
        }
        self.slotsItems = result["slots"] as! NSArray as [AnyObject]
        //--self.addViewLoad()
        endCallTypeService()
        }) { (error:NSError) -> Void in
            self.removeViewLoad()
            self.slotsItems = []
            endCallTypeService()
        }
    }
    
    func showTooltip(){
        self.viewContents!.alpha = 1.0
        self.imageIco!.alpha = 1.0
        self.lblInfo!.alpha = 1.0
        self.viewContents!.alpha = 1.0
        self.imageView!.addSubview(viewContents!)
        self.content.addSubview(imageView!)
        self.viewContents!.addSubview(lblInfo!)
        self.viewContents!.addSubview(imageIco!)
        let message = NSLocalizedString("checkout.tooltip.text", comment:"")
        self.lblInfo!.text = message
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "animationClose", userInfo: nil, repeats: false)
    }
    
    func animationClose () {
        UIView.animateWithDuration(0.9,
            animations: { () -> Void in
                self.viewContents!.alpha = 0.0
                self.imageIco!.alpha = 0.0
                self.lblInfo!.alpha = 0.0
                self.viewContents!.alpha = 0.0
            }, completion: { (finished:Bool) -> Void in
                if finished {
                    self.viewContents!.removeFromSuperview()
                    self.imageView!.removeFromSuperview()
                    self.lblInfo!.removeFromSuperview()
                    self.imageIco!.removeFromSuperview()
                }
        })
    }
    
    func validate() -> Bool{
        if self.shipmentItems ==  nil {
            return self.viewError(self.shipmentType!,message: NSLocalizedString("checkout.error.shipment", comment:""))
        }
        if self.slotsItems!.count == 0{
           return self.viewError(self.deliveryDate!,message: NSLocalizedString("checkout.error.slots", comment:""))
        }
        return true
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
    
    //MARK: -TableView Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.slotsItems!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellSelItem") as! SelectItemTableViewCell!
        cell.textLabel?.text = self.getHourToShow(self.slotsItems![indexPath.row]["displayText"] as! String)
        cell.checkSelected.frame = CGRectMake(0, 0, 33, 46)
        cell.selectionStyle = .None
        if self.selectedTimeSlotTypeIx != nil {
            cell.setSelected(indexPath.row == self.selectedTimeSlotTypeIx.row, animated: false)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if  self.selectedTimeSlotTypeIx == indexPath {
            cell?.setSelected(indexPath.row == self.selectedTimeSlotTypeIx.row, animated: false)
            return
        }
    
        cell?.selected = false
        let lastSelected =  self.selectedTimeSlotTypeIx
        self.selectedTimeSlotTypeIx = indexPath
        tableView.reloadRowsAtIndexPaths([ self.selectedTimeSlotTypeIx ,lastSelected], withRowAnimation: UITableViewRowAnimation.None)
        self.animationClose()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return  46.0
    }
}
