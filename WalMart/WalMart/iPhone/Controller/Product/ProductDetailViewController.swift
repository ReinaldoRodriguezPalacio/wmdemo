//
//  ProductoDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData
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

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
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



class ProductDetailViewController : IPOBaseController,UICollectionViewDataSource,UICollectionViewDelegate,ListSelectorDelegate,ProductDetailCrossSellViewDelegate,ProductDetailButtonBarCollectionViewCellDelegate ,ProductDetailBannerCollectionViewDelegate,UIActivityItemSource, ProductDetailColorSizeDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var detailCollectionView: UICollectionView!
    
    var viewLoad : WMLoadingView!
    var msi : [String] = []
    var sku : NSString = ""
    var upc : NSString = ""
    var name : NSString = ""
    var detail : NSString = ""
    var saving : NSString = ""
    var price : NSString = ""
    var listPrice : NSString = ""
    var comments : NSString = ""
    var ingredients: String = ""
    var nutrimentalInfo: [String:String] = [:]
    var imageUrl : [Any] = []
    var characteristics : [[String:Any]] = []
    var bundleItems : [Any] = []
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
    var itemsCrossSellUPC : NSArray! = []
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
    let heightDetail : CGFloat = 360
    var headerView : UIView!
    var currentHeaderView : UIView!
    var isPesable : Bool = false
    var type : ResultObjectType!
    var cellRelated : UICollectionViewCell? = nil
    var cellCharacteristics : UICollectionViewCell? = nil
    var facets: [[String:Any]]? = nil
    var facetsDetails: [String:Any]? = nil
    var selectedDetailItem: [String:String]? = nil
    
    var fromSearch =  false
    var idListFromlistFind = ""
    var productDeparment:String = ""
    
    var indexRowSelected : String = ""
    var listSelectorController: ListsSelectorViewController?
    var nutrimentalsView : GRNutrimentalInfoView? = nil
    var selectQuantityGR : GRShoppingCartQuantitySelectorView!
    var listSelectorContainer: UIView?
    var listSelectorBackgroundView: UIImageView?
    var alertView: IPOWMAlertViewController?
    var equivalenceByPiece : NSNumber! = NSNumber(value: 0 as Int32)
    
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
        
        detailCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        detailCollectionView.register(ProductDetailBannerCollectionViewCell.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage")
        detailCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emptyCell")
        detailCollectionView.register(ProductDetailMSICollectionViewCell.self, forCellWithReuseIdentifier: "msiCell")
        detailCollectionView.register(ProductDetailCharacteristicsCollectionViewCell.self, forCellWithReuseIdentifier: "cellCharacteristics")
        detailCollectionView.register(ProductDetailBundleCollectionViewCell.self, forCellWithReuseIdentifier: "cellBundleitems")
        detailCollectionView.register(ProductDetailCrossSellCollectionViewCell.self, forCellWithReuseIdentifier: "crossSellCell")
        
        if let layout = detailCollectionView.collectionViewLayout as? CSStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSize(width: self.view.frame.size.width, height: 314)
            layout.parallaxHeaderMinimumReferenceSize = CGSize(width: self.view.frame.size.width, height: 314)
            layout.itemSize = CGSize(width: self.view.frame.size.width, height: layout.itemSize.height)
            layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 56.0)
            layout.disableStickyHeaders = false

            NotificationCenter.default.addObserver(self, selector: #selector(ProductDetailViewController.closeContainerDetail), name: NSNotification.Name(rawValue: CustomBarNotification.SuccessAddUpdateCommentCart.rawValue), object: nil)
        }
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 46))
        headerView.backgroundColor = WMColor.light_light_gray
        let buttonBk = UIButton(frame: CGRect(x: 0, y: 0, width: 46, height: 46))
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ProductDetailViewController.endUpdatingShoppingCart(_:)), name: NSNotification.Name(rawValue: CustomBarNotification.UpdateBadge.rawValue), object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
                self.selectQuantity!.frame = CGRect(x: 0, y: 360, width: 320, height: 0)
                self.selectQuantity!.imageBlurView.frame = CGRect(x: 0, y: -360, width: 320, height: 360)
                }, completion: { (animated:Bool) -> Void in
                    if self.selectQuantity != nil {
                        self.selectQuantity!.removeFromSuperview()
                        self.selectQuantity = nil
                        self.detailCollectionView.isScrollEnabled = true
                        self.gestureCloseDetail.isEnabled = false
                    }
            })
        }
    }
    
    

    //MARK: TableViewDelegate
    func numberOfSectionsInTableView(_ tableView: UITableView!) -> Int {
        return 1
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
            if  bundleItems.count != 0 {
                return 170.0
            }
            return sizeForIndexPath ((indexPath.section,1),indexPath: indexPath)
        case (0,1):
            if  msi.count != 0 {
                return (CGFloat(msi.count) * 14) + 180.0
            }
            return sizeForIndexPath ((indexPath.section,2),indexPath: indexPath)
        case (0,2) :
            if characteristics.count != 0 {
                let size = ProductDetailCharacteristicsCollectionViewCell.sizeForCell(self.view.frame.width - 30,values:characteristics as NSArray)
                return size + 50
            }
            return sizeForIndexPath ((indexPath.section,3),indexPath: indexPath)
        case (0,3) :
            return 210
        default :
            return 210
        }
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
            
            productDetailButton = ProductDetailButtonBarCollectionViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 56.0))
            productDetailButton!.upc = self.upc as String
            productDetailButton!.desc = self.name as String
            productDetailButton!.price = self.price as String
            productDetailButton!.price = self.price as String
            productDetailButton!.isActive = self.strisActive
            productDetailButton!.onHandInventory = self.onHandInventory as String
            productDetailButton!.isPreorderable = self.strisPreorderable
            productDetailButton!.productDepartment = self.productDeparment
            productDetailButton!.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButton!.listButton.isSelected = UserCurrentSession.sharedInstance.userHasUPCUserlist(self.upc as String)
            
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
    
   
    /**
     Return to the last viewController
     */
    func backButton (){
        self.navigationController!.popViewController(animated: true)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BACK.rawValue, label: "")
    }
    
    
    func tableView(_ tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.0
        default:
            return 56.0
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewLoad.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
    }

    // MARK: - Collection view config
    /**
     Shows product detail in PageController
     
     - parameter upc:          upc
     - parameter items:        items
     - parameter index:        index
     - parameter imageProduct: image
     - parameter point:        point
     - parameter idList:       list identifier
     */
    func goTODetailProduct(_ upc: String, items: [[String : String]], index: Int, imageProduct: UIImage?, point: CGRect, idList: String) {
        //Event
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BUNDLE_PRODUCT_DETAIL_TAPPED.rawValue, label: "\(self.name) - \(self.upc)")
        
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = items as [Any]
        controller.ixSelected = index
        self.navigationController!.pushViewController(controller, animated: true)
    }
    /**
     Shows crossSell and reload collectionView
     */
    func showCrossSell() {
        isHideCrossSell = false
        //let numberOfRows = self.detailCollectionView.numberOfItemsInSection(0)
        //var indexPaths = [NSIndexPath(forRow: numberOfRows, inSection: 0)]
        //self.detailCollectionView.insertItemsAtIndexPaths(indexPaths)
        self.detailCollectionView.reloadData()

    }
    
    
    
    func loadCrossSell() {
        let crossService = CrossSellingProductService()
        crossService.callService(requestParams:["skuId":self.sku], successBlock: { (result:NSArray?) -> Void in
                if result != nil {
                self.itemsCrossSellUPC = result!
                if self.itemsCrossSellUPC.count > 0  {
                    self.showCrossSell()
                }
            }
            }, errorBlock: { (error:NSError) -> Void in
                print("Termina sevicio app")
        })
        
    }
    
    
    //MARK: - ProductDetailButtonBarCollectionViewCellDelegate
    /**
     Shows product detail information in popup view
     */
    func showProductDetail() {
        if isShowShoppingCart {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.isShowShoppingCart = false
                self.selectQuantity!.frame = CGRect(x: 0, y: 360, width: 320, height: 0)
                //self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
                }, completion: { (animated:Bool) -> Void in
                    if self.selectQuantity != nil {
                        self.selectQuantity!.closeAction()
                        self.selectQuantity!.removeFromSuperview()
                        self.selectQuantity = nil
                        self.detailCollectionView.isScrollEnabled = true
                        self.gestureCloseDetail.isEnabled = false
                    }
            })
        }
        
        
        //EVENT
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_INFORMATION.rawValue, label: "\(self.name) - \(self.upc)")
        
        self.detailCollectionView.scrollsToTop = true
        self.detailCollectionView.isScrollEnabled = false
        gestureCloseDetail.isEnabled = true
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.detailCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.detailCollectionView.frame.width,  height: self.detailCollectionView.frame.height ), animated: false)
            }, completion: { (complete:Bool) -> Void in
                if self.listSelectorContainer != nil {
                    self.removeListSelector(action: nil)
                }
                if self.viewDetail == nil && self.nutrimentalsView == nil {
                    self.isShowProductDetail = true
                    self.startAnimatingProductDetail()
                } else {
                    self.closeProductDetail()
                    self.closeProductDetailNutrimental()
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
    func addOrRemoveToWishList(_ upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,category:String,added:(Bool) -> Void) {
        
        self.closeProductDetail()
        
        if isShowShoppingCart {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.isShowShoppingCart = false
                self.selectQuantity!.frame = CGRect(x: 0, y: 360, width: 320, height: 0)
                //self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
                }, completion: { (animated:Bool) -> Void in
                    if self.selectQuantity != nil {
                        self.selectQuantity!.closeAction()
                        self.selectQuantity!.removeFromSuperview()
                        self.selectQuantity = nil
                        self.detailCollectionView.isScrollEnabled = true
                        self.gestureCloseDetail.isEnabled = false
                    }
            })
        }
        
        //Event
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_ADD_TO_LIST.rawValue, label: "\(self.name) - \(self.upc)")
        
        
        
        if self.listSelectorController == nil {
            self.listSelectorContainer = UIView(frame: CGRect(x: 0, y: 360.0, width: 320.0, height: 0.0))
            self.listSelectorContainer!.clipsToBounds = true
            self.view.addSubview(self.listSelectorContainer!)
            
            self.listSelectorController = ListsSelectorViewController()
            self.listSelectorController!.delegate = self
            self.listSelectorController!.productUpc = self.upc as String
            self.addChildViewController(self.listSelectorController!)
            self.listSelectorController!.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 360.0)
            self.listSelectorContainer!.addSubview(self.listSelectorController!.view)
            self.listSelectorController!.didMove(toParentViewController: self)
            self.listSelectorController!.view.clipsToBounds = true
            
            self.listSelectorBackgroundView = self.listSelectorController!.createBlurImage(self.view, frame: CGRect(x: 0, y: 0, width: 320, height: 360))
            self.listSelectorController!.generateBlurImage(self.view, frame: CGRect(x: 0, y: 0, width: 320, height: 360))
            
            self.detailCollectionView.isScrollEnabled = false
            UIView.animate(withDuration: 0.3,
                                       animations: { () -> Void in
                                        self.detailCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.detailCollectionView.frame.width,  height: self.detailCollectionView.frame.height), animated: false)
                },
                                       completion: { (complete:Bool) -> Void in
                                        if complete {
                                            self.listSelectorBackgroundView!.frame = CGRect(x: 0, y: -360.0, width: 320.0, height: 360.0)
                                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                                self.listSelectorContainer!.frame = CGRect(x: 0, y: 0, width: 320, height: 360)
                                                self.listSelectorBackgroundView!.frame = CGRect(x: 0, y: 0, width: 320, height: 360)
                                                self.listSelectorController!.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 360.0)
                                                self.productDetailButton?.listButton.isSelected = true
                                            })
                                        }
            })
        }
        else {
            self.removeListSelector(action: nil)
        }
    }
    
    
    func removeListSelector(action:(()->Void)?) {
        UIView.animate(withDuration: 0.3,
                                   animations: { () -> Void in
                                    self.detailCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.detailCollectionView.frame.width,  height: self.detailCollectionView.frame.height), animated: false)
            },
                                   completion: { (complete:Bool) -> Void in
                                    if complete {
                                        UIView.animate(withDuration: 0.5,
                                            delay: 0.0,
                                            options: .layoutSubviews,
                                            animations: { () -> Void in
                                                self.listSelectorContainer?.frame = CGRect(x: 0, y: 360.0, width: 320.0, height: 0.0)
                                                self.listSelectorBackgroundView?.frame = CGRect(x: 0, y: -360.0, width: 320.0, height: 360.0)
                                            }, completion: { (complete:Bool) -> Void in
                                                if complete {
                                                    self.listSelectorController!.willMove(toParentViewController: nil)
                                                    self.listSelectorController!.view.removeFromSuperview()
                                                    self.listSelectorController!.removeFromParentViewController()
                                                    self.listSelectorController = nil
                                                    
                                                    self.listSelectorBackgroundView!.removeFromSuperview()
                                                    self.listSelectorBackgroundView = nil
                                                    self.listSelectorContainer!.removeFromSuperview()
                                                    self.listSelectorContainer = nil
                                                    
                                                    //self.productDetailButton!.listButton.selected = false
                                                    self.productDetailButton!.listButton.isSelected = UserCurrentSession.sharedInstance.userHasUPCUserlist(self.upc as String)
                                                    
                                                    action?()
                                                    self.detailCollectionView.isScrollEnabled = true
                                                }
                                            }
                                        )
                                    }
        })
    }
    
    /**
     Adds product to shopping cart
     
     - parameter upc:      product upc
     - parameter desc:     product description
     - parameter price:    product price
     - parameter imageURL: product image
     - parameter comments: product comments
     */
    func addProductToShoppingCart(_ upc:String,desc:String,price:String,imageURL:String, comments:String)
    {
        if self.listSelectorContainer != nil {
            self.listSelectorDidClose()
        }
        
        
        if selectQuantity == nil {
            if isShowProductDetail == true {
                self.closeProductDetail()
            }
            
            isShowShoppingCart = true
             let finalFrameOfQuantity = CGRect(x: 0, y: 0, width: 320, height: 360)
            
            selectQuantity = ShoppingCartQuantitySelectorView(frame:CGRect(x: 0, y: 360, width: 320, height: 360),priceProduct:NSNumber(value: self.price.doubleValue as Double),upcProduct:upc)
            //selectQuantity!.priceProduct = NSNumber(double:self.price.doubleValue)
            selectQuantity!.frame = CGRect(x: 0, y: 360, width: 320, height: 0)
            selectQuantity!.closeAction =
                { () in
                    UIView.animate(withDuration: 0.5,
                        animations: { () -> Void in
                            self.productDetailButton?.reloadShoppinhgButton()
                            self.isShowShoppingCart = false
                            self.selectQuantity!.frame = CGRect(x: 0, y: 360, width: 320, height: 0)
                            //self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
                        },
                        completion: { (animated:Bool) -> Void in
                            if self.selectQuantity != nil {
                                self.selectQuantity!.removeFromSuperview()
                                self.selectQuantity = nil
                                self.gestureCloseDetail.isEnabled = false
                                self.detailCollectionView.isScrollEnabled = true
                            }
                        }
                    )
            }
            //Event
             BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_KEYBOARD.rawValue, label: "\(self.name) - \(self.upc)")
            
           // selectQuantity!.generateBlurImage(self.view,frame:finalFrameOfQuantity)
            
         
            selectQuantity!.addToCartAction =
                { (quantity:String) in
                    //let quantity : Int = quantity.toInt()!
                    let maxProducts = (self.onHandInventory.integerValue <= 5 || self.productDeparment == "d-papeleria") ? self.onHandInventory.integerValue : 5
                    if maxProducts >= Int(quantity) {
                        //let params = CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageURL, price: price, quantity: quantity,onHandInventory:self.onHandInventory,)
                        let params = self.buildParamsUpdateShoppingCart(quantity)
                        self.gestureCloseDetail.isEnabled = false
                        self.detailCollectionView.isScrollEnabled = true
                        self.isShowShoppingCart = false
                        
                        if UserCurrentSession.sharedInstance.userHasUPCShoppingCart(String(self.upc)) {
                            BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_UPDATE_SHOPPING_CART.rawValue, label: self.name as String)
                        } else {
                            BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label: self.name as String)
                        }
        

                
                        UIView.animate(withDuration: 0.2,
                            animations: { () -> Void in
                                self.productDetailButton?.reloadShoppinhgButton()
                                self.selectQuantity!.frame = CGRect(x: 0, y: 360, width: 320, height: 0	)
                               // self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
                            },
                            completion: { (animated:Bool) -> Void in
                                self.selectQuantity!.removeFromSuperview()
                                self.selectQuantity = nil
                                self.gestureCloseDetail.isEnabled = false
                                self.detailCollectionView.isScrollEnabled = true
                                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
                            }
                        )
                    }
                    else {
                        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                    
                        let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                        let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                        let msgInventory = "\(firstMessage)\(maxProducts) \(secondMessage)"
                        alert!.setMessage(msgInventory)
                        alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                        self.selectQuantity?.lblQuantity?.text = maxProducts < 10 ? "0\(maxProducts)" : "\(maxProducts)"
                    }
            }
            
            self.detailCollectionView.isScrollEnabled = false
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.detailCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.detailCollectionView.frame.width,  height: self.detailCollectionView.frame.height ), animated: false)
                }, completion: { (complete:Bool) -> Void in
                    self.selectQuantity!.clipsToBounds = true
                    self.view.addSubview(self.selectQuantity!)
                    
                    //self.selectQuantity?.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.productDetailButton?.setOpenQuantitySelector()
                        self.selectQuantity!.frame = finalFrameOfQuantity
                        //self.selectQuantity!.imageBlurView.frame = finalFrameOfQuantity
                    })
            })
        }else{
            self.closeContainerDetail()
        }
    }
    
    //MARK: Shopping cart
    /**
     Builds an [String:Any] with data to add product to shopping cart
     
     - parameter quantity: quantity of product
     
     - returns: [String:Any]
     */
    func buildParamsUpdateShoppingCart(_ quantity:String) -> [String:Any] {
        var imageUrlSend = ""
        if self.imageUrl.count > 0 {
            imageUrlSend = self.imageUrl[0] as! NSString as String
        }
        let pesable = isPesable ? "1" : "0"
        return ["skuid":self.sku,"upc":self.upc,"desc":self.name,"imgUrl":imageUrlSend,"price":self.price,"quantity":quantity,"onHandInventory":self.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable,"isPreorderable":self.strisPreorderable,"category":self.productDeparment]
    }
    
    
    func closeContainerDetail(){
        if selectQuantity != nil {
            
        gestureCloseDetail.isEnabled = false
        self.detailCollectionView.isScrollEnabled = true
        self.closeContainer({ () -> Void in
            
            }, completeClose: { () -> Void in
                self.isShowShoppingCart = false
                
                UserCurrentSession.sharedInstance.loadMGShoppingCart
                    { () -> Void in
                        self.productDetailButton?.reloadShoppinhgButton()
                }
                
                if self.selectQuantity != nil {
                    self.selectQuantity!.removeFromSuperview()
                    self.selectQuantity = nil
                }
        })
        }
        else {
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
                let finalFrameOfQuantity = CGRect(x: 0, y: 0, width: 320, height: 360)
                
                selectQuantity!.clipsToBounds = true
                self.view.addSubview(selectQuantity!)
                self.detailCollectionView.isScrollEnabled = false
                gestureCloseDetail.isEnabled = true
                //self.selectQuantity!.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
               
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
        let finalFrameOfQuantity = CGRect(x: 0, y: 0, width: 320, height: 360)
        
        if self.nutrimentalInfo.count == 0 {
            viewDetail = ProductDetailTextDetailView(frame: CGRect(x: 0,y: 360, width: 320, height: 0))
            viewDetail!.generateBlurImage(self.view,frame:finalFrameOfQuantity)
            //self.viewDetail!.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
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
        } else {
            
            let finalFrameOfQuantity = CGRect(x: 0, y: 0, width: 320, height: 360)
            if nutrimentalsView == nil {
                nutrimentalsView = GRNutrimentalInfoView(frame: CGRect(x: 0,y: 360, width: 320, height: 0))
                nutrimentalsView?.setup(self.ingredients, nutrimentals: self.nutrimentalInfo)
                nutrimentalsView!.generateBlurImage(self.view,frame:finalFrameOfQuantity)
            }
            
            nutrimentalsView!.frame = CGRect(x: 0,y: 360, width: 320, height: 0)
            self.nutrimentalsView!.imageBlurView.frame =  CGRect(x: 0, y: -360, width: 320, height: 360)
            
            
            nutrimentalsView!.closeDetail = { () in
                self.closeProductDetailNutrimental()
            }
            self.view.addSubview(nutrimentalsView!)
            
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.nutrimentalsView!.frame = finalFrameOfQuantity
                self.nutrimentalsView!.imageBlurView.frame = finalFrameOfQuantity
                //self.viewDetail.frame = CGRectMake(0, 0, self.tabledetail.frame.width, self.tabledetail.frame.height - 145)
                self.productDetailButton!.deltailButton.isSelected = true
            })
            
        }
    }
    
    /**
     Close product detail view
     */
    func closeProductDetail () {
        if isShowProductDetail == true {
            if viewDetail ==  nil {
                if  self.nutrimentalsView != nil {
                    closeProductDetailNutrimental()
                }else{
                    self.supcloseProductDetail()
                }
            }else {
              self.supcloseProductDetail()
            }
            
        }
    }
    
    func closeProductDetailNutrimental () {
        if isShowProductDetail == true {
            isShowProductDetail = false
            gestureCloseDetail.isEnabled = false
            self.detailCollectionView.isScrollEnabled = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                
                self.nutrimentalsView?.imageBlurView.frame =  CGRect(x: 0, y: -360, width: 320, height: 360)
                self.nutrimentalsView?.frame = CGRect(x: 0,y: 360, width: 320, height: 0)
            }, completion: { (ended:Bool) -> Void in
                if self.nutrimentalsView != nil {
                    self.nutrimentalsView?.removeFromSuperview()
                    self.nutrimentalsView = nil
                    
                    
                    self.productDetailButton!.deltailButton.isSelected = false
                }
            }) 
        }
    }
    
    func supcloseProductDetail(){
        if isShowProductDetail == true {
            isShowProductDetail = false
            gestureCloseDetail.isEnabled = false
            self.detailCollectionView.isScrollEnabled = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                
                self.viewDetail?.imageBlurView.frame =  CGRect(x: 0, y: -360, width: 320, height: 360)
                self.viewDetail.frame = CGRect(x: 0,y: 360, width: 320, height: 0)
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
     Presents a image in ImageDisplayCollectionViewController
     
     - parameter indexPath: indexPath or image to show
     */
    func sleectedImage(_ indexPath: IndexPath) {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_PRODUCT_DETAIL_IMAGE_TAPPED.rawValue, label: "\(self.name) - \(self.upc)")
        
        let controller = ImageDisplayCollectionViewController()
        controller.name = self.name as String
        controller.imagesToDisplay = imageUrl
        controller.currentItem = (indexPath as NSIndexPath).row
        controller.type = self.type.rawValue
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    /**
     Shows not aviable product message
     */
    func showMessageProductNotAviable() {
        self.detailCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.detailCollectionView.frame.width,  height: self.detailCollectionView.frame.height ), animated: false)
        let addedAlertNA = WishlistAddProductStatus(frame: CGRect(x: 0, y: 360, width: 320, height: 0))
        addedAlertNA.generateBlurImage(self.view,frame:CGRect(x: 0, y: 312, width: 320, height: 360))
        addedAlertNA.clipsToBounds = true
        addedAlertNA.imageBlurView.frame = CGRect(x: 0, y: -312, width: 320, height: 360)
        addedAlertNA.textView.text = NSLocalizedString("productdetail.notaviable",comment:"")

        self.view.addSubview(addedAlertNA)
        self.isWishListProcess = false
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            addedAlertNA.frame = CGRect(x: 0, y: 312, width: 320, height: 48)
            addedAlertNA.prepareToClose()
        })

    }
    
    /**
     Gets product detail info from service
     */
    func loadDataFromService() {
        print("parametro para signals MG Iphone :::\(self.indexRowSelected)")
        
        self.type = ResultObjectType.Mg
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue, label: "\(name) - \(upc)")
            //TODO signals
            let signalsDictionary : [String:Any] = ["signals" : GRBaseService.getUseSignalServices()]
            let productService = ProductDetailService(dictionary: signalsDictionary)
            let eventType = self.fromSearch ? "clickdetails" : "pdpview"
            //let params = productService.buildParams(upc as String,eventtype:eventType,stringSearching: self.stringSearching,position:self.indexRowSelected)
            let params = productService.buildMustangParams(upc as String, skuId:self.sku as String)
            productService.callService(requestParams:params as AnyObject, successBlock: { (result: [String:Any]) -> Void in
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
                
                }) { (error:NSError) -> Void in
                    //var empty = IPOGenericEmptyView(frame:self.viewLoad.frame)
                    let empty = IPOGenericEmptyView(frame:CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46))
                    
                    self.name = NSLocalizedString("empty.productdetail.title",comment:"") as NSString
                    empty.returnAction = { () in
                        print("")
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
        let sku = result["sku"] as! [String:Any]
        let parentProducts = sku["parentProducts"] as! [[String:Any]]
        let parentProduct = parentProducts.first
        
        self.name = parentProduct!["displayName"] as! NSString
        
        if let resultPrice = result["price"] as? NSString {
            self.price = resultPrice
        }else {
            self.price = "0.0"
        }
        
        if let resultDetail = sku["description"] as? NSString {
            self.detail = resultDetail
        }else {
            self.detail = ""
        }
        
        self.saving = ""
        self.detail = self.detail.replacingOccurrences(of: "^", with: "\n") as NSString
        self.upc = parentProduct!["id"] as! NSString
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
        print(self.saving)
        
        
        self.listPrice = result["original_listprice"] as? NSString ?? ""
        self.characteristics = []
        if let characteristicsResult = result["characteristics"] as? NSArray {
            self.characteristics = characteristicsResult as! [[String:Any]]
        }
        
        if let resultNutrimentalInfo = result["nutritional"] as? [String:String] {
            self.nutrimentalInfo = resultNutrimentalInfo
        }else{
            self.nutrimentalInfo = [:]
        }
        
        self.ingredients = result["Ingredients"] as? String ?? ""
        
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
        
        if let images = parentProduct!["largeImageUrl"] as? [Any] {
            self.imageUrl = images
        }else{
            self.imageUrl = [(parentProduct!["largeImageUrl"] as! String as AnyObject)]
        }
        
        let freeShippingStr  = result["freeShippingItem"] as? NSString ?? ""
        self.freeShipping = "true" == freeShippingStr
        
        var numOnHandInventory : NSString = "0"
        if let numberOf = result["onHandInventory"] as? NSString{
            numOnHandInventory  = numberOf
        }
        self.onHandInventory  = numOnHandInventory
        
        self.isActive = sku["onSale"] as! Bool
        self.strisActive = (self.isActive! ? "true" : "false")
        
        if self.isActive == true {
            self.isActive = self.price.doubleValue > 0
        }
        
        self.strisPreorderable  = sku["isPreOrderable"] as? String ?? ""
        
        self.isPreorderable = "true" == self.strisPreorderable
        self.bundleItems = [Any]()
        if let bndl = sku["bundleLinks"] as?  [Any] {
            self.bundleItems = bndl
        }
        
        if let lowStock = result["lowStock"] as? Bool{
           self.isLowStock = lowStock
        }
        
        if let equivalence = result["equivalenceByPiece"] as? NSNumber {
            self.equivalenceByPiece = equivalence
        }
        
        if let equivalence = result["equivalenceByPiece"] as? NSString {
            if equivalence != "" {
                self.equivalenceByPiece =  NSNumber(value: equivalence.intValue as Int32)
            }
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
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearSearch.rawValue), object: nil)
        
        //FACEBOOKLOG
        FBSDKAppEvents.logEvent(FBSDKAppEventNameViewedContent, valueToSum:self.price.doubleValue, parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "productmg",FBSDKAppEventParameterNameContentID:self.upc])
        
    }
    
    //MARK: - Collection view Data Source
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
        return inCountRows
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellEmpty = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath)
        cellEmpty.frame =  CGRect(x: 0, y: 0, width: 2, height: 2)
        var cell : UICollectionViewCell? = nil
        let point = ((indexPath as NSIndexPath).section,(indexPath as NSIndexPath).row)
        if isLoading {
            return cellEmpty
        }
        var rowChose = (indexPath as NSIndexPath).row
        switch point {
        case (0,0) :
            if bundleItems.count == 0 {rowChose += 1}
            cell = cellForPoint(((indexPath as NSIndexPath).section,rowChose), indexPath: indexPath)
        case (0,1) :
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            cell = cellForPoint(((indexPath as NSIndexPath).section,rowChose), indexPath: indexPath)
        case (0,2) :
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            cell = cellForPoint(((indexPath as NSIndexPath).section,rowChose), indexPath: indexPath)
        case (0,3) :
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            cell = cellForPoint(((indexPath as NSIndexPath).section,rowChose), indexPath: indexPath)
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
            
            view.items = self.imageUrl
            view.delegate = self
            view.colors = self.colorItems
            view.sizes = self.sizesItems
            view.colorsViewDelegate = self
            view.collection.reloadData()
            view.promotions = [["text":"Nuevo" as AnyObject,"tagText":"N" as AnyObject,"tagColor":WMColor.yellow],["text":"Paquete" as AnyObject,"tagText":"P" as AnyObject,"tagColor":WMColor.light_blue],["text":"Sobre pedido" as AnyObject,"tagText":"Sp" as AnyObject,"tagColor":WMColor.light_blue],["text":"Ahorra más" as AnyObject,"tagText":"A+","tagColor":WMColor.light_red]]
            
            view.setAdditionalValues(listPrice as String, price: price as String, saving: saving as String)
            view.activePromotions(ProductDetailViewController.validateUpcPromotion(self.upc as String))
            currentHeaderView = view
            return view
        }
        if kind == UICollectionElementKindSectionHeader {
            let view = detailCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) 
            
            productDetailButton = ProductDetailButtonBarCollectionViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 56.0))
            productDetailButton!.upc = self.upc as String
            productDetailButton!.desc = self.name as String
            productDetailButton!.price = self.price as String
            productDetailButton!.isPesable  = self.isPesable
            productDetailButton!.validateIsInList(self.upc as String)
            productDetailButton!.isActive = self.strisActive
            productDetailButton!.onHandInventory = self.onHandInventory as String
            productDetailButton!.isPreorderable = self.strisPreorderable
            productDetailButton!.listButton.isEnabled = !self.isGift
            productDetailButton!.idListSelect =  self.idListFromlistFind
            
            productDetailButton!.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButton!.listButton.isSelected = UserCurrentSession.sharedInstance.userHasUPCUserlist(self.upc as String)
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
    
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        var hForCell : CGFloat = 0.0
        let point = (indexPath.section,indexPath.row)
        var rowChose = indexPath.row
        switch point {
        case (0,0) :
            if bundleItems.count == 0 {rowChose += 1}
            hForCell = sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        case (0,1) :
            if bundleItems.count == 0 {rowChose += 1}
            if msi.count == 0 {rowChose += 1}
            hForCell = sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        case (0,2) :
            if msi.count == 0 {rowChose += 1}
            if characteristics.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            hForCell = sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        case (0,3) :
            hForCell = sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        default :
            hForCell = 0
        }
        return CGSize(width: self.view.frame.width , height: hForCell);
    }
    
    class func validateUpcPromotion(_ upc:String) -> Bool{
        let upcs =  UserCurrentSession.sharedInstance.upcSearch
        return upcs!.contains(upc)
    }
    
    func cellForPoint(_ point:(Int,Int),indexPath: IndexPath) -> UICollectionViewCell? {
        var cell : UICollectionViewCell? = nil
        switch point {
        case (0,0) :
            if bundleItems.count != 0 {
                let cellPromotion = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "cellBundleitems", for: indexPath) as? ProductDetailBundleCollectionViewCell
                cellPromotion!.delegate = self
                cellPromotion!.itemsUPC = bundleItems as NSArray
                cellPromotion!.type = "MG"
                cell = cellPromotion
            } else {
                return cellForPoint(((indexPath as NSIndexPath).section,1),indexPath: indexPath)
            }
        case (0,1) :
            if  msi.count != 0 {
                let cellPromotion = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "msiCell", for: indexPath) as! ProductDetailMSICollectionViewCell
                cellPromotion.priceProduct = self.price
                cellPromotion.setValues(msi)
                cell = cellPromotion
            }else {
                return cellForPoint(((indexPath as NSIndexPath).section,2),indexPath: indexPath)
            }
        case (0,2) :
            if characteristics.count != 0 {
                let cellCharacteristics = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "cellCharacteristics", for: indexPath) as! ProductDetailCharacteristicsCollectionViewCell
                cellCharacteristics.setValues(characteristics)
                cellCharacteristics.superview?.isUserInteractionEnabled = true
                cell = cellCharacteristics
            }else{
                return cellForPoint(((indexPath as NSIndexPath).section,3),indexPath: indexPath)
            }
        case (0,3) :
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
    
    /**
     validate open Container info from product
     
     - parameter open:                     is open
     - parameter viewShow:                 view where present container
     - parameter additionalAnimationOpen:  animation open block
     - parameter additionalAnimationClose: anipation close block
     */
    func opencloseContainer(_ open:Bool,viewShow:UIView,additionalAnimationOpen:@escaping (() -> Void),additionalAnimationClose:(() -> Void)) {
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
    func openContainer(_ viewShow:UIView,additionalAnimationOpen:@escaping (() -> Void)) {
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
     
     - parameter additionalAnimationClose: block
     - parameter completeClose:            block
     */
    func closeContainer(_ additionalAnimationClose:@escaping (() -> Void),completeClose:@escaping (() -> Void)) {
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
    
    //MARK: -  ProductDetailButtonBarCollectionViewCellDelegate
    /**
     Builds an image to share
     */
    func shareProduct() {
        let imageHead = UIImage(named:"detail_HeaderMail")
        let imageHeader = UIImage(from: self.headerView)
        //let headers = [0]
        
        let imagen = UIImage(from: currentHeaderView)
        
        //Event
         BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: "\(self.name) - \(self.upc)")
        
        //let screen = self.detailCollectionView.screenshotOfHeadersAtSections( NSSet(array:headers), footersAtSections: nil, rowsAtIndexPaths: NSSet(array: items))
        
        let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx/Busqueda.aspx?Text=\(self.upc)")
        let imgResult = UIImage.verticalImage(from: [imageHead!,imageHeader,imagen])
        
        //let urlWmart = NSURL(string: "walmartMG://UPC_\(self.upc)")
        if urlWmart != nil {
            let controller = UIActivityViewController(activityItems: [self,imgResult,urlWmart!], applicationActivities: nil)
            self.navigationController!.present(controller, animated: true, completion: nil)
        }
    }
    //MARK: activityViewControllerDelegate
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any{
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
    /**
     Reloads shopping cart button
     
     - parameter sender: sender
     */
    func endUpdatingShoppingCart(_ sender:AnyObject) {
        self.productDetailButton?.reloadShoppinhgButton()
    }
    
    //MARK: Color Size Functions
    /**
     Gets details objects from facets
     
     - returns: dictionary wit facet details
     */
    func getFacetsDetails() -> [String:Any]{
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
                var values = facetsDetails[label] as? [Any]
                if values == nil{ values = []}
                let itemToAdd = ["value":detail["unit"] as! String, "enabled": (details.count == 1 || label == "Color") ? 1 : 0, "type": label,"selected":false] as [String : Any]
                if !(values! as NSArray).contains(itemToAdd) {
                    values!.append(itemToAdd as AnyObject)
                }
                facetsDetails[label] = values as AnyObject?
                itemDetail[label] = detail["unit"] as? String
                count += 1
                if selected {
                    self.selectedDetailItem![label] = unit
                }
            }
            var detailsValues = facetsDetails["itemDetails"] as? [Any]
            if detailsValues == nil{ detailsValues = []}
            detailsValues!.append(itemDetail as AnyObject)
            facetsDetails["itemDetails"] = detailsValues as AnyObject?
        }
        return self.selectedDetailItem?.count > 0 ? self.marckSelectedDetails(facetsDetails) :  facetsDetails
    }
    
    /**
     Mark as selected the Details of the first upc
     
     - parameter facetsDetails: dictionary wit facet details
     
     - returns: dictionary wit facet details
     */
    func marckSelectedDetails(_ facetsDetails: [String:Any]) -> [String:Any] {
        var selectedDetails: [String:Any] = [:]
        let filteredKeys = self.getFilteredKeys(facetsDetails)
        // Primer elemento
        let itemsFirst: [[String:Any]] = facetsDetails[filteredKeys.first!] as! [[String:Any]]
        let selecteFirst =  self.selectedDetailItem![filteredKeys.first!]!
        var values: [Any] = []
        for item in itemsFirst{
            let label = item["type"] as! String
            let unit = item["value"] as! String
            values.append(["value":unit, "enabled": 1, "type": label,"selected": (unit == selecteFirst)])
        }
        selectedDetails[selecteFirst] = values as AnyObject?
        
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
            selectedDetails[selectedSecond] = valuesSecond as AnyObject?
        }
        selectedDetails["itemDetails"] = facetsDetails["itemDetails"]
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
    func getUpc(_ itemsSelected: [String:String]) -> String
    {
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
    
    //MARK: ProductDetailColorSizeDelegate
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
            self.reloadViewWithData(facet as [String:Any])
        }
    }
    
    func instanceOfQuantitySelector(_ frame:CGRect) -> GRShoppingCartQuantitySelectorView? {
        var instance: GRShoppingCartQuantitySelectorView? = nil
        if self.isPesable {
            instance = GRShoppingCartWeightSelectorView(frame: frame, priceProduct: NSNumber(value: self.price.doubleValue as Double),equivalenceByPiece:equivalenceByPiece,upcProduct:self.upc as String)
        } else {
            instance = GRShoppingCartQuantitySelectorView(frame: frame, priceProduct: NSNumber(value: self.price.doubleValue as Double),upcProduct:self.upc as String)
        }
        return instance
    }
    
    func showMessageWishList(_ message:String) {
        let addedAlertWL = WishlistAddProductStatus(frame: CGRect(x: self.detailCollectionView.frame.minX, y: self.detailCollectionView.frame.minY +  314, width: self.detailCollectionView.frame.width, height: 0))
        addedAlertWL.generateBlurImage(self.view,frame:CGRect(x: self.detailCollectionView.frame.minX, y: 270, width: self.detailCollectionView.frame.width, height: 44))
        addedAlertWL.clipsToBounds = true
        addedAlertWL.imageBlurView.frame = CGRect(x: self.detailCollectionView.frame.minX, y: 0, width: self.detailCollectionView.frame.width, height: 44)
        addedAlertWL.textView.text = message
        self.view.addSubview(addedAlertWL)
        self.isWishListProcess = false
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            addedAlertWL.frame = CGRect(x: self.detailCollectionView.frame.minX,y: self.detailCollectionView.frame.minY + 270, width: self.detailCollectionView.frame.width, height: 96)
        }, completion: { (complete:Bool) -> Void in
            UIView.animate(withDuration: 0.5, delay: 1, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
                addedAlertWL.frame = CGRect(x: addedAlertWL.frame.minX, y: self.detailCollectionView.frame.minY + 314.0, width: addedAlertWL.frame.width, height: 0)
            }) { (complete:Bool) -> Void in
                self.detailCollectionView.isScrollEnabled = true
                addedAlertWL.removeFromSuperview()
            }
        }) 
        
        
    }
    
    //MARK: ListSelectorDelegate
    func listSelectorDidShowList(_ listId: String, andName name:String) {
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? UserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func listSelectorDidShowListLocally(_ list: List) {
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? UserListDetailViewController {
            vc.listEntity = list
            vc.listName = list.name
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func listSelectorDidAddProduct(inList listId:String) {
        let frameDetail = CGRect(x: 320.0, y: 0.0, width: 320.0, height: 360.0)
        self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
        self.selectQuantityGR!.generateBlurImage(self.view, frame:CGRect(x: 0.0, y: 0.0, width: 320.0, height: 360.0))
        self.selectQuantityGR!.closeAction = { () in
            self.removeListSelector(action: nil)
        }
        
        self.selectQuantityGR!.addToCartAction = { (quantity:String) in
            /*if quantity.toInt() == 0 {
             self.listSelectorDidDeleteProduct(inList: listId)
             }
             else {*/
            if Int(quantity) <= 20000 {
                
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
                self.alertView!.setMessage(NSLocalizedString("list.message.addingProductToList", comment:""))
                
                let service = GRAddItemListService()
                let pesable = self.isPesable ? "1" : "0"
                //let productObject = service.buildProductObject(upc: self.upc as String, quantity:Int(quantity)!,pesable:pesable,active:self.isActive)
               let productObject =  service.buildItemMustang(self.upc as String, sku: self.sku as String, quantity: Int(quantity)!)
                service.callService(service.buildItemMustangObject(idList: listId, upcs: [productObject]),
                                    successBlock: { (result:[String:Any]) -> Void in
                                        self.alertView!.setMessage(NSLocalizedString("list.message.addProductToListDone", comment:""))
                                        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action: WMGAIUtils.ACTION_ADD_TO_LIST.rawValue, label:"\(self.name) \(self.upc) ")
                                        
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
                
            }else{
                
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                let secondMessage = NSLocalizedString("productdetail.notaviableinventorywe",comment:"")
                let msgInventory = "\(firstMessage) 20000 \(secondMessage)"
                alert!.setMessage(msgInventory)
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            }
            
            //}
        }
        
        //--
        
        self.listSelectorContainer!.addSubview(self.selectQuantityGR!)
        
        UIView.animate(withDuration: 0.5,
                                   animations: { () -> Void in
                                    self.listSelectorController!.view.frame = CGRect(x: -320.0, y: 0.0, width: 320.0, height: 360.0)
                                    self.selectQuantityGR!.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 360.0)
            }, completion: { (finished:Bool) -> Void in
                
            }
        )
    }
    
    func listSelectorDidDeleteProduct(inList listId:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone:UIImage(named:"done"),imageError:UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToList", comment:""))
        //TODO llamar al servicio que trae las LISTAS
//        let detailService = UserListDetailService()
//        detailService.buildParams(listId)
//        detailService.callService([:],
//                                  successBlock: { (result:[String:Any]) -> Void in
//                                    let service = GRDeleteItemListService()
//                                    service.callService(service.buildParams(self.upc as String),
//                                        successBlock: { (result:[String:Any]) -> Void in
//                                            self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToListDone", comment:""))
//                                            self.alertView!.showDoneIcon()
//                                            self.alertView!.afterRemove = {
//                                                self.removeListSelector(action: nil)
//                                            }
//                                            //Event
//                                            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_PRODUCT_MYLIST.rawValue, label: "\(self.name) - \(self.upc)")
//                                            
//                                        }, errorBlock: { (error:NSError) -> Void in
//                                            print("Error at remove product from list: \(error.localizedDescription)")
//                                            self.alertView!.setMessage(error.localizedDescription)
//                                            self.alertView!.showErrorIcon("Ok")
//                                            self.alertView!.afterRemove = {
//                                                self.removeListSelector(action: nil)
//                                            }
//                                        }
//                                    )
//            },
//                                  errorBlock: { (error:NSError) -> Void in
//                                    print("Error at retrieve list detail")
//            }
//        )
    }
    
    func listSelectorDidAddProductLocally(inList list:List) {
        
        let frameDetail = CGRect(x: 320.0, y: 0.0, width: 320.0, height: 360.0)
        self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
        self.selectQuantityGR!.generateBlurImage(self.view, frame:CGRect(x: 0.0, y: 0.0, width: 320.0, height: 360.0))
        self.selectQuantityGR!.closeAction = { () in
            self.removeListSelector(action: nil)
        }
        self.selectQuantityGR!.addToCartAction = { (quantity:String) in
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            
            let detail = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as? Product
            detail!.upc = self.upc as String
            detail!.desc = self.name as String
            detail!.price = self.price
            detail!.quantity = NSNumber(value: Int(quantity)! as Int)
            detail!.type = NSNumber(value: self.isPesable as Bool)
            detail!.list = list
            
            if self.imageUrl.count > 0 {
                detail!.img = self.imageUrl[0] as! NSString as String
            }
            
            BaseController.sendAnalytics(WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue , action:WMGAIUtils.ACTION_ADD_TO_LIST.rawValue , label:"\(self.name as String) \(self.upc as String)")
            
            
            var error: NSError? = nil
            do {
                try context.save()
            } catch let error1 as NSError {
                error = error1
            } catch {
                fatalError()
            }
            if error != nil {
                print(error!.localizedDescription)
            }
            
            let count:Int = list.products.count
            list.countItem = NSNumber(value: count as Int)
            
            error = nil
            do {
                try context.save()
            } catch let error1 as NSError {
                error = error1
            } catch {
                fatalError()
            }
            if error != nil {
                print(error!.localizedDescription)
            }
            
            self.removeListSelector(action: nil)
            
            //TODO: Add message
            self.showMessageWishList("Se agregó a la lista")
            
            self.productDetailButton!.listButton.isSelected = UserCurrentSession.sharedInstance.userHasUPCUserlist(self.upc as String)
            
            
        }
        self.listSelectorContainer!.addSubview(self.selectQuantityGR!)
        
        UIView.animate(withDuration: 0.5,
                                   animations: { () -> Void in
                                    self.listSelectorController!.view.frame = CGRect(x: -320.0, y: 0.0, width: 320.0, height: 360.0)
                                    self.selectQuantityGR!.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 360.0)
            }, completion: { (finished:Bool) -> Void in
                
            }
        )
    }
    
    func listSelectorDidDeleteProductLocally(_ product:Product, inList list:List) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        context.delete(product)
        do {
            try context.save()
        } catch {
            abort()
        }
        
        let count:Int = list.products.count
        list.countItem = NSNumber(value: count as Int)
        do {
            try context.save()
        } catch  {
            abort()
        }
        
        self.removeListSelector(action: nil)
        
    }
    
    func listSelectorDidClose() {
        self.removeListSelector(action: nil)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_ADD_TO_LIST.rawValue, action: WMGAIUtils.ACTION_CANCEL_ADD_TO_LIST.rawValue, label: "")
        
    }
    
    func shouldDelegateListCreation() -> Bool {
        return false
    }
    
    func listSelectorDidCreateList(_ name:String) {
        
    }
}
