//
//  IPADefaultListDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 02/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class IPADefaultListDetailViewController :  DefaultListDetailViewController {
    
    override func willShowTabbar() {
        isShowingTabBar = false
    }
    
    override func willHideTabbar() {
        isShowingTabBar = false
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = IPAProductDetailPageViewController()
        var productsToShow:[AnyObject] = []
        for var idx = 0; idx < self.detailItems!.count; idx++ {
            let product = self.detailItems![idx]
            let upc = product["upc"] as! NSString
            let description = product["description"] as! NSString
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_PRODUCTDETAIL.rawValue,
                    label: upc as String,
                    value: nil).build() as [NSObject : AnyObject])
            }
            
            productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Groceries.rawValue, "saving":""])
        }
        controller.itemsToShow = productsToShow
        controller.ixSelected = indexPath.row
        
        if let navCtrl = self.navigationController!.parentViewController as UIViewController! {
            navCtrl.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView?.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, self.view.frame.height - self.header!.frame.maxY)
        
        self.footerSection!.frame = CGRectMake(0,  self.view.frame.maxY - 72 , self.view.frame.width, 72)
        var x = self.shareButton!.frame.maxX + 16.0
        var y = (self.footerSection!.frame.height - 34.0)/2
        addToCartButton?.frame = CGRectMake(x, y, self.footerSection!.frame.width - (x + 16.0), 34.0)
        self.customLabel?.frame  = self.addToCartButton!.bounds
    }

    
}