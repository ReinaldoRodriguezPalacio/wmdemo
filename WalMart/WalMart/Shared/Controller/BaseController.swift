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
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            let valueScreenName = self.getScreenGAIName()
            if !valueScreenName.isEmpty {
                tracker.set(kGAIScreenName, value: self.getScreenGAIName())
                let eventTracker: NSObject = GAIDictionaryBuilder.createScreenView().build()
                tracker.send(eventTracker as! [NSObject : AnyObject])
            }
            
        }
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
    
   
    func getScreenGAIName() -> String {
        fatalError("SCreeen name not implemented");
    }
    
}