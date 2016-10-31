//
//  IPAProductDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
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


class IPAProductDetailViewController : UIViewController, UITableViewDelegate , UITableViewDataSource,UINavigationControllerDelegate,ProductDetailCrossSellViewDelegate,ProductDetailButtonBarCollectionViewCellDelegate,UIActivityItemSource ,ProductDetailBannerCollectionViewDelegate, ProductDetailColorSizeDelegate,ListSelectorDelegate,IPAUserListDetailDelegate{
    
    var listSelectorController: ListsSelectorViewController?
    var listSelectorContainer: UIView?
    var listSelectorBackgroundView: UIImageView?
    
    var animationController : ProductDetailNavigatinAnimationController!
    var viewLoad : WMLoadingView!
    var msi : NSArray = []
    var upc : NSString = ""
    var sku : NSString = ""
    var name : NSString = ""
    var detail : NSString = ""
    var saving : NSString = ""
    var price : NSString = ""
    var listPrice : NSString = ""
    var ingredients: String = ""
    var nutrimentalInfo: [String: String] = [:]
    var type : NSString = ResultObjectType.Mg.rawValue as NSString
    var imageUrl : [AnyObject] = []
    var characteristics : [AnyObject] = []
    var bundleItems : [AnyObject] = []
    var freeShipping : Bool = false
    var isLoading : Bool = false
    var productDetailButton: ProductDetailButtonBarCollectionViewCell?
    var isShowProductDetail : Bool = false
    var isShowShoppingCart : Bool = false
    var isHideCrossSell : Bool = true
    var indexSelected  : Int = 0
    var gestureCloseDetail : UITapGestureRecognizer!
    var itemsCrossSellUPC : NSArray! = []
    var bannerImagesProducts : IPAProductDetailBannerView!
    var productCrossSell : IPAProductCrossSellView!
    var tabledetail : UITableView!
    var headerView : UIView!
    var isContainerHide : Bool = true
    var containerinfo : UIView!
    var isActive : Bool! = true
    var onHandInventory : NSString = "0"
    var strisActive : NSString = ""
    var cellBundle : IPAProductDetailBundleTableViewCell? = nil
    var titlelbl : UILabel!
    var isPreorderable : Bool = false
    var strisPreorderable : NSString = ""
    
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
    var idListSelected = ""
    var productDeparment: String = ""
    var stringSearch = ""
    var defaultLoadingImg: UIImageView?
    var nutrimentalsView : GRNutrimentalInfoView? = nil
    var selectQuantityGR : GRShoppingCartQuantitySelectorView!
    var visibleDetailList = false
    var detailList  : IPAUserListDetailViewController? = nil
    var equivalenceByPiece : NSNumber! = NSNumber(value: 0 as Int32)
    
    var indexRowSelected : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = UIView(frame:CGRect(x: 0, y: 0, width: self.view.bounds.width, height: heigthHeader))
        headerView.backgroundColor = WMColor.light_light_gray
        
        let buttonBk = UIButton(frame: CGRect(x: 0, y: 0, width: 46, height: 46))
        buttonBk.setImage(UIImage(named:"BackProduct"), for: UIControlState())
        buttonBk.addTarget(self, action: #selector(IPAProductDetailViewController.backButton), for: UIControlEvents.touchUpInside)
        headerView.addSubview(buttonBk)
        
        titlelbl = UILabel(frame: CGRect(x: 46, y: 0, width: self.view.frame.width - (46 * 2), height: heigthHeader))
        titlelbl.textAlignment = .center
        titlelbl.text = self.name as String
        titlelbl.numberOfLines = 2
        titlelbl.font = WMFont.fontMyriadProRegularOfSize(14)
        titlelbl.textColor = WMColor.light_blue
        titlelbl.adjustsFontSizeToFitWidth = true
        titlelbl.minimumScaleFactor = 9 / 12
        headerView.addSubview(titlelbl)

        bannerImagesProducts =  IPAProductDetailBannerView(frame:CGRect(x: 0, y: heigthHeader, width: 682, height: 388))
        bannerImagesProducts.delegate = self
        
        defaultLoadingImg = UIImageView(frame:CGRect(x: 327, y: heigthHeader + 180, width: 28, height: 28))
        defaultLoadingImg!.image = UIImage(named: "img_default_cell")
        defaultLoadingImg!.contentMode = UIViewContentMode.scaleAspectFit
       
        self.view.backgroundColor = UIColor.white
        
        productCrossSell = IPAProductCrossSellView(frame:CGRect(x: 0, y: bannerImagesProducts.frame.maxY, width: 682, height: 226))
        productCrossSell.delegate = self
 
        tabledetail = UITableView(frame:CGRect(x: bannerImagesProducts.frame.maxX, y: headerView.frame.maxY, width: self.view.bounds.width - productCrossSell.frame.width, height: self.view.bounds.height - heigthHeader))
        tabledetail.register(ProductDetailCurrencyCollectionView.self, forCellReuseIdentifier: "priceCell")
        tabledetail.register(UITableViewCell.self, forCellReuseIdentifier: "emptyCell")
        tabledetail.register(ProductDetailLabelCollectionView.self, forCellReuseIdentifier: "labelCell")
        tabledetail.register(ProductDetailMSITableViewCell.self, forCellReuseIdentifier: "msiCell")
        tabledetail.register(ProductDetailCrossSellTableViewCell.self, forCellReuseIdentifier: "crossSellCell")
        tabledetail.register(ProductDetailCharacteristicsTableViewCell.self, forCellReuseIdentifier: "cellCharacteristics")
        tabledetail.register(IPAProductDetailBundleTableViewCell.self, forCellReuseIdentifier: "cellBundleitems")
        tabledetail.register(UITableViewCell.self, forCellReuseIdentifier: "colorsCell")

        tabledetail.separatorStyle = UITableViewCellSeparatorStyle.none
        
        let separator = UIView(frame: CGRect(x: tabledetail.frame.minX, y: headerView.frame.maxY,width: 1, height: self.view.bounds.height))
        separator.backgroundColor = WMColor.light_light_gray
        
        //NSNotificationCenter.defaultCenter().postNotificationName(IPACustomBarNotification.HideBar.toRaw(), object: nil)
        
        self.containerinfo = UIView()
        self.containerinfo.clipsToBounds = true
        
        let gestureClose = UIPinchGestureRecognizer(target: self, action: #selector(IPAProductDetailViewController.didPinch(_:)))
        self.view.addGestureRecognizer(gestureClose)
        
        self.view.addSubview(headerView)
        self.view.addSubview(productCrossSell)
        self.view.addSubview(tabledetail)
        self.view.addSubview(bannerImagesProducts)
        self.view.addSubview(containerinfo)
        self.view.addSubview(separator)
        self.view.addSubview(defaultLoadingImg!)
        loadDataFromService()
        bannerImagesProducts.imageIconView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(IPAProductDetailViewController.endUpdatingShoppingCart(_:)), name: NSNotification.Name(rawValue: CustomBarNotification.UpdateBadge.rawValue), object: nil)
        productCrossSell.setIdList(self.idListSelected) //
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "backButton", name: CustomBarNotification.finishUserLogOut.rawValue, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    
  
    func didPinch(_ sender:UIPinchGestureRecognizer){
        if  sender.scale < 1 {
            self.backButton()
        }
    }
    
    func backButton () {
        if  self.navigationController != nil {
            let viewControllers = self.navigationController!.viewControllers.count
            if !(viewControllers > 1 &&  self.navigationController!.viewControllers[viewControllers - 2].isKind(of: IPAProductDetailPageViewController.self)){
               self.navigationController!.delegate = self.pagerController
            }
            self.navigationController!.popViewController(animated: true)
        }
    }
   
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabledetail.frame = CGRect(x: bannerImagesProducts.frame.maxX, y: self.headerView.frame.maxY, width: self.view.bounds.width - productCrossSell.frame.width, height: self.view.bounds.height - heigthHeader )
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: heigthHeader)
        titlelbl.frame = CGRect(x: 46, y: 0, width: self.view.frame.width - (46 * 2), height: heigthHeader)
        
    }
    
    func loadCrossSell() {
        let crossService = CrossSellingProductService()
        crossService.callService(requestParams: ["skuId":self.sku] , successBlock: { (result:NSArray?) -> Void in
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        NSLog("\(indexPath)")
        NSLog("PD 1")
        var cell : UITableViewCell? = nil
        let point = ((indexPath as NSIndexPath).section,(indexPath as NSIndexPath).row)
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
            var rowChose = (indexPath as NSIndexPath).row
            if msi.count == 0 {rowChose += 2}
            cell = cellForPoint(((indexPath as NSIndexPath).section,rowChose), indexPath: indexPath)
        case (1,1) :
            var rowChose = (indexPath as NSIndexPath).row
            if msi.count == 0 {rowChose += 2}
            if bundleItems.count == 0 {rowChose += 2}
            cell = cellForPoint(((indexPath as NSIndexPath).section,rowChose), indexPath: indexPath)
        case (1,2) :
            var rowChose = (indexPath as NSIndexPath).row
            if msi.count == 0 {rowChose += 2}
            if bundleItems.count == 0 {rowChose += 2}
            cell = cellForPoint(((indexPath as NSIndexPath).section,rowChose), indexPath: indexPath)
        case (1,3) :
            var rowChose = (indexPath as NSIndexPath).row
            if msi.count == 0 {rowChose += 2}
            if bundleItems.count == 0 {rowChose += 2}
            cell = cellForPoint(((indexPath as NSIndexPath).section,rowChose), indexPath: indexPath)
        case (1,4) :
            var rowChose = (indexPath as NSIndexPath).row
            if msi.count == 0 {rowChose += 2}
            if bundleItems.count == 0 {rowChose += 2}
            cell = cellForPoint(((indexPath as NSIndexPath).section,rowChose), indexPath: indexPath)
        case (1,5) :
            let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            cell = cellSpace
        default :
            cell = nil
        }
        NSLog("PD 3")
        if cell != nil {
            cell!.selectionStyle = UITableViewCellSelectionStyle.none
        }
        NSLog("PD 4")
        return cell!
        
    }
    
    func cellForPoint(_ point:(Int,Int),indexPath: IndexPath) -> UITableViewCell? {
        var cell : UITableViewCell? = nil
        switch point {
        case (0,0) :
            let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            cell = cellSpace
        case (0,1) :
            if self.colorItems.count > 0 || self.sizeItems.count > 0{
                let cellColors = tabledetail.dequeueReusableCell(withIdentifier: "colorsCell", for: indexPath)
                if colorSizeViewCell == nil {
                    self.buildColorSizeCell(cellColors.frame.width)
                    //self.clearView(cellColors)
                    cellColors.addSubview(self.colorSizeViewCell!)
                }
                cell = cellColors
            }else{
                let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                cell = cellSpace
            }
        case (0,2) :
            if self.saving.doubleValue > 0{
                let cellListPrice = tabledetail.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as? ProductDetailCurrencyCollectionView
                let formatedValue = "\(CurrencyCustomLabel.formatString(self.listPrice))"
                cellListPrice!.setValues(formatedValue, font: WMFont.fontMyriadProLightOfSize(14), textColor: WMColor.reg_gray, interLine: true)
                cell = cellListPrice
            }else{
                let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                cell = cellSpace
            }
            
        case (0,3) :
            let cellPrice = tabledetail.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as? ProductDetailCurrencyCollectionView
            let formatedValue = CurrencyCustomLabel.formatString(self.price)
            cellPrice!.setValues(formatedValue, font: WMFont.fontMyriadProSemiboldSize(30), textColor: WMColor.orange, interLine: false)
            cell = cellPrice
        case (0,4) :
            if self.saving != ""{
                if self.saving.doubleValue > 0{
                    let cellAhorro = tabledetail.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as? ProductDetailCurrencyCollectionView
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
                    let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                    cell = cellSpace
                }
            } else{
                let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                cell = cellSpace
            }
        case (0,5) :
            let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            cell = cellSpace
        case (0,6) :
            let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            cell = cellSpace
        case (1,0) :
            if  msi.count != 0 {
                let cellPromotion = tabledetail.dequeueReusableCell(withIdentifier: "msiCell", for: indexPath) as? ProductDetailMSITableViewCell

                cellPromotion!.priceProduct = self.price
                cellPromotion!.setValues(msi)
                cell = cellPromotion
            }else {
                return cellForPoint(((indexPath as NSIndexPath).section,2),indexPath: indexPath)
            }
        case (1,1) :
            
            if bundleItems.count != 0 {
                let cellBundleItemsTitle = tabledetail.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as? ProductDetailLabelCollectionView
                let charText = NSLocalizedString("productdetail.bundleitems",comment:"")
                cellBundleItemsTitle!.setValues(charText, font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.light_blue, padding: 16,align:NSTextAlignment.left)
                cell = cellBundleItemsTitle
            } else {
                return cellForPoint(((indexPath as NSIndexPath).section,3),indexPath: indexPath)
            }
            
        case (1,2) :
            if bundleItems.count != 0 {
                let cellPromotion = tabledetail.dequeueReusableCell(withIdentifier: "cellBundleitems", for: indexPath) as? IPAProductDetailBundleTableViewCell
                cellBundle = cellPromotion
                cellPromotion!.delegate = self
                cellPromotion!.itemsUPC = bundleItems as NSArray
                cell = cellPromotion
            } else {
                return cellForPoint(((indexPath as NSIndexPath).section,4),indexPath: indexPath)
            }
        case (1,3) :
            if characteristics.count != 0 {
                let cellCharacteristicsTitle = tabledetail.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as? ProductDetailLabelCollectionView
                //self.clearView(cellCharacteristicsTitle!)
                let charText = NSLocalizedString("productdetail.characteristics",comment:"")
                cellCharacteristicsTitle!.setValues(charText, font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.light_blue, padding: 16,align:NSTextAlignment.left)
                cell = cellCharacteristicsTitle
            }else{
                return nil
            }
        case (1,4) :
            if characteristics.count != 0 {
                let cellCharacteristics = tabledetail.dequeueReusableCell(withIdentifier: "cellCharacteristics", for: indexPath) as? ProductDetailCharacteristicsTableViewCell
                //self.clearView(cellCharacteristics!)
                cellCharacteristics!.setValues(characteristics)
                cell = cellCharacteristics
            }else{
                return nil
            }
        case (1,5) :
            let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            cell = cellSpace
        default :
            cell = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let point = ((indexPath as NSIndexPath).section,(indexPath as NSIndexPath).row)
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
            var rowChose = (indexPath as NSIndexPath).row
            if msi.count == 0 {rowChose += 2}
            return sizeForIndexPath(((indexPath as NSIndexPath).section,rowChose),indexPath:indexPath)
        case (1,1) :
            var rowChose = (indexPath as NSIndexPath).row
            if bundleItems.count == 0 {rowChose += 2}
            if msi.count == 0 {rowChose += 2}
            return sizeForIndexPath(((indexPath as NSIndexPath).section,rowChose),indexPath:indexPath)
        case (1,2):
            var rowChose = (indexPath as NSIndexPath).row
            if bundleItems.count == 0 {rowChose += 2}
            if msi.count == 0 {rowChose += 2}
            return sizeForIndexPath(((indexPath as NSIndexPath).section,rowChose),indexPath:indexPath)
        case (1,3) :
            var rowChose = (indexPath as NSIndexPath).row
            if msi.count == 0 {rowChose += 2}
            if characteristics.count == 0 {rowChose += 2}
            return sizeForIndexPath(((indexPath as NSIndexPath).section,rowChose),indexPath:indexPath)
        case (1,4) :
            var rowChose = (indexPath as NSIndexPath).row
            if msi.count == 0 {rowChose += 2}
            if characteristics.count == 0 {rowChose += 2}
            return sizeForIndexPath(((indexPath as NSIndexPath).section,rowChose),indexPath:indexPath)
        default :
            return 0
        }
    }
    
    func sizeForIndexPath (_ point:(Int,Int),indexPath: IndexPath!)  -> CGFloat {
        var colorSizeHeight:CGFloat = 40.0
        if self.colorItems.count == 0 && self.sizeItems.count == 0 {
            colorSizeHeight = 5.0
        }
        else if self.colorItems.count > 0 && self.sizeItems.count != 0 {
            colorSizeHeight = 80.0
        }
        switch point {
        case (0,0) :
            return 15.0
        case (0,1) :
            return colorSizeHeight
        case (0,3) :
            return 36.0
        case (0,2),(0,4) :
            return 15.0
        case (0,5) :
            return (msi.count == 0 ? 302.0 : 222.0)
        case (0,6) :
            return 222.0
        case (1,0):
            if  msi.count != 0 {
                return (CGFloat(msi.count) * 14) + 180.0
            }
            return sizeForIndexPath ((indexPath.section,3),indexPath: indexPath)
        case (1,1) :
            if  bundleItems.count != 0 {
                return 40.0
            }
            return sizeForIndexPath ((indexPath.section,4),indexPath: indexPath)
        case (1,2):
            if  bundleItems.count != 0 {
                return 130.0
            }
            return sizeForIndexPath ((indexPath.section,5),indexPath: indexPath)
        case (1,3) :
            if characteristics.count != 0 {
                return 36.0
            }
            return sizeForIndexPath ((indexPath.section,6),indexPath: indexPath)
        case (1,4) :
            if characteristics.count != 0 {
                let size = ProductDetailCharacteristicsCollectionViewCell.sizeForCell(self.tabledetail.frame.width - 30,values:characteristics)
                return size + 126
            }
            return sizeForIndexPath ((indexPath.section,7),indexPath: indexPath)
        default :
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //let headerView = UIView()
        switch section {
        case 0:
            return nil
        default:
            
            if isLoading {
                return UIView()
            }
            
            self.productDetailButton = ProductDetailButtonBarCollectionViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64.0),spaceBetweenButtons:13,widthButtons:63)
            productDetailButton!.upc = self.upc as String
            productDetailButton!.desc = self.name as String
            productDetailButton!.price = self.price as String
            productDetailButton!.isPesable  = self.isPesable
            productDetailButton!.onHandInventory = self.onHandInventory as String
            productDetailButton!.isActive = self.strisActive as String
            productDetailButton!.isPreorderable = self.strisPreorderable as String
            productDetailButton!.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButton!.listButton.isSelected = UserCurrentSession.sharedInstance().userHasUPCUserlist(self.upc as String)
            productDetailButton!.idListSelect =  self.idListSelected
            var imageUrl = ""
            if self.imageUrl.count > 0 {
                imageUrl = self.imageUrl[0] as! NSString as String
            }
            productDetailButton!.image = imageUrl
            productDetailButton!.delegate = self
            productDetailButton!.validateIsInList(self.upc as String)
            
         
            return productDetailButton
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.0
        default:
            return 64.0
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if animationController == nil {
            return nil
        }
        
        switch (operation) {
        case UINavigationControllerOperation.push:
            
            animationController.type = AnimationType.present;
            return  animationController;
        case UINavigationControllerOperation.pop:
            animationController.type = AnimationType.dismiss;
            return animationController;
        default: return nil;
        }
        
    }
    
  
    // MARK: Product crosssell delegate

    func goTODetailProduct(_ upc: String, items: [[String : String]], index: Int, imageProduct: UIImage?, point: CGRect, idList: String) {
        
        let paginatedProductDetail = IPAProductDetailPageViewController()
        paginatedProductDetail.ixSelected = index
        paginatedProductDetail.idListSeleted = idList //TODO List
        paginatedProductDetail.itemsToShow = []
        for product  in items {
            let upc : NSString = product["upc"]! as NSString
            let desc : NSString = product["description"]! as NSString
            var type : NSString = "mg"
            if let newtype = product["type"] as String! {
                type = newtype as NSString
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
                    self.productDetailButton!.deltailButton.isSelected = false
            }, closeRow:true)
        }
    }
    
   
    
    func addProductToShoppingCart(_ upc:String,desc:String,price:String,imageURL:String, comments:String ) {
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
        let frameDetail = CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail)
         if self.nutrimentalInfo.count == 0 {
            viewDetail  = ProductDetailTextDetailView(frame: frameDetail)
            viewDetail?.generateBlurImage(self.tabledetail,frame:CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail))
            viewDetail?.imageBlurView.frame =  CGRect(x: 0, y: -heightDetail, width: self.tabledetail.frame.width, height: heightDetail)
            viewDetail?.setTextDetail(self.detail as String)
            viewDetail?.closeDetail = {() in
                self.closeContainer({ () -> Void in
                    },completeClose:{() in
                        self.isShowProductDetail = false
                        self.productDetailButton!.deltailButton.isSelected = false
                    }, closeRow:true)
            }
            opencloseContainer(true,viewShow:viewDetail!, additionalAnimationOpen: { () -> Void in
                self.viewDetail?.imageBlurView.frame = frameDetail
                self.productDetailButton!.deltailButton.isSelected = true
                self.productDetailButton?.reloadShoppinhgButton()
                },additionalAnimationClose:{ () -> Void in
                    self.viewDetail?.imageBlurView.frame =  CGRect(x: 0, y: -self.heightDetail, width: self.tabledetail.frame.width, height: self.heightDetail)
                    self.productDetailButton!.deltailButton.isSelected = true
                })
         } else {
    
            if nutrimentalsView == nil {
                nutrimentalsView = GRNutrimentalInfoView(frame: frameDetail)
                nutrimentalsView?.setup(self.ingredients, nutrimentals: self.nutrimentalInfo)
                nutrimentalsView!.generateBlurImage(self.tabledetail,frame:CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail))
                nutrimentalsView?.imageBlurView.frame =  CGRect(x: 0, y: -heightDetail, width: self.tabledetail.frame.width, height: heightDetail)
            }
            
            self.nutrimentalsView!.closeDetail = {() in
                self.closeContainer({ () -> Void in
                    },completeClose:{() in
                        self.isShowProductDetail = false
                        self.productDetailButton!.deltailButton.isSelected = false
                    }, closeRow:true)
            }
            
            opencloseContainer(true,viewShow:nutrimentalsView!, additionalAnimationOpen: { () -> Void in
                self.nutrimentalsView!.frame = frameDetail
                self.nutrimentalsView!.imageBlurView.frame = frameDetail
                self.productDetailButton?.reloadShoppinhgButton()
                self.productDetailButton!.deltailButton.isSelected = true
                },additionalAnimationClose:{ () -> Void in
                    self.nutrimentalsView?.imageBlurView.frame =  CGRect(x: 0, y: -self.heightDetail, width: self.tabledetail.frame.width, height: self.heightDetail)
                    self.productDetailButton!.deltailButton.isSelected = true
            })
    
        }

    }

    func addToShoppingCart(_ upc:String,desc:String,price:String,imageURL:String, comments:String) {
        
        let frameDetail = CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail)
        
        if self.isPesable {
            selectQuantity = ShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(value: self.price.doubleValue as Double),upcProduct:self.upc as String)
        }
         else {
            selectQuantity = ShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(value: self.price.doubleValue as Double),upcProduct:self.upc as String)
        }
        selectQuantity?.closeAction = { () in
            self.closeContainer({ () -> Void in
                self.productDetailButton?.reloadShoppinhgButton()
            }, completeClose: { () -> Void in
                self.isShowShoppingCart = false
            }, closeRow:true)
        }
        selectQuantity?.generateBlurImage(self.tabledetail,frame:CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail))
        selectQuantity?.addToCartAction = { (quantity:String) in
            let maxProducts = (self.onHandInventory.integerValue <= 5 || self.productDeparment == "d-papeleria") ? self.onHandInventory.integerValue : 5
            if maxProducts >= Int(quantity) {
                self.closeContainer({ () -> Void in
                    self.productDetailButton?.reloadShoppinhgButton()
                    }, completeClose: { () -> Void in
                        
                        self.isShowShoppingCart = false
                        var params  =  self.buildParamsUpdateShoppingCart(quantity)
                        params.updateValue(comments, forKey: "comments")
                        params.updateValue(self.type, forKey: "type")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
                        
                }, closeRow:true )
            } else {
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                
                let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                let msgInventory = "\(firstMessage)\(maxProducts) \(secondMessage)"
                alert!.setMessage(msgInventory)
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                self.selectQuantity?.lblQuantity?.text = maxProducts < 10 ? "0\(maxProducts)" : "\(maxProducts)"
            }
        }
        
        opencloseContainer(true,viewShow:selectQuantity!, additionalAnimationOpen: { () -> Void in
            self.productDetailButton?.setOpenQuantitySelector()
            self.selectQuantity?.imageBlurView.frame = frameDetail
            //self.productDetailButton?.reloadShoppinhgButton()
            },additionalAnimationClose:{ () -> Void in
                self.selectQuantity?.imageBlurView.frame =  CGRect(x: 0, y: -self.heightDetail, width: self.tabledetail.frame.width, height: self.heightDetail)
            },additionalAnimationFinish: { () -> Void in
                self.productDetailButton?.addToShoppingCartButton.setTitleColor(WMColor.light_blue, for: UIControlState())
                self.productDetailButton!.addToShoppingCartButton.isSelected = true
            })
        
        
        self.productDetailButton?.reloadButton()
    }
    
    //MARK: Shopping cart
    /**
     Builds an NSDictionary with data to add product to shopping cart
     
     - parameter quantity: quantity of product
     
     - returns: NSDictionary
     */
    func buildParamsUpdateShoppingCart(_ quantity:String) -> [AnyHashable: Any] {
        var imageUrlSend = ""
        if self.imageUrl.count > 0 {
            imageUrlSend = self.imageUrl[0] as! NSString as String
        }
        let pesable = isPesable ? "1" : "0"
        return ["upc":self.upc,"desc":self.name,"imgUrl":imageUrlSend,"price":self.price,"quantity":quantity,"onHandInventory":self.onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":self.strisPreorderable,"category":self.productDeparment]
    }
    
    func opencloseContainer(_ open:Bool,viewShow:UIView,additionalAnimationOpen:@escaping (() -> Void),additionalAnimationClose:(() -> Void)) {
        if isContainerHide && open {
            openContainer(viewShow, additionalAnimationOpen: additionalAnimationOpen, additionalAnimationFinish: { () -> Void in
            })
        }
    }
    
    func endUpdatingShoppingCart(_ sender:AnyObject) {
        self.productDetailButton?.reloadShoppinhgButton()
    }
    
    func opencloseContainer(_ open:Bool,viewShow:UIView,additionalAnimationOpen:@escaping (() -> Void),additionalAnimationClose:(() -> Void),additionalAnimationFinish:@escaping (() -> Void)) {
        if isContainerHide && open {
            openContainer(viewShow, additionalAnimationOpen: additionalAnimationOpen, additionalAnimationFinish: additionalAnimationFinish)
        }
        
    }
    
    func openContainer(_ viewShow:UIView,additionalAnimationOpen:@escaping (() -> Void),additionalAnimationFinish:@escaping (() -> Void)) {
        self.isContainerHide = false
        self.tabledetail!.setContentOffset(CGPoint.zero, animated:true)
        CATransaction.begin()
        CATransaction.setCompletionBlock({ () -> Void in
            
            let finalFrameOfQuantity = CGRect(x: self.tabledetail.frame.minX, y: self.headerView.frame.maxY, width: self.tabledetail.frame.width, height: self.heightDetail)
            self.containerinfo.frame = CGRect(x: self.tabledetail.frame.minX, y: self.headerView.frame.maxY + self.heightDetail, width: self.tabledetail.frame.width, height: 0)
            self.containerinfo.addSubview(viewShow)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.containerinfo.frame = finalFrameOfQuantity
                additionalAnimationOpen()
                }, completion: { (complete:Bool) -> Void in
                    self.tabledetail.isScrollEnabled = false
                    additionalAnimationFinish()
            })
            
        })
        
        self.tabledetail.beginUpdates()
        self.tabledetail.insertRows(at: [IndexPath(row: 5, section: 0)], with: UITableViewRowAnimation.bottom)
        self.tabledetail.endUpdates()
        self.pagerController!.enabledGesture(false)
        
        CATransaction.commit()
    }
    
    func closeContainer(_ additionalAnimationClose:@escaping (() -> Void),completeClose:@escaping (() -> Void), closeRow: Bool) {
        let finalFrameOfQuantity = CGRect(x: self.tabledetail.frame.minX, y: self.headerView.frame.maxY + heightDetail, width: self.tabledetail.frame.width, height: 0)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.containerinfo.frame = finalFrameOfQuantity
            additionalAnimationClose()
            }, completion: { (comple:Bool) -> Void in
                self.isContainerHide = true
                CATransaction.begin()
                CATransaction.setCompletionBlock({ () -> Void in
                    self.isShowShoppingCart = false
                    self.isShowProductDetail = false
                    self.productDetailButton!.deltailButton.isSelected = false
                    self.tabledetail.isScrollEnabled = true
                    self.productDetailButton!.listButton.isSelected = UserCurrentSession.sharedInstance().userHasUPCUserlist(self.upc as String)
                    self.listSelectorController = nil
                    self.listSelectorBackgroundView = nil
                    completeClose()
                    for viewInCont in self.containerinfo.subviews {
                        viewInCont.removeFromSuperview()
                    }
                    self.selectQuantity = nil
                    self.viewDetail = nil
                    
                })
                self.tabledetail.beginUpdates()
                self.tabledetail.deleteRows(at: [IndexPath(row: 5, section: 0)], with: UITableViewRowAnimation.top)
                self.tabledetail.endUpdates()
                self.pagerController!.enabledGesture(true)
                
                CATransaction.commit()
            }) 
    }

    
    func addOrRemoveToWishList(_ upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,category:String,added:@escaping (Bool) -> Void) {
        
        //let frameDetail = CGRectMake(0,0, self.tabledetail.frame.width, heightDetail)
        
        if self.isShowShoppingCart || self.isShowProductDetail  {
            self.closeContainer(
                { () -> Void in
                    self.productDetailButton?.reloadShoppinhgButton()
                }, completeClose: { () -> Void in
                    self.isShowShoppingCart = false
                    self.selectQuantityGR = nil
                    self.addOrRemoveToWishList(upc, desc: desc, imageurl: imageurl, price: price, addItem: addItem, isActive: isActive, onHandInventory: onHandInventory, isPreorderable: isPreorderable,category:category,added: added)
                }, closeRow:false
            )
            return
        }
        
        if self.listSelectorController == nil {
            addToList()
        }
        else {
            if visibleDetailList {
                self.removeDetailListSelector(
                    action: { () -> Void in
                        self.removeListSelector(action: nil, closeRow:true)
                })
            }else {
                self.removeListSelector(action: nil, closeRow:true)
            }
        }
        
    }
    
    
    func removeDetailListSelector(action:(()->Void)?) {

        if visibleDetailList {
            UIView.animate(withDuration: 0.5,
                                       animations: { () -> Void in
                                        self.detailList!.view.frame =  CGRect(x: -self.bannerImagesProducts.frame.width, y: 0.0, width: self.self.bannerImagesProducts.frame.width, height: self.productCrossSell.frame.maxY )
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        if self.detailList != nil {
                            //self.detailList!.willMoveToParentViewController(nil)
                            self.detailList!.willMove(toParentViewController: nil)
                            self.detailList!.view.removeFromSuperview()
                            self.detailList!.removeFromParentViewController()
                        }
                        self.detailList = nil
                        self.visibleDetailList = false
                        
                        action?()
                        
                    }
                }
            )
            
        }else {
            action?()
        }
        
    }
    
    func addToList() {
        let frameDetail = CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail)
        self.listSelectorContainer = UIView(frame: frameDetail)
        self.listSelectorContainer!.clipsToBounds = true
        self.listSelectorController = ListsSelectorViewController()
        self.listSelectorController!.delegate = self
        self.listSelectorController!.productUpc = self.upc as String
        self.addChildViewController(self.listSelectorController!)
        self.listSelectorController!.view.frame = frameDetail
        self.listSelectorContainer!.addSubview(self.listSelectorController!.view)
        self.listSelectorController!.didMove(toParentViewController: self)
        self.listSelectorController!.view.clipsToBounds = true
        self.listSelectorBackgroundView = self.listSelectorController!.createBlurImage(self.tabledetail, frame: frameDetail)
        self.listSelectorContainer!.insertSubview(self.listSelectorBackgroundView!, at: 0)
        let bg = UIView(frame: frameDetail)
        bg.backgroundColor = WMColor.light_blue
        self.listSelectorContainer!.insertSubview(bg, aboveSubview: self.listSelectorBackgroundView!)
        opencloseContainer(true,viewShow:self.listSelectorContainer!, additionalAnimationOpen: { () -> Void in
            self.productDetailButton?.listButton.isSelected = true
            },additionalAnimationClose:{ () -> Void in
            },additionalAnimationFinish: { () -> Void in
        })
    }
    
    //MARK: Load service 
    
    
    func loadDataFromService() {
        
        print("parametro para signals MG :::\(self.indexRowSelected)")
        
        let signalsDictionary : NSDictionary = NSDictionary(dictionary: ["signals" : GRBaseService.getUseSignalServices()])
        let productService = ProductDetailService(dictionary: signalsDictionary)
        let eventType = self.fromSearch ? "clickdetails" : "pdpview"
        //let params = productService.buildParams(upc as String,eventtype: eventType,stringSearching: self.stringSearch,position: self.indexRowSelected)//position
        let params = productService.buildMustangParams(upc as String, skuId:self.sku as String) //TODO : Validar si es sku
        productService.callService(requestParams:params, successBlock: { (result: NSDictionary) -> Void in
            self.reloadViewWithData(result)
            if let facets = result["facets"] as? [[String:AnyObject]] {
                self.facets = facets
                self.facetsDetails = self.getFacetsDetails()
                let keys = Array(self.facetsDetails!.keys)
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
                if self.facetsDetails?.count > 1 {
                    if let colors = self.facetsDetails![filteredKeys.first!] as? [AnyObject]{
                        self.colorItems = colors
                        self.tabledetail.reloadData()
                    }
                }
                if self.facetsDetails?.count > 2 {
                    if let sizes = self.facetsDetails![filteredKeys[1]] as? [AnyObject]{
                        self.sizeItems = sizes
                        self.tabledetail.reloadData()
                    }
                }
            }
            
            }) { (error:NSError) -> Void in
                let empty = IPOGenericEmptyView(frame:CGRect(x: 0, y: self.headerView.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.headerView.frame.maxY))
                self.name = NSLocalizedString("empty.productdetail.title",comment:"")
                empty.returnAction = { () in
                    print("Return Button")
                    self.backButton()
                }
                self.isEmpty = true
                self.view.addSubview(empty)
        }
    }
    
    func reloadViewWithData(_ result:NSDictionary){
        
        let sku = result["sku"] as! [String:AnyObject]
        let parentProducts = sku["parentProducts"] as! [[String:AnyObject]]
        let parentProduct = parentProducts.first
        
        self.name = parentProduct!["displayName"] as! String as NSString
        
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
        
        self.upc = sku["id"] as! NSString
        if let isGift = result["isGift"] as? Bool{
            self.isGift = isGift
        }
        
        self.detail = self.detail.replacingOccurrences(of: "^", with: "\n") as NSString
        
        self.saving = ""
        if let savingResult = result["saving"] as? NSString {
            self.saving = savingResult
        }
        self.listPrice = result["original_listprice"] as? NSString ?? ""
        self.characteristics = []
        if let cararray = result["characteristics"] as? [AnyObject] {
            self.characteristics = cararray
        }
        
        var allCharacteristics : [AnyObject] = []
        
        let strLabel = "UPC"
        //let strValue = self.upc
        
        if let resultNutrimentalInfo = result["nutritional"] as? [String:String] {
            self.nutrimentalInfo = resultNutrimentalInfo
        }else{
            self.nutrimentalInfo = [:]
        }
        
        self.ingredients = result["Ingredients"] as? String ?? ""
        
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
        
        if let images = parentProduct!["largeImageUrl"] as? [AnyObject] {
            self.imageUrl = images
        }else{
            self.imageUrl = [(parentProduct!["largeImageUrl"] as! String as AnyObject)]
        }
        
        let freeShippingStr  = result["freeShippingItem"] as? NSString ?? ""
        self.freeShipping = "true" == freeShippingStr
        
        var numOnHandInventory : NSString = "0"
        if let numberOf = result["onHandInventory"] as? String{
            numOnHandInventory  = numberOf as NSString
        }
        self.onHandInventory  = numOnHandInventory
        
        self.isActive = sku["onSale"] as! Bool
        self.strisActive = (self.isActive! ? "true" : "false")
        
        if self.isActive == true {
            self.isActive = self.price.doubleValue > 0
        }
        
        if self.isActive == true {
            self.isActive = self.onHandInventory.integerValue > 0
        }
        
        self.strisPreorderable  = sku["isPreOrderable"] as? String as NSString? ?? ""
        self.isPreorderable = "true" == self.strisPreorderable
        
        
        self.bundleItems = [AnyObject]()
        if let bndl = sku["bundleLinks"] as?  [AnyObject] {
            self.bundleItems = bndl
        }
        
        if let category = result["category"] as? String{
            self.productDeparment = category
        }
        
        self.isLoading = false
        
        self.tabledetail.delegate = self
        self.tabledetail.dataSource = self
        self.tabledetail.reloadData()
        self.defaultLoadingImg?.isHidden = true 
        
        self.bannerImagesProducts.items = self.imageUrl
        self.bannerImagesProducts.collection.reloadData()
        
        self.loadCrossSell()
        
        self.titlelbl.text = self.name as String
        
        self.bannerImagesProducts.promotions = [["text":"Nuevo","tagText":"N","tagColor":WMColor.yellow],["text":"Paquete","tagText":"P","tagColor":WMColor.light_blue],["text":"Sobre pedido","tagText":"Sp","tagColor":WMColor.light_blue],["text":"Ahorra más","tagText":"A+","tagColor":WMColor.light_red]]
        
        self.bannerImagesProducts.buildPromotions()
        
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearSearch.rawValue), object: nil)
        
        //FACEBOOKLOG
        FBSDKAppEvents.logEvent(FBSDKAppEventNameViewedContent, valueToSum:self.price.doubleValue, parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "productmg",FBSDKAppEventParameterNameContentID:self.upc])
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHOW_PRODUCT_DETAIL.rawValue, label: "\(self.name) - \(self.upc)")
    }
    
    func removeListSelector(action:(()->Void)?, closeRow: Bool ) {
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
        let tmpheaderView = UIView(frame:CGRect(x: 0, y: 0, width: self.bannerImagesProducts.frame.width, height: heigthHeader))
        tmpheaderView.backgroundColor = WMColor.light_light_gray
        
        //Event
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: "\(self.name) - \(self.upc)")
        
        let tmptitlelbl = UILabel(frame: CGRect(x: 0, y: 0,width: tmpheaderView.frame.width , height: tmpheaderView.frame.height))
        tmptitlelbl.textAlignment = .center
        tmptitlelbl.text = self.name as String
        tmptitlelbl.numberOfLines = 2
        tmptitlelbl.font = WMFont.fontMyriadProRegularOfSize(14)
        tmptitlelbl.textColor = WMColor.light_blue
        tmptitlelbl.adjustsFontSizeToFitWidth = true
        tmptitlelbl.minimumScaleFactor = 9 / 12
        tmpheaderView.addSubview(tmptitlelbl)
        
        
        let imageHeader = UIImage(from: tmpheaderView)
        let headers = [0]
        let items = [IndexPath(row: 1, section: 0),IndexPath(row: 2, section: 0),IndexPath(row: 3, section: 0),IndexPath(row: 4, section: 0)]
        let screen = self.tabledetail.screenshotOfHeaders( atSections: NSSet(array:headers) as Set<NSObject>, footersAtSections: nil, rowsAtIndexPaths: NSSet(array: items) as Set<NSObject>)
        
        let product = self.bannerImagesProducts.collection.cellForItem(at: IndexPath(row: 0, section: 0)) as! ProductDetailBannerMediaCollectionViewCell!
        
        print(imageHead!.size)
        print(imageHeader?.size)
        print(product?.imageView!.image!.size)
        print(screen?.size)
        
        
        let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx/Busqueda.aspx?Text=\(self.upc)")
        if urlWmart != nil {
            let imgResult = UIImage.verticalImage(fromArrayProdDetail: [imageHead!,imageHeader,product?.imageView!.image!,screen])
            //let imgResult = UIImage.verticalImageFromArray([imageHead!,product.imageView!.image!,screen],andWidth:320)
            let controller = UIActivityViewController(activityItems: [self,imgResult,urlWmart!], applicationActivities: nil)
            popup = UIPopoverController(contentViewController: controller)
            popup!.present(from: CGRect(x: 700, y: 100, width: 300, height: 100), in: self.view, permittedArrowDirections: UIPopoverArrowDirection.up, animated: true)
        }
        
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any{
        return "Walmart"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        var toUseName = ""
        if self.name.length > 32 {
            toUseName = self.name.substring(to: 32)
            toUseName = "\(toUseName)..."
        } else {
            toUseName = self.name as String
        }
        //Prueba de concepto
        //let url  = NSURL(string: "itms-apps://itunes.apple.com/mx/app/walmart-mexico/id823947897?mt=8")
        //let urlss  = NSURL(string: "walmartmexicoapp://bussines_mg/type_UPC/value_\(self.upc)")//NSURL(string: "walmartmexicoapp://bussines_mg/type_LIN/value_l-lp-colegio-montesori-primero")
        //let urlapp  = url?.absoluteURL

        if activityType == UIActivityType.mail {
            return "Hola, Me gustó este producto de Walmart. ¡Te lo recomiendo!\n\(self.name) \nSiempre encuentra todo y pagas menos\n"
        }else if activityType == UIActivityType.postToTwitter ||  activityType == UIActivityType.postToVimeo ||  activityType == UIActivityType.postToFacebook  {
            return "Chequen este producto: \(toUseName) #walmartapp #wow "
        }
        return "Checa este producto: \(toUseName)"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        if activityType == UIActivityType.mail {
            if UserCurrentSession.sharedInstance().userSigned == nil {
                return "Encontré un producto que te puede interesar en www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance().userSigned!.profile.name) \(UserCurrentSession.sharedInstance().userSigned!.profile.lastName) encontró un producto que te puede interesar en www.walmart.com.mx"
            }
        }
        return ""
    }

    
    // MARK Color Size Functions
    /**
     Gets details objects from facets
     
     - returns: dictionary wit facet details
     */
    func getFacetsDetails() -> [String:AnyObject]{
        var facetsDetails : [String:AnyObject] = [String:AnyObject]()
        self.selectedDetailItem = [:]
        for product in self.facets! {
            let productUpc =  product["upc"] as! String
            let selected = productUpc == self.upc as String
            let details = product["details"] as! [AnyObject]
            var itemDetail = [String:String]()
            itemDetail["upc"] = product["upc"] as? String
            var count = 0
            for detail in details{
                let label = detail["description"] as! String
                let unit = detail["unit"] as! String
                var values = facetsDetails[label] as? [AnyObject]
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
            var detailsValues = facetsDetails["itemDetails"] as? [AnyObject]
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
    func marckSelectedDetails(_ facetsDetails: [String:AnyObject]) -> [String:AnyObject] {
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
        selectedDetails[selecteFirst] = values as AnyObject?
        
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
    func getFilteredKeys(_ facetsDetails: [String:AnyObject]) -> [String] {
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

    
    func getUpc(_ itemsSelected: [String:String]) -> String
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
    
    func getFacetWithUpc(_ upc:String) -> [String:AnyObject] {
        var facet = self.facets!.first
        for product in self.facets! {
            if (product["upc"] as! String) == upc {
                facet = product
                break
            }
        }
        return facet!
    }
    
    func getDetailsWithKey(_ key: String, value: String, keyToFind: String) -> [String]{
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
    
    func sleectedImage(_ indexPath:IndexPath){
        let controller = ImageDisplayCollectionViewController()
        controller.name = self.name as String
        controller.imagesToDisplay = imageUrl
        controller.currentItem = (indexPath as NSIndexPath).row
        controller.type = self.type as String
        self.navigationController?.present(controller, animated: true, completion: nil)
        
        
    }
    
    func clearView(_ view: UIView){
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
    }
    
    //MARK: ProductDetailColorSizeDelegate
    func selectDetailItem(_ selected: String, itemType: String) {
        var detailOrderCount = 0
        let keys = Array(self.facetsDetails!.keys)
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
        if itemType == filteredKeys.first!{
            self.selectedDetailItem = [:]
            if detailOrderCount > 1 {
                //MARCAR desmarcar las posibles tallas
                let sizes = self.getDetailsWithKey(itemType, value: selected, keyToFind: filteredKeys[1])
                for view in self.sizesView!.viewToInsert!.subviews {
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
            self.reloadViewWithData(facet as NSDictionary)
        }
    }
    
    func buildColorSizeCell(_ width: CGFloat){
        if self.colorSizeViewCell != nil {
            self.clearView(self.colorSizeViewCell!)
        }else{
            self.colorSizeViewCell = UIView()
        }
        if colorItems.count != 0 || sizeItems.count != 0{
            if colorItems.count != 0 && sizeItems.count != 0{
                self.colorsView = ProductDetailColorSizeView()
                self.colorsView?.items = self.colorItems as! [[String:AnyObject]]
                self.colorsView!.alpha = 1.0
                self.colorsView!.frame =  CGRect(x: 0,y: 0, width: width, height: 40.0)
                self.colorsView!.buildItemsView()
                self.colorsView?.delegate = self
                self.sizesView = ProductDetailColorSizeView()
                self.sizesView!.items = self.sizeItems as! [[String:AnyObject]]
                self.sizesView!.alpha = 1.0
                self.sizesView!.frame =  CGRect(x: 0,y: 40,width: width, height: 40.0)
                self.sizesView!.buildItemsView()
                self.sizesView?.delegate = self
                self.colorsView!.deleteTopBorder()
                self.sizesView!.deleteTopBorder()
                self.colorSizeViewCell?.frame = CGRect(x: 0,y: 0, width: width, height: 80.0)
                self.colorSizeViewCell?.addSubview(colorsView!)
                self.colorSizeViewCell?.addSubview(sizesView!)
            }else if colorItems.count != 0 && sizeItems.count == 0{
                self.sizesView?.alpha = 0
                self.colorsView = ProductDetailColorSizeView()
                self.colorsView!.items = self.colorItems as! [[String:AnyObject]]
                self.colorsView!.alpha = 1.0
                self.colorsView!.frame =  CGRect(x: 0,y: 0, width: width, height: 40.0)
                self.colorsView!.buildItemsView()
                self.colorsView?.delegate = self
                self.colorsView!.deleteTopBorder()
                self.colorSizeViewCell?.frame = CGRect(x: 0,y: 0, width: width, height: 40.0)
                self.colorSizeViewCell?.addSubview(colorsView!)
            }else if colorItems.count == 0 && sizeItems.count != 0{
                self.colorsView?.alpha = 0
                self.sizesView = ProductDetailColorSizeView()
                self.sizesView!.items = self.sizeItems as! [[String:AnyObject]]
                self.sizesView!.alpha = 1.0
                self.sizesView!.frame =  CGRect(x: 0,y: 0,width: width, height: 40.0)
                self.sizesView!.buildItemsView()
                self.sizesView?.delegate = self
                self.sizesView!.deleteTopBorder()
                self.colorSizeViewCell?.frame = CGRect(x: 0,y: 0, width: width, height: 40.0)
                self.colorSizeViewCell?.addSubview(sizesView!)
            }
        }else{
            self.colorsView?.alpha = 0
            self.sizesView?.alpha = 0
        }
    }
    
    //MARK: listselectorDElegate
    func listSelectorDidShowList(_ listId: String, andName name:String) {
        if visibleDetailList {
            self.removeDetailListSelector(
                action: { () -> Void in
                    print("-- removeDetailListSelector --")
                    for  children in self.childViewControllers {
                        if children.isKind(of: IPAUserListDetailViewController.self){
                            children.view.removeFromSuperview()
                            children.removeFromParentViewController()
                        }
                    }
                    self.listSelectorDidShowList(listId, andName: name)
            })
            return
        }
        
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? IPAUserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            vc.delegate = self
            vc.widthView = self.bannerImagesProducts.frame.width
            vc.addGestureLeft = true
            vc.searchInList = {(controller) in
                self.navigationController?.pushViewController(controller, animated: false)
            }
            
            
            let frameDetail = CGRect(x: -self.bannerImagesProducts.frame.width, y: 0.0, width: self.bannerImagesProducts.frame.width, height: self.productCrossSell.frame.maxY )
            vc.view.frame = frameDetail
            self.view!.addSubview(vc.view)
            detailList = vc
            self.addChildViewController(self.detailList!)
            self.detailList!.didMove(toParentViewController: self)
            self.detailList!.view.clipsToBounds = true
            self.view!.bringSubview(toFront: self.detailList!.view)
            
            UIView.animate(withDuration: 0.5,
                                       animations: { () -> Void in
                                        self.detailList!.view.frame = CGRect(x: 0.0, y: 0.0, width: self.bannerImagesProducts.frame.width, height: self.productCrossSell.frame.maxY)
                }, completion: { (finished:Bool) -> Void in
                    self.visibleDetailList = true
                }
            )
        }
    }
    
    func listSelectorDidAddProduct(inList listId:String) {
        
        let frameDetail = CGRect(x: self.tabledetail.frame.width, y: 0.0, width: self.tabledetail.frame.width, height: heightDetail)
        self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
        self.selectQuantityGR!.closeAction = { () in
            self.removeListSelector(action: nil, closeRow:true)
        }
        self.selectQuantityGR!.addToCartAction = { (quantity:String) in
            /*if quantity.toInt() == 0 {
             self.listSelectorDidDeleteProduct(inList: listId)
             }
             else {*/
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(NSLocalizedString("list.message.addingProductToList", comment:""))
            
            let service = GRAddItemListService()
            let pesable =  self.isPesable ? "1" : "0"
            let productObject = service.buildProductObject(upc: self.upc as String, quantity:Int(quantity)!,pesable:pesable,active:self.isActive)
            service.callService(service.buildParams(idList: listId, upcs: [productObject]),
                                successBlock: { (result:NSDictionary) -> Void in
                                    self.alertView!.setMessage(NSLocalizedString("list.message.addProductToListDone", comment:""))
                                    self.alertView!.showDoneIcon()
                                    self.alertView!.afterRemove = {
                                        self.removeListSelector(action: nil, closeRow:true)
                                    }
                }, errorBlock: { (error:NSError) -> Void in
                    print("Error at add product to list: \(error.localizedDescription)")
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
                    self.alertView!.afterRemove = {
                        self.removeListSelector(action: nil, closeRow:true)
                    }
                }
            )
            //}
        }
        self.listSelectorContainer!.addSubview(self.selectQuantityGR!)
        UIView.animate(withDuration: 0.5,
                                   animations: { () -> Void in
                                    self.listSelectorController!.view.frame = CGRect(x: -self.tabledetail.frame.width, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
                                    self.selectQuantityGR!.frame = CGRect(x: 0.0, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
            }, completion: { (finished:Bool) -> Void in
                
            }
        )
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
    
    func listSelectorDidDeleteProduct(inList listId:String) {
        NSLog("23")
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone:UIImage(named:"done"),imageError:UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToList", comment:""))
        /*let detailService = GRUserListDetailService()
        detailService.buildParams(listId)
        detailService.callService([:],
                                  successBlock: { (result:NSDictionary) -> Void in
                                    let service = GRDeleteItemListService()
                                    service.callService(service.buildParams(self.upc as String),
                                        successBlock: { (result:NSDictionary) -> Void in
                                            self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToListDone", comment:""))
                                            self.alertView!.showDoneIcon()
                                            self.alertView!.afterRemove = {
                                                self.removeListSelector(action: nil, closeRow:true)
                                            }
                                        }, errorBlock: { (error:NSError) -> Void in
                                            print("Error at remove product from list: \(error.localizedDescription)")
                                            self.alertView!.setMessage(error.localizedDescription)
                                            self.alertView!.showErrorIcon("Ok")
                                            self.alertView!.afterRemove = {
                                                self.removeListSelector(action: nil, closeRow:true)
                                            }
                                        }
                                    )
            },
                                  errorBlock: { (error:NSError) -> Void in
                                    print("Error at retrieve list detail")
            }
        )*/
    }
    var isOpenListDetail  =  false
    

    func listSelectorDidShowListLocally(_ list: List) {
        
        if self.isOpenListDetail {
            self.removeDetailListSelector(action: {
                for  children in self.childViewControllers {
                    if children.isKind(of: IPAUserListDetailViewController.self){
                        children.view.removeFromSuperview()
                        children.removeFromParentViewController()
                    }
                }
                self.listSelectorDidShowListLocallyAnimation(list)
            })
        }else{
            self.listSelectorDidShowListLocallyAnimation(list)
        }
        
        
    }
    
    /**
     show  list detail controller in product detail
     
     - parameter list: id list selected
     */
    func  listSelectorDidShowListLocallyAnimation(_ list: List) {
        
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? IPAUserListDetailViewController {
            vc.listId = list.idList
            vc.listName = name as String
            vc.listEntity = list
            vc.delegate = self
            vc.widthView = self.bannerImagesProducts.frame.width
            vc.addGestureLeft = true
            
            let frameDetail = CGRect(x: -self.bannerImagesProducts.frame.width, y: 0.0, width: self.bannerImagesProducts.frame.width, height: self.productCrossSell.frame.maxY )
            
            vc.view.frame = frameDetail
            self.view!.addSubview(vc.view)
            detailList = vc
            self.addChildViewController(self.detailList!)
            self.detailList!.didMove(toParentViewController: self)
            self.detailList!.view.clipsToBounds = true
            self.view!.bringSubview(toFront: self.detailList!.view)
            
            UIView.animate(withDuration: 0.5,
                                       animations: { () -> Void in
                                        self.isOpenListDetail =  true
                                        self.detailList!.view.frame = CGRect(x: 0.0, y: 0.0, width: self.bannerImagesProducts.frame.width, height: self.productCrossSell.frame.maxY )
                                        
                }, completion: { (finished:Bool) -> Void in
                    self.visibleDetailList = true
                }
            )
        }
        
    }
    
    func listSelectorDidAddProductLocally(inList list:List) {
        let frameDetail = CGRect(x: self.tabledetail.frame.width, y: 0.0,  width: self.tabledetail.frame.width, height: heightDetail)
        self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
        self.selectQuantityGR!.closeAction = { () in
            self.removeListSelector(action: nil, closeRow:true)
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
            self.removeListSelector(action: nil, closeRow:true)
            self.productDetailButton!.listButton.isSelected = true
        }
        self.listSelectorContainer!.addSubview(self.selectQuantityGR!)
        UIView.animate(withDuration: 0.5,
                                   animations: { () -> Void in
                                    self.listSelectorController!.view.frame = CGRect(x: -self.tabledetail.frame.width, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
                                    self.selectQuantityGR!.frame = CGRect(x: 0.0, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
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
        } catch {
            abort()
        }
        self.removeListSelector(action: nil, closeRow:true)
    }
    
    func listSelectorDidClose() {
        self.removeListSelector(action: nil, closeRow:true)
    }
    
    func shouldDelegateListCreation() -> Bool {
        return false
    }
    
    func listSelectorDidCreateList(_ name:String) {
        
    }
    
    //MARK: - IPAUserListDetailDelegate
    func showProductListDetail(fromProducts products:[AnyObject], indexSelected index:Int) {
        let controller = IPAProductDetailPageViewController()
        controller.ixSelected = index
        controller.itemsToShow = products
        self.pagerController!.navigationController?.delegate = self
        self.pagerController!.navigationController?.pushViewController(controller, animated: true)
    }
    
    func reloadTableListUser() {
        if (self.listSelectorController  != nil) {
            self.listSelectorController!.loadLocalList()
        }
    }
    
    func closeUserListDetail() {
        self.removeDetailListSelector(action: nil)
    }

    func reloadTableListUserSelectedRow() {
        
    }
    func showMessageProductNotAviable() {
        //self.showMessageWishList(NSLocalizedString("productdetail.notaviable",comment:""))
    }
    
}

