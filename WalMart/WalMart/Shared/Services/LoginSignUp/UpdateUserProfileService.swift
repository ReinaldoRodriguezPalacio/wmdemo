//
//  UpdateUserProfileService.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 04/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class UpdateUserProfileService : BaseService {
    
    func buildParamsWithMembership(_ email:String,password:String,newPassword: String,name:String,lastName:String,birthdate:String,gender:String,allowTransfer:String,allowMarketingEmail:String) -> [String:Any] {
        return ["email":email,"password":password,"newPassword":newPassword,"profile":["name":name,"lastName":lastName, "birthdate":birthdate,"gender": gender,"allowTransfer": allowTransfer,"allowMarketingEmail": allowMarketingEmail]]
    }
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.integerValue == 0 {
                  
                    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                    var usr : User
                    
                    let email = params["email"] as! String;
                    let predicate = NSPredicate(format: "email == %@ ", email)
                    let array =  self.retrieve("User" ,sortBy:nil,isAscending:true,predicate:predicate) as! [Any]
        
                    if array.count > 0{
                        usr = array[0] as! User
                        
                        let resultProfileJSON = params["profile"] as! [String:Any]
                        
                        usr.profile.name = resultProfileJSON["name"] as! String
                        usr.profile.lastName = resultProfileJSON["lastName"] as! String
                        do {
                            try context.save()
                        } catch let error1 as NSError {
                            print(error1.description)
                        } catch {
                            fatalError()
                        }
                        UserCurrentSession.sharedInstance().userSigned = usr
                        successBlock!(resultCall)
                    }
                }
                else{
                    let errorDom = NSError(domain: "com.bcg.service.error", code: 0, userInfo: nil)
                    //let message = resultCall["message"] as! String
                    //errorDom(message, forKey:codeMessage)
                    errorBlock!(errorDom)
                }
            }
            
            
            
            }) { (error:NSError) -> Void in
                errorBlock!(error)
            }
    }
}
