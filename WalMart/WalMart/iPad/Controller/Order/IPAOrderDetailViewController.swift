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
        
        self.tableDetailOrder.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 110)
        
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
        if let image = self.tableDetailOrder!.screenshot() {
          let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.header!.frame.width, height: 70.0))
          let image = UIImage(named: "detail_HeaderMail")
          imageView.image = image
          let imageHead = UIImage(from: imageView) //(named:"detail_HeaderMail") //
            
            self.backButton?.isHidden = true
            let headerCapture = UIImage(from: header)
            self.backButton?.isHidden = false
            
            let imgResult = UIImage.verticalImage(from: [imageHead!, headerCapture!, image])
            let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx")
            
            let controller = UIActivityViewController(activityItems: [self, imgResult!, urlWmart!], applicationActivities: nil)
            self.sharePopover = UIPopoverController(contentViewController: controller)
            let rect = self.self.viewFooter!.convert(self.shareButton!.frame, to: self.view.superview!)
            self.sharePopover!.present(from: rect, in: self.view.superview!, permittedArrowDirections: .any, animated: true)
            
            controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        }
    }

    override func listSelectorDidShowList(_ listEntity: List, andName name:String) {
        let storyboard = self.loadStoryboardDefinition()
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? IPAUserListDetailViewController {
            vc.listId = listEntity.idList
            vc.listName = name
            vc.listEntity = listEntity
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
    
   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? OrderProductTableViewCell {
            
            if cell.canTap {
                
                let controller = IPAProductDetailPageViewController()
                cell.canTap = false
                controller.itemsToShow = getUPCItems(indexPath.section)
                controller.ixSelected = indexPath.row
                controller.detailOf = "Order"
                if !showFedexGuide {
                    controller.ixSelected = indexPath.row - 2
                }
                
                delay(0.5, completion: {
                    cell.canTap = true
                })
                
                if let navCtrl = self.navigationController!.parent as UIViewController! {
                    navCtrl.navigationController!.pushViewController(controller, animated: true)
                }
                
            }

        }

    }
    
}
    
