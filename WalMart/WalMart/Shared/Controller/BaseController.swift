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
                tracker.send(eventTracker as! [NSObject : AnyObject])
            }
        }
        
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["event": "openScreen", "screenName": self.getScreenGAIName()])
        
    }

    
    func loadStoryboardDefinition() -> UIStoryboard? {
        let storyboardName = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? "Storyboard_iphone" : "Storyboard_ipad"
        let storyboard : UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil);
        return storyboard;
    }
        
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let rotation = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? UIInterfaceOrientationMask.Portrait : UIInterfaceOrientationMask.Landscape
         return rotation
    }
    
    //WHITE BAR
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
   //TODO :  360 commnets
    class func sendAnalytics(category:String, action: String, label:String){
           ////////
//        print("Category: \(category) Action: \(action) Label: \(label)")
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEventWithCategory(category,
                        action: action,
                        label: label, value: nil).build() as [NSObject : AnyObject])
                }
    }
    
    class func sendAnalytics(categoryAuth:String, categoryNoAuth:String, action: String, label:String){
        let category = UserCurrentSession.hasLoggedUser() ? categoryAuth : categoryNoAuth
        BaseController.sendAnalytics(category, action: action, label: label)
    }
    
    class func sendTagProductToWishList(upc: String, desc:String, price: String) {
        self.sendAnalyticsPush(["event": "addList", "skuProducto": upc, "descripcionProducto": desc, "valorProducto": price])
    }
    
    class func sendTagWhishlistProductsToCart(totalPriceOfList: Double) {
        self.sendAnalyticsPush(["event": "addListCart", "valorLista": totalPriceOfList])
    }
    
    
    class func sendAnalyticsPush(pushData:[String:AnyObject]) {
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(pushData)
    }
    
    //MARK: Tag de Errores
    class func sendTagManagerErrors(event:String,detailError:String){
        
        let dataLayer = TAGManager.instance().dataLayer
        switch event {
        case "ErrorEvent":
             dataLayer.push(["event":event,"detailError":detailError])
            break
        case "ErrorEventBusiness":
             dataLayer.push(["event":event,"detailErrorBusiness":detailError])
            break
        default:
            break
        }
       
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
//            event.eventItems = payPalItems as [AnyObject]
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