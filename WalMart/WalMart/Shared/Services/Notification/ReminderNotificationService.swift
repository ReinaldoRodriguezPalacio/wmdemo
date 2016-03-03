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

class ReminderNotificationService {
    let options = [NSLocalizedString("list.reminder.option.onetime", comment:""),NSLocalizedString("list.reminder.option.weekly", comment:""), NSLocalizedString("list.reminder.option.everyTwoWeek", comment:""), NSLocalizedString("list.reminder.option.everyThreeWeek", comment:""),
        NSLocalizedString("list.reminder.option.montly", comment:"")]
    let SECS_IN_DAY:NSTimeInterval = 60 * 60 * 24
    
    var currentNotificationConfig: [NSObject:AnyObject]?
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
    func scheduleNotifications(forOption option:Int, withDate fireDate:NSDate, forTime time:String) {
        let timeArray = time.componentsSeparatedByString(":")
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
                self.createLocalNotification(title: title, fireDate: date, originalFireDate:date, frequency: NSCalendarUnit.Weekday, customType:1)
            }
        case 2 : //Cada 2 semanas
            //Generate all notifications for a year (52 weaks; 26 for every 2 weeks at year)
            if let date = self.createDateFrom(fireDate, forHour: hour!, andMinute: min!) {
                var nextDate = date
                for var i = 0; i < 26; i++ {
                    self.createLocalNotification(title: title, fireDate: nextDate, originalFireDate: date, frequency: nil, customType:2)
                    nextDate = nextDate.dateByAddingTimeInterval(self.SECS_IN_DAY * 14.0)
                }
            }
        case 3 : //Cada 3 semanas
            //Generate all notifications for a year (52 weaks; 18 for every 3 weeks at year, more or less)
            if let date = self.createDateFrom(fireDate, forHour: hour!, andMinute: min!) {
                var nextDate = date
                for var i = 0; i < 18; i++ {
                    self.createLocalNotification(title: title, fireDate: nextDate, originalFireDate: date, frequency: nil, customType:3)
                    nextDate = nextDate.dateByAddingTimeInterval(self.SECS_IN_DAY * 21.0)
                }
            }
        default:
            if let date = self.createDateFrom(fireDate, forHour: hour!, andMinute: min!) {
                self.createLocalNotification(title: title, fireDate: date, originalFireDate: date, frequency: NSCalendarUnit.Month, customType:4)
            }
        }
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
    
    func createLocalNotification(title title:String, fireDate:NSDate, originalFireDate:NSDate, frequency:NSCalendarUnit?, customType:Int) -> UILocalNotification {
        let notification = UILocalNotification()
        if frequency != nil {
            notification.repeatInterval = frequency!
        }
        notification.timeZone = NSTimeZone.localTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertBody = String(format: NSLocalizedString("list.reminder.notification.content", comment:""), self.listName!)
        notification.fireDate = fireDate
        //notification.fireDate = NSDate().dateByAddingTimeInterval(30) //TEST -
        if self.listId != nil {
            notification.userInfo = [
                REMINDER_PARAM_LISTID:self.listId!,
                REMINDER_PARAM_LISTNAME:self.listName!,
                REMINDER_PARAM_ORIGINALDATE:originalFireDate,
                REMINDER_PARAM_TYPE:NSNumber(integer: customType),
                REMINDER_PARAM_NOTIFTYPE:REMINDER_NOTIFICATION
            ]
            self.currentNotificationConfig = notification.userInfo
        }
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        return notification
    }
    
    func removeNotificationsFromCurrentList() {
        var notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        if notifications != nil && notifications!.count > 0 {
            for var idx = 0; idx < notifications!.count; idx++ {
                let notification:UILocalNotification = notifications![idx] as UILocalNotification
                if notification.userInfo != nil {
                    let values = notification.userInfo as NSDictionary?
                    if let listId = values![REMINDER_PARAM_LISTID] as? String {
                        if listId == self.listId {
                            UIApplication.sharedApplication().cancelLocalNotification(notification)
                        }
                    }
                }
            }
        }
    }
    
    func findNotificationForCurrentList() {
        var notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        if notifications != nil && notifications!.count > 0 {
            for var idx = 0; idx < notifications!.count; idx++ {
                let notification:UILocalNotification = notifications![idx] as UILocalNotification
                if notification.userInfo != nil {
                    let values = notification.userInfo as NSDictionary?
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
    
    func existNotificationForCurrentList() -> Bool {
        var exist = false
        var notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        if notifications != nil && notifications!.count > 0 {
            for var idx = 0; idx < notifications!.count; idx++ {
                let notification:UILocalNotification = notifications![idx] as UILocalNotification
                if notification.userInfo != nil {
                    let values = notification.userInfo as NSDictionary?
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
    
    static func isEnableLocalNotificationForApp() -> Bool {
        if(UIApplication.instancesRespondToSelector(Selector("currentUserNotificationSettings")))
        {
            if #available(iOS 8.0, *) {
                let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
                
                if settings == nil || settings!.types == .None {
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
                
            } else {
                // Fallback on earlier versions
                return false
            }
            
        }
        //do iOS 7 stuff, which is pretty much nothing for local notifications.
        return true
    }
    
    
    func getNotificationPeriod() -> String{
        self.findNotificationForCurrentList()
        return self.options[self.currentNotificationConfig!["type"] as! Int]
    }
}