//
//  BannerService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class BannerService : BaseService {
    
    let fileName =  "banner.json"
    
    let JSON_BANNER_BANNERLIST = "bannerList"
    let JSON_BANNER_EMBEDDEDLIST = "embeddedList"
    let JSON_BANNER_LANDING = "landing"
    let JSON_BANNER_LANDINGCAMPANA = "landingcampana"
    let JSON_BANNER_LANDINGCATEGORY = "landingcategory"
    let JSON_BANNER_PLECA = "pleca"

    
    
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        print(params)
        self.callGETService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            self.saveDictionaryToFile(resultCall, fileName:self.fileName)
            NSNotificationCenter.defaultCenter().postNotificationName(UpdateNotification.HomeUpdateServiceEnd.rawValue, object: nil)
            
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    
    func getBannerContent() -> [[String:String]] {
        var bannerItems : [[String:String]] = []
        
        let values = getDataFromFile(fileName)
        if values == nil {
            return bannerItems
        }
        
      
        
        bannerItems = values![JSON_BANNER_EMBEDDEDLIST] as! [[String:String]]
        if var moreBanner = values![JSON_BANNER_BANNERLIST] as? [[String:String]] {
            moreBanner.sortInPlace({ (one:[String : String], second:[String : String]) -> Bool in
                let firstString = one["order"] as String?
                let secondString = second["order"] as String?
                return Int(firstString!) < Int(secondString!)
            })
            
            //                Se quita validación por que el server es quen va a validar, Fecha y quien solicito: 09032015 Miguel Pahua
            //                let dateFormatter = NSDateFormatter()
            //                dateFormatter.dateFormat = "dd/MM/yyyy"
            //                let dateServer = values!["serverDate"] as String
            //                let todayDateServer = dateFormatter.dateFromString(dateServer)
            //                let arrayResultInicio =  banner.keys.filter {$0 == "inicio"}
            //                let arrayResultExpiration =  banner.keys.filter {$0 == "expiration"}
            //                if arrayResultInicio.array.count > 0 && arrayResultExpiration.array.count > 0 {
            //                    let beginShow = banner["inicio"]!
            //                    let expirationShow = banner["expiration"]!
            //
            //                    if beginShow != "" && expirationShow != "" {
            //                        let dateStart = dateFormatter.dateFromString(beginShow)
            //                        let dateEnd = dateFormatter.dateFromString(expirationShow)
            //
            //                        if dateStart!.compare(todayDateServer!) == NSComparisonResult.OrderedDescending {
            //                            println("Baner con fecha de inicio que aun no llega")
            //                            continue;
            //                        }
            //                        if todayDateServer!.compare(dateEnd!) == NSComparisonResult.OrderedDescending {
            //                            println("Baner con fecha de inicio que aun no llega")
            //                            continue;
            //                        }
            //                    }
            //                    if beginShow != "" {
            //                        let dateStart = dateFormatter.dateFromString(beginShow) as NSDate?
            //                        if dateStart!.compare(todayDateServer!) == NSComparisonResult.OrderedDescending {
            //                            println("Baner con fecha de inicio que aun no llega")
            //                            continue;
            //                        }
            //                    }
            //                }
            
            for banner in moreBanner {
                bannerItems.append(banner)
            }
        }
        //LANDINGCAMPANA
        if let moreBanner = values![JSON_BANNER_LANDINGCAMPANA] as? [[String:String]] {
            for banner in moreBanner {
                bannerItems.append(banner)
            }
        }
        
        if let moreBanner = values![JSON_BANNER_LANDINGCATEGORY] as? [[String:String]] {
            for banner in moreBanner {
                bannerItems.append(banner)
            }
        }

        
        
        return bannerItems
    }
    
    
    func getLanding() -> [[String:String]]? {
        
        let values = getDataFromFile(fileName)
        if values == nil {
            return nil
        }
        if let landingItem = values![JSON_BANNER_LANDING] as? [[String:String]] {
            return landingItem
        }
        return nil
    }
    
    func getPleca() -> NSDictionary? {
        
        let values = getDataFromFile(fileName)
        if values == nil {
            return nil
        }
        if let landingItem = values![JSON_BANNER_PLECA] as? [[String:String]] {
            if landingItem.count == 0{
                return [:]
            }
            return landingItem[0] as NSDictionary
        }
        return nil
    }
    
    
}