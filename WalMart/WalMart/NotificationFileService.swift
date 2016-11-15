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
    
    func saveNotification(_ notificationParams:[AnyHashable: Any]) {
        
        
        var notificationParamsToSave = notificationParams
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat  = "d / MMM / yyyy"
        
        let dateFmtHr = DateFormatter()
        dateFmtHr.dateFormat  = "HH:mm"
        
        let dateToday = Date()
        
        let currentNots = getAllNotifications()
        var itemsInDictionary = currentNots["items"] as! [Any]
        notificationParamsToSave["date"] = dateFmt.string(from: dateToday)
        notificationParamsToSave["hour"] = dateFmtHr.string(from: dateToday)
        itemsInDictionary.append(notificationParamsToSave as AnyObject)
        self.saveDictionaryToFile(["items":itemsInDictionary], fileName: fileNotification)
        
    }
    
    func getAllNotifications() -> [String:Any] {
        if let returnDict = self.getDataFromFile(fileNotification as NSString) {
            return returnDict
        }
        return ["items":[]]
    }
    
    
}



