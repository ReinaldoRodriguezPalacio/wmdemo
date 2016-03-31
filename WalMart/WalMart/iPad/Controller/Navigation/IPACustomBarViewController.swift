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
        
        self.buttonContainer!.backgroundColor = WMColor.blue
        
        let storyboard = self.loadStoryboardDefinition()
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("shoppingCartVC") as? UINavigationController {
            shoppingCartVC = vc
            if let vcRoot = shoppingCartVC.viewControllers.first as? ShoppingCartViewController {
                vcRoot.delegate = self
            }
        }
        
        buttonContainer?.frame = CGRectMake(0, 64, 1024, 46)
        
        
        self.view.bringSubviewToFront(self.buttonContainer!)
        //self.view.bringSubviewToFront(self.viewSuper)
        self.view.bringSubviewToFront(self.headerView)
        if self.helpView != nil {
            self.view.bringSubviewToFront(self.helpView!)
        }
        
        if updateAviable != nil {
            self.view.bringSubviewToFront(updateAviable)
        }
        self.view.bringSubviewToFront(self.splashVC.view)
        self.searchBackView = UIView()
        self.searchBackView.backgroundColor = UIColor.blackColor()
        self.searchBackView.alpha = 0.35
        self.searchBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "removePop:"))
        
    }
    
    func removePop(sender:UITapGestureRecognizer) {
        self.searchView.closeSearch()
    }
    
    override func retrieveTabBarOptions() -> [String] {
        //return ["tabBar_home", "tabBar_mg","tabBar_super", "tabBar_wishlist_list","tabBar_menu"]
        return ["home_ipad", "mg_ipad","wishlist_ipad","super_ipad",  "list_ipad","ubicacion_ipad","more_menu_ipad"]
    }
    
    override func setTabBarHidden(hidden:Bool, animated:Bool, delegate:CustomBarDelegate?) -> Void {
    }
    
    override func hideTabBar(notification:NSNotification) {
        // EN IPAD NO SE VA A ESCONDER LA BARRA CON EL SCROLL
        //self.setTabBarHidden(true, animated: true, delegate:notification.object as CustomBarDelegate?)
    }
    
    override func showTabBar(notification:NSNotification) {
        //self.setTabBarHidden(false, animated: true, delegate:notification.object as CustomBarDelegate?)
    }
    
    override func layoutButtons() {
        let space = (320 - (5 * TABBAR_HEIGHT))/7
        var x: CGFloat = ((self.view.bounds.width / 2) - (435 / 2))  + CGFloat(space)
        for button in  self.buttonList {
            button.frame = CGRectMake(x, 2, TABBAR_HEIGHT, TABBAR_HEIGHT)
            //var spacing: CGFloat = 1.0 // the space between the image and text
            //var imageSize: CGSize = button.imageView!.frame.size
            x = CGRectGetMaxX(button.frame) + space
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
    
    override func editSearch(notification:NSNotification){
        let searchKey = notification.object as! String
        self.openSearchProduct()
        self.searchView.field.text = searchKey
        self.isEditingSearch = true
    }
    
   
    
    override func camFindSearch(notification:NSNotification){
        let searchDic = notification.object as! [String:AnyObject]
        let upcs = searchDic["upcs"] as! [String]
        let keyWord = searchDic["keyWord"] as! String
        let controller = IPASearchProductViewController()
        contextSearch = .WithTextForCamFind
        controller.searchContextType = .WithTextForCamFind
        controller.titleHeader = keyWord
        controller.textToSearch = keyWord
        controller.upcsToShow = upcs
        let controllernav = self.currentController as? UINavigationController
        if (controllernav?.topViewController as? IPASearchProductViewController != nil){
            controllernav?.popViewControllerAnimated(false)
            
            isEditingSearch = false
        }
        if ((controllernav?.topViewController as? IPAWishlistViewController) != nil) {
            isOpenWishlist = false
            self.buttonList[2].selected = isOpenWishlist
            if  self.vcWishlist != nil {
                self.vcWishlist.view.frame = CGRectMake(0, -self.vcWishlist.view.frame.height, self.vcWishlist.view.frame.width, self.vcWishlist.view.frame.height)
                self.viewBgWishlist.alpha = 0
                self.buttonList[self.selectedBeforeWishlistIx].selected = !self.isOpenWishlist
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
        

        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SEARCH.rawValue, action: WMGAIUtils.ACTION_OPEN_SEARCH_OPTIONS.rawValue, label: "")
        
        if (self.btnShopping!.selected){
            if let vcRoot = shoppingCartVC.viewControllers.first as? ShoppingCartViewController {
                vcRoot.delegate = self
                vcRoot.closeShoppingCart()
            }
        }
        
        searchView = IPASearchView(frame: CGRectMake(self.btnSearch!.frame.minX,20,350,self.headerView.frame.height - 20))
        searchView.clipsToBounds = true
        searchView.delegate = self
        searchView.camfine =  contextSearch == SearchServiceContextType.WithTextForCamFind ? true : false
        searchView.viewContent.clipsToBounds = true
        searchView.viewContent.frame = CGRectMake(40,searchView.viewContent.frame.minY,searchView.frame.width - 40,self.btnSearch!.frame.height)
        self.headerView.addSubview(searchView)
        
        searchView.closeanimation =  {() -> Void in
            self.searchBackView.removeFromSuperview()
            self.btnSearch!.alpha = 1.0
            self.btnSearch!.frame = CGRectMake(0,self.btnSearch!.frame.minY,self.btnSearch!.frame.width,self.btnSearch!.frame.height)
            self.searchView = nil
        }
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.btnSearch!.alpha = 0.0
            }) { (com:Bool) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    if self.searchView != nil {
                        self.searchView.field.frame = CGRectMake(0,self.searchView.field.frame.minY,self.searchView.field.frame.width,self.searchView.field.frame.height)
                        //searchView.viewContent.frame = CGRectMake(0,searchView.viewContent.frame.minY, searchView.frame.width - searchView.viewContent.frame.minX ,self.btnSearch!.frame.height)
                    }
                    }) { (complete:Bool) -> Void in
                        UIView.animateWithDuration(0.2, animations: { () -> Void in
                            if self.searchView != nil {
                                self.searchView.backButton.alpha = 1
                                self.searchView.viewContent.clipsToBounds = false
                                self.searchView.clipsToBounds = false
                            }
                        })
                        
                }
                self.searchBackView.frame = CGRectMake(0, 65, self.view!.frame.width, self.view!.frame.height - 65)
                self.view.addSubview(self.searchBackView)
        }
    }

    override func selectKeyWord(keyWord:String, upc:String?, truncate:Bool,upcs:[String]?){
        if upc != nil {
           
            
            let contDetail = IPAProductDetailPageViewController()
            //contDetail.upc = upc!
            let useSignalsService : NSDictionary = NSDictionary(dictionary: ["signals" : GRBaseService.getUseSignalServices()])
            let svcValidate = GRProductDetailService(dictionary: useSignalsService)
            //let svcValidate = GRProductDetailService()
            
            let upcDesc : NSString = upc! as NSString
            var paddedUPC = upcDesc
            if upcDesc.length < 13 {
                let toFill = "".stringByPaddingToLength(13 - upcDesc.length, withString: "0", startingAtIndex: 0)
                paddedUPC = "\(toFill)\(paddedUPC)"
            }
            let params = svcValidate.buildParams(paddedUPC as String, eventtype: "pdpview")
            svcValidate.callService(requestParams:params, successBlock: { (result:NSDictionary) -> Void in
                contDetail.itemsToShow = [["upc":paddedUPC,"description":keyWord,"type":ResultObjectType.Groceries.rawValue]]
                let controllernav = self.currentController as? UINavigationController
                if (controllernav?.topViewController as? IPAProductDetailPageViewController != nil){
                    controllernav?.popViewControllerAnimated(false)
                    self.isEditingSearch = false
                }

                controllernav?.pushViewController(contDetail, animated: true)
                
                }, errorBlock: { (error:NSError) -> Void in
                    
                    if upcDesc.length < 14 {
                        let toFill = "".stringByPaddingToLength(14 - upcDesc.length, withString: "0", startingAtIndex: 0)
                        paddedUPC = "\(toFill)\(upcDesc)"
                    }
                    
                    contDetail.itemsToShow = [["upc":paddedUPC,"description":keyWord,"type":ResultObjectType.Mg.rawValue]]
                    let controllernav = self.currentController as? UINavigationController
                    //if (controllernav?.topViewController as? IPAProductDetailPageViewController != nil){
                    //    controllernav?.popViewControllerAnimated(false)
                    //    self.isEditingSearch = false
                    //}

                    controllernav?.pushViewController(contDetail, animated: true)
            })
        }
        else{
            
            
            
            let controller = IPASearchProductViewController()
            controller.searchContextType = .WithText
            controller.titleHeader = keyWord
            controller.textToSearch = keyWord
            let controllernav = self.currentController as? UINavigationController
            if (controllernav?.topViewController as? IPASearchProductViewController != nil){
                controllernav?.popViewControllerAnimated(false)
                
                isEditingSearch = false
            }
            if ((controllernav?.topViewController as? IPAWishlistViewController) != nil) {
                isOpenWishlist = false
                self.buttonList[2].selected = isOpenWishlist
                if  self.vcWishlist != nil {
                    self.vcWishlist.view.frame = CGRectMake(0, -self.vcWishlist.view.frame.height, self.vcWishlist.view.frame.width, self.vcWishlist.view.frame.height)
                    self.viewBgWishlist.alpha = 0
                    self.buttonList[self.selectedBeforeWishlistIx].selected = !self.isOpenWishlist
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
        self.btnSearch!.selected = false
    }
    
    
    override func createInstanceOfControllers() {
        let storyboard = self.loadStoryboardDefinition()
     
         let controllerIdentifiers : [String] = ["categoriesVC", "wishlistVC","GRCategoriesVC", "userListsVC", "storeLocatorVC","moreVC"] // "profileVC",
        
        for item in controllerIdentifiers {
            let components = item.componentsSeparatedByString("-")
            let strController = components[0] as String
            let vc = storyboard!.instantiateViewControllerWithIdentifier(strController)
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

    
    override func buttonSelected(sender:UIButton) {
        let index = self.buttonList.indexOf(sender)
        if index == 2 {
            sender.selected = !isOpenWishlist
            if !self.isOpenWishlist {
                self.isOpenWishlist = true
                if self.viewBgWishlist == nil {
                    self.viewBgWishlist = UIView(frame: self.currentController!.view.bounds)
                    self.viewBgWishlist.userInteractionEnabled = true
                    self.viewBgWishlist.alpha = 0
                    self.viewBgWishlist.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
                    
                    self.viewBgWishlist.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapHideWhishList"))
                    
                    let gestureSwipeUp = UISwipeGestureRecognizer(target: self, action: "didTapHideWhishList")
                    gestureSwipeUp.direction = UISwipeGestureRecognizerDirection.Up
                    self.viewBgWishlist.addGestureRecognizer(gestureSwipeUp)
                }
                
                if let vcwishlist = storyboard!.instantiateViewControllerWithIdentifier("wishlistVC") as? IPAWishlistViewController {
                    vcWishlist = vcwishlist
                    vcWishlist.closewl = {() in
                        self.closeWishList()
                    }
                    self.currentController?.addChildViewController(vcWishlist)
                    vcWishlist.view.frame = CGRectMake(0, -270, 1024,334)
                    self.currentController?.view.addSubview(vcWishlist.view)
                    vcWishlist.registerNotification()
                    let gestureSwipeUp = UISwipeGestureRecognizer(target: self, action: "didTapHideWhishList")
                    gestureSwipeUp.direction = UISwipeGestureRecognizerDirection.Up
                    vcWishlist.view.addGestureRecognizer(gestureSwipeUp)
                }
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.vcWishlist.view.frame = CGRectMake(0, 0, self.vcWishlist.view.frame.width, self.vcWishlist.view.frame.height)
                    self.viewBgWishlist.alpha = 1
                    self.currentController?.view.addSubview(self.viewBgWishlist)
                    self.currentController?.view.bringSubviewToFront(self.vcWishlist.view)
                    self.buttonList[self.selectedBeforeWishlistIx].selected = !self.isOpenWishlist
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
       
//        if index == 5 &&  UserCurrentSession.sharedInstance().userSigned == nil{
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
                    let vc = storyboard!.instantiateViewControllerWithIdentifier(controllerIdentifiers[newIndex])
                        
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
        isOpenWishlist = false
        self.buttonList[2].selected = isOpenWishlist
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            if  self.vcWishlist != nil {
                self.vcWishlist.view.frame = CGRectMake(0, -self.vcWishlist.view.frame.height, self.vcWishlist.view.frame.width, self.vcWishlist.view.frame.height)
                self.viewBgWishlist.alpha = 0
                
                
                self.buttonList[self.selectedBeforeWishlistIx].selected = !self.isOpenWishlist
            }
            }, completion: { (complete:Bool) -> Void in
                if  self.vcWishlist != nil {
                    self.vcWishlist.removeNotification()
                    self.vcWishlist.view.removeFromSuperview()
                    self.vcWishlist.removeFromParentViewController()
                    self.viewBgWishlist.removeFromSuperview()
                    self.vcWishlist = nil
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
        shoppingCartVC.view.frame = CGRectMake(0,self.buttonContainer!.frame.minY,self.container!.frame.width,self.container!.frame.height + self.buttonContainer!.frame.height )
        self.view.addSubview(shoppingCartVC.view)
        self.view.bringSubviewToFront(self.headerView)
        shoppingCartVC.didMoveToParentViewController(self)
        shoppingCartVC.view.backgroundColor = UIColor.clearColor()
        if let vcRoot = shoppingCartVC.viewControllers.first as? IPAPreShoppingCartViewController {
            vcRoot.delegate = self
            vcRoot.openShoppingCart()
            vcRoot.view.userInteractionEnabled = false
            vcRoot.finishAnimation = {() -> Void in
                print("")
                vcRoot.view.addGestureRecognizer(self.gestureCloseShoppingCart)
                self.btnShopping?.userInteractionEnabled = true
                self.btnCloseShopping?.enabled = true
                vcRoot.view.userInteractionEnabled = true
            }
            
//            self.btnShopping?.userInteractionEnabled = true
//            self.btnCloseShopping?.enabled = true
            
        }

    }
    

    
    override func showProducts(forDepartmentId depto: String?, andFamilyId family: String?, andLineId line: String?, andTitleHeader title:String , andSearchContextType searchContextType:SearchServiceContextType){
        let controller = IPASearchProductViewController()
        controller.searchContextType = searchContextType
        controller.idFamily  = family == nil ? "_" :  family
        controller.idDepartment = depto == nil ? "_" :  depto
        controller.idLine = line == nil ? "_" :  line
        controller.titleHeader = title
        controller.searchFromContextType = SearchServiceFromContext.FromSearchTextSelect
        let controllernav = self.currentController as? UINavigationController
        if (controllernav?.topViewController as? IPASearchProductViewController != nil){
            controllernav?.popViewControllerAnimated(false)
        }
        controllernav?.pushViewController(controller, animated: true)
        self.btnSearch!.selected = false
    }


    override func searchControllerScanButtonClicked() {
        let barCodeController = IPABarCodeViewController()
        barCodeController.searchProduct = true
        
        self.presentViewController(barCodeController, animated: true, completion: nil)
    }
    
    override func returnToView() {
        
        self.btnShopping?.selected = false
        self.btnCloseShopping?.alpha = 0
        self.showBadge()
        self.btnShopping?.alpha = 1

        
        if shoppingCartVC != nil {
            self.btnShopping!.selected = false
            shoppingCartVC.removeFromParentViewController()
            shoppingCartVC.view.removeFromSuperview()
            self.btnShopping?.userInteractionEnabled = true
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
    
    override func userLogOut(not:NSNotification) {
        self.removeAllCookies()
        
        if let navController = self.viewControllers[0] as? UINavigationController {
            let vc = storyboard!.instantiateViewControllerWithIdentifier("homeVC")
            navController.popToRootViewControllerAnimated(false)
            navController.viewControllers[0] = vc
            self.viewControllers[0] = navController
        }
        self.buttonSelected(self.buttonList[0])
        self.viewControllers.removeRange(1..<self.viewControllers.count)
        self.createInstanceOfControllers()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "sendHomeNotification", userInfo: nil, repeats: false)
    }
    
    override func sendHomeNotification(){
        NSNotificationCenter.defaultCenter().postNotificationName(UpdateNotification.HomeUpdateServiceEnd.rawValue, object: nil)
    }
    
    override func showListsGR() {
        buttonSelected(self.buttonList[4])
        NSNotificationCenter.defaultCenter().postNotificationName("ReloadListFormUpdate", object: self)
    }
   
    override func handleNotification(type:String,name:String,value:String,bussines:String) -> Bool {
        
        
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
        case "LIN": self.showProducts(forDepartmentId: nil, andFamilyId: nil,andLineId: trimValue, andTitleHeader:"Recomendados" , andSearchContextType:bussines == "gr" ? .WithCategoryForGR : .WithCategoryForMG )
        case "FAM": self.showProducts(forDepartmentId: nil, andFamilyId:trimValue, andLineId: nil, andTitleHeader:"Recomendados" , andSearchContextType:bussines == "gr" ? .WithCategoryForGR : .WithCategoryForMG)
        case "CAT": self.showProducts(forDepartmentId: trimValue, andFamilyId:nil, andLineId: nil, andTitleHeader:"Recomendados" , andSearchContextType:bussines == "gr" ? .WithCategoryForGR : .WithCategoryForMG)
        case "CF": self.showShoppingCart(self.btnShopping!,closeIfNeedded: false)
        case "WF": self.buttonSelected(self.buttonList[4])
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
    

}