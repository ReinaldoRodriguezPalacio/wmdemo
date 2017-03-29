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
    
    func invokeSaveListToDuplicateService(forListId products:[Any], andName listName:String,successDuplicateList:@escaping (() -> Void)) {
        alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.copy.inProcess", comment:""))
        
        
                let service = GRSaveUserListService()
                let serviceAdd = GRAddItemListService()
                var items: [Any] = []
                //if let products = result["items"] as? NSArray {
                    for idx in 0 ..< products.count {
                        var product = products[idx] as! [String:Any]
                        let quantity = product["quantityDesired"] as! String
                        var  nameLine = ""
                        if let line = product["line"] as? [String:Any] {
                            nameLine = line["name"] as! String
                        }
                        
                        if let sku = product["sku"] as? [String:Any] {
                            if let parentProducts = sku["parentProducts"] as? [[String:Any]]{
                                if let itemParent =  parentProducts[0] as? [String:Any] {
                                    
                                    //let itemAdd = service.buildProductObject(upc: itemParent["repositoryId"] as! String, quantity: Int(quantity)!, image: nil, description: nil, price: nil, type:nil,nameLine: nameLine)
                                    let itemAdd = serviceAdd.buildItemMustang(itemParent["repositoryId"] as! String, sku:sku["id"] as! String , quantity: Int(quantity)!, comments:"")
                                    items.append(itemAdd)
                                }
                            }
                        }
                        
                       
                    }
                //}
                
                let copyName = self.buildDuplicateNameList(listName)
                print("duplicate::List")
        //saveService.buildParamsMustang(name)
        //service.buildParams(copyName, items: items)
                print(service.jsonFromObject(service.buildParamsMustang(copyName) as AnyObject!))//invocar servicios como en tiket
        
        
                service.callService(service.buildParamsMustang(copyName),
                    successBlock: { (result:[String:Any]) -> Void in
                        let idList = result["idList"] as! String
                        //profileId
                        serviceAdd.callService(serviceAdd.buildItemMustangObject(idList: idList, upcs: items, profileId:UserCurrentSession.sharedInstance.userSigned!.idUser as String), successBlock: { (result:[String:Any]) in
                            
                            successDuplicateList()
                            
                            }, errorBlock: { (error:NSError) in
                                self.alertView!.setMessage(error.localizedDescription)
                                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                                
                        })
                        
                    },
                    errorBlock: { (error:NSError) -> Void in
                        print("Error at duplicate list")
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                    }
                )
        

        
    }
    
    
    
    func buildDuplicateNameList(_ theName:String) -> String {
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
        let listIndexes = Set([1,2,3,4,5,6,7,8,9,10,11,12])
        let dispinibleIndex = listIndexes.subtracting(arrayOfIndex).min()
        let idxTxt = dispinibleIndex! == 1 ? NSLocalizedString("list.copy.name", comment: "") : "\(NSLocalizedString("list.copy.name", comment: "")) \(dispinibleIndex!)"
        
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
