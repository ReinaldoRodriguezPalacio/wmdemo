//
//  CalendarView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 02/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

protocol CalendarViewDelegate{
    func selectedDate(date:NSDate?)
}

class CalendarView: UIView,ABCalendarPickerDelegateProtocol, ABCalendarPickerDataSourceProtocol{
     var calendar: ABCalendarPicker?
     var alertView:IPOWMAlertViewController?
     var delegate:CalendarViewDelegate?
     var originalDate: NSDate?
     var selectedDate: NSDate?
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
        self.calendar = ABCalendarPicker(frame: CGRectMake(0.0, 46.0, 288, 300), andState: ABCalendarPickerStateDays, andDelegate: self, andDataSource:self)
        self.calendar!.backgroundColor = UIColor.whiteColor()
        self.calendar!.bottomExpanding = true
        self.addSubview(self.calendar!)
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: "cancel", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Guardar", forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: "save", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(saveButton!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.layer.insertSublayer(layerLine, atIndex: 0)
    }
    
    override func layoutSubviews() {
        self.calendar!.frame = CGRectMake(0.0, 46.0,288, 300)
        self.layerLine.frame = CGRectMake(0,  self.calendar!.frame.maxY + 24,  self.frame.width, 1)
        self.cancelButton!.frame = CGRectMake(16, self.calendar!.frame.maxY + 43, 125, 34)
        self.saveButton!.frame = CGRectMake(  self.frame.width - 141 , self.calendar!.frame.maxY + 43, 125, 34)
    }
    
    // MARK: - ABCalendarPickerDataSourceProtocol
    func calendarPicker(calendarPicker: ABCalendarPicker!, numberOfEventsForDate date: NSDate!, onState state: ABCalendarPickerState) -> Int {
        if self.originalDate != nil {
            let timeDisplay = NSDateFormatter()
            timeDisplay.dateFormat = "HH:mm"
            let originalDateHour = timeDisplay.stringFromDate(self.originalDate!)
            let hourArray = originalDateHour.componentsSeparatedByString(":")
            let closedDate = self.createDateFrom(date, forHour: Int(hourArray.first!)!, andMinute: Int(hourArray.last!)!)
            let compareResult = closedDate!.compare(self.originalDate!)
            if compareResult == NSComparisonResult.OrderedSame {
                return 1
            }
            else if compareResult == NSComparisonResult.OrderedDescending {
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
                        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
                        //calendar.timeZone = NSTimeZone(abbreviation: "UTC")
                        calendar!.timeZone = NSTimeZone.localTimeZone()
                        let closedDateComponents = calendar!.components([NSCalendarUnit.Year , NSCalendarUnit.Month , NSCalendarUnit.Day], fromDate: closedDate!)
                        let dayRangeClosedDate = calendar!.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: closedDate!)
                        //print("month:\(closedDateComponents.month) days:\(dayRangeClosedDate.length)")
                        
                        let originalDateComponents = calendar!.components([NSCalendarUnit.Year , NSCalendarUnit.Month , NSCalendarUnit.Day], fromDate: self.originalDate!)
                        let originalRangeClosedDate = calendar!.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: self.originalDate!)
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
    
    func isDate(theDate:NSDate, partOfIntervalOfDays days:Int, fromDate:NSDate) -> Bool {
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        //calendar.timeZone = NSTimeZone(abbreviation: "UTC")
        calendar!.timeZone = NSTimeZone.localTimeZone()
        let components = calendar!.components(NSCalendarUnit.Day, fromDate: fromDate, toDate: theDate, options: [])
        return components.day % days == 0
    }
    
    // MARK: - ABCalendarPickerDelegateProtocol
    func calendarPickerHeightForHeader(calendarPicker: ABCalendarPicker!) -> CGFloat {
        return 50
    }
    
    func calendarPickerHeightForColumnHeader(calendarPicker: ABCalendarPicker!) -> CGFloat {
        return 50
    }
    
    func calendarPicker(calendarPicker: ABCalendarPicker!, animateNewHeight height: CGFloat) {
        
    }
    
    func calendarPicker(calendarPicker: ABCalendarPicker!, shouldSetState state: ABCalendarPickerState, fromState: ABCalendarPickerState) -> Bool {
        
        return state.rawValue == ABCalendarPickerStateDays.rawValue
    }
    
    
    func calendarPicker(calendarPicker: ABCalendarPicker!, willAnimateWith animation: ABCalendarPickerAnimation) {
    }
    
    func calendarPicker(calendarPicker: ABCalendarPicker!, dateSelected date: NSDate!, withState state: ABCalendarPickerState) {
        
        let theDate = self.createDateFrom(date, forHour: 0, andMinute: 0)
        let today = self.createDateFrom(NSDate(), forHour: 0, andMinute: 0)
       
       if theDate!.compare(today!) != NSComparisonResult.OrderedDescending {
            let text = NSLocalizedString("list.reminder.notification.validationDate",comment:"")
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(text)
            self.alertView!.showErrorIcon("Aceptar")
            return
        }
        
        self.selectedDate = date
    }
    
    func createDateFrom(date:NSDate, forHour hour:Int, andMinute minute:Int) -> NSDate? {
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        //calendar.timeZone = NSTimeZone(abbreviation: "UTC")
        calendar!.timeZone = NSTimeZone.localTimeZone()
        let components = calendar!.components([NSCalendarUnit.Year , NSCalendarUnit.Month , NSCalendarUnit.Day], fromDate: date)
        components.second = 00
        components.minute = minute
        components.hour = hour
        let otherDate = calendar!.dateFromComponents(components)
        return otherDate
    }
    
    func save(){
        self.delegate?.selectedDate(self.selectedDate)
    }
    
    func cancel(){
        self.delegate?.selectedDate(self.originalDate)
    }
}
