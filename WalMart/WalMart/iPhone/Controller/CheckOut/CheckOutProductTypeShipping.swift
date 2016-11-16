//
//  CheckOutProductTypeShipping.swift
//  WalMart
//
//  Created by Joel Juarez on 07/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

protocol CheckOutProductTypeShippingDelegate {
    func selectDataTypeShipping(_ envio: String, util: String, date: String, rowSelected: Int,idSolot:String)
}


class CheckOutProductTypeShipping: NavigationViewController,AlertPickerSelectOptionDelegate {
    
    let HOME_DELIVERY = "homeDeliveryTaxi"
    let STORE_PICK_UP = "storePickUp"
    
    var delegate: CheckOutProductTypeShippingDelegate?
    var deliveryButton : UIButton?
    var collectButton : UIButton?
    var titleDelivery : UILabel?
    
    var saveButton : UIButton?
    
    var delivaryCost : CurrencyCustomLabel?
    var collectCost : CurrencyCustomLabel?
    var picker : AlertPickerView!
    
    var viewDelivery : UIView?
    
    var viewFooter : UIView?
    
    var selectedParams : NSMutableDictionary?
    
    var dateSlot : [String] = []
    var timeSelect : [String] = []
    var groupSlotSelect : [String] = []
    
    
    let hourArray :NSMutableArray  = []
    let slotArray :NSMutableArray  = []
    
    var selectTypeDelivery = ""
    var textFieldSelected = ""
    var slotSelected = ""
    var selectedSlotIdx: IndexPath! = IndexPath(row: 0, section: 0)
    var selectedDateIdx: IndexPath! = IndexPath(row: 0, section: 0)
    var titleString : String?
    
    var paymentSelected : [String:Any]?
    var errorView : FormFieldErrorView? = nil

    var viewLoad : WMLoadingView!

    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.titleLabel?.text = titleString
        self.backButton?.isHidden =  IS_IPAD
        
        self.viewFooter =  UIView()
        self.viewFooter?.backgroundColor = UIColor.white
        self.view.addSubview(viewFooter!)
        
        let layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        viewFooter!.layer.insertSublayer(layerLine, at: 1000)
        layerLine.frame = CGRect(x: 0, y: 0, width: self.viewFooter!.frame.width, height: 2)
        
        saveButton = UIButton()
        saveButton!.setTitle(NSLocalizedString("Guardar", comment: ""), for: UIControlState())
        saveButton!.setTitleColor(UIColor.white, for: UIControlState())
        saveButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        saveButton!.backgroundColor =  WMColor.green
        saveButton!.layer.cornerRadius =  17
        saveButton!.addTarget(self, action: #selector(CheckOutProductTypeShipping.save), for: .touchUpInside)
        self.viewFooter?.addSubview(saveButton!)
        self.view.addSubview(viewFooter!)
        
        self.titleDelivery = UILabel()
        self.titleDelivery!.textColor = WMColor.light_blue
        self.titleDelivery!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleDelivery!.text = NSLocalizedString("select.type.delivery", comment: "")
        self.view.addSubview(titleDelivery!)


        self.deliveryButton = UIButton()
        self.deliveryButton!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
        self.deliveryButton!.setImage(UIImage(named:"check_full"), for: UIControlState.selected)
        self.deliveryButton!.setTitleColor(WMColor.dark_gray, for: UIControlState())
        self.deliveryButton!.setTitle(NSLocalizedString("home.delivery", comment: ""), for: UIControlState())
        self.deliveryButton!.titleEdgeInsets = UIEdgeInsets(top: 3, left: 10, bottom: 0, right:0)
        self.deliveryButton!.contentHorizontalAlignment = .left
        self.deliveryButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.deliveryButton?.tag =  1
        self.deliveryButton?.addTarget(self, action: #selector(CheckOutProductTypeShipping.checkTypeDeliver(_:) ), for: .touchUpInside)
       

        self.view.addSubview(deliveryButton!)
        
        delivaryCost = CurrencyCustomLabel(frame: CGRect(x: self.deliveryButton!.frame.maxX + 3, y: deliveryButton!.frame.minY, width: 50, height: 18))
        delivaryCost!.textAlignment = .right
        self.view.addSubview(delivaryCost!)
        
        self.collectButton = UIButton()
        self.collectButton!.setImage(UIImage(named:"checkTermOff"), for: UIControlState())
        self.collectButton!.setImage(UIImage(named:"check_full"), for: UIControlState.selected)
        self.collectButton!.setTitleColor(WMColor.dark_gray, for: UIControlState())
        self.collectButton!.setTitle(NSLocalizedString("store.pickup", comment: ""), for: UIControlState())
        self.collectButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.collectButton!.titleEdgeInsets = UIEdgeInsets(top: 3, left: 10, bottom: 0, right:0)
        self.collectButton!.addTarget(self, action: #selector(CheckOutProductTypeShipping.checkTypeDeliver(_:)), for: .touchUpInside)
        self.collectButton?.tag =  2
        self.collectButton!.contentHorizontalAlignment = .left
        self.view.addSubview(collectButton!)
        
        collectCost = CurrencyCustomLabel(frame: CGRect(x: self.collectButton!.frame.maxX + 3, y: collectButton!.frame.minY, width: 50, height: 18))
        collectCost!.textAlignment = .right
        self.view.addSubview(collectCost!)
        
        setvalues()
        
        self.picker = AlertPickerView.initPickerWithDefault()
        self.showLoadingView()
    
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewFooter?.frame = CGRect(x:0 , y:self.view.frame.maxY - 64, width:self.view.bounds.width , height: 64 )
        
        self.titleDelivery?.frame =  CGRect(x: 16,y: headerHeight + 16 ,width: self.view.frame.width - 32 ,height: 14)
        
        self.deliveryButton?.frame =  CGRect(x: 16,y: self.titleDelivery!.frame.maxY + 16 ,width: self.view.frame.midX - 16 ,height: 46)
        
        delivaryCost?.frame = CGRect(x: self.view.frame.width - (self.deliveryButton!.frame.width + 16) , y: deliveryButton!.frame.minY, width: self.deliveryButton!.frame.width , height: 46)
        
        self.collectButton?.frame =  CGRect(x: 16,y: self.deliveryButton!.frame.maxY + 8 ,width: self.view.frame.midX - 16 ,height: 46)
        collectCost?.frame = CGRect(x: self.view.frame.width - (self.collectButton!.frame.width + 16) , y: collectButton!.frame.minY, width: self.collectButton!.frame.width , height: 46)
        
        if afterSelected != nil &&  afterSelected!.tag == 1 {
                
                self.collectButton?.frame =  CGRect(x: 16,y: self.viewDelivery!.frame.maxY + 8 ,width: self.view.frame.midX - 16 ,height: 46)
                collectCost?.frame = CGRect(x: self.view.frame.width - (self.collectButton!.frame.width + 16) , y: collectButton!.frame.minY, width: self.collectButton!.frame.width , height: 46)
            
        }else{
                self.viewDelivery?.frame = CGRect(x: 16,y: self.collectButton!.frame.maxY + 16 ,width: self.view.frame.width - 32 ,height: 144)
        }
        
        self.saveButton?.frame =  CGRect(x:16 , y:16 , width:self.view.frame.width - 32, height:34)

    }
    
  
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear ... . . ")
        self.checkTypeDeliver(deliveryButton!)
    }
    
    //MARK: LodingView 
    
    func showLoadingView(){
        if viewLoad == nil {
            let bounds = IS_IPAD ? CGRect(x: 0, y: 0, width: 341, height: 705) : self.view.bounds
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
    
    
    func setvalues(){
        
        delivaryCost!.updateMount( CurrencyCustomLabel.formatString(NSString(string: "120.50")), font: WMFont.fontMyriadProSemiboldOfSize(18), color: WMColor.orange, interLine: false)
        
        collectCost!.updateMount( CurrencyCustomLabel.formatString(NSString(string: "10.50")), font: WMFont.fontMyriadProSemiboldOfSize(18), color: WMColor.orange, interLine: false)
    
    }
    
    
    var afterSelected : UIButton?
    func checkTypeDeliver(_ sender:UIButton) {
        
        if afterSelected != nil {
            self.afterSelected!.isSelected =  false
        }
        
        sender.isSelected = !sender.isSelected
        
        self.viewDelivery?.removeFromSuperview()
        afterSelected =  sender
        self.createView(CGRect(x: 16,y: sender.frame.maxY + 16 ,width: self.view.frame.width - 32 ,height: 144))
        
        self.slotSelected = ""
        self.invokeSloteService(sender.tag == 1 ? HOME_DELIVERY : STORE_PICK_UP )
        self.selectTypeDelivery = sender.tag == 1 ? HOME_DELIVERY : STORE_PICK_UP
        self.dateSelected = false
        self.slotIsSelected = false
        self.groupSlotSelect = []
        self.dateSlot = []
    }
    
    var  dateForm : FormFieldView?
    var  timeForm : FormFieldView?
    
    func createView(_ frame:CGRect)  {
        
        viewDelivery = UIView(frame: frame)
        
        let  addressInvoice = FormFieldView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 40))
        addressInvoice.attributedPlaceholder = NSAttributedString(string: "Mi casa", attributes: [NSForegroundColorAttributeName:WMColor.dark_gray , NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(14)])
        addressInvoice.isRequired = true
        addressInvoice.isEnabled = false
        addressInvoice.typeField = TypeField.list
        addressInvoice.setImageTypeField()
        addressInvoice.nameField = NSLocalizedString("checkout.field.shipmentType", comment:"")
    
        addressInvoice.imageList!.isHidden = true
        viewDelivery!.addSubview(addressInvoice)
        
      
        
        dateForm = FormFieldView(frame: CGRect(x: 0, y: addressInvoice.frame.maxY + 8 , width: frame.width, height: 40))
        dateForm!.setCustomPlaceholder(NSLocalizedString("dates.aviables", comment: ""))
        dateForm!.isRequired = true
        dateForm!.typeField = TypeField.list
        dateForm!.setImageTypeField()
        dateForm!.nameField = NSLocalizedString("dates.aviables", comment:"")
        dateForm!.onBecomeFirstResponder = { () in
            if self.dateSlot.count > 0 {
                self.picker!.selected = self.selectedDateIdx
                self.picker!.sender = self.dateForm
                self.picker!.selectOptionDelegate = self
                self.picker!.setValues(NSLocalizedString("dates.delivery.aviables",comment:"") as NSString, values:self.dateSlot )
                self.picker!.cellType = TypeField.check
                self.picker!.showPicker()
                self.view.endEditing(true)
                self.textFieldSelected = "Date"
            }
        }
        viewDelivery!.addSubview(dateForm!)

        
        timeForm = FormFieldView(frame: CGRect(x: 0, y: dateForm!.frame.maxY + 8, width: frame.width, height: 40))
        timeForm!.setCustomPlaceholder(NSLocalizedString("times.aviables", comment: ""))
        timeForm!.isRequired = true
        timeForm!.typeField = TypeField.list
        timeForm!.setImageTypeField()
        timeForm!.nameField = NSLocalizedString("times.aviables", comment:"")
        timeForm!.onBecomeFirstResponder = { () in
            if self.groupSlotSelect.count > 0 {
                self.picker!.selected = self.selectedSlotIdx
                self.picker!.sender = self.timeForm
                self.picker!.selectOptionDelegate = self
                self.picker!.setValues(NSLocalizedString("times.aviables",comment:"") as NSString, values:self.timeSelect )
                self.picker!.cellType = TypeField.check
                self.picker!.showPicker()
                self.textFieldSelected = "Time"
                self.view.endEditing(true)
            }
        }
        viewDelivery!.addSubview(timeForm!)
        
        self.view.addSubview(viewDelivery!)
        self.removeViewLoad()

    
    }
    
    
    func save(){
        if validate(){
            let selectedSlotService = SelectedSlotService()
            let params = selectedSlotService.buildParams(self.selectTypeDelivery, selectedSlotId: self.slotSelected)
            selectedSlotService.callService(requestParams: params as AnyObject, succesBlock: { (result) -> Void in
                self.delegate?.selectDataTypeShipping(NSLocalizedString(self.selectTypeDelivery, comment: ""), util: "", date: self.dateForm!.text! , rowSelected: 1,idSolot: self.slotSelected)
                self.navigationController!.popViewController(animated: true)
                }, errorBlock: { (error) -> Void in
                    
                    print("error guardando slot")
            })
        }
        
    }
    
    //MARK:  Invoke Services
    
    func invokeSloteService(_ type:String) {
        
        let service =  DisplaySlotsService()
        
        service.callService(requestParams: service.buildParamsHomeDelivery(type) as AnyObject, succesBlock: { (responce:[String:Any]) in
            
            let slots =  responce["responseObject"] as! [String:Any]
            let key =  slots.keys.sorted(by: { (first, second) -> Bool in
                return first < second
            })
            self.dateSlot =  []
            for keys in key{
                let horsSlot :NSMutableArray  = []
                let slot :NSMutableArray  = []
                let slotForDay = slots[keys] as! [[String:Any]]
                
                for daySlot in slotForDay {
                    
                    horsSlot.add(daySlot["deliveryTime"] as! String)
                    slot.add(daySlot["slotId"] as! String)
                    
                    let date  = daySlot["DeliveryDateCalendar.time"] as! [String:Any]
                    let dayDelivery  = "\(date["formattedDate"] as! String)"
                    
                    if !self.dateSlot.contains(dayDelivery) {
                        self.dateSlot.append(dayDelivery)
                    }
                    
                }
                self.hourArray.add(horsSlot)
                self.slotArray.add(slot)
            }
            self.getAviableDates()
            print(self.hourArray)
            print(self.dateSlot)
            
            
            }, errorBlock: { (error:NSError) in
                print("Error al consultar el servicio \(error.localizedDescription)")
                
        })
        
    }
    
    
    func getAviableDates(){
        
        let dateFmt = DateFormatter()
        dateFmt.timeZone = TimeZone.current
        
        var datearray : [String] = []
        var index =  0
        for dates in self.dateSlot {
            
            dateFmt.dateFormat = "dd/MM/yyyy"
            let dateform =  dateFmt.date(from: dates)
            dateFmt.dateFormat = "EEEE dd '\(NSLocalizedString("checkout.confirm.to", comment: ""))' MMMM"
            var stringDate = dateFmt.string(from: dateform!).capitalized
            if index == 0{
                stringDate = "Hoy \(stringDate)"
            }else if index == 1{
                stringDate = "Mañana \(stringDate)"
            }
            
            datearray.append(stringDate)
            index =  index + 1
            
        }
        self.dateSlot =  datearray
    }
    
    func getTimes(){
        var typeArray : [String] = []
        
        for time in self.timeSelect {
            typeArray.append("Entre \(time.replacingOccurrences(of: "-", with: " y ").replacingOccurrences(of: ":00 ", with: " "))")
        }
        timeSelect = typeArray
    }

    //MARK: - AlertPickerSelectOptionDelegate
    
    var dateSelected = false
    var slotIsSelected =  false
    func didSelectOptionAtIndex(_ indexPath: IndexPath){
        
        if self.textFieldSelected == "Date" {
           dateForm?.text =   self.dateSlot[(indexPath as NSIndexPath).row]
            let times  =  self.hourArray.object(at: (indexPath as NSIndexPath).row) as! [String]
            timeSelect =  times
            self.getTimes()
            
            let slots  =  self.slotArray.object(at: (indexPath as NSIndexPath).row) as! [String]
            groupSlotSelect = slots
            selectedDateIdx = indexPath
            dateSelected =  true
            self.dateForm!.layer.borderColor = UIColor.clear.cgColor
            self.errorView?.removeFromSuperview()
            self.errorView = nil
            
        }else{
            timeForm?.text = timeSelect[(indexPath as NSIndexPath).row]
            slotSelected = groupSlotSelect[(indexPath as NSIndexPath).row]
            selectedSlotIdx = indexPath
            slotIsSelected =  true
            self.timeForm!.layer.borderColor = UIColor.clear.cgColor
            self.errorView?.removeFromSuperview()
            self.errorView = nil
        }
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
    
 
    func validate() -> Bool{
        if !self.dateSelected  {
            return self.viewError(self.dateForm!,message: NSLocalizedString("select.dates.aviables",comment:""))
        }
        
        if !self.slotIsSelected {
            return self.viewError(self.timeForm!,message:NSLocalizedString("select.times.aviables", comment: ""))
        }
        
        return true
    }

    
    
    
    

}
