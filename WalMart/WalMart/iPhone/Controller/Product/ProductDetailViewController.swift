//
//  ProductoDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//
import FBSDKCoreKit
import FBNotifications
import Foundation
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ProductDetailViewController : IPOBaseController,UIGestureRecognizerDelegate {

    @IBOutlet weak var detailCollectionView: UICollectionView!
    
    var viewLoad : WMLoadingView!
    var msi : [Any] = []
    var upc : NSString = ""
    var name : NSString = ""
    var detail : NSString = ""
    var saving : NSString = ""
    var price : NSString = ""
    var listPrice : NSString = ""
    var comments : NSString = ""
    var imageUrl : [Any] = []
    var characteristics : [[String:Any]] = []
    var bundleItems : [[String:Any]] = []
    var colorItems : [Any] = []
    var sizesItems : [Any] = []
    var freeShipping : Bool = false
    var isLoading : Bool = false
    var viewDetail : ProductDetailTextDetailView!
    var productDetailButton: ProductDetailButtonBarCollectionViewCell?
    var selectQuantity : ShoppingCartQuantitySelectorView? = nil
    var isShowProductDetail : Bool = false
    var isShowShoppingCart : Bool = false
    var isWishListProcess : Bool = false
    var isHideCrossSell : Bool = true
    var indexSelected  : Int = 0
    var addOrRemoveToWishListBlock : (() -> Void)? = nil
    var gestureCloseDetail : UITapGestureRecognizer!
    var itemsCrossSellUPC : [[String:Any]]! = []
    var isActive : Bool! = true
    var isPreorderable : Bool = false
    var onHandInventory : NSString = "0"
    var isGift: Bool = false
    var isLowStock : Bool = false
    
    var strisActive : String! = "true"
    var strisPreorderable : String! = "false"
    var stringSearching  = ""
    
    var titlelbl : UILabel!
    var isContainerHide : Bool = true
    var containerinfo : UIView!
    var heightDetail : CGFloat = 360
    var collectionHeight: CGFloat = 314
    var headerView : UIView!
    var buttonBk: UIButton!
    var currentHeaderView : UIView!
    var isPesable : Bool = false
    var type : ResultObjectType!
    var cellRelated : UICollectionViewCell? = nil
    var cellCharacteristics : UICollectionViewCell? = nil
    var cellProviders : UICollectionViewCell? = nil
    var facets: [[String:Any]]? = nil
    var facetsDetails: [String:Any]? = nil
    var selectedDetailItem: [String:String]? = nil
    
    var fromSearch =  false
    var idListFromlistFind = ""
    var productDeparment:String = ""
    
    var indexRowSelected : String = ""
    var completeDelete : (() -> Void)? = nil
    var detailOf: String! = ""
    var baseUomcd : String = ""
    
    var hasProvider: Bool = false
    var providerInfo: [String:Any]? = nil
    var providerArray: [[String:Any]]? = nil
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46))
        self.view.addSubview(viewLoad)
        
        viewLoad.startAnnimating(self.isVisibleTab)
        isLoading = true
        self.loadDataFromService()
        
        if #available(iOS 10.0, *) {
            detailCollectionView.isPrefetchingEnabled = false
        }
        
        detailCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        detailCollectionView.register(ProductDetailBannerCollectionViewCell.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage")
        detailCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emptyCell")
        detailCollectionView.register(ProductDetailMSICollectionViewCell.self, forCellWithReuseIdentifier: "msiCell")
        detailCollectionView.register(ProductDetailCharacteristicsCollectionViewCell.self, forCellWithReuseIdentifier: "cellCharacteristics")
        detailCollectionView.register(ProductDetailBundleCollectionViewCell.self, forCellWithReuseIdentifier: "cellBundleitems")
        detailCollectionView.register(ProductDetailCrossSellCollectionViewCell.self, forCellWithReuseIdentifier: "crossSellCell")
        detailCollectionView.register(ProductDetailProviderCollectionViewCell.self, forCellWithReuseIdentifier: "providersCell")
        
        self.setCollectionLayout()
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 46))
        headerView.backgroundColor = WMColor.light_light_gray
        self.buttonBk = UIButton(frame: CGRect(x: 0, y: 0, width: 46, height: 46))
        buttonBk.setImage(UIImage(named:"BackProduct"), for: UIControlState())
        buttonBk.addTarget(self, action: #selector(ProductDetailViewController.backButton), for: UIControlEvents.touchUpInside)
        headerView.addSubview(buttonBk)
        
        titlelbl = UILabel(frame: CGRect(x: 46, y: 0, width: self.view.frame.width - (46 * 2), height: 46))
        titlelbl.textAlignment = .center
        titlelbl.text = self.name as String
        titlelbl.numberOfLines = 2
        titlelbl.font = WMFont.fontMyriadProRegularOfSize(14)
        titlelbl.textColor = WMColor.light_blue
        titlelbl.adjustsFontSizeToFitWidth = true
        titlelbl.minimumScaleFactor = 9 / 12
        
        headerView.addSubview(titlelbl)
        self.view.addSubview(headerView)
        
        gestureCloseDetail = UITapGestureRecognizer(target: self, action: #selector(ProductDetailViewController.closeActionView))
        gestureCloseDetail.isEnabled = false
        
        self.containerinfo = UIView()
        self.containerinfo.clipsToBounds = true
        
        self.view.addSubview(containerinfo)
        BaseController.setOpenScreenTagManager(titleScreen: self.titlelbl.text!, screenName:self.getScreenGAIName() )
        NSLog("finish viewDidLoad", "")
        NotificationCenter.default.addObserver(self, selector: #selector(endUpdatingShoppingCart(_:)), name: .successUpdateItemsInShoppingCart, object: nil)
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewLoad.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
        self.detailCollectionView.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 90)
    }
    
    func setCollectionLayout() {
        if self.hasProvider {
            heightDetail = 360
            collectionHeight = 314
        }else{
            heightDetail = 420
            collectionHeight = 364
        }
        
        if let layout = detailCollectionView.collectionViewLayout as? CSStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSize(width: self.view.frame.size.width, height: collectionHeight)
            layout.parallaxHeaderMinimumReferenceSize = CGSize(width: self.view.frame.size.width, height: collectionHeight)
            layout.itemSize = CGSize(width: self.view.frame.size.width, height: layout.itemSize.height)
            layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 56.0)
            layout.disableStickyHeaders = false
        }
    }
    /**
     Close or show action view if is necesary
     */
    func closeActionView () {
        if isShowProductDetail {
            closeProductDetail()
        }
        if isShowShoppingCart {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.productDetailButton?.reloadShoppinhgButton()
                self.isShowShoppingCart = false
                self.selectQuantity!.frame = CGRect(x: 0, y: self.heightDetail, width: self.view.frame.width, height: 0)
                self.selectQuantity!.imageBlurView.frame = CGRect(x: 0, y: -self.heightDetail, width: self.view.frame.width, height: self.heightDetail)
            }, completion: { (animated: Bool) -> Void in
                if self.selectQuantity != nil {
                    self.selectQuantity!.removeFromSuperview()
                    self.selectQuantity = nil
                    self.detailCollectionView.isScrollEnabled = true
                    self.gestureCloseDetail.isEnabled = false
                }
            })
        }
    }
    
    /**
     Return to the last viewController
     */
    func backButton (){
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func deleteFromCart() {
        
        //Add Alert
        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"remove_cart"), imageDone:UIImage(named:"done"),imageError:UIImage(named:"preCart_mg_icon"))
        alertView?.setMessage(NSLocalizedString("shoppingcart.deleteProductAlert", comment:""))
        self.selectQuantity!.closeAction()
        self.selectQuantity = nil
        
        
        let itemToDelete = self.buildParamsUpdateShoppingCart("0",orderByPiece: false, pieces: 0,equivalenceByPiece:0 )
        if !UserCurrentSession.hasLoggedUser() {
            BaseController.sendAnalyticsAddOrRemovetoCart([itemToDelete], isAdd: false)
        }
        let upc = itemToDelete["upc"] as! String
        let deleteShoppingCartService = ShoppingCartDeleteProductsService()
        deleteShoppingCartService.callCoreDataService(upc, successBlock: { (response) in
            UserCurrentSession.sharedInstance.loadMGShoppingCart {
                UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
                alertView?.setMessage(NSLocalizedString("shoppingcart.deleteProductDone", comment:""))
                alertView?.showDoneIcon()
                alertView?.afterRemove = {
                    self.productDetailButton?.reloadShoppinhgButton()
                }
            }
        }) { (error) in
            print("delete pressed Errro \(error)")
        }
        
        
    }
    
    //MARK: Shopping cart
    /**
     Builds an [String:Any] with data to add product to shopping cart
     
     - parameter quantity: quantity of product
     
     - returns: [String:Any]
     */
    func buildParamsUpdateShoppingCart(_ quantity:String, orderByPiece: Bool, pieces: Int,equivalenceByPiece:Int) -> [String: Any] {
        var imageUrlSend = ""
        if self.imageUrl.count > 0 {
            imageUrlSend = self.imageUrl[0] as! NSString as String
        }
        let pesable = isPesable ? "1" : "0"

        var params: [String: Any] = ["upc":self.upc,"desc":self.name,"imgUrl":imageUrlSend,"price":self.price,"quantity":quantity,"onHandInventory":self.onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":self.strisPreorderable,"category":self.productDeparment,"equivalenceByPiece":equivalenceByPiece]
        
        if self.providerInfo != nil {
            params["sellerId"] = self.providerInfo!["sellerId"]
            params["offerId"] = self.providerInfo!["offerId"]
            params["sellerName"] = self.providerInfo!["name"]
        }
        
        return params
    }
    
    func closeContainerDetail(completeClose: ((Void) -> Void)?, isPush: Bool){
        if selectQuantity != nil {
            
            gestureCloseDetail.isEnabled = false
            self.detailCollectionView.isScrollEnabled = true
            self.closeContainer({ () -> Void in
                self.selectQuantity?.frame = CGRect(x: 0, y: self.heightDetail, width: self.view.frame.width, height: 0)
            }, completeClose: { () -> Void in
                
                self.isShowShoppingCart = false
                
                UserCurrentSession.sharedInstance.loadMGShoppingCart { () -> Void in
                    self.productDetailButton?.reloadShoppinhgButton()
                }
                if self.selectQuantity != nil {
                    self.selectQuantity!.removeFromSuperview()
                    self.selectQuantity = nil
                }
                
                completeClose?()
            })
            
        } else {
            UserCurrentSession.sharedInstance.loadMGShoppingCart
                { () -> Void in
                    self.productDetailButton?.reloadShoppinhgButton()
            }
        }
        
    }
    
    //MARK: scrollViewDelegate
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
       
        if isShowProductDetail == true &&  isShowShoppingCart == false{
            if viewDetail == nil {
                startAnimatingProductDetail()
            } else {
                closeProductDetail()
            }
        }
        
        if isShowShoppingCart == true && isShowProductDetail == false{
            if selectQuantity != nil {
                
                let finalFrameOfQuantity = CGRect(x: 0, y: 0, width: self.view.frame.width, height: heightDetail)

                selectQuantity!.clipsToBounds = true
                self.view.addSubview(selectQuantity!)
                self.detailCollectionView.isScrollEnabled = false
                gestureCloseDetail.isEnabled = true
               
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.productDetailButton?.setOpenQuantitySelector()
                    self.selectQuantity!.frame = finalFrameOfQuantity
                    self.selectQuantity!.imageBlurView.frame = finalFrameOfQuantity
                }, completion: { (complete:Bool) -> Void in
                    self.productDetailButton?.addToShoppingCartButton.setTitleColor(WMColor.light_blue, for: UIControlState())
                })
            }
        }
        if  self.isWishListProcess  {
            if addOrRemoveToWishListBlock != nil {
                addOrRemoveToWishListBlock!()
            }
        }
    }
    
    /**
     Animates product detail view
     */
    func startAnimatingProductDetail() {
        let finalFrameOfQuantity = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.heightDetail)
        viewDetail = ProductDetailTextDetailView(frame: CGRect(x: 0,y: self.heightDetail, width: self.view.frame.width, height: 0))
        viewDetail!.generateBlurImage(self.view,frame:finalFrameOfQuantity)
        //self.viewDetail!.imageBlurView.frame =  CGRectMake(0, -self.heightDetail, 320, self.heightDetail)
        viewDetail.setTextDetail(detail as String)
        viewDetail.closeDetail = { () in
            self.isShowProductDetail = true
            self.closeProductDetail()
        }
        self.view.addSubview(viewDetail)
        
        self.productDetailButton?.reloadButton()
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.viewDetail!.frame = finalFrameOfQuantity
            self.viewDetail!.imageBlurView.frame = finalFrameOfQuantity
            //self.viewDetail.frame = CGRectMake(0, 0, self.tabledetail.frame.width, self.tabledetail.frame.height - 145)
            self.productDetailButton?.deltailButton.isSelected = true
        })
    }
    
    /**
     Close product detail view
     */
    func closeProductDetail () {
        if isShowProductDetail == true {
        isShowProductDetail = false
            gestureCloseDetail.isEnabled = false
        self.detailCollectionView.isScrollEnabled = true
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            
            self.viewDetail?.imageBlurView.frame =  CGRect(x: 0, y: -self.heightDetail, width: self.view.frame.width, height: self.heightDetail)
            self.viewDetail.frame = CGRect(x: 0,y: self.heightDetail, width: self.view.frame.width, height: 0)
            }, completion: { (ended:Bool) -> Void in
                if self.viewDetail != nil {
                self.viewDetail.removeFromSuperview()
                self.viewDetail = nil
                self.productDetailButton?.deltailButton.isSelected = false
                //self.productDetailButton?.reloadButton()
                }
        }) 
        }
    }
    
    /**
     Shows not aviable product message
     */
    func showMessageProductNotAviable() {
        self.detailCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.detailCollectionView.frame.width,  height: self.detailCollectionView.frame.height ), animated: false)
        let addedAlertNA = WishlistAddProductStatus(frame: CGRect(x: 0, y: self.heightDetail, width: self.view.frame.width, height: 0))
        addedAlertNA.generateBlurImage(self.view,frame:CGRect(x: 0, y: 312, width: self.view.frame.width, height: self.heightDetail))
        addedAlertNA.clipsToBounds = true
        addedAlertNA.imageBlurView.frame = CGRect(x: 0, y: -312, width: self.view.frame.width, height: self.heightDetail)
        addedAlertNA.textView.text = NSLocalizedString("productdetail.notaviable",comment:"")

        self.view.addSubview(addedAlertNA)
        self.isWishListProcess = false
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            addedAlertNA.frame = CGRect(x: 0, y: 312, width: self.view.frame.width, height: 48)
            addedAlertNA.prepareToClose()
        })

    }
    
    /**
     Gets product detail info from service
     */
    func loadDataFromService() {
        
         NSLog("loadDataFromService", "ProductDetailViewController")
        print("parametro para signals MG Iphone :::\(self.indexRowSelected)")
        
        self.type = ResultObjectType.Mg
        
            let signalsDictionary : [String:Any] = ["signals" : GRBaseService.getUseSignalServices()]
            let productService = ProductDetailService(dictionary: signalsDictionary)
            let eventType = self.fromSearch ? "clickdetails" : "pdpview"
            let params = productService.buildParams(upc as String,eventtype:eventType,stringSearching: self.stringSearching,position:self.indexRowSelected)
            productService.callService(requestParams:params, successBlock: { (result: [String:Any]) -> Void in
            
                if let offers = result["offers"] as? [[String:Any]] {
                    self.hasProvider = offers.count > 0
                    self.providerArray = offers
                    for offer in offers {
                        let offerId = offer["offerId"] as! NSString
                        if offerId == self.upc {
                            self.providerInfo = offer
                            break
                        }
                    }
                    if self.providerInfo == nil {
                      self.providerInfo =  offers.count > 0 ? offers.first! : [:]  
                    }
                    
                }
                self.setCollectionLayout()
                self.reloadViewWithData(result)
                
                if let facets = result["facets"] as? [[String:Any]] {
                    self.facets = facets
                    self.facetsDetails = self.getFacetsDetails()
                    let filteredKeys = self.getFilteredKeys(self.facetsDetails!)
                    if self.facetsDetails?.count > 1 {
                        if let colors = self.facetsDetails![filteredKeys.first!] as? [Any]{
                            self.colorItems = colors
                        }
                     }
                    if self.facetsDetails?.count > 2 {
                        if let sizes = self.facetsDetails![filteredKeys[1]] as? [Any]{
                            self.sizesItems = sizes
                        }
                    }
                   
                }
                
                //--Tag manager
                 let linea = result["linea"] as? String ?? ""
                 let isBundle = result["isBundle"] as? Bool ?? false
                // Remove "event": "ecommerce",
                BaseController.sendAnalyticsPush(["ecommerce":["detail":["actionField":["list": self.detailOf],"products":[["name": self.name,"id": self.upc,"price": self.price,"brand": "", "category": self.productDeparment,"variant": "pieza","dimension21": isBundle ? self.upc : "","dimension22": "","dimension23": linea,"dimension24": "","dimension25": ""]]]]])
                
            }) { (error:NSError) -> Void in
                    NSLog("ProductDetailService error : \(error.localizedDescription) ", "ProductDetailViewController")

                    let heightEmpty = self.view.bounds.height - 44 - 44
                    let empty = IPOGenericEmptyView(frame:CGRect(x: 0, y: 46, width: self.view.bounds.width, height: heightEmpty))
                    
                    self.name = NSLocalizedString("empty.productdetail.title",comment:"") as NSString
                    empty.isLarge = false
                    empty.returnAction = { () in
                        self.navigationController!.popViewController(animated: true)
                    }
                    self.view.addSubview(empty)
                    self.viewLoad.stopAnnimating()
            }
        
        
    }
    
    /**
     Reloads product detail view with a [String:Any]
     
     - parameter result: product detail data
     */
    func reloadViewWithData(_ result:[String:Any]){
        NSLog("reloadViewWithData init ", "ProductDetailViewController")
        self.name = result["description"] as! NSString
        self.price = result["price"] as! NSString
        self.detail = result["detail"] as! NSString
        self.saving = ""
        self.detail = self.detail.replacingOccurrences(of: "^", with: "\n") as NSString
        self.upc = result["upc"] as! NSString
        if let isGift = result["isGift"] as? Bool{
            self.isGift = isGift
        }
        
        if let savingResult = result["saving"] as? NSString {
            if savingResult != "" {
                let doubleVaule = NSString(string: savingResult).doubleValue
                if doubleVaule > 0 {
                    let savingStr = NSLocalizedString("price.saving",comment:"")
                    let formated = CurrencyCustomLabel.formatString("\(savingResult)" as NSString)
                    self.saving = "\(savingStr) \(formated)" as NSString
                }
            }
        }
        
        self.listPrice = result["original_listprice"] as! NSString
        self.characteristics = []
        if let cararray = result["characteristics"] as? [[String:Any]] {
            self.characteristics = cararray
        }
        
        var allCharacteristics : [[String:Any]] = []
        
        let strLabel = "UPC"
        //let strValue = self.upc
        
        allCharacteristics.append(["label":strLabel,"value":self.upc])
        
        for characteristic in self.characteristics  {
            allCharacteristics.append(characteristic)
        }
        self.characteristics = allCharacteristics
        
        if let msiResult =  result["msi"] as? NSString {
            if msiResult != "" {
                self.msi = msiResult.components(separatedBy: ",")
            }else{
                self.msi = []
            }
        }
        if let images = result["imageUrl"] as? [Any] {
            self.imageUrl = images
        }
        let freeShippingStr  = result["freeShippingItem"] as! NSString
        self.freeShipping = "true" == freeShippingStr
        
        var numOnHandInventory : NSString = "0"
        if let numberOf = result["onHandInventory"] as? NSString{
            numOnHandInventory  = numberOf
        }
        self.onHandInventory  = numOnHandInventory
        
        self.strisActive  = result["isActive"] as? String ?? "false"
        self.isActive = "true" == self.strisActive
        
        if self.isActive == true {
            self.isActive = self.price.doubleValue > 0
        }
        
        self.isPreorderable = "true" == self.strisPreorderable
        self.bundleItems = [[String:Any]]()
        if let bndl = result["bundleItems"] as?  [[String:Any]] {
            self.bundleItems = bndl
        }
        
        if let lowStock = result["lowStock"] as? Bool{
           self.isLowStock = lowStock
        }
        
        self.isLoading = false
        
        self.detailCollectionView.reloadData()
        
        self.viewLoad.stopAnnimating()
        //self.tabledetail.scrollEnabled = true
        //self.gestureCloseDetail.enabled = false
        if self.titlelbl != nil {
            self.titlelbl.text = self.name as String
        }
        
        if let category = result["category"] as? String{
            self.productDeparment = category
        }
        
        self.loadCrossSell()
        
        //NotificationCenter.default.post(name: .clearSearch, object: nil)
        
        //FACEBOOKLOG
        FBSDKAppEvents.logEvent(FBSDKAppEventNameViewedContent, valueToSum:self.price.doubleValue, parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "productmg",FBSDKAppEventParameterNameContentID:self.upc])
        
        // department,family,line
        let linea = result["linea"] as? String ?? ""
        BaseController.sendAnalyticsPush(["event":"interaccionFoto", "category" : self.productDeparment, "subCategory" :"", "subsubCategory" :linea])
        
        let isBundle = result["isBundle"] as? Bool ?? false
        if self.detailOf == "" {
            fatalError("detailOf not seted")
        }

        BaseController.sendAnalyticsPush(["event": "productClick","ecommerce":["click":["actionField":["list": self.detailOf],"products":[["name": self.name,"id": self.upc,"price": self.price,"brand": "", "category": self.productDeparment,"variant": "pieza","dimension21": isBundle ? self.upc : "","dimension22": "","dimension23": linea,"dimension24": "","dimension25": ""]]]]])

        //TODO Add timer time
        
       // BaseController.sendAnalyticsPush(["event": "ecommerce","ecommerce":["detail":["actionField":["list": self.detailOf],"products":[["name": self.name,"id": self.upc,"price": self.price,"brand": "", "category": self.productDeparment,"variant": "pieza","dimension21": isBundle ? self.upc : "","dimension22": "","dimension23": linea,"dimension24": "","dimension25": ""]]]]])
        
        //Validaciones MarketPLace
        if self.providerInfo != nil {
            self.onHandInventory = self.providerInfo!["onHandInventory"] as? NSString ?? "0"
            self.strisActive  =  self.onHandInventory != "0" ? "true" : "false"
            self.isActive = "true" == self.strisActive
            self.upc = self.providerInfo!["offerId"] as? NSString ?? self.upc
            self.strisPreorderable  = result["isPreorderable"] as? String ?? "false"
            self.price = providerInfo!["price"] as? NSString ?? self.price
            self.listPrice = ""
            self.saving = ""
        }
        
         NSLog("reloadViewWithData finish ", "ProductDetailViewController")
    }
    
    class func validateUpcPromotion(_ upc:String) -> Bool{
        NSLog("validateUpcPromotion::", "ProductDetailViewController")
        let upcs =  UserCurrentSession.sharedInstance.upcSearch
        return upcs!.contains(where: { return $0 == upc})
    }
    
    /**
     validate open Container info from product
     
     - parameter open:                     is open
     - parameter viewShow:                 view where present container
     - parameter additionalAnimationOpen:  animation open block
     - parameter additionalAnimationClose: anipation close block
     */
    func opencloseContainer(_ open:Bool,viewShow:UIView,additionalAnimationOpen: @escaping (() -> Void),additionalAnimationClose:(() -> Void)) {
        if isContainerHide && open {
            openContainer(viewShow, additionalAnimationOpen: additionalAnimationOpen)
        } else {
            
        }
        
    }
    
    /**
     Anumation where container info open
     
     - parameter viewShow:                view where present info
     - parameter additionalAnimationOpen: other animation block
     */
    func openContainer(_ viewShow:UIView,additionalAnimationOpen: @escaping (() -> Void)) {
         NSLog("openContainer::", "ProductDetailViewController")
        self.isContainerHide = false
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
             self.detailCollectionView.scrollRectToVisible(self.detailCollectionView.bounds, animated: false)
            }, completion: { (complete:Bool) -> Void in
                self.detailCollectionView.isScrollEnabled = false
                
                let finalFrameOfQuantity = CGRect(x: self.detailCollectionView.frame.minX, y: 0, width: self.detailCollectionView.frame.width, height: self.heightDetail)
                self.containerinfo.frame = CGRect(x: self.detailCollectionView.frame.minX, y: self.heightDetail, width: self.detailCollectionView.frame.width, height: 0)
                self.containerinfo.addSubview(viewShow)
                
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.containerinfo.frame = finalFrameOfQuantity
                    additionalAnimationOpen()
                })
                
        }) 
    }
    
    /**
     Animation where container info closed
     
     - parameter additionalAnimationClose: animationBlock
     - parameter completeClose:            complete block
     */
    func closeContainer(_ additionalAnimationClose: @escaping (() -> Void),completeClose: @escaping (() -> Void)) {
        self.productDetailButton!.isOpenQuantitySelector = false
        let finalFrameOfQuantity = CGRect(x: self.detailCollectionView.frame.minX,  y: heightDetail, width: self.detailCollectionView.frame.width, height: 0)
        UIView.animate(withDuration: 0.5,
            animations: { () -> Void in
                self.containerinfo.frame = finalFrameOfQuantity
                additionalAnimationClose()
            }, completion: { (comple:Bool) -> Void in
                self.isContainerHide = true
                self.isShowShoppingCart = false
                self.isShowProductDetail = false
                self.productDetailButton!.deltailButton.isSelected = false
                self.detailCollectionView.isScrollEnabled = true
                completeClose()
                for viewInCont in self.containerinfo.subviews {
                    viewInCont.removeFromSuperview()
                }
                self.selectQuantity = nil
                //self.viewDetail = nil
        }) 
    }
   
    /**
     Reloads shopping cart button
     
     - parameter sender: sender
     */
    func endUpdatingShoppingCart(_ sender:AnyObject) {
        self.productDetailButton?.reloadShoppinhgButton()
    }
}

    //MARK: - Collection view Data Source
extension ProductDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var inCountRows = 1
        if bundleItems.count != 0
        {
            inCountRows += 1
        }
        if msi.count != 0
        {
            inCountRows += 1
        }
        if !isHideCrossSell {
            inCountRows += 1
        }
        if hasProvider {
            inCountRows += 1
        }
        return inCountRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellEmpty = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath)
        cellEmpty.frame =  CGRect(x: 0, y: 0, width: 2, height: 2)
        var cell : UICollectionViewCell? = nil
        let point = (indexPath.section,indexPath.row)
        if isLoading {
            return cellEmpty
        }
        var rowChose = indexPath.row
        switch point {
        case (0,0) :
            if !hasProvider {rowChose += 1}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        case (0,1) :
            if !hasProvider {rowChose += 1}
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        case (0,2) :
            if !hasProvider {rowChose += 1}
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        case (0,3) :
            if !hasProvider {rowChose += 1}
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        case (0,4) :
            if !hasProvider {rowChose += 1}
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        default :
            cell = nil
        }
        
        if cell != nil {
            return cell!
        }
        return cellEmpty
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reusableView : UICollectionReusableView? = nil
        
        if kind == CSStickyHeaderParallaxHeader{
            let view = detailCollectionView.dequeueReusableSupplementaryView(ofKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage", for: indexPath) as! ProductDetailBannerCollectionViewCell
            if self.isPreorderable {
                view.imagePresale.isHidden = false
            }
            
            
            if self.isLowStock {
                view.lowStock?.isHidden = false
            }
            view.heightView = self.collectionHeight
            view.items = self.imageUrl
            view.delegate = self
            view.colors = self.colorItems
            view.sizes = self.sizesItems
            view.colorsViewDelegate = self
            view.hasProviders = self.hasProvider
            view.providerInfo = self.providerInfo
            view.providerView.offersCount = self.providerArray != nil ?  self.providerArray!.count : 0
            view.providerView?.delegate = self   
            view.collection.reloadData()
            
            view.setAdditionalValues(listPrice as String, price: price as String, saving: saving as String)
            view.activePromotions(ProductDetailViewController.validateUpcPromotion(self.upc as String))
            currentHeaderView = view
            return view
        }
        if kind == UICollectionElementKindSectionHeader {
            let view = detailCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
            
            productDetailButton = ProductDetailButtonBarCollectionViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 65.0))
            productDetailButton!.upc = self.upc as String
            productDetailButton!.desc = self.name as String
            productDetailButton!.price = self.price as String
            productDetailButton!.isPesable  = self.isPesable
            
            productDetailButton!.isActive = self.strisActive
            productDetailButton!.onHandInventory = self.onHandInventory as String
            productDetailButton!.isPreorderable = self.strisPreorderable
            productDetailButton!.listButton.isEnabled = !self.isGift
            
            productDetailButton!.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButton!.listButton.isSelected = UserCurrentSession.sharedInstance.userHasUPCWishlist(self.upc as String)
            var imageUrl = ""
            if self.imageUrl.count > 0 {
                imageUrl = self.imageUrl[0] as! NSString as String
            }
            productDetailButton!.image = imageUrl
            productDetailButton!.delegate = self
            
            for subView in view.subviews{
                subView.removeFromSuperview()
            }
            
            view.addSubview(productDetailButton!)
            
            return view
        }
        return reusableView!
    }
    
    /**
     Returns the size for indexPath
     
     - parameter point:     point
     - parameter indexPath: tableViewIndexPath
     
     - returns: CGFloat
     */
    func sizeForIndexPath (_ point:(Int,Int),indexPath: IndexPath!)  -> CGFloat {
        switch point {
        case (0,0) :
            if  hasProvider {
                return 180.0
            }
            return sizeForIndexPath ((indexPath.section,1),indexPath: indexPath)
        case (0,1) :
            if  bundleItems.count != 0 {
                return 170.0
            }
            return sizeForIndexPath ((indexPath.section,2),indexPath: indexPath)
        case (0,2):
            if  msi.count != 0 {
                return (CGFloat(msi.count) * 14) + 84.0
            }
            return sizeForIndexPath ((indexPath.section,3),indexPath: indexPath)
        case (0,3) :
            if characteristics.count != 0 {
                let size = ProductDetailCharacteristicsCollectionViewCell.sizeForCell(self.view.frame.width - 30,values:characteristics)
                return size + 50
            }
            return sizeForIndexPath ((indexPath.section,4),indexPath: indexPath)
        case (0,4) :
            return 210
        default :
            return 210
        }
    }

}

    //MARK: - UICollectionViewDelegate
extension ProductDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        var hForCell : CGFloat = 0.0
        let point = (indexPath.section,indexPath.row)
        var rowChose = indexPath.row
        switch point {
        case (0,0) :
            if !hasProvider {rowChose += 1}
            hForCell = sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        case (0,1) :
            if !hasProvider {rowChose += 1}
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            hForCell = sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        case (0,2) :
            if !hasProvider {rowChose += 1}
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            hForCell = sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        case (0,3) :
            if !hasProvider {rowChose += 1}
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            hForCell = sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        case (0,4) :
            if !hasProvider {rowChose += 1}
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            hForCell = sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        default :
            hForCell = 0
        }
        return CGSize(width: self.view.frame.width , height: hForCell);
    }
    
    func cellForPoint(_ point:(Int,Int),indexPath: IndexPath) -> UICollectionViewCell? {
        var cell : UICollectionViewCell? = nil
        switch point {
        case (0,0) :
            if hasProvider  {
                if cellProviders == nil {
                    let cellProvider = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "providersCell", for: indexPath) as? ProductDetailProviderCollectionViewCell
                    cellProvider!.selectedOfferId = self.providerInfo!["offerId"] as! String
                    cellProvider!.delegate = self
                    cellProvider!.showNewItems = ((self.providerInfo!["condition"]as! String) == "1")
                    cellProvider!.itemsProvider = self.providerArray!
                    cellProviders = cellProvider
                }
                cell = self.cellProviders
            } else {
                return cellForPoint((indexPath.section,1),indexPath: indexPath)
            }

        case (0,1) :
            if bundleItems.count != 0 {
                let cellPromotion = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "cellBundleitems", for: indexPath) as? ProductDetailBundleCollectionViewCell
                cellPromotion!.delegate = self
                cellPromotion!.itemsUPC = bundleItems
                cellPromotion!.type = "MG"
                //cell = cellPromotion
            } else {
                return cellForPoint((indexPath.section,2),indexPath: indexPath)
            }
        case (0,2) :
            if  msi.count != 0 {
                let cellPromotion = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "msiCell", for: indexPath) as! ProductDetailMSICollectionViewCell
                cellPromotion.priceProduct = self.price
                cellPromotion.setValues(msi)
                cell = cellPromotion
            }else {
                return cellForPoint((indexPath.section,3),indexPath: indexPath)
            }
        case (0,3) :
            if characteristics.count != 0 {
                let cellCharacteristics = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "cellCharacteristics", for: indexPath) as! ProductDetailCharacteristicsCollectionViewCell
                cellCharacteristics.setValues(characteristics)
                cellCharacteristics.superview?.isUserInteractionEnabled = true
                cell = cellCharacteristics
            }else{
                return cellForPoint((indexPath.section,4),indexPath: indexPath)
            }
        case (0,4) :
            if cellRelated == nil {
                let cellPromotion = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "crossSellCell", for: indexPath) as? ProductDetailCrossSellCollectionViewCell
                cellPromotion!.delegate = self
                cellPromotion!.idListSelectdFromSearch =  self.idListFromlistFind
                cellPromotion!.itemsUPC = itemsCrossSellUPC
                self.cellRelated = cellPromotion
            }
            cell = self.cellRelated
        default :
            cell = nil
        }
        return cell
    }
}

 //MARK: - UIActivityItemSource
extension ProductDetailViewController: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "Walmart"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        
        var toUseName = ""
        if self.name.length > 32 {
            toUseName = self.name.substring(to: 32)
            toUseName = "\(toUseName)..."
        }else {
            toUseName = self.name as String
        }
        //let url  = NSURL(string: "itms-apps://itunes.apple.com/mx/app/walmart-mexico/id823947897?mt=8")
        //let adroidAPP = "https://play.google.com/store/apps/details?id=com.walmart.mg"
        
        //        var urlss = ""
        //        if self.upc != ""{
        //            let url = NSURL(string: "walmartmexicoapp://bussines_mg/type_UPC/value_\(self.upc)")
        //           urlss =  "\n Entra a la aplicación:\n \(url!)) "
        //        }
        
        //let urlapp  = url?.absoluteURL
        
        if activityType == UIActivityType.mail {
            return "Hola, Me gustó este producto de Walmart.¡Te lo recomiendo!\n\(self.name) \nSiempre encuentra todo y pagas menos."
        }else if activityType == UIActivityType.postToTwitter ||  activityType == UIActivityType.postToVimeo ||  activityType == UIActivityType.postToFacebook  {
            return "Chequen este producto: \(toUseName) #walmartapp #wow"
        }
        return "Checa este producto: \(toUseName)"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        if activityType == UIActivityType.mail {
            if UserCurrentSession.sharedInstance.userSigned == nil {
                return "Encontré un producto que te puede interesar en www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance.userSigned!.profile.name) encontró un producto que te puede interesar en www.walmart.com.mx"
            }
        }
        return ""
    }
}


//MARK: ProductDetailColorSizeDelegate
extension ProductDetailViewController: ProductDetailColorSizeDelegate {
    /**
     Gets details objects from facets
     
     - returns: dictionary wit facet details
     */
    func getFacetsDetails() -> [String:Any] {
        NSLog("getFacetsDetails::", "ProductDetailViewController")
        var facetsDetails : [String:Any] = [String:Any]()
        self.selectedDetailItem = [:]
        for product in self.facets! {
            let productUpc =  product["upc"] as! String
            let selected = productUpc == self.upc as String
            let details = product["details"] as! [[String:Any]]
            var itemDetail = [String:String]()
            itemDetail["upc"] = product["upc"] as? String
            var count = 0
            for detail in details{
                let label = detail["description"] as! String
                let unit = detail["unit"] as! String
                var values = facetsDetails[label] as? [[String:Any]]
                if values == nil{ values = []}
                let itemToAdd = ["value":detail["unit"] as! String, "enabled": (details.count == 1 || label == "Color") ? 1 : 0, "type": label,"selected":false] as [String : Any]
                if !values!.contains(where: {return $0["value"] as! String == itemToAdd["value"] as! String && $0["enabled"] as! Int == itemToAdd["enabled"] as! Int && $0["type"] as! String == itemToAdd["type"] as! String && $0["selected"] as! Bool == itemToAdd["selected"] as! Bool}) {
                    values!.append(itemToAdd)
                }
                facetsDetails[label] = values
                itemDetail[label] = detail["unit"] as? String
                count += 1
                if selected {
                    self.selectedDetailItem![label] = unit
                }
            }
            var detailsValues = facetsDetails["itemDetails"] as? [Any]
            if detailsValues == nil{ detailsValues = []}
            detailsValues!.append(itemDetail as AnyObject)
            facetsDetails["itemDetails"] = detailsValues
        }
        return self.marckSelectedDetails(facetsDetails)
    }
    
    /**
     Mark as selected the Details of the first upc
     
     - parameter facetsDetails: dictionary wit facet details
     
     - returns: dictionary wit facet details
     */
    func marckSelectedDetails(_ facetsDetails: [String:Any]) -> [String:Any] {
        var selectedDetails: [String:Any] = [:]
        let filteredKeys = self.getFilteredKeys(facetsDetails)
        if filteredKeys.count > 0 {
            // Primer elemento
            let itemsFirst: [[String:Any]] = facetsDetails[filteredKeys.first!] as! [[String:Any]]
            let selecteFirst =  self.selectedDetailItem![filteredKeys.first!]!
            var values: [Any] = []
            for item in itemsFirst{
                let label = item["type"] as! String
                let unit = item["value"] as! String
                values.append(["value":unit, "enabled": 1, "type": label,"selected": (unit == selecteFirst)])
            }
            selectedDetails[selecteFirst] = values
            
            if filteredKeys.count > 1 {
                let itemsSecond: [[String:Any]] = facetsDetails[filteredKeys.last!] as! [[String:Any]]
                let selectedSecond =  self.selectedDetailItem![filteredKeys.last!]!
                
                let itemDetails = facetsDetails["itemDetails"] as? [[String:Any]]
                var findObj: [String] = []
                for item in itemDetails!{
                    if(item[filteredKeys.first!] as! String == selecteFirst)
                    {
                        findObj.append(item[filteredKeys.last!] as! String)
                    }
                }
                
                var valuesSecond: [Any] = []
                for item in itemsSecond{
                    let label = item["type"] as! String
                    let unit = item["value"] as! String
                    let enabled = findObj.contains(selectedSecond)
                    valuesSecond.append(["value":unit, "enabled": enabled ? 1 : 0, "type": label,"selected": (unit == selectedSecond)])
                }
                selectedDetails[selectedSecond] = valuesSecond
            }
            selectedDetails["itemDetails"] = facetsDetails["itemDetails"]
        }
        return selectedDetails
    }
    
    /**
     Returns Dictionary keys in order
     
     - parameter facetsDetails: facetsDetails Dictionary
     
     - returns: String array with keys in order
     */
    func getFilteredKeys(_ facetsDetails: [String:Any]) -> [String] {
        let keys = Array(facetsDetails.keys)
        var filteredKeys = keys.filter(){
            return ($0 as String) != "itemDetails"
        }
        filteredKeys = filteredKeys.sorted(by: {
            if $0 == "Color" {
                return true
            } else {
                return  $0 < $1
            }
            
        })
        return filteredKeys
    }
    
    /**
     Gets upc from selected details
     
     - parameter itemsSelected: selected items
     
     - returns: String upc
     */
    func getUpc(_ itemsSelected: [String:String]) -> String {
        var upc = ""
        var isSelected = false
        let details = self.facetsDetails!["itemDetails"] as? [[String:Any]]
        for item in details! {
            isSelected = false
            for selectItem in itemsSelected{
                if item[selectItem.0] as! String == selectItem.1{
                    isSelected = true
                }
                else{
                    isSelected = false
                    break
                }
            }
            if isSelected{
                upc = item["upc"] as! String
            }
        }
        return upc
    }
    
    /**
     Gets facet item from upc
     
     - parameter upc: product upc
     
     - returns: Dictionary with product data
     */
    func getFacetWithUpc(_ upc:String) -> [String:Any] {
        var facet = self.facets!.first
        for product in self.facets! {
            if (product["upc"] as! String) == upc {
                facet = product
                break
            }
        }
        return facet!
    }
    
    /**
     Gets detail from detail key
     
     - parameter key:       detail key
     - parameter value:     detail value
     - parameter keyToFind: key to find
     
     - returns: array of sting with details
     */
    func getDetailsWithKey(_ key: String, value: String, keyToFind: String) -> [String]{
        let itemDetails = self.facetsDetails!["itemDetails"] as? [[String:Any]]
        var findObj: [String] = []
        for item in itemDetails!{
            if(item[key] as! String == value)
            {
                findObj.append(item[keyToFind] as! String)
            }
        }
        return findObj
    }
    
    /**
     Gets next detail items or gets the product detail data
     
     - parameter selected: selected detail
     - parameter itemType: item type
     */
    func selectDetailItem(_ selected: String, itemType: String) {
        var detailOrderCount = 0
        let filteredKeys = self.getFilteredKeys(self.facetsDetails!)
        
        if self.colorItems.count != 0 && self.sizesItems.count != 0 {
            detailOrderCount = 2
        }else if self.colorItems.count != 0 && self.sizesItems.count == 0 {
            detailOrderCount = 1
        }else if self.colorItems.count == 0 && self.sizesItems.count != 0 {
            detailOrderCount = 1
        }
        if self.selectedDetailItem == nil{
            self.selectedDetailItem = [:]
        }
        if itemType == filteredKeys.first!{
            self.selectedDetailItem = [:]
            if detailOrderCount > 1 {
                //MARCAR desmarcar las posibles tallas
                let sizes = self.getDetailsWithKey(itemType, value: selected, keyToFind: filteredKeys[1])
                let headerView = self.currentHeaderView as! ProductDetailBannerCollectionViewCell
                for view in headerView.sizesView!.viewToInsert!.subviews {
                    if let button = view.subviews.first! as? UIButton {
                        button.isEnabled = sizes.contains(button.titleLabel!.text!)
                        if sizes.count > 0 && button.titleLabel!.text! == sizes.first {
                            button.sendActions(for: UIControlEvents.touchUpInside)
                        }
                    }
                }
            }
        }
        self.selectedDetailItem![itemType] = selected
        if self.selectedDetailItem!.count == detailOrderCount
        {
            let upc = self.getUpc(self.selectedDetailItem!)
            let facet = self.getFacetWithUpc(upc)
            self.reloadViewWithData(facet)
        }
    }

}

//MARK: ProductDetailBannerCollectionViewDelegate
extension ProductDetailViewController: ProductDetailBannerCollectionViewDelegate {
    /**
     Presents a image in ImageDisplayCollectionViewController
     
     - parameter indexPath: indexPath or image to show
     */
    func sleectedImage(_ indexPath: IndexPath) {
        ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_PRODUCT_DETAIL_IMAGE_TAPPED.rawValue, label: "\(self.name) - \(self.upc)")
        
        let controller = ImageDisplayCollectionViewController()
        controller.name = self.name as String
        controller.imagesToDisplay = imageUrl
        controller.currentItem = indexPath.row
        controller.type = self.type.rawValue
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
}

//MARK: ProductDetailCrossSellViewDelegate
extension ProductDetailViewController: ProductDetailCrossSellViewDelegate {
    /**
     Shows product detail in PageController
     
     - parameter upc:          upc
     - parameter items:        items
     - parameter index:        index
     - parameter imageProduct: image
     - parameter point:        point
     - parameter idList:       list identifier
     */
    func goTODetailProduct(_ upc: String, items: [[String : String]], index: Int, imageProduct: UIImage?, point: CGRect, idList: String, isBundle: Bool) {
        NSLog("goTODetailProduct", "ProductDetailViewController")
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = items as [Any]
        controller.ixSelected = index
        controller.detailOf = isBundle ? "Bundle" : "CrossSell"
        self.navigationController!.pushViewController(controller, animated: true)
    }

    //MARK: TableViewDelegate
    func numberOfSectionsInTableView(_ tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let headerView = UIView()
        switch section {
        case 0:
            headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 46)
            break;
        default:
            
            if isLoading {
                return UIView()
            }
            
            productDetailButton = ProductDetailButtonBarCollectionViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 65.0))
            productDetailButton!.upc = self.upc as String
            productDetailButton!.desc = self.name as String
            productDetailButton!.price = self.price as String
            productDetailButton!.price = self.price as String
            productDetailButton!.isActive = self.strisActive
            productDetailButton!.onHandInventory = self.onHandInventory as String
            productDetailButton!.isPreorderable = self.strisPreorderable
            productDetailButton!.productDepartment = self.productDeparment
            productDetailButton!.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButton!.listButton.isSelected = UserCurrentSession.sharedInstance.userHasUPCWishlist(self.upc as String)
            
            var imageUrl = ""
            if self.imageUrl.count > 0 {
                imageUrl = self.imageUrl[0] as! NSString as String
            }
            productDetailButton!.image = imageUrl
            productDetailButton!.delegate = self
            
            return productDetailButton!
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.0
        default:
            return 56.0
        }
        
    }
    
    /**
     Shows crossSell and reload collectionView
     */
    func showCrossSell() {
        NSLog("showCrossSell", "ProductDetailViewController")
        isHideCrossSell = false
        //let numberOfRows = self.detailCollectionView.numberOfItemsInSection(0)
        //var indexPaths = [NSIndexPath(forRow: numberOfRows, inSection: 0)]
        //self.detailCollectionView.insertItemsAtIndexPaths(indexPaths)
        self.detailCollectionView.reloadData()
        
    }
    
    func loadCrossSell() {
        NSLog("loadCrossSell", "ProductDetailViewController")
        let crossService = CrossSellingProductService()
        crossService.callService(requestParams:self.upc, successBlock: { (result:[[String:Any]]?) -> Void in
            NSLog("CrossSellingProductService successBlock", "ProductDetailViewController")
            if result != nil {
                
                self.itemsCrossSellUPC = result!
                
                if self.itemsCrossSellUPC.count > 0  {
                    self.showCrossSell()
                }
                
                var position = 0
                var positionArray: [Int] = []
                
                for _ in self.itemsCrossSellUPC {
                    position += 1
                    positionArray.append(position)
                }
                
                let listName = "CrossSell"
                let subCategory = ""
                let subSubCategory = ""
                BaseController.sendAnalyticsTagImpressions(self.itemsCrossSellUPC, positionArray: positionArray, listName: listName, mainCategory: "", subCategory: subCategory, subSubCategory: subSubCategory)
            }
            
        }, errorBlock: { (error:NSError) -> Void in
            NSLog("CrossSellingProductService error \(error.localizedDescription)", "ProductDetailViewController")
            print("Termina sevicio app")
        })
        
    }
}

extension ProductDetailViewController: ProductDetailButtonBarCollectionViewCellDelegate, ProviderDetailViewControllerDelegate {
    /**
     Builds an image to share
     */
    func shareProduct() {
        
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.headerView.frame.width, height: 70.0))
        let image = UIImage(named: "detail_HeaderMail")
        imageView.image = image
        let imageHead = UIImage(from: imageView) //(named:"detail_HeaderMail") //
        self.buttonBk.isHidden = true
        let imageHeader = UIImage(from: self.headerView)
        self.buttonBk.isHidden = false
        //let headers = [0]
        
        let imagen = UIImage(from: currentHeaderView)
        
        //Event
        ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: "\(self.name) - \(self.upc)")
        
        //let screen = self.detailCollectionView.screenshotOfHeadersAtSections( NSSet(array:headers), footersAtSections: nil, rowsAtIndexPaths: NSSet(array: items))
        
        let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx/Busqueda.aspx?Text=\(self.upc)")
        let imgResult = UIImage.verticalImage(from: [imageHead!,imageHeader!,imagen!])
        
        //let urlWmart = NSURL(string: "walmartMG://UPC_\(self.upc)")
        if urlWmart != nil {
            let controller = UIActivityViewController(activityItems: [self,imgResult!,urlWmart!], applicationActivities: nil)
            self.navigationController!.present(controller, animated: true, completion: nil)
            controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        }
    }
    
    /**
     Shows product detail information in popup view
     */
    func showProductDetail() {
        if isShowShoppingCart {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.isShowShoppingCart = false
                self.selectQuantity?.frame = CGRect(x: 0, y: self.heightDetail, width: self.view.frame.width, height: 0)
                //self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -self.heightDetail, 320, self.heightDetail)
            }, completion: { (animated:Bool) -> Void in
                if self.selectQuantity != nil {
                    self.selectQuantity!.removeFromSuperview()
                    self.selectQuantity = nil
                    self.detailCollectionView.isScrollEnabled = true
                    self.gestureCloseDetail.isEnabled = false
                }
            })
        }
        
        //EVENT
        ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawselectQuantity = nilValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_INFORMATION.rawValue, label: "\(self.name) - \(self.upc)")
        
        self.detailCollectionView.scrollsToTop = true
        self.detailCollectionView.isScrollEnabled = false
        gestureCloseDetail.isEnabled = true
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.detailCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.detailCollectionView.frame.width,  height: self.detailCollectionView.frame.height ), animated: false)
        }, completion: { (complete:Bool) -> Void in
            if self.viewDetail == nil {
                self.isShowProductDetail = true
                self.startAnimatingProductDetail()
            } else {
                self.closeProductDetail()
                
            }
        })
    }
    
    /**
     Adds or removes products in wishList
     
     - parameter upc:             product upc
     - parameter desc:            product description
     - parameter imageurl:        product Image
     - parameter price:           product price
     - parameter addItem:         add or remove item
     - parameter isActive:        product is active
     - parameter onHandInventory: product inventory
     - parameter isPreorderable:  is preorderable product
     - parameter added:           added block
     */
    func addOrRemoveToWishList(_ upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,category:String,added: @escaping (Bool) -> Void) {
        
        self.isWishListProcess = true
        
        self.addOrRemoveToWishListBlock = {() in
            /*if UserCurrentSession.sharedInstance.userSigned == nil {
             let storyboard = self.loadStoryboardDefinition()
             if let vc = storyboard!.instantiateViewControllerWithIdentifier("loginItemVC") as? LoginController {
             vc.showHeader = true
             vc.title = NSLocalizedString("profile.password.login.wishlits",comment:"")
             added(false)
             vc.successCallBack = {() in
             self.addOrRemoveToWishList(upc,desc:desc,imageurl:imageurl,price:price,addItem:addItem, added: added)
             self.navigationController?.popViewControllerAnimated(true)
             }
             self.navigationController?.pushViewController(vc, animated: true)
             }
             }else{*/
            let frameWishListbtn = self.view.convert(self.view.frame, from:self.productDetailButton?.listButton)
            let addedAlertWL = WishlistAddProductStatus(frame: CGRect(x: 0, y: frameWishListbtn.origin.y - 48, width: self.view.frame.width, height: 0))
            addedAlertWL.generateBlurImage(self.view,frame:CGRect(x: 0, y: frameWishListbtn.origin.y, width: self.view.frame.width, height: self.heightDetail))
            
            addedAlertWL.clipsToBounds = true
            addedAlertWL.imageBlurView.frame = CGRect(x: 0, y: -312, width: self.view.frame.width, height: self.heightDetail)
            if addItem {
                let offerId = self.providerInfo?["offerId"] as? String
                let sellerName = self.providerInfo?["name"] as? String
                let sellerId = self.providerInfo?["sellerId"] as? String
                let serviceWishList = AddItemWishlistService()
                serviceWishList.callService(upc, quantity: "1", comments: "",desc:desc,imageurl:imageurl,price:price,isActive:isActive,onHandInventory:onHandInventory,isPreorderable:isPreorderable,category:self.productDeparment,sellerId:sellerId,sellerName: sellerName,offerId:offerId,successBlock: { (result:[String:Any]) -> Void in
                    
                    addedAlertWL.textView.text = NSLocalizedString("wishlist.ready",comment:"")
                    added(true)
                    
                    //Event
                    ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ADD_WISHLIST.rawValue, label: "\(self.name) - \(self.upc)")
                    
                    self.view.addSubview(addedAlertWL)
                    self.isWishListProcess = false
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        
                        addedAlertWL.frame = CGRect(x: 0, y: frameWishListbtn.origin.y - 48 , width: self.view.frame.width, height: 48)
                        addedAlertWL.prepareToClose()
                        self.gestureCloseDetail.isEnabled = false
                        self.detailCollectionView.isScrollEnabled = true
                    })
                    
                }) { (error:NSError) -> Void in
                    self.isWishListProcess = false
                    if error.code != -100 {
                        added(false)
                        addedAlertWL.textView.text = NSLocalizedString("conection.error",comment:"")
                        self.view.addSubview(addedAlertWL)
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            addedAlertWL.frame = CGRect(x: 0, y: frameWishListbtn.origin.y - 48, width: self.view.frame.width , height: 48)
                            addedAlertWL.prepareToClose()
                            self.gestureCloseDetail.isEnabled = false
                            self.detailCollectionView.isScrollEnabled = true
                        })
                    }
                }
            } else {
                let serviceWishListDelete = DeleteItemWishlistService()
                serviceWishListDelete.callService(upc, successBlock: { (result:[String:Any]) -> Void in
                    added(true)
                    addedAlertWL.textView.text = NSLocalizedString("wishlist.deleted",comment:"")
                    self.view.addSubview(addedAlertWL)
                    self.isWishListProcess = false
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        addedAlertWL.frame = CGRect(x: 0, y: frameWishListbtn.origin.y - 48, width: self.view.frame.width, height: 48)
                        addedAlertWL.prepareToClose()
                        self.gestureCloseDetail.isEnabled = false
                        self.detailCollectionView.isScrollEnabled = true
                    })
                    
                    //Event
                    ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_WISHLIST.rawValue, label: "\(self.name) - \(self.upc)")
                    
                    
                }, errorBlock: { (error:NSError) -> Void in
                    self.isWishListProcess = false
                    added(false)
                    if error.code != -100 {
                        addedAlertWL.textView.text = NSLocalizedString("conection.error",comment:"")
                        self.view.addSubview(addedAlertWL)
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            addedAlertWL.frame = CGRect(x: 0, y: frameWishListbtn.origin.y - 48, width: self.view.frame.width, height: 48)
                            addedAlertWL.prepareToClose()
                            self.gestureCloseDetail.isEnabled = false
                            self.detailCollectionView.isScrollEnabled = true
                        })
                    }
                })
            }
            //}
        }
        
        if isShowShoppingCart {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.isShowShoppingCart = false
                self.selectQuantity!.frame = CGRect(x: 0, y: self.heightDetail, width: self.view.frame.width, height: 0)
                //self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -self.heightDetail, 320, self.heightDetail)
            }, completion: { (animated:Bool) -> Void in
                if self.selectQuantity != nil {
                    self.selectQuantity!.removeFromSuperview()
                    self.selectQuantity = nil
                    self.gestureCloseDetail.isEnabled = false
                    self.detailCollectionView.isScrollEnabled = true
                }
            })
        }
        
        closeProductDetail()
        
        
        self.detailCollectionView.isScrollEnabled = false
        gestureCloseDetail.isEnabled = true
        //if  self.detailCollectionView.contentOffset.y != 0.0 {
        //self.detailCollectionView.scrollRectToVisible(CGRectMake(0, 0, self.tabledetail.frame.width,  self.tabledetail.frame.height ), animated: true)
        //}
        if addOrRemoveToWishListBlock != nil {
            addOrRemoveToWishListBlock!()
        }
    }
    
    /**
     Adds product to shopping cart
     
     - parameter upc:      product upc
     - parameter desc:     product description
     - parameter price:    product price
     - parameter imageURL: product image
     - parameter comments: product comments
     */
    func addProductToShoppingCart(_ upc:String,desc:String,price:String,imageURL:String, comments:String) {
        let isInCart = self.productDetailButton?.detailProductCart != nil
        if !isInCart {
            //self.tabledetail.reloadData()
            self.isShowShoppingCart = false
            var params  =  self.buildParamsUpdateShoppingCart("1", orderByPiece: true, pieces: 1,equivalenceByPiece:0 )//equivalenceByPiece
            params.updateValue(comments, forKey: "comments")
            params.updateValue(self.type, forKey: "type")
            NotificationCenter.default.post(name: .addUPCToShopingCart, object: self, userInfo: params)
            return
        }
        
        if selectQuantity == nil {
            
            if isShowProductDetail == true {
                self.closeProductDetail()
            }
            
            isShowShoppingCart = true
            
            let finalFrameOfQuantity = CGRect(x: 0, y: 0, width: self.view.frame.width, height: heightDetail)
            selectQuantity = ShoppingCartQuantitySelectorView(frame:CGRect(x: 0, y: heightDetail, width: self.view.frame.width, height: heightDetail), priceProduct:NSNumber(value: self.price.doubleValue as Double), upcProduct: upc)
            selectQuantity!.frame = CGRect(x: 0, y: heightDetail, width: self.view.frame.width, height: 0)
            selectQuantity!.closeAction = { () in
                self.closeContainerDetail(completeClose: { () -> Void in
                    self.productDetailButton?.isOpenQuantitySelector = false
                    self.productDetailButton?.reloadShoppinhgButton()
                }, isPush: false)
            }
            
            if productDetailButton!.detailProductCart?.quantity != nil {
                selectQuantity?.userSelectValue(productDetailButton!.detailProductCart!.quantity.stringValue)
                selectQuantity?.first = true
            }
            
            selectQuantity!.addToCartAction =
                { (quantity:String) in
                    //let quantity : Int = quantity.toInt()!
                    self.selectQuantity?.closeAction()
                    
                    if quantity == "00" {
                        self.deleteFromCart()
                        return
                    }
                    
                    let maxProducts = (self.onHandInventory.integerValue <= 5 || self.productDeparment == "d-papeleria") ? self.onHandInventory.integerValue : 5
                    if maxProducts >= Int(quantity) {
                        //let params = CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageURL, price: price, quantity: quantity,onHandInventory:self.onHandInventory,)
                        let params = self.buildParamsUpdateShoppingCart(quantity, orderByPiece: true, pieces: Int(quantity)!,equivalenceByPiece:0 )//equivalenceByPiece
                        NotificationCenter.default.post(name: .addUPCToShopingCart, object: self, userInfo: params)
                    } else {
                        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                        
                        let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                        let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                        let msgInventory = "\(firstMessage)\(maxProducts) \(secondMessage)"
                        alert!.setMessage(msgInventory)
                        alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                        self.selectQuantity?.first = true
                        self.selectQuantity?.userSelectValue("\(maxProducts)")
                    }
            }
            
            if productDetailButton!.detailProductCart?.quantity != nil {
                self.productDetailButton?.reloadShoppinhgButton()
                selectQuantity?.userSelectValue(productDetailButton!.detailProductCart!.quantity.stringValue)
                selectQuantity?.first = true
            }
            
            self.detailCollectionView.isScrollEnabled = false
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.detailCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.detailCollectionView.frame.width,  height: self.detailCollectionView.frame.height ), animated: false)
            }, completion: { (complete: Bool) -> Void in
                
                self.selectQuantity!.clipsToBounds = true
                self.view.addSubview(self.selectQuantity!)
                
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.productDetailButton?.setOpenQuantitySelector()
                    self.selectQuantity!.frame = finalFrameOfQuantity
                })
            })
            
        } else {
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.selectQuantity!.frame = CGRect(x: 0, y: self.heightDetail, width: self.view.frame.width, height: 0)
            }, completion: { (animated: Bool) -> Void in
                self.closeContainerDetail(completeClose:nil, isPush: false)
            })
            
        }
    }
}

//MARK: ProductDetailProviderViewDelegate
extension ProductDetailViewController: ProductDetailProviderViewDelegate {
    func showProviderInfoView() {
      let controller = ProviderDetailViewController()
      controller.nameProvider = self.providerInfo!["name"] as! String
      controller.prodUpc = self.upc as String
      controller.prodImageUrl = self.imageUrl.first! as? String
      controller.prodDescription = self.name as String
      controller.prodPrice = self.price as String
      controller.sellerId = self.providerInfo!["sellerId"] as! String
      controller.delegate = self
      controller.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0
      self.navigationController!.pushViewController(controller, animated: true)
  }
    
    func showOtherProvidersView() {
        let controller = ProviderListViewController()
        controller.upcProduct = self.upc as String
        controller.providerItems = self.providerArray
        controller.productImageUrl = self.imageUrl.first! as? String
        controller.productDescription = self.name as String
        controller.productDeparment = self.productDeparment
        controller.productType = "Nuevo"
        controller.strisPreorderable = self.strisPreorderable
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: ProductDetailProviderCollectionViewCellDelegate
extension ProductDetailViewController: ProductDetailProviderCollectionViewCellDelegate {
    func selectOffer(offer: [String:Any]) {
        self.providerInfo = offer
        self.detailCollectionView.reloadData()
        self.upc = providerInfo!["offerId"] as! NSString
        self.price = providerInfo!["price"] as! NSString
    }
}
