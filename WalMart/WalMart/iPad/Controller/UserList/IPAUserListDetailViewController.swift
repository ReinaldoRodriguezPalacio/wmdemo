//
//  IPAUserListDetailViewController.swift
//  WalMart
//
//  Created by neftali on 25/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

protocol IPAUserListDetailDelegate {
    func showProductListDetail(fromProducts products:[AnyObject], indexSelected index:Int)
    func reloadTableListUser()
    func closeUserListDetail()
    func reloadTableListUserSelectedRow()
}

class IPAUserListDetailViewController: UserListDetailViewController, UIPopoverControllerDelegate {

    var sharePopover: UIPopoverController?
    var delegate: IPAUserListDetailDelegate?
    var widthView : CGFloat = 682
    var addGestureLeft = false
    var isShared =  false
    

   
    override func viewDidLoad() {
        self.hiddenBack = true

        super.viewDidLoad()

        let shareWidth:CGFloat = 34.0
        let separation:CGFloat = 16.0
        var x = (self.footerSection!.frame.width - (shareWidth + separation + 254.0))/2
        let y = (self.footerSection!.frame.height - shareWidth)/2
       
        self.duplicateButton!.frame = CGRectMake(145, y, 34.0, 34.0)
        
        x = self.duplicateButton!.frame.maxX + 16.0
        self.shareButton!.frame = CGRectMake(x, y, shareWidth, shareWidth)
        x = self.shareButton!.frame.maxX + separation
        self.addToCartButton!.frame = CGRectMake(x, y, 254.0, shareWidth)
        self.customLabel!.frame = self.addToCartButton!.bounds
       // self.tableView.frame = CGRectMake(self.tableView!.frame.minx , self.tableView!.frame.minY, self.view.bounds.width, self.tableView!.frame.heigth)

        var frame : CGRect = self.tableView!.frame
        frame.size.width = widthView
        self.tableView!.frame = frame
        
        var framefooter : CGRect = self.footerSection!.frame
        framefooter.size.width = widthView
        self.footerSection!.frame = framefooter
        
        if addGestureLeft {
            let gestureSwipeLeft = UISwipeGestureRecognizer(target: self, action: "didTapClose")
            gestureSwipeLeft.direction = UISwipeGestureRecognizerDirection.Left
            self.header!.addGestureRecognizer(gestureSwipeLeft)
        }
        
        self.reminderButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        
        
        self.header!.frame = CGRectMake(0, 0, self.view.bounds.width, 46.0)
//        if CGRectEqualToRect(self.titleLabel!.frame, CGRectZero) {
//            self.layoutTitleLabel()
//        }
        self.backButton?.frame = CGRectMake(0, (self.header!.frame.height - 46.0)/2, 46.0, 46.0)
        if CGRectEqualToRect(self.editBtn!.frame, CGRectZero) {
            let headerBounds = self.header!.frame.size
            let buttonWidth: CGFloat = 55.0
            let buttonHeight: CGFloat = 22.0
            self.editBtn!.frame = CGRectMake(headerBounds.width - (buttonWidth + 16.0), (headerBounds.height - buttonHeight)/2, buttonWidth, buttonHeight)
            self.deleteAllBtn!.frame = CGRectMake(self.editBtn!.frame.minX - (90.0 + 8.0), (headerBounds.height - buttonHeight)/2, 90.0, buttonHeight)
        }
        
        let x = self.shareButton!.frame.maxX + 16.0
        let y = (self.footerSection!.frame.height - 34.0)/2
        
        addToCartButton?.frame = CGRectMake(x, y, 256, 34.0)//self.footerSection!.frame.width - (x + 16.0)
        self.customLabel?.frame  = self.addToCartButton!.bounds
        if !isShared {
            if showReminderButton{
                self.reminderButton?.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width,  28.0)
                self.reminderImage?.frame = CGRectMake(self.view.frame.width - 28, self.header!.frame.maxY + 8, 12.0, 12.0)
				self.addProductsView!.frame = CGRectMake(0,  self.reminderButton!.frame.maxY, self.view.frame.width, 64.0)
                self.tableView?.frame = CGRectMake(0, self.addProductsView!.frame.maxY, self.view.frame.width, self.view.frame.height - self.addProductsView!.frame.maxY)
            }else{
                self.tableView?.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, self.view.frame.height - self.header!.frame.maxY)
            }
        }

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        super.viewWillAppear(animated)
        if UserCurrentSession.hasLoggedUser() {
            self.showLoadingView()
            self.invokeDetailListService({ () -> Void in
                self.loading?.stopAnnimating()
                self.loading = nil
                
                if self.products == nil || self.products!.count == 0  {
                    self.selectedItems = []
                } else {
                self.selectedItems = NSMutableArray()
                for i in 0...self.products!.count - 1 {
                    self.selectedItems?.addObject(i)
                }
                self.updateTotalLabel()
                }
                
            }, reloadList: false)
        }
        else {
            self.retrieveProductsLocally(false)
            if self.products == nil  || self.products!.count == 0  {
                self.selectedItems = []
            } else {
            self.selectedItems = NSMutableArray()
            for i in 0...self.products!.count - 1 {
                self.selectedItems?.addObject(i)
            }
            }
            self.updateTotalLabel()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - Actions
    
    override func showEditionMode() {
        if !self.isEdditing {
            
            //Event
//            //TODOGAI
//            if let tracker = GAI.sharedInstance().defaultTracker {
//                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
//                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_EDIT.rawValue,
//                    label: self.listName,
//                    value: nil).build() as [NSObject : AnyObject])
//            }
            
            self.deleteAllBtn!.hidden = false
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.deleteAllBtn!.alpha = 1.0
            })
            var cells = self.tableView!.visibleCells
            for var idx = 0; idx < cells.count; idx++ {
                if let cell = cells[idx] as? DetailListViewCell {
                    cell.setEditing(true, animated: false)
                    cell.showLeftUtilityButtonsAnimated(true)
                }
            }
        }
        else {
            
            //Event
//            //TODOGAI
//            if let tracker = GAI.sharedInstance().defaultTracker {
//                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
//                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_ENDEDIT.rawValue,
//                    label: self.listName,
//                    value: nil).build() as [NSObject : AnyObject])
//            }

            
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.deleteAllBtn!.alpha = 0.0
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        self.deleteAllBtn!.hidden = true
                    }
                }
            )
            var cells = self.tableView!.visibleCells
            for var idx = 0; idx < cells.count; idx++ {
                if let cell = cells[idx] as? DetailListViewCell {
                    cell.hideUtilityButtonsAnimated(false)
                    cell.setEditing(false, animated: false)
                }
            }
        }
        
        self.isEdditing = !self.isEdditing
        self.editBtn!.selected = self.isEdditing
        
    }

    override func shareList() {
        if self.isEdditing {
            return
        }
        isShared = true

        if let image = self.buildImageToShare() {
            
            
            //Event
            //TODOGAI
//            if let tracker = GAI.sharedInstance().defaultTracker {
//                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
//                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_SHARELIST.rawValue,
//                    label: self.listName,
//                    value: nil).build() as [NSObject : AnyObject])
//            }
            
            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.sharePopover = UIPopoverController(contentViewController: controller)
            self.sharePopover!.delegate = self
            //self.sharePopover!.backgroundColor = UIColor.greenColor()
            let rect = self.footerSection!.convertRect(self.shareButton!.frame, toView: self.view.superview!)
            self.sharePopover!.presentPopoverFromRect(rect, inView: self.view.superview!, permittedArrowDirections: .Any, animated: true)
        }
    }

    override func showEmptyView() {
        self.emptyView = UIView(frame: CGRectMake(0.0, self.header!.frame.maxY, self.view.bounds.width, 612))
        self.emptyView!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.emptyView!)
        
        let bg = UIImageView(image: UIImage(named: "empty_list"))
        bg.frame = CGRectMake(0.0, 0.0, self.view.bounds.width, 612)
        self.emptyView!.addSubview(bg)
        
        let labelOne = UILabel(frame: CGRectMake(0.0, 28.0, self.view.bounds.width, 16.0))
        labelOne.textAlignment = .Center
        labelOne.textColor = WMColor.light_blue
        labelOne.font = WMFont.fontMyriadProLightOfSize(14.0)
        labelOne.text = NSLocalizedString("list.detail.empty.header", comment:"")
        self.emptyView!.addSubview(labelOne)
        
        let labelTwo = UILabel(frame: CGRectMake(0.0, labelOne.frame.maxY + 12.0, self.view.bounds.width, 16))
        labelTwo.textAlignment = .Center
        labelTwo.textColor = WMColor.light_blue
        labelTwo.font = WMFont.fontMyriadProRegularOfSize(14.0)
        labelTwo.text = NSLocalizedString("list.detail.empty.text", comment:"")
        self.emptyView!.addSubview(labelTwo)
        
        let icon = UIImageView(image: UIImage(named: "empty_list_icon"))
        icon.frame = CGRectMake(280.0, labelOne.frame.maxY + 12.0, 16.0, 16.0)
        self.emptyView!.addSubview(icon)
    }

    override func showLoadingView() {
        self.loading = WMLoadingView(frame: CGRectMake(0.0, 0.0, self.tableView!.bounds.width, self.tableView!.bounds.height + self.header!.frame.height + 88))
        self.loading!.startAnnimating(false)
        self.view.addSubview(self.loading!)
    }
    
    //MARK: - Utils

    //MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var productsToShow:[AnyObject] = []
        if !tableView.cellForRowAtIndexPath(indexPath)!.isKindOfClass(GRShoppingCartTotalsTableViewCell){
            for product  in self.products! {
                for var idx = 0; idx < self.products!.count; idx++ {
                    if let product = self.products![idx] as? [String:AnyObject] {
                        let upc = product["upc"] as! String
                        let description = product["description"] as! String
                        
                        productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Groceries.rawValue, "saving":""])
                    }
                    else if let product = self.products![idx] as? Product {
                        
                        productsToShow.append(["upc":product.upc, "description":product.desc, "type":ResultObjectType.Groceries.rawValue, "saving":""])
                    }
                }
            }
            self.delegate?.showProductListDetail(fromProducts: productsToShow, indexSelected: indexPath.row)
        }
        
    }

    //MARK: - DetailListViewCellDelegate
    
    override func didChangeQuantity(cell:DetailListViewCell) {
        if self.isEdditing {
            return
        }
        let indexPath = self.tableView!.indexPathForCell(cell)
        if indexPath == nil {
            return
        }
        
        var isPesable = false
        var price: NSNumber? = nil
        if let item = self.products![indexPath!.row] as? [String:AnyObject] {
            
            if let pesable = item["type"] as?  NSString {
                isPesable = pesable.intValue == 1
            }
            
            
            price = item["price"] as? NSNumber
        }
        else if let item = self.products![indexPath!.row] as? Product {
            isPesable = item.type.boolValue
            price = NSNumber(double: item.price.doubleValue)
        }
        
        

        if isPesable {
            self.quantitySelector = GRShoppingCartWeightSelectorView(frame: CGRectMake(0.0, 0.0, 320.0, 388.0), priceProduct: price,equivalenceByPiece:equivalenceByPiece,upcProduct:cell.upcVal!)
            
        }
        else {
            self.quantitySelector = GRShoppingCartQuantitySelectorView(frame: CGRectMake(0.0, 0.0, 320.0, 388.0), priceProduct: price,upcProduct:cell.upcVal!)
        }
        self.quantitySelector!.closeAction = { () in
            self.sharePopover?.dismissPopoverAnimated(true)
            return
        }
       
        self.quantitySelector!.addToCartAction = { (quantity:String) in
            
           
            if Int(quantity) <= 20000 {
            
             self.sharePopover?.dismissPopoverAnimated(false)
            
             if let item = self.products![indexPath!.row] as? [String:AnyObject] {
                 let upc = item["upc"] as? String
                 self.invokeUpdateProductFromListService(upc!, quantity: Int(quantity)!)
             }
             else if let item = self.products![indexPath!.row] as? Product {
                 item.quantity = NSNumber(integer: Int(quantity)!)
                 self.saveContext()
                 self.retrieveProductsLocally(true)
                 self.removeSelector()
             }
            }else{
                self.sharePopover?.dismissPopoverAnimated(true)
                
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                let secondMessage = NSLocalizedString("productdetail.notaviableinventorywe",comment:"")
                let msgInventory = "\(firstMessage) 20000 \(secondMessage)"
                alert!.setMessage(msgInventory)
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            }
        
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
        self.sharePopover!.backgroundColor = WMColor.light_blue
        let rect = cell.convertRect(cell.quantityIndicator!.frame, toView: self.view.superview!)
        self.sharePopover!.presentPopoverFromRect(rect, inView: self.view.superview!, permittedArrowDirections: .Any, animated: true)

    }
    
    override func duplicate() {
        if UserCurrentSession.hasLoggedUser() {
            let service = GRUserListService()
            self.itemsUserList = service.retrieveUserList()
            self.invokeSaveListToDuplicateService(forListId: listId!, andName: listName!, successDuplicateList: { () -> Void in
                self.delegate?.reloadTableListUser()
                self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
                self.alertView!.showDoneIcon()
            })
        }else{
            NSNotificationCenter.defaultCenter().postNotificationName("DUPLICATE_LIST", object: nil)
        }
    }

    //MARK: - UIPopoverControllerDelegate
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        self.sharePopover = nil
    }

    override func willShowTabbar() {
        
    }
    
    override func willHideTabbar() {
        
    }
    
    override func reloadTableListUser() {
        if delegate != nil {
            self.delegate!.reloadTableListUser()
        }
    }
    
    override func reloadTableListUserSelectedRow(){
        if delegate != nil {
            self.delegate!.reloadTableListUserSelectedRow()
        }
    }
    
    func didTapClose() {
        if delegate != nil {
            self.delegate!.closeUserListDetail()
        }
    }

    override func invokeDeleteProductFromListService(upc: String) {
        super.invokeDeleteProductFromListService(upc)
        self.delegate!.reloadTableListUser()
    }
    
    override func addReminder(){
        let selected = self.reminderButton!.selected
        let reminderViewController = ReminderViewController()
        reminderViewController.listId = self.listId!
        reminderViewController.listName = self.listName!
        reminderViewController.delegate = self
        if  selected {
            reminderViewController.selectedPeriodicity = self.reminderService!.currentNotificationConfig!["type"] as? Int
            reminderViewController.currentOriginalFireDate = self.reminderService!.currentNotificationConfig!["originalFireDate"] as? NSDate
        }
        reminderViewController.view.frame = self.view.bounds
        self.addChildViewController(reminderViewController)
        self.view.addSubview(reminderViewController.view)
        reminderViewController.didMoveToParentViewController(self)
    }

    
    //MARK: AddProductTolistViewDelegate
    override func scanCode() {
        let barCodeController = IPABarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.delegate = self
        barCodeController.searchProduct = true
        barCodeController.useDelegate = true
        barCodeController.isAnyActionFromCode =  true
        self.presentViewController(barCodeController, animated: true, completion: nil)
    }
    
    
    override func searchByTextAndCamfind(text: String,upcs:[String]?,searchContextType:SearchServiceContextType,searchServiceFromContext:SearchServiceFromContext) {
        
        let controller = IPASearchProductViewController()
        controller.upcsToShow = upcs
        controller.searchContextType = searchContextType
        controller.titleHeader = text
        controller.textToSearch = text
        controller.searchFromContextType = searchServiceFromContext
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    override func invokeAddproductTolist(response:NSDictionary?,products:[AnyObject]?,succesBlock:(() -> Void)){
        super.invokeAddproductTolist(response, products: products) { () -> Void in
            self.reloadTableListUser()
        }
        
    }

}
