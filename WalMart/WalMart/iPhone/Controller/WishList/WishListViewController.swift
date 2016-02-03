//
//  WishListViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class WishListViewController : NavigationViewController, UITableViewDataSource,UITableViewDelegate, WishlistProductTableViewCellDelegate, SWTableViewCellDelegate,UIActivityItemSource {
    
    var startUrlUPCWalmart = "http://www.walmart.com.mx/Busqueda.aspx?Text="
    
    var idexesPath : [NSIndexPath]! = []
    var items : [AnyObject]! = []
    var wishLitsToolBar : UIView!

    @IBOutlet var wishlist: UITableView!
    
    var edit: UIButton!
    var deleteall: UIButton!
    let leftBtnWidth:CGFloat = 48.0
    
    
   
    var viewLoad : WMLoadingView!
    var isEdditing  = false
    var emptyView : IPOWishlistEmptyView!
    var isShowingTabBar : Bool = true
    var buttonShop : UIButton!
    var customlabel : CurrencyCustomLabel!
   
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_WISHLISTEMPTY.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel!.textColor = WMColor.wishlistTitleTextColor
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel!.text = NSLocalizedString("wishlist.title",comment:"")
        
        self.edit = UIButton(type: .Custom)
        self.edit.frame = CGRectMake(248.0, 12.0, 55.0, 22.0)

        self.edit.setTitle(NSLocalizedString("wishlist.edit", comment:""), forState: .Normal)
        self.edit.setTitle(NSLocalizedString("wishlist.endedit", comment:""), forState: .Selected)
        self.edit.setTitleColor(WMColor.navigationFilterTextColor, forState: .Normal)
        self.edit.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.edit.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
        self.edit!.backgroundColor = WMColor.UIColorFromRGB(0x005AA2)
        self.edit.layer.cornerRadius = 11
        self.edit.addTarget(self, action: "editAction:", forControlEvents: .TouchUpInside)
        self.header!.addSubview(self.edit)
        
        self.deleteall = UIButton(type: .Custom)
        self.deleteall.frame = CGRectMake(165.0, 12.0, 75.0, 22.0)
        self.deleteall.setTitle(NSLocalizedString("wishlist.deleteall", comment:""), forState: .Normal)
        self.deleteall.backgroundColor = WMColor.wishlistDeleteButtonBgColor
        self.deleteall.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.deleteall.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.deleteall.alpha = 0
        self.deleteall.layer.cornerRadius = 11
        self.deleteall.titleEdgeInsets = UIEdgeInsetsMake(2.0, 2.0, 0.0, 0.0)
        self.deleteall.addTarget(self, action: "deletealltap:", forControlEvents: .TouchUpInside)
        self.header!.addSubview(self.deleteall)

        
        wishlist.registerClass(WishlistProductTableViewCell.self, forCellReuseIdentifier: "product")
        
        wishlist.delegate = self
        wishlist.dataSource = self
        wishlist.separatorStyle = UITableViewCellSeparatorStyle.None
        wishlist.clipsToBounds = false
        self.view.sendSubviewToBack(wishlist)
        
        tabFooterView()
        
        emptyView = IPOWishlistEmptyView(frame: CGRectZero)
        emptyView.returnAction = {() in
            self.back()
        }
        self.view.addSubview(emptyView)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.idexesPath = []
        reloadWishlist()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadWishlist", name: CustomBarNotification.ReloadWishList.rawValue, object: nil)
        if isShowingTabBar {
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
      
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isShowingTabBar {
            self.wishlist.frame =  CGRectMake(0, self.wishlist.frame.minY , self.view.frame.width, self.view.frame.height - 109 - self.header!.frame.height)
            self.wishLitsToolBar.frame = CGRectMake(0, self.view.frame.height - 64  - 45 , self.view.frame.width, 64)
        }else{
            self.wishlist.frame =  CGRectMake(0, self.wishlist.frame.minY , self.view.frame.width, self.view.frame.height - 64 - self.header!.frame.height)
            self.wishLitsToolBar.frame = CGRectMake(0, self.view.frame.height - 64, self.view.frame.width, 64)
        }
        self.emptyView!.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        
    }
    
    override func willShowTabbar() {
       isShowingTabBar = true
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.wishlist.frame =  CGRectMake(0, self.wishlist.frame.minY , self.view.frame.width, self.view.frame.height - 119 - self.header!.frame.height)
             self.wishLitsToolBar.frame = CGRectMake(0, self.view.frame.height - 64  - 45 , self.view.frame.width, 64)
        })
    }
    
    override func willHideTabbar() {
       isShowingTabBar = false
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.wishlist.frame =  CGRectMake(0, self.wishlist.frame.minY , self.view.frame.width, self.view.frame.height - 64 - self.header!.frame.height)
             self.wishLitsToolBar.frame = CGRectMake(0, self.view.frame.height - 64  , self.view.frame.width, 64)
        })
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       let cell = wishlist.dequeueReusableCellWithIdentifier("product", forIndexPath: indexPath) as! WishlistProductTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.rightUtilityButtons = getRightButtonDelete()
        
        cell.setLeftUtilityButtons(getRightLeftDelete(), withButtonWidth: self.leftBtnWidth)
        
        cell.delegateProduct = self
        cell.delegate = self
        

        
        let itemWishlist = items[indexPath.row] as! [String:AnyObject]
        let upc = itemWishlist["upc"] as! String
        var pesable = "" //itemWishlist["pesable"] as NSString
        
        if let pesables = itemWishlist["type"] as?  NSString {
            pesable = pesables as String
        }else{
            pesable == "false"
        }
        
        
        //self.updateItemSavingForUPC(indexPath,upc:upc)
        
        
        let desc = itemWishlist["description"] as! String
        let price = itemWishlist["price"] as! NSString
        let imageArray = itemWishlist["imageUrl"]as! NSArray
        var imageUrl = ""
        if imageArray.count > 0 {
            imageUrl = imageArray.objectAtIndex(0) as! String
        }
        
        let savingIndex = itemWishlist.indexForKey("saving")
        var savingVal = "0.0"
        if savingIndex != nil {
             savingVal = itemWishlist["saving"]  as! String
        }
        
        let active  = itemWishlist["isActive"] as! String
        var isActive = "true" == active
        
        if isActive == true {
            isActive = price.doubleValue > 0
        }

        
        var isPreorderable = false
        if  let preordeable  = itemWishlist["isPreorderable"] as? NSString {
            isPreorderable = "true" == preordeable
        }
        
        let onHandInventory = itemWishlist["onHandInventory"] as! NSString

        let isInShoppingCart = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)
        
        cell.setValues(upc, productImageURL: imageUrl, productShortDescription: desc, productPrice: price as String, saving: savingVal, isActive: isActive, onHandInventory: onHandInventory.integerValue, isPreorderable: isPreorderable,isInShoppingCart:isInShoppingCart,pesable:pesable)
       
        //cell.setValues(upc,productImageURL:imageUrl, productShortDescription: desc, productPrice: price, saving:savingVal )

        cell.shouldChangeState = !isEdditing
        
        if isEdditing {
            cell.setEditing(true, animated: false)
            cell.showLeftUtilityButtonsAnimated(false)
        }else {
            cell.setEditing(false, animated: false)
            cell.hideUtilityButtonsAnimated(false)
        }
        
        
        return cell
    }
    
    func getRightButtonDelete() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        let buttonDelete = UIButton(frame: CGRectMake(0, 0, 64, 109))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), forState: UIControlState.Normal)
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.wishlistDeleteButtonBgColor
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    func getRightLeftDelete() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        let buttonDelete = UIButton(frame: CGRectMake(0, 0, 36, 109))
        buttonDelete.setImage(UIImage(named:"myList_delete"), forState: UIControlState.Normal)
        buttonDelete.backgroundColor = WMColor.light_gray
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 109
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var itemsToSend : [[String:String]] = []
        
        for itemWishlist in self.items {
            print("Wishlist : \(itemWishlist)")
            let upc = itemWishlist["upc"] as! String
            let desc = itemWishlist["description"] as! String
            let type = ResultObjectType.Mg.rawValue
            let dict = ["upc":upc,"description":desc,"type":type]
            itemsToSend.append(dict)

        }
        
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = itemsToSend
        controller.ixSelected = indexPath.row
        
        
        let itemWishlistSel = items[indexPath.row] as! [String:AnyObject]
        let upc = itemWishlistSel["upc"] as! String
        let desc = itemWishlistSel["description"] as! String
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_OPEN_DETAIL_WISHLIST.rawValue, label: "\(desc) - \(upc)")
               
        self.navigationController!.pushViewController(controller, animated: true)
        
        
        
    }
    

    
    func deleteFromWishlist(UPC:String) {
        let serviceWishDelete = DeleteItemWishlistService()
        serviceWishDelete.callCoreDataService(UPC, successBlock: { (result:NSDictionary) -> Void in
            self.reloadWishlist()
            }) { (error:NSError) -> Void in
            
        }
        
    }
    
    func reloadWishlist() {
        if WishlistService.shouldupdate {
             WishlistService.shouldupdate = false
            
            if viewLoad != nil {
                viewLoad.removeFromSuperview()
                viewLoad = nil
            }
            
            viewLoad = WMLoadingView(frame: CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height))
            viewLoad.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(viewLoad)
            viewLoad.startAnnimating(true)

            
//            var serviceWish = UserWishlistService()
//            serviceWish.callService({ (wishlist:NSDictionary) -> Void in
//                self.items = wishlist["items"] as [AnyObject]
//                
//                
//                self.emptyView.hidden = self.items.count > 0
//                if self.items.count == 0 {
//                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
//                }
//                self.edit.hidden = self.items.count == 0
//                
//                
//                
//                self.updateShopButton()
//                
//                self.wishlist.reloadData()
//                if self.items.count == 0 {
//                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
//                }
//                /* alertView.setMessage(NSLocalizedString("wishlist.readyload",comment:""))
//                alertView.showDoneIcon()*/
//                
//                self.viewLoad.stopAnnimating()
//                }, errorBlock: { (error:NSError) -> Void in
//                    if error.code != -100 {
//                        self.viewLoad.stopAnnimating()
//                    }
//                    //alertView.setMessage(NSLocalizedString("wishlist.readyload",comment:""))
//                    //alertView.showDoneIcon()
            
            UserCurrentSession.sharedInstance().loadMGShoppingCart({ () -> Void in
                self.invokeWishlistService()

            })
        }
        
    }
    
    func updateShopButton() {
        
        var total : Double = 0
        for itemWishList in self.items {
            let price = itemWishList["price"] as! NSString
            let active  = itemWishList["isActive"] as! NSString
            var isActive = "true" == active
            var isPreorderable = false
            
            if isActive == true {
                isActive = price.doubleValue > 0
            }
            
            if let preordeable  = itemWishList["isPreorderable"] as? NSString {
                isPreorderable = "true" == preordeable
            }
            
            let onHandInventory = itemWishList["onHandInventory"] as! NSString
            
            if isActive == true && onHandInventory.integerValue > 0  { //&& isPreorderable == false
                total = total + price.doubleValue
            }
        }
        
        let totalStr = String(format: "%.2f",total)
        
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: self.buttonShop.bounds)
            customlabel.backgroundColor = UIColor.clearColor()
            customlabel.setCurrencyUserInteractionEnabled(true)
            buttonShop.addSubview(customlabel)
            buttonShop.sendSubviewToBack(customlabel)
        }
        let shopStr = NSLocalizedString("wishlist.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(totalStr)
        let shopStrComplete = "\(shopStr) \(fmtTotal)"
        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.whiteColor(), interLine: false)
        
    }
    
    
//    func updateItemSavingForUPC(indexPath: NSIndexPath,upc:String) {
//        
//        let searchResult = idexesPath.filter({ (index) -> Bool in return index.row == indexPath.row })
//        if searchResult.count == 0 {
//            idexesPath.append(indexPath)
//            
//            let productService = ProductDetailService()
//            productService.callService(upc, successBlock: { (result: NSDictionary) -> Void in
//                 var currentItems =  self.items.filter({ (dictproduct) -> Bool in
//                    return upc == dictproduct["upc"] as NSString
//                 })
//                if currentItems.count > 0 {
//                    let savingItem = result["saving"] as NSString
//                    if self.items != nil && self.items.count > indexPath.row {
//                        var itemByUpc  = self.items[indexPath.row] as [String:AnyObject]
//                        let updateUpc = itemByUpc["upc"] as NSString
//                        if upc == updateUpc {
//                            itemByUpc.updateValue(savingItem, forKey: "saving")
//                            self.items[indexPath.row] = itemByUpc
//                            self.wishlist.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
//                        }
//                    }
//                    
//                    
//                }
//                
//                }) { (error:NSError) -> Void in
//
//                    
//            }
//        }
//        
//        
//    }
    
    @IBAction func editAction(sender: AnyObject) {
       
        if (!isEdditing) {
            isEdditing = !isEdditing
            
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_EDIT_WISHLIST.rawValue, label: "")
            
            let currentCells = self.wishlist.visibleCells as! [WishlistProductTableViewCell]
            for cell in currentCells {
                cell.setEditing(true, animated: false)
                cell.showLeftUtilityButtonsAnimated(true)
                //cell.shouldChangeState = !isEdditing
            }
            edit.selected = true
            edit.backgroundColor = WMColor.UIColorFromRGB(0x8EBB36)//WMColor.wishlistEndEditButtonBgColor
            edit.tintColor = WMColor.wishlistEndEditButtonBgColor
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.deleteall.alpha = 1
                self.titleLabel!.frame = CGRectMake(self.titleLabel!.frame.minX - 30, self.titleLabel!.frame.minY, self.titleLabel!.frame.width, self.titleLabel!.frame.height)
            })
            
        }else{
            
            let currentCells = self.wishlist.visibleCells as! [WishlistProductTableViewCell]
            for cell in currentCells {
                cell.hideUtilityButtonsAnimated(false)
                cell.setEditing(false, animated: false)
            }
            edit.hidden = self.items.count == 0
            edit.selected = false
            edit.backgroundColor = WMColor.wishlistEditButtonBgColor
            edit.tintColor = WMColor.wishlistEditButtonBgColor
            isEdditing = !isEdditing
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.deleteall.alpha = 0
                self.titleLabel!.frame = CGRectMake(self.titleLabel!.frame.minX + 30, self.titleLabel!.frame.minY, self.titleLabel!.frame.width, self.titleLabel!.frame.height)
            })
           
        }
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch index {
        case 0:
            let indexPath = self.wishlist.indexPathForCell(cell)
            if indexPath != nil {
                deleteRowAtIndexPath(indexPath!)
            }
           
        default :
             print("other pressed")
        }
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
        switch index {
        case 0:
            //let indexPath : NSIndexPath = self.wishlist.indexPathForCell(cell)!
            //deleteRowAtIndexPath(indexPath)
            cell.showRightUtilityButtonsAnimated(true)
        default :
            print("other pressed")
        }
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
        switch state {
        case SWCellState.CellStateLeft:
            return isEdditing
        case SWCellState.CellStateRight:
            return true
        case SWCellState.CellStateCenter:
            return !isEdditing
        default:
            return !isEdditing
        }
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return !isEdditing
    }

    
    func deleteRowAtIndexPath(indexPath : NSIndexPath){
        let itemWishlist = items[indexPath.row] as! [String:AnyObject]
        let upc = itemWishlist["upc"] as! String
        let deleteWishListService = DeleteItemWishlistService()
        deleteWishListService.callCoreDataService(upc, successBlock: { (result:NSDictionary) -> Void in
            self.items.removeAtIndex(indexPath.row)
            self.updateShopButton()
            self.wishlist.reloadData()
            self.emptyView.hidden = self.items.count > 0
            
            if !(self.items.count > 0){
               self.updateEditButton()
            }
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_PRODUCT_WISHLIST.rawValue, label: upc)
            
            
            //self.updateEditButton()
            
            
            }, errorBlock: { (error:NSError) -> Void in
                print("delete pressed Errro \(error)")
        })
    }
    
    func tabFooterView() {
        wishLitsToolBar = UIView(frame: CGRectMake(0, self.view.frame.height - 64 , self.view.frame.width, 64))
        wishLitsToolBar.backgroundColor = UIColor.clearColor()
        
        let bgShareBuy = UIView(frame:CGRectMake(0, 0 , self.view.frame.width, 64))
        bgShareBuy.backgroundColor = UIColor.whiteColor()
        bgShareBuy.alpha = 0.9
        
        
        let shareButton = UIButton(frame: CGRectMake(16, 14, 34, 34))
        shareButton.setImage(UIImage(named:"wishlist_share"), forState: UIControlState.Normal)
        shareButton.addTarget(self, action: "shareItem", forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonShop = UIButton(frame: CGRectMake(shareButton.frame.maxX + 16, 14, 240, 34))
        //buttonShop.setTitle("Comprar todo", forState: UIControlState.Normal)
        buttonShop.backgroundColor = WMColor.shoppingCartShopBgColor
        buttonShop.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonShop.layer.cornerRadius = 17
        buttonShop.addTarget(self, action: "senditemsToShoppingCart", forControlEvents: UIControlEvents.TouchUpInside)
        
        wishLitsToolBar.addSubview(bgShareBuy)
        wishLitsToolBar.addSubview(shareButton)
        wishLitsToolBar.addSubview(buttonShop)
        
        self.view.addSubview(wishLitsToolBar)
        
        
        
    }
    
    func shareItem() {
        //let image = UIImage(named:"navBar_cart")
        let headerImage = UIImage(named:"wishlist_headerMail")
        let image = self.wishlist.screenshot()
        let imageWHeader =  UIImage.verticalImageFromArray([headerImage!,image])
        var strAllUPCs = ""
        for item in self.items {
            let strItemUpc = item["upc"]
            if strAllUPCs != "" {
                strAllUPCs = "\(strAllUPCs),\(strItemUpc)"
            } else {
                strAllUPCs = "\(strItemUpc)"
            }
        }
        let upcList = "\(strAllUPCs)"
        let urlWmart = UserCurrentSession.urlWithRootPath("http://www.walmart.com.mx/Busqueda.aspx?Text=\(upcList)")
        
        let controller = UIActivityViewController(activityItems: [self,urlWmart!,imageWHeader], applicationActivities: nil)
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: "")
        
        
    }
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject{
        return "Walmart"
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        if activityType == UIActivityTypeMail {
            return "Hola,\nMira estos productos que encontré en Walmart. ¡Te los recomiendo!"
        }
        return ""
    }
    
    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        if activityType == UIActivityTypeMail {
            if UserCurrentSession.sharedInstance().userSigned == nil {
                return "Hola te quiero enseñar mi lista de www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance().userSigned!.profile.name) \(UserCurrentSession.sharedInstance().userSigned!.profile.lastName) te quiere enseñar su lista de www.walmart.com.mx"
            }
        }
        return ""
    }

    
    
    func senditemsToShoppingCart() {
        var params : [AnyObject] =  []
        for itemWishList in self.items {
            
            let upc = itemWishList["upc"] as! NSString
            let desc = itemWishList["description"] as! NSString
            let price = itemWishList["price"] as! NSString
            let imageArray = itemWishList["imageUrl"] as! NSArray
            
            let active  = itemWishList["isActive"] as! NSString
            var isActive = "true" == active
            
            if isActive == true {
                isActive = price.doubleValue > 0
            }
            
            var isPreorderable = "false"
            if  let preordeable  = itemWishList["isPreorderable"] as? String {
                isPreorderable =  preordeable
            }
            
            //let onHandInventory = itemWishList["onHandInventory"] as NSString
            
            var numOnHandInventory : NSString = "0"
            if let numberOf = itemWishList["onHandInventory"] as? NSString{
                numOnHandInventory  = numberOf
            }
            
            var imageUrl = ""
            if imageArray.count > 0 {
                imageUrl = imageArray.objectAtIndex(0) as! String
            }
            
            
            
            if isActive == true && numOnHandInventory.integerValue > 0  { //&& isPreorderable == false
                let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc as String)
                if !hasUPC {
                    let paramsItem = CustomBarViewController.buildParamsUpdateShoppingCart(upc as String, desc: desc as String, imageURL: imageUrl, price: price as String, quantity: "1",onHandInventory:numOnHandInventory as String,wishlist:true,type:ResultObjectType.Mg.rawValue,pesable:"0",isPreorderable:isPreorderable)
                    print(paramsItem)
                    params.append(paramsItem)
                }
                
            }
        }
        if params.count > 0 {
            let paramsAll = ["allitems":params, "image":"wishlist_addToCart"]
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddItemsToShopingCart.rawValue, object: self, userInfo: paramsAll as [NSObject : AnyObject])
        }
        if !(self.items.count > 0){
            self.updateEditButton()
        }
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_CHECKOUT.rawValue, label: "")
        
    }
    
    @IBAction func deletealltap(sender: AnyObject) {
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_DELETE_ALL_PRODUCTS_WISHLIST.rawValue, label: "")
        
        let serviceWishDelete = DeleteItemWishlistService()
        var upcsWL : [String]  = []
        for itemWishlist in self.items {
            let upc = itemWishlist["upc"] as! NSString
            upcsWL.append(upc as String)
        }
        serviceWishDelete.callServiceWithParams(["parameter":upcsWL], successBlock: { (result:NSDictionary) -> Void in
                self.reloadWishlist()
                self.editAction(self.edit)
            }) { (error:NSError) -> Void in
                self.reloadWishlist()
                self.editAction(self.edit)
        }
        
    }
    
    //MARK: - Services
    
    func invokeWishlistService() {
        let service = UserWishlistService()
        service.callService(
            { (wishlist:NSDictionary) -> Void in
                self.items = wishlist["items"] as! [AnyObject]
            
                self.emptyView.hidden = self.items.count > 0
                if self.items.count == 0 {
                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
                }
                self.edit.hidden = self.items.count == 0
            
                var total : Double = 0
                for itemWishList in self.items {
                    var price = NSString(string:"0")
                    if let priceVal = itemWishList["price"] as? String {
                        price = priceVal
                    }
                    
                    let active  = itemWishList["isActive"] as? String
                    var isActive = "true" == active
                    var isPreorderable = false
                
                    if isActive {
                        isActive = price.doubleValue > 0
                    }
                
                    if let preordeable = itemWishList["isPreorderable"] as? NSString {
                        isPreorderable = "true" == preordeable
                    }
                
                    let onHandInventory = itemWishList["onHandInventory"] as! NSString
                
                    if isActive && onHandInventory.integerValue > 0 && !isPreorderable {
                        total = total + price.doubleValue
                    }
                }
            
                self.updateShopButton()
                self.updateEditButton()
                self.wishlist.reloadData()
                self.viewLoad.stopAnnimating()
            }, errorBlock: { (error:NSError) -> Void in
                if error.code != -100 {
                    self.viewLoad.stopAnnimating()
                }
            }
        
        )
    }
    func updateEditButton (){
        deleteall.hidden = self.items.count == 0 && self.isEdditing
        edit.hidden = self.items.count == 0
        edit.selected = false
        edit.backgroundColor = WMColor.wishlistEditButtonBgColor
        edit.tintColor = WMColor.wishlistEditButtonBgColor

    }
    
    override func back() {
        super.back()
         BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_BACK_WISHLIST.rawValue, label: "")
    }
    
}