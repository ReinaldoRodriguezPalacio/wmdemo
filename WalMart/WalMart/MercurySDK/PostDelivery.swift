//
//  PostDelivery.swift
//  MercurySDK
//
//  Created by Gerardo Ramirez on 29/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation



public class PostDelivery {
    
    var currentDeliveries : [AnyObject]? = nil
    var followMercuryView : FollowViewController? = nil
    
    //Singleton init
    class func sharedInstance()-> PostDelivery! {
        struct Static {
            static var instance : PostDelivery? = nil
            static var onceToken : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = self.init()
        }
        
        return Static.instance!
    }
    
    
    func showFollowView(viewCtrl:UIViewController){
        if followMercuryView == nil {
            
            let firstDelivery = currentDeliveries![0] as! [String:AnyObject]
            
            followMercuryView = FollowViewController()
            viewCtrl.addChildViewController(self.followMercuryView!)
            viewCtrl.view.addSubview(self.followMercuryView!.view)
            viewCtrl.view.bringSubviewToFront(viewCtrl.view)
            followMercuryView!.idDelivery = firstDelivery["idDelivery"] as! String
            followMercuryView!.deliveryObject = firstDelivery

        } else {
            viewCtrl.view.bringSubviewToFront(viewCtrl.view)
        }
    }
    
    
    func hideFollowView(){
        if followMercuryView != nil {
            followMercuryView?.removeFromParentViewController()
            followMercuryView?.view.removeFromSuperview()
            followMercuryView = nil
        }
    }

    
    
    required  public init() {
        
    }

    
    class func postDeliveries(userName:String) {
        getCurrentMercuryDeliveries(userName, onSuccess: { (resultSuccess) -> Void in
            //PostDelivery.sharedInstance().currentDeliveries = resultSuccess["custom"] as! [AnyObject]
            if UserCurrentSession.sharedInstance().userSigned != nil {
                NSNotificationCenter.defaultCenter().postNotificationName("delivery", object: nil)
            }
        })
    }
    
    class func isInDelivery() -> Bool {
        return true
    }
    

    
    let urlMercury = "http://mercury.isol.ws:8080/mercury-1.0/api/mercury/v1/delivery"
    let urlMercuryValidate = "http://mercury.isol.ws:8080/mercury-1.0/api/mercury/v1/availability"
    let urlMercurySlots = "http://mercury.isol.ws:8080/mercury-1.0/api/mercury/v1/service/type"
    let urlMercuryCurrent = "http://mercury.isol.ws:8080/mercury-1.0/api/mercury/v1/customer/deliveries/"
    
    
    public func callMercuryDelivery(delivery:Delivery,onPostDelivery:((idDelivery:String) -> Void),onError:((error:NSError) -> Void)) {
        let toSendObject = delivery.toDictionary()
        print("Objecto a madar \(toSendObject)")
        request(Method.POST, urlMercury, parameters: toSendObject as! [String:AnyObject] , encoding: ParameterEncoding.JSON).debugLog().responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) -> Void in
            if response.result.isSuccess{
                let resultStatus = response.result.value!["status"] as! Int
                if resultStatus != 1 {
                    let errorDesc = response.result.value!["message"] as! String
                    let errorHandled = NSError(domain: "com.mercury.service", code: resultStatus, userInfo:[NSLocalizedDescriptionKey:errorDesc])
                    onError(error: errorHandled)
                    return
                }
                let idDeliveryResponse =  response.result.value!["custom"] as! String
                onPostDelivery(idDelivery: idDeliveryResponse)
            }else {
                onError(error: response.result.error!)
            }
        })
    }
    
    public func validateMercuryDelivery(delivery:Delivery,onSuccess:(() -> Void),onError:((error:NSError) -> Void)) {
        let toSendObject = delivery.toDictionary()
        if let dictToSendObject =  toSendObject as? [String:AnyObject] {
            
            request(Method.POST, urlMercuryValidate, parameters: dictToSendObject , encoding: ParameterEncoding.JSON).debugLog().responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) -> Void in
                if response.result.isSuccess{
                    let resultStatus = response.result.value!["status"] as! Int
                    if resultStatus != 1 {
                        let errorDesc = response.result.value!["message"] as! String
                        let errorHandled = NSError(domain: "com.mercury.service", code: resultStatus, userInfo:[NSLocalizedDescriptionKey:errorDesc])
                        onError(error: errorHandled)
                        return
                    }
                    onSuccess()
                } else {
                    onError(error: response.result.error!)
                }
            })
        } else {
            let errorHandled = NSError(domain: "com.mercury.service", code: 500, userInfo: [ NSLocalizedDescriptionKey:"Bad Request"])
            onError(error: errorHandled)
        }
    }
    
    
    public func validateMercurySlots(deliveryDate:NSDate,idShopper:String,idStore:String,onSuccess:((resultSuccess:AnyObject) -> Void)) {
        
        
        let dateFormat = "yyyy-MM-dd 00:00:00"
        let formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        
        let toSendObject : [String:AnyObject] = ["deliveryDate":formatter.stringFromDate(deliveryDate),"idShopper":idShopper,"idStore":idStore]
        
        request(Method.POST, urlMercurySlots, parameters: toSendObject , encoding: ParameterEncoding.JSON).debugLog().responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) -> Void in
            if response.result.isSuccess{
                let resultStatus = response.result.value!["status"] as! Int
                if resultStatus != 1 {
//                    let errorDesc = response.result.value!["message"] as! String
//                    let errorHandled = NSError(domain: "com.mercury.service", code: resultStatus, userInfo:[NSLocalizedDescriptionKey:errorDesc])
                    //onError(error: errorHandled)
                    return
                }
                onSuccess(resultSuccess:response.result.value!)
            } else {
                //onError(error: response.result.error!)
            }
        })
    }

    
    public class func getCurrentMercuryDeliveries(user:String,onSuccess:((resultSuccess:AnyObject) -> Void)) {
        let toSendObject : [String:AnyObject] = ["customerUserName":user]
        
        request(Method.POST, PostDelivery.sharedInstance().urlMercuryCurrent, parameters: toSendObject , encoding: ParameterEncoding.JSON).debugLog().responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) -> Void in
            if response.result.isSuccess{
                let resultStatus = response.result.value!["status"] as! Int
                if resultStatus != 1 {
//                    let errorDesc = response.result.value!["message"] as! String
//                    let errorHandled = NSError(domain: "com.mercury.service", code: resultStatus, userInfo:[NSLocalizedDescriptionKey:errorDesc])
//                    onError(error: errorHandled)
                    return
                }
                var arrayToAsign : [AnyObject] = []
                
                if let arrayDeliveries = response.result.value!["custom"] as? [AnyObject] {
                    for objDel in arrayDeliveries {
                        if let statusDel  =  objDel["status"] as? String {
                            if statusDel ==  "OnRoute" {
                                arrayToAsign.append(objDel)
                            }
                        }
                    }
                }
                PostDelivery.sharedInstance().currentDeliveries = arrayToAsign
                onSuccess(resultSuccess:response.result.value!)
            } else {
                //onError(error: response.result.error!)
            }
        })
        
    }
    
   
    
    
}

extension Request {
    public func debugLog() -> Self {

        //debugPrint(self)
        
        print(NSString(data: request!.HTTPBody!, encoding: NSUTF8StringEncoding))
        return self
    }
}

