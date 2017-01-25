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
import FBSDKCoreKit

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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


protocol ShoppingCartViewControllerDelegate {
    func closeShoppingCart()
}

class ShoppingCartViewController : BaseController ,UITableViewDelegate,UITableViewDataSource,ProductShoppingCartTableViewCellDelegate,SWTableViewCellDelegate,ProductDetailCrossSellViewDelegate,AlertPickerViewDelegate,ListSelectorDelegate {
    
    var viewLoad : WMLoadingView!
    
    var itemsInShoppingCart : [[String:Any]]! = []
    var itemsInCartOrderSection : [[String:Any]]! = []
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
    var alertAddress : GRFormAddressAlertView? = nil
    
    var listObj : [String:Any]!
    var productObje : [[String:Any]]!
    
    var heightHeaderTable : CGFloat = IS_IPAD ? 40.0 : 26
    var itemSelect = 0
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
        
        viewShoppingCart = UITableView(frame:CGRect(x: 0, y: 46 , width: self.viewContent.frame.width, height: viewContent.frame.height - 46))
        viewShoppingCart.clipsToBounds = false
        viewShoppingCart.backgroundColor =  WMColor.light_light_gray
        viewShoppingCart.backgroundColor =  UIColor.white
        viewShoppingCart.layoutMargins = UIEdgeInsets.zero
        viewShoppingCart.separatorInset = UIEdgeInsets.zero
        viewShoppingCart.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
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
        
        viewHerader.addSubview(editButton)
        viewHerader.addSubview(deleteall)
        viewHerader.addSubview(titleView)
        
        
        viewFooter = UIView()
        viewFooter.backgroundColor = UIColor.white
        
        let x:CGFloat = 16
        
        buttonListSelect = UIButton(frame: CGRect(x: x, y: 16, width: 34.0, height: 34.0))
        buttonListSelect.setImage(UIImage(named:"detail_list"), for: UIControlState())
        buttonListSelect.addTarget(self, action: #selector(ShoppingCartViewController.addToWishList), for: UIControlEvents.touchUpInside)
        viewFooter.addSubview(buttonListSelect)
        
        
        facebookButton = UIButton()
        facebookButton.frame = CGRect(x: buttonListSelect.frame.maxX + 16, y: 16.0, width: 34.0, height: 34.0)
        facebookButton.setImage(UIImage(named:"detail_shareOff"), for: UIControlState())
        facebookButton.setImage(UIImage(named:"detail_share"), for: UIControlState.highlighted)
        facebookButton.setImage(UIImage(named:"detail_share"), for: UIControlState.selected)
        facebookButton.addTarget(self, action: #selector(ShoppingCartViewController.shareProduct), for: UIControlEvents.touchUpInside)
        viewFooter.addSubview(facebookButton)
        
        
        buttonShop = UIButton(frame: CGRect(x: facebookButton.frame.maxX + 16, y: facebookButton.frame.minY  , width: self.view.frame.width - (facebookButton.frame.maxX + 32), height: 34))
        buttonShop.backgroundColor = WMColor.green
        //buttonShop.setTitle(NSLocalizedString("shoppingcart.shop",comment:""), forState: UIControlState.Normal)
        buttonShop.layer.cornerRadius = 17
        buttonShop.addTarget(self, action: #selector(ShoppingCartViewController.showloginshop), for: UIControlEvents.touchUpInside)
        viewFooter.addSubview(buttonShop)
        
        let viewBorderTop = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        viewBorderTop.backgroundColor = WMColor.light_light_gray
        viewFooter.addSubview(viewBorderTop)
        
        viewShoppingCart.register(ShoppingCartTextViewCell.self, forCellReuseIdentifier: "textCell")
        viewShoppingCart.register(ProductShoppingCartTableViewCell.self, forCellReuseIdentifier: "productCell")
        viewShoppingCart.register(ShoppingCartTotalsTableViewCell.self, forCellReuseIdentifier: "TotalsCell")
        viewShoppingCart.register(ShoppingCartCrossSellCollectionViewCell.self, forCellReuseIdentifier: "crossSellCell")
        
        viewShoppingCart.separatorStyle = .none
        
        viewShoppingCart.isMultipleTouchEnabled = false
        
        self.viewContent.addSubview(viewHerader)
        self.viewContent.addSubview(viewShoppingCart)
        self.viewContent.sendSubview(toBack: viewShoppingCart)
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
        emptyView = IPOShoppingCartEmptyView(frame:CGRect.zero)
        emptyView.frame = CGRect(x: 0,  y: viewHerader.frame.maxY,  width: self.view.frame.width,  height: self.view.frame.height - viewHerader.frame.height)
        emptyView.returnAction = {() in
            self.delegate.closeShoppingCart()
        }
        self.view.addSubview(emptyView)
        
        self.emptyView.iconImageView.image =  UIImage(named:"empty_cart")
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.viewLoad == nil {
            self.showLoadingView()
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
        self.viewShoppingCart.frame =  CGRect(x: 0, y: self.viewHerader.frame.maxY, width: self.view.bounds.width, height: viewContent.frame.height - self.viewFooter.frame.height - self.viewHerader.frame.maxY)

        if !self.isEdditing {
        self.titleView.frame = CGRect(x: (self.viewHerader.bounds.width / 2) - ((self.view.bounds.width - 32)/2), y: self.viewHerader.bounds.minY, width: self.view.bounds.width - 32, height: self.viewHerader.bounds.height)
        }

        self.editButton.frame = CGRect(x: self.view.frame.width - 71, y: 12, width: 55, height: 22)
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
        
        if UserCurrentSession.sharedInstance.itemsMG != nil {
            //self.itemsInShoppingCart = UserCurrentSession.sharedInstance.itemsMG!["items"] as! NSArray as [Any]
            let itemsUserCurren = UserCurrentSession.sharedInstance.itemsMG!
            self.itemsInCartOrderSection = RecentProductsViewController.adjustDictionary(itemsUserCurren as AnyObject,isShoppingCart: true)
            self.arrayItems()
        }
        
        if self.itemsInShoppingCart.count == 0 {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        if  self.itemsInShoppingCart.count > 0 {
            //let priceInfo = UserCurrentSession.sharedInstance.itemsMG!["commerceItems"] as! [String:Any]
            self.subtotal = Int(UserCurrentSession.sharedInstance.itemsMG!["rawSubtotal"] as? String ?? "0") as NSNumber!//subtotal
            self.ivaprod = Int(UserCurrentSession.sharedInstance.itemsMG!["amount"] as? String ?? "0") as NSNumber!//ivaSubtotal
            self.totalest = UserCurrentSession.sharedInstance.itemsMG!["total"] as! NSNumber//totalEstimado
        }else{
            self.subtotal = NSNumber(value: 0 as Int32)
            self.ivaprod = NSNumber(value: 0 as Int32)
            self.totalest = NSNumber(value: 0 as Int32)
        }
        
        
        let totalsItems = self.totalItems()
        let total = totalsItems["total"] as String!
        
        self.updateShopButton(total!)
        
        self.viewShoppingCart.delegate = self
        self.viewShoppingCart.dataSource = self
        viewShoppingCart.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.viewShoppingCart.reloadData()
        
        
        self.loadCrossSell()
        
        self.removeLoadingView()
        self.emptyView!.isHidden = self.itemsInShoppingCart.count > 0
        self.editButton.isHidden = self.itemsInShoppingCart.count == 0
    }
    
    /**
     Close sopping cart mg and send tag Analytics
     */
    func closeShoppingCart () {
        //EVENT
        //BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue,categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue,action:WMGAIUtils.ACTION_BACK_PRE_SHOPPING_CART.rawValue , label: "")
        self.view.removeFromSuperview()
    }

  
    func addToWishList () {
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_ADD_MY_LIST.rawValue, label: "")
        
        if self.listSelectorController == nil {
            self.buttonListSelect!.isSelected = true
            let frame = self.view.frame
            self.listSelectorController = ListsSelectorViewController()
            self.listSelectorController!.delegate = self
            
            //self.listSelectorController!.productUpc = self.upc
            let listSelectorHeight: CGFloat = frame.height - 72
            self.addChildViewController(self.listSelectorController!)
            self.listSelectorController!.view.frame = CGRect(x: 0, y: listSelectorHeight, width: frame.width, height: 0.0)
            self.view.insertSubview(self.listSelectorController!.view, belowSubview: self.viewFooter!)
            self.listSelectorController!.titleLabel!.text = NSLocalizedString("gr.addtolist.super", comment: "")
            self.listSelectorController!.didMove(toParentViewController: self)
            self.listSelectorController!.view.clipsToBounds = true
            
            self.listSelectorController!.generateBlurImage(self.view, frame: CGRect(x: 0, y: 0, width: frame.width, height: listSelectorHeight))
            self.listSelectorController!.imageBlurView!.frame = CGRect(x: 0, y: listSelectorHeight, width: frame.width, height: listSelectorHeight)
            
            UIView.animate(withDuration: 0.5,
                                       animations: { () -> Void in
                                        self.listSelectorController!.view.frame = CGRect(x: 0, y: 0, width: frame.width, height: listSelectorHeight)
                                        self.listSelectorController!.imageBlurView!.frame = CGRect(x: 0, y: 0, width: frame.width, height: listSelectorHeight)
                },
                                       completion: { (finished:Bool) -> Void in
                                        if finished {
                                            self.listSelectorController!.tableView!.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                                            self.listSelectorController!.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                                        }
                }
            )
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
        
        for itemSection in self.itemsInCartOrderSection {
            listObj = itemSection
            productObje = listObj["products"] as! [[String:Any]]
                
            for prodSection in productObje {
                self.itemsInShoppingCart.insert(prodSection as [String:Any], at: ind)//as! NSArray
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
    func runSpinAnimationOnView(_ view:UIView,duration:CGFloat,rotations:CGFloat,repeats:CGFloat) {
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float(repeats)
        view.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
    }
    
    //MARK: - TableviewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        listObj = self.itemsInCartOrderSection[section - 1] 
            productObje = listObj["products"] as! [[String:Any]]
            
        if section == (self.itemsInCartOrderSection.count) {
            return productObje!.count + (self.itemsUPC.count > 0 ? 2 : 1)
            } else {
            return productObje!.count
        }
        //return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return heightHeaderTable
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        let headerView : UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: heightHeaderTable))
        headerView.backgroundColor = UIColor.white
        let titleLabel = UILabel(frame: CGRect(x: 15.0, y: 0.0, width: self.view.frame.width, height: heightHeaderTable))
        
        listObj = self.itemsInCartOrderSection[section - 1] 
        titleLabel.text = listObj["name"] as? String
        titleLabel.textColor = WMColor.light_blue
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(12)

        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.itemsInCartOrderSection.count + 1
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        
        if (indexPath as NSIndexPath).section  == 0  {
            let cell = viewShoppingCart.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! ShoppingCartTextViewCell
            return cell
        }
        
        listObj = self.itemsInCartOrderSection[(indexPath as NSIndexPath).section - 1] 
            productObje = listObj["products"] as! [[String:Any]]
            
        var flagSectionCel = false
        if (itemsInCartOrderSection.count) != (indexPath as NSIndexPath).section {
            flagSectionCel = true
        } else {
            flagSectionCel = productObje.count > (indexPath as NSIndexPath).row ? true : false
        }
        
        if flagSectionCel{
            let cellProduct = viewShoppingCart.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductShoppingCartTableViewCell
            cellProduct.delegateProduct = self
            cellProduct.delegate = self
            cellProduct.rightUtilityButtons = getRightButtonDelete()
            cellProduct.setLeftUtilityButtons(getLeftDelete(), withButtonWidth: 36.0)
            let shoppingCartProduct = productObje[(indexPath as NSIndexPath).row] //as! [String:Any]
            let skuId = shoppingCartProduct["catalogRefId"] as? String ?? ""
            let productId = shoppingCartProduct["productId"] as? String ?? ""
            let desc = shoppingCartProduct["productDisplayName"] as! String
            var price : String = ""
            let commerceItemId = shoppingCartProduct["commerceItemId"] as! String
            
            let priceInfo = shoppingCartProduct["priceInfo"] as? [String:Any]
            if let priceValue = priceInfo!["amount"] as? NSNumber{
                price = priceValue.stringValue
            }
            if let priceValueS = priceInfo!["amount"] as? NSString{
                price = priceValueS as String
            }
            //let quantity = shoppingCartProduct["quantity"] as! NSString
            var quantity : String = ""
            if let quantityValue = shoppingCartProduct["quantity"] as? NSNumber{
                quantity = quantityValue.stringValue
            }
            if let quantityValueS = shoppingCartProduct["quantity"] as? String{
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
            
            //promoDescription
            if  let savingProd = shoppingCartProduct["promoDescription"] as? String {
                savingVal = savingProd
            }
            
            //comments
            let comments = shoppingCartProduct["itemComment"] as? String ?? ""
            
            var productDeparment = ""
            if let category = shoppingCartProduct["category"] as? String{
                productDeparment = category
            }
            
            var promotionDescription : String? = ""
            if let promotion = shoppingCartProduct["promotion"] as? [[String:Any]] {
                if promotion.count > 0 {
                    promotionDescription = promotion[0]["description"] as? String
                }
            }
            
            var through: String! = ""
            let plpArray = UserCurrentSession.sharedInstance.getArrayPLP(shoppingCartProduct )
           
            
            if let priceThr = shoppingCartProduct["saving"] as? NSString {
                through = priceThr as String!
            }
            
            through = plpArray["promo"] as! String == "" ? through : plpArray["promo"] as! String
            
            cellProduct.setValues(skuId,productId:productId,productImageURL:imageUrl, productShortDescription: desc, productPrice: price, saving: savingVal,quantity:(quantity as NSString).integerValue,onHandInventory:onHandInventory,isPreorderable: isPreorderable, category:productDeparment, promotionDescription: promotionDescription, productPriceThrough: through! as String, isMoreArts: plpArray["isMore"] as! Bool,commerceItemId: commerceItemId,comments:comments)
            
            cellProduct.setValueArray(plpArray["arrayItems"] as! [[String:Any]])
            
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
            if productObje.count == (indexPath as NSIndexPath).row && IS_IPHONE {
                let cellTotals = viewShoppingCart.dequeueReusableCell(withIdentifier: "TotalsCell", for: indexPath) as! ShoppingCartTotalsTableViewCell
                
                let totalsItems = totalItems()
                
                let subTotalText = totalsItems["subtotal"] as String!
                let iva = totalsItems["iva"] as String!
                let total = totalsItems["total"] as String!
                let totalSaving = totalsItems["totalSaving"] as String!
                
                updateShopButton(total!)
                
                let newTotal  = total
                let newTotalSavings = totalSaving
                
                //cellTotals.setValues(subTotalText, iva: iva, total:newTotal,totalSaving:newTotalSavings)
                cellTotals.setValuesAll(articles: String(itemsInShoppingCart.count), subtotal: subTotalText!, shippingCost: "", iva: iva!, saving: newTotalSavings!, total: newTotal!)
                cell = cellTotals
                
            } else { //if productObje.count < indexPath.row
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
        
        if (indexPath as NSIndexPath).section == 0 {
            return
        }
        
        listObj = self.itemsInCartOrderSection[(indexPath as NSIndexPath).section-1] as [String : Any]
        productObje = listObj["products"] as! [[String : Any]]

        if (indexPath as NSIndexPath).section == (itemsInCartOrderSection.count) {
            if productObje.count <= (indexPath as NSIndexPath).row {
                return
            }
        }
        
        if itemsInShoppingCart.count > (indexPath as NSIndexPath).row && !isSelectingProducts  {
            let controller = ProductDetailPageViewController()
            controller.itemsToShow = getUPCItems((indexPath as NSIndexPath).section - 1, row: (indexPath as NSIndexPath).row) as [Any]
            controller.ixSelected = self.itemSelect//indexPath.row
            
            let item = productObje[(indexPath as NSIndexPath).row] 
            let  name = item["productDisplayName"] as! String
            let upc = item["productId"] as! String
            //EVENT
            //BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue, label: "\(name) - \(upc)")
            if self.navigationController != nil {
                self.navigationController!.pushViewController(controller, animated: true)
                
            }
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 46
        }
        
        listObj = self.itemsInCartOrderSection[(indexPath as NSIndexPath).section - 1] as! [String:Any]
        self.productObje = listObj["products"] as! [[String:Any]]

        var flagSectionCel = false
        if (itemsInCartOrderSection.count) != (indexPath as NSIndexPath).section {
            flagSectionCel = true
        } else {
            flagSectionCel = productObje.count > (indexPath as NSIndexPath).row ? true : false
        }
        
        if flagSectionCel {
            return 124
        }else{
            if productObje.count == (indexPath as NSIndexPath).row  {
                return 124
            }
            if productObje.count < (indexPath as NSIndexPath).row  {
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
            //BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_EDIT_CART.rawValue, label: "")
            
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
        
        var itemByUpc  = self.itemsInShoppingCart![(indexPath as NSIndexPath).row] 
        itemByUpc.updateValue(String(cell.quantity) , forKey: "quantity")
        self.itemsInShoppingCart[(indexPath as NSIndexPath).row] = itemByUpc as [String:Any]
        
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
            
            //GRShoppingCartWeightSelectorView
            //cell.typeProd
            
            if cell.typeProd == 1 {
                selectQuantity = GRShoppingCartWeightSelectorView(frame:frameDetail,priceProduct:NSNumber(value: (cell.price as NSString).doubleValue as Double),quantity:cell.quantity,equivalenceByPiece:cell.equivalenceByPiece,upcProduct:cell.productId)
            } else {
                selectQuantity = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(value: (cell.price as NSString).doubleValue as Double),upcProduct:cell.productId as String)
            }
            
            selectQuantity?.addToCartAction = { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                
                if (cell.onHandInventory as NSString).integerValue <= Int(quantity) {
                    self.selectQuantity?.closeAction()

                    
                    if cell.typeProd == 0 {
                        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_CHANGE_NUMER_OF_PIECES.rawValue, label: "")
                    } else {
                        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_CHANGE_NUMER_OF_KG.rawValue, label: "")
                    }
                    
                    let updateOrderService = UpdateItemToOrderService()
                    let params = updateOrderService.buildParameter(cell.skuId, productId: cell.productId, quantity: quantity, quantityWithFraction: "0", orderedUOM: "EA", orderedQTYWeight: "0")
                    updateOrderService.callService(requestParams: params as AnyObject, succesBlock: {(result) in
                        self.reloadShoppingCart()
                        }, errorBlock: {(error) in
                         self.reloadShoppingCart()
                    })
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
                let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
                let frame = vc!.view.frame
                
                
                let addShopping = ShoppingCartUpdateController()
                let params = self.buildParamsUpdateShoppingCart(cell,quantity: "\(cell.quantity)")
                addShopping.params = params
                vc!.addChildViewController(addShopping)
                addShopping.view.frame = frame
                vc!.view.addSubview(addShopping.view)
                addShopping.didMove(toParentViewController: vc!)
                addShopping.typeProduct = ResultObjectType.Groceries
                addShopping.comments = cell.comments
                addShopping.goToShoppingCart = {() in }
                addShopping.removeSpinner()
                addShopping.addActionButtons()
                addShopping.addNoteToProduct(nil)
            }
            selectQuantity?.userSelectValue(String(cell.quantity))
            selectQuantity?.first = true
            if cell.comments.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
                selectQuantity!.setTitleCompleteButton(NSLocalizedString("shoppingcart.updateNote",comment:""))
            }else {
                selectQuantity!.setTitleCompleteButton(NSLocalizedString("shoppingcart.addNote",comment:""))
            }
            selectQuantity?.showNoteButtonComplete()
            selectQuantity?.closeAction = { () in
                self.selectQuantity!.removeFromSuperview()
                
            }
            self.view.addSubview(selectQuantity!)
        }
    }
    
    func buildParamsUpdateShoppingCart(_ cell:ProductShoppingCartTableViewCell,quantity:String) -> [String:Any] {
        let pesable = cell.pesable ? "1" : "0"
        return ["upc":cell.skuId as AnyObject,"desc":cell.desc as AnyObject,"imgUrl":cell.imageurl as AnyObject,"price":cell.price,"quantity":quantity as AnyObject,"comments":cell.comments as AnyObject,"onHandInventory":cell.onHandInventory,"wishlist":false as AnyObject,"type":ResultObjectType.Groceries.rawValue as AnyObject,"pesable":pesable,"commerceItemId":cell.commerceIds,"skuId":cell.skuId]
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
        //getUPCItems
        self.showLoadingView()
        self.listObj = self.itemsInCartOrderSection[(indexPath as NSIndexPath).section - 1]
        self.productObje = listObj["products"] as! [[String:Any]]
        let itemWishlist = productObje[(indexPath as NSIndexPath).row] 
        let upc = itemWishlist["commerceItemId"] as! String
        let deleteShoppingCartService = ShoppingCartDeleteProductsService()
        deleteShoppingCartService.callCoreDataService(upc, successBlock: { (result:[String:Any]) -> Void in
            self.itemsInCartOrderSection = []

            if UserCurrentSession.sharedInstance.itemsMG != nil {
                //self.itemsInShoppingCart = UserCurrentSession.sharedInstance.itemsMG!["items"] as! NSArray as [Any]
                let itemsUserCurren = UserCurrentSession.sharedInstance.itemsMG!["commerceItems"] as! [Any]
                self.itemsInCartOrderSection = RecentProductsViewController.adjustDictionary(itemsUserCurren as AnyObject, isShoppingCart: true)
                self.arrayItems()
            }
            
            self.loadShoppingCartService()
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
            let dictShoppingCartProduct = shoppingCartProduct 
            
            var price : NSString = ""
            
            let priceInfo = shoppingCartProduct["priceInfo"] as? [String:Any]
            if let priceValue = priceInfo!["amount"] as? NSNumber{
                price = priceValue.stringValue as NSString
            }
            if let priceValueS = priceInfo!["amount"] as? NSString{
                price = priceValueS
            }
            
            var iva : NSString = ""
            if let ivabase = priceInfo!["savingsAmount"] as? NSString {
                iva = ivabase
            }
            if let ivabase = priceInfo!["savingsAmount"] as? NSNumber {
                iva = ivabase.stringValue as NSString
            }
            
            var baseprice : NSString = ""
            if let priceEvent = shoppingCartProduct["priceEvent"] as? [String:Any]{
                
                if let pricebase = priceEvent["basePrice"] as? NSString {
                    baseprice = pricebase
                }
                if let pricebase = priceEvent["basePrice"] as? NSNumber {
                    baseprice = pricebase.stringValue as NSString
                }
            }
            
            var quantity : NSString = ""
            if let quantityN = shoppingCartProduct["quantity"] as? NSString { //NSNumber
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
            var price : NSString = ""
            let priceInfo = shoppingCartProduct["priceInfo"] as! [String:Any]
            
            if let priceValue = priceInfo["amount"] as? NSNumber{
                price = priceValue.stringValue as NSString
            }
            if let priceValueS = priceInfo["amount"] as? NSString{
                price = priceValueS
            }
            if price.doubleValue < priceLasiItem {
                continue
            }
            if let u = shoppingCartProduct["catalogRefId"] as? NSString  {
                upc = u as String
            }
          
        }
        return upc
    }
    
    /**
     Find all items in shopping cart
     
     - returns: array products in cart
     */
    func getUPCItems(_ section: Int, row: Int) -> [[String:String]] {

        var upcItems : [[String:String]] = []
        var countItems = 0
        
        //Get UPC of All items
         for lineItems in self.itemsInCartOrderSection {
            let productsline = lineItems["products"] as! [[String:Any]]
            for product in productsline {
                let upc = product["productId"] as! String
                let desc = product["productDisplayName"] as! String
                upcItems.append(["upc":upc,"description":desc,"type":ResultObjectType.Mg.rawValue,"sku":upc])//sku
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
            let upc = shoppingCartProduct["productId"] as! String
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
    func goTODetailProduct(_ upc: String, items: [[String : String]], index: Int, imageProduct: UIImage?, point: CGRect, idList: String) {
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = items as [Any]
        controller.ixSelected = index
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
        self.buttonShop!.isEnabled = false
        if UserCurrentSession.hasLoggedUser() {
            
            //FACEBOOKLOG
            FBSDKAppEvents.logPurchase(self.totalShop, currency: "MXN", parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "productgr",FBSDKAppEventParameterNameContentID:self.getUPCItemsString()])
            self.buttonShop!.isEnabled = true
            
            self.showAlertAddress()
            
            
        } else {
            let cont = LoginController.showLogin()
            self.buttonShop!.isEnabled = true
            cont!.closeAlertOnSuccess = false
            cont!.successCallBack = {() in
                //UserCurrentSession.sharedInstance.loadGRShoppingCart { () -> Void in
                //self.loadGRShoppingCart()
                
                 //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_CHECKOUT.rawValue, label: "")
                 
                 self.performSegue(withIdentifier: "checkoutVC", sender: self)
                 cont?.closeAlert(true, messageSucesss: true)
                 self.buttonShop!.isEnabled = true
                 //}
            }
        }
    }
    
    func showAlertAddress(){
        //Add alert
        if UserCurrentSession.sharedInstance.addressId != nil {//TODO
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
                    self.alertAddress?.beforeAddAddress = {(dictSend:[String:Any]?) in
                        self.alertAddress?.registryAddress(dictSend)
                        //alert?.close()
                    }
                    
                    self.alertAddress?.alertSaveSuccess = {() in
                        if !IS_IPAD{
                            self.performSegue(withIdentifier: "checkoutVC", sender: self)
                        }
                        self.alertAddress?.removeFromSuperview()
                    }
                    
                    self.alertAddress?.cancelPress = {() in
                        print("")
                        self.alertAddress?.closePicker()
                        
                    }
                }, isNewFrame: false)
        } else {
            if !IS_IPAD{
                self.performSegue(withIdentifier: "checkoutVC", sender: self)
            }
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
                    self.checkVC.itemsMG = itemsMG!["items"] as! [[String:Any]]
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
        
        let shopStr = NSLocalizedString("shoppingcart.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(total as NSString)
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
         if self.itemsInCartOrderSection.count >  0 {
            let uskuIdValue = getExpensive()
            let crossService = CrossSellingProductService()
            crossService.callService(requestParams: ["skuId":uskuIdValue], successBlock: { (result:[[String:Any]]?) -> Void in
                if result != nil {
                    
                    var isShowingBeforeLeave = false
                    let sectionMax = (self.itemsInCartOrderSection.count)
                    self.listObj = self.itemsInCartOrderSection[sectionMax - 1]
                    self.productObje = self.listObj["products"] as! [[String:Any]]
                    
                    if self.tableView(self.viewShoppingCart, numberOfRowsInSection: sectionMax) == self.productObje.count + 2{// + 2
                        isShowingBeforeLeave = true
                    }
                    
                    self.itemsUPC = result!
                    if self.itemsUPC.count > 3 {
                        var arrayUPCS = self.itemsUPC as [[String:Any]]
                        var resultArray : [[String:Any]] = []
                        for item in arrayUPCS[0...2] {
                            resultArray.append(item)
                        }
                        self.itemsUPC = resultArray
                        
                    }
                     if self.itemsInCartOrderSection.count >  0  {
                        if self.itemsUPC.count > 0  && !isShowingBeforeLeave {
                            self.viewShoppingCart.insertRows(at: [IndexPath(item: self.productObje.count + 1, section: sectionMax )], with: UITableViewRowAnimation.automatic)
                        }else{
                            self.viewShoppingCart.reloadRows(at: [IndexPath(item: self.productObje.count + 1, section: sectionMax)], with: UITableViewRowAnimation.automatic)
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
     Call delete itmes in sopping car,
     */
    func deleteAll() {
        let serviceSCDelete = ShoppingCartDeleteProductsService()
        var upcs : [String] = []
        for itemSClist in self.itemsInShoppingCart {
            let upc = itemSClist["commerceItemId"] as! String
            upcs.append(upc)
        }
        self.showLoadingView()
   
        
        serviceSCDelete.callService(serviceSCDelete.builParamsMultiple(upcs) as [String:Any], successBlock: { (result:[String:Any]) -> Void in
            UserCurrentSession.sharedInstance.loadMGShoppingCart({ () -> Void in
                self.editAction(self.editButton!)
                self.removeLoadingView()
                self.loadShoppingCartService()
                print("done")
                
                //EVENT
                //BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_ALL_PRODUCTS_CART.rawValue, label: "")
                
                self.navigationController?.popToRootViewController(animated: true)
            })
            
            }) { (error:NSError) -> Void in
                print("error")
                self.editAction(self.editButton!)
                self.removeLoadingView()
                self.loadShoppingCartService()
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
                service.callService(requestParams: service.buildParams(associateNumber!, determinant: determinant!),
                    succesBlock: { (response:[String:Any]) -> Void in
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
    
    /**
     Share products
     */
    func shareProduct() {
        
        if self.isEdditing {
            return
        }
        
        self.viewShoppingCart!.setContentOffset(CGPoint.zero , animated: false)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_SHARE.rawValue , label: "")
        
        if let image = self.viewShoppingCart!.screenshot() {
            let imageHead = UIImage(named:"detail_HeaderMail")
            let imgResult = UIImage.verticalImage(from: [imageHead!,image])
            let controller = UIActivityViewController(activityItems: [imgResult], applicationActivities: nil)
            self.navigationController?.present(controller, animated: true, completion: nil)
        }
    }
    
    //MARK: ListSelectorDelegate
    
    func listSelectorDidShowList(_ listId: String, andName name:String) {
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? UserListDetailViewController {
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
        var products: [Any] = []
        for idx in 0 ..< self.itemsInShoppingCart.count {
            let item = self.itemsInShoppingCart[idx] 
            
            let upc = item["productId"] as! String
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
            var sku = ""
            if let skuId = item["catalogRefId"] as? String {
                sku = skuId
            }
            //products.append(service.buildProductObject(upc: upc, quantity: quantity,pesable:pesable,active:active))
            products.append(service.buildItemMustang(upc, sku: sku, quantity: quantity)) //sku
        }
        
        service.callService(service.buildItemMustangObject(idList: listId, upcs: products),
                            successBlock: { (result:[String:Any]) -> Void in
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
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        for idx in 0 ..< self.itemsInShoppingCart.count {
            let item = self.itemsInShoppingCart[idx] 
            
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
            
            
            let detail = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as? Product
            detail!.upc = item["upc"] as! String
            detail!.desc = item["description"] as! String
            detail!.price = "\(price)" as NSString
            detail!.quantity = NSNumber(value: quantity as Int)
            detail!.type = NSNumber(value: typeProdVal as Int)
            detail!.list = list
            detail!.img = item["imageUrl"] as! String
        }
        
        do {
            try context.save()
        } catch  {
            print("Error save context listSelectorDidAddProductLocally")
        }
        
        let count:Int = list.products.count
        list.countItem = NSNumber(value: count as Int)
        do {
            try context.save()
        } catch {
            print("Error save context listSelectorDidAddProductLocally")
        }
        self.removeListSelector(action: nil)
        
    }
    
    func removeListSelector(action:(()->Void)?) {
        if self.listSelectorController != nil {
            UIView.animate(withDuration: 0.5,
                                       delay: 0.0,
                                       options: .layoutSubviews,
                                       animations: { () -> Void in
                                        let frame = self.view.frame
                                        let listSelectorHeight: CGFloat = frame.height - 72
                                        self.listSelectorController!.view.frame = CGRect(x: 0, y: listSelectorHeight, width: frame.width, height: 0.0)
                                        self.listSelectorController!.imageBlurView!.frame = CGRect(x: 0, y: listSelectorHeight, width: frame.width, height: listSelectorHeight)
                }, completion: { (complete:Bool) -> Void in
                    if complete {
                        if self.listSelectorController != nil {
                            self.listSelectorController!.willMove(toParentViewController: nil)
                            self.listSelectorController!.view.removeFromSuperview()
                            self.listSelectorController!.removeFromParentViewController()
                            self.listSelectorController = nil
                        }
                        self.buttonListSelect!.isSelected = false
                        
                        action?()
                    }
                }
            )
        }
    }
    
    func listSelectorDidDeleteProductLocally(_ product:Product, inList list:List) {
    }
    
    func listSelectorDidDeleteProduct(inList listId:String) {
    }

    func listSelectorDidShowListLocally(_ list: List) {
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? UserListDetailViewController {
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
    
    func listSelectorDidCreateList(_ name:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRSaveUserListService()
        
        var products: [Any] = []
        for idx in 0 ..< self.itemsInShoppingCart.count {
            let item = self.itemsInShoppingCart[idx] 
            
            let upc = item["productId"] as! String
            var quantity: Int = 0
            if  let qIntProd = item["quantity"] as? NSNumber {
                quantity = qIntProd.intValue
            }
            else if  let qIntProd = item["quantity"] as? NSString {
                quantity = qIntProd.integerValue
            }
            var price: String = ""
            if  let priceNum = item["price"] as? NSNumber {
                price = "\(priceNum)"
            }
            else if  let priceTxt = item["price"] as? String {
                price = priceTxt
            }
            
            var imgUrl = ""
            if let image = item["imageUrl"] as? String {
                imgUrl =  image
            }
            
            var  description = ""
            if let desc = item["description"] as? String{
                description = desc
            }
            
            let type = item["type"] as? String
            
            var  nameLine = ""
            if let line = item["line"] as? [String:Any] {
                nameLine = line["name"] as! String
            }
            
            let serviceItem = service.buildProductObject(upc: upc, quantity: quantity, image: imgUrl, description: description, price: price, type: type,nameLine:nameLine)
            products.append(serviceItem as AnyObject)
        }
        
        service.callService(service.buildParams(name, items: products),
                            successBlock: { (result:[String:Any]) -> Void in
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
