 //
//  ProductViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 29/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData


struct SearchResult {
    var products: NSArray? = nil
    var totalResults = -1
    var resultsInResponse = 0
   
    mutating func addResults(otherProducts:NSArray) {
        if self.products != nil {
            self.products = self.products!.arrayByAddingObjectsFromArray(otherProducts as [AnyObject])
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
    case WithText
    case WithCategoryForMG
    case WithCategoryForGR
    case WithTextForCamFind
    case WithRecomendedLine
}
 
 enum SearchServiceFromContext {
    case FromRecomended
    case FromLineSearch
    case FromSearchText
    case FromSearchCamFind
    case FromSearchTextSelect
    case FromSearchTextList
 }

class SearchProductViewController: NavigationViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FilterProductsViewControllerDelegate, SearchProductCollectionViewCellDelegate {

    var contentCollectionOffset: CGPoint?
    var collection: UICollectionView?
    var loading: WMLoadingView?
    var filterButton: UIButton?
    var empty: IPOGenericEmptyView!
    var emptyMGGR: IPOSearchResultEmptyView!
    lazy var results: SearchResult? = SearchResult()
    var allProducts: NSMutableArray? = []
    var upcsToShow : [String]? = []
    var upcsToShowApply : [String]? = []
    
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
    
    var facet : [[String:AnyObject]]!
    
    var controllerFilter : FilterProductsViewController!
    
    var firstOpen  = true
    var isLoading  = false
    var hasEmptyView = false
    
    var itemsUPC: NSArray? = []
    var itemsUPCBk: NSArray? = []
    
    var didSelectProduct =  false
    var finsihService =  false
    
    var selectQuantityGR : GRShoppingCartQuantitySelectorView!
    var selectQuantity : ShoppingCartQuantitySelectorView!
    var isTextSearch: Bool = false
    var isOriginalTextSearch: Bool = false
    
    var findUpcsMg: NSArray? = []
    
    var idListFromSearch : String? = ""
    var invokeServiceInError = false
    var viewEmptyImage =  false
    //var legendView : LegendView?
    
    var plpView : PLPLegendView?
    
    var  isAplyFilter : Bool =  false
    
    override func getScreenGAIName() -> String {
        if self.searchContextType != nil {
            switch self.searchContextType! {
            case .WithCategoryForMG :
                return WMGAIUtils.SCREEN_MGSEARCHRESULT.rawValue
            case .WithCategoryForGR :
                return WMGAIUtils.SCREEN_GRSEARCHRESULT.rawValue
            default :
                break
            }
        }
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        collection = getCollectionView()
        collection?.registerClass(SearchProductCollectionViewCell.self, forCellWithReuseIdentifier: "productSearch")
        collection?.registerClass(LoadingProductCollectionViewCell.self, forCellWithReuseIdentifier: "loadCell")
        collection?.registerClass(SectionHeaderSearchHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collection?.allowsMultipleSelection = true
        
        collection!.dataSource = self
        collection!.delegate = self
        
        collection!.backgroundColor = UIColor.whiteColor()
        self.idSort =  FilterType.none.rawValue
        if self.searchContextType! == .WithCategoryForMG {
            self.idSort =  FilterType.rankingASC.rawValue
        }
        
        self.filterButton = UIButton(type: .Custom)
        //self.filterButton!.setImage(iconImage, forState: .Normal)
        //elf.filterButton!.setImage(iconSelected, forState: .Highlighted)
        self.filterButton!.addTarget(self, action: #selector(SearchProductViewController.filter(_:)), forControlEvents: .TouchUpInside)
        self.filterButton!.tintColor = UIColor.whiteColor()
        self.filterButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        self.filterButton!.setTitle(NSLocalizedString("filter.button.title", comment:"" ) , forState: .Normal)
        self.filterButton!.backgroundColor = WMColor.light_blue
        self.filterButton!.layer.cornerRadius = 11.0

        self.filterButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.filterButton!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0)
        
        self.header?.addSubview(self.filterButton!)

        self.view.addSubview(collection!)
        self.titleLabel?.text = titleHeader
        
        if self.findUpcsMg?.count > 0 {
            self.invokeSearchUPCSCMG()
        }else{
            self.getServiceProduct(resetTable: false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.selectQuantity?.closeAction()
        self.selectQuantityGR?.closeAction()
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
        myString.appendAttributedString(attachmentString)
        titleLabelEdit.numberOfLines = 2
        titleLabelEdit.attributedText = myString
        titleLabelEdit.userInteractionEnabled = true
        titleLabelEdit.textColor =  WMColor.light_blue
        titleLabelEdit.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabelEdit.numberOfLines = 2
        titleLabelEdit.textAlignment = .Center
    
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SearchProductViewController.editSearch))
        titleLabelEdit.addGestureRecognizer(tapGesture)
        
        return titleLabelEdit
        
    }
    
    func editSearch(){
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.EditSearch.rawValue, object: titleHeader!)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.header?.addSubview(self.filterButton!)
        self.view.addSubview(collection!)
        self.isTextSearch = (self.searchContextType == SearchServiceContextType.WithText || self.searchContextType == SearchServiceContextType.WithTextForCamFind)
        self.isOriginalTextSearch = self.originalSearchContextType == SearchServiceContextType.WithText || self.originalSearchContextType == SearchServiceContextType.WithTextForCamFind
        
        if self.isTextSearch || isOriginalTextSearch
        {
            if self.titleLabel != nil {
                self.titleLabel?.removeFromSuperview()
            }
            if self.idListFromSearch == ""{
                self.titleLabel = self.setTitleWithEdit()
            }else{
                 self.titleLabel?.text = titleHeader
            }
            //self.titleLabel?.frame =  CGRectMake(self.titleLabel!.frame.origin.x,self.titleLabel!.frame.origin.y,102 ,self.titleLabel!.frame.size.height)
            self.titleLabel?.numberOfLines = 2
                self.header?.addSubview(self.titleLabel!)
            
            if self.originalSearchContextType == nil{
             self.originalSearchContextType = self.searchContextType
            }
        }
        else
        {
            self.titleLabel?.text = titleHeader
        }
        //aqui la quite
        if loading == nil {
            self.loading = WMLoadingView(frame: CGRectMake(11, 11, self.view.bounds.width, self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
        
        if self.isLoading {
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchProductViewController.afterAddToSC), name: CustomBarNotification.UpdateBadge.rawValue, object: nil)
    }
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.viewEmptyImage =  true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
		self.collection!.reloadData()
        
        if (self.allProducts == nil || self.allProducts!.count == 0) && self.isTextSearch  {
            if finsihService || viewEmptyImage {
            self.showEmptyView()
            }
        } else if self.allProducts == nil || self.allProducts!.count == 0 {
            if (finsihService || viewEmptyImage) && !self.isLoading {
                self.showEmptyView()
            }
        }
        if finsihService || didSelectProduct {
            self.loading?.stopAnnimating()
        }
        if self.results!.totalResults == 0 && self.searchContextType == .WithCategoryForMG {
            self.showEmptyView()
        }
    }
    
    
    func reloadUISearch() {
        self.collection!.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // aqui esta el otro
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if loading == nil {
            self.loading = WMLoadingView(frame: CGRectMake(11, 11, self.view.bounds.width, self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
        
        var startPoint = self.header!.frame.maxY
        
        if self.idListFromSearch != "" {
            startPoint = self.header!.frame.maxY
        }
        
        //TODO MAke Search only one resultset
        contentCollectionOffset = CGPointZero
        self.collection!.frame = CGRectMake(0, startPoint, self.view.bounds.width, self.view.bounds.height - startPoint)
        self.filterButton!.frame = CGRectMake(self.view.bounds.maxX - 70 , (self.header!.frame.size.height - 22)/2 , 55, 22)

        //if self.searchContextType == SearchServiceContextType.WithTextForCamFind {
        self.titleLabel!.frame = CGRectMake(self.filterButton!.frame.width - 5, 0, self.view.bounds.width - (self.filterButton!.frame.width * 2) - 10, self.header!.frame.maxY)
        
        if self.searchContextType != SearchServiceContextType.WithTextForCamFind {
            self.titleLabel!.frame = CGRectMake(self.filterButton!.frame.width , 0, self.view.bounds.width - (self.filterButton!.frame.width * 2) - 12, self.header!.frame.maxY)
        }
    
        self.loading!.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        if self.isAplyFilter {
            self.filterButton!.setTitle(NSLocalizedString("restaurar", comment:"" ) , forState: .Normal)
            self.filterButton!.frame = CGRectMake(self.view.bounds.maxX - 90 , (self.header!.frame.size.height - 22)/2 , 70, 22)
        }else{
            self.filterButton!.setTitle(NSLocalizedString("filter.button.title", comment:"" ) , forState: .Normal)
            self.filterButton!.frame = CGRectMake(self.view.bounds.maxX - 70 , (self.header!.frame.size.height - 22)/2 , 55, 22)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.loading!.frame = self.collection!.frame
    }
    
    //MARK: - UICollectionViewDataSource
    
//    Camfind Results
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        if upcsToShow?.count > 0 {
//            return 2
//        }
//        return 1
//    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! SectionHeaderSearchHeader
            
            view.title = setTitleWithEdit()
            view.title?.textAlignment = .Center
            view.addSubview(view.title!)
            view.addSubview(self.filterButton!)

            view.backgroundColor = WMColor.light_gray
            
            if indexPath.section == 0 {
                view.frame = CGRectMake(0, 0, 0, 0)
            }
            
            return view
        }
        return UICollectionReusableView(frame: CGRectZero)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSizeZero
        }
        
        return CGSizeMake(self.view.frame.width, 44)
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
            
            commonTotal =  (self.results!.totalResults == -1 ? 0:self.results!.totalResults)
            
            commonTotal = commonTotal == 0 ? (self.results!.totalResults == -1 ? 0:(self.results!.totalResults == 0 && self.results!.resultsInResponse != 0 ? self.results!.resultsInResponse : self.results!.totalResults)) : commonTotal
            if commonTotal > 0 {
                commonTotal =  self.results!.resultsInResponse > commonTotal ? self.results!.resultsInResponse :commonTotal
            }
            if count == commonTotal {
                return count
            }
            
            size = (count  >= commonTotal) ? commonTotal : count// + 1
            self.results!.resultsInResponse = size
            
        }
        return size
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //Show loading cell and invoke service
        var commonTotal = 0
        commonTotal =  (self.results!.totalResults == -1 ? 0:self.results!.totalResults)
        
        if indexPath.row == self.allProducts?.count && self.allProducts?.count <= commonTotal  {
            let loadCell = collectionView.dequeueReusableCellWithReuseIdentifier("loadCell", forIndexPath: indexPath)
            self.invokeServiceInError =  true
            self.getServiceProduct(resetTable: false) //Invoke service
            return loadCell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(productCellIdentifier(), forIndexPath: indexPath) as! SearchProductCollectionViewCell
        if self.allProducts?.count <= indexPath.item {
            return cell
        }
        var item : NSDictionary = [:]
        //Camfind Results
//        if indexPath.section == 0 && self.upcsToShow?.count > 0 {
//            if self.btnSuper.selected {
//                item = self.itemsUPCGR![indexPath.item] as! NSDictionary
//            } else {
//                item = self.itemsUPCMG![indexPath.item] as! NSDictionary
//            }
//        } else {
        
//        }
//        
        item = self.allProducts?[indexPath.item] as! NSDictionary
        let upc = item["upc"] as! String
        let skuid = item["skuId"] as? String ?? ""
        let description = item["description"] as? String
        
        var price: NSString? = "0"
        var through: NSString! = ""
        if let priceTxt = item["specialPrice"] as? NSString {
            price = priceTxt
        }
        else if let pricenum = item["specialPrice"] as? NSNumber {
            let txt = pricenum.stringValue
            price = txt
        }
        
        if let priceThr = item["saving"] as? NSString {
            through = priceThr
        }
        
        var imageUrl: String? = ""
        if let imageArray = item["imageUrl"] as? NSArray {
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
        
        //let type = item["type"] as! NSString
        
        var isPesable = false
        if let pesable = item["pesable"] as?  NSString {
            isPesable = pesable.boolValue//pesable.intValue == 1
        }
        
        var isLowStock = false
        if let lowStock = item["lowStock"] as?  Bool {
            isLowStock = lowStock
        }
        
        var productDeparment = ""
        if let category = item["lowStock"] as? String{
            productDeparment = category
        }
        
        var equivalenceByPiece = "0"
        if let equivalence = item["equivalenceByPiece"] as? String{
            equivalenceByPiece = equivalence
        }
        
        let plpArray = UserCurrentSession.sharedInstance().getArrayPLP(item)
        
        through = plpArray["promo"] as! String == "" ? through : plpArray["promo"] as! String
        
        //Set in Cell
        cell.setValues(upc,
            skuId: skuid,
            productImageURL: imageUrl!,
            productShortDescription: description!,
            productPrice: price! as String,
            productPriceThrough: through! as String,
            isMoreArts: plpArray["isMore"] as! Bool,//isMore
            isActive: isActive,
            onHandInventory: onHandDefault,
            isPreorderable:isPreorderable,
            isInShoppingCart: UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc),
            //type:"MG",
            pesable : isPesable,
            isFormList: idListFromSearch != "" ?  true :  false,
            productInlist:idListFromSearch == "" ? false : self.validateProductInList(forProduct: upc, inListWithId: self.idListFromSearch! ),
            isLowStock:isLowStock,
            category:productDeparment,
            equivalenceByPiece: equivalenceByPiece,
            position:self.isAplyFilter ? "" : "\(indexPath.row)"
        )
        
        cell.setValueArray(plpArray["arrayItems"] as! NSArray)
//        self.plpView = PLPLegendView(isvertical: true, PLPArray: plpArray["arrayItems"] as! NSArray, viewPresentLegend: self.view, viewContent: cell.picturesView!)
//        cell.addSubview(self.plpView!)
        cell.delegate = self
        return cell
    }
    
    func validateProductInList(forProduct upc:String?, inListWithId listId:String) -> Bool {
        let detail: Product? = self.retrieveProductInList(forProduct: upc, inListWithId: listId)
        return detail != nil
    }
    
    func retrieveProductInList(forProduct upc:String?, inListWithId listId:String) -> Product? {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        var detail: Product? = nil
        if upc != nil {
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName("Product", inManagedObjectContext: context)
            fetchRequest.predicate = NSPredicate(format: "upc == %@ && list.idList == %@", upc!, listId)
            var result: [Product] = (try! context.executeFetchRequest(fetchRequest)) as! [Product]
            if result.count > 0 {
                detail = result[0]
            }
        }
        return detail
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.view.bounds.maxX/2, 190)
     }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    //MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        didSelectProduct = true
        let cell = self.collection?.cellForItemAtIndexPath(indexPath)
        if cell!.isKindOfClass(SearchProductCollectionViewCell){
            let controller = ProductDetailPageViewController()
            var productsToShow : [[String:String]] = []
            if indexPath.section == 0 && self.upcsToShow?.count > 0 {
                if indexPath.row < self.allProducts!.count {
                    for strUPC in self.allProducts! {
                        let upc = strUPC["upc"] as! String
                        let description = strUPC["description"] as! String
                        //let type = strUPC["type"] as! String
                        var through = ""
                        if let priceThr = strUPC["saving"] as? String {
                            through = priceThr as String
                        }
                        //***Type se le agrega MG por default. esperar para ProductDetailPageViewController
                        productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Mg.rawValue,"saving":through])
                    }
                }
            } else {
                if indexPath.row < self.allProducts!.count {
                    for strUPC in self.allProducts! {
                        let upc = strUPC["upc"] as! String
                        let description = strUPC["description"] as! String
                        //let type = strUPC["type"] as! String
                        var through = ""
                        if let priceThr = strUPC["saving"] as? String {
                            through = priceThr as String
                        }
                        //***Type se le agrega MG por default. esperar para ProductDetailPageViewController
                        productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Mg.rawValue ,"saving":through,"sku":upc])//pendiente sku
                    }
                }
            }
            controller.isForSeach =  (self.textToSearch != nil && self.textToSearch != "") || (self.idLine != nil && self.idLine != "")
            controller.itemsToShow = productsToShow
            controller.ixSelected = indexPath.row
            controller.itemSelectedSolar = self.isAplyFilter ? "" : "\(indexPath.row)"
            controller.idListSeleted =  self.idListFromSearch!
            controller.stringSearching =  self.titleHeader!
            self.navigationController!.pushViewController(controller, animated: true)
        }
       
    }
    
    //MARK: - Services
    
    func getServiceProduct(resetTable resetTable:Bool) {
        self.filterButton?.alpha = 0
        self.contentCollectionOffset = self.collection?.contentOffset
        
        let sucessBlock = { () -> Void in self.updateViewAfterInvokeService(resetTable:resetTable) }
        let errorBlock = { () -> Void in self.updateViewAfterInvokeService(resetTable:resetTable) }
        
        if self.searchContextType != nil {
            self.invokeSearchUPCGroceries(actionSuccess: { () -> Void in
                    
                    self.invokeSearchProducts(actionSuccess: sucessBlock, actionError: errorBlock)
                    /*
                    switch self.searchContextType! {
                    case .WithCategoryForMG :
                        print("Searching products for Category In MG")
                        //    Sustituir busqueda en MG por Groceries
                        self.invokeSearchProducts(actionSuccess: sucessBlock, actionError: errorBlock)

                    case .WithCategoryForGR :
                        print("Searching products for Category In Groceries")
                        self.invokeSearchProducts(actionSuccess: sucessBlock, actionError: errorBlock)
                        
                    default :
                        print("Searching products for text")
                        //Only one service
                        self.invokeSearchProducts(actionSuccess: sucessBlock, actionError: errorBlock)
                    }
                    */
            })
        }
        else {
            print("No existe contexto de busqueda. Es necesario indicar el contexto")
        }
    }
    
    //Solo ocupar este servicio para busqueda
    func invokeSearchUPCGroceries(actionSuccess actionSuccess:(() -> Void)?) {
        if self.upcsToShow?.count > 0 {
            let serviceUPC = GRProductsByUPCService()
            serviceUPC.callService(requestParams: serviceUPC.buildParamServiceUpcs(self.upcsToShow!), successBlock: { (result:NSDictionary) -> Void in
                if result["items"] != nil {
                 self.itemsUPC = result["items"] as? NSArray
                }else {
                 self.itemsUPC = []
                }
               
                actionSuccess?()
                }, errorBlock: { (error:NSError) -> Void in
                    actionSuccess?()
            })
        } else {
            actionSuccess?()
        }
    }
    
    func invokeSearchProducts(actionSuccess actionSuccess:(() -> Void)?, actionError:(() -> Void)?) {
        
        if self.results!.totalResults != -1 && self.results!.resultsInResponse >= self.results!.totalResults {
            if self.allProducts == nil || self.allProducts!.count == 0{
                print("************ No hay productos para mostrar")
                self.showEmptyView()
            }
            print("Groceries Search IS COMPLETE!!!")
            print(self.results?.totalResults)
            print(self.results?.resultsInResponse)
            
            actionSuccess?()
            return
        }
        
        print("Invoking Groceries Search")
        var startOffSet = self.results!.resultsInResponse
        if startOffSet > 0 {
            startOffSet += 1
        }
        //TODO: Signals
        let signalsDictionary : NSDictionary = NSDictionary(dictionary: ["signals" : GRBaseService.getUseSignalServices()])
        let service = GRProductBySearchService(dictionary: signalsDictionary)
        
       // self.brandText = self.idSort != "" ? "" : self.brandText
        let params = service.buildParamsForSearch(text: self.textToSearch, family: self.idFamily, line: self.idLine, sort: self.idSort == "" ? "" : self.idSort , departament: self.idDepartment, start: startOffSet, maxResult: self.maxResult,brand:self.brandText)
        service.callService(params,
                successBlock: { (arrayProduct:NSArray?, facet:NSArray?) -> Void in
                
                self.facet = facet! as! [[String : AnyObject]]
                    
                if arrayProduct != nil && arrayProduct!.count > 0 {
                    
                    //All array items
                    self.results!.addResults(arrayProduct!)
                    self.results!.resultsInResponse = arrayProduct!.count
                    self.results!.totalResults = arrayProduct!.count
                    
                    if let item = arrayProduct?[0] as? NSDictionary {
                        //println(item)
                        if let results = item["resultsInResponse"] as? NSString {
                            self.results!.resultsInResponse += results.integerValue
                        }
                        if let total = item["totalResults"] as? NSString {
                            self.results!.totalResults = total.integerValue
                        }
                    }
                }
                else {
                    self.results!.resultsInResponse = 0
                    self.results!.totalResults = 0
                }
                
                actionSuccess?()
            }, errorBlock: {(error: NSError) in
                print(error)
                //No se encontraron resultados para la búsqueda
                if error.code == 1 {
                    self.results!.resultsInResponse = 0
                    self.results!.totalResults = 0
                    actionError?()
                }else{
                    print("GR Search ERROR!!!")
                    self.results!.totalResults = self.allProducts!.count
                    self.results!.resultsInResponse = self.results!.totalResults
                    actionSuccess?()
                    print(error)
                    actionError?()
                }
            }
        )
    }
    
    func updateViewAfterInvokeService(resetTable resetTable:Bool) {
        
        if firstOpen && (self.results!.products == nil || self.results!.products!.count == 0 ) {
            self.allProducts = []
            if self.results?.products != nil {
                if self.itemsUPC?.count > 0 {
                    self.allProducts?.addObjectsFromArray(self.itemsUPC as! [AnyObject])
                    var filtredProducts : [AnyObject] = []
                    for product in self.results!.products! {
                        let productDict = product as! [String:AnyObject]
                        if let productUPC =  productDict["upc"] as? String {
                            if !self.itemsUPC!.containsObject(productUPC) {
                                filtredProducts.append(productDict)
                            }
                        }
                    }
                    self.allProducts?.addObjectsFromArray(filtredProducts)
                } else {
                    if self.results!.products != nil{
                        self.allProducts?.addObjectsFromArray(self.results!.products as! [AnyObject])
                    }
                }
            }
            firstOpen = false
        } else {
            self.allProducts = []
            if self.results?.products != nil {
                if self.itemsUPC?.count > 0 {
                    self.allProducts?.addObjectsFromArray(self.itemsUPC as! [AnyObject])
                    var filtredProducts : [AnyObject] = []
                    for product in self.results!.products! {
                        let productDict = product as! [String:AnyObject]
                        if let productUPC =  productDict["upc"] as? String {
                            if !self.itemsUPC!.containsObject(productUPC) {
                                filtredProducts.append(productDict)
                            }
                        }
                    }
                    
                    self.allProducts?.addObjectsFromArray(filtredProducts)
                } else {
                    self.allProducts?.addObjectsFromArray(self.results!.products as! [AnyObject])
                }
            }
        }
        
        self.showLoadingIfNeeded(true)
        if (self.allProducts == nil || self.allProducts!.count == 0) && self.isTextSearch{
           self.showEmptyView()
        }
        else {
            if self.searchContextType != nil && self.isTextSearch && self.allProducts != nil {
                //println("sorting values from text search")
                //Order items
                switch (FilterType(rawValue: self.idSort!)!) {
                case .descriptionAsc :
                    //println("descriptionAsc")
                    self.allProducts?.sortUsingDescriptors([NSSortDescriptor(key: "description", ascending: true)])
                    //self.allProducts = self.allProducts!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "description", ascending: true)])
                case .descriptionDesc :
                    //println("descriptionDesc")
                    self.allProducts?.sortUsingDescriptors([NSSortDescriptor(key: "description", ascending: false)])
                    //self.allProducts = self.allProducts!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "description", ascending: false)])
                case .priceAsc :
                    //println("priceAsc")
                    self.allProducts?.sortUsingComparator({ (dictionary1:AnyObject!, dictionary2:AnyObject!) -> NSComparisonResult in
                        let priceOne:Double = self.priceValueFrom(dictionary1 as! NSDictionary)
                        let priceTwo:Double = self.priceValueFrom(dictionary2 as! NSDictionary)
                        
                        if priceOne < priceTwo {
                            return NSComparisonResult.OrderedAscending
                        }
                        else if (priceOne > priceTwo) {
                            return NSComparisonResult.OrderedDescending
                        }
                        else {
                            return NSComparisonResult.OrderedSame
                        }
                        
                    })
                   
                case .none : print("Not sorted")
                default :
                    //println("priceDesc")
                    self.allProducts!.sortUsingComparator({ (dictionary1:AnyObject!, dictionary2:AnyObject!) -> NSComparisonResult in
                        let priceOne:Double = self.priceValueFrom(dictionary1 as! NSDictionary)
                        let priceTwo:Double = self.priceValueFrom(dictionary2 as! NSDictionary)
                        
                        if priceOne > priceTwo {
                            return NSComparisonResult.OrderedAscending
                        }
                        else if (priceOne < priceTwo) {
                            return NSComparisonResult.OrderedDescending
                        }
                        else {
                            return NSComparisonResult.OrderedSame
                        }
                        
                    })
                }
            }
            if self.emptyMGGR != nil {
                self.emptyMGGR.removeFromSuperview()
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.showLoadingIfNeeded(true)
                self.collection?.reloadData()
                self.collection?.alpha = 1
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
                self.filterButton?.alpha = 1
            }
        }
    }
    
    func priceValueFrom(dictionary:NSDictionary) -> Double {
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
        //self.empty = IPOGenericEmptyView(frame:self.collection!.frame)
        
        self.filterButton?.alpha = 0
        var maxY = self.collection!.frame.minY
        
        if self.idListFromSearch != "" && !IS_IPAD {
          maxY = maxY + 64
        }
      
        if self.emptyMGGR == nil {
            self.empty = IPOGenericEmptyView(frame:self.collection!.frame)
            //self.emptyMGGR = IPOSearchResultEmptyView(frame:CGRectMake(0, maxY, self.view.bounds.width, self.view.bounds.height - maxY))
            self.empty.returnAction = { () in
                self.returnBack()
            }
        }
        
        if self.searchFromContextType != .FromSearchTextList{
            self.empty.descLabel.text = "No existe ese artículo"
        } else {
            self.empty.descLabel.text = "No existen artículos"
        }
        
        self.view.addSubview(self.empty)
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
    }
    
    //MARK: - Actions
    
    func returnBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showLoadingIfNeeded(hidden: Bool ) {
        if hidden {
            self.loading!.stopAnnimating()
        } else {
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
    }
    
    //MARK: - Filters
    
    func filter(sender:UIButton){
        if self.isAplyFilter {
            print("Resetea filtros")
            self.isAplyFilter =  false
            self.filterButton!.setTitle(NSLocalizedString("filter.button.title", comment:"" ) , forState: .Normal)
            self.filterButton!.frame = CGRectMake(self.view.bounds.maxX - 70 , (self.header!.frame.size.height - 22)/2 , 55, 22)
            self.results!.resetResult()
            self.getServiceProduct(resetTable: true)
        }else{
            print("Nuevos filtros")
            if controllerFilter == nil {
                controllerFilter = FilterProductsViewController()
                controllerFilter.facet = self.facet
                controllerFilter.textToSearch = self.textToSearch
                controllerFilter.selectedOrder = self.idSort! == "" ? "rating" :self.idSort! 
                controllerFilter.delegate = self
                //controllerFilter.isTextSearch = false //para no llamar los servicios de facets
                controllerFilter.originalSearchContext = self.originalSearchContextType == nil ? self.searchContextType : self.originalSearchContextType
                controllerFilter?.backFilter = {() in
                    self.loading?.stopAnnimating()
                    self.loading?.removeFromSuperview()
                }
            }
            controllerFilter.selectedOrder! =  ""
            controllerFilter.filterOrderViewCell?.resetOrderFilter()
            controllerFilter.sliderTableViewCell?.resetSlider()
            controllerFilter.upcPrices =  nil
            controllerFilter.selectedElementsFacet = [:]
            controllerFilter.searchContext = SearchServiceContextType.WithCategoryForMG //
            self.navigationController?.pushViewController(controllerFilter, animated: true)
        }
    }
    
    
    func apply(order:String, filters:[String:AnyObject]?, isForGroceries flag:Bool) {
        
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
            self.searchContextType = flag ? .WithCategoryForGR : .WithCategoryForMG
            
            if self.upcsToShowApply?.count == 0 {
                self.upcsToShowApply = self.upcsToShow
                self.itemsUPCBk = self.itemsUPC
                self.itemsUPC = []
                self.upcsToShow = []
            }
            
        } else {
            self.itemsUPC = self.itemsUPCBk
            self.upcsToShow = self.upcsToShowApply
            self.upcsToShowApply = []
        }

        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_APPLY_FILTER.rawValue, label: "\(self.idDepartment)-\(self.idFamily)-\(self.idLine)-\(order)-")
        
        self.allProducts = []
        //self.mgResults!.resetResult()
        self.results!.resetResult()
        self.getServiceProduct(resetTable: true)
    }
    
    func sendBrandFilter(brandFilter: String) {
        self.brandText = brandFilter
        
    }

    func apply(order:String, upcs: [String]) {

        self.isAplyFilter =  true
        
        if IS_IPHONE {
            self.isLoading = true
        } else {
            showLoadingIfNeeded(false)
        }
        
        self.collection?.alpha = 100
        if upcs.count == 0 {
            self.allProducts = []
            self.results?.totalResults = 0
            self.collection?.reloadData()
            self.collection?.alpha = 0
            self.finsihService =  true
            return
        } else {
            if self.emptyMGGR != nil {
                self.emptyMGGR.removeFromSuperview()
            }
        }
        
        
        let svcSearch = SearchItemsByUPCService()
        svcSearch.callService(upcs, successJSONBlock: { (result:JSON) -> Void in
            if self.originalSearchContextType != .WithTextForCamFind {
                self.allProducts? = []
            }
            self.allProducts?.addObjectsFromArray(result.arrayObject!)
            self.results?.totalResults = self.allProducts!.count
            self.idSort = order
            switch (FilterType(rawValue: self.idSort!)!) {
            case .descriptionAsc :
                //println("descriptionAsc")
                self.allProducts!.sortUsingDescriptors([NSSortDescriptor(key: "description", ascending: true)])
            case .descriptionDesc :
                //println("descriptionDesc")
                self.allProducts!.sortUsingDescriptors([NSSortDescriptor(key: "description", ascending: false)])
            case .priceAsc :
                //println("priceAsc")
                self.allProducts!.sortUsingComparator({ (dictionary1:AnyObject!, dictionary2:AnyObject!) -> NSComparisonResult in
                    let priceOne:Double = self.priceValueFrom(dictionary1 as! NSDictionary)
                    let priceTwo:Double = self.priceValueFrom(dictionary2 as! NSDictionary)
                    
                    if priceOne < priceTwo {
                        return NSComparisonResult.OrderedAscending
                    }
                    else if (priceOne > priceTwo) {
                        return NSComparisonResult.OrderedDescending
                    }
                    else {
                        return NSComparisonResult.OrderedSame
                    }
                    
                })
            case .none : print("Not sorted")
            case .priceDesc :
                //println("priceDesc")
                self.allProducts!.sortUsingComparator({ (dictionary1:AnyObject!, dictionary2:AnyObject!) -> NSComparisonResult in
                    let priceOne:Double = self.priceValueFrom(dictionary1 as! NSDictionary)
                    let priceTwo:Double = self.priceValueFrom(dictionary2 as! NSDictionary)
                    
                    if priceOne > priceTwo {
                        return NSComparisonResult.OrderedAscending
                    }
                    else if (priceOne < priceTwo) {
                        return NSComparisonResult.OrderedDescending
                    }
                    else {
                        return NSComparisonResult.OrderedSame
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
        if self.originalSearchContextType != nil && self.isTextSearch {
            self.idDepartment = nil
            self.idFamily = nil
            self.idLine = nil
        }
        self.allProducts = []
        self.results!.resetResult()
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
        self.results!.resetResult()
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
    func changeSuperTech(sender:UIButton) {
        //self.collection?.contentOffset = CGPointZero
        
        sender.selected = true
        
        self.allProducts = nil
        updateViewAfterInvokeService(resetTable:true)
        self.searchContextType = SearchServiceContextType.WithCategoryForGR
    }
    
    //MARK: SearchProductCollectionViewCellDelegate
    
    func buildGRSelectQuantityView(cell: SearchProductCollectionViewCell, viewFrame: CGRect){
        var prodQuantity = "1"
        if cell.pesable! {
            prodQuantity = "50"
            let equivalence =  cell.equivalenceByPiece == "" ? 0.0 : cell.equivalenceByPiece.toDouble()
            
            selectQuantityGR = GRShoppingCartWeightSelectorView(frame:viewFrame,priceProduct:NSNumber(double:(cell.price as NSString).doubleValue),quantity:Int(prodQuantity),equivalenceByPiece:Int(equivalence!),upcProduct:cell.upc)
            
        }else{
            prodQuantity = "1"
            selectQuantityGR = GRShoppingCartQuantitySelectorView(frame:viewFrame,priceProduct:NSNumber(double:(cell.price as NSString).doubleValue),quantity:Int(prodQuantity),upcProduct:cell.upc)
        }
        
        //EVENT
        let action = cell.pesable! ? WMGAIUtils.ACTION_CHANGE_NUMER_OF_KG.rawValue : WMGAIUtils.ACTION_CHANGE_NUMER_OF_PIECES.rawValue
        BaseController.sendAnalytics(WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue, action:action, label: "\(cell.desc) - \(cell.upc)")
        
        selectQuantityGR?.closeAction = { () in
            self.selectQuantityGR.removeFromSuperview()
        }
        
        selectQuantityGR?.addToCartAction = { (quantity:String) in
            //let quantity : Int = quantity.toInt()!
            if cell.onHandInventory.integerValue >= Int(quantity) {
                self.selectQuantityGR?.closeAction()
                if self.idListFromSearch == ""{
                    let params = self.buildParamsUpdateShoppingCart(cell,quantity: quantity,position:cell.positionSelected)
                    //CAMBIA IMAGEN CARRO SELECCIONADO
                    //cell.addProductToShopingCart!.setImage(UIImage(named: "products_done"), forState: UIControlState.Normal)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
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
    
    func selectGRQuantityForItem(cell: SearchProductCollectionViewCell) {
        let frameDetail = CGRectMake(0,0, self.view.frame.width,self.view.frame.height)
        self.buildGRSelectQuantityView(cell, viewFrame: frameDetail)
        self.view.addSubview(selectQuantityGR)
    }
    
    func buildMGSelectQuantityView(cell: SearchProductCollectionViewCell, viewFrame: CGRect){
        selectQuantity = ShoppingCartQuantitySelectorView(frame:viewFrame,priceProduct:NSNumber(double:(cell.price as NSString).doubleValue),upcProduct:cell.upc)
        selectQuantity!.closeAction = { () in
            self.selectQuantity.removeFromSuperview()
        }
        //selectQuantity!.generateBlurImage(self.view,frame:selectQuantity.bounds)
        
        //Event
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_KEYBOARD.rawValue, label: "\(cell.desc) - \(cell.upc)")
        
        selectQuantity!.addToCartAction =
            { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                let maxProducts = (cell.onHandInventory.integerValue <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory.integerValue : 5
                if maxProducts >= Int(quantity) {
                    let params = self.buildParamsUpdateShoppingCart(cell,quantity: quantity,position: cell.positionSelected)//
                    
                    BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label:"\(cell.upc) - \(cell.desc)")
                    
                    UIView.animateWithDuration(0.2,
                        animations: { () -> Void in
                            self.selectQuantity!.closeAction()
                        },
                        completion: { (animated:Bool) -> Void in
                            self.selectQuantity = nil
                            //CAMBIA IMAGEN CARRO SELECCIONADO
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
    }
    
    func selectMGQuantityForItem(cell: SearchProductCollectionViewCell) {
        let frameDetail = CGRectMake(0,0, self.view.frame.width,self.view.frame.height)
        self.buildMGSelectQuantityView(cell, viewFrame: frameDetail)
        self.view.addSubview(selectQuantity)
    }
    
    func buildParamsUpdateShoppingCart(cell:SearchProductCollectionViewCell,quantity:String,position:String) -> [String:AnyObject] {
        let pesable = cell.pesable! ? "1" : "0"
        let searchText = self.textToSearch ?? ""
        let channel = IS_IPAD ? "ipad" : "iphone"
        //Add skuId
        if cell.type == ResultObjectType.Groceries.rawValue {
            if searchText != ""{
                return ["upc":cell.upc,"skuId":cell.skuId,"desc":cell.desc,"imgUrl":cell.imageURL,"price":cell.price,"quantity":quantity,"comments":"","onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable,"parameter":["q":searchText,"eventtype": "addtocart","collection":"dah","channel": channel,"position":position]]
            }
            return ["upc":cell.upc,"skuId":cell.skuId,"desc":cell.desc,"imgUrl":cell.imageURL,"price":cell.price,"quantity":quantity,"comments":"","onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable]
        }
        else {
            
            if searchText != ""{
            return ["upc":cell.upc,"skuId":cell.skuId,"desc":cell.desc,"imgUrl":cell.imageURL,"price":cell.price,"quantity":quantity,"onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":cell.isPreorderable,"category": cell.productDeparment,"parameter":["q":searchText,"eventtype": "addtocart","collection":"mg","channel": channel,"position":position]]
            }
            return ["upc":cell.upc,"skuId":cell.skuId,"desc":cell.desc,"imgUrl":cell.imageURL,"price":cell.price,"quantity":quantity,"onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":cell.isPreorderable,"category": cell.productDeparment]
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
                let upcs : NSArray = result.arrayObject!
                if upcs.count > 0 {
                self.allProducts?.addObjectsFromArray(upcs as [AnyObject])
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
    
    func addItemToList(cell:SearchProductCollectionViewCell,quantity:String){
       let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.message.addingProductToList.fromList", comment:""))
        
        let service = GRAddItemListService()
        let pesable = cell.pesable! ? "1" : "0"
        let productObject = service.buildProductObject(upc: cell.upc as String, quantity:Int(quantity)!,pesable:pesable,active:true)
        service.callService(service.buildParams(idList: self.idListFromSearch!, upcs: [productObject]),
            successBlock: { (result:NSDictionary) -> Void in
                alertView!.setMessage(NSLocalizedString("list.message.addProductToListDone", comment:""))
                alertView!.showDoneIcon()
                print("Error at add product to list)")
                self.collection?.reloadData()

            }, errorBlock: { (error:NSError) -> Void in
                print("Error at add product to list: \(error.localizedDescription)")
                alertView!.setMessage(error.localizedDescription)
                alertView!.showErrorIcon("Ok")
              
            }
        )
    }
    
    
    
}
