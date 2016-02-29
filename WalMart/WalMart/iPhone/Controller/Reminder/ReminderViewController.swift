//
//  ReminderViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 29/02/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

class ReminderViewController: NavigationViewController,ABCalendarPickerDelegateProtocol, ABCalendarPickerDataSourceProtocol{
    
    var listId: String?
    var listName: String?
    var calendar: ABCalendarPicker?
    var currentOriginalFireDate: NSDate?
    var selectedPeriodicity: Int?
    var reminderService: ReminderNotificationService?
    var fmtDisplay: NSDateFormatter?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_REMINDER.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fmtDisplay = NSDateFormatter()
        self.fmtDisplay!.dateFormat = "MMMM d"
        self.titleLabel?.text = NSLocalizedString("list.reminder.title", comment:"")
        self.reminderService = ReminderNotificationService(listId: self.listId!, listName: self.listName!)
        self.reminderService?.findNotificationForCurrentList()
        //ABCalendarPickerStateDays
        self.calendar = ABCalendarPicker(frame: CGRectMake(0.0, 50.0, 320.0, 500.0), andState: ABCalendarPickerStateDays, andDelegate: self, andDataSource:self)
        self.calendar!.backgroundColor = UIColor.whiteColor()
        self.calendar!.bottomExpanding = true
        self.view.addSubview(self.calendar!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.frame.size
        self.calendar!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, 500.0)
    }
    
    // MARK: - ABCalendarPickerDataSourceProtocol
    func calendarPicker(calendarPicker: ABCalendarPicker!, numberOfEventsForDate date: NSDate!, onState state: ABCalendarPickerState) -> Int {
        if self.currentOriginalFireDate != nil {
            let closedDate = self.reminderService!.createDateFrom(date, forHour: 12, andMinute: 00)
            let compareResult = closedDate!.compare(self.currentOriginalFireDate!)
            if compareResult == NSComparisonResult.OrderedSame {
                return 1
            }
            else if compareResult == NSComparisonResult.OrderedDescending {
                if let type = self.reminderService!.currentNotificationConfig![REMINDER_PARAM_TYPE] as? NSNumber {
                    switch(type.integerValue) {
                    case 1 :
                        if self.isDate(closedDate!, partOfIntervalOfDays: 7, fromDate: self.currentOriginalFireDate!) {
                            return 1
                        }
                    case 2 :
                        if self.isDate(closedDate!, partOfIntervalOfDays: 14, fromDate: self.currentOriginalFireDate!) {
                            return 1
                        }
                    case 3 :
                        if self.isDate(closedDate!, partOfIntervalOfDays: 21, fromDate: self.currentOriginalFireDate!) {
                            return 1
                        }
                    case 4 :
                        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
                        //calendar.timeZone = NSTimeZone(abbreviation: "UTC")
                        calendar!.timeZone = NSTimeZone.localTimeZone()
                        let closedDateComponents = calendar!.components([NSCalendarUnit.Year , NSCalendarUnit.Month , NSCalendarUnit.Day], fromDate: closedDate!)
                        let dayRangeClosedDate = calendar!.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: closedDate!)
                        //print("month:\(closedDateComponents.month) days:\(dayRangeClosedDate.length)")
                        let originalDateComponents = calendar!.components([NSCalendarUnit.Year , NSCalendarUnit.Month , NSCalendarUnit.Day], fromDate: self.currentOriginalFireDate!)
                        let originalRangeClosedDate = calendar!.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: self.currentOriginalFireDate!)
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
        return UIScreen.mainScreen().bounds.size.height == 568.0 ? 50.0 : 20.0
    }
    
    func calendarPickerHeightForColumnHeader(calendarPicker: ABCalendarPicker!) -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height == 568.0 ? 50.0 : 20.0
    }
    
    func calendarPicker(calendarPicker: ABCalendarPicker!, animateNewHeight height: CGFloat) {
        
    }
    
    func calendarPicker(calendarPicker: ABCalendarPicker!, shouldSetState state: ABCalendarPickerState, fromState: ABCalendarPickerState) -> Bool {
        
        return state.rawValue == ABCalendarPickerStateDays.rawValue
    }
    
    
    func calendarPicker(calendarPicker: ABCalendarPicker!, willAnimateWith animation: ABCalendarPickerAnimation) {
    }
    
    func calendarPicker(calendarPicker: ABCalendarPicker!, dateSelected date: NSDate!, withState state: ABCalendarPickerState) {
        
        let theDate = self.reminderService!.createDateFrom(date, forHour: 0, andMinute: 0)
        let today = self.reminderService!.createDateFrom(NSDate(), forHour: 0, andMinute: 0)
        
        if theDate!.compare(today!) != NSComparisonResult.OrderedDescending {
            let text = NSLocalizedString("list.reminder.notification.validationDate",comment:"")
            //AlertController.presentViewController(text, icon: UIImage(named:"alerta_notificacion"))
            return
        }
        
        if self.selectedPeriodicity != nil {
            let text = self.reminderService!.options[self.selectedPeriodicity!]
            let title = String(format: NSLocalizedString("list.reminder.confirm.new",comment:""), text, self.fmtDisplay!.stringFromDate(date!))
            
           /* AlertController.presentViewController(title,
                icon:UIImage(named:"alerta_notificacion"),
                titleButtonLeft: NSLocalizedString("list.reminder.confirm.cancel", comment:""),
                leftAction: {() -> Void in
                    self.delegate?.notifyReminderWillClose(forceValidation: true, value: false)
                    self.navigationController?.popViewControllerAnimated(true)
                },
                titleButtonRight: NSLocalizedString("list.reminder.confirm.ok", comment:""),
                rightAction: {() -> Void in
                    
                    BaseGAIViewController.sendAnalytics(SAMSGAIUtils.CATEGORY_REMINDER_AUTH.rawValue, categoryNoAuth: SAMSGAIUtils.CATEGORY_REMINDER_NO_AUTH.rawValue, action: SAMSGAIUtils.ACTION_REMINDER_WEEK.rawValue, label: text)
                    
                    BaseGAIViewController.sendAnalytics(SAMSGAIUtils.CATEGORY_REMINDER_AUTH.rawValue, categoryNoAuth: SAMSGAIUtils.CATEGORY_REMINDER_NO_AUTH.rawValue, action: SAMSGAIUtils.ACTION_REMINDER_SELECTED.rawValue, label: String(date))
                    BaseGAIViewController.sendAnalytics(SAMSGAIUtils.CATEGORY_REMINDER_AUTH.rawValue, categoryNoAuth: SAMSGAIUtils.CATEGORY_REMINDER_NO_AUTH.rawValue, action: SAMSGAIUtils.ACTION_REMINDER_CONFIRM.rawValue, label: "")
                    self.scheduleNotifications(forOption:self.selectedPeriodicity!, withDate:date)
                    self.delegate?.notifyReminderWillClose(forceValidation: false, value: true)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            )*/
            
        }
    }
}