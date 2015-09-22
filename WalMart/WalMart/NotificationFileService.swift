//
//  NotificationFileService.swift
//  WalMart
//
//  Created by Alejandro Miranda on 09/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class NotificationFileService : BaseService {
    
    let fileNotification = "nots.json"
    
    func saveNotification(notificationParams:[NSObject : AnyObject]) {
        
        
        var notificationParamsToSave = notificationParams
        
        let dateFmt = NSDateFormatter()
        dateFmt.dateFormat  = "d / MMM / yyyy"
        
        let dateFmtHr = NSDateFormatter()
        dateFmtHr.dateFormat  = "HH:mm"
        
        let dateToday = NSDate()
        
        var currentNots = getAllNotifications()
        var itemsInDictionary = currentNots["items"] as! [AnyObject]
        notificationParamsToSave["date"] = dateFmt.stringFromDate(dateToday)
        notificationParamsToSave["hour"] = dateFmtHr.stringFromDate(dateToday)
        itemsInDictionary.append(notificationParamsToSave)
        self.saveDictionaryToFile(["items":itemsInDictionary], fileName: fileNotification)
        
    }
    
    func getAllNotifications() -> NSDictionary {
        if let returnDict = self.getDataFromFile(fileNotification) {
            return returnDict
        }
        return ["items":[]]
    }
    
    
}



