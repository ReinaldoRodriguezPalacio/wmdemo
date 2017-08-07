//
//  SEaddToCartListService.swift
//  WalMart
//
//  Created by Vantis on 07/08/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class SEaddToCartListService : GRBaseService {
    
    override init() {
        super.init()
    }
    
    func buildParamitemsSuperMinutos(_ quantity:String, upc:String, comments:String, baseUomcd:String) -> [String:Any] {
        let quantityInt : Int = Int(quantity)!
        //return [["quantity":quantityInt,"upc":upc,"comments":comments,"baseUomcd":baseUomcd]] //new piesas[EA]/gramos[GM]
        return ["quantity":quantityInt,"upc":upc,"comments":comments,"baseUomcd":baseUomcd]
    }
    
    func buildParametersSuperMinutos(busqueda:String, channel:String) -> [String:Any] {
        //return [["quantity":quantityInt,"upc":upc,"comments":comments,"baseUomcd":baseUomcd]] //new piesas[EA]/gramos[GM]
        return ["eventtype":"addtocart","q":busqueda,"collection": "dah","channel":channel, "position":"0", "module":"tusuper"]
    }
    
    func buildProductObjectSuperMinutos(_ upcsParams:[[String:Any]], parameter:[String:Any]) -> [String:Any] {
        
        return   ["items":upcsParams,"parameter":parameter]
        
    }
    
    
    func callService(params: [String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.setManagerTempHeader()
        self.callPOSTService(params,
                             successBlock: { (resultCall:[String:Any]) -> Void in
                                if let values = resultCall["responseArray"] as? [Any] {
                                    print(values)
                                }
                                successBlock?(resultCall)
                                return
        }, errorBlock: { (error:NSError) -> Void in
            errorBlock?(error)
            return
        }
        )
    }
    
    func setManagerTempHeader() {
        let timeInterval = Date().timeIntervalSince1970
        let timeStamp  = String(NSNumber(value: (timeInterval * 1000) as Double).intValue)
        let uuid  = UUID().uuidString
        let strUsr  = "ff24423eefbca345" + timeStamp + uuid
        AFStatic.manager.requestSerializer.setValue(timeStamp, forHTTPHeaderField: "timestamp")
        AFStatic.manager.requestSerializer.setValue(uuid, forHTTPHeaderField: "requestID")
        AFStatic.manager.requestSerializer.setValue(strUsr.sha1(), forHTTPHeaderField: "control")
    }
    
    func callCoreDataService(_ params:Any, successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        //BaseController.sendAnalyticsAddOrRemovetoCart(params as! [Any], isAdd: true)
        
        for product in params as! [[String:Any]] {
            
            var cartProduct : Cart
            var predicate = NSPredicate(format: "product.upc == %@ ",product["upc"] as! NSString)
            
            if UserCurrentSession.hasLoggedUser() {
                predicate = NSPredicate(format: "product.upc == %@ AND user == %@ ",product["upc"] as! NSString,UserCurrentSession.sharedInstance.userSigned!)
            }
            
            let array : [Cart] =  self.retrieve("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
            if array.count == 0 {
                cartProduct = NSEntityDescription.insertNewObject(forEntityName: "Cart" as String, into: context) as! Cart
                let productBD =  NSEntityDescription.insertNewObject(forEntityName: "Product" as String, into: context) as! Product
                cartProduct.product = productBD
            }else{
                cartProduct = array[0]
            }
            
            let quantityStr = product["quantity"] as? NSString
            cartProduct.quantity = NSNumber(value: (quantityStr?.intValue)!)
            
            print("Product in shopping cart: \(product)")
            
            var pesable : NSString = "0"
            
            if let pesableP = product["pesable"] as? NSString {
                pesable = pesableP
            }
            
            if let orderpiece = product["orderByPieces"] as? NSNumber {
                cartProduct.product.orderByPiece = orderpiece
            }
            
            if let totalPieces = product["pieces"] as? NSNumber {
                cartProduct.product.pieces = totalPieces
            }
            
            cartProduct.product.upc = product["upc"] as! String
            cartProduct.product.price = product["price"] as! NSString
            cartProduct.product.desc = product["desc"] as! String
            cartProduct.product.img = product["imageURL"] as! String
            cartProduct.product.onHandInventory = product["onHandInventory"] as! String
            cartProduct.product.iva = ""
            cartProduct.product.baseprice = ""
            cartProduct.product.type = NSNumber(value: pesable.integerValue)
            cartProduct.status = NSNumber(value: statusForProduct() as Int)
            cartProduct.type = ResultObjectType.Groceries.rawValue
            
            if let comment  = product["comments"] as? NSString {
                cartProduct.note = comment.trimmingCharacters(in: CharacterSet.whitespaces)
            }
            
            if UserCurrentSession.hasLoggedUser() {
                cartProduct.user  = UserCurrentSession.sharedInstance.userSigned!
            }
            
        }
        
        do {
            try context.save()
        } catch let error1 as NSError {
            print(error1.description)
        }
        
        WishlistService.shouldupdate = true
        NotificationCenter.default.post(name: .reloadWishList, object: nil)
        
        UserCurrentSession.sharedInstance.loadGRShoppingCart({ () -> Void in
            UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
        })
        
        let shoppingService = ShoppingCartProductsService()
        shoppingService.callCoreDataService([:], successBlock: successBlock, errorBlock: errorBlock)
    }
    
    func statusForProduct() -> Int {
        return CartStatus.created.rawValue
    }
    
    func updateShoppingCart() -> Bool {
        return true
    }
    
    override func needsToLoginCode() -> Int {
        return -100
    }

    
}
