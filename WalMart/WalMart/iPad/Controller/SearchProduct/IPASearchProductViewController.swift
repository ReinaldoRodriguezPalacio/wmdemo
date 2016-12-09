//
//  IPASearchProductViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class IPASearchProductViewController : SearchProductViewController, UIPopoverControllerDelegate {
   // var frameTitle : CGRect = CGRectZero
    var viewAnimated : Bool = false
    var currentCellSelected : IndexPath!
    var filterController: FilterProductsViewController?
    var sharePopover: UIPopoverController?
    var selectQuantityPopover:  UIPopoverController?
    var imageBackground : UIImage? = nil
    var viewHeader : IPASectionHeaderSearchReusable!
    var emptyViewHeader: UIView?
    var landingController: IPALandingPageViewController?
    
    override func viewDidLoad() {
        self.maxResult = 23
        super.viewDidLoad()
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        collection?.register(IPASearchProductCollectionViewCell.self, forCellWithReuseIdentifier: "iPAProductSearch")
        collection?.frame = self.view.bounds
    }

    override func viewWillLayoutSubviews() {
        self.loading?.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
        if !viewAnimated {
//            if  self.filterView != nil {
//               self.removeFilter()
//            }
            super.viewWillLayoutSubviews()
            let bounds = self.view.bounds
            self.titleLabel!.sizeToFit()
            self.titleLabel!.frame = CGRect(x: (bounds.width - self.titleLabel!.frame.width) / 2,  y: 0, width: titleLabel!.frame.width , height: self.header!.frame.height)
           // frameTitle = self.titleLabel!.frame
        }
        
        if self.showAlertView {
            searchAlertView!.frame =  CGRect(x: 0,  y: self.header!.frame.maxY, width: self.view.frame.width, height: 46)
            self.viewBgSelectorBtn.frame = CGRect(x: (self.view.bounds.width / 2)  - 160,  y: self.searchAlertView!.frame.maxY + 20, width: 320, height: 28)
        }else{
            self.viewBgSelectorBtn.frame = CGRect(x: (self.view.bounds.width / 2)  - 160,  y: self.header!.frame.maxY + 20, width: 320, height: 28)
        }
        searchAlertView!.alpha = self.showAlertView ? 1 : 0
        
        self.btnSuper.frame = CGRect(x: 1, y: 1, width: (viewBgSelectorBtn.frame.width / 2) , height: viewBgSelectorBtn.frame.height - 2)
        self.btnSuper.setImage(UIImage(color: UIColor.white, size: btnSuper.frame.size), for: UIControlState())
        self.btnSuper.setImage(UIImage(color: WMColor.light_blue, size: btnSuper.frame.size), for: UIControlState.selected)
        
        self.btnTech.frame = CGRect(x: btnSuper.frame.maxX, y: 1, width: viewBgSelectorBtn.frame.width / 2, height: viewBgSelectorBtn.frame.height - 2)
        self.btnTech.setImage(UIImage(color: UIColor.white, size: btnSuper.frame.size), for: UIControlState())
        self.btnTech.setImage(UIImage(color: WMColor.light_blue, size: btnSuper.frame.size), for: UIControlState.selected)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentCellSelected != nil {
            self.reloadSelectedCell()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isLandingPage && indexPath.row == 0 {
            return CGSize(width:self.view.bounds.width,height: 217)
        }
        return CGSize(width:(self.view.bounds.width - 32) / 3, height:254)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       print("Articulo seleccionado \(indexPath.row)")
        
        if self.isLandingPage && indexPath.row == 0 {
            return
        }
        
        let newIndexPath = self.isLandingPage ? IndexPath(row: indexPath.row - 1, section:indexPath.section) : indexPath
        
        let cell = self.collection?.cellForItem(at: indexPath)
        if cell!.isKind(of: SearchProductCollectionViewCell.self){
            if indexPath.row < self.allProducts!.count {

                let paginatedProductDetail = IPAProductDetailPageViewController()
                paginatedProductDetail.idListSeleted = self.idListFromSearch
                paginatedProductDetail.ixSelected = newIndexPath.row
                paginatedProductDetail.itemSelectedSolar = self.isAplyFilter ? "" : "\(newIndexPath.row)"
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
            
                let currentCell = collectionView.cellForItem(at: indexPath) as! IPASearchProductCollectionViewCell!
                currentCellSelected = indexPath
                let pontInView = currentCell?.convert(currentCell!.productImage!.frame, to:  self.view)
                //let pontInView =  currentCell.productImage?.convertRect(currentCell!.productImage!.frame, toView: self.view)
                paginatedProductDetail.isForSeach = (self.textToSearch != nil && self.textToSearch != "")
                paginatedProductDetail.animationController = ProductDetailNavigatinAnimationController(nav:self.navigationController!)
                paginatedProductDetail.animationController.originPoint =  pontInView
                paginatedProductDetail.animationController.setImage(currentCell!.productImage!.image!)
                paginatedProductDetail.detailOf = self.textToSearch != nil ? "Search Results" : (self.eventCode != nil ? self.eventCode! : self.titleHeader!)
                currentCell?.hideImageView()
            
                self.navigationController?.delegate = paginatedProductDetail
                self.navigationController?.pushViewController(paginatedProductDetail, animated: true)
            
            
            }
        }
    }
    
    func reloadSelectedCell() {
        let currentCell = collection!.cellForItem(at: currentCellSelected) as! IPASearchProductCollectionViewCell!
        if currentCell != nil{
            currentCell?.showImageView()
        }
        self.collection?.reloadData()
    }
    
    override func filter(_ sender:UIButton){
        if self.filterController == nil {
            self.filterController = FilterProductsViewController()
            self.filterController!.facet = self.facet
            self.filterController!.hiddenBack = true
            self.filterController!.textToSearch = self.textToSearch
            self.filterController!.selectedOrder = self.idSort!
            self.filterController!.delegate = self
            self.filterController!.originalSearchContext = self.originalSearchContextType == nil ? self.searchContextType : self.originalSearchContextType
            self.filterController!.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 390.0)
            self.filterController!.view.backgroundColor = UIColor.clear
            self.filterController!.facetGr = self.facetGr
            self.filterController!.successCallBack  = { () in
                self.sharePopover?.dismiss(animated: true)
                return
            }
        }
        self.filterController!.facet =  self.facet != nil ? self.facet : nil
        self.filterController!.facetGr = self.facetGr
        self.filterController!.isGroceriesSearch = self.btnSuper.isSelected
        self.filterController!.searchContext = self.searchContextType
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

    //MARK: - UIPopoverControllerDelegate
    
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController) {
        self.sharePopover = nil
        self.selectQuantityOpen = false
        //self.filterController = nil
    }
    
    
    override func showLandingPage(){
        if self.landingController == nil {
            self.landingController =  IPALandingPageViewController()
            self.landingController!.urlImage = self.landingPageMG!["imgipad"] as? String
            self.landingController!.departmentId = self.landingPageMG!["departmentid"] as? String
            self.landingController!.titleHeader = self.landingPageMG!["text"] as? String
            self.navigationController!.pushViewController(self.landingController!, animated: true)
        }
        return
    }
    
    override func setAlertViewValues(_ resultDic: [String:Any]){
        
        if resultDic.count == 0 {
            self.showAlertView = false
        }else if (resultDic["alternativeCombination"] as! String) != "" {
            let alternativeCombination = resultDic["alternativeCombination"] as! String
            self.textToSearch = self.textToSearch ?? ""
            let suggestion = (self.textToSearch! as NSString).replacingOccurrences(of: alternativeCombination, with: "")
            self.showAlertView = true
            self.searchAlertView?.setValues(suggestion as String, correction: suggestion as String, underline: alternativeCombination)
        }
        else if (resultDic["suggestion"] as! String) != "" {
            self.showAlertView = true
            self.searchAlertView?.setValues(self.textToSearch!, correction: resultDic["suggestion"] as! String, underline: nil)
        }else{
            self.showAlertView = false
        }
        
        if ( !self.firstOpen || self.isTextSearch || self.isOriginalTextSearch || self.showAlertView ) {
            self.searchAlertView!.frame =  CGRect(x: 0,  y: self.header!.frame.maxY, width: self.view.frame.width, height: 46)
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.isTextSearch || self.isOriginalTextSearch {
                if self.showAlertView {
                    self.searchAlertView!.frame =  CGRect(x: 0,  y: self.header!.frame.maxY, width: self.view.frame.width, height: 46)
                    self.viewBgSelectorBtn.frame = CGRect(x: (self.view.bounds.width / 2)  - 160,  y: self.searchAlertView!.frame.maxY + 20, width: 320, height: 28)
                }else{
                    self.viewBgSelectorBtn.frame = CGRect(x: (self.view.bounds.width / 2)  - 160,  y: self.header!.frame.maxY + 20, width: 320, height: 28)
                }
                
                self.searchAlertView!.alpha = self.showAlertView ? 1 : 0
                
                let startPoint = self.viewBgSelectorBtn.frame.maxY + 20
                self.collection!.frame = CGRect(x: 0, y: startPoint, width: self.view.bounds.width, height: self.view.bounds.height - startPoint)
                
            }else {
                self.searchAlertView!.alpha = 0
                self.viewBgSelectorBtn.alpha = 0
            }
            
            
            }, completion: nil)
        }
    }
    
    override func productCellIdentifier() -> String {
        return "iPAProductSearch"
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 && self.searchContextType == SearchServiceContextType.withCategoryForGR && self.titleHeader ==  "Recomendados"  {
            return CGSize.zero
        }
        
        if section == 0 && self.searchContextType == SearchServiceContextType.withCategoryForGR && self.searchFromContextType == SearchServiceFromContext.fromLineSearch  {
            return CGSize.zero
        }
        
        
        if section == 0 && self.searchContextType == SearchServiceContextType.withCategoryForGR && !self.isTextSearch && self.searchFromContextType == SearchServiceFromContext.fromSearchTextSelect {
            return CGSize.zero
        }
        
        if section == 0 && self.searchContextType == SearchServiceContextType.withCategoryForMG && !self.isTextSearch && self.searchFromContextType == SearchServiceFromContext.fromSearchTextSelect {
            return CGSize.zero
        }
        
        if section == 0 && self.isOriginalTextSearch {
            return CGSize.zero
        }
        
        if section == 0 && self.searchContextType == SearchServiceContextType.withCategoryForGR && !self.isTextSearch {
            return CGSize(width: self.view.frame.width, height: 54)
        }
        
        if section == 0 && self.searchContextType != SearchServiceContextType.withCategoryForMG  {
            return CGSize.zero
        }
        
        if self.searchContextType == SearchServiceContextType.withCategoryForMG && self.isTextSearch {
            return CGSize.zero
        }
        
        if section == 0 && self.originalSearchContextType == SearchServiceContextType.withTextForCamFind {
            return CGSize.zero
        }
        
        if section == 0 && self.searchContextType == SearchServiceContextType.withCategoryForMG && self.titleHeader ==  "Recomendados"  {
            return CGSize.zero
        }
        
        
        return CGSize(width: self.view.frame.width, height: 54)
    }
    
    //MARK: SearchProductCollectionViewCellDelegate
    
    override func selectGRQuantityForItem(_ cell: SearchProductCollectionViewCell) {
        
        if !selectQuantityOpen {
            
            let frameDetail = CGRect(x: 0,y: 0,width: 320,height: 394)
            self.buildGRSelectQuantityView(cell, viewFrame: frameDetail)
            
            selectQuantityGR?.closeAction = { () in
                self.selectQuantityPopover!.dismiss(animated: true)
                self.selectQuantityOpen = false
            }
            
            let viewController = UIViewController()
            viewController.view = selectQuantityGR
            viewController.view.frame = frameDetail
            selectQuantityPopover = UIPopoverController(contentViewController: viewController)
            selectQuantityPopover!.backgroundColor = WMColor.light_blue.withAlphaComponent(0.9)
            selectQuantityPopover!.setContentSize(CGSize(width: 320,height: 394), animated: true)
            selectQuantityPopover!.delegate = self
            selectQuantityPopover!.present(from: cell.addProductToShopingCart!.bounds, in: cell.addProductToShopingCart!, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            selectQuantityOpen = true
        }
        
    }
    
    override func selectMGQuantityForItem(_ cell: SearchProductCollectionViewCell) {
        
        if !selectQuantityOpen {
            
            let frameDetail = CGRect(x: 0,y: 0,width: 320,height: 394)
            self.buildMGSelectQuantityView(cell, viewFrame: frameDetail)
            
            selectQuantity?.closeAction = { () in
                self.selectQuantityPopover!.dismiss(animated: true)
                self.selectQuantityOpen = false
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
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
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
            selectQuantityPopover!.delegate = self
            selectQuantityPopover!.present(from: cell.addProductToShopingCart!.bounds, in: cell.addProductToShopingCart!, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            selectQuantityOpen = true
            
        }
        
    }
    
    override func apply(_ order:String, upcs: [String]) {
        super.apply(order, upcs: upcs)
        if upcs.count == 0 {
         self.showEmptyView()
        }
        
    }
    
    override func showEmptyView(){
        
        self.filterButton?.alpha = 0
        let buidHeader =  self.header!.frame.maxY > 46
        if  self.empty == nil {
            self.empty = IPOGenericEmptyView(frame:CGRect(x: 0,y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46))
        }else{
            self.empty.removeFromSuperview()
            self.empty =  nil
            self.empty = IPOGenericEmptyView(frame:CGRect(x: 0,y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46))
        }
        
        self.empty.returnAction = { () in
         self.returnBack()
        }
        
        if buidHeader {
            self.emptyViewHeader = UIView()
            self.emptyViewHeader!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 46)
            self.emptyViewHeader!.backgroundColor = WMColor.light_light_gray
            let backButton = UIButton()
            backButton.setImage(UIImage(named: "BackProduct"), for: UIControlState())
            backButton.addTarget(self, action: #selector(NavigationViewController.back), for: UIControlEvents.touchUpInside)
            self.emptyViewHeader!.addSubview(backButton)
            backButton.frame = CGRect(x: 0, y: 0  ,width: 46,height: 46)
            let titleLabel = UILabel()
            titleLabel.textColor =  WMColor.light_blue
            titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
            titleLabel.numberOfLines = 2
            titleLabel.text = self.titleHeader
            titleLabel.textAlignment = .center
            titleLabel.frame = CGRect(x: 46, y: 0, width: self.emptyViewHeader!.frame.width - 92, height: self.emptyViewHeader!.frame.maxY)
            self.emptyViewHeader!.addSubview(titleLabel)
            self.view.addSubview(self.emptyViewHeader!)
        }
        self.view.addSubview(self.empty)
         self.loading?.stopAnnimating()
        self.filterButton?.alpha = 0
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearSearch.rawValue), object: nil)
    }
    
    override func removeEmptyView(){
        self.empty.removeFromSuperview()
        self.empty =  nil
        self.emptyViewHeader?.removeFromSuperview()
        self.emptyViewHeader = nil
    }
    
    override func back() {
        self.returnBack()
        
    }
    
}
