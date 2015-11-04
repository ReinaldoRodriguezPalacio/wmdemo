//
//  IPAOrderDetailViewController.swift
//  WalMart
//
//  Created by ISOL Ingenieria de Soluciones on 24/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class IPAOrderDetailViewController: OrderDetailViewController {
    
    
    var sharePopover: UIPopoverController?
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64, self.view.frame.width, 64)
        
    }
    
    
    override func shareList() {
         BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label:"")
        if let image = self.buildImageToShare() {
            
            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.sharePopover = UIPopoverController(contentViewController: controller)
            let rect = self.self.viewFooter!.convertRect(self.shareButton!.frame, toView: self.view.superview!)
            self.sharePopover!.presentPopoverFromRect(rect, inView: self.view.superview!, permittedArrowDirections: .Any, animated: true)

        }
    }
    
    //MARK: - ScrollDelegate
    
    override func willShowTabbar() {
           }
    
    override func willHideTabbar() {
            }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let _ = tableView.cellForRowAtIndexPath(indexPath) as? OrderProductTableViewCell {
            
            let controller = IPAProductDetailPageViewController()
            controller.itemsToShow = getUPCItems(indexPath.section)
            controller.ixSelected = indexPath.row
            if !showFedexGuide {
                controller.ixSelected = indexPath.row - 2
            }
            
            if let navCtrl = self.navigationController!.parentViewController as UIViewController! {
                navCtrl.navigationController!.pushViewController(controller, animated: true)
            }
        }
        
    }
    
}