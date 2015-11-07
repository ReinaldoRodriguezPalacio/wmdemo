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
        
        if self.titleLabel != nil && self.titleLabel!.frame.width == 0 {
            self.header!.frame = CGRectMake(0, 0, self.view.bounds.width, 46)
            self.titleLabel!.frame = CGRectMake(46, 0, self.header!.frame.width - 92, self.header!.frame.maxY)
        }
        if backButton != nil{
            self.backButton!.frame = CGRectMake(0, 0  ,46,46)
        }
        
        self.tableDetailOrder.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        
        self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64 , self.view.frame.width, 64)
        
        let y = (self.viewFooter!.frame.height - 34.0)/2
        
        if self.type == ResultObjectType.Groceries {
            self.addToListButton!.frame = CGRectMake((self.view.frame.width / 2) - 186, y, 34.0, 34.0)
            self.shareButton!.frame = CGRectMake(self.addToListButton!.frame.maxX + 16.0, y, 34.0, 34.0)
        }
        else {
            self.shareButton!.frame = CGRectMake((self.view.frame.width/2) - 186, y, 34.0, 34.0)
        }
        
        self.addToCartButton!.frame = CGRectMake(self.shareButton!.frame.maxX + 16.0, y, (self.viewFooter!.frame.width - (self.shareButton!.frame.maxX + 16.0)) - 16.0, 34.0)
        
        self.viewFooter.frame = CGRectMake(0, self.view.frame.height - 64, self.view.frame.width, 64)
        
        
        let x = self.shareButton!.frame.maxX + 16.0
        addToCartButton?.frame = CGRectMake(x, y, 256, 34.0)//self.footerSection!.frame.width - (x + 16.0)

 
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
    
