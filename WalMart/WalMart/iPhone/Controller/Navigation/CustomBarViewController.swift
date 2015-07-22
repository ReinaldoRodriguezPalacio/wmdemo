//
//  HomeViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/27/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

enum CustomBarNotification : String {
    case HideBar = "kCustomBarHideBarNotification"
    case ShowBar = "kCustomBarShowBarNotification"
    case ShowCategories = "kCustomBarCategoriesNotification"
    case ShowCartBadge = "kCustomBarShowCartBadgeNotification"
    case AddUPCToShopingCart = "kAddUPCToShopingCart"
    case AddItemsToShopingCart = "kAddItemsToShopingCart"
    case SuccessAddItemsToShopingCart = "kSuccessAddItemsToShopingCart"
    case ReloadWishList = "kReloadWishList"
    case UpdateBadge = "kUpdateBadge"
    case UserLogOut = "kUserLogOut"
    case UpdateShoppingCartBegin = "kUpdateShoppingCartBegin"
    case UpdateShoppingCartEnd = "kUpdateShoppingCartEnd"
    case ClearSearch = "kClearSearch"
    case HideBadge = "kHideBadge"
    case ShowBadge = "kShowBadge"
    case ShowHelp = "kShowHelp"
    case SuccessAddUpdateCommentCart = "kSuccessAddUpdateCommentCart"
    case ClearShoppingCartGR = "kClearShoppingCartGR"
    case ClearShoppingCartMG = "kClearShoppingCartMG"
    
}

struct TabBarHidden {
    static var isTabBarHidden : Bool = false
}


@objc protocol CustomBarDelegate {
    func customBarDidAnimate(hide:Bool, offset:CGFloat)
}

class CustomBarViewController: BaseController, UITabBarDelegate, ShoppingCartViewControllerDelegate, SearchViewControllerDelegate, UINavigationControllerDelegate {
    
    var buttonContainer: UIView? = nil
    @IBOutlet var container: UIView? = nil
    @IBOutlet weak var headerView: UIView!
    @IBOutlet var btnSearch: UIButton?
    @IBOutlet var btnShopping: UIButton?
    var badgeShoppingCart : BadgeView!
    var timmer : NSTimer? = nil
    
    
    var shoppingCartVC : UINavigationController!
    
    let TABBAR_HEIGHT: CGFloat = 45.0
    
    var currentController: UIViewController? = nil
    var searchController: SearchViewController? = nil
    var viewControllers: [UIViewController] = []
    var buttonList: [UIButton] = []
    var isTabBarHidden = false
    var isTabBarCreated = false
    var isShowingGroceriesView = true
    var lastIndexSelected : Int?  = 0
    var imageBlurView: UIImageView? = nil
    var imageLoadingCart: UIImageView!
    var openSearch = false
    var totuView : TutorialHelpView!
    //var viewSuper : IPOGroceriesView!
    
    var splashVC : IPOSplashViewController!
    
    @IBOutlet var viewLogo: UIImageView!
    //@IBOutlet var supperIndicator: UIImageView!
    
    var gestureCloseShoppingCart : UISwipeGestureRecognizer!
    
    var emptyGroceriesTap : Bool = false
    var emptyMgTap : Bool = false
    var updateAviable : UpdateViewController!
    
    
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
        }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideTabBar:", name: CustomBarNotification.HideBar.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showTabBar:", name: CustomBarNotification.ShowBar.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showCategories", name: CustomBarNotification.ShowCategories.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showCartBadge:", name: CustomBarNotification.ShowCartBadge.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addItemToShoppingCart:", name: CustomBarNotification.AddUPCToShopingCart.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addItemsToShoppingCart:", name: CustomBarNotification.AddItemsToShopingCart.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificaUpdateBadge:", name: CustomBarNotification.UpdateBadge.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLogOut:", name: CustomBarNotification.UserLogOut.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startUpdatingShoppingCart:", name: CustomBarNotification.UpdateShoppingCartBegin.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "endUpdatingShoppingCart:", name: CustomBarNotification.UpdateShoppingCartEnd.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearSearch", name: CustomBarNotification.ClearSearch.rawValue, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hidebadge", name: CustomBarNotification.HideBadge.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showbadge", name: CustomBarNotification.ShowBadge.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showHelp", name: CustomBarNotification.ShowHelp.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeShoppingCartEmptyGroceries", name: CustomBarNotification.ClearShoppingCartGR.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeShoppingCartEmptyMG", name: CustomBarNotification.ClearShoppingCartMG.rawValue, object: nil)
        
        
        self.isTabBarHidden = false
        
        buttonContainer = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, 45))
        self.view.addSubview(buttonContainer!)
        
        self.headerView.backgroundColor = WMColor.headerViewBgCollor
        self.buttonContainer!.backgroundColor = WMColor.tabBarBgColor
        self.btnSearch?.addTarget(self, action: "search:", forControlEvents: UIControlEvents.TouchUpInside)
        
        showBadge()
        
        self.createInstanceOfControllers()
        
        self.view.bringSubviewToFront(headerView)
        
        reviewHelp(false)
        
        let tapGestureLogo =  UITapGestureRecognizer(target: self, action: "logoTap")
        viewLogo.addGestureRecognizer(tapGestureLogo)
        
        splashVC = IPOSplashViewController()
        splashVC.didHideSplash = { () in
            self.splashVC = nil
            self.checkPrivaceNotice()
        }
        splashVC.validateVersion =  {(force:Bool) in
            self.updateAviable = UpdateViewController()
            self.updateAviable.setup()
            self.updateAviable.forceUpdate = force
            self.updateAviable.frame = self.view.bounds
            self.view.addSubview(self.updateAviable)
        }
        self.addChildViewController(splashVC)
        self.view.addSubview(splashVC.view)
        
        let storyboard = self.loadStoryboardDefinition()
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("shoppingCartVC") as? UINavigationController {
            shoppingCartVC = vc
            if let vcRoot = shoppingCartVC.viewControllers.first as? ShoppingCartViewController {
                vcRoot.delegate = self
            }
        }
        
        
        createTabBarButtons()
        
        gestureCloseShoppingCart = UISwipeGestureRecognizer(target: self, action: "closeShoppingCart")
        gestureCloseShoppingCart.direction = UISwipeGestureRecognizerDirection.Up
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        badgeShoppingCart.frame = CGRectMake(self.view.bounds.width - 30 , 20, 15, 15)
        if self.helpView != nil {
            self.helpView!.frame = CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height)
            if totuView != nil {
                totuView.frame = self.helpView!.bounds
            }
        }
        layoutButtons()
        self.setTabBarHidden(self.isTabBarHidden, animated: false, delegate:nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.setTabBarHidden(self.isTabBarHidden, animated: true, delegate:nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Check PrivaceNotice Dates
    func checkPrivaceNotice(){
        
        let sinceDate : NSDate = UserCurrentSession.sharedInstance().dateStart
        let untilDate : NSDate = UserCurrentSession.sharedInstance().dateEnd
        let version = UserCurrentSession.sharedInstance().version as String
        
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let nowDate = dateFormatter.dateFromString(dateFormatter.stringFromDate(date))
        
        var requiredAP : String! = ""
        if let param = self.retrieveParam(version) {
            requiredAP = param.value
        }
        
        if requiredAP != "true" {
            if untilDate.compare(nowDate!) == NSComparisonResult.OrderedDescending && sinceDate.compare(nowDate!) == NSComparisonResult.OrderedAscending {
                self.addOrUpdateParam(version, value: "false")
                var alertNot = IPAWMAlertViewController.showAlert(UIImage(named:"done"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"done"))
                alertNot?.showDoneIconWithoutClose()
                alertNot?.setMessage(NSLocalizedString("privace.notice.message", comment: ""))
                alertNot?.addActionButtonsWithCustomText(NSLocalizedString("update.later", comment: ""),
                    leftAction: { () -> Void in
                        let ale: ()? = alertNot?.close()
                    },
                    rightText: NSLocalizedString("noti.godetail", comment: ""),
                    rightAction: { () -> Void in
                        self.addOrUpdateParam(version, value: "true")
                        let ale: ()? = alertNot?.close()
                })
            }
        }
    }
    
    func retrieveParam(key:String) -> Param? {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let user = UserCurrentSession.sharedInstance().userSigned
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Param", inManagedObjectContext: context)
        if user != nil {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && user == %@", key, user!)
        }
        else {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && user == %@", key, NSNull())
        }
        var error: NSError? = nil
        var result = context.executeFetchRequest(fetchRequest, error: &error) as [Param]?
        var parameter: Param? = nil
        if result != nil && result!.count > 0 {
            parameter = result!.first
        }
        return parameter
    }
    
    func addOrUpdateParam(key:String, value:String) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        if let param = self.retrieveParam(key) {
            param.value = value
        }
        else {
            var param = NSEntityDescription.insertNewObjectForEntityForName("Param", inManagedObjectContext: context) as? Param
            if let user = UserCurrentSession.sharedInstance().userSigned {
                param!.user = user
            }
            param!.key = key
            param!.value = value
        }
        var error: NSError? = nil
        context.save(&error)
        if error != nil {
            println("error at save context: \(error!.localizedDescription)")
        }
    }
    
    // MARK: - Create buttons
    func createTabBarButtons() {
        if isTabBarCreated == false {
            isTabBarCreated = true
            var images = self.retrieveTabBarOptions()
            let space = (320 - (CGFloat(images.count) * TABBAR_HEIGHT))/6
            var x: CGFloat = ((self.view.bounds.width / 2) - (320 / 2))  + CGFloat(space)
            for image in images {
                var title = NSString(format: "tabbar.%@", image)
                title = NSLocalizedString(title, comment: "")
                var button = UIButton()
                button.setImage(UIImage(named: image), forState: .Normal)
                button.setImage(UIImage(named: NSString(format: "%@_active", image)), forState: .Selected)
                button.setImage(UIImage(named: NSString(format: "%@_active", image)), forState: .Highlighted)
                button.imageView!.contentMode =  UIViewContentMode.Center
                button.addTarget(self, action: "buttonSelected:", forControlEvents: .TouchUpInside)
                button.selected = image == "tabBar_home"
                button.frame = CGRectMake(x, 2, TABBAR_HEIGHT, TABBAR_HEIGHT)
                
                var spacing: CGFloat = 1.0 // the space between the image and text
                var imageSize: CGSize = button.imageView!.frame.size
                
                
                x = CGRectGetMaxX(button.frame) + space
                
                self.buttonContainer!.addSubview(button)
                self.buttonList.append(button)
            }
        }
        
    }
    
    func retrieveTabBarOptions() -> [String] {
        return ["tabBar_home", "tabBar_mg","tabBar_super", "tabBar_wishlist_list","tabBar_menu"]
    }
    func layoutButtons() {
        let space = (320 - (5 * TABBAR_HEIGHT))/6
        var x: CGFloat = ((self.view.bounds.width / 2) - (320 / 2))  + CGFloat(space)
        for button in  self.buttonList {
            button.frame = CGRectMake(x, 2, TABBAR_HEIGHT, TABBAR_HEIGHT)
            var spacing: CGFloat = 1.0 // the space between the image and text
            var imageSize: CGSize = button.imageView!.frame.size
            x = CGRectGetMaxX(button.frame) + space
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "homeEmbedSegue" {
            var controller = segue.destinationViewController as? UINavigationController
            self.viewControllers.append(controller!)
            controller?.delegate = self
            self.currentController = controller
        }
    }
    
    
    //MARK: -
    
    func buttonSelected(sender:UIButton) {
        
        WishlistService.shouldupdate = true
        if self.btnSearch!.selected {
            self.closeSearch(false,sender:sender)
        }
        else {
            var index = find(self.buttonList, sender)
            
            
            var controller = self.viewControllers[index!]
            if controller === self.currentController {
                if let navController = self.currentController as? UINavigationController {
                    navController.popToRootViewControllerAnimated(true)
                }
                return
            }
            
            for button in self.buttonList {
                button.selected = sender === button
            }
            
            self.displayContentController(controller)
            if self.currentController != nil  {
                self.hideContentController(self.currentController!)
            }
            
            self.currentController = controller
            
            self.btnSearch!.enabled = true
            self.btnShopping!.enabled = true
            self.btnSearch!.selected = false
            
        }
    }
    
    func createInstanceOfControllers() {
        let storyboard = self.loadStoryboardDefinition()
        
        //var   = "loginVC-profileItemVC" as String
        if UserCurrentSession.sharedInstance().userSigned != nil{
            //controllerProfile = "profileVC"
        }
        
        let controllerIdentifiers : [String] = ["categoriesVC","GRCategoriesVC" ,"userListsVC", "moreVC"]
        
        for item in controllerIdentifiers {
            let components = item.componentsSeparatedByString("-")
            let strController = components[0] as String
            if let vc = storyboard!.instantiateViewControllerWithIdentifier(strController) as? UIViewController {
                if let navVC = vc as? UINavigationController {
                    if let loginVC = navVC.viewControllers.first as? LoginController {
                        if components.count > 1 {
                            loginVC.controllerTo = components[1] as String
                        }
                    }
                }
                if let navController = vc as? UINavigationController {
                    navController.delegate = self
                }
                self.viewControllers.append(vc)
            }
        }
    }
    
    func displayContentController(content: UIViewController) {
        self.addChildViewController(content)
        content.view.frame = self.container!.bounds
        self.container!.addSubview(content.view)
        content.didMoveToParentViewController(self)
    }
    
    func hideContentController(content: UIViewController) {
        content.willMoveToParentViewController(nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }
    
    func setTabBarHidden(hidden:Bool, animated:Bool, delegate:CustomBarDelegate?) -> Void {
        
        let bounds: CGRect = self.view.frame
        if(hidden)
        {
            self.isTabBarHidden = true
            TabBarHidden.isTabBarHidden = true
            if(animated)
            {
                
                UIView.animateWithDuration(0.2, animations: {
                    self.buttonContainer!.frame = CGRectMake(self.buttonContainer!.frame.minX, self.view.frame.maxY,
                        self.buttonContainer!.frame.width, self.buttonContainer!.frame.height)
                    },
                    completion: {(value: Bool) in
                })
            }
            else
            {
                self.buttonContainer!.frame = CGRectMake(self.buttonContainer!.frame.minX, self.view.frame.maxY,
                    self.buttonContainer!.frame.width, self.buttonContainer!.frame.height)
            }
        }
        else {
            self.isTabBarHidden = false
            TabBarHidden.isTabBarHidden = false
            if(animated)
            {
                UIView.animateWithDuration(0.2, animations: {
                    self.buttonContainer!.frame = CGRectMake(self.buttonContainer!.frame.minX, self.view.frame.maxY - self.buttonContainer!.frame.height,self.buttonContainer!.frame.width, self.buttonContainer!.frame.height)
                    },
                    completion: {(value: Bool) in
                        if value {
                            UIView.animateWithDuration(0.2, delay: 0.0, options: .BeginFromCurrentState, animations: {
                                },
                                completion: {(value: Bool) in
                            })
                        }
                })
            }
            else
            {
                self.buttonContainer!.frame = CGRectMake(self.buttonContainer!.frame.minX, self.view.frame.maxY - self.buttonContainer!.frame.height,self.buttonContainer!.frame.width, self.buttonContainer!.frame.height)
            }
        }
        
    }
    
    func hideTabBar(notification:NSNotification) {
        self.setTabBarHidden(true, animated: true, delegate:notification.object as CustomBarDelegate?)
    }
    
    func showTabBar(notification:NSNotification) {
        self.setTabBarHidden(false, animated: true, delegate:notification.object as CustomBarDelegate?)
    }
    
    class func buildParamsUpdateShoppingCart(upc:String,desc:String,imageURL:String,price:String!,quantity:String,onHandInventory:String,pesable:String) -> [NSObject:AnyObject] {
        return ["upc":upc,"desc":desc,"imgUrl":imageURL,"price":price, "quantity":quantity,"onHandInventory":onHandInventory,"pesable":pesable]
    }
    
    class func buildParamsUpdateShoppingCart(upc:String,desc:String,imageURL:String,price:String!,quantity:String,onHandInventory:String,wishlist:Bool,type:String,pesable:String) -> [NSObject:AnyObject] {
        return ["upc":upc,"desc":desc,"imgUrl":imageURL,"price":price,"quantity":quantity,"onHandInventory":onHandInventory,"wishlist":wishlist,"pesable":pesable]
        
    }
    
    class func buildParamsUpdateShoppingCart(upc:String,desc:String,imageURL:String,price:String!,quantity:String,comments:String,onHandInventory:String,type:String,pesable:String) -> [NSObject:AnyObject] {
        return
            ["upc":upc,"desc":desc,"imgUrl":imageURL,"price":price,"quantity":quantity,"comments":comments,"onHandInventory":onHandInventory,"wishlist":false,"type":type,"pesable":pesable]
    }
    
    class func buildParamsUpdateShoppingCart(upc:String,desc:String,imageURL:String,price:String!,quantity:String,onHandInventory:String,pesable:String, type:String ) -> [NSObject:AnyObject] {
        return ["upc":upc,"desc":desc,"imgUrl":imageURL,"price":price, "quantity":quantity,"onHandInventory":onHandInventory,"pesable":pesable, "type" : type]
    }
    
    
    func addItemToShoppingCart(notification:NSNotification){
        let addShopping = ShoppingCartUpdateController()
        if !btnShopping!.selected {
            addShopping.goToShoppingCart = {() in
                self.showShoppingCart(self.btnShopping!)
            }
        }
        let params = notification.userInfo as [String:AnyObject]
        
        addShopping.params = params
        let type = params["type"] as? String
        if type == nil {
            addShopping.typeProduct = ResultObjectType.Mg
        }
        else {
            addShopping.typeProduct = (type == ResultObjectType.Mg.rawValue ? ResultObjectType.Mg : ResultObjectType.Groceries)
        }
        self.addChildViewController(addShopping)
        addShopping.view.frame = self.view.bounds
        self.view.addSubview(addShopping.view)
        addShopping.didMoveToParentViewController(self)
        addShopping.startAddingToShoppingCart()
    }
    
    
    
    func addItemsToShoppingCart(notification:NSNotification) {
        let addShopping = ShoppingCartUpdateController()
        
        let params = notification.userInfo as [String:AnyObject]
        let type = params["type"] as? String
        if type == nil {
            addShopping.typeProduct = ResultObjectType.Mg
        }
        else {
            addShopping.typeProduct = (type == ResultObjectType.Mg.rawValue ? ResultObjectType.Mg : ResultObjectType.Groceries)
        }
        
        addShopping.goToShoppingCart = {() in
            self.showShoppingCart(self.btnShopping!)
        }
        addShopping.multipleItems = notification.userInfo as? [String:AnyObject]
        self.addChildViewController(addShopping)
        addShopping.view.frame = self.view.bounds
        self.view.addSubview(addShopping.view)
        addShopping.didMoveToParentViewController(self)
        addShopping.startAddingToShoppingCart()
    }
    
    func search(btn: UIButton){
        openSearch = false
        if (!btn.selected){
            if (self.btnShopping!.selected){
                self.closeShoppingCart()
            }
            else{
                self.clearSearch()
                self.openSearchProduct()
            }
        }
        else{
            self.closeSearch(false, sender: nil)
        }
    }
    
    func openSearchProduct(){
        if let navController = self.currentController! as? UINavigationController {
            
            if self.searchController == nil  {
                
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_HOME.rawValue, action: WMGAIUtils.EVENT_SEARCHPRESS.rawValue, label: "", value: nil).build())
                }
                
                if self.imageBlurView != nil {
                    self.imageBlurView?.removeFromSuperview()
                }
                
                self.imageBlurView = nil
                
                self.view.bringSubviewToFront(headerView!)
                container!.clipsToBounds = true
                
                self.btnSearch!.enabled = false
                self.btnShopping!.enabled = false
                //let current = navController.viewControllers.last as? UIViewController
                let current = self.currentController!
                self.searchController = SearchViewController()
                current.addChildViewController(self.searchController!)
                self.searchController!.delegate = self
                //            self.searchController!.view.frame = CGRectMake(0,-90, current.view.frame.width, current.view.frame.height)
                self.searchController!.view.frame = CGRectMake(0,current.view.frame.height * -1, current.view.frame.width, current.view.frame.height)
                self.searchController!.clearSearch()
                self.imageBlurView = self.searchController?.generateBlurImage()
                current.view.addSubview(self.imageBlurView!)
                current.view.addSubview(self.searchController!.view)
                
                ///
                //            self.searchController!.viewBackground!.alpha = 0
                //            self.searchController!.camButton!.alpha = 0
                //            self.searchController!.camLabel!.alpha = 0
                //            self.searchController!.scanButton!.alpha = 0
                //            self.searchController!.scanLabel!.alpha = 0
                
                UIView.animateWithDuration(0.6, animations: {() in
                    self.searchController!.view.frame = CGRectMake(0,0, current.view.frame.width, current.view.frame.height)
                    self.btnSearch?.setImage(UIImage(named: "close"), forState:  UIControlState.Normal)
                    }, completion: {(bool : Bool) in
                        if bool {
                            self.btnSearch!.enabled = true
                            self.btnShopping!.enabled = true
                            self.btnSearch!.selected = true
                            self.searchController?.field!.becomeFirstResponder()
                            //                        self.showHelpViewForSearchIfNeeded(current)
                            
                            self.view.sendSubviewToBack(self.headerView!)
                            self.container!.clipsToBounds = false
                            
                            //
                            //                        UIView.animateWithDuration(0.6, animations: {() in
                            //                            self.searchController!.viewBackground!.alpha = 1
                            //                            self.searchController!.camButton!.alpha = 1
                            //                            self.searchController!.camLabel!.alpha = 1
                            //                            self.searchController!.scanButton!.alpha = 1
                            //                            self.searchController!.scanLabel!.alpha = 1
                            //                        })
                        }
                })
                
            }
            
        }
    }
    
    var helpView: UIView?
    
    func showHelpViewForSearchIfNeeded(controller:UIViewController) {
        var requiredHelp = true
        if let param = self.retrieveParam("searchHelp") {
            requiredHelp = !(param.value == "false")
        }
        
        if requiredHelp && self.helpView == nil {
            let bounds = controller.view.bounds
            
            self.helpView = UIView(frame: CGRectMake(0.0, 0.0, bounds.width, bounds.height))
            self.helpView!.backgroundColor = WMColor.UIColorFromRGB(0x000000, alpha: 0.70)
            self.helpView!.alpha = 0.0
            self.helpView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "removeHelpForSearchView"))
            controller.view.addSubview(self.helpView!)
            
            var icon = UIImageView(image: UIImage(named: "search_scan_help"))
            icon.frame = CGRectMake(189.0, 11.0, 55.0, 48.0)
            self.helpView!.addSubview(icon)
            
            var arrow = UIImageView(image: UIImage(named: "search_scan_arrow_help"))
            arrow.frame = CGRectMake(icon.center.x - 75.0, icon.frame.maxY, 80.0, 36.0)
            self.helpView!.addSubview(arrow)
            
            var message = UILabel(frame: CGRectMake(16.0, arrow.frame.maxY, self.view.bounds.width - 88.0, 40.0))
            message.numberOfLines = 0
            message.textColor = UIColor.whiteColor()
            message.textAlignment = .Center
            message.font = WMFont.fontMyriadProRegularOfSize(16.0)
            message.text = NSLocalizedString("product.search.scann.help", comment:"")
            self.helpView!.addSubview(message)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.helpView!.alpha = 1.0
                self.addOrUpdateParam("searchHelp", value: "false")
            })
        }
        else {
            self.searchController?.field!.becomeFirstResponder()
        }
    }
    
    func removeHelpForSearchView() {
        if self.helpView != nil {
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.helpView!.alpha = 0.0
                },
                completion: { (finished:Bool) -> Void in
                    if finished {
                        self.helpView!.removeFromSuperview()
                        self.helpView = nil
                        //self.addOrUpdateParam("searchHelp", value: "false")
                        self.searchController?.field!.becomeFirstResponder()
                    }
                }
            )
        }
    }
    
    //MARK: - SearchViewControllerDelegate
    func closeSearch(addShoping:Bool, sender:UIButton?) {
        self.view.bringSubviewToFront(headerView!)
        container!.clipsToBounds = true
        if self.searchController != nil {
            self.btnSearch!.enabled = false
            self.btnShopping!.enabled = false
            self.searchController!.table.backgroundColor = UIColor.whiteColor()
            self.searchController!.table.alpha = 0.6
            self.searchController!.viewTapClose?.backgroundColor = UIColor.clearColor()
            
            UIView.animateWithDuration(0.6,
                animations: {
                    self.helpView?.alpha = 0.0
                    self.searchController!.view.frame = CGRectMake(self.container!.frame.minX, -1 * (self.container!.frame.height + self.buttonContainer!.frame.height), self.container!.frame.width, self.container!.frame.height + self.buttonContainer!.frame.height)
                    self.btnSearch?.setImage(UIImage(named: "navBar_search"), forState:  UIControlState.Normal)
                    
                    let param = self.searchController!.field!.resignFirstResponder()
                },
                completion: {(bool : Bool) in
                    if bool {
                        self.helpView?.removeFromSuperview()
                        self.helpView = nil
                        self.clearSearch()
                        if addShoping {
                            self.addtoShopingCar()
                        }
                        if sender != nil {
                            self.buttonSelected(sender!)
                        }
                    }
                }
            )
        }
    }
    
    func selectKeyWord(keyWord:String, upc:String?, truncate:Bool ){
        if upc != nil {
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_HOME.rawValue, action: WMGAIUtils.EVENT_SEARCHACTION.rawValue, label: upc, value: nil).build())
            }
            
            
            let controller = ProductDetailPageViewController()
            let svcValidate = GRProductDetailService()
            let upcDesc : NSString = upc! as NSString
            var paddedUPC = upcDesc
            if upcDesc.length < 13 {
                let toFill = "".stringByPaddingToLength(13 - upcDesc.length, withString: "0", startingAtIndex: 0)
                paddedUPC = "\(toFill)\(paddedUPC)"
            }
            svcValidate.callService(paddedUPC, successBlock: { (result:NSDictionary) -> Void in
                controller.itemsToShow = [["upc":paddedUPC,"description":keyWord,"type":ResultObjectType.Groceries.rawValue]]
                var controllernav = self.currentController as? UINavigationController
                controllernav?.pushViewController(controller, animated: true)
                
                }, errorBlock: { (error:NSError) -> Void in
                    
                    if upcDesc.length < 14 {
                        let toFill = "".stringByPaddingToLength(14 - upcDesc.length, withString: "0", startingAtIndex: 0)
                        paddedUPC = "\(toFill)\(upcDesc)"
                    }
                    
                    controller.itemsToShow = [["upc":paddedUPC,"description":keyWord,"type":ResultObjectType.Mg.rawValue]]
                    var controllernav = self.currentController as? UINavigationController
                    controllernav?.pushViewController(controller, animated: true)
            })
        }
        else{
            
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_HOME.rawValue, action: WMGAIUtils.EVENT_SEARCHACTION.rawValue, label: keyWord, value: nil).build())
            }
            
            let controller = SearchProductViewController()
            controller.searchContextType = .WithText
            controller.titleHeader = keyWord
            controller.textToSearch = keyWord
            var controllernav = self.currentController as? UINavigationController
            controllernav?.pushViewController(controller, animated: true)
        }
        self.btnSearch!.selected = true
    }
    
    
    
    func showProducts(forDepartmentId depto: String?, andFamilyId family: String?, andLineId line: String?, andTitleHeader title:String , andSearchContextType searchContextType:SearchServiceContextType){
        let controller = SearchProductViewController()
        controller.searchContextType = searchContextType
        controller.idFamily  = family == nil ? "_" :  family
        controller.idDepartment = depto == nil ? "_" :  depto
        controller.idLine = line == nil ? "_" :  line
        controller.titleHeader = title
        var controllernav = self.currentController as? UINavigationController
        controllernav?.pushViewController(controller, animated: true)
        self.btnSearch!.selected = false
    }
    
    func navigationController(navigationController: UINavigationController!, didShowViewController viewController: UIViewController!, animated: Bool) {
        self.btnSearch!.selected =  false
        //self.clearSearch()
    }
    
    func clearSearch() {
        self.view.bringSubviewToFront(headerView!)
        container!.clipsToBounds = true
        if self.searchController != nil{
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    if self.imageBlurView != nil {
                        self.imageBlurView!.alpha = 0.0
                    }
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        if self.imageBlurView != nil {
                            self.imageBlurView?.removeFromSuperview()
                        }
                        self.imageBlurView = nil
                    }
                }
            )
            
            self.searchController!.willMoveToParentViewController(nil)
            self.searchController!.view.removeFromSuperview()
            self.searchController!.removeFromParentViewController()
            self.searchController = nil
            self.btnSearch!.enabled = true
            self.btnShopping!.enabled = true
            self.btnSearch!.selected = false
        }
    }
    
    
    func navigationController(navigationController: UINavigationController!, willShowViewController viewController: UIViewController!, animated: Bool) {
    }
    
    func searchControllerScanButtonClicked(controller: BarCodeViewControllerDelegate!) {
        let barCodeController = BarCodeViewController()
        barCodeController.delegate = controller
        self.presentViewController(barCodeController, animated: true, completion: nil)
    }
    
    func searchControllerCamButtonClicked(controller: CameraViewControllerDelegate!) {
        let cameraController = CameraViewController()
        cameraController.delegate = controller
        self.presentViewController(cameraController, animated: true, completion: nil)
    }
    
    func closeShoppingCartEmptyGroceries() {
        self.emptyGroceriesTap  = true
        self.closeShoppingCart()
    }
    
    func closeShoppingCartEmptyMG() {
        self.emptyMgTap  = true
        self.closeShoppingCart()
    }
    
    func closeShoppingCart() {
        if let vcRoot = shoppingCartVC.viewControllers.first as? PreShoppingCartViewController {
            vcRoot.delegate = self
            vcRoot.closeShoppingCart()
            vcRoot.view.removeGestureRecognizer(gestureCloseShoppingCart)
            openSearch = false
        }
        if let vcRoot = shoppingCartVC.viewControllers.first as? IPAPreShoppingCartViewController {
            vcRoot.delegate = self
            vcRoot.closeShoppingCart()
            vcRoot.view.removeGestureRecognizer(gestureCloseShoppingCart)
            openSearch = false
        }
    }
    
    func showShoppingCart(sender:UIButton,closeIfNeedded:Bool) {
        if shoppingCartVC != nil {
            if (!sender.selected){
                ShoppingCartService.shouldupdate = true
                if (self.btnSearch!.selected)  {
                    self.closeSearch(true, sender:nil)
                }else{
                    self.addtoShopingCar()
                }
                sender.selected = !sender.selected
            }
            else {
                if closeIfNeedded {
                    self.closeShoppingCart()
                }
            }
        }
        
    }
    
    @IBAction func showShoppingCart(sender:UIButton) {
        self.showShoppingCart(sender,closeIfNeedded:true)
    }
    
    func addtoShopingCar(){
        
        self.addChildViewController(shoppingCartVC)
        shoppingCartVC.view.frame = self.container!.frame
        self.view.addSubview(shoppingCartVC.view)
        self.view.bringSubviewToFront(self.headerView)
        shoppingCartVC.didMoveToParentViewController(self)
        if let vcRoot = shoppingCartVC.viewControllers.first as? PreShoppingCartViewController {
            vcRoot.delegate = self
            self.btnShopping?.userInteractionEnabled = false
            vcRoot.finishAnimation = {() -> Void in
                println("")
                vcRoot.view.addGestureRecognizer(self.gestureCloseShoppingCart)
                self.btnShopping?.userInteractionEnabled = true
            }
            vcRoot.openShoppingCart()
        }
        //self.view.endEditing(true)
    }
    
    
    func returnToView() {
        if shoppingCartVC != nil {
            self.btnShopping!.selected = false
            shoppingCartVC.removeFromParentViewController()
            shoppingCartVC.view.removeFromSuperview()
            self.btnShopping?.userInteractionEnabled = true
            if (openSearch){
                self.openSearchProduct()
                openSearch = false
            }
        }
        //Tap on Groceries Cart Empty
        if self.emptyGroceriesTap {
            buttonSelected(self.buttonList[3])
            if let navController = self.currentController as? UINavigationController {
                navController.popToRootViewControllerAnimated(false)
                if let categoriesVC = navController.viewControllers.first as? IPOCategoriesViewController {
                    if categoriesVC.currentIndexSelected  != nil {
                        categoriesVC.closeSelectedDepartment()
                    }
                }
            }
        }
        //Tap on MG Cart Empty
        if self.emptyMgTap {
            buttonSelected(self.buttonList[1])
            if let navController = self.currentController as? UINavigationController {
                navController.popToRootViewControllerAnimated(false)
                if let categoriesVC = navController.viewControllers.first as? IPOCategoriesViewController {
                    if categoriesVC.currentIndexSelected  != nil {
                        categoriesVC.closeSelectedDepartment()
                    }
                }
            }
        }
        
        self.emptyMgTap  = false
        self.emptyGroceriesTap  = false
    }
    
    
    func showBadge() {
        if badgeShoppingCart == nil {
            badgeShoppingCart = BadgeView(frame: CGRectMake(self.view.bounds.width - 30 , 20, 15, 15))
            self.headerView.addSubview(badgeShoppingCart)
        }
    }
    
    func notificaUpdateBadge(notification:NSNotification){
        if notification.object != nil {
            let params = notification.object as NSDictionary
            let number = params["quantity"] as Int!
            updateBadge(number)
            self.endUpdatingShoppingCart(notification)
        }
    }
    
    func updateBadge(numProducts:Int) {
        dispatch_async(dispatch_get_main_queue(),{
            self.badgeShoppingCart.updateTitle(numProducts)
            self.badgeShoppingCart.frame = CGRectMake(self.view.bounds.width - 30 , 20, 15, 15)
        });
    }
    
    func userLogOut(not:NSNotification) {
        self.removeAllCookies()
        self.buttonSelected(self.buttonList[0])
    }
    
    func removeAllCookies() {
        var storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        var cookies = storage.cookiesForURL(NSURL(string: "https://www.walmart.com.mx")!)
        for var idx = 0; idx < cookies!.count; idx++ {
            var cookie = cookies![idx] as NSHTTPCookie
            storage.deleteCookie(cookie)
        }
        cookies =   storage.cookiesForURL(NSURL(string: "https://www.aclaraciones.com.mx")!)
        for var idx = 0; idx < cookies!.count; idx++ {
            var cookie = cookies![idx] as NSHTTPCookie
            storage.deleteCookie(cookie)
        }
    }
    
    func startUpdatingShoppingCart(sender:AnyObject) {
        self.badgeShoppingCart.hidden = true
        if imageLoadingCart == nil {
            let imageLoading = UIImage(named:"waiting_cart")
            imageLoadingCart = UIImageView(frame:CGRectMake(self.btnShopping!.frame.minX + 15.5 , self.btnShopping!.frame.minY + 4, imageLoading!.size.width, imageLoading!.size.height))
            imageLoadingCart.image  = imageLoading
            imageLoadingCart.hidden = true
            imageLoadingCart.center = self.btnShopping!.center
            self.headerView.addSubview(imageLoadingCart)
            runSpinAnimationOnView(imageLoadingCart, duration: 100, rotations: 1, repeat: 100)
            
        }
    }
    
    func endUpdatingShoppingCart(sender:AnyObject) {
        self.badgeShoppingCart.hidden = false
        self.showBadge()
        if self.imageLoadingCart != nil {
            self.imageLoadingCart.layer.removeAllAnimations()
            self.imageLoadingCart.removeFromSuperview()
            self.imageLoadingCart = nil
        }
    }
    
    func runSpinAnimationOnView(view:UIView,duration:CGFloat,rotations:CGFloat,repeat:CGFloat) {
        var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = Float(repeat)
        
        view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
        
        if self.imageLoadingCart != nil {
            imageLoadingCart.hidden = false
        }
    }
    
    //MARK: Before adding groceries
    /*func apearSuperView (){
    isShowingGroceriesView = true
    supperIndicator.image = UIImage(named: "home_switch_On")
    if timmer != nil {
    timmer?.invalidate()
    timmer = nil
    }
    
    self.viewSuper.generateBlurImageWithView(self.currentController?.view)
    UIView.animateWithDuration(0.5, animations: { () -> Void in
    self.viewSuper.frame = CGRectMake(0,self.headerView.frame.maxY, self.viewSuper.frame.width, self.viewSuper.frame.height)
    }) { (complete:Bool) -> Void in
    
    }
    
    
    }
    
    func disapearSuperView (){
    isShowingGroceriesView = false
    supperIndicator.image = UIImage(named: "home_switch_Off")
    if timmer != nil {
    timmer?.invalidate()
    timmer = nil
    }
    UIView.animateWithDuration(0.5, animations: { () -> Void in
    self.viewSuper.frame = CGRectMake(0,-self.viewSuper.frame.height, self.viewSuper.frame.width, self.viewSuper.frame.height)
    }) { (complete:Bool) -> Void in
    
    }
    }
    
    func initViewSuper(){
    viewSuper = IPOGroceriesView(frame: CGRectMake(0, self.headerView.frame.maxY, self.view.bounds.width, 48))
    self.view.addSubview(viewSuper)
    }
    */
    
    func logoTap(){
        self.buttonSelected(self.buttonList[0])
        self.closeShoppingCart()
    }
    
    func hidebadge() {
        self.badgeShoppingCart.hidden = true
    }
    
    func showbadge() {
        self.badgeShoppingCart.hidden = false
    }
    
    
    
    func handleNotification(type:String,name:String,value:String) {
        let trimValue = value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if type != "CF" {
            if btnShopping!.selected {
                closeShoppingCart()
                btnShopping!.selected = !btnShopping!.selected
            }
        }
        
        //TODO: Es necesario ver el manejo de groceries para las notificaciones.
        switch(type.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) {
        case "": self.buttonSelected(self.buttonList[0])
        case "UPC": self.selectKeyWord("", upc:trimValue, truncate:true)
        case "TXT": self.selectKeyWord(trimValue, upc:nil, truncate:true)
        case "LIN": self.showProducts(forDepartmentId: nil, andFamilyId: nil,andLineId: trimValue, andTitleHeader:"Recomendados" , andSearchContextType:.WithCategoryForMG )
        case "FAM": self.showProducts(forDepartmentId: nil, andFamilyId:trimValue, andLineId: nil, andTitleHeader:"Recomendados" , andSearchContextType:.WithCategoryForMG)
        case "CAT": self.showProducts(forDepartmentId: trimValue, andFamilyId:nil, andLineId: nil, andTitleHeader:"Recomendados" , andSearchContextType:.WithCategoryForMG)
        case "CF": self.showShoppingCart(self.btnShopping!,closeIfNeedded: false)
        case "WF": self.buttonSelected(self.buttonList[2])
        default: println("No value type for notification")
        }
        
        
    }
    
    
    //GRA: Help Validation
    func reviewHelp(force:Bool) {
        var requiredHelp = true
        if let param = self.retrieveParam("mainHelp") {
            requiredHelp = !(param.value == "false")
        }
        
        if (requiredHelp && self.helpView == nil ) || force {
            let bounds = self.view.bounds
            
            self.helpView = UIView(frame: CGRectMake(0.0, 0.0, bounds.width, bounds.height))
            self.helpView!.backgroundColor = WMColor.light_blue
            self.helpView!.alpha = 0.0
            
            self.view.addSubview(self.helpView!)
            
            
            let imageArray = [["image":"ahora_todo_walmart","details":NSLocalizedString("help.walmart.nowallWM",comment:"")],["image":"busca_por_codigo","details":NSLocalizedString("help.walmart.search",comment:"")],["image":"consulta_pedidos_articulos","details":NSLocalizedString("help.walmart.backup",comment:"")],["image":"haz_una_lista","details":NSLocalizedString("help.walmart.list",comment:"")]]
            totuView = TutorialHelpView(frame: self.helpView!.bounds, properties: imageArray)
            totuView.onClose = {() in
                self.removeHelpForSearchView()
                self.addOrUpdateParam("mainHelp", value: "false")
            }
            helpView?.addSubview(totuView)
            
            
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.helpView!.alpha = 1.0
            })
        }
        
        
    }
    
    func showHelp() {
        reviewHelp(true)
    }
    
    
    
    
}