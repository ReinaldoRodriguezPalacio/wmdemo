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
    
    func buildParamsWithMembership(_ profileId:String,name:String,lastName:String,email:String,gender:String,ocupation:String,phoneNumber:String,phoneExtension:String,mobileNumber:String,updateAssociate:Bool,associateStore:String,joinDate:String,associateNumber:String,updatePassword:Bool,oldPassword:String,newPassword:String) -> [String:Any] {
        
        return ["profileId":profileId,"firstName":name,"lastName":lastName,"email":email,"gender":gender,"occupation":ocupation,"phoneNumber":phoneNumber,"phoneExtension":phoneExtension,"mobileNumber":mobileNumber,"associateCheckBox":updateAssociate ? "true" : "false","associateNumber":associateNumber,"associateStore":associateStore,"joinDate":joinDate,"passwordCheckBox":updatePassword ? "true" : "false","oldPassword":oldPassword,"newPassword":newPassword]
    }
    
    func callService(_ params:[String:Any],successBlock:(([String:Any]) -> Void)?, errorBlock:((NSError) -> Void)? ) {
        self.callPOSTService(params, successBlock: { (resultCall:[String:Any]) -> Void in
            
            if let codeMessage = resultCall["codeMessage"] as? NSNumber {
                if codeMessage.intValue == 0 {
                  
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                    var usr : User
                    
                    let email = params.object(forKey: "email") as! String;
                    let predicate = NSPredicate(format: "email == %@ ", email)
                    let array =  self.retrieve("User" ,sortBy:nil,isAscending:true,predicate:predicate) as! [[String:Any]]
        
                    if array.count > 0{
                        usr = array[0] as! User
                        
                        //let resultProfileJSON = params["profile"] as! [String:Any]
                        
                        usr.profile.name = params["firstName"] as! NSString
                        usr.profile.lastName = params["lastName"] as! NSString
                        do {
                            try context.save()
                        } catch let error1 as NSError {
                            print(error1.description)
                        } catch {
                            fatalError()
                        }
                        UserCurrentSession.sharedInstance.userSigned = usr
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
