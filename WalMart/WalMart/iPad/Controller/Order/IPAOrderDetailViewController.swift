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
        
        self.viewFooter.frame = CGRect(x: 0, y: self.view.frame.height - 64 , width: self.view.frame.width, height: 64)
        
        let y = (self.viewFooter!.frame.height - 34.0)/2
        
        if self.type == ResultObjectType.Groceries {
            self.addToListButton!.frame = CGRect(x: (self.view.frame.width / 2) - 186, y: y, width: 34.0, height: 34.0)
            self.shareButton!.frame = CGRect(x: self.addToListButton!.frame.maxX + 16.0, y: y, width: 34.0, height: 34.0)
        }
        else {
            self.shareButton!.frame = CGRect(x: (self.view.frame.width/2) - 186, y: y, width: 34.0, height: 34.0)
        }
        
        self.addToCartButton!.frame = CGRect(x: self.shareButton!.frame.maxX + 16.0, y: y, width: (self.viewFooter!.frame.width - (self.shareButton!.frame.maxX + 16.0)) - 16.0, height: 34.0)
        
        self.viewFooter.frame = CGRect(x: 0, y: self.view.frame.height - 64, width: self.view.frame.width, height: 64)
        
        
        let x = self.shareButton!.frame.maxX + 16.0
        addToCartButton?.frame = CGRect(x: x, y: y, width: 256, height: 34.0)//self.footerSection!.frame.width - (x + 16.0)

 
    }
    
    
    override func shareList() {
         //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label:"")
        if let image = self.buildImageToShare() {
            
            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.sharePopover = UIPopoverController(contentViewController: controller)
            if #available(iOS 8.0, *) {
                let rect = self.self.viewFooter!.convert(self.shareButton!.frame, to: self.view.superview!)
                self.sharePopover!.present(from: rect, in: self.view.superview!, permittedArrowDirections: .any, animated: true)
            } else {
                // Fallback on earlier versions
            }
            
            if #available(iOS 8.0, *) {
                controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                    if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                        BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                    }
                }
            } else {
                controller.completionHandler = {(activityType, completed:Bool) in
                    if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                        BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                    }
                }
            }
        }
    }
    
    override func listSelectorDidShowList(_ listId: String, andName name:String) {
        let storyboard = self.loadStoryboardDefinition()
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? IPAUserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            vc.enableScrollUpdateByTabBar = false
            vc.hiddenBackButton = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
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
            controller.itemsToShow = getUPCItems(indexPath.section)
            controller.ixSelected = indexPath.row
            controller.detailOf = "Order"
            if !showFedexGuide {
                controller.ixSelected = indexPath.row - 2
            }
            
            if let navCtrl = self.navigationController!.parent as UIViewController! {
                navCtrl.navigationController!.pushViewController(controller, animated: true)
            }
        }

    }
}
    
