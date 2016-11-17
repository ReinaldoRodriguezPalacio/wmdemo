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
    var products: [[String:Any]]?
    var isEdditing = false
    var enableScrollUpdateByTabBar = true

    var deleteProductServiceInvoked = false
    
    var equivalenceByPiece : NSNumber! = NSNumber(value: 0 as Int32)
    var selectedItems : NSMutableArray? = nil
    
    var containerEditName: UIView?
    var reminderButton: UIButton?
    var reminderService: ReminderNotificationService?
    var showReminderButton: Bool = false
    
    var addProductsView : AddProductTolistView?
    var fromDelete  =  true
    var openEmpty =  false
    
    var retunrFromSearch =  false
    
    var listDetailHelView : ListHelpView?
    //var plpView : PLPLegendView?
    
    var openDetailOrReminder =  false
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
        self.view.backgroundColor = UIColor.white
        
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
        self.tableView!.register(ShoppingCartTotalsTableViewCell.self, forCellReuseIdentifier: self.TOTAL_CELL_ID)

        self.footerSection!.backgroundColor = UIColor.white
        
        
        let y = (self.footerSection!.frame.height - 34.0)/2
        self.duplicateButton = UIButton(frame: CGRect(x: 16.0, y: y, width: 34.0, height: 34.0))
        self.duplicateButton!.setImage(UIImage(named: "list_duplicate"), for: UIControlState())
        self.duplicateButton!.setImage(UIImage(named: "list_active_duplicate"), for: .selected)
        self.duplicateButton!.setImage(UIImage(named: "list_active_duplicate"), for: .highlighted)
        self.duplicateButton!.addTarget(self, action: #selector(UserListDetailViewController.duplicate), for: .touchUpInside)
        self.footerSection!.addSubview(self.duplicateButton!)
        
        var x = self.duplicateButton!.frame.maxX + 16.0
        self.shareButton = UIButton(frame: CGRect(x: x, y: y, width: 34.0, height: 34.0))
        self.shareButton!.setImage(UIImage(named: "detail_shareOff"), for: UIControlState())
        self.shareButton!.setImage(UIImage(named: "detail_share"), for: .selected)
        self.shareButton!.setImage(UIImage(named: "detail_share"), for: .highlighted)
        self.shareButton!.addTarget(self, action: #selector(UserListDetailViewController.shareList), for: .touchUpInside)
        self.footerSection!.addSubview(self.shareButton!)
        
        x = self.shareButton!.frame.maxX + 16.0
        self.reminderButton = UIButton(frame: CGRect(x: x, y: y, width: 34.0, height: 34.0))
        self.reminderButton!.setImage(UIImage(named: "reminder"), for: UIControlState())
        self.reminderButton!.addTarget(self, action: #selector(UserListDetailViewController.addReminder), for: UIControlEvents.touchUpInside)
        self.reminderButton!.isHidden = true
        self.reminderButton!.layer.cornerRadius = 11
        self.footerSection!.addSubview(self.reminderButton!)
        
        if UserCurrentSession.hasLoggedUser() {
            x = self.reminderButton!.frame.maxX + 16.0
        }
        self.addToCartButton = UIButton(frame: CGRect(x: x, y: y, width: self.footerSection!.frame.width - (x + 16.0), height: 34.0))
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
        
       
        
        if !TabBarHidden.isTabBarHidden {
            let tabBarHeight:CGFloat = 45.0
            self.footerConstraint?.constant = tabBarHeight
            self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height + tabBarHeight, 0)
            self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height + tabBarHeight, 0)
        }else if !self.enableScrollUpdateByTabBar && TabBarHidden.isTabBarHidden {
            self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)
            self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)
        }
        
        self.isSharing = false
        buildEditNameSection()
        self.showReminderButton = UserCurrentSession.hasLoggedUser() && ReminderNotificationService.isEnableLocalNotificationForApp() && self.listId != nil && self.listName != nil
        self.tableConstraint?.constant = (self.showReminderButton ? 110.0 : self.header!.frame.height)
        self.addProductsView = AddProductTolistView()
        self.addProductsView!.backgroundColor =  UIColor.white
        self.addProductsView!.delegate =  self
        if showReminderButton{
            x = self.reminderButton!.frame.maxX + 16.0
            self.addToCartButton!.frame =  CGRect(x: x,y: y, width: self.addToCartButton!.frame.width, height: self.addToCartButton!.frame.height)
            
            self.reminderService = ReminderNotificationService(listId: self.listId!, listName: self.listName!)
            self.reminderService?.findNotificationForCurrentList()
            self.setReminderSelected(self.reminderService!.existNotificationForCurrentList())
            self.view.addSubview(self.addProductsView!)
            
        }
        
        // self.showLoadingView()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CustomBarNotification.TapBarFinish.rawValue), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(UserListDetailViewController.tabBarActions),name:NSNotification.Name(rawValue: CustomBarNotification.TapBarFinish.rawValue), object: nil)
        //Solo para presentar los resultados al presentar el controlador sin delay
        if !openDetailOrReminder {
            if UIDevice.current.userInterfaceIdiom == .phone {
                loadServiceItems(nil)
            }
        }
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarActions()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.header!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 46.0)
        
        
        if !self.isSharing {
            if showReminderButton {
                self.reminderButton?.frame = CGRect(x: self.shareButton!.frame.maxX + 16.0, y: self.shareButton!.frame.minY, width: 34, height: 34)
                
                self.addProductsView!.frame = CGRect(x: 0,y: self.header!.frame.maxY, width: self.view.frame.width, height: 64.0)
                
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
     Present helpView  in detail
     */
    func showHelpViewDetail(){
        var requiredHelp = true
        if let param = CustomBarViewController.retrieveParam("reminderListHelp") {
            requiredHelp = !(param.value == "false")
        }
        let  showTurial = (requiredHelp && self.listDetailHelView == nil)
        
        if showTurial {
            listDetailHelView =  ListHelpView(frame: CGRect(x: 0,y: 0,width: self.view.bounds.width,height: self.view.bounds.height),context:ListHelpContextType.inReminderList )
            listDetailHelView?.onClose  = {() in
                self.removeHelpView()
            }
            
            let window = UIApplication.shared.keyWindow
            if let customBar = window!.rootViewController as? CustomBarViewController {
                listDetailHelView?.frame = CGRect(x: 0,y: 0 , width: self.view.bounds.width, height: customBar.view.frame.height)
                customBar.view.addSubview(listDetailHelView!)
                CustomBarViewController.addOrUpdateParam("reminderListHelp", value: "false")
            }
        }
    }
    
    /**
     Removehelp view
     */
    func removeHelpView() {
        if self.listDetailHelView != nil {
            UIView.animate(withDuration: 0.5,
                                       animations: { () -> Void in
                                        self.listDetailHelView!.alpha = 0.0
                },
                                       completion: { (finished:Bool) -> Void in
                                        if finished {
                                            self.listDetailHelView!.removeFromSuperview()
                                            self.listDetailHelView = nil
                                        }
                }
            )
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
                        let item =  self.products![i] //as? [String:Any]
                        if let sku = item["sku"] as? [String:Any] {
                            if let parentProducts = sku["parentProducts"] as? [[String:Any]]{
                                if let item =  parentProducts.object(at: 0) as? [String:Any] {
                                    self.selectedItems?.add(item["repositoryId"] as! String)
                                }
                            }
                        }
                    }
                    self.updateTotalLabel()
                    self.showHelpViewDetail()
                }
                
                complete?()
                }, reloadList: false)
        }
        else {
            self.retrieveProductsLocally(false)
            if self.products == nil  || self.products!.count == 0 {
                self.selectedItems = []
            } else {
                self.counSections()
                self.selectedItems = NSMutableArray()
                for i in 0...self.products!.count - 1 {
                    let item =  self.products![i] as? Product
                    self.selectedItems?.add(item!.upc )
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
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_EDIT_MY_LIST.rawValue, label: "")
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.tableConstraint?.constant = 110
                self.containerEditName!.alpha = 1
                self.footerSection!.alpha = 0
                self.reminderButton?.alpha = 0.0
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
                self.updateListName()
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
                    self.tableConstraint?.constant = (self.showReminderButton ? 110.0 : 0.0)
                    self.containerEditName!.alpha = 0
                    self.reminderButton?.alpha = 1.0
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
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_SHARE.rawValue , label: "")
        
        if let image = self.tableView!.screenshot() {
            let imageHead = UIImage(named:"detail_HeaderMail")
            let imgResult = UIImage.verticalImage(from: [imageHead!,image])
            let controller = UIActivityViewController(activityItems: [imgResult], applicationActivities: nil)
            self.navigationController?.present(controller, animated: true, completion: nil)
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

        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_ADD_ALL_TO_SHOPPING_CART.rawValue , label: "")
        //ValidateActives
        var hasActive = false
        for product in self.products! {
            if let item = product as? [String:Any] {
                if let stock = item["stock"] as? Bool { //Preguntar con que se valida la venta
                    if stock == true {
                        hasActive = true
                        break
                    }
                }else{//TODO Prueba
                    hasActive = true
                    break
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
            let msgInventory = NSLocalizedString("list.message.no.aviable.products", comment: "")
            alert!.setMessage(msgInventory)
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            return
        }
        
        if self.products != nil && self.products!.count > 0 {
            var upcs: [Any] = []
            for idxVal  in selectedItems! {
               var params: [String:Any] = [:]
                //validar session
                if  UserCurrentSession.hasLoggedUser() {
                    var index = 0
                    for lines in self.products! {
                        var productItem : [String:Any]? = [:]
                        
                        let quantityItem = lines["quantityDesired"] as! String
                        let priceItem = lines["specialPrice"] as! String
                        
                        if let sku = lines["sku"] as? [String:Any] {
                            
                            if let parentProducts = sku.object(forKey: "parentProducts") as? [[String:Any]]{
                                if let item =  parentProducts.object(at: 0) as? [String:Any] {
                                    productItem = item
                                }
                            }
                        }
                        
                        if productItem!["repositoryId"] as! String == idxVal as! String {
                            params["upc"] = productItem!["repositoryId"] as! String as AnyObject?
                            params["skuId"] = "skuidList" as AnyObject?
                            params["desc"] = productItem!["description"] as! String as AnyObject?
                            params["imgUrl"] = productItem!["smallImageUrl"] as! String as AnyObject?
                            
                            params["price"] = priceItem as AnyObject?
                            
                            params["quantity"] = quantityItem as AnyObject?
                         
                            
                            params["pesable"] = lines["type"] as? NSString
                            params["wishlist"] = false as AnyObject?
                            params["type"] = ResultObjectType.Groceries.rawValue as AnyObject?
                            params["comments"] = "" as AnyObject?
                            if let type = lines["type"] as? String {
                                if Int(type)! == 0 { //Piezas
                                    params["onHandInventory"] = "99" as AnyObject?
                                }
                                else { //Gramos
                                    params["onHandInventory"] = "20000" as AnyObject?
                                }
                            }
                        }
                    }
                }else{
                    var index = 0
                    
                    
                    
                    for lines in self.products!{
                        //let arrayItems =  lines[linesArray[index] as! String] as! [[String:Any]]
                        //for item  in  arrayItems {
                            let productItem = lines as? Product
                            if selectedItems!.contains(productItem!.upc){
                                //let productItem = item as? Product
                                params["skuId"] = "skuidList" as AnyObject?
                                params["upc"] = productItem!.upc as AnyObject?
                                params["desc"] = productItem!.desc as AnyObject?
                                params["imgUrl"] = productItem!.img as AnyObject?
                                params["price"] = productItem!.price
                                params["quantity"] = "\(productItem!.quantity)" as AnyObject?
                                params["wishlist"] = false as AnyObject?
                                params["comments"] = "" as AnyObject?
                                let isPesable = productItem!.type.boolValue
                                params["pesable"] = isPesable ? "1" : "0" as AnyObject?
                                params["type"] = ResultObjectType.Groceries.rawValue as AnyObject? //validar Type
                                if productItem!.type.intValue == 0 { //Piezas
                                    params["onHandInventory"] = "99" as AnyObject?
                                }
                                else { //Gramos
                                    params["onHandInventory"] = "20000" as AnyObject?
                                }
                                
                            }
                        //}
                        index = index+1
                    }
                    print("params sin session")
                    print(params)
                    
                    
                }
                
                upcs.append(params as AnyObject)
            }
            if upcs.count > 0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddItemsToShopingCart.rawValue), object: self, userInfo: ["allitems":upcs, "image":"list_alert_addToCart"])
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
        let msgInventory = NSLocalizedString("list.message.no.aviable.products", comment: "")
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
                self.showEmptyView()
                self.reloadTableListUser()
            }
            
            
            
        }
    }
    
    /**
     Show Empty View
     */
    func showEmptyView() {
        self.openEmpty = true
        let bounds = self.view.bounds
        let height = bounds.size.height - self.header!.frame.height
        self.emptyView?.removeFromSuperview()
        if UserCurrentSession.hasLoggedUser() {
            self.emptyView = UIView(frame: CGRect(x: 0.0, y: self.header!.frame.maxY + 64, width: bounds.width, height: height))
        }else{
            self.emptyView = UIView(frame: CGRect(x: 0.0, y: self.header!.frame.maxY, width: bounds.width, height: height))
        }
        self.emptyView!.backgroundColor = UIColor.white
        self.view.addSubview(self.emptyView!)
        
        let bg = UIImageView(image: UIImage(named:  UserCurrentSession.hasLoggedUser() ? "empty_list":"list_empty_no" ))
        bg.frame = CGRect(x: 0.0, y: 0.0,  width: bounds.width,  height: bg.image!.size.height)
        self.emptyView!.addSubview(bg)
        
        let labelOne = UILabel(frame: CGRect(x: 0.0, y: 28.0, width: bounds.width, height: 16.0))
        labelOne.textAlignment = .center
        labelOne.textColor = WMColor.light_blue
        labelOne.font = WMFont.fontMyriadProLightOfSize(14.0)
        labelOne.text = NSLocalizedString("list.detail.empty.header", comment:"")
        self.emptyView!.addSubview(labelOne)
        
        let labelTwo = UILabel(frame: CGRect(x: 0.0, y: labelOne.frame.maxY + 12.0, width: bounds.width, height: 48))
        labelTwo.textAlignment = .center
        labelTwo.textColor = WMColor.light_blue
        labelTwo.font = WMFont.fontMyriadProRegularOfSize(14.0)
        
        labelTwo.numberOfLines =  5
        labelTwo.text = NSLocalizedString("list.detail.empty.text", comment:"")
        self.emptyView!.addSubview(labelTwo)
        
        let icon = UIImageView(image: UIImage(named: "empty_list_icon"))
        icon.frame = CGRect(x: 63.0, y: labelTwo.frame.maxY - 18 , width: 16.0, height: 16.0)
        self.emptyView!.addSubview(icon)
        
        let button = UIButton(type: .custom)
        if UserCurrentSession.hasLoggedUser() {
            button.frame = CGRect(x: (bounds.width - 160.0)/2,y: self.emptyView!.frame.height - 100, width: 160 , height: 40)
        }else{
            button.frame = CGRect(x: (bounds.width - 160.0)/2,y: self.emptyView!.frame.height - 160, width: 160 , height: 40)
        }
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
            print("updateTotalLabel::")
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
        print("calculateTotalAmount:::")
        if selectedItems != nil {
    
            if UserCurrentSession.hasLoggedUser() {
                for upcSelected in selectedItems! {
                    for lines in self.products! {
                        let upc = upcSelected as! String
                        if let sku = lines["sku"] as? [String:Any] {
                            if let parentProducts = sku.object(forKey: "parentProducts") as? [[String:Any]]{
                                if let item =  parentProducts.object(at: 0) as? [String:Any] {
                                    if  item["repositoryId"] as! String  == upc {
                                        
                                        if let typeProd = sku["weighable"] as? NSString {
                                            let quantity = lines["quantityDesired"] as! String
                                            let price = lines["specialPrice"] as! String
                                            
                                            if typeProd == "N" {
                                                total += (Double(quantity)! * Double(price)!)
                                            }
                                            else {
                                                let kgrams = Double(quantity)! / 1000.0
                                                total += (kgrams * Double(price)!)
                                            }
                                        }
                                    }
                                    
                                }//Item
                            }
                        }

                }
                }//for upcSelected in selectedItems!
                
            }else{// if UserCurrentSession.hasLoggedUser()
            
                var index = 0
                    
                for lines in self.products!{
                   // let arrayItems =  lines[linesArray[index] as! String] as! NSArray
                    //for item  in  arrayItems {
                        let productItem = lines as? Product
                        if selectedItems!.contains(productItem!.upc){
                            print("suma: \(productItem!.price.doubleValue)")
                            let quantity = productItem!.quantity
                            let price:Double = productItem!.price.doubleValue
                            if productItem!.type == 0 {
                                total += (quantity.doubleValue * price)
                            }
                            else {
                                let kgrams = quantity.doubleValue / 1000.0
                                total += (kgrams * price)
                            }
                            
                        }
                    //}
                    index = index+1
                }

                
            }//close else
            
            
        }
        print("total::")
        print(total)
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
                if item.type == "false" {
                    count += quantity.intValue
                }
                else {
                    count += 1
                }
            }
        }
        return count
    }
    

    
    //MARK: - UITableViewDataSource
    let linesArray : NSMutableArray = []
    //var newArrayProducts : [[String:Any]]! = []
    
    /**
     Find any lines and organized by sections
     */
    func counSections(){
        //self.newArrayProducts = []
        if UserCurrentSession.hasLoggedUser() {
            for items in self.products! {
                let line = items["fineContent"] as? [String:Any]
                let lineId = line!["fineLineName"] as? String
                if  !linesArray.contains(lineId!) {
                    print("se agrega")
                    linesArray.add(lineId!)
                }
            }
            for lineArray in linesArray {
                var arrayitems : [Any] = []
                for  items in self.products!  {
                    let line = items["fineContent"] as? [String:Any]
                    let lineId = line!["fineLineName"] as? String
                    
                    if lineId! == lineArray as! String {
                        arrayitems.append(items)
                    }
                }
              //  newArrayProducts.append ([lineArray as! String:arrayitems])
            }
//            self.newArrayProducts = newArrayProducts.sort({ (first:[String:Any], second:[String:Any]) -> Bool in
//                let dicFirst = first.first!.0 as String
//                let dicSecond = second.first!.0 as String
//                return dicFirst < dicSecond
//            })
        }else{//Product - Entity
            
            for items in self.products! {
                let productItem =  items as! Product
                
                if  !linesArray.contains(productItem.nameLine) {
                    print("se agrega sin session ")
                    linesArray.add(productItem.nameLine)
                }
            }
    
            for lineArray in linesArray {
                var arrayitems : [Any] = []
                for  items in self.products!  {
                    let productItem =  items as! Product
                    if productItem.nameLine == lineArray as! String {
                        arrayitems.append(productItem)
                    }
                }
              //  newArrayProducts.append ([lineArray as! String:arrayitems])
            }
        
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  2//products!.count == 0 ? 1 : products!.count + 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        if section == 1 {
           return nil
        }
        
        let header = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 21.0))
        header.backgroundColor = UIColor.white
        if linesArray.count > 0 {
            let title = UILabel(frame: CGRect(x: 16.0, y: (header.frame.height - 12) / 2 , width: self.view.frame.width - 32.0, height: 12.0))
            title.textColor = WMColor.light_blue
            title.font = WMFont.fontMyriadProRegularOfSize(11)
            title.text = linesArray[section] as? String
            header.addSubview(title)
            
        }
        
        return header

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var size = 0

        print(section)
        if section == 1 {//self.products!.count  {
            return 1
        }
        
        if self.products != nil  && self.products!.count > 0 {
                size = self.products!.count
        }
        
        return size
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath as NSIndexPath).section == 1 { //self.products!.count
            let totalCell = tableView.dequeueReusableCell(withIdentifier: self.TOTAL_CELL_ID, for: indexPath) as! ShoppingCartTotalsTableViewCell
            let total = self.calculateTotalAmount()
            //totalCell.setValues("", iva: "", total: "\(total)", totalSaving: "", numProds:"")
            totalCell.setValuesTotalSaving(Total: "\(total)", saving: "")
            return totalCell
        }

        let listCell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID, for: indexPath) as! DetailListViewCell
        let controller = self.view.window!.rootViewController
        listCell.viewIpad = controller!.view
        listCell.productImage!.image = nil
        listCell.productImage!.cancelImageRequestOperation()
        listCell.defaultList = false
        listCell.detailDelegate = self
        listCell.delegate = self
        
        var plpArray : [String:Any] = [:]
            if self.products!.count > 0{
                let items = self.products![(indexPath as NSIndexPath).row]
           
                var upc = ""
                if let sku = items["sku"] as? [String:Any] {
                    if let parentProducts = sku.object(forKey: "parentProducts") as? [[String:Any]]{
                        if let item =  parentProducts.object(at: 0) as? [String:Any] {
                            upc = item["repositoryId"] as! String
                        }
                    }
                }

                
                if UserCurrentSession.hasLoggedUser() {
                listCell.setValuesDictionary(items as [String:Any],disabled:self.retunrFromSearch ? !self.retunrFromSearch : !self.selectedItems!.contains(upc), productPriceThrough: "", isMoreArts: true)
                }else{
                    //let listProduct = items[linesArray[indexPath.section] as! String] as! NSArray
                    let product =  items as! Product
                    print(product.upc)
                    listCell.setValues(product,disabled:!self.selectedItems!.contains(product.upc))
                }
            }
        
        
        if self.isEdditing {
            listCell.showLeftUtilityButtons(animated: false)
        }
        //TODO Promotios
        listCell.setValueArray([])
        
        return listCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        if (indexPath as NSIndexPath).section == self.products?.count {
            return 56.0
        }
        return  114.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell!.isKind(of: DetailListViewCell.self) {
            self.openDetailOrReminder =  true
            let controller = ProductDetailPageViewController()
            var productsToShow:[Any] = []
            for idx in 0 ..< self.products!.count {
                if let product = self.products![idx] {
                    
                    if let sku = product["sku"] as? [String:Any] {
                        if let parentProducts = sku.object(forKey: "parentProducts") as? [[String:Any]]{
                            if let item =  parentProducts.object(at: 0) as? [String:Any] {
                                let upc = item["repositoryId"] as! String
                                let description = item["description"] as! String
                                
                                productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Groceries.rawValue, "saving":"","sku":sku.object(forKey: "id") as! String])
                            }
                        }
                    }
                    
                }
                else if let product = self.products![idx] as? Product {
                    
                    productsToShow.append(["upc":product.upc, "description":product.desc, "type":ResultObjectType.Groceries.rawValue, "saving":""])
                }
            }
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue, label: "")
        
        if (indexPath as NSIndexPath).row < productsToShow.count {
            controller.itemsToShow = productsToShow
            controller.ixSelected = (indexPath as NSIndexPath).row
            self.navigationController!.pushViewController(controller, animated: true)
        }
      }
    }
    
    //MARK: - SWTableViewCellDelegate
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        switch index {
        case 0:
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_DELETE_PRODUCT_MYLIST.rawValue, label: "")
            if let indexPath = self.tableView!.indexPath(for: cell) {
                if let item = self.products![(indexPath as NSIndexPath).row] {
                    
                    //Event
                    if self.selectedItems!.contains((indexPath as NSIndexPath).row) {
                        self.selectedItems?.remove((indexPath as NSIndexPath).row)
                    }
                    self.fromDelete =  true
                    self.invokeDeleteProductFromListService(repositoryId: item["repositoryId"] as! String, succesDelete: { () -> Void in
                        print("succesDelete")
                    })
                    
                    
                }
                else if let item = self.products![(indexPath as NSIndexPath).row] as? Product {
                    self.managedContext!.delete(item)
                    self.saveContext()
                    let count:Int = self.listEntity!.products.count
                    self.listEntity!.countItem = NSNumber(value: count as Int)
                    self.saveContext()
                    self.fromDelete =  true
                    self.retrieveProductsLocally(true)
                    self.editBtn!.isHidden = count == 0
                    self.deleteAllBtn!.isHidden = count == 0
                    
                    //self.editBtn!.hidden = true
                }
            }
        default :
            print("other pressed")
        }
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerLeftUtilityButtonWith index: Int) {
        switch index {
        case 0:
            //let indexPath : NSIndexPath = self.viewShoppingCart.indexPathForCell(cell)!
            //deleteRowAtIndexPath(indexPath)
            cell.showRightUtilityButtons(animated: true)
        default :
            print("other pressed")
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
    func didChangeQuantity(_ cell:DetailListViewCell) {
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
            if let item = self.products![(indexPath! as NSIndexPath).row] as? [String:Any] {
                if let pesable = item["type"] as? NSString {
                    isPesable = pesable.intValue == 1
                }
                let numberPrice =  NumberFormatter()
                numberPrice.numberStyle = .decimal
                price = numberPrice.number(from: item["specialPrice"] as! String)
            }
            else if let item = self.products![(indexPath! as NSIndexPath).row] as? Product {
                isPesable = item.type == "false" ?  false : true //mustang
                price = NSNumber(value: item.price.doubleValue as Double)
            }
            

            let width:CGFloat = self.view.frame.width
            var height:CGFloat = (self.view.frame.height - self.header!.frame.height) + 2.0
            if TabBarHidden.isTabBarHidden {
                height += 45.0
            }
            let selectorFrame = CGRect(x: 0, y: self.view.frame.height, width: width, height: height)
            
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
            //self.quantitySelector!.generateBlurImage(self.view, frame:CGRectMake(0.0, 0.0, width, height))
            self.quantitySelector!.addToCartAction = { (quantity:String) in
                if let item = self.products![(indexPath! as NSIndexPath).row] as? [String:Any] {
                    
                    if let sku = item["sku"] as? [String:Any] {
                        if let parentProducts = sku.object(forKey: "parentProducts") as? [[String:Any]]{
                            if let item =  parentProducts.object(at: 0) as? [String:Any] {
                                self.invokeUpdateProductFromListService(fromUpc: item["repositoryId"] as! String, skuId: sku.object(forKey: "id") as! String, quantity: Int(quantity)!)
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
    let serviceBase = GRZipCodeService()
    //MARK: - Services
    func invokeDetailListService(_ action:(()->Void)? , reloadList : Bool) {
        let detailService = UserListDetailService()
        
        detailService.callService(detailService.buildParams(self.listId!),
                                  successBlock: { (result:[String:Any]) -> Void in
                                    
                                    self.products = result["giftlistItems"] as? [[String:Any]]
                                    self.titleLabel?.text = result["name"] as? String
                                    
                                    if self.products == nil || self.products!.count == 0  {
                                        self.selectedItems = []
                                    } else {
                                        if self.fromDelete {
                                            self.fromDelete =  false
                                            self.selectedItems = NSMutableArray()
                                            for i in 0...self.products!.count - 1 {
                                                let item =  self.products![i] //as? [String:Any]
                                                if let sku = item["sku"] as? [String:Any] {
                                                    if let parentProducts = sku.object(forKey: "parentProducts") as? [[String:Any]]{
                                                        if let item =  parentProducts.object(at: 0) as? [String:Any] {
                                                            self.selectedItems?.add(item["repositoryId"] as! String )
                                                        }
                                                    }
                                                }
                                                
                                            }
                                        }
                                        self.openEmpty =  false
                                        self.removeEmpyView()
                                        //self.counSections() //TODO Walmart
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
    
    func invokeDeleteProductFromListService(repositoryId:String,succesDelete:@escaping (()->Void)) {
        if !self.deleteProductServiceInvoked {
            
            self.deleteProductServiceInvoked = true
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToList", comment:""))
            let service = GRDeleteItemListService()
            let params = service.buildDeleteItemMustangObject(idList: self.listId!, upcs:service.buildDeleteItemMustang(repositoryId: repositoryId) as [String:Any])
            service.jsonFromObject(params)
            service.callService(params,
                                successBlock:{ (result:[String:Any]) -> Void in
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
            
            
        }
    }
    
    func invokeDeleteAllProductsFromListService(_ upcs:[String]) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.deletingAllProductsInList", comment:""))
        let service = GRDeleteItemListService()
        service.callService(service.buildParamsArray(upcs) as [String:Any],
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
    
    func invokeUpdateProductFromListService(fromUpc upc:String,skuId:String, quantity:Int) {
        if quantity == 0 {
            invokeDeleteProductFromListService(repositoryId: upc, succesDelete: { () -> Void in
                print("succesDelete")
            })
            return
        }
        
        if quantity <= 20000 {
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(NSLocalizedString("list.message.updatingProductInList", comment:""))
            
            let service = GRUpdateItemListService()
            let params = service.buildItemMustangObject(idList: self.listId!, upcs:service.buildItemMustang(upc,sku: skuId, quantity: quantity))
            service.callService(params,
                                successBlock: { (result:[String:Any]) -> Void in
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
            self.products = products as! [[String : Any]]?
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
                    //for i in 0...self.products!.count - 1 {
                    for product in self.products!{
                        let item =  product as! Product
                        self.selectedItems?.add(item.upc)
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
        do {
            try self.managedContext!.save()
        } catch {
            print("error at save context on UserListViewController")
        }
    }
    
    //MARK: - IPOBaseController scrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.addProductsView?.textFindProduct?.resignFirstResponder()
        
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
            if(scrollView.isTracking && (abs(differenceFromLast)>0.20)) {
                self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)
                self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)

                self.willHideTabbar()
                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.HideBar.rawValue), object: nil)
            }
        }
        if differenceFromStart > 0 && TabBarHidden.isTabBarHidden {
            TabBarHidden.isTabBarHidden = false
            self.isVisibleTab = true
            if(scrollView.isTracking && (abs(differenceFromLast)>0.20)) {
                let bottom : CGFloat = self.footerSection!.frame.height + 45.0
                self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, bottom, 0)
                self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, bottom, 0)
                
                self.willShowTabbar()
                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ShowBar.rawValue), object: nil)
            }
        }
    }

    
    override func willShowTabbar() {
        self.footerConstraint!.constant = 45.0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    override func willHideTabbar() {
        self.footerConstraint!.constant = 0.0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func reloadTableListUser(){
        
    }
    
    func didDisable(_ disaable:Bool,cell:DetailListViewCell) {
        let indexPath = self.tableView?.indexPath(for: cell)
        if disaable {
            self.selectedItems?.remove(cell.upcVal!)//(indexPath!.row)
        } else {
            self.selectedItems?.add(cell.upcVal!)//(indexPath!.row)
        }
        self.updateTotalLabel()
        if self.selectedItems != nil {
            self.tableView?.reloadRows(at: [IndexPath(row: (indexPath! as NSIndexPath).row, section: (indexPath! as NSIndexPath).section)], with: UITableViewRowAnimation.fade)
        }
    }
    
    
    func buildEditNameSection() {
        
        containerEditName = UIView()
        containerEditName?.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: 64)
        
        let separator = UIView(frame:CGRect(x: 0, y: containerEditName!.frame.height - AppDelegate.separatorHeigth(), width: self.view.frame.width, height: AppDelegate.separatorHeigth()))
        separator.backgroundColor = WMColor.light_light_gray
        
        self.nameField = FormFieldView()
        self.nameField!.maxLength = 100
        self.nameField!.delegate = self
        self.nameField!.typeField = .string
        self.nameField!.nameField = NSLocalizedString("list.search.placeholder",comment:"")
        self.nameField!.frame = CGRect(x: 16.0, y: 12.0, width: self.view.bounds.width - 32.0, height: 40.0)
        self.nameField!.text = listName
        
        containerEditName?.addSubview(separator)
        containerEditName?.addSubview(nameField!)
        self.view.addSubview(containerEditName!)
        containerEditName?.alpha = 0
        
    }
    
    
    func duplicate() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_DUPLICATE_LIST.rawValue , label: "")
        if UserCurrentSession.hasLoggedUser() {
            let service = GRUserListService()
            self.itemsUserList = service.retrieveUserList()
            if  self.itemsUserList!.count == 12{
                 self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
                alertView!.setMessage(NSLocalizedString("list.copy.inProcess", comment:""))
                self.alertView!.setMessage(NSLocalizedString("list.error.validation.max", comment: ""))
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            }else{
                self.invokeSaveListToDuplicateService(forListId: self.products!, andName: listName!, successDuplicateList: { () -> Void in
                    self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
                    self.alertView!.showDoneIcon()
                })
            }

        }else{
         NotificationCenter.default.post(name: Notification.Name(rawValue: "DUPLICATE_LIST"), object: nil)
        }
    }
    
    /**
     call service update name list
     */
    func updateListName() {
        if self.nameField?.text != self.titleLabel?.text {
            
            self.nameField?.resignFirstResponder()
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(NSLocalizedString("list.message.updatingListNames", comment:""))
            
            let service = GRUpdateListService()
            
            service.callService(service.buildParams(self.listId!, name: self.nameField!.text!),
                                successBlock: { (result:[String:Any]) -> Void in
                                    self.titleLabel?.text = self.nameField?.text
                                    self.reminderService!.updateListName(self.nameField!.text!)
                                    self.loadServiceItems({ () -> Void in
                                        self.alertView!.setMessage(NSLocalizedString("list.message.updatingListNamesDone", comment:""))
                                        self.alertView!.showDoneIcon()
                                    })
                },
                                errorBlock: { (error:NSError) -> Void in
                                    self.alertView!.setMessage(error.localizedDescription)
                                    self.alertView!.showErrorIcon("Ok")
            })
            
        }
    }
    
    /**
     return to listview where is empty view
     */
    func backEmpty() {
        super.back()
         BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS_DETAIL_EMPTY.rawValue, action:WMGAIUtils.ACTION_BACK_MY_LIST.rawValue, label: "")
    }

    override func back() {
        super.back()
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_BACK_MY_LIST.rawValue, label: "")
    }
    
    //MARK: - Reminder
    
    func setReminderSelected(_ selected:Bool){
        self.reminderButton?.isSelected = selected
        
        if selected{
            self.reminderButton?.setImage(UIImage(named: "reminder_full"), for: .selected)
        }else{
            self.reminderButton?.setImage(UIImage(named: "reminder"), for: UIControlState())
        }
    }
    
    func addReminder(){
        let selected = self.reminderButton!.isSelected
        let reminderViewController = ReminderViewController()
        reminderViewController.listId = self.listId!
        reminderViewController.listName = self.listName!
        reminderViewController.delegate = self
        if  selected {
            reminderViewController.reminderService?.findNotificationForCurrentList()
            reminderViewController.selectedPeriodicity = self.reminderService!.currentNotificationConfig!["type"] as? Int
            reminderViewController.currentOriginalFireDate = self.reminderService!.currentNotificationConfig!["originalFireDate"] as? Date
        }
        self.openDetailOrReminder =  true
        self.navigationController?.pushViewController(reminderViewController, animated: true)
    }
    
    func notifyReminderWillClose(forceValidation flag: Bool, value: Bool) {

        if self.reminderService!.existNotificationForCurrentList() || value{
            setReminderSelected(true)
        }else{
            setReminderSelected(false)
        }
        self.reminderService?.findNotificationForCurrentList()
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
            self.searchByTextAndCamfind(text, upcs: nil, searchContextType: .WithText,searchServiceFromContext:.FromSearchText )
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
                self.searchByTextAndCamfind(value!, upcs: upcs, searchContextType: .WithTextForCamFind,searchServiceFromContext: .fromSearchCamFind)
            }
        }
    }
    
    //MARK:  Actions
    func findProdutFromUpc(_ upc:String){
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.add.product.list", comment:""))
        
        let useSignalsService : [String:Any] = [String:Any](dictionary: ["signals" : GRBaseService.getUseSignalServices()])
        let svcValidate = ProductDetailService(dictionary: useSignalsService)
        
        let upcDesc : NSString = upc as NSString
        var paddedUPC = upcDesc
        if upcDesc.length < 13 {
            let toFill = "".padding(toLength: 13 - upcDesc.length, withPad: "0", startingAt: 0)
            paddedUPC = "\(toFill)\(paddedUPC)" as NSString
        }
        //let params = svcValidate.buildParams(paddedUPC as String, eventtype: "pdpview",stringSearching: "",position: "")//position
        let params = svcValidate.buildMustangParams(paddedUPC as String, skuId:paddedUPC as String )//TODO Enviar sku
        svcValidate.callService(requestParams:params, successBlock: { (result:[String:Any]) -> Void in
            //[["upc":paddedUPC,"description":keyWord,"type":ResultObjectType.Groceries.rawValue]]
            print("Correcto el producto es::::")
            self.invokeAddproductTolist(result,products: nil, succesBlock: { () -> Void in
                print("Se agrega correctamnete")
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
        }
        
        let productObject = response == nil ? [] : [service.buildProductObject(upc:upcAdd, quantity:1,pesable:isPesable,active:isActive)]
      
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
        self.alertView!.setMessage(NSLocalizedString("list.message.add.products.to.list", comment:""))
        
        let service = GRProductByTicket()
        service.callService(service.buildParams(ticket) as AnyObject,
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
                        products.append(service.buildItemMustang(upc, sku: "00750226892092_000897302", quantity: quantity))
                        //(service.buildProductObject(upc: upc, quantity: quantity,pesable:pesable,active:active))
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
            message = NSLocalizedString("list.message.write.word.search", comment: "")
        }
        if trimValidate.lengthOfBytes(using: String.Encoding.utf8) < 2 {
            message = NSLocalizedString("product.search.minimum",comment:"")
        }
        if !validateSearch(search)  {
           message = NSLocalizedString("field.validate.text", comment: "")
        }
        if search.lengthOfBytes(using: String.Encoding.utf8) > 50  {
            message = NSLocalizedString("list.message.validation.characters", comment: "")
        }
        return message
    }
    
    func validateSearch(_ toValidate:String) -> Bool{
        let regString : String = "^[A-Z0-9a-z._-ñÑÁáÉéÍíÓóÚú ]{0,100}$";
        return IPASearchView.validateRegEx(regString,toValidate:toValidate)
    }
    
    func tabBarActions(){
        if TabBarHidden.isTabBarHidden {
            self.willHideTabbar()
        }else{
            self.willShowTabbar()
        }
    }
    
}
