//
//  CarouselService.swift
//  WalMart
//
//  Created by Alejandro MIranda on 02/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
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

class CarouselService : BaseService {
    
    
    let fileName = "carousel.json"
    
    let JSON_BANNER_RESPONSEARRAY = "responseArray"
    
    
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        //print(params)
        self.callGETService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            self.saveDictionaryToFile(resultCall, fileName:self.fileName)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: UpdateNotification.HomeUpdateServiceEnd.rawValue), object: nil)

            
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
   
    
    func getCarouselContent() -> [[String:Any]] {
        var carouselItems : [[String:Any]] = []
        
        let values = getDataFromFile(fileName as NSString)
        if values == nil {
            return carouselItems
        }
        
        
        
        carouselItems = values![JSON_BANNER_RESPONSEARRAY] as! [[String:Any]]
        
        if var moreCarousel = values![JSON_BANNER_RESPONSEARRAY] as? [[String:String]] {
            
            moreCarousel.sort(by: { (one:[String : String], second:[String : String]) -> Bool in
                let firstString = one["order"] as String?
                let secondString = second["order"] as String?
                return Int(firstString!) < Int(secondString!)
            })
            

            
            for Carousel in moreCarousel {
                carouselItems.append(Carousel)
            }
        }

        
        
        
        return carouselItems
    }

    
    
    
}
