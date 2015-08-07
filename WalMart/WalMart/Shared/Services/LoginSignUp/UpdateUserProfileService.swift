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
    
    func buildParamsWithMembership(email:String,password:String,newPassword: String,name:String,lastName:String,birthdate:String,gender:String,allowTransfer:String,allowMarketingEmail:String) -> NSDictionary {
        return ["email":email,"password":password,"newPassword":newPassword,"profile":["name":name,"lastName":lastName, "birthdate":birthdate,"gender": gender,"allowTransfer": allowTransfer,"allowMarketingEmail": allowMarketingEmail]]
    }
    
    func callService(params:NSDictionary,successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:NSDictionary) -> Void in
            
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.integerValue == 0 {
                  
                    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                    var usr : User
                    
                    let email = params.objectForKey("email") as! String;
                    let predicate = NSPredicate(format: "email == %@ ", email)
                    let array =  self.retrieve("User" ,sortBy:nil,isAscending:true,predicate:predicate) as! NSArray
        
                    if array.count > 0{
                        usr = array[0] as! User
                        
                        var resultProfileJSON = params["profile"] as! NSDictionary
                        
                        usr.profile.name = resultProfileJSON["name"] as! String
                        usr.profile.lastName = resultProfileJSON["lastName"] as! String

                        var error: NSError? = nil
                        context.save(&error)
                        UserCurrentSession.sharedInstance().userSigned = usr
                        successBlock!(resultCall)
                    }
                }
                else{
                    let errorDom = NSError(domain: "com.bcg.service.error", code: 0, userInfo: nil)
                    let message = resultCall["message"] as! String
                    var error = NSError()
                    //error.setValue(message, forKey:codeMessage)
                    errorBlock!(error)
                }
            }
            
            
            
            }) { (error:NSError) -> Void in
                errorBlock!(error)
            }
    }
}