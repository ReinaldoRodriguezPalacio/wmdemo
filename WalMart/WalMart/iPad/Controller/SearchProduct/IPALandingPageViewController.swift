//
//  IPALandingPageViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 07/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class IPALandingPageViewController: NavigationViewController, UIPopoverControllerDelegate, IPAFamilyViewControllerDelegate, IPASectionHeaderSearchReusableDelegate,SearchProductCollectionViewCellDelegate {
    
    var filterController: FilterProductsViewController?
    var sharePopover: UIPopoverController?
    var filterButton: UIButton?
    var idSort:String?
    var isOriginalTextSearch: Bool = false
    var originalSearchContextType: SearchServiceContextType?
    
    var selectQuantity : ShoppingCartQuantitySelectorView!
    
    var currentCellSelected : NSIndexPath!
    var isFirstLoad: Bool = true
    var urlImage: String?
    var imageBackground:UIImageView?
    var loading: WMLoadingView?
    var collection: UICollectionView?
    var titleHeader: String?
    var viewHeader: UIView?
    var allProducts: NSMutableArray? = []
    var departmentId: String?
    var headerView: UIView?
    var itemsCategory: [[String:AnyObject]]?
    var familyController : IPAFamilyViewController!
    var popover : UIPopoverController?
    let maxResult = 20
    var facet : [[String:AnyObject]]!
    
    var familySelected = ""
    var lineSelected = ""
    var nameSelected = ""
    var selectQuantityPopover:  UIPopoverController?
    var startOffSet = 0
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_LANDINGPAGE.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.idSort =  FilterType.rankingASC.rawValue
        
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
        titleLabel!.numberOfLines = 2
        titleLabel!.attributedText = myString
        titleLabel!.userInteractionEnabled = true
        titleLabel!.textColor =  WMColor.light_blue
        titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel!.numberOfLines = 2
        titleLabel!.textAlignment = .Center
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LandingPageViewController.editSearch))
        titleLabel!.addGestureRecognizer(tapGesture)
        
        self.headerView = UIView(frame: CGRectMake(0, 0, 1024, 46))
        self.headerView!.backgroundColor = WMColor.light_light_gray
        
        self.familyController = IPAFamilyViewController()
        self.familyController!.delegate = self
        
        self.imageBackground = UIImageView()
        self.imageBackground!.setImageWithURL(NSURL(string: "\(self.urlImage!)"), placeholderImage:UIImage(named: "header_default"), success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            self.imageBackground!.image = image
            self.collection?.reloadData()
        }) { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
            print("Error al presentar imagen")
        }
        
        self.loading = WMLoadingView(frame: CGRectMake(0, 216, self.view.bounds.width, self.view.bounds.height - 216))
        
        self.collection = getCollectionView()
        self.collection?.registerClass(SearchProductCollectionViewCell.self, forCellWithReuseIdentifier: "productSearch")
        self.collection?.registerClass(LoadingProductCollectionViewCell.self, forCellWithReuseIdentifier: "loadCell")
        self.collection?.registerClass(SectionHeaderSearchHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        self.collection?.allowsMultipleSelection = true
        
        self.collection!.dataSource = self
        self.collection!.delegate = self
        self.collection!.backgroundColor = UIColor.whiteColor()
        
        self.collection?.registerClass(IPASearchProductCollectionViewCell.self, forCellWithReuseIdentifier: "iPAProductSearch")
        self.collection?.registerClass(IPASectionHeaderSearchReusable.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        self.collection?.registerClass(IPACatHeaderSearchReusable.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage")
        
        self.filterButton = UIButton(type: .Custom)
        self.filterButton!.addTarget(self, action: #selector(IPALandingPageViewController.filter(_:)), forControlEvents: .TouchUpInside)
        self.filterButton!.tintColor = UIColor.whiteColor()
        self.filterButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        self.filterButton!.setTitle(NSLocalizedString("filter.button.title", comment:"" ) , forState: .Normal)
        self.filterButton!.backgroundColor = WMColor.light_blue
        self.filterButton!.layer.cornerRadius = 11.0
        
        self.filterButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.filterButton!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0)
        
        
        self.view.addSubview(self.header!)
        self.view.addSubview(self.headerView!)
        self.view.addSubview(self.collection!)
        
        self.loadDepartments()
        self.setValuesFamily()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentCellSelected != nil {
            self.reloadSelectedCell()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.isOriginalTextSearch = self.originalSearchContextType == SearchServiceContextType.WithText || self.originalSearchContextType == SearchServiceContextType.WithTextForCamFind
        
        if self.originalSearchContextType == nil{
            self.originalSearchContextType = SearchServiceContextType.WithCategoryForMG
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        self.headerView!.frame = CGRectMake(0, 0, 1024, 46)
        self.header!.frame = CGRectMake(0, 0, self.view.bounds.width, 46)
        self.filterButton!.frame = CGRectMake(self.view.bounds.maxX - 70 , (self.header!.frame.size.height - 22)/2 , 55, 22)
        self.backButton!.frame = CGRectMake(0, 0  ,46,46)
        self.titleLabel!.frame = CGRectMake(46, 0, self.header!.frame.width - 92, self.header!.frame.maxY)
        self.collection!.frame = CGRectMake(0, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY)
    }
    
    override func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func getCollectionView() -> UICollectionView {
        let customlayout = CSStickyHeaderFlowLayout()
        customlayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 216)
        customlayout.parallaxHeaderReferenceSize = CGSizeMake(1024, 216)
        customlayout.parallaxHeaderMinimumReferenceSize = CGSizeMake(1024, 216)
        customlayout.disableStickyHeaders = false
        //customlayout.parallaxHeaderAlwaysOnTop = true
        let collectionView = UICollectionView(frame: CGRectMake(0, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY), collectionViewLayout: customlayout)
        return collectionView
    }
    
    func showLoadingIfNeeded(hidden: Bool ) {
        if hidden {
            self.loading!.stopAnnimating()
        } else {
            //let boundsCenter:CGPoint =  self.viewHeader == nil ? CGPoint(x:0 , y: 320)  : self.viewHeader!.convertRect(self.viewHeader!.frame, toView:self.view.superview)
            let boundsCenter : CGPoint = self.viewHeader == nil ? CGPoint(x:0 , y: 320)  : self.viewHeader!.superview!.convertPoint(CGPoint(x: self.viewHeader!.frame.maxX,y:self.viewHeader!.frame.maxY), toView: self.view)
            
            self.loading = WMLoadingView(frame: CGRectMake(0, boundsCenter.y, self.view.bounds.width, self.view.bounds.height - boundsCenter.y ))
            self.isFirstLoad = false
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(false)
        }
    }
    
    func editSearch(){
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.EditSearch.rawValue, object: titleHeader!)
    }
    
    func loadDepartments() ->  [AnyObject]? {
        let serviceCategory = CategoryService()
        self.itemsCategory = serviceCategory.getCategoriesContent()
        return self.itemsCategory
    }
    
    func setValuesFamily(){
        
        for item in self.itemsCategory! {
            if item["idDepto"] as? String == departmentId {
                let famArray : AnyObject = item["family"] as AnyObject!
                let itemsFam : [[String:AnyObject]] = famArray as! [[String:AnyObject]]
                
                self.familyController.departmentId = item["idDepto"] as! String
                self.familyController.families = itemsFam
                self.familyController.selectedFamily = nil
                self.addPopover()
                break
            }
        }
        
        self.populateDefaultData(0)
        
    }
    
    func populateDefaultData(section: Int) {
        
        func nextSection() {
            let nextSection: Int = section + 1
            populateDefaultData(nextSection)
        }
        
        if self.familyController.families.count > section {
            let selectedSection = self.familyController.families[section]
            let linesArr = selectedSection["line"] as! NSArray
            
            if linesArr.count > 0 {
                if let itemLine = linesArr[0] as? NSDictionary {
                    let name = itemLine["name"] as! String
                    self.invokeSearchService(self.familyController.departmentId , family: selectedSection["id"] as! String,line: itemLine["id"] as! String, name: name,fromFilter: false)
                } else {
                    nextSection()
                }
            } else {
                nextSection()
            }
            
        }
        
    }
    
    func addPopover(){
        //familyController.delegate = self
        if #available(iOS 8.0, *) {
            familyController.modalPresentationStyle = .Popover
        } else {
            familyController.modalPresentationStyle = .FormSheet
        }
        familyController.preferredContentSize = CGSizeMake(320, 322)
        
        if popover ==  nil {
            popover = UIPopoverController(contentViewController: familyController)
            popover!.delegate = self
        }
        //popover!.delegate = self
        
        if let view =  self.viewHeader as?  IPASectionHeaderSearchReusable {
            view.setSelected()
        }
        
        popover!.presentPopoverFromRect(CGRectMake(self.headerView!.frame.width / 2, self.headerView!.frame.height - 10, 0, 0), inView: self.headerView!, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        
        if familyController.familyTable != nil {
            familyController.familyTable.reloadData()
        }
        
    }
    
    func filter(sender:UIButton){
        
        if self.filterController == nil {
            self.filterController = FilterProductsViewController()
            self.filterController!.hiddenBack = true
            self.filterController!.selectedOrder = self.idSort!
            self.filterController!.textToSearch = ""
            self.filterController!.facet = self.facet
            self.filterController!.originalSearchContext = self.originalSearchContextType
            self.filterController!.delegate = self
            self.filterController!.view.frame = CGRectMake(0.0, 0.0, 320.0, 390.0)
            self.filterController!.view.backgroundColor = UIColor.clearColor()
            self.filterController!.searchContext =  .WithCategoryForMG
            self.filterController!.successCallBack  = { () in
                self.sharePopover?.dismissPopoverAnimated(true)
                return
            }
        }
        
        let pointPop =  self.filterButton!.convertPoint(CGPointMake(self.filterButton!.frame.minX,  self.filterButton!.frame.maxY / 2  ), toView:self.view)
        
        //self.filterController!.view.backgroundView!.backgroundColor = UIColor.clearColor()
        let controller = UIViewController()
        controller.view.frame = CGRectMake(0.0, 0.0, 320.0, 390.0)
        controller.view.addSubview(self.filterController!.view)
        controller.view.backgroundColor = UIColor.clearColor()
        
        self.sharePopover = UIPopoverController(contentViewController: controller)
        self.sharePopover!.popoverContentSize =  CGSizeMake(320.0, 390.0)
        self.sharePopover!.delegate = self
        self.sharePopover!.backgroundColor = UIColor.whiteColor()
        //var rect = cell.convertRect(cell.quantityIndicator!.frame, toView: self.view.superview!)//
        
        self.sharePopover!.presentPopoverFromRect(CGRectMake(self.filterButton!.frame.minX , pointPop.y , 0, 0), inView: self.view.superview!, permittedArrowDirections: .Any, animated: true)
    }
    
    func reloadSelectedCell() {
        let currentCell = collection!.cellForItemAtIndexPath(currentCellSelected) as! IPASearchProductCollectionViewCell!
        if currentCell != nil{
            currentCell.showImageView()
        }
        self.collection?.reloadData()
    }

    func invokeSearchService(department:String,family:String,line:String, name:String,fromFilter:Bool) {
        print("Invoking MG Search")
        let resultsInResponse = self.allProducts?.count > 0 ? self.allProducts![0]["resultsInResponse"] as! NSString : "0"
        startOffSet +=  self.allProducts != nil ? Int(resultsInResponse as String)! : 0
        self.showLoadingIfNeeded(false)
        var commonTotal = 0
        let totalResults = self.allProducts?.count > 0 ? self.allProducts![0]["totalResults"] as! NSString : "1"
        commonTotal = ( Int(totalResults as String)  == -1 ? 0 : Int(totalResults as String)! )
        //TODO: Signals
        
        if startOffSet >= commonTotal && !fromFilter{
            self.loading!.stopAnnimating()
            return
        }
        
        let signalsDictionary : NSDictionary = NSDictionary(dictionary: ["signals" :GRBaseService.getUseSignalServices()])
        let service = ProductbySearchService(dictionary:signalsDictionary)
        self.familySelected = family
        self.lineSelected = line
        self.nameSelected = name
        let params = service.buildParamsForSearch(text: "", family: family, line: line, sort: self.idSort, departament: department, start: startOffSet, maxResult: self.maxResult)
        service.callService(params,
                            successBlock:{ (arrayProduct:NSArray?,facet:NSArray,resultDic:[String:AnyObject]) in
            //self.allProducts =  []
            self.allProducts!.addObjectsFromArray(arrayProduct! as [AnyObject])
                self.collection?.reloadData()
            NSNotificationCenter.defaultCenter().postNotificationName("FINISH_SEARCH", object: nil)
            self.showLoadingIfNeeded(true)
                                
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
                                }//
                                
                                
            }, errorBlock: {(error: NSError) in
                print("MG Search ERROR!!!")
                print(error)
                self.showLoadingIfNeeded(true)
            }
        )
    }
    
    //MARK: IPAFamilyViewControllerDelegate
    func didSelectLine(department:String,family:String,line:String, name:String) {
        self.popover?.dismissPopoverAnimated(true)
        self.titleHeader = name
        self.invokeSearchService(department,family: family, line: line, name:name,fromFilter: false)
        if let view =  self.viewHeader as?  IPASectionHeaderSearchReusable {
            view.dismissPopover()
        }
    }
    
    //MARK: UIPopoverController
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        if let view =  self.viewHeader as?  IPASectionHeaderSearchReusable {
            view.dismissPopover()
        }
    }

    //MARK: IPASectionHeaderSearchReusableDelegate
    func showFamilyController() {
        self.addPopover()
    }
    
}

extension IPALandingPageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(self.view.frame.width, 46)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let reusableView : UICollectionReusableView? = nil
        
        if kind == CSStickyHeaderParallaxHeader {
            let view = collection?.dequeueReusableSupplementaryViewOfKind(CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage", forIndexPath: indexPath) as! IPACatHeaderSearchReusable
            view.setValues(imageBackground!.image,imgIcon: nil,titleStr: "")
            view.btnClose.hidden = true
            return view
        }
        if kind == UICollectionElementKindSectionHeader {
            let view = collection?.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as! IPASectionHeaderSearchReusable
            let setSelected = viewHeader == nil && popover != nil
            self.headerView!.frame = CGRectMake(0, 0, 1024, 46)
            view.addSubview(self.headerView!)
            view.sendSubviewToBack(self.headerView!)
            view.title!.setTitle(titleHeader, forState: UIControlState.Normal)
            let attrStringLab = NSAttributedString(string:titleHeader!, attributes: [NSFontAttributeName : view.title!.titleLabel!.font])
            let rectSize = attrStringLab.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
            let wTitleSize = rectSize.width + 48
            view.title!.frame = CGRectMake((1024 / 2) -  (wTitleSize / 2), (self.headerView!.frame.height / 2) - 12, wTitleSize, 24)
            view.delegate = self
            viewHeader = view
            if setSelected {
                view.setSelected()
            }
            viewHeader?.addSubview(self.filterButton!)
            return view
        }
        return reusableView!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        var commonTotal = 0
        let totalResults = self.allProducts![0]["totalResults"] as! NSString
        commonTotal = ( Int(totalResults as String)!  == -1 ? 0 : Int(totalResults as String)! )
        print(commonTotal)
        
        if indexPath.row == (self.allProducts?.count)! - 1  && self.allProducts?.count <= commonTotal  {
            let loadCell = collectionView.dequeueReusableCellWithReuseIdentifier("loadCell", forIndexPath: indexPath)
            //self.invokeServiceInError =  true
            //self.getServiceProduct(resetTable: false) //Invoke service
            self.invokeSearchService(self.familyController.departmentId, family: self.familySelected, line: self.lineSelected, name: self.nameSelected,fromFilter: false)
             self.showLoadingIfNeeded(true)
            return loadCell
        }
        

        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("iPAProductSearch", forIndexPath: indexPath) as! SearchProductCollectionViewCell
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
                       isInShoppingCart: UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc),
                       type:type as String,
                       pesable : isPesable,
                       isFormList:  false,
                       productInlist:false,
                       isLowStock:isLowStock,
                       category:productDeparment,
                       equivalenceByPiece: equivalenceByPiece,
                       position:"\(indexPath.row)"
        )
        cell.delegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.view.bounds.width / 3, 254);
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Articulo seleccionado \(indexPath.row)")
        
        let cell = self.collection?.cellForItemAtIndexPath(indexPath)
        if cell!.isKindOfClass(SearchProductCollectionViewCell){
            if indexPath.row < self.allProducts!.count {
                
                let paginatedProductDetail = IPAProductDetailPageViewController()
                //paginatedProductDetail.idListSeleted = self.idListFromSearch
                paginatedProductDetail.ixSelected = indexPath.row
                //paginatedProductDetail.itemSelectedSolar = self.isAplyFilter ? "" : "\(indexPath.row)"
                paginatedProductDetail.itemsToShow = []
                paginatedProductDetail.stringSearching = self.titleHeader!
                paginatedProductDetail.detailOf = "Recomendados"
                
                for product in self.allProducts! {
                    let upc = product["upc"] as! NSString
                    let desc = product["description"] as! NSString
                    let type = product["type"] as! NSString
                    paginatedProductDetail.itemsToShow.append(["upc":upc,"description":desc, "type":type ])
                }
                
                //var contDetail = IPAProductDetailViewController()
                //contDetail.upc = upc
                //contDetail.name = desc
                
                let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! IPASearchProductCollectionViewCell!
                //currentCellSelected = indexPath
                let pontInView = currentCell.convertRect(currentCell!.productImage!.frame, toView:  self.view)
                //let pontInView =  currentCell.productImage?.convertRect(currentCell!.productImage!.frame, toView: self.view)
                //paginatedProductDetail.isForSeach = (self.textToSearch != nil && self.textToSearch != "")
                currentCellSelected = indexPath
                paginatedProductDetail.animationController = ProductDetailNavigatinAnimationController(nav:self.navigationController!)
                paginatedProductDetail.animationController.originPoint =  pontInView
                paginatedProductDetail.animationController.setImage(currentCell!.productImage!.image!)
                currentCell.hideImageView()
                
                self.navigationController?.delegate = paginatedProductDetail
                self.navigationController?.pushViewController(paginatedProductDetail, animated: true)
                
                
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  (self.allProducts != nil ? self.allProducts!.count : 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func buildMGSelectQuantityView(cell: SearchProductCollectionViewCell, viewFrame: CGRect){
        selectQuantity = ShoppingCartQuantitySelectorView(frame:viewFrame,priceProduct:NSNumber(double:(cell.price as NSString).doubleValue),upcProduct:cell.upc)
        selectQuantity!.closeAction = { () in
            self.selectQuantity.removeFromSuperview()
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
        let frameDetail = CGRectMake(0,0,320,394)
        self.buildMGSelectQuantityView(cell, viewFrame: frameDetail)
        
        selectQuantity?.closeAction = { () in
            self.selectQuantityPopover!.dismissPopoverAnimated(true)
            
        }
        
        selectQuantity!.addToCartAction =
            { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                let maxProducts = (cell.onHandInventory.integerValue <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory.integerValue : 5
                if maxProducts >= Int(quantity) {
                    let params = self.buildParamsUpdateShoppingCart(cell,quantity: quantity,position:cell.positionSelected)//position
                    
                    ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label:"\(cell.upc) - \(cell.desc)")
                    
                    UIView.animateWithDuration(0.2,
                                               animations: { () -> Void in
                                                self.selectQuantity!.closeAction()
                        },
                                               completion: { (animated:Bool) -> Void in
                                                self.selectQuantity = nil
                                                //CAMBIA IMAGEN CARRO SELECCIONADO
                                                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
                                                dispatch_async(dispatch_get_main_queue()) {
                                                    cell.addProductToShopingCart!.setImage(UIImage(named: "products_done"), forState: UIControlState.Normal)
                                                    self.collection!.reloadData()
                                                }
                        }
                    )
                }
                else {
                    self.selectQuantity!.closeAction()
                    let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                    
                    let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                    let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                    let msgInventory = "\(firstMessage)\(maxProducts) \(secondMessage)"
                    alert!.setMessage(msgInventory)
                    alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                    self.selectQuantity?.lblQuantity?.text = "0\(maxProducts)"
                }
        }
        
        let viewController = UIViewController()
        viewController.view = selectQuantity
        viewController.view.frame = frameDetail
        selectQuantityPopover = UIPopoverController(contentViewController: viewController)
        selectQuantityPopover!.setPopoverContentSize(CGSizeMake(320,394), animated: true)
        selectQuantityPopover!.backgroundColor = WMColor.light_blue.colorWithAlphaComponent(0.9)
        selectQuantityPopover!.presentPopoverFromRect(cell.addProductToShopingCart!.bounds, inView: cell.addProductToShopingCart!, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
    }
    func selectGRQuantityForItem(cell: SearchProductCollectionViewCell) {

    }
    
    func buildParamsUpdateShoppingCart(cell:SearchProductCollectionViewCell,quantity:String,position:String) -> [String:AnyObject] {
        let pesable = cell.pesable! ? "1" : "0"
    
            return ["upc":cell.upc,"desc":cell.desc,"imgUrl":cell.imageURL,"price":cell.price,"quantity":quantity,"onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":cell.isPreorderable,"category": cell.productDeparment]
        
    }


}

extension IPALandingPageViewController: FilterProductsViewControllerDelegate {
    
    func apply(order: String, filters: [String:AnyObject]?, isForGroceries flag: Bool) {
        print("apply")
        self.idSort = order
        
        self.allProducts = []
        self.invokeSearchService(self.familyController.departmentId, family: self.familySelected, line: self.lineSelected, name: self.nameSelected,fromFilter: true)
        
    }
    
    func sendBrandFilter(brandFilter: String) {
        print("sendBrandFilter")
        
    }
    
    func apply(order:String, upcs: [String]) {
        print("apply - upcs ")
       
        showLoadingIfNeeded(false)
        
        self.collection?.alpha = 100
        if upcs.count == 0 {
            self.allProducts = []
            //self.mgResults?.totalResults = 0
            self.collection?.reloadData()
            self.collection?.alpha = 0
        
        }
        
        
        let svcSearch = SearchItemsByUPCService()
        svcSearch.callService(upcs, successJSONBlock: { (result:JSON) -> Void in
            if self.originalSearchContextType != .WithTextForCamFind {
                self.allProducts? = []
            }
            self.allProducts?.addObjectsFromArray(result.arrayObject!)
           // self.mgResults?.totalResults = self.allProducts!.count
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
            
            
            self.collection?.reloadData()
            self.showLoadingIfNeeded(true)
        }) { (error:NSError) -> Void in
            print(error)
        }
        
    }
    
    func removeSelectedFilters(){
        print("removeSelectedFilters")
        
    }
    
    func removeFilters() {
        print("removeFilters")
        
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
    
}

