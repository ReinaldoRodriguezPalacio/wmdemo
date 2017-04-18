//
//  IPACustomBarViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
/*
enum IPACustomBarNotification : String {
    case HideBar = "kIPACustomBarHideBarNotification"
    case ShowBar = "kIPACustomBarShowBarNotification"
}*/

class IPACustomBarViewController :  CustomBarViewController {
    @IBOutlet var logoImageView: UIImageView!
    
    var vcWishlist : IPAWishlistViewController!
    var viewBgWishlist : UIView!
    
    var selectedBeforeWishlistIx : Int = 0
    
    var isOpenWishlist : Bool = false
    
    var searchView : IPASearchView!
    var searchBackView: UIView!
   
    var camFind : Bool = false

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         NotificationCenter.default.addObserver(self, selector: #selector(IPACustomBarViewController.showHomeSelected), name: .showHomeSelected, object: nil)
        
        self.buttonContainer!.backgroundColor = WMColor.blue
        
        let storyboard = self.loadStoryboardDefinition()
        if let vc = storyboard!.instantiateViewController(withIdentifier: "shoppingCartVC") as? UINavigationController {
            shoppingCartVC = vc
            if let vcRoot = shoppingCartVC.viewControllers.first as? ShoppingCartViewController {
                vcRoot.delegate = self
            }
        }
        
        buttonContainer?.frame = CGRect(x: 0, y: 64, width: 1024, height: 46)
        
        
        self.view.bringSubview(toFront: self.buttonContainer!)
        //self.view.bringSubviewToFront(self.viewSuper)
        self.view.bringSubview(toFront: self.headerView)
        if self.helpView != nil {
            self.view.bringSubview(toFront: self.helpView!)
        }
        
        if updateAviable != nil {
            self.view.bringSubview(toFront: updateAviable)
        }
        self.view.bringSubview(toFront: self.splashVC.view)
        self.searchBackView = UIView()
        self.searchBackView.backgroundColor = UIColor.black
        self.searchBackView.alpha = 0.35
        self.searchBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(IPACustomBarViewController.removePop(_:))))
        
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    func removePop(_ sender:UITapGestureRecognizer) {
        self.searchView.closeSearch()
    }
    
    override func retrieveTabBarOptions() -> [String] {
        //return ["tabBar_home", "tabBar_mg","tabBar_super", "tabBar_wishlist_list","tabBar_menu"]
        return ["home_ipad", "mg_ipad","wishlist_ipad","super_ipad",  "list_ipad","ubicacion_ipad","more_menu_ipad"]
    }
    
   
    
    override func layoutButtons() {
        let space = (320 - (5 * TABBAR_HEIGHT))/7
        var x: CGFloat = ((self.view.bounds.width / 2) - (435 / 2))  + CGFloat(space)
        for button in  self.buttonList {
            button.frame = CGRect(x: x, y: 2, width: TABBAR_HEIGHT, height: TABBAR_HEIGHT)
            //var spacing: CGFloat = 1.0 // the space between the image and text
            //var imageSize: CGSize = button.imageView!.frame.size
            x = button.frame.maxX + space
        }
    }
    
    //La barra no se debe de mover
    /*func hideswipebar(sender:UISwipeGestureRecognizer) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.buttonContainer!.frame = CGRectMake(0, self.headerView!.frame.maxY - ( self.buttonContainer!.frame.height - 8), self.buttonContainer!.frame.width, self.buttonContainer!.frame.height)
            self.container!.frame = CGRectMake(0, self.buttonContainer!.frame.maxY , self.container!.frame.width,  self.view.bounds.height -  self.buttonContainer!.frame.maxY)
        })
    }
    
    func showtabbar(sender:AnyObject) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.buttonContainer!.frame = CGRectMake(0, self.headerView!.frame.maxY , self.buttonContainer!.frame.width, self.buttonContainer!.frame.height)
            self.container!.frame = CGRectMake(0, self.buttonContainer!.frame.maxY , self.container!.frame.width, self.view.bounds.height -  self.buttonContainer!.frame.maxY)
        })
    }*/
    
    override func editSearch(_ notification:Notification){
        let searchKey = notification.object as! String
        self.openSearchProduct()
        self.searchView.field.text = searchKey
        self.isEditingSearch = true
    }
    
   
    
    override func camFindSearch(_ notification:Notification){
        let searchDic = notification.object as! [String:Any]
        let upcs = searchDic["upcs"] as! [String]
        let keyWord = searchDic["keyWord"] as! String
        let controller = IPASearchProductViewController()
        contextSearch = .withTextForCamFind
        controller.searchContextType = .withTextForCamFind
        controller.titleHeader = keyWord
        controller.textToSearch = keyWord
        controller.upcsToShow = upcs
        let controllernav = self.currentController as? UINavigationController
        if (controllernav?.topViewController as? IPASearchProductViewController != nil){
            let _ = controllernav?.popViewController(animated: false)
            
            isEditingSearch = false
        }
        if ((controllernav?.topViewController as? IPAWishlistViewController) != nil) {
            isOpenWishlist = false
            self.buttonList[2].isSelected = isOpenWishlist
            if  self.vcWishlist != nil {
                self.vcWishlist.view.frame = CGRect(x: 0, y: -self.vcWishlist.view.frame.height, width: self.vcWishlist.view.frame.width, height: self.vcWishlist.view.frame.height)
                self.viewBgWishlist.alpha = 0
                self.buttonList[self.selectedBeforeWishlistIx].isSelected = !self.isOpenWishlist
                self.vcWishlist.view.removeFromSuperview()
                self.vcWishlist.removeFromParentViewController()
                self.viewBgWishlist.removeFromSuperview()
                self.vcWishlist = nil
            }
            
        }
        if controllernav != nil {
            if controllernav!.delegate != nil {
                controllernav!.delegate = nil
            }
            controllernav?.pushViewController(controller, animated: true)
        }

    }
    
    override func openSearchProduct(){
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SEARCH.rawValue, action: WMGAIUtils.ACTION_OPEN_SEARCH_OPTIONS.rawValue, label: "")
        
        if (self.btnShopping!.isSelected){
            if let vcRoot = shoppingCartVC.viewControllers.first as? ShoppingCartViewController {
                vcRoot.delegate = self
                vcRoot.closeShoppingCart()
            }
        }
        
        searchView = IPASearchView(frame: CGRect(x: self.btnSearch!.frame.minX,y: 20,width: 350,height: self.headerView.frame.height - 20))
        searchView.clipsToBounds = true
        searchView.delegate = self
        searchView.camfine =  contextSearch == SearchServiceContextType.withTextForCamFind ? true : false
        searchView.viewContent.clipsToBounds = true
        searchView.viewContent.frame = CGRect(x: 40,y: searchView.viewContent.frame.minY,width: searchView.frame.width - 40,height: self.btnSearch!.frame.height)
        self.headerView.addSubview(searchView)
        
        searchView.closeanimation =  {() -> Void in
            self.searchBackView.removeFromSuperview()
            self.btnSearch!.alpha = 1.0
            self.btnSearch!.frame = CGRect(x: 0,y: self.btnSearch!.frame.minY,width: self.btnSearch!.frame.width,height: self.btnSearch!.frame.height)
            self.searchView = nil
            self.btnSearch!.isSelected = false
        }
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.btnSearch!.alpha = 0.0
            }, completion: { (com:Bool) -> Void in
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    if self.searchView != nil {
                        self.searchView.field.frame = CGRect(x: 0,y: self.searchView.field.frame.minY,width: self.searchView.field.frame.width,height: self.searchView.field.frame.height)
                        //searchView.viewContent.frame = CGRectMake(0,searchView.viewContent.frame.minY, searchView.frame.width - searchView.viewContent.frame.minX ,self.btnSearch!.frame.height)
                    }
                    }, completion: { (complete:Bool) -> Void in
                        UIView.animate(withDuration: 0.2, animations: { () -> Void in
                            if self.searchView != nil {
                                self.searchView.backButton.alpha = 1
                                self.searchView.viewContent.clipsToBounds = false
                                self.searchView.clipsToBounds = false
                            }
                        })
                        
                }) 
                self.searchBackView.frame = CGRect(x: 0, y: 65, width: self.view!.frame.width, height: self.view!.frame.height - 65)
                self.view.addSubview(self.searchBackView)
        }) 
    }

    override func selectKeyWord(_ keyWord:String, upc:String?, truncate:Bool,upcs:[String]?){
        if upc != nil {
            let contDetail = IPAProductDetailPageViewController()
            contDetail.idListSeleted = self.idListSelected
            //contDetail.upc = upc!
            let useSignalsService : [String:Any] = ["signals" : GRBaseService.getUseSignalServices()]
            let svcValidate = GRProductDetailService(dictionary: useSignalsService)
            //let svcValidate = GRProductDetailService()
            
            let upcDesc : NSString = upc! as NSString
            var paddedUPC = upcDesc
            if upcDesc.length < 13 {
                let toFill = "".padding(toLength: 14 - upcDesc.length, withPad: "0", startingAt: 0)
                paddedUPC = "\(toFill)\(paddedUPC)" as NSString
            }
            let params = svcValidate.buildParams(paddedUPC as String, eventtype: "pdpview",stringSearch: "",position:"")//position
            svcValidate.callService(requestParams:params, successBlock: { (result:[String:Any]) -> Void in
                contDetail.itemsToShow = [["upc":paddedUPC,"description":keyWord,"type":ResultObjectType.Groceries.rawValue]]
                contDetail.detailOf = "Search results"
                let controllernav = self.currentController as? UINavigationController
                if (controllernav?.topViewController as? IPAProductDetailPageViewController != nil){
                    controllernav?.delegate = contDetail
                }
                  controllernav?.pushViewController(contDetail, animated: true)
                }, errorBlock: { (error:NSError) -> Void in
                    if upcDesc.length < 14 {
                        let toFill = "".padding(toLength: 14 - upcDesc.length, withPad: "0", startingAt: 0)
                        paddedUPC = "\(toFill)\(upcDesc)" as NSString
                    }
                    contDetail.itemsToShow = [["upc":paddedUPC,"description":keyWord,"type":ResultObjectType.Mg.rawValue]]
                    let controllernav = self.currentController as? UINavigationController
                    if (controllernav?.topViewController as? IPAProductDetailPageViewController != nil){
                        controllernav?.delegate = contDetail
                    }
                    contDetail.detailOf = "Search results"
                    controllernav?.pushViewController(contDetail, animated: true)
            })
        }
        else{
            let controller = IPASearchProductViewController()
            controller.searchContextType = .withText
            controller.titleHeader = keyWord
            controller.textToSearch = keyWord
            let controllernav = self.currentController as? UINavigationController
            if (controllernav?.topViewController as? IPASearchProductViewController != nil){
                let _ = controllernav?.popViewController(animated: false)

                isEditingSearch = false
            }
            if ((controllernav?.topViewController as? IPAWishlistViewController) != nil) {
                isOpenWishlist = false
                self.buttonList[2].isSelected = isOpenWishlist
                if  self.vcWishlist != nil {
                    self.vcWishlist.view.frame = CGRect(x: 0, y: -self.vcWishlist.view.frame.height, width: self.vcWishlist.view.frame.width, height: self.vcWishlist.view.frame.height)
                    self.viewBgWishlist.alpha = 0
                    self.buttonList[self.selectedBeforeWishlistIx].isSelected = !self.isOpenWishlist
                    self.vcWishlist.view.removeFromSuperview()
                    self.vcWishlist.removeFromParentViewController()
                    self.viewBgWishlist.removeFromSuperview()
                    self.vcWishlist = nil
                }

            }
            if controllernav != nil {
                if controllernav!.delegate != nil {
                    controllernav!.delegate = nil
                }
                controllernav?.pushViewController(controller, animated: true)
            }
        }
        self.btnSearch!.isSelected = false
    }
    
    override func showProducts(forDepartmentId depto: String?, andFamilyId family: String?, andLineId line: String?, andTitleHeader title:String , andSearchContextType searchContextType:SearchServiceContextType){
        let controller = IPASearchProductViewController()
        controller.searchContextType = searchContextType
        controller.idFamily  = family == nil ? "_" :  family
        controller.idDepartment = depto == nil ? "_" :  depto
        controller.idLine = line == nil ? "_" :  line
        controller.titleHeader = title
        controller.searchFromContextType = SearchServiceFromContext.fromSearchTextSelect
        let controllernav = self.currentController as? UINavigationController
        if (controllernav?.topViewController as? IPASearchProductViewController != nil){
            let _ = controllernav?.popViewController(animated: false)
            
            isEditingSearch = false
        }
        if controllernav != nil {
            if controllernav!.delegate != nil {
                controllernav!.delegate = nil
            }
            controllernav?.pushViewController(controller, animated: true)
        }
        self.btnSearch!.isSelected = true
        self.closeSearch(false, sender: nil)
    }
    
    
    override func createInstanceOfControllers() {
        let storyboard = self.loadStoryboardDefinition()
     
         let controllerIdentifiers : [String] = ["categoriesVC", "wishlistVC","GRCategoriesVC", "userListsVC", "storeLocatorVC","moreVC"] // "profileVC",
        
        for item in controllerIdentifiers {
            let components = item.components(separatedBy: "-")
            let strController = components[0] as String
            let vc = storyboard!.instantiateViewController(withIdentifier: strController)
                if let navVC = vc as? UINavigationController {
                    if let loginVC = navVC.viewControllers.first as? IPALoginController {
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

    
    override func buttonSelected(_ sender:UIButton) {
        let index = self.buttonList.index(of: sender)
        if index == 2 {
            sender.isSelected = !isOpenWishlist
            if !self.isOpenWishlist {
                if self.viewBgWishlist == nil {
                    self.viewBgWishlist = UIView(frame: self.currentController!.view.bounds)
                    self.viewBgWishlist.isUserInteractionEnabled = true
                    self.viewBgWishlist.alpha = 0
                    self.viewBgWishlist.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                    
                    self.viewBgWishlist.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(IPACustomBarViewController.didTapHideWhishList)))
                    
                    let gestureSwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(IPACustomBarViewController.didTapHideWhishList))
                    gestureSwipeUp.direction = UISwipeGestureRecognizerDirection.up
                    self.viewBgWishlist.addGestureRecognizer(gestureSwipeUp)
                }
                
                if let vcwishlist = storyboard!.instantiateViewController(withIdentifier: "wishlistVC") as? IPAWishlistViewController {
                    vcWishlist = vcwishlist
                    vcWishlist.closewl = {() in
                        self.closeWishList()
                    }
                    BaseController.setOpenScreenTagManager(titleScreen: "wishlist", screenName: "WishList")
                    self.currentController?.addChildViewController(vcWishlist)
                    vcWishlist.view.frame = CGRect(x: 0, y: -270, width: 1024,height: 334)
                    self.currentController?.view.addSubview(vcWishlist.view)
                    vcWishlist.registerNotification()
                    let gestureSwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(IPACustomBarViewController.didTapHideWhishList))
                    gestureSwipeUp.direction = UISwipeGestureRecognizerDirection.up
                    vcWishlist.view.addGestureRecognizer(gestureSwipeUp)
                }
                
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.vcWishlist.view.frame = CGRect(x: 0, y: 0, width: self.vcWishlist.view.frame.width, height: self.vcWishlist.view.frame.height)
                    self.viewBgWishlist.alpha = 1
                    self.currentController?.view.addSubview(self.viewBgWishlist)
                    self.currentController?.view.bringSubview(toFront: self.vcWishlist.view)
                    self.isOpenWishlist = true
                    self.buttonList[self.selectedBeforeWishlistIx].isSelected = !self.isOpenWishlist
                })
            }
            else {
                self.closeWishList()
            }
            
            return
        }
        
        if self.isOpenWishlist {
            self.closeWishList()
        }
        
        self.selectedBeforeWishlistIx = index!
       
//        if index == 5 &&  UserCurrentSession.sharedInstance.userSigned == nil{
//            var cont = IPALoginController.showLogin()
//            cont!.successCallBack = {() in
//                if cont.alertView != nil {
//                    cont!.closeAlert(true, messageSucesss: true)
//                }else {
//                    cont!.closeModal()
//                }
//                self.buttonSelected(sender)
//                cont = nil
//            }
//            return
//        }
        
        let controller = self.viewControllers[index!]
        if controller === self.currentController {
            //let controllerIdentifiers : [String] = ["categoriesVC","wishlitsVC","profileVC","moreVC"]
            let controllerIdentifiers : [String] = ["categoriesVC","wishlistVC","GRCategoriesVC",  "userListsVC","storeLocatorVC","moreVC"]//, "profileVC"
            
            if let navController = self.currentController as? UINavigationController {
                if index! > 0 {
                    let newIndex = index! - 1
                    let vc = storyboard!.instantiateViewController(withIdentifier: controllerIdentifiers[newIndex])
                        
                        self.displayContentController(vc)
                        if self.currentController != nil  {
                            self.hideContentController(navController)
                        }
                        self.currentController?.removeFromParentViewController()
                        self.currentController?.view.removeFromSuperview()
                        self.currentController = nil
                        self.currentController = vc
                        self.viewControllers[index!] = vc
                }
                else {
                    super.buttonSelected(sender)
                }
            }
            return
        }
        else {
            super.buttonSelected(sender)
        }
        
    }
    
   
    func closeWishList() {

        self.buttonList[2].isSelected = !isOpenWishlist
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            if  self.vcWishlist != nil {
                self.vcWishlist.view.frame = CGRect(x: 0, y: -self.vcWishlist.view.frame.height, width: self.vcWishlist.view.frame.width, height: self.vcWishlist.view.frame.height)
                self.viewBgWishlist.alpha = 0
                self.buttonList[self.selectedBeforeWishlistIx].isSelected = self.isOpenWishlist
            }
            }, completion: { (complete:Bool) -> Void in
                if  self.vcWishlist != nil {
                    self.vcWishlist.view.removeFromSuperview()
                    self.vcWishlist.removeFromParentViewController()
                    self.viewBgWishlist.removeFromSuperview()
                    self.vcWishlist = nil
                    self.isOpenWishlist = false
                }
        })
    }
    
    func didTapHideWhishList() {
        buttonSelected(self.buttonList[2])
    }
    
    override func addtoShopingCar() {
        self.view.endEditing(true)
        if self.searchView != nil {
            self.searchView.viewContent.clipsToBounds = true
            self.searchView.clipsToBounds = true
            self.searchView!.closeSearch()
        }
        
        self.addChildViewController(shoppingCartVC)
        shoppingCartVC.view.frame = CGRect(x: 0,y: self.buttonContainer!.frame.minY,width: self.container!.frame.width,height: self.container!.frame.height + self.buttonContainer!.frame.height )
        self.view.addSubview(shoppingCartVC.view)
        self.view.bringSubview(toFront: self.headerView)
        shoppingCartVC.didMove(toParentViewController: self)
        shoppingCartVC.view.backgroundColor = UIColor.clear
        if let vcRoot = shoppingCartVC.viewControllers.first as? IPAPreShoppingCartViewController {
            vcRoot.delegate = self
            vcRoot.openShoppingCart()
            vcRoot.view.isUserInteractionEnabled = false
            vcRoot.finishAnimation = {() -> Void in
                print("")
                vcRoot.view.addGestureRecognizer(self.gestureCloseShoppingCart)
                self.btnShopping?.isUserInteractionEnabled = true
                self.btnCloseShopping?.isEnabled = true
                vcRoot.view.isUserInteractionEnabled = true
            }
            
//            self.btnShopping?.userInteractionEnabled = true
//            self.btnCloseShopping?.enabled = true
            
        }

    }


    override func searchControllerScanButtonClicked() {
        let barCodeController = IPABarCodeViewController()
        barCodeController.searchProduct = true
        
        self.present(barCodeController, animated: true, completion: nil)
    }
    
    override func returnToView() {
        
        self.btnShopping?.isSelected = false
        self.btnCloseShopping?.alpha = 0
        self.showBadge()
        self.btnShopping?.alpha = 1

        
        if shoppingCartVC != nil {
            self.btnShopping!.isSelected = false
            shoppingCartVC.removeFromParentViewController()
            shoppingCartVC.view.removeFromSuperview()
            self.btnShopping?.isUserInteractionEnabled = true
            if (openSearch){
                if !camFind{
                self.openSearchProduct()
                
                openSearch = false
            }
            }
        }
        //Tap on Groceries Cart Empty
        if self.emptyGroceriesTap {
            buttonSelected(self.buttonList[3])
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
    
    override func userLogOut(_ not:Notification) {
        self.removeAllCookies()
        self.removeChildViewControllers(self.viewControllers[0].childViewControllers)
        self.closeWishList()
        if let navController = self.viewControllers[0] as? UINavigationController {
            let vc = storyboard!.instantiateViewController(withIdentifier: "homeVC")
            navController.popToRootViewController(animated: false)
            navController.viewControllers[0] = vc
            self.viewControllers[0] = navController
        }
        self.buttonSelected(self.buttonList[0])
        self.viewControllers.removeSubrange(1..<self.viewControllers.count)
        self.createInstanceOfControllers()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CustomBarViewController.sendHomeNotification), userInfo: nil, repeats: false)
    }
    
    func removeChildViewControllers(_ controllers:[UIViewController]) {
        var count = 0
        for controller in controllers {
            if count == 0 {
                count += 1
                continue
            }
            count += 1
            controller.willMove(toParentViewController: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParentViewController()
        }
    }
    
    override func sendHomeNotification(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: UpdateNotification.HomeUpdateServiceEnd.rawValue), object: nil)
    }
    
    override func showListsGR() {
        buttonSelected(self.buttonList[4])
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadListFormUpdate"), object: self)
    }
   
    override func handleNotification(_ type:String,name:String,value:String,bussines:String) -> Bool {
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
        case "LIN", "lin": self.showProducts(forDepartmentId: nil, andFamilyId: nil,andLineId: trimValue, andTitleHeader:name == "CP" ? "Centro de promociones": "Recomendados" , andSearchContextType:bussines == "gr" ? .withCategoryForGR : .withCategoryForMG )
        case "FAM", "fam": self.showProducts(forDepartmentId: nil, andFamilyId:trimValue, andLineId: nil, andTitleHeader:"Recomendados" , andSearchContextType:bussines == "gr" ? .withCategoryForGR : .withCategoryForMG)
        case "CAT", "cat": self.showProducts(forDepartmentId: trimValue, andFamilyId:nil, andLineId: nil, andTitleHeader:"Recomendados" , andSearchContextType:bussines == "gr" ? .withCategoryForGR : .withCategoryForMG)
        case "CF", "cf": self.showShoppingCart(self.btnShopping!,closeIfNeedded: false)
        case "WF", "wf": self.buttonSelected(self.buttonList[4])
        case "URL", "url": self.openURLNotification(trimValue)
        case "LIST", "list": self.showProductList(forDepartmentId: nil, andFamilyId: nil, andLineId: trimValue, andTitleHeader: "",andGrade:"", andSearchContextType: .withCategoryForMG)
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
        
         self.btnSearch?.isSelected =  false
        
        return true
    }
    
    override func showProductList(forDepartmentId depto: String?, andFamilyId family: String?, andLineId line: String?, andTitleHeader title:String, andGrade grade:String, andSearchContextType searchContextType:SearchServiceContextType){
        let controller = IPASchoolListViewController()
        controller.familyId  = family ?? "_"
        controller.departmentId = depto ??  "_"
        controller.lineId = line ?? "_"
        controller.schoolName = title
        controller.gradeName = grade
        controller.showInPopover = true
        controller.showWishList = false
        controller.view.backgroundColor = UIColor.white
        
        let controllernav = self.currentController as? UINavigationController
        controller.parentNavigationController = controllernav
        controllernav?.pushViewController(controller, animated: true)
        
    }

    func showHomeSelected(){
        self.buttonList[0].isSelected = true
    }
    
    override func showHelpHomeView(){
        let param = CustomBarViewController.retrieveParam("appVersion", forUser: false)
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
        if param != nil {
            self.showHelpHome = (appVersion != param!.value)
        }else{
            self.showHelpHome = true
        }
        if self.showHelpHome {
            DispatchQueue.main.async(execute: {
                let helpView = IPAHelpHomeView.initView()
                helpView.showView()
                helpView.onClose = {(Void) -> Void in
                    CustomBarViewController.addOrUpdateParam("appVersion", value:"\(Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String)",forUser: false)
                }
            })
        }
    }

}
