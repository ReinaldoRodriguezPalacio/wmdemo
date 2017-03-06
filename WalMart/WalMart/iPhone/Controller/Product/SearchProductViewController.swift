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
    var products: [[String:Any]]? = nil
    var totalResults = -1
    var resultsInResponse = 0
    
    mutating func addResults(otherProducts:[[String:Any]]) {
        if self.products != nil {
            for product in otherProducts {
                self.products?.append(product)
            }
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
    var allProducts: [[String:Any]]? = []
    var upcsToShow : [String]? = []
    var upcsToShowApply : [String]? = []
    
    var titleHeader: String?
    var originalSort: String?
    var originalSearchContextType: SearchServiceContextType?
    var searchContextType: SearchServiceContextType?
    var searchFromContextType: SearchServiceFromContext?
    var textToSearch:String?
    var urlFamily:String?
    var idDepartment:String?
    var idFamily :String?
    var idLine:String?
    var idSort:String?
    var maxResult: Int = 20
    var brandText: String? = ""
    var originalUrl : String = ""
    var originalText : String = ""
    
    var facet : NSDictionary? = [:]
    
    var controllerFilter : FilterProductsViewController!
    
    var firstOpen  = true
    var isLoading  = false
    var hasEmptyView = false
    
    var itemsUPC: [[String:Any]]? = []
    var itemsUPCBk: [[String:Any]]? = []
    
    var didSelectProduct =  false
    var finsihService =  false
    
    var selectQuantityGR : GRShoppingCartQuantitySelectorView!
    var selectQuantity : ShoppingCartQuantitySelectorView!
    var isTextSearch: Bool = false
    var isOriginalTextSearch: Bool = false
    
    var findUpcsMg: [String]? = []
    
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
        
        self.view.backgroundColor = UIColor.white
        
        collection = getCollectionView()
        collection?.register(SearchProductCollectionViewCell.self, forCellWithReuseIdentifier: "productSearch")
        collection?.register(LoadingProductCollectionViewCell.self, forCellWithReuseIdentifier: "loadCell")
        collection?.register(SectionHeaderSearchHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collection?.allowsMultipleSelection = true
        
        collection!.dataSource = self
        collection!.delegate = self
        
        collection!.backgroundColor = UIColor.white
        self.idSort =  FilterType.none.rawValue
        if self.searchContextType! == .WithCategoryForMG {
            self.idSort =  FilterType.rankingASC.rawValue
        }
        
        self.filterButton = UIButton(type: .custom)
        //self.filterButton!.setImage(iconImage, forState: .Normal)
        //elf.filterButton!.setImage(iconSelected, forState: .Highlighted)
        self.filterButton!.addTarget(self, action: #selector(SearchProductViewController.filter(_:)), for: .touchUpInside)
        self.filterButton!.tintColor = UIColor.white
        self.filterButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        self.filterButton!.setTitle(NSLocalizedString("filter.button.title", comment:"" ) , for: .normal)
        self.filterButton!.backgroundColor = WMColor.light_blue
        self.filterButton!.layer.cornerRadius = 11.0
        
        self.filterButton!.setTitleColor(UIColor.white, for: .normal)
        self.filterButton!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0)
        
        self.header?.addSubview(self.filterButton!)
        
        self.view.addSubview(collection!)
        self.titleLabel?.text = titleHeader
        
        if self.findUpcsMg != nil &&  self.findUpcsMg!.count > 0 {
            self.invokeSearchUPCSCMG()
        }else{
            self.getServiceProduct(resetTable: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CustomBarNotification.EditSearch.rawValue), object: titleHeader!)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
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
            self.loading = WMLoadingView(frame: CGRect(x:11, y:11, width:self.view.bounds.width, height:self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.white
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
        
        if self.isLoading {
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
        
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
            self.loading = WMLoadingView(frame: CGRect(x:11, y:11, width:self.view.bounds.width, height:self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.white
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
        
        var startPoint = self.header!.frame.maxY
        
        if self.idListFromSearch != "" {
            startPoint = self.header!.frame.maxY
        }
        
        //TODO MAke Search only one resultset
        contentCollectionOffset = CGPoint.zero
        self.collection!.frame = CGRect(x:0, y:startPoint, width:self.view.bounds.width,height: self.view.bounds.height - startPoint)
        self.filterButton!.frame = CGRect(x:self.view.bounds.maxX - 70 ,  y:(self.header!.frame.size.height - 22)/2 ,width: 55,height: 22)
        
        //if self.searchContextType == SearchServiceContextType.WithTextForCamFind {
        self.titleLabel!.frame = CGRect(x:self.filterButton!.frame.width - 5,  y:0, width:self.view.bounds.width - (self.filterButton!.frame.width * 2) - 10, height:self.header!.frame.maxY)
        
        if self.searchContextType != SearchServiceContextType.WithTextForCamFind {
            self.titleLabel!.frame = CGRect(x:self.filterButton!.frame.width , y: 0, width:self.view.bounds.width - (self.filterButton!.frame.width * 2) - 12, height:self.header!.frame.maxY)
        }
        
        self.loading!.frame = CGRect(x:0, y: 46,width: self.view.bounds.width,height: self.view.bounds.height - 46)
        if self.isAplyFilter {
            self.filterButton!.setTitle(NSLocalizedString("restaurar", comment:"" ) , for: .normal)
            self.filterButton!.frame = CGRect(x:self.view.bounds.maxX - 90 , y: (self.header!.frame.size.height - 22)/2 ,width: 70, height:22)
        }else{
            self.filterButton!.setTitle(NSLocalizedString("filter.button.title", comment:"" ) , for: .normal)
            self.filterButton!.frame = CGRect(x:self.view.bounds.maxX - 70 , y: (self.header!.frame.size.height - 22)/2 ,width: 55,height: 22)
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
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath as IndexPath) as! SectionHeaderSearchHeader
            
            view.title = setTitleWithEdit()
            view.title?.textAlignment = .center
            view.addSubview(view.title!)
            view.addSubview(self.filterButton!)
            
            view.backgroundColor = WMColor.light_gray
            
            if indexPath.section == 0 {
                view.frame = CGRect(x:0, y:0, width:0, height:0)
            }
            
            return view
        }
        return UICollectionReusableView(frame: CGRect.zero)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize.zero
        }
        
        return CGSize(width:self.view.frame.width, height:44)
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
            
            commonTotal =  (self.results!.totalResults == -1 ? 0:self.results!.totalResults)
            
            commonTotal = commonTotal == 0 ? (self.results!.totalResults == -1 ? 0:(self.results!.totalResults == 0 && self.results!.resultsInResponse != 0 ? self.results!.resultsInResponse : self.results!.totalResults)) : commonTotal
            if commonTotal > 0 {
                commonTotal =  self.results!.resultsInResponse > commonTotal ? self.results!.resultsInResponse :commonTotal
            }
            if count == commonTotal {
                return count
            }
            
            size = (count  >= commonTotal) ? commonTotal : count + 1
            self.results!.resultsInResponse = (count  >= commonTotal) ? commonTotal : count
            
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Show loading cell and invoke service
        var commonTotal = 0
        commonTotal =  (self.results!.totalResults == -1 ? 0:self.results!.totalResults)
        
        if indexPath.row == (self.allProducts?.count)! && (self.allProducts?.count)! <= commonTotal  {
            let loadCell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadCell", for: indexPath as IndexPath)
            self.invokeServiceInError =  true
            self.getServiceProduct(resetTable: false) //Invoke service
            return loadCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productCellIdentifier(), for: indexPath as IndexPath) as! SearchProductCollectionViewCell
        if (self.allProducts?.count)! <= indexPath.item {
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
        var upc = ""
        if let upcValue = item["productRepositoryId"] as? NSArray {
            upc = upcValue[0] as! String
        }
        
        var skuid = ""
        if let skuIdValue = item["skuRepositoryId"] as? NSArray {
            skuid = skuIdValue[0] as! String
        }
        var description = ""
        if let productDispValue = item["productDisplayText"] as? NSArray {
            description = productDispValue[0] as! String
        }
        
        var price: NSString? = "0"
        var through: NSString! = ""
        if let priceTxt = item["skuFinalPrice"] as? NSArray {
            price = priceTxt[0] as? NSString
        }
        else if let pricenum = item["skuFinalPrice"] as? NSNumber {
            let txt = pricenum.stringValue
            price = txt as NSString?
        }
        
        if let priceThr = item["saving"] as? NSString {
            through = priceThr
        }
        
        var imageUrl: String? = ""
        if let imageArray = item["productSmallImageUrl"] as? NSArray{
            if imageArray.count > 0 {
                imageUrl = imageArray[0] as? String
            }
        } else if let imageUrlTxt = item["productSmallImageUrl"] as? String {
            imageUrl = imageUrlTxt
        }
        
        var isActive = true
        if let activeTxt = item["isActive"] as? String {//isActive
            isActive = "true" == activeTxt
        }
        
        //??????
        if isActive {
            isActive = price!.doubleValue > 0
        }
        
        var isPreorderable = false
        if let preordeable = item["isPreorderable"] as? String {//
            isPreorderable = "true" == preordeable
        }
        
        var onHandDefault = 99
        if let onHandInventory = item["onHandInventory"] as? NSString {//
            onHandDefault = onHandInventory.integerValue
        }
        
        //let type = item["type"] as! NSString
        
        var isPesable = false
        if let pesable = item["pesable"] as?  NSString {//skuWeighable or skuUnitOfMeasure
            isPesable = pesable.boolValue//pesable.intValue == 1
        }
        
        var isLowStock = false
        if let lowStock = item["lowStock"] as?  Bool {//
            isLowStock = lowStock
        }
        
        var productDeparment = ""
        if let category = item["lowStock"] as? String{//
            productDeparment = category
        }
        
        var equivalenceByPiece = "0"
        if let equivalence = item["equivalenceByPiece"] as? String{//skuWeighable
            equivalenceByPiece = equivalence
        }
        
        let plpArray = UserCurrentSession.sharedInstance.getArrayPLP(item)
        
        through = plpArray["promo"] as! String == "" ? through : plpArray["promo"] as! NSString
        
        //Set in Cell
        cell.setValues(upc,
                       skuId: skuid,
                       productImageURL: imageUrl!,
                       productShortDescription: description,
                       productPrice: price! as String,
                       productPriceThrough: through! as String,
                       isMoreArts: plpArray["isMore"] as! Bool,//isMore
            isActive: isActive,
            onHandInventory: onHandDefault,
            isPreorderable:isPreorderable,
            isInShoppingCart: UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc),
            //type:"MG",
            pesable : isPesable,
            isFormList: idListFromSearch != "" ?  true :  false,
            productInlist:idListFromSearch == "" ? false : self.validateProductInList(forProduct: upc, inListWithId: self.idListFromSearch! ),
            isLowStock:isLowStock,
            category:productDeparment,
            equivalenceByPiece: equivalenceByPiece,
            position:self.isAplyFilter ? "" : "\(indexPath.row)"
        )
        
        cell.setValueArray(plpArray["arrayItems"] as! [[String:Any]])
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
        return CGSize(width:self.view.bounds.maxX/2,height: 190)
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
        let cell = self.collection?.cellForItem(at: indexPath as IndexPath)
        if cell! is SearchProductCollectionViewCell {
            let controller = ProductDetailPageViewController()
            var productsToShow : [[String:String]] = []
            if indexPath.section == 0 && (self.upcsToShow?.count)! > 0 {
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
    
    func getServiceProduct(resetTable:Bool) {
        self.filterButton?.alpha = 0
        self.contentCollectionOffset = self.collection?.contentOffset
        
        let sucessBlock = { () -> Void in self.updateViewAfterInvokeService(resetTable:resetTable) }
        let errorBlock = { () -> Void in self.updateViewAfterInvokeService(resetTable:resetTable) }
        
        if self.searchContextType != nil {
            
            self.invokeSearchUPCGroceries(actionSuccess: { () -> Void in
                
                self.invokeSearchProducts(actionSuccess: sucessBlock, actionError: errorBlock)
            })
        }
        else {
            print("No existe contexto de busqueda. Es necesario indicar el contexto")
        }
    }
    
    //Solo ocupar este servicio para busqueda
    func invokeSearchUPCGroceries(actionSuccess:(() -> Void)?) {
        if self.upcsToShow != nil {
            if (self.upcsToShow?.count)! > 0 {
                let serviceUPC = GRProductsByUPCService()
                serviceUPC.callService(requestParams: serviceUPC.buildParamServiceUpcs(self.upcsToShow!) as AnyObject, successBlock: { (result:[String:Any]) -> Void in
                    if result["items"] != nil {
                        self.itemsUPC = result["items"] as? [[String : Any]]
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
         else {
            actionSuccess?()
        }
    }
    
    func invokeSearchProducts(actionSuccess:(() -> Void)?, actionError:(() -> Void)?) {
        
        if self.results!.totalResults != -1 && self.results!.resultsInResponse >= self.results!.totalResults {
            if self.allProducts == nil || self.allProducts!.count == 0{
                print("************ No hay productos para mostrar")
                self.showEmptyView()
            }
            print("Groceries Search IS COMPLETE!!!")
            
            actionSuccess?()
            return
        }
        
        print("Invoking Groceries Search")
        var startOffSets = self.results!.resultsInResponse
        if startOffSets > 0 {
            startOffSets += 1
        }
        //TODO: Signals
        let signalsDictionary : [String:Any] = ["signals" : BaseService.getUseSignalServices()]
        let service = GRProductBySearchService(dictionary: signalsDictionary)
        
        // self.brandText = self.idSort != "" ? "" : self.brandText
        //let params = service.buildParamsForSearch(text: self.textToSearch, family: self.idFamily, line: self.idLine, sort: self.idSort == "" ? "" : self.idSort , departament: self.idDepartment, start: startOffSet, maxResult: self.maxResult,brand:self.brandText)
        let params = service.buildParamsForSearch(url: self.urlFamily, text: self.textToSearch, sort: "0", startOffSet: String(startOffSets), maxResult:"20")
        service.callService(params as AnyObject,
                            successBlock: { (arrayProduct:[[String : Any]]?, facet:NSMutableDictionary?) -> Void in
                                
                                self.facet = facet!
                                if arrayProduct != nil && arrayProduct!.count > 0 {
                                    
                                    //All array items
                                    self.results!.addResults(otherProducts: arrayProduct!)//result
                                    self.results!.resultsInResponse = arrayProduct!.count //NumRes
                                    self.results!.totalResults = arrayProduct!.count //TotalRes
                                    
                                     let item = arrayProduct![0]
                                        //println(item)
                                    if let results = item["resultsInResponse"] as? NSString {
                                        self.results!.resultsInResponse += results.integerValue
                                    }
                                    if let total = item["totalResults"] as? NSString {
                                        self.results!.totalResults = total.integerValue
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
    
    func updateViewAfterInvokeService(resetTable:Bool) {
        
        if firstOpen && (self.results!.products == nil || self.results!.products!.count == 0 ) {
            self.allProducts = []
            if self.results?.products != nil {
                if (self.itemsUPC?.count)! > 0 {
                    self.allProducts!.append(array:self.itemsUPC!)
                    var filtredProducts : [[String:Any]]? = []
                    for product in self.results!.products! {
                        let productDict = product
                        if let productUPC =  productDict["upc"] as? String {
                            if !self.itemsUPC!.contains(where: { (item:[String:Any]) -> Bool  in return (item["upc"] as! String) == productUPC } ) {
                                filtredProducts?.append(productDict)
                            }
                        }
                    }
                     self.allProducts!.append(array:filtredProducts!)
                } else {
                    if self.results!.products != nil{
                         self.allProducts!.append(array:self.results!.products!)
                    }
                }
            }
            firstOpen = false
        } else {
            self.allProducts = []
            if self.results?.products != nil {
                if (self.itemsUPC?.count)! > 0 {
                    self.allProducts!.append(array:self.itemsUPC!)
                    var filtredProducts : [[String:Any]] = []
                    for product in self.results!.products! {
                        let productDict = product
                        if let productUPC =  productDict["upc"] as? String {
                            if !self.itemsUPC!.contains(where: { (item:[String:Any]) -> Bool  in return (item["upc"] as! String) == productUPC }) {
                                filtredProducts.append(productDict)
                            }
                        }
                    }
                    
                   self.allProducts!.append(array:filtredProducts)
                } else {
                   self.allProducts!.append(array:self.results!.products!)
                }
            }
        }
        
        self.showLoadingIfNeeded(hidden: true)
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
                    self.allProducts?.sort(by: { ($0["description"] as! String) > ($1["description"] as! String) })
                //self.allProducts = self.allProducts!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "description", ascending: true)])
                case .descriptionDesc :
                    //println("descriptionDesc")
                    self.allProducts?.sort(by:{ ($0["description"] as! String) < ($1["description"] as! String)})
                //self.allProducts = self.allProducts!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "description", ascending: false)])
                case .priceAsc :
                    //println("priceAsc")
                    self.allProducts?.sort(by: { (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                        let priceOne:Double = self.priceValueFrom(dictionary: dictionary1)
                        let priceTwo:Double = self.priceValueFrom(dictionary: dictionary2)
                        
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
                default :
                    //println("priceDesc")
                    self.allProducts!.sort(by: { (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                        let priceOne:Double = self.priceValueFrom(dictionary: dictionary1)
                        let priceTwo:Double = self.priceValueFrom(dictionary: dictionary2)
                        
                        if priceOne > priceTwo {
                            return true
                        }
                        else if (priceOne < priceTwo) {
                            return false
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
            
            DispatchQueue.main.async {
                self.showLoadingIfNeeded(hidden: true)
                self.collection?.reloadData()
                self.collection?.alpha = 1
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: CustomBarNotification.ClearSearch.rawValue), object: nil)
                self.filterButton?.alpha = 1
            }
        }
    }
    
    func priceValueFrom(dictionary:[String:Any]) -> Double {
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CustomBarNotification.ClearSearch.rawValue), object: nil)
    }
    
    //MARK: - Actions
    
    func returnBack() {
        self.navigationController?.popViewController(animated: true)
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
    
    func filter(_ sender:UIButton){
        if self.isAplyFilter {
            print("Resetea filtros")
            self.isAplyFilter =  false
            self.filterButton!.setTitle(NSLocalizedString("filter.button.title", comment:"" ) , for: .normal)
            self.filterButton!.frame = CGRect(x:self.view.bounds.maxX - 70 , y:(self.header!.frame.size.height - 22)/2 , width:55, height:22)
            self.results!.resetResult()
            self.getServiceProduct(resetTable: true)
        }else{
            print("Nuevos filtros")
            if controllerFilter == nil {
                controllerFilter = FilterProductsViewController()
                controllerFilter.facet = self.facet as? [[String:Any]]
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
            controllerFilter.filtersAll = self.facet
            controllerFilter.filterOrderViewCell?.resetOrderFilter()
            controllerFilter.upcPrices =  nil
            controllerFilter.selectedElementsFacet = [:]
            controllerFilter.searchContext = SearchServiceContextType.WithCategoryForMG //
            self.navigationController?.pushViewController(controllerFilter, animated: true)
        }
    }
    
    func apply(_urlSort: String) {
        self.urlFamily = _urlSort
        self.textToSearch = ""
        
        self.results!.resetResult()
        self.getServiceProduct(resetTable: true)
        
        self.collection!.reloadData()
        self.showLoadingIfNeeded(hidden: false)
    }
    
    /*func removeSelectedFilters(){
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
        
    }*/
    
    func removeFilters() {
        
        self.urlFamily = self.originalUrl
        self.textToSearch = self.originalText
        
        self.allProducts = []
        self.results!.resetResult()
        self.showLoadingIfNeeded(hidden: false)
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
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: customlayout)
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }

        return collectionView
    }
    
    //MARK: Filter Super Tecnologia
    func changeSuperTech(sender:UIButton) {
        //self.collection?.contentOffset = CGPointZero
        
        sender.isSelected = true
        
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
            
            selectQuantityGR = GRShoppingCartWeightSelectorView(frame:viewFrame,priceProduct:NSNumber(value:(cell.price as NSString).doubleValue),quantity:Int(prodQuantity),equivalenceByPiece:NSNumber(value: equivalence!),upcProduct:cell.upc)
            
        }else{
            prodQuantity = "1"
            selectQuantityGR = GRShoppingCartQuantitySelectorView(frame:viewFrame,priceProduct:NSNumber(value:(cell.price as NSString).doubleValue),quantity:Int(prodQuantity),upcProduct:cell.upc)
        }
        
        //EVENT
        let action = cell.pesable! ? WMGAIUtils.ACTION_CHANGE_NUMER_OF_KG.rawValue : WMGAIUtils.ACTION_CHANGE_NUMER_OF_PIECES.rawValue
        //BaseController.sendAnalytics(WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth: WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue, action:action, label: "\(cell.desc) - \(cell.upc)")
        
        selectQuantityGR?.closeAction = { () in
            self.selectQuantityGR.removeFromSuperview()
        }
        
        selectQuantityGR?.addToCartAction = { (quantity:String) in
            //let quantity : Int = quantity.toInt()!
            if cell.onHandInventory.integerValue >= Int(quantity)! {
                self.selectQuantityGR?.closeAction()
                if self.idListFromSearch == ""{
                    let params = self.buildParamsUpdateShoppingCart(cell: cell,quantity: quantity,position:cell.positionSelected)
                    //CAMBIA IMAGEN CARRO SELECCIONADO
                    //cell.addProductToShopingCart!.setImage(UIImage(named: "products_done"), forState: UIControlState.Normal)
                    
                    NotificationCenter.default.post(name:NSNotification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
                }else{
                    self.addItemToList(cell: cell, quantity:quantity)
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
        let frameDetail = CGRect(x:0,y:0, width:self.view.frame.width,height:self.view.frame.height)
        self.buildGRSelectQuantityView(cell: cell, viewFrame: frameDetail)
        self.view.addSubview(selectQuantityGR)
    }
    
    func buildMGSelectQuantityView(cell: SearchProductCollectionViewCell, viewFrame: CGRect){
        selectQuantity = ShoppingCartQuantitySelectorView(frame:viewFrame,priceProduct:NSNumber(value:(cell.price as NSString).doubleValue),upcProduct:cell.upc)
        selectQuantity!.closeAction = { () in
            self.selectQuantity.removeFromSuperview()
        }
        //selectQuantity!.generateBlurImage(self.view,frame:selectQuantity.bounds)
        
        //Event
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_KEYBOARD.rawValue, label: "\(cell.desc) - \(cell.upc)")
        
        selectQuantity!.addToCartAction =
            { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                let maxProducts = (cell.onHandInventory.integerValue <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory.integerValue : 5
                if maxProducts >= Int(quantity)! {
                    let params = self.buildParamsUpdateShoppingCart(cell: cell,quantity: quantity,position: cell.positionSelected)//
                    
                    //BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label:"\(cell.upc) - \(cell.desc)")
                    
                    UIView.animate(withDuration: 0.2,
                                               animations: { () -> Void in
                                                self.selectQuantity!.closeAction()
                    },
                                               completion: { (animated:Bool) -> Void in
                                                self.selectQuantity = nil
                                                //CAMBIA IMAGEN CARRO SELECCIONADO
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
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
        let frameDetail = CGRect(x:0,y:0, width:self.view.frame.width,height:self.view.frame.height)
        self.buildMGSelectQuantityView(cell: cell, viewFrame: frameDetail)
        self.view.addSubview(selectQuantity)
    }
    
    func buildParamsUpdateShoppingCart(cell:SearchProductCollectionViewCell,quantity:String,position:String) -> [String:Any] {
        let pesable = cell.pesable! ? "1" : "0"
        let searchText = self.textToSearch ?? ""
        let channel = IS_IPAD ? "ipad" : "iphone"
        //Add skuId
        if cell.type == ResultObjectType.Groceries.rawValue {
            if searchText != ""{
                return ["upc":cell.upc as AnyObject,"skuId":cell.skuId as AnyObject,"desc":cell.desc as AnyObject,"imgUrl":cell.imageURL as AnyObject,"price":cell.price as AnyObject,"quantity":quantity as AnyObject,"comments":"" as AnyObject,"onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable,"parameter":["q":searchText,"eventtype": "addtocart","collection":"dah","channel": channel,"position":position]]
            }
            return ["upc":cell.upc as AnyObject,"skuId":cell.skuId as AnyObject,"desc":cell.desc as AnyObject,"imgUrl":cell.imageURL as AnyObject,"price":cell.price as AnyObject,"quantity":quantity as AnyObject,"comments":"" as AnyObject,"onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable]
        }
        else {
            
            if searchText != ""{
                return ["upc":cell.upc as AnyObject,"skuId":cell.skuId as AnyObject,"desc":cell.desc as AnyObject,"imgUrl":cell.imageURL as AnyObject,"price":cell.price as AnyObject,"quantity":quantity as AnyObject,"onHandInventory":cell.onHandInventory,"wishlist":false as AnyObject,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":cell.isPreorderable,"category": cell.productDeparment,"parameter":["q":searchText,"eventtype": "addtocart","collection":"mg","channel": channel,"position":position]]
            }
            return ["upc":cell.upc as AnyObject,"skuId":cell.skuId as AnyObject,"desc":cell.desc as AnyObject,"imgUrl":cell.imageURL as AnyObject,"price":cell.price as AnyObject,"quantity":quantity as AnyObject,"onHandInventory":cell.onHandInventory,"wishlist":false as AnyObject,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":cell.isPreorderable,"category": cell.productDeparment]
        }
    }
    
    //reload after update
    func afterAddToSC() {
        self.collection?.reloadData()
    }
    
    var invokeServiceUpc =  false
    
    func invokeSearchUPCSCMG() {
        if (self.findUpcsMg?.count)! > 0 {
            self.filterButton?.alpha = 0
            let serviceUPC = SearchItemsByUPCService()
            serviceUPC.callService(self.findUpcsMg!, successJSONBlock: { (result:JSON) -> Void in
                //self.itemsUPCMG = result.arrayObject
                let upcs : [[String:Any]] = result.arrayObject! as! [[String:Any]]
                if upcs.count > 0 {
                    self.allProducts!.append(contentsOf: upcs)
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
        service.callService(service.buildParams(idList: self.idListFromSearch!, upcs: [productObject]) as [String:Any],
                            successBlock: { (result:[String:Any]) -> Void in
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
