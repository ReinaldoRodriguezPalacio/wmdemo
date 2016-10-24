//
//  BaseController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
//import Tune

struct Banner {
    var id:String = ""
    var name:String = ""
    var creative:String = ""
    var position:String = ""
}

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
    
    class func sendAnalyticsSuccesfulRegistration() {
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["event": "registroExitoso"])
    }
    
    class func sendAnalyticsUnsuccesfulRegistrationWithError(error: String, stepError: String) {
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["event": "errorRegistro", "errorDetail": error, "stepError": stepError])
    }
    
    class func sendAnalyticsIntentRegistration() {
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["event": "intentoRegistro"])
    }
    
    class func sendAnalyticsPush(pushData:[String:AnyObject]) {
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(pushData)
    }
    
    class func sendEcommerceAnalyticsBanners(banners:[Banner]) {
        
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["ecommerce": NSNull()])
        var promotions: [[String : String]] = []
        
        for banner in banners {
            let banner = ["id": banner.id, "name": banner.name, "creative": banner.creative, "position": banner.position]
            promotions.append(banner)
        }
        
        let impression = ["ecommerce": ["promoView": ["promotions": promotions]], "event": "ecommerce"]
        

        
        print(impression)
        
        dataLayer.push(impression)
        
    }
    
    class func sendEcommerceClickBanner(banner:Banner) {
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["ecommerce": NSNull()])
        let promotion = ["id": banner.id, "name": banner.name, "creative": banner.creative, "position": banner.position]
        let impression = ["event": "promotionClick", "ecommerce": ["promoClick": ["promotions": [promotion]]]]
        dataLayer.push(impression)
    }
    
    class func sendAnalyticsTagImpressions(mgProducts:NSArray, positionArray:[Int], listName: String, subCategory: String, subSubCategory: String) {
        
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["ecommerce": NSNull()])
        var impressions: [[String : String]] = []
        var index = 0
        
        for mgProduct in mgProducts {
            
            index += 1
            
            guard let name = mgProduct["description"] as? String,
                  let id = mgProduct["upc"] as? String,
                  let price = mgProduct["price"] as? String,
                  let category = mgProduct["category"] as? String else {
                return
            }
            
            let brand = ""
            let variant = "pieza"
            let list = listName
            let position = "\(positionArray[index - 1])"
            let dimensions21 = "" // sku bundle
            let dimensions22 = subCategory // sub categoría del producto
            let dimensions23 = subSubCategory // sub sub categoría del producto
            let dimensions24 = "" // big item o no big item
            let dimensions25 = "" // super, exclusivo o compartido
            
            let impression = ["name": name, "id": id, "price": price, "brand": brand, "category": category, "variant": variant, "list": list, "position": position, "dimesions21": dimensions21, "dimesions22": dimensions22, "dimesions23": dimensions23, "dimesions24": dimensions24, "dimesions25": dimensions25]
            impressions.append(impression)
        }
        
        let data = [ "ecommerce": ["currencyCode": "MXN", "impressions": impressions], "event": "ecommerce"]
        dataLayer.push(data)
        
    }
    
    class func sendAnalyticsAddOrRemovetoCart(items:NSArray,isAdd:Bool) {
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
       dataLayer.push(["ecommerce": NSNull()])
        var productsAdd: [[String : String]] = []
        
        for item in items {
            
            let name = item["desc"] as? String ?? ""
            let upc = item["upc"] as? String ?? ""
            let quantity = item["quantity"] as? String ?? "1"
            
           print(UserCurrentSession.sharedInstance().nameListToTag)
            let sendCategory = isAdd ? UserCurrentSession.sharedInstance().nameListToTag : "Shopping Cart"
            let product = ["name":name,"id":upc,"brand":"","category":sendCategory,"variant":"pieza","quantity":quantity,"dimension21":"","dimension22":"","dimension23":"","dimension24":"","dimension25":""]
            
            productsAdd.append(product)
        
        }
        let ecommerce =  isAdd ? ["currencyCode": "MXN","add" :["products": productsAdd]] : ["remove" :["products": productsAdd]]
        
        
        print("event:addToCart")
        //print(push)
        dataLayer.push(["event": (isAdd ? "addToCart" : "removeFromCart") ,"ecommerce" :ecommerce])

        
    }
    
 
    
    
    
    class func setOpenScreenTagManager(titleScreen titleScreen:String,screenName:String){
       
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        print("setOpenScreenTagManager")
        print("event:openScreen")
        print("screenName:\(screenName)")
        print("userID:\(UserCurrentSession.hasLoggedUser() ? UserCurrentSession.sharedInstance().userSigned!.idUser : "")")
        print("guestID: \(UserCurrentSession.hasLoggedUser() ? UserCurrentSession.sharedInstance().userSigned!.idUser : "100")" )
        print("typePage:\(screenName)")
        print("pageTitle:\(titleScreen)")
        print("category:\(screenName)")
        print("subCategory:")
        print("subsubCategory:")
        print("visitorLoginStatus:\(UserCurrentSession.hasLoggedUser())")
        print("estatusArticulo:")
        
        
//        dataLayer.push([
//            "event":"openScreen",
//            "screenName":screenName,
//            "userID":UserCurrentSession.hasLoggedUser() ? UserCurrentSession.sharedInstance().userSigned!.idUser : "",
//            "guestID": UserCurrentSession.hasLoggedUser() ? UserCurrentSession.sharedInstance().userSigned!.idUser : "100" ,//TODO validar lo que se va a enviar
//            "typePage":screenName,
//            "pageTitle":titleScreen,
//            "category":"",
//            "subCategory":"",
//            "subsubCategory":"",
//            "visitorLoginStatus":UserCurrentSession.hasLoggedUser(),
//            "estatusArticulo":""
//            ])
        
    }
    
    //MARK: Tag de Errores
    class func sendTagManagerErrors(event:String,detailError:String){
        switch event {
        case "ErrorEvent":
             self.sendAnalyticsPush(["event":event,"detailError":detailError])
            break
        case "ErrorEventBusiness":
             self.sendAnalyticsPush(["event":event,"detailErrorBusiness":detailError])
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