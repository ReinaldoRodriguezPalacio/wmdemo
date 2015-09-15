//
//  ProductoDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailViewController : IPOBaseController,UICollectionViewDataSource,UICollectionViewDelegate ,ProductDetailCrossSellViewDelegate,ProductDetailButtonBarCollectionViewCellDelegate ,ProductDetailBannerCollectionViewDelegate,UIActivityItemSource {

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
    var freeShipping : Bool = false
    var isLoading : Bool = false
    var viewDetail : ProductDetailTextDetailView!
    var productDetailButton: ProductDetailButtonBarCollectionViewCell!
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
    
    var strisActive : String! = "true"
    var strisPreorderable : String! = "false"
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Quitar HardCode de colores
        self.colorItems = [0xDF1C11,0x696E72,0x0E1219,0x1183C2,0x573281]
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
        
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

            NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeContainerDetail", name: CustomBarNotification.SuccessAddUpdateCommentCart.rawValue, object: nil)
        }
        
        headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 46))
        headerView.backgroundColor = WMColor.navigationHeaderBgColor
        let buttonBk = UIButton(frame: CGRectMake(0, 0, 46, 46))
        buttonBk.setImage(UIImage(named:"BackProduct"), forState: UIControlState.Normal)
        buttonBk.addTarget(self, action: "backButton", forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(buttonBk)
        
        titlelbl = UILabel(frame: CGRectMake(46, 0, self.view.frame.width - (46 * 2), 46))
        titlelbl.textAlignment = .Center
        titlelbl.text = self.name as String
        titlelbl.numberOfLines = 2
        titlelbl.font = WMFont.fontMyriadProRegularOfSize(14)
        titlelbl.textColor = WMColor.navigationTilteTextColor
        titlelbl.adjustsFontSizeToFitWidth = true
        titlelbl.minimumScaleFactor = 9 / 12
        
        headerView.addSubview(titlelbl)
        self.view.addSubview(headerView)
        
        gestureCloseDetail = UITapGestureRecognizer(target: self, action: "closeActionView")
        gestureCloseDetail.enabled = false
        
        self.containerinfo = UIView()
        self.containerinfo.clipsToBounds = true
        
        self.view.addSubview(containerinfo)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "endUpdatingShoppingCart:", name: CustomBarNotification.UpdateBadge.rawValue, object: nil)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    func closeActionView () {
        if isShowProductDetail {
            closeProductDetail()
        }
        if isShowShoppingCart {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.productDetailButton.reloadShoppinhgButton()
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
    
    
    

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
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
            productDetailButton.upc = self.upc as String
            productDetailButton.desc = self.name as String
            productDetailButton.price = self.price as String
            productDetailButton.price = self.price as String
            
            productDetailButton.isActive = self.strisActive
            productDetailButton.onHandInventory = self.onHandInventory as String
            productDetailButton.isPreorderable = self.strisPreorderable
            
            productDetailButton.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButton.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCWishlist(self.upc as String)
            
            var imageUrl = ""
            if self.imageUrl.count > 0 {
                imageUrl = self.imageUrl[0] as! NSString as String
            }
            productDetailButton.image = imageUrl
            productDetailButton.delegate = self

            return productDetailButton
        }
        return headerView
    }
    
   
    
    func backButton (){
        self.navigationController!.popViewControllerAnimated(true)
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
    func goTODetailProduct(upc:String,items:[[String:String]],index:Int,imageProduct:UIImage?,point:CGRect) {
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = items
        controller.ixSelected = index
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func showCrossSell() {
        isHideCrossSell = false
        let numberOfRows = self.detailCollectionView.numberOfItemsInSection(0)
        var indexPaths = [NSIndexPath(forRow: numberOfRows, inSection: 0)]
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
                println("Termina sevicio app")
        })
        
    }
   
    
    
    
    
    func showProductDetail() {
        
        if isShowShoppingCart {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
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
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue, action: (self.type == ResultObjectType.Mg ?  WMGAIUtils.MG_EVENT_PRODUCTDETAIL_INFORMATION.rawValue : WMGAIUtils.GR_EVENT_PRODUCTDETAIL_INFORMATION.rawValue) , label: upc as String, value: nil).build() as [NSObject : AnyObject])
        }

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
    
    func addOrRemoveToWishList(upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,added:(Bool) -> Void) {
        
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
                
                let addedAlertWL = WishlistAddProductStatus(frame: CGRectMake(0, 360, 320, 0))
                addedAlertWL.generateBlurImage(self.view,frame:CGRectMake(0, 312, 320, 360))
                
                addedAlertWL.clipsToBounds = true
                addedAlertWL.imageBlurView.frame = CGRectMake(0, -312, 320, 360)
                if addItem {
                    let serviceWishList = AddItemWishlistService()
                    serviceWishList.callService(upc, quantity: "1", comments: "",desc:desc,imageurl:imageurl,price:price,isActive:isActive,onHandInventory:onHandInventory,isPreorderable:isPreorderable, successBlock: { (result:NSDictionary) -> Void in
                        addedAlertWL.textView.text = NSLocalizedString("wishlist.ready",comment:"")
                        added(true)
            
                        //Event
                        if let tracker = GAI.sharedInstance().defaultTracker {
                            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue, action: (self.type == ResultObjectType.Mg ?  WMGAIUtils.MG_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCART.rawValue : WMGAIUtils.GR_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCART.rawValue) , label: "\(self.upc) - \(self.name)", value: nil).build() as [NSObject : AnyObject])
                        }

                        
                        
                        
                        self.view.addSubview(addedAlertWL)
                        self.isWishListProcess = false
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            addedAlertWL.frame = CGRectMake(0, 312, 320, 48)
                            addedAlertWL.prepareToClose()
                            self.gestureCloseDetail.enabled = false
                            self.detailCollectionView.scrollEnabled = true
                        })
                        
                        }) { (error:NSError) -> Void in
                            self.isWishListProcess = false
                            if error.code != -100 {
                                added(false)
                                addedAlertWL.textView.text = error.localizedDescription
                                self.view.addSubview(addedAlertWL)
                                UIView.animateWithDuration(0.3, animations: { () -> Void in
                                    addedAlertWL.frame = CGRectMake(0, 312, 320, 48)
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
                            addedAlertWL.frame = CGRectMake(0, 312, 320, 48)
                            addedAlertWL.prepareToClose()
                            self.gestureCloseDetail.enabled = false
                            self.detailCollectionView.scrollEnabled = true
                        })
                        
                        //Event
                        if let tracker = GAI.sharedInstance().defaultTracker {
                            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue,
                                action: WMGAIUtils.MG_EVENT_PRODUCTDETAIL_REMOVEFROMWISHLIST.rawValue ,
                                label: upc,
                                value: nil).build() as [NSObject : AnyObject])
                        }
                        
                        
                        }, errorBlock: { (error:NSError) -> Void in
                             self.isWishListProcess = false
                            added(false)
                            if error.code != -100 {
                                addedAlertWL.textView.text = error.localizedDescription
                                self.view.addSubview(addedAlertWL)
                                UIView.animateWithDuration(0.3, animations: { () -> Void in
                                    addedAlertWL.frame = CGRectMake(0, 312, 320, 48)
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
                self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
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
        if  self.detailCollectionView.contentOffset.y != 0.0 {
            //self.detailCollectionView.scrollRectToVisible(CGRectMake(0, 0, self.tabledetail.frame.width,  self.tabledetail.frame.height ), animated: true)
        } else {
            if addOrRemoveToWishListBlock != nil {
                addOrRemoveToWishListBlock!()
            }
        }
    }
    
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
                            self.productDetailButton.reloadShoppinhgButton()
                            self.isShowShoppingCart = false
                            self.selectQuantity!.frame = CGRectMake(0, 360, 320, 0)
                            self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
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
            selectQuantity!.generateBlurImage(self.view,frame:finalFrameOfQuantity)
            
         
            selectQuantity!.addToCartAction =
                { (quantity:String) in
                    //let quantity : Int = quantity.toInt()!
                    if self.onHandInventory.integerValue >= quantity.toInt() {
                        //let params = CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageURL, price: price, quantity: quantity,onHandInventory:self.onHandInventory,)
                        let params = self.buildParamsUpdateShoppingCart(quantity)
                        self.gestureCloseDetail.enabled = false
                        self.detailCollectionView.scrollEnabled = true
                        self.isShowShoppingCart = false
                        
                        //Event
                        if let tracker = GAI.sharedInstance().defaultTracker {
                            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue, action: (self.type == ResultObjectType.Mg ?  WMGAIUtils.MG_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCART.rawValue : WMGAIUtils.GR_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCART.rawValue) , label: "\(self.upc) - \(self.name)", value: nil).build() as [NSObject : AnyObject])
                        }

                
                        UIView.animateWithDuration(0.2,
                            animations: { () -> Void in
                                self.productDetailButton.reloadShoppinhgButton()
                                self.selectQuantity!.frame = CGRectMake(0, 360, 320, 0	)
                                self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
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
                        let msgInventory = "\(firstMessage)\(self.onHandInventory) \(secondMessage)"
                        alert!.setMessage(msgInventory)
                        alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                    }
            }
            
            self.detailCollectionView.scrollEnabled = false
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.detailCollectionView.scrollRectToVisible(CGRectMake(0, 0, self.detailCollectionView.frame.width,  self.detailCollectionView.frame.height ), animated: false)
                }, completion: { (complete:Bool) -> Void in
                    self.selectQuantity!.clipsToBounds = true
                    self.view.addSubview(self.selectQuantity!)
                    
                    self.selectQuantity!.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.productDetailButton.setOpenQuantitySelector()
                        self.selectQuantity!.frame = finalFrameOfQuantity
                        self.selectQuantity!.imageBlurView.frame = finalFrameOfQuantity
                    })
            })
        }else{
            self.closeContainerDetail()
        }
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
                        self.productDetailButton.reloadShoppinhgButton()
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
                    self.productDetailButton.reloadShoppinhgButton()
            }
        }
        
    }
    
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
                self.selectQuantity!.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
               
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.productDetailButton.setOpenQuantitySelector()
                    self.selectQuantity!.frame = finalFrameOfQuantity
                    self.selectQuantity!.imageBlurView.frame = finalFrameOfQuantity
                    }, completion: { (complete:Bool) -> Void in
                        self.productDetailButton.addToShoppingCartButton.setTitleColor(WMColor.navigationTilteTextColor, forState: UIControlState.Normal)
                })
            }
        }
        if  self.isWishListProcess  {
            if addOrRemoveToWishListBlock != nil {
                addOrRemoveToWishListBlock!()
            }
        }
    }
    
    func startAnimatingProductDetail() {
        let finalFrameOfQuantity = CGRectMake(0, 0, 320, 360)
        viewDetail = ProductDetailTextDetailView(frame: CGRectMake(0,360, 320, 0))
        viewDetail!.generateBlurImage(self.view,frame:finalFrameOfQuantity)
        self.viewDetail!.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
        viewDetail.setTextDetail(detail as String)
        viewDetail.closeDetail = { () in
            self.closeProductDetail()
        }
        self.view.addSubview(viewDetail)
        
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.viewDetail!.frame = finalFrameOfQuantity
            self.viewDetail!.imageBlurView.frame = finalFrameOfQuantity
            //self.viewDetail.frame = CGRectMake(0, 0, self.tabledetail.frame.width, self.tabledetail.frame.height - 145)
            self.productDetailButton.deltailButton.selected = true
        })
    }
    
    func closeProductDetail () {
        if isShowProductDetail == true {
        isShowProductDetail = false
            gestureCloseDetail.enabled = false
        self.detailCollectionView.scrollEnabled = true
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.viewDetail!.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
            self.viewDetail.frame = CGRectMake(0,360, 320, 0)
            }) { (ended:Bool) -> Void in
                if self.viewDetail != nil {
                self.viewDetail.removeFromSuperview()
                self.viewDetail = nil
                    
            
            self.productDetailButton.deltailButton.selected = false
                }
        }
        }
    }
    
    
    func sleectedImage(indexPath: NSIndexPath) {
        var controller = ImageDisplayCollectionViewController()
        controller.name = self.name as String
        controller.imagesToDisplay = imageUrl
        controller.currentItem = indexPath.row
        controller.type = self.type.rawValue
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    func showMessageProductNotAviable() {
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
    
    
    func loadDataFromService() {
        
        self.type = ResultObjectType.Mg
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue, action: WMGAIUtils.MG_EVENT_SHOWPRODUCTDETAIL.rawValue, label: "\(upc) - \(name)", value: nil).build() as [NSObject : AnyObject])
        }
        
        let productService = ProductDetailService()
        productService.callService(requestParams:upc, successBlock: { (result: NSDictionary) -> Void in
            
            self.name = result["description"] as! NSString
            self.price = result["price"] as! NSString
            self.detail = result["detail"] as! NSString
            self.saving = ""
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
            println(self.saving)
            
            self.listPrice = result["original_listprice"] as! NSString
            self.characteristics = []
            if let cararray = result["characteristics"] as? NSArray {
                self.characteristics = cararray as [AnyObject]
            }
            
            var allCharacteristics : [AnyObject] = []
            
            let strLabel = "UPC"
            let strValue = self.upc
            
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
            
            self.isLoading = false
            
            self.detailCollectionView.reloadData()
            
            self.viewLoad.stopAnnimating()
            //self.tabledetail.scrollEnabled = true
            //self.gestureCloseDetail.enabled = false
            if self.titlelbl != nil {
                self.titlelbl.text = self.name as String
            }
            
            self.loadCrossSell()
            
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
            
            if let tracker = GAI.sharedInstance().defaultTracker {
                
                var product = GAIEcommerceProduct()
                var builder = GAIDictionaryBuilder.createScreenView()
                product.setId(self.upc as String)
                product.setName(self.name as String)
                
                var action = GAIEcommerceProductAction();
                action.setAction(kGAIPADetail)
                builder.setProductAction(action)
                builder.addProduct(product)
                
                tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue)
                tracker.send(builder.build() as [NSObject : AnyObject])
            }
            
            }) { (error:NSError) -> Void in
                //var empty = IPOGenericEmptyView(frame:self.viewLoad.frame)
                var empty = IPOGenericEmptyView(frame:CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
                
                self.name = NSLocalizedString("empty.productdetail.title",comment:"")
                empty.returnAction = { () in
                    println("")
                    self.navigationController!.popViewControllerAnimated(true)
                }
                self.view.addSubview(empty)
                self.viewLoad.stopAnnimating()
        }
    }
    
    //MARK: - Collection view Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var inCountRows = 1
        if bundleItems.count != 0
        {
            inCountRows++
        }
        if msi.count != 0
        {
            inCountRows++
        }
        if !isHideCrossSell {
            inCountRows++
        }
        return inCountRows
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cellEmpty = detailCollectionView.dequeueReusableCellWithReuseIdentifier("emptyCell", forIndexPath: indexPath) as! UICollectionViewCell
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
        
        var reusableView : UICollectionReusableView? = nil
        
        if kind == CSStickyHeaderParallaxHeader {
            let view = detailCollectionView.dequeueReusableSupplementaryViewOfKind(CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage", forIndexPath: indexPath) as! ProductDetailBannerCollectionViewCell
            view.items = self.imageUrl
            view.delegate = self
            view.colors = self.colorItems
            view.collection.reloadData()
            
            view.setAdditionalValues(listPrice as String, price: price as String, saving: saving as String)
            currentHeaderView = view
            return view
        }
        if kind == UICollectionElementKindSectionHeader {
            let view = detailCollectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as! UICollectionReusableView
            
            productDetailButton = ProductDetailButtonBarCollectionViewCell(frame: CGRectMake(0, 0, self.view.frame.width, 56.0))
            productDetailButton.upc = self.upc as String
            productDetailButton.desc = self.name as String
            productDetailButton.price = self.price as String
            productDetailButton.isPesable  = self.isPesable

            productDetailButton.isActive = self.strisActive
            productDetailButton.onHandInventory = self.onHandInventory as String
            productDetailButton.isPreorderable = self.strisPreorderable
            productDetailButton.hasDetailOptions = (self.colorItems.count > 0)
            
            productDetailButton.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButton.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCWishlist(self.upc as String)
            
            var imageUrl = ""
            if self.imageUrl.count > 0 {
                imageUrl = self.imageUrl[0] as! NSString as String
            }
            productDetailButton.image = imageUrl
            productDetailButton.delegate = self
            view.addSubview(productDetailButton)
            
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
                if cellCharacteristics == nil {
                    let cellCharacteristics = detailCollectionView.dequeueReusableCellWithReuseIdentifier("cellCharacteristics", forIndexPath: indexPath) as! ProductDetailCharacteristicsCollectionViewCell
                    cellCharacteristics.setValues(characteristics)
                    cell = cellCharacteristics
                }
                return cellCharacteristics
            }else{
                return cellForPoint((indexPath.section,3),indexPath: indexPath)
            }
        case (0,3) :
            if cellRelated == nil {
                let cellPromotion = detailCollectionView.dequeueReusableCellWithReuseIdentifier("crossSellCell", forIndexPath: indexPath) as? ProductDetailCrossSellCollectionViewCell
                cellPromotion!.delegate = self
                cellPromotion!.itemsUPC = itemsCrossSellUPC
                self.cellRelated = cellPromotion
            }
            cell = self.cellRelated
        default :
            cell = nil
        }
        return cell
    }
    
    
    func opencloseContainer(open:Bool,viewShow:UIView,additionalAnimationOpen:(() -> Void),additionalAnimationClose:(() -> Void)) {
        
        if isContainerHide && open {
            openContainer(viewShow, additionalAnimationOpen: additionalAnimationOpen)
        } else {
            
        }
        
    }
    
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
                self.productDetailButton.deltailButton.selected = false
                self.detailCollectionView.scrollEnabled = true
                completeClose()
                for viewInCont in self.containerinfo.subviews {
                    viewInCont.removeFromSuperview()
                }
                self.selectQuantity = nil
                self.viewDetail = nil
        }
    }
    
    //MARK: Shopping cart
    func buildParamsUpdateShoppingCart(quantity:String) -> [NSObject:AnyObject] {
        var imageUrlSend = ""
        if self.imageUrl.count > 0 {
            imageUrlSend = self.imageUrl[0] as! NSString as String
        }
        var pesable = isPesable ? "1" : "0"
        return ["upc":self.upc,"desc":self.name,"imgUrl":imageUrlSend,"price":self.price,"quantity":quantity,"onHandInventory":self.onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,pesable:pesable,"isPreorderable":self.strisPreorderable]
    }
    
    
    
    //MARK: -  ProductDetailButtonBarCollectionViewCellDelegate
    
    func shareProduct() {
        let imageHead = UIImage(named:"detail_HeaderMail")
        let imageHeader = UIImage(fromView: self.headerView)
        let headers = [0]
        
        let imagen = UIImage(fromView: currentHeaderView)
        
        //Event
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue, action: (self.type == ResultObjectType.Mg ?  WMGAIUtils.MG_EVENT_PRODUCTDETAIL_SHAREPRODUCT.rawValue : WMGAIUtils.GR_EVENT_PRODUCTDETAIL_SHAREPRODUCT.rawValue) , label: self.upc as String, value: nil).build() as [NSObject : AnyObject])
        }
        
        //let screen = self.detailCollectionView.screenshotOfHeadersAtSections( NSSet(array:headers), footersAtSections: nil, rowsAtIndexPaths: NSSet(array: items))
        
        let urlWmart = UserCurrentSession.urlWithRootPath("http://www.walmart.com.mx/Busqueda.aspx?Text=\(self.upc)")
        let imgResult = UIImage.verticalImageFromArray([imageHead!,imageHeader,imagen])
        
        //let urlWmart = NSURL(string: "walmartMG://UPC_\(self.upc)")
        
        var controller = UIActivityViewController(activityItems: [self,imgResult,urlWmart!], applicationActivities: nil)

        
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
    
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
        
        if activityType == UIActivityTypeMail {
            return "Hola, Me gustó este producto de Walmart.¡Te lo recomiendo!\n\(self.name) \nSiempre encuentra todo y pagas menos"
        }else if activityType == UIActivityTypePostToTwitter ||  activityType == UIActivityTypePostToVimeo ||  activityType == UIActivityTypePostToFacebook  {
            return "Chequen este producto: \(toUseName) #walmartapp #wow "
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
    
    func endUpdatingShoppingCart(sender:AnyObject) {
        self.productDetailButton.reloadShoppinhgButton()
    }
    
    func showProductDetailOptions() {
        var controller = ProductDetailOptionsViewController()
        controller.name = self.name as String
        controller.imagesToDisplay = imageUrl
        controller.currentItem = 0
        controller.type = self.type.rawValue
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
        controller.setAdditionalValues(self.listPrice as! String, price: self.price as! String, saving: self.saving as! String)
    }
    
}