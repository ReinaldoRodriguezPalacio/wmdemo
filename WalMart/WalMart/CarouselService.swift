//
//  CarouselService.swift
//  WalMart
//
//  Created by Alejandro MIranda on 02/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
class CarouselService : BaseService {
    
    
    let fileName = "carousel.json"
    
    let JSON_BANNER_RESPONSEARRAY = "responseArray"
    
    
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        //print(params)
        self.callGETService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            self.saveDictionaryToFile(resultCall, fileName:self.fileName)
            NSNotificationCenter.defaultCenter().postNotificationName(UpdateNotification.HomeUpdateServiceEnd.rawValue, object: nil)
            successBlock!(resultCall)
            }) { (error:NSError) -> Void in
                errorBlock!(error)
        }
    }
   
    
    func getCarouselContent() -> [[String:AnyObject]] {
        var carouselItems : [[String:AnyObject]] = []
        
        let values = getDataFromFile(fileName)
        if values == nil {
            return carouselItems
        }
        
        
        
        carouselItems = values![JSON_BANNER_RESPONSEARRAY] as! [[String:AnyObject]]
        
        if var moreCarousel = values![JSON_BANNER_RESPONSEARRAY] as? [[String:String]] {
            
            moreCarousel.sortInPlace({ (one:[String : String], second:[String : String]) -> Bool in
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
