//
//  ReminderNotificationService.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 25/02/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

let REMINDER_PARAM_LISTID = "listId"
let REMINDER_PARAM_LISTNAME = "listName"
let REMINDER_PARAM_ORIGINALDATE = "originalFireDate"
let REMINDER_PARAM_TYPE = "type"
let REMINDER_PARAM_NOTIFTYPE = "notificationType"
let REMINDER_NOTIFICATION = "ListReminder"
let REMINDER_NOTIFICATION_NAME = "name"
let REMINDER_NOTIFICATION_VALUE = "value"
let REMINDER_NOTIFICATION_BUSINESS = "business"

class ReminderNotificationService {
    let options = [NSLocalizedString("list.reminder.option.onetime", comment:""),NSLocalizedString("list.reminder.option.weekly", comment:""), NSLocalizedString("list.reminder.option.everyTwoWeek", comment:""), NSLocalizedString("list.reminder.option.everyThreeWeek", comment:""),
        NSLocalizedString("list.reminder.option.montly", comment:"")]
    let SECS_IN_DAY:TimeInterval = 60 * 60 * 24
    
    var currentNotificationConfig: [AnyHashable: Any]?
    var selectedPeriodicity: Int?
    var listId: String?
    var listName: String?
    
    init (){
        self.listId = nil
        self.listName = nil
    }

    init (listId:String,listName:String){
       self.listId = listId
       self.listName = listName
    }

    //MARK: - Notifications
    /**
     Creates a reminder with periodicity
     
     - parameter option:   reminder periodicity
     - parameter fireDate: reminder start date
     - parameter time:     reminder hour
     */
    func scheduleNotifications(forOption option:Int, withDate fireDate:Date, forTime time:String) {
        let timeArray = time.components(separatedBy: ":")
        let hour = Int(timeArray.first!)
        let min = Int(timeArray.last!)
        let title = self.options[option]
        switch (option) {
        case 0 : //Sólo una vez
            if let date = self.createDateFrom(fireDate, forHour: hour!, andMinute: min!) {
                self.createLocalNotification(title: title, fireDate: date, originalFireDate:date, frequency: nil, customType:0)
            }
        case 1 : //Semanal
            if let date = self.createDateFrom(fireDate, forHour: hour!, andMinute: min!) {
                self.createLocalNotification(title: title, fireDate: date, originalFireDate:date, frequency: NSCalendar.Unit.weekOfYear, customType:1)
            }
        case 2 : //Cada 2 semanas
            //Generate all notifications for a year (52 weaks; 26 for every 2 weeks at year)
            if let date = self.createDateFrom(fireDate, forHour: hour!, andMinute: min!) {
                var nextDate = date
                for _ in 0 ..< 26 {
                    self.createLocalNotification(title: title, fireDate: nextDate, originalFireDate: date, frequency: nil, customType:2)
                    nextDate = nextDate.addingTimeInterval(self.SECS_IN_DAY * 14.0)
                }
            }
        case 3 : //Cada 3 semanas
            //Generate all notifications for a year (52 weaks; 18 for every 3 weeks at year, more or less)
            if let date = self.createDateFrom(fireDate, forHour: hour!, andMinute: min!) {
                var nextDate = date
                for _ in 0 ..< 18 {
                    self.createLocalNotification(title: title, fireDate: nextDate, originalFireDate: date, frequency: nil, customType:3)
                    nextDate = nextDate.addingTimeInterval(self.SECS_IN_DAY * 21.0)
                }
            }
        default:
            if let date = self.createDateFrom(fireDate, forHour: hour!, andMinute: min!) {
                self.createLocalNotification(title: title, fireDate: date, originalFireDate: date, frequency: NSCalendar.Unit.month, customType:4)
            }
        }
    }
    
    /**
     Adds hours and minutes to a date
     
     - parameter date:   date
     - parameter hour:   hour to add
     - parameter minute: minutes to add
     
     - returns: Regresa la fecha con la hora especificada
     */
    func createDateFrom(_ date:Date, forHour hour:Int, andMinute minute:Int) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        //calendar.timeZone = NSTimeZone(abbreviation: "UTC")
        calendar.timeZone = TimeZone.autoupdatingCurrent
        var components = (calendar as NSCalendar).components([NSCalendar.Unit.year , NSCalendar.Unit.month , NSCalendar.Unit.day], from: date)
        components.second = 00
        components.minute = minute
        components.hour = hour
        let otherDate = calendar.date(from: components)
        return otherDate
    }
    
    /**
     Creates a reminder as a local notification
     
     - parameter title:            reminder title
     - parameter fireDate:         reminder date
     - parameter originalFireDate: reminder start date
     - parameter frequency:        reminder frequency
     - parameter customType:       reminder periodicity as int
     
     - returns: UILocalNotification
     */
    func createLocalNotification(title:String, fireDate:Date, originalFireDate:Date, frequency:NSCalendar.Unit?, customType:Int) -> UILocalNotification {
        let notification = UILocalNotification()
        if frequency != nil {
            notification.repeatInterval = frequency!
        }
        notification.timeZone = TimeZone.autoupdatingCurrent
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertBody = String(format: NSLocalizedString("list.reminder.notification.content", comment:""), self.listName!)
        notification.fireDate = fireDate
        //notification.fireDate = NSDate().dateByAddingTimeInterval(30) //TEST -
        if self.listId != nil {
            notification.userInfo = [
                REMINDER_PARAM_LISTID:self.listId!,
                REMINDER_PARAM_LISTNAME:self.listName!,
                REMINDER_PARAM_ORIGINALDATE:originalFireDate,
                REMINDER_PARAM_TYPE:NSNumber(value: customType as Int),
                REMINDER_PARAM_NOTIFTYPE:REMINDER_NOTIFICATION,
                REMINDER_NOTIFICATION_NAME: REMINDER_NOTIFICATION,
                REMINDER_NOTIFICATION_VALUE: "WF",
                REMINDER_NOTIFICATION_BUSINESS: "mg"
            ]
            self.currentNotificationConfig = notification.userInfo
        }
        UIApplication.shared.scheduleLocalNotification(notification)
        return notification
    }
    
    /**
     Delete the reminders from current list
     */
    func removeNotificationsFromCurrentList() {
        var notifications = UIApplication.shared.scheduledLocalNotifications
        if notifications != nil && notifications!.count > 0 {
            for idx in 0 ..< notifications!.count {
                let notification:UILocalNotification = notifications![idx] as UILocalNotification
                if notification.userInfo != nil {
                    let values = notification.userInfo as! [String:Any]?
                    if let listId = values![REMINDER_PARAM_LISTID] as? String {
                        if listId == self.listId {
                            UIApplication.shared.cancelLocalNotification(notification)
                        }
                    }
                }
            }
        }
    }
    
    /**
     Search local notifications and set the currentNotificationConfig
     */
    func findNotificationForCurrentList() {
        var notifications = UIApplication.shared.scheduledLocalNotifications
        if notifications != nil && notifications!.count > 0 {
            for idx in 0 ..< notifications!.count {
                let notification:UILocalNotification = notifications![idx] as UILocalNotification
                if notification.userInfo != nil {
                    let values = notification.userInfo as! [String:Any]?
                    if let listId = values![REMINDER_PARAM_LISTID] as? String {
                        if listId == self.listId {
                            self.currentNotificationConfig = notification.userInfo
                            break
                        }
                    }
                }
            }
        }
    }
    
    /**
     Return true only if exists reminders from current list
     
     - returns: Bool
     */
    func existNotificationForCurrentList() -> Bool {
        var exist = false
        var notifications = UIApplication.shared.scheduledLocalNotifications
        if notifications != nil && notifications!.count > 0 {
            for idx in 0 ..< notifications!.count {
                let notification:UILocalNotification = notifications![idx] as UILocalNotification
                if notification.userInfo != nil {
                    let values = notification.userInfo as! [String:Any]?
                    if let listId = values!["listId"] as? String {
                        if listId == self.listId {
                            exist = true
                            break
                        }
                    }
                }
            }
        }
        return exist
    }
    
    /**
     Check whether the device can create reminders
     
     - returns: Bool
     */
    static func isEnableLocalNotificationForApp() -> Bool {
        if #available(iOS 8.0, *) {
            if(UIApplication.instancesRespond(to: #selector(getter: UIApplication.currentUserNotificationSettings)))
            {
                let settings = UIApplication.shared.currentUserNotificationSettings
                    
                if settings == nil || settings!.types == UIUserNotificationType() {
                    //AlertController.presentViewController(NSLocalizedString("list.reminder.notification.validation",comment:""),
                    //    icon: nil,
                    //  titleButton: NSLocalizedString("list.reminder.notification.settings", comment:""),
                    //action: {() in
                    //  if #available(iOS 8.0, *) {
                    //    UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
                    //} else {
                    // Fallback on earlier versions
                    //};
                    //return
                    //})
                        
                    return false
                }
                    
                
            }
        } else {
            // Fallback on earlier versions
             return false
        }
        //do iOS 7 stuff, which is pretty much nothing for local notifications.
        return true
    }
    
    /**
     Returns the reminder period as string
     
     - returns: String
     */
    func getNotificationPeriod() -> String{
        self.findNotificationForCurrentList()
        return self.options[self.currentNotificationConfig!["type"] as! Int]
    }
    
    /**
     Look for the reminders to the current list, delete old and create new reminders with the new name.
    
     - parameter newName: reminder new name
     */
    func updateListName(_ newName:String){
        if self.existNotificationForCurrentList(){
            self.findNotificationForCurrentList()
            self.listName = newName
            let period = self.currentNotificationConfig!["type"] as! Int
            let date = self.currentNotificationConfig!["originalFireDate"] as! Date
            let timeFormat = DateFormatter()
            timeFormat.dateFormat = "HH:mm"
            timeFormat.locale = Locale(identifier: "da_DK")
            let time = timeFormat.string(from: date)
            self.removeNotificationsFromCurrentList()
            self.scheduleNotifications(forOption: period, withDate: date, forTime: time)
        }
    }
    
}
