//
//  BannerService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class BannerService : BaseService {
    
    let fileName =  "banner.json"
    
    let JSON_BANNER_BANNERLIST = "bannerList"
    let JSON_BANNER_EMBEDDEDLIST = "embeddedList"
    let JSON_BANNER_LANDING = "landing"
    let JSON_BANNER_LANDINGCAMPANA = "landingcampana"
    let JSON_BANNER_LANDINGCATEGORY = "landingcategory"
    let JSON_BANNER_PLECA = "pleca"

    
    
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        print(params)
        self.callGETService(params as AnyObject, successBlock: { (resultCall:[String:Any]) -> Void in
            self.saveDictionaryToFile(resultCall, fileName:self.fileName)
            NotificationCenter.default.post(name: Notification.Name(rawValue: UpdateNotification.HomeUpdateServiceEnd.rawValue), object: nil)
            
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
    
    
    func getBannerContent() -> [[String:String]] {
        var bannerItems : [[String:String]] = []
        
        let values = getDataFromFile(fileName as NSString)
        if values == nil {
            return bannerItems
        }
        
        bannerItems = values![JSON_BANNER_EMBEDDEDLIST] as! [[String:String]]
        if var moreBanner = values![JSON_BANNER_BANNERLIST] as? [[String:String]] {
            moreBanner.sort(by: { (one:[String : String], second:[String : String]) -> Bool in
                let firstString = one["order"] as String?
                let secondString = second["order"] as String?
                return Int(firstString!) < Int(secondString!)
            })
            
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
        
        let values = getDataFromFile(fileName as NSString)
        if values == nil {
            return nil
        }
        if let landingItem = values![JSON_BANNER_LANDING] as? [[String:String]] {
            return landingItem
        }
        return nil
    }
    
    func getPleca() -> [String:Any]? {
        
        let values = getDataFromFile(fileName as NSString)
        if values == nil {
            return nil
        }
        if let landingItem = values![JSON_BANNER_PLECA] as? [[String:String]] {
            if landingItem.count == 0{
                return [:]
            }
            return landingItem[0] as [String:Any]
        }
        return nil
    }
    
    
}
