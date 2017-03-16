//
//  GRCheckOutDeliveryViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

//import Tune

class GRCheckOutDeliveryViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate,UITableViewDataSource, UITableViewDelegate {

    let secSep: CGFloat = 30.0
    let titleSep: CGFloat = 15.0
    let fieldSep: CGFloat = 10.0
    let headerHeight: CGFloat = 46
    var content: TPKeyboardAvoidingScrollView!
    var scrollForm : TPKeyboardAvoidingScrollView!
    var viewLoad : WMLoadingView!
    var picker : AlertPickerView!
    var sAddredssForm : GRFormSuperAddressView!
    var alertView : IPOWMAlertViewController? = nil
    var errorView : FormFieldErrorView? = nil
    var address: FormFieldView?
    var shipmentType: FormFieldView?
    var deliveryDate: FormFieldView?
    var timeSlotsTable: UITableView?
    var addressItems: [[String:Any]]?
    var shipmentItems: [[String:Any]]?
    var slotsItems: [[String:Any]]? = []
    var datesItems: [[String:Any]]?
    var datesToShow: [String]?
    var dateFmt: DateFormatter?
    var addressDesccription: String? = nil
    var selectedAddress: String? = nil
    var selectedAddressHasStore: Bool = true
    var selectedDate : Date!
    var selectedAddressIx : IndexPath!
    var selectedShipmentTypeIx : IndexPath!
    var selectedTimeSlotTypeIx : IndexPath!
    var selectedDateTypeIx : IndexPath!
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
    var paramsToOrder : [String:Any]?
    var paramsToConfirm : [String:Any]?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel?.text = "Detalles de Entrega"
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
        self.stepLabel.textColor = WMColor.gray
        self.stepLabel.text = "1 de 3"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        self.dateFmt = DateFormatter()
        self.dateFmt!.dateFormat =  "EEEE dd, MMMM"
        
        let margin: CGFloat = 16.0
        let width =  IS_IPAD ? 301.0 : self.view.frame.width - (2*margin)
        let fheight: CGFloat = 40.0
        let lheight: CGFloat = 15.0
        
        self.sectionTitle = self.buildSectionTitle(NSLocalizedString("checkout.field.address", comment:""), frame: CGRect(x: margin, y: margin, width: width, height: lheight))
        self.content.addSubview(sectionTitle)
        
        self.address = FormFieldView(frame: CGRect(x: margin, y: sectionTitle.frame.maxY + margin, width: width, height: fheight))
        self.address!.setCustomPlaceholder(NSLocalizedString("checkout.field.address", comment:""))
        self.address!.isRequired = true
        self.address!.typeField = TypeField.list
        self.address!.setImageTypeField()
        self.address!.nameField = NSLocalizedString("checkout.field.address", comment:"")
        self.content.addSubview(self.address!)
        
        self.sectionTitleShipment = self.buildSectionTitle(NSLocalizedString("checkout.field.shipmentType", comment:""), frame: CGRect(x: margin, y: self.address!.frame.maxY + 28, width: width, height: lheight))
        self.content.addSubview(sectionTitleShipment)

        self.shipmentType = FormFieldView(frame: CGRect(x: margin, y: sectionTitleShipment.frame.maxY + margin, width: width, height: fheight))
        self.shipmentType!.setCustomPlaceholder(NSLocalizedString("checkout.field.shipmentType", comment:""))
        self.shipmentType!.isRequired = true
        self.shipmentType!.typeField = TypeField.list
        self.shipmentType!.setImageTypeField()
        self.shipmentType!.nameField = NSLocalizedString("checkout.field.shipmentType", comment:"")
        self.content.addSubview(self.shipmentType!)

        self.sectionTitleDate = self.buildSectionTitle(NSLocalizedString("checkout.title.date", comment:""), frame: CGRect(x: margin, y: self.shipmentType!.frame.maxY + 28, width: width, height: lheight))
        self.content!.addSubview(sectionTitleDate)
        
        self.deliveryDate = FormFieldView(frame: CGRect(x: margin, y: self.sectionTitleDate!.frame.maxY + 5.0, width: width, height: fheight))
        self.deliveryDate!.setCustomPlaceholder(NSLocalizedString("checkout.field.deliveryDate", comment:""))
        self.deliveryDate!.isRequired = true
        self.deliveryDate!.typeField = TypeField.list
        self.deliveryDate!.setImageTypeField()
        self.deliveryDate!.nameField = NSLocalizedString("checkout.field.deliveryDate", comment:"")
        self.deliveryDate!.disablePaste = true
        self.content.addSubview(self.deliveryDate!)
        
        self.timeSlotsTable = UITableView()
        self.timeSlotsTable!.delegate = self
        self.timeSlotsTable!.dataSource = self
        self.timeSlotsTable!.backgroundColor = UIColor.white
        self.timeSlotsTable!.separatorStyle = .none
        self.timeSlotsTable!.register(SelectItemTableViewCell.self, forCellReuseIdentifier: "cellSelItem")
        self.timeSlotsTable!.isScrollEnabled = false
        self.content.addSubview(self.timeSlotsTable!)
        
        self.toolTipLabel = UILabel()
        self.toolTipLabel!.text = NSLocalizedString("checkout.title.tooltip", comment:"")
        self.toolTipLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.toolTipLabel!.textColor = WMColor.empty_gray
        self.toolTipLabel!.textAlignment = .right
        self.toolTipLabel!.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GRCheckOutDeliveryViewController.showTooltip))
        self.toolTipLabel!.addGestureRecognizer(tapGesture)
        self.content.addSubview(self.toolTipLabel!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.view!.layer.insertSublayer(layerLine, at: 1000)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: Selector("back"), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("profile.create.an.continue", comment:""), for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.light_blue
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(GRCheckOutDeliveryViewController.nextStep), for: UIControlEvents.touchUpInside)
        self.view.addSubview(saveButton!)
        
        self.imageView =  UIView()
        self.viewContents = UIView()
        self.viewContents!.layer.cornerRadius = 5.0
        self.viewContents!.backgroundColor = WMColor.light_blue
        
        self.lblInfo = UILabel()
        self.lblInfo!.font = WMFont.fontMyriadProRegularOfSize(12)
        
        self.lblInfo!.textColor = UIColor.white
        self.lblInfo!.backgroundColor = UIColor.clear
        self.lblInfo!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.lblInfo!.textAlignment = NSTextAlignment.left
        self.lblInfo!.numberOfLines = 10
    
        self.imageIco = UIImageView(image:UIImage(named:"tooltip_cart"))
        
        self.picker = AlertPickerView.initPickerWithDefault()
        self.addViewLoad()
        if UserCurrentSession.hasLoggedUser() {
            self.reloadUserAddresses()
        
            self.deliveryDate!.onBecomeFirstResponder = {() in
                self.picker!.selected = self.selectedDateTypeIx
                self.picker!.sender = self.deliveryDate!
                self.picker!.delegate = self
                self.picker!.setValues(NSLocalizedString("checkout.title.deliverySchedule", comment:""), values: self.datesToShow!)
                self.picker!.hiddenRigthActionButton(true)
                self.picker!.cellType = TypeField.check
                self.picker!.showPicker()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let margin: CGFloat = 16.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 40.0
        let lheight: CGFloat = 15.0
        
        self.stepLabel!.frame = CGRect(x: self.view.bounds.width - 51.0,y: 8.0, width: self.titleLabel!.bounds.height, height: 35)
        self.sectionTitle.frame = CGRect(x: margin, y: margin, width: width, height: lheight)
        self.address!.frame = CGRect(x: margin, y: sectionTitle.frame.maxY + margin, width: width, height: fheight)
        self.sectionTitleShipment.frame = CGRect(x: margin, y: self.address!.frame.maxY + 28, width: width, height: lheight)
        self.shipmentType!.frame = CGRect(x: margin, y: sectionTitleShipment.frame.maxY + margin, width: width, height: fheight)
        self.sectionTitleDate.frame = CGRect(x: margin, y: self.shipmentType!.frame.maxY + 28, width: width, height: lheight)
        self.deliveryDate!.frame = CGRect(x: margin, y: self.sectionTitleDate!.frame.maxY + margin, width: width, height: fheight)
        
        let tableMinHeight = self.view.frame.height - self.deliveryDate!.frame.maxY - 145
        let tableMaxHeight: CGFloat = CGFloat(self.slotsItems!.count) * 46
        let tableHeight: CGFloat =  max(tableMinHeight, tableMaxHeight)
        self.timeSlotsTable!.frame = CGRect(x: margin, y: self.deliveryDate!.frame.maxY, width: width, height: tableHeight)
        
        self.toolTipLabel!.frame =  CGRect(x: margin,y: self.timeSlotsTable!.frame.maxY,width: width,height: 34)
        self.content!.contentSize = CGSize(width: width, height: self.toolTipLabel!.frame.maxY)
        self.content!.frame = CGRect(x: 0.0, y: 46.0, width: self.view.bounds.width, height: self.view.bounds.height - 110)
        self.layerLine.frame = CGRect(x: 0, y: self.content!.frame.maxY,  width: self.view.frame.width, height: 1)
        self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148,y: self.content!.frame.maxY + 16, width: 140, height: 34)
        self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.content!.frame.maxY + 16, width: 140, height: 34)
        self.lblInfo!.frame = CGRect (x: 8 , y: 8, width: self.toolTipLabel.frame.width - 16, height: 108)
        self.imageView!.frame = CGRect(x: 16 , y: self.toolTipLabel.frame.minY - 124, width: self.toolTipLabel.frame.width, height: 124)
        self.viewContents!.frame = imageView!.bounds
        self.imageIco!.frame = CGRect(x: self.toolTipLabel.frame.width - 24 , y: viewContents!.frame.maxY - 1, width: 8, height: 6)
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
        
        let btnNewAddress = WMRoundButton()
        btnNewAddress.setTitle("nueva", for: UIControlState())
        btnNewAddress.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        btnNewAddress.setBackgroundColor(WMColor.light_blue, size: CGSize(width: 64.0, height: 22), forUIControlState: UIControlState())
        btnNewAddress.layer.cornerRadius = 2.0
        
        self.picker!.addRigthActionButton(btnNewAddress)
        self.picker!.setValues(self.address!.nameField, values: itemsAddress)
        self.picker!.hiddenRigthActionButton(false)
        self.picker!.cellType = TypeField.check
        if !self.selectedAddressHasStore {
            self.picker!.onClosePicker = {
                //--self.removeViewLoad()
                self.picker!.onClosePicker = nil
                let _ = self.navigationController?.popViewController(animated: true)
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
                    if let id = option["id"] as? String {
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
    /**
     Sets the aviable dates to delibery
     */
    func getAviableDates(){
        self.datesItems = []
        self.datesToShow = []
        self.selectedDateTypeIx = IndexPath(item: 0, section: 0)
        for index in 0...5{
            let date = Date()
            let newDate = date.addingTimeInterval(60 * 60 * 24 * Double(index))
            let dateFmt = DateFormatter()
            dateFmt.timeZone = TimeZone.current
            dateFmt.dateFormat = "EEEE dd, MMMM"
            var stringDate = dateFmt.string(from: newDate).capitalized
            if index == 0{
                stringDate = "Hoy \(stringDate)"
            }else if index == 1{
                stringDate = "Mañana \(stringDate)"
            }
            
            let dateItem = ["dateString":stringDate,"date":newDate] as [String : Any]
            self.datesItems!.append(dateItem)
            self.datesToShow!.append(stringDate)
        }
    }
    /**
     Returns the aviable date  format of a dte
     
     - parameter date: date to format
     
     - returns: [String:Any]
     */
    func returnAviableDate(_ date:Date) -> [String: Any]{
        var aviableDate = self.datesItems!.last!
        var row = 0
        for item in self.datesItems! {
            let itemDate = item["date"] as! Date
            if (Calendar.current as NSCalendar).compare(itemDate, to: date,
                toUnitGranularity: .day) == ComparisonResult.orderedSame {
                aviableDate = item
                break
            }
            row += 1
        }
        self.selectedDateTypeIx = IndexPath(row: row, section: 0)
        return aviableDate
    }
    /**
     Converts an hour string in another format
     
     - parameter hour: hour string
     
     - returns: return hour in format to show
     */
    func getHourToShow(_ hour:String) -> String{
        var cellText = hour
        let range = cellText.range(of: "(")
        let index: Int = cellText.characters.distance(from: cellText.startIndex, to: range!.lowerBound)
        cellText = cellText.substring(index + 1, length: cellText.length() - (index + 1))
        cellText = cellText.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
        cellText = cellText.replacingOccurrences(of: "-", with: "y", options: NSString.CompareOptions.literal, range: nil)
        return "Entre \(cellText)"
    }
    
    func getAddressDescription(_ addressId: String){
        let serviceAddress = GRAddressesByIDService()
        serviceAddress.addressId = self.selectedAddress!
        serviceAddress.callService([:], successBlock: { (result:[String:Any]) -> Void in
            self.addressDesccription = "\(result["street"] as! String) \(result["outerNumber"] as! String) \n\(result["county"] as! String) \(result["city"] as! String)"
            }) { (error:NSError) -> Void in
            self.addressDesccription = ""
            }
        
    }
    /**
     Sent to the following page only if the data is valid
     */
    func nextStep(){
        if !self.validate() {
            return
        }
        let nextController = GRCheckOutCommentsViewController()
        let components : DateComponents = (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: self.selectedDate)
        let dateMonth = components.month
        let dateYear = components.year
        let dateDay = components.day
        let slotSel = self.slotsItems![selectedTimeSlotTypeIx.row]  
        let slotSelectedId = slotSel["id"] as! Int
        let slotHour = slotSel["displayText"] as! String
        let shipmentTypeSel = self.shipmentItems![selectedShipmentTypeIx.row] 
        let shipmentType = shipmentTypeSel["key"] as! String
        self.shipmentAmount = shipmentTypeSel["cost"] as! Double
        self.paramsToOrder = ["month":dateMonth!, "year":dateYear!, "day":dateDay!, "comments":"", "AddressID":self.selectedAddress!,  "slotId":slotSelectedId, "deliveryType":shipmentType, "hour":slotHour, "pickingInstruction":"", "deliveryTypeString":self.shipmentType!.text!,"shipmentAmount":self.shipmentAmount]
        self.paramsToConfirm = ["address":self.addressDesccription!.capitalized,"date":self.deliveryDate!.text!,"hour":self.getHourToShow(slotHour),"shipmentAmount":"\(self.shipmentAmount!)","pickingInstruction":""]
        nextController.paramsToOrder = self.paramsToOrder
        nextController.paramsToConfirm = self.paramsToConfirm
        self.navigationController?.pushViewController(nextController, animated: true)
    }
 
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    func contentSizeForScrollView(_ sender:Any) -> CGSize {
        if let scroll = sender as? TPKeyboardAvoidingScrollView {
            if scrollForm != nil {
                if scroll == scrollForm {
                    return CGSize(width: self.scrollForm.frame.width, height: self.scrollForm.contentSize.height)
                }
            }
        }
        return CGSize(width: self.view.frame.width, height: self.content.contentSize.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.animationClose()
    }
    //MARK: Services
    /**
     Gets the user addresses
     */
    func reloadUserAddresses(){
        self.invokeAddressUserService({ () -> Void in
            let _ = self.getItemsTOSelectAddres()
            self.getAddressDescription(self.selectedAddress!)
            self.address!.onBecomeFirstResponder = {() in
                self.showAddressPicker()
            }
            //TODO
            self.getAviableDates()
            self.selectedDate = self.datesItems!.first!["date"] as! Date
            self.deliveryDate!.text = self.datesToShow!.first!
            self.buildAndConfigureDeliveryType()
        })
    }
    /**
     Gets the user addresses service
     */
    func invokeAddressUserService(_ endCallAddress:@escaping (() -> Void)) {
        //--self.addViewLoad()
        let service = GRAddressByUserService()
        service.callService(
            { (result:[String:Any]) -> Void in
                if let items = result["responseArray"] as? [[String:Any]] {
                    self.addressItems = items
                    if items.count > 0 {
                        let ixCurrent = 0
                        for dictDir in items {
                            if let preferred = dictDir["preferred"] as? NSNumber {
                                if self.selectedAddress == nil {
                                    if preferred.boolValue == true {
                                        self.selectedAddressIx = IndexPath(row: ixCurrent, section: 0)
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
    
    /**
     Gets and shows the delibery types in a popup view
     */
    func buildAndConfigureDeliveryType() {
        if self.selectedAddress != nil {
            self.invokeDeliveryTypesService({ () -> Void in
                self.shipmentType!.onBecomeFirstResponder = {() in
                    //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_ADDRES_DELIVERY.rawValue , label: "")
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
                        self.picker!.cellType = TypeField.check
                        self.picker!.showPicker()
                    }
                }
                self.selectedDate = Date()
                self.buildSlotsPicker(self.selectedDate)
                //self.invokeSetDeliveryTypeService()
            })
        }
    }
    
    /**
     Sets delivery types from an address
     */
    func invokeSetDeliveryTypeService() {
        var shipmentType = "1"
        if self.shipmentItems != nil {
            let shipmentTypeSel = self.shipmentItems![selectedShipmentTypeIx.row]
            shipmentType = shipmentTypeSel["key"] as! String
        }
        
        let carId = UserCurrentSession.sharedInstance.userSigned!.cartIdGR
        let service = SetDeliveryTypeService()
        let params = service.buildParams(shipmentType, addressID: self.selectedAddress!, idList: carId as String)
        service.callService(requestParams: params, successBlock: nil, errorBlock: nil)
    }
    
    /**
     Gets delivery types from an address
     
     - parameter endCallTypeService: block to call at end of service
     */
    func invokeDeliveryTypesService(_ endCallTypeService:@escaping (() -> Void)) {
        //--self.addViewLoad()
        let service = GRDeliveryTypeService()
        //Validar self.selectedAddress != nil
        if self.selectedAddress != nil {
            service.setParams("\(UserCurrentSession.sharedInstance.numberOfArticlesGR())", addressId: self.selectedAddress!,isFreeShiping:"false")
            let empty: [String:Any] = [:]
            service.callService(requestParams: empty as AnyObject,
                successBlock: { (result:[String:Any]) -> Void in
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
                        let shipName = self.shipmentItems![0] 
                        self.selectedShipmentTypeIx = IndexPath(row: 0, section: 0)
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
    /**
     Gets the available hours from date
     
     - parameter date: date
     */
    func buildSlotsPicker(_ date:Date?) {
        //self.addViewLoad()
        var strDate = ""
        if date != nil {
            let formatService  = DateFormatter()
            formatService.dateFormat = "dd/MM/yyyy"
            strDate = formatService.string(from: date!)
        }
        self.invokeTimeBandsService(strDate, endCallTypeService: { () -> Void in
            if  self.slotsItems?.count > 0 {
                if self.errorView != nil {
                    self.errorView!.removeFromSuperview()
                    self.errorView!.focusError = nil
                    self.errorView = nil
                    self.deliveryDate?.layer.borderColor =   UIColor.white.cgColor
                }
                self.selectedTimeSlotTypeIx = IndexPath(row: 0, section: 0)
            }
            self.timeSlotsTable!.reloadData()
            self.removeViewLoad()//ok
        })
    }
    /**
      Gets available hours from date
     
     - parameter date:               date to get hours
     - parameter endCallTypeService: end block
     */
    func invokeTimeBandsService(_ date:String,endCallTypeService:@escaping (() -> Void)) {
        let service = GRTimeBands()
        let params = service.buildParams(date, addressId: self.selectedAddress!)
        service.callService(requestParams: params, successBlock: { (result:[String:Any]) -> Void in
            if let day = result["day"] as? String {
            if let month = result["month"] as? String {
                if let year = result["year"] as? String {
                    let dateSlot = "\(day)/\(month)/\(year)"
                    let aviableDate = self.returnAviableDate(self.parseDateString(dateSlot))
                    self.deliveryDate!.text = aviableDate["dateString"] as? String
                    self.selectedDate = aviableDate["date"] as! Date
                }
            }
        }
            self.slotsItems = result["slots"] as? [[String:Any]]
        //--self.addViewLoad()
        endCallTypeService()
        }) { (error:NSError) -> Void in
            self.removeViewLoad()
            self.slotsItems = []
            let aviableDate = self.returnAviableDate(self.parseDateString(date))
            self.deliveryDate!.text = aviableDate["dateString"] as? String
            self.selectedDate = aviableDate["date"] as! Date
            endCallTypeService()
        }
    }
    /**
     Shows or hides tooltip view
     */
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
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(GRCheckOutDeliveryViewController.animationClose), userInfo: nil, repeats: false)
    }
    /**
     Animation that closes toltip view
     */
    func animationClose () {
        UIView.animate(withDuration: 0.9,
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
    /**
     Validates shipment items and slot items
     
     - returns: true if the data is valid
     */
    func validate() -> Bool{
        if self.shipmentItems ==  nil {
            return self.viewError(self.shipmentType!,message: NSLocalizedString("checkout.error.shipment", comment:""))
        }
        if self.slotsItems!.count == 0{
           return self.viewError(self.deliveryDate!,message: NSLocalizedString("checkout.error.slots", comment:""))
        }
        if !self.selectedAddressHasStore  {
            return self.viewError(self.address!,message: NSLocalizedString("gr.address.field.addressNotOk",comment:""))
        }
        return true
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
    
    //MARK: -TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.slotsItems!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSelItem") as! SelectItemTableViewCell!
        cell?.textLabel?.text = self.getHourToShow(self.slotsItems![indexPath.row]["displayText"] as! String)
        cell?.checkSelected.frame = CGRect(x: 0, y: 0, width: 33, height: 46)
        cell?.selectionStyle = .none
        if self.selectedTimeSlotTypeIx != nil {
            cell?.setSelected(indexPath.row == self.selectedTimeSlotTypeIx.row, animated: false)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if  self.selectedTimeSlotTypeIx == indexPath {
            cell?.setSelected(indexPath.row == self.selectedTimeSlotTypeIx.row, animated: false)
            return
        }
    
        cell?.isSelected = false
        let lastSelected =  self.selectedTimeSlotTypeIx
        self.selectedTimeSlotTypeIx = indexPath
        tableView.reloadRows(at: [ self.selectedTimeSlotTypeIx ,lastSelected!], with: UITableViewRowAnimation.none)
        self.animationClose()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  46.0
    }
}

extension GRCheckOutDeliveryViewController: AlertPickerViewDelegate {
    
    //MARK: AlertPickerViewDelegate
    func didSelectOption(_ picker:AlertPickerView,indexPath: IndexPath,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  self.address! {
                self.addViewLoad()
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_CHANGE_ADDRES_DELIVERY.rawValue , label: "")
                self.address!.text = selectedStr
                var option = self.addressItems![indexPath.row]
                if let addressId = option["id"] as? String {
                    print("Asigned AddresID :::\(addressId) ---")
                    self.selectedAddress = addressId
                    self.getAddressDescription(addressId)
                }
                self.selectedAddressIx = indexPath
                self.buildAndConfigureDeliveryType()
                
            }
            if formFieldObj ==  self.shipmentType! {
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_AUTH.rawValue, action:WMGAIUtils.ACTION_OK.rawValue , label: "")
                self.shipmentType!.text = selectedStr
                self.selectedShipmentTypeIx = indexPath
                let shipment = self.shipmentItems![indexPath.row]
                self.shipmentAmount = shipment["cost"] as! Double
                //self.invokeSetDeliveryTypeService()
            }
            if formFieldObj ==  self.deliveryDate! {
                self.addViewLoad()
                self.selectedDateTypeIx = indexPath
                let selectedItem = self.datesItems![indexPath.row]
                self.selectedDate = selectedItem["date"] as! Date
                self.buildSlotsPicker(self.selectedDate)
            }
        }
    }
    
    func didDeSelectOption(_ picker:AlertPickerView) {
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
    
    func buttomViewSelected(_ sender: UIButton) {
        
    }
    /**
     Returns the view to replace in popup
     
     - parameter frame: view frame
     
     - returns:UIView
     */
    func viewReplaceContent(_ frame:CGRect) -> UIView! {
        scrollForm = TPKeyboardAvoidingScrollView(frame: frame)
        self.scrollForm.scrollDelegate = self
        scrollForm.contentSize = CGSize(width: frame.width, height: 720)
        if sAddredssForm == nil {
            sAddredssForm = GRFormSuperAddressView(frame: CGRect(x: scrollForm.frame.minX, y: 0, width: scrollForm.frame.width, height: 700))
        }
        sAddredssForm.clearView()
        sAddredssForm.allAddress = self.addressItems as [Any]!
        sAddredssForm.idAddress = ""
        self.picker!.closeButton!.isHidden =  true
        if !self.selectedAddressHasStore && !self.picker!.isNewAddres{
            self.picker!.closeButton!.isHidden =  false
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
                self.sAddredssForm.setZipCodeAnfFillFields(self.sAddredssForm.zipcode.text!, neighborhoodID: neighborhoodID!, storeID: storeID!)
                self.sAddredssForm.idAddress = result["addressID"] as! String!
            }) { (error:NSError) -> Void in
            }
        }else{
            self.sAddredssForm.addressName.text = ""
            self.sAddredssForm.outdoornumber.text = ""
            self.sAddredssForm.indoornumber.text = ""
            self.sAddredssForm.betweenFisrt.text = ""
            self.sAddredssForm.betweenSecond.text = ""
            self.sAddredssForm.zipcode.text = ""
            self.sAddredssForm.street.text = ""
            self.sAddredssForm.idAddress = ""
            self.sAddredssForm.suburb!.text = ""
            self.sAddredssForm.zipcode.text! = ""
            self.sAddredssForm.store!.text = ""
            self.sAddredssForm.phoneHomeNumber.text = ""
            self.sAddredssForm.phoneWorkNumber.text = ""
            self.sAddredssForm.cellPhone.text = ""
            
        
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
                service.callService(requestParams: dictSend!, successBlock: { (resultCall:[String:Any]) -> Void  in
                    //--self.addViewLoad()
                    print("Se realizao la direccion")
                    self.picker!.closeNew()
                    self.picker!.closePicker()
                    let addresId  = resultCall["addressID"] as! String!
                    if addresId != "" {
                        self.selectedAddress = resultCall["addressID"] as! String!
                        print("saveReplaceViewSelected Address ID \(self.selectedAddress)---")
                    } else{
                        print("error:: no regresan id se queda Address ID \(self.selectedAddress)---")
                    }
                    if let message = resultCall["message"] as? String {
                        self.alertView!.setMessage("\(message)")
                    }
                    self.alertView!.showDoneIcon()
                    
                    self.picker!.titleLabel.textAlignment = .center
                    self.picker!.titleLabel.frame =  CGRect(x: 40, y: self.picker!.titleLabel.frame.origin.y, width: self.picker!.titleLabel.frame.width, height: self.picker!.titleLabel.frame.height)
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
}
