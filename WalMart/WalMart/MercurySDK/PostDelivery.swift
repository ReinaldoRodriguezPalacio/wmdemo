//
//  PostDelivery.swift
//  MercurySDK
//
//  Created by Gerardo Ramirez on 29/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation



public class PostDelivery : HelpMercuryViewDelegate {
    
    var currentDeliveries : [AnyObject]? = nil
    var currentToRate : [AnyObject]? = []
    var currentKPIRate : [AnyObject]? = []
    var followMercuryView : FollowViewController? = nil
    var rateView : RatingAlertViewController? = nil
    var helpView : HelpMercuryView? = nil
    
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
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                followMercuryView = IPAFollowViewController()
            } else {
                followMercuryView = FollowViewController()
            }
            
            let defaults = NSUserDefaults.standardUserDefaults()
            if let showHelp  = defaults.boolForKey("didshowmercuryhelp") as? Bool {
                if !showHelp {
                    showHelpView(viewCtrl)
                }
            } else {
                showHelpView(viewCtrl)
            }
            
            
            viewCtrl.addChildViewController(self.followMercuryView!)
            viewCtrl.view.addSubview(self.followMercuryView!.view)
            viewCtrl.view.bringSubviewToFront(viewCtrl.view)
            followMercuryView!.idDelivery = firstDelivery["idDelivery"] as! String
            followMercuryView!.deliveryObject = firstDelivery
            
        } else {
            viewCtrl.view.bringSubviewToFront(viewCtrl.view)
        }
    }
    
    
    func showRateView(viewCtrl:UIViewController){
        if rateView == nil {
            let firstDelivery = currentToRate![0] as! [String:AnyObject]
            rateView = RatingAlertViewController()
            rateView!.assignBluredImage(viewCtrl.view)
            
            //            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            //                rateView = IPAFollowViewController()
            //            } else {
            //
            //            }
            
            rateView!.objectDelivery = firstDelivery
            rateView!.kpiDelivery = PostDelivery.sharedInstance().currentKPIRate!
            
            viewCtrl.addChildViewController(self.rateView!)
            viewCtrl.view.addSubview(self.rateView!.view)
            viewCtrl.view.bringSubviewToFront(viewCtrl.view)
            
            rateView?.onEndRating = {() in
                self.rateView = nil
            }
            
            
        } else {
            viewCtrl.view.bringSubviewToFront(viewCtrl.view)
        }
    }
    
    func showHelpView(controller:UIViewController) {
        if self.helpView == nil {
            self.followMercuryView!.view.alpha = 0
            self.helpView = HelpMercuryView(frame:controller.view.frame)
            self.helpView?.delegate = self
            controller.view.addSubview(self.helpView!)
        }
    }
    
    func willCloseHelp() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "didshowmercuryhelp")
        self.followMercuryView!.view.alpha = 1
        self.followMercuryView!.select()
        
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
    
    
    let baseUrl = "https://mercury.isol.ws/mercury-1.0/api/mercury/"
    let urlMercury = "v1/delivery"
    let urlMercuryValidate = "v1/availability/parameters"
    let urlMercurySlots = "v1/service/type"
    let urlMercuryCurrent = "v1/customer/deliveries/"
    let urlMercuryRate = "v1/rating"
    let urlMercuryPostRate = "v1/rating/send"
    let urlMercuryPostRateCancel = "v1/rating/cancel"
    
    
    
    
    public func callMercuryDelivery(delivery:Delivery,onPostDelivery:((idDelivery:String) -> Void),onError:((error:NSError) -> Void)) {
        let toSendObject = delivery.toDictionary()
        print("Objecto a madar \(toSendObject)")
        request(Method.POST,"\(baseUrl)\(urlMercury)" , parameters: toSendObject as! [String:AnyObject] , encoding: ParameterEncoding.JSON).debugLog().responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) -> Void in
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
    
    public func validateMercuryDelivery(deviceToken:String,onSuccess:((rules:[String:AnyObject]) -> Void),onError:((error:NSError) -> Void)) {
        let bundleID = NSBundle.mainBundle().bundleIdentifier
        
        let params : [String:AnyObject] = ["bundleid":bundleID!, "device" : ["systemName":UIDevice.currentDevice().systemName,
            "appdevicetoken":deviceToken,
            "model":UIDevice.currentDevice().model,
            "version":UIDevice.currentDevice().systemVersion,
            "localizedMode":UIDevice.currentDevice().localizedModel,
            "macAddress":"",
            "identifierForVendor":UIDevice.currentDevice().identifierForVendor!.UUIDString]]
        
        request(Method.POST, "\(baseUrl)\(urlMercuryValidate)" , parameters: params , encoding: ParameterEncoding.JSON).debugLog().responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) -> Void in
            if response.result.isSuccess{
                let resultStatus = response.result.value!["status"] as! Int
                if resultStatus != 1 {
                    let errorDesc = response.result.value!["message"] as! String
                    let errorHandled = NSError(domain: "com.mercury.service", code: resultStatus, userInfo:[NSLocalizedDescriptionKey:errorDesc])
                    onError(error: errorHandled)
                    return
                }
                onSuccess(rules:response.result.value! as! [String:AnyObject])
            } else {
                onError(error: response.result.error!)
            }
        })
        
    }
    
    
    public func validateMercurySlots(deliveryDate:NSDate,idShopper:String,idStore:String,onSuccess:((resultSuccess:AnyObject) -> Void),onError:((error:NSError) -> Void)) {
        
        
        let dateFormat = "yyyy-MM-dd 00:00:00"
        let formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        
        let toSendObject : [String:AnyObject] = ["deliveryDate":formatter.stringFromDate(deliveryDate),"idShopper":idShopper,"idStore":idStore]
        
        request(Method.POST, "\(baseUrl)\(urlMercurySlots)", parameters: toSendObject , encoding: ParameterEncoding.JSON).debugLog().responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) -> Void in
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
                print( response.result.error!)
                onError(error: response.result.error!)
            }
        })
    }
    
    
    public class func getCurrentMercuryDeliveries(user:String,onSuccess:((resultSuccess:AnyObject) -> Void)) {
        let toSendObject : [String:AnyObject] = ["customerUserName":user]
        
        request(Method.POST, "\(PostDelivery.sharedInstance().baseUrl)\(PostDelivery.sharedInstance().urlMercuryCurrent)" , parameters: toSendObject , encoding: ParameterEncoding.JSON).debugLog().responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) -> Void in
            if response.result.isSuccess{
                let resultStatus = response.result.value!["status"] as! Int
                if resultStatus != 1 {
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
                getRateDescriptions(user, onSuccess: onSuccess)
            } else {
                //onError(error: response.result.error!)
            }
        })
        
    }
    
    
    public class func getRateDescriptions(user:String,onSuccess:((resultSuccess:AnyObject) -> Void)) {
        let bundleID = NSBundle.mainBundle().bundleIdentifier!
        let scale = scaleFactor()
        let params : [String:AnyObject] = ["typePerson":2,"emailConsumer":user,"bundleId":bundleID,"scale":scale]
        
        request(Method.POST, "\(PostDelivery.sharedInstance().baseUrl)\(PostDelivery.sharedInstance().urlMercuryRate)", parameters: params , encoding: ParameterEncoding.JSON).debugLog().responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) -> Void in
            if response.result.isSuccess{
                print( response.result.value)
                let resultStatus = response.result.value!["status"] as! Int
                if resultStatus != 1 {
                    //                    let errorDesc = response.result.value!["message"] as! String
                    //                    let errorHandled = NSError(domain: "com.mercury.service", code: resultStatus, userInfo:[NSLocalizedDescriptionKey:errorDesc])
                    //onError(error: errorHandled)
                    return
                }
                if let responseCustom = response.result.value!["custom"] as? [String:AnyObject] {
                    if let responseList = responseCustom["listDeliveryConsumerRating"] as? [[String:AnyObject]] {
                        PostDelivery.sharedInstance().currentToRate = responseList
                    }
                    if let responseAnsweres = responseCustom["listQualifies"] as? [[String:AnyObject]] {
                        let orderKPI = responseAnsweres.sort({ (first, second) -> Bool in
                            let positionOne = first["position"] as! Int
                            let positionTwo = second["position"] as! Int
                            return positionOne < positionTwo
                        })
                        PostDelivery.sharedInstance().currentKPIRate = orderKPI
                    }
                }
                
            }
            onSuccess(resultSuccess:[])
        })
    }
    
    class func scaleFactor() -> CGFloat {
        if UIScreen.mainScreen().respondsToSelector(#selector(UIScreen.displayLinkWithTarget(_:selector:))) {
            return UIScreen.mainScreen().scale
        }
        return 1.0
    }
    
    public class func postDeliveryRating(deliveryId:String,message:String,rating:[[String:AnyObject]],onSuccess:((resultSuccess:AnyObject) -> Void)) {
        
        
        let dateFormat = "yyyy-MM-dd 00:00:00"
        let formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        
        let toSendObject : [String:AnyObject] = ["idDelivery":deliveryId,"ratings":rating,"comments":message]
        
        request(Method.POST, "\(PostDelivery.sharedInstance().baseUrl)\(PostDelivery.sharedInstance().urlMercuryPostRate)", parameters: toSendObject , encoding: ParameterEncoding.JSON).debugLog().responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) -> Void in
            if response.result.isSuccess{
                let resultStatus = response.result.value!["status"] as! Int
                if resultStatus != 1 {
                    //let errorDesc = response.result.value!["message"] as! String
                    //let errorHandled = NSError(domain: "com.mercury.service", code: resultStatus, userInfo:[NSLocalizedDescriptionKey:errorDesc])
                    //onError(error: errorHandled)
                    return
                }
                onSuccess(resultSuccess:response.result.value!)
            } else {
                //onError(error: response.result.error!)
            }
        })
    }
    
    public class func cancelRatingDelivery(deliveryId:String,onSuccessCancel:(()->Void)) {
        
        let toSendObject : [String:AnyObject] = ["idDelivery":deliveryId]
        
        request(Method.POST, "\(PostDelivery.sharedInstance().baseUrl)\(PostDelivery.sharedInstance().urlMercuryPostRateCancel)", parameters: toSendObject , encoding: ParameterEncoding.JSON).debugLog().responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) -> Void in
            if response.result.isSuccess{
                let resultStatus = response.result.value!["status"] as! Int
                if resultStatus != 1 {
                    //let errorDesc = response.result.value!["message"] as! String
                    //let errorHandled = NSError(domain: "com.mercury.service", code: resultStatus, userInfo:[NSLocalizedDescriptionKey:errorDesc])
                    //onError(error: errorHandled)
                    return
                }
                onSuccessCancel()
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

