//
//  UserListNavigationBaseViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/08/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class UserListNavigationBaseViewController :  NavigationViewController {
    
    
    var itemsUserList: [AnyObject]? = []
    var alertView: IPOWMAlertViewController?
    
    func invokeSaveListToDuplicateService(forListId listId:String, andName listName:String,successDuplicateList:(() -> Void)) {
        alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.copy.inProcess", comment:""))
        
        let detailService = GRUserListDetailService()
        detailService.buildParams(listId)
        detailService.callService([:],
            successBlock: { (result:NSDictionary) -> Void in
                
                let service = GRSaveUserListService()
                var items: [AnyObject] = []
                if let products = result["items"] as? NSArray {
                    for var idx = 0; idx < products.count; idx++ {
                        var product = products[idx] as! [String:AnyObject]
                        let quantity = product["quantity"] as! NSNumber
                        if let upc = product["upc"] as? String {
                            let item = service.buildProductObject(upc: upc, quantity: quantity.integerValue, image: nil, description: nil, price: nil, type:nil)
                            items.append(item)
                        }
                    }
                }
                
                let copyName = self.buildDuplicateNameList(listName, forListId: listId)
                service.callService(service.buildParams(copyName, items: items),
                    successBlock: { (result:NSDictionary) -> Void in
                        successDuplicateList()
                    },
                    errorBlock: { (error:NSError) -> Void in
                        print("Error at duplicate list")
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                    }
                )
                
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at retrieve list detail")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            }
        )
        
    }
    
    
    
    func buildDuplicateNameList(theName:String, forListId listId:String?) -> String {
        var listName = "\(theName)" //Se crea una nueva instancia
        let whitespaceset = NSCharacterSet.whitespaceCharacterSet()
        if let range = listName.rangeOfString("copia", options: .LiteralSearch, range: nil, locale: nil) {
            listName = listName.substringToIndex(range.startIndex)
        }
        listName = listName.stringByTrimmingCharactersInSet(whitespaceset)
        
        var lastIdx = 1
        if itemsUserList!.count > 0 {
            for var idx = 0; idx < itemsUserList!.count; idx++ {
                var name:String? = nil
                if let innerList = itemsUserList![idx] as? [String:AnyObject] {
                    //let innerListId = innerList["id"] as! String
                    //if innerListId == listId! {
                      //  continue
                    //}
                    name = innerList["name"] as? String
                }
                else if let listEntity = itemsUserList![idx] as? List {
                    name = listEntity.name
                }
                
                if name != nil {
                    if let range = name!.rangeOfString("copia", options: .LiteralSearch, range: nil, locale: nil) {
                        name = name!.substringToIndex(range.startIndex)
                    }
                    name = name!.stringByTrimmingCharactersInSet(whitespaceset)
                    
                    if name!.hasPrefix(listName) {
                        lastIdx++
                    }
                }
            }
        }
        
        let idxTxt = lastIdx == 1 ? "copia" : "copia \(lastIdx)"
        
        /*if self.existnameList("\(listName) \(idxTxt)"){
            idxTxt = lastIdx == 1 ? "copia" : "copia \(lastIdx++)"
        }*/
        
        
        return "\(listName) \(idxTxt)"
    }
    
    /*func existnameList(nameList:String)->Bool{
        var nameExist = false
        
        if itemsUserList!.count > 0 {
            for var idx = 0; idx < itemsUserList!.count; idx++ {
                if let listEntity = itemsUserList![idx] as? List {
                    if nameList ==  listEntity.name {
                        nameExist =  true
                    }
                }
            }
        }
        
        return nameExist
    
    }*/
    
    
}