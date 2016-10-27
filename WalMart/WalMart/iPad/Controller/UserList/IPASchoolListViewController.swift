//
//  IPASchoolListViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 27/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class IPASchoolListViewController: SchoolListViewController, UIPopoverControllerDelegate {
    
    var sharePopover: UIPopoverController?
    var showInPopover:Bool = false
    var parentNavigationController: UINavigationController?
    
    override func setup() {
        super.setup()
        if self.showInPopover {
            self.backButton?.setImage(UIImage(named:"detail_close"), forState: .Normal)
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !self.isSharing {
            self.tableView?.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, self.view.frame.height - (self.header!.frame.height + self.footerSection!.frame.height))
        }
        self.footerSection!.frame = CGRectMake(0,  self.view.frame.maxY - 72 , self.view.frame.width, 72)
        let y = (self.footerSection!.frame.height - 34.0)/2
        var x: CGFloat = self.showInPopover ? 312 : 162.0
        self.selectAllButton?.frame = CGRectMake(x, y, 34.0, 34.0)
         x = self.selectAllButton!.frame.maxX + 16
        self.shareButton!.frame = CGRectMake(x, y, 34.0, 34.0)
        self.wishlistButton!.frame = CGRectMake(x, y, 34.0, 34.0)
         x = self.wishlistButton!.frame.maxX + 16
        let shopButtonSpace: CGFloat = self.showInPopover ? 296.0 : 146.0
        self.addToCartButton?.frame = CGRectMake(x, y, self.footerSection!.frame.width - (x + shopButtonSpace), 34.0)
        self.customLabel!.frame = CGRectMake(0, 0, self.footerSection!.frame.width - (x + shopButtonSpace), 34.0)
    }
    
    //MARK: TableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 || indexPath.row == self.detailItems!.count {
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
        controller.detailOf = self.schoolName
        
        let product = self.detailItems![indexPath.row]
        let upc = product["upc"] as! NSString
        let description = product["description"] as! NSString
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL_PRACTILISTA.rawValue, label: "\(description) - \(upc)")
        
        if self.navigationController != nil && !self.showInPopover {
            if let navCtrl = self.navigationController!.parentViewController as UIViewController! {
                navCtrl.navigationController!.pushViewController(controller, animated: true)
            }
        }else{
            self.parentNavigationController!.pushViewController(controller, animated: true)
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
            self.quantitySelectorMg!.closeAction()
            let maxProducts = (cell.onHandInventory <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory : 5
            if maxProducts >= Int(quantity) {
                var item = self.detailItems![indexPath!.row]
                //var upc = item["upc"] as? String
                item["quantity"] = NSNumber(integer:Int(quantity)!)
                self.detailItems![indexPath!.row] = item
                self.tableView?.reloadData()
                self.removeSelector()
                self.updateTotalLabel()
            }else {
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                
                let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                let msgInventory = "\(firstMessage)\(maxProducts) \(secondMessage)"
                alert!.setMessage(msgInventory)
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                self.quantitySelectorMg?.lblQuantity?.text = maxProducts < 10 ? "0\(maxProducts)" : "\(maxProducts)"
            }
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
    
    /**
     Add loading view
     */
    override func addViewLoad(){
        if self.loading == nil {
            self.loading = WMLoadingView(frame: CGRectMake(0.0, 0.0, 682.0, 658.0))
            if self.showInPopover {
                self.loading?.frame = CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height)
            }
            self.loading!.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
    }
    
    //MARK: Actions
    /**
     Share view
     */
    override func shareList() {
        //isShared = true
        if let image = self.buildImageToShare() {
            let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx/")
            
            let controller = UIActivityViewController(activityItems: [self,image,urlWmart!], applicationActivities: nil)
            //let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.sharePopover = UIPopoverController(contentViewController: controller)
            self.sharePopover!.delegate = self
            //self.sharePopover!.backgroundColor = UIColor.greenColor()
            let rect = self.footerSection!.convertRect(self.shareButton!.frame, toView: self.view.superview!)
            self.sharePopover!.presentPopoverFromRect(rect, inView: self.view.superview!, permittedArrowDirections: .Any, animated: true)
            
            if #available(iOS 8.0, *) {
                controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
                    if completed && !activityType!.containsString("com.apple")   {
                        BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                    }
                }
            } else {
                controller.completionHandler = {(activityType, completed:Bool) in
                    if completed && !activityType!.containsString("com.apple")   {
                        BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                    }
                }
            }
        }
    }
    
    //MARK: - UIPopoverControllerDelegate
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        self.sharePopover = nil
    }
    
    override func willShowTabbar() { }
}