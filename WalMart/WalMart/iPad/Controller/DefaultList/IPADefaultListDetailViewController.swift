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
    


    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = IPAProductDetailPageViewController()
        var productsToShow:[Any] = []
        for idx in 0 ..< self.detailItems!.count {
            let product = self.detailItems![idx]
            let upc = product["upc"] as! NSString
            let description = product["description"] as! NSString
            productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Groceries.rawValue, "saving":""])
        }
        controller.itemsToShow = productsToShow
        controller.ixSelected = indexPath.row
        controller.detailOf = self.defaultListName!
        
        if let navCtrl = self.navigationController!.parent as UIViewController! {
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
          tableView?.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.header!.frame.maxY)
        }
            self.footerSection!.frame = CGRect(x: 0,  y: self.view.frame.maxY - 72 , width: self.view.frame.width, height: 72)
            self.duplicateButton?.frame = CGRect(x: 145, y: y, width: 34.0, height: 34.0)
            
            x = self.duplicateButton!.frame.maxX + 16.0
            self.shareButton!.frame = CGRect(x: x, y: y, width: shareWidth, height: shareWidth)
            x = self.shareButton!.frame.maxX + separation
            addToCartButton?.frame = CGRect(x: x, y: y, width: 256, height: 34.0)//CGRectMake(x, y, self.footerSection!.frame.width - (x + 16.0), 34.0)
            self.customLabel?.frame  = self.addToCartButton!.bounds
      
    }

    
    override func shareList() {
        isShared = true

        if let image = self.buildImageToShare() {

            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
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
    
     //MARK: Delegate item cell
    override func didChangeQuantity(_ cell:DetailListViewCell){
        
        let indexPath = self.tableView!.indexPath(for: cell)
        if indexPath == nil {
            return
        }
        
        var isPesable = false
        var price: NSNumber? = nil
        var quantity: NSNumber? = nil
        
        let item = self.detailItems![indexPath!.row]
        
        if let pesable = item["type"] as? NSString {
            isPesable = pesable.intValue == 1
        }
        
        quantity = item["quantity"] as? NSNumber
        price = item["price"] as? NSNumber
        
        
        let width:CGFloat = self.view.frame.width
        var height:CGFloat = (self.view.frame.height - self.header!.frame.height) + 2.0
        if TabBarHidden.isTabBarHidden {
            height += 45.0
        }
        _ = CGRect(x: 0, y: self.view.frame.height, width: width, height: height)
        
        if isPesable {
            self.quantitySelector = GRShoppingCartWeightSelectorView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 388.0), priceProduct: price,equivalenceByPiece:cell.equivalenceByPiece!,upcProduct:cell.upcVal!)
        }
        else {
            self.quantitySelector = GRShoppingCartQuantitySelectorView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 388.0), priceProduct: price,upcProduct:cell.upcVal!)
        }
        
        if let orderByPiece = item["orderByPiece"] as? Bool {
            quantitySelector?.validateOrderByPiece(orderByPiece: orderByPiece, quantity: quantity!.doubleValue, pieces: Int(quantity!))
        } else {
            quantitySelector?.first = true
            quantitySelector?.userSelectValue(quantity!.stringValue)
        }
        
        self.view.addSubview(self.quantitySelector!)
        self.quantitySelector!.closeAction = { () in
            self.sharePopover!.dismiss(animated: true)
            //self.removeSelector()
        }
        //self.quantitySelector!.generateBlurImage(self.view, frame:CGRectMake(0.0, 0.0, width, height))
        self.quantitySelector!.addToCartAction = { (quantity:String) in
            var item = self.detailItems![indexPath!.row]
            //var upc = item["upc"] as? String
            item["quantity"] = NSNumber(value: Int(quantity)! as Int)
            item["orderByPiece"] = self.quantitySelector!.orderByPiece
            self.detailItems![indexPath!.row] = item
            self.tableView?.reloadData()
            //self.removeSelector()
            self.updateTotalLabel()
            self.sharePopover!.dismiss(animated: true)
            //TODO: Update quantity
        }
        
        self.quantitySelector!.backgroundColor = UIColor.clear
        self.quantitySelector!.backgroundView!.backgroundColor = UIColor.clear
        let controller = UIViewController()
        controller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 388.0)
        controller.view.addSubview(self.quantitySelector!)
        controller.view.backgroundColor = UIColor.clear
        
        self.sharePopover = UIPopoverController(contentViewController: controller)
        self.sharePopover!.contentSize =  CGSize(width: 320.0, height: 388.0)
        self.sharePopover!.delegate = self
        self.sharePopover!.backgroundColor = WMColor.light_blue
        let rect = cell.convert(cell.quantityIndicator!.frame, to: self.view.superview!)
        self.sharePopover!.present(from: rect, in: self.view.superview!, permittedArrowDirections: .any, animated: true)
        
    }
    
    //MARK: - UIPopoverControllerDelegate
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController) {
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
