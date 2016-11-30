//
//  ShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/8/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import QuartzCore
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


protocol ShoppingCartViewControllerDelegate {
    func returnToView()
}

class ShoppingCartViewController : BaseController ,UITableViewDelegate,UITableViewDataSource,ProductShoppingCartTableViewCellDelegate,SWTableViewCellDelegate,ProductDetailCrossSellViewDelegate,AlertPickerViewDelegate {
    
    var viewLoad : WMLoadingView!
    
    var itemsInShoppingCart : [[String:Any]]! = []
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
    var beforeShopTag: Bool = false
    
    //var addProductToShopingCart : UIButton? = nil

    var isEmployeeDiscount: Bool = false
    
    var closeButton : UIButton!
    
    var idexesPath : [IndexPath]! = []
    
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

    var itemsUPC: [[String:Any]] = []
    
     var picker : AlertPickerView!
     var selectedConfirmation : IndexPath!
     var alertView: IPOWMAlertViewController?
    var containerView : UIImage!
    var visibleLabel = false
    let headerHeight: CGFloat = 46
    
    
    var emptyView : IPOShoppingCartEmptyView!
    var totalShop: Double = 0.0
    var selectQuantity: ShoppingCartQuantitySelectorView?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MGSHOPPINGCART.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = WMColor.light_light_gray
        
        viewShoppingCart = UITableView(frame:CGRect(x: 0, y: 46 , width: self.viewContent.frame.width, height: viewContent.frame.height - 46))
        viewShoppingCart.clipsToBounds = false
        viewShoppingCart.backgroundColor =  WMColor.light_light_gray
        //self.navigationController?.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.clear
        self.view.clipsToBounds = true
        
        viewHerader = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 46))
        viewHerader.backgroundColor = WMColor.light_light_gray
        
        titleView = UILabel(frame: viewHerader.bounds)
        titleView.font = WMFont.fontMyriadProRegularOfSize(14)
        titleView.textColor = WMColor.light_blue
        titleView.text = NSLocalizedString("shoppingcart.title",comment:"")
        titleView.textAlignment = .center
        
        
        
        editButton = UIButton(frame:CGRect(x: self.view.frame.width - 82, y: 12, width: 55, height: 22))
        editButton.setTitle(NSLocalizedString("shoppingcart.edit",comment:""), for: UIControlState())
        editButton.setTitle(NSLocalizedString("shoppingcart.endedit",comment:""), for: UIControlState.selected)
        editButton.backgroundColor = WMColor.light_blue
        editButton.setTitleColor(UIColor.white, for: UIControlState())
        editButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        editButton.layer.cornerRadius = 11
        editButton.addTarget(self, action: #selector(ShoppingCartViewController.editAction(_:)), for: UIControlEvents.touchUpInside)
        editButton.titleEdgeInsets = UIEdgeInsetsMake(1.0, 0.0, 1.0, 0.0)
        
        deleteall = UIButton(frame: CGRect(x: editButton.frame.minX - 72, y: 12, width: 75, height: 22))
        deleteall.setTitle(NSLocalizedString("wishlist.deleteall",comment:""), for: UIControlState())
        deleteall.backgroundColor = WMColor.red
        deleteall.setTitleColor(UIColor.white, for: UIControlState())
        deleteall.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        deleteall.layer.cornerRadius = 11
        deleteall.alpha = 0
        deleteall.titleEdgeInsets = UIEdgeInsetsMake(1.0, 1.0, 0.0, 0.0)
        deleteall.addTarget(self, action: #selector(ShoppingCartViewController.deleteAll), for: UIControlEvents.touchUpInside)
        
        closeButton = UIButton(frame:CGRect(x: 0, y: 0, width: viewHerader.frame.height, height: viewHerader.frame.height))
        //closeButton.setTitle(NSLocalizedString("shoppingcart.keepshoppinginsidecart",comment:""), forState: UIControlState.Normal)
        closeButton.setImage(UIImage(named: "BackProduct"), for: UIControlState())
        //closeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        //closeButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        //closeButton.layer.cornerRadius = 3
        closeButton.addTarget(self, action: #selector(ShoppingCartViewController.closeShoppingCart), for: UIControlEvents.touchUpInside)
        
        viewHerader.addSubview(closeButton)
        viewHerader.addSubview(editButton)
        viewHerader.addSubview(deleteall)
        viewHerader.addSubview(titleView)
        
        
        viewFooter = UIView()
        viewFooter.backgroundColor = UIColor.white
        
        
        //--
        self.showDiscountAsociate()
        
        buttonShop.backgroundColor = WMColor.green
        //buttonShop.setTitle(NSLocalizedString("shoppingcart.shop",comment:""), forState: UIControlState.Normal)
        buttonShop.layer.cornerRadius = 17
        buttonShop.addTarget(self, action: #selector(ShoppingCartViewController.showloginshop), for: UIControlEvents.touchUpInside)
        viewFooter.addSubview(buttonShop)
        
        let viewBorderTop = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        viewBorderTop.backgroundColor = WMColor.light_light_gray
        viewFooter.addSubview(viewBorderTop)
        
        viewShoppingCart.register(ProductShoppingCartTableViewCell.self, forCellReuseIdentifier: "productCell")
        viewShoppingCart.register(ShoppingCartTotalsTableViewCell.self, forCellReuseIdentifier: "productTotalsCell")
        viewShoppingCart.register(ShoppingCartCrossSellCollectionViewCell.self, forCellReuseIdentifier: "crossSellCell")
        
        viewShoppingCart.separatorStyle = .none
        
        viewShoppingCart.isMultipleTouchEnabled = false
        
        self.viewContent.addSubview(viewHerader)
        self.viewContent.addSubview(viewShoppingCart)
        self.viewContent.sendSubview(toBack: viewShoppingCart)
        self.viewContent.addSubview(viewFooter)


        
        picker = AlertPickerView.initPickerWithDefault()
        
       initEmptyView()
        
        loadShoppingCartService()
        
        BaseController.setOpenScreenTagManager(titleScreen: "Carrito", screenName: self.getScreenGAIName())
        UserCurrentSession.sharedInstance.nameListToTag = "Shopping Cart"
        
    }
    
    /**
         Present empty view after load items in car
     
     - returns: na
     */
    func initEmptyView(){
        emptyView = IPOShoppingCartEmptyView(frame:CGRect.zero)
        emptyView.frame = CGRect(x: 0,  y: viewHerader.frame.maxY,  width: self.view.frame.width,  height: self.view.frame.height - viewHerader.frame.height)
        emptyView.returnAction = {() in
            self.closeShoppingCart()
        }
        self.view.addSubview(emptyView)
        
        self.emptyView.iconImageView.image =  UIImage(named:"empty_cart")
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.viewLoad == nil {
            self.showLoadingView()
        }
        
        self.emptyView!.isHidden = self.itemsInShoppingCart.count > 0
        self.editButton.isHidden = self.itemsInShoppingCart.count == 0
        
        if !showCloseButton {
            self.closeButton.isHidden = true
        } else {
            self.closeButton.isHidden = false
        }

        self.isEdditing = false
        editButton.isSelected = false
        editButton.backgroundColor = WMColor.light_blue
        editButton.tintColor = WMColor.light_blue
        deleteall.alpha = 0
        
        UserCurrentSession.sharedInstance.loadMGShoppingCart { () -> Void in
            self.loadShoppingCartService()
        }
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ShoppingCartViewController.reloadShoppingCart), name: NSNotification.Name(rawValue: CustomBarNotification.SuccessAddItemsToShopingCart.rawValue), object: nil)
        self.showDiscountAsociate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        
       // self.buttonShop = UIButton(frame: CGRectMake(buttonWishlist.frame.maxX + 16, 16, self.view.frame.width - (buttonWishlist.frame.maxX + 32), 34))
        
        self.viewContent.frame = self.view.bounds
        self.viewFooter.frame = CGRect(x: 0, y: viewContent.frame.height - 72 , width: self.viewContent.frame.width, height: 72)
        self.viewShoppingCart.frame =  CGRect(x: 0, y: self.viewHerader.frame.maxY , width: self.view.bounds.width, height: viewContent.frame.height - self.viewFooter.frame.height - self.viewHerader.frame.maxY)

        if !self.isEdditing {
        self.titleView.frame = CGRect(x: (self.viewHerader.bounds.width / 2) - ((self.view.bounds.width - 32)/2), y: self.viewHerader.bounds.minY, width: self.view.bounds.width - 32, height: self.viewHerader.bounds.height)
        }

        self.editButton.frame = CGRect(x: self.view.frame.width - 71, y: 12, width: 55, height: 22)
        self.closeButton.frame = CGRect(x: 0, y: 0, width: viewHerader.frame.height, height: viewHerader.frame.height)
        if UserCurrentSession.sharedInstance.userSigned != nil {
            if UserCurrentSession.sharedInstance.isAssociated == 1{
                    self.associateDiscount("Si tienes descuento de asociado captura aquí tus datos")
            }
        }
            
        
    }
    
    func showDiscountAsociate(){
        var x:CGFloat = 16
        self.loadShoppingCartService()
        if UserCurrentSession.sharedInstance.userSigned != nil {
            if UserCurrentSession.sharedInstance.isAssociated == 1{
                if buttonAsociate == nil {
                    buttonAsociate = UIButton(frame: CGRect(x: 16, y: 16, width: 34, height: 34))
                }else{
                    buttonAsociate.frame = CGRect(x: 16, y: 16, width: 34, height: 34)
                }
                
                buttonAsociate.setImage(UIImage(named:"active_dis"), for: UIControlState())
                buttonAsociate.setImage(UIImage(named:"active_discount"), for: UIControlState.highlighted)
                buttonAsociate.addTarget(self, action: #selector(ShoppingCartViewController.validateAsociate), for: UIControlEvents.touchUpInside)
                viewFooter.addSubview(buttonAsociate)
                x =  buttonAsociate.frame.maxX + 16
            }
        }
        if buttonWishlist ==  nil {
            buttonWishlist = UIButton(frame: CGRect(x: x, y: 16, width: 34, height: 34))
        }else{
            buttonWishlist.frame = CGRect(x: x, y: 16, width: 34, height: 34)
        }
        buttonWishlist.setImage(UIImage(named:"detail_wishlistOff"), for: UIControlState())
        buttonWishlist.addTarget(self, action: #selector(ShoppingCartViewController.addToWishList), for: UIControlEvents.touchUpInside)
        viewFooter.addSubview(buttonWishlist)
        var wShop : CGFloat =  341 - 82
        if UserCurrentSession.sharedInstance.userSigned != nil {
            if UserCurrentSession.sharedInstance.isAssociated == 1{
                if buttonAsociate ==  nil {
                    buttonAsociate = UIButton(frame: CGRect(x: 16, y: 16, width: 34, height: 34))
                }else{
                    buttonAsociate.frame =  CGRect(x: 16, y: 16, width: 40, height: 40)
                }
                x = buttonAsociate.frame.maxX + 16
                wShop = 341 - 135
            }
        }
        if buttonShop == nil {
            buttonShop = UIButton(frame: CGRect(x: buttonWishlist.frame.maxX + 16, y: buttonWishlist.frame.minY  ,width: wShop - 16, height: 34))
        }else {
            buttonShop.frame = CGRect(x: buttonWishlist.frame.maxX + 16, y: buttonWishlist.frame.minY  , width: wShop - 16, height: 34)
        }

    
    }
    
    /**
     Load items in shopping cart, anda create cell width totals, 
     if no containt items back to shopping cart
     */
    func loadShoppingCartService() {

        idexesPath = []
        
        self.itemsInShoppingCart =  []
        if UserCurrentSession.sharedInstance.itemsMG != nil {
            self.itemsInShoppingCart = UserCurrentSession.sharedInstance.itemsMG!["items"] as! [[String : Any]]!
        }
        
        if self.itemsInShoppingCart.count == 0 {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        if  self.itemsInShoppingCart.count > 0 {
            self.subtotal = UserCurrentSession.sharedInstance.itemsMG!["subtotal"] as! NSNumber
            self.ivaprod = UserCurrentSession.sharedInstance.itemsMG!["ivaSubtotal"] as! NSNumber
            self.totalest = UserCurrentSession.sharedInstance.itemsMG!["totalEstimado"] as! NSNumber
        }else{
            self.subtotal = NSNumber(value: 0 as Int32)
            self.ivaprod = NSNumber(value: 0 as Int32)
            self.totalest = NSNumber(value: 0 as Int32)
        }
        
        
        let totalsItems = self.totalItems()
        let total = totalsItems["total"] as String!
        if self.buttonShop != nil {
            self.updateShopButton(total!)
        }
        
        self.viewShoppingCart.delegate = self
        self.viewShoppingCart.dataSource = self
        self.viewShoppingCart.reloadData()
        
        
        self.loadCrossSell()
        
        self.removeLoadingView()

    }
    
    /**
     Close sopping cart mg and send tag Analytics
     */
    func closeShoppingCart () {
        //EVENT
        ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue,categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue,action:WMGAIUtils.ACTION_BACK_PRE_SHOPPING_CART.rawValue , label: "")
        self.navigationController!.popToRootViewController(animated: true)
    }

    /**
     Add items from shopping cart to wishlist, call service Add Item Wishlist
     */
    func addToWishList () {
        
        if !self.isWishListProcess {
            self.isWishListProcess = true
            let animation = UIImageView(frame: CGRect(x: 0, y: 0,width: 36, height: 36));
            animation.center = self.buttonWishlist.center
            animation.image = UIImage(named:"detail_addToList")
            runSpinAnimationOnView(animation, duration: 100, rotations: 1, repeats: 100)
            self.viewFooter.addSubview(animation)
            var ixCount = 1
            
            //EVENT
            ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue,categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue,action:WMGAIUtils.ACTION_ADD_ALL_WISHLIST.rawValue , label: "")
            
            for shoppingCartProduct  in self.itemsInShoppingCart {
                let upc = shoppingCartProduct["upc"] as! String
                let desc = shoppingCartProduct["description"] as! String
                let price = shoppingCartProduct["price"] as! String
                //let quantity = shoppingCartProduct["quantity"] as! String
                
                var onHandInventory = "0"
                if let inventory = shoppingCartProduct["onHandInventory"] as? String {
                    onHandInventory = inventory
                }
                
                let imageArray = shoppingCartProduct["imageUrl"] as! [Any]
                var imageUrl = ""
                if imageArray.count > 0 {
                    imageUrl = imageArray[0] as! String
                }
                
                var preorderable = "false"
                if let preorder = shoppingCartProduct["isPreorderable"] as? String {
                    preorderable = preorder
                }

                var category = ""
                if let categoryVal = shoppingCartProduct["category"] as? String {
                    category = categoryVal
                }

                
                let serviceAdd = AddItemWishlistService()
                if ixCount < self.itemsInShoppingCart.count {
                    serviceAdd.callService(upc, quantity: "1", comments: "", desc: desc, imageurl: imageUrl, price: price as String, isActive: "true", onHandInventory: onHandInventory, isPreorderable: preorderable,category:category, mustUpdateWishList: false, successBlock: { (result:[String:Any]) -> Void in
                        //let path = NSIndexPath(forRow: , inSection: 0)

                        
                        }, errorBlock: { (error:NSError) -> Void in
                    })
                }else {
                    serviceAdd.callService(upc, quantity: "1", comments: "", desc: desc, imageurl: imageUrl, price: price, isActive: "true", onHandInventory: onHandInventory, isPreorderable: preorderable,category:category,mustUpdateWishList: true, successBlock: { (result:[String:Any]) -> Void in
                        self.showMessageWishList(NSLocalizedString("shoppingcart.wishlist.ready",comment:""))
                        animation.removeFromSuperview()
                        }, errorBlock: { (error:NSError) -> Void in
                            animation.removeFromSuperview()
                    })
                }
                ixCount += 1
                
                // Event
                BaseController.sendAnalyticsProductToList(upc, desc: desc, price: price)
                
            }
        }

    }
    
    /**
     Animation from whislist icon
     
     - parameter view:      view icon
     - parameter duration:  time animation
     - parameter rotations: number rotation
     - parameter repeats:   number repeats
     */
    func runSpinAnimationOnView(_ view:UIView,duration:CGFloat,rotations:CGFloat,repeats:CGFloat) {
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float(repeats)
        view.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
    }
    
    //MARK : TableviewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemsInShoppingCart.count > 0{
            if itemsUPC.count > 0 {
                return itemsInShoppingCart.count + 2
            }else {
                return itemsInShoppingCart.count + 1
            }
        }
        return 1
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        if itemsInShoppingCart.count > indexPath.row {
            let cellProduct = viewShoppingCart.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductShoppingCartTableViewCell
            cellProduct.delegateProduct = self
            cellProduct.delegate = self
            cellProduct.rightUtilityButtons = getRightButtonDelete()
            cellProduct.setLeftUtilityButtons(getLeftDelete(), withButtonWidth: 36.0)
            let shoppingCartProduct = self.itemsInShoppingCart![indexPath.row] as! [String:Any]
            let upc = shoppingCartProduct["upc"] as! String
            let desc = shoppingCartProduct["description"] as! String
            let price = shoppingCartProduct["price"] as! String
            let quantity = shoppingCartProduct["quantity"] as! NSString
            
            var onHandInventory = "0"
            if let inventory = shoppingCartProduct["onHandInventory"] as? String {
                onHandInventory = inventory
            }
            
            
            var isPreorderable = "false"
            if let preorderable = shoppingCartProduct["isPreorderable"] as? String {
                isPreorderable = preorderable
            }


            let imageArray = shoppingCartProduct["imageUrl"] as! [Any]
            var imageUrl = ""
            if imageArray.count > 0 {
                imageUrl = imageArray[0] as! String
            }
            
            let savingIndex = shoppingCartProduct.index(forKey: "saving")
            var savingVal = "0.0"
            if savingIndex != nil {
                savingVal = shoppingCartProduct["saving"]  as! String
            }
            
            var productDeparment = ""
            if let category = shoppingCartProduct["category"] as? String{
                productDeparment = category
            }
            
            //updateItemSavingForUPC(indexPath,upc:upc)
            
            cellProduct.setValues(upc,productImageURL:imageUrl, productShortDescription: desc, productPrice: price as NSString, saving: savingVal as NSString,quantity:quantity.integerValue,onHandInventory:onHandInventory as NSString,isPreorderable: isPreorderable, category:productDeparment)
            //
            //cellProduct.priceSelector.closeBand()
            //cellProduct.endEdditingQuantity()
            if isEdditing == true {
                cellProduct.setEditing(true, animated: false)
                cellProduct.showLeftUtilityButtons(animated: false)
                cellProduct.moveRightImagePresale(false)
            }else{
                cellProduct.setEditing(false, animated: false)
                cellProduct.hideUtilityButtons(animated: false)
                cellProduct.moveRightImagePresale(false)
                
            }
            
            cell = cellProduct
        }
        else {
            if itemsInShoppingCart.count == indexPath.row  {
                let cellTotals = viewShoppingCart.dequeueReusableCell(withIdentifier: "productTotalsCell", for: indexPath) as! ShoppingCartTotalsTableViewCell
                
                let totalsItems = totalItems()
                
                let subTotalText = totalsItems["subtotal"] as String!
                let iva = totalsItems["iva"] as String!
                let total = totalsItems["total"] as String!
                let totalSaving = totalsItems["totalSaving"] as String!
                
                updateShopButton(total!)
                
                 var newTotal  = total
                 var newTotalSavings = totalSaving
                if self.isEmployeeDiscount {
                    newTotal = "\((total! as NSString).doubleValue - ((total! as NSString).doubleValue *  UserCurrentSession.sharedInstance.porcentageAssociate))"
                    newTotalSavings = "\((totalSaving! as NSString).doubleValue + ((total! as NSString).doubleValue *  UserCurrentSession.sharedInstance.porcentageAssociate))"
                }
                
                cellTotals.setValues(subTotalText!, iva: iva!, total:newTotal!,totalSaving:newTotalSavings!)
                cell = cellTotals
            }
            if itemsInShoppingCart.count < indexPath.row  {
                
                let cellPromotion = viewShoppingCart.dequeueReusableCell(withIdentifier: "crossSellCell", for: indexPath) as? ShoppingCartCrossSellCollectionViewCell
                cellPromotion!.delegate = self
                cellPromotion!.itemsUPC = itemsUPC
                cellPromotion!.collection.reloadData()
                cell = cellPromotion
            }

        }
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemsInShoppingCart.count > indexPath.row && !isSelectingProducts  {
            let controller = ProductDetailPageViewController()
            controller.itemsToShow = getUPCItems() as [Any]
            controller.ixSelected = indexPath.row
            controller.detailOf = "Shopping Cart"
            
            
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

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    /**
     Generate Right buttons delete
     
     - returns: array buttons delete
     */
    func getRightButtonDelete() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        let buttonDelete = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 109))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), for: UIControlState())
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    /**
       Generate left buttons delete
     
     - returns: array left buttons
     */
    func getLeftDelete() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        let buttonDelete = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 109))
        buttonDelete.setImage(UIImage(named:"myList_delete"), for: UIControlState())
        buttonDelete.backgroundColor = WMColor.light_gray
        toReturn.append(buttonDelete)
        
        return toReturn
    }
 

    //Se quita funcionalidad ya que el saving ya viene en el servicio
//    func updateItemSavingForUPC(indexPath: NSIndexPath,upc:String) {
    
//        let searchResult = idexesPath.filter({ (index) -> Bool in return index.row == indexPath.row })
//        if searchResult.count == 0 {
//            idexesPath.append(indexPath)
//            
//            let productService = ProductDetailService()
//            productService.callService(upc, successBlock: { (result: [String:Any]) -> Void in
//                let savingItem = result["saving"] as NSString
//                if self.itemsInShoppingCart.count > indexPath.row {
//                var itemByUpc  = self.itemsInShoppingCart![indexPath.row] as [String:Any]
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
    
    
    /**
        Present view in mode edit
     
     - parameter sender: button send action
     */
    @IBAction func editAction(_ sender: AnyObject) {
        isEdditing = !isEdditing
        if (isEdditing) {
            let currentCells = self.viewShoppingCart.visibleCells
            for cell in currentCells {
                if cell.isKind(of: SWTableViewCell.self) {
                    let productCell = cell as! ProductShoppingCartTableViewCell
                    productCell.setEditing(true, animated: false)
                    productCell.showLeftUtilityButtons(animated: true)
                    productCell.moveRightImagePresale(true)
                }
            }
            editButton.isSelected = true
            editButton.backgroundColor =  WMColor.green
            editButton.tintColor = WMColor.dark_blue
            
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.deleteall.alpha = 1
                self.titleView.frame = CGRect(x: self.titleView.frame.minX - 30, y: self.titleView.frame.minY, width: self.titleView.frame.width, height: self.titleView.frame.height)
            })
            
            //EVENT
            ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_EDIT_CART.rawValue, label: "")
            
        }else{
            let currentCells = self.viewShoppingCart.visibleCells
            for cell in currentCells {
                if cell.isKind(of: SWTableViewCell.self) {
                    let productCell = cell as! ProductShoppingCartTableViewCell
                    productCell.setEditing(false, animated: false)
                    productCell.hideUtilityButtons(animated: false)
                    productCell.moveRightImagePresale(false)
                    
                }
            }
            editButton.isSelected = false
            editButton.backgroundColor = WMColor.light_blue
            editButton.tintColor = WMColor.light_blue
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.deleteall.alpha = 0
                self.titleView.frame = CGRect(x: self.titleView.frame.minX + 30, y: self.titleView.frame.minY, width: self.titleView.frame.width, height: self.titleView.frame.height)
            })

        }
    }
    
//MARK: ProductShoppingCartTableViewCellDelegate
    
    func endUpdatingShoppingCart(_ cell:ProductShoppingCartTableViewCell) {
        let indexPath : IndexPath = self.viewShoppingCart.indexPath(for: cell)!
        
        var itemByUpc  = self.itemsInShoppingCart![indexPath.row] 
        itemByUpc.updateValue(String(cell.quantity) , forKey: "quantity")
        self.itemsInShoppingCart[indexPath.row] = itemByUpc
        
        //viewLoad.stopAnnimating()
        self.updateTotalItemsRow()
    }
    
    func deleteProduct(_ cell:ProductShoppingCartTableViewCell) {
        let toUseCellIndex = self.viewShoppingCart.indexPath(for: cell)
        if toUseCellIndex != nil {
            let indexPath : IndexPath = toUseCellIndex!
            deleteRowAtIndexPath(indexPath)
        }
    }
    
    func userShouldChangeQuantity(_ cell:ProductShoppingCartTableViewCell) {
        if self.isEdditing == false {
            let frameDetail = CGRect(x: 0,y: 0, width: self.view.frame.width,height: self.view.frame.height)
            selectQuantity = ShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(value: cell.price.doubleValue as Double),upcProduct:cell.upc as String)
            let text = String(cell.quantity).characters.count < 2 ? "0" : ""
            self.selectQuantity!.lblQuantity.text = "\(text)"+"\(cell.quantity)"
            self.selectQuantity!.updateQuantityBtn()
            selectQuantity!.closeAction = { () in
                self.selectQuantity!.removeFromSuperview()
            }
            selectQuantity!.addToCartAction = { (quantity:String) in
                let maxProducts = (cell.onHandInventory.integerValue <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory.integerValue : 5
                if maxProducts >= Int(quantity) {
                    
                    let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"alert_cart"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
                    alertView!.setMessage(NSLocalizedString("shoppingcart.additem", comment:""))
                    
                    let updateService = ShoppingCartUpdateProductsService()
                    updateService.isInCart = true
                    updateService.callCoreDataService(cell.upc, quantity: String(quantity), comments: "", desc:cell.desc,price:cell.price as String,imageURL:cell.imageurl,onHandInventory:cell.onHandInventory,isPreorderable:cell.isPreorderable,category:cell.productDeparment ,successBlock: { (response:[String:Any]) -> Void in
                        delay(0.3, completion: {
                            alertView!.setMessage(NSLocalizedString("shoppingcart.update.product", comment:""))
                            alertView!.showDoneIcon()
                        })
                        
                        print("done")
                        },errorBlock: nil)
                    self.reloadShoppingCart()
                    self.selectQuantity!.closeAction()
                } else {
                    let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                    
                    let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                    let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                    let msgInventory = "\(firstMessage)\(maxProducts) \(secondMessage)"
                    alert!.setMessage(msgInventory)
                    alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                    self.selectQuantity!.lblQuantity?.text = maxProducts < 10 ? "0\(maxProducts)" : "\(maxProducts)"
                }
            }
            self.view.addSubview(selectQuantity!)
        }
    }
    
    //MARK: SWTableViewCellDelegate
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        switch index {
        case 0:

            let indexPath = self.viewShoppingCart.indexPath(for: cell)
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
            //let indexPath : NSIndexPath = self.viewShoppingCart.indexPathForCell(cell)!
            //deleteRowAtIndexPath(indexPath)
            let index = self.viewShoppingCart.indexPath(for: cell)
            let superCell = self.viewShoppingCart.cellForRow(at: index!) as! ProductShoppingCartTableViewCell
            superCell.moveRightImagePresale(false)
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
            //   return !isEdditing && !self.isSelectingProducts
        }
    }
    
    //MARK : Actions
    
    /**
     Delete item in car from indexpath selected
     
     - parameter indexPath: selected row
     */
    func deleteRowAtIndexPath(_ indexPath : IndexPath){
        let itemWishlist = itemsInShoppingCart[indexPath.row] as! [String:Any]
        let upc = itemWishlist["upc"] as! String
        let deleteShoppingCartService = ShoppingCartDeleteProductsService()
        let descriptions =  itemWishlist["description"] as! String
        ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_PRODUCT_CART.rawValue, label: "\(descriptions) - \(upc)")
        if !UserCurrentSession.hasLoggedUser() {
         BaseController.sendAnalyticsAddOrRemovetoCart([itemWishlist], isAdd: false)
        }
        deleteShoppingCartService.callCoreDataService(upc, successBlock: { (result:[String:Any]) -> Void in
            self.itemsInShoppingCart.remove(at: indexPath.row)
            
            self.viewShoppingCart.reloadData()
            self.updateTotalItemsRow()
            
            if self.itemsInShoppingCart.count == 0 {
                self.navigationController!.popToRootViewController(animated: true)
            }
            
            }, errorBlock: { (error:NSError) -> Void in
                print("delete pressed Errro \(error)")
        })
    }
    
    /**
     Update totals view in case, delete or update itmes
     */
    func updateTotalItemsRow() {
        let totalIndexPath =  IndexPath(row: itemsInShoppingCart.count, section: 0)
        self.viewShoppingCart.reloadRows(at: [totalIndexPath], with: UITableViewRowAnimation.none)
        UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
    }
    
    /**
     Sum items from sopping cart.
     
     - returns: Strings totals, include iva, subtotal ,discount
     */
    func totalItems() -> [String:String] {
        
        var subtotal = 0.0
        var subtotalIVA = 0.0
        var total = 0.0
        var totalSavings = 0.0
        var showIva = true
        
        for shoppingCartProduct in  itemsInShoppingCart {
            let dictShoppingCartProduct = shoppingCartProduct as! [String:Any]
            let price = shoppingCartProduct["price"] as! NSString
            
            var iva : NSString = ""
            if let ivabase = shoppingCartProduct["ivaAmount"] as? NSString {
                iva = ivabase
            }
            if let ivabase = shoppingCartProduct["ivaAmount"] as? NSNumber {
                iva = ivabase.stringValue as NSString
            }
            var baseprice : NSString = ""
            if let pricebase = shoppingCartProduct["basePrice"] as? NSString {
                baseprice = pricebase
            }
            if let pricebase = shoppingCartProduct["basePrice"] as? NSNumber {
                baseprice = pricebase.stringValue as NSString
            }
            
            var quantity : NSString = ""
            if let quantityN = shoppingCartProduct["quantity"] as? NSString {
                quantity = quantityN
            }
            if let quantityN = shoppingCartProduct["quantity"] as? NSNumber {
                quantity = quantityN.stringValue as NSString
            }


            //let quantity = shoppingCartProduct["quantity"] as NSString
            
            let savingIndex = dictShoppingCartProduct.index(forKey: "saving")
            var savingVal : NSString = "0.0"
            if savingIndex != nil {
                savingVal = shoppingCartProduct["saving"]  as! String as NSString
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
        
        let totalInCart = NSNumber(value: total as Double).stringValue
        var subtotalCart = ""
        var totalIVA = ""
        if showIva {
            subtotalCart = NSNumber(value: subtotal as Double).stringValue
            totalIVA = NSNumber(value: subtotalIVA as Double).stringValue
        }
        let totalSaving = NSNumber(value: totalSavings as Double).stringValue
        
        return ["subtotal":subtotalCart,"iva":totalIVA,"total":totalInCart,"totalSaving":totalSaving]
    }

    /**
     Find upc from items more expencive from crosselling n car
     
     - returns: upc found
     */
    func getExpensive() -> String {
        let priceLasiItem = 0.0
        var upc = ""
           for shoppingCartProduct in  itemsInShoppingCart {
            //let dictShoppingCartProduct = shoppingCartProduct as! [String:Any]
            let price = shoppingCartProduct["price"] as! NSString
            if price.doubleValue < priceLasiItem {
                continue
            }
            upc = shoppingCartProduct["upc"] as! NSString as String
        }
        return upc
    }
    
    /**
     Find all items in shopping cart
     
     - returns: array products in cart
     */
    func getUPCItems() -> [[String:String]] {

        var upcItems : [[String:String]] = []
        for shoppingCartProduct in  itemsInShoppingCart {
            let upc = shoppingCartProduct["upc"] as! String
            let desc = shoppingCartProduct["description"] as! String
            upcItems.append(["upc":upc,"description":desc,"type":ResultObjectType.Mg.rawValue])
        }
        return upcItems
    }
    
    /**
     fins all upcs to products in cart
     
     - returns: strig width upcs
     */
    func getUPCItemsString() -> String {
        
        var upcItems :String = "["
        for shoppingCartProduct in  itemsInShoppingCart {
            let upc = shoppingCartProduct["upc"] as! String
            upcItems.append("'\(upc)',")
        }
        upcItems.append("]")
        return upcItems
    }

    /**
     Present product detail controller
     
     - parameter upc:          upc product
     - parameter items:        all items in cart
     - parameter index:        select item
     - parameter imageProduct: image product
     - parameter point:        point of start animation if use
     - parameter idList:       id list if requiered in detail
     */
    func goTODetailProduct(_ upc: String, items: [[String : String]], index: Int, imageProduct: UIImage?, point: CGRect, idList: String, isBundle: Bool) {
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = items as [Any]
        controller.ixSelected = index
        controller.detailOf = "Shopping Cart"
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
     /**
     Open form of discount associate
     */
    func openDiscount(){
        let discountAssociateItems = [NSLocalizedString("checkout.discount.associateNumber", comment:""),NSLocalizedString("checkout.discount.dateAdmission", comment:""),NSLocalizedString("checkout.discount.determinant", comment:"")]
        self.selectedConfirmation  = IndexPath(row: 0, section: 0)
        
        self.picker!.sender = self//self.discountAssociate!
        self.picker!.titleHeader = NSLocalizedString("checkout.field.discountAssociate", comment:"")
        self.picker!.delegate = self
        self.picker!.selected = self.selectedConfirmation
        self.picker!.setValues("Descuento de asociado", values: discountAssociateItems)
        self.picker!.hiddenRigthActionButton(true)
        self.picker!.cellType = TypeField.alphanumeric
        self.picker!.showPicker()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ShoppingCartViewController.keyBoardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ShoppingCartViewController.keyBoardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    //Keyboart
    func keyBoardWillShow() {
        self.picker!.viewContent.center = CGPoint(x: self.picker!.center.x, y: self.picker!.center.y - 85)
    }
    
    func keyBoardWillHide() {
        self.picker!.viewContent.center = self.picker!.center
    }

    func validateAsociate(){
        self.openDiscount()
    }

    /**
     Present  login controller after shopping, 
     validate if user contain address, if not , call service to add new addres an save.
     */
    func showloginshop() {
        picker?.closePicker()
        //Event
        ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_LOGIN_PRE_CHECKOUT.rawValue, label: "")
        
        self.canceledAction = false
        self.buttonShop.isEnabled = false
        self.buttonShop.alpha = 0.7
        //let storyboard = self.loadStoryboardDefinition()
        let addressService = AddressByUserService()
        
        self.buttonShop.isEnabled = true
        self.buttonShop.alpha = 1.0
        let cont = LoginController.showLogin()
        var user = ""
        if UserCurrentSession.hasLoggedUser() {
            cont!.noAccount?.isHidden = true
            cont!.registryButton?.isHidden = true
            cont!.valueEmail = UserCurrentSession.sharedInstance.userSigned!.email as String
            cont!.email?.text = UserCurrentSession.sharedInstance.userSigned!.email as String
            cont!.email!.isEnabled = false
            user = UserCurrentSession.sharedInstance.userSigned!.email as String
        }
        cont?.isMGLogin =  true
        cont!.closeAlertOnSuccess = false
        cont!.okCancelCallBack = {() in
            self.canceledAction = true
            //let response = self.navigationController?.popToRootViewControllerAnimated(true)
            cont!.closeAlert(true, messageSucesss:false)
        }
        cont!.successCallBack = {() in
            if UserCurrentSession.hasLoggedUser() {
                if user !=  UserCurrentSession.sharedInstance.userSigned!.email as String {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: ProfileNotification.updateProfile.rawValue), object: nil)
                    //self.reloadShoppingCart()
                }
            }
            
            addressService.callService({ (resultCall:[String:Any]) -> Void in
                var presentAddres = true
                if let shippingAddress = resultCall["shippingAddresses"] as? [Any]
                {
                    if shippingAddress.count > 0 {
                        presentAddres = false
                        if(cont!.email?.text == nil || cont!.email?.text == "" ){
                            cont!.email?.text = cont!.signUp.email?.text
                            cont!.password?.text = cont!.signUp.password?.text
                        }
                        if(cont!.password?.text == nil || cont!.password?.text == "" ){
                            self.showloginshop()
                            cont!.closeAlert(true, messageSucesss: true)
                            return
                        }
                        self.presentedCheckOut(cont!, address: nil)
                    }
                }
                if presentAddres {
                    let address = AddressViewController()
                    address.typeAddress = TypeAddress.shiping
                    address.item =  [String:Any]()
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
                }else{
                    cont!.closeAlert(true, messageSucesss: true)
                }
                }, errorBlock: { (error:NSError) -> Void in
                    
                    self.buttonShop.isEnabled = true
                    self.buttonShop.alpha = 1.0
                    print("errorBlock")
                    let address = AddressViewController()
                    address.typeAddress = TypeAddress.shiping
                    address.item =  [String:Any]()
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
    
    
    
    func presentedCheckOut(_ loginController: LoginController, address: AddressViewController?){
        //FACEBOOKLOG
        FBSDKAppEvents.logPurchase(self.totalShop, currency: "MXN", parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "productmg",FBSDKAppEventParameterNameContentID:self.getUPCItemsString()])

        
        UserCurrentSession.sharedInstance.loadMGShoppingCart { () -> Void in
            let serviceReview = ReviewShoppingCartService()
            serviceReview.callService([:], successBlock: { (result:[String:Any]) -> Void in
                if !self.canceledAction  {
                    print(UserCurrentSession.sharedInstance.itemsMG)
                    let itemsMG = UserCurrentSession.sharedInstance.itemsMG
                    let totalsItems = self.totalItems()
                    let total = totalsItems["total"] as String!
                    
                    self.checkVC = self.checkOutController()
                    self.checkVC.afterclose = {() -> Void in self.checkVC = nil }
                    self.checkVC.username = loginController.email?.text
                    self.checkVC.password = loginController.password?.text
                    self.checkVC.isEmployeeDiscount = self.isEmployeeDiscount
                    self.checkVC.itemsMG = itemsMG!["items"] as! [Any]
                    self.checkVC.total = total
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
                            self.navigationController!.popViewController(animated: false)
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
                                    self.navigationController!.popViewController(animated: false)
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
                                        self.navigationController!.popViewController(animated: false)
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

    /**
     Call shopping cart service mg and load car
     */
    func reloadShoppingCart () {
        //self.viewContent.addSubview(viewLoad)
        //viewLoad.startAnnimating()
        idexesPath = []
        UserCurrentSession.sharedInstance.loadMGShoppingCart { () -> Void in
            self.loadShoppingCartService()
        }
        
    }
    
    /**
     Update sho button, before update or delete itemes.
     
     - parameter total: new total
     */
    func updateShopButton(_ total:String) {
        self.totalShop = (total as NSString).doubleValue
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: self.buttonShop.bounds)
            customlabel.backgroundColor = UIColor.clear
            customlabel.setCurrencyUserInteractionEnabled(true)
            buttonShop.addSubview(customlabel)
            buttonShop.sendSubview(toBack: customlabel)
        }
        customlabel.frame = self.buttonShop.bounds
        var newTotal  = total
        if self.isEmployeeDiscount {
            newTotal = "\((total as NSString).doubleValue - ((total as NSString).doubleValue *  UserCurrentSession.sharedInstance.porcentageAssociate))"
            self.totalest = (newTotal as NSString).doubleValue as NSNumber!
        }
        
        let shopStr = NSLocalizedString("shoppingcart.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(newTotal as NSString)
        let shopStrComplete = "\(shopStr) \(fmtTotal)"
        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.white, interLine: false)
        
    }
    
    func generateImageOfView(_ viewCapture:UIView) -> UIImage {
        var cloneImage : UIImage? = nil
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(viewCapture.frame.size, false, 1.0);
            viewCapture.layer.render(in: UIGraphicsGetCurrentContext()!)
            cloneImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        return cloneImage!
    }
    
    /**
     Invoke cross Selling service, present related products in car
     */
    func loadCrossSell() {
        if self.itemsInShoppingCart.count >  0 {
            let upcValue = getExpensive()
            let crossService = CrossSellingProductService()
            crossService.callService(upcValue, successBlock: { (result:[[String:Any]]?) -> Void in
                if result != nil {
                    
                    var isShowingBeforeLeave = false
                    if self.tableView(self.viewShoppingCart, numberOfRowsInSection: 0) == self.itemsInShoppingCart.count + 2 {
                        isShowingBeforeLeave = true
                    }
                    
                    self.itemsUPC = result!
                    if self.itemsUPC.count > 3 {
                        var arrayUPCS = self.itemsUPC
                        arrayUPCS.sort(by: { (before, after) -> Bool in
                            let priceB = before["price"] as! NSString
                            let priceA = after["price"] as! NSString
                            return priceB.doubleValue < priceA.doubleValue
                        })
                        var resultArray : [[String:Any]] = []
                        for item in arrayUPCS[0...2] {
                            resultArray.append(item)
                        }
                        self.itemsUPC = resultArray
                        
                        
                        
                    }
                    if self.itemsInShoppingCart.count >  0  {
                        if self.itemsUPC.count > 0  && !isShowingBeforeLeave {
                            self.viewShoppingCart.insertRows(at: [IndexPath(item: self.itemsInShoppingCart.count + 1, section: 0)], with: UITableViewRowAnimation.automatic)
                        }else{
                            self.viewShoppingCart.reloadRows(at: [IndexPath(item: self.itemsInShoppingCart.count + 1, section: 0)], with: UITableViewRowAnimation.automatic)
                        }
                    }
                    //self.collection.reloadData()
                    
                    if !self.beforeShopTag {
                        var position = 0
                        var positionArray: [Int] = []
                        
                        for _ in self.itemsUPC {
                            position += 1
                            positionArray.append(position)
                        }
                        
                        let listName = "Antes de irte"
                        let subCategory = ""
                        let subSubCategory = ""
                        BaseController.sendAnalyticsTagImpressions(self.itemsUPC, positionArray: positionArray, listName: listName, mainCategory: "", subCategory: subCategory, subSubCategory: subSubCategory)
                        self.beforeShopTag = true
                    }
                    
                }else {
                    
                }
                }, errorBlock: { (error:NSError) -> Void in
                    print("Termina sevicio app")
            })
        }
    }
    

    /**
     View presenten message when add or delete items from wishlist
     
     - parameter message: text to present in view
     */
    func showMessageWishList(_ message:String) {
        let addedAlertWL = WishlistAddProductStatus(frame: CGRect(x: self.viewFooter.frame.minX, y: self.viewFooter.frame.minY , width: self.viewFooter.frame.width, height: 0))
        addedAlertWL.generateBlurImage(self.view,frame:CGRect(x: self.viewFooter.frame.minX, y: -96, width: self.viewFooter.frame.width, height: 96))
        addedAlertWL.clipsToBounds = true
        addedAlertWL.imageBlurView.frame = CGRect(x: self.viewFooter.frame.minX, y: -96, width: self.viewFooter.frame.width, height: 96)
        addedAlertWL.textView.text = message
        self.view.addSubview(addedAlertWL)
        self.isWishListProcess = false
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            addedAlertWL.frame = CGRect(x: self.viewFooter.frame.minX,y: self.viewFooter.frame.minY - 48, width: self.viewFooter.frame.width, height: 48)
            }, completion: { (complete:Bool) -> Void in
                UIView.animate(withDuration: 0.5, delay: 1, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
                    addedAlertWL.frame = CGRect(x: addedAlertWL.frame.minX, y: self.viewFooter.frame.minY , width: addedAlertWL.frame.width, height: 0)
                    }) { (complete:Bool) -> Void in
                        addedAlertWL.removeFromSuperview()
                }
        }) 
        
    }
    
    /**
     Call delete itmes in sopping car,
     */
    func deleteAll() {
        let serviceSCDelete = ShoppingCartDeleteProductsService()
        var upcs : [String] = []
        
        for itemSClist in self.itemsInShoppingCart {
            let upc = itemSClist["upc"] as! String
            upcs.append(upc)
        }
        self.showLoadingView()
   
        BaseController.sendAnalyticsAddOrRemovetoCart(self.itemsInShoppingCart , isAdd: false)
        serviceSCDelete.callService(serviceSCDelete.builParamsMultiple(upcs), successBlock: { (result:[String:Any]) -> Void in
           /* println("Error not done")
            
            self.reloadShoppingCart()
            self.navigationController!.popToRootViewControllerAnimated(true)
            */
            UserCurrentSession.sharedInstance.loadMGShoppingCart({ () -> Void in
                //self.reloadShoppingCart()
                self.removeLoadingView()
              
                
                print("done")
                
                //EVENT
                ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_ALL_PRODUCTS_CART.rawValue, label: "")
                
                self.navigationController?.popToRootViewController(animated: true)
            })
            
            }) { (error:NSError) -> Void in
        }
       
    }
    
    func checkOutController() -> CheckOutViewController {
        return CheckOutViewController()
    }
    
    //MARK: AlertPickerViewDelegate
    func didSelectOption(_ picker: AlertPickerView, indexPath: IndexPath, selectedStr: String) {
        
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
                    succesBlock: { (response:[String:Any]) -> Void in
                        print(response)
                        if response["codeMessage"] as? Int == 0 {
                            //Mostrar alerta y continua
                            self.alertView?.setMessage("Datos correctos")
                            self.buttonAsociate.isHighlighted =  true
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
                            self.buttonAsociate.isHighlighted =  false
                        }
                        
                    }) { (error:NSError) -> Void in
                        // mostrar alerta de error de info
                        self.isEmployeeDiscount =  false
                        self.alertView?.setMessage("Error en los datos del asociado")
                        self.alertView!.showErrorIcon("Ok")
                         self.buttonAsociate.isHighlighted =  false
                        print(error)
                }
            }else{
                self.isEmployeeDiscount =  false
                self.alertView?.setMessage("Error en los datos del asociado\(result)")
                self.alertView!.showErrorIcon("Ok")
                 self.buttonAsociate.isHighlighted =  false
            }
        
    })
    
        
        
    }
    
    func closeAlertPk() {
        self.buttonAsociate.isHighlighted =  isEmployeeDiscount
    }
    
    /**
     Validate info associate
     
     - parameter associateNumber: number asociate
     - parameter dateAdmission:   date admission
     - parameter determinant:     determinat
     - parameter completion:      block validate
     */
    func validateAssociate(_ associateNumber:String?,dateAdmission:String?,determinant:String?, completion: (_ result:String) -> Void) {
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
        
        completion(message)
        
    }
  
    func didDeSelectOption(_ picker:AlertPickerView){
    }
    
    func viewReplaceContent(_ frame: CGRect) -> UIView! {
        let view: UIView! =  UIView(frame: self.view.frame)
        
        return view
        
    }

    func saveReplaceViewSelected() {
        
    }
    
    func buttomViewSelected(_ sender: UIButton) {
        
    }

    var  imageView : UIView?
    var  viewContents : UIView?
    var lblError : UILabel?
    var imageIco : UIImageView?
    
    /**
     Present view if discount associate mg is active, 
     width message.
     
     - parameter message: text to present in alert
     */
    func associateDiscount (_ message: String ){
        if !visibleLabel  {
            
            visibleLabel = true
            
            imageView =  UIView(frame:CGRect(x: (self.view.frame.width/2) - 150 ,  y: viewFooter.frame.minY - 90, width: 190, height: 38))
            viewContents = UIView(frame: imageView!.bounds)
            viewContents!.layer.cornerRadius = 5.0
            viewContents!.backgroundColor = WMColor.light_blue
            imageView!.addSubview(viewContents!)
            self.viewContent.addSubview(imageView!)
            
            lblError = UILabel(frame:CGRect (x: 15, y: 0 , width: viewContents!.frame.width - 30, height: 38))
            lblError!.font = WMFont.fontMyriadProRegularOfSize(12)
            
            lblError!.textColor = UIColor.white
            lblError!.backgroundColor = UIColor.clear
            lblError!.text = message
            lblError!.textAlignment = NSTextAlignment.left
            lblError!.numberOfLines = 2
            viewContents!.addSubview(lblError!)
            
            
            imageIco = UIImageView(image:UIImage(named:"tooltip_cart"))
            imageIco!.frame = CGRect( x: 24 , y: viewContents!.frame.maxY - 1, width: 8, height: 6)
            self.viewContents!.addSubview(imageIco!)
            Timer.scheduledTimer(timeInterval: 1.8, target: self, selector: #selector(ShoppingCartViewController.animationClose), userInfo: nil, repeats: false)
            
        }
        
    }
    /**
     Create animation after close shopping cart
     */
    func animationClose () {
        
        UIView.animate(withDuration: 0.9,
            animations: { () -> Void in
                self.viewContents!.alpha = 0.0
                self.imageView!.alpha = 0.0
                self.lblError!.alpha = 0.0
                self.imageIco!.alpha = 0.0
                
            }, completion: { (finished:Bool) -> Void in
                if finished {
                    self.viewContents!.removeFromSuperview()
                    self.imageView!.removeFromSuperview()
                    self.lblError!.removeFromSuperview()
                    self.imageIco!.removeFromSuperview()
                    self.viewContents = nil
                    self.imageView = nil
                    self.lblError = nil
                    self.imageIco = nil
                }
        })
    }
    
    /**
     Present loader in screen car
     */
    func showLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.viewLoad!.backgroundColor = UIColor.white
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(false)
    }
    
    /**
     Remove loader from screen car
     */
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    
}
