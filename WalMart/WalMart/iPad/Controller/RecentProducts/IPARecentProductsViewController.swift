//
//  IPARecentProductsViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 05/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class IPARecentProductsViewController: RecentProductsViewController {
   
    override func viewDidLoad() {
        self.hiddenBack = true
        if  self.navigationController != nil {
            self.navigationController!.setNavigationBarHidden(true, animated: true)
        }
         super.viewDidLoad()
        self.emptyView.iconImageView.image = UIImage(named:"empty_recent")
        self.emptyView.returnButton.hidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.recentProducts.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height-46)
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue , label: self.recentProductItems[0]["description"] as! String)
        
        let controller = IPAProductDetailPageViewController()
        controller.itemsToShow = getUPCItems()
        controller.ixSelected = indexPath.row
        controller.detailOf = "Recent Products"
       
        if let navCtrl = self.navigationController!.parentViewController as UIViewController! {
            navCtrl.navigationController!.pushViewController(controller, animated: true)
        }
        
    }
   
    
}
