//
//  ReminderViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 29/02/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

protocol ReminderViewControllerDelegate {
    func notifyReminderWillClose(forceValidation flag:Bool, value:Bool)
}

class ReminderViewController: NavigationViewController,CalendarViewDelegate, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate, AlertPickerSelectOptionDelegate{
    
    var listId: String?
    var listName: String?
    var currentOriginalFireDate: NSDate?
    var currentOriginalFireHour:Int! = 0
    var currentOriginalFireMin:Int! = 0
    var selectedPeriodicity: Int?
    var reminderService: ReminderNotificationService?
    var fmtDisplay: NSDateFormatter?
    var timeDisplay: NSDateFormatter?
    var alertView: IPOWMAlertViewController?
    var delegate: ReminderViewControllerDelegate?
    var frequencyLabel:UILabel?
    var dateLabel:UILabel?
    var hourLabel:UILabel?
    var frequencyField: FormFieldView?
    var dateField: FormFieldView?
    var hourField:FormFieldView?
    var deleteButton: UIButton?
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var modalView: AlertModalView?
    var timePicker: UIDatePicker?
    var content:TPKeyboardAvoidingScrollView?
    var errorView : FormFieldErrorView? = nil
    var picker : AlertPickerView!
    var alertController: IPOWMAlertViewController?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_REMINDER.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content!.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, self.view.bounds.height - (46))
        self.content!.delegate = self
        self.content!.scrollDelegate = self
        self.content!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.view.layer.insertSublayer(layerLine, atIndex: 1000)
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.fmtDisplay = NSDateFormatter()
        self.fmtDisplay!.dateFormat = "EEEE dd, MMMM"
        
        self.timeDisplay = NSDateFormatter()
        self.timeDisplay!.dateFormat = "HH:mm"
        
        self.titleLabel?.text = NSLocalizedString("list.reminder.title", comment:"")
        self.reminderService = ReminderNotificationService(listId: self.listId!, listName: self.listName!)
        self.reminderService?.findNotificationForCurrentList()
        self.deleteButton = UIButton()
        self.deleteButton!.setTitle("eliminar", forState: .Normal)
        self.deleteButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.deleteButton!.titleLabel?.font =  WMFont.fontMyriadProRegularOfSize(12)
        self.deleteButton!.addTarget(self, action: "deleteReminder", forControlEvents: UIControlEvents.TouchUpInside)
        self.deleteButton!.backgroundColor = WMColor.red
        self.deleteButton!.layer.cornerRadius = 11.0
        self.header!.addSubview(deleteButton!)
        
        self.frequencyLabel = UILabel()
        self.frequencyLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.frequencyLabel?.textColor = WMColor.light_light_blue
        self.frequencyLabel?.textAlignment = .Left
        self.frequencyLabel?.text = "Frecuencia del recordatorio"
        self.content!.addSubview(self.frequencyLabel!)
        
        self.dateLabel = UILabel()
        self.dateLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.dateLabel?.textColor = WMColor.light_light_blue
        self.dateLabel?.textAlignment = .Left
        self.dateLabel?.text = "Fecha de inicio"
        self.content!.addSubview(self.dateLabel!)
        
        self.hourLabel = UILabel()
        self.hourLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.hourLabel?.textColor = WMColor.light_light_blue
        self.hourLabel?.textAlignment = .Left
        self.hourLabel?.text = "Horario"
        self.content!.addSubview(self.hourLabel!)
        
        self.frequencyField = FormFieldView(frame: CGRectMake(16, self.frequencyLabel!.frame.maxY + 8,  self.view.frame.width - 32, 40))
        self.frequencyField!.isRequired = true
        self.frequencyField!.setCustomPlaceholder("Semanal")
        self.frequencyField!.typeField = TypeField.List
        self.frequencyField!.setImageTypeField()
        self.frequencyField!.nameField = "Frecuencia del recordatorio"
        self.frequencyField!.minLength = 3
        self.frequencyField!.maxLength = 25
        self.content!.addSubview(self.frequencyField!)
        
        self.dateField = FormFieldView(frame:CGRectMake(16, self.dateLabel!.frame.maxY + 8,  self.view.frame.width - 32, 40))
        self.dateField!.isRequired = true
        self.dateField!.setCustomPlaceholder("Fecha")
        self.dateField!.typeField = TypeField.List
        self.dateField!.setImageTypeField()
        self.dateField!.nameField = "Fecha de inicio"
        self.dateField!.minLength = 3
        self.dateField!.maxLength = 25
        self.content!.addSubview(self.dateField!)
        
        self.hourField = FormFieldView(frame:CGRectMake(16, self.hourLabel!.frame.maxY + 8,  self.view.frame.width - 32, 40))
        self.hourField!.isRequired = true
        self.hourField!.setCustomPlaceholder("Hora")
        self.hourField!.typeField = TypeField.List
        self.hourField!.setImageTypeField()
        self.hourField!.nameField = "Horario"
        self.hourField!.minLength = 3
        self.hourField!.maxLength = 25
        self.hourField!.disablePaste = true
        self.content!.addSubview(self.hourField!)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Guardar", forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: "save", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(saveButton!)
    
        
        if !self.reminderService!.existNotificationForCurrentList(){
            self.deleteButton!.hidden = true
        }else{
            self.deleteButton!.hidden = false
            self.frequencyField?.text = self.reminderService!.options[self.selectedPeriodicity!]
            self.dateField?.text = self.fmtDisplay!.stringFromDate(self.currentOriginalFireDate!).capitalizedString
            self.hourField?.text = self.timeDisplay!.stringFromDate(self.currentOriginalFireDate!)
        }
        
        self.picker = AlertPickerView.initPickerWithDefaultCancelButton()
        
        self.frequencyField?.onBecomeFirstResponder = { () in
            self.picker!.selected = NSIndexPath(forRow: self.selectedPeriodicity ?? 0, inSection: 0)
            self.picker!.sender = self.frequencyField!
            self.picker!.selectOptionDelegate = self
            self.picker!.setValues("Frecuencia del recordatorio", values: self.reminderService!.options)
            self.picker!.hiddenRigthActionButton(true)
            self.picker!.cellType = TypeField.Check
            self.picker!.showPicker()

        }
        
        self.dateField?.onBecomeFirstResponder = { () in
            let calendarView = CalendarView(frame: CGRectMake(0, 0,  288, 434))
            calendarView.delegate = self
            if self.reminderService!.existNotificationForCurrentList(){
               calendarView.originalDate = self.currentOriginalFireDate
               calendarView.notificationType = self.selectedPeriodicity
            }
            self.modalView = AlertModalView.initModalWithView("Fecha de inicio",innerView: calendarView)
            self.modalView!.showPicker()
        }
        
        self.timePicker = UIDatePicker()
        self.timePicker!.datePickerMode = .Time
        self.timePicker!.locale = NSLocale(localeIdentifier: "da_DK")
        self.timePicker!.minuteInterval = 15
        self.timePicker!.date = NSDate()
        self.timePicker!.addTarget(self, action: "timeChanged", forControlEvents: .ValueChanged)
        self.hourField!.inputView = self.timePicker!
        
        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, self.view.frame.width , 44),
            inputViewStyle: .Keyboard,
            titleSave: "Ok",
            save: { (field:UITextField?) -> Void in
                field?.resignFirstResponder()
                if field != nil {
                    if field!.text == nil || field!.text!.isEmpty {
                        self.timeChanged()
                    }
                }
        })
        self.hourField!.inputAccessoryView = viewAccess
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.deleteButton!.frame = CGRectMake(self.header!.frame.width - 80, 12, 65, 22)
        self.frequencyLabel!.frame = CGRectMake(16, 16,  self.view.frame.width - 32, 20)
        self.frequencyField!.frame = CGRectMake(16, self.frequencyLabel!.frame.maxY + 8,  self.view.frame.width - 32, 40)
        self.dateLabel!.frame = CGRectMake(16, self.frequencyField!.frame.maxY + 16,  self.view.frame.width - 32, 20)
        self.dateField!.frame = CGRectMake(16, self.dateLabel!.frame.maxY + 8,  self.view.frame.width - 32, 40)
        self.hourLabel!.frame = CGRectMake(16, self.dateField!.frame.maxY + 16,  self.view.frame.width - 32, 20)
        self.hourField!.frame = CGRectMake(16, self.hourLabel!.frame.maxY + 8,  self.view.frame.width - 32, 40)
        self.content!.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, self.view.bounds.height)
        self.layerLine.frame = CGRectMake(0, self.hourField!.frame.maxY + 94,  self.view.frame.width, 1)
        self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148,self.layerLine.frame.maxY + 16, 140, 34)
        self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.layerLine.frame.maxY + 16, 140, 34)
    }
    
    override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return !IS_IPAD
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if IS_IPAD{
            self.beginAppearanceTransition(true, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.hourField!.setImageTypeField()
        self.dateField!.setImageTypeField()
        self.frequencyField!.setImageTypeField()
        
        if IS_IPAD{
            self.endAppearanceTransition()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if IS_IPAD{
            self.beginAppearanceTransition(false, animated: true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if IS_IPAD{
            self.endAppearanceTransition()
        }
    }
    
    override func back() {
        self.delegate?.notifyReminderWillClose(forceValidation: true, value: false)
        if IS_IPAD{
            UIView.animateWithDuration(0.4, delay: 0.1, options: [], animations: {
                self.view.frame = CGRectMake(self.view.bounds.maxX, 0.0, self.view.bounds.width, self.view.bounds.height)
                }, completion: {(finish) in
                    self.willMoveToParentViewController(nil)
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
            })
            return
        }
        super.back()
    }
    
    func deleteReminder(){
        self.alertController = IPOWMAlertViewController.showAlert(UIImage(named: "reminder_alert"), imageDone: UIImage(named: "done"), imageError: UIImage(named: "reminder_alert"))
        self.alertController!.setMessage("Eliminando recordatorio ...")
        let delaySec:Double = IS_IPAD ? 2.0 : 1.0
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySec * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.reminderService!.removeNotificationsFromCurrentList()
            self.delegate?.notifyReminderWillClose(forceValidation: true, value: false)
            self.alertController!.setMessage("Recordatorio eliminado")
            self.alertController!.showDoneIcon()
            if IS_IPAD{
                self.willMoveToParentViewController(nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }else{
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    func save(){
        if self.validateReminderForm(){
            self.alertController = IPOWMAlertViewController.showAlert(UIImage(named: "reminder_alert"), imageDone: UIImage(named: "done"), imageError: UIImage(named: "reminder_alert"))
            self.alertController!.setMessage("Guardando recordatorio ...")
            let delaySec:Double = IS_IPAD ? 2.0 : 1.0
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySec * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                if self.reminderService!.existNotificationForCurrentList(){
                    self.reminderService!.removeNotificationsFromCurrentList()
                }
                self.reminderService?.scheduleNotifications(forOption: self.selectedPeriodicity!, withDate: self.currentOriginalFireDate!, forTime:self.hourField!.text!)
                self.delegate?.notifyReminderWillClose(forceValidation: true, value: true)
                self.alertController!.setMessage("Te recordatorio se ha guardado.")
                self.alertController!.showDoneIcon()
                if IS_IPAD{
                    self.willMoveToParentViewController(nil)
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
                }else{
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }
    
    func timeChanged(){
        if self.errorView != nil{
            self.errorView!.removeFromSuperview()
            self.errorView!.focusError = nil
            self.errorView = nil
        }
        let date = self.timePicker!.date
        let dateString = self.timeDisplay!.stringFromDate(date)
        let timeArray = dateString.componentsSeparatedByString(":")
        self.currentOriginalFireHour = Int(timeArray.first!)
        self.currentOriginalFireMin = Int(timeArray.last!)
        let minInterval = abs((self.currentOriginalFireMin % 15) - self.currentOriginalFireMin)
        let minString = minInterval == 0 ? "00" : "\(minInterval)"
        self.hourField!.text = "\(self.currentOriginalFireHour):\(minString)"
        let fireDate = self.currentOriginalFireDate ?? NSDate()
        self.currentOriginalFireDate = self.reminderService!.createDateFrom(fireDate, forHour: self.currentOriginalFireHour, andMinute: self.currentOriginalFireMin)
        //self.selectedDate = date
    }
    
    func validateReminderForm() -> Bool{
        var field = FormFieldView()
        var message = ""
        let frequencyMessage = self.frequencyField!.validate()
        let timeMessage = self.hourField!.validate()
        if #available(iOS 8.0, *) {
            let compare = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: self.currentOriginalFireDate!,
                toUnitGranularity: .Second)
            if  compare != NSComparisonResult.OrderedAscending {
                field = hourField!
                message = "Selecciona una hora superior a la actual"
            }
        } else {
            if NSDate().compare(self.currentOriginalFireDate!) != NSComparisonResult.OrderedAscending {
                    field = hourField!
                    message = "Selecciona una hora superior a la actual"
            }
        }
        if !hourField!.isValid
        {
            field = hourField!
            message = timeMessage!
        }
        let dateMessage = self.dateField!.validate()
        if !dateField!.isValid
        {
            field = dateField!
            message = dateMessage!
        }
        if !frequencyField!.isValid
        {
            field = frequencyField!
            message = frequencyMessage!
        }
        if message.characters.count > 0 {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field,  nameField:field.nameField ,  message: message ,errorView:self.errorView!,  becomeFirstResponder: false )
            return false
        }
        return true
    }
    
    //MARK: -CalendarViewDelegate
    func selectedDate(date: NSDate?) {
        if self.errorView != nil{
            self.errorView!.removeFromSuperview()
            self.errorView!.focusError = nil
            self.errorView = nil
        }
       self.modalView?.closePicker()
        if date != nil{
            self.currentOriginalFireDate = self.reminderService!.createDateFrom(date!, forHour: self.currentOriginalFireHour, andMinute: self.currentOriginalFireMin)
            self.dateField?.text = self.fmtDisplay!.stringFromDate(self.currentOriginalFireDate!).capitalizedString
            self.dateField?.layer.borderWidth = 0
        }
    }
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        return CGSizeMake(self.view.frame.width, self.content!.contentSize.height)
    }
    
    //MARK: - AlertPickerSelectOptionDelegate
    func didSelectOptionAtIndex(indexPath: NSIndexPath){
        if self.errorView != nil{
            self.errorView!.removeFromSuperview()
            self.errorView!.focusError = nil
            self.errorView = nil
        }
        self.selectedPeriodicity = indexPath.row
        self.frequencyField?.text = self.reminderService!.options[indexPath.row]
        self.frequencyField?.layer.borderWidth = 0
    }
}