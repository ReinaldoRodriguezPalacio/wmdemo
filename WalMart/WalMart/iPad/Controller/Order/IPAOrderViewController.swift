//
//  IPAOrderViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 20/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class IPAOrderViewController: OrderViewController {

    override func viewDidLoad() {
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        self.hiddenBack = true
        super.viewDidLoad()
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.emptyView.returnButton.hidden = true
        
        self.tableOrders!.contentInset = UIEdgeInsetsZero
        self.tableOrders!.scrollIndicatorInsets = UIEdgeInsetsZero
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.emptyView!.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
         self.tableOrders.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 128)

        self.facturasToolBar.frame = CGRectMake(0, self.view.frame.height - 64, self.view.frame.width, 64)
        
        if isShowingButtonFactura {
            self.buttonFactura.frame = CGRectMake(16, 14, facturasToolBar.frame.width - 32, 34)
        }else{
             self.tableOrders.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        }
        
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.reloadPreviousOrders()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    //MARK: - TableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.items[indexPath.row] as! NSDictionary
        let detailController = IPAOrderDetailViewController()
        
        if (item["type"] as! String) == ResultObjectType.Mg.rawValue {
            detailController.type = ResultObjectType.Mg
            let dateStr = item["placedDate"] as! String
            let trackingStr = item["trackingNumber"] as! String
            
            var statusStr = item["status"] as! String
            if (item["type"] as! String) == ResultObjectType.Groceries.rawValue {
                statusStr = NSLocalizedString("gr.order.status.\(statusStr)", comment: "")
            }
            
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_RECENTPURCHASES.rawValue,
                    action:WMGAIUtils.EVENT_PROFILE_RECENTPURCHASES_DETAIL.rawValue,
                    label: trackingStr,
                    value: nil).build() as [NSObject : AnyObject])
            }
            
            detailController.trackingNumber = trackingStr
            detailController.status = statusStr
            detailController.date = dateStr
            self.navigationController!.pushViewController(detailController, animated: true)
        } else {
            detailController.type = ResultObjectType.Groceries
            let dateStr = item["placedDate"] as! String
            let trackingStr = item["trackingNumber"] as! String
            let statusStr = item["status"] as! String
            
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_RECENTPURCHASES.rawValue,
                    action:WMGAIUtils.EVENT_PROFILE_RECENTPURCHASES_DETAIL.rawValue,
                    label: trackingStr,
                    value: nil).build() as [NSObject : AnyObject])
            }
            
            
            let statusDesc = NSLocalizedString("gr.order.status.\(statusStr)", comment: "")
            
            detailController.trackingNumber = trackingStr
            detailController.status = statusDesc
            detailController.date = dateStr
            detailController.detailsOrderGroceries = item
            self.navigationController!.pushViewController(detailController, animated: true)
            
        }
    }
    
    //MARK: - ScrollDelegate
    override func willShowTabbar() {
        }
    
    override func willHideTabbar() {
        }
}
