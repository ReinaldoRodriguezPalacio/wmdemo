//
//  HomeViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/27/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import FBSDKCoreKit
import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension Notification.Name {
    static let addUPCToShopingCart = Notification.Name("kAddUPCToShopingCart")
    static let addItemsToShopingCart = Notification.Name("kAddItemsToShopingCart")
    static let successUpdateItemsInShoppingCart = Notification.Name("kSuccessUpdateItemsInShoppingCart")
    static let reloadWishList = Notification.Name("kReloadWishList")
    static let updateBadge = Notification.Name("kUpdateBadge")
    static let userLogOut = Notification.Name("kUserLogOut")
    static let updateShoppingCartBegin = Notification.Name("kUpdateShoppingCartBegin")
    static let updateShoppingCartEnd = Notification.Name("kUpdateShoppingCartEnd")
    static let clearSearch = Notification.Name("kClearSearch")
    static let hideBadge = Notification.Name("kHideBadge")
    static let showBadge = Notification.Name("kShowBadge")
    static let showHelp = Notification.Name("kShowHelp")
    static let clearShoppingCartGR = Notification.Name("kClearShoppingCartGR")
    static let clearShoppingCartMG = Notification.Name("kClearShoppingCartMG")
    static let editSearch = Notification.Name("kEditSearch")
    static let camFindSearch = Notification.Name("kCamFindSearch")
    static let scanBarCode = Notification.Name("kScanBarcode")
    static let updateNotificationBadge = Notification.Name("kUpdateNotificationBadge")
    static let showGRLists = Notification.Name("kShowGRLists")
    static let showHomeSelected = Notification.Name("kShowHomeSelected")
    static let addCLosePopCategorie = Notification.Name("kAddCLosePopCategorie")
    static let removePopSearch = Notification.Name("KremovePopSearch")
    static let userlistUpdated = Notification.Name("KuserlistUpdated")
}



struct TabBarHidden {
    static var isTabBarHidden : Bool = false
}


@objc protocol CustomBarDelegate: class {
    func customBarDidAnimate(_ hide:Bool, offset:CGFloat)
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
    var timmer : Timer? = nil
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
    let KEY_RATING = "ratingEnabled"
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
    var finishOpen =  false
    var onCloseSearch: ((Void) -> Void)?
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
        }()
    
    override func getScreenGAIName() -> String {
        return "SCREEN_SPLASHLOADAPP"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.addItemToShoppingCart(_:)), name: .addUPCToShopingCart, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.addItemsToShoppingCart(_:)), name: .addItemsToShopingCart, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.notificaUpdateBadge(_:)), name: .updateBadge, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.userLogOut(_:)), name: .userLogOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.startUpdatingShoppingCart(_:)), name: .updateShoppingCartBegin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.endUpdatingShoppingCart(_:)), name: .updateShoppingCartEnd, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.clearSearch), name: .clearSearch, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.hidebadge), name: .hideBadge, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.showbadge), name: .showBadge, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.showHelp), name: .showHelp, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.closeShoppingCartEmptyGroceries), name: .clearShoppingCartGR, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.closeShoppingCartEmptyMG), name: .clearShoppingCartMG, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.editSearch(_:)), name: .editSearch, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.showListsGR), name: .showGRLists, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.camFindSearch(_:)), name: .camFindSearch, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.scanBarcode(_:)), name: .scanBarCode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomBarViewController.updateNotificationBadge), name: .updateNotificationBadge, object: nil)
        
        buttonContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 45))
        self.view.addSubview(buttonContainer!)
        
        self.headerView.backgroundColor = WMColor.light_blue
        self.buttonContainer!.backgroundColor = WMColor.light_blue
        self.btnSearch?.addTarget(self, action: #selector(CustomBarViewController.search(_:)), for: UIControlEvents.touchUpInside)
        
        showBadge()
        
        self.createInstanceOfControllers()
        
        self.view.bringSubview(toFront: headerView)
        
        let showTutorial = self.reviewHelp(false)
        
        let tapGestureLogo =  UITapGestureRecognizer(target: self, action: #selector(CustomBarViewController.logoTap))
        viewLogo.addGestureRecognizer(tapGestureLogo)
        splashVC = IPOSplashViewController()
        splashVC.didHideSplash = { [weak self] () in
            if !showTutorial {
                self?.showHelpHomeView()
            }
            if self!.waitToSplash {
                self?.openSearchProduct()
            }
            self?.splashVC = nil
            self?.checkPrivaceNotice()
        }
        
        splashVC.validateVersion =  {[weak self] (force:Bool) in
            self?.updateAviable = UpdateViewController()
            self?.updateAviable.setup()
            self?.updateAviable.forceUpdate = force
            self?.updateAviable.frame = (self?.view.bounds)!
            self?.view.addSubview((self?.updateAviable)!)
        }
        self.addChildViewController(splashVC)
        self.view.addSubview(splashVC.view)
        
        let storyboard = self.loadStoryboardDefinition()
        if let vc = storyboard!.instantiateViewController(withIdentifier: "shoppingCartVC") as? UINavigationController {
            shoppingCartVC = vc
            if let vcRoot = shoppingCartVC.viewControllers.first as? ShoppingCartViewController {
                vcRoot.delegate = self
            }
        }
        
        createTabBarButtons()
        setTabBarHidden(false, animated: false, delegate: nil)
        
        gestureCloseShoppingCart = UISwipeGestureRecognizer(target: self, action: #selector(CustomBarViewController.closeShoppingCart))
        gestureCloseShoppingCart.direction = UISwipeGestureRecognizerDirection.up
        
        
        
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        badgeShoppingCart.frame = CGRect(x: self.view.bounds.width - 24 , y: 20, width: 15, height: 15)
        if self.helpView != nil {
            self.helpView!.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
            if totuView != nil {
                totuView!.frame = self.helpView!.bounds
            }
        }
        layoutButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.setTabBarHidden(self.isTabBarHidden, animated: true, delegate:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Check PrivaceNotice Dates
    /**
     Validate if present privace notice, find param in db and valid date
     */
    func checkPrivaceNotice(){
        
        let sinceDate : Date = UserCurrentSession.sharedInstance.dateStart as Date
        let untilDate : Date = UserCurrentSession.sharedInstance.dateEnd as Date
        let version = UserCurrentSession.sharedInstance.version as String
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let nowDate = dateFormatter.date(from: dateFormatter.string(from: date))
        
        var requiredAP : String! = ""
        if let param = CustomBarViewController.retrieveParam(version) {
            requiredAP = param.value
        }
        
        if requiredAP != "true" {
            if (untilDate.compare(nowDate!) == ComparisonResult.orderedDescending && sinceDate.compare(nowDate!) == ComparisonResult.orderedAscending) || untilDate.compare(nowDate!) == ComparisonResult.orderedSame || sinceDate.compare(nowDate!) == ComparisonResult.orderedSame {
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
    
    static func retrieveParam(_ key:String) -> Param? {
        return self.retrieveParam(key, forUser: true)
    }
    
    static func retrieveParamNoUser(key:String) -> Param? {
        return self.retrieveParam(key, forUser: false)
    }
    
    
    /**
     Find param for key and use user to validate query
     
     - parameter key:     param to seacrh
     - parameter forUser: use user in query
     
     - returns: param entity
     */
    static func retrieveParam(_ key:String, forUser: Bool) -> Param? {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let user = UserCurrentSession.sharedInstance.userSigned
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Param", in: context)
        if user != nil && forUser {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && user == %@", key, user!)
        }
        else {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && user == %@", key, NSNull())
        }
        var parameter: Param? = nil
        
        do {
            let result = try context.fetch(fetchRequest) as! [Param]
            if  result.count > 0 {
                parameter = result.first
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        return parameter
    }
    
    static func addOrUpdateParam(_ key:String, value:String){
        self.addOrUpdateParam(key, value: value, forUser: true)
    }
    
    static func addOrUpdateParamNoUser(key:String, value:String){
        self.addOrUpdateParam(key, value: value, forUser: false)
    }
    
    
    /**
     Add or update params in data base
     
     - parameter key:     indentifier param
     - parameter value:   value of pamam
     - parameter forUser: valid if use User in query
     */
    static func addOrUpdateParam(_ key:String, value:String, forUser:Bool) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        if let param = self.retrieveParam(key,forUser: forUser) {
            param.value = value
        }
        else {
            let param = NSEntityDescription.insertNewObject(forEntityName: "Param", into: context) as? Param
            if let user = UserCurrentSession.sharedInstance.userSigned {
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
    static func retrieveRateParam(_ key:String) -> Param? {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        
        let user = UserCurrentSession.sharedInstance.userSigned
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Param", in: context)
        if user != nil {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && idUser == %@", key, user!.idUser)
        }
      
        var parameter: Param? = nil
        
        do {
            let result = try context.fetch(fetchRequest) as! [Param]
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
    static func addRateParam(_ key:String, value:String) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        if let param = self.retrieveRateParam(key) {
            param.value = value
        }
        else {
            let param = NSEntityDescription.insertNewObject(forEntityName: "Param", into: context) as? Param
            if let user = UserCurrentSession.sharedInstance.userSigned {
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
                title = NSLocalizedString(title as String, comment: "") as NSString
                let button = UIButton()
                button.setImage(UIImage(named: image), for: UIControlState())
                button.setImage(UIImage(named: NSString(format: "%@_active", image) as String), for: .selected)
                button.setImage(UIImage(named: NSString(format: "%@_active", image) as String), for: .highlighted)
                button.imageView!.contentMode =  UIViewContentMode.center
                button.addTarget(self, action: #selector(CustomBarViewController.buttonSelected(_:)), for: .touchUpInside)
                button.isSelected = image == "tabBar_home"
                button.frame = CGRect(x: x, y: 2, width: TABBAR_HEIGHT, height: TABBAR_HEIGHT)
                
                //var spacing: CGFloat = 1.0 // the space between the image and text
                //var imageSize: CGSize = button.imageView!.frame.size
                
                if image == "tabBar_menu" || image == "more_menu_ipad" {
                    let posY: CGFloat = IS_IPAD ? 0.0 : -8.0
                    self.badgeNotification = BadgeView(frame: CGRect(x: TABBAR_HEIGHT - 22, y: posY, width: 16, height: 16), backgroundColor: WMColor.red, textColor: UIColor.white)
                    let badgeNumber = UIApplication.shared.applicationIconBadgeNumber
                    if  badgeNumber > 0 {
                     self.badgeNotification.showBadge(false)
                    }
                    self.badgeNotification.updateTitle(badgeNumber)
                    self.badgeNotification.clipsToBounds = false
                    button.clipsToBounds = false
                    button.addSubview(self.badgeNotification)
                }

                x = button.frame.maxX + space
                
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
        let space = (self.view.frame.width - (5 * TABBAR_HEIGHT))/6
        var x: CGFloat = ((self.view.bounds.width / 2) - (self.view.frame.width / 2))  + CGFloat(space)
        for button in  self.buttonList {
            button.frame = CGRect(x: x, y: 2, width: TABBAR_HEIGHT, height: TABBAR_HEIGHT)
            //var spacing: CGFloat = 1.0 // the space between the image and text
            //var imageSize: CGSize = button.imageView!.frame.size
            x = button.frame.maxX + space
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "homeEmbedSegue" {
            let controller = segue.destination as? UINavigationController
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
    func buttonSelected(_ sender:UIButton) {
        
        WishlistService.shouldupdate = true
        if self.btnSearch!.isSelected {
            self.closeSearch(false,sender:sender)
        }
        else {
            let index = self.buttonList.index(of: sender)
            //TODO: 360 Analytics
            switch index! {
            //case 0:
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TAP_BAR.rawValue, action: WMGAIUtils.ACTION_OPEN_HOME.rawValue, label: "")
            case 1:
                ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TAP_BAR.rawValue, action: WMGAIUtils.ACTION_OPEN_MG.rawValue, label: "")
                BaseController.setOpenScreenTagManager(titleScreen: "Categorias", screenName: "MGDepartment")
            case 2:
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TAP_BAR.rawValue, action: WMGAIUtils.ACTION_OPEN_GR.rawValue, label: "")
                 BaseController.setOpenScreenTagManager(titleScreen: "Categorias", screenName: "GRDepartment")
            //case 3:
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TAP_BAR.rawValue, action: WMGAIUtils.ACTION_OPEN_LIST.rawValue, label: "")
            //case 4:
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TAP_BAR.rawValue, action: WMGAIUtils.ACTION_OPEN_MORE_OPTION.rawValue, label: "")
            default:
                break
            }
            
            
            let controller = self.viewControllers[index!]
            if controller === self.currentController {
                if let navController = self.currentController as? UINavigationController {
                 DispatchQueue.main.async {
                    navController.popToRootViewController(animated: true)
                  }
                }
                return
            }
            
            for button in self.buttonList {
                button.isSelected = sender === button
            }
            
            self.displayContentController(controller)
            if self.currentController != nil  {
                self.hideContentController(self.currentController!)
            }
            
            self.currentController = controller
            
            self.btnSearch!.isEnabled = true
            self.btnShopping!.isEnabled = true
            self.btnSearch!.isSelected = false
            
        }
    }
    
    /**
     Create instance of controllers,for each option of menu
     */
    func createInstanceOfControllers() {
        let storyboard = self.loadStoryboardDefinition()
        
        //var   = "loginVC-profileItemVC" as String
       // if UserCurrentSession.sharedInstance.userSigned != nil{
            //controllerProfile = "profileVC"
        //}
        
        
        let controllerIdentifiers : [String] = ["categoriesVC","GRCategoriesVC" ,"userListsVC", "moreVC"]
        
        for item in controllerIdentifiers {
            let components = item.components(separatedBy: "-")
            let strController = components[0] as String
            let vc = storyboard!.instantiateViewController(withIdentifier: strController)
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
    
    func displayContentController(_ content: UIViewController) {
        self.addChildViewController(content)
        content.view.frame = self.container!.bounds
        self.container?.addSubview(content.view)
        content.didMove(toParentViewController: self)
    }
    /**
     Remove curren controller from content
     
     - parameter content: view controller at remove
     */
    func hideContentController(_ content: UIViewController) {
        content.willMove(toParentViewController: nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }
    
    func setTabBarHidden(_ hidden:Bool, animated:Bool, delegate:CustomBarDelegate?) -> Void {
        let badgeNumber = UIApplication.shared.applicationIconBadgeNumber
        let showBadgeNotification = (badgeNumber > 0) && !hidden
        
        self.isTabBarHidden = false
       
        
        self.badgeNotification.isHidden = !showBadgeNotification
        self.buttonContainer!.frame = CGRect(x: self.buttonContainer!.frame.minX, y: self.view.frame.maxY - self.buttonContainer!.frame.height,width: self.buttonContainer!.frame.width, height: self.buttonContainer!.frame.height)
        
        
        
    }
    
    
    class func buildParamsUpdateShoppingCart(_ upc:String,desc:String,imageURL:String,price:String!,quantity:String,onHandInventory:String,pesable:String,isPreorderable:String) -> [AnyHashable: Any] {
        return ["upc":upc,"desc":desc,"imgUrl":imageURL,"price":price, "quantity":quantity,"onHandInventory":onHandInventory,"pesable":pesable,"isPreorderable":isPreorderable]
    }
    
    class func buildParamsUpdateShoppingCart(_ upc:String,desc:String,imageURL:String,price:String!,quantity:String,onHandInventory:String,wishlist:Bool,type:String,pesable:String,isPreorderable:String,category:String) -> [AnyHashable: Any] {
        return ["upc":upc,"desc":desc,"imgUrl":imageURL,"price":price,"quantity":quantity,"onHandInventory":onHandInventory,"wishlist":wishlist,"pesable":pesable,"isPreorderable":isPreorderable,"category":category,"type":type]
        
    }
    
    class func buildParamsUpdateShoppingCart(_ upc:String,desc:String,imageURL:String,price:String!,quantity:String,comments:String,onHandInventory:String,type:String,pesable:String,isPreorderable:String,orderByPieces: Bool) -> [AnyHashable: Any] {
        return
            ["upc":upc,"desc":desc,"imgUrl":imageURL,"price":price,"quantity":quantity,"comments":comments,"onHandInventory":onHandInventory,"wishlist":false,"type":type,"pesable":pesable,"isPreorderable":isPreorderable, "orderByPieces": orderByPieces]
    }
    
    class func buildParamsUpdateShoppingCart(_ upc:String,desc:String,imageURL:String,price:String!,quantity:String,onHandInventory:String,pesable:String, type:String ,isPreorderable:String) -> [AnyHashable: Any] {
        return ["upc":upc,"desc":desc,"imgUrl":imageURL,"price":price, "quantity":quantity,"onHandInventory":onHandInventory,"pesable":pesable, "type" : type,"isPreorderable":isPreorderable]
    }
    
    /**
     add item to shopping cart from notification
     
     - parameter notification: notification
     */
    func addItemToShoppingCart(_ notification:Notification){
        
        let addShopping = ShoppingCartUpdateController()
        if !btnShopping!.isSelected {
//            addShopping.goToShoppingCart = {() in
//                self.showShoppingCart(self.btnShopping!)
//            }
        }
        
        let params = notification.userInfo as! [String:Any]
        addShopping.params = params
        
        let price = (params["price"] as? NSString)!.doubleValue
        var type : String! = nil
        if String(describing: params["type"]) == "WalmartMG.ResultObjectType.Groceries"{
            type = "groceries"
        }
        
        let upc = params["upc"] as? String
        
        if type == nil {
            addShopping.typeProduct = ResultObjectType.Mg
            type = "MG"
        } else {
            addShopping.typeProduct = (type == ResultObjectType.Mg.rawValue ? ResultObjectType.Mg : ResultObjectType.Groceries)
        }
        
        //FACEBOOKLOG
        FBSDKAppEvents.logEvent(FBSDKAppEventNameAddedToCart, valueToSum:price, parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "product\(type!)",FBSDKAppEventParameterNameContentID:upc!])
        
        self.addChildViewController(addShopping)
        addShopping.view.frame = self.view.bounds
        self.view.addSubview(addShopping.view)
        addShopping.didMove(toParentViewController: self)
        addShopping.startAddingToShoppingCart()
    }
    
    
    /**
     add items to shopping cart from notification
     
     - parameter notification: notification
     */
    func addItemsToShoppingCart(_ notification:Notification) {
        
        let addShopping = ShoppingCartUpdateController()
        
        let params = notification.userInfo as! [String:Any]
        var type = params["type"] as? String
        var price: Double = 0
        var upc: String = "["
        let allItems = params["allitems"] as? [[String:Any]]
        
        for item in allItems! {
            let productUpc = item["upc"] as? String
            upc.append("'\(productUpc!)',")
            price += (item["price"] as? NSString)!.doubleValue
            type = item["type"] as? String
        }
        
        upc.append("]")
        
        //FACEBOOKLOG
        FBSDKAppEvents.logEvent(FBSDKAppEventNameAddedToCart, valueToSum:price, parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "product\(type!)",FBSDKAppEventParameterNameContentID:upc])
        
        if type == nil {
            addShopping.typeProduct = ResultObjectType.Mg
        } else {
            addShopping.typeProduct = (type == ResultObjectType.Mg.rawValue ? ResultObjectType.Mg : ResultObjectType.Groceries)
        }
//        addShopping.goToShoppingCart = {() in
//            self.showShoppingCart(self.btnShopping!)
//        }
        addShopping.multipleItems = notification.userInfo as? [String:Any]
        self.addChildViewController(addShopping)
        addShopping.view.frame = self.view.bounds
        self.view.addSubview(addShopping.view)
        addShopping.didMove(toParentViewController: self)
        addShopping.startAddingToShoppingCart()
    }
    
    //MARK: Search functions
    
    /**
        open or close options searching
     
     - parameter btn: button action
     */
    func search(_ btn: UIButton){
        openSearch = false
        if (!btn.isSelected){
            if (self.btnShopping!.isSelected){
                if finishOpen {
                    UIView.animate(withDuration: 0.5,
                                   animations: { () -> Void in
                                    self.closeShoppingCart()
                    }, completion: { (finished:Bool) -> Void in
                        if finished {
                            self.clearSearch()
                            self.contextSearch = .withText
                            self.openSearchProduct()
                        }
                    })
                }
            }else{
                self.clearSearch()
                self.contextSearch = .withText
                self.openSearchProduct()
                
            }
        }
        else{
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT.rawValue, action: WMGAIUtils.ACTION_CANCEL.rawValue, label: "")
            self.closeSearch(false, sender: nil)
        }
    }
    
    /**
        Open edito searching
     
     - parameter notification: notification
     */
    func editSearch(_ notification:Notification){
        let searchKey = notification.object as! String
        self.openSearchProduct()
        self.searchController!.field!.text = searchKey
        self.isEditingSearch = true
    }
    
    /**
      Open controller in order to look for by photo
     
     - parameter notification: notification
     */
    func camFindSearch(_ notification:Notification){
        let searchDic = notification.object as! [String:Any]
        let upcs = searchDic["upcs"] as! [String]
        let keyWord = searchDic["keyWord"] as! String
        let controllernav = self.currentController as? UINavigationController
        
        let controller = SearchProductViewController()
        controller.upcsToShow = upcs
        controller.searchContextType = .withTextForCamFind
        controller.titleHeader = keyWord
        controller.textToSearch = keyWord
        
        if (controllernav?.childViewControllers.last as? SearchViewController) != nil {
            self.onCloseSearch = {
                let navController = self.currentController as? UINavigationController
                let controllersInNavigation = navController?.viewControllers.count
                if (controllersInNavigation > 1 && navController?.viewControllers[controllersInNavigation! - 1] as? SearchProductViewController != nil){
                    navController?.viewControllers.remove(at: controllersInNavigation! - 1)
                    self.isEditingSearch = false
                }
                navController?.pushViewController(controller, animated: true)
            }
            self.btnSearch!.isSelected = true
            self.closeSearch(false, sender: nil)
        }else{
            let controllersInNavigation = controllernav?.viewControllers.count
            if (controllersInNavigation > 2 && controllernav?.viewControllers[controllersInNavigation! - 2] as? SearchProductViewController != nil){
                controllernav?.viewControllers.remove(at: controllersInNavigation! - 2)
                isEditingSearch = false
            }
            controllernav?.pushViewController(controller, animated: true)
        }
        
    }
    /**
     
     */
    func openSearchProduct(){
        if let _ = self.currentController! as? UINavigationController {
            if self.searchController == nil  {
                

                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SEARCH.rawValue, action: WMGAIUtils.ACTION_OPEN_SEARCH_OPTIONS.rawValue, label: "")
                
                if self.imageBlurView != nil {
                    self.imageBlurView?.removeFromSuperview()
                }
                
                self.imageBlurView = nil
                
                self.view.bringSubview(toFront: headerView!)
                container!.clipsToBounds = true
                
                self.btnSearch!.isEnabled = false
                self.btnShopping!.isEnabled = false
                //let current = navController.viewControllers.last as? UIViewController
                let current = self.currentController!
                self.searchController = SearchViewController()
                current.addChildViewController(self.searchController!)
                self.searchController!.didMove(toParentViewController: current)
                self.searchController!.delegate = self
                //            self.searchController!.view.frame = CGRectMake(0,-90, current.view.frame.width, current.view.frame.height)
                self.searchController!.view.frame = CGRect(x: 0,y: current.view.frame.height * -1, width: current.view.frame.width, height: current.view.frame.height)
                self.searchController!.clearSearch()
                self.imageBlurView = self.searchController?.generateBlurImage()
                current.view.addSubview(self.imageBlurView!)
                current.view.addSubview(self.searchController!.view)
                
                UIView.animate(withDuration: 0.6, animations: {() in
                    self.searchController!.view.frame = CGRect(x: 0,y: 0, width: current.view.frame.width, height: current.view.frame.height)
                    self.btnSearch?.setImage(UIImage(named: "close"), for:  UIControlState())
                    }, completion: {(bool : Bool) in
                        if bool {
                            self.btnSearch!.isEnabled = true
                            self.btnShopping!.isEnabled = true
                            self.btnSearch!.isSelected = true
                            self.searchController?.field!.becomeFirstResponder()
                            //                        self.showHelpViewForSearchIfNeeded(current)
                            
                            self.view.sendSubview(toBack: self.headerView!)
                            self.container!.clipsToBounds = false
                                                    }
                })
                
            }
            
        }
    }
    
    var helpView: UIView?
    
    
    func showHelpViewForSearchIfNeeded(_ controller:UIViewController) {
        var requiredHelp = true
        if let param = CustomBarViewController.retrieveParam("searchHelp") {
            requiredHelp = !(param.value == "false")
        }
        
        if requiredHelp && self.helpView == nil {
            let bounds = controller.view.bounds
            
            self.helpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height))
            self.helpView!.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.helpView!.alpha = 0.0
            self.helpView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CustomBarViewController.removeHelpForSearchView)))
            controller.view.addSubview(self.helpView!)
            
            let icon = UIImageView(image: UIImage(named: "search_scan_help"))
            icon.frame = CGRect(x: 189.0, y: 11.0, width: 55.0, height: 48.0)
            self.helpView!.addSubview(icon)
            
            let arrow = UIImageView(image: UIImage(named: "search_scan_arrow_help"))
            arrow.frame = CGRect(x: icon.center.x - 75.0, y: icon.frame.maxY, width: 80.0, height: 36.0)
            self.helpView!.addSubview(arrow)
            
            let message = UILabel(frame: CGRect(x: 16.0, y: arrow.frame.maxY, width: self.view.bounds.width - 88.0, height: 40.0))
            message.numberOfLines = 0
            message.textColor = UIColor.white
            message.textAlignment = .center
            message.font = WMFont.fontMyriadProRegularOfSize(16.0)
            message.text = NSLocalizedString("product.search.scann.help", comment:"")
            self.helpView!.addSubview(message)
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
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
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    self.helpView!.alpha = 0.0
                },
                completion: { (finished:Bool) -> Void in
                    if finished {
                        self.helpView?.removeFromSuperview()
                        self.helpView = nil
                        //self.addOrUpdateParam("searchHelp", value: "false")
                        self.searchController?.field!.becomeFirstResponder()
                    }
                }
            )
        }
    }
    
    //MARK: - SearchViewControllerDelegate
    func closeSearch(_ addShoping:Bool, sender:UIButton?) {
        self.view.bringSubview(toFront: headerView!)
        container!.clipsToBounds = true
        if self.searchController != nil {
            self.btnSearch!.isEnabled = false
            self.btnShopping!.isEnabled = false
            self.searchController!.table.backgroundColor = UIColor.white
            self.searchController!.table.alpha = 0.6
            self.searchController!.viewTapClose?.backgroundColor = UIColor.clear
            
            UIView.animate(withDuration: 0.6,
                animations: {
                    self.helpView?.alpha = 0.0
                    self.searchController!.view.frame = CGRect(x: self.container!.frame.minX, y: -1 * (self.container!.frame.height + self.buttonContainer!.frame.height), width: self.container!.frame.width, height: self.container!.frame.height + self.buttonContainer!.frame.height)
                    self.btnSearch?.setImage(UIImage(named: "navBar_search"), for:  UIControlState())
                    
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
    
    func selectKeyWord(_ keyWord:String, upc:String?, truncate:Bool,upcs:[String]? ){
        if upc != nil {
            let controller = ProductDetailPageViewController()
            controller.idListSeleted  = self.idListSelected
            let useSignalsService : [String:Any] = ["signals" : GRBaseService.getUseSignalServices()]
            let svcValidate = GRProductDetailService(dictionary: useSignalsService)
            
            let upcDesc : NSString = upc! as NSString
            var paddedUPC = upcDesc
            if upcDesc.length < 13 {
                let toFill = "".padding(toLength: 14 - upcDesc.length, withPad: "0", startingAt: 0)
                paddedUPC = "\(toFill)\(paddedUPC)" as NSString
            }
            let params = svcValidate.buildParams(paddedUPC as String, eventtype: "pdpview",stringSearch: "",position: "")//
            svcValidate.callService(requestParams:params, successBlock: { (result:[String:Any]) -> Void in
                controller.itemsToShow = [["upc":paddedUPC,"description":keyWord,"type":ResultObjectType.Groceries.rawValue]]
                
                let controllernav = self.currentController as? UINavigationController
                let controllersInNavigation = controllernav?.viewControllers.count
                if controllersInNavigation > 1 && (controllernav?.viewControllers[controllersInNavigation! - 2] as? ProductDetailPageViewController != nil){
                    controllernav?.viewControllers.remove(at: controllersInNavigation! - 2)
                    self.isEditingSearch = false
                }
                controller.detailOf = "Search results"
                
                    if (controllernav?.childViewControllers.last as? SearchViewController) != nil {
                        self.onCloseSearch = {
                            let navController = self.currentController as? UINavigationController
                            navController?.pushViewController(controller, animated: true)
                        }
                        self.closeSearch(false, sender: nil)
                    }else{
                        controllernav?.pushViewController(controller, animated: true)
                    }
                }, errorBlock: { (error:NSError) -> Void in
                    
                    if upcDesc.length < 14 {
                        let toFill = "".padding(toLength: 14 - upcDesc.length, withPad: "0", startingAt: 0)
                        paddedUPC = "\(toFill)\(upcDesc)" as NSString
                    }
                    
                    controller.itemsToShow = [["upc":paddedUPC,"description":keyWord,"type":ResultObjectType.Mg.rawValue]]
                    let controllernav = self.currentController as? UINavigationController
                    let controllersInNavigation = controllernav?.viewControllers.count
                    if controllersInNavigation > 1 && (controllernav?.viewControllers[controllersInNavigation! - 2] as? ProductDetailPageViewController != nil){
                        controllernav?.viewControllers.remove(at: controllersInNavigation! - 2)
                        self.isEditingSearch = false
                    }
                    controller.detailOf = "Search results"
                    
                    if (controllernav?.childViewControllers.last as? SearchViewController) != nil {
                        self.onCloseSearch = {
                            let navController = self.currentController as? UINavigationController
                            navController?.pushViewController(controller, animated: true)
                        }
                    }else{
                        controllernav?.pushViewController(controller, animated: true)
                    }
                    
                    self.btnSearch!.isSelected = true
                    self.closeSearch(false, sender: nil)
            })
        }
        else{
            
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SEARCH_BY_TAKING_A_PHOTO.rawValue, label: "")
            let controller = SearchProductViewController()
            controller.upcsToShow = upcs
            controller.searchContextType = .withText
            controller.titleHeader = keyWord
            controller.textToSearch = keyWord
            
            let controllernav = self.currentController as? UINavigationController
            if (controllernav?.childViewControllers.last as? SearchViewController) != nil {
                self.onCloseSearch = {
                    let navController = self.currentController as? UINavigationController
                    let controllersInNavigation = navController?.viewControllers.count
                    if controllersInNavigation > 1 && (navController?.viewControllers[controllersInNavigation! - 1] as? SearchProductViewController != nil){
                        navController?.viewControllers.remove(at: controllersInNavigation! - 1)
                        self.isEditingSearch = false
                    }
                    navController?.pushViewController(controller, animated: true)
                }
            }else{
                let controllersInNavigation = controllernav?.viewControllers.count
                if controllersInNavigation > 2 && (controllernav?.viewControllers[controllersInNavigation! - 2] as? SearchProductViewController != nil){
                    controllernav?.viewControllers.remove(at: controllersInNavigation! - 2)
                    isEditingSearch = false
                }
                if controllersInNavigation > 2 && (controllernav?.viewControllers[controllersInNavigation! - 2] as? LandingPageViewController != nil){
                    controllernav?.viewControllers.remove(at: controllersInNavigation! - 2)
                    controllernav?.viewControllers.remove(at: controllersInNavigation! - 3)
                    isEditingSearch = false
                }
                controllernav?.pushViewController(controller, animated: true)
            }
            self.btnSearch!.isSelected = true
            self.closeSearch(false, sender: nil)
        }
    }
    
    
    
    func showProducts(forDepartmentId depto: String?, andFamilyId family: String?, andLineId line: String?, andTitleHeader title:String , andSearchContextType searchContextType:SearchServiceContextType){
        let controller = SearchProductViewController()
        controller.searchContextType = searchContextType
        controller.idFamily  = family == nil ? "_" :  family
        controller.idDepartment = depto == nil ? "_" :  depto
        controller.idLine = line == nil ? "_" :  line
        controller.titleHeader = title
        let controllernav = self.currentController as? UINavigationController
        
        if (controllernav?.childViewControllers.last as? SearchViewController) != nil {
            self.onCloseSearch = {
                let navController = self.currentController as? UINavigationController
                let controllersInNavigation = controllernav?.viewControllers.count
                
                if controllersInNavigation > 1 && (navController?.viewControllers[controllersInNavigation! - 2] as? SearchProductViewController != nil){
                    navController?.viewControllers.remove(at: controllersInNavigation! - 1)
                }
                if controllersInNavigation > 1 && (navController?.viewControllers[controllersInNavigation! - 2] as? LandingPageViewController != nil){
                    navController?.viewControllers.remove(at: controllersInNavigation! - 1)
                    navController?.viewControllers.remove(at: controllersInNavigation! - 2)
                }
                
                navController?.pushViewController(controller, animated: true)
            }
            self.closeSearch(false, sender: nil)
        }else{
            let controllersInNavigation = controllernav?.viewControllers.count
            if controllersInNavigation > 2 && (controllernav?.viewControllers[controllersInNavigation! - 2] as? SearchProductViewController != nil){
                controllernav?.viewControllers.remove(at: controllersInNavigation! - 2)
            }
            if controllersInNavigation > 2 && (controllernav?.viewControllers[controllersInNavigation! - 2] as? LandingPageViewController != nil){
                controllernav?.viewControllers.remove(at: controllersInNavigation! - 2)
                controllernav?.viewControllers.remove(at: controllersInNavigation! - 3)
            }
            
            controllernav?.pushViewController(controller, animated: true)
        }
//        self.btnSearch!.selected = false
//        self.btnSearch!.setImage(UIImage(named: "navBar_search"), forState:  UIControlState.Normal)
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
            controllernav?.viewControllers.remove(at: controllersInNavigation! - 2)
        }
        controllernav?.pushViewController(controller, animated: true)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.btnSearch!.isSelected =  false
        //self.clearSearch()
    }
    
    func clearSearch() {
        self.view.bringSubview(toFront: headerView!)
        container!.clipsToBounds = true
        if self.searchController != nil{
            UIView.animate(withDuration: 0.5,
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
            self.searchController!.willMove(toParentViewController: nil)
            self.searchController!.view.removeFromSuperview()
            self.searchController!.removeFromParentViewController()
            self.searchController = nil
            self.btnSearch!.isEnabled = true
            self.btnShopping!.isEnabled = true
            self.btnSearch!.isSelected = false
            self.onCloseSearch?()
            self.onCloseSearch = nil
        }
    }
    
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    }
    
    func searchControllerScanButtonClicked() {
        let barCodeController = BarCodeViewController()
        barCodeController.searchProduct = true
        self.present(barCodeController, animated: true, completion: nil)
    }
    
    func searchControllerCamButtonClicked(_ controller: CameraViewControllerDelegate!) {
        let cameraController = CameraViewController()
        cameraController.delegate = controller
        self.present(cameraController, animated: true, completion: nil)
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
        
        if mgCheckOutComplete {
            rateFinishShopp()
            mgCheckOutComplete = false
        } else {
            validateCloseShoppingCart()
        }
        
    }
    
    func validateCloseShoppingCart() {
        self.finishOpen =  false
        self.btnShopping?.isSelected = false
        self.btnCloseShopping?.alpha = 0
        self.showBadge()
        self.btnShopping?.alpha = 1
        
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
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MORE_OPTIONS_RELOAD"), object: nil)
    }
    
    func rateFinishShopp(){
        //Validar presentar mensaje
        let showRating = CustomBarViewController.retrieveRateParam(self.KEY_RATING)
        let velue = showRating == nil ? "" :showRating?.value
        
        if UserCurrentSession.sharedInstance.isReviewActive && (velue == "" ||  velue == "true") {
            let alert = IPOWMAlertRatingViewController.showAlertRating(UIImage(named:"rate_the_app"),imageDone:nil,imageError:UIImage(named:"rate_the_app"))
            alert!.isCustomAlert = true
            alert!.spinImage.isHidden =  true
            alert!.setMessage(NSLocalizedString("review.title.like.app", comment: ""))
            alert!.addActionButtonsWithCustomText("No", leftAction: {
                CustomBarViewController.addRateParam(self.KEY_RATING, value: "false")
                alert?.close()
                //regresar a carrito
                self.validateCloseShoppingCart()
                print("Save in data base")
                
                
                ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_I_DONT_LIKE_APP.rawValue , label: "No me gusta la app")
                }, rightText: "Sí", rightAction: {
                    alert?.close()
                    ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_I_LIKE_APP.rawValue , label: "Me gusta la app")
                    self.rankingApp()
                }, isNewFrame: false)
            
            alert!.leftButton.layer.cornerRadius = 20
            alert!.rightButton.layer.cornerRadius = 20
        }else{
            //regresar a carrito
            validateCloseShoppingCart()
        }
        
    }
    
    /**
     Show screen rate with options :
     -review app
     -later or no thanks
     */
    func rankingApp(){
        
        let alert = IPOWMAlertRatingViewController.showAlertRating(UIImage(named:"rate_the_app"),imageDone:nil,imageError:UIImage(named:"rate_the_app"))
        alert!.spinImage.isHidden =  true
        alert!.setMessage(NSLocalizedString("review.description.ok.rate", comment: ""))
        
        alert!.addActionButtonsWithCustomTextRating(NSLocalizedString("review.no.thanks", comment: ""), leftAction: {
            // ---
            CustomBarViewController.addRateParam(self.KEY_RATING, value: "false")
            alert?.close()
            ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_NO_THANKS.rawValue , label: "No gracias")
            //regresar a carrito
            self.validateCloseShoppingCart()
            
            }, rightText: NSLocalizedString("review.maybe.later", comment: ""), rightAction: {
                
                CustomBarViewController.addRateParam(self.KEY_RATING, value: "true")
                alert?.close()
                
                ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_MAYBE_LATER.rawValue , label: "Más tarde")
                //regresar a carrito
                self.validateCloseShoppingCart()
                
                
            }, centerText: NSLocalizedString("review.yes.rate", comment: ""),centerAction: {
                CustomBarViewController.addRateParam(self.KEY_RATING, value: "false")
                alert?.close()
                ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GENERATE_ORDER_OK.rawValue, action:WMGAIUtils.ACTION_RATING_OPEN_APP_STORE.rawValue , label: "Si Claro")
                //regresar a carrito
                self.validateCloseShoppingCart()
                let url  = URL(string: "itms-apps://itunes.apple.com/mx/app/walmart-mexico/id823947897?mt=8")
                if UIApplication.shared.canOpenURL(url!) == true  {
                    UIApplication.shared.openURL(url!)
                }
                
                
        })
        
        alert!.leftButton.backgroundColor = WMColor.regular_blue
        alert!.leftButton.layer.cornerRadius = 20
        
        alert!.rightButton.backgroundColor = WMColor.dark_blue
        alert!.rightButton.layer.cornerRadius = 20
        
        
    }
    
    func showShoppingCart() {
        self.showShoppingCart(self.btnShopping!)
    }
    
    func showShoppingCart(_ sender:UIButton,closeIfNeedded:Bool) {
        if shoppingCartVC != nil {
            if (!sender.isSelected){
                sender.isSelected = !sender.isSelected
                ShoppingCartService.shouldupdate = true
                if (self.btnSearch!.isSelected)  {
                    self.closeSearch(true, sender:nil)
                }else{
                    self.addtoShopingCar()
                }
                self.endUpdatingShoppingCart(self)
                self.hidebadge()
                self.btnShopping?.alpha = 0
                
                if self.btnCloseShopping == nil {
                    self.btnCloseShopping = UIButton()
                    self.btnCloseShopping?.frame = self.btnShopping!.frame
                    self.btnCloseShopping?.setImage(UIImage(named:"close"), for: UIControlState())
                    self.btnCloseShopping?.addTarget(self, action: #selector(CustomBarViewController.showShoppingCart as (CustomBarViewController) -> () -> ()), for: UIControlEvents.touchUpInside)
                    self.btnShopping?.superview?.addSubview(self.btnCloseShopping!)
                    
                }
                self.btnCloseShopping?.isEnabled = false
                self.btnCloseShopping?.alpha = 1
            }
            else {
                if closeIfNeedded {
                    self.closeShoppingCart()
                }
            }
        }
        
    }
    
    @IBAction func showShoppingCart(_ sender:UIButton) {
        self.showShoppingCart(sender,closeIfNeedded:true)
    }
    
    func addtoShopingCar(){
        self.addChildViewController(shoppingCartVC)
        shoppingCartVC.view.frame = CGRect(x: 0, y: 0, width: self.container!.frame.width, height: self.container!.frame.height + 44)
        self.view.addSubview(shoppingCartVC.view)
        self.view.bringSubview(toFront: self.headerView)
        shoppingCartVC.didMove(toParentViewController: self)
        if let vcRoot = shoppingCartVC.viewControllers.first as? PreShoppingCartViewController {
            vcRoot.delegate = self
            self.btnShopping?.isUserInteractionEnabled = false
            vcRoot.finishAnimation = {() -> Void in
                vcRoot.view.addGestureRecognizer(self.gestureCloseShoppingCart)
                self.btnShopping?.isUserInteractionEnabled = true
                self.btnCloseShopping?.isEnabled = true
                self.finishOpen =  true
            }
            vcRoot.openShoppingCart()
        }
        self.view.endEditing(true)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CAR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CAR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PRE_SHOPPING_CART.rawValue, label: "")
    }
    
    
    func returnToView() {
        if shoppingCartVC != nil {
            self.btnShopping!.isSelected = false
            shoppingCartVC.removeFromParentViewController()
            shoppingCartVC.view.removeFromSuperview()
            self.btnShopping?.isUserInteractionEnabled = true
            if (openSearch){
                self.openSearchProduct()
                openSearch = false
            }
        }
        //Tap on Groceries Cart Empty
        if self.emptyGroceriesTap {
            buttonSelected(self.buttonList[2])
            if let navController = self.currentController as? UINavigationController {
                navController.popToRootViewController(animated: false)
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
                navController.popToRootViewController(animated: false)
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
         NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadListFormUpdate"), object: self)
    }
        
        
    
    
    func showBadge() {
        if badgeShoppingCart == nil {
            badgeShoppingCart = BadgeView(frame: CGRect(x: self.view.bounds.width - 24 , y: 20, width: 15, height: 15))
            self.headerView.addSubview(badgeShoppingCart)
        }
        if btnShopping?.isSelected == false {
            self.badgeShoppingCart.alpha = 1
        }
    }
    
    func notificaUpdateBadge(_ notification:Notification){
        if notification.object != nil {
            let params = notification.object as! [String:Any]
            let number = params["quantity"] as! Int
            updateBadge(number)
            self.endUpdatingShoppingCart(notification as AnyObject)
        }
    }
    
    func updateBadge(_ numProducts:Int) {
        DispatchQueue.main.async(execute: {
            self.badgeShoppingCart.updateTitle(numProducts)
            self.badgeShoppingCart.frame = CGRect(x: self.view.bounds.width - 24 , y: 20, width: 15, height: 15)
        });
    }
    
    func userLogOut(_ not:Notification) {
        self.removeAllCookies()
        
        UserCurrentSession.sharedInstance.phoneNumber = ""
        UserCurrentSession.sharedInstance.workNumber =  ""
        UserCurrentSession.sharedInstance.cellPhone = ""
        
        self.viewControllers.removeSubrange(1..<self.viewControllers.count)
        self.createInstanceOfControllers()
        self.buttonSelected(self.buttonList[0])
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CustomBarViewController.sendHomeNotification), userInfo: nil, repeats: false)
    }
    
    func sendHomeNotification(){
        if let navController = self.viewControllers[0] as? UINavigationController {
            navController.popToRootViewController(animated: true)
            self.viewControllers[0] = navController
        }
    }
    
    func removeAllCookies() {
        let storage = HTTPCookieStorage.shared
        var cookies = storage.cookies(for: URL(string: "https://www.walmart.com.mx")!)
        for idx in 0 ..< cookies!.count {
            let cookie = cookies![idx] 
            storage.deleteCookie(cookie)
        }
        cookies =   storage.cookies(for: URL(string: "https://www.walmartmobile.com.mx")!)
        for idx in 0 ..< cookies!.count {
            let cookie = cookies![idx] 
            storage.deleteCookie(cookie)
        }
    }
    
    func startUpdatingShoppingCart(_ sender:AnyObject) {
        self.badgeShoppingCart.isHidden = true
        if imageLoadingCart == nil {
            let imageLoading = UIImage(named:"waiting_cart")
            imageLoadingCart = UIImageView(frame:CGRect(x: self.btnShopping!.frame.minX + 15.5 , y: self.btnShopping!.frame.minY + 4, width: imageLoading!.size.width, height: imageLoading!.size.height))
            imageLoadingCart.image  = imageLoading
            imageLoadingCart.isHidden = true
            imageLoadingCart.center = self.btnShopping!.center
            self.headerView.addSubview(imageLoadingCart)
            runSpinAnimationOnView(imageLoadingCart, duration: 100, rotations: 1, repeats: 100)
            
        }
    }
    
    func endUpdatingShoppingCart(_ sender:AnyObject) {
        self.showBadge()
        if self.imageLoadingCart != nil {
            self.imageLoadingCart.layer.removeAllAnimations()
            self.imageLoadingCart.removeFromSuperview()
            self.imageLoadingCart = nil
        }
    }
    
    func runSpinAnimationOnView(_ view:UIView,duration:CGFloat,rotations:CGFloat,repeats:CGFloat) {
        if btnShopping?.isSelected == false {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = .pi * CGFloat(2.0) * rotations * duration
            rotationAnimation.duration = CFTimeInterval(duration)
            rotationAnimation.isCumulative = true
            rotationAnimation.repeatCount = Float(repeats)
            
            view.layer.add(rotationAnimation, forKey: "rotationAnimation")
            
            if self.imageLoadingCart != nil {
                imageLoadingCart.isHidden = false
            }
        }
        
    }
    
    
    func logoTap(){
        self.buttonSelected(self.buttonList[0])
        self.closeShoppingCart()
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_NAVIGATION_BAR.rawValue, action: WMGAIUtils.ACTION_GO_TO_HOME.rawValue, label: "")
    }
    
    func hidebadge() {
        self.badgeShoppingCart.alpha = 0
    }
    
    func showbadge() {
        if btnShopping?.isSelected == false {
                self.badgeShoppingCart.alpha = 1
        }
    }
    
    
    
    func handleNotification(_ type:String,name:String,value:String,bussines:String) -> Bool {
        //Se elimina el badge de notificaciones
        UIApplication.shared.applicationIconBadgeNumber = 0
        NotificationCenter.default.post(name: .updateNotificationBadge, object: nil)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_NOTIFICATION.rawValue, action: WMGAIUtils.ACTION_PUSH_NOTIFICATION_OPEN.rawValue, label: value)
       return self.handleListNotification(type, name: name, value: value, bussines: bussines, schoolName: "", grade: "")
    }
    
    func handleListNotification(_ type:String,name:String,value:String,bussines:String,schoolName:String,grade:String) -> Bool {
        let trimValue = value.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if type != "CF" {
            if btnShopping!.isSelected {
                closeShoppingCart()
                btnShopping!.isSelected = !btnShopping!.isSelected
            }
        }
        //TODO: Es necesario ver el manejo de groceries para las notificaciones.
        switch(type.trimmingCharacters(in: CharacterSet.whitespaces)) {
        case "": self.buttonSelected(self.buttonList[0])
        case "UPC", "upc": self.selectKeyWord("", upc:trimValue, truncate:true,upcs:nil)
        case "TXT", "txt": self.selectKeyWord(trimValue, upc:nil, truncate:true,upcs:nil)
        case "LIN", "lin": self.showProducts(forDepartmentId: nil, andFamilyId: nil,andLineId: trimValue, andTitleHeader:name == "CP" ? PROMOTION_CENTER: "Recomendados" , andSearchContextType:bussines == "gr" ? .withCategoryForGR : .withCategoryForMG )
        case "FAM", "fam": self.showProducts(forDepartmentId: nil, andFamilyId:trimValue, andLineId: nil, andTitleHeader:"Recomendados" , andSearchContextType:bussines == "gr" ? .withCategoryForGR : .withCategoryForMG)
        case "CAT", "cat": self.showProducts(forDepartmentId: trimValue, andFamilyId:nil, andLineId: nil, andTitleHeader:"Recomendados" , andSearchContextType:bussines == "gr" ? .withCategoryForGR : .withCategoryForMG)
        case "CF", "cf": self.showShoppingCart(self.btnShopping!,closeIfNeedded: false)
        case "WF", "wf": self.buttonSelected(self.buttonList[3])
        case "LIST", "list": self.showProductList(forDepartmentId: nil, andFamilyId: nil, andLineId: trimValue, andTitleHeader: schoolName, andGrade:grade, andSearchContextType: .withCategoryForMG)
        case "URL", "url": self.openURLNotification(trimValue)
        case "SH", "sh":
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
            self.view.bringSubview(toFront: splashVC.view)
        }
        
        return true
    }
    
    /**
     open url from notification, url or app store
     
     - parameter url: url open
     */
    func openURLNotification(_ url:String){

        if url.range(of: "itms-apps:") != nil {
            let urlApp  = URL(string: url)
            if UIApplication.shared.canOpenURL(urlApp!) == true  {
                UIApplication.shared.openURL(urlApp!)
            }
        }else{
            let ctrlWeb = IPOWebViewController()
            ctrlWeb.openURL(url)
            self.present(ctrlWeb, animated: true, completion: nil)
        }
    }
    
    //MARK: Barcode Function
    func scanBarcode(_ notification:Notification){
        let barcodeValue = notification.object as! String
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Barcode.rawValue
        self.idListSelected = ""
        self.selectKeyWord("", upc: barcodeValue, truncate:true,upcs:nil)
    }
    
    //GRA: Help Validation
    func reviewHelp(_ force:Bool) -> Bool {
        var requiredHelp = true
        if let param = CustomBarViewController.retrieveParam("mainHelp") {
            requiredHelp = !(param.value == "false")
        }
        let showTurial = (requiredHelp && self.helpView == nil ) || force
        if showTurial {
            let bounds = self.view.bounds
            
            self.helpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height))
            self.helpView!.backgroundColor = WMColor.light_blue
            self.helpView!.alpha = 0.0
            
            self.view.addSubview(self.helpView!)
            
            
            let imageArray = [["image":"1_tutohelp","details":NSLocalizedString("help.walmart.nowPolis",comment:"")],["image":"ahora_todo_walmart","details":NSLocalizedString("help.walmart.nowallWM",comment:"")],["image":"busca_por_codigo","details":NSLocalizedString("help.walmart.search",comment:"")],["image":"consulta_pedidos_articulos","details":NSLocalizedString("help.walmart.backup",comment:"")],["image":"haz_una_lista","details":NSLocalizedString("help.walmart.list",comment:"")]]
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
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
        if param != nil {
            self.showHelpHome = (appVersion != param!.value)
        }else{
            self.showHelpHome = true
        }
        if self.showHelpHome {
            let helpView = HelpHomeView(frame:CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height))
            helpView.alpha = 0.0
            UIView.animate(withDuration: 0.4, animations: {
                helpView.alpha = 1.0
                }, completion: nil)
            self.view.addSubview(helpView)
            helpView.onClose = {(Void) -> Void in
                CustomBarViewController.addOrUpdateParam("appVersion", value:"\(Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String)",forUser: false)
            }
        }
    }
    
    func updateNotificationBadge(){
        DispatchQueue.main.async(execute: {
            let badgeNumber = UIApplication.shared.applicationIconBadgeNumber
            if  badgeNumber > 0 {
                self.badgeNotification.showBadge(false)
            }
            self.badgeNotification.updateTitle(badgeNumber)
            self.badgeNotification.isHidden = (badgeNumber == 0)
        })
    }
    
    func showHelp() {
        let _ = reviewHelp(true)
    }
}
