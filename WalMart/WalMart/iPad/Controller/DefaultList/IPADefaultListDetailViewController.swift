//
//  IPADefaultListDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 02/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol IPADefaultListDetailViewControllerDelegate {
    func reloadViewList()
}

class IPADefaultListDetailViewController :  DefaultListDetailViewController,UIPopoverControllerDelegate {
    
    var sharePopover: UIPopoverController?
    var delegate : IPADefaultListDetailViewControllerDelegate?
    
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

    
    override func shareList() {

        if let image = self.buildImageToShare() {
            
            
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_SHARELIST.rawValue,
                    label: self.defaultListName,
                    value: nil).build() as [NSObject : AnyObject])
            }
            
            var controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.sharePopover = UIPopoverController(contentViewController: controller)
            self.sharePopover!.delegate = self
            //self.sharePopover!.backgroundColor = UIColor.greenColor()
            var rect = self.footerSection!.convertRect(self.shareButton!.frame, toView: self.view.superview!)
            self.sharePopover!.presentPopoverFromRect(rect, inView: self.view.superview!, permittedArrowDirections: .Any, animated: true)
        }
    }
    
    //MARK: - UIPopoverControllerDelegate
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        self.sharePopover = nil
    }

    override func duplicate() {
        self.invokeSaveListToDuplicateService(defaultListName!, successDuplicateList: { () -> Void in
            self.delegate?.reloadViewList()
            self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
            self.alertView!.showDoneIcon()
        })
    }
    
}