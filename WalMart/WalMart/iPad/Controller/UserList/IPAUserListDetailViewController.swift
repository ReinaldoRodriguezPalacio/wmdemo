//
//  IPAUserListDetailViewController.swift
//  WalMart
//
//  Created by neftali on 25/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit
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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


protocol IPAUserListDetailDelegate {
    func showProductListDetail(fromProducts products:[Any], indexSelected index:Int)
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
    var showReminderController = true
    var searchInList : (( _ controller:IPASearchProductViewController) -> Void)?
    var hiddenBackButton: Bool = true
   
    override func viewDidLoad() {
        self.hiddenBack = self.hiddenBackButton

        super.viewDidLoad()
        let shareWidth:CGFloat = 34.0
        let separation:CGFloat = 16.0
        var x = (self.footerSection!.frame.width - (shareWidth + separation + 254.0))/2
        let y = (self.footerSection!.frame.height - shareWidth)/2
       
        self.duplicateButton!.frame = CGRect(x: 145, y: y, width: 34.0, height: 34.0)
        
        x = self.duplicateButton!.frame.maxX + 16.0
        self.shareButton!.frame = CGRect(x: x, y: y, width: shareWidth, height: shareWidth)
        x = self.shareButton!.frame.maxX + separation
        self.addToCartButton!.frame = CGRect(x: x, y: y, width: 254.0, height: shareWidth)
        self.customLabel!.frame = self.addToCartButton!.bounds
       // self.tableView.frame = CGRectMake(self.tableView!.frame.minx , self.tableView!.frame.minY, self.view.bounds.width, self.tableView!.frame.heigth)

        var frame : CGRect = self.tableView!.frame
        frame.size.width = widthView
        self.tableView!.frame = frame
        
        var framefooter : CGRect = self.footerSection!.frame
        framefooter.size.width = widthView
        framefooter.origin = CGPoint(x: 0, y: 590.0)
        self.footerSection!.frame = framefooter
        
        if addGestureLeft {
            let gestureSwipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(IPAUserListDetailViewController.didTapClose))
            gestureSwipeLeft.direction = UISwipeGestureRecognizerDirection.left
            self.header!.addGestureRecognizer(gestureSwipeLeft)
        }
        self.reminderButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        if !UserCurrentSession.hasLoggedUser() {
            self.retrieveProductsLocally(false)
            self.counSections()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        self.header!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 46.0)

        self.backButton?.frame = CGRect(x: 0, y: (self.header!.frame.height - 46.0)/2, width: 46.0, height: 46.0)
        if self.editBtn!.frame.equalTo(CGRect.zero) {
            let headerBounds = self.header!.frame.size
            let buttonWidth: CGFloat = 55.0
            let buttonHeight: CGFloat = 22.0
            self.editBtn!.frame = CGRect(x: headerBounds.width - (buttonWidth + 16.0), y: (headerBounds.height - buttonHeight)/2, width: buttonWidth, height: buttonHeight)
            self.deleteAllBtn!.frame = CGRect(x: self.editBtn!.frame.minX - (90.0 + 8.0), y: (headerBounds.height - buttonHeight)/2, width: 90.0, height: buttonHeight)
        }
        
        var x = self.shareButton!.frame.maxX + 16.0
        let y = (self.footerSection!.frame.height - 34.0)/2
        
        addToCartButton?.frame = CGRect(x: x, y: y, width: 256, height: 34.0)
        self.customLabel?.frame  = self.addToCartButton!.bounds
        if !isShared {
            if showReminderButton{
                
                self.reminderButton?.frame = CGRect(x: self.shareButton!.frame.maxX + 16.0, y: self.shareButton!.frame.minY, width: 34, height: 34)
                x = self.reminderButton!.frame.maxX + 16.0
                self.addToCartButton?.frame = CGRect(x: x, y: y, width: 256, height: 34.0)
                self.customLabel?.frame  = self.addToCartButton!.bounds
                
                self.addProductsView!.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: 64.0)
                
                self.tableView?.frame = CGRect(x: 0, y: self.addProductsView!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.addProductsView!.frame.maxY)
            }else{
                self.tableView?.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.header!.frame.maxY)
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showLoadingView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.loading != nil {
            self.loading!.stopAnnimating()
        }
        
        if UserCurrentSession.hasLoggedUser() {
            self.showLoadingView()
            self.invokeDetailListService({ () -> Void in
                self.loading?.stopAnnimating()
                self.loading = nil
                self.reminderButton!.isHidden = false
                if self.products == nil || self.products!.count == 0  {
                    self.selectedItems = []
                } else {
                    if self.fromDelete || self.selectedItems == nil {
                        self.fromDelete =  false
                        self.selectedItems = NSMutableArray()
                        for i in 0...self.products!.count - 1 {
                            self.selectedItems?.add(i)
                        }
                    }
                self.updateTotalLabel()
                    self.showHelpViewDetail()
                }
                 self.tableView!.reloadData()
                
            }, reloadList: false)
        }
        else {
            self.retrieveProductsLocally(false)
            if self.products == nil  || self.products!.count == 0  {
                self.selectedItems = []
            } else {
            self.counSections()
            self.selectedItems = NSMutableArray()
            for i in 0...self.products!.count - 1 {
                
                let item =  self.products![i] as? Product
                self.selectedItems?.add(item!.upc )
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
    
    override func showHelpViewDetail(){
        var requiredHelp = true
        if let param = CustomBarViewController.retrieveParam("reminderListHelp") {
            requiredHelp = !(param.value == "false")
        }
        let  showReminderHelp = (requiredHelp && self.listDetailHelView == nil)
        
        if showReminderHelp {
            listDetailHelView =  ListHelpView(frame: CGRect(x: 0,y: 0,width: self.view.bounds.width,height: self.view.bounds.height),context:ListHelpContextType.inReminderList )
            listDetailHelView?.onClose  = {() in
                self.removeHelpView()
            }
            
            let window = UIApplication.shared.keyWindow
            if let customBar = window!.rootViewController as? IPACustomBarViewController {
                listDetailHelView?.frame = CGRect(x: 0,y: 0 , width: customBar.view.bounds.width, height: customBar.view.frame.height)
                customBar.view.addSubview(listDetailHelView!)
                CustomBarViewController.addOrUpdateParam("reminderListHelp", value: "false")
            }
        }
    }
    
    override func showEditionMode() {
        if !self.isEdditing {
            self.deleteAllBtn!.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.deleteAllBtn!.alpha = 1.0
            })
            var cells = self.tableView!.visibleCells
            for idx in 0 ..< cells.count {
                if let cell = cells[idx] as? DetailListViewCell {
                    cell.setEditing(true, animated: false)
                    cell.showLeftUtilityButtons(animated: true)
                }
            }
        }
        else {
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    self.deleteAllBtn!.alpha = 0.0
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        self.deleteAllBtn!.isHidden = true
                    }
                }
            )
            var cells = self.tableView!.visibleCells
            for idx in 0 ..< cells.count {
                if let cell = cells[idx] as? DetailListViewCell {
                    cell.hideUtilityButtons(animated: false)
                    cell.setEditing(false, animated: false)
                }
            }
        }
        
        self.isEdditing = !self.isEdditing
        self.editBtn!.isSelected = self.isEdditing
        
    }

    override func shareList() {
        if self.isEdditing {
            return
        }
        isShared = true
            
        if let image = self.tableView!.screenshot() {
            let imageHead = UIImage(named:"detail_HeaderMail")
            let imgResult = UIImage.verticalImage(from: [imageHead!,image])
            let controller = UIActivityViewController(activityItems: [imgResult], applicationActivities: nil)
            self.sharePopover = UIPopoverController(contentViewController: controller)
            self.sharePopover!.delegate = self
                //self.sharePopover!.backgroundColor = UIColor.greenColor()
            let rect = self.footerSection!.convert(self.shareButton!.frame, to: self.view.superview!)
            self.sharePopover!.present(from: rect, in: self.view.superview!, permittedArrowDirections: .any, animated: true)
        }
    }

    override func showEmptyView() {
         self.openEmpty = true
        
        self.titleLabel?.text = self.listName
        if self.emptyView == nil {
            self.emptyView = UIView()
        }
        
        if UserCurrentSession.hasLoggedUser() {
           self.emptyView!.frame = CGRect(x: 0.0, y: self.header!.frame.maxY + 64, width: self.view.bounds.width, height: 612 - 64 )
        }else{
            self.emptyView!.frame = CGRect(x: 0.0, y: self.header!.frame.maxY, width: self.view.bounds.width, height: 612)
        }
        
        self.emptyView!.backgroundColor = UIColor.white
       
        
        
        self.emptyView!.backgroundColor = UIColor.white
        self.view.addSubview(self.emptyView!)
        
        let bg = UIImageView(image: UIImage(named:UserCurrentSession.hasLoggedUser() ? "empty_list" : "list_empty_no"))
        bg.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: UserCurrentSession.hasLoggedUser() ?  612 - 64 : 612)
        self.emptyView!.addSubview(bg)
        
        let labelOne = UILabel(frame: CGRect(x: 0.0, y: 28.0, width: self.view.bounds.width, height: 16.0))
        labelOne.textAlignment = .center
        labelOne.textColor = WMColor.light_blue
        labelOne.font = WMFont.fontMyriadProLightOfSize(14.0)
        labelOne.text = NSLocalizedString("list.detail.empty.header", comment:"")
        self.emptyView!.addSubview(labelOne)
        
        let labelTwo = UILabel(frame: CGRect(x: 0.0, y: labelOne.frame.maxY + 12.0, width: self.view.bounds.width, height: 48))
        labelTwo.textAlignment = .center
        labelTwo.textColor = WMColor.light_blue
        labelTwo.numberOfLines =  5
        labelTwo.font = WMFont.fontMyriadProRegularOfSize(14.0)
        labelTwo.text = NSLocalizedString("list.detail.empty.text", comment:"")
        self.emptyView!.addSubview(labelTwo)
        
        let icon = UIImageView(image: UIImage(named: "empty_list_icon"))
        icon.frame = CGRect(x: 242.0, y: labelTwo.frame.maxY - 18.0, width: 16.0, height: 16.0)
        self.emptyView!.addSubview(icon)
    }

    override func showLoadingView() {
        self.loading = WMLoadingView(frame: CGRect(x: 0.0, y: 0.0, width: self.tableView!.bounds.width, height: 746))
        self.loading!.startAnnimating(true)
        self.view.addSubview(self.loading!)
    }
    
    //MARK: - Utils

    //MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var productsToShow:[Any] = []
        if !tableView.cellForRow(at: indexPath)!.isKind(of: ShoppingCartTotalsTableViewCell.self){
            for productObj  in self.products! {
                if let product = productObj as? [String:Any] {
                    
                    if let sku = product["sku"] as? [String:Any] {
                        if let parentProducts = sku["parentProducts"] as? [[String:Any]]{
                            if let item =  parentProducts.object(at: 0) as? [String:Any] {
                                let upc = item["repositoryId"] as! String
                                let description = item["description"] as! String
                                productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Groceries.rawValue, "saving":""])
                            }
                        }
                    }
                    
                }
                else if let product = productObj as? Product {
                    productsToShow.append(["upc":product.upc, "description":product.desc, "type":ResultObjectType.Groceries.rawValue, "saving":""])
                }
            }
            self.delegate?.showProductListDetail(fromProducts: productsToShow, indexSelected: (indexPath as NSIndexPath).row)
        }
        
    }

    //MARK: - DetailListViewCellDelegate
    
    override func didChangeQuantity(_ cell:DetailListViewCell) {
        if self.isEdditing {
            return
        }
        let indexPath = self.tableView!.indexPath(for: cell)
        if indexPath == nil {
            return
        }
        
        var isPesable = false
        var price: NSNumber? = nil
        if let item = self.products![(indexPath! as NSIndexPath).row] as? [String:Any] {
            
            if let pesable = item["type"] as?  NSString {
                isPesable = pesable.intValue == 1
            }
            let numberPrice =  NumberFormatter()
            numberPrice.numberStyle = .decimal
            price = numberPrice.number(from: item["specialPrice"] as! String)
            
        }
        else if let item = self.products![(indexPath! as NSIndexPath).row] as? Product {
            isPesable = item.type.boolValue
            price = NSNumber(value: item.price.doubleValue as Double)
        }
        
        

        if isPesable {
            self.quantitySelector = GRShoppingCartWeightSelectorView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 388.0), priceProduct: price,equivalenceByPiece:equivalenceByPiece,upcProduct:cell.upcVal!)
            
        }
        else {
            self.quantitySelector = GRShoppingCartQuantitySelectorView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 388.0), priceProduct: price,upcProduct:cell.upcVal!)
        }
        self.quantitySelector!.closeAction = { () in
            self.sharePopover?.dismiss(animated: true)
            return
        }
       
        self.quantitySelector!.addToCartAction = { (quantity:String) in
            
           
            if Int(quantity) <= 20000 {
            
             self.sharePopover?.dismiss(animated: false)
            
             if let item = self.products![(indexPath! as NSIndexPath).row] as? [String:Any] {
                
                if let sku = item["sku"] as? [String:Any] {
                    if let parentProducts = sku["parentProducts"] as? [[String:Any]]{
                        if let productItem =  parentProducts.object(at: 0) as? [String:Any] {
                            self.invokeUpdateProductFromListService(fromUpc:productItem["repositoryId"] as! String , skuId:sku["id"] as! String , quantity: Int(quantity)!)
                        }
                    }
                }
                
             }
             else if let item = self.products![(indexPath! as NSIndexPath).row] as? Product {
                 item.quantity = NSNumber(value: Int(quantity)! as Int)
                 self.saveContext()
                 self.retrieveProductsLocally(true)
                 self.removeSelector()
             }
            }else{
                self.sharePopover?.dismiss(animated: true)
                
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                let secondMessage = NSLocalizedString("productdetail.notaviableinventorywe",comment:"")
                let msgInventory = "\(firstMessage) 20000 \(secondMessage)"
                alert!.setMessage(msgInventory)
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            }
        
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
    
    override func duplicate() {
        if UserCurrentSession.hasLoggedUser() {
            if itemsUserList?.count >= 12{
                alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
                self.alertView!.setMessage(NSLocalizedString("list.error.validation.max",comment:""))
                self.alertView!.showErrorIcon("Ok")
            }else{
                let service = GRUserListService()
                //TODO: Checar como hacer este cast
                //self.itemsUserList = service.retrieveUserList() as! [[String : Any]]?
                self.invokeSaveListToDuplicateService(forListId: self.products!, andName: listName!, successDuplicateList: { () -> Void in
                    self.delegate?.reloadTableListUser()
                    self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
                    self.alertView!.showDoneIcon()
                })
            }
        }else{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "DUPLICATE_LIST"), object: nil)
        }
    }

    //MARK: - UIPopoverControllerDelegate
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController) {
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

    override func invokeDeleteProductFromListService(repositoryId: String, succesDelete: @escaping (() -> Void)) {
        super.invokeDeleteProductFromListService(repositoryId: repositoryId) { () -> Void in
            self.delegate!.reloadTableListUser()
        }
        
    }
    
 
    
    override func addReminder(){
        if self.showReminderController{
            self.showReminderController = false
            let selected = self.reminderButton!.isSelected
            let reminderViewController = ReminderViewController()
            reminderViewController.listId = self.listId!
            reminderViewController.listName = self.listName!
            reminderViewController.delegate = self
            if  selected {
                reminderViewController.reminderService?.findNotificationForCurrentList()
                reminderViewController.selectedPeriodicity = self.reminderService!.currentNotificationConfig?["type"] as? Int
                reminderViewController.currentOriginalFireDate = self.reminderService!.currentNotificationConfig?["originalFireDate"] as? Date
            }
            reminderViewController.view.frame = CGRect(x: self.view.bounds.maxX, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
            self.addChildViewController(reminderViewController)
            self.view.addSubview(reminderViewController.view)
            UIView.animate(withDuration: 0.4, delay: 0.1, options: [], animations: {
                reminderViewController.view.frame = self.view.bounds
                }, completion: {(finish) in
                    reminderViewController.didMove(toParentViewController: self)
            })
        }
    }

    
    //MARK: AddProductTolistViewDelegate
    override func scanCode() {
        let barCodeController = IPABarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.delegate = self
        barCodeController.searchProduct = true
        barCodeController.useDelegate = true
        barCodeController.isAnyActionFromCode =  true
        self.present(barCodeController, animated: true, completion: nil)
    }
    
    
    override func searchByTextAndCamfind(_ text: String,upcs:[String]?,searchContextType:SearchServiceContextType,searchServiceFromContext:SearchServiceFromContext) {
        
        let controller = IPASearchProductViewController()
        controller.upcsToShow = upcs
        controller.searchContextType = searchContextType
        controller.titleHeader = text
        controller.textToSearch = text
        controller.searchFromContextType = searchServiceFromContext
        controller.idListFromSearch = self.listId
        self.retunrFromSearch =  true
        if self.searchInList != nil {
            self.searchInList?(controller)
        }else{
            self.navigationController?.pushViewController(controller, animated: true)
        }

        
    }
    
    override func searchByText(_ text: String) {
        if text.isNumeric() && text.length() == 13 ||  text.length() == 14 {
             self.findProdutFromUpc(text)
//            let window = UIApplication.sharedApplication().keyWindow
//            if let customBar = window!.rootViewController as? IPACustomBarViewController {
//                customBar.idListSelected =  self.listId!
//                customBar.handleNotification("UPC",name:"",value:text,bussines:"gr")
//            }
        }else{
            super.searchByText(text)
        }
      
    }
    
    override func invokeAddproductTolist(_ response:[String:Any]?,products:[Any]?,succesBlock:@escaping (() -> Void)){
        super.invokeAddproductTolist(response, products: products) { () -> Void in
            self.reloadTableListUser()
        }
        
    }
    
    override func notifyReminderWillClose(forceValidation flag: Bool, value: Bool) {
        self.showReminderController = true
        if self.reminderService!.existNotificationForCurrentList() || value{
            setReminderSelected(true)
        }else{
            setReminderSelected(false)
        }
    }

}
