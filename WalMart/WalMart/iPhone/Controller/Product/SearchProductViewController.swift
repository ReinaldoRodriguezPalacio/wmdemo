 //
//  ProductViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 29/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
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



struct SearchResult {
    var products: [[String:Any]]? = nil
    var totalResults = -1
    var resultsInResponse = 0
   
    mutating func addResults(_ otherProducts:[[String:Any]]) {
        if self.products != nil {
           self.products!.append(array: otherProducts)
        }
        else {
            self.products = otherProducts
        }
    }
    
    mutating func resetResult() {
        self.totalResults = -1
        self.resultsInResponse = 0
        self.products = nil
    }
}

enum SearchServiceContextType {
    case withText
    case withCategoryForMG
    case withCategoryForGR
    case withTextForCamFind
    case withRecomendedLine
}
 
 enum SearchServiceFromContext {
    case fromRecomended
    case fromLineSearch
    case fromSearchText
    case fromSearchCamFind
    case fromSearchTextSelect
    case fromSearchTextList
 }

class SearchProductViewController: NavigationViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FilterProductsViewControllerDelegate, SearchProductCollectionViewCellDelegate {

    var contentCollectionOffset: CGPoint?
    var collection: UICollectionView?
    var loading: WMLoadingView?
    var filterButton: UIButton?
    var empty: IPOGenericEmptyView!
    var emptyMGGR: IPOSearchResultEmptyView!
    lazy var mgResults: SearchResult? = SearchResult()
    lazy var grResults: SearchResult? = SearchResult()
    var allProducts: [[String:Any]]? = []
    var upcsToShow : [String]? = []
    var upcsToShowApply : [String]? = []
    var flagtest = true
    var eventCode: String?
    
    var titleHeader: String?
    var originalSort: String?
    var originalSearchContextType: SearchServiceContextType?
    var searchContextType: SearchServiceContextType?
    var searchFromContextType: SearchServiceFromContext?
    var textToSearch:String?
    var idDepartment:String?
    var idFamily :String?
    var idLine:String?
    var idSort:String?
    var maxResult: Int = 20
    var brandText: String? = ""
    
    var bannerView : UIImageView!
    var maxYBanner: CGFloat = 46.0
    var isLandingPage = false
    var landingPageMG : [String:Any]?
    var landingPageGR : [String:Any]?
    var controllerLanding : LandingPageViewController?
    
    var viewBgSelectorBtn : UIView!
    var btnSuper : UIButton!
    var btnTech : UIButton!
    var facet : [[String:Any]]!
    var facetGr : [Any]? = nil
    
    var controllerFilter : FilterProductsViewController!
    
    var firstOpen  = true
    var isLoading  = false
    var hasEmptyView = false
    
    var itemsUPCMG: [[String:Any]]? = []
    var itemsUPCGR: [[String:Any]]? = []
    var itemsUPCMGBk: [[String:Any]]? = []
    var itemsUPCGRBk: [[String:Any]]? = []
    
    var didSelectProduct =  false
    var finsihService =  false
    
    var selectQuantityGR : GRShoppingCartQuantitySelectorView!
    var selectQuantity : ShoppingCartQuantitySelectorView!
    var isTextSearch: Bool = false
    var isOriginalTextSearch: Bool = false
    
    var findUpcsMg: [Any]? = []
    
    var idListFromSearch : String? = ""
    var invokeServiceInError = false
    var viewEmptyImage =  false
    
    var selectQuantityOpen = false
    var isAplyFilter : Bool =  false
    var removeEmpty =  false
    var searchAlertView: SearchAlertView? = nil
    var showAlertView = false
    var mgResponceDic: [String:Any] = [:]
    var grResponceDic: [String:Any] = [:]
    var position = 0
    
    var changebtns  =  false
    var validate = false
    
    override func getScreenGAIName() -> String {
        if self.searchContextType != nil {
            switch self.searchContextType! {
            case .withCategoryForMG :
                return WMGAIUtils.SCREEN_MGSEARCHRESULT.rawValue
            case .withCategoryForGR :
                return WMGAIUtils.SCREEN_GRSEARCHRESULT.rawValue
            default :
                break
            }
        }
        return WMGAIUtils.SCREEN_SEARCHTEXTRESULT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.bannerView = UIImageView()
        self.bannerView.contentMode = UIViewContentMode.scaleAspectFill
        self.view.addSubview(self.bannerView)
        self.view.sendSubview(toBack: self.bannerView!)
       
        collection = getCollectionView()
        collection?.register(SearchProductCollectionViewCell.self, forCellWithReuseIdentifier: "productSearch")
        collection?.register(LoadingProductCollectionViewCell.self, forCellWithReuseIdentifier: "loadCell")
        collection?.register(SectionHeaderSearchHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collection?.allowsMultipleSelection = true
        
        collection!.dataSource = self
        collection!.delegate = self
        collection!.backgroundColor = UIColor.white
        
        self.view.addSubview(collection!)
        self.idSort =  FilterType.none.rawValue
        if self.searchContextType! == .withCategoryForMG {
            self.idSort =  FilterType.rankingASC.rawValue
        }
        
        
        //bannerView.backgroundColor = WMColor.empty_gray
        
        
        self.filterButton = UIButton(type: .custom)
        //self.filterButton!.setImage(iconImage, forState: .Normal)
        //elf.filterButton!.setImage(iconSelected, forState: .Highlighted)
        self.filterButton!.addTarget(self, action: #selector(SearchProductViewController.filter(_:)), for: .touchUpInside)
        self.filterButton!.tintColor = UIColor.white
        self.filterButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        self.filterButton!.setTitle(NSLocalizedString("filter.button.title", comment:"" ) , for: UIControlState())
        self.filterButton!.backgroundColor = WMColor.light_blue
        self.filterButton!.layer.cornerRadius = 11.0

        self.filterButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.filterButton!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0)
        

        self.header?.addSubview(self.filterButton!)
    
        
        viewBgSelectorBtn = UIView(frame: CGRect(x: 16,  y: self.header!.frame.maxY + 16, width: 288, height: 28))
        viewBgSelectorBtn.layer.borderWidth = 1
        viewBgSelectorBtn.layer.cornerRadius = 14
        viewBgSelectorBtn.layer.borderColor = WMColor.light_blue.cgColor
        
        let titleSupper = NSLocalizedString("profile.address.super",comment:"")
        btnSuper = UIButton(frame: CGRect(x: 1, y: 1, width: (viewBgSelectorBtn.frame.width / 2) , height: viewBgSelectorBtn.frame.height - 2))
        btnSuper.setImage(UIImage(color: UIColor.white, size: btnSuper.frame.size), for: UIControlState())
        btnSuper.setImage(UIImage(color: WMColor.light_blue, size: btnSuper.frame.size), for: UIControlState.selected)
        btnSuper.setTitle(titleSupper, for: UIControlState())
        btnSuper.setTitle(titleSupper, for: UIControlState.selected)
        btnSuper.setTitleColor(UIColor.white, for: UIControlState.selected)
        btnSuper.setTitleColor(WMColor.light_blue, for: UIControlState())
        btnSuper.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnSuper.isSelected = true
        btnSuper.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnSuper.frame.size.width + 1, 0, 0.0);
        btnSuper.addTarget(self, action: #selector(SearchProductViewController.changeSuperTech(_:)), for: UIControlEvents.touchUpInside)
        
        let titleTech = NSLocalizedString("profile.address.tech",comment:"")
        btnTech = UIButton(frame: CGRect(x: btnSuper.frame.maxX, y: 1, width: viewBgSelectorBtn.frame.width / 2, height: viewBgSelectorBtn.frame.height - 2))
        btnTech.setImage(UIImage(color: UIColor.white, size: btnSuper.frame.size), for: UIControlState())
        btnTech.setImage(UIImage(color: WMColor.light_blue, size: btnSuper.frame.size), for: UIControlState.selected)
        btnTech.setTitleColor(UIColor.white, for: UIControlState.selected)
        btnTech.setTitleColor(WMColor.light_blue, for: UIControlState())
        btnTech.setTitle(titleTech, for: UIControlState())
        btnTech.setTitle(titleTech, for: UIControlState.selected)
        btnTech.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnTech.isSelected = false
        btnTech.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnSuper.frame.size.width , 0, 0.0);
        btnTech.addTarget(self, action: #selector(SearchProductViewController.changeSuperTech(_:)), for: UIControlEvents.touchUpInside)
        
        viewBgSelectorBtn.clipsToBounds = true
        viewBgSelectorBtn.backgroundColor = UIColor.white
        viewBgSelectorBtn.addSubview(btnSuper)
        viewBgSelectorBtn.addSubview(btnTech)
        if self.idListFromSearch == ""{
            self.view.addSubview(viewBgSelectorBtn)
        }
        
       
        self.titleLabel?.text = titleHeader
        
        if self.findUpcsMg?.count > 0 {
            self.invokeSearchUPCSCMG()
        }else{
            self.getServiceProduct(resetTable: false)
            if  self.searchContextType == .withCategoryForGR {
                self.getFacet(self.idDepartment!,textSearch:self.textToSearch,idFamily:self.idFamily)
            }
        }
        
        self.searchAlertView = SearchAlertView()

        self.view.addSubview(self.searchAlertView!)
        
         //self.header!.bringSubviewToFront(self.bannerView)
        BaseController.setOpenScreenTagManager(titleScreen: self.titleHeader!, screenName: self.getScreenGAIName())
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.selectQuantity?.closeAction()
        self.selectQuantityGR?.closeAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.header?.addSubview(self.filterButton!)
        if IS_IPAD {
        self.view.addSubview(collection!)
        }
        self.isTextSearch = (self.searchContextType == SearchServiceContextType.withText || self.searchContextType == SearchServiceContextType.withTextForCamFind)
        self.isOriginalTextSearch = self.originalSearchContextType == SearchServiceContextType.withText || self.originalSearchContextType == SearchServiceContextType.withTextForCamFind
        
        if self.isTextSearch || isOriginalTextSearch
        {
            if self.idListFromSearch == ""{
                self.titleLabel?.removeFromSuperview()
                self.titleLabel = self.setTitleWithEdit()
                self.titleLabel?.numberOfLines = 2
                self.header?.addSubview(self.titleLabel!)
            }else{
                 self.titleLabel?.text = titleHeader
            }
            if self.originalSearchContextType == nil{
             self.originalSearchContextType = self.searchContextType
            }
        }
        else
        {
            self.titleLabel?.text = titleHeader
            if  self.searchContextType == SearchServiceContextType.withCategoryForMG && titleHeader != "Recomendados" &&  titleHeader != "Centro de promociones" && IS_IPAD {
                self.titleLabel?.text = ""
            }
           
        }
        //aqui la quite
        if loading == nil {
            self.loading = WMLoadingView(frame: CGRect(x: 11, y: 11, width: self.view.bounds.width, height: self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.white
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        
        } else {
            self.viewWillLayoutSubviews()
        }
        
        if self.isLoading {
            self.view.addSubview(self.loading!)
            //if self.allProducts!.count > 0 {
                self.loading!.startAnnimating(self.isVisibleTab)
            //}
        }
        NotificationCenter.default.addObserver(self, selector: #selector(SearchProductViewController.reloadUISearch), name: NSNotification.Name(rawValue: CustomBarNotification.ReloadWishList.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchProductViewController.afterAddToSC), name: NSNotification.Name(rawValue: CustomBarNotification.UpdateBadge.rawValue), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.viewEmptyImage =  true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
		self.collection!.reloadData()
        
        if (self.allProducts == nil || self.allProducts!.count == 0) && self.isTextSearch  {
            if finsihService && viewEmptyImage { //&&
            self.showEmptyMGGRView()
            }
        } else if self.allProducts == nil || self.allProducts!.count == 0 {
            if (finsihService || viewEmptyImage) && !self.isLoading {
                if !removeEmpty {
                    self.showEmptyView()
                }
            }
        }
        if finsihService || didSelectProduct {
            if self.allProducts?.count > 0{
                self.loading?.stopAnnimating()
            
            }
        }
        if self.mgResults!.totalResults == 0 && self.searchContextType == .withCategoryForMG {
            self.showEmptyView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if loading == nil {
            self.loading = WMLoadingView(frame: CGRect(x: 11, y: 11, width: self.view.bounds.width, height: self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.white
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
        
        var startPoint = self.header!.frame.maxY
        if self.isTextSearch || self.isOriginalTextSearch {
            if self.showAlertView {
                searchAlertView!.frame =  CGRect(x: 0,  y: self.header!.frame.maxY, width: self.view.frame.width, height: 46)
                viewBgSelectorBtn.frame =  CGRect(x: 16,  y: self.searchAlertView!.frame.maxY + 20, width: 288, height: 28)
            }else{
                viewBgSelectorBtn.frame =  CGRect(x: 16,  y: self.header!.frame.maxY + 20, width: 288, height: 28)
            }
            searchAlertView!.alpha = self.showAlertView ? 1 : 0
            startPoint = viewBgSelectorBtn.frame.maxY + 20
        }else {
            searchAlertView!.alpha = 0
            viewBgSelectorBtn.alpha = 0
        }
        
        if self.idListFromSearch != "" {
            if  self.showAlertView {
                startPoint = self.header!.frame.maxY + 46
            }else{
                startPoint = self.header!.frame.maxY
            }
        }
        
        //TODO MAke Search only one resultset
        contentCollectionOffset = CGPoint.zero
        self.collection!.frame = CGRect(x: 0, y: startPoint, width: self.view.bounds.width, height: self.view.bounds.height - startPoint)
        self.filterButton!.frame = CGRect(x: self.view.bounds.maxX - 70 , y: (self.header!.frame.size.height - 22)/2 , width: 55, height: 22)
        
        if isLandingPage {
            //self.maxYBanner == 0.0 ? self.header!.frame.maxY + 20 : self.maxYBanner
            bannerView!.frame = CGRect(x: 0, y: self.maxYBanner, width: self.view.frame.width, height: IS_IPAD ?  216 :93)
            viewBgSelectorBtn.frame =  CGRect(x: 16,  y: self.bannerView!.frame.maxY - 28, width: 288, height: 28)
            viewBgSelectorBtn.alpha = 0
            startPoint = viewBgSelectorBtn.frame.maxY// + 20
            self.collection!.frame = CGRect(x: 0, y: startPoint, width: self.view.bounds.width, height: (self.view.bounds.height - startPoint))
        }

        //if self.searchContextType == SearchServiceContextType.WithTextForCamFind {
        self.titleLabel!.frame = CGRect(x: self.filterButton!.frame.width - 5, y: 0, width: self.view.bounds.width - (self.filterButton!.frame.width * 2) - 10, height: self.header!.frame.maxY)
        
        if self.searchContextType != SearchServiceContextType.withTextForCamFind {
            self.titleLabel!.frame = CGRect(x: self.filterButton!.frame.width , y: 0, width: self.view.bounds.width - (self.filterButton!.frame.width * 2) - 12, height: self.header!.frame.maxY)
        }
    
        self.loading!.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
        
        //println("View bounds: \(self.view.bounds)")
        self.collection!.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.loading!.frame = self.collection!.frame
    }
    
    //MARK: - UICollectionViewDataSource
    
//    Camfind Results
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SectionHeaderSearchHeader
            
            view.title = setTitleWithEdit()
            view.title?.textAlignment = .center
            view.addSubview(view.title!)
            view.addSubview(self.filterButton!)

            view.backgroundColor = WMColor.light_gray
            
            if indexPath.section == 0 {
                view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            }
            
            
            return view
        }
        return UICollectionReusableView(frame: CGRect.zero)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize.zero
        }
        
        return CGSize(width: self.view.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Camfind results
//        if upcsToShow?.count > 0 && section == 0 {
//            if self.btnSuper.selected {
//                return self.itemsUPCGR!.count
//            } else {
//                return self.itemsUPCMG!.count
//            }
//        }
        if self.invokeServiceUpc {
            if let count = self.allProducts?.count {
                return count
            }
        }
        
        var size = 0
        if let count = self.allProducts?.count {
            var commonTotal = 0
            if self.btnSuper.isSelected {
                commonTotal =  (self.grResults!.totalResults == -1 ? 0:self.grResults!.totalResults)
        
                commonTotal = commonTotal == 0 ? (self.grResults!.totalResults == -1 ? 0:(self.grResults!.totalResults == 0 && self.grResults!.resultsInResponse != 0 ? self.grResults!.resultsInResponse : self.grResults!.totalResults)) : commonTotal
                if commonTotal > 0 {
                    commonTotal =  self.grResults!.resultsInResponse > commonTotal ? self.grResults!.resultsInResponse :commonTotal
                }
                if count == commonTotal {
                    return count
                }
            } else {
                commonTotal = (self.mgResults!.totalResults == -1 ? 0:self.mgResults!.totalResults)
                if self.itemsUPCMG?.count > 0{
                    commonTotal = commonTotal +  (self.itemsUPCMG?.count)!
                }
                
                if count == commonTotal {
                    return count
                }
            }
            size = (count  >= commonTotal) ? commonTotal : count + 1
            
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Show loading cell and invoke service
        var commonTotal = 0
        if self.btnSuper.isSelected {
            commonTotal =  (self.grResults!.totalResults == -1 ? 0:self.grResults!.totalResults)
        } else {
            commonTotal = (self.mgResults!.totalResults == -1 ? 0:self.mgResults!.totalResults)
        }
        
        if self.allProducts?.count > 0{
        if indexPath.row == self.allProducts?.count && self.allProducts?.count <= commonTotal  {
            let loadCell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadCell", for: indexPath)
            self.invokeServiceInError =  true
            self.getServiceProduct(resetTable: false) //Invoke service
            return loadCell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productCellIdentifier(), for: indexPath) as! SearchProductCollectionViewCell
        if self.allProducts?.count <= indexPath.item {
            return cell
        }
        var item : [String:Any] = [:]
        //Camfind Results
//        if indexPath.section == 0 && self.upcsToShow?.count > 0 {
//            if self.btnSuper.selected {
//                item = self.itemsUPCGR![indexPath.item] as! [String:Any]
//            } else {
//                item = self.itemsUPCMG![indexPath.item] as! [String:Any]
//            }
//        } else {
        
//        }
//        
        item = self.allProducts![indexPath.item]
        let upc = item["upc"] as! String
        let description = item["description"] as? String
        
        var price: NSString?
        var through: NSString! = ""
        if let priceTxt = item["price"] as? NSString {
            price = priceTxt
        }
        else if let pricenum = item["price"] as? NSNumber {
            let txt = pricenum.stringValue
            price = txt as NSString?
        }
        
        if let priceThr = item["saving"] as? NSString {
            through = priceThr
        }
        
        var imageUrl: String? = ""
        if let imageArray = item["imageUrl"] as? [Any] {
            if imageArray.count > 0 {
                imageUrl = imageArray[0] as? String
            }
        } else if let imageUrlTxt = item["imageUrl"] as? String {
            imageUrl = imageUrlTxt
        }
        
        var isActive = true
        if let activeTxt = item["isActive"] as? String {
            isActive = "true" == activeTxt
        }
        
        //??????
        if isActive {
            isActive = price!.doubleValue > 0
        }
        
        var isPreorderable = false
        if let preordeable = item["isPreorderable"] as? String {
            isPreorderable = "true" == preordeable
        }
        
        var onHandDefault = 99
        if let onHandInventory = item["onHandInventory"] as? NSString {
            onHandDefault = onHandInventory.integerValue
        }
        
        let type = item["type"] as! NSString
        
        var isPesable = false
        if let pesable = item["pesable"] as?  NSString {
            isPesable = pesable.intValue == 1
        }
        
        var isLowStock = false
        if let lowStock = item["lowStock"] as?  Bool {
            isLowStock = lowStock
        }
        
        var productDeparment = ""
        if let category = item["category"] as? String{
            productDeparment = category
        }
        
        var equivalenceByPiece = "0"
        if let equivalence = item["equivalenceByPiece"] as? String{
            equivalenceByPiece = equivalence
        }
        
        
        
        cell.setValues(upc,
            productImageURL: imageUrl!,
            productShortDescription: description!,
            productPrice: price! as String,
            productPriceThrough: through! as String,
            isActive: isActive,
            onHandInventory: onHandDefault,
            isPreorderable:isPreorderable,
            isInShoppingCart: UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc),
            type:type as String,
            pesable : isPesable,
            isFormList: idListFromSearch != "" ?  true :  false,
            productInlist:idListFromSearch == "" ? false : self.validateProductInList(forProduct: upc, inListWithId: self.idListFromSearch! ),
            isLowStock:isLowStock,
            category:productDeparment,
            equivalenceByPiece: equivalenceByPiece,
            position:self.isAplyFilter ? "" : "\(indexPath.row)"
        )
        cell.delegate = self
        return cell
    }
    
    func validateProductInList(forProduct upc:String?, inListWithId listId:String) -> Bool {
        let detail: Product? = self.retrieveProductInList(forProduct: upc, inListWithId: listId)
        return detail != nil
    }
    
    func retrieveProductInList(forProduct upc:String?, inListWithId listId:String) -> Product? {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        var detail: Product? = nil
        if upc != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
            fetchRequest.predicate = NSPredicate(format: "upc == %@ && list.idList == %@", upc!, listId)
            var result: [Product] = (try! context.fetch(fetchRequest)) as! [Product]
            if result.count > 0 {
                detail = result[0]
            }
        }
        return detail
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.maxX/2, height: 190)
     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectProduct = true
        let cell = self.collection?.cellForItem(at: indexPath)
        if cell!.isKind(of: SearchProductCollectionViewCell.self){
            let controller = ProductDetailPageViewController()
            var productsToShow : [[String:String]] = []
            if indexPath.section == 0 && self.upcsToShow?.count > 0 {
                if self.btnSuper.isSelected {
                    if indexPath.row < self.allProducts!.count {
                        for strUPC in self.allProducts! {
                            let upc = strUPC["upc"] as! String
                            let description = strUPC["description"] as! String
                            let type = strUPC["type"] as! String
                            var through = ""
                            if let priceThr = strUPC["saving"] as? String {
                                through = priceThr as String
                            }
                            productsToShow.append(["upc":upc, "description":description, "type":type,"saving":through])
                        }
                   
                    }
                } else {
                    if indexPath.row < self.allProducts!.count {
                        //for strUPC in self.itemsUPCMG! {
                        for strUPC in self.allProducts! {
                            let upc = strUPC["upc"] as! String
                            let description = strUPC["description"] as! String
                            let type = strUPC["type"] as! String
                            var through = ""
                            if let priceThr = strUPC["saving"] as? String {
                                through = priceThr as String
                            }
                            productsToShow.append(["upc":upc, "description":description, "type":type,"saving":through])
                        }
                    }
                }
            } else {
                if indexPath.row < self.allProducts!.count {
                
                    for strUPC in self.allProducts! {
                        let upc = strUPC["upc"] as! String
                        let description = strUPC["description"] as! String
                        let type = strUPC["type"] as! String
                        var through = ""
                        if let priceThr = strUPC["saving"] as? String {
                            through = priceThr as String
                        }
                        productsToShow.append(["upc":upc, "description":description, "type":type,"saving":through])
                    }

                }
            }
            controller.isForSeach =  (self.textToSearch != nil && self.textToSearch != "") || (self.idLine != nil && self.idLine != "")
            controller.itemsToShow = productsToShow as [Any]
            controller.ixSelected = indexPath.row
            controller.itemSelectedSolar = self.isAplyFilter ? "" : "\(indexPath.row)"
            controller.idListSeleted =  self.idListFromSearch!
            controller.stringSearching =  self.titleHeader!
            controller.detailOf = self.textToSearch != nil ? "Search Results" : (self.eventCode != nil ? self.eventCode! : self.titleHeader!)
            
            self.navigationController!.pushViewController(controller, animated: true)
        }
       
    }
    
    //MARK: - Services
    
    func getServiceProduct(resetTable:Bool) {
        self.filterButton?.alpha = 0
        self.contentCollectionOffset = self.collection?.contentOffset
        
        let sucessBlock = { () -> Void in self.updateViewAfterInvokeService(resetTable:resetTable) }
        let errorBlock = { () -> Void in self.updateViewAfterInvokeService(resetTable:resetTable) }
        
        if self.searchContextType != nil {
            self.invokeSearchUPCGroceries(actionSuccess: { () -> Void in
                self.invokeSearchUPCMG { () -> Void in
                    switch self.searchContextType! {
                    case .withCategoryForMG :
                        print("Searching products for Category In MG")
                        if self.originalSearchContextType != nil && self.isTextSearch{
                            self.invokeSearchproductsInMG(
                                actionSuccess: { () -> Void in
                                    self.invokeSearchProductsInGroceries(actionSuccess: sucessBlock, actionError: errorBlock)
                                },
                                actionError: { () -> Void in
                                    self.invokeSearchProductsInGroceries(actionSuccess: sucessBlock, actionError: errorBlock)
                                }
                            )
                        }
                        else{
                            self.invokeSearchproductsInMG(actionSuccess: sucessBlock, actionError: errorBlock)
                        }

                    case .withCategoryForGR :
                        print("Searching products for Category In Groceries")
                        
                        if self.originalSearchContextType != nil && self.isTextSearch{
                            self.invokeSearchProductsInGroceries(
                                actionSuccess: { () -> Void in
                                    self.invokeSearchproductsInMG(actionSuccess: sucessBlock, actionError: errorBlock)
                                },
                                actionError: { () -> Void in
                                    self.invokeSearchproductsInMG(actionSuccess: sucessBlock, actionError: errorBlock)
                                }
                            )
                        }
                        else{
                            
                            self.invokeSearchProductsInGroceries(actionSuccess: sucessBlock, actionError: errorBlock)
                        }
                    default :
                        print("Searching products for text")
                        self.invokeSearchProductsInGroceries(
                            actionSuccess: { () -> Void in
                                    self.invokeSearchproductsInMG(actionSuccess: sucessBlock, actionError: errorBlock)
                               
                            },
                            actionError: { () -> Void in
                                if self.invokeServiceInError {
                                    self.invokeSearchproductsInMG(actionSuccess: sucessBlock, actionError: errorBlock)
                                }
                            }
                        )
                    }
                }
            })
        }
        else {
            print("No existe contexto de busqueda. Es necesario indicar el contexto")
        }
    }
    
    func invokeSearchUPCGroceries(actionSuccess:(() -> Void)?) {
        if self.upcsToShow?.count > 0 {
            let serviceUPC = GRProductsByUPCService()
            serviceUPC.callService(requestParams: serviceUPC.buildParamServiceUpcs(self.upcsToShow!), successBlock: { (result:[String:Any]) -> Void in
                if result["items"] != nil {
                    self.itemsUPCGR = result["items"] as? [[String:Any]]
                }else {
                 self.itemsUPCGR = []
                }
               
                actionSuccess?()
                }, errorBlock: { (error:NSError) -> Void in
                    actionSuccess?()
            })
        } else {
            actionSuccess?()
        }
    }
    
    func invokeSearchUPCMG(actionSuccess:(() -> Void)?) {
        if self.upcsToShow?.count > 0 {
            let serviceUPC = SearchItemsByUPCService()
            serviceUPC.callService(self.upcsToShow!, successJSONBlock: { (result:JSON) -> Void in
                self.itemsUPCMG = result.arrayObject as? [[String : Any]]
                actionSuccess?()
                }) { (error:NSError) -> Void in
                    actionSuccess?()
            }
        } else {
            actionSuccess?()
        }
    }
    
    func invokeSearchproductsInMG(actionSuccess:(() -> Void)?, actionError:(() -> Void)?) {
        
        if self.idListFromSearch != ""{
            actionSuccess?()
            return
        }
        
        if self.mgResults!.totalResults != -1 && self.mgResults!.resultsInResponse >= self.mgResults!.totalResults && self.btnTech.isSelected {
            print("MG Search IS COMPLETE!!!")
            self.mgResults!.totalResults = self.allProducts!.count
            self.mgResults!.resultsInResponse = self.mgResults!.totalResults
            if self.mgResults!.totalResults == 0 && self.mgResults!.resultsInResponse == 0 {
                self.finsihService =  true
                self.removeEmpty =  false
                self.showEmptyView()
            }
            actionSuccess?()
            return
        }
        
        print("Invoking MG Search")
        let startOffSet = self.mgResults!.resultsInResponse
        
        //TODO: Signals
        let signalsDictionary : [String:Any] = ["signals" :GRBaseService.getUseSignalServices()]
        let service = ProductbySearchService(dictionary:signalsDictionary)
        let params = service.buildParamsForSearch(text: self.textToSearch, family: self.idFamily, line: self.idLine, sort: self.idSort, departament: self.idDepartment, start: startOffSet, maxResult: self.maxResult)
        service.callService(params!,
            successBlock:{ (arrayProduct:[[String:Any]]?,facet:[[String:Any]],resultDic:[String:Any]) in
                
                let landingMg = resultDic["landingPage"] as! [String:Any]
                self.landingPageMG = landingMg.count > 0 ? landingMg : self.landingPageMG
                if self.landingPageMG != nil && self.landingPageMG!.count > 0 && arrayProduct!.count == 0 {// && self.btnTech.selected {
                    self.showLandingPage()
                    return
                }
                
                if arrayProduct != nil && arrayProduct!.count > 0 {
                    
                    if let item = arrayProduct![0] as? [String:Any] {
                        //println(item)
                        if let results = item["resultsInResponse"] as? NSString {
                            self.mgResults!.resultsInResponse += results.integerValue
                        }
                        if let total = item["totalResults"] as? NSString {
                            self.mgResults!.totalResults = total.integerValue
                        }
                    }
                    
                    self.mgResponceDic = resultDic
                    
                    if self.landingPageMG?.count > 0{ // > 0 TODO cambiar
                        //let imageURL = "www.walmart.com.mx/images/farmacia.jpg"
                        let imageURL = IS_IPAD ? self.landingPageMG!["imgipad"] as! String : self.landingPageMG!["imgiphone"] as! String
                        self.bannerView.setImageWith(URLRequest(url:URL(string: imageURL)!), placeholderImage:UIImage(named: "header_default"), success: { (request:URLRequest, response:HTTPURLResponse?, image:UIImage) -> Void in
                            self.bannerView.image = image//"http://\(imageURL)"
                        }) { (request:URLRequest, response:HTTPURLResponse?, error:Error) -> Void in
                            print("Error al presentar imagen")
                        }
                        
                        self.isLandingPage = true
                        
                        //Se muestra listado de MG
                        self.btnTech.isSelected = false
                        self.btnSuper.isSelected = true
                        self.showAlertView = false
                    }
                    
                    self.mgResults!.addResults(arrayProduct!)
                    if var sortFacet = facet as? [[String:Any]] {
                        sortFacet.sort { (item, seconditem) -> Bool in
                            var firstOrder = "0"
                            if let firstOrderVal = item["order"] as? String {
                                firstOrder = firstOrderVal
                            }
                            var secondOrder = "0"
                            if let secondOrderVal = seconditem["order"] as? String {
                                secondOrder = secondOrderVal
                            }
                            return Int(firstOrder) < Int(secondOrder)
                        }
                        self.facet = sortFacet
                    }//
                    
                    
                    //                    if self.allProducts != nil {
                    //                        self.allProducts = self.allProducts!.arrayByAddingObjectsFromArray(arrayProduct!)
                    //                    }
                    //                    else {
                    //                        self.allProducts = arrayProduct
                    //                    }
                    
                    //Gogle 360 falta departamento
                    if self.textToSearch != nil {
                        BaseController.sendAnalyticsPush(["event": "searchResult", "searchCategory" : "enter", "searchTerm" :self.textToSearch!,"searchNumberResults" :  self.mgResults!.totalResults]) //TODO quitar:_IOS
                    }
                }
                else {
                    self.mgResults!.resultsInResponse = 0
                    if self.mgResults!.products == nil {
                        self.mgResults!.totalResults = 0
                    }
                }
                
                actionSuccess?()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "FINISH_SEARCH"), object: nil)
                
                // Event -- Product Impressions
                if let mgArrayProducts = arrayProduct {
                    if mgArrayProducts.count > 0 {
                        
                        var positionArray: [Int] = []
                        
                        for _ in mgArrayProducts {
                            self.position += 1
                            positionArray.append(self.position)
                        }
                        UserCurrentSession.sharedInstance.nameListToTag = self.textToSearch != nil ? "Search Results" : (self.eventCode != nil ? self.eventCode! : self.titleHeader!)
                        
                        let listName = self.textToSearch != nil ? "Search Results" : (self.eventCode != nil ? self.eventCode : self.titleHeader)
                        let category = self.eventCode != nil ? "banner" : ""
                        let subCategory = self.idFamily != nil ? self.idFamily!.replacingOccurrences(of: "_", with: "") : ""
                        let subSubCategory = self.idLine != nil ? self.idLine!.replacingOccurrences(of: "_", with: "") : ""
                        BaseController.sendAnalyticsTagImpressions(mgArrayProducts, positionArray: positionArray, listName: listName!, mainCategory: category, subCategory: subCategory, subSubCategory: subSubCategory)
                    }
                }
                
            }, errorBlock: {(error: NSError) in
                print("MG Search ERROR!!!")
                self.mgResults!.totalResults = self.allProducts!.count
                self.mgResults!.resultsInResponse = self.mgResults!.totalResults
                actionSuccess?()
                //self.mgResults!.resultsInResponse = 0
                //self.mgResults!.totalResults = 0
                print(error)
                actionError?()
            }
        )
    }
    
    func invokeSearchProductsInGroceries(actionSuccess:(() -> Void)?, actionError:(() -> Void)?) {
        
        if self.grResults!.totalResults != -1 && self.grResults!.resultsInResponse >= self.grResults!.totalResults {
            print("Groceries Search IS COMPLETE!!!")
            actionSuccess?()
            return
        }
        
        print("Invoking Groceries Search")
        var startOffSet = self.grResults!.resultsInResponse
        if startOffSet > 0 {
            startOffSet += 1
        }
        //TODO: Signals
        let signalsDictionary : [String:Any] = ["signals" : GRBaseService.getUseSignalServices()]
        let service = GRProductBySearchService(dictionary: signalsDictionary)
        
       // self.brandText = self.idSort != "" ? "" : self.brandText
        let params = service.buildParamsForSearch(text: self.textToSearch, family: self.idFamily, line: self.idLine, sort: self.idSort == "" ? "" : self.idSort , departament: self.idDepartment, start: startOffSet, maxResult: self.maxResult,brand:self.brandText)
        service.callService(params!, successBlock: { (arrayProduct:[[String:Any]]?, resultDic:[String:Any]) -> Void in
            
            self.landingPageGR = resultDic["landingPage"] as? [String:Any]
            if arrayProduct != nil && arrayProduct!.count > 0 {
                self.grResponceDic = resultDic
                if self.landingPageGR?.count > 0 && self.btnSuper.isSelected{ // > 0 TODO cambiar
                    //let imageURL = "www.walmart.com.mx/images/farmacia.jpg"
                    let imageURL = IS_IPAD ? self.landingPageGR!["imgipad"] as! String : self.landingPageGR!["imgiphone"] as! String
                    self.bannerView.setImageWith(URLRequest(url:URL(string: imageURL)!), placeholderImage:UIImage(named: "header_default"), success: { (request:URLRequest, response:HTTPURLResponse?, image:UIImage) -> Void in
                        self.bannerView.image = image //"http://\(imageURL)"
                    }) { (request:URLRequest, response:HTTPURLResponse?, error:Error) -> Void in
                        print("Error al presentar imagen")
                    }
                    self.isLandingPage = true
                    self.showAlertView = false
                    //Se muestra listado de MG
                    self.btnTech.isSelected = false
                    self.btnSuper.isSelected = true
                }
                
                if let item = arrayProduct![0] as? [String:Any] {
                    //println(item)
                    if let results = item["resultsInResponse"] as? NSString {
                        self.grResults!.resultsInResponse += results.integerValue
                    }
                    if let total = item["totalResults"] as? NSString {
                        self.grResults!.totalResults = total.integerValue
                    }
                }
                
                self.grResults!.addResults(arrayProduct!)
                
                //Gogle 360 falta departamento
                if self.textToSearch != nil {
                    BaseController.sendAnalyticsPush(["event": "searchResult", "searchCategory" : "enter", "searchTerm" :self.textToSearch!,"searchNumberResults" :  self.grResults!.totalResults]) //TODO quitar:_IOS
                }
            }
            else {
                self.grResults!.resultsInResponse = 0
                self.grResults!.totalResults = 0
            }
            actionSuccess?()
            
            // Event -- Product Impressions
            if let grArrayProducts = arrayProduct {
                if grArrayProducts.count > 0 {
                    
                    var positionArray: [Int] = []
                    
                    for _ in grArrayProducts {
                        self.position += 1
                        positionArray.append(self.position)
                    }
                    UserCurrentSession.sharedInstance.nameListToTag = self.textToSearch != nil ? "Search Results" : (self.eventCode != nil ? self.eventCode! : self.titleHeader!)
                    
                    let listName = self.textToSearch != nil ? "Search Results" : (self.eventCode != nil ? self.eventCode : self.titleHeader)
                    let category = self.eventCode != nil ? "banner" : ""
                    let subCategory = self.idFamily != nil ? self.idFamily!.replacingOccurrences(of: "_", with: "") : ""
                    let subSubCategory = self.idLine != nil ? self.idLine!.replacingOccurrences(of: "_", with: "") : ""
                    BaseController.sendAnalyticsTagImpressions(grArrayProducts, positionArray: positionArray, listName: listName!, mainCategory: category, subCategory: subCategory, subSubCategory: subSubCategory)
                }
            }
            
        }, errorBlock: {(error: NSError) in
            print(error)
            //No se encontraron resultados para la búsqueda
            if error.code == 1 {
                self.grResults!.resultsInResponse = 0
                self.grResults!.totalResults = 0
                self.finsihService =   self.btnSuper.isSelected
                self.removeEmpty =  false
                if self.btnSuper.isSelected {
                    self.showEmptyView()//Iphone
                }
                self.collection?.reloadData()//Ipad
                actionError?()
            }else{
                print("GR Search ERROR!!!")
                self.grResults!.totalResults = self.allProducts!.count
                self.grResults!.resultsInResponse = self.mgResults!.totalResults
                self.finsihService =   self.btnSuper.isSelected
                self.removeEmpty =  false
                self.collection?.reloadData()
                actionSuccess?()
                print(error)
                actionError?()
            }
        })
    }
    
    func setAlertViewValues(_ resultDic: [String:Any]){
        
        if resultDic.count == 0 || self.isLandingPage {
            self.showAlertView = false
        }else if !self.isLandingPage && (resultDic["alternativeCombination"] as! String) != "" {
            let alternativeCombination = resultDic["alternativeCombination"] as! String
            let suggestion = (self.textToSearch! as NSString).replacingOccurrences(of: alternativeCombination, with: "")
            self.showAlertView = true
            self.searchAlertView?.setValues(suggestion as String, correction: suggestion as String, underline: alternativeCombination)
        }
        else if !self.isLandingPage && (resultDic["suggestion"] as! String) != "" {
            self.showAlertView = true
                self.searchAlertView?.setValues(self.textToSearch!, correction: resultDic["suggestion"] as! String, underline: nil)
        }else{
           self.showAlertView = false
        }
        
        if (self.isTextSearch || self.isOriginalTextSearch) && (!self.firstOpen || self.showAlertView) {
            
            UIView.animate(withDuration: 0.3, animations: {
                if self.isTextSearch || self.isOriginalTextSearch{
                    if self.showAlertView {
                        self.searchAlertView!.frame =  CGRect(x: 0,  y: self.header!.frame.maxY, width: self.view.frame.width, height: 46)
                        self.viewBgSelectorBtn.frame =  CGRect(x: 16,  y: self.searchAlertView!.frame.maxY + 20, width: 288, height: 28)
                    }else{
                        self.viewBgSelectorBtn.frame =  CGRect(x: 16,  y: self.header!.frame.maxY + 20, width: 288, height: 28)
                    }
                    self.searchAlertView!.alpha = self.showAlertView ? 1 : 0
                }else {
                    self.searchAlertView!.alpha = 0
                    self.viewBgSelectorBtn.alpha = 0
                }
                
                var startPoint = self.viewBgSelectorBtn.frame.maxY + 20
                
                if self.idListFromSearch != "" {
                    if  self.showAlertView {
                        startPoint = self.header!.frame.maxY + 46
                    }else{
                        startPoint = self.header!.frame.maxY
                    }
                }
                
                self.collection!.frame = CGRect(x: 0, y: startPoint, width: self.view.bounds.width, height: self.view.bounds.height - startPoint)
                
            }, completion: nil)
            
        } else if !self.showAlertView && self.searchAlertView != nil {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                if self.isTextSearch || self.isOriginalTextSearch {
                    self.viewBgSelectorBtn.frame =  CGRect(x: 16,  y: self.header!.frame.maxY + 20, width: 288, height: 28)
                    self.searchAlertView!.alpha = self.showAlertView ? 1 : 0
                }else {
                    self.searchAlertView!.alpha = 0
                    self.viewBgSelectorBtn.alpha = 0
                }
                
                var startPoint = self.header!.frame.maxY
                
                if self.isTextSearch || self.isOriginalTextSearch {
                    startPoint = self.viewBgSelectorBtn.frame.maxY + 20
                }
                
                //if (resultDic["suggestion"] as! String) != "" {
                 self.collection!.frame = CGRect(x: 0, y: startPoint, width: self.view.bounds.width, height: self.view.bounds.height - startPoint)
                //}
                
            }, completion: nil)
            
        }
        
    }
    
    func validateSeletctedTap(){
        validate =  true
        
        let  grTotalResults =  self.grResults!.products != nil ? self.grResults!.products!.count : 0
        let  mgTotalResults =  self.mgResults!.products != nil ? self.mgResults!.products!.count : 0
        if !changebtns {
            if grTotalResults > mgTotalResults || grTotalResults == mgTotalResults {
                btnSuper.isSelected  =  true
                btnTech.isSelected =  false
            }else {
                btnSuper.isSelected  =  false
                btnTech.isSelected =  true
            }
        }
        
    }
    
    func updateViewAfterInvokeService(resetTable:Bool) {
        if !validate {
            self.validateSeletctedTap()
        }
        if  self.searchContextType == .withCategoryForGR {
            if self.idDepartment !=  nil {
                self.getFacet(self.idDepartment!,textSearch:self.textToSearch,idFamily:self.idFamily)
            }
        }
        
        if btnSuper.isSelected   {
            if firstOpen && (self.grResults!.products == nil || self.grResults!.products!.count == 0 ) {
                btnTech.isSelected = true
                btnSuper.isSelected = false
                self.allProducts = []
                if self.mgResults?.products != nil {
                    if self.itemsUPCMG?.count > 0 {
                        self.allProducts?.append(array: self.itemsUPCMG!)
                        var filtredProducts : [[String:Any]] = []
                        for product in self.mgResults!.products! {
                            let productDict = product 
                            if let productUPC =  productDict["upc"] as? String {
                                if !self.itemsUPCMG!.contains(where:{ return ($0["upc"] as! String) == productUPC }) {
                                    filtredProducts.append(productDict)
                                }
                            }
                        }
                        self.allProducts?.append(array: filtredProducts)
                    } else {
                        if self.mgResults!.products != nil{
                            self.allProducts?.append(array: self.mgResults!.products!)
                        }
                    }
                }
                firstOpen = false
            } else {
                btnTech.isSelected = false
                btnSuper.isSelected = true
                self.allProducts = []
                if self.grResults?.products != nil {
                    if self.itemsUPCGR?.count > 0 {
                        self.allProducts?.append(array: self.itemsUPCGR!)
                        var filtredProducts : [[String:Any]] = []
                            for product in self.grResults!.products! {
                                let productDict = product 
                                if let productUPC =  productDict["upc"] as? String {
                                    if !self.itemsUPCGR!.contains(where: { return ($0["upc"] as! String) == productUPC }) {
                                        filtredProducts.append(productDict)
                                    }
                                }
                            }
                        
                        self.allProducts?.append(array: filtredProducts)
                    } else {
                        self.allProducts?.append(array: self.grResults!.products!)
                    }
                }
            }
        } else {
            if firstOpen && (self.mgResults!.products == nil || self.mgResults!.products!.count == 0 ) {
                btnTech.isSelected = false
                btnSuper.isSelected = true
                self.allProducts = []
                if self.grResults?.products != nil {
                    if self.itemsUPCGR?.count > 0 {
                        self.allProducts?.append(array: self.itemsUPCGR!)
                        var filtredProducts : [[String:Any]] = []
                        for product in self.grResults!.products! {
                            let productDict = product 
                            if let productUPC =  productDict["upc"] as? String {
                                if !self.itemsUPCGR!.contains(where: { return ($0["upc"] as! String) == productUPC }) {
                                    filtredProducts.append(productDict)
                                }
                            }
                        }
                        self.allProducts?.append(array: filtredProducts)
                    } else {
                        if self.grResults!.products != nil{
                            self.allProducts?.append(array: self.grResults!.products!)
                        }
                    }
                }
                firstOpen = false
            }else{
                btnTech.isSelected = true
                btnSuper.isSelected = false
                self.allProducts = []
                if self.mgResults?.products != nil {
                    if self.itemsUPCMG?.count > 0 {
                        self.allProducts?.append(array: self.itemsUPCMG!)
                        var filtredProducts : [[String:Any]] = []
                        for product in self.mgResults!.products! {
                            let productDict = product
                            if let productUPC =  productDict["upc"] as? String {
                                if !self.itemsUPCMG!.contains(where: { return ($0["upc"] as! String) == productUPC }) {
                                    filtredProducts.append(productDict)
                                }
                            }
                        }
                        self.allProducts?.append(array: filtredProducts)
                    } else {
                        self.allProducts?.append(array: self.mgResults!.products!)
                    }
                }else{//new validate
                    if self.itemsUPCMG?.count > 0 {
                        self.allProducts?.append(array: self.itemsUPCMG!)
                    }
                }
            }
        }
        
        if self.idListFromSearch != ""{
            btnTech.isSelected = false
            btnSuper.isSelected = true
        }
        
        self.showLoadingIfNeeded(true)
        if (self.allProducts == nil || self.allProducts!.count == 0) && (self.isTextSearch || self.isOriginalTextSearch) && self.searchFromContextType != .fromSearchTextList{
            if self.btnTech.isSelected {
                self.setAlertViewValues(self.mgResponceDic)
            }else{
                self.setAlertViewValues(self.grResponceDic)
            }
           self.showEmptyMGGRView()
        } else if (self.allProducts == nil || self.allProducts!.count == 0) &&  self.searchFromContextType == .fromSearchTextList{
           self.showEmptyView()
        }
        else {
            if self.searchContextType != nil && self.isTextSearch && self.allProducts != nil {
                //println("sorting values from text search")
                //Order items
                switch (FilterType(rawValue: self.idSort!)!) {
                case .descriptionAsc :
                    //println("descriptionAsc")
                    self.allProducts?.sort(by: { (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                        let description1:String = dictionary1["description"] as! String
                        let description2:String = dictionary2["description"] as! String
                        
                        if description1 < description2 {
                            return true
                        }
                        else if (description1 > description2) {
                            return false
                        }
                        else {
                            return false
                        }
                        
                    })
                    //self.allProducts = self.allProducts!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "description", ascending: true)])
                case .descriptionDesc :
                    //println("descriptionDesc")
                    self.allProducts?.sort(by: { (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                        let description1:String = dictionary1["description"] as! String
                        let description2:String = dictionary2["description"] as! String
                        
                        if description1 < description2 {
                            return false
                        }
                        else if (description1 > description2) {
                            return true
                        }
                        else {
                            return false
                        }
                        
                    })
                    //self.allProducts = self.allProducts!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "description", ascending: false)])
                case .priceAsc :
                    //println("priceAsc")
                    self.allProducts?.sort(by: { (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                        let priceOne:Double = self.priceValueFrom(dictionary1)
                        let priceTwo:Double = self.priceValueFrom(dictionary2)
                        
                        if priceOne < priceTwo {
                            return true
                        }
                        else if (priceOne > priceTwo) {
                            return false
                        }
                        else {
                            return false
                        }
                        
                    })
                   
                case .none :
                    print("Not sorted")
                default :
                    //println("priceDesc")
                    self.allProducts!.sort(by: { (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                        let priceOne:Double = self.priceValueFrom(dictionary1)
                        let priceTwo:Double = self.priceValueFrom(dictionary2)
                        
                        if priceOne > priceTwo {
                            return false
                        }
                        else if (priceOne < priceTwo) {
                            return true
                        }
                        else {
                            return false
                        }
                        
                    })
                }
            }
            if self.emptyMGGR != nil {
                self.emptyMGGR.removeFromSuperview()
            }
            if self.empty != nil {
                if self.allProducts?.count > 0 {
                    self.removeEmptyView()
                }
            }
            DispatchQueue.main.async {
                self.showLoadingIfNeeded(true)
                self.collection?.reloadData()
                if self.btnTech.isSelected {
                    self.setAlertViewValues(self.mgResponceDic)
                }else{
                   self.setAlertViewValues(self.grResponceDic)
                }
                self.collection?.alpha = 1
                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearSearch.rawValue), object: nil)
                if self.allProducts?.count > 0 {
                    self.filterButton?.alpha = 1
                }
            }
        }
    }
    
    func priceValueFrom(_ dictionary:[String:Any]) -> Double {
        var price:Double = 0.0
        
        if let priceTxt = dictionary["price"] as? NSString {
            price = priceTxt.doubleValue
        }
        else if let pricenum = dictionary["price"] as? NSNumber {
            price = pricenum.doubleValue
        }
        
        return price
    }
    
    func removeEmptyView(){
         self.empty.removeFromSuperview()
         self.empty =  nil
    }
    
    func showEmptyView(){
        //self.titleLabel?.text = NSLocalizedString("empty.productdetail.title",comment:"")
        self.filterButton?.alpha = 0
        //self.empty = IPOGenericEmptyView(frame:self.collection!.frame)

        if  self.empty == nil {
            self.empty = IPOGenericEmptyView(frame:CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - 46))
        }else{
            self.removeEmptyView()
            self.empty = IPOGenericEmptyView(frame:CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - 46))
        }
        
        if self.searchFromContextType == .fromSearchTextList {
            self.empty.descLabel.text = "No existe ese artículo en Súper"
            self.empty.descLabel.numberOfLines = 1
        }else{
            self.empty.descLabel.text = NSLocalizedString(IPOGenericEmptyViewSelected.Selected,comment:"")
            self.empty.descLabel.numberOfLines = 3
        }
    
        self.empty.returnAction = { () in
            self.returnBack()
        }
        
        self.view.addSubview(self.empty)
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearSearch.rawValue), object: nil)
    }
    
    func showEmptyMGGRView(){
        //self.titleLabel?.text = NSLocalizedString("empty.productdetail.title",comment:"")
        
       
        self.filterButton?.alpha = 0
        //self.empty = IPOGenericEmptyView(frame:self.collection!.frame)
        var maxY = self.collection!.frame.minY
        
        if self.idListFromSearch != "" && !IS_IPAD {
          maxY =   maxY + 64
        }
        self.loading?.stopAnnimating()
      
        if self.emptyMGGR == nil {
            self.emptyMGGR = IPOSearchResultEmptyView(frame:CGRect(x: 0, y: maxY, width: self.view.bounds.width, height: self.view.bounds.height - maxY))
            self.emptyMGGR.returnAction = { () in
                self.returnBack()
            }
        }
        if btnSuper.isSelected {
            self.emptyMGGR.descLabel.text = "No existe ese artículo en Súper"
        } else {
            self.emptyMGGR.descLabel.text = "No existe ese artículo en Tecnología, Hogar y más"
        }
         self.view.addSubview(self.emptyMGGR)
       
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearSearch.rawValue), object: nil)
    }
    
    func showLandingPage(){
        if self.controllerLanding == nil {
            self.controllerLanding =  LandingPageViewController()
            self.controllerLanding!.urlTicer = self.landingPageMG!["imgiphone"] as! String
            self.controllerLanding!.departmentId = self.landingPageMG!["departmentid"] as! String
            self.controllerLanding!.titleHeader = self.landingPageMG!["text"] as? String
            self.controllerLanding!.startView = 46.0
            self.controllerLanding!.searchFieldSpace = 0
            self.navigationController!.pushViewController(self.controllerLanding!, animated: true)
        }
        return
    }
    
    //MARK: - Actions
    
    func returnBack() {
        self.navigationController?.popViewController(animated: true)
         NotificationCenter.default.post(name: Notification.Name(rawValue: "CENTER_PROMOS"), object: nil)
    }
    
    func showLoadingIfNeeded(_ hidden: Bool ) {
        if hidden {
            if  self.allProducts?.count > 0 {
                self.loading!.stopAnnimating()
            }
        } else {
            if self.loading ==  nil {
             self.loading = WMLoadingView(frame: CGRect(x: 11, y: 11, width: self.view.bounds.width, height: self.view.bounds.height - 46))
               
            }
            self.view.addSubview(self.loading!)
            self.loading!.backgroundColor = UIColor.white
            self.loading!.startAnnimating(self.isVisibleTab)
            
        }
    }
    
    /**
     Change titlte tiltle
     
     - returns: new title label
     */
    func setTitleWithEdit() -> UILabel {
        
        let titleLabelEdit = UILabel()
        var titleText = titleHeader!
        if titleText.length() > 47
        {
            titleText = titleText.substring(0, length: 44) + "..."
        }
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "search_edit")
        let attachmentString = NSAttributedString(attachment: attachment)
        let myString = NSMutableAttributedString(string: "\(titleText) ")
        myString.append(attachmentString)
        titleLabelEdit.numberOfLines = 2
        titleLabelEdit.attributedText = myString
        titleLabelEdit.isUserInteractionEnabled = true
        titleLabelEdit.textColor =  WMColor.light_blue
        titleLabelEdit.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabelEdit.numberOfLines = 2
        titleLabelEdit.textAlignment = .center
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SearchProductViewController.editSearch))
        titleLabelEdit.addGestureRecognizer(tapGesture)
        
        return titleLabelEdit
        
    }
    
    func editSearch(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.EditSearch.rawValue), object: titleHeader!)
        
    }
    
    func reloadUISearch() {
        self.collection!.reloadData()
    }
    
    //MARK: - Filters
    
    func filter(_ sender:UIButton){
        if controllerFilter == nil {
            controllerFilter = FilterProductsViewController()
            controllerFilter.facet = self.facet as [[String:Any]]?
            controllerFilter.textToSearch = self.textToSearch
            controllerFilter.selectedOrder = self.idSort!//self.idSort! == "" ? "rating" :self.idSort!
            controllerFilter.isGroceriesSearch = self.btnSuper.isSelected
            controllerFilter.delegate = self
            controllerFilter.originalSearchContext = self.originalSearchContextType == nil ? self.searchContextType : self.originalSearchContextType
            //controllerFilter.searchContext = self.searchContextType
            controllerFilter?.facetGr = self.facetGr
            controllerFilter?.backFilter = {() in
                self.loading?.stopAnnimating()
                self.loading?.removeFromSuperview()
            }

            
        }
        controllerFilter.isGroceriesSearch = self.btnSuper.isSelected
        controllerFilter.searchContext = self.searchContextType
        self.navigationController?.pushViewController(controllerFilter, animated: true)
    }
    
    func getFacet(_ idDepartament:String,textSearch:String?,idFamily:String?){
        let serviceFacet = GRFacets()
        
        serviceFacet.callService(idDepartament,stringSearch:textSearch == nil ? "" : textSearch!,idFamily: idFamily == nil ? "" : idFamily!,idLine:self.idLine == nil ? "":self.idLine!,
            successBlock: { (result:[String:Any]) -> Void in
                let arrayCall = result["brands"] as! [Any]
                
                self.facetGr = arrayCall
                print(result)
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at invoke payment type service")
                
            }
        )
        
        
    }
    
    func apply(_ order:String, filters:[String:Any]?, isForGroceries flag:Bool) {
        
        self.isAplyFilter =  true
        
        if IS_IPHONE {
            self.isLoading = true
        } else {
            self.showLoadingIfNeeded(false)
        }
        
        self.filterButton!.alpha = 1
        if self.originalSort == nil {
            self.originalSort = self.idSort
        }
        if self.originalSearchContextType == nil {
            self.originalSearchContextType = self.searchContextType
        }
        self.idSort = order
        
        if filters != nil && self.originalSearchContextType != nil && self.isTextSearch {
            self.idDepartment = filters![JSON_KEY_IDDEPARTMENT] as? String
            self.idFamily = filters![JSON_KEY_IDFAMILY] as? String
            self.idLine = filters![JSON_KEY_IDLINE] as? String
            self.searchContextType = flag ? .withCategoryForGR : .withCategoryForMG
            
            if self.upcsToShowApply?.count == 0 {
                self.upcsToShowApply = self.upcsToShow
                self.itemsUPCMGBk = self.itemsUPCMG
                self.itemsUPCGRBk = self.itemsUPCGR
                self.itemsUPCMG = []
                self.itemsUPCGR = []
                self.upcsToShow = []
            }
            
        } else {
            self.removeEmpty =  true
            self.itemsUPCMG = self.itemsUPCMGBk
            self.itemsUPCGR = self.itemsUPCGRBk
            self.upcsToShow = self.upcsToShowApply
            self.upcsToShowApply = []
        }

        if flag {
            BaseController.sendAnalyticsPush(["event":"searchSortResult","searchCategory" : "enter-IOS","searchTerm" : self.textToSearch ?? "", "searchNumberResults" : self.grResults!.totalResults, "sortUsado":order])
        }else{
            BaseController.sendAnalyticsPush(["event":"searchSortResult","searchCategory" : "enter-IOS","searchTerm" : self.textToSearch ?? "", "searchNumberResults" : self.mgResults!.totalResults, "sortUsado":order])
        }
        
        self.allProducts = []
        self.mgResults!.resetResult()
        self.grResults!.resetResult()
        self.getServiceProduct(resetTable: true)
    }
    
    func sendBrandFilter(_ brandFilter: String) {
        self.brandText = brandFilter
        
    }

    func apply(_ order:String, upcs: [String]) {

        
        if IS_IPHONE {
            self.isLoading = true
        } else {
            showLoadingIfNeeded(false)
        }
        
        self.collection?.alpha = 100
        if upcs.count == 0 {
            self.allProducts = []
            self.mgResults?.totalResults = 0
            self.collection?.reloadData()
            self.collection?.alpha = 0
//            if self.empty == nil {
//                self.viewBgSelectorBtn.alpha = 0
//                self.empty = IPOGenericEmptyView(frame:CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
//                self.empty.returnAction = { () in
//                    self.viewBgSelectorBtn.alpha = 1
//                    self.returnBack()
//                }
//            }
//            //self.empty.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
//
//            self.view.addSubview(self.empty)
//            self.empty.descLabel.text = NSLocalizedString("empty.productdetail.recent", comment: "")
            self.finsihService =  true
            return
        } else {
            if self.empty != nil {
                self.removeEmptyView()
            }
        }
        
        
        let svcSearch = SearchItemsByUPCService()
        svcSearch.callService(upcs, successJSONBlock: { (result:JSON) -> Void in
            if self.originalSearchContextType != .withTextForCamFind {
                self.allProducts? = []
            }
            self.allProducts?.append(array: result.arrayObject! as! [[String:Any]])
            self.mgResults?.totalResults = self.allProducts!.count
            self.idSort = order
            switch (FilterType(rawValue: self.idSort!)!) {
            case .descriptionAsc :
                //println("descriptionAsc")
                self.allProducts!.sort(by: { (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                    let description1:String = dictionary1["description"] as! String
                    let description2:String = dictionary2["description"] as! String
                    
                    if description1 < description2 {
                        return true
                    }
                    else if (description1 > description2) {
                        return false
                    }
                    else {
                        return false
                    }
                    
                })
            case .descriptionDesc :
                //println("descriptionDesc")
                self.allProducts!.sort(by:{ (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                    let description1:String = dictionary1["description"] as! String
                    let description2:String = dictionary2["description"] as! String
                    
                    if description1 < description2 {
                        return false
                    }
                    else if (description1 > description2) {
                        return true
                    }
                    else {
                        return false
                    }
                    
                })
            case .priceAsc :
                //println("priceAsc")
                self.allProducts!.sort(by: { (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                    let priceOne:Double = self.priceValueFrom(dictionary1)
                    let priceTwo:Double = self.priceValueFrom(dictionary2)
                    
                    if priceOne < priceTwo {
                        return true
                    }
                    else if (priceOne > priceTwo) {
                        return false
                    }
                    else {
                        return false
                    }
                    
                })
            case .none : print("Not sorted")
            case .priceDesc :
                //println("priceDesc")
                self.allProducts!.sort(by: { (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                    let priceOne:Double = self.priceValueFrom(dictionary1)
                    let priceTwo:Double = self.priceValueFrom(dictionary2)
                    
                    if priceOne > priceTwo {
                        return false
                    }
                    else if (priceOne < priceTwo) {
                        return true
                    }
                    else {
                        return false
                    }
                    
                })
            default :
                print("default")
            }
            
            
            self.finsihService =  true
            self.collection?.reloadData()
            self.showLoadingIfNeeded(true)
            }) { (error:NSError) -> Void in
                print(error)
        }
        
    }
    
    func removeSelectedFilters(){
        
        //Quitamos los filtros despues de la busqueda.
        //self.idSort = self.originalSort
        
        self.searchContextType = self.originalSearchContextType
        
        /* Removed, causing results > 20 to reset filter
         
        if self.originalSearchContextType != nil && self.isTextSearch {
            self.idDepartment = nil
            self.idFamily = nil
            self.idLine = nil
        }
         
        */
        
        self.allProducts = []
        self.mgResults!.resetResult()
        self.grResults!.resetResult()
        self.controllerFilter = nil
        
        
        
    }
    
    func removeFilters() {
        
        self.idSort = self.originalSort
        self.searchContextType = self.originalSearchContextType
        if self.originalSearchContextType != nil && self.isTextSearch {
            self.idDepartment = nil
            self.idFamily = nil
            self.idLine = nil
        }
        
        self.allProducts = []
        self.mgResults!.resetResult()
        self.grResults!.resetResult()
        self.showLoadingIfNeeded(false)
        self.getServiceProduct(resetTable: true)
        
        self.controllerFilter = nil
        
        
        
    }
    
    
    //MARK: -
    
    func productCellIdentifier() -> String {
        return "productSearch"
    }
    
    func getCollectionView() -> UICollectionView {
        let customlayout = CSStickyHeaderFlowLayout()
        customlayout.disableStickyHeaders = false
        customlayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 56.0)
        //        let customlayout = UICollectionViewFlowLayout()
        //        customlayout.headerReferenceSize = CGSizeMake(0, 44);
        return UICollectionView(frame: self.view.bounds, collectionViewLayout: customlayout)
        
    }
    
    
    //MARK: Filter Super Tecnologia
    
    func changeSuperTech(_ sender:UIButton) {
        changebtns =  true
        //self.collection?.contentOffset = CGPointZero
        if sender == btnSuper &&  !sender.isSelected {
            sender.isSelected = true
            btnTech.isSelected = false
            self.allProducts = nil
            updateViewAfterInvokeService(resetTable:true)
            self.searchContextType = SearchServiceContextType.withCategoryForGR
        } else if sender == btnTech &&  !sender.isSelected {
            sender.isSelected = true
            btnSuper.isSelected = false
            self.allProducts = nil
            updateViewAfterInvokeService(resetTable:true)
            self.searchContextType = SearchServiceContextType.withCategoryForMG
        }
        
    }
    
    //MARK: SearchProductCollectionViewCellDelegate
    
    func buildGRSelectQuantityView(_ cell: SearchProductCollectionViewCell, viewFrame: CGRect){
        var prodQuantity = "1"
        if cell.pesable! {
            prodQuantity = "50"
            let equivalence =  cell.equivalenceByPiece == "" ? 0.0 : cell.equivalenceByPiece.toDouble()
            
            selectQuantityGR = GRShoppingCartWeightSelectorView(frame:viewFrame,priceProduct:NSNumber(value: (cell.price as NSString).doubleValue as Double),quantity:Int(prodQuantity),equivalenceByPiece:NSNumber(value: Int(equivalence!)),upcProduct:cell.upc)
            
        }else{
            prodQuantity = "1"
            selectQuantityGR = GRShoppingCartQuantitySelectorView(frame:viewFrame,priceProduct:NSNumber(value: (cell.price as NSString).doubleValue as Double),quantity:Int(prodQuantity),upcProduct:cell.upc)
        }
        
        //EVENT
        //let action = cell.pesable! ? WMGAIUtils.ACTION_CHANGE_NUMER_OF_KG.rawValue : WMGAIUtils.ACTION_CHANGE_NUMER_OF_PIECES.rawValue
        //BaseController.sendAnalytics(WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue, action:action, label: "\(cell.desc) - \(cell.upc)")
        
        selectQuantityGR?.closeAction = { () in
            self.selectQuantityGR.removeFromSuperview()
            self.selectQuantityOpen = false
        }
        
        selectQuantityGR?.addToCartAction = { (quantity:String) in
            //let quantity : Int = quantity.toInt()!
            if cell.onHandInventory.integerValue >= Int(quantity) {
                self.selectQuantityGR?.closeAction()
                if self.idListFromSearch == ""{
                    let params = self.buildParamsUpdateShoppingCart(cell,quantity: quantity,position:cell.positionSelected)
                    //CAMBIA IMAGEN CARRO SELECCIONADO
                    //cell.addProductToShopingCart!.setImage(UIImage(named: "products_done"), forState: UIControlState.Normal)
                    
                    NotificationCenter.default.post(name:NSNotification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
                }else{
                    self.addItemToList(cell, quantity:quantity)
                }
                
            } else {
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                
                let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                
                var secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                
                if cell.pesable! {
                    secondMessage = NSLocalizedString("productdetail.notaviableinventorywe",comment:"")
                }
                
                let msgInventory = "\(firstMessage)\(cell.onHandInventory) \(secondMessage)"
                alert!.setMessage(msgInventory)
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            }
        }
        selectQuantityGR?.userSelectValue(prodQuantity)
        selectQuantityGR?.first = true
        //selectQuantityGR!.generateBlurImage(self.view,frame:selectQuantityGR.bounds)
    }
    
    func selectGRQuantityForItem(_ cell: SearchProductCollectionViewCell) {
        if !selectQuantityOpen {
            let frameDetail = CGRect(x: 0,y: 0, width: self.view.frame.width,height: self.view.frame.height)
            self.buildGRSelectQuantityView(cell, viewFrame: frameDetail)
            self.view.addSubview(selectQuantityGR)
            selectQuantityOpen = true
        }
    }
    
    func buildMGSelectQuantityView(_ cell: SearchProductCollectionViewCell, viewFrame: CGRect){
        selectQuantity = ShoppingCartQuantitySelectorView(frame:viewFrame,priceProduct:NSNumber(value: (cell.price as NSString).doubleValue as Double),upcProduct:cell.upc)
        selectQuantity!.closeAction = { () in
            self.selectQuantity.removeFromSuperview()
            self.selectQuantityOpen = false
        }
        //selectQuantity!.generateBlurImage(self.view,frame:selectQuantity.bounds)
        
        //Event
        ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_KEYBOARD.rawValue, label: "\(cell.desc) - \(cell.upc)")
        
        selectQuantity!.addToCartAction =
            { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                let maxProducts = (cell.onHandInventory.integerValue <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory.integerValue : 5
                if maxProducts >= Int(quantity) {
                    let params = self.buildParamsUpdateShoppingCart(cell,quantity: quantity,position: cell.positionSelected)//
                    
                    ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label:"\(cell.upc) - \(cell.desc)")
                    
                    UIView.animate(withDuration: 0.2,
                        animations: { () -> Void in
                            self.selectQuantity!.closeAction()
                        },
                        completion: { (animated:Bool) -> Void in
                            self.selectQuantity = nil
                            //CAMBIA IMAGEN CARRO SELECCIONADO
                            NotificationCenter.default.post(name:NSNotification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
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
    }
    
    func selectMGQuantityForItem(_ cell: SearchProductCollectionViewCell) {
        if !selectQuantityOpen {
            let frameDetail = CGRect(x: 0,y: 0, width: self.view.frame.width,height: self.view.frame.height)
            self.buildMGSelectQuantityView(cell, viewFrame: frameDetail)
            self.view.addSubview(selectQuantity)
            selectQuantityOpen = true
        }
    }
    
    func buildParamsUpdateShoppingCart(_ cell:SearchProductCollectionViewCell,quantity:String,position:String) -> [String:Any] {
        let pesable = cell.pesable! ? "1" : "0"
        let searchText = self.textToSearch ?? ""
        let channel = IS_IPAD ? "ipad" : "iphone"
        if cell.type == ResultObjectType.Groceries.rawValue {
            if searchText != ""{
                return ["upc":cell.upc,"desc":cell.desc,"imgUrl":cell.imageURL,"price":cell.price,"quantity":quantity,"comments":"","onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable,"parameter":["q":searchText,"eventtype": "addtocart","collection":"dah","channel": channel,"position":position]]
            }
            return ["upc":cell.upc,"desc":cell.desc,"imgUrl":cell.imageURL,"price":cell.price,"quantity":quantity,"comments":"","onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable]
        }
        else {
            
            if searchText != ""{
            return ["upc":cell.upc,"desc":cell.desc,"imgUrl":cell.imageURL,"price":cell.price,"quantity":quantity,"onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":cell.isPreorderable,"category": cell.productDeparment,"parameter":["q":searchText,"eventtype": "addtocart","collection":"mg","channel": channel,"position":position]]
            }
            return ["upc":cell.upc,"desc":cell.desc,"imgUrl":cell.imageURL,"price":cell.price,"quantity":quantity,"onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":cell.isPreorderable,"category": cell.productDeparment]
        }
    }
    
    //reload after update
    
    func afterAddToSC() {
        self.collection?.reloadData()
    }
    
    var invokeServiceUpc =  false
    
    func invokeSearchUPCSCMG() {
        if self.findUpcsMg?.count > 0 {
             self.filterButton?.alpha = 0
            let serviceUPC = SearchItemsByUPCService()
            serviceUPC.callService(self.findUpcsMg as! [String], successJSONBlock: { (result:JSON) -> Void in
                //self.itemsUPCMG = result.arrayObject
                let upcs : [[String:Any]] = result.arrayObject! as! [[String : Any]]
                if upcs.count > 0 {
                self.allProducts?.append(array: upcs)
                self.finsihService =  true
                self.invokeServiceUpc =  true
                self.collection?.reloadData()
                self.collection?.layoutIfNeeded()
                }else{
                    self.showEmptyView()
                }
                
                print("busqueda completa")
                }) { (error:NSError) -> Void in
                    self.finsihService =  true
                    self.showEmptyView()
                    print(error.localizedDescription)
            }
        } else {
         self.showEmptyView()
         print("No hay upcs a buscar ")
        }
    }
    
    //MARK AddToList
    
    func addItemToList(_ cell:SearchProductCollectionViewCell,quantity:String){
       let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.message.addingProductToList.fromList", comment:""))
        
        let service = GRAddItemListService()
        let pesable = cell.pesable! ? "1" : "0"
        let productObject = service.buildProductObject(upc: cell.upc as String, quantity:Int(quantity)!,pesable:pesable,active:true)
        service.callService(service.buildParams(idList: self.idListFromSearch!, upcs: [productObject]),
            successBlock: { (result:[String:Any]) -> Void in
                alertView!.setMessage(NSLocalizedString("list.message.addProductToListDone", comment:""))
                alertView!.showDoneIcon()
                print("Error at add product to list)")
                self.collection?.reloadData()
                
                // 360 Event
                BaseController.sendAnalyticsProductToList(cell.upc, desc: cell.desc, price: "\(cell.price)")
                
            }, errorBlock: { (error:NSError) -> Void in
                print("Error at add product to list: \(error.localizedDescription)")
                alertView!.setMessage(error.localizedDescription)
                alertView!.showErrorIcon("Ok")
              
            }
        )
    }
    
    /**
     Hides tap bar and hides image header
     */
    override func willHideTabbar() {
        super.willHideTabbar()
        if self.isLandingPage{
            self.showImageHeader(false)
        }
    }
    
    /**
     Shows tap bar and hiddes image header
     */
    
    override func willShowTabbar() {
        super.willShowTabbar()
        if self.isLandingPage{
            self.showImageHeader(true)
        }
    }
    
    //MARK: Animations
    /**
     Show or hides image Header
     
     - parameter didShow: Bool
     */
    func showImageHeader(_ didShow:Bool) {
        
        var startPoint = self.header!.frame.maxY
        if self.isTextSearch || self.isOriginalTextSearch {
            startPoint = viewBgSelectorBtn.frame.maxY + 20
        }
        
        if self.idListFromSearch != "" {
            startPoint = self.header!.frame.maxY
        }
        
        if didShow {
            UIView.animate(withDuration: 0.3, animations: {() in
                self.maxYBanner = self.header!.frame.maxY
                self.bannerView!.frame = CGRect(x: 0, y: self.maxYBanner, width: self.view.frame.width, height: 93)
                startPoint = self.bannerView.frame.maxY
                self.collection!.frame = CGRect(x: 0, y: startPoint, width: self.view.bounds.width, height: (self.view.bounds.height - startPoint))
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.maxYBanner = self.header!.frame.maxY - 93
                self.bannerView!.frame = CGRect(x: 0, y: self.maxYBanner, width: self.view.frame.width, height: 93)
                startPoint = self.bannerView!.frame.maxY
                self.collection!.frame = CGRect(x: 0, y: startPoint, width: self.view.bounds.width, height: (self.view.bounds.height - startPoint))
                
                }, completion: {(finish) in
            })
        }
    }
    
}
 
 extension Array {
    mutating func append(array:Array) {
        for element in array {
            self.append(element)
        }
    }
 }
 
 extension Dictionary {
    mutating func update(from:Dictionary) {
        for (key,value) in from {
            self.updateValue(value, forKey:key)
        }
    }
 }
