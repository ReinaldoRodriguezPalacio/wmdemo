//
//  BaseController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
//import Tune


class BaseController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            let valueScreenName = self.getScreenGAIName()
            if !valueScreenName.isEmpty {
                tracker.set(kGAIScreenName, value: self.getScreenGAIName())
                let eventTracker: NSObject = GAIDictionaryBuilder.createScreenView().build()
                tracker.send(eventTracker as! [AnyHashable: Any])
            }
            
        }
    }

    
    func loadStoryboardDefinition() -> UIStoryboard? {
        let storyboardName = UIDevice.current.userInterfaceIdiom == .phone ? "Storyboard_iphone" : "Storyboard_ipad"
        let storyboard : UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil);
        return storyboard;
    }
        
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        let rotation = UIDevice.current.userInterfaceIdiom == .phone ? UIInterfaceOrientationMask.portrait : UIInterfaceOrientationMask.landscape
         return rotation
    }
    
    //WHITE BAR
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    
    override var shouldAutorotate : Bool {
        return true
    }
    
    class func sendAnalytics(_ category:String, action: String, label:String){
           ////////
//        print("Category: \(category) Action: \(action) Label: \(label)")
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEvent(withCategory: category,
                        action: action,
                        label: label, value: nil).build() as [AnyHashable: Any])
                }
    }
    
    class func sendAnalytics(_ categoryAuth:String, categoryNoAuth:String, action: String, label:String){
        let category = UserCurrentSession.hasLoggedUser() ? categoryAuth : categoryNoAuth
        BaseController.sendAnalytics(category, action: action, label: label)
    }

//    class func sendTuneAnalytics(event:String,email:String,userName:String,gender:String,idUser:String,itesShop:NSArray?,total:NSNumber,refId:String){
//        
//        print("TUNE_EVENT_\(event)")
//        switch(event){
//        case TUNE_EVENT_PURCHASE:
//            let payPalItems:NSMutableArray = []
//            for item in itesShop! {
//                
//                var itemPrice = 0.0
//                var quantity : UInt = 1
//                
//                if let priceItem = item["price"] as? Double {
//                     itemPrice = priceItem
//                }
//                if let priceItem = item["price"] as? String {
//                    itemPrice = Double(priceItem)!
//                }
//                
//                if let itemQuantity = item["quantity"] as? UInt{
//                    quantity = itemQuantity
//                }
//                
//                if let itemQuantity = item["quantity"] as? String {
//                    quantity = UInt(itemQuantity)!
//                }
//                
//                
//                if let types = item["type"] as? String
//                {
//                    if types == "1"{
//                        itemPrice = (Double(quantity) / 1000.0) * itemPrice
//                        quantity = 1
//                    }
//                }
//                var upcSend = ""
//                if let upc = item["upc"] as? String
//                {
//                    upcSend = upc
//                }
//                
//                let tuneItem : TuneEventItem = TuneEventItem(name: item["description"] as! String, unitPrice: CGFloat(itemPrice), quantity: quantity)
//                tuneItem.attribute1 = upcSend
//                payPalItems.addObject(tuneItem)
//            }
//            
//            Tune.setUserId(idUser)
//            
//            let event :TuneEvent = TuneEvent(name: event)
//            event.eventItems = payPalItems as [Any]
//            event.refId = refId
//            event.revenue = CGFloat(total)
//            event.currencyCode = "MXN"
//            Tune.measureEvent(event)
//            
//            
//            break
//        case TUNE_EVENT_LOGIN:
//            Tune.setUserEmail(email)
//            Tune.setUserName(userName)
//            Tune.setGender(gender.lowercaseString == "male" ?TuneGender.Male:TuneGender.Female)
//            Tune.setUserId(idUser)
//            Tune.measureEventName(event)
//            print(TUNE_EVENT_LOGIN)
//            break
//        case TUNE_EVENT_REGISTRATION:
//            Tune.setUserEmail(email)
//            Tune.setUserName(userName)
//            Tune.setGender(gender.lowercaseString == "male" ? TuneGender.Male :TuneGender.Female)
//            Tune.setUserId(idUser)
//            Tune.measureEventName(TUNE_EVENT_REGISTRATION)
//            print(TUNE_EVENT_REGISTRATION)
//            
//            break
//            
//        default:
//            break
//            
//        
//        }
//        
//    }

    
   
    func getScreenGAIName() -> String {
        fatalError("SCreeen name not implemented")
    }
    
}
