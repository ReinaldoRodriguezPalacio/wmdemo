//
//  UserListNavigationBaseViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/08/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class UserListNavigationBaseViewController :  NavigationViewController {
    
    
    var itemsUserList: [Any]? = []
    var alertView: IPOWMAlertViewController?
    
    func invokeSaveListToDuplicateService(forListId listId:String, andName listName:String,successDuplicateList:@escaping (() -> Void)) {
        alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.copy.inProcess", comment:""))
        
        let detailService = GRUserListDetailService()
        detailService.buildParams(listId)
        detailService.callService([:],
            successBlock: { (result:[String:Any]) -> Void in
                
                let service = GRSaveUserListService()
                var items: [Any] = []
                if let products = result["items"] as? [Any] {
                    for idx in 0 ..< products.count {
                        var product = products[idx] as! [String:Any]
                        let quantity = product["quantity"] as! NSNumber
                        let price = product["price"] as! NSNumber
                        let dsc = product["description"] as! String
                        let baseUomcd = product["baseUomcd"] as! String
                         let stock = product["stock"] as? Bool ?? true
                      
                        if let upc = product["upc"] as? String {
                            let item = service.buildProductObject(upc: upc, quantity: quantity.intValue, image: nil, description: nil, price: nil, type:nil,baseUomcd: baseUomcd,equivalenceByPiece: 0 ,stock:stock )//baseUomcd and equivalenceByPiece
                            items.append(item)
                            
                            // 360 Event
                            BaseController.sendAnalyticsProductToList(upc, desc: dsc, price: "\(price as Int)")
                            
                        }
                    }
                }
                
                let copyName = self.buildDuplicateNameList(listName, forListId: listId)
                service.callService(service.buildParams(copyName, items: items),
                    successBlock: { (result:[String:Any]) -> Void in
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
                if error.code != -100 {
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                }else{
                    self.alertView?.close()
                }
               
            }
        )
        
    }
    
    
    
    func buildDuplicateNameList(_ theName:String, forListId listId:String?) -> String {
        var listName = "\(theName)" //Se crea una nueva instancia
        let whitespaceset = CharacterSet.whitespaces
        var arrayOfIndex: [Int] = []
        if let range = listName.range(of: "copia", options: .literal, range: nil, locale: nil) {
            listName = listName.substring(to: range.lowerBound)
        }
        listName = listName.trimmingCharacters(in: whitespaceset)
        
        if itemsUserList!.count > 0 {
            for idx in 0 ..< itemsUserList!.count {
                var name:String? = nil
                var stringIndex: String? = nil
                if let innerList = itemsUserList![idx] as? [String:Any] {
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
                    if let range = name!.range(of: "copia", options: .literal, range: nil, locale: nil) {
                        stringIndex = name!.substring(from: range.upperBound)
                        name = name!.substring(to: range.lowerBound)
                    }
                    name = name!.trimmingCharacters(in: whitespaceset)
                    if stringIndex != nil {
                        stringIndex = stringIndex!.trimmingCharacters(in: whitespaceset)
                        if name!.hasPrefix(listName) {
                            stringIndex = stringIndex! == "" ? "1" : stringIndex
                            arrayOfIndex.append(Int(stringIndex!)!)
                        }
                    }
                }
            }
        }
        let listIndexes = Set([1,2,3,4,5,6,7,8,9,10,11,12,13])
        let dispinibleIndex = listIndexes.subtracting(arrayOfIndex).min()
        let idxTxt = dispinibleIndex! == 1 ? "copia" : "copia \(dispinibleIndex!)"
        
        /*if self.existnameList("\(listName) \(idxTxt)"){
            idxTxt = lastIdx == 1 ? "copia" : "copia \(lastIdx++)"
        }*/
        
        var returnName =  "\(listName) \(idxTxt)"
        if returnName.length() > 25 {
            returnName = (returnName as NSString).substring(to: 24)
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
