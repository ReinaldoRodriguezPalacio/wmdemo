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
    
    func invokeSaveListToDuplicateService(forListId products:[AnyObject], andName listName:String,successDuplicateList:(() -> Void)) {
        alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.copy.inProcess", comment:""))
        
        
                let service = GRSaveUserListService()
                var items: [AnyObject] = []
                //if let products = result["items"] as? NSArray {
                    for idx in 0 ..< products.count {
                        var product = products[idx] as! [String:AnyObject]
                        let quantity = product["quantity"] as! NSNumber
                        var  nameLine = ""
                        if let line = product["line"] as? NSDictionary {
                            nameLine = line["name"] as! String
                        }
                        if let upc = product["upc"] as? String {
                            let item = service.buildProductObject(upc: upc, quantity: quantity.integerValue, image: nil, description: nil, price: nil, type:nil,nameLine: nameLine)
                            items.append(item)
                        }
                    }
                //}
                
                let copyName = self.buildDuplicateNameList(listName)
                print("duplicate::List")
                print(service.jsonFromObject(service.buildParams(copyName, items: items)))
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
        

        
    }
    
    
    
    func buildDuplicateNameList(theName:String) -> String {
        var listName = "\(theName)" //Se crea una nueva instancia
        let whitespaceset = NSCharacterSet.whitespaceCharacterSet()
        var arrayOfIndex: [Int] = []
        if let range = listName.rangeOfString("copia", options: .LiteralSearch, range: nil, locale: nil) {
            listName = listName.substringToIndex(range.startIndex)
        }
        listName = listName.stringByTrimmingCharactersInSet(whitespaceset)
        
        if itemsUserList!.count > 0 {
            for idx in 0 ..< itemsUserList!.count {
                var name:String? = nil
                var stringIndex: String? = nil
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
                        stringIndex = name!.substringFromIndex(range.endIndex)
                        name = name!.substringToIndex(range.startIndex)
                    }
                    name = name!.stringByTrimmingCharactersInSet(whitespaceset)
                    if stringIndex != nil {
                        stringIndex = stringIndex!.stringByTrimmingCharactersInSet(whitespaceset)
                        if name!.hasPrefix(listName) {
                            stringIndex = stringIndex! == "" ? "1" : stringIndex
                            arrayOfIndex.append(Int(stringIndex!)!)
                        }
                    }
                }
            }
        }
        let listIndexes = Set([1,2,3,4,5,6,7,8,9,10,11,12])
        let dispinibleIndex = listIndexes.subtract(arrayOfIndex).minElement()
        let idxTxt = dispinibleIndex! == 1 ? NSLocalizedString("list.copy.name", comment: "") : "\(NSLocalizedString("list.copy.name", comment: "")) \(dispinibleIndex!)"
        
        /*if self.existnameList("\(listName) \(idxTxt)"){
            idxTxt = lastIdx == 1 ? "copia" : "copia \(lastIdx++)"
        }*/
        
        var returnName =  "\(listName) \(idxTxt)"
        if returnName.length() > 25 {
            returnName = (returnName as NSString).substringToIndex(24)
            returnName = "\(returnName)\(dispinibleIndex!)"
        }
        
        return returnName
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