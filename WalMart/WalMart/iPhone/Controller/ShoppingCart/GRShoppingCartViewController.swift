//
//  GRShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/21/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//
import FBSDKCoreKit
import Foundation
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

class GRShoppingCartViewController : BaseController, UITableViewDelegate, UITableViewDataSource,UIViewControllerTransitioningDelegate, GRProductShoppingCartTableViewCellDelegate, SWTableViewCellDelegate, ListSelectorDelegate {

    var onClose: ((_ isClose:Bool) -> Void)? = nil
    var viewLoad: WMLoadingView!
    var viewHeader: UIView!
    var titleView: UILabel!
    var closeButton: UIButton!
    var itemsInCart: [[String:Any]] = []
    var tableShoppingCart: UITableView!
    var viewFooter: UIView!
    var buttonShop: UIButton!
    var selectQuantityGR : GRShoppingCartQuantitySelectorView!
    var listSelectorController: ListsSelectorViewController?
    var alertView: IPOWMAlertViewController?
    
    var addToListButton: UIButton?
    var editButton: UIButton!
    var deleteAll: UIButton!
    
    var customlabel : CurrencyCustomLabel!
    var isEdditing = false
    var showCloseButton: Bool = true
    var emptyView: IPOShoppingCartEmptyView!
    var totalShop: Double = 0.0
    var preview: PreviewModalView? = nil
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(GRShoppingCartViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = WMColor.yellow
        return refreshControl
    }()
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRSHOPPINGCART.rawValue
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 46))
        viewHeader.backgroundColor = WMColor.light_light_gray
        
        titleView = UILabel(frame: viewHeader.bounds)
        titleView.font = WMFont.fontMyriadProRegularOfSize(14)
        titleView.textColor = WMColor.light_blue
        titleView.text = NSLocalizedString("shoppingcart.title",comment:"")
        titleView.textAlignment = .center
        
        closeButton = UIButton(frame:CGRect(x: 0, y: 0, width: viewHeader.frame.height, height: viewHeader.frame.height))
        closeButton.setImage(UIImage(named: "BackProduct"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(GRShoppingCartViewController.closeShoppingCart), for: UIControlEvents.touchUpInside)
        
        viewHeader.addSubview(closeButton)
        viewHeader.addSubview(titleView)
        
        tableShoppingCart = UITableView(frame: self.view.bounds)
        tableShoppingCart.delegate = self
        tableShoppingCart.dataSource = self
        tableShoppingCart.register(GRProductShoppingCartTableViewCell.self, forCellReuseIdentifier: "productCell")
        tableShoppingCart.register(GRShoppingCartTotalsTableViewCell.self, forCellReuseIdentifier: "totals")
        tableShoppingCart.separatorStyle = UITableViewCellSeparatorStyle.none

        tableShoppingCart.clipsToBounds = false

        view.addSubview(tableShoppingCart)
        view.addSubview(viewHeader)
        
        viewFooter = UIView(frame: CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width - 72 - 44, height: 72))
        viewFooter.backgroundColor = UIColor.white
        viewFooter.alpha = 0
        
        let viewBorderTop = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        viewBorderTop.backgroundColor = WMColor.light_light_gray
        
        addToListButton = UIButton(frame: CGRect(x: 8 ,y: 0, width: 50, height: viewFooter.frame.height))
        addToListButton!.setImage(UIImage(named: "detail_list"), for: UIControlState())
        addToListButton!.setImage(UIImage(named: "detail_list_selected"), for: .selected)
        addToListButton!.addTarget(self, action: #selector(GRShoppingCartViewController.addCartToList), for: .touchUpInside)
        
        let buttonShare = UIButton(frame: CGRect(x: self.addToListButton!.frame.maxX, y: 0, width: 50, height: viewFooter.frame.height))
        buttonShare.setImage(UIImage(named: "detail_shareOff"), for: UIControlState())
        buttonShare.addTarget(self, action: #selector(GRShoppingCartViewController.shareShoppingCart), for: UIControlEvents.touchUpInside)
        
        buttonShop = UIButton(frame: CGRect(x: buttonShare.frame.maxX + 8, y: (viewFooter.frame.height / 2) - 17, width: self.view.frame.width - buttonShare.frame.maxX - 24, height: 34))
        buttonShop.backgroundColor = WMColor.green
        buttonShop.layer.cornerRadius = 17
        buttonShop.addTarget(self, action: #selector(GRShoppingCartViewController.showshoppingcart), for: UIControlEvents.touchUpInside)
        buttonShop.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        
        viewFooter.addSubview(self.addToListButton!)
        viewFooter.addSubview(buttonShare)
        viewFooter.addSubview(buttonShop)
        viewFooter.addSubview(viewBorderTop)
        view.addSubview(viewFooter)
        
        //Edit 
        editButton = UIButton(frame:CGRect(x: self.view.frame.width - 71, y: 12, width: 55, height: 22))
        editButton.setTitle(NSLocalizedString("shoppingcart.edit",comment:""), for: UIControlState())
        editButton.setTitle(NSLocalizedString("shoppingcart.endedit",comment:""), for: UIControlState.selected)
        editButton.backgroundColor = WMColor.light_blue
        editButton.setTitleColor(UIColor.white, for: UIControlState())
        editButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        editButton.layer.cornerRadius = 11
        editButton.addTarget(self, action: #selector(GRShoppingCartViewController.editAction(_:)), for: UIControlEvents.touchUpInside)
        editButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
        
        deleteAll = UIButton(frame: CGRect(x: editButton.frame.minX - 80, y: 12, width: 75, height: 22))
        deleteAll.setTitle(NSLocalizedString("wishlist.deleteall",comment:""), for: UIControlState())
        deleteAll.backgroundColor = WMColor.red
        deleteAll.setTitleColor(UIColor.white, for: UIControlState())
        deleteAll.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        deleteAll.layer.cornerRadius = 11
        deleteAll.alpha = 0
        deleteAll.titleEdgeInsets = UIEdgeInsetsMake(2.0, 2.0, 0.0, 0.0)
        deleteAll.addTarget(self, action: #selector(GRShoppingCartViewController.deleteAllProducts), for: UIControlEvents.touchUpInside)
        
        viewHeader.addSubview(editButton)
        viewHeader.addSubview(deleteAll)
        
        initEmptyView()
        BaseController.setOpenScreenTagManager(titleScreen: "Carrito", screenName: self.getScreenGAIName())
        
        //The 'view' argument should be the view receiving the 3D Touch.
        if #available(iOS 9.0, *), self.is3DTouchAvailable(){
            registerForPreviewing(with: self, sourceView: tableShoppingCart!)
        }else if !IS_IPAD{
            addLongTouch(view:tableShoppingCart!)
        }
        
       self.tableShoppingCart?.addSubview(self.refreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.removeViewLoad()
        
        loadGRShoppingCart()
        
        self.emptyView!.isHidden = self.itemsInCart.count > 0
        self.editButton.isHidden = self.itemsInCart.count == 0
        
 //       self.emptyView!.isHidden = false
   //     self.editButton!.isHidden = true
        if !showCloseButton {
            self.closeButton.isHidden = true
        } else {
            self.closeButton.isHidden = false
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableShoppingCart.frame = CGRect(x: 0, y: self.viewHeader.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.viewHeader.frame.height - 72 - 44)
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(GRShoppingCartViewController.reloadGRShoppingCart), name: NSNotification.Name(rawValue: CustomBarNotification.SuccessAddItemsToShopingCart.rawValue), object: nil)
        
        if viewFooter.alpha == 0 {
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.viewFooter.alpha = 1
            })
            
            viewFooter.frame = CGRect(x: 0, y: self.view.bounds.height - 72 - 59 , width: self.view.bounds.width, height: 72)
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func initEmptyView(){
        var heightEmptyView = self.view.frame.maxY - viewHeader.frame.height
        if !IS_IPAD && !IS_IPAD_MINI{
            heightEmptyView -= 60
        }
        else {
            heightEmptyView -= 25
        }
        
        self.emptyView = IPOShoppingCartEmptyView(frame:CGRect.zero)
        self.emptyView.frame = CGRect(x: 0,  y: viewHeader.frame.maxY,  width: self.view.frame.width,  height: heightEmptyView)
        self.emptyView.returnAction = {() in
            self.closeShoppingCart()
        }
        
        view.addSubview(emptyView)
        
        self.emptyView.bgImageView.image = UIImage(named:"empty_cart")
    }
    
    func closeShoppingCart() {
        self.navigationController!.popToRootViewController(animated: true)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_BACK_PRE_SHOPPING_CART.rawValue, label: "")
    }
    
    func reloadGRShoppingCart(){
        UserCurrentSession.sharedInstance.loadGRShoppingCart { () -> Void in
            self.loadGRShoppingCart()
        }
    }
    
    func loadGRShoppingCart() {
        if UserCurrentSession.sharedInstance.itemsGR != nil {
            self.itemsInCart = UserCurrentSession.sharedInstance.itemsGR!["items"] as! [[String:Any]]
            self.tableShoppingCart.reloadData()
            self.updateShopButton("\(UserCurrentSession.sharedInstance.estimateTotalGR() -  UserCurrentSession.sharedInstance.estimateSavingGR())")
        }
    }
    
    
    //MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsInCart.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == itemsInCart.count {
            let tblTotalCell = tableShoppingCart.dequeueReusableCell(withIdentifier: "totals", for: indexPath) as! GRShoppingCartTotalsTableViewCell
            let subtotal = UserCurrentSession.sharedInstance.estimateTotalGR()
            let saving = UserCurrentSession.sharedInstance.estimateSavingGR()
            
            tblTotalCell.setValuesWithSubtotal("\(subtotal)", iva: "", total: "\(subtotal - saving)", totalSaving: "\(saving)", numProds:"\(UserCurrentSession.sharedInstance.numberOfArticlesGR())")
            
            return tblTotalCell
        }
        
        let tblShoppingCell = tableShoppingCart.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! GRProductShoppingCartTableViewCell
        
        tblShoppingCell.selectionStyle = UITableViewCellSelectionStyle.none
        tblShoppingCell.rightUtilityButtons = getRightButton()
        tblShoppingCell.setLeftUtilityButtons(getLeftDelete(), withButtonWidth: 36.0)
        
        let itemProduct = itemsInCart[indexPath.row] 
        
        let upc = itemProduct["upc"] as! String
        
        var quantity: Int = 0
        if let qIntProd = itemProduct["quantity"] as? Int {
            quantity = qIntProd
        }
        
        if let qIntProd = itemProduct["quantity"] as? NSString {
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
        if let savingProd = itemProduct["promoDescription"] as? String {
            saving = savingProd
        }
        
        let description = itemProduct["description"] as! String
        
        let priceStr = "\(price)"
        var typeProdVal : Int = 0
        
        if let typeProd = itemProduct["type"] as? NSString {
            typeProdVal = typeProd.integerValue
        }
        
        var equivalenceByPiece = NSNumber(value: 0 as Int32)
        if let equivalence = itemProduct["equivalenceByPiece"] as? NSNumber {
            equivalenceByPiece = equivalence
        }
        
        if let equivalence = itemProduct["equivalenceByPiece"] as? NSString {
            if equivalence != "" {
                equivalenceByPiece =  NSNumber(value: equivalence.intValue as Int32)
            }
        }

        let comments = itemProduct["comments"] as? String
        
        var orderByPiece = false
        if let orderPiece = itemProduct["baseUomcd"] as? String {
            orderByPiece = (orderPiece == "EA")
        }
        
        var totalPieces = 0
        if orderByPiece {
            if let pieces = itemProduct["quantity"] as? Int {
                totalPieces = pieces
            }
            if let pieces = itemProduct["quantity"] as? NSString {
                totalPieces = pieces.integerValue
            }
        }

        tblShoppingCell.delegateQuantity = self
        tblShoppingCell.delegate = self
        
        if typeProdVal != 1 {
            tblShoppingCell.setValues(upc, productImageURL: imgUrl, productShortDescription: description, productPrice: priceStr as NSString, saving: saving as NSString, quantity: quantity, onHandInventory: "99",typeProd:typeProdVal, comments:comments == nil ? "" : comments! as NSString,equivalenceByPiece:equivalenceByPiece, orderByPiece: orderByPiece, pieces: totalPieces)
        } else {
            tblShoppingCell.setValues(upc, productImageURL: imgUrl, productShortDescription: description, productPrice: priceStr as NSString, saving: saving as NSString, quantity: quantity, onHandInventory: "20000",typeProd:typeProdVal, comments:comments == nil ? "" : comments! as NSString,equivalenceByPiece:equivalenceByPiece, orderByPiece: orderByPiece, pieces: totalPieces)
        }
        
        if isEdditing == true {
            tblShoppingCell.setEditing(true, animated: false)
            tblShoppingCell.showLeftUtilityButtons(animated: false)
        } else {
            tblShoppingCell.setEditing(false, animated: false)
            tblShoppingCell.hideUtilityButtons(animated: true)
        }

        return tblShoppingCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == itemsInCart.count {
            return 80
        }
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemsInCart.count > indexPath.row   {
            
            let controller = self.getProductDetailController(indexPath: indexPath)
            if self.navigationController  != nil {
                self.navigationController!.pushViewController(controller!, animated: true)
            }
            
        }
    }
    
    func getProductDetailController(indexPath:IndexPath) -> ProductDetailPageViewController? {
    
        if itemsInCart.count > indexPath.row   {
            let controller = ProductDetailPageViewController()
            controller.itemsToShow = getUPCItems() as [Any]
            controller.ixSelected = indexPath.row
            controller.detailOf = "Shopping Cart"
        
            return controller
        }
        
        return nil
    }
    
    func showshoppingcart() {
        
        self.buttonShop!.isEnabled = false
        
        if UserCurrentSession.sharedInstance.userSigned != nil {
            self.addViewload()
            //FACEBOOKLOG
            FBSDKAppEvents.logPurchase(self.totalShop, currency: "MXN", parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "productgr",FBSDKAppEventParameterNameContentID:self.getUPCItemsString()])
            UserCurrentSession.sharedInstance.loadGRShoppingCart { () -> Void in
                self.buttonShop!.isEnabled = true
                self.performSegue(withIdentifier: "checkoutVC", sender: self)
            }
        } else {
            
            let cont = LoginController.showLogin()
            self.buttonShop!.isEnabled = true
            cont!.closeAlertOnSuccess = false
            cont!.successCallBack = {() in
                
                UserCurrentSession.sharedInstance.loadGRShoppingCart { () -> Void in
                    
                    self.loadGRShoppingCart()
                    
                    if self.itemsInCart.count == 0 {
                        
                        if IS_IPAD {
                            self.navigationController!.popViewController(animated: true)
                            self.onClose?(true)
                        }
                       
                        let _ = self.navigationController?.popToRootViewController(animated: true)
                        self.removeViewLoad()
                        
                    } else {
                        self.performSegue(withIdentifier: "checkoutVC", sender: self)
                    }
                    
                    cont?.closeAlert(true, messageSucesss: true)
                    self.buttonShop!.isEnabled = true
                    
                }
            }
        }
    }
    
    func userShouldChangeQuantity(_ cell: GRProductShoppingCartTableViewCell) {
        
        if self.isEdditing == false {
            
            let frameDetail = CGRect(x: 0,y: 0, width: self.view.frame.width,height: self.view.frame.height)
            
            if cell.typeProd == 1 {
                selectQuantityGR = GRShoppingCartWeightSelectorView(frame:frameDetail,priceProduct:NSNumber(value: cell.price.doubleValue as Double),quantity:cell.quantity!,equivalenceByPiece:cell.equivalenceByPiece,upcProduct:cell.upc, isSearchProductView: false)
            } else {
                selectQuantityGR = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(value: cell.price.doubleValue as Double),quantity:cell.quantity,upcProduct:cell.upc)
            }
            
            if cell.orderByPieces {
                selectQuantityGR?.validateOrderByPiece(orderByPiece: cell.orderByPieces, quantity: Double(cell.quantity), pieces: cell.pieces)
            } else {
                selectQuantityGR?.userSelectValue(String(cell.quantity))
                selectQuantityGR?.first = true
            }
            
            selectQuantityGR?.addToCartAction = { (quantity:String) in
                if quantity ==  "00"{
                    self.selectQuantityGR?.closeAction()
                    self.deleteRowAtIndexPath(self.tableShoppingCart.indexPath(for: cell)!)
                    return
                }
                
                if quantity ==  "00"{
                    self.selectQuantityGR?.closeAction()
                    self.deleteRowAtIndexPath(self.tableShoppingCart.indexPath(for: cell)!)
                    return
                }

                
                if cell.onHandInventory.integerValue >= Int(quantity) {
                    self.selectQuantityGR?.closeAction()
                    
                    cell.orderByPieces = self.selectQuantityGR!.orderByPiece
                    cell.pieces = Int(quantity)!
                    let params = self.buildParamsUpdateShoppingCart(cell, quantity: quantity)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
                    
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
                    let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
                    let frame = vc!.view.frame
                    let addShopping = ShoppingCartUpdateController()
                    let paramsToSC = self.buildParamsUpdateShoppingCart(cell,quantity: "\(cell.quantity!)")
                    addShopping.params = paramsToSC
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

            selectQuantityGR?.userSelectValue(String(cell.quantity!))
            selectQuantityGR?.first = true
//            if cell.comments.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
//                selectQuantityGR.setTitleCompleteButton(NSLocalizedString("shoppingcart.updateNote",comment:""))
//            }else {
//                selectQuantityGR.setTitleCompleteButton(NSLocalizedString("shoppingcart.addNote",comment:""))
//            }
//            selectQuantityGR?.showNoteButtonComplete()
            selectQuantityGR?.closeAction = { () in
                self.selectQuantityGR.removeFromSuperview()
            }
            
            delay(0.2, completion: {
                self.view.addSubview(self.selectQuantityGR)
            })
            
            
        } else {
            let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
            let frame = vc!.view.frame
            let addShopping = ShoppingCartUpdateController()
            let params = self.buildParamsUpdateShoppingCart(cell,quantity: "\(cell.quantity!)")
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
        
    }
    
    func buildParamsUpdateShoppingCart(_ cell: GRProductShoppingCartTableViewCell,quantity:String) -> [String:Any] {
        let pesable = cell.pesable ? "1" : "0"
        return ["upc":cell.upc, "desc":cell.desc, "imgUrl": cell.imageurl, "price": cell.price, "quantity": quantity, "comments": cell.comments, "onHandInventory": cell.onHandInventory, "wishlist":false, "type":ResultObjectType.Groceries.rawValue, "pesable": pesable, "orderByPieces": cell.orderByPieces, "pieces": cell.pieces,"baseUomcd":cell.orderByPieces ? "EA" : "GM"]
    }
    
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
    
    
    //MARK : Edit shopping cart
    
    func editAction(_ sender:AnyObject) {
        
        isEdditing = !isEdditing
        
        if (isEdditing) {
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_EDIT_CART.rawValue, label: "")
            
            let currentCells = self.tableShoppingCart.visibleCells
            for cell in currentCells {
                if cell.isKind(of: SWTableViewCell.self) {
                    if let cellSW = cell as? GRProductShoppingCartTableViewCell {
                        cellSW.setEditing(true, animated: false)
                        cellSW.showLeftUtilityButtons(animated: true)
                    }
                }
            }
            
            editButton.isSelected = true
            editButton.backgroundColor = WMColor.green
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.deleteAll.alpha = 1
                self.titleView.frame = CGRect(x: self.titleView.frame.minX - 30, y: self.titleView.frame.minY, width: self.titleView.frame.width, height: self.titleView.frame.height)
            })
            
        } else {
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_CANCEL.rawValue, label: "")
            
            let currentCells = self.tableShoppingCart.visibleCells
            for cell in currentCells {
                if cell.isKind(of: SWTableViewCell.self) {
                    if let cellSW = cell as? GRProductShoppingCartTableViewCell {
                        cellSW.setEditing(false, animated: false)
                        cellSW.hideUtilityButtons(animated: false)
                        cellSW.rightUtilityButtons = getRightButton()
                    }
                }
            }
            
            editButton.isSelected = false
            editButton.backgroundColor = WMColor.light_blue
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.deleteAll.alpha = 0
                self.titleView.frame = CGRect(x: self.titleView.frame.minX + 30, y: self.titleView.frame.minY, width: self.titleView.frame.width, height: self.titleView.frame.height)
            })
            
        }

    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        switch index {
        case 0:
           
            let indexPath = self.tableShoppingCart.indexPath(for: cell)
            if self.isEdditing {
                if indexPath != nil {
                    deleteRowAtIndexPath(indexPath!)
                   // self.
                }
            } else {
                if let cellSC = cell as? GRProductShoppingCartTableViewCell {
                    
                    let vc: UIViewController? = UIApplication.shared.keyWindow!.rootViewController
                    let frame = vc!.view.frame
                    let addShopping = ShoppingCartUpdateController()
                    let params = self.buildParamsUpdateShoppingCart(cellSC,quantity: "\(cellSC.quantity!)")
                    
                    addShopping.params = params
                    vc!.addChildViewController(addShopping)
                    addShopping.view.frame = frame
                    vc!.view.addSubview(addShopping.view)
                    addShopping.didMove(toParentViewController: vc!)
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
            let indexPath = self.tableShoppingCart.indexPath(for: cell)
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
            cell.rightUtilityButtons = getRightButtonOnlyDelete()
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
        //    return !isEdditing
        }
    }
    
    func getRightButton() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        let buttonNote = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 109))
        buttonNote.setTitle(NSLocalizedString("shoppingcart.note",comment:""), for: UIControlState())
        buttonNote.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonNote.backgroundColor = WMColor.light_blue
        toReturn.append(buttonNote)
        
        let buttonDelete = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 109))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), for: UIControlState())
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    func getRightButtonOnlyDelete() -> [UIButton] {
        var toReturn : [UIButton] = []

        let buttonDelete = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 109))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), for: UIControlState())
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    func getLeftDelete() -> [UIButton] {
        var toReturn : [UIButton] = []
        let buttonDelete = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 109))
        buttonDelete.setImage(UIImage(named:"myList_delete"), for: UIControlState())
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
            upcItems.append("'\(upc)',")
        }
        upcItems.append("]")
        return upcItems
    }

    
    //MARK: Delete item 
    
    func deleteRowAtIndexPath(_ indexPath : IndexPath){
        
        let itemGRSC = itemsInCart[indexPath.row]
        let upc = itemGRSC["upc"] as! String
        let serviceWishDelete = GRShoppingCartDeleteProductsService()
        let allUPCS: [String] = [upc]
        addViewload()
        
        BaseController.sendAnalyticsAddOrRemovetoCart([itemGRSC], isAdd: false)
        
        serviceWishDelete.callService(allUPCS, successBlock: { (result:[String:Any]) -> Void in
            
            self.itemsInCart.remove(at: indexPath.row)
            self.removeViewLoad()
            if self.itemsInCart.count == 0 {
                _ = self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.tableShoppingCart.reloadData()
                self.updateShopButton("\(UserCurrentSession.sharedInstance.estimateTotalGR() - UserCurrentSession.sharedInstance.estimateSavingGR())")
            }
            
        }, errorBlock: { (error:NSError) -> Void in
            self.removeViewLoad()
            print("error")
        })
        
    }
    
    func retrieveParam(_ entityName : String, sortBy:String? = nil, isAscending:Bool = true, predicate:NSPredicate? = nil) -> AnyObject{
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        fetchRequest.predicate = predicate
        
        var error: NSError? = nil
        var fetchedResult: [Any]?
        do {
            fetchedResult = try context.fetch(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult! as AnyObject
        
    }
    
    func deleteAllProducts() {
        
        var predicate = NSPredicate(format: "user == nil AND status != %@ AND type == %@",NSNumber(value: WishlistStatus.deleted.rawValue as Int),ResultObjectType.Groceries.rawValue)
        
        if UserCurrentSession.hasLoggedUser() {
            predicate = NSPredicate(format: "user == %@ AND status != %@ AND type == %@", UserCurrentSession.sharedInstance.userSigned!,NSNumber(value: CartStatus.deleted.rawValue as Int),ResultObjectType.Groceries.rawValue)
        }
        
        var arrayUPCQuantity: [[String:String]] = []
        var arrayDeleteItems: [[String:Any]] = []
        let array  =  self.retrieveParam("Cart",sortBy:nil,isAscending:true,predicate:predicate) as! [Cart]
        let service = GRProductsByUPCService()
        
        for item in array {
            arrayUPCQuantity.append(service.buildParamService(item.product.upc, quantity: item.quantity.stringValue,baseUomcd:item.product.orderByPiece.boolValue ? "EA" : "GM" ))// send baseUomcd
            arrayDeleteItems.append(["desc":item.product.desc,"upc":item.product.upc,"quantity":"\(item.product.quantity)","pesable":false])
        }
        
        //360 delete
        BaseController.sendAnalyticsAddOrRemovetoCart(arrayDeleteItems, isAdd: false)
        
        let serviceWishDelete = GRShoppingCartDeleteProductsService()
        var allUPCS : [String] = []
        for itemWishlist in arrayUPCQuantity {
            print(itemWishlist)
            let upc = itemWishlist["upc"] 
           allUPCS.append("\(upc!)")
        }
        
        addViewload()
        
        serviceWishDelete.callService(allUPCS, successBlock: { (result:[String:Any]) -> Void in
            
            self.removeViewLoad()
            
            if self.onClose != nil {
                self.onClose?(true)
                let _ = self.navigationController?.popViewController(animated: true)
            } else {
                let _ = self.navigationController?.popToRootViewController(animated: true)
            }
            
        }, errorBlock: { (error: NSError) -> Void in
            print("error")
        })
        
        self.editAction(self.editButton)
    }
    
    
    //MARK: Share Shopping Cart
    
    func shareShoppingCart() {
        self.removeListSelector(action: nil)
        let imageHead = UIImage(named:"detail_HeaderMail")
        let imageHeader = UIImage(from: self.viewHeader)
        let screen = self.tableShoppingCart.screenshot()
        let imgResult = UIImage.verticalImage(from: [imageHead!,imageHeader!,screen!])
        let controller = UIActivityViewController(activityItems: [imgResult!], applicationActivities: nil)
        self.navigationController!.present(controller, animated: true, completion: nil)
        
        controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
            }
        }
    }
    
    
    //MARK: - Actions List Selector
    
    func addCartToList() {
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SHOPPING_CART_SUPER.rawValue, action: WMGAIUtils.ACTION_ADD_MY_LIST.rawValue, label: "")
        
        if self.listSelectorController == nil {
            self.addToListButton!.isSelected = true
            let frame = self.view.frame
            self.listSelectorController = ListsSelectorViewController()
            self.listSelectorController!.delegate = self
            
            //self.listSelectorController!.productUpc = self.upc
            self.addChildViewController(self.listSelectorController!)
            self.listSelectorController!.view.frame = CGRect(x: 0.0, y: frame.height, width: frame.width, height: frame.height)
            self.view.insertSubview(self.listSelectorController!.view, belowSubview: self.viewFooter!)
            self.listSelectorController!.titleLabel!.text = NSLocalizedString("gr.addtolist.super", comment: "")
            self.listSelectorController!.didMove(toParentViewController: self)
            self.listSelectorController!.view.clipsToBounds = true
            
            
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    self.listSelectorController!.view.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
                    //self.listSelectorController!.imageBlurView!.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
                },
                completion: { (finished:Bool) -> Void in
                    if finished {
                        let footerFrame = self.viewFooter!.frame
                        self.listSelectorController!.tableView!.contentInset = UIEdgeInsetsMake(0, 0, footerFrame.height, 0)
                        self.listSelectorController!.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, footerFrame.height, 0)
                    }
                }
            )
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.listSelectorController!.view.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
                //self.listSelectorController!.imageBlurView!.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            })
        }
        else {
            self.removeListSelector(action: nil)
        }
    }
    
    func removeListSelector(action:(()->Void)?) {
        if self.listSelectorController != nil {
            UIView.animate(withDuration: 0.5,
                delay: 0.0,
                options: .layoutSubviews,
                animations: { () -> Void in
                    let frame = self.view.frame
                    self.listSelectorController!.view.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: 0.0)
                    //self.listSelectorController!.imageBlurView!.frame = CGRect(x: 0, y: -frame.height, width: frame.width, height: frame.height)
                }, completion: { (complete:Bool) -> Void in
                    if complete {
                        if self.listSelectorController != nil {
                            self.listSelectorController!.willMove(toParentViewController: nil)
                            self.listSelectorController!.view.removeFromSuperview()
                            self.listSelectorController!.removeFromParentViewController()
                            self.listSelectorController = nil
                        }
                        self.addToListButton!.isSelected = false
                        
                        action?()
                    }
                }
            )
        }
    }
    
    
    //MARK: - ListSelectorDelegate
    
    func listIdSelectedListsLocally(idListSelected idListsSelected: [String]) {
        print("lista de id de listas")
    }
    
    func listSelectedListsLocally(listSelected listsSelected: [List]) {
        print("Listas Seleccionadas")
    }
    
    func listSelectorDidClose() {
        self.removeListSelector(action: nil)
    }
    
    internal func listSelectorDidAddProduct(inList listId: String) {
        listSelectorDidAddProduct(inList:listId,included:false)
    }
    
    func listSelectorDidAddProduct(inList listId:String, included: Bool) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRAddItemListService()
        var products: [Any] = []
        for idx in 0 ..< self.itemsInCart.count {
            let item = self.itemsInCart[idx] 
            
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
            
            var baseUomcd = "EA"
            if  let baseUomcdP = item["baseUomcd"] as? String {
                baseUomcd = baseUomcdP
            }
            
            products.append(service.buildProductObject(upc: upc, quantity: quantity,pesable:pesable,active:active,baseUomcd:baseUomcd) as AnyObject)//baseUomcd
            
            // 360 Event
            BaseController.sendAnalyticsProductToList(upc, desc: desc, price: "\(price)")
        }

        service.callService(service.buildParams(idList: listId, upcs: products),
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
    
    func listSelectorDidAddProductLocally(inList list:List,finishAdd:Bool) {
        
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        

        for idx in 0 ..< self.itemsInCart.count {
            let item = self.itemsInCart[idx] 
            
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
           
            
            
            var addInList = true
            for prod  in list.products {
                let myprod = prod as! Product
                
                if  myprod.upc == item["upc"] as! String {
                    addInList =  false
                    myprod.quantity =  NSNumber(value:Int(myprod.quantity) + quantity)
                    break
                }
            }
            
            if addInList {
                
                let detail = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as? Product
                detail!.upc = item["upc"] as! String
                detail!.desc = item["description"] as! String
                detail!.price = "\(price)" as NSString
                detail!.quantity = NSNumber(value: quantity as Int)
                detail!.type = NSNumber(value: typeProdVal as Int)
                detail!.list = list
                detail!.img = item["imageUrl"] as! String
                var equivalenceByPiece : NSNumber = 0
                if let equiva = item["equivalenceByPiece"] as? NSNumber {
                    equivalenceByPiece =  equiva
                }else if let equiva = item["equivalenceByPiece"] as? Int {
                    equivalenceByPiece =  NSNumber(value: equiva)
                }else if let equiva = item["equivalenceByPiece"] as? String {
                    equivalenceByPiece =   NSNumber(value:Int(equiva)!)
                }
                
                detail?.equivalenceByPiece =  equivalenceByPiece
                
                // 360 Event
                BaseController.sendAnalyticsProductToList(detail!.upc, desc: detail!.desc, price: "\(detail!.price)")
            }
            
           
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
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToListDone", comment:""))
        self.alertView!.showDoneIcon()
        self.alertView!.afterRemove = {
            self.removeListSelector(action: nil)
        }

    }
    
    func listSelectorDidDeleteProductLocally(_ product:Product, inList list:List) {
    }

    func listSelectorDidDeleteProduct(inList listId:String) {
    }
    
    func listSelectorDidShowList(_ listId: String, andName name:String) {
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? UserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func listSelectorDidShowListLocally(_ list: List) {
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? UserListDetailViewController {
            vc.listEntity = list
            vc.listName = list.name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }

    func shouldDelegateListCreation() -> Bool {
        return true
    }
    
    func listSelectorDidCreateList(_ name:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRSaveUserListService()
        
        var products: [Any] = []
        for idx in 0 ..< self.itemsInCart.count {
            let item = self.itemsInCart[idx] 
            
            let upc = item["upc"] as! String
            var quantity: Int = 0
            if  let qIntProd = item["quantity"] as? NSNumber {
                quantity = qIntProd.intValue
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
            let baseUomcd = item["baseUomcd"] as? String

            let serviceItem = service.buildProductObject(upc: upc, quantity: quantity, image: imgUrl!, description: description!, price: price!, type: type,baseUomcd:baseUomcd,equivalenceByPiece: 0)//baseUomcd and equivalenceByPiece
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
    
    func addViewload(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.white
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
    
    //MARK: RefreshControl
    func handleRefresh(refreshControl: UIRefreshControl) {
        UserCurrentSession.sharedInstance.loadGRShoppingCart { () -> Void in
            self.loadGRShoppingCart()
            print("Refresh")
            refreshControl.endRefreshing()
            
            if self.itemsInCart.count == 0 {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension GRShoppingCartViewController: UIViewControllerPreviewingDelegate {
    //registerForPreviewingWithDelegate
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableShoppingCart?.indexPathForRow(at: location) {
            //This will show the cell clearly and blur the rest of the screen for our peek.
            if #available(iOS 9.0, *) {
                previewingContext.sourceRect = tableShoppingCart!.rectForRow(at: indexPath)
            }
            return self.getProductDetailController(indexPath:indexPath)
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController!.pushViewController(viewControllerToCommit, animated: true)
        //present(viewControllerToCommit, animated: true, completion: nil)
    }
}

extension GRShoppingCartViewController: UIGestureRecognizerDelegate {
    
    func addLongTouch(view:UIView) {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(GRShoppingCartViewController.handleLongPress(gestureReconizer:)))
        longPressGesture.minimumPressDuration = 0.6 // 1 second press
        longPressGesture.allowableMovement = 15 // 15 points
        longPressGesture.delegate = self
        view.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        
        let p = gestureReconizer.location(in: self.tableShoppingCart)
        let indexPath = tableShoppingCart!.indexPathForRow(at: p)
        
        if let viewControllerToCommit = self.getProductDetailController(indexPath: indexPath!) {
            viewControllerToCommit.view.frame.size = CGSize(width: self.view.frame.width - 20, height: self.view.frame.height - 45)
            
            if self.preview == nil {
                let cellFrame =  tableShoppingCart!.rectForRow(at: indexPath!)
                let cellFrameInSuperview = tableShoppingCart!.convert(cellFrame, to: tableShoppingCart!.superview)
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
