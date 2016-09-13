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
    case AddUPCToShopingCart = "kAddUPCToShopingCart"
    case AddItemsToShopingCart = "kAddItemsToShopingCart"
    case SuccessAddItemsToShopingCart = "kSuccessAddItemsToShopingCart"
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
    case EditSearch = "kEditSearch"
    case CamFindSearch = "kCamFindSearch"
    case ScanBarCode = "kScanBarcode"
    case UpdateNotificationBadge = "kUpdateNotificationBadge"
    
    case ShowGRLists = "kShowGRLists"
    case TapBarFinish = "kTapBarFinish"
    case ShowHomeSelected = "kShowHomeSelected"
    case CloseShoppingCart = "KCloseShoppingCart"
    
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
    var btnCloseShopping: UIButton?
    
    var badgeShoppingCart : BadgeView!
    var badgeNotification: BadgeView!
    var timmer : NSTimer? = nil
    var idListSelected = ""
    
    
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
    var totuView : TutorialHelpView?
    //var viewSuper : IPOGroceriesView!
    
    var splashVC : IPOSplashViewController!
    
    @IBOutlet var viewLogo: UIImageView!
    //@IBOutlet var supperIndicator: UIImageView!
    
    var gestureCloseShoppingCart : UISwipeGestureRecognizer!
    
    var emptyGroceriesTap : Bool = false
    var emptyMgTap : Bool = false
    var updateAviable : UpdateViewController!
    var isEditingSearch: Bool = false
    
    var waitToSplash = false
    var contextSearch : SearchServiceContextType!
    var showHelpHome: Bool = false
    
    
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
        }()
    
    
    override func getScreenGAIName() -> String {
        return "SCREEN_SPLASHLOADAPP"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.hideTabBar(_:)), name: CustomBarNotification.HideBar.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.showTabBar(_:)), name: CustomBarNotification.ShowBar.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.addItemToShoppingCart(_:)), name: CustomBarNotification.AddUPCToShopingCart.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.addItemsToShoppingCart(_:)), name: CustomBarNotification.AddItemsToShopingCart.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.notificaUpdateBadge(_:)), name: CustomBarNotification.UpdateBadge.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.userLogOut(_:)), name: CustomBarNotification.UserLogOut.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.startUpdatingShoppingCart(_:)), name: CustomBarNotification.UpdateShoppingCartBegin.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.endUpdatingShoppingCart(_:)), name: CustomBarNotification.UpdateShoppingCartEnd.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.clearSearch), name: CustomBarNotification.ClearSearch.rawValue, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.hidebadge), name: CustomBarNotification.HideBadge.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.showbadge), name: CustomBarNotification.ShowBadge.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.showHelp), name: CustomBarNotification.ShowHelp.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.closeShoppingCartEmptyGroceries), name: CustomBarNotification.ClearShoppingCartGR.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.closeShoppingCartEmptyMG), name: CustomBarNotification.ClearShoppingCartMG.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.editSearch(_:)), name: CustomBarNotification.EditSearch.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.showListsGR), name: CustomBarNotification.ShowGRLists.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.camFindSearch(_:)), name: CustomBarNotification.CamFindSearch.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.scanBarcode(_:)), name: CustomBarNotification.ScanBarCode.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.updateNotificationBadge), name: CustomBarNotification.UpdateNotificationBadge.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomBarViewController.closeShoppingCart), name: CustomBarNotification.CloseShoppingCart.rawValue, object: nil)
        
        
        
        
        self.isTabBarHidden = false
        
        buttonContainer = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, 45))
        self.view.addSubview(buttonContainer!)
        
        self.headerView.backgroundColor = WMColor.light_blue
        self.buttonContainer!.backgroundColor = WMColor.light_blue
        self.btnSearch?.addTarget(self, action: #selector(CustomBarViewController.search(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        showBadge()
        
        self.createInstanceOfControllers()
        
        self.view.bringSubviewToFront(headerView)
        
        let showTutorial = self.reviewHelp(false)
        
        let tapGestureLogo =  UITapGestureRecognizer(target: self, action: #selector(CustomBarViewController.logoTap))
        viewLogo.addGestureRecognizer(tapGestureLogo)
        splashVC = IPOSplashViewController()
        splashVC.didHideSplash = { () in
            if !showTutorial {
                self.showHelpHomeView()
            }
            if self.waitToSplash {
                self.openSearchProduct()
            }
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
        
        
        
        createTabBarButtons()
        
        gestureCloseShoppingCart = UISwipeGestureRecognizer(target: self, action: #selector(CustomBarViewController.closeShoppingCart))
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
                totuView!.frame = self.helpView!.bounds
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
    /**
     Validate if present privace notice, find param in db and valid date
     */
    func checkPrivaceNotice(){
        
        let sinceDate : NSDate = UserCurrentSession.sharedInstance().dateStart
        let untilDate : NSDate = UserCurrentSession.sharedInstance().dateEnd
        let version = UserCurrentSession.sharedInstance().version as String
        
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let nowDate = dateFormatter.dateFromString(dateFormatter.stringFromDate(date))
        
        var requiredAP : String! = ""
        if let param = CustomBarViewController.retrieveParam(version) {
            requiredAP = param.value
        }
        
        if requiredAP != "true" {
            if (untilDate.compare(nowDate!) == NSComparisonResult.OrderedDescending && sinceDate.compare(nowDate!) == NSComparisonResult.OrderedAscending) || untilDate.compare(nowDate!) == NSComparisonResult.OrderedSame || sinceDate.compare(nowDate!) == NSComparisonResult.OrderedSame {
                CustomBarViewController.addOrUpdateParam(version, value: "false")
                let alertNot = IPAWMAlertViewController.showAlert(UIImage(named:"done"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"done"))
                alertNot?.showDoneIconWithoutClose()
                alertNot?.setMessage(NSLocalizedString("privace.notice.message", comment: ""))
                alertNot?.addActionButtonsWithCustomText(NSLocalizedString("update.later", comment: ""),
                    leftAction: { () -> Void in
                         alertNot?.close()
                    },
                    rightText: NSLocalizedString("noti.godetail", comment: ""),
                    rightAction: { () -> Void in
                        
                        let controllerToGo = PrivacyViewController()
                        if let navController = self.currentController as? UINavigationController {
                            navController.pushViewController(controllerToGo, animated: true)
                        }
                        
                        CustomBarViewController.addOrUpdateParam(version, value: "true")
                        alertNot?.close()
                },isNewFrame: false)
            }
        }
    }
    
    static func retrieveParam(key:String) -> Param? {
        return self.retrieveParam(key, forUser: true)
    }
    
    
    /**
     Find param for key and use user to validate query
     
     - parameter key:     param to seacrh
     - parameter forUser: use user in query
     
     - returns: param entity
     */
    static func retrieveParam(key:String, forUser: Bool) -> Param? {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let user = UserCurrentSession.sharedInstance().userSigned
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Param", inManagedObjectContext: context)
        if user != nil && forUser {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && user == %@", key, user!)
        }
        else {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && user == %@", key, NSNull())
        }
        var parameter: Param? = nil
        
        do {
            let result = try context.executeFetchRequest(fetchRequest) as! [Param]
            if  result.count > 0 {
                parameter = result.first
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        return parameter
    }
    
    static func addOrUpdateParam(key:String, value:String){
        self.addOrUpdateParam(key, value: value, forUser: true)
    }
    
    
    /**
     Add or update params in data base
     
     - parameter key:     indentifier param
     - parameter value:   value of pamam
     - parameter forUser: valid if use User in query
     */
    static func addOrUpdateParam(key:String, value:String, forUser:Bool) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        if let param = self.retrieveParam(key,forUser: forUser) {
            param.value = value
        }
        else {
            let param = NSEntityDescription.insertNewObjectForEntityForName("Param", inManagedObjectContext: context) as? Param
            if let user = UserCurrentSession.sharedInstance().userSigned {
                if forUser {
                    param!.user = user
                }
            }
            param!.key = key
            param!.value = value
            param!.idUser = ""
        }
        var error: NSError? = nil
        do {
            try context.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            print("error at save context: \(error!.localizedDescription)")
        }
    }
    
    
    
    /**
        Find param in db by iduser an key
     
     - parameter key: key value
     
     - returns: param entity
     */
    static func retrieveRateParam(key:String) -> Param? {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        
        let user = UserCurrentSession.sharedInstance().userSigned
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Param", inManagedObjectContext: context)
        if user != nil {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && idUser == %@", key, user!.idUser)
        }
      
        var parameter: Param? = nil
        
        do {
            let result = try context.executeFetchRequest(fetchRequest) as! [Param]
            if  result.count > 0 {
                parameter = result.first
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        return parameter
    }
    
    /**
     add param from review app
     
     - parameter key:   key param
     - parameter value: value of params
     */
    static func addRateParam(key:String, value:String) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        if let param = self.retrieveRateParam(key) {
            param.value = value
        }
        else {
            let param = NSEntityDescription.insertNewObjectForEntityForName("Param", inManagedObjectContext: context) as? Param
            if let user = UserCurrentSession.sharedInstance().userSigned {
                param!.user = user
                param!.idUser = user.idUser as String
            }
            param!.key = key
            param!.value = value
        }
        
        
        var error: NSError? = nil
        do {
            try context.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            print("error at save context: \(error!.localizedDescription)")
        }
    }
    
    
    // MARK: - Create buttons
    func createTabBarButtons() {
        if isTabBarCreated == false {
            isTabBarCreated = true
            let images = self.retrieveTabBarOptions()
            let space = (320 - (CGFloat(images.count) * TABBAR_HEIGHT))/6
            var x: CGFloat = ((self.view.bounds.width / 2) - (320 / 2))  + CGFloat(space)
            for image in images {
                var title = NSString(format: "tabbar.%@", image)
                title = NSLocalizedString(title as String, comment: "")
                let button = UIButton()
                button.setImage(UIImage(named: image), forState: .Normal)
                button.setImage(UIImage(named: NSString(format: "%@_active", image) as String), forState: .Selected)
                button.setImage(UIImage(named: NSString(format: "%@_active", image) as String), forState: .Highlighted)
                button.imageView!.contentMode =  UIViewContentMode.Center
                button.addTarget(self, action: #selector(CustomBarViewController.buttonSelected(_:)), forControlEvents: .TouchUpInside)
                button.selected = image == "tabBar_home"
                button.frame = CGRectMake(x, 2, TABBAR_HEIGHT, TABBAR_HEIGHT)
                
                //var spacing: CGFloat = 1.0 // the space between the image and text
                //var imageSize: CGSize = button.imageView!.frame.size
                
                if image == "tabBar_menu" || image == "more_menu_ipad" {
                    let posY: CGFloat = IS_IPAD ? 0.0 : -8.0
                    self.badgeNotification = BadgeView(frame: CGRectMake(TABBAR_HEIGHT - 22, posY, 16, 16), backgroundColor: WMColor.red, textColor: UIColor.whiteColor())
                    let badgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
                    if  badgeNumber > 0 {
                     self.badgeNotification.showBadge(false)
                    }
                    self.badgeNotification.updateTitle(badgeNumber)
                    self.badgeNotification.clipsToBounds = false
                    button.clipsToBounds = false
                    button.addSubview(self.badgeNotification)
                }

                x = CGRectGetMaxX(button.frame) + space
                
                self.buttonContainer!.addSubview(button)
                self.buttonContainer!.clipsToBounds = false
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
            //var spacing: CGFloat = 1.0 // the space between the image and text
            //var imageSize: CGSize = button.imageView!.frame.size
            x = CGRectGetMaxX(button.frame) + space
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "homeEmbedSegue" {
            let controller = segue.destinationViewController as? UINavigationController
            self.viewControllers.append(controller!)
            controller?.delegate = self
            self.currentController = controller
        }
    }
    
    
    //MARK: -
    /**
     Action when pressing a button from home,send analitycs
     
     - parameter sender: button tap
     */
    func buttonSelected(sender:UIButton) {
        
        if self.btnSearch!.selected {
            self.closeSearch(false,sender:sender)
        }
        else {
            let index = self.buttonList.indexOf(sender)
            
            switch index! {
            case 0:
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TAP_BAR.rawValue, action: WMGAIUtils.ACTION_OPEN_HOME.rawValue, label: "")
            case 1:
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TAP_BAR.rawValue, action: WMGAIUtils.ACTION_OPEN_MG.rawValue, label: "")
            case 2:
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TAP_BAR.rawValue, action: WMGAIUtils.ACTION_OPEN_GR.rawValue, label: "")
            case 3:
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TAP_BAR.rawValue, action: WMGAIUtils.ACTION_OPEN_LIST.rawValue, label: "")
            case 4:
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TAP_BAR.rawValue, action: WMGAIUtils.ACTION_OPEN_MORE_OPTION.rawValue, label: "")
            default:
                break
            }
            
            
            let controller = self.viewControllers[index!]
            if controller === self.currentController {
                if let navController = self.currentController as? UINavigationController {
                 dispatch_async(dispatch_get_main_queue()) {
                    navController.popToRootViewControllerAnimated(true)
                  }
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
    
    /**
     Create instance of controllers,for each option of menu
     */
    func createInstanceOfControllers() {
        let storyboard = self.loadStoryboardDefinition()
        
        //var   = "loginVC-profileItemVC" as String
       // if UserCurrentSession.sharedInstance().userSigned != nil{
            //controllerProfile = "profileVC"
        //}
        
        
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
        self.container?.addSubview(content.view)
        content.didMoveToParentViewController(self)
    }
    /**
     Remove curren controller from content
     
     - parameter content: view controller at remove
     */
    func hideContentController(content: UIViewController) {
        content.willMoveToParentViewController(nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }
    

    func setTabBarHidden(hidden:Bool, animated:Bool, delegate:CustomBarDelegate?) -> Void {
        //self.badgeNotification.hidden = hidden
        //let bounds: CGRect = self.view.frame
        let badgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
        let showBadgeNotification = (badgeNumber > 0) && !hidden
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
                        self.badgeNotification.hidden = !showBadgeNotification
                         NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.TapBarFinish.rawValue, object: nil)
                })
            }
            else
            {
                self.buttonContainer!.frame = CGRectMake(self.buttonContainer!.frame.minX, self.view.frame.maxY,
                self.buttonContainer!.frame.width, self.buttonContainer!.frame.height)
                self.badgeNotification.hidden = !showBadgeNotification
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.TapBarFinish.rawValue, object: nil)
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
                                    self.badgeNotification.hidden = !showBadgeNotification
                                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.TapBarFinish.rawValue, object: nil)
                            })
                        }
                })
            }
            else
            {
                self.badgeNotification.hidden = !showBadgeNotification
                self.buttonContainer!.frame = CGRectMake(self.buttonContainer!.frame.minX, self.view.frame.maxY - self.buttonContainer!.frame.height,self.buttonContainer!.frame.width, self.buttonContainer!.frame.height)
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.TapBarFinish.rawValue, object: nil)
            }
        }
        
    }
    
    func hideTabBar(notification:NSNotification) {
        self.setTabBarHidden(true, animated: true, delegate:notification.object as! CustomBarDelegate?)
    }
    
    func showTabBar(notification:NSNotification) {
        self.setTabBarHidden(false, animated: true, delegate:notification.object as! CustomBarDelegate?)
    }
    
    class func buildParamsUpdateShoppingCart(upc:String,desc:String,imageURL:String,price:String!,quantity:String,onHandInventory:String,pesable:String,isPreorderable:String) -> [NSObject:AnyObject] {
        return ["upc":upc,"desc":desc,"imgUrl":imageURL,"price":price, "quantity":quantity,"onHandInventory":onHandInventory,"pesable":pesable,"isPreorderable":isPreorderable]
    }
    
    class func buildParamsUpdateShoppingCart(upc:String,desc:String,imageURL:String,price:String!,quantity:String,onHandInventory:String,wishlist:Bool,type:String,pesable:String,isPreorderable:String,category:String) -> [NSObject:AnyObject] {
        return ["upc":upc,"desc":desc,"imgUrl":imageURL,"price":price,"quantity":quantity,"onHandInventory":onHandInventory,"wishlist":wishlist,"pesable":pesable,"isPreorderable":isPreorderable,"category":category,"type":type]
        
    }
    
    class func buildParamsUpdateShoppingCart(upc:String,desc:String,imageURL:String,price:String!,quantity:String,comments:String,onHandInventory:String,type:String,pesable:String,isPreorderable:String) -> [NSObject:AnyObject] {
        return
            ["upc":upc,"desc":desc,"imgUrl":imageURL,"price":price,"quantity":quantity,"comments":comments,"onHandInventory":onHandInventory,"wishlist":false,"type":type,"pesable":pesable,"isPreorderable":isPreorderable]
    }
    
    class func buildParamsUpdateShoppingCart(upc:String,desc:String,imageURL:String,price:String!,quantity:String,onHandInventory:String,pesable:String, type:String ,isPreorderable:String) -> [NSObject:AnyObject] {
        return ["upc":upc,"desc":desc,"imgUrl":imageURL,"price":price, "quantity":quantity,"onHandInventory":onHandInventory,"pesable":pesable, "type" : type,"isPreorderable":isPreorderable]
    }
    
    /**
     add item to shopping cart from notification
     
     - parameter notification: notification
     */
    func addItemToShoppingCart(notification:NSNotification){
        
        let addShopping = ShoppingCartUpdateController()
        if !btnShopping!.selected {
            addShopping.goToShoppingCart = {() in
                self.showShoppingCart(self.btnShopping!)
            }
        }
        let params = notification.userInfo as! [String:AnyObject]
        
        addShopping.params = params
        
        let price = (params["price"] as? NSString)!.doubleValue
        var type = params["type"] as? String
        let upc = params["upc"] as? String
        
        if type == nil {
            addShopping.typeProduct = ResultObjectType.Mg
            type = "MG"
        }
        else {
            addShopping.typeProduct = (type == ResultObjectType.Mg.rawValue ? ResultObjectType.Mg : ResultObjectType.Groceries)
        }
        
        //FACEBOOKLOG
        FBSDKAppEvents.logEvent(FBSDKAppEventNameAddedToCart, valueToSum:price, parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "product\(type!)",FBSDKAppEventParameterNameContentID:upc!])
        
        self.addChildViewController(addShopping)
        addShopping.view.frame = self.view.bounds
        self.view.addSubview(addShopping.view)
        addShopping.didMoveToParentViewController(self)
        addShopping.startAddingToShoppingCart()
    }
    
    
    /**
     add items to shopping cart from notification
     
     - parameter notification: notification
     */
    func addItemsToShoppingCart(notification:NSNotification) {
        let addShopping = ShoppingCartUpdateController()
        
        let params = notification.userInfo as! [String:AnyObject]
        var type = params["type"] as? String
        var price: Double = 0
        var upc: String = "["
        let allItems = params["allitems"] as? [[String:AnyObject]]
        
        for item in allItems! {
            let productUpc = item["upc"] as? String
            upc.appendContentsOf("'\(productUpc!)',")
            price += (item["price"] as? NSString)!.doubleValue
            type = item["type"] as? String
        }
        upc.appendContentsOf("]")
        //FACEBOOKLOG
        FBSDKAppEvents.logEvent(FBSDKAppEventNameAddedToCart, valueToSum:price, parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "product\(type!)",FBSDKAppEventParameterNameContentID:upc])
        
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
    
    //MARK: Search functions
    
    /**
        open or close options searching
     
     - parameter btn: button action
     */
    func search(btn: UIButton){
        openSearch = false
        if (!btn.selected){
            if (self.btnShopping!.selected){
                self.closeShoppingCart()
            }
            else{
                self.clearSearch()
                self.contextSearch = .WithText
                self.openSearchProduct()
                
            }
        }
        else{
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT.rawValue, action: WMGAIUtils.ACTION_CANCEL.rawValue, label: "")
            self.closeSearch(false, sender: nil)
        }
    }
    
    /**
        Open edito searching
     
     - parameter notification: notification
     */
    func editSearch(notification:NSNotification){
        let searchKey = notification.object as! String
        self.openSearchProduct()
        self.searchController!.field!.text = searchKey
        self.isEditingSearch = true
    }
    
    /**
      Open controller in order to look for by photo
     
     - parameter notification: notification
     */
    func camFindSearch(notification:NSNotification){
        let searchDic = notification.object as! [String:AnyObject]
        let upcs = searchDic["upcs"] as! [String]
        let keyWord = searchDic["keyWord"] as! String
        let controllernav = self.currentController as? UINavigationController
        let controllersInNavigation = controllernav?.viewControllers.count
        if (controllersInNavigation > 2 && controllernav?.viewControllers[controllersInNavigation! - 2] as? SearchProductViewController != nil){
            controllernav?.viewControllers.removeAtIndex(controllersInNavigation! - 2)
            isEditingSearch = false
        }
        let controller = SearchProductViewController()
        controller.upcsToShow = upcs
        controller.searchContextType = .WithTextForCamFind
        controller.titleHeader = keyWord
        controller.textToSearch = keyWord
        controllernav?.pushViewController(controller, animated: true)
    }
    /**
     
     */
    func openSearchProduct(){
        if let _ = self.currentController! as? UINavigationController {
            if self.searchController == nil  {
                

                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SEARCH.rawValue, action: WMGAIUtils.ACTION_OPEN_SEARCH_OPTIONS.rawValue, label: "")
                
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
                                                    }
                })
                
            }
            
        }
    }
    
    var helpView: UIView?
    
    
    func showHelpViewForSearchIfNeeded(controller:UIViewController) {
        var requiredHelp = true
        if let param = CustomBarViewController.retrieveParam("searchHelp") {
            requiredHelp = !(param.value == "false")
        }
        
        if requiredHelp && self.helpView == nil {
            let bounds = controller.view.bounds
            
            self.helpView = UIView(frame: CGRectMake(0.0, 0.0, bounds.width, bounds.height))
            self.helpView!.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
            self.helpView!.alpha = 0.0
            self.helpView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CustomBarViewController.removeHelpForSearchView)))
            controller.view.addSubview(self.helpView!)
            
            let icon = UIImageView(image: UIImage(named: "search_scan_help"))
            icon.frame = CGRectMake(189.0, 11.0, 55.0, 48.0)
            self.helpView!.addSubview(icon)
            
            let arrow = UIImageView(image: UIImage(named: "search_scan_arrow_help"))
            arrow.frame = CGRectMake(icon.center.x - 75.0, icon.frame.maxY, 80.0, 36.0)
            self.helpView!.addSubview(arrow)
            
            let message = UILabel(frame: CGRectMake(16.0, arrow.frame.maxY, self.view.bounds.width - 88.0, 40.0))
            message.numberOfLines = 0
            message.textColor = UIColor.whiteColor()
            message.textAlignment = .Center
            message.font = WMFont.fontMyriadProRegularOfSize(16.0)
            message.text = NSLocalizedString("product.search.scann.help", comment:"")
            self.helpView!.addSubview(message)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.helpView!.alpha = 1.0
                CustomBarViewController.addOrUpdateParam("searchHelp", value: "false")
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
                    
                     self.searchController!.field!.resignFirstResponder()
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
    
    func selectKeyWord(keyWord:String, upc:String?, truncate:Bool,upcs:[String]? ){
        if upc != nil {
                
            
            let controller = ProductDetailPageViewController()
            controller.idListSeleted  = self.idListSelected
            let useSignalsService : NSDictionary = NSDictionary(dictionary: ["signals" : GRBaseService.getUseSignalServices()])
            let svcValidate = ProductDetailService(dictionary: useSignalsService)
            
            let upcDesc : NSString = upc! as NSString
            var paddedUPC = upcDesc
            if upcDesc.length < 13 {
                let toFill = "".stringByPaddingToLength(13 - upcDesc.length, withString: "0", startingAtIndex: 0)
                paddedUPC = "\(toFill)\(paddedUPC)"
            }
            let params = svcValidate.buildParams(paddedUPC as String, eventtype: "pdpview",stringSearching: "",position: "")//
            svcValidate.callService(requestParams:params, successBlock: { (result:NSDictionary) -> Void in
                controller.itemsToShow = [["upc":paddedUPC,"description":keyWord,"type":ResultObjectType.Groceries.rawValue]]
                
                let controllernav = self.currentController as? UINavigationController
                let controllersInNavigation = controllernav?.viewControllers.count
                if controllersInNavigation > 1 && (controllernav?.viewControllers[controllersInNavigation! - 2] as? ProductDetailPageViewController != nil){
                    controllernav?.viewControllers.removeAtIndex(controllersInNavigation! - 2)
                    self.isEditingSearch = false
                }
                controllernav?.pushViewController(controller, animated: true)
                
                }, errorBlock: { (error:NSError) -> Void in
                    
                    if upcDesc.length < 14 {
                        let toFill = "".stringByPaddingToLength(14 - upcDesc.length, withString: "0", startingAtIndex: 0)
                        paddedUPC = "\(toFill)\(upcDesc)"
                    }
                    
                    controller.itemsToShow = [["upc":paddedUPC,"description":keyWord,"type":ResultObjectType.Mg.rawValue]]
                    let controllernav = self.currentController as? UINavigationController
                    let controllersInNavigation = controllernav?.viewControllers.count
                    if controllersInNavigation > 1 && (controllernav?.viewControllers[controllersInNavigation! - 2] as? ProductDetailPageViewController != nil){
                        controllernav?.viewControllers.removeAtIndex(controllersInNavigation! - 2)
                        self.isEditingSearch = false
                    }

                    controllernav?.pushViewController(controller, animated: true)
            })
        }
        else{
            
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SEARCH_BY_TAKING_A_PHOTO.rawValue, label: "")
            let controllernav = self.currentController as? UINavigationController
            let controllersInNavigation = controllernav?.viewControllers.count
            if controllersInNavigation > 2 && (controllernav?.viewControllers[controllersInNavigation! - 2] as? SearchProductViewController != nil){
                controllernav?.viewControllers.removeAtIndex(controllersInNavigation! - 2)
                isEditingSearch = false
            }
            let controller = SearchProductViewController()
            controller.upcsToShow = upcs
            controller.searchContextType = .WithText
            controller.titleHeader = keyWord
            controller.textToSearch = keyWord
            controllernav?.pushViewController(controller, animated: true)
        }
        
        self.btnSearch!.selected = true
//        self.btnSearch!.setImage(UIImage(named: "navBar_search"), forState:  UIControlState.Normal)
        self.closeSearch(false, sender: nil)
    }
    
    
    
    func showProducts(forDepartmentId depto: String?, andFamilyId family: String?, andLineId line: String?, andTitleHeader title:String , andSearchContextType searchContextType:SearchServiceContextType){
        let controller = SearchProductViewController()
        controller.searchContextType = searchContextType
        controller.idFamily  = family == nil ? "_" :  family
        controller.idDepartment = depto == nil ? "_" :  depto
        controller.idLine = line == nil ? "_" :  line
        controller.titleHeader = title
        let controllernav = self.currentController as? UINavigationController
        let controllersInNavigation = controllernav?.viewControllers.count
        if controllersInNavigation > 2 && (controllernav?.viewControllers[controllersInNavigation! - 2] as? SearchProductViewController != nil){
            controllernav?.viewControllers.removeAtIndex(controllersInNavigation! - 2)
        }
        controllernav?.pushViewController(controller, animated: true)
//        self.btnSearch!.selected = false
//        self.btnSearch!.setImage(UIImage(named: "navBar_search"), forState:  UIControlState.Normal)
        
        self.btnSearch!.selected = true
        self.closeSearch(false, sender: nil)
    }
    
    func showProductList(forDepartmentId depto: String?, andFamilyId family: String?, andLineId line: String?, andTitleHeader title:String, andGrade grade:String , andSearchContextType searchContextType:SearchServiceContextType){
        let controller = SchoolListViewController()
        controller.familyId  = family ?? "_"
        controller.departmentId = depto ??  "_"
        controller.lineId = line ?? "_"
        controller.schoolName = title
        controller.gradeName = grade
        controller.showWishList = false
        
        let controllernav = self.currentController as? UINavigationController
        let controllersInNavigation = controllernav?.viewControllers.count
        if controllersInNavigation > 2 && (controllernav?.viewControllers[controllersInNavigation! - 2] as? SchoolListViewController != nil){
            controllernav?.viewControllers.removeAtIndex(controllersInNavigation! - 2)
        }
        controllernav?.pushViewController(controller, animated: true)
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
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
            self.closeSearch(false, sender: nil)
            self.searchController!.willMoveToParentViewController(nil)
            self.searchController!.view.removeFromSuperview()
            self.searchController!.removeFromParentViewController()
            self.searchController = nil
            self.btnSearch!.enabled = true
            self.btnShopping!.enabled = true
            self.btnSearch!.selected = false
        }
    }
    
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
    }
    
    func searchControllerScanButtonClicked() {
        let barCodeController = BarCodeViewController()
        barCodeController.searchProduct = true
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
        self.btnShopping?.selected = false
        self.btnCloseShopping?.alpha = 0
        //self.showBadge()
        self.btnShopping?.alpha = 1
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRE_SHOPPING_CART.rawValue,action:WMGAIUtils.ACTION_CANCEL.rawValue , label:"")
        
        if shoppingCartVC != nil {
            if ((shoppingCartVC.viewControllers.first as? ShoppingCartViewController) != nil) {
                
                UIView.animateWithDuration(0.5,
                                           animations: {() in
                                            self.shoppingCartVC.view.frame = CGRectMake(-self.shoppingCartVC.view.frame.minX, -self.shoppingCartVC.view.frame.height, self.shoppingCartVC.view.frame.width, self.shoppingCartVC.view.frame.height)
                                            
                    },
                                           completion: {(finished : Bool) in
                                            if finished {
                                                self.shoppingCartVC.willMoveToParentViewController(nil)
                                                self.shoppingCartVC.view.removeFromSuperview()
                                                self.shoppingCartVC.removeFromParentViewController()
                                                self.shoppingCartVC = nil
                                                self.openSearch = false
                                                self.shoppingCartVC = nil
                                            }
                    }
                )
            }
            
            
            NSNotificationCenter.defaultCenter().postNotificationName("MORE_OPTIONS_RELOAD", object: nil)
            
        }
    }
    
    func showShoppingCart() {
        self.showShoppingCart(self.btnShopping!)
    }
    
    func showShoppingCart(sender:UIButton,closeIfNeedded:Bool) {
        if (!sender.selected){
            sender.selected = !sender.selected
            self.addtoShopingCar()
            
            self.endUpdatingShoppingCart(self)
            self.hidebadge()
            self.btnShopping?.alpha = 0
            
            if self.btnCloseShopping == nil {
                self.btnCloseShopping = UIButton()
                self.btnCloseShopping?.frame = self.btnShopping!.frame
                self.btnCloseShopping?.setImage(UIImage(named:"close"), forState: .Normal)
                self.btnCloseShopping?.addTarget(self, action: #selector(CustomBarViewController.showShoppingCart as (CustomBarViewController) -> () -> ()), forControlEvents: UIControlEvents.TouchUpInside)
                self.btnShopping?.superview?.addSubview(self.btnCloseShopping!)
                
            }
            self.btnCloseShopping?.enabled = false
            self.btnCloseShopping?.alpha = 1
            self.btnShopping?.userInteractionEnabled = true
            self.btnCloseShopping?.enabled = true
            
        }
        else {
            if closeIfNeedded {
                self.closeShoppingCart()
            }
        }
        
    }
    
    @IBAction func showShoppingCart(sender:UIButton) {
        self.showShoppingCart(sender,closeIfNeedded:true)
    }
    
    func addtoShopingCar(){
        
        let storyboard = self.loadStoryboardDefinition()
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("shoppingCartVC") as? UINavigationController {
            shoppingCartVC = vc
            if let vcRoot = shoppingCartVC.viewControllers.first as? ShoppingCartViewController {
                vcRoot.delegate = self
            }
        }
        
        self.addChildViewController(shoppingCartVC)
        shoppingCartVC.view.frame = self.container!.frame
        
        shoppingCartVC.view.frame = CGRectMake(-shoppingCartVC.view.frame.minX, -shoppingCartVC.view.frame.height, shoppingCartVC.view.frame.width, shoppingCartVC.view.frame.height)
        
        self.view.addSubview(shoppingCartVC.view)
        self.view.bringSubviewToFront(self.headerView)
        shoppingCartVC.didMoveToParentViewController(self)
        
        
        UIView.animateWithDuration(0.5,
                                   animations: {() in
                                    self.shoppingCartVC.view.frame = CGRectMake(self.container!.frame.minX, self.container!.frame.minY, self.shoppingCartVC.view.frame.width, self.shoppingCartVC.view.frame.height)
            },
                                   completion: {(finished : Bool) in
                                    
            }
        )
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CAR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CAR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PRE_SHOPPING_CART.rawValue, label: "")
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
            buttonSelected(self.buttonList[2])
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
    
    func showListsGR() {
        buttonSelected(self.buttonList[3])
         NSNotificationCenter.defaultCenter().postNotificationName("ReloadListFormUpdate", object: self)
    }
        
        
    
    
    func showBadge() {
        if badgeShoppingCart == nil {
            badgeShoppingCart = BadgeView(frame: CGRectMake(self.view.bounds.width - 30 , 20, 15, 15))
            self.headerView.addSubview(badgeShoppingCart)
        }
        if btnShopping?.selected == false {
            self.badgeShoppingCart.alpha = 1
        }
    }
    
    func notificaUpdateBadge(notification:NSNotification){
        if notification.object != nil {
            let params = notification.object as! NSDictionary
            let number = params["quantity"] as! Int
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
        
        UserCurrentSession.sharedInstance().phoneNumber = ""
        UserCurrentSession.sharedInstance().cellPhone = ""
        
        self.viewControllers.removeRange(1..<self.viewControllers.count)
        self.createInstanceOfControllers()
        self.buttonSelected(self.buttonList[0])
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(CustomBarViewController.sendHomeNotification), userInfo: nil, repeats: false)
    }
    
    func sendHomeNotification(){
        if let navController = self.viewControllers[0] as? UINavigationController {
            navController.popToRootViewControllerAnimated(true)
            self.viewControllers[0] = navController
        }
    }
    
    func removeAllCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        var cookies = storage.cookiesForURL(NSURL(string: "https://www.walmart.com.mx")!)
        for idx in 0 ..< cookies!.count {
            let cookie = cookies![idx] 
            storage.deleteCookie(cookie)
        }
        cookies =   storage.cookiesForURL(NSURL(string: "https://www.aclaraciones.com.mx")!)
        for idx in 0 ..< cookies!.count {
            let cookie = cookies![idx] 
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
            runSpinAnimationOnView(imageLoadingCart, duration: 100, rotations: 1, repeats: 100)
            
        }
    }
    
    func endUpdatingShoppingCart(sender:AnyObject) {
        self.showBadge()
        if self.imageLoadingCart != nil {
            self.imageLoadingCart.layer.removeAllAnimations()
            self.imageLoadingCart.removeFromSuperview()
            self.imageLoadingCart = nil
        }
    }
    
    func runSpinAnimationOnView(view:UIView,duration:CGFloat,rotations:CGFloat,repeats:CGFloat) {
        if btnShopping?.selected == false {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
            rotationAnimation.duration = CFTimeInterval(duration)
            rotationAnimation.cumulative = true
            rotationAnimation.repeatCount = Float(repeats)
            
            view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
            
            if self.imageLoadingCart != nil {
                imageLoadingCart.hidden = false
            }
        }
        
    }
    
    
    func logoTap(){
        self.buttonSelected(self.buttonList[0])
        self.closeShoppingCart()
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_NAVIGATION_BAR.rawValue, action: WMGAIUtils.ACTION_GO_TO_HOME.rawValue, label: "")
    }
    
    func hidebadge() {
        self.badgeShoppingCart.alpha = 0
    }
    
    func showbadge() {
        if btnShopping?.selected == false {
                self.badgeShoppingCart.alpha = 1
        }
    }
    
    
    
    func handleNotification(type:String,name:String,value:String,bussines:String) -> Bool {
        //Se elimina el badge de notificaciones
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateNotificationBadge.rawValue, object: nil)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_NOTIFICATION.rawValue, action: WMGAIUtils.ACTION_PUSH_NOTIFICATION_OPEN.rawValue, label: value)
       return self.handleListNotification(type, name: name, value: value, bussines: bussines, schoolName: "", grade: "")
    }
    
    func handleListNotification(type:String,name:String,value:String,bussines:String,schoolName:String,grade:String) -> Bool {
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
        case "UPC": self.selectKeyWord("", upc:trimValue, truncate:true,upcs:nil)
        case "TXT": self.selectKeyWord(trimValue, upc:nil, truncate:true,upcs:nil)
        case "LIN": self.showProducts(forDepartmentId: nil, andFamilyId: nil,andLineId: trimValue, andTitleHeader:name == "CP" ? "Centro de promociones": "Recomendados" , andSearchContextType:bussines == "gr" ? .WithCategoryForGR : .WithCategoryForMG )
        case "FAM": self.showProducts(forDepartmentId: nil, andFamilyId:trimValue, andLineId: nil, andTitleHeader:"Recomendados" , andSearchContextType:bussines == "gr" ? .WithCategoryForGR : .WithCategoryForMG)
        case "CAT": self.showProducts(forDepartmentId: trimValue, andFamilyId:nil, andLineId: nil, andTitleHeader:"Recomendados" , andSearchContextType:bussines == "gr" ? .WithCategoryForGR : .WithCategoryForMG)
        case "CF": self.showShoppingCart(self.btnShopping!,closeIfNeedded: false)
        case "WF": self.buttonSelected(self.buttonList[3])
        case "LIST": self.showProductList(forDepartmentId: nil, andFamilyId: nil, andLineId: trimValue, andTitleHeader: schoolName, andGrade:grade, andSearchContextType: .WithCategoryForMG)
        case "URL": self.openURLNotification(trimValue)
        case "SH":
            if self.splashVC == nil {
                self.openSearchProduct()
            } else {
                self.waitToSplash = true
            }
        default:
            print("No value type for notification")
            return false
        }
        
        if splashVC != nil {
            self.view.bringSubviewToFront(splashVC.view)
        }
        
        return true
    }
    
    /**
     open url from notification, url or app store
     
     - parameter url: url open
     */
    func openURLNotification(url:String){

        if url.rangeOfString("itms-apps:") != nil {
            let urlApp  = NSURL(string: url)
            if UIApplication.sharedApplication().canOpenURL(urlApp!) == true  {
                UIApplication.sharedApplication().openURL(urlApp!)
            }
        }else{
            let ctrlWeb = IPOWebViewController()
            ctrlWeb.openURL(url)
            self.presentViewController(ctrlWeb, animated: true, completion: nil)
        }
    }
    
    //MARK: Barcode Function
    func scanBarcode(notification:NSNotification){
        let barcodeValue = notification.object as! String
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Barcode.rawValue
        self.idListSelected = ""
        self.selectKeyWord("", upc: barcodeValue, truncate:true,upcs:nil)
    }
    
    //GRA: Help Validation
    func reviewHelp(force:Bool) -> Bool {
        var requiredHelp = true
        if let param = CustomBarViewController.retrieveParam("mainHelp") {
            requiredHelp = !(param.value == "false")
        }
        let showTurial = (requiredHelp && self.helpView == nil ) || force
        if showTurial {
            let bounds = self.view.bounds
            
            self.helpView = UIView(frame: CGRectMake(0.0, 0.0, bounds.width, bounds.height))
            self.helpView!.backgroundColor = WMColor.light_blue
            self.helpView!.alpha = 0.0
            
            self.view.addSubview(self.helpView!)
            
            
            let imageArray = [["image":"ahora_todo_walmart","details":NSLocalizedString("help.walmart.nowallWM",comment:"")],["image":"busca_por_codigo","details":NSLocalizedString("help.walmart.search",comment:"")],["image":"consulta_pedidos_articulos","details":NSLocalizedString("help.walmart.backup",comment:"")],["image":"haz_una_lista","details":NSLocalizedString("help.walmart.list",comment:"")]]
            totuView = TutorialHelpView(frame: self.helpView!.bounds, properties: imageArray)
            totuView!.onClose = {() in
                self.removeHelpForSearchView()
                CustomBarViewController.addOrUpdateParam("mainHelp", value: "false")
                self.showHelpHomeView()
            }
            helpView?.addSubview(totuView!)
            //UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.helpView!.alpha = 1.0
            //})
        }
        return showTurial
    }
    
    func showHelpHomeView(){
        let param = CustomBarViewController.retrieveParam("appVersion", forUser: false)
        let appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]! as! String
        if param != nil {
            self.showHelpHome = (appVersion != param!.value)
        }else{
            self.showHelpHome = true
        }
        if self.showHelpHome {
            let helpView = HelpHomeView(frame:CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height))
            helpView.alpha = 0.0
            UIView.animateWithDuration(0.4, animations: {
                helpView.alpha = 1.0
                }, completion: nil)
            self.view.addSubview(helpView)
            helpView.onClose = {(Void) -> Void in
                CustomBarViewController.addOrUpdateParam("appVersion", value:"\(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]! as! String)",forUser: false)
            }
        }
    }
    
    func updateNotificationBadge(){
        dispatch_async(dispatch_get_main_queue(), {
            let badgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
            if  badgeNumber > 0 {
                self.badgeNotification.showBadge(false)
            }
            self.badgeNotification.updateTitle(badgeNumber)
            self.badgeNotification.hidden = (badgeNumber == 0)
        })
    }
    
    func showHelp() {
        reviewHelp(true)
    }
}