//
//  IPAMasterHelpViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 22/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit


class IPAMasterHelpViewController: UISplitViewController, UISplitViewControllerDelegate, IPAMoreOptionsViewControllerDelegate { // HelpViewControllerDelegate{

    var selected : Int? = nil
    var navigation : UINavigationController!
    var navController = UIViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        self.delegate = self
        self.navigation = UINavigationController()
        
        let storyboard = self.loadStoryboardDefinition()
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("ipaMoreVC") as? UIViewController {
            
            if let vcRoot = vc as? IPAMoreOptionsViewController {
                vcRoot.delegate = self
                self.navController = vc
                self.viewControllers = [vc, navigation]
            }
        }

        var recent = IPAHelpViewController()
        self.navigation.pushViewController(recent, animated: true)
        selected = 0
        
        if(self.respondsToSelector(Selector("maximumPrimaryColumnWidth")))
        {
            self.maximumPrimaryColumnWidth = 342
            self.minimumPrimaryColumnWidth = 342
        }
    }
    
    
    func selectedDetail(row: Int) {
        
        if selected == row {
            return
        }
    
        if selected == row{
            self.navigation.popToRootViewControllerAnimated(true)
            return
        }
        self.navigation = UINavigationController()
        self.navigation!.popViewControllerAnimated(true)
        
        switch row {
        case 0:
            var edit = IPAEditProfileViewController()
            var indexPath = NSIndexPath(forItem:Int(selected!), inSection:0)
            self.navigation.pushViewController(edit, animated: true)
        case 1:
            var recent = IPARecentProductsViewController()
            self.navigation.pushViewController(recent, animated: true)
        case 2:
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PROFILE.rawValue, action: WMGAIUtils.EVENT_PROFILE_MYADDRESSES.rawValue, label: "", value: nil).build())
            }
            var myAddres = IPAMyAddressViewController()
            self.navigation.pushViewController(myAddres, animated: true)
        case 3:
            var order = IPAOrderViewController()
            self.navigation.pushViewController(order, animated: true)
        case 4:
            var recent = IPAHelpViewController()
            self.navigation.pushViewController(recent, animated: true)
        case 5:
            var recent = IPATermViewController()
            self.navigation.pushViewController(recent, animated: true)
        case 6:
            
            var recent = IPASupportViewController()
            self.navigation.pushViewController(recent, animated: true)
        default :
            println("other pressed")
        }
        
//        selected = row
//        self.viewControllers = [profile, navigation];
//        switch row {
//        case 0:
//            var recent = IPAHelpViewController()
//            self.navigation.pushViewController(recent, animated: true)
//        case 1:
//            var recent = IPATermViewController()
//            self.navigation.pushViewController(recent, animated: true)
//        case 2:
//            
//            var recent = IPASupportViewController()
//            self.navigation.pushViewController(recent, animated: true)
//            
//        default :
//            println("other pressed")
//        }
        
        selected = row
        self.viewControllers = [self.navController, navigation];
    }
    
    
    func loadStoryboardDefinition() -> UIStoryboard? {
        let storyboardName = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? "Storyboard_iphone" : "Storyboard_ipad"
        let storyboard : UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil);
        return storyboard;
    }
    
}
