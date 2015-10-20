//
//  DefaultListDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 25/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class DefaultListDetailViewController : NavigationViewController, UITableViewDelegate, UITableViewDataSource, DetailListViewCellDelegate{
    
    //MARK: Views
    var tableView : UITableView?
    
    var defaultListName : String? = ""
    var detailItems : [[String:AnyObject]]? = []
    var selectedItems : NSMutableArray? = nil
    var quantitySelector: GRShoppingCartQuantitySelectorView?
    
    var footerSection : UIView? = nil
    var shareButton: UIButton?
    var addToCartButton: UIButton?
    var customLabel: CurrencyCustomLabel?
    var enableScrollUpdateByTabBar = true
    var isShowingTabBar : Bool = true
    var isSharing: Bool = false
    var duplicateButton: UIButton?
    
    var alertView : IPOWMAlertViewController?
    
    
    let CELL_ID = "listDefaultCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = defaultListName
    
    }
    
    
    override func setup() {
        super.setup()
        
        tableView  = UITableView(frame: CGRectZero)
        tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellDetailList")
        tableView?.registerClass(DetailListViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        tableView?.delegate = self
        tableView?.dataSource = self
        self.view.addSubview(tableView!)
        
        if self.detailItems?.count == 0 || self.detailItems == nil {
            selectedItems = []
        }
        else{
            selectedItems = NSMutableArray()
            for i in 0...self.detailItems!.count - 1 {
                selectedItems?.addObject(i)
            }
        }
        
        if TabBarHidden.isTabBarHidden {
            self.footerSection = UIView(frame:CGRectMake(0,  self.view.frame.maxY - 132 , self.view.frame.width, 72))
        }
        else{
            self.footerSection = UIView(frame:CGRectMake(0,  self.view.frame.maxY - 177 , self.view.frame.width, 72))
        }
        self.footerSection!.backgroundColor = WMColor.shoppingCartFooter
        self.view.addSubview(footerSection!)
        
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
        
        self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)
        self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)
        
        if self.enableScrollUpdateByTabBar && !TabBarHidden.isTabBarHidden {
            let tabBarHeight:CGFloat = 45.0
            self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height + tabBarHeight, 0)
            self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height + tabBarHeight, 0)
        }
        
        self.isSharing = false
        updateTotalLabel()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !self.isSharing {
            tableView?.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, self.view.frame.height - self.header!.frame.maxY)
        }
        let x = self.shareButton!.frame.maxX + 16.0
        let y = (self.footerSection!.frame.height - 34.0)/2
        addToCartButton?.frame = CGRectMake(x, y, self.footerSection!.frame.width - (x + 16.0), 34.0)
    
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.detailItems == nil { return 0 }
        return self.detailItems!.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let listCell = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID, forIndexPath: indexPath) as! DetailListViewCell
        listCell.setValuesDictionary(self.detailItems![indexPath.row],disabled:!self.selectedItems!.containsObject(indexPath.row))
        listCell.detailDelegate = self
        listCell.hideUtilityButtonsAnimated(false)
        listCell.setLeftUtilityButtons([], withButtonWidth: 0.0)
        listCell.setRightUtilityButtons([], withButtonWidth: 0.0)
        return listCell 
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = ProductDetailPageViewController()
        var productsToShow:[AnyObject] = []
        for var idx = 0; idx < self.detailItems!.count; idx++ {
            let product = self.detailItems![idx]
            let upc = product["upc"] as! NSString
            let description = product["description"] as! NSString
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_PRODUCTDETAIL.rawValue,
                    label: upc as String,
                    value: nil).build() as [NSObject : AnyObject])
            }
            
            productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Groceries.rawValue, "saving":""])
        }
        controller.itemsToShow = productsToShow
        controller.ixSelected = indexPath.row
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == self.detailItems!.count ? 56.0 : 109.0
    }
    
    //MARK: Delegate item cell
    func didChangeQuantity(cell:DetailListViewCell){
        
        if self.quantitySelector == nil {
            
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
                var item = self.detailItems![indexPath!.row]
                //var upc = item["upc"] as? String
                item["quantity"] = NSNumber(integer:Int(quantity)!)
                self.detailItems![indexPath!.row] = item
                self.tableView?.reloadData()
                self.removeSelector()
                self.updateTotalLabel()
                //TODO: Update quantity
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

    
    func didDisable(disaable:Bool, cell:DetailListViewCell) {
        let indexPath = self.tableView?.indexPathForCell(cell)
        if disaable {
            self.selectedItems?.removeObject(indexPath!.row)
        } else {
            self.selectedItems?.addObject(indexPath!.row)
        }
        self.updateTotalLabel()
    }
    
    
    //MARK: Actions
    
    func shareList() {

        if let image = self.buildImageToShare() {
            
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_SHARELIST.rawValue,
                    label: self.defaultListName,
                    value: nil).build() as [NSObject : AnyObject])
            }
            
            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.navigationController?.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func buildImageToShare() -> UIImage? {
        self.isSharing = true
        let oldFrame : CGRect = self.tableView!.frame
        var frame : CGRect = self.tableView!.frame
        frame.size.height = self.tableView!.contentSize.height + 50.0
        self.tableView!.frame = frame
        
        UIGraphicsBeginImageContextWithOptions(self.tableView!.bounds.size, false, 2.0)
        self.tableView!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let saveImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.isSharing = false
        self.tableView!.frame = oldFrame
        return saveImage
    }
    
    func addListToCart() {
        
        
        //ValidateActives
        var hasActive = false
        for product in self.detailItems! {
            let item = product
            if let stock = item["stock"] as? Bool {
                if stock == true {
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
        
        if self.selectedItems != nil && self.selectedItems!.count > 0 {
            
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_DETAILLIST.rawValue,
                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL_SHOPALL.rawValue,
                    label: self.defaultListName,
                    value: nil).build() as [NSObject : AnyObject])
            }
            
            var upcs: [AnyObject] = []
            for idxVal  in selectedItems! {
                let idx = idxVal as! Int
                var params: [String:AnyObject] = [:]
                let item = self.detailItems![idx]
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
                upcs.append(params)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddItemsToShopingCart.rawValue, object: self, userInfo: ["allitems":upcs, "image":"list_alert_addToCart"])
        }
    }

    
    
    func updateTotalLabel() {
        var total: Double = 0.0
        if self.selectedItems != nil && self.selectedItems!.count > 0 {
            total = self.calculateTotalAmount()
        }
        
        let fmtTotal = CurrencyCustomLabel.formatString("\(total)")
        let amount = String(format: NSLocalizedString("list.detail.buy",comment:""), fmtTotal)
        self.customLabel!.updateMount(amount, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.whiteColor(), interLine: false)
    }
    
    func calculateTotalAmount() -> Double {
        var total: Double = 0.0
        for idxVal  in selectedItems! {
            let idx = idxVal as! Int
            let item = self.detailItems![idx]
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
        return total
    }
    
    func calculateTotalCount() -> Int {
        var count = 0
        for idxVal  in selectedItems! {
            let idx = idxVal as! Int
            let item = self.detailItems![idx]
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
        return count
    }
    
    
    
    
    override func willShowTabbar() {
        isShowingTabBar = true
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.footerSection!.frame = CGRectMake(0,  self.view.frame.maxY - 117 , self.view.frame.width, 72)
        })
    }
    
    override func willHideTabbar() {
        isShowingTabBar = false
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.footerSection!.frame = CGRectMake(0,  self.view.frame.maxY - 72, self.view.frame.width, 72)
        })
    }
    

    func duplicate() {
        self.invokeSaveListToDuplicateService(defaultListName!, successDuplicateList: { () -> Void in
            self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
            self.alertView!.showDoneIcon()
        })
    }
    
    
    func invokeSaveListToDuplicateService(listName:String,successDuplicateList:(() -> Void)) {
        
        alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.copy.inProcess", comment:""))
        let service = GRUserListService()
        if UserCurrentSession.hasLoggedUser() {
            
            service.callService([:], successBlock: { (result:NSDictionary) -> Void in
                
                let  itemsUserList = result["responseArray"] as? [AnyObject]
                self.copyList(listName, itemsUserList: itemsUserList, successDuplicateList: successDuplicateList)
                
                
                }) { (error:NSError) -> Void in
                    
                    print("Error at retrieve list detail")
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                    
            }
        } else {
            let itemsUserList = service.retrieveUserList()
            self.copyList(listName, itemsUserList: itemsUserList, successDuplicateList: successDuplicateList)
        }

        
    }
    
    
    
    func copyList(listName:String,itemsUserList:[AnyObject]?,successDuplicateList:(() -> Void)) {
        let service = GRSaveUserListService()
        var items: [AnyObject] = []
        if self.detailItems != nil {
            for var idx = 0; idx < self.detailItems!.count; idx++ {
                var product = self.detailItems![idx]
                let quantity = product["quantity"] as! NSNumber
                let imageUrl = product["imageUrl"] as! String
                let price = product["price"] as! NSNumber
                let dsc = product["description"] as! String
                let type = product["type"] as! String
                
                if let upc = product["upc"] as? String {
                    let item = service.buildProductObject(upc: upc, quantity: quantity.integerValue, image: imageUrl, description: dsc, price: price.stringValue, type:type)
                    items.append(item)
                }
            }
        }
        
        let copyName = self.buildDuplicateNameList(listName, forListId: "",itemsUserList:itemsUserList)
        service.callService(service.buildParams(copyName, items: items),
            successBlock: { (result:NSDictionary) -> Void in
                successDuplicateList()
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at duplicate list")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            }
        )
    }
    
    func buildDuplicateNameList(theName:String, forListId listId:String?,itemsUserList:[AnyObject]?) -> String {
     
        
        var listName = "\(theName)" //Se crea una nueva instancia
        let whitespaceset = NSCharacterSet.whitespaceCharacterSet()
        if let range = listName.rangeOfString("copia", options: .LiteralSearch, range: nil, locale: nil) {
            listName = listName.substringToIndex(range.startIndex)
        }
        listName = listName.stringByTrimmingCharactersInSet(whitespaceset)
        
        var lastIdx = 1
        if itemsUserList != nil {
            if itemsUserList!.count > 0 {
                for var idx = 0; idx < itemsUserList!.count; idx++ {
                    var name:String? = nil
                    if let innerList = itemsUserList![idx] as? [String:AnyObject] {
                        let innerListId = innerList["id"] as! String
                        if innerListId == listId! {
                            continue
                        }
                        name = innerList["name"] as? String
                    }
                    else if let listEntity = itemsUserList![idx] as? List {
                        name = listEntity.name
                    }
                    
                    if name != nil {
                        if let range = name!.rangeOfString("copia", options: .LiteralSearch, range: nil, locale: nil) {
                            name = name!.substringToIndex(range.startIndex)
                        }
                        name = name!.stringByTrimmingCharactersInSet(whitespaceset)
                        
                        if name!.hasPrefix(listName) {
                            lastIdx++
                        }
                    }
                }
            }
        }
    
    
        let idxTxt = lastIdx == 1 ? "copia" : "copia \(lastIdx)"
        return "\(listName) \(idxTxt)"
        
        
    }

    

}