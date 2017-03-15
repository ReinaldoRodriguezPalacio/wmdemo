//
//  GRAddItemListService.swift
//  WalMart
//
//  Created by neftali on 22/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class GRAddItemListService: GRBaseService {
    
    func buildParams(idList:String, upcs:[Any]?) -> [String:Any]! {
        //{"idList":"26e50bc7-3644-48d8-a51c-73d7536ab30d","itemArrImp":[{"longDescription":"","quantity":1.0,"upc":"0065024002180","pesable":"","equivalenceByPiece":"","promoDescription":"","productIsInStores":""}]}
        return ["idList":idList, "itemArrImp":upcs!]
    }
    
    func buildProductObject(upc:String, quantity:Int,pesable:String,active:Bool,baseUomcd:String) -> [String:Any] {
        //{"longDescription":"","quantity":1.0,"upc":"0065024002180","pesable":"","equivalenceByPiece":"","promoDescription":"","productIsInStores":""}
        return ["longDescription" : "", "quantity" : quantity, "upc" : upc, "pesable" : pesable, "equivalenceByPiece" : "", "promoDescription" : "", "productIsInStores" : "","isActive":active,"baseUomcd":baseUomcd]
    }
    
    func buildProductObject(upc:String, quantity:Int,pesable:String,baseUomcd:String) -> [String:Any] {
        // {"longDescription":"","quantity":1.0,"upc":"0065024002180","pesable":"","equivalenceByPiece":"","promoDescription":"","productIsInStores":""}
        return ["longDescription" : "", "quantity" : quantity, "upc" : upc, "pesable" : pesable, "equivalenceByPiece" : "", "promoDescription" : "", "productIsInStores" : "","baseUomcd":baseUomcd]
    }
    
    func callService(_ params:[String:Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        var toSneditem : [String:Any] = [:]
        let arrayItems = params["itemArrImp"] as! [[String:Any]]
        var arrayToSend : [[String:Any]] = []
        for item in arrayItems {
            let paramUpc = item["upc"] as! String
            let paramQuantity = item["quantity"] as! Int
            let paramPesable = item["pesable"] as! String
            let paramBaseUomcd = item["baseUomcd"] as! String
            
            let toSendUPC = buildProductObject(upc: paramUpc, quantity: paramQuantity, pesable: paramPesable,baseUomcd:paramBaseUomcd)
            arrayToSend.append(toSendUPC)
        }
        toSneditem["idList"] = params["idList"] as! String
        toSneditem["itemArrImp"] = arrayToSend
        
        self.callPOSTService(toSneditem,
            successBlock: { (resultCall:[String:Any]) -> Void in
                //self.jsonFromObject(resultCall)
                self.manageList(resultCall)
                successBlock?(resultCall)
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
        
        
    }
    
    func manageList(_ list:[String:Any]) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        if  let listId = list["id"] as? String {
            
            let user = UserCurrentSession.sharedInstance.userSigned
            var entity : List?  = nil
            if user!.lists != nil {
                let userLists : [List] = user!.lists!.allObjects as! [List]
                
                let resultLists = userLists.filter({ (list:List) -> Bool in
                    return list.idList == listId
                })
                if resultLists.count > 0 {
                    entity = resultLists[0]
                }
            }
            if entity == nil {
                entity = NSEntityDescription.insertNewObject(forEntityName: "List", into: context) as? List
                entity!.idList = listId
                entity!.user = UserCurrentSession.sharedInstance.userSigned!
                entity!.registryDate = Date()
                entity!.name = list["name"] as! String
                //println("Creating user list \(listId)")
                
                var error: NSError? = nil
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                }
                if error != nil {
                    print("error at save list: \(error!.localizedDescription)")
                }
            }
            else {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
                fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
                fetchRequest.predicate = NSPredicate(format: "list == %@", entity!)
                let result: [Product] = (try! context.fetch(fetchRequest)) as! [Product]
                if result.count > 0 {
                    for listDetail in result {
                        //println("Delete product list \(listDetail.upc)")
                        context.delete(listDetail)
                    }
                    do {
                        try context.save()
                    } catch let error1 as NSError {
                        print("error at delete details: \(error1.localizedDescription)")
                    }
                }
            }
            
            if let items = list["items"] as? [Any] {
                entity!.countItem = NSNumber(value: items.count as Int)
                
                for idx in 0 ..< items.count {
                    var item = items[idx] as! [String:Any]
                    let detail = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as? Product
                    detail!.upc = item["upc"] as! String
                    detail!.img = item["imageUrl"] as! String
                    detail!.desc = item["description"] as! String
                    if let active = item["isActive"] as? Bool {
                        detail!.isActive = active ? "true" : "false"
                    }
                    
                    if let price = item["price"] as? NSNumber {
                        detail!.price = "\(price)" as NSString
                    }
                    else if let price = item["price"] as? String {
                        detail!.price = price as NSString
                    }
                    
                    var quantity: Int = 0
                    if  let qIntProd = item["quantity"] as? Int {
                        quantity = qIntProd
                    }else if  let qIntProd = item["quantity"] as? NSString {
                        quantity = qIntProd.integerValue
                    }
                    
                    var typeProdVal: Int = 0
                    if let typeProd = item["type"] as? NSString {
                        typeProdVal = typeProd.integerValue
                    }
                    var equivalenceByPiece : NSNumber = 0
                    if let equiva = item["equivalenceByPiece"] as? NSNumber {
                        equivalenceByPiece =  equiva
                    }else if let equiva = item["equivalenceByPiece"] as? Int {
                        equivalenceByPiece =  NSNumber(value: equiva)
                    }else if let equiva = item["equivalenceByPiece"] as? String {
                        if equiva != "" {
                            equivalenceByPiece =   NSNumber(value:Int(equiva)!)
                        }
                    }
                    
                    var baseUomcd = "EA"
                    if  let baseUomcdP = item["baseUomcd"] as? String {
                        baseUomcd = baseUomcdP
                    }
                    
//                    if quantity > 20000 && baseUomcd == "GM" {
//                        quantity = 20000
//                    }else if quantity > 99 && baseUomcd == "EA"{
//                        quantity = 99
//                    }
                    
                    detail!.quantity = NSNumber(value: quantity as Int)
                    detail!.type = NSNumber(value: typeProdVal as Int)
                    detail?.orderByPiece = (baseUomcd == "EA") ? 1 : 0
                    detail?.equivalenceByPiece =  equivalenceByPiece
                    detail!.pieces = NSNumber(value: quantity as Int)
                    
                    detail!.list = entity!
                }
                
                var error: NSError? = nil
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                }
                if error != nil {
                    print("error at delete details: \(error!.localizedDescription)")
                }
                
            }
        }
        
    }
}
