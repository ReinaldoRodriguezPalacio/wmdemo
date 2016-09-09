//
//  ShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/8/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import QuartzCore
import CoreData

protocol ShoppingCartViewControllerDelegate {
    func closeShoppingCart()
}

class ShoppingCartViewController : BaseController ,UITableViewDelegate,UITableViewDataSource,ProductShoppingCartTableViewCellDelegate,SWTableViewCellDelegate,ProductDetailCrossSellViewDelegate,AlertPickerViewDelegate,ListSelectorDelegate {
    
    var viewLoad : WMLoadingView!
    
    var itemsInShoppingCart : [AnyObject]! = []
    var itemsInCartOrderSection : [AnyObject]! = []
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
    var buttonListSelect : UIButton!
    //var addProductToShopingCart : UIButton? = nil
    var alertAddress : GRFormAddressAlertView? = nil
    
    var listObj : NSDictionary!
    var productObje : NSArray!
    
    var heightHeaderTable : CGFloat = IS_IPAD ? 40.0 : 26
    var itemSelect = 0
    
    //var closeButton : UIButton!
    
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
    var containerView : UIImage!
    var visibleLabel = false
    
    
    var emptyView : IPOShoppingCartEmptyView!
    var totalShop: Double = 0.0
    var selectQuantity: GRShoppingCartQuantitySelectorView?
    var facebookButton : UIButton!
    
    var listSelectorController: ListsSelectorViewController?
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MGSHOPPINGCART.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = WMColor.light_light_gray
        
        viewShoppingCart = UITableView(frame:CGRectMake(0, 46 , self.viewContent.frame.width, viewContent.frame.height - 46))
        viewShoppingCart.clipsToBounds = false
        viewShoppingCart.backgroundColor =  WMColor.light_light_gray
         viewShoppingCart.backgroundColor =  UIColor.whiteColor()
        viewShoppingCart.layoutMargins = UIEdgeInsetsZero
        viewShoppingCart.separatorInset = UIEdgeInsetsZero
        viewShoppingCart.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.view.backgroundColor = UIColor.clearColor()
        self.view.clipsToBounds = true
        
        viewHerader = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 46))
        viewHerader.backgroundColor = WMColor.light_light_gray
        
        titleView = UILabel(frame: viewHerader.bounds)
        titleView.font = WMFont.fontMyriadProRegularOfSize(14)
        titleView.textColor = WMColor.light_blue
        titleView.text = NSLocalizedString("shoppingcart.title",comment:"")
        titleView.textAlignment = .Center
        
    
        editButton = UIButton(frame:CGRectMake(self.view.frame.width - 82, 12, 55, 22))
        editButton.setTitle(NSLocalizedString("shoppingcart.edit",comment:""), forState: UIControlState.Normal)
        editButton.setTitle(NSLocalizedString("shoppingcart.endedit",comment:""), forState: UIControlState.Selected)
        editButton.backgroundColor = WMColor.light_blue
        editButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        editButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        editButton.layer.cornerRadius = 11
        editButton.addTarget(self, action: #selector(ShoppingCartViewController.editAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        editButton.titleEdgeInsets = UIEdgeInsetsMake(1.0, 0.0, 1.0, 0.0)
        
        deleteall = UIButton(frame: CGRectMake(editButton.frame.minX - 72, 12, 75, 22))
        deleteall.setTitle(NSLocalizedString("wishlist.deleteall",comment:""), forState: UIControlState.Normal)
        deleteall.backgroundColor = WMColor.red
        deleteall.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        deleteall.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        deleteall.layer.cornerRadius = 11
        deleteall.alpha = 0
        deleteall.titleEdgeInsets = UIEdgeInsetsMake(1.0, 1.0, 0.0, 0.0)
        deleteall.addTarget(self, action: #selector(ShoppingCartViewController.deleteAll), forControlEvents: UIControlEvents.TouchUpInside)
        
       /* closeButton = UIButton(frame:CGRectMake(0, 0, viewHerader.frame.height, viewHerader.frame.height))
        //closeButton.setTitle(NSLocalizedString("shoppingcart.keepshoppinginsidecart",comment:""), forState: UIControlState.Normal)
        closeButton.setImage(UIImage(named: "BackProduct"), forState: UIControlState.Normal)
        //closeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        //closeButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        //closeButton.layer.cornerRadius = 3
        closeButton.addTarget(self, action: #selector(ShoppingCartViewController.closeShoppingCart), forControlEvents: UIControlEvents.TouchUpInside)
        */
        
        //viewHerader.addSubview(closeButton)
        
        viewHerader.addSubview(editButton)
        viewHerader.addSubview(deleteall)
        viewHerader.addSubview(titleView)
        
        
        viewFooter = UIView()
        viewFooter.backgroundColor = UIColor.whiteColor()
        
        let x:CGFloat = 16
        
        buttonListSelect = UIButton(frame: CGRectMake(x, 16, 34.0, 34.0))
        buttonListSelect.setImage(UIImage(named:"detail_list"), forState: UIControlState.Normal)
        buttonListSelect.addTarget(self, action: #selector(ShoppingCartViewController.addToWishList), forControlEvents: UIControlEvents.TouchUpInside)
        viewFooter.addSubview(buttonListSelect)
        
        
        facebookButton = UIButton()
        facebookButton.frame = CGRectMake(buttonListSelect.frame.maxX + 16, 16.0, 34.0, 34.0)
        facebookButton.setImage(UIImage(named:"detail_shareOff"), forState: UIControlState.Normal)
        facebookButton.setImage(UIImage(named:"detail_share"), forState: UIControlState.Highlighted)
        facebookButton.setImage(UIImage(named:"detail_share"), forState: UIControlState.Selected)
        facebookButton.addTarget(self, action: #selector(ShoppingCartViewController.shareProduct), forControlEvents: UIControlEvents.TouchUpInside)
        viewFooter.addSubview(facebookButton)
        
        
        buttonShop = UIButton(frame: CGRectMake(facebookButton.frame.maxX + 16, facebookButton.frame.minY  , self.view.frame.width - (facebookButton.frame.maxX + 32), 34))
        buttonShop.backgroundColor = WMColor.green
        //buttonShop.setTitle(NSLocalizedString("shoppingcart.shop",comment:""), forState: UIControlState.Normal)
        buttonShop.layer.cornerRadius = 17
        buttonShop.addTarget(self, action: #selector(ShoppingCartViewController.showloginshop), forControlEvents: UIControlEvents.TouchUpInside)
        viewFooter.addSubview(buttonShop)
        
        let viewBorderTop = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 1))
        viewBorderTop.backgroundColor = WMColor.light_light_gray
        viewFooter.addSubview(viewBorderTop)
        
        viewShoppingCart.registerClass(ShoppingCartTextViewCell.self, forCellReuseIdentifier: "textCell")
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
        
       // loadShoppingCartService()
        
    }
    
    /**
         Present empty view after load items in car
     
     - returns: na
     */
    func initEmptyView(){
        emptyView = IPOShoppingCartEmptyView(frame:CGRectZero)
        emptyView.frame = CGRectMake(0,  viewHerader.frame.maxY,  self.view.frame.width,  self.view.frame.height - viewHerader.frame.height)
        emptyView.returnAction = {() in
            //self.delegate.closeShoppingCart()
            //self.closeShoppingCart()
            
            self.testServiceShopping()
        }
        self.view.addSubview(emptyView)
        
        self.emptyView.iconImageView.image =  UIImage(named:"empty_cart")
        
    }
    
    func testServiceShopping(){
        
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.viewLoad == nil {
            self.showLoadingView()
        }
        
        /* if !showCloseButton {
            self.closeButton.hidden = true
        } else {
            self.closeButton.hidden = false
        }*/

        self.isEdditing = false
        editButton.selected = false
        editButton.backgroundColor = WMColor.light_blue
        editButton.tintColor = WMColor.light_blue
        deleteall.alpha = 0
        
        UserCurrentSession.sharedInstance().loadMGShoppingCart { () -> Void in
            self.loadShoppingCartService()
        }
       
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShoppingCartViewController.reloadShoppingCart), name: CustomBarNotification.SuccessAddItemsToShopingCart.rawValue, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        
       // self.buttonShop = UIButton(frame: CGRectMake(buttonWishlist.frame.maxX + 16, 16, self.view.frame.width - (buttonWishlist.frame.maxX + 32), 34))
        
        self.viewContent.frame = self.view.bounds
        self.viewFooter.frame = CGRectMake(0, viewContent.frame.height - 72 , self.viewContent.frame.width, 72)
        self.viewShoppingCart.frame =  CGRectMake(0, self.viewHerader.frame.maxY, self.view.bounds.width, viewContent.frame.height - self.viewFooter.frame.height - self.viewHerader.frame.maxY)

        if !self.isEdditing {
        self.titleView.frame = CGRectMake((self.viewHerader.bounds.width / 2) - ((self.view.bounds.width - 32)/2), self.viewHerader.bounds.minY, self.view.bounds.width - 32, self.viewHerader.bounds.height)
        }

        self.editButton.frame = CGRectMake(self.view.frame.width - 71, 12, 55, 22)
       // self.closeButton.frame = CGRectMake(0, 0, viewHerader.frame.height, viewHerader.frame.height)
        
        
    }
    
    /**
     Load items in shopping cart, anda create cell width totals, 
     if no containt items back to shopping cart
     */
    func loadShoppingCartService() {

        idexesPath = []
        
        //self.itemsInShoppingCart =  []
        self.itemsInCartOrderSection = []
        
        if UserCurrentSession.sharedInstance().itemsMG != nil {
            //self.itemsInShoppingCart = UserCurrentSession.sharedInstance().itemsMG!["items"] as! NSArray as [AnyObject]
            let itemsUserCurren = UserCurrentSession.sharedInstance().itemsMG!["items"] as! NSArray as [AnyObject]
            self.itemsInCartOrderSection = RecentProductsViewController.adjustDictionary(itemsUserCurren as [AnyObject]) as! [AnyObject]
            self.arrayItems()
        }
        
        if self.itemsInShoppingCart.count == 0 {
            self.navigationController?.popToRootViewControllerAnimated(true)
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
        viewShoppingCart.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.viewShoppingCart.reloadData()
        
        
        self.loadCrossSell()
        
        self.removeLoadingView()
        self.emptyView!.hidden = self.itemsInShoppingCart.count > 0
        self.editButton.hidden = self.itemsInShoppingCart.count == 0
        
        

    }
    
    /**
     Close sopping cart mg and send tag Analytics
     */
    func closeShoppingCart () {
        //EVENT
        BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue,categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue,action:WMGAIUtils.ACTION_BACK_PRE_SHOPPING_CART.rawValue , label: "")
        self.view.removeFromSuperview()
        //self.navigationController!.popToRootViewControllerAnimated(true)
    }

  
    func addToWishList () {
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_ADD_MY_LIST.rawValue, label: "")
        
        if self.listSelectorController == nil {
            self.buttonListSelect!.selected = true
            let frame = self.view.frame
            self.listSelectorController = ListsSelectorViewController()
            self.listSelectorController!.delegate = self
            
            //self.listSelectorController!.productUpc = self.upc
            self.addChildViewController(self.listSelectorController!)
            self.listSelectorController!.view.frame = CGRectMake(0.0, frame.height, frame.width, frame.height)
            self.view.insertSubview(self.listSelectorController!.view, belowSubview: self.viewFooter!)
            self.listSelectorController!.titleLabel!.text = NSLocalizedString("gr.addtolist.super", comment: "")
            self.listSelectorController!.didMoveToParentViewController(self)
            self.listSelectorController!.view.clipsToBounds = true
            
            self.listSelectorController!.generateBlurImage(self.view, frame: CGRectMake(0, 0, frame.width, frame.height))
            self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, -frame.height, frame.width, frame.height)
            
            UIView.animateWithDuration(0.5,
                                       animations: { () -> Void in
                                        self.listSelectorController!.view.frame = CGRectMake(0, 0, frame.width, frame.height)
                                        self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, 0, frame.width, frame.height)
                },
                                       completion: { (finished:Bool) -> Void in
                                        if finished {
                                            let footerFrame = self.viewFooter!.frame
                                            self.listSelectorController!.tableView!.contentInset = UIEdgeInsetsMake(0, 0, footerFrame.height, 0)
                                            self.listSelectorController!.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, footerFrame.height, 0)
                                        }
                }
            )
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.listSelectorController!.view.frame = CGRectMake(0, 0, frame.width, frame.height)
                self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, 0, frame.width, frame.height)
            })
        }
        else {
            self.removeListSelector(action: nil)
        }

    }
    
    /**
    Add array items products in self.itemsInShoppingCart
     */
    func arrayItems(){
        self.itemsInShoppingCart =  []
        var ind = 0
        
        for itemSection in 0 ..< self.itemsInCartOrderSection.count {
            listObj = self.itemsInCartOrderSection[itemSection] as! NSDictionary

                productObje = listObj["products"] as! [AnyObject]
                
            for prodSection in 0 ..< productObje.count {
                self.itemsInShoppingCart.insert(productObje[prodSection], atIndex: ind)//as! NSArray
                    ind = ind + 1
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
    func runSpinAnimationOnView(view:UIView,duration:CGFloat,rotations:CGFloat,repeats:CGFloat) {
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = Float(repeats)
        view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
        
    }
    
    //MARK: - TableviewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        listObj = self.itemsInCartOrderSection[section - 1] as! NSDictionary
            productObje = listObj["products"] as! NSArray
            
        if section == (self.itemsInCartOrderSection.count) {
            return productObje!.count + 2
            } else {
            return productObje!.count
        }
        //return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return heightHeaderTable
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        let headerView : UIView = UIView(frame: CGRectMake(0.0, 0.0, self.view.frame.width, heightHeaderTable))
        headerView.backgroundColor = UIColor.whiteColor()
        let titleLabel = UILabel(frame: CGRectMake(15.0, 0.0, self.view.frame.width, heightHeaderTable))
        
        listObj = self.itemsInCartOrderSection[section - 1] as! NSDictionary
        titleLabel.text = listObj["name"] as? String
        titleLabel.textColor = WMColor.light_blue
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(12)

        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.itemsInCartOrderSection.count + 1
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        
        if indexPath.section  == 0  {
            let cell = viewShoppingCart.dequeueReusableCellWithIdentifier("textCell", forIndexPath: indexPath) as! ShoppingCartTextViewCell
            return cell
        }
        
        listObj = self.itemsInCartOrderSection[indexPath.section - 1] as! NSDictionary
            productObje = listObj["products"] as! NSArray
            
        var flagSectionCel = false
        if (itemsInCartOrderSection.count) != indexPath.section {
            flagSectionCel = true
        } else {
            flagSectionCel = productObje.count > indexPath.row ? true : false
        }
        
        //var flagSection = itemsInCartOrderSection.count != indexPath.section ? true : false
        if flagSectionCel{
            let cellProduct = viewShoppingCart.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! ProductShoppingCartTableViewCell
            cellProduct.delegateProduct = self
            cellProduct.delegate = self
            cellProduct.rightUtilityButtons = getRightButtonDelete()
            cellProduct.setLeftUtilityButtons(getLeftDelete(), withButtonWidth: 36.0)
            //let shoppingCartProduct = self.itemsInShoppingCart![indexPath.row] as! [String:AnyObject]
            //let listObj = self.itemsInCartOrderSection[indexPath.section] as! NSDictionary
            //let prodObj = listObj["products"] as! NSArray
            let shoppingCartProduct = productObje[indexPath.row] //as! NSDictionary
            let upc = shoppingCartProduct["upc"] as! String
            let desc = shoppingCartProduct["description"] as! String
            var price : NSString = ""
            if let priceValue = shoppingCartProduct["price"] as? NSNumber{
                price = priceValue.stringValue
            }
            if let priceValueS = shoppingCartProduct["price"] as? NSString{
                price = priceValueS
            }
            //let quantity = shoppingCartProduct["quantity"] as! NSString
            var quantity : NSString = ""
            if let quantityValue = shoppingCartProduct["quantity"] as? NSNumber{
                quantity = quantityValue.stringValue
            }
            if let quantityValueS = shoppingCartProduct["quantity"] as? NSString{
                quantity = quantityValueS
            }
            
            var onHandInventory = "0"
            if let inventory = shoppingCartProduct["onHandInventory"] as? String {
                onHandInventory = inventory
            }
            
            var isPreorderable = "false"
            if let preorderable = shoppingCartProduct["isPreorderable"] as? String {
                isPreorderable = preorderable
            }
            
            var imageUrl = ""
            if let imageVal = shoppingCartProduct["imageUrl"] as? String {
                imageUrl = imageVal
            }
            
            //let savingIndex = shoppingCartProduct.indexForKey("saving")
            var savingVal = "0.0"
             if let savingIndex =  shoppingCartProduct["saving"]  as? String {
                savingVal = savingIndex
            }
            
            //promoDescription of GR
            if  let savingProd = shoppingCartProduct["promoDescription"] as? String {
                savingVal = savingProd
            }
            
            //equivalenceByPiece GR
            var equivalenceByPiece = NSNumber(int:0)
            if let equivalence = shoppingCartProduct["equivalenceByPiece"] as? NSNumber {
                equivalenceByPiece = equivalence
            }
            
            if let equivalence = shoppingCartProduct["equivalenceByPiece"] as? NSString {
                if equivalence != "" {
                    equivalenceByPiece =  NSNumber(int: equivalence.intValue)
                }
            }
            
            //comments GR
            let comments = shoppingCartProduct["comments"] as? String
            
            var productDeparment = ""
            if let category = shoppingCartProduct["category"] as? String{
                productDeparment = category
            }
            
            var promotionDescription : String? = ""
            if let promotion = shoppingCartProduct["promotion"] as? NSArray{
                if promotion.count > 0 {
                    promotionDescription = promotion[0]["description"] as? String
                }
            }
            
            
            //updateItemSavingForUPC(indexPath,upc:upc)
            
            //type of GR
            var typeProdVal : Int = 0
            var flagSuper = false
            if shoppingCartProduct["type"] as? NSNumber == 1{
                typeProdVal = (shoppingCartProduct["type"] as? Int)!
                flagSuper = true
            }
            
            //SetValues
           /* if flagSuper {
                
                // GR typeProdVal
                if typeProdVal != 1 {
                    cellProduct.setValuesGR(upc, productImageURL: imageUrl, productShortDescription: desc, productPrice: price, saving: savingVal, quantity: quantity.integerValue, onHandInventory: "99", typeProd:typeProdVal, comments:comments == nil ? "" : comments!,equivalenceByPiece:equivalenceByPiece)
                } else {
                    cellProduct.setValuesGR(upc, productImageURL: imageUrl, productShortDescription: desc, productPrice: price, saving: savingVal, quantity: quantity.integerValue, onHandInventory: "20000", typeProd:typeProdVal, comments:comments == nil ? "" : comments!,equivalenceByPiece:equivalenceByPiece)
                }
            } else {
                //tecnologia
                cellProduct.setValues(upc,productImageURL:imageUrl, productShortDescription: desc, productPrice: price, saving: savingVal,quantity:quantity.integerValue,onHandInventory:onHandInventory,isPreorderable: isPreorderable, category:productDeparment, promotionDescription: promotionDescription)
            }
            */
            
            var through: NSString! = ""
            let plpArray = UserCurrentSession.sharedInstance().getArrayPLP(shoppingCartProduct as! NSDictionary)
           
            
            if let priceThr = shoppingCartProduct["saving"] as? NSString {
                through = priceThr
            }
            
            through = plpArray["promo"] as! String == "" ? through : plpArray["promo"] as! String
            
            cellProduct.setValues(upc,productImageURL:imageUrl, productShortDescription: desc, productPrice: price, saving: savingVal,quantity:quantity.integerValue,onHandInventory:onHandInventory,isPreorderable: isPreorderable, category:productDeparment, promotionDescription: promotionDescription, productPriceThrough: through! as String, isMoreArts: plpArray["isMore"] as! Bool)
            
            cellProduct.setValueArray(plpArray["arrayItems"] as! NSArray)
            
            //cellProduct.priceSelector.closeBand()
            //cellProduct.endEdditingQuantity()
            if isEdditing == true {
                cellProduct.setEditing(true, animated: false)
                cellProduct.showLeftUtilityButtonsAnimated(false)
                cellProduct.moveRightImagePresale(false)
            }else{
                cellProduct.setEditing(false, animated: false)
                cellProduct.hideUtilityButtonsAnimated(false)
                cellProduct.moveRightImagePresale(false)
            }
            
            cell = cellProduct
        }
        else {
            if productObje.count == indexPath.row  {
                let cellTotals = viewShoppingCart.dequeueReusableCellWithIdentifier("productTotalsCell", forIndexPath: indexPath) as! ShoppingCartTotalsTableViewCell
                
                let totalsItems = totalItems()
                
                let subTotalText = totalsItems["subtotal"] as String!
                let iva = totalsItems["iva"] as String!
                let total = totalsItems["total"] as String!
                let totalSaving = totalsItems["totalSaving"] as String!
                
                updateShopButton(total)
                
                 let newTotal  = total
                 let newTotalSavings = totalSaving
                
                cellTotals.setValues(subTotalText, iva: iva, total:newTotal,totalSaving:newTotalSavings)
                cell = cellTotals
            } else { //if productObje.count < indexPath.row
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
        
        if indexPath.section == 0 {
            return
        }
        
        listObj = self.itemsInCartOrderSection[indexPath.section-1] as! NSDictionary
        productObje = listObj["products"] as! NSArray

        if indexPath.section == (itemsInCartOrderSection.count) {
            if productObje.count <= indexPath.row {
                return
            }
        }
        
        if itemsInShoppingCart.count > indexPath.row && !isSelectingProducts  {
            let controller = ProductDetailPageViewController()
            controller.itemsToShow = getUPCItems(indexPath.section - 1, row: indexPath.row)
            controller.ixSelected = self.itemSelect//indexPath.row
            
            let item = productObje[indexPath.row] as! [String:AnyObject]
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

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 46
        }
        
        listObj = self.itemsInCartOrderSection[indexPath.section - 1] as! NSDictionary
            productObje = listObj["products"] as! NSArray

        var flagSectionCel = false
        if (itemsInCartOrderSection.count) != indexPath.section {
            flagSectionCel = true
        } else {
            flagSectionCel = productObje.count > indexPath.row ? true : false
        }
        
        if flagSectionCel {
            return 124
        }else{
            if productObje.count == indexPath.row  {
                return 124
            }
            if productObje.count < indexPath.row  {
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
        
        let buttonDelete = UIButton(frame: CGRectMake(0, 0, 80, 109))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), forState: UIControlState.Normal)
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
        
        let buttonDelete = UIButton(frame: CGRectMake(0, 0, 36, 109))
        buttonDelete.setImage(UIImage(named:"myList_delete"), forState: UIControlState.Normal)
        buttonDelete.backgroundColor = WMColor.light_gray
        toReturn.append(buttonDelete)
        
        return toReturn
    }
 
    /**
        Present view in mode edit
     
     - parameter sender: button send action
     */
    @IBAction func editAction(sender: AnyObject) {
        isEdditing = !isEdditing
        if (isEdditing) {
            let currentCells = self.viewShoppingCart.visibleCells
            for cell in currentCells {
                if cell.isKindOfClass(SWTableViewCell) {
                    let productCell = cell as! ProductShoppingCartTableViewCell
                    productCell.setEditing(true, animated: false)
                    productCell.showLeftUtilityButtonsAnimated(true)
                    productCell.moveRightImagePresale(true)
                }
            }
            editButton.selected = true
            editButton.backgroundColor =  WMColor.green
            editButton.tintColor = WMColor.dark_blue
            
            
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
                    productCell.moveRightImagePresale(false)
                    
                }
            }
            editButton.selected = false
            editButton.backgroundColor = WMColor.light_blue
            editButton.tintColor = WMColor.light_blue
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.deleteall.alpha = 0
                self.titleView.frame = CGRectMake(self.titleView.frame.minX + 30, self.titleView.frame.minY, self.titleView.frame.width, self.titleView.frame.height)
            })

        }
    }
    
//MARK: ProductShoppingCartTableViewCellDelegate
    
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
    
    func userShouldChangeQuantity(cell:ProductShoppingCartTableViewCell) {
        if self.isEdditing == false {
            let frameDetail = CGRectMake(0,0, self.view.frame.width,self.view.frame.height)
            
            //GRShoppingCartWeightSelectorView
            //cell.typeProd
            
            if cell.typeProd == 1 {
                selectQuantity = GRShoppingCartWeightSelectorView(frame:frameDetail,priceProduct:NSNumber(double:cell.price.doubleValue),quantity:cell.quantity,equivalenceByPiece:cell.equivalenceByPiece,upcProduct:cell.upc)
            } else {
                selectQuantity = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(double:cell.price.doubleValue),upcProduct:cell.upc as String)
            }
            
            selectQuantity?.addToCartAction = { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                
                if cell.onHandInventory.integerValue >= Int(quantity) {
                    self.selectQuantity?.closeAction()
                    
                    if cell.typeProd == 0 {
                        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_CHANGE_NUMER_OF_PIECES.rawValue, label: "")
                    } else {
                        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_CHANGE_NUMER_OF_KG.rawValue, label: "")
                    }
                    
                    let params = self.buildParamsUpdateShoppingCart(cell,quantity: quantity)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
                } else {
                    let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                    
                    let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                    
                    var secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                    
                    if cell.pesable {
                        secondMessage = NSLocalizedString("productdetail.notaviableinventorywe",comment:"")
                    }
                    
                    let msgInventory = "\(firstMessage)\(cell.onHandInventory) \(secondMessage)"
                    alert!.setMessage(msgInventory)
                    alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                }
                
                
            }
            
            selectQuantity?.addUpdateNote = {() in
                let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
                let frame = vc!.view.frame
                
                
                let addShopping = ShoppingCartUpdateController()
                let paramsToSC = self.buildParamsUpdateShoppingCart(cell,quantity: "\(cell.quantity)")
                addShopping.params = paramsToSC
                vc!.addChildViewController(addShopping)
                addShopping.view.frame = frame
                vc!.view.addSubview(addShopping.view)
                addShopping.didMoveToParentViewController(vc!)
                addShopping.typeProduct = ResultObjectType.Groceries
                addShopping.comments = cell.comments
                addShopping.goToShoppingCart = {() in }
                addShopping.removeSpinner()
                addShopping.addActionButtons()
                addShopping.addNoteToProduct(nil)
                
                
                
            }
            selectQuantity?.userSelectValue(String(cell.quantity))
            selectQuantity?.first = true
            if cell.comments.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
                selectQuantity!.setTitleCompleteButton(NSLocalizedString("shoppingcart.updateNote",comment:""))
            }else {
                selectQuantity!.setTitleCompleteButton(NSLocalizedString("shoppingcart.addNote",comment:""))
            }
            selectQuantity?.showNoteButtonComplete()
            selectQuantity?.closeAction = { () in
                self.selectQuantity!.removeFromSuperview()
                
            }
            
            /*let text = String(cell.quantity).characters.count < 2 ? "0" : ""
            self.selectQuantity!.lblQuantity.text = "\(text)"+"\(cell.quantity)"
            self.selectQuantity!.updateQuantityBtn()
            selectQuantity!.closeAction = { () in
                self.selectQuantity!.removeFromSuperview()
            }
            selectQuantity!.addToCartAction = { (quantity:String) in
                let maxProducts = (cell.onHandInventory.integerValue <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory.integerValue : 5
                if maxProducts >= Int(quantity) {
                    let updateService = ShoppingCartUpdateProductsService()
                    updateService.isInCart = true
                    updateService.callCoreDataService(cell.upc, quantity: String(quantity), comments: "", desc:cell.desc,price:cell.price as String,imageURL:cell.imageurl,onHandInventory:cell.onHandInventory,isPreorderable:cell.isPreorderable,category:cell.productDeparment ,successBlock: nil,errorBlock: nil)
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
            }*/
            self.view.addSubview(selectQuantity!)
        }
    }
    
    func buildParamsUpdateShoppingCart(cell:ProductShoppingCartTableViewCell,quantity:String) -> [String:AnyObject] {
        let pesable = cell.pesable ? "1" : "0"
        return ["upc":cell.upc,"desc":cell.desc,"imgUrl":cell.imageurl,"price":cell.price,"quantity":quantity,"comments":cell.comments,"onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable]
    }
    
    //MARK: SWTableViewCellDelegate
    
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
            let index = self.viewShoppingCart.indexPathForCell(cell)
            let superCell = self.viewShoppingCart.cellForRowAtIndexPath(index!) as! ProductShoppingCartTableViewCell
            superCell.moveRightImagePresale(false)
             cell.showRightUtilityButtonsAnimated(true)
        default :
            print("other pressed")
        }
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return !isEdditing
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
    
    //MARK : Actions
    
    /**
     Delete item in car from indexpath selected
     
     - parameter indexPath: selected row
     */
    func deleteRowAtIndexPath(indexPath : NSIndexPath){
        //getUPCItems
        self.showLoadingView()
        listObj = self.itemsInCartOrderSection[indexPath.section - 1] as! NSDictionary
        productObje = listObj["products"] as! NSArray
        let itemWishlist = productObje[indexPath.row] as! [String:AnyObject]
        let upc = itemWishlist["upc"] as! String
        let deleteShoppingCartService = ShoppingCartDeleteProductsService()
        let descriptions =  itemWishlist["description"] as! String
        BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_PRODUCT_CART.rawValue, label: "\(descriptions) - \(upc)")
        //let paramUpc = deleteShoppingCartService.builParams(upc)
        //deleteShoppingCartService.callService(paramUpc, successBlock: { (result:NSDictionary) -> Void in
        deleteShoppingCartService.callCoreDataService(upc, successBlock: { (result:NSDictionary) -> Void in
            //self.idexesPath = []
            
            //self.viewShoppingCart.beginUpdates()
            self.itemsInCartOrderSection = []

            if UserCurrentSession.sharedInstance().itemsMG != nil {
                //self.itemsInShoppingCart = UserCurrentSession.sharedInstance().itemsMG!["items"] as! NSArray as [AnyObject]
                let itemsUserCurren = UserCurrentSession.sharedInstance().itemsMG!["items"] as! NSArray as [AnyObject]
                self.itemsInCartOrderSection = RecentProductsViewController.adjustDictionary(itemsUserCurren as [AnyObject]) as! [AnyObject]
                self.arrayItems()
            }
            /*self.itemsInShoppingCart.removeAtIndex(indexPath.row)
             self.itemsInCartOrderSection.removeAtIndex(indexPath.row)
             */
            
            //self.viewShoppingCart.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            
            
            self.loadShoppingCartService()
            
            self.updateTotalItemsRow()
            self.viewShoppingCart.reloadData()
            
            //self.viewShoppingCart.endUpdates()
            
            if self.itemsInShoppingCart.count == 0 {
                self.navigationController!.popToRootViewControllerAnimated(true)
            }
            
            }, errorBlock: { (error:NSError) -> Void in
                print("delete pressed Errro \(error)")
        })
    }
    
    /**
     Update totals view in case, delete or update itmes
     */
    func updateTotalItemsRow() {
        let totalIndexPath =  NSIndexPath(forRow: itemsInShoppingCart.count, inSection: 0)
        self.viewShoppingCart.reloadRowsAtIndexPaths([totalIndexPath], withRowAnimation: UITableViewRowAnimation.None)
        UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
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
            let dictShoppingCartProduct = shoppingCartProduct as! [String:AnyObject]
            
            var price : NSString = ""
            if let priceValue = shoppingCartProduct["price"] as? NSNumber{
                price = priceValue.stringValue
            }
            if let priceValueS = shoppingCartProduct["price"] as? NSString{
                price = priceValueS
            }
            
            var iva : NSString = ""
            if let ivabase = shoppingCartProduct["ivaAmount"] as? NSString {
                iva = ivabase
            }
            if let ivabase = shoppingCartProduct["ivaAmount"] as? NSNumber {
                iva = ivabase.stringValue
            }
            
            var baseprice : NSString = ""
            if let priceEvent = shoppingCartProduct["priceEvent"] as? NSDictionary{
                
                if let pricebase = priceEvent["basePrice"] as? NSString {
                    baseprice = pricebase
                }
                if let pricebase = priceEvent["basePrice"] as? NSNumber {
                    baseprice = pricebase.stringValue
                }
            }
            
            var quantity : NSString = ""
            if let quantityN = shoppingCartProduct["quantity"] as? NSString { //NSNumber
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
            /*if shoppingCartProduct["type"] as? NSNumber == 0 {
                total +=  (price.doubleValue * quantity.doubleValue)
            } else {
                total +=  ((quantity.doubleValue / 1000.0 ) * price.doubleValue)
            }*/
            
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

    /**
     Find upc from items more expencive from crosselling n car
     
     - returns: upc found
     */
    func getExpensive() -> String {
        let priceLasiItem = 0.0
        var upc = ""
           for shoppingCartProduct in  itemsInShoppingCart {
            //let dictShoppingCartProduct = shoppingCartProduct as! [String:AnyObject]
            var price : NSString = ""
            if let priceValue = shoppingCartProduct["price"] as? NSNumber{
                price = priceValue.stringValue
            }
            if let priceValueS = shoppingCartProduct["price"] as? NSString{
                price = priceValueS
            }
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
    func getUPCItems(section: Int, row: Int) -> [[String:String]] {

        var upcItems : [[String:String]] = []
        var countItems = 0
        
        //Get UPC of All items
         for sect in 0 ..< self.itemsInCartOrderSection.count {
            let lineItems = self.itemsInCartOrderSection[sect]
            let productsline = lineItems["products"]
            for idx in 0 ..< productsline!.count {
                if section == sect && row == idx {
                    self.itemSelect = countItems
                }
                let upc = productsline![idx]["upc"] as! String
                let desc = productsline![idx]["description"] as! String
                upcItems.append(["upc":upc,"description":desc,"type":ResultObjectType.Mg.rawValue])
                countItems = countItems + 1
            }
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
            upcItems.appendContentsOf("'\(upc)',")
        }
        upcItems.appendContentsOf("]")
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
    func goTODetailProduct(upc: String, items: [[String : String]], index: Int, imageProduct: UIImage?, point: CGRect, idList: String) {
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = items
        controller.ixSelected = index
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
     /**
     Open form of discount associate
     */
    func openDiscount(){
        let discountAssociateItems = [NSLocalizedString("checkout.discount.associateNumber", comment:""),NSLocalizedString("checkout.discount.dateAdmission", comment:""),NSLocalizedString("checkout.discount.determinant", comment:"")]
        self.selectedConfirmation  = NSIndexPath(forRow: 0, inSection: 0)
        
        self.picker!.sender = self//self.discountAssociate!
        self.picker!.titleHeader = NSLocalizedString("checkout.field.discountAssociate", comment:"")
        self.picker!.delegate = self
        self.picker!.selected = self.selectedConfirmation
        self.picker!.setValues("Descuento de asociado", values: discountAssociateItems)
        self.picker!.cellType = TypeField.Alphanumeric
        self.picker!.showPicker()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShoppingCartViewController.keyBoardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShoppingCartViewController.keyBoardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
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

    /**
     Present  login controller after shopping, 
     validate if user contain address, if not , call service to add new addres an save.
     */
    func showloginshop() {
        self.buttonShop!.enabled = false
        if UserCurrentSession.hasLoggedUser() {
            
            //FACEBOOKLOG
            FBSDKAppEvents.logPurchase(self.totalShop, currency: "MXN", parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "productgr",FBSDKAppEventParameterNameContentID:self.getUPCItemsString()])
            self.buttonShop!.enabled = true
            
            //Add alert
            if UserCurrentSession().addressId == nil {
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"tabBar_storeLocator_active"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"tabBar_storeLocator_active"))
                alert?.showicon(UIImage(named:"tabBar_storeLocator_active"))
                alert?.setMessage(NSLocalizedString("alert.checkout.address", comment: ""))
                //alert?.bgView.backgroundColor = WMColor.light_blue
                alert?.addActionButtonsWithCustomText(NSLocalizedString("update.later", comment: ""), leftAction: {
                    
                    alert?.close()
                    }, rightText: NSLocalizedString("checkout.alert.createAddress", comment: ""), rightAction: {
                        alert?.showDoneIcon()
                        alert?.close()
                        
                        //Add new address
                        if self.alertAddress == nil {
                            self.alertAddress = GRFormAddressAlertView.initAddressAlert()!
                        }
                        self.alertAddress?.showAddressAlert()
                        self.alertAddress?.beforeAddAddress = {(dictSend:NSDictionary?) in
                            self.alertAddress?.registryAddress(dictSend)
                            //alert?.close()
                        }
                        
                        self.alertAddress?.alertSaveSuccess = {() in
                            self.performSegueWithIdentifier("checkoutVC", sender: self)
                            self.alertAddress?.removeFromSuperview()
                        }
                        
                        self.alertAddress?.cancelPress = {() in
                            print("")
                            self.alertAddress?.closePicker()
                            
                        }
                    }, isNewFrame: false)
            } else {
                self.performSegueWithIdentifier("checkoutVC", sender: self)
            }
            
        } else {
            let cont = LoginController.showLogin()
            self.buttonShop!.enabled = true
            cont!.closeAlertOnSuccess = false
            cont!.successCallBack = {() in
                //UserCurrentSession.sharedInstance().loadGRShoppingCart { () -> Void in
                //self.loadGRShoppingCart()
                
                 BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_CHECKOUT.rawValue, label: "")
                 
                 self.performSegueWithIdentifier("checkoutVC", sender: self)
                 
                 cont.closeAlert(true, messageSucesss: true)
                 
                 self.buttonShop!.enabled = true
                 
                 //}
            }
        }

    }
    
    
    
    func presentedCheckOut(loginController: LoginController, address: AddressViewController?){
        //FACEBOOKLOG
        FBSDKAppEvents.logPurchase(self.totalShop, currency: "MXN", parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "productmg",FBSDKAppEventParameterNameContentID:self.getUPCItemsString()])

        UserCurrentSession.sharedInstance().loadMGShoppingCart { () -> Void in
            let serviceReview = ReviewShoppingCartService()
            serviceReview.callService([:], successBlock: { (result:NSDictionary) -> Void in
                if !self.canceledAction  {
                    print(UserCurrentSession.sharedInstance().itemsMG)
                    let itemsMG = UserCurrentSession.sharedInstance().itemsMG
                    let totalsItems = self.totalItems()
                    let total = totalsItems["total"] as String!
                    
                    self.checkVC = self.checkOutController()
                    self.checkVC.afterclose = {() -> Void in self.checkVC = nil }
                    self.checkVC.username = loginController.email?.text
                    self.checkVC.password = loginController.password?.text
                    self.checkVC.itemsMG = itemsMG!["items"] as! NSArray
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

    /**
     Call shopping cart service mg and load car
     */
    func reloadShoppingCart () {
        //self.viewContent.addSubview(viewLoad)
        //viewLoad.startAnnimating()
        idexesPath = []
        UserCurrentSession.sharedInstance().loadMGShoppingCart { () -> Void in
            self.loadShoppingCartService()
        }
        
    }
    
    /**
     Update sho button, before update or delete itemes.
     
     - parameter total: new total
     */
    func updateShopButton(total:String) {
        self.totalShop = (total as NSString).doubleValue
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: self.buttonShop.bounds)
            customlabel.backgroundColor = UIColor.clearColor()
            customlabel.setCurrencyUserInteractionEnabled(true)
            buttonShop.addSubview(customlabel)
            buttonShop.sendSubviewToBack(customlabel)
        }
        
        let shopStr = NSLocalizedString("shoppingcart.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(total)
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
    
    /**
     Invoke cross Selling service, present related products in car
     */
    func loadCrossSell() {
         if self.itemsInCartOrderSection.count >  0 {
            let upcValue = getExpensive()
            let crossService = CrossSellingProductService()
            crossService.callService(upcValue, successBlock: { (result:NSArray?) -> Void in
                if result != nil {
                    
                    var isShowingBeforeLeave = false
                    let sectionMax = (self.itemsInCartOrderSection.count)
                    self.listObj = self.itemsInCartOrderSection[sectionMax - 1] as! NSDictionary
                    self.productObje = self.listObj["products"] as! NSArray
                    
                    if self.tableView(self.viewShoppingCart, numberOfRowsInSection: sectionMax) == self.productObje.count + 2{// + 2
                        isShowingBeforeLeave = true
                    }
                    
                    self.itemsUPC = result!
                    if self.itemsUPC.count > 3 {
                        var arrayUPCS = self.itemsUPC as [AnyObject]
//                        arrayUPCS.sortInPlace({ (before, after) -> Bool in
//                            let priceB = before["price"] as! NSString
//                            let priceA = after["price"] as! NSString
//                            return priceB.doubleValue < priceA.doubleValue
//                        })
                        var resultArray : [AnyObject] = []
                        for item in arrayUPCS[0...2] {
                            resultArray.append(item)
                        }
                        self.itemsUPC = NSArray(array:resultArray)
                        
                    }
                     if self.itemsInCartOrderSection.count >  0  {
                        if self.itemsUPC.count > 0  && !isShowingBeforeLeave {
                            self.viewShoppingCart.insertRowsAtIndexPaths([NSIndexPath(forItem: self.productObje.count + 1, inSection: sectionMax )], withRowAnimation: UITableViewRowAnimation.Automatic)
                        }else{
                            self.viewShoppingCart.reloadRowsAtIndexPaths([NSIndexPath(forItem: self.productObje.count + 1, inSection: sectionMax)], withRowAnimation: UITableViewRowAnimation.Automatic)
                        }
                    }
                    //self.collection.reloadData()
                }else {
                    
                }
                }, errorBlock: { (error:NSError) -> Void in
                    print("Termina sevicio app \(error.localizedDescription)")
            })
        }
    }
    

    /**
     View presenten message when add or delete items from wishlist
     
     - parameter message: text to present in view
     */
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
   
        
        serviceSCDelete.callService(serviceSCDelete.builParamsMultiple(upcs), successBlock: { (result:NSDictionary) -> Void in
           /* println("Error not done")
            
            self.reloadShoppingCart()
            self.navigationController!.popToRootViewControllerAnimated(true)
            */
            UserCurrentSession.sharedInstance().loadMGShoppingCart({ () -> Void in
                //self.reloadShoppingCart()
                self.removeLoadingView()
              
                
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
                service.callService(requestParams: service.buildParams(associateNumber!, determinant: determinant!),
                    succesBlock: { (response:NSDictionary) -> Void in
                        print(response)
                        if response["codeMessage"] as? Int == 0 {
                            //Mostrar alerta y continua
                            self.alertView?.setMessage("Datos correctos")
                            self.alertView?.close()
                            self.loadShoppingCartService()
                            self.viewShoppingCart.reloadData()
                            self.updateTotalItemsRow()
                            //self.showloginshop()
                        }else{
                            self.alertView?.setMessage("Error en los datos del asociado")
                            self.alertView!.showErrorIcon("Ok")
                        }
                        
                    }) { (error:NSError) -> Void in
                        // mostrar alerta de error de info
                        self.alertView?.setMessage("Error en los datos del asociado")
                        self.alertView!.showErrorIcon("Ok")
                        print(error)
                }
            }else{
                self.alertView?.setMessage("Error en los datos del asociado\(result)")
                self.alertView!.showErrorIcon("Ok")
            }
        
    })
    
        
        
    }
    
    func closeAlertPk() {
    }
    
    /**
     Validate info associate
     
     - parameter associateNumber: number asociate
     - parameter dateAdmission:   date admission
     - parameter determinant:     determinat
     - parameter completion:      block validate
     */
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
    
    /**
     Present loader in screen car
     */
    func showLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height))
        self.viewLoad!.backgroundColor = UIColor.whiteColor()
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
    
    /**
     Share products
     */
    func shareProduct() {
        
        if self.isEdditing {
            return
        }
        
        self.viewShoppingCart!.setContentOffset(CGPoint.zero , animated: false)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_SHARE.rawValue , label: "")
        
        if let image = self.viewShoppingCart!.screenshot() {
            let imageHead = UIImage(named:"detail_HeaderMail")
            let imgResult = UIImage.verticalImageFromArray([imageHead!,image])
            let controller = UIActivityViewController(activityItems: [imgResult], applicationActivities: nil)
            self.navigationController?.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    //MARK: ListSelectorDelegate
    
    func listSelectorDidShowList(listId: String, andName name:String) {
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? UserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func listSelectorDidAddProduct(inList listId:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRAddItemListService()
        var products: [AnyObject] = []
        for idx in 0 ..< self.itemsInShoppingCart.count {
            let item = self.itemsInShoppingCart[idx] as! [String:AnyObject]
            
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
            products.append(service.buildProductObject(upc: upc, quantity: quantity,pesable:pesable,active:active))
        }
        
        service.callService(service.buildParams(idList: listId, upcs: products),
                            successBlock: { (result:NSDictionary) -> Void in
                                self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToListDone", comment:""))
                                self.alertView!.showDoneIcon()
                                self.alertView!.afterRemove = {
                                    self.removeListSelector(action: nil)
                                }
            }, errorBlock: { (error:NSError) -> Void in
                print("Error at add product to list: \(error.localizedDescription)")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
                self.alertView!.afterRemove = {
                    self.removeListSelector(action: nil)
                }
            }
        )
    }
    
    func listSelectorDidAddProductLocally(inList list:List) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        for idx in 0 ..< self.itemsInShoppingCart.count {
            let item = self.itemsInShoppingCart[idx] as! [String:AnyObject]
            
            var quantity: Int = 0
            if  let qIntProd = item["quantity"] as? Int {
                quantity = qIntProd
            }
            if  let qIntProd = item["quantity"] as? NSString {
                quantity = qIntProd.integerValue
            }
            
            var price: Double = 0.0
            if  let qIntProd = item["price"] as? NSNumber {
                price = qIntProd.doubleValue
            }
            if  let qIntProd = item["price"] as? NSString {
                price = qIntProd.doubleValue
            }
            
            var typeProdVal: Int = 0
            if let typeProd = item["type"] as? NSString {
                typeProdVal = typeProd.integerValue
            }
            
            
            let detail = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as? Product
            detail!.upc = item["upc"] as! String
            detail!.desc = item["description"] as! String
            detail!.price = "\(price)"
            detail!.quantity = NSNumber(integer: quantity)
            detail!.type = NSNumber(integer: typeProdVal)
            detail!.list = list
            detail!.img = item["imageUrl"] as! String
        }
        
        do {
            try context.save()
        } catch  {
            print("Error save context listSelectorDidAddProductLocally")
        }
        
        let count:Int = list.products.count
        list.countItem = NSNumber(integer: count)
        do {
            try context.save()
        } catch {
            print("Error save context listSelectorDidAddProductLocally")
        }
        self.removeListSelector(action: nil)
        
    }
    
    func removeListSelector(action action:(()->Void)?) {
        if self.listSelectorController != nil {
            UIView.animateWithDuration(0.5,
                                       delay: 0.0,
                                       options: .LayoutSubviews,
                                       animations: { () -> Void in
                                        let frame = self.view.frame
                                        self.listSelectorController!.view.frame = CGRectMake(0, frame.height, frame.width, 0.0)
                                        self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, -frame.height, frame.width, frame.height)
                }, completion: { (complete:Bool) -> Void in
                    if complete {
                        if self.listSelectorController != nil {
                            self.listSelectorController!.willMoveToParentViewController(nil)
                            self.listSelectorController!.view.removeFromSuperview()
                            self.listSelectorController!.removeFromParentViewController()
                            self.listSelectorController = nil
                        }
                        self.buttonListSelect!.selected = false
                        
                        action?()
                    }
                }
            )
        }
    }
    
    func listSelectorDidDeleteProductLocally(product:Product, inList list:List) {
    }
    
    func listSelectorDidDeleteProduct(inList listId:String) {
    }

    func listSelectorDidShowListLocally(list: List) {
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? UserListDetailViewController {
            vc.listEntity = list
            vc.listName = list.name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }

    
    func listSelectorDidClose() {
        self.removeListSelector(action: nil)
    }
    
    func shouldDelegateListCreation() -> Bool {
        return true
    }
    
    func listSelectorDidCreateList(name:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRSaveUserListService()
        
        var products: [AnyObject] = []
        for idx in 0 ..< self.itemsInShoppingCart.count {
            let item = self.itemsInShoppingCart[idx] as! [String:AnyObject]
            
            let upc = item["upc"] as! String
            var quantity: Int = 0
            if  let qIntProd = item["quantity"] as? NSNumber {
                quantity = qIntProd.integerValue
            }
            else if  let qIntProd = item["quantity"] as? NSString {
                quantity = qIntProd.integerValue
            }
            var price: String? = nil
            if  let priceNum = item["price"] as? NSNumber {
                price = "\(priceNum)"
            }
            else if  let priceTxt = item["price"] as? String {
                price = priceTxt
            }
            
            let imgUrl = item["imageUrl"] as? String
            let description = item["description"] as? String
            let type = item["type"] as? String
            
            var  nameLine = ""
            if let line = item["line"] as? NSDictionary {
                nameLine = line["name"] as! String
            }
            
            let serviceItem = service.buildProductObject(upc: upc, quantity: quantity, image: imgUrl!, description: description!, price: price!, type: type,nameLine:nameLine)
            products.append(serviceItem)
        }
        
        service.callService(service.buildParams(name, items: products),
                            successBlock: { (result:NSDictionary) -> Void in
                                self.listSelectorController!.loadLocalList()
                                self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToListDone", comment:""))
                                self.alertView!.showDoneIcon()
                                self.removeListSelector(action: nil)
            },
                            errorBlock: { (error:NSError) -> Void in
                                print(error)
                                self.alertView!.setMessage(error.localizedDescription)
                                self.alertView!.showErrorIcon("Ok")
            }
        )
    }
    
}
