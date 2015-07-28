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
            self.products = self.products!.arrayByAddingObjectsFromArray(otherProducts)
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
}

class SearchProductViewController: NavigationViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FilterProductsViewControllerDelegate {

    var contentCollectionOffset: CGPoint?
    var collection: UICollectionView?
    var loading: WMLoadingView?
    var filterButton: UIButton?
    var empty: IPOGenericEmptyView!
    var emptyMGGR: IPOSearchResultEmptyView!

    lazy var mgResults: SearchResult? = SearchResult()
    lazy var grResults: SearchResult? = SearchResult()
    var allProducts: NSArray? = []
    
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
    
    var viewBgSelectorBtn : UIView!
    var btnSuper : UIButton!
    var btnTech : UIButton!
    var facet : [[String:AnyObject]]!
    
    var controllerFilter : FilterProductsViewController!
    
    var firstOpen  = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        if self.searchContextType != nil {
            switch self.searchContextType! {
            case .WithCategoryForMG :
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.set(kGAIScreenName, value: WMGAIUtils.MG_SCREEN_CATEGORY.rawValue)
                    tracker.send(GAIDictionaryBuilder.createScreenView().build())
                }
            case .WithCategoryForGR :
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.set(kGAIScreenName, value: WMGAIUtils.GR_SCREEN_CATEGORY.rawValue)
                    tracker.send(GAIDictionaryBuilder.createScreenView().build())
                }
            default :
                break
            }
        }
        
        collection = getCollectionView()
        collection?.registerClass(SearchProductCollectionViewCell.self, forCellWithReuseIdentifier: "productSearch")
        collection?.registerClass(LoadingProductCollectionViewCell.self, forCellWithReuseIdentifier: "loadCell")
        collection!.dataSource = self
        collection!.delegate = self
        
        collection!.backgroundColor = UIColor.whiteColor()
        self.idSort =  FilterType.none.rawValue
        
        let iconImage = UIImage(color: WMColor.light_blue, size: CGSizeMake(55, 22), radius: 11) // UIImage(named:"button_bg")
        let iconSelected = UIImage(color: WMColor.regular_blue
            
            , size: CGSizeMake(55, 22), radius: 11)
        
        
        
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
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.header?.addSubview(self.filterButton!)
        
        self.view.addSubview(collection!)
        self.titleLabel?.text = titleHeader
        
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
        if self.searchContextType == SearchServiceContextType.WithText {
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
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        if indexPath.row == self.allProducts!.count && self.allProducts!.count <= commonTotal  {
            let loadCell = collectionView.dequeueReusableCellWithReuseIdentifier("loadCell", forIndexPath: indexPath) as UICollectionViewCell
            self.getServiceProduct(resetTable: false) //Invoke service
            return loadCell
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(productCellIdentifier(), forIndexPath: indexPath) as SearchProductCollectionViewCell
        if self.allProducts?.count <= indexPath.item {
            return cell
        }
        let item = self.allProducts![indexPath.item] as NSDictionary
        
        let upc = item["upc"] as String
        let description = item["description"] as? String
        
        var price: NSString?
        var through: NSString! = ""
        if let priceTxt = item["price"] as? NSString {
            price = priceTxt
        }
        else if let pricenum = item["price"] as? NSNumber {
            var txt = pricenum.stringValue
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
        
        let type = item["type"] as NSString
        
        var isPesable = false
        if let pesable = item["pesable"] as?  NSString {
            isPesable = pesable.intValue == 1
        }

      
        cell.setValues(upc,
            productImageURL: imageUrl!,
            productShortDescription: description!,
            productPrice: price!,
            productPriceThrough: through!,
            isActive: isActive,
            onHandInventory: onHandDefault,
            isPreorderable:isPreorderable,
            isInShoppingCart: UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc),
            type:type,
            pesable : isPesable
        )
        
        return cell
    }
    

    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        var size = CGSizeMake(self.view.bounds.maxX/2, 190)
        var commonTotal = self.mgResults!.totalResults + self.grResults!.totalResults
        if indexPath.row == self.allProducts!.count && self.allProducts!.count < commonTotal {
            size = CGSizeMake(self.view.bounds.maxX, 80)
        }
        return size
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        if indexPath.row < self.allProducts!.count {
            let controller = ProductDetailPageViewController()
            var productsToShow : [[String:String]] = []
            for strUPC in self.allProducts! {
                let upc = strUPC["upc"] as NSString
                let description = strUPC["description"] as NSString
                let type = strUPC["type"] as NSString
                var through = ""
                if let priceThr = strUPC["saving"] as? NSString {
                    through = priceThr
                }
                productsToShow.append(["upc":upc, "description":description, "type":type,"saving":through])
            }
            controller.itemsToShow = productsToShow
            controller.ixSelected = indexPath.row
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    //MARK: - Services
    
    func getServiceProduct(#resetTable:Bool) {
        self.filterButton?.alpha = 0
        self.contentCollectionOffset = self.collection?.contentOffset
        
        var sucessBlock = { () -> Void in self.updateViewAfterInvokeService(resetTable:resetTable) }
        var errorBlock = { () -> Void in self.updateViewAfterInvokeService(resetTable:resetTable) }
        
        if self.searchContextType != nil {
            switch self.searchContextType! {
            case .WithCategoryForMG :
                println("Searching products for Category In MG")
                self.invokeSearchproductsInMG(actionSuccess: sucessBlock, actionError: errorBlock)
            case .WithCategoryForGR :
                println("Searching products for Category In Groceries")
                self.invokeSearchProductsInGroceries(actionSuccess: sucessBlock, actionError: errorBlock)
            default :
                println("Searching products for text")
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
        else {
            println("No existe contexto de busqueda. Es necesario indicar el contexto")
        }
        
    }
    
    func invokeSearchproductsInMG(#actionSuccess:(() -> Void)?, actionError:(() -> Void)?) {
        
        if self.mgResults!.totalResults != -1 && self.mgResults!.resultsInResponse >= self.mgResults!.totalResults {
            println("MG Search IS COMPLETE!!!")
            self.mgResults!.totalResults = self.allProducts!.count
            self.mgResults!.resultsInResponse = self.mgResults!.totalResults
            actionSuccess?()
            return
        }

        println("Invoking MG Search")
        var startOffSet = self.mgResults!.resultsInResponse
        
       
        
        var service = ProductbySearchService()
        var params = service.buildParamsForSearch(text: self.textToSearch, family: self.idFamily, line: self.idLine, sort: self.idSort, departament: self.idDepartment, start: startOffSet, maxResult: self.maxResult)
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
                        sortFacet.sort { (item, seconditem) -> Bool in
                            var firstOrder = "0"
                            if let firstOrderVal = item["order"] as? String {
                                firstOrder = firstOrderVal
                            }
                            var secondOrder = "0"
                            if let secondOrderVal = seconditem["order"] as? String {
                                secondOrder = secondOrderVal
                            }
                            return firstOrder.toInt() < secondOrder.toInt()
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
                println(error)
                actionError?()
            }
        )
    }
    
    func invokeSearchProductsInGroceries(#actionSuccess:(() -> Void)?, actionError:(() -> Void)?) {
        
        if self.grResults!.totalResults != -1 && self.grResults!.resultsInResponse >= self.grResults!.totalResults {
            println("Groceries Search IS COMPLETE!!!")
            actionSuccess?()
            return
        }
        
        println("Invoking Groceries Search")
        var startOffSet = self.grResults!.resultsInResponse
        if startOffSet > 0 {
            startOffSet++
        }
        
        var service = GRProductBySearchService()
        var params = service.buildParamsForSearch(text: self.textToSearch, family: self.idFamily, line: self.idLine, sort: self.idSort, departament: self.idDepartment, start: startOffSet, maxResult: self.maxResult)
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
                println(error)
                //No se encontraron resultados para la búsqueda
                if error.code == 1 {
                    self.grResults!.resultsInResponse = 0
                    self.grResults!.totalResults = 0
                }
                actionError?()
            }
        )
    }
    
    func updateViewAfterInvokeService(#resetTable:Bool) {
        
     
        if btnSuper.selected   {
            if firstOpen && (self.grResults!.products == nil || self.grResults!.products!.count == 0 ) {
                btnTech.selected = true
                btnSuper.selected = false
                self.allProducts = self.mgResults!.products
                firstOpen = false
            } else {
                btnTech.selected = false
                btnSuper.selected = true
                self.allProducts = self.grResults!.products
            }
        } else {
            btnTech.selected = true
            btnSuper.selected = false
            self.allProducts = self.mgResults!.products
        }
        
        self.showLoadingIfNeeded(true)
        if (self.allProducts == nil || self.allProducts!.count == 0) && self.searchContextType == SearchServiceContextType.WithText {
            
            //self.titleLabel?.text = NSLocalizedString("empty.productdetail.title",comment:"")
            self.filterButton?.alpha = 1
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
        } else if self.allProducts == nil || self.allProducts!.count == 0 {
            //self.titleLabel?.text = NSLocalizedString("empty.productdetail.title",comment:"")
            self.filterButton?.alpha = 1
            //self.empty = IPOGenericEmptyView(frame:self.collection!.frame)
            
            self.empty = IPOGenericEmptyView(frame:CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
            
            self.empty.returnAction = { () in
                self.returnBack()
            }
            
            self.view.addSubview(self.empty)
        }
        else {
            
            if self.searchContextType != nil && self.searchContextType == SearchServiceContextType.WithText && self.allProducts != nil {
                //println("sorting values from text search")
                //Order items
                switch (FilterType(rawValue: self.idSort!)!) {
                    case .descriptionAsc :
                        //println("descriptionAsc")
                        self.allProducts = self.allProducts!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "description", ascending: true)])
                    case .descriptionDesc :
                        //println("descriptionDesc")
                        self.allProducts = self.allProducts!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "description", ascending: false)])
                    case .priceAsc :
                        //println("priceAsc")
                        self.allProducts = self.allProducts!.sortedArrayUsingComparator({ (dictionary1:AnyObject!, dictionary2:AnyObject!) -> NSComparisonResult in
                            var priceOne:Double = self.priceValueFrom(dictionary1 as NSDictionary)
                            var priceTwo:Double = self.priceValueFrom(dictionary2 as NSDictionary)
                            
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
                    case .none : println("Not sorted")
                    default :
                        //println("priceDesc")
                        self.allProducts = self.allProducts!.sortedArrayUsingComparator({ (dictionary1:AnyObject!, dictionary2:AnyObject!) -> NSComparisonResult in
                            var priceOne:Double = self.priceValueFrom(dictionary1 as NSDictionary)
                            var priceTwo:Double = self.priceValueFrom(dictionary2 as NSDictionary)
                            
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
            self.collection?.reloadData()
             self.collection?.alpha = 1
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
            self.filterButton?.alpha = 1
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
        //if controllerFilter == nil {
            controllerFilter = FilterProductsViewController()
            controllerFilter.facet = self.facet
            controllerFilter.textToSearch = self.textToSearch
            controllerFilter.selectedOrder = self.idSort!
            controllerFilter.isGroceriesSearch = self.btnSuper.selected
            controllerFilter.delegate = self
            controllerFilter.originalSearchContext = self.originalSearchContextType == nil ? self.searchContextType : self.originalSearchContextType
            controllerFilter.searchContext = self.searchContextType
        //}
        self.navigationController?.pushViewController(controllerFilter, animated: true)
    }
    
    
    //MARK: - FilterProductsViewControllerDelegate
    
    func apply(order:String, filters:[String:AnyObject]?, isForGroceries flag:Bool) {
        
        
        self.filterButton!.alpha = 1
        if self.originalSort == nil {
            self.originalSort = self.idSort
        }
        if self.originalSearchContextType == nil {
            self.originalSearchContextType = self.searchContextType
        }
        self.idSort = order
     
        if filters != nil && self.originalSearchContextType != nil && self.originalSearchContextType! == SearchServiceContextType.WithText {
            self.idDepartment = filters![JSON_KEY_IDDEPARTMENT] as? String
            self.idFamily = filters![JSON_KEY_IDFAMILY] as? String
            self.idLine = filters![JSON_KEY_IDLINE] as? String
            self.searchContextType = flag ? .WithCategoryForGR : .WithCategoryForMG
        }
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_FILTER.rawValue, action: flag ? WMGAIUtils.GR_EVENT_FILTERDATA.rawValue : WMGAIUtils.MG_EVENT_FILTERDATA.rawValue, label: "\(self.idDepartment)-\(self.idFamily)-\(self.idLine)-\(order)-", value: nil).build())
        }
        
        self.allProducts = []
        self.mgResults!.resetResult()
        self.grResults!.resetResult()
        
        self.showLoadingIfNeeded(false)
        self.getServiceProduct(resetTable: true)
    }
    
    func apply(order:String, upcs: [String]) {
        self.collection?.alpha = 100
        if upcs.count == 0 {
            self.allProducts = []
            self.mgResults?.totalResults = 0
            self.collection?.reloadData()
            self.collection?.alpha = 0
            if self.empty == nil {
                self.empty = IPOGenericEmptyView(frame:CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
                self.empty.returnAction = { () in
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

        self.showLoadingIfNeeded(true)
        var svcSearch = SearchItemsByUPCService()
        svcSearch.callService(upcs, successJSONBlock: { (result:JSON) -> Void in
            self.allProducts = result.arrayObject
            self.mgResults?.totalResults = self.allProducts!.count
            
            switch (FilterType(rawValue: self.idSort!)!) {
            case .descriptionAsc :
                //println("descriptionAsc")
                self.allProducts = self.allProducts!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "description", ascending: true)])
            case .descriptionDesc :
                //println("descriptionDesc")
                self.allProducts = self.allProducts!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "description", ascending: false)])
            case .priceAsc :
                //println("priceAsc")
                self.allProducts = self.allProducts!.sortedArrayUsingComparator({ (dictionary1:AnyObject!, dictionary2:AnyObject!) -> NSComparisonResult in
                    var priceOne:Double = self.priceValueFrom(dictionary1 as NSDictionary)
                    var priceTwo:Double = self.priceValueFrom(dictionary2 as NSDictionary)
                    
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
            case .none : println("Not sorted")
            case .priceDesc :
                //println("priceDesc")
                self.allProducts = self.allProducts!.sortedArrayUsingComparator({ (dictionary1:AnyObject!, dictionary2:AnyObject!) -> NSComparisonResult in
                    var priceOne:Double = self.priceValueFrom(dictionary1 as NSDictionary)
                    var priceTwo:Double = self.priceValueFrom(dictionary2 as NSDictionary)
                    
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
                println("default")
            }
            
            
            
            self.collection?.reloadData()
            self.showLoadingIfNeeded(true)
            }) { (error:NSError) -> Void in
            println(error)
        }
    }
    
    func removeFilters() {
        
        self.idSort = self.originalSort
        self.searchContextType = self.originalSearchContextType
        if self.originalSearchContextType != nil && self.originalSearchContextType! == SearchServiceContextType.WithText {
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
        return UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    //MARK: Filter Super Tecnologia 
    func changeSuperTech(sender:UIButton) {
        if sender == btnSuper &&  !sender.selected {
            sender.selected = true
            btnTech.selected = false
            self.allProducts = nil
            updateViewAfterInvokeService(resetTable:true)
        } else if sender == btnTech &&  !sender.selected {
            sender.selected = true
            btnSuper.selected = false
            self.allProducts = nil
            updateViewAfterInvokeService(resetTable:true)
        }
        
    }
    
    
}
