//
//  CalendarView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 02/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

protocol CalendarViewDelegate{
    func selectedDate(_ date:Date?)
}

class CalendarView: UIView,ABCalendarPickerDelegateProtocol, ABCalendarPickerDataSourceProtocol{
     var calendar: ABCalendarPicker?
     var alertView:IPOWMAlertViewController?
     var delegate:CalendarViewDelegate?
     var originalDate: Date?
     var selectedDate: Date?
     var saveButton: UIButton?
     var cancelButton: UIButton?
     var layerLine: CALayer!
     var notificationType: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
     func setup() {
        //ABCalendarPickerStateDays
        self.calendar = ABCalendarPicker(frame: CGRect(x: 0.0, y: 46.0, width: 288, height: 300), andState: ABCalendarPickerStateDays, andDelegate: self, andDataSource:self)
        self.calendar!.backgroundColor = UIColor.white
        self.calendar!.bottomExpanding = true
        self.addSubview(self.calendar!)
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(CalendarView.cancel), for: UIControlEvents.touchUpInside)
        self.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Guardar", for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(CalendarView.save), for: UIControlEvents.touchUpInside)
        self.addSubview(saveButton!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(layerLine, at: 0)
    }
    
    override func layoutSubviews() {
        self.calendar!.frame = CGRect(x: 0.0, y: 46.0,width: 288, height: 300)
        self.layerLine.frame = CGRect(x: 0,  y: self.calendar!.frame.maxY + 24,  width: self.frame.width, height: 1)
        self.cancelButton!.frame = CGRect(x: 16, y: self.layerLine.frame.maxY + 16, width: 125, height: 34)
        self.saveButton!.frame = CGRect(  x: self.frame.width - 141 , y: self.layerLine.frame.maxY + 16, width: 125, height: 34)
    }
    
    // MARK: - ABCalendarPickerDataSourceProtocol
    func calendarPicker(_ calendarPicker: ABCalendarPicker!, numberOfEventsFor date: Date!, on state: ABCalendarPickerState) -> Int {
        if self.originalDate != nil {
            let timeDisplay = DateFormatter()
            timeDisplay.dateFormat = "HH:mm"
            let originalDateHour = timeDisplay.string(from: self.originalDate!)
            let hourArray = originalDateHour.components(separatedBy: ":")
            let closedDate = self.createDateFrom(date, forHour: Int(hourArray.first!)!, andMinute: Int(hourArray.last!)!)
            let compareResult = closedDate!.compare(self.originalDate!)
            if compareResult == ComparisonResult.orderedSame {
                return 1
            }
            else if compareResult == ComparisonResult.orderedDescending {
                switch(self.notificationType!) {
                    case 1 :
                        if self.isDate(closedDate!, partOfIntervalOfDays: 7, fromDate: self.originalDate!) {
                            return 1
                        }
                    case 2 :
                        if self.isDate(closedDate!, partOfIntervalOfDays: 14, fromDate: self.originalDate!) {
                            return 1
                        }
                    case 3 :
                        if self.isDate(closedDate!, partOfIntervalOfDays: 21, fromDate: self.originalDate!) {
                            return 1
                        }
                    case 4 :
                        let calendar = Calendar(identifier: NSGregorianCalendar)
                        //calendar.timeZone = NSTimeZone(abbreviation: "UTC")
                        calendar!.timeZone = TimeZone.autoupdatingCurrent
                        let closedDateComponents = (calendar! as NSCalendar).components([NSCalendar.Unit.year , NSCalendar.Unit.month , NSCalendar.Unit.day], from: closedDate!)
                        let dayRangeClosedDate = (calendar! as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: closedDate!)
                        //print("month:\(closedDateComponents.month) days:\(dayRangeClosedDate.length)")
                        
                        let originalDateComponents = (calendar! as NSCalendar).components([NSCalendar.Unit.year , NSCalendar.Unit.month , NSCalendar.Unit.day], from: self.originalDate!)
                        let originalRangeClosedDate = (calendar! as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: self.originalDate!)
                        //this day is last of month
                        
                        if closedDateComponents.day == originalDateComponents.day {
                            return 1
                        }
                        
                        if closedDateComponents.day == dayRangeClosedDate.length && originalDateComponents.day == originalRangeClosedDate.length {
                            return 1
                        }
                        
                        if originalDateComponents.day == originalRangeClosedDate.length && originalDateComponents.day < dayRangeClosedDate.length {
                            return 1
                        }
                        
                        if closedDateComponents.day == dayRangeClosedDate.length && originalDateComponents.day > dayRangeClosedDate.length {
                            return 1
                        }
                        
                        return 0
                    default :
                        
                        break
                        
                }
            }
        }
        return 0
    }
    
    /**
     Validates a range of days between two dates
     
     - parameter theDate:  First date
     - parameter days:     Days to compare
     - parameter fromDate: Second date
     
     - returns: Bool returns true if the difference of days between the dates is equals to days parameter
     */
    func isDate(_ theDate:Date, partOfIntervalOfDays days:Int, fromDate:Date) -> Bool {
        let calendar = Calendar(identifier: NSGregorianCalendar)
        //calendar.timeZone = NSTimeZone(abbreviation: "UTC")
        calendar!.timeZone = TimeZone.autoupdatingCurrent
        let components = (calendar! as NSCalendar).components(NSCalendar.Unit.day, from: fromDate, to: theDate, options: [])
        return components.day % days == 0
    }
    
    // MARK: - ABCalendarPickerDelegateProtocol
    func calendarPickerHeight(forHeader calendarPicker: ABCalendarPicker!) -> CGFloat {
        return 37
    }
    
    func calendarPickerHeight(forColumnHeader calendarPicker: ABCalendarPicker!) -> CGFloat {
        return 37
    }
    
    func calendarPicker(_ calendarPicker: ABCalendarPicker!, animateNewHeight height: CGFloat) {
        
    }
    
    func calendarPicker(_ calendarPicker: ABCalendarPicker!, shouldSetState state: ABCalendarPickerState, from fromState: ABCalendarPickerState) -> Bool {
        return state.rawValue == ABCalendarPickerStateDays.rawValue
    }
    
    
    func calendarPicker(_ calendarPicker: ABCalendarPicker!, willAnimateWith animation: ABCalendarPickerAnimation) {
    }
    
    func calendarPicker(_ calendarPicker: ABCalendarPicker!, dateSelected date: Date!, with state: ABCalendarPickerState) {
        let theDate = self.createDateFrom(date, forHour: 0, andMinute: 0)
        let today = self.createDateFrom(Date(), forHour: 0, andMinute: 0)
       
       
       if theDate!.compare(today!) == ComparisonResult.orderedAscending {
            let text = NSLocalizedString("list.reminder.notification.validationDate",comment:"")
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(text)
            self.alertView!.showErrorIcon("Aceptar")
            calendarPicker.setHighlightedAndSectedDate(Date(), animated: true)
            return
        }
        
        self.selectedDate = date
    }
    
    /**
     Add hours and minutes to a date
     
     - parameter date:   date
     - parameter hour:   hours to add
     - parameter minute: minutes to add
     
     - returns: NSDate with date, hours and minutes
     */
    func createDateFrom(_ date:Date, forHour hour:Int, andMinute minute:Int) -> Date? {
        let calendar = Calendar(identifier: NSGregorianCalendar)
        //calendar.timeZone = NSTimeZone(abbreviation: "UTC")
        calendar!.timeZone = TimeZone.autoupdatingCurrent
        let components = (calendar! as NSCalendar).components([NSCalendar.Unit.year , NSCalendar.Unit.month , NSCalendar.Unit.day], from: date)
        components.second = 00
        components.minute = minute
        components.hour = hour
        let otherDate = calendar!.date(from: components)
        return otherDate
    }
    
    /**
     Calls the delegate with the selected date
     */
    func save(){
        self.delegate?.selectedDate(self.selectedDate)
    }
    
    /**
     Calls the delegate with the original date
     */
    func cancel(){
        self.delegate?.selectedDate(self.originalDate)
    }
}
