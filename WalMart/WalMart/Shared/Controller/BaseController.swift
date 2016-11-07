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

struct ItemTag {
    var name : String = ""
    var quantity : String = "1"
    var price: String = ""
    var upc : String = ""
    var variant : Bool =  false
}

class BaseController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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


// MARK: - Analytics 360
extension BaseController {
    
    
    class func sendAnalytics(category:String, action: String, label:String){
        ////////
        //        print("Category: \(category) Action: \(action) Label: \(label)")
        //                if let tracker = GAI.sharedInstance().defaultTracker {
        //                    tracker.send(GAIDictionaryBuilder.createEventWithCategory(category,
        //                        action: action,
        //                        label: label, value: nil).build() as [NSObject : AnyObject])
        //                }
    }
    
    class func sendAnalytics(categoryAuth:String, categoryNoAuth:String, action: String, label:String){
        let category = UserCurrentSession.hasLoggedUser() ? categoryAuth : categoryNoAuth
        BaseController.sendAnalytics(category, action: action, label: label)
    }
    
    class func sendAnalyticsProductToList(upc: String, desc:String, price: String) {
        if let productPrice = price.toIntNoDecimals() {
            self.sendAnalyticsPush(["event": "addList", "skuProducto": upc, "descripcionProducto": desc, "valorProducto": productPrice])
        }
    }
    
    class func sendAnalyticsProductsToCart(totalPriceOfList: Int) {
        self.sendAnalyticsPush(["event": "addListCart", "valorLista": totalPriceOfList])
    }
    
    class func sendAnalyticsSuccesfulRegistration() {
         self.sendAnalyticsPush(["event": "registroExitoso"])
    }
    
    class func sendAnalyticsUnsuccesfulRegistrationWithError(error: String, stepError: String) {
         self.sendAnalyticsPush(["event": "errorRegistro", "errorDetail": error, "stepError": stepError])
    }
    
    class func sendAnalyticsIntentRegistration() {
         self.sendAnalyticsPush(["event": "intentoRegistro"])
    }
    
    class func sendAnalyticsPush(pushData:[String:AnyObject]) {
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["ecommerce": NSNull()])
        dataLayer.push(pushData)
    }
    
    class func sendAnalyticsBanners(banners:[Banner]) {
        
           var promotions: [[String : String]] = []
        
        for banner in banners {
            let banner = ["id": banner.id + "_ios", "name": banner.name +  "_ios", "creative": banner.creative, "position": banner.position]
            promotions.append(banner)
        }
        
        
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["ecommerce": NSNull()])
        dataLayer.push(["ecommerce": ["promoView":["promotions": promotions] ] ,"event":"ecommerce" ])
        
    }
    
    class func sendAnalyticsClickBanner(banner:Banner) {
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["ecommerce": NSNull()])
        let promotion = ["id": banner.id, "name": banner.name, "creative": banner.creative, "position": banner.position]
        let impression = ["event": "promotionClick", "ecommerce": ["promoClick": ["promotions": [promotion]]]]
        dataLayer.push(impression)
    }
    
    class func sendAnalyticsTagImpressions(products:NSArray, positionArray:[Int], listName: String, subCategory: String, subSubCategory: String) {
        
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["ecommerce": NSNull()])
        var impressions: [[String : String]] = []
        var index = 0
        
        for product in products {
            
            index += 1
            
            guard let name = product["description"] as? String,
                let id = product["upc"] as? String,
                let price = product["price"] else {
                    return
            }
            
            var category = ""
            if let parsedCategory = product["category"] as? String {
                category = parsedCategory
            }
            
            let brand = ""
            var variant = "pieza"
            
            if let type = product["type"] as? String {
                if type == "groceries" {
                    if let parsedVariant = product["pesable"] as? String {
                        if parsedVariant == "1" {
                            variant = "gramos"
                        }
                    }
                }
            }
            
            let list = listName
            let position = "\(positionArray[index - 1])"
            let dimensions21 = "" // sku bundle
            let dimensions22 = subCategory // sub categoría del producto
            let dimensions23 = subSubCategory // sub sub categoría del producto
            let dimensions24 = "" // big item o no big item
            let dimensions25 = "" // super, exclusivo o compartido
            
            let impression = ["name": name, "id": id, "price": "\(price)", "brand": brand, "category": category, "variant": variant, "list": list, "position": position, "dimesions21": dimensions21, "dimesions22": dimensions22, "dimesions23": dimensions23, "dimesions24": dimensions24, "dimesions25": dimensions25]
            impressions.append(impression)
        }
        
        let data = [ "ecommerce": ["currencyCode": "MXN", "impressions": impressions], "event": "ecommerce"]
        dataLayer.push(data)
        dataLayer.push(["ecommerce": NSNull()])
        
    }
    
    class func sendAnalyticsAddOrRemovetoCart(items:NSArray,isAdd:Bool) {
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["ecommerce": NSNull()])
        var productsAdd: [[String : String]] = []
        
        for item in items {
            
           let newItem = self.itemsToTag(item as! NSDictionary)
            
            print(UserCurrentSession.sharedInstance().nameListToTag)
            
            let sendCategory = isAdd ? UserCurrentSession.sharedInstance().nameListToTag : "Shopping Cart"
            
            let product = ["name":newItem.name , "price": newItem.price, "id":newItem.upc,"brand":"","category":sendCategory,"variant":newItem.variant ? "gramos" : "pieza","quantity":newItem.variant ? "1" : newItem.quantity,"dimension21":newItem.upc.contains("B") ? newItem.upc : "","dimension22":"","dimension23":"","dimension24":"false","dimension25":"","metric1":newItem.variant ? newItem.quantity : "" ]
            
            productsAdd.append(product)
            
        }
        
        let ecommerce =  isAdd ? ["currencyCode": "MXN","add" :["products": productsAdd]] : ["remove" :["products": productsAdd]]
        
        
        print("event:addToCart")
        //print(push)
        dataLayer.push(["event": (isAdd ? "addToCart" : "removeFromCart") ,"ecommerce" :ecommerce])
        
        
    }
    
    class func setOpenScreenTagManager(titleScreen titleScreen:String,screenName:String){
        
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        UserCurrentSession.sharedInstance().screenSubSubCategory = UserCurrentSession.sharedInstance().screenSubCategory
        UserCurrentSession.sharedInstance().screenSubCategory = UserCurrentSession.sharedInstance().screenCategory
        UserCurrentSession.sharedInstance().screenCategory = screenName
        print("setOpenScreenTagManager")
        print(" screenName \(screenName) - \(subCategory: UserCurrentSession.sharedInstance().screenSubCategory, subsubCategory: UserCurrentSession.sharedInstance().screenSubSubCategory)")
        
        dataLayer.push([
            "event":"openScreen",
            "screenName":screenName,
            "userID":UserCurrentSession.hasLoggedUser() ? UserCurrentSession.sharedInstance().userSigned!.idUser : "",
            "guestID": UserCurrentSession.hasLoggedUser() ? UserCurrentSession.sharedInstance().userSigned!.idUser : UIDevice.currentDevice().identifierForVendor!.UUIDString,
            "typePage":screenName,
            "pageTitle":titleScreen,
            "category":screenName,
            "subCategory": UserCurrentSession.sharedInstance().screenSubCategory,
            "subsubCategory": UserCurrentSession.sharedInstance().screenSubSubCategory,
            "visitorLoginStatus":UserCurrentSession.hasLoggedUser(),
            "estatusArticulo":""
            ])
        
    }
    
    
    
    //MARK: Checkout - Revisar pedido 
    
    class func sendAnalyticsPreviewCart(paymentType:String) {
        let products =  UserCurrentSession.sharedInstance().itemsGR
        let items = products!["items"] as? NSArray
        
        
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["ecommerce": NSNull()])
        var productsAdd: [[String : String]] = []
        if items?.count > 0 {
            for item in items! {
                
              let newItem = self.itemsToTag(item as! NSDictionary)
                
                
                let products = ["name":newItem.name ,"id":newItem.upc,"brand":"","category":"","variant":newItem.variant ? "gramos" : "pieza","quantity": newItem.variant ? "1" :newItem.quantity,"dimension21":newItem.upc.contains("B") ? newItem.upc : "","dimension22":"","dimension23":"","dimension24":"false","dimension25":"","metric1":newItem.variant ? newItem.quantity : "" ]
                
                productsAdd.append(products)
                
                
            }
            
            let ecommerce = ["checkout":["step":"3","option":paymentType,"products":productsAdd]]
            dataLayer.push(["event":"checkout","ecommerce":ecommerce])
        }
        
        print("sendAnalyticsPurchaseCart")
        
    }

    
    class func sendAnalyticsPurchase(sucursal: AnyObject, paymentType:String, deliveryType: String, deliveryDate: String, deliveryHour: String, purchaseId: AnyObject, affiliation: String, revenue: String, tax: String, shipping:String, coupon: String ) {
        
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["ecommerce": NSNull()])
        
        let products =  UserCurrentSession.sharedInstance().itemsGR
        let items = products!["items"] as? NSArray
        var productsAdd: [[String : String]] = []
        
        for item in items! {
            let newItem = self.itemsToTag(item as! NSDictionary)
            let products = ["name": newItem.name , "id": newItem.upc, "price": newItem.price, "brand": "", "category": "", "variant": newItem.variant ? "gramos" : "pieza", "quantity": newItem.variant ? "1" :newItem.quantity, "coupon": "","metric1":newItem.variant ? newItem.quantity : ""]
            productsAdd.append(products)
        }
        
        let ecomerce =  ["event": "ecommerce", "ecommerce":["purchase":["sucursal": sucursal, "formaPago": paymentType, "tipoEntrega": deliveryType, "fechaEntrega": deliveryDate, "horaEntrega": deliveryHour, "numeroCompraClientes": "1", "tipoTarjeta": "", "banco": "", "MSI": "", "carrier": "", "codigoPostalEntrega": "", "ciudadEntrega": "", "estadoEntrega": "", "actionField": ["id": purchaseId, "affiliation": affiliation, "revenue": revenue, "tax": tax, "shipping": shipping,"coupon": coupon, "products": productsAdd]]]]
        
        dataLayer.push(ecomerce)
        print("sendAnalyticsPreviewCart")
    }
    
    class func itemsToTag(item:NSDictionary) -> ItemTag {
        
        var itemsTag = ItemTag()
       
        if let desc =  item["desc"] as? String {
            itemsTag.name = desc
        }else if let  desc = item["description"] as? String {
            itemsTag.name = desc
        }else if let  desc = item["name"] as? String {
            itemsTag.name = desc
        }
        
        itemsTag.upc = item["upc"] as? String ?? ""
        
        if let quantityItem =  item["quantity"] as? String {
            itemsTag.quantity = quantityItem != "0" ? quantityItem : "1"
        }else if let quantityItem =  item["quantity"] as? Int {
         itemsTag.quantity = "\(quantityItem)"
        }
        
        if let price = item["price"] as? String {
            itemsTag.price = price
        } else if let price = item["price"] as? NSNumber {
            itemsTag.price = "\(price)"
        }
        
        if let isPesable = item["pesable"] as? Bool {
             itemsTag.variant = isPesable
        }else if let isPesable = item["pesable"] as? NSNumber {
             itemsTag.variant = (isPesable == 1)
        }else if let isPesable = item["pesable"] as? String {
             itemsTag.variant = (isPesable == "true" || isPesable == "1" )
        }
        
        return itemsTag 
    }
    
    
    //MARK: Tag de Errores
    
    class func sendTagManagerErrors(event:String,detailError:String){
        switch event {
        case "ErrorEvent":
            self.sendAnalyticsPush(["event":event,"detailError":detailError])
            break
        case "ErrorEventBusiness":
            //self.sendAnalyticsPush(["event":event,"detailErrorBusiness":detailError])
            break
        default:
            break
        }
        
    }

}
    