//
//  IPAProductDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAProductDetailViewController : UIViewController, UITableViewDelegate , UITableViewDataSource,UINavigationControllerDelegate,ProductDetailCrossSellViewDelegate,ProductDetailButtonBarCollectionViewCellDelegate,UIActivityItemSource ,ProductDetailBannerCollectionViewDelegate{
    
    var listSelectorController: ListsSelectorViewController?
    var listSelectorContainer: UIView?
    var listSelectorBackgroundView: UIImageView?
    
    var animationController : ProductDetailNavigatinAnimationController!
    var viewLoad : WMLoadingView!
    var msi : NSArray = []
    var upc : NSString = ""
    var name : NSString = ""
    var detail : NSString = ""
    var saving : NSString = ""
    var price : NSString = ""
    var listPrice : NSString = ""
    var type : NSString = ResultObjectType.Mg.rawValue
    var imageUrl : [AnyObject] = []
    var characteristics : [AnyObject] = []
    var bundleItems : [AnyObject] = []
    var freeShipping : Bool = false
    var isLoading : Bool = false
    var productDetailButton: ProductDetailButtonBarCollectionViewCell!
    var isShowProductDetail : Bool = false
    var isShowShoppingCart : Bool = false
    var isWishListProcess : Bool = false
    var isHideCrossSell : Bool = true
    var indexSelected  : Int = 0
    var addOrRemoveToWishListBlock : (() -> Void)? = nil
    var gestureCloseDetail : UITapGestureRecognizer!
    var itemsCrossSellUPC : NSArray! = []
    var bannerImagesProducts : IPAProductDetailBannerView!
    var productCrossSell : IPAProductCrossSellView!
    var tabledetail : UITableView!
    var headerView : UIView!
    var isContainerHide : Bool = true
    var containerinfo : UIView!
    var isActive : Bool! = true
    var isPreorderable : Bool = false
    var onHandInventory : NSString = "0"
    var strisActive : NSString = ""
    var strisPreorderable : NSString = ""
    var cellBundle : IPAProductDetailBundleTableViewCell? = nil
    var titlelbl : UILabel!
    
    let heigthHeader : CGFloat = 46.0
    var viewDetail : ProductDetailTextDetailView? = nil
    var selectQuantity : ShoppingCartQuantitySelectorView? = nil
    var popup : UIPopoverController?
    var pagerController : IPAProductDetailPageViewController? = nil
    var isPesable = false
    var alertView : IPOWMAlertViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = UIView(frame:CGRectMake(0, 0, self.view.bounds.width, heigthHeader))
        headerView.backgroundColor = WMColor.productDetailHeaderBgColor
        
        let buttonBk = UIButton(frame: CGRectMake(0, 0, 46, 46))
        buttonBk.setImage(UIImage(named:"BackProduct"), forState: UIControlState.Normal)
        buttonBk.addTarget(self, action: "backButton", forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(buttonBk)
        
        titlelbl = UILabel(frame: CGRectMake(46, 0, self.view.frame.width - (46 * 2), heigthHeader))
        titlelbl.textAlignment = .Center
        titlelbl.text = self.name as String
        titlelbl.numberOfLines = 2
        titlelbl.font = WMFont.fontMyriadProRegularOfSize(14)
        titlelbl.textColor = WMColor.navigationTilteTextColor
        titlelbl.adjustsFontSizeToFitWidth = true
        titlelbl.minimumScaleFactor = 9 / 12
        headerView.addSubview(titlelbl)

        bannerImagesProducts =  IPAProductDetailBannerView(frame:CGRectMake(0, heigthHeader, 682, 388))
        bannerImagesProducts.delegate = self
        self.view.backgroundColor = UIColor.whiteColor()
        
        productCrossSell = IPAProductCrossSellView(frame:CGRectMake(0, bannerImagesProducts.frame.maxY, 682, 226))
        productCrossSell.delegate = self
 
        tabledetail = UITableView(frame:CGRectMake(bannerImagesProducts.frame.maxX, headerView.frame.maxY, self.view.bounds.width - productCrossSell.frame.width, self.view.bounds.height - heigthHeader))
        tabledetail.registerClass(ProductDetailCurrencyCollectionView.self, forCellReuseIdentifier: "priceCell")
        tabledetail.registerClass(UITableViewCell.self, forCellReuseIdentifier: "emptyCell")
        tabledetail.registerClass(ProductDetailLabelCollectionView.self, forCellReuseIdentifier: "labelCell")
        tabledetail.registerClass(ProductDetailMSITableViewCell.self, forCellReuseIdentifier: "msiCell")
        tabledetail.registerClass(ProductDetailCrossSellTableViewCell.self, forCellReuseIdentifier: "crossSellCell")
        tabledetail.registerClass(ProductDetailCharacteristicsTableViewCell.self, forCellReuseIdentifier: "cellCharacteristics")
        tabledetail.registerClass(IPAProductDetailBundleTableViewCell.self, forCellReuseIdentifier: "cellBundleitems")

        tabledetail.separatorStyle = UITableViewCellSeparatorStyle.None
        
        let separator = UIView(frame: CGRectMake(tabledetail.frame.minX, headerView.frame.maxY,1, self.view.bounds.height))
        separator.backgroundColor = WMColor.lineSaparatorColor
        
        //NSNotificationCenter.defaultCenter().postNotificationName(IPACustomBarNotification.HideBar.toRaw(), object: nil)
        
        self.containerinfo = UIView()
        self.containerinfo.clipsToBounds = true
        
        let gestureClose = UIPinchGestureRecognizer(target: self, action: "didPinch:")
        self.view.addGestureRecognizer(gestureClose)
        
        self.view.addSubview(headerView)
        self.view.addSubview(productCrossSell)
        self.view.addSubview(tabledetail)
        self.view.addSubview(bannerImagesProducts)
        self.view.addSubview(containerinfo)
        self.view.addSubview(separator)
        
        loadDataFromService()
    }
    
  
    func didPinch(sender:UIPinchGestureRecognizer){
        if  sender.scale < 1 {
            self.backButton()
        }
    }
    
    func backButton () {
        if  self.navigationController != nil {
            if self.pagerController != nil {
                self.navigationController!.delegate = self.pagerController
            }
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
   
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabledetail.frame = CGRectMake(bannerImagesProducts.frame.maxX, self.headerView.frame.maxY, self.view.bounds.width - productCrossSell.frame.width, self.view.bounds.height - heigthHeader )
        headerView.frame = CGRectMake(0, 0, self.view.bounds.width, heigthHeader)
        titlelbl.frame = CGRectMake(46, 0, self.view.frame.width - (46 * 2), heigthHeader)
        
    }
    
    func loadCrossSell() {
        let crossService = CrossSellingProductService()
        crossService.callService(self.upc as! String, successBlock: { (result:NSArray?) -> Void in
            if result != nil {
                self.itemsCrossSellUPC = result!
                if self.itemsCrossSellUPC.count > 0{
                    self.productCrossSell.reloadWithData(self.itemsCrossSellUPC, upc: self.upc as String)
                }
            }
            }, errorBlock: { (error:NSError) -> Void in
                println("Termina sevicio app")
        })
    }
    
    //MARK : Table view
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if !self.isContainerHide {
                return 6
            }
            return 5
            
        case 1:
            var inCountRows = 0
            if msi.count != 0
            {
                inCountRows += 2
            }
            if bundleItems.count != 0
            {
                inCountRows += 2
            }
            if characteristics.count != 0
            {
                inCountRows += 2
            }
         
            return inCountRows
        default:
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        NSLog("\(indexPath)")
        NSLog("PD 1")
        var cell : UITableViewCell? = nil
        let point = (indexPath.section,indexPath.row)
        if isLoading {
            cell = cellForPoint((0,4), indexPath: indexPath)
            return cell!
        }
        NSLog("PD 2")
        switch point {
        case (0,0) :
            cell = cellForPoint(point, indexPath: indexPath)
        case (0,1) :
            cell = cellForPoint(point, indexPath: indexPath)
        case (0,2) :
            cell = cellForPoint(point, indexPath: indexPath)
        case (0,3) :
            cell = cellForPoint(point, indexPath: indexPath)
        case (0,4) :
            cell = cellForPoint(point, indexPath: indexPath)
        case (0,5) :
            cell = cellForPoint(point, indexPath: indexPath)
        case (1,0) :
            var rowChose = indexPath.row
            if msi.count == 0 {rowChose += 2}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        case (1,1) :
            var rowChose = indexPath.row
            if msi.count == 0 {rowChose += 2}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        case (1,2) :
            var rowChose = indexPath.row
            if msi.count == 0 {rowChose += 2}
            if bundleItems.count == 0 {rowChose += 2}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        case (1,3) :
            var rowChose = indexPath.row
            if msi.count == 0 {rowChose += 2}
            if bundleItems.count == 0 {rowChose += 2}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        case (1,4) :
            var rowChose = indexPath.row
            if msi.count == 0 {rowChose += 2}
            if bundleItems.count == 0 {rowChose += 2}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        case (1,5) :
            var rowChose = indexPath.row
            if msi.count == 0 {rowChose += 2}
            if bundleItems.count == 0 {rowChose += 2}
            cell = cellForPoint((indexPath.section,rowChose), indexPath: indexPath)
        default :
            cell = nil
        }
        NSLog("PD 3")
        if cell != nil {
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
        }
        NSLog("PD 4")
        return cell!
        
    }
    
    func cellForPoint(point:(Int,Int),indexPath: NSIndexPath) -> UITableViewCell? {
        var cell : UITableViewCell? = nil
        switch point {
        case (0,0) :
            let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath) as? UITableViewCell
            cell = cellSpace
        case (0,1) :
            if self.saving.doubleValue > 0{
                let cellListPrice = tabledetail.dequeueReusableCellWithIdentifier("priceCell", forIndexPath: indexPath) as? ProductDetailCurrencyCollectionView
                let formatedValue = "\(CurrencyCustomLabel.formatString(self.listPrice))"
                cellListPrice!.setValues(formatedValue, font: WMFont.fontMyriadProLightOfSize(14), textColor: WMColor.productDetailPriceText, interLine: true)
                cell = cellListPrice
            }else{
                let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath) as? UITableViewCell
                cell = cellSpace
            }
            
        case (0,2) :
            let cellPrice = tabledetail.dequeueReusableCellWithIdentifier("priceCell", forIndexPath: indexPath) as? ProductDetailCurrencyCollectionView
            let formatedValue = CurrencyCustomLabel.formatString(self.price)
            cellPrice!.setValues(formatedValue, font: WMFont.fontMyriadProSemiboldSize(30), textColor: WMColor.priceDetailProductTextColor, interLine: false)
            cell = cellPrice
        case (0,3) :
            if self.saving != ""{
                if self.saving.doubleValue > 0{
                    let cellAhorro = tabledetail.dequeueReusableCellWithIdentifier("priceCell", forIndexPath: indexPath) as? ProductDetailCurrencyCollectionView
                    var savingSend = self.saving
                    let doubleVaule = self.saving.doubleValue
                    if doubleVaule > 0 {
                        let savingStr = NSLocalizedString("price.saving",comment:"")
                        let formated = CurrencyCustomLabel.formatString("\(savingSend)")
                        savingSend = "\(savingStr) \(formated)"
                    }
                    
                    cellAhorro!.setValues(savingSend as String, font: WMFont.fontMyriadProSemiboldOfSize(14), textColor: WMColor.savingTextColor, interLine: false)
                    cell = cellAhorro
                }else {
                    let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath) as? UITableViewCell
                    cell = cellSpace
                }
            } else{
                let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath) as? UITableViewCell
                cell = cellSpace
            }
        case (0,4) :
            let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath) as? UITableViewCell
            cell = cellSpace
        case (0,5) :
            let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath) as? UITableViewCell
            cell = cellSpace
        case (1,0) :
            if  msi.count != 0 {
                let cellPromotion = tabledetail.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as? ProductDetailLabelCollectionView
                let msiText = NSLocalizedString("productdetail.msitext",comment:"")
                cellPromotion!.setValues(msiText, font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.productProductPromotionsTextColor, padding: 12,align:NSTextAlignment.Left)
                cell = cellPromotion
            }else {
                return cellForPoint((indexPath.section,2),indexPath: indexPath)
            }
        case (1,1) :
            if  msi.count != 0 {
                let cellPromotion = tabledetail.dequeueReusableCellWithIdentifier("msiCell", forIndexPath: indexPath) as? ProductDetailMSITableViewCell
                cellPromotion!.priceProduct = self.price
                cellPromotion!.setValues(msi)
                cell = cellPromotion
            }else {
                return cellForPoint((indexPath.section,3),indexPath: indexPath)
            }
        case (1,2) :
            
            if bundleItems.count != 0 {
                let cellBundleItemsTitle = tabledetail.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as? ProductDetailLabelCollectionView
                let charText = NSLocalizedString("productdetail.bundleitems",comment:"")
                cellBundleItemsTitle!.setValues(charText, font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.productDetailTitleTextColor, padding: 12,align:NSTextAlignment.Left)
                cell = cellBundleItemsTitle
            } else {
                return cellForPoint((indexPath.section,4),indexPath: indexPath)
            }
            
        case (1,3) :
            if bundleItems.count != 0 {
                let cellPromotion = tabledetail.dequeueReusableCellWithIdentifier("cellBundleitems", forIndexPath: indexPath) as? IPAProductDetailBundleTableViewCell
                cellBundle = cellPromotion
                cellPromotion!.delegate = self
                cellPromotion!.itemsUPC = bundleItems
                cell = cellPromotion
            } else {
                return cellForPoint((indexPath.section,5),indexPath: indexPath)
            }
        case (1,4) :
            if characteristics.count != 0 {
                let cellCharacteristicsTitle = tabledetail.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as? ProductDetailLabelCollectionView
                let charText = NSLocalizedString("productdetail.characteristics",comment:"")
                cellCharacteristicsTitle!.setValues(charText, font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.productDetailTitleTextColor, padding: 12,align:NSTextAlignment.Left)
                cell = cellCharacteristicsTitle
            }else{
                return nil
            }
        case (1,5) :
            if characteristics.count != 0 {
                let cellCharacteristics = tabledetail.dequeueReusableCellWithIdentifier("cellCharacteristics", forIndexPath: indexPath) as? ProductDetailCharacteristicsTableViewCell
                cellCharacteristics!.setValues(characteristics)
                cell = cellCharacteristics
            }else{
                return nil
            }
        default :
            cell = nil
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let point = (indexPath.section,indexPath.row)
        switch point {
        case (0,0) :
            return sizeForIndexPath(point,indexPath:indexPath)
        case (0,1) :
            return sizeForIndexPath(point,indexPath:indexPath)
        case (0,2) :
            return sizeForIndexPath(point,indexPath:indexPath)
        case (0,3) :
            return sizeForIndexPath(point,indexPath:indexPath)
        case (0,4) :
            return sizeForIndexPath(point,indexPath:indexPath)
        case (0,5) :
            return sizeForIndexPath(point,indexPath:indexPath)
        case (1,0) :
            var rowChose = indexPath.row
            if msi.count == 0 {rowChose += 2}
            return sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        case (1,1) :
            var rowChose = indexPath.row
            if msi.count == 0 {rowChose += 2}
            return sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        case (1,2) :
            var rowChose = indexPath.row
            if bundleItems.count == 0 {rowChose += 2}
            if msi.count == 0 {rowChose += 2}
            return sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        case (1,3):
            var rowChose = indexPath.row
            if bundleItems.count == 0 {rowChose += 2}
            if msi.count == 0 {rowChose += 2}
            return sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        case (1,4) :
            var rowChose = indexPath.row
            if msi.count == 0 {rowChose += 2}
            if characteristics.count == 0 {rowChose += 2}
            return sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        case (1,5) :
            var rowChose = indexPath.row
            if msi.count == 0 {rowChose += 2}
            if characteristics.count == 0 {rowChose += 2}
            return sizeForIndexPath((indexPath.section,rowChose),indexPath:indexPath)
        default :
            return 0
        }
    }
    
    func sizeForIndexPath (point:(Int,Int),indexPath: NSIndexPath!)  -> CGFloat {
        switch point {
        case (0,0) :
            return 15.0
        case (0,2) :
            return 36.0
        case (0,1),(0,3) :
            return 15.0
        case (0,4) :
            return 15.0
        case (0,5) :
            return 292.0
        case (1,0) :
            if  msi.count != 0 {
                return 36.0
            }
            return sizeForIndexPath ((indexPath.section,2),indexPath: indexPath)
        case (1,1):
            if  msi.count != 0 {
                return (CGFloat(msi.count) * 17) + 22.0
            }
            return sizeForIndexPath ((indexPath.section,3),indexPath: indexPath)
        case (1,2) :
            if  bundleItems.count != 0 {
                return 40.0
            }
            return sizeForIndexPath ((indexPath.section,4),indexPath: indexPath)
        case (1,3):
            if  bundleItems.count != 0 {
                return 130.0
            }
            return sizeForIndexPath ((indexPath.section,5),indexPath: indexPath)
        case (1,4) :
            if characteristics.count != 0 {
                return 36.0
            }
            return sizeForIndexPath ((indexPath.section,6),indexPath: indexPath)
        case (1,5) :
            if characteristics.count != 0 {
                let size = ProductDetailCharacteristicsCollectionViewCell.sizeForCell(self.tabledetail.frame.width - 30,values:characteristics)
                return size + 26
            }
            return sizeForIndexPath ((indexPath.section,7),indexPath: indexPath)
        default :
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        switch section {
        case 0:
          return nil
        default:
            
            if isLoading {
                return UIView()
            }
            
            productDetailButton = ProductDetailButtonBarCollectionViewCell(frame: CGRectMake(0, 0, self.view.frame.width, 64.0),spaceBetweenButtons:13,widthButtons:63)
            productDetailButton.upc = self.upc as String
            productDetailButton.desc = self.name as String
            productDetailButton.price = self.price as String
            productDetailButton.onHandInventory = self.onHandInventory as String
            productDetailButton.isActive = self.strisActive as String
            productDetailButton.isPreorderable = self.strisPreorderable as String
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
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.0
        default:
            return 64.0
        }
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if animationController == nil {
            return nil
        }
        
        switch (operation) {
        case UINavigationControllerOperation.Push:
            
            animationController.type = AnimationType.Present;
            return  animationController;
        case UINavigationControllerOperation.Pop:
            animationController.type = AnimationType.Dismiss;
            return animationController;
        default: return nil;
        }
        
    }
    
  
    // MARK: Product crosssell delegate
    func goTODetailProduct(upc:String,items:[[String:String]],index:Int,imageProduct:UIImage?,point:CGRect){
        
        var paginatedProductDetail = IPAProductDetailPageViewController()
        paginatedProductDetail.ixSelected = index
        paginatedProductDetail.itemsToShow = []
        for product  in items {
            let upc : NSString = product["upc"]!
            let desc : NSString = product["description"]!
            var type : NSString = "mg"
            if let newtype = product["type"] as String! {
                type = newtype
            }

            paginatedProductDetail.itemsToShow.append(["upc":upc,"description":desc,"type":type])
        }
        
      
        //let pontInView =  currentCell.productImage?.convertRect(currentCell!.productImage!.frame, toView: self.view)
        paginatedProductDetail.animationController = ProductDetailNavigatinAnimationController(nav:self.navigationController!)
        paginatedProductDetail.animationController.originPoint =  point
        paginatedProductDetail.animationController.setImage(imageProduct!)
        
        self.navigationController?.delegate = paginatedProductDetail
        self.navigationController?.pushViewController(paginatedProductDetail, animated: true)
        
    }
    
    func reloadSelectedCell() {

        //self.tabledetail.reloadRowsAtIndexPaths([NSIndexPath(forRow:3,inSection:1)], withRowAnimation: UITableViewRowAnimation.None)
        if self.cellBundle != nil {
            self.cellBundle!.collection.reloadData()
        }
        self.productCrossSell.reloadWithData()
    }
    
    
    
    
    func showProductDetail() {
        if !isShowProductDetail {
            if isContainerHide {
                self.openProductDetail()
            }else {
                self.closeContainer({ () -> Void in
                    }, completeClose: { () -> Void in
                        self.openProductDetail()
                }, closeRow:false)
            }
        }else {
            self.closeContainer({ () -> Void in
                },completeClose:{() in
                    self.isShowProductDetail = false
                    self.productDetailButton.deltailButton.selected = false
            }, closeRow:true)
        }
    }
    
   
    
    func addProductToShoppingCart(upc:String,desc:String,price:String,imageURL:String, comments:String ) {
         if !self.isShowShoppingCart {
            let openShoppingCart = { () -> Void in
                self.isShowShoppingCart = true
                if self.listSelectorController != nil {
                    self.closeContainer({ () -> Void in
                        self.productDetailButton.reloadShoppinhgButton()
                        }, completeClose: { () -> Void in
                         self.addToShoppingCart(upc,desc:desc,price:price,imageURL:imageURL, comments:comments)
                    }, closeRow:false)
                    return
                }else {
                    self.addToShoppingCart(upc,desc:desc,price:price,imageURL:imageURL, comments:comments)
                }
            }
        
            if isContainerHide {
                openShoppingCart()
            }else {
                self.closeContainer({ () -> Void in
                    self.productDetailButton.reloadShoppinhgButton()
                    }, completeClose: { () -> Void in
                        openShoppingCart()
                }, closeRow:false)
            }
         }else{
            self.closeContainer({ () -> Void in
                self.productDetailButton.reloadShoppinhgButton()
                }, completeClose: { () -> Void in
            }, closeRow:true)
        }
        
    }
    
    let heightDetail : CGFloat = 388
    
    func openProductDetail() {
        isShowProductDetail = true
        let frameDetail = CGRectMake(0,0, self.tabledetail.frame.width, heightDetail)
        viewDetail  = ProductDetailTextDetailView(frame: frameDetail)
        viewDetail?.generateBlurImage(self.tabledetail,frame:CGRectMake(0,0, self.tabledetail.frame.width, heightDetail))
        viewDetail?.imageBlurView.frame =  CGRectMake(0, -heightDetail, self.tabledetail.frame.width, heightDetail)
        viewDetail?.setTextDetail(self.detail as String)
        viewDetail?.closeDetail = {() in
            self.closeContainer({ () -> Void in
                },completeClose:{() in
                    self.isShowProductDetail = false
                    self.productDetailButton.deltailButton.selected = false
            }, closeRow:true)
        }
        opencloseContainer(true,viewShow:viewDetail!, additionalAnimationOpen: { () -> Void in
            self.viewDetail?.imageBlurView.frame = frameDetail
            self.productDetailButton.deltailButton.selected = true
            self.productDetailButton.reloadShoppinhgButton()
            },additionalAnimationClose:{ () -> Void in
                self.viewDetail?.imageBlurView.frame =  CGRectMake(0, -self.heightDetail, self.tabledetail.frame.width, self.heightDetail)
                self.productDetailButton.deltailButton.selected = true
            })
    }
    
    func addToShoppingCart(upc:String,desc:String,price:String,imageURL:String, comments:String) {
        
        let frameDetail = CGRectMake(0,0, self.tabledetail.frame.width, heightDetail)
        
        if self.isPesable {
            selectQuantity = ShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(double:self.price.doubleValue))
        }
         else {
            selectQuantity = ShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(double:self.price.doubleValue))
        }
        selectQuantity?.closeAction = { () in
            self.closeContainer({ () -> Void in
                self.productDetailButton.reloadShoppinhgButton()
            }, completeClose: { () -> Void in
                self.isShowShoppingCart = false
            }, closeRow:true)
        }
        selectQuantity?.generateBlurImage(self.tabledetail,frame:CGRectMake(0,0, self.tabledetail.frame.width, heightDetail))
        selectQuantity?.addToCartAction = { (quantity:String) in
            if self.onHandInventory.integerValue >= quantity.toInt() {
                self.closeContainer({ () -> Void in
                    self.productDetailButton.reloadShoppinhgButton()
                    }, completeClose: { () -> Void in
                        
                        self.isShowShoppingCart = false
                        
                        var pesable = self.isPesable ? "1" : "0"
                        
                        var params  =  CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageURL, price: price,quantity: quantity,onHandInventory:"1",pesable:pesable)
                        params.updateValue(comments, forKey: "comments")
                        params.updateValue(self.type, forKey: "type")
                        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
                        
                }, closeRow:true )
            } else {
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                
                let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                let msgInventory = "\(firstMessage)\(self.onHandInventory) \(secondMessage)"
                alert!.setMessage(msgInventory)
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            }
        }
        
        opencloseContainer(true,viewShow:selectQuantity!, additionalAnimationOpen: { () -> Void in
            self.productDetailButton.setOpenQuantitySelector()
            self.selectQuantity?.imageBlurView.frame = frameDetail
            self.productDetailButton.addToShoppingCartButton.selected = true
            },additionalAnimationClose:{ () -> Void in
                self.selectQuantity?.imageBlurView.frame =  CGRectMake(0, -self.heightDetail, self.tabledetail.frame.width, self.heightDetail)
                self.productDetailButton.addToShoppingCartButton.selected = true
            },additionalAnimationFinish: { () -> Void in
                self.productDetailButton.addToShoppingCartButton.setTitleColor(WMColor.navigationTilteTextColor, forState: UIControlState.Normal)
            })
        
    }
    
    func opencloseContainer(open:Bool,viewShow:UIView,additionalAnimationOpen:(() -> Void),additionalAnimationClose:(() -> Void)) {
        
        if isContainerHide && open {
            openContainer(viewShow, additionalAnimationOpen: additionalAnimationOpen, additionalAnimationFinish: { () -> Void in
            })
        } else {
          
        }
        
    }
    
    func opencloseContainer(open:Bool,viewShow:UIView,additionalAnimationOpen:(() -> Void),additionalAnimationClose:(() -> Void),additionalAnimationFinish:(() -> Void)) {
        if isContainerHide && open {
            openContainer(viewShow, additionalAnimationOpen: additionalAnimationOpen, additionalAnimationFinish: additionalAnimationFinish)
        } else {
            
        }
        
    }
    
    func openContainer(viewShow:UIView,additionalAnimationOpen:(() -> Void),additionalAnimationFinish:(() -> Void)) {
        self.isContainerHide = false
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({ () -> Void in
            self.tabledetail.scrollEnabled = false
            
            let finalFrameOfQuantity = CGRectMake(self.tabledetail.frame.minX, self.headerView.frame.maxY, self.tabledetail.frame.width, self.heightDetail)
            self.containerinfo.frame = CGRectMake(self.tabledetail.frame.minX, self.headerView.frame.maxY + self.heightDetail, self.tabledetail.frame.width, 0)
            self.containerinfo.addSubview(viewShow)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.containerinfo.frame = finalFrameOfQuantity
                additionalAnimationOpen()
                }, completion: { (complete:Bool) -> Void in
                additionalAnimationFinish()
            })
            
        })
       
        if self.tabledetail.numberOfRowsInSection(0) == 5 {
            self.tabledetail.beginUpdates()
            self.tabledetail.insertRowsAtIndexPaths([NSIndexPath(forRow: 5, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Bottom)
            self.tabledetail.endUpdates()
            
             self.pagerController!.enabledGesture(false)
        }
        
        CATransaction.commit()
    }
    
    func closeContainer(additionalAnimationClose:(() -> Void),completeClose:(() -> Void), closeRow: Bool) {
        let finalFrameOfQuantity = CGRectMake(self.tabledetail.frame.minX, self.headerView.frame.maxY + heightDetail, self.tabledetail.frame.width, 0)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.containerinfo.frame = finalFrameOfQuantity
            additionalAnimationClose()
            }) { (comple:Bool) -> Void in
                self.isContainerHide = true
                CATransaction.begin()
                CATransaction.setCompletionBlock({ () -> Void in
                    self.isShowShoppingCart = false
                    self.isShowProductDetail = false
                    self.productDetailButton.deltailButton.selected = false
                    self.tabledetail.scrollEnabled = true
                    self.productDetailButton!.listButton.selected = false
                    self.listSelectorController = nil
                    self.listSelectorBackgroundView = nil
                    
                    completeClose()
                    for viewInCont in self.containerinfo.subviews {
                        viewInCont.removeFromSuperview()
                    }
                    self.selectQuantity = nil
                    self.viewDetail = nil
                    
                })
               
                
                if self.tabledetail.numberOfRowsInSection(0) >= 5 && closeRow {
                    self.tabledetail.beginUpdates()
                    self.tabledetail.deleteRowsAtIndexPaths([NSIndexPath(forRow: 5, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Top)
                    self.tabledetail.endUpdates()
                    
                    self.pagerController!.enabledGesture(true)
                }
                CATransaction.commit()
            }
    }
    
    func showMessageProductNotAviable() {
        
        self.showMessageWishList(NSLocalizedString("productdetail.notaviable",comment:""))
        
    }
    
    func addOrRemoveToWishList(upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,added:(Bool) -> Void) {
        
        self.isWishListProcess = true
        
        self.addOrRemoveToWishListBlock = {() in
            if addItem {
                let serviceWishList = AddItemWishlistService()
                serviceWishList.callService(upc, quantity: "1", comments: "",desc:desc,imageurl:imageurl,price:price,isActive:isActive,onHandInventory:onHandInventory,isPreorderable:isPreorderable, successBlock: { (result:NSDictionary) -> Void in
                    added(true)
                    
                    //Event
                    if let tracker = GAI.sharedInstance().defaultTracker {
                        tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue,
                            action: WMGAIUtils.MG_EVENT_PRODUCTDETAIL_ADDTOWISHLIST.rawValue ,
                            label: upc,
                            value: nil).build() as [NSObject : AnyObject])
                    }
                    
                    self.showMessageWishList(NSLocalizedString("wishlist.ready",comment:""))
                    }) { (error:NSError) -> Void in
                        self.isWishListProcess = false
                        if error.code != -100 {
                            added(false)
                            self.showMessageWishList(error.localizedDescription)
                        }
                }
            } else {
                let serviceWishListDelete = DeleteItemWishlistService()
                serviceWishListDelete.callService(upc, successBlock: { (result:NSDictionary) -> Void in
                    added(true)
                    
                    //Event
                    if let tracker = GAI.sharedInstance().defaultTracker {
                        tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue,
                            action: WMGAIUtils.MG_EVENT_PRODUCTDETAIL_REMOVEFROMWISHLIST.rawValue ,
                            label: upc,
                            value: nil).build() as [NSObject : AnyObject])
                    }
                    
                    self.showMessageWishList(NSLocalizedString("wishlist.deleted",comment:""))
                    }, errorBlock: { (error:NSError) -> Void in
                        self.isWishListProcess = false
                        added(false)
                        if error.code != -100 {
                            self.showMessageWishList(error.localizedDescription)
                        }
                })
            }
            //}
        }
        
        if !isContainerHide {
         closeContainer({ () -> Void in
         }, completeClose: { () -> Void in
         }, closeRow:true)
        }
        
        
        self.tabledetail.scrollEnabled = false
        //gestureCloseDetail.enabled = true
        if  self.tabledetail.contentOffset.y != 0.0 {
            self.tabledetail.scrollRectToVisible(CGRectMake(0, 0, self.tabledetail.frame.width,  self.tabledetail.frame.height ), animated: true)
        } else {
            if addOrRemoveToWishListBlock != nil {
                addOrRemoveToWishListBlock!()
            }
        }
        
        
    }
    
    
    func showMessageWishList(message:String) {
        let addedAlertWL = WishlistAddProductStatus(frame: CGRectMake(self.tabledetail.frame.minX, self.tabledetail.frame.minY +  96, self.tabledetail.frame.width, 0))
        addedAlertWL.generateBlurImage(self.view,frame:CGRectMake(self.tabledetail.frame.minX, -96, self.tabledetail.frame.width, 96))
        addedAlertWL.clipsToBounds = true
        addedAlertWL.imageBlurView.frame = CGRectMake(self.tabledetail.frame.minX, -96, self.tabledetail.frame.width, 96)
        addedAlertWL.textView.text = message
        self.view.addSubview(addedAlertWL)
        self.isWishListProcess = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            addedAlertWL.frame = CGRectMake(self.tabledetail.frame.minX,self.tabledetail.frame.minY + 48, self.tabledetail.frame.width, 48)
            }) { (complete:Bool) -> Void in
                UIView.animateWithDuration(0.5, delay: 1, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                    addedAlertWL.frame = CGRectMake(addedAlertWL.frame.minX, self.tabledetail.frame.minY + 96, addedAlertWL.frame.width, 0)
                    }) { (complete:Bool) -> Void in
                        self.tabledetail.scrollEnabled = true
                        addedAlertWL.removeFromSuperview()
                }
        }
        
       
    }
    
    
    //MARK: Load service 
    
    
    func loadDataFromService() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue, action: WMGAIUtils.MG_EVENT_SHOWPRODUCTDETAIL.rawValue, label: upc as String, value: nil).build() as [NSObject : AnyObject])
        }
        
        let productService = ProductDetailService()
        productService.callService(upc as String, successBlock: { (result: NSDictionary) -> Void in
            self.name = result["description"] as! String
            self.price = result["price"] as! String
            self.detail = result["detail"] as! String
            
            self.detail = self.detail.stringByReplacingOccurrencesOfString("^", withString: "\n")
            
            self.saving = ""
            if let savingResult = result["saving"] as? String {
                self.saving = result["saving"] as! String
            }
            self.listPrice = result["original_listprice"] as! String
            self.characteristics = []
            if let cararray = result["characteristics"] as? [AnyObject] {
                self.characteristics = cararray
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
            let freeShippingStr  = result["freeShippingItem"] as! String
            self.freeShipping = "true" == freeShippingStr
            
            var numOnHandInventory : NSString = "0"
            if let numberOf = result["onHandInventory"] as? String{
                numOnHandInventory  = numberOf
            }
            self.onHandInventory  = numOnHandInventory
            
            self.strisActive  = result["isActive"] as! String
            self.isActive = "true" == self.strisActive
            
            if self.isActive == true {
                self.isActive = self.price.doubleValue > 0
            }
            
            if self.isActive == true {
                self.isActive = self.onHandInventory.integerValue > 0
            }
            
            self.strisPreorderable  = result["isPreorderable"] as! String
            self.isPreorderable = "true" == self.strisPreorderable
            
            self.bundleItems = [AnyObject]()
            if let bndl = result["bundleItems"] as?  [AnyObject] {
                self.bundleItems = bndl
            }
            
            self.isLoading = false
            
            self.tabledetail.delegate = self
            self.tabledetail.dataSource = self
            self.tabledetail.reloadData()
            
            
            self.bannerImagesProducts.items = self.imageUrl
            self.bannerImagesProducts.collection.reloadData()
            
            self.loadCrossSell()
            
            self.titlelbl.text = self.name as String
            
            
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
                var empty = IPOGenericEmptyView(frame:CGRectMake(0, self.headerView.frame.maxY, self.view.frame.width, self.view.frame.height - self.headerView.frame.maxY))
                self.name = NSLocalizedString("empty.productdetail.title",comment:"")
                empty.returnAction = { () in
                    println("")
                    self.navigationController!.popViewControllerAnimated(true)
                }
                self.view.addSubview(empty)
        }
    }
    
    func removeListSelector(#action:(()->Void)?, closeRow: Bool ) {
        if  self.listSelectorController != nil {
            self.closeContainer({ () -> Void in
                //action?()
                }, completeClose: { () -> Void in
                    
                    //self.listSelectorController!.willMoveToParentViewController(nil)
                    if self.listSelectorController != nil {
                        self.listSelectorController!.view.removeFromSuperview()
                        self.listSelectorController!.removeFromParentViewController()
                        self.listSelectorController = nil
                    }
                    
                    if self.listSelectorBackgroundView != nil {
                        self.listSelectorBackgroundView!.removeFromSuperview()
                        self.listSelectorBackgroundView = nil
                    }
                    
                    if self.listSelectorContainer != nil {
                        self.listSelectorContainer!.removeFromSuperview()
                        self.listSelectorContainer = nil
                    }
                    
            }, closeRow: closeRow)
        }
    }
    
    
    //MARK: Share product
    func shareProduct() {
        let imageHead = UIImage(named:"detail_HeaderMail")
        // Build header title to share
        var tmpheaderView = UIView(frame:CGRectMake(0, 0, self.bannerImagesProducts.frame.width, heigthHeader))
        tmpheaderView.backgroundColor = WMColor.productDetailHeaderBgColor
        
        //Event
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue,
                action: WMGAIUtils.MG_EVENT_PRODUCTDETAIL_SHAREPRODUCT.rawValue ,
                label: self.upc as String,
                value: nil).build() as [NSObject : AnyObject])
        }
        
        
        var tmptitlelbl = UILabel(frame: CGRectMake(0, 0,tmpheaderView.frame.width , tmpheaderView.frame.height))
        tmptitlelbl.textAlignment = .Center
        tmptitlelbl.text = self.name as String
        tmptitlelbl.numberOfLines = 2
        tmptitlelbl.font = WMFont.fontMyriadProRegularOfSize(14)
        tmptitlelbl.textColor = WMColor.navigationTilteTextColor
        tmptitlelbl.adjustsFontSizeToFitWidth = true
        tmptitlelbl.minimumScaleFactor = 9 / 12
        tmpheaderView.addSubview(tmptitlelbl)
        
        
        let imageHeader = UIImage(fromView: tmpheaderView)
        let headers = [0]
        let items = [NSIndexPath(forRow: 1, inSection: 0),NSIndexPath(forRow: 2, inSection: 0),NSIndexPath(forRow: 3, inSection: 0),NSIndexPath(forRow: 4, inSection: 0)]
        let screen = self.tabledetail.screenshotOfHeadersAtSections( NSSet(array:headers) as Set<NSObject>, footersAtSections: nil, rowsAtIndexPaths: NSSet(array: items) as Set<NSObject>)
        
        let product = self.bannerImagesProducts.collection.cellForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! ProductDetailBannerMediaCollectionViewCell!
        
        println(imageHead!.size)
        println(imageHeader.size)
        println(product.imageView!.image!.size)
        println(screen.size)
        
        
        let urlWmart = UserCurrentSession.urlWithRootPath("http://www.walmart.com.mx/Busqueda.aspx?Text=\(self.upc)")
        
        let imgResult = UIImage.verticalImageFromArrayProdDetail([imageHead!,imageHeader,product.imageView!.image!,screen])
        //let imgResult = UIImage.verticalImageFromArray([imageHead!,product.imageView!.image!,screen],andWidth:320)
        var controller = UIActivityViewController(activityItems: [self,imgResult,urlWmart!], applicationActivities: nil)
        popup = UIPopoverController(contentViewController: controller)
        
        popup!.presentPopoverFromRect(CGRectMake(700, 100, 300, 100), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        
    }
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject{
        return "Walmart"
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        var toUseName = ""
        if self.name.length > 32 {
            toUseName = self.name.substringToIndex(32)
            toUseName = "\(toUseName)..."
        } else {
            toUseName = self.name as String
        }

        if activityType == UIActivityTypeMail {
            return "Hola, Me gustó este producto de Walmart. ¡Te lo recomiendo!\n\(self.name) \nSiempre encuentra todo y pagas menos"
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
                return "\(UserCurrentSession.sharedInstance().userSigned!.profile.name) \(UserCurrentSession.sharedInstance().userSigned!.profile.lastName) encontró un producto que te puede interesar en www.walmart.com.mx"
            }
        }
        return ""
    }

        
    func sleectedImage(indexPath:NSIndexPath){
        var controller = ImageDisplayCollectionViewController()
        controller.name = self.name as String
        controller.imagesToDisplay = imageUrl
        controller.currentItem = indexPath.row
        controller.type = self.type as String
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
}

