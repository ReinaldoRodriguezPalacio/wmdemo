//
//  CheckOutProductTypeShipping.swift
//  WalMart
//
//  Created by Joel Juarez on 07/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

protocol CheckOutProductTypeShippingDelegate {
    func selectDataTypeShipping(envio: String, util: String, date: String, rowSelected: Int,idSolot:String)
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
    var selectedSlotIdx: NSIndexPath! = NSIndexPath(forRow: 0, inSection: 0)
    var selectedDateIdx: NSIndexPath! = NSIndexPath(forRow: 0, inSection: 0)
    var titleString : String?
    
    var paymentSelected : NSDictionary?
    var errorView : FormFieldErrorView? = nil

    var viewLoad : WMLoadingView!

    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.titleLabel?.text = titleString
        self.backButton?.hidden =  IS_IPAD
        
        self.viewFooter =  UIView()
        self.viewFooter?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(viewFooter!)
        
        let layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        viewFooter!.layer.insertSublayer(layerLine, atIndex: 1000)
        layerLine.frame = CGRectMake(0, 0, self.viewFooter!.frame.width, 2)
        
        saveButton = UIButton()
        saveButton!.setTitle(NSLocalizedString("Guardar", comment: ""), forState: .Normal)
        saveButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        saveButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        saveButton!.backgroundColor =  WMColor.green
        saveButton!.layer.cornerRadius =  17
        saveButton!.addTarget(self, action: #selector(CheckOutProductTypeShipping.save), forControlEvents: .TouchUpInside)
        self.viewFooter?.addSubview(saveButton!)
        self.view.addSubview(viewFooter!)
        
        self.titleDelivery = UILabel()
        self.titleDelivery!.textColor = WMColor.light_blue
        self.titleDelivery!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleDelivery!.text = "Selecciona un tipo de envío"
        self.view.addSubview(titleDelivery!)


        self.deliveryButton = UIButton()
        self.deliveryButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.deliveryButton!.setImage(UIImage(named:"check_full"), forState: UIControlState.Selected)
        self.deliveryButton!.setTitleColor(WMColor.dark_gray, forState: .Normal)
        self.deliveryButton!.setTitle("Envío a domicilio", forState: .Normal)
        self.deliveryButton!.titleEdgeInsets = UIEdgeInsets(top: 3, left: 10, bottom: 0, right:0)
        self.deliveryButton!.contentHorizontalAlignment = .Left
        self.deliveryButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.deliveryButton?.tag =  1
        self.deliveryButton?.addTarget(self, action: #selector(CheckOutProductTypeShipping.checkTypeDeliver(_:) ), forControlEvents: .TouchUpInside)
       

        self.view.addSubview(deliveryButton!)
        
        delivaryCost = CurrencyCustomLabel(frame: CGRectMake(self.deliveryButton!.frame.maxX + 3, deliveryButton!.frame.minY, 50, 18))
        delivaryCost!.textAlignment = .Right
        self.view.addSubview(delivaryCost!)
        
        self.collectButton = UIButton()
        self.collectButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.collectButton!.setImage(UIImage(named:"check_full"), forState: UIControlState.Selected)
        self.collectButton!.setTitleColor(WMColor.dark_gray, forState: .Normal)
        self.collectButton!.setTitle("Recoger en tienda", forState: .Normal)
        self.collectButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.collectButton!.titleEdgeInsets = UIEdgeInsets(top: 3, left: 10, bottom: 0, right:0)
        self.collectButton!.addTarget(self, action: #selector(CheckOutProductTypeShipping.checkTypeDeliver(_:)), forControlEvents: .TouchUpInside)
        self.collectButton?.tag =  2
        self.collectButton!.contentHorizontalAlignment = .Left
        self.view.addSubview(collectButton!)
        
        collectCost = CurrencyCustomLabel(frame: CGRectMake(self.collectButton!.frame.maxX + 3, collectButton!.frame.minY, 50, 18))
        collectCost!.textAlignment = .Right
        self.view.addSubview(collectCost!)
        
        setvalues()
        
        self.picker = AlertPickerView.initPickerWithDefault()
        self.showLoadingView()
    
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewFooter?.frame = CGRect(x:0 , y:self.view.frame.maxY - 64, width:self.view.bounds.width , height: 64 )
        
        self.titleDelivery?.frame =  CGRectMake(16,headerHeight + 16 ,self.view.frame.width - 32 ,14)
        
        self.deliveryButton?.frame =  CGRectMake(16,self.titleDelivery!.frame.maxY + 16 ,self.view.frame.midX - 16 ,46)
        
        delivaryCost?.frame = CGRectMake(self.view.frame.width - (self.deliveryButton!.frame.width + 16) , deliveryButton!.frame.minY, self.deliveryButton!.frame.width , 46)
        
        self.collectButton?.frame =  CGRectMake(16,self.deliveryButton!.frame.maxY + 8 ,self.view.frame.midX - 16 ,46)
        collectCost?.frame = CGRectMake(self.view.frame.width - (self.collectButton!.frame.width + 16) , collectButton!.frame.minY, self.collectButton!.frame.width , 46)
        
        if afterSelected != nil &&  afterSelected!.tag == 1 {
                
                self.collectButton?.frame =  CGRectMake(16,self.viewDelivery!.frame.maxY + 8 ,self.view.frame.midX - 16 ,46)
                collectCost?.frame = CGRectMake(self.view.frame.width - (self.collectButton!.frame.width + 16) , collectButton!.frame.minY, self.collectButton!.frame.width , 46)
            
        }else{
                self.viewDelivery?.frame = CGRectMake(16,self.collectButton!.frame.maxY + 16 ,self.view.frame.width - 32 ,144)
        }
        
        self.saveButton?.frame =  CGRect(x:16 , y:16 , width:self.view.frame.width - 32, height:34)

    }
    
  
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear ... . . ")
        self.checkTypeDeliver(deliveryButton!)
    }
    
    //MARK: LodingView 
    
    func showLoadingView(){
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
    
    
    func setvalues(){
        
        delivaryCost!.updateMount( CurrencyCustomLabel.formatString(String("120.50")), font: WMFont.fontMyriadProSemiboldOfSize(18), color: WMColor.orange, interLine: false)
        
        collectCost!.updateMount( CurrencyCustomLabel.formatString(String("10.50")), font: WMFont.fontMyriadProSemiboldOfSize(18), color: WMColor.orange, interLine: false)
    
    }
    
    
    var afterSelected : UIButton?
    func checkTypeDeliver(sender:UIButton) {
        
        if afterSelected != nil {
            self.afterSelected!.selected =  false
        }
        
        sender.selected = !sender.selected
        
        self.viewDelivery?.removeFromSuperview()
        afterSelected =  sender
        self.createView(CGRectMake(16,sender.frame.maxY + 16 ,self.view.frame.width - 32 ,144))
        
        self.slotSelected = ""
        self.invokeSloteService(sender.tag == 1 ? HOME_DELIVERY : STORE_PICK_UP )
        self.selectTypeDelivery = sender.tag == 1 ? HOME_DELIVERY : STORE_PICK_UP
        self.dateSelected = false
        self.slotIsSelected = false
    }
    
    var  dateForm : FormFieldView?
    var  timeForm : FormFieldView?
    
    func createView(frame:CGRect)  {
        
        viewDelivery = UIView(frame: frame)
        
        let  addressInvoice = FormFieldView(frame: CGRectMake(0, 0, frame.width, 40))
        addressInvoice.attributedPlaceholder = NSAttributedString(string: "Mi casa", attributes: [NSForegroundColorAttributeName:WMColor.dark_gray , NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(14)])
        addressInvoice.isRequired = true
        addressInvoice.enabled = false
        addressInvoice.typeField = TypeField.List
        addressInvoice.setImageTypeField()
        addressInvoice.nameField = NSLocalizedString("checkout.field.shipmentType", comment:"")
    
        addressInvoice.imageList!.hidden = true
        viewDelivery!.addSubview(addressInvoice)
        
      
        
        dateForm = FormFieldView(frame: CGRectMake(0, addressInvoice.frame.maxY + 8 , frame.width, 40))
        dateForm!.setCustomPlaceholder("Fechas disponibles")
        dateForm!.isRequired = true
        dateForm!.typeField = TypeField.List
        dateForm!.setImageTypeField()
        dateForm!.nameField = NSLocalizedString("Fechas disponibles", comment:"")
        dateForm!.onBecomeFirstResponder = { () in
            self.picker!.selected = self.selectedDateIdx
            self.picker!.sender = self.dateForm
            self.picker!.selectOptionDelegate = self
            self.picker!.setValues(NSLocalizedString("Fechas de entrega disponibles",comment:""), values:self.dateSlot )
            self.picker!.cellType = TypeField.Check
            self.picker!.showPicker()
            self.view.endEditing(true)
            self.textFieldSelected = "Date"
        }
        viewDelivery!.addSubview(dateForm!)

        
        timeForm = FormFieldView(frame: CGRectMake(0, dateForm!.frame.maxY + 8, frame.width, 40))
        timeForm!.setCustomPlaceholder("Horarios disponibles")
        timeForm!.isRequired = true
        timeForm!.typeField = TypeField.List
        timeForm!.setImageTypeField()
        timeForm!.nameField = NSLocalizedString("Horarios disponibles", comment:"")
        timeForm!.onBecomeFirstResponder = { () in
            self.picker!.selected = self.selectedSlotIdx
            self.picker!.sender = self.timeForm
            self.picker!.selectOptionDelegate = self
            self.picker!.setValues(NSLocalizedString("Horarios disponibles",comment:""), values:self.timeSelect )
            self.picker!.cellType = TypeField.Check
            self.picker!.showPicker()
            self.textFieldSelected = "Time"
            self.view.endEditing(true)
        }
        viewDelivery!.addSubview(timeForm!)
        
        self.view.addSubview(viewDelivery!)
        self.removeViewLoad()

    
    }
    
    
    func save(){
        if validate(){
            let selectedSlotService = SelectedSlotService()
            let params = selectedSlotService.buildParams(self.selectTypeDelivery, selectedSlotId: self.slotSelected)
            selectedSlotService.callService(requestParams: params, succesBlock: { (result) -> Void in
                self.delegate?.selectDataTypeShipping(NSLocalizedString(self.selectTypeDelivery, comment: ""), util: "", date: self.dateForm!.text! , rowSelected: 1,idSolot: self.slotSelected)
                self.navigationController!.popViewControllerAnimated(true)
                }, errorBlock: { (error) -> Void in
                    
                    print("error guardando slot")
            })
        }
        
    }
    
    //MARK:  Invoke Services
    
    func invokeSloteService(type:String) {
        
        let service =  DisplaySlotsService()
         self.dateSlot =  []
        service.callService(requestParams: service.buildParamsHomeDelivery(type), succesBlock: { (responce:NSDictionary) in
            
            let slots =  responce["responseObject"] as! NSDictionary
            let key =  slots.allKeys.sort({ (first, second) -> Bool in
                let onne = first as! String
                let two = second as! String
                return onne < two
            })
            
            for keys in key{
                let horsSlot :NSMutableArray  = []
                let slot :NSMutableArray  = []
                let slotForDay = slots.objectForKey(keys) as! NSArray
                
                for daySlot in slotForDay {
                    
                    horsSlot.addObject(daySlot["deliveryTime"] as! String)
                    slot.addObject(daySlot["slotId"] as! String)
                    
                    let date  = daySlot["DeliveryDateCalendar.time"] as! NSDictionary
                    let dayDelivery  = "\(date.objectForKey("formattedDate") as! String)"
                    
                    if !self.dateSlot.contains(dayDelivery) {
                        self.dateSlot.append(dayDelivery)
                    }
                    
                }
                self.hourArray.addObject(horsSlot)
                self.slotArray.addObject(slot)
            }
            self.getAviableDates()
            print(self.hourArray)
            print(self.dateSlot)
            
            
            }, errorBlock: { (error:NSError) in
                print("Error al consultar el servicio \(error.localizedDescription)")
                
        })
        
    }
    
    
    func getAviableDates(){
        
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        
        var datearray : [String] = []
        var index =  0
        for dates in self.dateSlot {
            
            dateFmt.dateFormat = "dd/MM/yyyy"
            let dateform =  dateFmt.dateFromString(dates)
            dateFmt.dateFormat = "EEEE dd '\(NSLocalizedString("checkout.confirm.to", comment: ""))' MMMM"
            var stringDate = dateFmt.stringFromDate(dateform!).capitalizedString
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
            typeArray.append("Entre \(time.stringByReplacingOccurrencesOfString("-", withString: " y ").stringByReplacingOccurrencesOfString(":00 ", withString: " "))")
        }
        timeSelect = typeArray
    }

    //MARK: - AlertPickerSelectOptionDelegate
    
    var dateSelected = false
    var slotIsSelected =  false
    func didSelectOptionAtIndex(indexPath: NSIndexPath){
        
        if self.textFieldSelected == "Date" {
           dateForm?.text =   self.dateSlot[indexPath.row]
            let times  =  self.hourArray.objectAtIndex(indexPath.row) as! [String]
            timeSelect =  times
            self.getTimes()
            
            let slots  =  self.slotArray.objectAtIndex(indexPath.row) as! [String]
            groupSlotSelect = slots
            selectedDateIdx = indexPath
            dateSelected =  true
            self.dateForm!.layer.borderColor = UIColor.clearColor().CGColor
            self.errorView?.removeFromSuperview()
            self.errorView = nil
            
        }else{
            timeForm?.text = timeSelect[indexPath.row]
            slotSelected = groupSlotSelect[indexPath.row]
            selectedSlotIdx = indexPath
            slotIsSelected =  true
            self.timeForm!.layer.borderColor = UIColor.clearColor().CGColor
            self.errorView?.removeFromSuperview()
            self.errorView = nil
        }
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
    
 
    func validate() -> Bool{
        if !self.dateSelected  {
            return self.viewError(self.dateForm!,message: NSLocalizedString("Selecciona una fecha disponible",comment:""))
        }
        
        if !self.slotIsSelected {
            return self.viewError(self.timeForm!,message: "Selecciona un horario disponible")
        }
        
        return true
    }

    
    
    
    

}