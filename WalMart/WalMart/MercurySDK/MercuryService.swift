//
//  MercuryService.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 24/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


public class MercuryService {
    
    var username = ""
    
    //Singleton init
    class func sharedInstance()-> MercuryService! {
        struct Static {
            static var instance : MercuryService? = nil
            static var onceToken : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = self.init()
        }
        
        return Static.instance!
    }
    
    required  public init() {
        
    }

    public func startMercuryService(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateMercuryDelivery"), name: "delivery", object: nil)
    
        if self.username != "" {
            setActiveUserName(self.username)
        }
    }
    
    public func updateMercuryService(){
        if self.username != "" {
            setActiveUserName(self.username)
        }
    }
    
    
    public func setActiveUserName(username:String) {
        self.username = username
        PostDelivery.getCurrentMercuryDeliveries(username) { (resultSuccess) -> Void in
            self.updateMercuryDelivery()
        }
    }
    
    public func appWillResignActive(notification: NSNotification) {
        setActiveUserName(self.username)
    }
    
    public func appWillTerminate(notification: NSNotification)  {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
   
    
     public func updateMercuryDelivery() {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        if PostDelivery.sharedInstance().currentDeliveries != nil {
            if PostDelivery.sharedInstance().currentDeliveries!.count > 0 {
                PostDelivery.sharedInstance().showFollowView(vc!)
            } else {
                PostDelivery.sharedInstance().hideFollowView()
            }
        }
        if PostDelivery.sharedInstance().currentToRate != nil {
            if PostDelivery.sharedInstance().currentToRate!.count > 0 {
                PostDelivery.sharedInstance().showRateView(vc!)
            }
        }
        
    }
    
    
}