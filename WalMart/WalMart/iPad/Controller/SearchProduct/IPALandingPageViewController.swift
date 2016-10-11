//
//  IPALandingPageViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 07/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class IPALandingPageViewController: NavigationViewController, UICollectionViewDataSource, UICollectionViewDelegate,IPAFamilyViewControllerDelegate,UIPopoverControllerDelegate,IPASectionHeaderSearchReusableDelegate {
    var urlImage: String?
    var imageBackground:UIImageView?
    var loading: WMLoadingView?
    var collection: UICollectionView?
    var titleHeader: String?
    var viewHeader: UIView?
    var allProducts: [AnyObject]! = []
    var departmentId: String?
    var headerView: UIView?
    var itemsCategory: [[String:AnyObject]]?
    var familyController : IPAFamilyViewController!
    var popover : UIPopoverController?
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_LANDINGPAGE.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.view.addSubview(self.header!)
        self.view.addSubview(self.headerView!)
        self.view.addSubview(self.collection!)
        
        self.loadDepartments()
        self.setValuesFamily()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillLayoutSubviews() {
        self.headerView!.frame = CGRectMake(0, 0, 1024, 46)
        self.header!.frame = CGRectMake(0, 0, self.view.bounds.width, 46)
        self.backButton!.frame = CGRectMake(0, 0  ,46,46)
        self.titleLabel!.frame = CGRectMake(46, 0, self.header!.frame.width - 92, self.header!.frame.maxY)
        self.collection!.frame = CGRectMake(0, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(self.view.frame.width, 54)
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
            self.headerView!.frame = CGRectMake(0, 0, 1024, 46)
            view.addSubview(self.headerView!)
            view.sendSubviewToBack(self.headerView!)
            view.title!.setTitle(titleHeader, forState: UIControlState.Normal)
            let attrStringLab = NSAttributedString(string:titleHeader!, attributes: [NSFontAttributeName : view.title!.titleLabel!.font])
            let rectSize = attrStringLab.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
            let wTitleSize = rectSize.width + 48
            view.title!.frame = CGRectMake((1024 / 2) -  (wTitleSize / 2), (self.headerView!.frame.height / 2) - 12, wTitleSize, 24)
            view.delegate = self
            view.setSelected()
            viewHeader = view
            return view
        }
        return reusableView!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
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
        //cell.delegate = self
        return cell
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
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.view.bounds.width / 3, 254);
    }
    
    // override func returnBack() {
    //    viewHeader.dismissPopover()
    // }
    
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
        return self.allProducts!.count
    }

    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func showLoadingIfNeeded(hidden: Bool ) {
        if hidden {
            self.loading!.stopAnnimating()
        } else {
            self.viewHeader!.convertPoint(CGPointMake(self.view.frame.width / 2, 216), toView:self.view.superview)
            self.loading = WMLoadingView(frame: CGRectMake(0, 216, self.view.bounds.width, self.view.bounds.height - 216))
            
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(false)
        }
    }
    
    func editSearch(){
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.EditSearch.rawValue, object: titleHeader!)
    }
    
    override func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
        popover!.presentPopoverFromRect(CGRectMake(self.headerView!.frame.width / 2, self.headerView!.frame.height - 10, 0, 0), inView: self.headerView!, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        
        if familyController.familyTable != nil {
            familyController.familyTable.reloadData()
        }
        
    }
    
    //MARK: IPAFamilyViewControllerDelegate
    func didSelectLine(department:String,family:String,line:String, name:String) {
        if let view =  self.viewHeader as?  IPASectionHeaderSearchReusable {
            view.dismissPopover()
        }
        self.popover?.dismissPopoverAnimated(true)
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
