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
            self.header!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 46)
            self.titleLabel!.frame = CGRect(x: 46, y: 0, width: self.header!.frame.width - 92, height: self.header!.frame.maxY)
        }
        if backButton != nil{
            self.backButton!.frame = CGRect(x: 0, y: 0  ,width: 46,height: 46)
        }
        
        self.tableDetailOrder.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
    }
    
    /*override func shareList() {
         BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label:"")
        if let image = self.buildImageToShare() {
            
            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.sharePopover = UIPopoverController(contentViewController: controller)
            let rect = self.self.viewFooter!.convertRect(self.shareButton!.frame, toView: self.view.superview!)
            self.sharePopover!.presentPopoverFromRect(rect, inView: self.view.superview!, permittedArrowDirections: .Any, animated: true)

        }
    }*/
    
    /*override func listSelectorDidShowList(listId: String, andName name:String) {
        let storyboard = self.loadStoryboardDefinition()
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? IPAUserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            vc.enableScrollUpdateByTabBar = false
            vc.hiddenBackButton = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }*/
    
    override func showLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
            self.viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 46, width: 681.5, height: self.view.frame.height - 46))
            self.viewLoad!.backgroundColor = UIColor.white
            self.view.addSubview(self.viewLoad!)
            self.viewLoad!.startAnnimating(self.isVisibleTab)
    }
    
    //MARK: - ScrollDelegate
    
    override func willShowTabbar() {
    }
    
    override func willHideTabbar() {
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let _ = tableView.cellForRow(at: indexPath) as? OrderProductTableViewCell {
            
            let controller = IPAProductDetailPageViewController()
            controller.itemsToShow = getUPCItems((indexPath as NSIndexPath).section)
            controller.ixSelected = (indexPath as NSIndexPath).row
            if !showFedexGuide {
                controller.ixSelected = (indexPath as NSIndexPath).row - 2
            }
            
            if let navCtrl = self.navigationController!.parent as UIViewController! {
                navCtrl.navigationController!.pushViewController(controller, animated: true)
            }
        }

    }
}
    
