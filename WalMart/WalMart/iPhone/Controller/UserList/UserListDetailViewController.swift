//
//  UserListDetailViewController.swift
//  WalMart
//
//  Created by neftali on 20/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

class UserListDetailViewController: UserListNavigationBaseViewController, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, DetailListViewCellDelegate, UITextFieldDelegate, ReminderViewControllerDelegate,AddProductTolistViewDelegate,BarCodeViewControllerDelegate,CameraViewControllerDelegate {

    let CELL_ID = "listCell"
    let TOTAL_CELL_ID = "totalsCell"

    @IBOutlet var tableView: UITableView?
    @IBOutlet var footerSection: UIView?
    
    @IBOutlet var footerConstraint: NSLayoutConstraint?
    @IBOutlet var tableConstraint: NSLayoutConstraint?

    var editBtn: UIButton?
    var isSharing: Bool = false

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
    var products: [Any]?
    var isEdditing = false
    var enableScrollUpdateByTabBar = true

    var deleteProductServiceInvoked = false
    
    var equivalenceByPiece : NSNumber! = NSNumber(value: 0 as Int32)
    var selectedItems : NSMutableArray? = nil
    
    var containerEditName: UIView?
    var reminderButton: UIButton?
    var reminderImage: UIImageView?
    var reminderService: ReminderNotificationService?
    var showReminderButton: Bool = false
    
    var addProductsView : AddProductTolistView?
    var fromDelete  =  true
    var openEmpty =  false
    
    var retunrFromSearch =  false
    var isDeleting = false
    var analyticsSent = false
    var preview: PreviewModalView? = nil
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MYLIST.rawValue
    }
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let iconImage = UIImage(color: WMColor.light_blue, size: CGSize(width: 110, height: 44), radius: 22)
        let iconSelected = UIImage(color: WMColor.green, size: CGSize(width: 110, height: 44), radius: 22)
        
        self.header!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 46.0)

        self.editBtn = UIButton(type: .custom)
        self.editBtn!.setTitle(NSLocalizedString("list.edit", comment:""), for: UIControlState())
        self.editBtn!.setTitle(NSLocalizedString("list.endedit", comment:""), for: .selected)
        self.editBtn!.setBackgroundImage(iconImage, for: UIControlState())
        self.editBtn!.setBackgroundImage(iconSelected, for: .selected)
        self.editBtn!.setTitleColor(UIColor.white, for: UIControlState())
        self.editBtn!.layer.cornerRadius = 11
        self.editBtn!.addTarget(self, action: #selector(UserListDetailViewController.showEditionMode), for: .touchUpInside)
        self.editBtn!.backgroundColor = WMColor.light_blue
        self.editBtn!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.editBtn!.isHidden = true
        self.header!.addSubview(self.editBtn!)
        

        self.deleteAllBtn = UIButton(type: .custom)
        self.deleteAllBtn!.setTitle(NSLocalizedString("wishlist.deleteall",comment:""), for: UIControlState())
        self.deleteAllBtn!.backgroundColor = WMColor.red
        self.deleteAllBtn!.setTitleColor(UIColor.white, for: UIControlState())
        self.deleteAllBtn!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.deleteAllBtn!.layer.cornerRadius = 11
        self.deleteAllBtn!.alpha = 0
        self.deleteAllBtn!.isHidden = true
        self.deleteAllBtn!.addTarget(self, action: #selector(UserListDetailViewController.deleteAll), for: .touchUpInside)
        self.header!.addSubview(self.deleteAllBtn!)

        self.titleLabel?.text = self.listName
        self.tableView!.register(DetailListViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        self.tableView!.register(GRShoppingCartTotalsTableViewCell.self, forCellReuseIdentifier: self.TOTAL_CELL_ID)

        self.footerSection!.backgroundColor = UIColor.white
        
        
        let y = (72 - 34.0)/2

        self.duplicateButton = UIButton(frame: CGRect(x: 16.0, y: y, width: 34.0, height: 34.0))
        self.duplicateButton!.setImage(UIImage(named: "list_duplicate"), for: UIControlState())
        self.duplicateButton!.setImage(UIImage(named: "list_active_duplicate"), for: .selected)
        self.duplicateButton!.setImage(UIImage(named: "list_active_duplicate"), for: .highlighted)
        self.duplicateButton!.addTarget(self, action: #selector(UserListDetailViewController.duplicate), for: .touchUpInside)
        self.footerSection!.addSubview(self.duplicateButton!)
        
        var x = Double(self.duplicateButton!.frame.maxX + 16.0)
        self.shareButton = UIButton(frame: CGRect(x: x, y: y, width: 34.0, height: 34.0))
        self.shareButton!.setImage(UIImage(named: "detail_shareOff"), for: UIControlState())
        self.shareButton!.setImage(UIImage(named: "detail_share"), for: .selected)
        self.shareButton!.setImage(UIImage(named: "detail_share"), for: .highlighted)
        self.shareButton!.addTarget(self, action: #selector(UserListDetailViewController.shareList), for: .touchUpInside)
        self.footerSection!.addSubview(self.shareButton!)
        
        x = Double(self.shareButton!.frame.maxX + 16.0)
        self.addToCartButton = UIButton(frame: CGRect(x: x, y: y, width: Double(self.view.bounds.width) - (x + 16.0), height: 34.0))
        self.addToCartButton!.backgroundColor = WMColor.green
        self.addToCartButton!.layer.cornerRadius = 17.0
        self.addToCartButton!.addTarget(self, action: #selector(UserListDetailViewController.addListToCart), for: .touchUpInside)
        self.footerSection!.addSubview(self.addToCartButton!)

        self.customLabel = CurrencyCustomLabel(frame: self.addToCartButton!.bounds)
        self.customLabel!.backgroundColor = UIColor.clear
        self.customLabel!.setCurrencyUserInteractionEnabled(true)
        self.addToCartButton!.addSubview(self.customLabel!)
        self.addToCartButton!.sendSubview(toBack: self.customLabel!)

        self.footerConstraint?.constant = 0.0
        self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)
        self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)
        
        self.reminderButton = UIButton()
        self.reminderButton!.setTitle("Crear recordatorio para esta lista", for: UIControlState())
        self.reminderButton!.setImage(UIImage(named: "reminder_icon"), for: UIControlState())
        self.reminderButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.reminderButton!.backgroundColor = WMColor.orange
        self.reminderButton!.addTarget(self, action: #selector(UserListDetailViewController.addReminder), for: UIControlEvents.touchUpInside)
        self.reminderButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12.0)
        self.reminderButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.reminderButton!.titleEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        self.reminderButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 2, right:0 )
        self.reminderButton!.isHidden = true
        
        self.reminderImage = UIImageView(image: UIImage(named: "white_arrow"))
        
//        let tabBarHeight:CGFloat = 45.0
//        self.footerConstraint?.constant = tabBarHeight
        self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height , 0)
        self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height , 0)
      
        
        self.isSharing = false
        buildEditNameSection()
        self.showReminderButton = UserCurrentSession.hasLoggedUser() && ReminderNotificationService.isEnableLocalNotificationForApp() && self.listId != nil && self.listName != nil
        self.tableConstraint?.constant = (self.showReminderButton ? 134.0 : 46.0)
        self.addProductsView = AddProductTolistView()
        self.addProductsView!.backgroundColor =  UIColor.white
        self.addProductsView!.delegate =  self
        if showReminderButton{
            self.view.addSubview(reminderButton!)
            self.view.addSubview(reminderImage!)
            self.reminderService = ReminderNotificationService(listId: self.listId!, listName: self.listName!)
            self.setReminderSelected(self.reminderService!.existNotificationForCurrentList())
            self.view.addSubview(self.addProductsView!)

        }
        UserCurrentSession.sharedInstance.nameListToTag = self.listName!
        BaseController.setOpenScreenTagManager(titleScreen: self.listName!, screenName: self.getScreenGAIName())
        
        //The 'view' argument should be the view receiving the 3D Touch.
        if #available(iOS 9.0, *), self.is3DTouchAvailable(){
            registerForPreviewing(with: self, sourceView: tableView!)
        }else if !IS_IPAD{
            addLongTouch(view:tableView!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Solo para presentar los resultados al presentar el controlador sin delay
        if UIDevice.current.userInterfaceIdiom == .phone {
            loadServiceItems(nil)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        
        if products != nil && !analyticsSent {
            
            var position = 0
            var positionArray: [Int] = []
            var productsArray: [[String: Any]] = []
            var params: [String:Any] = [:]
            
            for product in self.products! {
                
                if let item = product as? Product {
                    params["upc"] = item.upc
                    params["description"] = item.desc
                    params["imgUrl"] = item.img
                    params["price"] = item.price
                    params["quantity"] = "\(item.quantity)"
                    params["wishlist"] = false
                    params["type"] = ResultObjectType.Groceries.rawValue
                    params["comments"] = ""
                    let isPesable = item.type.boolValue
                    params["pesable"] = isPesable ? "1" : "0"
                    position += 1
                    positionArray.append(position)
                    productsArray.append(params as [String : AnyObject])
                }
                
            }
            
            let listName = self.listName!
            let subCategory = ""
            let subSubCategory = ""
            BaseController.sendAnalyticsTagImpressions(productsArray, positionArray: positionArray, listName: listName, mainCategory: "", subCategory: subCategory, subSubCategory: subSubCategory)
            analyticsSent = true
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.header!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 46.0)
        
        
        if !self.isSharing {
            if showReminderButton {
                self.reminderButton?.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: 23.0)
                self.reminderImage?.frame = CGRect(x: self.view.frame.width - 27, y: self.header!.frame.maxY + 6, width: 11.0, height: 11.0)
             
                self.addProductsView!.frame = CGRect(x: 0,y: openEmpty ? self.header!.frame.maxY : self.reminderButton!.frame.maxY, width: self.view.frame.width, height: 64.0)
                
                self.tableView?.frame = CGRect(x: 0, y: self.addProductsView!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.addProductsView!.frame.maxY)

            }else{
                self.tableView?.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.header!.frame.maxY)
            }
        }
        
        
//        if CGRectEqualToRect(self.titleLabel!.frame, CGRectZero) {titleLabel
//            self.layoutTitleLabel()
//        }
        self.backButton?.frame = CGRect(x: 0, y: (self.header!.frame.height - 46.0)/2, width: 46.0, height: 46.0)
        if self.editBtn!.frame.equalTo(CGRect.zero) {
            let headerBounds = self.header!.frame.size
            let buttonWidth: CGFloat = 55.0
            let buttonHeight: CGFloat = 22.0
            self.editBtn!.frame = CGRect(x: headerBounds.width - (buttonWidth + 16.0), y: (headerBounds.height - buttonHeight)/2, width: buttonWidth, height: buttonHeight)
            self.deleteAllBtn!.frame = CGRect(x: self.editBtn!.frame.minX - (90.0 + 8.0), y: (headerBounds.height - buttonHeight)/2, width: 90.0, height: buttonHeight)
        }
        
        
    }

    /**
     Load items from service
     
     - parameter complete: complete block
     */
    func loadServiceItems(_ complete:(()->Void)?) {
        if let _ = UserCurrentSession.sharedInstance.userSigned {
            self.showLoadingView()
            self.invokeDetailListService({ () -> Void in
                if self.loading != nil {
                    self.loading!.stopAnnimating()
                }
                self.loading = nil
                self.reminderButton!.isHidden = false
                	
                self.selectedItems = []
                self.selectedItems = NSMutableArray()
                if self.products != nil  && self.products!.count > 0  {
                    for i in 0...self.products!.count - 1 {
                        self.selectedItems?.add(i)
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
                    self.selectedItems?.add(i)
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
    /**
     Show cells in edition mode
     */
    func showEditionMode() {
        if !self.isEdditing {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_EDIT_MY_LIST.rawValue, label: "")
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.tableConstraint?.constant = 110
                self.containerEditName!.alpha = 1
                self.footerSection!.alpha = 0
                self.reminderButton?.alpha = 0.0
                self.reminderImage?.alpha = 0.0
                self.addProductsView?.alpha = 0
            }, completion: { (complete:Bool) -> Void in
                self.deleteAllBtn!.isHidden = false
                UIView.animate(withDuration: 0.5,
                    animations: { () -> Void in
                        self.titleLabel!.alpha = 0.0
                        self.deleteAllBtn!.alpha = 1.0
                    }, completion: { (finished:Bool) -> Void in
                        
                    }
                )
                var cells = self.tableView!.visibleCells
                for idx in 0 ..< cells.count {
                    if let cell = cells[idx] as? DetailListViewCell {
                        cell.setEditing(true, animated: false)
                        cell.showLeftUtilityButtons(animated: true)
                    }
                }
            })
        }
        else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.updateLustName()
                UIView.animate(withDuration: 0.5,
                    animations: { () -> Void in
                        self.titleLabel!.alpha = 1.0
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
                }, completion: { (completition:Bool) -> Void in
                    self.tableConstraint?.constant = (self.showReminderButton ? 134.0 : self.header!.frame.maxY)
                    self.containerEditName!.alpha = 0
                    self.reminderButton?.alpha = 1.0
                    self.reminderImage?.alpha = 1.0
                    self.footerSection!.alpha = 1
                    self.addProductsView?.alpha = 1
            })
         
        }
        
        self.isEdditing = !self.isEdditing
        self.editBtn!.isSelected = self.isEdditing
        
    }

    /**
     Share products list
     */
    func shareList() {
        if self.isEdditing {
            return
        }
        
        self.tableView!.setContentOffset(CGPoint.zero , animated: false)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_SHARE.rawValue , label: "")
        
        if let image = self.tableView!.screenshot() {
            let imageHead = UIImage(named:"detail_HeaderMail")
            let imgResult = UIImage.verticalImage(from: [imageHead!,image])
            let controller = UIActivityViewController(activityItems: [imgResult!], applicationActivities: nil)
            self.navigationController?.present(controller, animated: true, completion: nil)
            
            controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        }
    }

    /**
     Builds view image to share
     
     - returns: UIImage
     */
    func buildImageToShare() -> UIImage? {
        self.isSharing = true
        let oldFrame : CGRect = self.tableView!.frame
        var frame : CGRect = self.tableView!.frame
        frame.size.height = self.tableView!.contentSize.height + 50.0
        self.tableView!.frame = frame
        
        UIGraphicsBeginImageContextWithOptions(self.tableView!.bounds.size, false, 2.0)
        self.tableView!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let saveImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.isSharing = false
        self.tableView!.frame = oldFrame
        return saveImage
    }

    /**
     Adds list products to shopping cart
     */
    func addListToCart() {
        if self.isEdditing {
            return
        }

        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_ADD_ALL_TO_SHOPPING_CART.rawValue , label: "")
        //ValidateActives
        var hasActive = false
        for product in self.products! {
            if let item = product as? [String:Any] {
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
            
            var upcs: [Any] = []
            var totalPrice: Int = 0
            
            for idxVal  in selectedItems! {
                let idx = idxVal as! Int
                var params: [String:Any] = [:]
                if let item = self.products![idx] as? [String:Any] {
                    params["upc"] = item["upc"] as! String
                    params["desc"] = item["description"] as! String
                    params["imgUrl"] = item["imageUrl"] as! String
                    if let price = item["price"] as? NSNumber {
                        totalPrice += price as Int
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
                    if item.type.intValue == 0 { //Piezas
                        params["onHandInventory"] = "99"
                    }
                    else { //Gramos
                        params["onHandInventory"] = "20000"
                    }
                    
                    let checkedPrice:Int? = (item.price as String).toIntNoDecimals()
                    
                    if let productPrice = checkedPrice {
                        totalPrice += Int(productPrice)
                    }
                    
                }
                upcs.append(params as AnyObject)
            }
            if upcs.count > 0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddItemsToShopingCart.rawValue), object: self, userInfo: ["allitems":upcs, "image":"list_alert_addToCart"])
                BaseController.sendAnalyticsProductsToCart(totalPrice)
            }
            else{
                self.noProductsAvailableAlert()
                return
            }
        }else{
            self.noProductsAvailableAlert()
            return
        }
    }
    
    /**
     No Products Available Alert
     */
    func noProductsAvailableAlert(){
        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
        let msgInventory = "No existen productos disponibles para agregar al carrito"
        alert!.setMessage(msgInventory)
        alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
    }
    
    /**
     Delete all products
     */
    func deleteAll() {
        if self.products != nil && self.products!.count > 0 {
            var upcs: [String] = []
            var entities: [Product] = []
            for idx in 0 ..< self.products!.count {
                if let item = self.products![idx] as? [String:Any] {
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
                    self.managedContext!.delete(product)
                }
                self.listEntity!.countItem = NSNumber(value: 0 as Int)
                self.saveContext()
                self.editBtn!.isHidden = true
                self.deleteAllBtn!.isHidden =  true
                self.titleLabel!.alpha = 1.0
                self.showEmptyView()
                self.reloadTableListUser()
            }
            
            
            
        }
    }
    
    
    func getRightButtonOnlyDelete() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        let buttonDelete = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 109))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), for: UIControlState())
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    
    /**
     Delete element from cell
     
     - parameter cell: cell to delete
     */
    func deleteFromCellUtilityButton(_ cell: SWTableViewCell!) {
        
        if self.isDeleting {
            return
        }
        
        self.isDeleting = true
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_DELETE_PRODUCT_MYLIST.rawValue, label: "")
        if let indexPath = self.tableView!.indexPath(for: cell) {
            if UserCurrentSession.hasLoggedUser() {
                    if let item = self.products![indexPath.row] as? Product {
                    //Event
                    if self.selectedItems!.contains(indexPath.row) {
                        self.selectedItems?.remove(indexPath.row)
                    }
                    self.fromDelete =  true
                    self.invokeDeleteProductFromListService(item, succesDelete: { () -> Void in
                        self.isDeleting = false
                        print("succesDelete")
                    })
                }
            }
            else if let item = self.products![indexPath.row] as? Product {
                self.managedContext!.delete(item)
                let count:Int = self.listEntity!.products.count
                self.listEntity!.countItem = NSNumber(value: count as Int)
                self.saveContext()
                self.fromDelete =  true
                self.retrieveProductsLocally(true)
                self.editBtn!.isHidden = count == 0
                self.deleteAllBtn!.isHidden = count == 0
                self.isDeleting = false
                //self.editBtn!.hidden = true
            }
        }
    }
    
    /**
     Show Empty View
     */
    func showEmptyView() {
        self.openEmpty = true
        var emptyHeight = 44
        if IS_IPHONE_4_OR_LESS {
            emptyHeight = 0
        }
        self.footerSection!.frame = CGRect(x: 0, y: Int(self.view.frame.height), width: Int(self.view.frame.width), height: emptyHeight)
        let bounds = self.view.bounds
        let height = bounds.size.height - self.header!.frame.height
        self.emptyView?.removeFromSuperview()
        if UserCurrentSession.hasLoggedUser() {
            self.emptyView = UIView(frame: CGRect(x: 0.0, y: self.header!.frame.maxY + 64, width: bounds.width, height: height - 44 - 64))
        }else{
            let heightempty = self.view!.superview == nil ? height - self.footerSection!.frame.height - 9 : self.view.frame.height - 64
            self.emptyView = UIView(frame: CGRect(x: 0.0, y: self.header!.frame.maxY, width: bounds.width, height: heightempty ))
        }
        self.emptyView!.backgroundColor = UIColor.white
        self.view.addSubview(self.emptyView!)
        
        let bg = UIImageView(image: UIImage(named:  UserCurrentSession.hasLoggedUser() ? "empty_list":"list_empty_no" ))
        bg.frame = CGRect(x: 0.0, y: 0.0,  width: bounds.width,  height:self.emptyView!.frame.height)
        self.emptyView!.addSubview(bg)
        
        let labelOne = UILabel(frame: CGRect(x: 0.0, y: 28.0, width: bounds.width, height: 16.0))
        labelOne.textAlignment = .center
        labelOne.textColor = WMColor.light_blue
        labelOne.font = WMFont.fontMyriadProLightOfSize(14.0)
        labelOne.text = NSLocalizedString("list.detail.empty.header", comment:"")
        self.emptyView!.addSubview(labelOne)
        
        let labelTwo = UILabel(frame: CGRect(x: 0.0, y: labelOne.frame.maxY + 12.0, width: bounds.width, height: 16))
        labelTwo.textAlignment = .center
        labelTwo.textColor = WMColor.light_blue
        labelTwo.font = WMFont.fontMyriadProRegularOfSize(14.0)
        labelTwo.text = NSLocalizedString("list.detail.empty.text", comment:"")
        self.emptyView!.addSubview(labelTwo)
        
        let icon = UIImageView(image: UIImage(named: "empty_list_icon"))
        icon.frame = CGRect(x: labelTwo.frame.midX - 63, y: labelOne.frame.maxY + 12.0, width: 16.0, height: 16.0)
        self.emptyView!.addSubview(icon)
        
        let button = UIButton(type: .custom)
        
        var buttonY = self.emptyView!.frame.height - 100
        if UserCurrentSession.hasLoggedUser() {
            buttonY -= 60
        }
        if IS_IPHONE_4_OR_LESS {
            buttonY = self.emptyView!.frame.height - 90
        }
        
        
        button.frame = CGRect(x: (bounds.width - 160.0)/2, y: buttonY, width: 160 , height: 40)
        
        /*if IS_IPHONE_4_OR_LESS{
         button.frame = CGRectMake((bounds.width - 160.0)/2,height - 160, 160 , 40)
        }*/
        button.backgroundColor = WMColor.light_blue
        button.setTitle(NSLocalizedString("list.detail.empty.back", comment:""), for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.addTarget(self, action: #selector(UserListDetailViewController.backEmpty), for: .touchUpInside)
        button.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        button.layer.cornerRadius = 20.0
        button.isHidden = UserCurrentSession.hasLoggedUser()
        self.emptyView!.addSubview(button)
    }
    
    /**
     Remove empty view
     */
    func removeEmpyView() {
        if self.emptyView != nil {
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    self.emptyView!.alpha = 0.0
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        self.emptyView?.isHidden = true
                        self.emptyView?.removeFromSuperview()
                        self.emptyView = nil
                    }
                }
            )
        }
    }
    
    /**
     Shows Loading View
     */
    func showLoadingView() {
        self.loading = WMLoadingView(frame: CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46))
        self.loading!.startAnnimating(self.isVisibleTab)
        self.view.addSubview(self.loading!)
    }
    
    //MARK: - Utils
    /**
     Update total label
     */
    func updateTotalLabel() {
        var total: Double = 0.0
        if self.products != nil && self.products!.count > 0 {
            total = self.calculateTotalAmount()
        }
        
        let fmtTotal = CurrencyCustomLabel.formatString("\(total)" as NSString)
        let amount = String(format: NSLocalizedString("list.detail.buy",comment:""), fmtTotal)
        self.customLabel!.updateMount(amount, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.white, interLine: false)
    }
    
    /**
     Calculates the total amount of product list
     
     - returns: Total Amount
     */
    func calculateTotalAmount() -> Double {
        var total: Double = 0.0
        if selectedItems != nil {
            for idxVal  in selectedItems! {
                let idx = idxVal as! Int
                if let item = self.products![idx] as? [String:Any] {
                    if let typeProd = item["type"] as? NSString {
                        let quantity = item["quantity"] as! NSNumber
                        let price = item["price"] as! NSNumber
                        let baseUomcd = item["baseUomcd"] as! String == "EA"
                        let equivalenceByPiece = item["equivalenceByPiece"] as! NSString
                        
                        if typeProd.integerValue == 0 {
                            total += (quantity.doubleValue * price.doubleValue)
                        }
                        else {
                            if baseUomcd {
                              total +=  ((quantity.doubleValue *  equivalenceByPiece.doubleValue) *  price.doubleValue) / 1000
                                
                            }else{
                                let kgrams = quantity.doubleValue / 1000.0
                                total += (kgrams * price.doubleValue)
                            }
                        }
                    }
                }
                else if let item = self.products![idx] as? Product {
                    let quantity = item.quantity
                    let price:Double = item.price.doubleValue
                    if item.type.intValue == 0 {
                        total += (quantity.doubleValue * price)
                    }
                    else {
                        if item.orderByPiece.boolValue {
                             total +=  ((quantity.doubleValue *  item.equivalenceByPiece.doubleValue) * price) / 1000
                        }else{
                            let kgrams = quantity.doubleValue / 1000.0
                            total += (kgrams * price)
                        }
                    }
                }
            }
        }
        return total
    }
    
    /**
     Total of products
     
     - returns: return total
     */
    func calculateTotalCount() -> Int {
        var count = 0
        for idxVal  in selectedItems! {
            let idx = idxVal as! Int
            if let item = self.products![idx] as? [String:Any] {
                if let typeProd = item["type"] as? NSString {
                    if typeProd.integerValue == 0 {
                        let quantity = item["quantity"] as! NSNumber
                        count += quantity.intValue
                    }
                    else {
                        count += 1
                    }
                }
            }
            else if let item = self.products![idx] as? Product {
                let quantity = item.quantity
                if item.type.intValue == 0 {
                    count += quantity.intValue
                }
                else {
                    count += 1
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var size = 0
        if self.products != nil {
            size = self.products!.count
            if size > 0 {
                size += 1
            }
        }
        return size
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         print("\(self.products!.count)")
        if indexPath.row == self.products!.count {
            let totalCell = tableView.dequeueReusableCell(withIdentifier: self.TOTAL_CELL_ID, for: indexPath) as! GRShoppingCartTotalsTableViewCell
            let total = self.calculateTotalAmount()
            totalCell.setValues("", iva: "", total: "\(total)", totalSaving: "", numProds:"")
            return totalCell
        }

        let listCell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID, for: indexPath) as! DetailListViewCell
        listCell.productImage!.image = nil
        listCell.productImage!.cancelImageDownloadTask()
        listCell.defaultList = false
        listCell.detailDelegate = self
        listCell.delegate = self
        
        if let item = self.products![indexPath.row] as? [String : AnyObject] {
            listCell.setValuesDictionary(item, disabled:self.retunrFromSearch ? !self.retunrFromSearch : !self.selectedItems!.contains(indexPath.row))
        } else if let item = self.products![indexPath.row] as? Product {
            listCell.setValues(item, disabled:self.retunrFromSearch ? !self.retunrFromSearch : !self.selectedItems!.contains(indexPath.row))
        }
        
        if self.isEdditing {
            listCell.rightUtilityButtons = nil
            listCell.showLeftUtilityButtons(animated: false)
        } else {
            if listCell.rightUtilityButtons == nil {
                delay(0.5, completion: {
                    listCell.setDeleteButton()
                })
            }
        }

        return listCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == self.products!.count ? 56.0 : 109.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell!.isKind(of: DetailListViewCell.self) {

            let controller = self.getDetailController(index:indexPath)
            self.navigationController!.pushViewController(controller!, animated: true)
        }
    }
    
    func getDetailController(index: IndexPath) -> ProductDetailPageViewController? {
        let cell = tableView!.cellForRow(at: index)
        if cell!.isKind(of: DetailListViewCell.self) {
            let controller = ProductDetailPageViewController()
            var productsToShow:[Any] = []
            for idx in 0 ..< self.products!.count {
                if let product = self.products![idx] as? [String:Any] {
                    let upc = product["upc"] as! String
                    let description = product["description"] as! String
                
                    productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Groceries.rawValue, "saving":""])
                }
                else if let product = self.products![idx] as? Product {
                    productsToShow.append(["upc":product.upc, "description":product.desc, "type":ResultObjectType.Groceries.rawValue, "saving":""])
                }
            }
        
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue, label: "")
        
            if index.row < productsToShow.count {
                controller.itemsToShow = productsToShow
                controller.ixSelected = index.row
                controller.completeDeleteItem = {() in
                    print("completeDelete")
                    self.fromDelete =  true
                }
                controller.detailOf = self.listName!
            }

            return controller
        }
        return nil
    }
    
    //MARK: - SWTableViewCellDelegate
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        if index == 0{
            self.deleteFromCellUtilityButton(cell)
        }
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerLeftUtilityButtonWith index: Int) {
        if index == 0{
            cell.rightUtilityButtons = getRightButtonOnlyDelete()
            cell.showRightUtilityButtons(animated: true)
        }
    }
    
    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool {
        return !isEdditing
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, canSwipeTo state: SWCellState) -> Bool {
        switch state {
        case SWCellState.cellStateLeft:
            return isEdditing
        case SWCellState.cellStateRight:
            return true
        case SWCellState.cellStateCenter:
            return !isEdditing
        //default:
           // return !isEdditing && !self.isSelectingProducts
          //  return !isEdditing
        }
    }
    
    //MARK: - DetailListViewCellDelegate
    func didChangeQuantity(_ cell: DetailListViewCell) {
        if self.isEdditing {
            return
        }
        if self.quantitySelector == nil {
            
            let indexPath = self.tableView!.indexPath(for: cell)
            if indexPath == nil {
                return
            }
            var isPesable = false
            var price: NSNumber? = nil
            if let item = self.products![indexPath!.row] as? [String:Any] {
                if let pesable = item["type"] as? NSString {
                    isPesable = pesable.intValue == 1
                }
                price = item["price"] as? NSNumber
            }
            else if let item = self.products![indexPath!.row] as? Product {
                isPesable = item.type.boolValue
                price = NSNumber(value: item.price.doubleValue as Double)
            }
            

            let width:CGFloat = self.view.frame.width
            var height:CGFloat = (self.view.frame.height - self.header!.frame.height) + 2.0
            if TabBarHidden.isTabBarHidden {
                height += 45.0
            }
            let selectorFrame = CGRect(x: 0, y: self.view.frame.height, width: width, height: height)
            
            if isPesable {
                self.quantitySelector = GRShoppingCartWeightSelectorView(frame: selectorFrame, priceProduct: price,equivalenceByPiece:cell.equivalenceByPiece!,upcProduct:cell.upcVal!, isSearchProductView: false)
            }
            else {
                self.quantitySelector = GRShoppingCartQuantitySelectorView(frame: selectorFrame, priceProduct: price,upcProduct:cell.upcVal!)
            }
            
            self.view.addSubview(self.quantitySelector!)
            self.quantitySelector!.closeAction = { () in
                self.removeSelector()
            }
            
            if let item = self.products![indexPath!.row] as? [String:Any] {
                // TODO: cast values from response
                 quantitySelector?.validateOrderByPiece(orderByPiece: item["baseUomcd"] as! String  == "EA", quantity:item["quantity"] as! Double, pieces: item["quantity"] as! Int)
            } else if let item = self.products![indexPath!.row] as? Product {
                quantitySelector?.validateOrderByPiece(orderByPiece: item.orderByPiece.boolValue, quantity: item.quantity.doubleValue, pieces: item.pieces.intValue)
            }
            
            self.quantitySelector!.addToCartAction = { (quantity:String) in
                if UserCurrentSession.hasLoggedUser() {
                    if let item = self.products![indexPath!.row] as? Product {
                        self.invokeUpdateProductFromListService(item, quantity: Int(quantity)!,baseUomcd:self.quantitySelector!.orderByPiece ? "EA" : "GM")
                    }
                }
                else if let item = self.products![indexPath!.row] as? Product {
                    item.quantity = NSNumber(value: Int(quantity)! as Int)
                    item.orderByPiece = NSNumber(value: self.quantitySelector!.orderByPiece)
                    item.pieces =  NSNumber(value:Int(quantity)!) //NSNumber(value: cell.equivalenceByPiece!.intValue > 0 ? (Int(quantity)! / cell.equivalenceByPiece!.intValue): (Int(quantity)!))
                    self.saveContext()
                    self.retrieveProductsLocally(true)
                    self.removeSelector()
                }
            }
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.quantitySelector!.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            })
            
        }
        else {
            self.removeSelector()
        }
    }
    
    func removeSelector() {
        if   self.quantitySelector != nil {
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    let width:CGFloat = self.view.frame.width
                    let height:CGFloat = self.view.frame.height - self.header!.frame.height
                    self.quantitySelector!.frame = CGRect(x: 0.0, y: self.view.frame.height, width: width, height: height)
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
    func invokeDetailListService(_ action:(()->Void)? , reloadList : Bool) {
        let detailService = GRUserListDetailService()
        detailService.callCoreDataService(listId: self.listId!,
                                          successBlock: { (result:List?,products:[Product]?) -> Void in
                self.products = products!
                
                if !self.analyticsSent {
                    
                    var position = 0
                    var positionArray: [Int] = []
                    
                    for _ in self.products! {
                        position += 1
                        positionArray.append(position)
                    }
                    
                    let listName = self.listName!
                    let subCategory = ""
                    let subSubCategory = ""
                    BaseController.sendAnalyticsTagImpressionsFor(self.products! as! [Product], positionArray: positionArray, listName: listName, mainCategory: "", subCategory: subCategory, subSubCategory: subSubCategory)
                    self.analyticsSent = true
                }
                
                self.titleLabel?.text = result!.name
                if self.products == nil || self.products!.count == 0  {
                    self.selectedItems = []
                } else {
                    if self.fromDelete {
                        self.fromDelete =  false
                        self.selectedItems = NSMutableArray()
                        for i in 0...self.products!.count - 1 {
                            self.selectedItems?.add(i)
                        }
                    }
                    self.openEmpty =  false
                     self.removeEmpyView()
                }
                
                //self.layoutTitleLabel()
                self.tableView!.reloadData()
                if reloadList {
                    self.reloadTableListUserSelectedRow()
                }
                self.updateTotalLabel()
                if self.products == nil || self.products!.count == 0 {
                    self.editBtn!.isHidden = true
                    self.deleteAllBtn!.isHidden = true
                    self.isEdditing = true
                    self.showEditionMode()
                    self.showEmptyView()
                }
                else {
                    self.editBtn!.isHidden = false
                    self.deleteAllBtn!.isHidden = false
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
    
    func invokeDeleteProductFromListService(_ product:Product,succesDelete:@escaping (()->Void)) {
        if !self.deleteProductServiceInvoked {
            
            let detailService = GRUserListDetailService()
            detailService.buildParams(listId!)
            detailService.callService([:], successBlock: { (result:[String:Any]) -> Void in
                self.deleteProductServiceInvoked = true
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
                self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToList", comment:""))
                let service = GRDeleteItemListService()
                service.callService(service.buildParams(product.upc),
                    successBlock:{ (result:[String:Any]) -> Void in
                        
                        self.managedContext!.delete(product)
                        let count:Int = self.listEntity!.products.count
                        self.listEntity!.countItem = NSNumber(value: count as Int)
                        self.saveContext()
                        
                        self.invokeDetailListService({ () -> Void in
                            self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToListDone", comment:""))
                            self.alertView!.showDoneIcon()
                            self.deleteProductServiceInvoked = false
                            self.alertView!.afterRemove = {
                                self.removeSelector()
                                return
                            }
                            
                            if self.products == nil || self.products!.count == 0 {
                                self.editBtn!.isHidden = true
                                self.deleteAllBtn!.isHidden = true
                                self.isEdditing = true
                                self.showEditionMode()
                                self.showEmptyView()
                            } else {
                                self.editBtn!.isHidden = false
                            }
                            }, reloadList: true)
                        succesDelete()
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
    
    func invokeDeleteAllProductsFromListService(_ upcs:[String]) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.deletingAllProductsInList", comment:""))
        let service = GRDeleteItemListService()
        service.callService(service.buildParamsArray(upcs),
            successBlock: { (result:[String:Any]) -> Void in
                self.alertView!.setMessage(NSLocalizedString("list.message.deletingAllProductsInListDone", comment:""))
                self.alertView!.showDoneIcon()
               
                self.showEditionMode()
                self.products = nil
                self.editBtn!.isHidden = true
                self.deleteAllBtn!.isHidden = true
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
    
    func invokeUpdateProductFromListService(_ product: Product, quantity:Int,baseUomcd:String) {
        if quantity == 0 {
            invokeDeleteProductFromListService(product, succesDelete: { () -> Void in
                print("succesDelete")
            })
            return
        }
        
        if quantity <= 20000 {
        
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.updatingProductInList", comment:""))
            
                    
        
        let service = GRUpdateItemListService()
        service.callService(service.buildParams(upc: product.upc, quantity: quantity,baseUomcd:baseUomcd),
            successBlock: { (result:[String:Any]) -> Void in
                
                product.quantity = NSNumber(value: Int(quantity) as Int)
                product.orderByPiece = NSNumber(value: self.quantitySelector!.orderByPiece)
                product.pieces =  NSNumber(value:Int(quantity)) 
                self.saveContext()
                
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
    func retrieveProductsLocally(_ reloadList : Bool) {
        var products: [Product]? = nil
        let dateList =  self.listEntity?.registryDate
        
        self.listEntity =  dateList == nil ? nil : self.listEntity
       
        
        if self.listEntity != nil  {//&& self.listEntity!.idList != nil
            
            print("name listEntity:: \(self.listEntity?.name)")
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Product", in: self.managedContext!)
            fetchRequest.predicate = NSPredicate(format: "list == %@", self.listEntity!)
            do{
               products = try self.managedContext!.fetch(fetchRequest) as? [Product]
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
            
        //if self.selectedItems ==  nil  {
            if fromDelete {
                fromDelete = false
                self.selectedItems = []
                self.selectedItems = NSMutableArray()
            
           
                if self.products != nil  && self.products!.count > 0  {
                    for i in 0...self.products!.count - 1 {
                        self.selectedItems?.add(i)
                    }
                    self.updateTotalLabel()
                }
            }
          //  }
            
            self.updateTotalLabel()
        }else
        {
         self.products =  nil
         self.titleLabel?.text = ""
            self.editBtn!.isHidden = true
            self.deleteAllBtn!.isHidden = true
            self.tableView!.reloadData()
            self.reloadTableListUser()
        }


        if self.products == nil || self.products!.count == 0 {
            self.editBtn!.isHidden = true
            self.deleteAllBtn!.isHidden = true
            self.isEdditing = true
            self.showEditionMode()
            self.showEmptyView()
            
        } else {
            self.editBtn!.isHidden = false
            self.deleteAllBtn!.isHidden = false
            self.removeEmpyView()
        }
        
      
        
    }
    
    func reloadTableListUserSelectedRow(){
        
    }

    
    func saveContext() {
        if self.managedContext!.hasChanges {
            do {
                try self.managedContext!.save()
            } catch {
                print("error at save context on UserListViewController")
            }
        }
    }
    
        
    func reloadTableListUser(){
        
    }
    
    func didDisable(_ disaable:Bool,cell:DetailListViewCell) {
        let indexPath = self.tableView?.indexPath(for: cell)
        if disaable {
            self.selectedItems?.remove(indexPath!.row)
        } else {
            self.selectedItems?.add(indexPath!.row)
        }
        self.updateTotalLabel()
        if self.selectedItems != nil {
            self.tableView?.reloadData()
        }
    }
    
    
    func buildEditNameSection() {
        
        containerEditName = UIView()
        containerEditName?.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: 64)
        
        let separator = UIView(frame:CGRect(x: 0, y: containerEditName!.frame.height - AppDelegate.separatorHeigth(), width: self.view.frame.width, height: AppDelegate.separatorHeigth()))
        separator.backgroundColor = WMColor.light_light_gray
        
        self.nameField = FormFieldView()
        self.nameField!.maxLength = 25
        self.nameField!.delegate = self
        self.nameField!.typeField = .string
        self.nameField!.nameField = NSLocalizedString("list.search.placeholder",comment:"")
        self.nameField!.frame = CGRect(x: 16.0, y: 12.0, width: self.view.bounds.width - 32.0, height: 40.0)
        self.nameField!.text = listName
        self.nameField!.delegate = self
        
        
        containerEditName?.addSubview(separator)
        containerEditName?.addSubview(nameField!)
        self.view.addSubview(containerEditName!)
        containerEditName?.alpha = 0
        
    }
    
    
    func duplicate() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_DUPLICATE_LIST.rawValue , label: "")
        if UserCurrentSession.hasLoggedUser() {
            let service = GRUserListService()
            self.itemsUserList = service.retrieveUserList()
            if  self.itemsUserList!.count == 12{
                 self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
                alertView!.setMessage(NSLocalizedString("list.copy.inProcess", comment:""))
                self.alertView!.setMessage(NSLocalizedString("list.error.validation.max", comment: ""))
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            }else{
                self.invokeSaveListToDuplicateService(forListId: listId!, andName: listName!, successDuplicateList: { () -> Void in
                    self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
                    self.alertView!.showDoneIcon()
                })
            }

        }else{
         NotificationCenter.default.post(name: Notification.Name(rawValue: "DUPLICATE_LIST"), object: nil)
        }
    }
    

    
    
    func updateLustName() {
        
        if self.nameField?.text != self.titleLabel?.text {
            
            
            let _ = self.nameField?.resignFirstResponder()
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(NSLocalizedString("list.message.updatingListNames", comment:""))
            
            if UserCurrentSession.hasLoggedUser() {
                if  NewListTableViewCell.isValidName(self.nameField!){
                if saveUpdateListContinue() {
                    let detailService = GRUserListDetailService()
                    detailService.buildParams(self.listId == nil ? "" : self.listId!)
                    detailService.callService([:],
                                              successBlock: { (result:[String:Any]) -> Void in
                                                let service = GRUpdateListService()
                                                service.callService(self.nameField!.text!,
                                                                    successBlock: { (result:[String:Any]) -> Void in
                                                                        self.titleLabel?.text = self.nameField?.text
                                                                        service.updateListNameDB(self.listId!, listName: self.nameField!.text!)
                                                                        self.reminderService!.updateListName(self.nameField!.text!)
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
                    )//service
                    }
                }else{
                    self.nameField?.text =  self.listName
                    self.alertView!.close()
                }
                
            }else{
                
                if NewListTableViewCell.isValidName(self.nameField!){
        
                    if self.saveUpdateListContinue() {
                        let service = GRUserListService()
                        let listIndb = service.retrieveNotSyncList()
                        for mylist in listIndb! {
                            if mylist.name == self.listName {
                                mylist.name = self.nameField!.text!
                                self.titleLabel?.text = self.nameField!.text!
                                self.listName = self.nameField!.text!
                                
                                break
                            }
                        }
                        self.saveContext()
                        
                        self.alertView!.setMessage(NSLocalizedString("list.message.updatingListNamesDone", comment:""))
                        self.alertView!.showDoneIcon()
                    }
                }else{
                    self.nameField?.text =  self.listName
                    self.alertView!.close()
                }
                
            }//else
            
        }
    }
    
    func saveUpdateListContinue()->Bool {
    
        var savecontinue = true
        let service = GRUserListService()
        let listIndb = service.retrieveUserList()
        
        for mylist in listIndb! {
            if mylist.name == self.nameField!.text!{
                self.alertView!.setMessage(NSLocalizedString("gr.list.samename", comment: ""))
                self.alertView!.showErrorIcon("Ok")
                self.nameField?.text =  self.listName
                savecontinue =  false
                break
            }
        }
        
        return savecontinue
        
    }
    
    //MAR: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        let newString = strNSString.replacingCharacters(in: range, with: string)
        
        return (newString.characters.count > 25) ? false : true
    }
    
    
    func backEmpty() {
        super.back()
    }

    override func back() {
        super.back()
    }
    
    //MARK: - Reminder
    
    func setReminderSelected(_ selected:Bool){
        self.reminderButton?.isSelected = selected
        if selected{
            self.reminderButton!.setTitle("Recordatorio: \(self.reminderService!.getNotificationPeriod())", for: .selected)
            self.reminderButton!.setTitle("Recordatorio: \(self.reminderService!.getNotificationPeriod())", for: UIControlState())
        }else{
            self.reminderButton!.setTitle("Crear recordatorio para esta lista", for: UIControlState())
        }
    }
    
    func addReminder(){
        let selected = self.reminderButton!.isSelected
        let reminderViewController = ReminderViewController()
        reminderViewController.listId = self.listId!
        reminderViewController.listName = self.listName!
        reminderViewController.delegate = self
        if  selected {
            reminderViewController.selectedPeriodicity = self.reminderService!.currentNotificationConfig!["type"] as? Int
            reminderViewController.currentOriginalFireDate = self.reminderService!.currentNotificationConfig!["originalFireDate"] as? Date
        }
        self.navigationController?.pushViewController(reminderViewController, animated: true)
    }
    
    func notifyReminderWillClose(forceValidation flag: Bool, value: Bool) {

        if self.reminderService!.existNotificationForCurrentList() || value{
            setReminderSelected(true)
        }else{
            setReminderSelected(false)
        }
    }
    
    //MARK: AddProductTolistViewDelegate
    func scanCode() {
        let barCodeController = BarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.delegate = self
        barCodeController.searchProduct = true
        barCodeController.useDelegate = true
        barCodeController.isAnyActionFromCode =  true
        self.present(barCodeController, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraController = CameraViewController()
        cameraController.delegate = self
        self.present(cameraController, animated: true, completion: nil)
    }
    
    func searchByText(_ text: String) {
        if text.isNumeric() {
            let cero = text.length() < 13 ? "0":""
            self.findProdutFromUpc("\(cero)\(text)")
        }else{
            
            let message = self.validateText(text)
            if message != ""{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"), imageDone: nil, imageError:
                    UIImage(named:"noAvaliable"))
                self.alertView!.setMessage(message)
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                self.addProductsView?.changeFrame = false
                return
            }
            self.searchByTextAndCamfind(text, upcs: nil, searchContextType: .withText,searchServiceFromContext:.fromSearchText )
        }
        
    }
    
    
    //MARK: BarCodeViewControllerDelegate
    func barcodeCaptured(_ value: String?) {
        print(value ?? "")
    }
    
    func barcodeCapturedWithType(_ value: String?, isUpcSearch: Bool) {
        
        if isUpcSearch {
            self.findProdutFromUpc(value!)
        }else{
            self.invokeServicefromTicket(value!)
        }
    }
    
    //MARK: CameraViewControllerDelegate
    func photoCaptured(_ value: String?, upcs: [String]?, done: (() -> Void)) {
        if value !=  nil {
            if value != "" {
                self.searchByTextAndCamfind(value!, upcs: upcs, searchContextType: .withTextForCamFind,searchServiceFromContext: .fromSearchCamFind)
            }
        }
    }
    
    //MARK:  Actions
    func findProdutFromUpc(_ upc:String){
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("Agregando el producto a tu lista", comment:""))
        
        let useSignalsService : [String:Any] = ["signals" : GRBaseService.getUseSignalServices()]
        let svcValidate = GRProductDetailService(dictionary: useSignalsService)
        
        let upcDesc : NSString = upc as NSString
        var paddedUPC = upcDesc
        if upcDesc.length < 13 {
            let toFill = "".padding(toLength: 14 - upcDesc.length, withPad: "0", startingAt: 0)
            paddedUPC = "\(toFill)\(paddedUPC)" as NSString
        }
        let params = svcValidate.buildParams(paddedUPC as String, eventtype: "pdpview",stringSearch: "",position: "")//position
        svcValidate.callService(requestParams:params, successBlock: { (result:[String:Any]) -> Void in
            //[["upc":paddedUPC,"description":keyWord,"type":ResultObjectType.Groceries.rawValue]]
            print("Correcto el producto es::::")
            self.invokeAddproductTolist(result,products: nil, succesBlock: { () -> Void in
                print("Se agrega correctamnete")
                
                guard let name = result["description"] as? String,
                    let id = result["upc"] as? String,
                    let price = result["price"] else {
                        return
                }
                
                // 360 Event
                BaseController.sendAnalyticsProductToList(id, desc: name, price: "\(price as! Int)")
                
            })
            
            }, errorBlock: { (error:NSError) -> Void in
                print("Error al buscar producto")
                self.alertView?.setMessage(error.localizedDescription)
                self.alertView?.showErrorIcon("Ok")
        })
        
    }
    
    func searchByTextAndCamfind(_ text: String,upcs:[String]?,searchContextType:SearchServiceContextType,searchServiceFromContext:SearchServiceFromContext) {
        
        let controller = SearchProductViewController()
        controller.upcsToShow = upcs
        controller.searchContextType = searchContextType
        controller.titleHeader = text
        controller.textToSearch = text
        controller.searchFromContextType = .fromSearchTextList
        controller.idListFromSearch =  self.listId
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    func invokeAddproductTolist(_ response:[String:Any]?,products:[Any]?,succesBlock:@escaping (() -> Void)){
        
        let service = GRAddItemListService()
        var isPesable  = ""
        var isActive =  true
        var upcAdd = ""
        var baseUomcdAdd = ""
        if response != nil {
            if let pesable = response!["type"] as? String {
                isPesable = pesable
            }
            if let active = response!["stock"] as? Int {
                isActive = active == 1  ? true :  false
            }
            if let upc =  response!["upc"] as? String{
                upcAdd = upc
            }
            
            if let baseUomcd =  response!["baseUomcd"] as? String{
                baseUomcdAdd = baseUomcd
            }
        }
        
        let productObject = response == nil ? [] : [service.buildProductObject(upc:upcAdd, quantity:1,pesable:isPesable,active:isActive,baseUomcd:baseUomcdAdd)]//send baseUomcd
      
        service.callService(service.buildParams(idList: self.listId!, upcs: products != nil ? products : productObject),
            successBlock: { (result:[String:Any]) -> Void in
                succesBlock()
                self.alertView?.setMessage(NSLocalizedString("list.message.addProductToListDone", comment:""))
                self.alertView?.showDoneIcon()
                self.loadServiceItems(nil)
              
            }, errorBlock: { (error:NSError) -> Void in
                print("Error at add product to list: \(error.localizedDescription)")
                self.alertView?.setMessage(error.localizedDescription)
                self.alertView?.showErrorIcon("Ok")
               
            }
        )
    }
 
    func invokeServicefromTicket(_ ticket:String){
        
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("Agregando los productos a tu lista", comment:""))
        
        let service = GRProductByTicket()
        service.callService(service.buildParams(ticket),
            successBlock: { (result: [String:Any]) -> Void in
                
                
                if let items = result["items"] as? [Any] {
                    if items.count == 0 {
                        self.alertView?.setMessage(NSLocalizedString("list.message.noProductsForTicket", comment:""))
                        self.alertView?.showErrorIcon("Ok")
                        return
                    }
                    
                    let service = GRAddItemListService()
                    var products: [Any] = []
                    for idx in 0 ..< items.count {
                        let item = items[idx] as! [String:Any]
                        let upc = item["upc"] as! String
                        var quantity: Int = 0
                        
                        if  let qIntProd = item["quantity"] as? Int {
                            quantity = qIntProd
                        }
                        if  let qIntProd = item["quantity"] as? NSString {
                            quantity = qIntProd.integerValue
                        }
                        var pesable = "0"
                        if  let pesableP = item["type"] as? String {
                            pesable = pesableP
                        }
                        var active = true
                        if let stock = item["stock"] as? Bool {
                            active = stock
                        }
                        products.append(service.buildProductObject(upc: upc, quantity: quantity,pesable:pesable,active:active,baseUomcd:""))//baseUomcd
                    }
                    
                    self.invokeAddproductTolist(nil, products:products, succesBlock: { () -> Void in
                        print("Se agrega correctamnete")
                    })
                
                }
            },  errorBlock: { (error:NSError) -> Void in
                self.alertView?.setMessage(error.localizedDescription)
                self.alertView?.showErrorIcon("Ok")
        })
        
    }
    
    //MARK validate search
    func validateText(_ search:String) -> String {
        var message  =  ""
        let toValidate : NSString = search as NSString
        let trimValidate = toValidate.trimmingCharacters(in: CharacterSet.whitespaces)
        if toValidate.isEqual(to: ""){
            message = "Escriba una palabra a buscar"
        }
        if trimValidate.lengthOfBytes(using: String.Encoding.utf8) < 2 {
            message = NSLocalizedString("product.search.minimum",comment:"")
        }
        if !validateSearch(search)  {
           message = "Texto no permitido"
        }
        if search.lengthOfBytes(using: String.Encoding.utf8) > 50  {
            message = "La longitud no puede ser mayor a 50 caracteres"
        }
        return message
    }
    
    func validateSearch(_ toValidate:String) -> Bool{
        let regString : String = "^[A-Z0-9a-z._-ñÑÁáÉéÍíÓóÚú& ]{0,100}$";
        return IPASearchView.validateRegEx(regString,toValidate:toValidate)
    }
   
    
}

extension UserListDetailViewController: UIViewControllerPreviewingDelegate {
    //registerForPreviewingWithDelegate
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView?.indexPathForRow(at: location) {
            //This will show the cell clearly and blur the rest of the screen for our peek.
            if #available(iOS 9.0, *) {
                previewingContext.sourceRect = tableView!.rectForRow(at: indexPath)
            }
            return self.getDetailController(index:indexPath)
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController!.pushViewController(viewControllerToCommit, animated: true)
        //present(viewControllerToCommit, animated: true, completion: nil)
    }
}

extension UserListDetailViewController: UIGestureRecognizerDelegate {
    
    func addLongTouch(view:UIView) {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(UserListDetailViewController.handleLongPress(gestureReconizer:)))
        longPressGesture.minimumPressDuration = 0.6 // 1 second press
        longPressGesture.allowableMovement = 15 // 15 points
        longPressGesture.delegate = self
        view.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        
        let p = gestureReconizer.location(in: self.tableView)
        let indexPath = tableView!.indexPathForRow(at: p)
        
        if let viewControllerToCommit = self.getDetailController(index: indexPath!) {

            viewControllerToCommit.view.frame.size = CGSize(width: self.view.frame.width - 20, height: self.view.frame.height - 45)
            
            if self.preview == nil {
                let cellFrame =  tableView!.rectForRow(at: indexPath!)
                let cellFrameInSuperview = tableView!.convert(cellFrame, to: tableView!.superview)
                self.preview = PreviewModalView.initPreviewModal(viewControllerToCommit.view)
                self.preview?.cellFrame = cellFrameInSuperview
            }
            
            if gestureReconizer.state == UIGestureRecognizerState.ended {
                self.preview?.closePicker()
                self.preview = nil
            }
            
            if gestureReconizer.state == UIGestureRecognizerState.began {
                if indexPath != nil {
                    self.preview?.showPreview()
                }
            }
        }
    }
}
