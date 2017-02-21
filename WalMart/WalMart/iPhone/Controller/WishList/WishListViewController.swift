//
//  WishListViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class WishListViewController : NavigationViewController, UITableViewDataSource,UITableViewDelegate, WishlistProductTableViewCellDelegate, SWTableViewCellDelegate,UIActivityItemSource {
    
    var startUrlUPCWalmart = "https://www.walmart.com.mx/Busqueda.aspx?Text="
    
    var idexesPath : [IndexPath]! = []
    var items : [[String:Any]]! = []
    var wishLitsToolBar : UIView!

    @IBOutlet var wishlist: UITableView!
    
    var edit: UIButton!
    var deleteall: UIButton!
    let leftBtnWidth:CGFloat = 48.0
    var position = 0
    
    var viewLoad : WMLoadingView!
    var isEdditing  = false
    var emptyView : IPOWishlistEmptyView!
    var isShowingTabBar : Bool = true
    var buttonShop : UIButton!
    var customlabel : CurrencyCustomLabel!
    var preview: PreviewModalView? = nil
   
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_WISHLISTEMPTY.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel!.textColor = WMColor.light_blue
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel!.text = NSLocalizedString("wishlist.title",comment:"")
        
        self.edit = UIButton(type: .custom)
        self.edit.frame = CGRect(x: (self.view.bounds.width - 71), y: 12.0, width: 55.0, height: 22.0)

        self.edit.setTitle(NSLocalizedString("wishlist.edit", comment:""), for: UIControlState())
        self.edit.setTitle(NSLocalizedString("wishlist.endedit", comment:""), for: .selected)
        self.edit.setTitleColor(UIColor.white, for: UIControlState())
        self.edit.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.edit.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
        self.edit!.backgroundColor = WMColor.dark_blue
        self.edit.layer.cornerRadius = 11
        self.edit.addTarget(self, action: #selector(WishListViewController.editAction(_:)), for: .touchUpInside)
        self.header!.addSubview(self.edit)
        
        self.deleteall = UIButton(type: .custom)
        self.deleteall.frame = CGRect(x: (self.edit.frame.minX - 83), y: 12.0, width: 75.0, height: 22.0)
        self.deleteall.setTitle(NSLocalizedString("wishlist.deleteall", comment:""), for: UIControlState())
        self.deleteall.backgroundColor = WMColor.red
        self.deleteall.setTitleColor(UIColor.white, for: UIControlState())
        self.deleteall.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.deleteall.alpha = 0
        self.deleteall.layer.cornerRadius = 11
        self.deleteall.titleEdgeInsets = UIEdgeInsetsMake(2.0, 2.0, 0.0, 0.0)
        self.deleteall.addTarget(self, action: #selector(WishListViewController.deletealltap(_:)), for: .touchUpInside)
        self.header!.addSubview(self.deleteall)

        
        wishlist.register(WishlistProductTableViewCell.self, forCellReuseIdentifier: "product")
        
        wishlist.delegate = self
        wishlist.dataSource = self
        wishlist.separatorStyle = UITableViewCellSeparatorStyle.none
        wishlist.clipsToBounds = false
        self.view.sendSubview(toBack: wishlist)
        
        tabFooterView()
        
        emptyView = IPOWishlistEmptyView(frame: CGRect.zero)
        emptyView.returnAction = {() in
            self.back()
        }
        self.view.addSubview(emptyView)
        
        BaseController.setOpenScreenTagManager(titleScreen: "WishList", screenName: self.getScreenGAIName())
        
        //The 'view' argument should be the view receiving the 3D Touch.
        if #available(iOS 9.0, *), self.is3DTouchAvailable(){
            registerForPreviewing(with: self, sourceView: wishlist!)
        }else{
            addLongTouch(view:wishlist!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserCurrentSession.sharedInstance.nameListToTag = "WishList"
        self.idexesPath = []
        reloadWishlist()
        
        NotificationCenter.default.addObserver(self, selector: #selector(WishListViewController.reloadWishlist), name: NSNotification.Name(rawValue: CustomBarNotification.ReloadWishList.rawValue), object: nil)
       
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.wishlist.frame =  CGRect(x: 0, y: self.wishlist.frame.minY , width: self.view.frame.width, height: self.view.frame.height - 108 - self.header!.frame.height)
        self.wishLitsToolBar.frame = CGRect(x: 0, y: self.view.frame.height - 108 , width: self.view.frame.width, height: 64)
        self.emptyView!.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
       
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = wishlist.dequeueReusableCell(withIdentifier: "product", for: indexPath) as! WishlistProductTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.rightUtilityButtons = getRightButtonDelete()
        
        cell.setLeftUtilityButtons(getRightLeftDelete(), withButtonWidth: self.leftBtnWidth)
        
        cell.delegateProduct = self
        cell.delegate = self
        

        
        let itemWishlist = items[indexPath.row]
        let upc = itemWishlist["upc"] as! String
        var pesable = "" //itemWishlist["pesable"] as NSString
        
        if let pesables = itemWishlist["type"] as?  NSString {
            pesable = pesables as String
        }else{
            pesable = "false"
        }
        
        
        //self.updateItemSavingForUPC(indexPath,upc:upc)
        
        
        let desc = itemWishlist["description"] as! String
        let price = itemWishlist["price"] as! NSString
        let imageArray = itemWishlist["imageUrl"]as! [Any]
        var imageUrl = ""
        if imageArray.count > 0 {
            imageUrl = imageArray[0] as! String
        }
        
        let savingIndex = itemWishlist.index(forKey: "saving")
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

        let isInShoppingCart = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc)
        cell.moveRightImagePresale(isPreorderable)
        cell.setValues(upc, productImageURL: imageUrl, productShortDescription: desc, productPrice: price as String, saving: savingVal as NSString, isActive: isActive, onHandInventory: onHandInventory.integerValue, isPreorderable: isPreorderable,isInShoppingCart:isInShoppingCart,pesable:pesable as NSString)
       
        //cell.setValues(upc,productImageURL:imageUrl, productShortDescription: desc, productPrice: price, saving:savingVal )

        cell.shouldChangeState = !isEdditing
        
        if isEdditing {
            cell.setEditing(true, animated: false)
            cell.showLeftUtilityButtons(animated: false)
            cell.moveRightImagePresale(true)

        }else {
            cell.setEditing(false, animated: false)
            cell.hideUtilityButtons(animated: false)
            cell.moveRightImagePresale(false)

        }
        
        
        return cell
    }
    
    func getRightButtonDelete() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        let buttonDelete = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 109))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), for: UIControlState())
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    func getRightLeftDelete() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        let buttonDelete = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 109))
        buttonDelete.setImage(UIImage(named:"myList_delete"), for: UIControlState())
        buttonDelete.backgroundColor = WMColor.light_gray
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 109
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = self.getDetailController(indexPath: indexPath)
        self.navigationController!.pushViewController(controller!, animated: true)
    }
    

    func getDetailController(indexPath:IndexPath) -> ProductDetailPageViewController? {
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
        controller.itemsToShow = itemsToSend as [Any]
        controller.ixSelected = indexPath.row
        controller.detailOf = "Wish List"

        return controller
    }
    
    func deleteFromWishlist(_ UPC:String) {
        let serviceWishDelete = DeleteItemWishlistService()
        serviceWishDelete.callCoreDataService(UPC, successBlock: { (result:[String:Any]) -> Void in
            self.reloadWishlist()
            }) { (error:NSError) -> Void in
            
        }
        
    }
    
    func reloadWishlist() {
        if WishlistService.shouldupdate {
            WishlistService.shouldupdate = false
            self.buttonShop.isEnabled = true
            if viewLoad != nil {
                viewLoad.removeFromSuperview()
                viewLoad = nil
            }
            
            viewLoad = WMLoadingView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height))
            viewLoad.backgroundColor = UIColor.white
            self.view.addSubview(viewLoad)
            viewLoad.startAnnimating(true)

            
//            var serviceWish = UserWishlistService()
//            serviceWish.callService({ (wishlist:[String:Any]) -> Void in
//                self.items = wishlist["items"] as [Any]
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
            
            UserCurrentSession.sharedInstance.loadMGShoppingCart({ () -> Void in
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
            //var isPreorderable = false
            
            if isActive == true {
                isActive = price.doubleValue > 0
            }
            
//            if let preordeable  = itemWishList["isPreorderable"] as? NSString {
//                isPreorderable = "true" == preordeable
//            }
            
            let onHandInventory = itemWishList["onHandInventory"] as! NSString
            
            if isActive == true && onHandInventory.integerValue > 0  { //&& isPreorderable == false
                total = total + price.doubleValue
            }
        }
        
        let totalStr = String(format: "%.2f",total)
        
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: self.buttonShop.bounds)
            customlabel.backgroundColor = UIColor.clear
            customlabel.setCurrencyUserInteractionEnabled(true)
            buttonShop.addSubview(customlabel)
            buttonShop.sendSubview(toBack: customlabel)
        }
        let shopStr = NSLocalizedString("wishlist.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(totalStr as NSString)
        let shopStrComplete = "\(shopStr) \(fmtTotal)"
        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.white, interLine: false)
        
    }
    
    
//    func updateItemSavingForUPC(indexPath: NSIndexPath,upc:String) {
//        
//        let searchResult = idexesPath.filter({ (index) -> Bool in return index.row == indexPath.row })
//        if searchResult.count == 0 {
//            idexesPath.append(indexPath)
//            
//            let productService = ProductDetailService()
//            productService.callService(upc, successBlock: { (result: [String:Any]) -> Void in
//                 var currentItems =  self.items.filter({ (dictproduct) -> Bool in
//                    return upc == dictproduct["upc"] as NSString
//                 })
//                if currentItems.count > 0 {
//                    let savingItem = result["saving"] as NSString
//                    if self.items != nil && self.items.count > indexPath.row {
//                        var itemByUpc  = self.items[indexPath.row] as [String:Any]
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
    
    @IBAction func editAction(_ sender: AnyObject) {
       
        if (!isEdditing) {
            isEdditing = !isEdditing
            
            
            ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_EDIT_WISHLIST.rawValue, label: "")
            
            let currentCells = self.wishlist.visibleCells as! [WishlistProductTableViewCell]
            for cell in currentCells {
                cell.showLeftUtilityButtons(animated: true)
                cell.moveRightImagePresale(true)
                cell.setEditing(true, animated: false)

                //cell.shouldChangeState = !isEdditing
            }
            edit.isSelected = true
            edit.backgroundColor = WMColor.green
            edit.tintColor = WMColor.dark_blue
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.deleteall.alpha = 1
                self.titleLabel!.frame = CGRect(x: self.titleLabel!.frame.minX - 30, y: self.titleLabel!.frame.minY, width: self.titleLabel!.frame.width, height: self.titleLabel!.frame.height)
                })
            
        }else{
            
            let currentCells = self.wishlist.visibleCells as! [WishlistProductTableViewCell]
            for cell in currentCells {
                cell.hideUtilityButtons(animated: false)
                cell.setEditing(false, animated: false)
                cell.moveRightImagePresale(false)
            }
            edit.isHidden = self.items.count == 0
            edit.isSelected = false
            edit.backgroundColor = WMColor.light_blue
            edit.tintColor = WMColor.light_blue
            isEdditing = !isEdditing
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.deleteall.alpha = 0
                self.titleLabel!.frame = CGRect(x: self.titleLabel!.frame.minX + 30, y: self.titleLabel!.frame.minY, width: self.titleLabel!.frame.width, height: self.titleLabel!.frame.height)
            })
           
        }
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        switch index {
        case 0:
            let indexPath = self.wishlist.indexPath(for: cell)
            if indexPath != nil {
                deleteRowAtIndexPath(indexPath!)
            }
           
        default :
             print("other pressed")
        }
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerLeftUtilityButtonWith index: Int) {
        switch index {
        case 0:
            //let indexPath : NSIndexPath = self.wishlist.indexPathForCell(cell)!
            //deleteRowAtIndexPath(indexPath)
            let index = self.wishlist.indexPath(for: cell)
            let superCell = self.wishlist.cellForRow(at: index!) as! WishlistProductTableViewCell
            superCell.moveRightImagePresale(false)
            cell.hideUtilityButtons(animated: true)
            cell.showRightUtilityButtons(animated: true)
        default :
            print("other pressed")
        }
    }
    
//    func swipeableTableViewCell(_ cell: SWTableViewCell!, canSwipeTo state: SWCellState) -> Bool {
//        switch state {
//        case SWCellState.cellStateLeft:
//            print("cellStateLeft \(self.isEdditing)")
//            return self.isEdditing
//        case SWCellState.cellStateRight:
//            print("cellStateRight \(self.isEdditing)")
//            return !self.isEdditing
//        case SWCellState.cellStateCenter:
//            print("cellStateCenter \(!self.isEdditing)")
//            return !self.isEdditing
//        }
//    }
    
    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool {
        return !self.isEdditing
    }

    
    func deleteRowAtIndexPath(_ indexPath : IndexPath){
        let itemWishlist = items[indexPath.row] 
        let upc = itemWishlist["upc"] as! String
        let deleteWishListService = DeleteItemWishlistService()
        deleteWishListService.callCoreDataService(upc, successBlock: { (result:[String:Any]) -> Void in
            self.items.remove(at: indexPath.row)
            self.updateShopButton()
            self.wishlist.reloadData()
            self.emptyView.isHidden = self.items.count > 0
            
            if !(self.items.count > 0){
               self.updateEditButton()
            }
            
            ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_PRODUCT_WISHLIST.rawValue, label: upc)
            
            
            //self.updateEditButton()
            
            
            }, errorBlock: { (error:NSError) -> Void in
                print("delete pressed Errro \(error)")
        })
    }
    
    func tabFooterView() {
        wishLitsToolBar = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 108 , width: self.view.frame.width, height: 64))
        wishLitsToolBar.backgroundColor = UIColor.clear
        
        let bgShareBuy = UIView(frame:CGRect(x: 0, y: 0 , width: self.view.frame.width, height: 64))
        bgShareBuy.backgroundColor = UIColor.white
        bgShareBuy.alpha = 0.9
        
        
        let shareButton = UIButton(frame: CGRect(x: 16, y: 14, width: 34, height: 34))
        shareButton.setImage(UIImage(named:"wishlist_share"), for: UIControlState())
        shareButton.addTarget(self, action: #selector(WishListViewController.shareItem), for: UIControlEvents.touchUpInside)
        
        buttonShop = UIButton(frame: CGRect(x: shareButton.frame.maxX + 16, y: 14, width: self.view.frame.width - (shareButton.frame.maxX + 32) , height: 34))
        //buttonShop.setTitle("Comprar todo", forState: UIControlState.Normal)
        buttonShop.backgroundColor = WMColor.green
        buttonShop.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonShop.layer.cornerRadius = 17
        buttonShop.addTarget(self, action: #selector(WishListViewController.senditemsToShoppingCart), for: UIControlEvents.touchUpInside)
        
        wishLitsToolBar.addSubview(bgShareBuy)
        wishLitsToolBar.addSubview(shareButton)
        wishLitsToolBar.addSubview(buttonShop)
        
        self.view.addSubview(wishLitsToolBar)
        
        
        
    }
    
    func shareItem() {
        //let image = UIImage(named:"navBar_cart")
        let headerImage = UIImage(named:"wishlist_headerMail")
        let image = self.wishlist.screenshot()
        let imageWHeader =  UIImage.verticalImage(from: [headerImage!,image!])
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
        let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx/Busqueda.aspx?Text=\(upcList)")
        
        let controller = UIActivityViewController(activityItems: [self,urlWmart!,imageWHeader!], applicationActivities: nil)
        self.navigationController!.present(controller, animated: true, completion: nil)
        
        controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
            }
        }
    ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: "")
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any{
        return "Walmart"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        if activityType == UIActivityType.mail {
            return "Hola,\nMira estos productos que encontré en Walmart. ¡Te los recomiendo!"
        }
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        if activityType == UIActivityType.mail {
            if UserCurrentSession.sharedInstance.userSigned == nil {
                return "Hola te quiero enseñar mi lista de www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance.userSigned!.profile.name) \(UserCurrentSession.sharedInstance.userSigned!.profile.lastName) te quiere enseñar su lista de www.walmart.com.mx"
            }
        }
        return ""
    }

    func senditemsToShoppingCart() {
        
        var params : [Any] =  []
        var paramsPreorderable : [Any] =  []
        var hasItemsNotAviable = false
        var wishlistTotalPrice = 0.0
        
        for itemWishList in self.items {
            
            let upc = itemWishList["upc"] as! NSString
            let desc = itemWishList["description"] as! NSString
            let price = itemWishList["price"] as! NSString
            let imageArray = itemWishList["imageUrl"] as! [Any]
            
            let active  = itemWishList["isActive"] as! NSString
            var isActive = "true" == active
            
            if isActive == true {
                isActive = price.doubleValue > 0
                if isActive {
                    wishlistTotalPrice += price.doubleValue
                }
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
            
            var category : String = ""
            if let categoryVal = itemWishList["category"] as? String{
                category  = categoryVal
            }
            
            var imageUrl = ""
            if imageArray.count > 0 {
                imageUrl = imageArray[0] as! String
            }
            
            
            if isActive == true && numOnHandInventory.integerValue > 0  { //&& isPreorderable == false
                
                let hasUPC = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc as String)
                if !hasUPC {
                    let paramsItem = CustomBarViewController.buildParamsUpdateShoppingCart(upc as String, desc: desc as String, imageURL: imageUrl, price: price as String, quantity: "1",onHandInventory:numOnHandInventory as String,wishlist:true,type:ResultObjectType.Mg.rawValue,pesable:"0",isPreorderable:isPreorderable,category:category)
                    //params.append(paramsItem)
                    if isPreorderable == "true" {
                        paramsPreorderable.append(paramsItem)
                    }else{
                        params.append(paramsItem)
                    }
                }
            } else {
                hasItemsNotAviable = true
            }
        } //For alert
        
        if paramsPreorderable.count == 0 && params.count == 0 {

            //shoppingcart.alreadyincart
            //shoppingcart.isincart
        
            if self.items.count == 1 {
                for itemWishList in self.items {
                    let upc = itemWishList["upc"] as! NSString
                    let hasUPC = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc as String)
                    if hasUPC {
                        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"done"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"done"))
                        alert!.setMessage(NSLocalizedString("shoppingcart.isincart",comment:""))
                        alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                    
                        return
                    }
                    //
                    if self.items.count > 0 {
                        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"cart_loading"),imageDone:nil,imageError:UIImage(named:"cart_loading"))
                        let aleradyMessage = NSLocalizedString("productdetail.notaviable",comment:"")
                        alert!.setMessage(aleradyMessage)
                        alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshoppinginsidecart",comment:""))
                    }
                    return
                }
                

            }
        }
        
        if self.items.count == 1 && hasItemsNotAviable {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"cart_loading"),imageDone:nil,imageError:UIImage(named:"cart_loading"))
            let aleradyMessage = NSLocalizedString("productdetail.notaviable",comment:"")
            
            alert!.setMessage(aleradyMessage)
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            return
        }
    
        let identicalMG = UserCurrentSession.sharedInstance.identicalMG()
        let totArticlesMG = UserCurrentSession.sharedInstance.numberOfArticlesMG()
        
        if paramsPreorderable.count == 0 && params.count == 0 {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"done"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"done"))
            alert!.setMessage(NSLocalizedString("shoppingcart.alreadyincart",comment:""))
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            return
        }
        if params.count  > 0 && paramsPreorderable.count == 0 && (totArticlesMG == 0 || !identicalMG) {
            self.sendNewItemsToShoppingCart(params)
        
        }else{
            
            if paramsPreorderable.count > 1 && params.count == 0  &&  totArticlesMG == 0{
                let itemImage =  paramsPreorderable[0] as! [String:Any]
               
                let alert = IPOWMAlertViewController.showAlert(WishListViewController.createImage(itemImage["imgUrl"] as! String),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                alert!.spinImage.isHidden =  true
                alert!.viewBgImage.backgroundColor =  UIColor.white
                let messagePreorderable = NSLocalizedString("alert.presaletobuyback",comment:"")
                alert!.setMessage(messagePreorderable)
                alert!.addActionButtonsWithCustomText("Cancelar", leftAction: { () -> Void in
                    alert!.close()
                    
                    }, rightText: "Ok", rightAction: { () -> Void in
                        self.sendNewItemsToShoppingCart([paramsPreorderable[0]])
                        alert!.close()
                    }, isNewFrame: false)
                
            } else if paramsPreorderable.count > 0 && params.count > 0 &&  totArticlesMG == 0{
                
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                alert!.spinImage.isHidden =  true
                alert!.btnFrame =  true
                let messagePreorderable = NSLocalizedString("alert.presalewishlist",comment:"")
                alert!.setMessage(messagePreorderable)
                alert!.addActionButtonsWithCustomText("Cancelar", leftAction: { () -> Void in
                    alert!.close()
                    }, rightText: "Ok", rightAction: { () -> Void in
                        self.sendNewItemsToShoppingCart(params)
                        alert!.close()
                    }, isNewFrame: false)
            }else {
                
                if totArticlesMG == 0 {
                    self.sendNewItemsToShoppingCart(paramsPreorderable)
                }else{
                    var itemImage =  [String:Any]()
                    if paramsPreorderable.count == 0{
                     itemImage =  params[0] as! [String:Any]
                    }else{
                      itemImage =  paramsPreorderable[0] as! [String:Any]
                    }
                    let alert = IPOWMAlertViewController.showAlert(WishListViewController.createImage(itemImage["imgUrl"] as! String),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                    alert!.spinImage.isHidden =  true
                    alert!.viewBgImage.backgroundColor = UIColor.white
                    var messagePreorderable = NSLocalizedString("alert.presaleindependent",comment:"")
                    messagePreorderable =  NSLocalizedString("alert.presaleindependent",comment:"")
                    alert!.setMessage(messagePreorderable)
                    
                    
                    alert!.addActionButtonsWithCustomText("Cancelar", leftAction: { () -> Void in
                        print("Cancelar accion")
                        
                        alert!.close()
                        
                        
                        }, rightText: "Vaciar carrito y comprar este artículo", rightAction: { () -> Void in
                            WishListViewController.deleteAllShoppingCart({ () -> Void in
                                //Agregar al carrito
                                if paramsPreorderable.count == 0 {
                                     self.sendNewItemsToShoppingCart(params)
                                }else{
                                    if paramsPreorderable.count > 1 {
                                        self.sendNewItemsToShoppingCart([paramsPreorderable[0]])
                                    }else{
                                        self.sendNewItemsToShoppingCart(paramsPreorderable)
                                    }
                                }
                            })
                            self.buttonShop.isEnabled = true
                            alert!.close()
                            
                        },isNewFrame: true)//Close - addActionButtonsWithCustomText
                }
            }//close else
        }
        
        
        // Event
        BaseController.sendAnalyticsProductsToCart(Int(wishlistTotalPrice))
        
    }

    
    class func createImage(_ url:String) -> UIImage{
        let imageData = try! Data(contentsOf: URL(string: url)!)//urlImage["imgUrl"] as! String
        let image = UIImage(data:imageData)
        let newSize = CGSize(width: 60.0, height: 60.0)
        let RECT = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        UIBezierPath(roundedRect:RECT , cornerRadius: 10.0).addClip()
        image!.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    func sendNewItemsToShoppingCart(_ params:[Any]){
        
        if params.count > 0 {
            let paramsAll = ["allitems":params, "image":"wishlist_addToCart"] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddItemsToShopingCart.rawValue), object: self, userInfo: paramsAll as [AnyHashable: Any])
        }
  
        ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_ADD_ALL_WISHLIST.rawValue, label: "")
        
    }
    
    @IBAction func deletealltap(_ sender: AnyObject) {
        
        ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_DELETE_ALL_PRODUCTS_WISHLIST.rawValue, label: "")
        
        let serviceWishDelete = DeleteItemWishlistService()
        var upcsWL : [String]  = []
        for itemWishlist in self.items {
            let upc = itemWishlist["upc"] as! NSString
            upcsWL.append(upc as String)
        }
        serviceWishDelete.callServiceWithParams(["parameter":upcsWL], successBlock: { (result:[String:Any]) -> Void in
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
            { (wishlist:[String:Any]) -> Void in
                self.items = wishlist["items"] as! [[String:Any]]
            
                self.emptyView.isHidden = self.items.count > 0
                self.edit.isHidden = self.items.count == 0
            
                var total : Double = 0
                var positionArray: [Int] = []
                
                for itemWishList in self.items {
                    var price = NSString(string:"0")
                    if let priceVal = itemWishList["price"] as? NSString {
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
                    
                    self.position += 1
                    positionArray.append(self.position)
                }
                
                let listName = "Wishlist"
                let subCategory = ""
                let subSubCategory = ""
                BaseController.sendAnalyticsTagImpressions(self.items, positionArray: positionArray, listName: listName, mainCategory: "", subCategory: subCategory, subSubCategory: subSubCategory)
                
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
        deleteall.isHidden = self.items.count == 0 && self.isEdditing
        edit.isHidden = self.items.count == 0
        edit.isSelected = false
        edit.backgroundColor = WMColor.light_blue
        edit.tintColor = WMColor.light_blue

    }
    
    override func back() {
        super.back()
         ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_BACK_WISHLIST.rawValue, label: "")
    }
    
    
    
    class func deleteAllShoppingCart(_ onFinish:@escaping (() -> Void) ) {
        if let itemsInShoppingCart = UserCurrentSession.sharedInstance.itemsMG!["items"] as? [[String:Any]] {
            let serviceSCDelete = ShoppingCartDeleteProductsService()
            var upcs : [String] = []
            for itemSClist in itemsInShoppingCart {
                let upc = itemSClist["upc"] as! String
                upcs.append(upc)
            }
            
            serviceSCDelete.callService(serviceSCDelete.builParamsMultiple(upcs), successBlock: { (result:[String:Any]) -> Void in
                /* println("Error not done")
                
                self.reloadShoppingCart()
                self.navigationController!.popToRootViewControllerAnimated(true)
                */
                UserCurrentSession.sharedInstance.loadMGShoppingCart({ () -> Void in
                    
                    //self.startAddingToShoppingCart()
                    
                    onFinish()
                    
                })
                
                }) { (error:NSError) -> Void in
            }
        }
    }
}

extension WishListViewController: UIViewControllerPreviewingDelegate {
    //registerForPreviewingWithDelegate
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = wishlist?.indexPathForRow(at: location) {
            //This will show the cell clearly and blur the rest of the screen for our peek.
            if #available(iOS 9.0, *) {
                previewingContext.sourceRect = wishlist!.rectForRow(at: indexPath)
            }
            return self.getDetailController(indexPath:indexPath)
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController!.pushViewController(viewControllerToCommit, animated: true)
        //present(viewControllerToCommit, animated: true, completion: nil)
    }
}

extension WishListViewController: UIGestureRecognizerDelegate {
    
    func addLongTouch(view:UIView) {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(WishListViewController.handleLongPress(gestureReconizer:)))
        longPressGesture.minimumPressDuration = 0.6 // 1 second press
        longPressGesture.allowableMovement = 15 // 15 points
        longPressGesture.delegate = self
        view.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        
        let p = gestureReconizer.location(in: self.wishlist)
        let indexPath = wishlist!.indexPathForRow(at: p)
        
        if let viewControllerToCommit = self.getDetailController(indexPath: indexPath!) {
            viewControllerToCommit.view.frame.size = CGSize(width: self.view.frame.width - 20, height: self.view.frame.height - 45)
            
            if self.preview == nil {
                let cellFrame =  wishlist!.rectForRow(at: indexPath!)
                let cellFrameInSuperview = wishlist!.convert(cellFrame, to: wishlist!.superview)
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
