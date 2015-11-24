 //
//  ProductViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 29/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

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
    case WithRemomendedLine
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
    var allProducts: NSMutableArray? = []
    var upcsToShow : [String]? = []
    var upcsToShowApply : [String]? = []
    
    var titleHeader: String?
    var originalSort: String?
    var originalSearchContextType: SearchServiceContextType?
    var searchContextType: SearchServiceContextType?
    var textToSearch:String?
    var idDepartment:String?
    var idFamily :String?
    var idLine:String?
    var idSort:String?
    var maxResult: Int = 20
    var brandText: String? = ""
    
    var viewBgSelectorBtn : UIView!
    var btnSuper : UIButton!
    var btnTech : UIButton!
    var facet : [[String:AnyObject]]!
    var facetGr : NSArray? = nil
    
    var controllerFilter : FilterProductsViewController!
    
    var firstOpen  = true
    
    var itemsUPCMG: NSArray? = []
    var itemsUPCGR: NSArray? = []
    var itemsUPCMGBk: NSArray? = []
    var itemsUPCGRBk: NSArray? = []
    
   
    
    var selectQuantityGR : GRShoppingCartQuantitySelectorView!
    var selectQuantity : ShoppingCartQuantitySelectorView!
    var isTextSearch: Bool = false

    
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
        
        
        let iconImage = UIImage(color: WMColor.light_blue, size: CGSizeMake(55, 22), radius: 11) // UIImage(named:"button_bg")
        let iconSelected = UIImage(color: WMColor.regular_blue, size: CGSizeMake(55, 22), radius: 11)
        
        self.filterButton = UIButton()
        self.filterButton!.setImage(iconImage, forState: .Normal)
        self.filterButton!.setImage(iconSelected, forState: .Highlighted)
        self.filterButton!.addTarget(self, action: "filter:", forControlEvents: .TouchUpInside)
        self.filterButton!.tintColor = WMColor.navigationFilterTextColor
        self.filterButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        self.filterButton!.setTitle(NSLocalizedString("filter.button.title", comment:"" ) , forState: .Normal)
        self.filterButton!.setTitleColor(WMColor.navigationFilterTextColor, forState: .Normal)
        
        self.filterButton!.titleEdgeInsets = UIEdgeInsetsMake(2.0, -iconImage!.size.width, 0, 0.0);
        self.filterButton!.imageEdgeInsets = UIEdgeInsetsMake(0, (80 - iconImage!.size.width) / 2 , 0.0, 0.0)
        self.header?.addSubview(self.filterButton!)
        
        
        viewBgSelectorBtn = UIView(frame: CGRectMake(16,  self.header!.frame.maxY + 16, 288, 28))
        viewBgSelectorBtn.layer.borderWidth = 1
        viewBgSelectorBtn.layer.cornerRadius = 14
        viewBgSelectorBtn.layer.borderColor = WMColor.addressSelectorColor.CGColor
        
        let titleSupper = NSLocalizedString("profile.address.super",comment:"")
        btnSuper = UIButton(frame: CGRectMake(1, 1, (viewBgSelectorBtn.frame.width / 2) , viewBgSelectorBtn.frame.height - 2))
        btnSuper.setImage(UIImage(color: UIColor.whiteColor(), size: btnSuper.frame.size), forState: UIControlState.Normal)
        btnSuper.setImage(UIImage(color: WMColor.addressSelectorColor, size: btnSuper.frame.size), forState: UIControlState.Selected)
        btnSuper.setTitle(titleSupper, forState: UIControlState.Normal)
        btnSuper.setTitle(titleSupper, forState: UIControlState.Selected)
        btnSuper.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btnSuper.setTitleColor(WMColor.addressSelectorColor, forState: UIControlState.Normal)
        btnSuper.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnSuper.selected = true
        btnSuper.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnSuper.frame.size.width + 1, 0, 0.0);
        btnSuper.addTarget(self, action: "changeSuperTech:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let titleTech = NSLocalizedString("profile.address.tech",comment:"")
        btnTech = UIButton(frame: CGRectMake(btnSuper.frame.maxX, 1, viewBgSelectorBtn.frame.width / 2, viewBgSelectorBtn.frame.height - 2))
        btnTech.setImage(UIImage(color: UIColor.whiteColor(), size: btnSuper.frame.size), forState: UIControlState.Normal)
        btnTech.setImage(UIImage(color: WMColor.addressSelectorColor, size: btnSuper.frame.size), forState: UIControlState.Selected)
        btnTech.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btnTech.setTitleColor(WMColor.addressSelectorColor, forState: UIControlState.Normal)
        btnTech.setTitle(titleTech, forState: UIControlState.Normal)
        btnTech.setTitle(titleTech, forState: UIControlState.Selected)
        btnTech.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnTech.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnSuper.frame.size.width , 0, 0.0);
        btnTech.addTarget(self, action: "changeSuperTech:", forControlEvents: UIControlEvents.TouchUpInside)
        
        viewBgSelectorBtn.clipsToBounds = true
        viewBgSelectorBtn.backgroundColor = UIColor.whiteColor()
        viewBgSelectorBtn.addSubview(btnSuper)
        viewBgSelectorBtn.addSubview(btnTech)
        
        self.view.addSubview(viewBgSelectorBtn)
        
        self.view.addSubview(collection!)
        self.titleLabel?.text = titleHeader
        
        self.getServiceProduct(resetTable: false)
        if  self.searchContextType == .WithCategoryForGR {
            self.getFacet(self.idDepartment!,textSearch:self.textToSearch,idFamily:self.idFamily)
        }
    }
    
    func setTitleWithEdit() -> UILabel {
        
        let titleLabel = UILabel()
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
        titleLabel.numberOfLines = 2;
        titleLabel.attributedText = myString;
        titleLabel.userInteractionEnabled = true;
        titleLabel.textColor =  WMColor.navigationTilteTextColor
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .Center
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "editSearch")
        titleLabel.addGestureRecognizer(tapGesture)
        
        return titleLabel
        
    }
    
    func editSearch(){
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.EditSearch.rawValue, object: titleHeader!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.header?.addSubview(self.filterButton!)
        self.view.addSubview(collection!)
        self.isTextSearch = (self.searchContextType == SearchServiceContextType.WithText || self.searchContextType == SearchServiceContextType.WithTextForCamFind)
        let isOriginalTextSearch = self.originalSearchContextType == SearchServiceContextType.WithText || self.originalSearchContextType == SearchServiceContextType.WithTextForCamFind
        
        if self.isTextSearch || isOriginalTextSearch
        {
            if self.titleLabel != nil {
                self.titleLabel?.removeFromSuperview()
            }
                self.titleLabel = self.setTitleWithEdit()
                self.header?.addSubview(self.titleLabel!)
            
             self.originalSearchContextType = self.searchContextType
            //self.searchContextType = SearchServiceContextType.WithCategoryForGR
        }
        else
        {
            self.titleLabel?.text = titleHeader
        }
        
        
        if loading == nil {
            self.loading = WMLoadingView(frame: CGRectMake(11, 11, self.view.bounds.width, self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadUISearch", name: CustomBarNotification.ReloadWishList.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        
        
    }
    
    func reloadUISearch() {
        self.collection!.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        var startPoint = self.header!.frame.maxY
        if self.isTextSearch {
            viewBgSelectorBtn.frame =  CGRectMake(16,  self.header!.frame.maxY + 16, 288, 28)
            startPoint = viewBgSelectorBtn.frame.maxY + 16
        }else {
            viewBgSelectorBtn.alpha = 0
        }
        
        
        
        //TODO MAke Search only one resultset
        contentCollectionOffset = CGPointZero
        self.collection!.frame = CGRectMake(0, startPoint, self.view.bounds.width, self.view.bounds.height - startPoint)
        self.titleLabel!.frame = CGRectMake(self.filterButton!.frame.width , 0, self.view.bounds.width - (self.filterButton!.frame.width * 2), self.header!.frame.maxY)
        self.filterButton!.frame = CGRectMake(self.view.bounds.maxX - 87, 0 , 87, 46)
        self.loading!.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        
        //println("View bounds: \(self.view.bounds)")
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
        
        var size = 0
        if let count = self.allProducts?.count {
            var commonTotal = 0
            if self.btnSuper.selected {
                commonTotal =  (self.grResults!.totalResults == -1 ? 0:self.grResults!.totalResults)
                if count == commonTotal {
                    return count
                }
            } else {
                commonTotal = (self.mgResults!.totalResults == -1 ? 0:self.mgResults!.totalResults)
                if count == commonTotal {
                    return count
                }
            }
            size = (count  >= commonTotal) ? commonTotal : count + 1
            
        }
        return size
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //Show loading cell and invoke service
        var commonTotal = 0
        if self.btnSuper.selected {
            commonTotal =  (self.grResults!.totalResults == -1 ? 0:self.grResults!.totalResults)
        } else {
            commonTotal = (self.mgResults!.totalResults == -1 ? 0:self.mgResults!.totalResults)
        }
        if indexPath.row == self.allProducts?.count && self.allProducts?.count <= commonTotal  {
            let loadCell = collectionView.dequeueReusableCellWithReuseIdentifier("loadCell", forIndexPath: indexPath)
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
        let description = item["description"] as? String
        
        var price: NSString?
        var through: NSString! = ""
        if let priceTxt = item["price"] as? NSString {
            price = priceTxt
        }
        else if let pricenum = item["price"] as? NSNumber {
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
        
        var onHandDefault = 10
        if let onHandInventory = item["onHandInventory"] as? NSString {
            onHandDefault = onHandInventory.integerValue
        }
        
        let type = item["type"] as! NSString
        
        var isPesable = false
        if let pesable = item["pesable"] as?  NSString {
            isPesable = pesable.intValue == 1
        }
        
        
        cell.setValues(upc,
            productImageURL: imageUrl!,
            productShortDescription: description!,
            productPrice: price! as String,
            productPriceThrough: through! as String,
            isActive: isActive,
            onHandInventory: onHandDefault,
            isPreorderable:isPreorderable,
            isInShoppingCart: UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc),
            type:type as String,
            pesable : isPesable
        )
        cell.delegate = self
        return cell
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = CGSizeMake(self.view.bounds.maxX/2, 190)
        let commonTotal = self.mgResults!.totalResults + self.grResults!.totalResults
        if indexPath.row == self.allProducts!.count && self.allProducts!.count < commonTotal {
            size = CGSizeMake(self.view.bounds.maxX, 80)
        }
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < self.allProducts!.count {
            let controller = ProductDetailPageViewController()
            var productsToShow : [[String:String]] = []
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
            controller.itemsToShow = productsToShow
            controller.ixSelected = indexPath.row
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
                self.invokeSearchUPCMG { () -> Void in
                    switch self.searchContextType! {
                    case .WithCategoryForMG :
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

                    case .WithCategoryForGR :
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
                                self.invokeSearchproductsInMG(actionSuccess: sucessBlock, actionError: errorBlock)
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
    
    func invokeSearchUPCGroceries(actionSuccess actionSuccess:(() -> Void)?) {
        if self.upcsToShow?.count > 0 {
            let serviceUPC = GRProductsByUPCService()
            serviceUPC.callService(requestParams: serviceUPC.buildParamServiceUpcs(self.upcsToShow!), successBlock: { (result:NSDictionary) -> Void in
                if result["items"] != nil {
                 self.itemsUPCGR = result["items"] as! NSArray
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
    
    func invokeSearchUPCMG(actionSuccess actionSuccess:(() -> Void)?) {
        if self.upcsToShow?.count > 0 {
            let serviceUPC = SearchItemsByUPCService()
            serviceUPC.callService(self.upcsToShow!, successJSONBlock: { (result:JSON) -> Void in
                self.itemsUPCMG = result.arrayObject
                actionSuccess?()
                }) { (error:NSError) -> Void in
                    actionSuccess?()
            }
        } else {
            actionSuccess?()
        }
    }
    
    
    func invokeSearchproductsInMG(actionSuccess actionSuccess:(() -> Void)?, actionError:(() -> Void)?) {
        
        if self.mgResults!.totalResults != -1 && self.mgResults!.resultsInResponse >= self.mgResults!.totalResults {
            print("MG Search IS COMPLETE!!!")
            self.mgResults!.totalResults = self.allProducts!.count
            self.mgResults!.resultsInResponse = self.mgResults!.totalResults
            actionSuccess?()
            return
        }
        
        print("Invoking MG Search")
        let startOffSet = self.mgResults!.resultsInResponse
        
        
        
        let service = ProductbySearchService()
        let params = service.buildParamsForSearch(text: self.textToSearch, family: self.idFamily, line: self.idLine, sort: self.idSort, departament: self.idDepartment, start: startOffSet, maxResult: self.maxResult)
        service.callService(params,
            successBlock:{ (arrayProduct:NSArray?,facet:NSArray) in
                if arrayProduct != nil && arrayProduct!.count > 0 {
                    if let item = arrayProduct?[0] as? NSDictionary {
                        //println(item)
                        if let results = item["resultsInResponse"] as? NSString {
                            self.mgResults!.resultsInResponse += results.integerValue
                        }
                        if let total = item["totalResults"] as? NSString {
                            self.mgResults!.totalResults = total.integerValue
                        }
                    }
                    self.mgResults!.addResults(arrayProduct!)
                    if var sortFacet = facet as? [[String:AnyObject]] {
                        sortFacet.sortInPlace { (item, seconditem) -> Bool in
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
                    }
                    
                    //                    if self.allProducts != nil {
                    //                        self.allProducts = self.allProducts!.arrayByAddingObjectsFromArray(arrayProduct!)
                    //                    }
                    //                    else {
                    //                        self.allProducts = arrayProduct
                    //                    }
                }
                else {
                    self.mgResults!.resultsInResponse = 0
                    if self.mgResults!.products == nil {
                        self.mgResults!.totalResults = 0
                    }
                }
                
                actionSuccess?()
                
            }, errorBlock: {(error: NSError) in
                self.mgResults!.resultsInResponse = 0
                self.mgResults!.totalResults = 0
                print(error)
                actionError?()
            }
        )
    }
    
    func invokeSearchProductsInGroceries(actionSuccess actionSuccess:(() -> Void)?, actionError:(() -> Void)?) {
        
        if self.grResults!.totalResults != -1 && self.grResults!.resultsInResponse >= self.grResults!.totalResults {
            print("Groceries Search IS COMPLETE!!!")
            actionSuccess?()
            return
        }
        
        print("Invoking Groceries Search")
        var startOffSet = self.grResults!.resultsInResponse
        if startOffSet > 0 {
            startOffSet++
        }
        
        let service = GRProductBySearchService()//TODO Agregar rating al idSort
        let params = service.buildParamsForSearch(text: self.textToSearch, family: self.idFamily, line: self.idLine, sort: self.idSort == "" ? "" : self.idSort , departament: self.idDepartment, start: startOffSet, maxResult: self.maxResult,brand:self.brandText)
        service.callService(params,
            successBlock: { (arrayProduct:NSArray?) -> Void in
                if arrayProduct != nil && arrayProduct!.count > 0 {
                    if let item = arrayProduct?[0] as? NSDictionary {
                        //println(item)
                        if let results = item["resultsInResponse"] as? NSString {
                            self.grResults!.resultsInResponse += results.integerValue
                        }
                        if let total = item["totalResults"] as? NSString {
                            self.grResults!.totalResults = total.integerValue
                        }
                    }
                    self.grResults!.addResults(arrayProduct!)
                    
                    //                    if self.allProducts != nil {
                    //                        self.allProducts = self.allProducts!.arrayByAddingObjectsFromArray(arrayProduct!)
                    //                    }
                    //                    else {
                    //                        self.allProducts = arrayProduct
                    //                    }
                }
                else {
                    self.grResults!.resultsInResponse = 0
                    self.grResults!.totalResults = 0
                }
                
                actionSuccess?()
            }, errorBlock: {(error: NSError) in
                print(error)
                //No se encontraron resultados para la búsqueda
                if error.code == 1 {
                    self.grResults!.resultsInResponse = 0
                    self.grResults!.totalResults = 0
                }
                actionError?()
            }
        )
    }
    
    func updateViewAfterInvokeService(resetTable resetTable:Bool) {
        
        if  self.searchContextType == .WithCategoryForGR {
            if self.idDepartment !=  nil {
                self.getFacet(self.idDepartment!,textSearch:self.textToSearch,idFamily:self.idFamily)
            }
        }
        
        if btnSuper.selected   {
            if firstOpen && (self.grResults!.products == nil || self.grResults!.products!.count == 0 ) {
                btnTech.selected = true
                btnSuper.selected = false
                self.allProducts = []
                if self.mgResults?.products != nil {
                    if self.itemsUPCMG?.count > 0 {
                        self.allProducts?.addObjectsFromArray(self.itemsUPCMG as! [AnyObject])
                        var filtredProducts : [AnyObject] = []
                        for product in self.mgResults!.products! {
                            let productDict = product as! [String:AnyObject]
                            if let productUPC =  productDict["upc"] as? String {
                                if !self.itemsUPCMG!.containsObject(productUPC) {
                                    filtredProducts.append(productDict)
                                }
                            }
                        }
                        self.allProducts?.addObjectsFromArray(filtredProducts)
                    } else {
                        if self.mgResults!.products != nil{
                            self.allProducts?.addObjectsFromArray(self.mgResults!.products as! [AnyObject])
                        }
                    }
                }
                firstOpen = false
            } else {
                btnTech.selected = false
                btnSuper.selected = true
                self.allProducts = []
                if self.grResults?.products != nil {
                    if self.itemsUPCGR?.count > 0 {
                        self.allProducts?.addObjectsFromArray(self.itemsUPCGR as! [AnyObject])
                        var filtredProducts : [AnyObject] = []
                            for product in self.grResults!.products! {
                                let productDict = product as! [String:AnyObject]
                                if let productUPC =  productDict["upc"] as? String {
                                    if !self.itemsUPCGR!.containsObject(productUPC) {
                                        filtredProducts.append(productDict)
                                    }
                                }
                            }
                        
                        self.allProducts?.addObjectsFromArray(filtredProducts)
                    } else {
                        self.allProducts?.addObjectsFromArray(self.grResults!.products as! [AnyObject])
                    }
                }
            }
        } else {
            btnTech.selected = true
            btnSuper.selected = false
            self.allProducts = []
            if self.mgResults?.products != nil {
                if self.itemsUPCMG?.count > 0 {
                    self.allProducts?.addObjectsFromArray(self.itemsUPCMG as! [AnyObject])
                    var filtredProducts : [AnyObject] = []
                    for product in self.mgResults!.products! {
                        let productDict = product as! [String:AnyObject]
                        if let productUPC =  productDict["upc"] as? String {
                            if !self.itemsUPCMG!.containsObject(productUPC) {
                                filtredProducts.append(productDict)
                            }
                        }
                    }
                    self.allProducts?.addObjectsFromArray(filtredProducts)
                } else {
                    self.allProducts?.addObjectsFromArray(self.mgResults!.products as! [AnyObject])
                }
            }
        }
        
        self.showLoadingIfNeeded(true)
        if (self.allProducts == nil || self.allProducts!.count == 0) && self.isTextSearch {
            
            //self.titleLabel?.text = NSLocalizedString("empty.productdetail.title",comment:"")
            self.filterButton?.alpha = 0
            //self.empty = IPOGenericEmptyView(frame:self.collection!.frame)
            let maxY =  self.viewBgSelectorBtn.frame.maxY + 16.0
            if self.emptyMGGR == nil {
                self.emptyMGGR = IPOSearchResultEmptyView(frame:CGRectMake(0, maxY, self.view.bounds.width, self.view.bounds.height - maxY))
                self.emptyMGGR.returnAction = { () in
                    self.returnBack()
                }
                
                
                
            }
            if btnSuper.selected {
                self.emptyMGGR.descLabel.text = "No existe ese artículo en Súper"
            } else {
                self.emptyMGGR.descLabel.text = "No existe ese artículo en Tecnología, Hogar y más"
            }
            
            self.view.addSubview(self.emptyMGGR)
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
        } else if self.allProducts == nil || self.allProducts!.count == 0 {
            //self.titleLabel?.text = NSLocalizedString("empty.productdetail.title",comment:"")
            self.filterButton?.alpha = 0
            //self.empty = IPOGenericEmptyView(frame:self.collection!.frame)
            
            self.empty = IPOGenericEmptyView(frame:CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
            
            self.empty.returnAction = { () in
                self.returnBack()
            }
            
            self.view.addSubview(self.empty)
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
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
            if self.empty != nil {
                self.empty.removeFromSuperview()
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
    
    //MARK: - Actions
    
    func returnBack() {
        self.navigationController!.popViewControllerAnimated(true)
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
        if controllerFilter == nil {
            controllerFilter = FilterProductsViewController()
            controllerFilter.facet = self.facet
            controllerFilter.textToSearch = self.textToSearch
            controllerFilter.selectedOrder = self.idSort!//self.idSort! == "" ? "rating" :self.idSort!
            controllerFilter.isGroceriesSearch = self.btnSuper.selected
            controllerFilter.delegate = self
            controllerFilter.originalSearchContext = self.originalSearchContextType == nil ? self.searchContextType : self.originalSearchContextType
            //controllerFilter.searchContext = self.searchContextType
            controllerFilter?.facetGr = self.facetGr
            
        }
        controllerFilter.isGroceriesSearch = self.btnSuper.selected
        controllerFilter.searchContext = self.searchContextType
        self.navigationController?.pushViewController(controllerFilter, animated: true)
    }
    
    func getFacet(idDepartament:String,textSearch:String?,idFamily:String?){
        let serviceFacet = GRFacets()
        
        serviceFacet.callService(idDepartament,stringSearch:textSearch == nil ? "" : textSearch!,idFamily: idFamily == nil ? "" : idFamily!,idLine:self.idLine!,
            successBlock: { (result:NSDictionary) -> Void in
                let arrayCall = result["brands"] as! NSArray
                
                self.facetGr = arrayCall
                print(result)
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at invoke payment type service")
                
            }
        )
        
        
    }
    
    //MARK: - FilterProductsViewControllerDelegate
    
    func apply(order:String, filters:[String:AnyObject]?, isForGroceries flag:Bool) {
        
        //Clean upcs
       
        
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
                self.itemsUPCMGBk = self.itemsUPCMG
                self.itemsUPCGRBk = self.itemsUPCGR
                self.itemsUPCMG = []
                self.itemsUPCGR = []
                self.upcsToShow = []
            }
            
        } else {
            
            self.itemsUPCMG = self.itemsUPCMGBk
            self.itemsUPCGR = self.itemsUPCGRBk
            self.upcsToShow = self.upcsToShowApply
            self.upcsToShowApply = []
        }

        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_APPLY_FILTER.rawValue, label: "\(self.idDepartment)-\(self.idFamily)-\(self.idLine)-\(order)-")
        
        self.allProducts = []
        self.mgResults!.resetResult()
        self.grResults!.resetResult()
        
        self.showLoadingIfNeeded(false)
        self.getServiceProduct(resetTable: true)
    }
    
    func sendBrandFilter(brandFilter: String) {
        self.brandText = brandFilter
        
    }
    
    func apply(order:String, upcs: [String]) {
        self.collection?.alpha = 100
        if upcs.count == 0 {
            self.allProducts = []
            self.mgResults?.totalResults = 0
            self.collection?.reloadData()
            self.collection?.alpha = 0
            if self.empty == nil {
                self.viewBgSelectorBtn.alpha = 0
                self.empty = IPOGenericEmptyView(frame:CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
                self.empty.returnAction = { () in
                    self.viewBgSelectorBtn.alpha = 1
                    self.returnBack()
                }
            }
            self.view.addSubview(self.empty)
            self.empty.descLabel.text = NSLocalizedString("empty.productdetail.recent", comment: "")
            
            return
        } else {
            if self.empty != nil {
                self.empty.removeFromSuperview()
                self.empty = nil
            }
        }
        
        self.showLoadingIfNeeded(false)
        let svcSearch = SearchItemsByUPCService()
        svcSearch.callService(upcs, successJSONBlock: { (result:JSON) -> Void in
            self.allProducts?.addObjectsFromArray(result.arrayObject!)
            self.mgResults?.totalResults = self.allProducts!.count
            
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
    func changeSuperTech(sender:UIButton) {
        self.collection?.contentOffset = CGPointZero
        if sender == btnSuper &&  !sender.selected {
            sender.selected = true
            btnTech.selected = false
            self.allProducts = nil
            updateViewAfterInvokeService(resetTable:true)
            self.searchContextType = SearchServiceContextType.WithCategoryForGR
        } else if sender == btnTech &&  !sender.selected {
            sender.selected = true
            btnSuper.selected = false
            self.allProducts = nil
            updateViewAfterInvokeService(resetTable:true)
            self.searchContextType = SearchServiceContextType.WithCategoryForMG
        }
        
    }
    
    //MARK: SearchProductCollectionViewCellDelegate
    
    func buildGRSelectQuantityView(cell: SearchProductCollectionViewCell, viewFrame: CGRect){
        var prodQuantity = "1"
        if cell.pesable! {
            prodQuantity = "50"
            selectQuantityGR = GRShoppingCartWeightSelectorView(frame:viewFrame,priceProduct:NSNumber(double:(cell.price as NSString).doubleValue),quantity:Int(prodQuantity),equivalenceByPiece:0.0,upcProduct:cell.upc)
            
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
                let params = self.buildParamsUpdateShoppingCart(cell,quantity: quantity)
                
                //CAMBIA IMAGEN CARRO SELECCIONADO
                cell.addProductToShopingCart!.setImage(UIImage(named: "products_done"), forState: UIControlState.Normal)
                
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
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
        
        selectQuantityGR?.addUpdateNote = {() in
            let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
            let frame = vc!.view.frame
            
            
            let addShopping = ShoppingCartUpdateController()
            let paramsToSC = self.buildParamsUpdateShoppingCart(cell,quantity: prodQuantity)
            addShopping.params = paramsToSC
            vc!.addChildViewController(addShopping)
            addShopping.view.frame = frame
            vc!.view.addSubview(addShopping.view)
            addShopping.didMoveToParentViewController(vc!)
            addShopping.typeProduct = ResultObjectType.Groceries
            addShopping.goToShoppingCart = {() in }
            addShopping.removeSpinner()
            addShopping.addActionButtons()
            addShopping.addNoteToProduct(nil)
            
        }
        selectQuantityGR?.userSelectValue(prodQuantity)
        selectQuantityGR?.first = true
        selectQuantityGR?.showNoteButtonComplete()
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
        
        //Event
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_KEYBOARD.rawValue, label: "\(cell.desc) - \(cell.upc)")
        
        selectQuantity!.addToCartAction =
            { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                if cell.onHandInventory.integerValue >= Int(quantity) {
                    let params = self.buildParamsUpdateShoppingCart(cell,quantity: quantity)
                    BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label:"\(cell.upc) - \(cell.desc)")
                    
                    UIView.animateWithDuration(0.2,
                        animations: { () -> Void in
                            self.selectQuantity!.closeAction()
                        },
                        completion: { (animated:Bool) -> Void in
                            self.selectQuantity = nil
                            //CAMBIA IMAGEN CARRO SELECCIONADO
                            cell.addProductToShopingCart!.setImage(UIImage(named: "products_done"), forState: UIControlState.Normal)
                            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
                        }
                    )
                }
                else {
                    let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                    
                    let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                    let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                    let msgInventory = "\(firstMessage)\(cell.onHandInventory) \(secondMessage)"
                    alert!.setMessage(msgInventory)
                    alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                }
        }
    }
    
    func selectMGQuantityForItem(cell: SearchProductCollectionViewCell) {
        let frameDetail = CGRectMake(0,0, self.view.frame.width,self.view.frame.height)
        self.buildMGSelectQuantityView(cell, viewFrame: frameDetail)
        self.view.addSubview(selectQuantity)
    }
    
    func buildParamsUpdateShoppingCart(cell:SearchProductCollectionViewCell,quantity:String) -> [String:AnyObject] {
        let pesable = cell.pesable! ? "1" : "0"
        
        if cell.type == ResultObjectType.Groceries.rawValue {
           return ["upc":cell.upc,"desc":cell.desc,"imgUrl":cell.imageURL,"price":cell.price,"quantity":quantity,"comments":"","onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable]
        }
        else {
            return ["upc":cell.upc,"desc":cell.desc,"imgUrl":cell.imageURL,"price":cell.price,"quantity":quantity,"onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":cell.isPreorderable]
        }
    }
}
