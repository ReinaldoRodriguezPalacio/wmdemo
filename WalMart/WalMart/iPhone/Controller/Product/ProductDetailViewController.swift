//
//  ProductoDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailViewController : IPOBaseController,UICollectionViewDataSource,UICollectionViewDelegate ,ProductDetailCrossSellViewDelegate,ProductDetailButtonBarCollectionViewCellDelegate ,ProductDetailBannerCollectionViewDelegate,UIActivityItemSource, ProductDetailColorSizeDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var detailCollectionView: UICollectionView!
    
    var viewLoad : WMLoadingView!
    var msi : NSArray = []
    var upc : NSString = ""
    var name : NSString = ""
    var detail : NSString = ""
    var saving : NSString = ""
    var price : NSString = ""
    var listPrice : NSString = ""
    var comments : NSString = ""
    var imageUrl : [AnyObject] = []
    var characteristics : [AnyObject] = []
    var bundleItems : [AnyObject] = []
    var colorItems : [AnyObject] = []
    var sizesItems : [AnyObject] = []
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
    var facets: [[String:AnyObject]]? = nil
    var facetsDetails: [String:AnyObject]? = nil
    var selectedDetailItem: [String:String]? = nil
    
    var fromSearch =  false
    var idListFromlistFind = ""
    var productDeparment:String = ""
    
    var indexRowSelected : String = ""
    var completeDelete : (() -> Void)? = nil
    var detailOf: String! = ""
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewLoad = WMLoadingView(frame: CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
        self.view.addSubview(viewLoad)
        
        viewLoad.startAnnimating(self.isVisibleTab)
        isLoading = true
        self.loadDataFromService()
        
        detailCollectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        detailCollectionView.registerClass(ProductDetailBannerCollectionViewCell.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage")
        detailCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "emptyCell")
        detailCollectionView.registerClass(ProductDetailMSICollectionViewCell.self, forCellWithReuseIdentifier: "msiCell")
        detailCollectionView.registerClass(ProductDetailCharacteristicsCollectionViewCell.self, forCellWithReuseIdentifier: "cellCharacteristics")
        detailCollectionView.registerClass(ProductDetailBundleCollectionViewCell.self, forCellWithReuseIdentifier: "cellBundleitems")
        detailCollectionView.registerClass(ProductDetailCrossSellCollectionViewCell.self, forCellWithReuseIdentifier: "crossSellCell")
        
        if let layout = detailCollectionView.collectionViewLayout as? CSStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, 314)
            layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(self.view.frame.size.width, 314)
            layout.itemSize = CGSizeMake(self.view.frame.size.width, layout.itemSize.height)
            layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 56.0)
            layout.disableStickyHeaders = false

            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProductDetailViewController.closeContainerDetail), name: CustomBarNotification.SuccessAddUpdateCommentCart.rawValue, object: nil)
        }
        
        headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 46))
        headerView.backgroundColor = WMColor.light_light_gray
        let buttonBk = UIButton(frame: CGRectMake(0, 0, 46, 46))
        buttonBk.setImage(UIImage(named:"BackProduct"), forState: UIControlState.Normal)
        buttonBk.addTarget(self, action: #selector(ProductDetailViewController.backButton), forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(buttonBk)
        
        titlelbl = UILabel(frame: CGRectMake(46, 0, self.view.frame.width - (46 * 2), 46))
        titlelbl.textAlignment = .Center
        titlelbl.text = self.name as String
        titlelbl.numberOfLines = 2
        titlelbl.font = WMFont.fontMyriadProRegularOfSize(14)
        titlelbl.textColor = WMColor.light_blue
        titlelbl.adjustsFontSizeToFitWidth = true
        titlelbl.minimumScaleFactor = 9 / 12
        
        headerView.addSubview(titlelbl)
        self.view.addSubview(headerView)
        
        gestureCloseDetail = UITapGestureRecognizer(target: self, action: #selector(ProductDetailViewController.closeActionView))
        gestureCloseDetail.enabled = false
        
        self.containerinfo = UIView()
        self.containerinfo.clipsToBounds = true
        
        self.view.addSubview(containerinfo)
        BaseController.setOpenScreenTagManager(titleScreen: self.titlelbl.text!, screenName:self.getScreenGAIName() )
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProductDetailViewController.endUpdatingShoppingCart(_:)), name: CustomBarNotification.UpdateBadge.rawValue, object: nil)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    /**
     Close or show action view if is necesary
     */
    func closeActionView () {
        if isShowProductDetail {
            closeProductDetail()
        }
        if isShowShoppingCart {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.productDetailButton?.reloadShoppinhgButton()
                self.isShowShoppingCart = false
                self.selectQuantity!.frame = CGRectMake(0, 360, 320, 0)
                self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
                }, completion: { (animated:Bool) -> Void in
                    if self.selectQuantity != nil {
                        self.selectQuantity!.removeFromSuperview()
                        self.selectQuantity = nil
                        self.detailCollectionView.scrollEnabled = true
                        self.gestureCloseDetail.enabled = false
                    }
            })
        }
    }
    
    

    //MARK: TableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    /**
     Returns the size for indexPath
     
     - parameter point:     point
     - parameter indexPath: tableViewIndexPath
     
     - returns: CGFloat
     */
    func sizeForIndexPath (point:(Int,Int),indexPath: NSIndexPath!)  -> CGFloat {
        switch point {
        case (0,0) :
            if  bundleItems.count != 0 {
                return 170.0
            }
            return sizeForIndexPath ((indexPath.section,1),indexPath: indexPath)
        case (0,1):
            if  msi.count != 0 {
                return (CGFloat(msi.count) * 14) + 84.0
            }
            return sizeForIndexPath ((indexPath.section,2),indexPath: indexPath)
        case (0,2) :
            if characteristics.count != 0 {
                let size = ProductDetailCharacteristicsCollectionViewCell.sizeForCell(self.view.frame.width - 30,values:characteristics)
                return size + 50
            }
            return sizeForIndexPath ((indexPath.section,3),indexPath: indexPath)
        case (0,3) :
            return 210
        default :
            return 210
        }
    }
    

    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let headerView = UIView()
        switch section {
        case 0:
            headerView.frame = CGRectMake(0, 0, self.view.frame.width, 46)
            break;
        default:
            
            if isLoading {
                return UIView()
            }
            
            productDetailButton = ProductDetailButtonBarCollectionViewCell(frame: CGRectMake(0, 0, self.view.frame.width, 56.0))
            productDetailButton!.upc = self.upc as String
            productDetailButton!.desc = self.name as String
            productDetailButton!.price = self.price as String
            productDetailButton!.price = self.price as String
            productDetailButton!.isActive = self.strisActive
            productDetailButton!.onHandInventory = self.onHandInventory as String
            productDetailButton!.isPreorderable = self.strisPreorderable
            productDetailButton!.productDepartment = self.productDeparment
            productDetailButton!.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButton!.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCWishlist(self.upc as String)
            
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
        self.navigationController!.popViewControllerAnimated(true)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BACK.rawValue, label: "")
    }
    
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.0
        default:
            return 56.0
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewLoad.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
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
    func goTODetailProduct(upc: String, items: [[String : String]], index: Int, imageProduct: UIImage?, point: CGRect, idList: String) {
        //Event
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BUNDLE_PRODUCT_DETAIL_TAPPED.rawValue, label: "\(self.name) - \(self.upc)")
        
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = items
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
        crossService.callService(requestParams:self.upc, successBlock: { (result:NSArray?) -> Void in
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
    /**
     Shows product detail information in popup view
     */
    func showProductDetail() {
        if isShowShoppingCart {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.isShowShoppingCart = false
                self.selectQuantity!.frame = CGRectMake(0, 360, 320, 0)
                //self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
                }, completion: { (animated:Bool) -> Void in
                    if self.selectQuantity != nil {
                        self.selectQuantity!.removeFromSuperview()
                        self.selectQuantity = nil
                        self.detailCollectionView.scrollEnabled = true
                        self.gestureCloseDetail.enabled = false
                    }
            })
        }
        
        //EVENT
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_INFORMATION.rawValue, label: "\(self.name) - \(self.upc)")
        
        self.detailCollectionView.scrollsToTop = true
        self.detailCollectionView.scrollEnabled = false
        gestureCloseDetail.enabled = true
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.detailCollectionView.scrollRectToVisible(CGRectMake(0, 0, self.detailCollectionView.frame.width,  self.detailCollectionView.frame.height ), animated: false)
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
    func addOrRemoveToWishList(upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,category:String,added:(Bool) -> Void) {
        
        self.isWishListProcess = true
        
        self.addOrRemoveToWishListBlock = {() in
            /*if UserCurrentSession.sharedInstance().userSigned == nil {
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
                let frameWishListbtn = self.view.convertRect(self.view.frame, fromView:self.productDetailButton?.listButton)
                let addedAlertWL = WishlistAddProductStatus(frame: CGRectMake(0, frameWishListbtn.origin.y - 48, 320, 0))
                addedAlertWL.generateBlurImage(self.view,frame:CGRectMake(0, frameWishListbtn.origin.y, 320, 360))
                
                addedAlertWL.clipsToBounds = true
                addedAlertWL.imageBlurView.frame = CGRectMake(0, -312, 320, 360)
                if addItem {
                    let serviceWishList = AddItemWishlistService()
                    serviceWishList.callService(upc, quantity: "1", comments: "",desc:desc,imageurl:imageurl,price:price,isActive:isActive,onHandInventory:onHandInventory,isPreorderable:isPreorderable,category:self.productDeparment, successBlock: { (result:NSDictionary) -> Void in
                        addedAlertWL.textView.text = NSLocalizedString("wishlist.ready",comment:"")
                        added(true)
            
                        //Event
                         //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ADD_WISHLIST.rawValue, label: "\(self.name) - \(self.upc)")
                        
                        self.view.addSubview(addedAlertWL)
                        self.isWishListProcess = false
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            
                            addedAlertWL.frame = CGRectMake(0, frameWishListbtn.origin.y - 48 , 320, 48)
                            addedAlertWL.prepareToClose()
                            self.gestureCloseDetail.enabled = false
                            self.detailCollectionView.scrollEnabled = true
                        })
                        
                        
                        }) { (error:NSError) -> Void in
                            self.isWishListProcess = false
                            if error.code != -100 {
                                added(false)
                                addedAlertWL.textView.text = NSLocalizedString("conection.error",comment:"")
                                self.view.addSubview(addedAlertWL)
                                UIView.animateWithDuration(0.3, animations: { () -> Void in
                                    addedAlertWL.frame = CGRectMake(0, frameWishListbtn.origin.y - 48, 320 , 48)
                                    addedAlertWL.prepareToClose()
                                    self.gestureCloseDetail.enabled = false
                                    self.detailCollectionView.scrollEnabled = true
                                })
                            }
                    }
                } else {
                    let serviceWishListDelete = DeleteItemWishlistService()
                    serviceWishListDelete.callService(upc, successBlock: { (result:NSDictionary) -> Void in
                        added(true)
                        addedAlertWL.textView.text = NSLocalizedString("wishlist.deleted",comment:"")
                        self.view.addSubview(addedAlertWL)
                        self.isWishListProcess = false
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            addedAlertWL.frame = CGRectMake(0, frameWishListbtn.origin.y - 48, 320, 48)
                            addedAlertWL.prepareToClose()
                            self.gestureCloseDetail.enabled = false
                            self.detailCollectionView.scrollEnabled = true
                        })
                        
                        //Event
                         //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_WISHLIST.rawValue, label: "\(self.name) - \(self.upc)")
                        
                        
                        }, errorBlock: { (error:NSError) -> Void in
                             self.isWishListProcess = false
                            added(false)
                            if error.code != -100 {
                                addedAlertWL.textView.text = NSLocalizedString("conection.error",comment:"")
                                self.view.addSubview(addedAlertWL)
                                UIView.animateWithDuration(0.3, animations: { () -> Void in
                                    addedAlertWL.frame = CGRectMake(0, frameWishListbtn.origin.y - 48, 320, 48)
                                    addedAlertWL.prepareToClose()
                                    self.gestureCloseDetail.enabled = false
                                    self.detailCollectionView.scrollEnabled = true
                                })
                            }
                    })
                }
            //}
        }
        
        if isShowShoppingCart {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.isShowShoppingCart = false
                self.selectQuantity!.frame = CGRectMake(0, 360, 320, 0)
                //self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
                }, completion: { (animated:Bool) -> Void in
                    if self.selectQuantity != nil {
                        self.selectQuantity!.removeFromSuperview()
                        self.selectQuantity = nil
                        self.gestureCloseDetail.enabled = false
                        self.detailCollectionView.scrollEnabled = true
                    }
            })
        }
        
        closeProductDetail()
        
        
        self.detailCollectionView.scrollEnabled = false
        gestureCloseDetail.enabled = true
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
    func addProductToShoppingCart(upc:String,desc:String,price:String,imageURL:String, comments:String)
    {
        if selectQuantity == nil {
            if isShowProductDetail == true {
                self.closeProductDetail()
            }
            
            isShowShoppingCart = true
             let finalFrameOfQuantity = CGRectMake(0, 0, 320, 360)
            
            selectQuantity = ShoppingCartQuantitySelectorView(frame:CGRectMake(0, 360, 320, 360),priceProduct:NSNumber(double:self.price.doubleValue),upcProduct:upc)
            //selectQuantity!.priceProduct = NSNumber(double:self.price.doubleValue)
            selectQuantity!.frame = CGRectMake(0, 360, 320, 0)
            selectQuantity!.closeAction =
                { () in
                    UIView.animateWithDuration(0.5,
                        animations: { () -> Void in
                            self.productDetailButton?.reloadShoppinhgButton()
                            self.isShowShoppingCart = false
                            self.selectQuantity!.frame = CGRectMake(0, 360, 320, 0)
                            //self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
                        },
                        completion: { (animated:Bool) -> Void in
                            if self.selectQuantity != nil {
                                self.selectQuantity!.removeFromSuperview()
                                self.selectQuantity = nil
                                self.gestureCloseDetail.enabled = false
                                self.detailCollectionView.scrollEnabled = true
                            }
                        }
                    )
            }
            //Event
             //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_KEYBOARD.rawValue, label: "\(self.name) - \(self.upc)")
            
           // selectQuantity!.generateBlurImage(self.view,frame:finalFrameOfQuantity)
            
         
            selectQuantity!.addToCartAction =
                { (quantity:String) in
                    //let quantity : Int = quantity.toInt()!
                    let maxProducts = (self.onHandInventory.integerValue <= 5 || self.productDeparment == "d-papeleria") ? self.onHandInventory.integerValue : 5
                    if maxProducts >= Int(quantity) {
                        //let params = CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageURL, price: price, quantity: quantity,onHandInventory:self.onHandInventory,)
                        let params = self.buildParamsUpdateShoppingCart(quantity)
                        self.gestureCloseDetail.enabled = false
                        self.detailCollectionView.scrollEnabled = true
                        self.isShowShoppingCart = false
                        
                        if UserCurrentSession.sharedInstance().userHasUPCShoppingCart(String(self.upc)) {
                            //BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_UPDATE_SHOPPING_CART.rawValue, label: self.name as String)
                        } else {
                            //BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label: self.name as String)
                        }
        

                
                        UIView.animateWithDuration(0.2,
                            animations: { () -> Void in
                                self.productDetailButton?.reloadShoppinhgButton()
                                self.selectQuantity!.frame = CGRectMake(0, 360, 320, 0	)
                               // self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
                            },
                            completion: { (animated:Bool) -> Void in
                                self.selectQuantity!.removeFromSuperview()
                                self.selectQuantity = nil
                                self.gestureCloseDetail.enabled = false
                                self.detailCollectionView.scrollEnabled = true
                                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
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
            
            self.detailCollectionView.scrollEnabled = false
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.detailCollectionView.scrollRectToVisible(CGRectMake(0, 0, self.detailCollectionView.frame.width,  self.detailCollectionView.frame.height ), animated: false)
                }, completion: { (complete:Bool) -> Void in
                    self.selectQuantity!.clipsToBounds = true
                    self.view.addSubview(self.selectQuantity!)
                    
                    //self.selectQuantity?.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
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
     Builds an NSDictionary with data to add product to shopping cart
     
     - parameter quantity: quantity of product
     
     - returns: NSDictionary
     */
    func buildParamsUpdateShoppingCart(quantity:String) -> [NSObject:AnyObject] {
        var imageUrlSend = ""
        if self.imageUrl.count > 0 {
            imageUrlSend = self.imageUrl[0] as! NSString as String
        }
        let pesable = isPesable ? "1" : "0"
        return ["upc":self.upc,"desc":self.name,"imgUrl":imageUrlSend,"price":self.price,"quantity":quantity,"onHandInventory":self.onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":self.strisPreorderable,"category":self.productDeparment]
    }
    
    
    func closeContainerDetail(){
        if selectQuantity != nil {
            
        gestureCloseDetail.enabled = false
        self.detailCollectionView.scrollEnabled = true
        self.closeContainer({ () -> Void in
            
            }, completeClose: { () -> Void in
                self.isShowShoppingCart = false
                
                UserCurrentSession.sharedInstance().loadMGShoppingCart
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
            UserCurrentSession.sharedInstance().loadMGShoppingCart
                { () -> Void in
                    self.productDetailButton?.reloadShoppinhgButton()
            }
        }
        
    }
    
    //MARK: scrollViewDelegate
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
       
        if isShowProductDetail == true &&  isShowShoppingCart == false{
            if viewDetail == nil {
                startAnimatingProductDetail()
            } else {
                closeProductDetail()
            }
        }
        if isShowShoppingCart == true && isShowProductDetail == false{
            if selectQuantity != nil {
                let finalFrameOfQuantity = CGRectMake(0, 0, 320, 360)
                
                selectQuantity!.clipsToBounds = true
                self.view.addSubview(selectQuantity!)
                self.detailCollectionView.scrollEnabled = false
                gestureCloseDetail.enabled = true
                //self.selectQuantity!.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
               
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.productDetailButton?.setOpenQuantitySelector()
                    self.selectQuantity!.frame = finalFrameOfQuantity
                    self.selectQuantity!.imageBlurView.frame = finalFrameOfQuantity
                    }, completion: { (complete:Bool) -> Void in
                        self.productDetailButton?.addToShoppingCartButton.setTitleColor(WMColor.light_blue, forState: UIControlState.Normal)
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
        let finalFrameOfQuantity = CGRectMake(0, 0, 320, 360)
        viewDetail = ProductDetailTextDetailView(frame: CGRectMake(0,360, 320, 0))
        viewDetail!.generateBlurImage(self.view,frame:finalFrameOfQuantity)
        //self.viewDetail!.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
        viewDetail.setTextDetail(detail as String)
        viewDetail.closeDetail = { () in
            self.isShowProductDetail = true
            self.closeProductDetail()
        }
        self.view.addSubview(viewDetail)
        
        self.productDetailButton?.reloadButton()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.viewDetail!.frame = finalFrameOfQuantity
            self.viewDetail!.imageBlurView.frame = finalFrameOfQuantity
            //self.viewDetail.frame = CGRectMake(0, 0, self.tabledetail.frame.width, self.tabledetail.frame.height - 145)
            self.productDetailButton?.deltailButton.selected = true
        })
    }
    /**
     Close product detail view
     */
    func closeProductDetail () {
        if isShowProductDetail == true {
        isShowProductDetail = false
            gestureCloseDetail.enabled = false
        self.detailCollectionView.scrollEnabled = true
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.viewDetail?.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
            self.viewDetail.frame = CGRectMake(0,360, 320, 0)
            }) { (ended:Bool) -> Void in
                if self.viewDetail != nil {
                self.viewDetail.removeFromSuperview()
                self.viewDetail = nil
                self.productDetailButton?.deltailButton.selected = false
                //self.productDetailButton?.reloadButton()
                }
        }
        }
    }
    
    /**
     Presents a image in ImageDisplayCollectionViewController
     
     - parameter indexPath: indexPath or image to show
     */
    func sleectedImage(indexPath: NSIndexPath) {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_PRODUCT_DETAIL_IMAGE_TAPPED.rawValue, label: "\(self.name) - \(self.upc)")
        
        let controller = ImageDisplayCollectionViewController()
        controller.name = self.name as String
        controller.imagesToDisplay = imageUrl
        controller.currentItem = indexPath.row
        controller.type = self.type.rawValue
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    /**
     Shows not aviable product message
     */
    func showMessageProductNotAviable() {
        self.detailCollectionView.scrollRectToVisible(CGRectMake(0, 0, self.detailCollectionView.frame.width,  self.detailCollectionView.frame.height ), animated: false)
        let addedAlertNA = WishlistAddProductStatus(frame: CGRectMake(0, 360, 320, 0))
        addedAlertNA.generateBlurImage(self.view,frame:CGRectMake(0, 312, 320, 360))
        addedAlertNA.clipsToBounds = true
        addedAlertNA.imageBlurView.frame = CGRectMake(0, -312, 320, 360)
        addedAlertNA.textView.text = NSLocalizedString("productdetail.notaviable",comment:"")

        self.view.addSubview(addedAlertNA)
        self.isWishListProcess = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            addedAlertNA.frame = CGRectMake(0, 312, 320, 48)
            addedAlertNA.prepareToClose()
        })

    }
    
    /**
     Gets product detail info from service
     */
    func loadDataFromService() {
        
        
        print("parametro para signals MG Iphone :::\(self.indexRowSelected)")
        
        self.type = ResultObjectType.Mg
        
            let signalsDictionary : NSDictionary = NSDictionary(dictionary: ["signals" : GRBaseService.getUseSignalServices()])
            let productService = ProductDetailService(dictionary: signalsDictionary)
            let eventType = self.fromSearch ? "clickdetails" : "pdpview"
            let params = productService.buildParams(upc as String,eventtype:eventType,stringSearching: self.stringSearching,position:self.indexRowSelected)
            productService.callService(requestParams:params, successBlock: { (result: NSDictionary) -> Void in
                self.reloadViewWithData(result)
                
                if let facets = result["facets"] as? [[String:AnyObject]] {
                    self.facets = facets
                    self.facetsDetails = self.getFacetsDetails()
                    let filteredKeys = self.getFilteredKeys(self.facetsDetails!)
                    if self.facetsDetails?.count > 1 {
                        if let colors = self.facetsDetails![filteredKeys.first!] as? [AnyObject]{
                            self.colorItems = colors
                        }
                     }
                    if self.facetsDetails?.count > 2 {
                        if let sizes = self.facetsDetails![filteredKeys[1]] as? [AnyObject]{
                            self.sizesItems = sizes
                        }
                    }
                   
                }
                
                }) { (error:NSError) -> Void in
                    //var empty = IPOGenericEmptyView(frame:self.viewLoad.frame)
                    let empty = IPOGenericEmptyView(frame:CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
                    
                    self.name = NSLocalizedString("empty.productdetail.title",comment:"")
                    empty.returnAction = { () in
                        print("")
                        self.navigationController!.popViewControllerAnimated(true)
                    }
                    self.view.addSubview(empty)
                    self.viewLoad.stopAnnimating()
            }
        
        
    }
    /**
     Reloads product detail view with a NSDIctionary
     
     - parameter result: product detail data
     */
    func reloadViewWithData(result:NSDictionary){
        self.name = result["description"] as! NSString
        self.price = result["price"] as! NSString
        self.detail = result["detail"] as! NSString
        self.saving = ""
        self.detail = self.detail.stringByReplacingOccurrencesOfString("^", withString: "\n")
        self.upc = result["upc"] as! NSString
        if let isGift = result["isGift"] as? Bool{
            self.isGift = isGift
        }
        
        
        if let savingResult = result["saving"] as? NSString {
            if savingResult != "" {
                let doubleVaule = NSString(string: savingResult).doubleValue
                if doubleVaule > 0 {
                    let savingStr = NSLocalizedString("price.saving",comment:"")
                    let formated = CurrencyCustomLabel.formatString("\(savingResult)")
                    self.saving = "\(savingStr) \(formated)"
                }
            }
        }
        print(self.saving)
        
        
        self.listPrice = result["original_listprice"] as! NSString
        self.characteristics = []
        if let cararray = result["characteristics"] as? NSArray {
            self.characteristics = cararray as [AnyObject]
        }
        
        var allCharacteristics : [AnyObject] = []
        
        let strLabel = "UPC"
        //let strValue = self.upc
        
        allCharacteristics.append(["label":strLabel,"value":self.upc])
        
        for characteristic in self.characteristics  {
            allCharacteristics.append(characteristic)
        }
        self.characteristics = allCharacteristics
        
        if let msiResult =  result["msi"] as? NSString {
            if msiResult != "" {
                self.msi = msiResult.componentsSeparatedByString(",")
            }else{
                self.msi = []
            }
        }
        if let images = result["imageUrl"] as? [AnyObject] {
            self.imageUrl = images
        }
        let freeShippingStr  = result["freeShippingItem"] as! NSString
        self.freeShipping = "true" == freeShippingStr
        
        var numOnHandInventory : NSString = "0"
        if let numberOf = result["onHandInventory"] as? NSString{
            numOnHandInventory  = numberOf
        }
        self.onHandInventory  = numOnHandInventory
        
        self.strisActive  = result["isActive"] as! String
        self.isActive = "true" == self.strisActive
        
        if self.isActive == true {
            self.isActive = self.price.doubleValue > 0
        }
        
        self.strisPreorderable  = result["isPreorderable"] as! String
        
        self.isPreorderable = "true" == self.strisPreorderable
        self.bundleItems = [AnyObject]()
        if let bndl = result["bundleItems"] as?  [AnyObject] {
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
        
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
        
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
    }
    
    //MARK: - Collection view Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cellEmpty = detailCollectionView.dequeueReusableCellWithReuseIdentifier("emptyCell", forIndexPath: indexPath)
        cellEmpty.frame =  CGRectMake(0, 0, 2, 2)
        var cell : UICollectionViewCell? = nil
        let point = (indexPath.section,indexPath.row)
        if isLoading {
            return cellEmpty
        }
        var rowChose = indexPath.row
        switch point {
        case (0,0) :
            if bundleItems.count == 0 {rowChose += 1}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        case (0,1) :
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        case (0,2) :
            if msi.count == 0 {rowChose += 1}
            if bundleItems.count == 0 {rowChose += 1}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        case (0,3) :
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
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let reusableView : UICollectionReusableView? = nil
        
        if kind == CSStickyHeaderParallaxHeader{
            let view = detailCollectionView.dequeueReusableSupplementaryViewOfKind(CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage", forIndexPath: indexPath) as! ProductDetailBannerCollectionViewCell
            if self.isPreorderable {
                view.imagePresale.hidden = false
            }

            
            if self.isLowStock {
                view.lowStock?.hidden = false
            }
            
            view.items = self.imageUrl
            view.delegate = self
            view.colors = self.colorItems
            view.sizes = self.sizesItems
            view.colorsViewDelegate = self
            view.collection.reloadData()
            
            view.setAdditionalValues(listPrice as String, price: price as String, saving: saving as String)
            view.activePromotions(ProductDetailViewController.validateUpcPromotion(self.upc as String))
            currentHeaderView = view
            return view
        }
        if kind == UICollectionElementKindSectionHeader {
            let view = detailCollectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) 
            
            productDetailButton = ProductDetailButtonBarCollectionViewCell(frame: CGRectMake(0, 0, self.view.frame.width, 56.0))
            productDetailButton!.upc = self.upc as String
            productDetailButton!.desc = self.name as String
            productDetailButton!.price = self.price as String
            productDetailButton!.isPesable  = self.isPesable

            productDetailButton!.isActive = self.strisActive
            productDetailButton!.onHandInventory = self.onHandInventory as String
            productDetailButton!.isPreorderable = self.strisPreorderable
            productDetailButton!.listButton.enabled = !self.isGift
            
            productDetailButton!.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButton!.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCWishlist(self.upc as String)
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
    
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
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
        return CGSizeMake(self.view.frame.width , hForCell);
    }
    
 
    /*func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return (action == Selector("copy:"))
    }
    
    func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if (action == Selector("copy:")) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            let pasteBoard = UIPasteboard.generalPasteboard()
            pasteBoard.setValue("UPC", forPasteboardType: "UPC")
        }

    }*/
    
    class func validateUpcPromotion(upc:String) -> Bool{
        let upcs =  UserCurrentSession.sharedInstance().upcSearch
        return upcs.containsObject(upc)
    }
    
    func cellForPoint(point:(Int,Int),indexPath: NSIndexPath) -> UICollectionViewCell? {
        var cell : UICollectionViewCell? = nil
        switch point {
        case (0,0) :
            if bundleItems.count != 0 {
                let cellPromotion = detailCollectionView.dequeueReusableCellWithReuseIdentifier("cellBundleitems", forIndexPath: indexPath) as? ProductDetailBundleCollectionViewCell
                cellPromotion!.delegate = self
                cellPromotion!.itemsUPC = bundleItems
                cellPromotion!.type = "MG"
                //cell = cellPromotion
            } else {
                return cellForPoint((indexPath.section,1),indexPath: indexPath)
            }
        case (0,1) :
            if  msi.count != 0 {
                let cellPromotion = detailCollectionView.dequeueReusableCellWithReuseIdentifier("msiCell", forIndexPath: indexPath) as! ProductDetailMSICollectionViewCell
                cellPromotion.priceProduct = self.price
                cellPromotion.setValues(msi)
                cell = cellPromotion
            }else {
                return cellForPoint((indexPath.section,2),indexPath: indexPath)
            }
        case (0,2) :
            if characteristics.count != 0 {
                let cellCharacteristics = detailCollectionView.dequeueReusableCellWithReuseIdentifier("cellCharacteristics", forIndexPath: indexPath) as! ProductDetailCharacteristicsCollectionViewCell
                cellCharacteristics.setValues(characteristics)
                cellCharacteristics.superview?.userInteractionEnabled = true
                cell = cellCharacteristics
            }else{
                return cellForPoint((indexPath.section,3),indexPath: indexPath)
            }
        case (0,3) :
            if cellRelated == nil {
                let cellPromotion = detailCollectionView.dequeueReusableCellWithReuseIdentifier("crossSellCell", forIndexPath: indexPath) as? ProductDetailCrossSellCollectionViewCell
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
    func opencloseContainer(open:Bool,viewShow:UIView,additionalAnimationOpen:(() -> Void),additionalAnimationClose:(() -> Void)) {
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
    func openContainer(viewShow:UIView,additionalAnimationOpen:(() -> Void)) {
        self.isContainerHide = false
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
             self.detailCollectionView.scrollRectToVisible(self.detailCollectionView.bounds, animated: false)
            }) { (complete:Bool) -> Void in
                self.detailCollectionView.scrollEnabled = false
                
                let finalFrameOfQuantity = CGRectMake(self.detailCollectionView.frame.minX, 0, self.detailCollectionView.frame.width, self.heightDetail)
                self.containerinfo.frame = CGRectMake(self.detailCollectionView.frame.minX, self.heightDetail, self.detailCollectionView.frame.width, 0)
                self.containerinfo.addSubview(viewShow)
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.containerinfo.frame = finalFrameOfQuantity
                    additionalAnimationOpen()
                })
                
        }
    }
    
    /**
     Animation where container info closed
     
     - parameter additionalAnimationClose: <#additionalAnimationClose description#>
     - parameter completeClose:            <#completeClose description#>
     */
    func closeContainer(additionalAnimationClose:(() -> Void),completeClose:(() -> Void)) {
        let finalFrameOfQuantity = CGRectMake(self.detailCollectionView.frame.minX,  heightDetail, self.detailCollectionView.frame.width, 0)
        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.containerinfo.frame = finalFrameOfQuantity
                additionalAnimationClose()
            }) { (comple:Bool) -> Void in
                self.isContainerHide = true
                self.isShowShoppingCart = false
                self.isShowProductDetail = false
                self.productDetailButton!.deltailButton.selected = false
                self.detailCollectionView.scrollEnabled = true
                completeClose()
                for viewInCont in self.containerinfo.subviews {
                    viewInCont.removeFromSuperview()
                }
                self.selectQuantity = nil
                //self.viewDetail = nil
        }
    }
    
    //MARK: -  ProductDetailButtonBarCollectionViewCellDelegate
    /**
     Builds an image to share
     */
    func shareProduct() {
        let imageHead = UIImage(named:"detail_HeaderMail")
        let imageHeader = UIImage(fromView: self.headerView)
        //let headers = [0]
        
        let imagen = UIImage(fromView: currentHeaderView)
        
        //Event
         //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: "\(self.name) - \(self.upc)")
        
        //let screen = self.detailCollectionView.screenshotOfHeadersAtSections( NSSet(array:headers), footersAtSections: nil, rowsAtIndexPaths: NSSet(array: items))
        
        let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx/Busqueda.aspx?Text=\(self.upc)")
        let imgResult = UIImage.verticalImageFromArray([imageHead!,imageHeader,imagen])
        
        //let urlWmart = NSURL(string: "walmartMG://UPC_\(self.upc)")
        if urlWmart != nil {
            let controller = UIActivityViewController(activityItems: [self,imgResult,urlWmart!], applicationActivities: nil)
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
    }
    //MARK: activityViewControllerDelegate
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject{
        return "Walmart"
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        
        var toUseName = ""
        if self.name.length > 32 {
            toUseName = self.name.substringToIndex(32)
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

        if activityType == UIActivityTypeMail {
            return "Hola, Me gustó este producto de Walmart.¡Te lo recomiendo!\n\(self.name) \nSiempre encuentra todo y pagas menos."
        }else if activityType == UIActivityTypePostToTwitter ||  activityType == UIActivityTypePostToVimeo ||  activityType == UIActivityTypePostToFacebook  {
            return "Chequen este producto: \(toUseName) #walmartapp #wow"
        }
        return "Checa este producto: \(toUseName)"
    }
    
    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        if activityType == UIActivityTypeMail {
            if UserCurrentSession.sharedInstance().userSigned == nil {
                  return "Encontré un producto que te puede interesar en www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance().userSigned!.profile.name) encontró un producto que te puede interesar en www.walmart.com.mx"
            }
        }
        return ""
    }
    /**
     Reloads shopping cart button
     
     - parameter sender: sender
     */
    func endUpdatingShoppingCart(sender:AnyObject) {
        self.productDetailButton?.reloadShoppinhgButton()
    }
    
    //MARK: Color Size Functions
    /**
     Gets details objects from facets
     
     - returns: dictionary wit facet details
     */
    func getFacetsDetails() -> [String:AnyObject]{
        var facetsDetails : [String:AnyObject] = [String:AnyObject]()
        self.selectedDetailItem = [:]
        for product in self.facets! {
            let productUpc =  product["upc"] as! String
            let selected = productUpc == self.upc
            let details = product["details"] as! [AnyObject]
            var itemDetail = [String:String]()
            itemDetail["upc"] = product["upc"] as? String
            var count = 0
            for detail in details{
                let label = detail["description"] as! String
                let unit = detail["unit"] as! String
                var values = facetsDetails[label] as? [AnyObject]
                if values == nil{ values = []}
                let itemToAdd = ["value":detail["unit"] as! String, "enabled": (details.count == 1 || label == "Color") ? 1 : 0, "type": label,"selected":false]
                if !(values! as NSArray).containsObject(itemToAdd) {
                    values!.append(itemToAdd)
                }
                facetsDetails[label] = values
                itemDetail[label] = detail["unit"] as? String
                count += 1
                if selected {
                    self.selectedDetailItem![label] = unit
                }
            }
            var detailsValues = facetsDetails["itemDetails"] as? [AnyObject]
            if detailsValues == nil{ detailsValues = []}
            detailsValues!.append(itemDetail)
            facetsDetails["itemDetails"] = detailsValues
        }
        return self.marckSelectedDetails(facetsDetails)
    }
    
    /**
     Mark as selected the Details of the first upc
     
     - parameter facetsDetails: dictionary wit facet details
     
     - returns: dictionary wit facet details
     */
    func marckSelectedDetails(facetsDetails: [String:AnyObject]) -> [String:AnyObject] {
        var selectedDetails: [String:AnyObject] = [:]
        let filteredKeys = self.getFilteredKeys(facetsDetails)
        // Primer elemento
        let itemsFirst: [[String:AnyObject]] = facetsDetails[filteredKeys.first!] as! [[String:AnyObject]]
        let selecteFirst =  self.selectedDetailItem![filteredKeys.first!]!
        var values: [AnyObject] = []
        for item in itemsFirst{
            let label = item["type"] as! String
            let unit = item["value"] as! String
            values.append(["value":unit, "enabled": 1, "type": label,"selected": (unit == selecteFirst)])
        }
        selectedDetails[selecteFirst] = values
        
        if filteredKeys.count > 1 {
            let itemsSecond: [[String:AnyObject]] = facetsDetails[filteredKeys.last!] as! [[String:AnyObject]]
            let selectedSecond =  self.selectedDetailItem![filteredKeys.last!]!
            
            let itemDetails = facetsDetails["itemDetails"] as? [AnyObject]
            var findObj: [String] = []
            for item in itemDetails!{
                if(item[filteredKeys.first!] as! String == selecteFirst)
                {
                    findObj.append(item[filteredKeys.last!] as! String)
                }
            }
            
            var valuesSecond: [AnyObject] = []
            for item in itemsSecond{
                let label = item["type"] as! String
                let unit = item["value"] as! String
                let enabled = findObj.contains(selectedSecond)
                valuesSecond.append(["value":unit, "enabled": enabled ? 1 : 0, "type": label,"selected": (unit == selectedSecond)])
            }
            selectedDetails[selectedSecond] = valuesSecond
        }
        selectedDetails["itemDetails"] = facetsDetails["itemDetails"]
        return selectedDetails
    }
    /**
     Returns Dictionary keys in order
     
     - parameter facetsDetails: facetsDetails Dictionary
     
     - returns: String array with keys in order
     */
    func getFilteredKeys(facetsDetails: [String:AnyObject]) -> [String] {
        let keys = Array(facetsDetails.keys)
        var filteredKeys = keys.filter(){
            return ($0 as String) != "itemDetails"
        }
        filteredKeys = filteredKeys.sort({
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
    func getUpc(itemsSelected: [String:String]) -> String
    {
        var upc = ""
        var isSelected = false
        let details = self.facetsDetails!["itemDetails"] as? [AnyObject]
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
    func getFacetWithUpc(upc:String) -> [String:AnyObject] {
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
    func getDetailsWithKey(key: String, value: String, keyToFind: String) -> [String]{
        let itemDetails = self.facetsDetails!["itemDetails"] as? [AnyObject]
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
    func selectDetailItem(selected: String, itemType: String) {
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
                     button.enabled = sizes.contains(button.titleLabel!.text!)
                    if sizes.count > 0 && button.titleLabel!.text! == sizes.first {
                            button.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
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