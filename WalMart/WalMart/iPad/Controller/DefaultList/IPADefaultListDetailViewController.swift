//
//  IPADefaultListDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 02/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol IPADefaultListDetailViewControllerDelegate {
    func reloadViewList()
}

class IPADefaultListDetailViewController :  DefaultListDetailViewController,UIPopoverControllerDelegate {
    
    var sharePopover: UIPopoverController?
    var delegate : IPADefaultListDetailViewControllerDelegate?
    var isShared =  false
    
    override func willShowTabbar() {
        isShowingTabBar = false
    }
    
    override func willHideTabbar() {
        isShowingTabBar = false
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = IPAProductDetailPageViewController()
        var productsToShow:[AnyObject] = []
        for var idx = 0; idx < self.detailItems!.count; idx++ {
            let product = self.detailItems![idx]
            let upc = product["upc"] as! NSString
            let description = product["description"] as! NSString
            //Event
            //TODOGAI:
//            if let tracker = GAI.sharedInstance().defaultTracker {
//                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
//                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_PRODUCTDETAIL.rawValue,
//                    label: upc as String,
//                    value: nil).build() as [NSObject : AnyObject])
//            }
            
            productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Groceries.rawValue, "saving":""])
        }
        controller.itemsToShow = productsToShow
        controller.ixSelected = indexPath.row
        
        if let navCtrl = self.navigationController!.parentViewController as UIViewController! {
            navCtrl.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let shareWidth:CGFloat = 34.0
        let separation:CGFloat = 16.0
        var x = (self.footerSection!.frame.width - (shareWidth + separation + 254.0))/2
        let y = (self.footerSection!.frame.height - shareWidth)/2
        
        if !isShared {
          tableView?.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, self.view.frame.height - self.header!.frame.maxY)
        }
            self.footerSection!.frame = CGRectMake(0,  self.view.frame.maxY - 72 , self.view.frame.width, 72)
            self.duplicateButton?.frame = CGRectMake(145, y, 34.0, 34.0)
            
            x = self.duplicateButton!.frame.maxX + 16.0
            self.shareButton!.frame = CGRectMake(x, y, shareWidth, shareWidth)
            x = self.shareButton!.frame.maxX + separation
            addToCartButton?.frame = CGRectMake(x, y, 256, 34.0)//CGRectMake(x, y, self.footerSection!.frame.width - (x + 16.0), 34.0)
            self.customLabel?.frame  = self.addToCartButton!.bounds
      
    }

    
    override func shareList() {
        isShared = true

        if let image = self.buildImageToShare() {

            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.sharePopover = UIPopoverController(contentViewController: controller)
            self.sharePopover!.delegate = self
            //self.sharePopover!.backgroundColor = UIColor.greenColor()
            let rect = self.footerSection!.convertRect(self.shareButton!.frame, toView: self.view.superview!)
            self.sharePopover!.presentPopoverFromRect(rect, inView: self.view.superview!, permittedArrowDirections: .Any, animated: true)
        }
    }
    
     //MARK: Delegate item cell
    override func didChangeQuantity(cell:DetailListViewCell){
        
                   
            let indexPath = self.tableView!.indexPathForCell(cell)
            if indexPath == nil {
                return
            }
            var isPesable = false
            var price: NSNumber? = nil
            
            let item = self.detailItems![indexPath!.row]
            if let pesable = item["type"] as? NSString {
                isPesable = pesable.intValue == 1
            }
            price = item["price"] as? NSNumber
            
            
            let width:CGFloat = self.view.frame.width
            var height:CGFloat = (self.view.frame.height - self.header!.frame.height) + 2.0
            if TabBarHidden.isTabBarHidden {
                height += 45.0
            }
            _ = CGRectMake(0, self.view.frame.height, width, height)
            
            if isPesable {
                self.quantitySelector = GRShoppingCartWeightSelectorView(frame: CGRectMake(0.0, 0.0, 320.0, 388.0), priceProduct: price,equivalenceByPiece:cell.equivalenceByPiece!,upcProduct:cell.upcVal!)
            }
            else {
                self.quantitySelector = GRShoppingCartQuantitySelectorView(frame: CGRectMake(0.0, 0.0, 320.0, 388.0), priceProduct: price,upcProduct:cell.upcVal!)
            }
            self.view.addSubview(self.quantitySelector!)
            self.quantitySelector!.closeAction = { () in
                self.sharePopover!.dismissPopoverAnimated(true)
                //self.removeSelector()
            }
            //self.quantitySelector!.generateBlurImage(self.view, frame:CGRectMake(0.0, 0.0, width, height))
            self.quantitySelector!.addToCartAction = { (quantity:String) in
                var item = self.detailItems![indexPath!.row]
                //var upc = item["upc"] as? String
                item["quantity"] = NSNumber(integer:Int(quantity)!)
                self.detailItems![indexPath!.row] = item
                self.tableView?.reloadData()
                //self.removeSelector()
                self.updateTotalLabel()
                self.sharePopover!.dismissPopoverAnimated(true)
                //TODO: Update quantity
        }
        
            self.quantitySelector!.backgroundColor = UIColor.clearColor()
            self.quantitySelector!.backgroundView!.backgroundColor = UIColor.clearColor()
            let controller = UIViewController()
            controller.view.frame = CGRectMake(0.0, 0.0, 320.0, 388.0)
            controller.view.addSubview(self.quantitySelector!)
            controller.view.backgroundColor = UIColor.clearColor()
            
            self.sharePopover = UIPopoverController(contentViewController: controller)
            self.sharePopover!.popoverContentSize =  CGSizeMake(320.0, 388.0)
            self.sharePopover!.delegate = self
            self.sharePopover!.backgroundColor = WMColor.productAddToCartQuantitySelectorBgColor
            let rect = cell.convertRect(cell.quantityIndicator!.frame, toView: self.view.superview!)
            self.sharePopover!.presentPopoverFromRect(rect, inView: self.view.superview!, permittedArrowDirections: .Any, animated: true)
            
//            UIView.animateWithDuration(0.5, animations: { () -> Void in
//                self.quantitySelector!.frame = CGRectMake(0.0, 0.0, width, height)
//            })
            
      
    }
    
    //MARK: - UIPopoverControllerDelegate
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        self.sharePopover = nil
    }

    override func duplicate() {
        self.invokeSaveListToDuplicateService(defaultListName!, successDuplicateList: { () -> Void in
            self.delegate?.reloadViewList()
            self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
            self.alertView!.showDoneIcon()
        })
    }
    
}