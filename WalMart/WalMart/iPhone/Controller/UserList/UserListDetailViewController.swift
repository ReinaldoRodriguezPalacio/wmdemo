//
//  UserListDetailViewController.swift
//  WalMart
//
//  Created by neftali on 20/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class UserListDetailViewController: UserListNavigationBaseViewController, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, DetailListViewCellDelegate, UITextFieldDelegate {

    let CELL_ID = "listCell"
    let TOTAL_CELL_ID = "totalsCell"

    @IBOutlet var tableView: UITableView?
    @IBOutlet var footerSection: UIView?
    
    @IBOutlet var footerConstraint: NSLayoutConstraint?
    @IBOutlet var tableConstraint: NSLayoutConstraint?

    var editBtn: UIButton?
    
    var deleteAllBtn: UIButton?
    var shareButton: UIButton?
    var duplicateButton: UIButton?
    var addToCartButton: UIButton?
    var customLabel: CurrencyCustomLabel?
    var nameField: FormFieldView?
    
    var loading: WMLoadingView?
    var emptyView: UIView?
    var quantitySelector: GRShoppingCartQuantitySelectorView?
    //var alertView: IPOWMAlertViewController?
    
    var listId: String?
    var listName: String?
    var listEntity: List?
    var products: [AnyObject]?
    var isEdditing = false
    var enableScrollUpdateByTabBar = true

    var deleteProductServiceInvoked = false
    
    var equivalenceByPiece : NSNumber! = NSNumber(int:0)
    var selectedItems : NSMutableArray? = nil
    
    var containerEditName: UIView?
    

    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let iconImage = UIImage(color: WMColor.light_blue, size: CGSizeMake(110, 44), radius: 22)
        let iconSelected = UIImage(color: WMColor.UIColorFromRGB(0x8EBB36), size: CGSizeMake(110, 44), radius: 22)
        
        self.header!.frame = CGRectMake(0, 0, self.view.bounds.width, 46.0)

        self.editBtn = UIButton(type: .Custom)
        self.editBtn!.setTitle(NSLocalizedString("list.edit", comment:""), forState: .Normal)
        self.editBtn!.setTitle(NSLocalizedString("list.endedit", comment:""), forState: .Selected)
        self.editBtn!.setBackgroundImage(iconImage, forState: .Normal)
        self.editBtn!.setBackgroundImage(iconSelected, forState: .Selected)
        self.editBtn!.setTitleColor(WMColor.navigationFilterTextColor, forState: .Normal)
        self.editBtn!.layer.cornerRadius = 11
        self.editBtn!.addTarget(self, action: "showEditionMode", forControlEvents: .TouchUpInside)
        self.editBtn!.backgroundColor = WMColor.titleTextColor
        self.editBtn!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.editBtn!.hidden = true
        self.header!.addSubview(self.editBtn!)

        self.deleteAllBtn = UIButton(type: .Custom)
        self.deleteAllBtn!.setTitle(NSLocalizedString("wishlist.deleteall",comment:""), forState: .Normal)
        self.deleteAllBtn!.backgroundColor = WMColor.wishlistDeleteButtonBgColor
        self.deleteAllBtn!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.deleteAllBtn!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.deleteAllBtn!.layer.cornerRadius = 11
        self.deleteAllBtn!.alpha = 0
        self.deleteAllBtn!.hidden = true
//        self.deleteAllBtn!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 2.0, 0.0, 0.0)
        self.deleteAllBtn!.addTarget(self, action: "deleteAll", forControlEvents: .TouchUpInside)
        self.header!.addSubview(self.deleteAllBtn!)

        
       
        
        
        self.titleLabel?.text = self.listName
        self.tableView!.registerClass(DetailListViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        self.tableView!.registerClass(GRShoppingCartTotalsTableViewCell.self, forCellReuseIdentifier: self.TOTAL_CELL_ID)

        self.footerSection!.backgroundColor = WMColor.shoppingCartFooter
        
        
        let y = (self.footerSection!.frame.height - 34.0)/2
        self.duplicateButton = UIButton(frame: CGRectMake(16.0, y, 34.0, 34.0))
        self.duplicateButton!.setImage(UIImage(named: "list_duplicate"), forState: .Normal)
        self.duplicateButton!.setImage(UIImage(named: "list_active_duplicate"), forState: .Selected)
        self.duplicateButton!.setImage(UIImage(named: "list_active_duplicate"), forState: .Highlighted)
        self.duplicateButton!.addTarget(self, action: "duplicate", forControlEvents: .TouchUpInside)
        self.footerSection!.addSubview(self.duplicateButton!)
        
        var x = self.duplicateButton!.frame.maxX + 16.0
        self.shareButton = UIButton(frame: CGRectMake(x, y, 34.0, 34.0))
        self.shareButton!.setImage(UIImage(named: "detail_shareOff"), forState: .Normal)
        self.shareButton!.setImage(UIImage(named: "detail_share"), forState: .Selected)
        self.shareButton!.setImage(UIImage(named: "detail_share"), forState: .Highlighted)
        self.shareButton!.addTarget(self, action: "shareList", forControlEvents: .TouchUpInside)
        self.footerSection!.addSubview(self.shareButton!)
        
        x = self.shareButton!.frame.maxX + 16.0
        self.addToCartButton = UIButton(frame: CGRectMake(x, y, self.footerSection!.frame.width - (x + 16.0), 34.0))
        self.addToCartButton!.backgroundColor = WMColor.shoppingCartShopBgColor
        self.addToCartButton!.layer.cornerRadius = 17.0
        self.addToCartButton!.addTarget(self, action: "addListToCart", forControlEvents: .TouchUpInside)
        self.footerSection!.addSubview(self.addToCartButton!)

        self.customLabel = CurrencyCustomLabel(frame: self.addToCartButton!.bounds)
        self.customLabel!.backgroundColor = UIColor.clearColor()
        self.customLabel!.setCurrencyUserInteractionEnabled(true)
        self.addToCartButton!.addSubview(self.customLabel!)
        self.addToCartButton!.sendSubviewToBack(self.customLabel!)

        self.footerConstraint?.constant = 0.0
        self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)
        self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)
        
        if self.enableScrollUpdateByTabBar && !TabBarHidden.isTabBarHidden {
            let tabBarHeight:CGFloat = 45.0
            self.footerConstraint?.constant = tabBarHeight
            self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height + tabBarHeight, 0)
            self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height + tabBarHeight, 0)
        }
        
         buildEditNameSection()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Solo para presentar los resultados al presentar el controlador sin delay
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            loadServiceItems(nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.header!.frame = CGRectMake(0, 0, self.view.bounds.width, 46.0)
//        if CGRectEqualToRect(self.titleLabel!.frame, CGRectZero) {titleLabel
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
        
        
        
    }

    
    
    func loadServiceItems(complete:(()->Void)?) {
        if let _ = UserCurrentSession.sharedInstance().userSigned {
            self.showLoadingView()
            self.invokeDetailListService({ () -> Void in
                if self.loading != nil {
                    self.loading!.stopAnnimating()
                }
                self.loading = nil
                
                
                self.selectedItems = []
                self.selectedItems = NSMutableArray()
                if self.products != nil  && self.products!.count > 0  {
                    for i in 0...self.products!.count - 1 {
                        self.selectedItems?.addObject(i)
                    }
                    self.updateTotalLabel()
                }
                
                complete?()
                }, reloadList: false)
        }
        else {
            self.retrieveProductsLocally(false)
            if self.products == nil  || self.products!.count == 0 {
                self.selectedItems = []
            } else {
                self.selectedItems = NSMutableArray()
                for i in 0...self.products!.count - 1 {
                    self.selectedItems?.addObject(i)
                }
                self.updateTotalLabel()
            }
            complete?()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func showEditionMode() {
        
        
        
        if !self.isEdditing {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.tableConstraint?.constant = 110
                self.containerEditName!.alpha = 1
                self.footerSection!.alpha = 0
            }, completion: { (complete:Bool) -> Void in
                //Event
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                        action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_EDIT.rawValue,
                        label: self.listName,
                        value: nil).build() as [NSObject : AnyObject])
                }
                
                
                self.deleteAllBtn!.hidden = false
                
                UIView.animateWithDuration(0.5,
                    animations: { () -> Void in
                        self.titleLabel!.alpha = 0.0
                        self.deleteAllBtn!.alpha = 1.0
                        
                    }, completion: { (finished:Bool) -> Void in
                        
                    }
                )
                var cells = self.tableView!.visibleCells
                for var idx = 0; idx < cells.count; idx++ {
                    if let cell = cells[idx] as? DetailListViewCell {
                        cell.setEditing(true, animated: false)
                        cell.showLeftUtilityButtonsAnimated(true)
                    }
                }
            })
        }
        else {
            
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self.updateLustName()
                
                //Event
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                        action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_ENDEDIT.rawValue,
                        label: self.listName,
                        value: nil).build() as [NSObject : AnyObject])
                }
                
                UIView.animateWithDuration(0.5,
                    animations: { () -> Void in
                        self.titleLabel!.alpha = 1.0
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
                }, completion: { (completition:Bool) -> Void in
                    self.tableConstraint?.constant = self.header!.frame.maxY
                    self.containerEditName!.alpha = 0
                    self.footerSection!.alpha = 1
            })
            
           
         
        }
        
        self.isEdditing = !self.isEdditing
        self.editBtn!.selected = self.isEdditing
        
    }

    func shareList() {
        if self.isEdditing {
            return
        }
        if let image = self.buildImageToShare() {
            
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_SHARELIST.rawValue,
                    label: self.listName,
                    value: nil).build() as [NSObject : AnyObject])
            }
            
            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.navigationController?.presentViewController(controller, animated: true, completion: nil)
        }
    }

    func buildImageToShare() -> UIImage? {
        let oldFrame : CGRect = self.tableView!.frame
        var frame : CGRect = self.tableView!.frame
        frame.size.height = self.tableView!.contentSize.height
        self.tableView!.frame = frame
        
        UIGraphicsBeginImageContextWithOptions(self.tableView!.bounds.size, false, 2.0)
        self.tableView!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let saveImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.tableView!.frame = oldFrame
        return saveImage
    }

    func addListToCart() {
        if self.isEdditing {
            return
        }

        
        //ValidateActives
        var hasActive = false
        for product in self.products! {
            if let item = product as? [String:AnyObject] {
                if let stock = item["stock"] as? Bool {
                    if stock == true {
                        hasActive = true
                        break
                    }
                }
            }
            if let item = product as? Product {
                if item.isActive == "true" {
                    hasActive = true
                    break
                }
            }
        }
        
        if !hasActive {
            
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
            let msgInventory = "No existen productos disponibles para agregar al carrito"
            alert!.setMessage(msgInventory)
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            return
        }
        
        if self.products != nil && self.products!.count > 0 {
            
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_SHOPALL.rawValue,
                    label: self.listName,
                    value: nil).build() as [NSObject : AnyObject])
            }
            
            var upcs: [AnyObject] = []
            for idxVal  in selectedItems! {
                let idx = idxVal as! Int
                var params: [String:AnyObject] = [:]
                if let item = self.products![idx] as? [String:AnyObject] {
                    params["upc"] = item["upc"] as! String
                    params["desc"] = item["description"] as! String
                    params["imgUrl"] = item["imageUrl"] as! String
                    if let price = item["price"] as? NSNumber {
                        params["price"] = "\(price)"
                    }
                    if let quantity = item["quantity"] as? NSNumber {
                        params["quantity"] = "\(quantity)"
                    }
                 
                    params["pesable"] = item["type"] as? NSString
                    params["wishlist"] = false
                    params["type"] = ResultObjectType.Groceries.rawValue
                    params["comments"] = ""
                    if let type = item["type"] as? String {
                        if Int(type)! == 0 { //Piezas
                            params["onHandInventory"] = "99"
                        }
                        else { //Gramos
                            params["onHandInventory"] = "20000"
                        }
                    }
                }
                else if let item = self.products![idx] as? Product {
                    params["upc"] = item.upc
                    params["desc"] = item.desc
                    params["imgUrl"] = item.img
                    params["price"] = item.price
                    params["quantity"] = "\(item.quantity)"
                    params["wishlist"] = false
                    params["type"] = ResultObjectType.Groceries.rawValue
                    params["comments"] = ""
                    let isPesable = item.type.boolValue
                    params["pesable"] = isPesable ? "1" : "0"
                    if item.type.integerValue == 0 { //Piezas
                        params["onHandInventory"] = "99"
                    }
                    else { //Gramos
                        params["onHandInventory"] = "20000"
                    }
                }
                upcs.append(params)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddItemsToShopingCart.rawValue, object: self, userInfo: ["allitems":upcs, "image":"list_alert_addToCart"])
        }
    }
    
    func deleteAll() {
        if self.products != nil && self.products!.count > 0 {
            
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_DELETEALL.rawValue,
                    label: self.listName,
                    value: nil).build() as [NSObject : AnyObject])
            }
            
            
            
            var upcs: [String] = []
            var entities: [Product] = []
            for var idx = 0; idx < self.products!.count; idx++ {
                if let item = self.products![idx] as? [String:AnyObject] {
                    if let upc = item["upc"] as? String {
                        upcs.append(upc)
                    }
                }
                else if let item = self.products![idx] as? Product {
                    entities.append(item)
                }
            }
            
            if upcs.count > 0 {
                self.invokeDeleteAllProductsFromListService(upcs)
            }
            if entities.count > 0 {
                for product in entities {
                    self.managedContext!.deleteObject(product)
                }
                self.listEntity!.countItem = NSNumber(integer: 0)
                self.saveContext()
                self.editBtn!.hidden = true
                self.showEmptyView()
                self.reloadTableListUser()
            }
            
            
            
        }
    }
    
    func showEmptyView() {
        let bounds = self.view.frame
        let height = bounds.height - self.header!.frame.height
        self.emptyView = UIView(frame: CGRectMake(0.0, self.header!.frame.maxY, bounds.width, height))
        self.emptyView!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.emptyView!)
        
        let bg = UIImageView(image: UIImage(named: "empty_list"))
        bg.frame = CGRectMake(0.0, 0.0, bounds.width, height)
        self.emptyView!.addSubview(bg)
        
        let labelOne = UILabel(frame: CGRectMake(0.0, 28.0, bounds.width, 16.0))
        labelOne.textAlignment = .Center
        labelOne.textColor = WMColor.UIColorFromRGB(0x2870c9)
        labelOne.font = WMFont.fontMyriadProLightOfSize(14.0)
        labelOne.text = NSLocalizedString("list.detail.empty.header", comment:"")
        self.emptyView!.addSubview(labelOne)
        
        let labelTwo = UILabel(frame: CGRectMake(0.0, labelOne.frame.maxY + 12.0, bounds.width, 16))
        labelTwo.textAlignment = .Center
        labelTwo.textColor = WMColor.UIColorFromRGB(0x2870c9)
        labelTwo.font = WMFont.fontMyriadProRegularOfSize(14.0)
        labelTwo.text = NSLocalizedString("list.detail.empty.text", comment:"")
        self.emptyView!.addSubview(labelTwo)
        
        let icon = UIImageView(image: UIImage(named: "empty_list_icon"))
        icon.frame = CGRectMake(98.0, labelOne.frame.maxY + 12.0, 16.0, 16.0)
        self.emptyView!.addSubview(icon)
        
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake((bounds.width - 160.0)/2, height - 140.0, 160.0, 40.0)
        button.backgroundColor = WMColor.UIColorFromRGB(0x2870c9)
        button.setTitle(NSLocalizedString("list.detail.empty.back", comment:""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(self, action: "back", forControlEvents: .TouchUpInside)
        button.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        button.layer.cornerRadius = 20.0
        self.emptyView!.addSubview(button)
    }
    
    func removeEmpyView() {
        if self.emptyView != nil {
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.emptyView!.alpha = 0.0
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        self.emptyView!.removeFromSuperview()
                        self.emptyView = nil
                    }
                }
            )
        }
    }
    
    func showLoadingView() {
        self.loading = WMLoadingView(frame: CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
        self.loading!.startAnnimating(self.isVisibleTab)
        self.view.addSubview(self.loading!)
    }
    
    //MARK: - Utils
    
    func updateTotalLabel() {
        var total: Double = 0.0
        if self.products != nil && self.products!.count > 0 {
            total = self.calculateTotalAmount()
        }
        
        let fmtTotal = CurrencyCustomLabel.formatString("\(total)")
        let amount = String(format: NSLocalizedString("list.detail.buy",comment:""), fmtTotal)
        self.customLabel!.updateMount(amount, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.whiteColor(), interLine: false)
    }
    
    func calculateTotalAmount() -> Double {
        var total: Double = 0.0
        if selectedItems != nil {
            for idxVal  in selectedItems! {
                let idx = idxVal as! Int
                if let item = self.products![idx] as? [String:AnyObject] {
                    if let typeProd = item["type"] as? NSString {
                        let quantity = item["quantity"] as! NSNumber
                        let price = item["price"] as! NSNumber
                        
                        if typeProd.integerValue == 0 {
                            total += (quantity.doubleValue * price.doubleValue)
                        }
                        else {
                            let kgrams = quantity.doubleValue / 1000.0
                            total += (kgrams * price.doubleValue)
                        }
                    }
                }
                else if let item = self.products![idx] as? Product {
                    let quantity = item.quantity
                    let price:Double = item.price.doubleValue
                    if item.type.integerValue == 0 {
                        total += (quantity.doubleValue * price)
                    }
                    else {
                        let kgrams = quantity.doubleValue / 1000.0
                        total += (kgrams * price)
                    }
                }
            }
        }
        return total
    }
    
    func calculateTotalCount() -> Int {
        var count = 0
        for idxVal  in selectedItems! {
            let idx = idxVal as! Int
            if let item = self.products![idx] as? [String:AnyObject] {
                if let typeProd = item["type"] as? NSString {
                    if typeProd.integerValue == 0 {
                        let quantity = item["quantity"] as! NSNumber
                        count += quantity.integerValue
                    }
                    else {
                        count++
                    }
                }
            }
            else if let item = self.products![idx] as? Product {
                let quantity = item.quantity
                if item.type.integerValue == 0 {
                    count += quantity.integerValue
                }
                else {
                    count++
                }
            }
        }
        return count
    }
    
//    func layoutTitleLabel() {
//        if !isEdditing {
//            var rect: CGRect = self.titleLabel!.text!.boundingRectWithSize(CGSizeMake(self.view.bounds.width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:self.titleLabel!.font], context: nil)
//            var size = CGSizeMake(ceil(rect.size.width), ceil(rect.size.height))
//            
//            self.titleLabel!.frame = CGRectMake(0, 0, size.width, size.height)
//            self.titleLabel!.center = CGPointMake(self.header!.frame.width/2, self.header!.frame.height/2)
//        }
//    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var size = 0
        if self.products != nil {
            size = self.products!.count
            if size > 0 {
                size++
            }
        }
        return size
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         print("\(self.products!.count)")
        if indexPath.row == self.products!.count {
            let totalCell = tableView.dequeueReusableCellWithIdentifier(self.TOTAL_CELL_ID, forIndexPath: indexPath) as! GRShoppingCartTotalsTableViewCell
            let total = self.calculateTotalAmount()
            totalCell.setValues("", iva: "", total: "\(total)", totalSaving: "", numProds:"")
            return totalCell
        }

        let listCell = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID, forIndexPath: indexPath) as! DetailListViewCell
        listCell.detailDelegate = self
        listCell.delegate = self
        if let item = self.products![indexPath.row] as? [String : AnyObject] {
            listCell.setValuesDictionary(item,disabled:!self.selectedItems!.containsObject(indexPath.row))
        }
        else if let item = self.products![indexPath.row] as? Product {
            listCell.setValues(item,disabled:!self.selectedItems!.containsObject(indexPath.row))
        }
        if self.isEdditing {
            listCell.showLeftUtilityButtonsAnimated(false)
        }

        return listCell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == self.products!.count ? 56.0 : 109.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
            let controller = ProductDetailPageViewController()
            var productsToShow:[AnyObject] = []
            for var idx = 0; idx < self.products!.count; idx++ {
                if let product = self.products![idx] as? [String:AnyObject] {
                    let upc = product["upc"] as! String
                    let description = product["description"] as! String
                    //Event
                    if let tracker = GAI.sharedInstance().defaultTracker {
                        tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                            action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_PRODUCTDETAIL.rawValue,
                            label: upc,
                            value: nil).build() as [NSObject : AnyObject])
                    }
                    
                    productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Groceries.rawValue, "saving":""])
                }
                else if let product = self.products![idx] as? Product {
                    
                    if let tracker = GAI.sharedInstance().defaultTracker {
                        tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                            action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_PRODUCTDETAIL.rawValue,
                            label:product.upc,
                            value: nil).build() as [NSObject : AnyObject])
                    }
                    
                    productsToShow.append(["upc":product.upc, "description":product.desc, "type":ResultObjectType.Groceries.rawValue, "saving":""])
                }
            }
            print(productsToShow)
        if indexPath.row < productsToShow.count {
            controller.itemsToShow = productsToShow
            controller.ixSelected = indexPath.row
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    //MARK: - SWTableViewCellDelegate
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch index {
        case 0:
            if let indexPath = self.tableView!.indexPathForCell(cell) {
                if let item = self.products![indexPath.row] as? NSDictionary {
                    if let upc = item["upc"] as? String {
                        //Event
                        if let tracker = GAI.sharedInstance().defaultTracker {
                            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                                action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_DELETEPRODUCT.rawValue,
                                label: upc,
                                value: nil).build() as [NSObject : AnyObject])
                        }
                        if self.selectedItems!.containsObject(indexPath.row) {
                            self.selectedItems?.removeObject(indexPath.row)
                        }
                        self.invokeDeleteProductFromListService(upc)
                    }
                }
                else if let item = self.products![indexPath.row] as? Product {
                    self.managedContext!.deleteObject(item)
                    self.saveContext()
                    let count:Int = self.listEntity!.products.count
                    self.listEntity!.countItem = NSNumber(integer: count)
                    self.saveContext()
                    self.retrieveProductsLocally(true)
                    self.editBtn!.hidden = true
                }
            }
        default :
            print("other pressed")
        }
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
        switch index {
        case 0:
            //let indexPath : NSIndexPath = self.viewShoppingCart.indexPathForCell(cell)!
            //deleteRowAtIndexPath(indexPath)
            cell.showRightUtilityButtonsAnimated(true)
        default :
            print("other pressed")
        }
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return !isEdditing
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
        switch state {
        case SWCellState.CellStateLeft:
            return isEdditing
        case SWCellState.CellStateRight:
            return true
        case SWCellState.CellStateCenter:
            return !isEdditing
        //default:
           // return !isEdditing && !self.isSelectingProducts
          //  return !isEdditing
        }
    }
    
    //MARK: - DetailListViewCellDelegate

    func didChangeQuantity(cell:DetailListViewCell) {
        if self.isEdditing {
            return
        }
        if self.quantitySelector == nil {
            
            let indexPath = self.tableView!.indexPathForCell(cell)
            if indexPath == nil {
                return
            }
            var isPesable = false
            var price: NSNumber? = nil
            if let item = self.products![indexPath!.row] as? [String:AnyObject] {
                if let pesable = item["type"] as? NSString {
                    isPesable = pesable.intValue == 1
                }
                price = item["price"] as? NSNumber
            }
            else if let item = self.products![indexPath!.row] as? Product {
                isPesable = item.type.boolValue
                price = NSNumber(double: item.price.doubleValue)
            }
            

            let width:CGFloat = self.view.frame.width
            var height:CGFloat = (self.view.frame.height - self.header!.frame.height) + 2.0
            if TabBarHidden.isTabBarHidden {
                height += 45.0
            }
            let selectorFrame = CGRectMake(0, self.view.frame.height, width, height)
            
            if isPesable {
                self.quantitySelector = GRShoppingCartWeightSelectorView(frame: selectorFrame, priceProduct: price,equivalenceByPiece:cell.equivalenceByPiece!,upcProduct:cell.upcVal!)
            }
            else {
                self.quantitySelector = GRShoppingCartQuantitySelectorView(frame: selectorFrame, priceProduct: price,upcProduct:cell.upcVal!)
            }
            self.view.addSubview(self.quantitySelector!)
            self.quantitySelector!.closeAction = { () in
                self.removeSelector()
            }
            self.quantitySelector!.generateBlurImage(self.view, frame:CGRectMake(0.0, 0.0, width, height))
            self.quantitySelector!.addToCartAction = { (quantity:String) in
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
            }
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.quantitySelector!.frame = CGRectMake(0.0, 0.0, width, height)
            })
            
        }
        else {
            self.removeSelector()
        }
    }
    
    func removeSelector() {
        if   self.quantitySelector != nil {
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    let width:CGFloat = self.view.frame.width
                    let height:CGFloat = self.view.frame.height - self.header!.frame.height
                    self.quantitySelector!.frame = CGRectMake(0.0, self.view.frame.height, width, height)
                },
                completion: { (finished:Bool) -> Void in
                    if finished {
                        self.quantitySelector!.removeFromSuperview()
                        self.quantitySelector = nil
                    }
                }
            )
        }
    }

    //MARK: - Services

    func invokeDetailListService(action:(()->Void)? , reloadList : Bool) {
        let detailService = GRUserListDetailService()
        detailService.buildParams(self.listId)
        detailService.callService([:],
            successBlock: { (result:NSDictionary) -> Void in
                
                
                
                self.products = result["items"] as? [AnyObject]
                self.titleLabel?.text = result["name"] as? String
                
                
                if self.products == nil || self.products!.count == 0  {
                    self.selectedItems = []
                } else {
                    
                    self.selectedItems = NSMutableArray()
                    for i in 0...self.products!.count - 1 {
                        self.selectedItems?.addObject(i)
                    }
                }
                
                //self.layoutTitleLabel()
                self.tableView!.reloadData()
                if reloadList {
                    self.reloadTableListUserSelectedRow()
                }
                self.updateTotalLabel()
                if self.products == nil || self.products!.count == 0 {
                    self.editBtn!.hidden = true
                    self.showEmptyView()
                }
                else {
                    self.editBtn!.hidden = false
                    self.removeEmpyView()
                }
                
                
                
                action?()
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at retrieve list detail")
                self.back()
            }
        )
    }
    
    func invokeDeleteProductFromListService(upc:String) {
        if !self.deleteProductServiceInvoked {
            
            let detailService = GRUserListDetailService()
            detailService.buildParams(listId!)
            detailService.callService([:], successBlock: { (result:NSDictionary) -> Void in
                self.deleteProductServiceInvoked = true
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
                self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToList", comment:""))
                let service = GRDeleteItemListService()
                service.callService(service.buildParams(upc),
                    successBlock:{ (result:NSDictionary) -> Void in
                        self.invokeDetailListService({ () -> Void in
                            
                            
                            
                            self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToListDone", comment:""))
                            self.alertView!.showDoneIcon()
                            self.deleteProductServiceInvoked = false
                            self.alertView!.afterRemove = {
                                self.removeSelector()
                                return
                            }
                            
                            if self.products == nil || self.products!.count == 0 {
                                self.editBtn!.hidden = false
                                self.showEmptyView()
                            }
                            
                            
                            
                            }, reloadList: true)
                    },
                    errorBlock:{ (error:NSError) -> Void in
                        print("Error at delete product from user")
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                        self.deleteProductServiceInvoked = false
                    }
                )
                }, errorBlock: { (error:NSError) -> Void in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
                    self.deleteProductServiceInvoked = false
            })
            
            
           
        }
    }
    
    func invokeDeleteAllProductsFromListService(upcs:[String]) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.deletingAllProductsInList", comment:""))
        let service = GRDeleteItemListService()
        service.callService(service.buildParamsArray(upcs),
            successBlock: { (result:NSDictionary) -> Void in
                self.alertView!.setMessage(NSLocalizedString("list.message.deletingAllProductsInListDone", comment:""))
                self.alertView!.showDoneIcon()
               
                self.showEditionMode()
                self.products = nil
                self.editBtn!.hidden = true
                self.tableView!.reloadData()
                self.reloadTableListUser()
                self.showEmptyView()
            }, errorBlock: { (error:NSError) -> Void in
                print("Error at delete all items on list")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
            }
        )
    }
    
    func invokeUpdateProductFromListService(upc:String, quantity:Int) {
        if quantity == 0 {
            invokeDeleteProductFromListService(upc)
            return
        }
        
        if quantity <= 20000 {
        
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.updatingProductInList", comment:""))
            
            
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_CHANGEQUANTITY.rawValue,
                    label: "\(upc) - \(quantity)",
                    value: nil).build() as [NSObject : AnyObject])
            }
            
        
        let service = GRUpdateItemListService()
        service.callService(service.buildParams(upc: upc, quantity: quantity),
            successBlock: { (result:NSDictionary) -> Void in
                self.invokeDetailListService({ () -> Void in
                    self.alertView!.setMessage(NSLocalizedString("list.message.updatingProductInListDone", comment:""))
                    self.alertView!.showDoneIcon()
                    self.alertView!.afterRemove = {
                        self.removeSelector()
                        return
                    }
                }, reloadList: true)
            }, errorBlock: { (error:NSError) -> Void in
                print("Error at delete product from user")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
            }
        )
        }else{
            
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
            let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
            let secondMessage = NSLocalizedString("productdetail.notaviableinventorywe",comment:"")
            let msgInventory = "\(firstMessage) 20000 \(secondMessage)"
            alert!.setMessage(msgInventory)
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
        }
    }
    
    //MARK: - DB
    
    func retrieveProductsLocally(reloadList : Bool) {
        var products: [Product]? = nil
        let dateList =  self.listEntity?.registryDate
        
        self.listEntity =  dateList == nil ? nil : self.listEntity
       
        
        if self.listEntity != nil  {//&& self.listEntity!.idList != nil
            
            print("name listEntity:: \(self.listEntity?.name)")
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName("Product", inManagedObjectContext: self.managedContext!)
            fetchRequest.predicate = NSPredicate(format: "list == %@", self.listEntity!)
            do{
               products = try self.managedContext!.executeFetchRequest(fetchRequest) as? [Product]
            }
            catch{
                print("Error retrieveProductsLocally")
            }
            self.products = products
            self.titleLabel?.text = self.listEntity?.name
            //self.layoutTitleLabel()
            self.tableView!.reloadData()
            if reloadList {
                self.reloadTableListUserSelectedRow()
                //self.reloadTableListUser()
            }
            
           
            self.selectedItems = []
            self.selectedItems = NSMutableArray()
            if self.products != nil  && self.products!.count > 0  {
                for i in 0...self.products!.count - 1 {
                    self.selectedItems?.addObject(i)
                }
                self.updateTotalLabel()
            }
            
            self.updateTotalLabel()
        }else
        {
         self.products =  nil
         self.titleLabel?.text = ""
            self.editBtn!.hidden = true
            self.tableView!.reloadData()
            self.reloadTableListUser()
        }


        if self.products == nil || self.products!.count == 0 {
            self.editBtn!.hidden = true
            self.showEmptyView()
        } else {
            self.editBtn!.hidden = false
            self.removeEmpyView()
        }
        
      
        
    }
    
    func reloadTableListUserSelectedRow(){
        
    }

    
    func saveContext() {
        do {
            try self.managedContext!.save()
        } catch {
            print("error at save context on UserListViewController")
        }
    }
    
    //MARK: - IPOBaseController
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if !self.enableScrollUpdateByTabBar {
            return
        }
        
        let currentOffset: CGFloat = scrollView.contentOffset.y
        let differenceFromStart: CGFloat = self.startContentOffset! - currentOffset
        let differenceFromLast: CGFloat = self.lastContentOffset! - currentOffset
        lastContentOffset = currentOffset
        
        if differenceFromStart < 0 && !TabBarHidden.isTabBarHidden {
            TabBarHidden.isTabBarHidden = true
            self.isVisibleTab = false
            if(scrollView.tracking && (abs(differenceFromLast)>0.20)) {
                self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)
                self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)

                self.willHideTabbar()
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.HideBar.rawValue, object: nil)
            }
        }
        if differenceFromStart > 0 && TabBarHidden.isTabBarHidden {
            TabBarHidden.isTabBarHidden = false
            self.isVisibleTab = true
            if(scrollView.tracking && (abs(differenceFromLast)>0.20)) {
                let bottom : CGFloat = self.footerSection!.frame.height + 45.0
                self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, bottom, 0)
                self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, bottom, 0)
                
                self.willShowTabbar()
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
            }
        }
    }

    
    override func willShowTabbar() {
        self.footerConstraint!.constant = 45.0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    override func willHideTabbar() {
        self.footerConstraint!.constant = 0.0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func reloadTableListUser(){
        
    }
    
    func didDisable(disaable:Bool,cell:DetailListViewCell) {
        let indexPath = self.tableView?.indexPathForCell(cell)
        if disaable {
            self.selectedItems?.removeObject(indexPath!.row)
        } else {
            self.selectedItems?.addObject(indexPath!.row)
        }
        self.updateTotalLabel()

    }
    
    
    func buildEditNameSection() {
        
        containerEditName = UIView()
        containerEditName?.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, 64)
        
        let separator = UIView(frame:CGRectMake(0, containerEditName!.frame.height - AppDelegate.separatorHeigth(), self.view.frame.width, AppDelegate.separatorHeigth()))
        separator.backgroundColor = WMColor.lineSaparatorColor
        
        self.nameField = FormFieldView()
        self.nameField!.maxLength = 100
        self.nameField!.delegate = self
        self.nameField!.typeField = .String
        self.nameField!.nameField = NSLocalizedString("list.search.placeholder",comment:"")
        self.nameField!.frame = CGRectMake(16.0, 12.0, self.view.bounds.width - 32.0, 40.0)
        self.nameField!.text = listName
        
        containerEditName?.addSubview(separator)
        containerEditName?.addSubview(nameField!)
        self.view.addSubview(containerEditName!)
        containerEditName?.alpha = 0
        
    }
    
    
    func duplicate() {
        if let _ = UserCurrentSession.sharedInstance().userSigned {
            self.invokeSaveListToDuplicateService(forListId: listId!, andName: listName!, successDuplicateList: { () -> Void in
                self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
                self.alertView!.showDoneIcon()
            })
        }else{
         NSNotificationCenter.defaultCenter().postNotificationName("DUPLICATE_LIST", object: nil)
        }
    }
    

    
    
    func updateLustName() {
        if self.nameField?.text != self.titleLabel?.text {
            
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(NSLocalizedString("list.message.updatingListNames", comment:""))
            
            let detailService = GRUserListDetailService()
            detailService.buildParams(listId!)
            detailService.callService([:],
                successBlock: { (result:NSDictionary) -> Void in
                    let service = GRUpdateListService()
                    service.callService(self.nameField!.text!,
                        successBlock: { (result:NSDictionary) -> Void in
                           self.titleLabel?.text = self.nameField?.text
                            self.loadServiceItems({ () -> Void in
                                self.alertView!.setMessage(NSLocalizedString("list.message.updatingListNamesDone", comment:""))
                                self.alertView!.showDoneIcon()
                            })
                        },
                        errorBlock: { (error:NSError) -> Void in
                                self.alertView!.setMessage(error.localizedDescription)
                                self.alertView!.showErrorIcon("Ok")
                        }
                    )
                },
                errorBlock: { (error:NSError) -> Void in
                    
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                }
            )
        }
    }
    

}
