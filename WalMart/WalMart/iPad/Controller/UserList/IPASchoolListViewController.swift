//
//  IPASchoolListViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 27/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class IPASchoolListViewController: SchoolListViewController {
    
    var sharePopover: UIPopoverController?
    
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
        self.customLabel!.frame = CGRectMake(0, 0, self.footerSection!.frame.width - (x + 16.0), 34.0)
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
    
    //MARK: Delegate item cell
    override func didChangeQuantity(cell:DetailListViewCell){
            
        let indexPath = self.tableView!.indexPathForCell(cell)
        if indexPath == nil {
            return
        }
        var price: String? = nil
            
        let item = self.detailItems![indexPath!.row]
        price = item["price"] as? String
        let selectorFrame = CGRectMake(0.0, 0.0, 320.0, 388.0)
        self.quantitySelectorMg = ShoppingCartQuantitySelectorView(frame: selectorFrame, priceProduct: NSNumber(double:Double(price!)!),upcProduct:cell.upcVal!)
        self.view.addSubview(self.quantitySelectorMg!)
        self.quantitySelectorMg!.closeAction = { () in
            self.sharePopover!.dismissPopoverAnimated(true)
            self.quantitySelectorMg = nil
        }
        self.quantitySelectorMg!.addToCartAction = { (quantity:String) in
            var item = self.detailItems![indexPath!.row]
            //var upc = item["upc"] as? String
            item["quantity"] = NSNumber(integer:Int(quantity)!)
            self.detailItems![indexPath!.row] = item
            self.tableView?.reloadData()
            self.updateTotalLabel()
            self.quantitySelectorMg!.closeAction()
            //TODO: Update quantity
        }
            
        self.quantitySelectorMg!.backgroundColor = UIColor.clearColor()
        let controller = UIViewController()
        controller.view.frame = CGRectMake(0.0, 0.0, 320.0, 388.0)
        controller.view.addSubview(self.quantitySelectorMg!)
        controller.view.backgroundColor = UIColor.clearColor()
            
        self.sharePopover = UIPopoverController(contentViewController: controller)
        self.sharePopover!.popoverContentSize =  CGSizeMake(320.0, 388.0)
        self.sharePopover!.backgroundColor = WMColor.light_blue
        let rect = cell.convertRect(cell.quantityIndicator!.frame, toView: self.view.superview!)
        self.sharePopover!.presentPopoverFromRect(rect, inView: self.view.superview!, permittedArrowDirections: .Any, animated: true)
    }
    
    override func willShowTabbar() { }
    
}