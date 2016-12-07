//
//  ReminderViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 29/02/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

protocol ReminderViewControllerDelegate {
    /**
     Notify than the reminder is created
     
     - parameter flag:  indicates if is necesary to force the validation 
     - parameter value: indicates if the reminder was created or not
     */
    func notifyReminderWillClose(forceValidation flag:Bool, value:Bool)
}

class ReminderViewController: NavigationViewController,CalendarViewDelegate, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate, AlertPickerSelectOptionDelegate{
    
    var listId: String?
    var listName: String?
    var currentOriginalFireDate: Date?
    var currentOriginalFireHour:Int! = 0
    var currentOriginalFireMin:Int! = 0
    var selectedPeriodicity: Int?
    var reminderService: ReminderNotificationService?
    var fmtDisplay: DateFormatter?
    var timeDisplay: DateFormatter?
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
        self.content!.frame = CGRect(x: 0.0, y: 46.0, width: self.view.bounds.width, height: self.view.bounds.height - (46))
        self.content!.delegate = self
        self.content!.scrollDelegate = self
        self.content!.backgroundColor = UIColor.white
        self.view.addSubview(self.content!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.view.layer.insertSublayer(layerLine, at: 1000)
        
        self.view.backgroundColor = UIColor.white
        self.fmtDisplay = DateFormatter()
        self.fmtDisplay!.dateFormat = "EEEE dd, MMMM"
        
        self.timeDisplay = DateFormatter()
        self.timeDisplay!.dateFormat = "HH:mm"
        
        self.titleLabel?.text = NSLocalizedString("list.reminder.title", comment:"")
        self.reminderService = ReminderNotificationService(listId: self.listId!, listName: self.listName!)
        self.reminderService?.findNotificationForCurrentList()
        self.deleteButton = UIButton()
        self.deleteButton!.setTitle("eliminar", for: UIControlState())
        self.deleteButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.deleteButton!.titleLabel?.font =  WMFont.fontMyriadProRegularOfSize(12)
        self.deleteButton!.addTarget(self, action: #selector(ReminderViewController.deleteReminder), for: UIControlEvents.touchUpInside)
        self.deleteButton!.backgroundColor = WMColor.red
        self.deleteButton!.layer.cornerRadius = 11.0
        self.header!.addSubview(deleteButton!)
        
        self.frequencyLabel = UILabel()
        self.frequencyLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.frequencyLabel?.textColor = WMColor.light_light_blue
        self.frequencyLabel?.textAlignment = .left
        self.frequencyLabel?.text = "Frecuencia del recordatorio"
        self.content!.addSubview(self.frequencyLabel!)
        
        self.dateLabel = UILabel()
        self.dateLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.dateLabel?.textColor = WMColor.light_light_blue
        self.dateLabel?.textAlignment = .left
        self.dateLabel?.text = "Fecha de inicio"
        self.content!.addSubview(self.dateLabel!)
        
        self.hourLabel = UILabel()
        self.hourLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.hourLabel?.textColor = WMColor.light_light_blue
        self.hourLabel?.textAlignment = .left
        self.hourLabel?.text = "Horario"
        self.content!.addSubview(self.hourLabel!)
        
        self.frequencyField = FormFieldView(frame: CGRect(x: 16, y: self.frequencyLabel!.frame.maxY + 8,  width: self.view.frame.width - 32, height: 40))
        self.frequencyField!.isRequired = true
        self.frequencyField!.setCustomPlaceholder("Semanal")
        self.frequencyField!.typeField = TypeField.list
        self.frequencyField!.setImageTypeField()
        self.frequencyField!.nameField = "Frecuencia del recordatorio"
        self.frequencyField!.minLength = 3
        self.frequencyField!.maxLength = 25
        self.content!.addSubview(self.frequencyField!)
        
        self.dateField = FormFieldView(frame:CGRect(x: 16, y: self.dateLabel!.frame.maxY + 8,  width: self.view.frame.width - 32, height: 40))
        self.dateField!.isRequired = true
        self.dateField!.setCustomPlaceholder("Fecha")
        self.dateField!.typeField = TypeField.list
        self.dateField!.setImageTypeField()
        self.dateField!.nameField = "Fecha de inicio"
        self.dateField!.minLength = 3
        self.dateField!.maxLength = 25
        self.content!.addSubview(self.dateField!)
        
        self.hourField = FormFieldView(frame:CGRect(x: 16, y: self.hourLabel!.frame.maxY + 8,  width: self.view.frame.width - 32, height: 40))
        self.hourField!.isRequired = true
        self.hourField!.setCustomPlaceholder("Hora")
        self.hourField!.typeField = TypeField.list
        self.hourField!.setImageTypeField()
        self.hourField!.nameField = "Horario"
        self.hourField!.minLength = 3
        self.hourField!.maxLength = 25
        self.hourField!.disablePaste = true
        self.content!.addSubview(self.hourField!)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Guardar", for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(ReminderViewController.save), for: UIControlEvents.touchUpInside)
        self.view.addSubview(saveButton!)
    
        
        if !self.reminderService!.existNotificationForCurrentList(){
            self.deleteButton!.isHidden = true
        }else{
            self.deleteButton!.isHidden = false
            self.frequencyField?.text = self.reminderService!.options[self.selectedPeriodicity!]
            self.dateField?.text = self.fmtDisplay!.string(from: self.currentOriginalFireDate!).capitalized
            self.hourField?.text = self.timeDisplay!.string(from: self.currentOriginalFireDate!)
        }
        
        self.picker = AlertPickerView.initPickerWithDefaultCancelButton()
        
        self.frequencyField?.onBecomeFirstResponder = { () in
            self.picker!.selected = IndexPath(row: self.selectedPeriodicity ?? 0, section: 0)
            self.picker!.sender = self.frequencyField!
            self.picker!.selectOptionDelegate = self
            self.picker!.setValues("Frecuencia del recordatorio", values: self.reminderService!.options)
            self.picker!.hiddenRigthActionButton(true)
            self.picker!.cellType = TypeField.check
            self.picker!.showPicker()

        }
        
        self.dateField?.onBecomeFirstResponder = { () in
            let calendarView = CalendarView(frame: CGRect(x: 0, y: 0,  width: 288, height: 434))
            calendarView.delegate = self
            if self.reminderService!.existNotificationForCurrentList(){
               calendarView.originalDate = self.currentOriginalFireDate
               calendarView.notificationType = self.selectedPeriodicity
            }
            self.modalView = AlertModalView.initModalWithView("Fecha de inicio",innerView: calendarView)
            self.modalView!.showPicker()
        }
        
        self.timePicker = UIDatePicker()
        self.timePicker!.datePickerMode = .time
        self.timePicker!.locale = Locale(identifier: "da_DK")
        self.timePicker!.minuteInterval = 15
        self.timePicker!.date = Date()
        self.timePicker!.addTarget(self, action: #selector(ReminderViewController.timeChanged), for: .valueChanged)
        self.hourField!.inputView = self.timePicker!
        
        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width , height: 44),
            inputViewStyle: .keyboard,
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
        let lineHeight: CGFloat = TabBarHidden.isTabBarHidden ? 67 : 113
        self.deleteButton!.frame = CGRect(x: self.header!.frame.width - 80, y: 12, width: 65, height: 22)
        self.frequencyLabel!.frame = CGRect(x: 16, y: 16,  width: self.view.frame.width - 32, height: 20)
        self.frequencyField!.frame = CGRect(x: 16, y: self.frequencyLabel!.frame.maxY + 8,  width: self.view.frame.width - 32, height: 40)
        self.dateLabel!.frame = CGRect(x: 16, y: self.frequencyField!.frame.maxY + 16,  width: self.view.frame.width - 32, height: 20)
        self.dateField!.frame = CGRect(x: 16, y: self.dateLabel!.frame.maxY + 8,  width: self.view.frame.width - 32, height: 40)
        self.hourLabel!.frame = CGRect(x: 16, y: self.dateField!.frame.maxY + 16,  width: self.view.frame.width - 32, height: 20)
        self.hourField!.frame = CGRect(x: 16, y: self.hourLabel!.frame.maxY + 8,  width: self.view.frame.width - 32, height: 40)
        self.content!.frame = CGRect(x: 0.0, y: 46.0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.layerLine.frame = CGRect(x: 0, y: self.view.frame.height - lineHeight,  width: self.view.frame.width, height: 1)
        self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148,y: self.layerLine.frame.maxY + 16, width: 140, height: 34)
        self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.layerLine.frame.maxY + 16, width: 140, height: 34)
    }
    
    override var shouldAutomaticallyForwardAppearanceMethods : Bool {
        return !IS_IPAD
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if IS_IPAD{
            self.beginAppearanceTransition(true, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.hourField!.setImageTypeField()
        self.dateField!.setImageTypeField()
        self.frequencyField!.setImageTypeField()
        
        if IS_IPAD{
            self.endAppearanceTransition()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if IS_IPAD{
            self.beginAppearanceTransition(false, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if IS_IPAD{
            self.endAppearanceTransition()
        }
    }
    
    override func back() {
        self.delegate?.notifyReminderWillClose(forceValidation: true, value: false)
        if IS_IPAD{
            UIView.animate(withDuration: 0.4, delay: 0.1, options: [], animations: {
                self.view.frame = CGRect(x: self.view.bounds.maxX, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
                }, completion: {(finish) in
                    self.willMove(toParentViewController: nil)
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
            })
            return
        }
        super.back()
    }
    
    /**
     Delete reminders from the current list
     */
    func deleteReminder(){
        self.alertController = IPOWMAlertViewController.showAlert(UIImage(named: "reminder_alert"), imageDone: UIImage(named: "done"), imageError: UIImage(named: "reminder_alert"))
        self.alertController!.setMessage("Eliminando recordatorio ...")
        let delaySec:Double = IS_IPAD ? 2.0 : 1.0
        let delayTime = DispatchTime.now() + Double(Int64(delaySec * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.reminderService!.removeNotificationsFromCurrentList()
            self.delegate?.notifyReminderWillClose(forceValidation: true, value: false)
            self.alertController!.setMessage("Recordatorio eliminado")
            self.alertController!.showDoneIcon()
            if IS_IPAD{
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }else{
                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    /**
     Creates new reminders with the form data
     */
    func save(){
        if self.validateReminderForm(){
            self.alertController = IPOWMAlertViewController.showAlert(UIImage(named: "reminder_alert"), imageDone: UIImage(named: "done"), imageError: UIImage(named: "reminder_alert"))
            self.alertController!.setMessage("Guardando recordatorio ...")
            let delaySec:Double = IS_IPAD ? 2.0 : 1.0
            let delayTime = DispatchTime.now() + Double(Int64(delaySec * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                if self.reminderService!.existNotificationForCurrentList(){
                    self.reminderService!.removeNotificationsFromCurrentList()
                }
                self.reminderService?.scheduleNotifications(forOption: self.selectedPeriodicity!, withDate: self.currentOriginalFireDate!, forTime:self.hourField!.text!)
                self.delegate?.notifyReminderWillClose(forceValidation: true, value: true)
                self.alertController!.setMessage("Tu recordatorio se ha guardado.")
                self.alertController!.showDoneIcon()
                if IS_IPAD{
                    self.willMove(toParentViewController: nil)
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
                }else{
                    let _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    /**
     Validates the hour for the reminder (Every 15 min)
     */
    func timeChanged(){
        if self.errorView != nil{
            self.errorView!.removeFromSuperview()
            self.errorView!.focusError = nil
            self.errorView = nil
        }
        let date = self.timePicker!.date
        let dateString = self.timeDisplay!.string(from: date)
        let timeArray = dateString.components(separatedBy: ":")
        self.currentOriginalFireHour = Int(timeArray.first!)
        self.currentOriginalFireMin = Int(timeArray.last!)
        let minInterval = abs((self.currentOriginalFireMin % 15) - self.currentOriginalFireMin)
        let minString = minInterval == 0 ? "00" : "\(minInterval)"
        self.hourField!.text = "\(self.currentOriginalFireHour!):\(minString)"
        let fireDate = self.currentOriginalFireDate ?? Date()
        self.currentOriginalFireDate = self.reminderService!.createDateFrom(fireDate, forHour: self.currentOriginalFireHour, andMinute: self.currentOriginalFireMin)
        //self.selectedDate = date
    }
    /**
     Validates reminder form data
     
     - returns: Bool returns true if the data is valid and complete
     */
    func validateReminderForm() -> Bool{
        var field = FormFieldView()
        var message = ""
        let frequencyMessage = self.frequencyField!.validate()
        let timeMessage = self.hourField!.validate()
        self.currentOriginalFireDate = self.currentOriginalFireDate ?? Date()
        let compare = (Calendar.current as NSCalendar).compare(Date(), to: self.currentOriginalFireDate!,
                toUnitGranularity: .second)
        if  compare != ComparisonResult.orderedAscending {
            field = hourField!
            message = "Selecciona una hora superior a la actual"
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
    func selectedDate(_ date: Date?) {
        if self.errorView != nil{
            self.errorView!.removeFromSuperview()
            self.errorView!.focusError = nil
            self.errorView = nil
        }
       self.modalView?.closePicker()
        if date != nil{
            self.currentOriginalFireDate = self.reminderService!.createDateFrom(date!, forHour: self.currentOriginalFireHour, andMinute: self.currentOriginalFireMin)
            self.dateField?.text = self.fmtDisplay!.string(from: self.currentOriginalFireDate!).capitalized
            self.dateField?.layer.borderWidth = 0
        }
    }
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    func contentSizeForScrollView(_ sender:Any) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.content!.contentSize.height)
    }
    
    //MARK: - AlertPickerSelectOptionDelegate
    func didSelectOptionAtIndex(_ indexPath: IndexPath){
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
