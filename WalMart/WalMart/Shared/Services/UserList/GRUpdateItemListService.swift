//
//  GRUpdateItemListService.swift
//  WalMart
//
//  Created by neftali on 12/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class GRUpdateItemListService: GRBaseService {
    
    var listId: String = ""
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
    }()

    //[{"upc": "0750105530007", "quantity": 3.0, "comments": "", "longDescription": "", "pesable": "", "equivalenceByPiece": "", "promoDescription": "", "productIsInStores": ""}]
    
    func buildParams(upc:String, quantity:Int,baseUomcd:String) -> [Any] {
        return [self.buildProductObject(upc: upc, quantity: quantity) as AnyObject]
    }
    
    func buildProductObject(upc:String, quantity:Int) -> [String:Any] {
        return ["upc":upc, "quantity":quantity, "comments":"", "longDescription": "", "pesable": "", "equivalenceByPiece": "", "promoDescription": "", "productIsInStores": ""]
    }
    
    func callService(_ params:[Any], successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)?) {
        self.callPOSTService(params,
            successBlock: { (resultCall:[String:Any]) -> Void in
                let product = params.first  as! [String:Any]
                let upc = product["upc"] as! String
                let items = resultCall["items"] as! [Any]
                let resultProduct = self.getResultProduct(items: items, productupc: upc)
                self.syncProductInList(product: resultProduct)
                successBlock?(resultCall)
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }
    
    func getResultProduct(items: [Any], productupc: String) ->   [String:Any]{
        var resultProduct: [String:Any] = [:]
        for item in items as! [[String:Any]]{
            let itemUpc = item["upc"] as! String
            if itemUpc == productupc {
                resultProduct = item
                break
            }
        }
        return resultProduct
    }
    
    func syncProductInList(product: [String:Any]) {
        if product.count == 0 {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "List" as String, in: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "idList == %@", self.listId)
        var result: [List] = (try! self.managedContext!.fetch(fetchRequest)) as! [List]
        var list: List? = nil
        if result.count > 0 {
            list = result[0]
        }
        
        if list != nil {
            let upc = product["upc"] as! String
            let fetchRequestProduct = NSFetchRequest<NSFetchRequestResult>()
            fetchRequestProduct.entity = NSEntityDescription.entity(forEntityName: "Product", in: self.managedContext!)
            fetchRequestProduct.predicate = NSPredicate(format: "list == %@ && upc == %@", list!,upc)
            let resultProduct: [Product] = (try! self.managedContext!.fetch(fetchRequestProduct)) as! [Product]
            if resultProduct.count > 0 {
                for detail in resultProduct {
                    detail.upc = upc

                    var quantity: Int32 = 0
                    if let quantityNumber = product["quantity"] as? NSNumber {
                        quantity = Int32(quantityNumber.intValue)
                    }
                    else if let quantityString = product["quantity"] as? String {
                         quantity = Int32(quantityString)!
                    }
                
                    var equivalenceByPiece : NSNumber = 0
                    if let equiva = product["equivalenceByPiece"] as? NSNumber {
                        equivalenceByPiece =  equiva
                    }else if let equiva = product["equivalenceByPiece"] as? Int {
                        equivalenceByPiece =  NSNumber(value: equiva)
                    }else if let equiva = product["equivalenceByPiece"] as? String {
                        if equiva != "" { equivalenceByPiece =   NSNumber(value:Int(equiva)!) }
                    }
                    
                    if let baseUomcd = product["baseUomcd"] as? String {
                      detail.orderByPiece = (baseUomcd == "EA" ? 1 : 0)
                    }
                    
                    detail.equivalenceByPiece =  equivalenceByPiece
                    detail.pieces = NSNumber(value: quantity)
                    detail.quantity = NSNumber(value: quantity)
                    
                    detail.list = list!
                }
                var error: NSError? = nil
                do {
                    try self.managedContext!.save()
                } catch let error1 as NSError {
                    error = error1
                }
                if error != nil {
                    print("error at update details: \(error!.localizedDescription)")
                }
            }
        }
    }

}
