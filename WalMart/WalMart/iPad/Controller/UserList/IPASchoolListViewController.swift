//
//  IPASchoolListViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 27/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class IPASchoolListViewController: SchoolListViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !self.isSharing {
            tableView?.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, self.view.frame.height - self.header!.frame.maxY)
        }
        self.footerSection!.frame = CGRectMake(146,  self.view.frame.maxY - 72 , 390, 72)
        let x = self.shareButton!.frame.maxX + 16.0
        let y = (self.footerSection!.frame.height - 34.0)/2
        self.addToCartButton?.frame = CGRectMake(x, y, self.footerSection!.frame.width - (x + 16.0), 34.0)
        self.selectAllButton?.frame = CGRectMake(16.0, y, 34.0, 34.0)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        
        let controller = IPAProductDetailPageViewController()
        var productsToShow:[AnyObject] = []
        for idx in 0 ..< self.detailItems!.count {
            let product = self.detailItems![idx]
            let upc = product["upc"] as! NSString
            let description = product["description"] as! NSString
            
            productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Mg.rawValue, "saving":""])
        }
        controller.itemsToShow = productsToShow
        controller.ixSelected = indexPath.row
        
        let product = self.detailItems![indexPath.row]
        let upc = product["upc"] as! NSString
        let description = product["description"] as! NSString
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL_PRACTILISTA.rawValue, label: "\(description) - \(upc)")
        
        if let navCtrl = self.navigationController!.parentViewController as UIViewController! {
            navCtrl.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    override func willShowTabbar() { }
    
}