//
//  IPALandingPageViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 07/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

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


class IPALandingPageViewController: NavigationViewController, UIPopoverControllerDelegate, IPAFamilyViewControllerDelegate, IPASectionHeaderSearchReusableDelegate,SearchProductCollectionViewCellDelegate {
    var filterMedida: Bool! = false
    var medidaToSearch:String! = ""
    
    var filterController: FilterProductsViewController?
    var sharePopover: UIPopoverController?
    var filterButton: UIButton?
    var idSort:String?
    var isOriginalTextSearch: Bool = false
    var originalSearchContextType: SearchServiceContextType?
    
    var selectQuantity : ShoppingCartQuantitySelectorView!
    
    var currentCellSelected : IndexPath!
    var isFirstLoad: Bool = true
    var urlImage: String?
    var imageBackground:UIImageView?
    var loading: WMLoadingView?
    var collection: UICollectionView?
    var titleHeader: String?
    var viewHeader: UIView?
    var allProducts: [[String:Any]]? = []
    var departmentId: String?
    var headerView: UIView?
    var itemsCategory: [[String:Any]]?
    var familyController : IPAFamilyViewController!
    var popover : UIPopoverController?
    let maxResult = 20
    var facet : [[String:Any]]!
    
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
        myString.append(attachmentString)
        titleLabel!.numberOfLines = 2
        titleLabel!.attributedText = myString
        titleLabel!.isUserInteractionEnabled = true
        titleLabel!.textColor =  WMColor.light_blue
        titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel!.numberOfLines = 2
        titleLabel!.textAlignment = .center
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LandingPageViewController.editSearch))
        titleLabel!.addGestureRecognizer(tapGesture)
        
        self.headerView = UIView(frame: CGRect(x: 0, y: 0, width: 1024, height: 46))
        self.headerView!.backgroundColor = WMColor.light_light_gray
        
        self.familyController = IPAFamilyViewController()
        self.familyController!.delegate = self
        
        self.imageBackground = UIImageView()
        self.imageBackground!.setImageWith(URLRequest(url:URL(string: "\(self.urlImage!)")!), placeholderImage:UIImage(named: "header_default"), success: { (request:URLRequest, response:HTTPURLResponse?, image:UIImage) -> Void in
            self.imageBackground!.image = image
            self.collection?.reloadData()
        }) { (request:URLRequest, response:HTTPURLResponse?, error:Error) -> Void in
            print("Error al presentar imagen")
        }
        
        self.loading = WMLoadingView(frame: CGRect(x: 0, y: 216, width: self.view.bounds.width, height: self.view.bounds.height - 216))
        
        self.collection = getCollectionView()
        self.collection?.register(SearchProductCollectionViewCell.self, forCellWithReuseIdentifier: "productSearch")
        self.collection?.register(LoadingProductCollectionViewCell.self, forCellWithReuseIdentifier: "loadCell")
        self.collection?.register(SectionHeaderSearchHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        self.collection?.allowsMultipleSelection = true
        
        self.collection!.dataSource = self
        self.collection!.delegate = self
        self.collection!.backgroundColor = UIColor.white
        
        self.collection?.register(IPASearchProductCollectionViewCell.self, forCellWithReuseIdentifier: "iPAProductSearch")
        self.collection?.register(IPASectionHeaderSearchReusable.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        self.collection?.register(IPACatHeaderSearchReusable.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage")
        
        self.filterButton = UIButton(type: .custom)
        self.filterButton!.addTarget(self, action: #selector(IPALandingPageViewController.filter(_:)), for: .touchUpInside)
        self.filterButton!.tintColor = UIColor.white
        self.filterButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        self.filterButton!.setTitle(NSLocalizedString("filter.button.title", comment:"" ) , for: UIControlState())
        self.filterButton!.backgroundColor = WMColor.light_blue
        self.filterButton!.layer.cornerRadius = 11.0
        
        self.filterButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.filterButton!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0)
        
                
        self.view.addSubview(self.header!)
        self.view.addSubview(self.headerView!)
        self.view.addSubview(self.collection!)
        
        let _ = self.loadDepartments()
        self.setValuesFamily()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentCellSelected != nil {
            self.reloadSelectedCell()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.isOriginalTextSearch = self.originalSearchContextType == SearchServiceContextType.withText || self.originalSearchContextType == SearchServiceContextType.withTextForCamFind
        
        if self.originalSearchContextType == nil{
            self.originalSearchContextType = SearchServiceContextType.withCategoryForMG
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        self.headerView!.frame = CGRect(x: 0, y: 0, width: 1024, height: 46)
        self.header!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 46)
        self.filterButton!.frame = CGRect(x: self.view.bounds.maxX - 70 , y: (self.header!.frame.size.height - 22)/2 , width: 55, height: 22)
        self.backButton!.frame = CGRect(x: 0, y: 0  ,width: 46,height: 46)
        self.titleLabel!.frame = CGRect(x: 46, y: 0, width: self.header!.frame.width - 92, height: self.header!.frame.maxY)
        self.collection!.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.header!.frame.maxY)
    }
    
    override func back() {
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func getCollectionView() -> UICollectionView {
        let customlayout = CSStickyHeaderFlowLayout()
        customlayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 216)
        customlayout.parallaxHeaderReferenceSize = CGSize(width: 1024, height: 216)
        customlayout.parallaxHeaderMinimumReferenceSize = CGSize(width: 1024, height: 216)
        customlayout.disableStickyHeaders = false
        //customlayout.parallaxHeaderAlwaysOnTop = true
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.header!.frame.maxY), collectionViewLayout: customlayout)
        
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        
        return collectionView
    }
    
    func showLoadingIfNeeded(_ hidden: Bool ) {
        if hidden {
            self.loading!.stopAnnimating()
        } else {
            //let boundsCenter:CGPoint =  self.viewHeader == nil ? CGPoint(x:0 , y: 320)  : self.viewHeader!.convertRect(self.viewHeader!.frame, toView:self.view.superview)
            let boundsCenter : CGPoint = self.viewHeader == nil ? CGPoint(x:0 , y: 320)  : self.viewHeader!.superview!.convert(CGPoint(x: self.viewHeader!.frame.maxX,y:self.viewHeader!.frame.maxY), to: self.view)
            
            self.loading = WMLoadingView(frame: CGRect(x: 0, y: boundsCenter.y, width: self.view.bounds.width, height: self.view.bounds.height - boundsCenter.y ))
            self.isFirstLoad = false
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(false)
        }
    }
    
    func editSearch(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.EditSearch.rawValue), object: titleHeader!)
    }
    
    func loadDepartments() ->  [Any]? {
        let serviceCategory = CategoryService()
        self.itemsCategory = serviceCategory.getCategoriesContent()
        return self.itemsCategory as [Any]?
    }
    
    func setValuesFamily(){
        
        for item in self.itemsCategory! {
            if item["idDepto"] as? String == departmentId {
                let famArray : AnyObject = item["family"] as AnyObject!
                let itemsFam : [[String:Any]] = famArray as! [[String:Any]]
                
                self.familyController.departmentId = item["idDepto"] as! String
                self.familyController.families = itemsFam
                self.familyController.selectedFamily = nil
                self.addPopover()
                break
            }
        }
        
        self.populateDefaultData(0)
        
    }
    
    func populateDefaultData(_ section: Int) {
        
        func nextSection() {
            let nextSection: Int = section + 1
            populateDefaultData(nextSection)
        }
        
        if self.familyController.families.count > section {
            let selectedSection = self.familyController.families[section]
            let linesArr = selectedSection["line"] as! [Any]
            
            if linesArr.count > 0 {
                if let itemLine = linesArr[0] as? [String:Any] {
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
        familyController.modalPresentationStyle = .popover
        
        familyController.preferredContentSize = CGSize(width: 320, height: 322)
        
        if popover ==  nil {
            popover = UIPopoverController(contentViewController: familyController)
            popover!.delegate = self
        }
        //popover!.delegate = self
        
        if let view =  self.viewHeader as?  IPASectionHeaderSearchReusable {
            view.setSelected()
        }
        
        popover!.present(from: CGRect(x: self.headerView!.frame.width / 2, y: self.headerView!.frame.height - 10, width: 0, height: 0), in: self.headerView!, permittedArrowDirections: UIPopoverArrowDirection.up, animated: true)
        
        if familyController.familyTable != nil {
            familyController.familyTable.reloadData()
        }
        
    }
    
    func filter(_ sender:UIButton){
        
        if self.filterController == nil {
            self.filterController = FilterProductsViewController()
            self.filterController!.hiddenBack = true
            self.filterController!.selectedOrder = self.idSort!
            self.filterController!.textToSearch = ""
            self.filterController!.facet = self.facet as [[String:Any]]?
            self.filterController!.originalSearchContext = self.originalSearchContextType
            self.filterController!.delegate = self
            self.filterController!.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 390.0)
            self.filterController!.view.backgroundColor = UIColor.clear
            self.filterController!.searchContext =  .withCategoryForMG
            self.filterController!.successCallBack  = { () in
                self.sharePopover?.dismiss(animated: true)
                return
            }
        }
        
        let pointPop =  self.filterButton!.convert(CGPoint(x: self.filterButton!.frame.minX,  y: self.filterButton!.frame.maxY / 2  ), to:self.view)
        
        //self.filterController!.view.backgroundView!.backgroundColor = UIColor.clearColor()
        let controller = UIViewController()
        controller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 390.0)
        controller.view.addSubview(self.filterController!.view)
        controller.view.backgroundColor = UIColor.clear
        
        self.sharePopover = UIPopoverController(contentViewController: controller)
        self.sharePopover!.contentSize =  CGSize(width: 320.0, height: 390.0)
        self.sharePopover!.delegate = self
        self.sharePopover!.backgroundColor = UIColor.white
        //var rect = cell.convertRect(cell.quantityIndicator!.frame, toView: self.view.superview!)//
        
        self.sharePopover!.present(from: CGRect(x: self.filterButton!.frame.minX , y: pointPop.y , width: 0, height: 0), in: self.view.superview!, permittedArrowDirections: .any, animated: true)
    }
    
    func reloadSelectedCell() {
        let currentCell = collection!.cellForItem(at: currentCellSelected) as! IPASearchProductCollectionViewCell!
        if currentCell != nil{
            currentCell?.showImageView()
        }
        self.collection?.reloadData()
    }

    func invokeSearchService(_ department:String,family:String,line:String, name:String,fromFilter:Bool) {
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
        
        let signalsDictionary : [String:Any] = ["signals" :GRBaseService.getUseSignalServices()]
        let service = ProductbySearchService(dictionary:signalsDictionary)
        self.familySelected = family
        self.lineSelected = line
        self.nameSelected = name
        let params = service.buildParamsForSearch(text: "", family: family, line: line, sort: self.idSort, departament: department, start: startOffSet, maxResult: self.maxResult)
        service.callService(params!,
                            successBlock:{ (arrayProduct:[[String:Any]]?,facet:[[String:Any]],resultDic:[String:Any]) in
            //self.allProducts =  []
            self.allProducts!.append(array: arrayProduct!)
                self.collection?.reloadData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "FINISH_SEARCH"), object: nil)
            self.showLoadingIfNeeded(true)
            var sortFacet = facet
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
                
            }, errorBlock: {(error: NSError) in
                print("MG Search ERROR!!!")
                print(error)
                self.showLoadingIfNeeded(true)
            }
        )
    }
    
    //MARK: IPAFamilyViewControllerDelegate
    func didSelectLine(_ department:String,family:String,line:String, name:String) {
        self.popover?.dismiss(animated: true)
        self.titleHeader = name
        self.invokeSearchService(department,family: family, line: line, name:name,fromFilter: false)
        if let view =  self.viewHeader as?  IPASectionHeaderSearchReusable {
            view.dismissPopover()
        }
    }
    
    //MARK: UIPopoverController
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController) {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reusableView : UICollectionReusableView? = nil
        
        if kind == CSStickyHeaderParallaxHeader {
            let view = collection?.dequeueReusableSupplementaryView(ofKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage", for: indexPath) as! IPACatHeaderSearchReusable
            view.setValues(imageBackground!.image,imgIcon: nil,titleStr: "")
            view.btnClose.isHidden = true
            return view
        }
        if kind == UICollectionElementKindSectionHeader {
            let view = collection?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! IPASectionHeaderSearchReusable
            let setSelected = viewHeader == nil && popover != nil
            self.headerView!.frame = CGRect(x: 0, y: 0, width: 1024, height: 46)
            view.addSubview(self.headerView!)
            view.sendSubview(toBack: self.headerView!)
            view.title!.setTitle(titleHeader, for: UIControlState())
            let attrStringLab = NSAttributedString(string:titleHeader!, attributes: [NSFontAttributeName : view.title!.titleLabel!.font])
            let rectSize = attrStringLab.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            let wTitleSize = rectSize.width + 48
            view.title!.frame = CGRect(x: (1024 / 2) -  (wTitleSize / 2), y: (self.headerView!.frame.height / 2) - 12, width: wTitleSize, height: 24)
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        var commonTotal = 0
        let totalResults = self.allProducts![0]["totalResults"] as! NSString
        commonTotal = ( Int(totalResults as String)!  == -1 ? 0 : Int(totalResults as String)! )
        print(commonTotal)
        
        if indexPath.row == (self.allProducts?.count)! - 1  && self.allProducts?.count <= commonTotal  {
            let loadCell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadCell", for: indexPath)
            //self.invokeServiceInError =  true
            //self.getServiceProduct(resetTable: false) //Invoke service
            self.invokeSearchService(self.familyController.departmentId, family: self.familySelected, line: self.lineSelected, name: self.nameSelected,fromFilter: false)
             self.showLoadingIfNeeded(true)
            return loadCell
        }
        

        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iPAProductSearch", for: indexPath) as! SearchProductCollectionViewCell
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width / 3, height: 254);
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Articulo seleccionado \(indexPath.row)")
        
        let cell = self.collection?.cellForItem(at: indexPath)
        if cell!.isKind(of: SearchProductCollectionViewCell.self){
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
                
                let currentCell = collectionView.cellForItem(at: indexPath) as! IPASearchProductCollectionViewCell!
                //currentCellSelected = indexPath
                let pontInView = currentCell?.convert(currentCell!.productImage!.frame, to:  self.view)
                //let pontInView =  currentCell.productImage?.convertRect(currentCell!.productImage!.frame, toView: self.view)
                //paginatedProductDetail.isForSeach = (self.textToSearch != nil && self.textToSearch != "")
                currentCellSelected = indexPath
                paginatedProductDetail.animationController = ProductDetailNavigatinAnimationController(nav:self.navigationController!)
                paginatedProductDetail.animationController.originPoint =  pontInView
                paginatedProductDetail.animationController.setImage(currentCell!.productImage!.image!)
                currentCell?.hideImageView()
                
                self.navigationController?.delegate = paginatedProductDetail
                self.navigationController?.pushViewController(paginatedProductDetail, animated: true)
                
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  (self.allProducts != nil ? self.allProducts!.count : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func buildMGSelectQuantityView(_ cell: SearchProductCollectionViewCell, viewFrame: CGRect){
        selectQuantity = ShoppingCartQuantitySelectorView(frame:viewFrame,priceProduct:NSNumber(value: (cell.price as NSString).doubleValue as Double),upcProduct:cell.upc)
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
    
    func selectMGQuantityForItem(_ cell: SearchProductCollectionViewCell,productInCart:Cart?) {
        
        let frameDetail = CGRect(x: 0,y: 0,width: 320,height: 394)
        self.buildMGSelectQuantityView(cell, viewFrame: frameDetail)
        
        selectQuantity?.closeAction = { () in
            self.selectQuantityPopover!.dismiss(animated: true)
            
        }
        
        selectQuantity!.addToCartAction =
            { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                let maxProducts = (cell.onHandInventory.integerValue <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory.integerValue : 5
                if maxProducts >= Int(quantity) {
                    let params = self.buildParamsUpdateShoppingCart(cell,quantity: quantity,position:cell.positionSelected)//position
                    
                    ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label:"\(cell.upc) - \(cell.desc)")
                    
                    UIView.animate(withDuration: 0.2,
                                               animations: { () -> Void in
                                                self.selectQuantity!.closeAction()
                        },
                                               completion: { (animated:Bool) -> Void in
                                                self.selectQuantity = nil
                                                //CAMBIA IMAGEN CARRO SELECCIONADO
                                                NotificationCenter.default.post(name:NSNotification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
                                                DispatchQueue.main.async {
                                                    cell.addProductToShopingCart!.setImage(UIImage(named: "products_done"), for: UIControlState())
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
        selectQuantityPopover!.setContentSize(CGSize(width: 320,height: 394), animated: true)
        selectQuantityPopover!.backgroundColor = WMColor.light_blue.withAlphaComponent(0.9)
        selectQuantityPopover!.present(from: cell.addProductToShopingCart!.bounds, in: cell.addProductToShopingCart!, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
    }
    func selectGRQuantityForItem(_ cell: SearchProductCollectionViewCell,productInCart:Cart?) {

    }
    
    func buildParamsUpdateShoppingCart(_ cell:SearchProductCollectionViewCell,quantity:String,position:String) -> [String:Any] {
        let pesable = cell.pesable! ? "1" : "0"
    
            return ["upc":cell.upc,"desc":cell.desc,"imgUrl":cell.imageURL,"price":cell.price,"quantity":quantity,"onHandInventory":cell.onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,"pesable":pesable,"isPreorderable":cell.isPreorderable,"category": cell.productDeparment]
        
    }


}

extension IPALandingPageViewController: FilterProductsViewControllerDelegate {
    
    func apply(_ order: String, filters: [String:Any]?, isForGroceries flag: Bool) {
        print("apply")
        self.idSort = order
        
        self.allProducts = []
        self.invokeSearchService(self.familyController.departmentId, family: self.familySelected, line: self.lineSelected, name: self.nameSelected,fromFilter: true)
        
    }
    
    func sendBrandFilter(_ brandFilter: String) {
        print("sendBrandFilter")
        
    }
    
    func apply(_ order:String, upcs: [String]) {
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
            if self.originalSearchContextType != .withTextForCamFind {
                self.allProducts? = []
            }
            self.allProducts?.append(array: result.arrayObject! as! Array<[String : Any]>)
           // self.mgResults?.totalResults = self.allProducts!.count
            self.idSort = order
            switch (FilterType(rawValue: self.idSort!)!) {
            case .descriptionAsc :
                //println("descriptionAsc")
                self.allProducts!.sort(by:{ (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                    if (dictionary1["description"] as! String) < (dictionary2["description"] as! String) {
                        return false
                    }
                    else if (dictionary1["description"] as! String) > (dictionary2["description"] as! String) {
                        return true
                    }
                    else {
                        return true
                    }
                    
                })

            case .descriptionDesc :
                //println("descriptionDesc")
                self.allProducts!.sort(by: { (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                    if (dictionary1["description"] as! String) < (dictionary2["description"] as! String) {
                        return true
                    }
                    else if (dictionary1["description"] as! String) > (dictionary2["description"] as! String) {
                        return false
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
                        return false
                    }
                    else if (priceOne > priceTwo) {
                        return true
                    }
                    else {
                        return true
                    }
                    
                })
            case .none : print("Not sorted")
            case .priceDesc :
                //println("priceDesc")
                self.allProducts!.sort(by: { (dictionary1:[String:Any], dictionary2:[String:Any]) -> Bool in
                    let priceOne:Double = self.priceValueFrom(dictionary1)
                    let priceTwo:Double = self.priceValueFrom(dictionary2)
                    
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
    
}

