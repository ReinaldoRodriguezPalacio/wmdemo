//
//  IPASchoolListViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 27/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class IPASchoolListViewController: SchoolListViewController, UIPopoverControllerDelegate {
    
    var sharePopover: UIPopoverController?
    var showInPopover:Bool = false
    var parentNavigationController: UINavigationController?
    
    override func setup() {
        super.setup()
        if self.showInPopover {
            self.backButton?.setImage(UIImage(named:"detail_close"), for: UIControlState())
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !self.isSharing {
            self.tableView?.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - (self.header!.frame.height + self.footerSection!.frame.height))
        }
        self.footerSection!.frame = CGRect(x: 0,  y: self.view.frame.maxY - 72 , width: self.view.frame.width, height: 72)
        let y = (self.footerSection!.frame.height - 34.0)/2
        var x: CGFloat = self.showInPopover ? 312 : 162.0
        self.selectAllButton?.frame = CGRect(x: x, y: y, width: 34.0, height: 34.0)
         x = self.selectAllButton!.frame.maxX + 16
        self.shareButton!.frame = CGRect(x: x, y: y, width: 34.0, height: 34.0)
        self.wishlistButton!.frame = CGRect(x: x, y: y, width: 34.0, height: 34.0)
         x = self.wishlistButton!.frame.maxX + 16
        let shopButtonSpace: CGFloat = self.showInPopover ? 296.0 : 146.0
        self.addToCartButton?.frame = CGRect(x: x, y: y, width: self.footerSection!.frame.width - (x + shopButtonSpace), height: 34.0)
        self.customLabel!.frame = CGRect(x: 0, y: 0, width: self.footerSection!.frame.width - (x + shopButtonSpace), height: 34.0)
    }
    
    //MARK: TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 || indexPath.row == self.detailItems!.count {
            return
        }
        
        let controller = IPAProductDetailPageViewController()
        var productsToShow:[Any] = []
        for idx in 0 ..< self.detailItems!.count {
            let product = self.detailItems![idx]
            let upc = product["upc"] as! NSString
            let description = product["description"] as! NSString
            
            productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Mg.rawValue, "saving":""])
        }
        controller.itemsToShow = productsToShow
        controller.ixSelected = indexPath.row
        controller.detailOf = self.schoolName
        
        //let product = self.detailItems![indexPath.row]
        //let upc = product["upc"] as! NSString
        //let description = product["description"] as! NSString
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL_PRACTILISTA.rawValue, label: "\(description) - \(upc)")
        
        if self.navigationController != nil && !self.showInPopover {
            if let navCtrl = self.navigationController!.parent as UIViewController! {
                navCtrl.navigationController!.pushViewController(controller, animated: true)
            }
        }else{
            self.parentNavigationController!.pushViewController(controller, animated: true)
        }
        
        
    }
    
    //MARK: Delegate item cell
    override func didChangeQuantity(_ cell:DetailListViewCell){
            
        let indexPath = self.tableView!.indexPath(for: cell)
        if indexPath == nil {
            return
        }
        var price: String? = nil
            
        let item = self.detailItems![indexPath!.row]
        price = item["price"] as? String
        let selectorFrame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 388.0)
        self.quantitySelectorMg = ShoppingCartQuantitySelectorView(frame: selectorFrame, priceProduct: NSNumber(value: Double(price!)! as Double),upcProduct:cell.upcVal!)
        self.view.addSubview(self.quantitySelectorMg!)
        self.quantitySelectorMg!.closeAction = { () in
            self.sharePopover!.dismiss(animated: true)
            self.quantitySelectorMg = nil
        }
        self.quantitySelectorMg!.addToCartAction = { (quantity:String) in
            self.quantitySelectorMg!.closeAction()
            let maxProducts = (cell.onHandInventory <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory : 5
            if maxProducts >= Int(quantity) {
                var item = self.detailItems![indexPath!.row]
                //var upc = item["upc"] as? String
                item["quantity"] = NSNumber(value: Int(quantity)! as Int)
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
        
        self.quantitySelectorMg!.backgroundColor = UIColor.clear
        let controller = UIViewController()
        controller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 388.0)
        controller.view.addSubview(self.quantitySelectorMg!)
        controller.view.backgroundColor = UIColor.clear
            
        self.sharePopover = UIPopoverController(contentViewController: controller)
        self.sharePopover!.contentSize =  CGSize(width: 320.0, height: 388.0)
        self.sharePopover!.backgroundColor = WMColor.light_blue

        let rect = cell.convert(cell.quantityIndicator!.frame, to: self.view.superview!)
        self.sharePopover!.present(from: rect, in: self.view.superview!, permittedArrowDirections: .any, animated: true)
    }
    
    /**
     Add loading view
     */
    override func addViewLoad(){
        if self.loading == nil {
            self.loading = WMLoadingView(frame: CGRect(x: 0.0, y: 0.0, width: 682.0, height: 658.0))
            if self.showInPopover {
                self.loading?.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height)
            }
            self.loading!.backgroundColor = UIColor.white
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
            let rect = self.footerSection!.convert(self.shareButton!.frame, to: self.view.superview!)
            self.sharePopover!.present(from: rect, in: self.view.superview!, permittedArrowDirections: .any, animated: true)
            
            
            controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        }
    }
    
    //MARK: - UIPopoverControllerDelegate
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController) {
        self.sharePopover = nil
    }
    
    override func willShowTabbar() { }
}
