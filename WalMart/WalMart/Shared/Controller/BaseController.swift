//
//  BaseController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class BaseController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let tracker = GAI.sharedInstance().defaultTracker {
//            let valueScreenName = self.getScreenGAIName()
//            if !valueScreenName.isEmpty {
//                tracker.set(kGAIScreenName, value: self.getScreenGAIName())
//                let eventTracker: NSObject = GAIDictionaryBuilder.createScreenView().build()
//                tracker.send(eventTracker as! [NSObject : AnyObject])
//            }
//        }
    }

    
    func loadStoryboardDefinition() -> UIStoryboard? {
        let storyboardName = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? "Storyboard_iphone" : "Storyboard_ipad"
        let storyboard : UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil);
        return storyboard;
    }
        
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let rotation = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? UIInterfaceOrientationMask.Portrait : UIInterfaceOrientationMask.Landscape
         return rotation
    }
    
    //WHITE BAR
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    
    override func shouldAutorotate() -> Bool {
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
    
}