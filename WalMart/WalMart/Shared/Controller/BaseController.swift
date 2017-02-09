//
//  BaseController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


var messageError:String  = ""

class BaseController : UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["event": "openScreen", "screenName": self.getScreenGAIName()])

    }

    
    func loadStoryboardDefinition() -> UIStoryboard? {
        let storyboardName = UIDevice.current.userInterfaceIdiom == .phone ? "Storyboard_iphone" : "Storyboard_ipad"
        let storyboard : UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil);
        return storyboard
    }
        
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        let rotation = UIDevice.current.userInterfaceIdiom == .phone ? UIInterfaceOrientationMask.portrait : UIInterfaceOrientationMask.landscape
         return rotation
    }
    
    //WHITE BAR
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    
    override var shouldAutorotate : Bool {
        return true
    }
    
//    class func sendAnalytics(category:String, action: String, label:String){
//           ////////
////        print("Category: \(category) Action: \(action) Label: \(label)")
//                if let tracker = GAI.sharedInstance().defaultTracker {
//                    tracker.send(GAIDictionaryBuilder.createEventWithCategory(category,
//                        action: action,
//                        label: label, value: nil).build() as [NSObject : AnyObject])
//                }
//    }
    
//    class func sendAnalytics(categoryAuth:String, categoryNoAuth:String, action: String, label:String){
//        let category = UserCurrentSession.hasLoggedUser() ? categoryAuth : categoryNoAuth
//        //BaseController.sendAnalytics(category, action: action, label: label)
//    }


    
   
    func getScreenGAIName() -> String {
        fatalError("SCreeen name not implemented")
    }
    
    // MARK: - Analytics 360
    
    class func sendAnalyticsPush(_ pushData:[String:Any]) {
        let dataLayer: TAGDataLayer = TAGManager.instance().dataLayer
        dataLayer.push(["ecommerce": NSNull()])
        dataLayer.push(pushData)
    }
    
    //MARK: Tag de Errores
    class func sendTagManagerErrors(_ event:String,detailError:String){
        switch event {
        case "ErrorEvent":
            self.sendAnalyticsPush(["event":event,"detailError":detailError])
            break
        case "ErrorEventBusiness":
            
            if  messageError != detailError {
                self.sendAnalyticsPush(["event":event,"detailErrorBusiness":detailError])
            }
            messageError = detailError
            break
        default:
            break
        }
        
    }
    
}
