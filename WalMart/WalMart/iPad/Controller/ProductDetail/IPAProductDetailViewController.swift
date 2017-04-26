//
//  IPAProductDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import FBSDKCoreKit
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


class IPAProductDetailViewController : UIViewController, UITableViewDelegate , UITableViewDataSource,UINavigationControllerDelegate,ProductDetailCrossSellViewDelegate,ProductDetailButtonBarCollectionViewCellDelegate,UIActivityItemSource ,ProductDetailBannerCollectionViewDelegate, ProductDetailColorSizeDelegate{
    
    var listSelectorController: ListsSelectorViewController?
    var listSelectorContainer: UIView?
    var listSelectorBackgroundView: UIImageView?
    
    var animationController : ProductDetailNavigatinAnimationController!
    var viewLoad : WMLoadingView!
    var msi : [Any] = []
    var upc : NSString = ""
    var name : NSString = ""
    var detail : NSString = ""
    var saving : NSString = ""
    var price : NSString = ""
    var listPrice : NSString = ""
    var type : NSString = ResultObjectType.Mg.rawValue as NSString
    var imageUrl : [Any] = []
    var characteristics : [[String:Any]] = []
    var bundleItems : [[String:Any]] = []
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
    var itemsCrossSellUPC : [[String:Any]]! = []
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
    var colorItems : [Any] = []
    var sizeItems : [Any] = []
    var facets: [[String:Any]]? = nil
    var facetsDetails: [String:Any]? = nil
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
    
    var indexRowSelected : String = ""
    var detailOf : String = ""
    let heightDetail : CGFloat = 388
    
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
        BaseController.setOpenScreenTagManager(titleScreen: self.titlelbl.text!, screenName: "IPAProductDetail")
        NotificationCenter.default.addObserver(self, selector: #selector(IPAProductDetailViewController.endUpdatingShoppingCart(_:)), name: .successAddItemsToShopingCart, object: nil)
        
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       productCrossSell.setIdList(self.idListSelected) //
        self.tabledetail.reloadData()
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "backButton", name: CustomBarNotification.finishUserLogOut.rawValue, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabledetail.reloadData()
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
        crossService.callService(self.upc as String, successBlock: { (result:[[String:Any]]?) -> Void in
            if result != nil {
                self.itemsCrossSellUPC = result!
                if self.itemsCrossSellUPC.count > 0{
                    self.productCrossSell.reloadWithData(self.itemsCrossSellUPC, upc: self.upc as String)
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
                cellListPrice!.setValues(formatedValue, font: WMFont.fontMyriadProLightOfSize(14), textColor: WMColor.gray, interLine: true)
                cell = cellListPrice
            }else{
                let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                cell = cellSpace
            }
            
        case (0,3) :
            let cellPrice = tabledetail.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as? ProductDetailCurrencyCollectionView
            let formatedValue = CurrencyCustomLabel.formatString(self.price.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "") as NSString)
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
                        let formated = CurrencyCustomLabel.formatString("\(savingSend)" as NSString)
                        savingSend = "\(savingStr) \(formated)" as NSString
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
                let cellPromotion = tabledetail.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as? ProductDetailLabelCollectionView
                let msiText = NSLocalizedString("productdetail.msitext",comment:"")
                cellPromotion!.setValues(msiText, font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.orange, padding: 16,align:NSTextAlignment.left)
                cell = cellPromotion
            }else {
                return cellForPoint((indexPath.section,2),indexPath: indexPath)
            }
        case (1,1) :
            if  msi.count != 0 {
                let cellPromotion = tabledetail.dequeueReusableCell(withIdentifier: "msiCell", for: indexPath) as? ProductDetailMSITableViewCell

                cellPromotion!.priceProduct = self.price
                cellPromotion!.setValues(msi)
                cell = cellPromotion
            }else {
                return cellForPoint((indexPath.section,3),indexPath: indexPath)
            }
        case (1,2) :
            
            if bundleItems.count != 0 {
                let cellBundleItemsTitle = tabledetail.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as? ProductDetailLabelCollectionView
                let charText = NSLocalizedString("productdetail.bundleitems",comment:"")
                cellBundleItemsTitle!.setValues(charText, font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.light_blue, padding: 16,align:NSTextAlignment.left)
                cell = cellBundleItemsTitle
            } else {
                return cellForPoint((indexPath.section,4),indexPath: indexPath)
            }
            
        case (1,3) :
            if bundleItems.count != 0 {
                let cellPromotion = tabledetail.dequeueReusableCell(withIdentifier: "cellBundleitems", for: indexPath) as? IPAProductDetailBundleTableViewCell
                cellBundle = cellPromotion
                cellPromotion!.delegate = self
                cellPromotion!.itemsUPC = bundleItems as [[String:Any]]
                cell = cellPromotion
            } else {
                return cellForPoint((indexPath.section,5),indexPath: indexPath)
            }
        case (1,4) :
            if characteristics.count != 0 {
                let cellCharacteristicsTitle = tabledetail.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as? ProductDetailLabelCollectionView
                //self.clearView(cellCharacteristicsTitle!)
                let charText = NSLocalizedString("productdetail.characteristics",comment:"")
                cellCharacteristicsTitle!.setValues(charText, font: WMFont.fontMyriadProLightOfSize(14), numberOfLines: 1, textColor: WMColor.light_blue, padding: 16,align:NSTextAlignment.left)
                cell = cellCharacteristicsTitle
            }else{
                return nil
            }
        case (1,5) :
            if characteristics.count != 0 {
                let cellCharacteristics = tabledetail.dequeueReusableCell(withIdentifier: "cellCharacteristics", for: indexPath) as? ProductDetailCharacteristicsTableViewCell
                //self.clearView(cellCharacteristics!)
                cellCharacteristics!.setValues(characteristics)
                cell = cellCharacteristics
            }else{
                return nil
            }
        case (1,6) :
            let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            cell = cellSpace
        default :
            cell = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
            return 302.0
        case (0,6) :
            return 222.0
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
            
            productDetailButton = ProductDetailButtonBarCollectionViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64.0),spaceBetweenButtons:13,widthButtons:63)
            productDetailButton!.upc = self.upc as String
            productDetailButton!.desc = self.name as String
            productDetailButton!.price = self.price as String
            productDetailButton!.onHandInventory = self.onHandInventory as String
            productDetailButton!.isActive = self.strisActive as String
            productDetailButton!.isPreorderable = self.strisPreorderable as String
            productDetailButton!.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButton!.reloadButton()
            productDetailButton!.listButton.isSelected = UserCurrentSession.sharedInstance.userHasUPCWishlist(self.upc as String)
            productDetailButton!.listButton.isEnabled = !self.isGift
            productDetailButton!.productDepartment = self.productDeparment
            var imageUrl = ""
            if self.imageUrl.count > 0 {
                imageUrl = self.imageUrl[0] as! NSString as String
            }
            productDetailButton!.image = imageUrl
            productDetailButton!.delegate = self
            return productDetailButton!
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
        
//        if animationController == nil {
//            return nil
//        }
//        
//        switch (operation) {
//        case UINavigationControllerOperation.push:
//            
//            animationController.type = AnimationType.present;
//            return  animationController;
//        case UINavigationControllerOperation.pop:
//            animationController.type = AnimationType.dismiss;
//            return animationController;
//        default: return nil;
//        }
        
        return nil
        
    }
    
  
    // MARK: Product crosssell delegate

    func goTODetailProduct(_ upc: String, items: [[String : String]], index: Int, imageProduct: UIImage?, point: CGRect, idList: String, isBundle: Bool) {
        
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
            paginatedProductDetail.detailOf =   isBundle ? "Bundle" : "CrossSell"
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
    
    func openProductDetail() {
        isShowProductDetail = true
        let frameDetail = CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail)
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
    }
    
    func deleteFromCart() {
        //Add Alert
        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"remove_cart"), imageDone:UIImage(named:"done"),imageError:UIImage(named:"preCart_mg_icon"))
        alertView?.setMessage(NSLocalizedString("shoppingcart.deleteProductAlert", comment:""))
        
        
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
                    self.closeContainer({ () -> Void in
                        self.productDetailButton?.reloadShoppinhgButton()
                    }, completeClose: { () -> Void in
                        self.tabledetail.reloadData()
                    }, closeRow:true )
                }
            }
        }) { (error) in
            print("delete pressed Errro \(error)")
        }
    }
    
    func addToShoppingCart(_ upc:String,desc:String,price:String,imageURL:String, comments:String) {
        
        let isInCart = self.productDetailButton?.detailProductCart != nil 
        if !isInCart {
            self.tabledetail.reloadData()
            self.isShowShoppingCart = false
            var params  =  self.buildParamsUpdateShoppingCart("1", orderByPiece: true, pieces: 1,equivalenceByPiece:0 )//equivalenceByPiece
            params.updateValue(comments, forKey: "comments")
            params.updateValue(self.type, forKey: "type")
            NotificationCenter.default.post(name:  .addUPCToShopingCart, object: self, userInfo: params)
            return
        }
        
        let frameDetail = CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail)
        
        self.tabledetail.reloadData()
        
        if self.isPesable {
            selectQuantity = ShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(value: self.price.doubleValue as Double),upcProduct:self.upc as String)
        }
         else {
            selectQuantity = ShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(value: self.price.doubleValue as Double),upcProduct:self.upc as String)
        }
        
        selectQuantity?.closeAction = { () in
            self.productDetailButton!.isOpenQuantitySelector = false
            self.closeContainer({ () -> Void in
                self.productDetailButton?.reloadShoppinhgButton()
            }, completeClose: { () -> Void in
                self.isShowShoppingCart = false
                self.tabledetail.reloadData()
            }, closeRow:true)
        }
        //selectQuantity?.generateBlurImage(self.tabledetail,frame:CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail))
        selectQuantity?.addToCartAction = { (quantity:String) in
            
            if quantity == "00" {
                self.deleteFromCart()
                return
            }
            
            let maxProducts = (self.onHandInventory.integerValue <= 5 || self.productDeparment == "d-papeleria") ? self.onHandInventory.integerValue : 5
            if maxProducts >= Int(quantity) {
                self.closeContainer({ () -> Void in
                    self.productDetailButton?.reloadShoppinhgButton()
                }, completeClose: { () -> Void in
                    self.tabledetail.reloadData()
                    self.isShowShoppingCart = false
                    var params  =  self.buildParamsUpdateShoppingCart(quantity, orderByPiece: true, pieces: Int(quantity)!,equivalenceByPiece:0 )//equivalenceByPiece
                    params.updateValue(comments, forKey: "comments")
                    params.updateValue(self.type, forKey: "type")
                    NotificationCenter.default.post(name:  .addUPCToShopingCart, object: self, userInfo: params)
                }, closeRow:true )
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
      
        opencloseContainer(true,viewShow:selectQuantity!, additionalAnimationOpen: { () -> Void in
            self.selectQuantity?.imageBlurView.frame = frameDetail
            self.productDetailButton!.addToShoppingCartButton.isSelected = true
            self.productDetailButton?.reloadShoppinhgButton()
            self.tabledetail.reloadData()
        },additionalAnimationClose:{ () -> Void in
            self.selectQuantity?.imageBlurView.frame =  CGRect(x: 0, y: -self.heightDetail, width: self.tabledetail.frame.width, height: self.heightDetail)
            self.productDetailButton!.addToShoppingCartButton.isSelected = true
        },additionalAnimationFinish: { () -> Void in
            self.productDetailButton?.addToShoppingCartButton.setTitleColor(WMColor.light_blue, for: UIControlState())
            self.productDetailButton?.setOpenQuantitySelector()
        })
        
        self.productDetailButton?.reloadButton()
    }
    
    //MARK: Shopping cart
    
    /**
     Builds an [String:Any] with data to add product to shopping cart
     
     - parameter quantity: quantity of product
     
     - returns: [String:Any]
     */
    
    func buildParamsUpdateShoppingCart(_ quantity:String, orderByPiece: Bool, pieces: Int,equivalenceByPiece:Int) -> [AnyHashable: Any] {
        var imageUrlSend = ""
        if self.imageUrl.count > 0 {
            imageUrlSend = self.imageUrl[0] as! NSString as String
        }
        let pesable = isPesable ? "1" : "0"
        return ["upc":self.upc,"desc":self.name,"imgUrl":imageUrlSend,"price":self.price,"quantity":quantity,"onHandInventory":self.onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":self.strisPreorderable,"category":self.productDeparment,"equivalenceByPiece":equivalenceByPiece]
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
        if self.tabledetail.numberOfRows(inSection: 0) <= 5 {
            self.tabledetail.beginUpdates()
            self.tabledetail.insertRows(at: [IndexPath(row: 5, section: 0)], with: UITableViewRowAnimation.bottom)
            self.tabledetail.endUpdates()
            self.pagerController!.enabledGesture(false)
        }
        
        
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
                    self.productDetailButton!.listButton.isSelected = UserCurrentSession.sharedInstance.userHasUPCWishlist(self.upc as String)
                    self.listSelectorController = nil
                    self.listSelectorBackgroundView = nil
                    
                    completeClose()
                    for viewInCont in self.containerinfo.subviews {
                        viewInCont.removeFromSuperview()
                    }
                    self.selectQuantity = nil
                    self.viewDetail = nil
                    
                })
               
                
                if self.tabledetail.numberOfRows(inSection: 0) >= 5 && closeRow {
                    self.tabledetail.beginUpdates()
                    self.tabledetail.deleteRows(at: [IndexPath(row: 5, section: 0)], with: UITableViewRowAnimation.top)
                    self.tabledetail.endUpdates()
                    
                    self.pagerController!.enabledGesture(true)
                }
                
                self.tabledetail.reloadData()
                
                CATransaction.commit()
            }) 
    }
    
    func showMessageProductNotAviable() {
        
        self.showMessageWishList(NSLocalizedString("productdetail.notaviable",comment:""))
        
    }
    
    func addOrRemoveToWishList(_ upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,category:String,added:@escaping (Bool) -> Void) {
        
        self.isWishListProcess = true
        
        self.addOrRemoveToWishListBlock = {() in
            if addItem {
                let serviceWishList = AddItemWishlistService()
                serviceWishList.callService(upc, quantity: "1", comments: "",desc:desc,imageurl:imageurl,price:price,isActive:isActive,onHandInventory:onHandInventory,isPreorderable:isPreorderable,category:self.productDeparment, successBlock: { (result:[String:Any]) -> Void in
                    added(true)
                    
                    //Event
                    ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ADD_WISHLIST.rawValue, label: "\(self.name) - \(self.upc)")
                    
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
                serviceWishListDelete.callService(upc, successBlock: { (result:[String:Any]) -> Void in
                    added(true)
                    
                    //Event
                    ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_PRODUCT_WISHLIST.rawValue, label: "\(self.name) - \(self.upc)")
                    
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
        
        
        self.tabledetail.isScrollEnabled = false
        //gestureCloseDetail.enabled = true
        if  self.tabledetail.contentOffset.y != 0.0 {
            self.tabledetail.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.tabledetail.frame.width,  height: self.tabledetail.frame.height ), animated: true)
        }
        if addOrRemoveToWishListBlock != nil {
            addOrRemoveToWishListBlock!()
        }
        
        
    }
    
    func showMessageWishList(_ message:String) {
        let addedAlertWL = WishlistAddProductStatus(frame: CGRect(x: self.tabledetail.frame.minX, y: self.tabledetail.frame.minY +  96, width: self.tabledetail.frame.width, height: 0))
        addedAlertWL.generateBlurImage(self.view,frame:CGRect(x: self.tabledetail.frame.minX, y: -96, width: self.tabledetail.frame.width, height: 96))
        addedAlertWL.clipsToBounds = true
        addedAlertWL.imageBlurView.frame = CGRect(x: self.tabledetail.frame.minX, y: -96, width: self.tabledetail.frame.width, height: 96)
        addedAlertWL.textView.text = message
        self.view.addSubview(addedAlertWL)
        self.isWishListProcess = false
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            addedAlertWL.frame = CGRect(x: self.tabledetail.frame.minX,y: self.tabledetail.frame.minY + 48, width: self.tabledetail.frame.width, height: 48)
            }, completion: { (complete:Bool) -> Void in
                UIView.animate(withDuration: 0.5, delay: 1, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
                    addedAlertWL.frame = CGRect(x: addedAlertWL.frame.minX, y: self.tabledetail.frame.minY + 96, width: addedAlertWL.frame.width, height: 0)
                    }) { (complete:Bool) -> Void in
                        self.tabledetail.isScrollEnabled = true
                        addedAlertWL.removeFromSuperview()
                }
        }) 
        
       
    }
    
    
    //MARK: Load service 
    
    func loadDataFromService() {
        
        print("parametro para signals MG :::\(self.indexRowSelected)")
        
        let signalsDictionary : [String:Any] = ["signals" : GRBaseService.getUseSignalServices()]
        let productService = ProductDetailService(dictionary: signalsDictionary)
        let eventType = self.fromSearch ? "clickdetails" : "pdpview"
        let params = productService.buildParams(upc as String,eventtype: eventType,stringSearching: self.stringSearch,position: self.indexRowSelected)//position
        productService.callService(requestParams:params, successBlock: { (result: [String:Any]) -> Void in
            self.reloadViewWithData(result)
            
            if let facets = result["facets"] as? [[String:Any]] {
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
                    if let colors = self.facetsDetails![filteredKeys.first!] as? [Any]{
                        self.colorItems = colors
                        self.tabledetail.reloadData()
                    }
                }
                if self.facetsDetails?.count > 2 {
                    if let sizes = self.facetsDetails![filteredKeys[1]] as? [Any]{
                        self.sizeItems = sizes
                        self.tabledetail.reloadData()
                    }
                }
            }
            //TODO Tag Manager
            let linea = result["linea"] as? String ?? ""
            let isBundle = result["isBundle"] as? Bool ?? false
            // remove "event": "ecommerce",
            BaseController.sendAnalyticsPush(["ecommerce":["detail":["actionField":["list": self.detailOf],"products":[["name": self.name,"id": self.upc,"price": self.price,"brand": "", "category": self.productDeparment,"variant": "pieza","dimension21": isBundle ? self.upc : "","dimension22": "","dimension23": linea,"dimension24": "","dimension25": ""]]]]])
            
            }) { (error:NSError) -> Void in
                let empty = IPOGenericEmptyView(frame:CGRect(x: 0, y: self.headerView.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.headerView.frame.maxY))
                self.name = NSLocalizedString("empty.productdetail.title",comment:"") as NSString
                empty.returnAction = { () in
                    print("Return Button")
                    self.backButton()
                }
                self.isEmpty = true
                self.view.addSubview(empty)
        }
    }
    
    func reloadViewWithData(_ result:[String:Any]){
        self.name = result["description"] as! String as NSString
        self.price = result["price"] as! String as NSString
        self.detail = result["detail"] as! String as NSString
        self.upc = result["upc"] as! NSString
        if let isGift = result["isGift"] as? Bool{
            self.isGift = isGift
        }
        
        self.detail = self.detail.replacingOccurrences(of: "^", with: "\n") as NSString
        
        self.saving = ""
        if let savingResult = result["saving"] as? NSString {
            self.saving = savingResult
        }
        self.listPrice = result["original_listprice"] as! String as NSString
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
        let freeShippingStr  = result["freeShippingItem"] as! String
        self.freeShipping = "true" == freeShippingStr
        
        var numOnHandInventory : NSString = "0"
        if let numberOf = result["onHandInventory"] as? String{
            numOnHandInventory  = numberOf as NSString
        }
        self.onHandInventory  = numOnHandInventory
        
        self.strisActive  = result["isActive"] as! String as NSString
        self.isActive = "true" == self.strisActive
        
        if self.isActive == true {
            self.isActive = self.price.doubleValue > 0
        }
        
        if self.isActive == true {
            self.isActive = self.onHandInventory.integerValue > 0
        }
        
        self.strisPreorderable  = result["isPreorderable"] as! String as NSString
        self.isPreorderable = "true" == self.strisPreorderable
        if self.isPreorderable {
            bannerImagesProducts.imagePresale.isHidden = false
        }
        
        if let lowStock = result["lowStock"] as? Bool{
            //bannerImagesProducts.imageLastPieces.hidden = !lowStock
            bannerImagesProducts.lowStock?.isHidden = !lowStock
        }
         //bannerImagesProducts.lowStock?.hidden =  false
        
        
        self.bundleItems = [[String:Any]]()
        if let bndl = result["bundleItems"] as?  [[String:Any]] {
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
        
        
        NotificationCenter.default.post(name: .clearSearch, object: nil)
        
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
        
        ///BaseController.sendAnalyticsPush(["event": "ecommerce","ecommerce":["detail":["actionField":["list": self.detailOf],"products":[["name": self.name,"id": self.upc,"price": self.price,"brand": "", "category": self.productDeparment,"variant": "pieza","dimension21": isBundle ? self.upc : "","dimension22": "","dimension23": linea,"dimension24": "","dimension25": ""]]]]])
        

        
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
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: "\(self.name) - \(self.upc)")
        
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
        print(imageHeader!.size)
        print(product!.imageView!.image!.size)
        print(screen!.size)
        
        
        let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx/Busqueda.aspx?Text=\(self.upc)")
        if urlWmart != nil {
            let imgResult = UIImage.verticalImage(fromArrayProdDetail: [imageHead!,imageHeader!,product!.imageView!.image!,screen!])
            //let imgResult = UIImage.verticalImageFromArray([imageHead!,product.imageView!.image!,screen],andWidth:320)
            let controller = UIActivityViewController(activityItems: [self,imgResult!,urlWmart!], applicationActivities: nil)
            popup = UIPopoverController(contentViewController: controller)
            popup!.present(from: CGRect(x: 700, y: 100, width: 300, height: 100), in: self.view, permittedArrowDirections: UIPopoverArrowDirection.up, animated: true)
            
            controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
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
            if UserCurrentSession.sharedInstance.userSigned == nil {
                return "Encontré un producto que te puede interesar en www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance.userSigned!.profile.name) \(UserCurrentSession.sharedInstance.userSigned!.profile.lastName) encontró un producto que te puede interesar en www.walmart.com.mx"
            }
        }
        return ""
    }

    
    // MARK Color Size Functions
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
                var values = facetsDetails[label] as? [[String:Any]]
                if values == nil{ values = []}
                let itemToAdd = ["value":detail["unit"] as! String, "enabled": (details.count == 1 || label == "Color") ? 1 : 0, "type": label,"selected":false] as [String : Any]
                if !values!.contains(where: { return $0["value"] as! String == itemToAdd["value"] as! String && $0["enabled"] as! Int == itemToAdd["enabled"] as! Int && $0["type"] as! String == itemToAdd["type"] as! String && $0["selected"] as! Bool == itemToAdd["selected"] as! Bool}) {
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
        // Primer elemento
        if filteredKeys.count > 0 {
        let itemsFirst: [[String:AnyObject]] = facetsDetails[filteredKeys.first!] as! [[String:AnyObject]]
        let selecteFirst =  self.selectedDetailItem![filteredKeys.first!]!
        var values: [Any] = []
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

    func getUpc(_ itemsSelected: [String:String]) -> String
    {
        var upc = ""
        var isSelected = false
        let details: [[String:Any]] = self.facetsDetails!["itemDetails"] as! [[String : Any]]
        for item in details {
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
    
    func getDetailsWithKey(_ key: String, value: String, keyToFind: String) -> [String]{
        let itemDetails: [[String:Any]] = self.facetsDetails!["itemDetails"] as! [[String : Any]]
        var findObj: [String] = []
        for item in itemDetails{
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
        controller.currentItem = indexPath.row
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
            self.reloadViewWithData(facet)
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
                self.colorsView?.items = self.colorItems as! [[String:Any]] as [[String : AnyObject]]!
                self.colorsView!.alpha = 1.0
                self.colorsView!.frame =  CGRect(x: 0,y: 0, width: width, height: 40.0)
                self.colorsView!.buildItemsView()
                self.colorsView?.delegate = self
                self.sizesView = ProductDetailColorSizeView()
                self.sizesView!.items = self.sizeItems as! [[String:Any]] as [[String : AnyObject]]!
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
                self.colorsView!.items = self.colorItems as! [[String:Any]] as [[String : AnyObject]]!
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
                self.sizesView!.items = self.sizeItems as! [[String:Any]] as [[String : AnyObject]]!
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
    
}

