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
        self.emptyView.returnButton.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.recentProducts.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height-46)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue , label: self.recentProductItems[0]["description"] as! String)
        
        let controller = IPAProductDetailPageViewController()
        controller.itemsToShow = getUPCItems() as [Any]
        controller.ixSelected = indexPath.row
        controller.detailOf = "Recent Products"
       
        if let navCtrl = self.navigationController!.parent as UIViewController! {
            navCtrl.navigationController!.pushViewController(controller, animated: true)
        }
        
    }
   
    
}
