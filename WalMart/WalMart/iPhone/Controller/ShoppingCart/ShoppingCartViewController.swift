//
//  ShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/8/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import QuartzCore

protocol ShoppingCartViewControllerDelegate {
    func returnToView()
}

class ShoppingCartViewController : BaseController ,UITableViewDelegate,UITableViewDataSource,ProductShoppingCartTableViewCellDelegate,SWTableViewCellDelegate,ProductDetailCrossSellViewDelegate,AlertPickerViewDelegate {
    
    var viewLoad : WMLoadingView!
    
    var itemsInShoppingCart : [AnyObject]! = []
    var subtotal : NSNumber!
    var ivaprod : NSNumber!
    var totalest : NSNumber!
    var deleteall: UIButton!
    @IBOutlet var viewContent : UIView!
    var viewHerader : UIView!
    var viewShoppingCart : UITableView!
    var viewFooter : UIView!
    var delegate : ShoppingCartViewControllerDelegate!
    var titleView : UILabel!
    var buttonWishlist : UIButton!
    var buttonAsociate : UIButton!
    //var addProductToShopingCart : UIButton? = nil

    var isEmployeeDiscount: Bool = false
    
    var closeButton : UIButton!
    
    var idexesPath : [NSIndexPath]! = []
    
    var isEdditing = false
    var isSelectingProducts = false
    var editButton : UIButton!
    var buttonShop : UIButton!
    var customlabel : CurrencyCustomLabel!
    var checkVC : CheckOutViewController!
    
    var isWishListProcess = false
    
    var canceledAction : Bool = false
    var presentAddressFullScreen : Bool = false
    
    var showCloseButton : Bool = true

    var itemsUPC = []
    
     var picker : AlertPickerView!
     var selectedConfirmation : NSIndexPath!
     var alertView: IPOWMAlertViewController?
    let headerHeight: CGFloat = 46
    
    
    var emptyView : IPOShoppingCartEmptyView!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MGSHOPPINGCART.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = WMColor.shoppingCartTotalBgColor
        
        viewShoppingCart = UITableView(frame:CGRectMake(0, 46 , self.viewContent.frame.width, viewContent.frame.height - 0 - 46))
        viewShoppingCart.clipsToBounds = false
        viewShoppingCart.backgroundColor =  WMColor.shoppingCartTotalBgColor
        self.navigationController?.view.clipsToBounds = true
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_SHOPPINGCART.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
        
        
        self.view.backgroundColor = UIColor.clearColor()
        self.view.clipsToBounds = true
        
        viewHerader = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 46))
        viewHerader.backgroundColor = WMColor.shoppingCartHeader
        
        titleView = UILabel(frame: viewHerader.bounds)
        titleView.font = WMFont.fontMyriadProRegularOfSize(14)
        titleView.textColor = WMColor.shoppingCartHeaderTextColor
        titleView.text = NSLocalizedString("shoppingcart.title",comment:"")
        titleView.textAlignment = .Center
        
        
        
        editButton = UIButton(frame:CGRectMake(self.view.frame.width - 82, 12, 55, 22))
        editButton.setTitle(NSLocalizedString("shoppingcart.edit",comment:""), forState: UIControlState.Normal)
        editButton.setTitle(NSLocalizedString("shoppingcart.endedit",comment:""), forState: UIControlState.Selected)
        editButton.backgroundColor = WMColor.shoppingCartEditButtonBgColor
        editButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        editButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        editButton.layer.cornerRadius = 11
        editButton.addTarget(self, action: "editAction:", forControlEvents: UIControlEvents.TouchUpInside)
        editButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
        
        deleteall = UIButton(frame: CGRectMake(editButton.frame.minX - 72, 12, 75, 22))
        deleteall.setTitle(NSLocalizedString("wishlist.deleteall",comment:""), forState: UIControlState.Normal)
        deleteall.backgroundColor = WMColor.wishlistDeleteButtonBgColor
        deleteall.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        deleteall.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        deleteall.layer.cornerRadius = 11
        deleteall.alpha = 0
        deleteall.titleEdgeInsets = UIEdgeInsetsMake(2.0, 2.0, 0.0, 0.0)
        deleteall.addTarget(self, action: "deleteAll", forControlEvents: UIControlEvents.TouchUpInside)
        
        closeButton = UIButton(frame:CGRectMake(0, 0, viewHerader.frame.height, viewHerader.frame.height))
        //closeButton.setTitle(NSLocalizedString("shoppingcart.keepshoppinginsidecart",comment:""), forState: UIControlState.Normal)
        closeButton.setImage(UIImage(named: "BackProduct"), forState: UIControlState.Normal)
        //closeButton.backgroundColor = WMColor.shoppingCartEditButtonBgColor
        //closeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        //closeButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        //closeButton.layer.cornerRadius = 3
        closeButton.addTarget(self, action: "closeShoppingCart", forControlEvents: UIControlEvents.TouchUpInside)
        
        viewHerader.addSubview(closeButton)
        viewHerader.addSubview(editButton)
        viewHerader.addSubview(deleteall)
        viewHerader.addSubview(titleView)
        
        
        viewFooter = UIView()
        viewFooter.backgroundColor = WMColor.shoppingCartFooter
        
        var x:CGFloat = 16
        if UserCurrentSession.sharedInstance().isAssociated == 1{
            
            buttonAsociate = UIButton(frame: CGRectMake(16, 16, 40, 40))
            buttonAsociate.setImage(UIImage(named:"active_dis"), forState: UIControlState.Normal)
            buttonAsociate.setImage(UIImage(named:"active_discount"), forState: UIControlState.Highlighted)
            buttonAsociate.addTarget(self, action: "validateAsociate", forControlEvents: UIControlEvents.TouchUpInside)
            viewFooter.addSubview(buttonAsociate)
            x =  buttonAsociate.frame.maxX + 16
        }
        
        buttonWishlist = UIButton(frame: CGRectMake(x, 16, 40, 40))
        buttonWishlist.setImage(UIImage(named:"detail_wishlistOff"), forState: UIControlState.Normal)
        buttonWishlist.addTarget(self, action: "addToWishList", forControlEvents: UIControlEvents.TouchUpInside)
        viewFooter.addSubview(buttonWishlist)
        
        buttonShop = UIButton(frame: CGRectMake(buttonWishlist.frame.maxX + 16, 16, self.view.frame.width - (buttonWishlist.frame.maxX + 32), 40))
        buttonShop.backgroundColor = WMColor.shoppingCartShopBgColor
        //buttonShop.setTitle(NSLocalizedString("shoppingcart.shop",comment:""), forState: UIControlState.Normal)
        buttonShop.layer.cornerRadius = 20
        buttonShop.addTarget(self, action: "showloginshop", forControlEvents: UIControlEvents.TouchUpInside)
        viewFooter.addSubview(buttonShop)
        
        let viewBorderTop = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 1))
        viewBorderTop.backgroundColor = WMColor.shoppingCartButtonContainerBorderViewColor
        viewFooter.addSubview(viewBorderTop)
        
        viewShoppingCart.registerClass(ProductShoppingCartTableViewCell.self, forCellReuseIdentifier: "productCell")
        viewShoppingCart.registerClass(ShoppingCartTotalsTableViewCell.self, forCellReuseIdentifier: "productTotalsCell")
        viewShoppingCart.registerClass(ShoppingCartCrossSellCollectionViewCell.self, forCellReuseIdentifier: "crossSellCell")
        
        viewShoppingCart.separatorStyle = .None
        
        viewShoppingCart.multipleTouchEnabled = false
        
        self.viewContent.addSubview(viewHerader)
        self.viewContent.addSubview(viewShoppingCart)
        self.viewContent.sendSubviewToBack(viewShoppingCart)
        self.viewContent.addSubview(viewFooter)


        
        picker = AlertPickerView.initPickerWithDefault()
        
       initEmptyView()
        
        loadShoppingCartService()
        
    }
    
    func initEmptyView(){
        emptyView = IPOShoppingCartEmptyView(frame:CGRectZero)
        emptyView.frame = CGRectMake(0,  viewHerader.frame.maxY,  self.view.frame.width,  self.view.frame.height - viewHerader.frame.height)
        emptyView.returnAction = {() in
            self.closeShoppingCart()
        }
        self.view.addSubview(emptyView)
        
        self.emptyView.iconImageView.image =  UIImage(named:"empty_cart")
        
    }
    
   
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.emptyView!.hidden = self.itemsInShoppingCart.count > 0
        self.editButton.hidden = self.itemsInShoppingCart.count == 0
        
        if !showCloseButton {
            self.closeButton.hidden = true
        } else {
            self.closeButton.hidden = false
        }

        self.isEdditing = false
        editButton.selected = false
        editButton.backgroundColor = WMColor.wishlistEditButtonBgColor
        editButton.tintColor = WMColor.wishlistEditButtonBgColor
        deleteall.alpha = 0
        
        UserCurrentSession.sharedInstance().loadMGShoppingCart { () -> Void in
            self.loadShoppingCartService()
        }
       
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadShoppingCart", name: CustomBarNotification.SuccessAddItemsToShopingCart.rawValue, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        
        self.buttonShop = UIButton(frame: CGRectMake(buttonWishlist.frame.maxX + 16, 16, self.view.frame.width - (buttonWishlist.frame.maxX + 32), 40))
        
        self.viewContent.frame = self.view.bounds
        self.viewFooter.frame = CGRectMake(0, viewContent.frame.height - 72 , self.viewContent.frame.width, 72)
        self.viewShoppingCart.frame =  CGRectMake(0, self.viewHerader.frame.maxY , self.viewContent.frame.width, viewContent.frame.height - self.viewFooter.frame.height - self.viewHerader.frame.maxY)

        self.titleView.frame = CGRectMake((self.viewHerader.bounds.width / 2) - ((self.view.bounds.width - 32)/2), self.viewHerader.bounds.minY, self.view.bounds.width - 32, self.viewHerader.bounds.height)

        self.editButton.frame = CGRectMake(self.view.frame.width - 71, 12, 55, 22)
        self.closeButton.frame = CGRectMake(0, 0, viewHerader.frame.height, viewHerader.frame.height)
        
        
        
    }
    
    
    func loadShoppingCartService() {

        idexesPath = []
        
        self.itemsInShoppingCart =  []
        if UserCurrentSession.sharedInstance().itemsMG != nil {
            self.itemsInShoppingCart = UserCurrentSession.sharedInstance().itemsMG!["items"] as! NSArray as [AnyObject]
        }
        
        if  self.itemsInShoppingCart.count > 0 {
            self.subtotal = UserCurrentSession.sharedInstance().itemsMG!["subtotal"] as! NSNumber
            self.ivaprod = UserCurrentSession.sharedInstance().itemsMG!["ivaSubtotal"] as! NSNumber
            self.totalest = UserCurrentSession.sharedInstance().itemsMG!["totalEstimado"] as! NSNumber
        }else{
            self.subtotal = NSNumber(int: 0)
            self.ivaprod = NSNumber(int: 0)
            self.totalest = NSNumber(int: 0)
        }
        
        
        let totalsItems = self.totalItems()
        let total = totalsItems["total"] as String!
        
        self.updateShopButton(total)
        
        self.viewShoppingCart.delegate = self
        self.viewShoppingCart.dataSource = self
        self.viewShoppingCart.reloadData()
        
        self.loadCrossSell()

    }
    
    func closeShoppingCart () {
        //EVENT
        BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue,categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue,action:WMGAIUtils.ACTION_BACK_PRE_SHOPPING_CART.rawValue , label: "")
        self.navigationController!.popToRootViewControllerAnimated(true)
    }

    
    func addToWishList () {
        
        if !self.isWishListProcess {
            self.isWishListProcess = true
            let animation = UIImageView(frame: CGRectMake(0, 0,36, 36));
            animation.center = self.buttonWishlist.center
            animation.image = UIImage(named:"detail_addToList")
            runSpinAnimationOnView(animation, duration: 100, rotations: 1, `repeat`: 100)
            self.viewFooter.addSubview(animation)
            var ixCount = 1
            
            //EVENT
            BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue,categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue,action:WMGAIUtils.ACTION_ADD_ALL_WISHLIST.rawValue , label: "")
            
            for shoppingCartProduct  in self.itemsInShoppingCart {
                let upc = shoppingCartProduct["upc"] as! String
                let desc = shoppingCartProduct["description"] as! String
                let price = shoppingCartProduct["price"] as! String
                //let quantity = shoppingCartProduct["quantity"] as! String
                
                var onHandInventory = "0"
                if let inventory = shoppingCartProduct["onHandInventory"] as? String {
                    onHandInventory = inventory
                }
                
                let imageArray = shoppingCartProduct["imageUrl"] as! NSArray
                var imageUrl = ""
                if imageArray.count > 0 {
                    imageUrl = imageArray.objectAtIndex(0) as! String
                }
                
                let serviceAdd = AddItemWishlistService()
                if ixCount < self.itemsInShoppingCart.count {
                    serviceAdd.callService(upc, quantity: "1", comments: "", desc: desc, imageurl: imageUrl, price: price as String, isActive: "true", onHandInventory: onHandInventory, isPreorderable: "false", mustUpdateWishList: false, successBlock: { (result:NSDictionary) -> Void in
                        //let path = NSIndexPath(forRow: , inSection: 0)

                        
                        }, errorBlock: { (error:NSError) -> Void in
                    })
                }else {
                    serviceAdd.callService(upc, quantity: "1", comments: "", desc: desc, imageurl: imageUrl, price: price, isActive: "true", onHandInventory: onHandInventory, isPreorderable: "false", mustUpdateWishList: true, successBlock: { (result:NSDictionary) -> Void in
                        self.showMessageWishList(NSLocalizedString("shoppingcart.wishlist.ready",comment:""))
                        animation.removeFromSuperview()
                        }, errorBlock: { (error:NSError) -> Void in
                            animation.removeFromSuperview()
                    })
                }
                ixCount++
                
            }
        }

    }
    
    func runSpinAnimationOnView(view:UIView,duration:CGFloat,rotations:CGFloat,`repeat`:CGFloat) {
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = Float(`repeat`)
        view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
        
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemsInShoppingCart.count > 0{
            if itemsUPC.count > 0 {
                return itemsInShoppingCart.count + 2
            }else {
                return itemsInShoppingCart.count + 1
            }
        }
        return 1

    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        if itemsInShoppingCart.count > indexPath.row {
            let cellProduct = viewShoppingCart.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! ProductShoppingCartTableViewCell
            cellProduct.delegateProduct = self
            cellProduct.delegate = self
            cellProduct.rightUtilityButtons = getRightButtonDelete()
            cellProduct.leftUtilityButtons = getLeftDelete()
            let shoppingCartProduct = self.itemsInShoppingCart![indexPath.row] as! [String:AnyObject]
            let upc = shoppingCartProduct["upc"] as! String
            let desc = shoppingCartProduct["description"] as! String
            let price = shoppingCartProduct["price"] as! String
            let quantity = shoppingCartProduct["quantity"] as! NSString
            
            var onHandInventory = "0"
            if let inventory = shoppingCartProduct["onHandInventory"] as? String {
                onHandInventory = inventory
            }


            let imageArray = shoppingCartProduct["imageUrl"] as! NSArray
            var imageUrl = ""
            if imageArray.count > 0 {
                imageUrl = imageArray.objectAtIndex(0) as! String
            }
            
            let savingIndex = shoppingCartProduct.indexForKey("saving")
            var savingVal = "0.0"
            if savingIndex != nil {
                savingVal = shoppingCartProduct["saving"]  as! String
            }
            
            //updateItemSavingForUPC(indexPath,upc:upc)
            
            cellProduct.setValues(upc,productImageURL:imageUrl, productShortDescription: desc, productPrice: price, saving: savingVal,quantity:quantity.integerValue,onHandInventory:onHandInventory)
            
            if isEdditing == true {
                cellProduct.setEditing(true, animated: false)
                cellProduct.showLeftUtilityButtonsAnimated(false)
            }else{
                cellProduct.setEditing(false, animated: false)
                cellProduct.hideUtilityButtonsAnimated(true)
            }
            
            cell = cellProduct
        }
        else {
            if itemsInShoppingCart.count == indexPath.row  {
                let cellTotals = viewShoppingCart.dequeueReusableCellWithIdentifier("productTotalsCell", forIndexPath: indexPath) as! ShoppingCartTotalsTableViewCell
                
                let totalsItems = totalItems()
                
                let subTotalText = totalsItems["subtotal"] as String!
                let iva = totalsItems["iva"] as String!
                let total = totalsItems["total"] as String!
                let totalSaving = totalsItems["totalSaving"] as String!
                
                updateShopButton(total)
                
                 var newTotal  = total
                 var newTotalSavings = totalSaving
                if self.isEmployeeDiscount {
                    newTotal = "\((total as NSString).doubleValue - ((total as NSString).doubleValue *  UserCurrentSession.sharedInstance().porcentageAssociate))"
                    newTotalSavings = "\((totalSaving as NSString).doubleValue + ((total as NSString).doubleValue *  UserCurrentSession.sharedInstance().porcentageAssociate))"
                }
                
                cellTotals.setValues(subTotalText, iva: iva, total:newTotal,totalSaving:newTotalSavings)
                cell = cellTotals
            }
            if itemsInShoppingCart.count < indexPath.row  {
                
                let cellPromotion = viewShoppingCart.dequeueReusableCellWithIdentifier("crossSellCell", forIndexPath: indexPath) as? ShoppingCartCrossSellCollectionViewCell
                cellPromotion!.delegate = self
                cellPromotion!.itemsUPC = itemsUPC
                cellPromotion!.collection.reloadData()
                cell = cellPromotion
                
            }
        }
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if itemsInShoppingCart.count > indexPath.row && !isSelectingProducts  {
            let controller = ProductDetailPageViewController()
            controller.itemsToShow = getUPCItems()
            controller.ixSelected = indexPath.row
            
            let item = self.itemsInShoppingCart[indexPath.row] as! [String:AnyObject]
            let  name = item["description"] as! String
            let upc = item["upc"] as! String
            //EVENT
            BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue, label: "\(name) - \(upc)")
            if self.navigationController != nil {
                self.navigationController!.pushViewController(controller, animated: true)
            }
        }
        /*if isSelectingProducts {
            if let cell = viewShoppingCart.cellForRowAtIndexPath(indexPath) as? ProductShoppingCartTableViewCell {
                cell.priceSelector.removeBand()
            }
        }*/
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
    
    func getLeftDelete() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        let buttonDelete = UIButton(frame: CGRectMake(0, 0, 64, 109))
        buttonDelete.setImage(UIImage(named:"myList_delete"), forState: UIControlState.Normal)
        buttonDelete.backgroundColor = WMColor.wishlistDeleteLeftButtonBgColor
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if itemsInShoppingCart.count > indexPath.row {
            return 110
        }else{
            if itemsInShoppingCart.count == indexPath.row  {
                return 100
            }
            if itemsInShoppingCart.count < indexPath.row  {
                return 207
            }
        }
        return 0
    }
    
    
    
    //Se quita funcionalidad ya que el saving ya viene en el servicio
//    func updateItemSavingForUPC(indexPath: NSIndexPath,upc:String) {
    
//        let searchResult = idexesPath.filter({ (index) -> Bool in return index.row == indexPath.row })
//        if searchResult.count == 0 {
//            idexesPath.append(indexPath)
//            
//            let productService = ProductDetailService()
//            productService.callService(upc, successBlock: { (result: NSDictionary) -> Void in
//                let savingItem = result["saving"] as NSString
//                if self.itemsInShoppingCart.count > indexPath.row {
//                var itemByUpc  = self.itemsInShoppingCart![indexPath.row] as [String:AnyObject]
//                itemByUpc.updateValue(savingItem, forKey: "saving")
//                self.itemsInShoppingCart[indexPath.row] = itemByUpc
//                
//                self.viewShoppingCart.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
//                self.updateTotalItemsRow()
//                }
//                }) { (error:NSError) -> Void in
//                    
//                    
//            }
//        }
//        
        
//    }
    
    @IBAction func editAction(sender: AnyObject) {
        isEdditing = !isEdditing
        if (isEdditing) {
            let currentCells = self.viewShoppingCart.visibleCells
            for cell in currentCells {
                if cell.isKindOfClass(SWTableViewCell) {
                    let productCell = cell as! ProductShoppingCartTableViewCell
                    productCell.setEditing(true, animated: false)
                    productCell.showLeftUtilityButtonsAnimated(true)
                }
            }
            editButton.selected = true
            editButton.backgroundColor =  WMColor.UIColorFromRGB(0x8EBB36) // WMColor.wishlistEndEditButtonBgColor
            editButton.tintColor = WMColor.wishlistEndEditButtonBgColor
            
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.deleteall.alpha = 1
                self.titleView.frame = CGRectMake(self.titleView.frame.minX - 30, self.titleView.frame.minY, self.titleView.frame.width, self.titleView.frame.height)
            })
            
            //EVENT
            BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_EDIT_CART.rawValue, label: "")
            
        }else{
            let currentCells = self.viewShoppingCart.visibleCells
            for cell in currentCells {
                if cell.isKindOfClass(SWTableViewCell) {
                    let productCell = cell as! ProductShoppingCartTableViewCell
                    productCell.setEditing(false, animated: false)
                    productCell.hideUtilityButtonsAnimated(false)
                }
            }
            editButton.selected = false
            editButton.backgroundColor = WMColor.wishlistEditButtonBgColor
            editButton.tintColor = WMColor.wishlistEditButtonBgColor
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.deleteall.alpha = 0
                self.titleView.frame = CGRectMake(self.titleView.frame.minX + 30, self.titleView.frame.minY, self.titleView.frame.width, self.titleView.frame.height)
            })

        }
    }
    
    
    func startUpdatingShoppingCart() {
        //self.viewContent.addSubview(viewLoad)
        //viewLoad.startAnnimating()
    }
    
    
    func endUpdatingShoppingCart(cell:ProductShoppingCartTableViewCell) {
        let indexPath : NSIndexPath = self.viewShoppingCart.indexPathForCell(cell)!
        
        var itemByUpc  = self.itemsInShoppingCart![indexPath.row] as! [String:AnyObject]
        itemByUpc.updateValue(String(cell.quantity) , forKey: "quantity")
        self.itemsInShoppingCart[indexPath.row] = itemByUpc
        
        //viewLoad.stopAnnimating()
        self.updateTotalItemsRow()
    }
    
    func deleteProduct(cell:ProductShoppingCartTableViewCell) {
        let toUseCellIndex = self.viewShoppingCart.indexPathForCell(cell)
        if toUseCellIndex != nil {
            let indexPath : NSIndexPath = toUseCellIndex!
            deleteRowAtIndexPath(indexPath)
        }
    }
    
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch index {
        case 0:

            let indexPath = self.viewShoppingCart.indexPathForCell(cell)
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
            //let indexPath : NSIndexPath = self.viewShoppingCart.indexPathForCell(cell)!
            //deleteRowAtIndexPath(indexPath)
             cell.showRightUtilityButtonsAnimated(true)
        default :
            print("other pressed")
        }
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return !isEdditing
    }
    
    
    
    
    func deleteRowAtIndexPath(indexPath : NSIndexPath){
        let itemWishlist = itemsInShoppingCart[indexPath.row] as! [String:AnyObject]
        let upc = itemWishlist["upc"] as! String
        let deleteShoppingCartService = ShoppingCartDeleteProductsService()
        let descriptions =  itemWishlist["description"] as! String
        BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_PRODUCT_CART.rawValue, label: "\(descriptions) - \(upc)")
        
        deleteShoppingCartService.callCoreDataService(upc, successBlock: { (result:NSDictionary) -> Void in
            self.itemsInShoppingCart.removeAtIndex(indexPath.row)
            
            self.viewShoppingCart.reloadData()
            self.updateTotalItemsRow()
            
            if self.itemsInShoppingCart.count == 0 {
                self.navigationController!.popToRootViewControllerAnimated(true)
            }
            
            }, errorBlock: { (error:NSError) -> Void in
                print("delete pressed Errro \(error)")
        })
    }


    func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
        switch state {
            case SWCellState.CellStateLeft:
                return isEdditing
            case SWCellState.CellStateRight:
                return true
            case SWCellState.CellStateCenter:
                return !isEdditing
            //default:
            //   return !isEdditing && !self.isSelectingProducts
        }
    }
    
    func updateTotalItemsRow() {
        let totalIndexPath =  NSIndexPath(forRow: itemsInShoppingCart.count, inSection: 0)
        self.viewShoppingCart.reloadRowsAtIndexPaths([totalIndexPath], withRowAnimation: UITableViewRowAnimation.None)
        UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
    }
    
    func totalItems() -> [String:String] {
        
        var subtotal = 0.0
        var subtotalIVA = 0.0
        var total = 0.0
        var totalSavings = 0.0
        var showIva = true
        
        for shoppingCartProduct in  itemsInShoppingCart {
            let dictShoppingCartProduct = shoppingCartProduct as! [String:AnyObject]
            let price = shoppingCartProduct["price"] as! NSString
            
            var iva : NSString = ""
            if let ivabase = shoppingCartProduct["ivaAmount"] as? NSString {
                iva = ivabase
            }
            if let ivabase = shoppingCartProduct["ivaAmount"] as? NSNumber {
                iva = ivabase.stringValue
            }
            var baseprice : NSString = ""
            if let pricebase = shoppingCartProduct["basePrice"] as? NSString {
                baseprice = pricebase
            }
            if let pricebase = shoppingCartProduct["basePrice"] as? NSNumber {
                baseprice = pricebase.stringValue
            }
            
            var quantity : NSString = ""
            if let quantityN = shoppingCartProduct["quantity"] as? NSString {
                quantity = quantityN
            }
            if let quantityN = shoppingCartProduct["quantity"] as? NSNumber {
                quantity = quantityN.stringValue
            }


            //let quantity = shoppingCartProduct["quantity"] as NSString
            
            let savingIndex = dictShoppingCartProduct.indexForKey("saving")
            var savingVal : NSString = "0.0"
            if savingIndex != nil {
                savingVal = shoppingCartProduct["saving"]  as! String
                totalSavings += (savingVal.doubleValue * quantity.doubleValue)
            }
            total +=  (price.doubleValue * quantity.doubleValue)
            if showIva {
                if iva != "" {
                    subtotal +=  (baseprice.doubleValue * quantity.doubleValue)
                    subtotalIVA +=  (iva.doubleValue * quantity.doubleValue)
                }else {
                    showIva = false
                }
            }
            
        }
        
        //let subTotalStr =  totalest
        //let iva = ivaprod
        
        let totalInCart = NSNumber(double:total).stringValue
        var subtotalCart = ""
        var totalIVA = ""
        if showIva {
            subtotalCart = NSNumber(double:subtotal).stringValue
            totalIVA = NSNumber(double:subtotalIVA).stringValue
        }
        let totalSaving = NSNumber(double:totalSavings).stringValue
        
        return ["subtotal":subtotalCart,"iva":totalIVA,"total":totalInCart,"totalSaving":totalSaving]
    }

    func getExpensive() -> String {
        let priceLasiItem = 0.0
        var upc = ""
           for shoppingCartProduct in  itemsInShoppingCart {
            //let dictShoppingCartProduct = shoppingCartProduct as! [String:AnyObject]
            let price = shoppingCartProduct["price"] as! NSString
            if price.doubleValue < priceLasiItem {
                continue
            }
            upc = shoppingCartProduct["upc"] as! NSString as String
        }
        return upc
    }
    
    func getUPCItems() -> [[String:String]] {

        var upcItems : [[String:String]] = []
        for shoppingCartProduct in  itemsInShoppingCart {
            let upc = shoppingCartProduct["upc"] as! String
            let desc = shoppingCartProduct["description"] as! String
            upcItems.append(["upc":upc,"description":desc,"type":ResultObjectType.Mg.rawValue])
        }
        return upcItems
    }

    func goTODetailProduct(upc:String,items:[[String:String]],index:Int,imageProduct:UIImage?,point:CGRect){
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = items
        controller.ixSelected = index
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func startEdditingQuantity() {
       self.isSelectingProducts = true
    }
    func endEdditingQuantity(){
        self.isSelectingProducts = false
    }
    
    func openDiscount(){
        let discountAssociateItems = [NSLocalizedString("checkout.discount.associateNumber", comment:""),NSLocalizedString("checkout.discount.dateAdmission", comment:""),NSLocalizedString("checkout.discount.determinant", comment:"")]
        self.selectedConfirmation  = NSIndexPath(forRow: 0, inSection: 0)
        
        self.picker!.sender = self//self.discountAssociate!
        self.picker!.titleHeader = NSLocalizedString("checkout.field.discountAssociate", comment:"")
        self.picker!.delegate = self
        self.picker!.selected = self.selectedConfirmation
        self.picker!.setValues("Descuento de asociado", values: discountAssociateItems)
        self.picker!.hiddenRigthActionButton(true)
        self.picker!.cellType = TypeField.Alphanumeric
        self.picker!.showPicker()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillShow", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillHide", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    //Keyboart
    func keyBoardWillShow() {
        self.picker!.viewContent.center = CGPointMake(self.picker!.center.x, self.picker!.center.y - 85)
    }
    
    func keyBoardWillHide() {
        self.picker!.viewContent.center = self.picker!.center
    }

    func validateAsociate(){
        self.openDiscount()
    }

    
    func showloginshop() {
        picker?.closePicker()
        //Event
        BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_LOGIN_PRE_CHECKOUT.rawValue, label: "")
        
        self.canceledAction = false
        self.buttonShop.enabled = false
        self.buttonShop.alpha = 0.7
        //let storyboard = self.loadStoryboardDefinition()
        let addressService = AddressByUserService()
        
        self.buttonShop.enabled = true
        self.buttonShop.alpha = 1.0
        let cont = LoginController.showLogin()
        var user = ""
        if UserCurrentSession.hasLoggedUser() {
            cont!.noAccount?.hidden = true
            cont!.registryButton?.hidden = true
            cont!.valueEmail = UserCurrentSession.sharedInstance().userSigned!.email as String
            cont!.email?.text = UserCurrentSession.sharedInstance().userSigned!.email as String
            cont!.email!.enabled = false
            user = UserCurrentSession.sharedInstance().userSigned!.email as String
        }
        cont.isMGLogin =  true
        cont!.closeAlertOnSuccess = false
        cont!.okCancelCallBack = {() in
            self.canceledAction = true
            //let response = self.navigationController?.popToRootViewControllerAnimated(true)
            cont!.closeAlert(true, messageSucesss:false)
        }
        cont!.successCallBack = {() in
            
            if UserCurrentSession.hasLoggedUser() {
                if user !=  UserCurrentSession.sharedInstance().userSigned!.email {
                    NSNotificationCenter.defaultCenter().postNotificationName(ProfileNotification.updateProfile.rawValue, object: nil)
                    //self.reloadShoppingCart()
                }
            }
            
            addressService.callService({ (resultCall:NSDictionary) -> Void in
                var presentAddres = true
                if let shippingAddress = resultCall["shippingAddresses"] as? NSArray
                {
                    if shippingAddress.count > 0 {
                        presentAddres = false
                        self.presentedCheckOut(cont!, address: nil)
                    }
                }
                if presentAddres {
                    let address = AddressViewController()
                    address.typeAddress = TypeAddress.Shiping
                    address.item =  NSDictionary()
                    address.successCallBack = {() in
                        address.closeAlert()
                        if(cont!.email?.text == nil || cont!.email?.text == "" ){
                            cont!.email?.text = cont!.signUp.email?.text
                            cont!.password?.text = cont!.signUp.password?.text
                        }
                        self.presentedCheckOut(cont!, address: address)
                    }
                    self.navigationController!.pushViewController(address, animated: true)
                    cont!.closeAlert(true, messageSucesss: true)
                }
                }, errorBlock: { (error:NSError) -> Void in
                    
                    self.buttonShop.enabled = true
                    self.buttonShop.alpha = 1.0
                    print("errorBlock")
                    let address = AddressViewController()
                    address.typeAddress = TypeAddress.Shiping
                    address.item =  NSDictionary()
                    address.successCallBack = {() in
                        address.closeAlert()
                        if(cont!.email?.text == nil || cont!.email?.text == "" ){
                            cont!.email?.text = cont!.signUp.email?.text
                            cont!.password?.text = cont!.signUp.password?.text
                        }
                        self.presentedCheckOut(cont!, address: address)
                    }
                    self.navigationController!.pushViewController(address, animated: true)
                    
                    cont!.closeAlert(true, messageSucesss: true)
            })
        }
    }
    
    
    
    func presentedCheckOut(loginController: LoginController, address: AddressViewController?){
        UserCurrentSession.sharedInstance().loadMGShoppingCart { () -> Void in
            let serviceReview = ReviewShoppingCartService()
            serviceReview.callService([:], successBlock: { (result:NSDictionary) -> Void in
                if !self.canceledAction  {
                    self.checkVC = self.checkOutController()
                    self.checkVC.afterclose = {() -> Void in self.checkVC = nil }
                    self.checkVC.username = loginController.email?.text
                    self.checkVC.password = loginController.password?.text
                    self.checkVC.isEmployeeDiscount = self.isEmployeeDiscount
                    self.checkVC.finishLoadCheckOut = {() in
                       
                        if address != nil {
                            address!.closeAlert()
                        }
                        
                        if loginController.alertView != nil {
                            loginController.closeAlert(true, messageSucesss: true)
                        }else {
                            loginController.closeModal()
                        }
                      
                    }
                    
                    loginController.alertView?.okCancelCallBack = {() in
                        //check.back()
                        self.canceledAction = true
                        //let response = self.navigationController?.popToRootViewControllerAnimated(true)
                        
                        
                        if loginController.alertView != nil {
                            loginController.closeAlert(true, messageSucesss: false)
                        }else {
                            loginController.closeModal()
                        }
                        
                        if address != nil {
                            address!.closeAlert()
                        }
                        
                        if self.navigationController != nil {
                            self.navigationController!.popViewControllerAnimated(false)
                        }

                        
                    }
                    
                    self.navigationController?.pushViewController(self.checkVC, animated: true)
                    self.canceledAction = false
                    
                    if self.presentAddressFullScreen {
                        loginController.closeModal()
                    }
                        
                    else {
                        if loginController.alertView != nil {
                            loginController.alertView?.okCancelCallBack = {() in
                                //check.back()
                                self.canceledAction = true
                                if self.navigationController != nil {
                                    self.navigationController!.popViewControllerAnimated(false)
                                }
                                //let response = self.navigationController?.popToRootViewControllerAnimated(true)
                                loginController.closeAlert(true, messageSucesss: false)
                            }
                            
                            loginController.alertView?.successCallBack = {() in
                                //check.back()
                                //let response = self.navigationController?.popToRootViewControllerAnimated(true)
                                //loginController.closeAlert()
                            }
                        }
                        else {
                            loginController.closeModal()
                        }
                    }
                }
                }) { (error:NSError) -> Void in
                    if error.code == 1 {
                        if !self.canceledAction  {
                            self.checkVC = self.checkOutController()
                            self.checkVC.afterclose = {() -> Void in self.checkVC = nil }
                            self.checkVC.username = loginController.email?.text
                            self.checkVC.password = loginController.password?.text
                            self.checkVC.finishLoadCheckOut = {() in
                                loginController.closeAlert(true, messageSucesss: true)
                            }
                            self.navigationController?.pushViewController(self.checkVC, animated: true)
                            if self.presentAddressFullScreen {
                                loginController.alertView?.okCancelCallBack = {() in
                                    //check.back()
                                    self.canceledAction = true
                                    if self.navigationController != nil {
                                        self.navigationController!.popViewControllerAnimated(false)
                                    }
                                    loginController.closeModal()
                                }
                            }
                            else {
                                if loginController.alertView != nil {
                                    loginController.alertView?.successCallBack = {() in
                                        //let response = self.navigationController?.popToRootViewControllerAnimated(true)
                                    }
                                    loginController.alertView?.okCancelCallBack = {() in
                                        //check.back()
                                        self.canceledAction = true
                                        if self.navigationController != nil {
                                            //let response = self.navigationController!.popViewControllerAnimated(false)
                                            loginController.closeAlert(true, messageSucesss: false)
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
            }

        }
    }

    func reloadShoppingCart () {
        //self.viewContent.addSubview(viewLoad)
        //viewLoad.startAnnimating()
        idexesPath = []
        UserCurrentSession.sharedInstance().loadMGShoppingCart { () -> Void in
            self.loadShoppingCartService()
        }
        
    }
    
    func updateShopButton(total:String) {
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: self.buttonShop.bounds)
            customlabel.backgroundColor = UIColor.clearColor()
            customlabel.setCurrencyUserInteractionEnabled(true)
            buttonShop.addSubview(customlabel)
            buttonShop.sendSubviewToBack(customlabel)
        }
        var newTotal  = total
        if self.isEmployeeDiscount {
            newTotal = "\((total as NSString).doubleValue - ((total as NSString).doubleValue *  UserCurrentSession.sharedInstance().porcentageAssociate))"
            self.totalest = (newTotal as NSString).doubleValue
        }
        
        let shopStr = NSLocalizedString("shoppingcart.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(newTotal)
        let shopStrComplete = "\(shopStr) \(fmtTotal)"
        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.whiteColor(), interLine: false)
        
    }
    
    func generateImageOfView(viewCapture:UIView) -> UIImage {
        var cloneImage : UIImage? = nil
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(viewCapture.frame.size, false, 1.0);
            viewCapture.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            cloneImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        return cloneImage!
    }
    
    func loadCrossSell() {
        if self.itemsInShoppingCart.count >  0 {
            let upcValue = getExpensive()
            let crossService = CrossSellingProductService()
            crossService.callService(upcValue, successBlock: { (result:NSArray?) -> Void in
                if result != nil {
                    
                    var isShowingBeforeLeave = false
                    if self.tableView(self.viewShoppingCart, numberOfRowsInSection: 0) == self.itemsInShoppingCart.count + 2 {
                        isShowingBeforeLeave = true
                    }
                    
                    self.itemsUPC = result!
                    if self.itemsUPC.count > 3 {
                        var arrayUPCS = self.itemsUPC as [AnyObject]
                        arrayUPCS.sortInPlace({ (before, after) -> Bool in
                            let priceB = before["price"] as! NSString
                            let priceA = after["price"] as! NSString
                            return priceB.doubleValue < priceA.doubleValue
                        })
                        var resultArray : [AnyObject] = []
                        for item in arrayUPCS[0...2] {
                            resultArray.append(item)
                        }
                        self.itemsUPC = NSArray(array:resultArray)
                        
                    }
                    if self.itemsInShoppingCart.count >  0  {
                        if self.itemsUPC.count > 0  && !isShowingBeforeLeave {
                            self.viewShoppingCart.insertRowsAtIndexPaths([NSIndexPath(forItem: self.itemsInShoppingCart.count + 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                        }else{
                            self.viewShoppingCart.reloadRowsAtIndexPaths([NSIndexPath(forItem: self.itemsInShoppingCart.count + 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                        }
                    }
                    //self.collection.reloadData()
                }else {
                    
                }
                }, errorBlock: { (error:NSError) -> Void in
                    print("Termina sevicio app")
            })
        }
    }
    

    
    func showMessageWishList(message:String) {
        let addedAlertWL = WishlistAddProductStatus(frame: CGRectMake(self.viewFooter.frame.minX, self.viewFooter.frame.minY , self.viewFooter.frame.width, 0))
        addedAlertWL.generateBlurImage(self.view,frame:CGRectMake(self.viewFooter.frame.minX, -96, self.viewFooter.frame.width, 96))
        addedAlertWL.clipsToBounds = true
        addedAlertWL.imageBlurView.frame = CGRectMake(self.viewFooter.frame.minX, -96, self.viewFooter.frame.width, 96)
        addedAlertWL.textView.text = message
        self.view.addSubview(addedAlertWL)
        self.isWishListProcess = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            addedAlertWL.frame = CGRectMake(self.viewFooter.frame.minX,self.viewFooter.frame.minY - 48, self.viewFooter.frame.width, 48)
            }) { (complete:Bool) -> Void in
                UIView.animateWithDuration(0.5, delay: 1, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                    addedAlertWL.frame = CGRectMake(addedAlertWL.frame.minX, self.viewFooter.frame.minY , addedAlertWL.frame.width, 0)
                    }) { (complete:Bool) -> Void in
                        addedAlertWL.removeFromSuperview()
                }
        }
        
        
    }
    
    func deleteAll() {
        let serviceSCDelete = ShoppingCartDeleteProductsService()
        var upcs : [String] = []
        for itemSClist in self.itemsInShoppingCart {
            let upc = itemSClist["upc"] as! String
            upcs.append(upc)
        }
        
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.whiteColor()
            viewLoad.startAnnimating(false)
            self.view.addSubview(viewLoad)
        }
        
        serviceSCDelete.callService(serviceSCDelete.builParamsMultiple(upcs), successBlock: { (result:NSDictionary) -> Void in
           /* println("Error not done")
            
            self.reloadShoppingCart()
            self.navigationController!.popToRootViewControllerAnimated(true)
            */
            UserCurrentSession.sharedInstance().loadMGShoppingCart({ () -> Void in
                //self.reloadShoppingCart()
                
                if self.viewLoad != nil {
                    self.viewLoad.stopAnnimating()
                    self.viewLoad = nil
                }
                
                print("done")
                
                //EVENT
                BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_ALL_PRODUCTS_CART.rawValue, label: "")
                
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
            
            }) { (error:NSError) -> Void in
        }
       
    }
    
    func checkOutController() -> CheckOutViewController {
        return CheckOutViewController()
    }
    
    //MARK: AlertPickerViewDelegate
    func didSelectOption(picker: AlertPickerView, indexPath: NSIndexPath, selectedStr: String) {
        
        let paramsDic = picker.textboxValues!
        let associateNumber = paramsDic[NSLocalizedString("checkout.discount.associateNumber", comment:"")]
        let dateAdmission = paramsDic[NSLocalizedString("checkout.discount.dateAdmission", comment:"")]
        let determinant = paramsDic[NSLocalizedString("checkout.discount.determinant", comment:"")]
        
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"user_error"))
        self.alertView?.setMessage("Validando datos del asociado")
        
        validateAssociate(associateNumber, dateAdmission:dateAdmission , determinant:determinant,completion: { (result:String) -> Void in
            if result == ""{
                let service = ValidateAssociateService()
                service.callService(requestParams: service.buildParams(associateNumber!, dateAdmission:dateAdmission!, determinant: determinant!),
                    succesBlock: { (response:NSDictionary) -> Void in
                        print(response)
                        if response["codeMessage"] as? Int == 0 {
                            //Mostrar alerta y continua
                            self.alertView?.setMessage("Datos correctos")
                            self.buttonAsociate.highlighted =  true
                            self.alertView?.close()
                            self.isEmployeeDiscount =  true
                            self.loadShoppingCartService()
                            self.viewShoppingCart.reloadData()
                            self.updateTotalItemsRow()
                            //self.showloginshop()
                        }else{
                            self.isEmployeeDiscount =  false
                            self.alertView?.setMessage("Error en los datos del asociado")
                            self.alertView!.showErrorIcon("Ok")
                            self.buttonAsociate.highlighted =  false
                        }
                        
                    }) { (error:NSError) -> Void in
                        // mostrar alerta de error de info
                        self.isEmployeeDiscount =  false
                        self.alertView?.setMessage("Error en los datos del asociado")
                        self.alertView!.showErrorIcon("Ok")
                         self.buttonAsociate.highlighted =  false
                        print(error)
                }
            }else{
                self.isEmployeeDiscount =  false
                self.alertView?.setMessage("Error en los datos del asociado\(result)")
                self.alertView!.showErrorIcon("Ok")
                 self.buttonAsociate.highlighted =  false
            }
        
    })
    
        
        
    }
    
    func validateAssociate(associateNumber:String?,dateAdmission:String?,determinant:String?, completion: (result:String) -> Void) {
        var message = ""
        
        if associateNumber == nil ||  associateNumber?.trim() == "" {
             message =  ", Número de asociado requerido"
        }
        else if dateAdmission == nil ||  dateAdmission?.trim() == ""{
             message =  ", Fecha de ingreso requerida"
        }
        else if determinant == nil || determinant?.trim() == ""{
             message =  ", Determinante requerido"
        }
        
        completion(result: message)
        
    }
  
    func didDeSelectOption(picker:AlertPickerView){
    }
    
    func viewReplaceContent(frame: CGRect) -> UIView! {
        let view: UIView! =  UIView(frame: self.view.frame)
        
        
        return view
        
    }

    func saveReplaceViewSelected() {
        
    }
    
    func buttomViewSelected(sender: UIButton) {
        
    }


    
}