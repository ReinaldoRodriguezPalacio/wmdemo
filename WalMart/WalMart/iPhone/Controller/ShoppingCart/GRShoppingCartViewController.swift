//
//  GRShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/21/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class GRShoppingCartViewController : BaseController, UITableViewDelegate, UITableViewDataSource,UIViewControllerTransitioningDelegate, GRProductShoppingCartTableViewCellDelegate, SWTableViewCellDelegate, ListSelectorDelegate {
    
    var onClose : ((isClose:Bool) -> Void)? = nil
    var viewLoad : WMLoadingView!
    var viewHerader : UIView!
    var titleView : UILabel!
    var closeButton : UIButton!
    var itemsInCart : [AnyObject] = []
    var tableShoppingCart : UITableView!
    var viewFooter : UIView!
    var buttonShop : UIButton!
    var selectQuantityGR : GRShoppingCartQuantitySelectorView!
    var listSelectorController: ListsSelectorViewController?
    var alertView: IPOWMAlertViewController?
    
    var addToListButton: UIButton?
    var editButton : UIButton!
    var deleteall: UIButton!
    
    var customlabel : CurrencyCustomLabel!
    
    var isEdditing = false
    
    var showCloseButton : Bool = true

    var emptyView : IPOShoppingCartEmptyView!
    var totalShop: Double = 0.0
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRSHOPPINGCART.rawValue
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        viewHerader = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, 46))
        viewHerader.backgroundColor = WMColor.light_light_gray
        
        titleView = UILabel(frame: viewHerader.bounds)
        titleView.font = WMFont.fontMyriadProRegularOfSize(14)
        titleView.textColor = WMColor.light_blue
        titleView.text = NSLocalizedString("shoppingcart.title",comment:"")
        titleView.textAlignment = .Center
        
        
        closeButton = UIButton(frame:CGRectMake(0, 0, viewHerader.frame.height, viewHerader.frame.height))
        closeButton.setImage(UIImage(named: "BackProduct"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: #selector(GRShoppingCartViewController.closeShoppingCart), forControlEvents: UIControlEvents.TouchUpInside)
        
        viewHerader.addSubview(closeButton)
        viewHerader.addSubview(titleView)
        
        
        tableShoppingCart = UITableView(frame: self.view.bounds)
        tableShoppingCart.delegate = self
        tableShoppingCart.dataSource = self
        tableShoppingCart.registerClass(GRProductShoppingCartTableViewCell.self, forCellReuseIdentifier: "productCell")
        tableShoppingCart.registerClass(GRShoppingCartTotalsTableViewCell.self, forCellReuseIdentifier: "totals")
        tableShoppingCart.separatorStyle = UITableViewCellSeparatorStyle.None

        
        tableShoppingCart.clipsToBounds = false

        self.view.addSubview(tableShoppingCart)
        
        self.view.addSubview(viewHerader)
        
        
        viewFooter = UIView(frame: CGRectMake(0, self.view.bounds.height - 72 , self.view.bounds.width, 72))
        viewFooter.backgroundColor = UIColor.whiteColor()
        viewFooter.alpha = 0
        
        
        self.addToListButton = UIButton(frame: CGRectMake(8 ,0, 50, viewFooter.frame.height))
        self.addToListButton!.setImage(UIImage(named: "detail_list"), forState: .Normal)
        self.addToListButton!.setImage(UIImage(named: "detail_list_selected"), forState: .Selected)
        self.addToListButton!.addTarget(self, action: #selector(GRShoppingCartViewController.addCartToList), forControlEvents: .TouchUpInside)
        
        let buttonShare = UIButton(frame: CGRectMake(self.addToListButton!.frame.maxX, 0, 50, viewFooter.frame.height))
        buttonShare.setImage(UIImage(named: "detail_shareOff"), forState: UIControlState.Normal)
        buttonShare.addTarget(self, action: #selector(GRShoppingCartViewController.shareShoppingCart), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonShop = UIButton(frame: CGRectMake(buttonShare.frame.maxX + 8, (viewFooter.frame.height / 2) - 17, self.view.frame.width - buttonShare.frame.maxX - 24, 34))
        buttonShop.backgroundColor = WMColor.green
        buttonShop.layer.cornerRadius = 17
        buttonShop.addTarget(self, action: #selector(GRShoppingCartViewController.showshoppingcart), forControlEvents: UIControlEvents.TouchUpInside)
        buttonShop.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        
        viewFooter.addSubview(self.addToListButton!)
        viewFooter.addSubview(buttonShare)
        viewFooter.addSubview(buttonShop)
        self.view.addSubview(viewFooter)
        
        
        //Edit 
        editButton = UIButton(frame:CGRectMake(self.view.frame.width - 71, 12, 55, 22))
        editButton.setTitle(NSLocalizedString("shoppingcart.edit",comment:""), forState: UIControlState.Normal)
        editButton.setTitle(NSLocalizedString("shoppingcart.endedit",comment:""), forState: UIControlState.Selected)
        editButton.backgroundColor = WMColor.light_blue
        editButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        editButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        editButton.layer.cornerRadius = 11
        editButton.addTarget(self, action: #selector(GRShoppingCartViewController.editAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        editButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
        
        deleteall = UIButton(frame: CGRectMake(editButton.frame.minX - 80, 12, 75, 22))
        deleteall.setTitle(NSLocalizedString("wishlist.deleteall",comment:""), forState: UIControlState.Normal)
        deleteall.backgroundColor = WMColor.red
        deleteall.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        deleteall.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        deleteall.layer.cornerRadius = 11
        deleteall.alpha = 0
        deleteall.titleEdgeInsets = UIEdgeInsetsMake(2.0, 2.0, 0.0, 0.0)
        deleteall.addTarget(self, action: #selector(GRShoppingCartViewController.deleteAll), forControlEvents: UIControlEvents.TouchUpInside)
        
        viewHerader.addSubview(editButton)
        viewHerader.addSubview(deleteall)
        
        
        
        initEmptyView()
        //loadGRShoppingCart()
        BaseController.setOpenScreenTagManager(titleScreen: "Carrito", screenName: self.getScreenGAIName())

        
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
        self.removeViewLoad()
        loadGRShoppingCart()
        
        self.emptyView!.hidden = self.itemsInCart.count > 0
        self.editButton.hidden = self.itemsInCart.count == 0
        
        if !showCloseButton {
            self.closeButton.hidden = true
        } else {
            self.closeButton.hidden = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableShoppingCart.frame = CGRectMake(0, self.viewHerader.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.viewHerader.frame.height - 72)
        self.viewFooter.frame = CGRectMake(0, self.view.bounds.height - 72 , self.view.bounds.width, 72)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GRShoppingCartViewController.reloadGRShoppingCart), name: CustomBarNotification.SuccessAddItemsToShopingCart.rawValue, object: nil)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.viewFooter.alpha = 1
        })
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func closeShoppingCart() {
        self.navigationController!.popToRootViewControllerAnimated(true)
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_BACK_PRE_SHOPPING_CART.rawValue, label: "")
        
    }
    
    func reloadGRShoppingCart(){
        UserCurrentSession.sharedInstance().loadGRShoppingCart { () -> Void in
            self.loadGRShoppingCart()
        }
    }
    
    
    func loadGRShoppingCart() {
        if UserCurrentSession.sharedInstance().itemsGR != nil {
            self.itemsInCart = UserCurrentSession.sharedInstance().itemsGR!["items"] as! [AnyObject]
            self.tableShoppingCart.reloadData()
            self.updateShopButton("\(UserCurrentSession.sharedInstance().estimateTotalGR() -  UserCurrentSession.sharedInstance().estimateSavingGR())")
        }
        
    }
    
    //MARK: - Table View Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsInCart.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.row == itemsInCart.count {
        let tblTotalCell = tableShoppingCart.dequeueReusableCellWithIdentifier("totals", forIndexPath: indexPath) as! GRShoppingCartTotalsTableViewCell
            let subtotal = UserCurrentSession.sharedInstance().estimateTotalGR()
            let saving = UserCurrentSession.sharedInstance().estimateSavingGR()
            
            tblTotalCell.setValuesWithSubtotal("\(subtotal)", iva: "",
                total: "\(subtotal - saving)",
                totalSaving: "\(saving)",
                numProds:"\(UserCurrentSession.sharedInstance().numberOfArticlesGR())")
            
            return tblTotalCell
        }
        
        let tblShoppingCell = tableShoppingCart.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! GRProductShoppingCartTableViewCell
        
        tblShoppingCell.selectionStyle = UITableViewCellSelectionStyle.None
        tblShoppingCell.rightUtilityButtons = getRightButton()
        tblShoppingCell.setLeftUtilityButtons(getLeftDelete(), withButtonWidth: 36.0)
        
        let itemProduct = itemsInCart[indexPath.row] as! NSDictionary
        
        let upc = itemProduct["upc"] as! String
        var quantity : Int = 0
        if  let qIntProd = itemProduct["quantity"] as? Int {
            quantity = qIntProd
        }
        if  let qIntProd = itemProduct["quantity"] as? NSString {
            quantity = qIntProd.integerValue
        }
        
        
        let imgUrl = itemProduct["imageUrl"] as! String
        var price : Double = 0.0
        
        if  let qIntProd = itemProduct["price"] as? Double {
            price = qIntProd
        }
        if  let qIntProd = itemProduct["price"] as? NSString {
            price = qIntProd.doubleValue
        }
        
        var saving = ""
        if  let savingProd = itemProduct["promoDescription"] as? String {
            saving = savingProd
        }
        
        let description = itemProduct["description"] as! String
        let priceStr = "\(price)"
        var typeProdVal : Int = 0
        if let typeProd = itemProduct["type"] as? NSString {
            typeProdVal = typeProd.integerValue
        }
        
//        var stock = 0
//        if let stockProd = itemProduct["stock"] as? NSNumber {
//            stock = stockProd.integerValue
//        }
//        
//        if let stockProd = itemProduct["stock"] as? NSNumber {
//            stock = stockProd.integerValue
//        }

//        if let _ = itemProduct["stock"] as?  Bool {
//            if self.isActive == true  {
//                self.isActive  = stockSvc
//            }
//        }

        
        
        var equivalenceByPiece = NSNumber(int:0)
        if let equivalence = itemProduct["equivalenceByPiece"] as? NSNumber {
            equivalenceByPiece = equivalence
        }
        
        if let equivalence = itemProduct["equivalenceByPiece"] as? NSString {
            if equivalence != "" {
                equivalenceByPiece =  NSNumber(int: equivalence.intValue)
            }
        }

        
        let comments = itemProduct["comments"] as? String
        
        
        tblShoppingCell.delegateQuantity = self
        tblShoppingCell.delegate = self
        
        if typeProdVal != 1 {
            tblShoppingCell.setValues(upc, productImageURL: imgUrl, productShortDescription: description, productPrice: priceStr, saving: saving, quantity: quantity, onHandInventory: "99",typeProd:typeProdVal, comments:comments == nil ? "" : comments!,equivalenceByPiece:equivalenceByPiece)
        } else {
            tblShoppingCell.setValues(upc, productImageURL: imgUrl, productShortDescription: description, productPrice: priceStr, saving: saving, quantity: quantity, onHandInventory: "20000",typeProd:typeProdVal, comments:comments == nil ? "" : comments!,equivalenceByPiece:equivalenceByPiece)
        }
        
        
        if isEdditing == true {
            tblShoppingCell.setEditing(true, animated: false)
            tblShoppingCell.showLeftUtilityButtonsAnimated(false)
        }else{
            tblShoppingCell.setEditing(false, animated: false)
            tblShoppingCell.hideUtilityButtonsAnimated(true)
        }

        
        return tblShoppingCell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == itemsInCart.count {
            return 80
        }
        return 110
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if itemsInCart.count > indexPath.row   {
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue, label: "")
            
            let controller = ProductDetailPageViewController()
            controller.itemsToShow = getUPCItems()
            controller.ixSelected = indexPath.row
            controller.detailOf = "Shopping Cart"
            if self.navigationController  != nil {
                self.navigationController!.pushViewController(controller, animated: true)
            }
        }
    }
    
    func showshoppingcart() {
        self.buttonShop!.enabled = false
        if UserCurrentSession.sharedInstance().userSigned != nil {
            self.addViewload()
            //FACEBOOKLOG
            FBSDKAppEvents.logPurchase(self.totalShop, currency: "MXN", parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "productgr",FBSDKAppEventParameterNameContentID:self.getUPCItemsString()])
            UserCurrentSession.sharedInstance().loadGRShoppingCart { () -> Void in
                self.buttonShop!.enabled = true
                self.performSegueWithIdentifier("checkoutVC", sender: self)
            }
        } else {
            let cont = LoginController.showLogin()
            self.buttonShop!.enabled = true
            cont!.closeAlertOnSuccess = false
            cont!.successCallBack = {() in
                UserCurrentSession.sharedInstance().loadGRShoppingCart { () -> Void in
                    self.loadGRShoppingCart()
                    
                    
                    //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_CHECKOUT.rawValue, label: "")
                    
                    self.performSegueWithIdentifier("checkoutVC", sender: self)
                    
                    cont.closeAlert(true, messageSucesss: true)
                    
                    self.buttonShop!.enabled = true
                    
                }
            }
        }
    }
    
    func userShouldChangeQuantity(cell:GRProductShoppingCartTableViewCell) {
        if self.isEdditing == false {
            let frameDetail = CGRectMake(0,0, self.view.frame.width,self.view.frame.height)
            if cell.typeProd == 1 {
                selectQuantityGR = GRShoppingCartWeightSelectorView(frame:frameDetail,priceProduct:NSNumber(double:cell.price.doubleValue),quantity:cell.quantity,equivalenceByPiece:cell.equivalenceByPiece,upcProduct:cell.upc)
                
            }else{
                selectQuantityGR = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(double:cell.price.doubleValue),quantity:cell.quantity,upcProduct:cell.upc)
            }
            
            
            selectQuantityGR?.addToCartAction = { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                
                if cell.onHandInventory.integerValue >= Int(quantity) {
                    self.selectQuantityGR?.closeAction()
                    
                    if cell.typeProd == 0 {
                    //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_CHANGE_NUMER_OF_PIECES.rawValue, label: "")
                    } else {
                    //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_CHANGE_NUMER_OF_KG.rawValue, label: "")
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
            
            selectQuantityGR?.addUpdateNote = {() in
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
            selectQuantityGR?.userSelectValue(String(cell.quantity))
            selectQuantityGR?.first = true
            if cell.comments.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
                selectQuantityGR.setTitleCompleteButton(NSLocalizedString("shoppingcart.updateNote",comment:""))
            }else {
                selectQuantityGR.setTitleCompleteButton(NSLocalizedString("shoppingcart.addNote",comment:""))
            }
            selectQuantityGR?.showNoteButtonComplete()
            selectQuantityGR?.closeAction = { () in
                self.selectQuantityGR.removeFromSuperview()
                
            }
            
            self.view.addSubview(selectQuantityGR)
            
        } else {
            let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
            let frame = vc!.view.frame
            
            
            let addShopping = ShoppingCartUpdateController()
            let params = self.buildParamsUpdateShoppingCart(cell,quantity: "\(cell.quantity)")
            addShopping.params = params
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
    }
    
    
    func buildParamsUpdateShoppingCart(cell:GRProductShoppingCartTableViewCell,quantity:String) -> [String:AnyObject] {
        let pesable = cell.pesable ? "1" : "0"
        return ["upc":cell.upc,"desc":cell.desc,"imgUrl":cell.imageurl,"price":cell.price,"quantity":quantity,"comments":cell.comments,"onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable]
    }
    
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
    
    //MARK : Edit shopping cart
    
    func editAction(sender:AnyObject) {
        
        
        isEdditing = !isEdditing
        if (isEdditing) {
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_EDIT_CART.rawValue, label: "")
            
            let currentCells = self.tableShoppingCart.visibleCells
            for cell in currentCells {
                if cell.isKindOfClass(SWTableViewCell) {
                    if let cellSW = cell as? GRProductShoppingCartTableViewCell {
                        cellSW.setEditing(true, animated: false)
                        cellSW.showLeftUtilityButtonsAnimated(true)
                    }
                }
            }
            editButton.selected = true
            editButton.backgroundColor = WMColor.green
            
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.deleteall.alpha = 1
                self.titleView.frame = CGRectMake(self.titleView.frame.minX - 30, self.titleView.frame.minY, self.titleView.frame.width, self.titleView.frame.height)
            })
            
        }else{
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_CANCEL.rawValue, label: "")
            
            let currentCells = self.tableShoppingCart.visibleCells
            for cell in currentCells {
                if cell.isKindOfClass(SWTableViewCell) {
                    if let cellSW = cell as? GRProductShoppingCartTableViewCell {
                        cellSW.setEditing(false, animated: false)
                        cellSW.hideUtilityButtonsAnimated(false)
                        cellSW.rightUtilityButtons = getRightButton()
                    }
                }
            }
            editButton.selected = false
            editButton.backgroundColor = WMColor.light_blue
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.deleteall.alpha = 0
                self.titleView.frame = CGRectMake(self.titleView.frame.minX + 30, self.titleView.frame.minY, self.titleView.frame.width, self.titleView.frame.height)
            })
            
        }

    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch index {
        case 0:
           
            let indexPath = self.tableShoppingCart.indexPathForCell(cell)
            if self.isEdditing {
                if indexPath != nil {
                    deleteRowAtIndexPath(indexPath!)
                   // self.
                }
            } else {
                if let cellSC = cell as? GRProductShoppingCartTableViewCell {
                    
                    let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
                    let frame = vc!.view.frame
                    
                    
                    let addShopping = ShoppingCartUpdateController()
                    let params = self.buildParamsUpdateShoppingCart(cellSC,quantity: "\(cellSC.quantity)")
                    addShopping.params = params
                    vc!.addChildViewController(addShopping)
                    addShopping.view.frame = frame
                    vc!.view.addSubview(addShopping.view)
                    addShopping.didMoveToParentViewController(vc!)
                    addShopping.typeProduct = ResultObjectType.Groceries
                    addShopping.comments = cellSC.comments
                    addShopping.goToShoppingCart = {() in }
                    addShopping.removeSpinner()
                    addShopping.addActionButtons()
                    addShopping.addNoteToProduct(nil)
                }
            }
            
        case 1:
             //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_DELETE_PRODUCT_CART.rawValue, label: "")
            let indexPath = self.tableShoppingCart.indexPathForCell(cell)
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
            cell.rightUtilityButtons = getRightButtonOnlyDelete()
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
        //    return !isEdditing
        }
    }
    
    
    func getRightButton() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        let buttonNote = UIButton(frame: CGRectMake(0, 0, 80, 109))
        buttonNote.setTitle(NSLocalizedString("shoppingcart.note",comment:""), forState: UIControlState.Normal)
        buttonNote.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonNote.backgroundColor = WMColor.light_blue
        toReturn.append(buttonNote)
        
        let buttonDelete = UIButton(frame: CGRectMake(0, 0, 80, 109))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), forState: UIControlState.Normal)
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    func getRightButtonOnlyDelete() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        
        let buttonDelete = UIButton(frame: CGRectMake(0, 0, 80, 109))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), forState: UIControlState.Normal)
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    func getLeftDelete() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        let buttonDelete = UIButton(frame: CGRectMake(0, 0, 36, 109))
        buttonDelete.setImage(UIImage(named:"myList_delete"), forState: UIControlState.Normal)
        buttonDelete.backgroundColor = WMColor.light_gray
        toReturn.append(buttonDelete)
        
        return toReturn
    }

    
    func getUPCItems() -> [[String:String]] {
        
        var upcItems : [[String:String]] = []
        for shoppingCartProduct in  itemsInCart {
            let upc = shoppingCartProduct["upc"] as! String
            let desc = shoppingCartProduct["description"] as! String
            let type = ResultObjectType.Groceries.rawValue
            upcItems.append(["upc":upc,"description":desc,"type":type])
        }
        return upcItems
    }
    
    func getUPCItemsString() -> String {
        var upcItems :String = "["
        for shoppingCartProduct in  itemsInCart {
            let upc = shoppingCartProduct["upc"] as! String
            upcItems.appendContentsOf("'\(upc)',")
        }
        upcItems.appendContentsOf("]")
        return upcItems
    }

    //MARK: Delete item 
    
    func deleteRowAtIndexPath(indexPath : NSIndexPath){
        let itemGRSC = itemsInCart[indexPath.row] as! [String:AnyObject]
        let upc = itemGRSC["upc"] as! String
        
        let serviceWishDelete = GRShoppingCartDeleteProductsService()
        var allUPCS : [String] = []
         allUPCS.append(upc)
        self.addViewload()
            
            serviceWishDelete.callService(allUPCS, successBlock: { (result:NSDictionary) -> Void in
                UserCurrentSession.sharedInstance().loadMGShoppingCart({ () -> Void in
                    self.itemsInCart.removeAtIndex(indexPath.row)
                    self.removeViewLoad()
                if self.itemsInCart.count == 0 {
                    self.navigationController!.popToRootViewControllerAnimated(true)
                } else {
                    self.tableShoppingCart.reloadData()
                    self.updateShopButton("\(UserCurrentSession.sharedInstance().estimateTotalGR() - UserCurrentSession.sharedInstance().estimateSavingGR())")
                }
            })
            }, errorBlock: { (error:NSError) -> Void in
                print("error")
            })
        
    }
    
    func retrieveParam(entityName : String, sortBy:String? = nil, isAscending:Bool = true, predicate:NSPredicate? = nil) -> AnyObject{
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
        fetchRequest.predicate = predicate
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult!
        
    }
    
    
    
    func deleteAll() {
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_DELETE_ALL_PRODUCTS_CART.rawValue, label: "")
        
        var predicate = NSPredicate(format: "user == nil AND status != %@ AND type == %@",NSNumber(integer: WishlistStatus.Deleted.rawValue),ResultObjectType.Groceries.rawValue)
        if UserCurrentSession.hasLoggedUser() {
            predicate = NSPredicate(format: "user == %@ AND status != %@ AND type == %@", UserCurrentSession.sharedInstance().userSigned!,NSNumber(integer: CartStatus.Deleted.rawValue),ResultObjectType.Groceries.rawValue)
        }
        var arrayUPCQuantity : [[String:String]] = []
        let array  =  self.retrieveParam("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
        let service = GRProductsByUPCService()
        for item in array {
            arrayUPCQuantity.append(service.buildParamService(item.product.upc, quantity: item.quantity.stringValue))
        }
        
        
        let serviceWishDelete = GRShoppingCartDeleteProductsService()
        var allUPCS : [String] = []
        for itemWishlist in arrayUPCQuantity {
            print(itemWishlist)
            let upc = itemWishlist["upc"] 
           allUPCS.append("\(upc!)")
        }
        
        self.addViewload()
        
        serviceWishDelete.callService(allUPCS, successBlock: { (result:NSDictionary) -> Void in
            UserCurrentSession.sharedInstance().loadGRShoppingCart({ () -> Void in
                //self.loadGRShoppingCart()
                
                self.removeViewLoad()
                
                print("done")
                if self.onClose != nil {
                    self.onClose?(isClose:true)
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
                
            })
            }, errorBlock: { (error:NSError) -> Void in
                print("error")
        })
        self.editAction(self.editButton)
    }
    
    
    //MARK: Share Shopping Cart
    
    
    func shareShoppingCart() {
        self.removeListSelector(action: nil)
        let imageHead = UIImage(named:"detail_HeaderMail")
        let imageHeader = UIImage(fromView: self.viewHerader)
        let screen = self.tableShoppingCart.screenshot()
        let imgResult = UIImage.verticalImageFromArray([imageHead!,imageHeader,screen])
        let controller = UIActivityViewController(activityItems: [imgResult], applicationActivities: nil)
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
        
        if #available(iOS 8.0, *) {
            controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
                if completed && !activityType!.containsString("com.apple")   {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        } else {
            controller.completionHandler = {(activityType, completed:Bool) in
                if completed && !activityType!.containsString("com.apple")   {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        }
        
    }
    
    //MARK: - Actions List Selector
    
    func addCartToList() {
        
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_ADD_MY_LIST.rawValue, label: "")
        
        if self.listSelectorController == nil {
            self.addToListButton!.selected = true
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
                        self.addToListButton!.selected = false
                        
                        action?()
                    }
                }
            )
        }
    }
    
    //MARK: - ListSelectorDelegate
    
    func listSelectorDidClose() {
        self.removeListSelector(action: nil)
    }
    
    func listSelectorDidAddProduct(inList listId:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRAddItemListService()
        var products: [AnyObject] = []
        for idx in 0 ..< self.itemsInCart.count {
            let item = self.itemsInCart[idx] as! [String:AnyObject]
            
            let upc = item["upc"] as! String
            let desc = item["description"] as! String
            let price = item["price"] as! Int
            
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
            
            // 360 Event
            BaseController.sendAnalyticsProductToList(upc, desc: desc, price: "\(price)")
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

        for idx in 0 ..< self.itemsInCart.count {
            let item = self.itemsInCart[idx] as! [String:AnyObject]
            
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
            
            // 360 Event
            BaseController.sendAnalyticsProductToList(detail!.upc, desc: detail!.desc, price: "\(detail!.price)")
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
    
    func listSelectorDidDeleteProductLocally(product:Product, inList list:List) {
    }

    func listSelectorDidDeleteProduct(inList listId:String) {
    }
    
    func listSelectorDidShowList(listId: String, andName name:String) {
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? UserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func listSelectorDidShowListLocally(list: List) {
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? UserListDetailViewController {
            vc.listEntity = list
            vc.listName = list.name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }

    func shouldDelegateListCreation() -> Bool {
        return true
    }
    
    func listSelectorDidCreateList(name:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRSaveUserListService()
        
        var products: [AnyObject] = []
        for idx in 0 ..< self.itemsInCart.count {
            let item = self.itemsInCart[idx] as! [String:AnyObject]
            
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

            let serviceItem = service.buildProductObject(upc: upc, quantity: quantity, image: imgUrl!, description: description!, price: price!, type: type)
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
    
    func addViewload(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.whiteColor()
            viewLoad.startAnnimating(false)
            self.view.addSubview(viewLoad)
        }
    }
    
    func removeViewLoad(){
        if self.viewLoad != nil {
            self.viewLoad.stopAnnimating()
            self.viewLoad = nil
        }
    }


}