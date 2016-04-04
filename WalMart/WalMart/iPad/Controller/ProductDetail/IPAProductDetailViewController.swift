//
//  IPAProductDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAProductDetailViewController : UIViewController, UITableViewDelegate , UITableViewDataSource,UINavigationControllerDelegate,ProductDetailCrossSellViewDelegate,ProductDetailButtonBarCollectionViewCellDelegate,UIActivityItemSource ,ProductDetailBannerCollectionViewDelegate, ProductDetailColorSizeDelegate{
    
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
    var productDetailButton: ProductDetailButtonBarCollectionViewCell?
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
    var colorItems : [AnyObject] = []
    var sizeItems : [AnyObject] = []
    var facets: [[String:AnyObject]]? = nil
    var facetsDetails: [String:AnyObject]? = nil
    var selectedDetailItem: [String:String]? = nil
    var colorsView: ProductDetailColorSizeView? = nil
    var sizesView: ProductDetailColorSizeView? = nil
    var colorSizeViewCell: UIView? = nil
    var isGift: Bool = false
    var fromSearch =  false
    var isEmpty: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = UIView(frame:CGRectMake(0, 0, self.view.bounds.width, heigthHeader))
        headerView.backgroundColor = WMColor.light_light_gray
        
        let buttonBk = UIButton(frame: CGRectMake(0, 0, 46, 46))
        buttonBk.setImage(UIImage(named:"BackProduct"), forState: UIControlState.Normal)
        buttonBk.addTarget(self, action: "backButton", forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(buttonBk)
        
        titlelbl = UILabel(frame: CGRectMake(46, 0, self.view.frame.width - (46 * 2), heigthHeader))
        titlelbl.textAlignment = .Center
        titlelbl.text = self.name as String
        titlelbl.numberOfLines = 2
        titlelbl.font = WMFont.fontMyriadProRegularOfSize(14)
        titlelbl.textColor = WMColor.light_blue
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
        tabledetail.registerClass(UITableViewCell.self, forCellReuseIdentifier: "colorsCell")

        tabledetail.separatorStyle = UITableViewCellSeparatorStyle.None
        
        let separator = UIView(frame: CGRectMake(tabledetail.frame.minX, headerView.frame.maxY,1, self.view.bounds.height))
        separator.backgroundColor = WMColor.light_light_gray
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "endUpdatingShoppingCart:", name: CustomBarNotification.UpdateBadge.rawValue, object: nil)
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "backButton", name: CustomBarNotification.finishUserLogOut.rawValue, object: nil)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
  
    func didPinch(sender:UIPinchGestureRecognizer){
        if  sender.scale < 1 {
            self.backButton()
        }
    }
    
    func backButton () {
        if  self.navigationController != nil {
            if self.pagerController != nil && self.pagerController!.pageController!.viewControllers!.count > 1{
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
        crossService.callService(self.upc as String, successBlock: { (result:NSArray?) -> Void in
            if result != nil {
                self.itemsCrossSellUPC = result!
                if self.itemsCrossSellUPC.count > 0{
                    self.productCrossSell.reloadWithData(self.itemsCrossSellUPC, upc: self.upc as String)
                }
            }
            }, errorBlock: { (error:NSError) -> Void in
                print("Termina sevicio app")
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
            let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath)
            cell = cellSpace
        case (0,1) :
            if self.colorItems.count > 0 || self.sizeItems.count > 0{
                let cellColors = tabledetail.dequeueReusableCellWithIdentifier("colorsCell", forIndexPath: indexPath)
                if colorSizeViewCell == nil {
                    self.buildColorSizeCell(cellColors.frame.width)
                    self.clearView(cellColors)
                    cellColors.addSubview(self.colorSizeViewCell!)
                }
                cell = cellColors
            }else{
                let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath)
                cell = cellSpace
            }
        case (0,2) :
            if self.saving.doubleValue > 0{
                let cellListPrice = tabledetail.dequeueReusableCellWithIdentifier("priceCell", forIndexPath: indexPath) as? ProductDetailCurrencyCollectionView
                let formatedValue = "\(CurrencyCustomLabel.formatString(self.listPrice))"
                cellListPrice!.setValues(formatedValue, font: WMFont.fontMyriadProLightOfSize(14), textColor: WMColor.gray, interLine: true)
                cell = cellListPrice
            }else{
                let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath)
                cell = cellSpace
            }
            
        case (0,3) :
            let cellPrice = tabledetail.dequeueReusableCellWithIdentifier("priceCell", forIndexPath: indexPath) as? ProductDetailCurrencyCollectionView
            let formatedValue = CurrencyCustomLabel.formatString(self.price)
            cellPrice!.setValues(formatedValue, font: WMFont.fontMyriadProSemiboldSize(30), textColor: WMColor.orange, interLine: false)
            cell = cellPrice
        case (0,4) :
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
                    
                    cellAhorro!.setValues(savingSend as String, font: WMFont.fontMyriadProSemiboldOfSize(14), textColor: WMColor.green, interLine: false)
                    cell = cellAhorro
                }else {
                    let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath)
                    cell = cellSpace
                }
            } else{
                let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath)
                cell = cellSpace
            }
        case (0,5) :
            let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath)
            cell = cellSpace
        case (0,6) :
            let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath)
            cell = cellSpace
        case (1,0) :
            if  msi.count != 0 {
                let cellPromotion = tabledetail.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as? ProductDetailLabelCollectionView
                let msiText = NSLocalizedString("productdetail.msitext",comment:"")
                cellPromotion!.setValues(msiText, font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.orange, padding: 12,align:NSTextAlignment.Left)
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
                cellBundleItemsTitle!.setValues(charText, font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.light_blue, padding: 12,align:NSTextAlignment.Left)
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
                self.clearView(cellCharacteristicsTitle!)
                let charText = NSLocalizedString("productdetail.characteristics",comment:"")
                cellCharacteristicsTitle!.setValues(charText, font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.light_blue, padding: 12,align:NSTextAlignment.Left)
                cell = cellCharacteristicsTitle
            }else{
                return nil
            }
        case (1,5) :
            if characteristics.count != 0 {
                let cellCharacteristics = tabledetail.dequeueReusableCellWithIdentifier("cellCharacteristics", forIndexPath: indexPath) as? ProductDetailCharacteristicsTableViewCell
                //self.clearView(cellCharacteristics!)
                cellCharacteristics!.setValues(characteristics)
                cell = cellCharacteristics
            }else{
                return nil
            }
        case (1,6) :
            let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath)
            cell = cellSpace
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
        case (0,1) :
            var colorSizeHeight:CGFloat = 5.0
            if self.colorItems.count != 0 && self.sizeItems.count != 0 {
                colorSizeHeight = 80.0
            }else if self.colorItems.count != 0 && self.sizeItems.count == 0 {
                colorSizeHeight = 40.0
            }else if self.colorItems.count == 0 && self.sizeItems.count != 0 {
                colorSizeHeight = 40.0
            }
            return colorSizeHeight
        case (0,3) :
            return 36.0
        case (0,2),(0,4) :
            return 15.0
        case (0,5) :
            return 15.0
        case (0,6) :
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
        //let headerView = UIView()
        switch section {
        case 0:
          return nil
        default:
            
            if isLoading {
                return UIView()
            }
            
            productDetailButton = ProductDetailButtonBarCollectionViewCell(frame: CGRectMake(0, 0, self.view.frame.width, 64.0),spaceBetweenButtons:13,widthButtons:63)
            productDetailButton!.upc = self.upc as String
            productDetailButton!.desc = self.name as String
            productDetailButton!.price = self.price as String
            productDetailButton!.onHandInventory = self.onHandInventory as String
            productDetailButton!.isActive = self.strisActive as String
            productDetailButton!.isPreorderable = self.strisPreorderable as String
            productDetailButton!.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButton!.reloadButton()
            productDetailButton!.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCWishlist(self.upc as String)
            productDetailButton!.listButton.enabled = !self.isGift
            var imageUrl = ""
            if self.imageUrl.count > 0 {
                imageUrl = self.imageUrl[0] as! NSString as String
            }
            productDetailButton!.image = imageUrl
            productDetailButton!.delegate = self
            return productDetailButton!
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
        
        let paginatedProductDetail = IPAProductDetailPageViewController()
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
                    self.productDetailButton!.deltailButton.selected = false
            }, closeRow:true)
        }
    }
    
   
    
    func addProductToShoppingCart(upc:String,desc:String,price:String,imageURL:String, comments:String ) {
         if !self.isShowShoppingCart {
            let openShoppingCart = { () -> Void in
                self.isShowShoppingCart = true
                if self.listSelectorController != nil {
                    self.closeContainer({ () -> Void in
                        self.productDetailButton!.reloadShoppinhgButton()
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
                    self.productDetailButton?.reloadShoppinhgButton()
                    }, completeClose: { () -> Void in
                        openShoppingCart()
                }, closeRow:false)
            }
         }else{
            self.closeContainer({ () -> Void in
                self.productDetailButton?.reloadShoppinhgButton()
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
                    self.productDetailButton!.deltailButton.selected = false
            }, closeRow:true)
        }
        opencloseContainer(true,viewShow:viewDetail!, additionalAnimationOpen: { () -> Void in
            self.viewDetail?.imageBlurView.frame = frameDetail
            self.productDetailButton!.deltailButton.selected = true
            self.productDetailButton?.reloadShoppinhgButton()
            },additionalAnimationClose:{ () -> Void in
                self.viewDetail?.imageBlurView.frame =  CGRectMake(0, -self.heightDetail, self.tabledetail.frame.width, self.heightDetail)
                self.productDetailButton!.deltailButton.selected = true
            })
    }
    
    func addToShoppingCart(upc:String,desc:String,price:String,imageURL:String, comments:String) {
        
        let frameDetail = CGRectMake(0,0, self.tabledetail.frame.width, heightDetail)
        
        if self.isPesable {
            selectQuantity = ShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(double:self.price.doubleValue),upcProduct:self.upc as String)
        }
         else {
            selectQuantity = ShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(double:self.price.doubleValue),upcProduct:self.upc as String)
        }
        selectQuantity?.closeAction = { () in
            self.closeContainer({ () -> Void in
                self.productDetailButton?.reloadShoppinhgButton()
            }, completeClose: { () -> Void in
                self.isShowShoppingCart = false
            }, closeRow:true)
        }
        selectQuantity?.generateBlurImage(self.tabledetail,frame:CGRectMake(0,0, self.tabledetail.frame.width, heightDetail))
        selectQuantity?.addToCartAction = { (quantity:String) in
            let maxProducts = self.onHandInventory.integerValue <= 5 ? self.onHandInventory.integerValue : 5
            if maxProducts >= Int(quantity) {
                self.closeContainer({ () -> Void in
                    self.productDetailButton?.reloadShoppinhgButton()
                    }, completeClose: { () -> Void in
                        
                        self.isShowShoppingCart = false
                        
                        let pesable = self.isPesable ? "1" : "0"
                        
                        var params  =  CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageURL, price: price,quantity: quantity,onHandInventory:"\(maxProducts)",pesable:pesable,isPreorderable:"\(self.isPreorderable)")
                        params.updateValue(comments, forKey: "comments")
                        params.updateValue(self.type, forKey: "type")
                        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
                        
                }, closeRow:true )
            } else {
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                
                let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                let msgInventory = "\(firstMessage)\(maxProducts) \(secondMessage)"
                alert!.setMessage(msgInventory)
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                self.selectQuantity?.lblQuantity?.text = "0\(maxProducts)"
            }
        }
        
        opencloseContainer(true,viewShow:selectQuantity!, additionalAnimationOpen: { () -> Void in
            self.productDetailButton?.setOpenQuantitySelector()
            self.selectQuantity?.imageBlurView.frame = frameDetail
            self.productDetailButton!.addToShoppingCartButton.selected = true
            self.productDetailButton?.reloadShoppinhgButton()
            },additionalAnimationClose:{ () -> Void in
                self.selectQuantity?.imageBlurView.frame =  CGRectMake(0, -self.heightDetail, self.tabledetail.frame.width, self.heightDetail)
                self.productDetailButton!.addToShoppingCartButton.selected = true
            },additionalAnimationFinish: { () -> Void in
                self.productDetailButton?.addToShoppingCartButton.setTitleColor(WMColor.light_blue, forState: UIControlState.Normal)
            })
        
        
        self.productDetailButton?.reloadButton()
    }
    
    func opencloseContainer(open:Bool,viewShow:UIView,additionalAnimationOpen:(() -> Void),additionalAnimationClose:(() -> Void)) {
        
        if isContainerHide && open {
            openContainer(viewShow, additionalAnimationOpen: additionalAnimationOpen, additionalAnimationFinish: { () -> Void in
            })
        } else {
          
        }
        
    }
    
    func endUpdatingShoppingCart(sender:AnyObject) {
        self.productDetailButton?.reloadShoppinhgButton()
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
                    self.productDetailButton!.deltailButton.selected = false
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
                    BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ADD_WISHLIST.rawValue, label: "\(self.name) - \(self.upc)")
                    
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
                    BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_PRODUCT_WISHLIST.rawValue, label: "\(self.name) - \(self.upc)")
                    
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
        
        let signalsDictionary : NSDictionary = NSDictionary(dictionary: ["signals" : GRBaseService.getUseSignalServices()])
        let productService = ProductDetailService(dictionary: signalsDictionary)
        let eventType = self.fromSearch ? "clickdetails" : "pdpview"
        let params = productService.buildParams(upc as String,eventtype: eventType)
        productService.callService(requestParams:params, successBlock: { (result: NSDictionary) -> Void in
            
            self.reloadViewWithData(result)
            if let facets = result["facets"] as? [[String:AnyObject]] {
                self.facets = facets
                self.facetsDetails = self.getFacetsDetails()
                let keys = Array(self.facetsDetails!.keys)
                if self.facetsDetails?.count > 1 {
                    if let colors = self.facetsDetails![keys.first!] as? [AnyObject]{
                        self.colorItems = colors
                    }
                }
                if self.facetsDetails?.count > 2 {
                    if let sizes = self.facetsDetails![keys[1]] as? [AnyObject]{
                        self.sizeItems = sizes
                    }
                }
            }
            
            }) { (error:NSError) -> Void in
                let empty = IPOGenericEmptyView(frame:CGRectMake(0, self.headerView.frame.maxY, self.view.frame.width, self.view.frame.height - self.headerView.frame.maxY))
                self.name = NSLocalizedString("empty.productdetail.title",comment:"")
                empty.returnAction = { () in
                    print("Return Button")
                    self.navigationController!.popViewControllerAnimated(true)
                }
                self.isEmpty = true
                self.view.addSubview(empty)
        }
    }
    
    func reloadViewWithData(result:NSDictionary){
        self.name = result["description"] as! String
        self.price = result["price"] as! String
        self.detail = result["detail"] as! String
        self.upc = result["upc"] as! NSString
        if let isGift = result["isGift"] as? Bool{
            self.isGift = isGift
        }
        
        self.detail = self.detail.stringByReplacingOccurrencesOfString("^", withString: "\n")
        
        self.saving = ""
        if let savingResult = result["saving"] as? String {
            self.saving = savingResult
        }
        self.listPrice = result["original_listprice"] as! String
        self.characteristics = []
        if let cararray = result["characteristics"] as? [AnyObject] {
            self.characteristics = cararray
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
        if self.isPreorderable {
            bannerImagesProducts.imagePresale.hidden = false
        }
        
        if let lowStock = result["lowStock"] as? Bool{
            //bannerImagesProducts.imageLastPieces.hidden = !lowStock
            bannerImagesProducts.lowStock?.hidden = !lowStock
        }
         //bannerImagesProducts.lowStock?.hidden =  false
        
        
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
            
            let product = GAIEcommerceProduct()
            let builder = GAIDictionaryBuilder.createScreenView()
            product.setId(self.upc as String)
            product.setName(self.name as String)
            
            let action = GAIEcommerceProductAction();
            action.setAction(kGAIPADetail)
            builder.setProductAction(action)
            builder.addProduct(product)
            
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue)
            tracker.send(builder.build() as [NSObject : AnyObject])
        }
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHOW_PRODUCT_DETAIL.rawValue, label: "\(self.name) - \(self.upc)")
        
    }
    
    func removeListSelector(action action:(()->Void)?, closeRow: Bool ) {
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
        let tmpheaderView = UIView(frame:CGRectMake(0, 0, self.bannerImagesProducts.frame.width, heigthHeader))
        tmpheaderView.backgroundColor = WMColor.light_light_gray
        
        //Event
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: "\(self.name) - \(self.upc)")
        
        let tmptitlelbl = UILabel(frame: CGRectMake(0, 0,tmpheaderView.frame.width , tmpheaderView.frame.height))
        tmptitlelbl.textAlignment = .Center
        tmptitlelbl.text = self.name as String
        tmptitlelbl.numberOfLines = 2
        tmptitlelbl.font = WMFont.fontMyriadProRegularOfSize(14)
        tmptitlelbl.textColor = WMColor.light_blue
        tmptitlelbl.adjustsFontSizeToFitWidth = true
        tmptitlelbl.minimumScaleFactor = 9 / 12
        tmpheaderView.addSubview(tmptitlelbl)
        
        
        let imageHeader = UIImage(fromView: tmpheaderView)
        let headers = [0]
        let items = [NSIndexPath(forRow: 1, inSection: 0),NSIndexPath(forRow: 2, inSection: 0),NSIndexPath(forRow: 3, inSection: 0),NSIndexPath(forRow: 4, inSection: 0)]
        let screen = self.tabledetail.screenshotOfHeadersAtSections( NSSet(array:headers) as Set<NSObject>, footersAtSections: nil, rowsAtIndexPaths: NSSet(array: items) as Set<NSObject>)
        
        let product = self.bannerImagesProducts.collection.cellForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! ProductDetailBannerMediaCollectionViewCell!
        
        print(imageHead!.size)
        print(imageHeader.size)
        print(product.imageView!.image!.size)
        print(screen.size)
        
        
        let urlWmart = UserCurrentSession.urlWithRootPath("http://www.walmart.com.mx/Busqueda.aspx?Text=\(self.upc)")
        
        let imgResult = UIImage.verticalImageFromArrayProdDetail([imageHead!,imageHeader,product.imageView!.image!,screen])
        //let imgResult = UIImage.verticalImageFromArray([imageHead!,product.imageView!.image!,screen],andWidth:320)
        let controller = UIActivityViewController(activityItems: [self,imgResult,urlWmart!], applicationActivities: nil)
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
    
    func showProductDetailOptions() {
        let controller = ProductDetailOptionsViewController()
        controller.upc = self.upc as String
        controller.name = self.name as String
        controller.imagesToDisplay = imageUrl
        controller.currentItem = 0
        controller.onHandInventory = self.onHandInventory
        controller.detailProductCart = self.productDetailButton!.detailProductCart
        controller.strIsPreorderable = self.isPreorderable ? "true" : "false"
        controller.facets = self.facets
        controller.facetsDetails = self.facetsDetails
        controller.colorItems = self.colorItems
        controller.selectedDetailItem = self.selectedDetailItem
        controller.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
        controller.setAdditionalValues(self.listPrice as String, price: self.price as String, saving: self.saving as String)
    }
    
    // MARK Color Size Functions
    func getFacetsDetails() -> [String:AnyObject]{
        var facetsDetails : [String:AnyObject] = [String:AnyObject]()
        for product in self.facets! {
            let details = product["details"] as! [AnyObject]
            var itemDetail = [String:String]()
            itemDetail["upc"] = product["upc"] as? String
            for detail in details{
                let label = detail["description"] as! String
                var values = facetsDetails[label] as? [AnyObject]
                if values == nil{ values = []}
                let itemToAdd = ["value":detail["unit"] as! String, "enabled": (details.count == 1 || label == "Color") ? 1 : 0, "type": label]
                if !(values! as NSArray).containsObject(itemToAdd) {
                    values!.append(itemToAdd)
                }
                facetsDetails[label] = values
                itemDetail[label] = detail["unit"] as? String
            }
            var detailsValues = facetsDetails["itemDetails"] as? [AnyObject]
            if detailsValues == nil{ detailsValues = []}
            detailsValues!.append(itemDetail)
            facetsDetails["itemDetails"] = detailsValues
        }
        return facetsDetails
    }
    
    func getUpc(itemsSelected: [String:String]) -> String
    {
        var upc = ""
        var isSelected = false
        let details = self.facetsDetails!["itemDetails"] as? [AnyObject]
        for item in details! {
            for selectItem in itemsSelected{
                if item[selectItem.0] as! String == selectItem.1{
                    isSelected = true
                }
                else{
                    isSelected = false
                }
            }
            if isSelected{
                upc = item["upc"] as! String
            }
        }
        return upc
    }
    
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
    
    func sleectedImage(indexPath:NSIndexPath){
        let controller = ImageDisplayCollectionViewController()
        controller.name = self.name as String
        controller.imagesToDisplay = imageUrl
        controller.currentItem = indexPath.row
        controller.type = self.type as String
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
        
        
    }
    
    func clearView(view: UIView){
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
    }
    
    //MARK: ProductDetailColorSizeDelegate
    func selectDetailItem(selected: String, itemType: String) {
        var detailOrderCount = 0
        if self.colorItems.count != 0 && self.sizeItems.count != 0 {
            detailOrderCount = 2
        }else if self.colorItems.count != 0 && self.sizeItems.count == 0 {
            detailOrderCount = 1
        }else if self.colorItems.count == 0 && self.sizeItems.count != 0 {
            detailOrderCount = 1
        }
        if self.selectedDetailItem == nil{
            self.selectedDetailItem = [:]
        }
        if itemType == "Color"{
            self.selectedDetailItem = [:]
            if detailOrderCount > 1 {
                //MARCAR desmarcar las posibles tallas
                let sizes = self.getDetailsWithKey(itemType, value: selected, keyToFind: "Talla")
                for view in self.sizesView!.viewToInsert!.subviews {
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
    
    func buildColorSizeCell(width: CGFloat){
        if self.colorSizeViewCell != nil {
            self.clearView(self.colorSizeViewCell!)
        }else{
            self.colorSizeViewCell = UIView()
        }
        if colorItems.count != 0 || sizeItems.count != 0{
            if colorItems.count != 0 && sizeItems.count != 0{
                self.colorsView = ProductDetailColorSizeView()
                self.colorsView?.items = self.colorItems
                self.colorsView!.buildViewForColors(self.colorItems as! [[String:AnyObject]])
                self.colorsView!.alpha = 1.0
                self.colorsView!.frame =  CGRectMake(0,0, width, 40.0)
                self.colorsView!.buildItemsView()
                self.colorsView?.delegate = self
                self.sizesView = ProductDetailColorSizeView()
                self.sizesView!.items = self.sizeItems
                self.sizesView!.buildViewForColors(self.sizeItems as! [[String:AnyObject]])
                self.sizesView!.alpha = 1.0
                self.sizesView!.frame =  CGRectMake(0,40,width, 40.0)
                self.sizesView!.buildItemsView()
                self.sizesView?.delegate = self
                self.colorsView!.deleteTopBorder()
                self.sizesView!.deleteTopBorder()
                self.colorSizeViewCell?.frame = CGRectMake(0,0, width, 80.0)
                self.colorSizeViewCell?.addSubview(colorsView!)
                self.colorSizeViewCell?.addSubview(sizesView!)
            }else if colorItems.count != 0 && sizeItems.count == 0{
                self.sizesView?.alpha = 0
                self.colorsView = ProductDetailColorSizeView()
                self.colorsView!.items = self.colorItems
                self.colorsView!.buildViewForColors(self.colorItems as! [[String:AnyObject]])
                self.colorsView!.alpha = 1.0
                self.colorsView!.frame =  CGRectMake(0,0, width, 40.0)
                self.colorsView!.buildItemsView()
                self.colorsView?.delegate = self
                self.colorsView!.deleteTopBorder()
                self.colorSizeViewCell?.frame = CGRectMake(0,0, width, 40.0)
                self.colorSizeViewCell?.addSubview(colorsView!)
            }else if colorItems.count == 0 && sizeItems.count != 0{
                self.colorsView?.alpha = 0
                self.sizesView = ProductDetailColorSizeView()
                self.sizesView!.items = self.sizeItems
                self.sizesView!.buildViewForColors(self.sizeItems as! [[String:AnyObject]])
                self.sizesView!.alpha = 1.0
                self.sizesView!.frame =  CGRectMake(0,0,width, 40.0)
                self.sizesView!.buildItemsView()
                self.sizesView?.delegate = self
                self.sizesView!.deleteTopBorder()
                self.colorSizeViewCell?.frame = CGRectMake(0,0, width, 40.0)
                self.colorSizeViewCell?.addSubview(sizesView!)
            }
        }else{
            self.colorsView?.alpha = 0
            self.sizesView?.alpha = 0
        }
    }
}

