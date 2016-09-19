//
//  IPASearchProductViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPASearchProductViewController : SearchProductViewController, UIPopoverControllerDelegate {
   // var frameTitle : CGRect = CGRectZero
    var viewAnimated : Bool = false
    var currentCellSelected : NSIndexPath!
    var filterController: FilterProductsViewController?
    var sharePopover: UIPopoverController?
    var selectQuantityPopover:  UIPopoverController?
    var imageBackground : UIImage? = nil
    var viewHeader : IPASectionHeaderSearchReusable!
    var emptyViewHeader: UIView?
    
    override func viewDidLoad() {
        self.maxResult = 23
        super.viewDidLoad()
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        collection?.registerClass(IPASearchProductCollectionViewCell.self, forCellWithReuseIdentifier: "iPAProductSearch")
        collection?.frame = self.view.bounds
    }

    override func viewWillLayoutSubviews() {
        self.loading!.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        if !viewAnimated {
//            if  self.filterView != nil {
//               self.removeFilter()
//            }
            super.viewWillLayoutSubviews()
            let bounds = self.view.bounds
            self.titleLabel!.sizeToFit()
            self.titleLabel!.frame = CGRectMake((bounds.width - self.titleLabel!.frame.width) / 2,  0, titleLabel!.frame.width , self.header!.frame.height)
           // frameTitle = self.titleLabel!.frame
        }
        /*
        self.viewBgSelectorBtn.frame = CGRectMake((self.view.bounds.width / 2)  - 160,  self.header!.frame.maxY + 16, 320, 28)
        self.btnSuper.frame = CGRectMake(1, 1, (viewBgSelectorBtn.frame.width / 2) , viewBgSelectorBtn.frame.height - 2)
        self.btnSuper.setImage(UIImage(color: UIColor.whiteColor(), size: btnSuper.frame.size), forState: UIControlState.Normal)
        self.btnSuper.setImage(UIImage(color: WMColor.light_blue, size: btnSuper.frame.size), forState: UIControlState.Selected)
        
        self.btnTech.frame = CGRectMake(btnSuper.frame.maxX, 1, viewBgSelectorBtn.frame.width / 2, viewBgSelectorBtn.frame.height - 2)
        self.btnTech.setImage(UIImage(color: UIColor.whiteColor(), size: btnSuper.frame.size), forState: UIControlState.Normal)
        self.btnTech.setImage(UIImage(color: WMColor.light_blue, size: btnSuper.frame.size), forState: UIControlState.Selected)
        */
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (self.allProducts == nil || self.allProducts!.count == 0) {
            if finsihService {
                self.showEmptyView()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentCellSelected != nil {
            self.reloadSelectedCell()
        }
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.view.bounds.width / 3, 254);
    }
    
   // override func returnBack() {
   //    viewHeader.dismissPopover()
   // }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       print("Articulo seleccionado \(indexPath.row)")
        
        let cell = self.collection?.cellForItemAtIndexPath(indexPath)
        if cell!.isKindOfClass(SearchProductCollectionViewCell){
            if indexPath.row < self.allProducts!.count {

                let paginatedProductDetail = IPAProductDetailPageViewController()
                paginatedProductDetail.idListSeleted = self.idListFromSearch
                paginatedProductDetail.ixSelected = indexPath.row
                paginatedProductDetail.itemSelectedSolar = self.isAplyFilter ? "" : "\(indexPath.row)"
                paginatedProductDetail.itemsToShow = []
                paginatedProductDetail.stringSearching = self.titleHeader!
                
                for product in self.allProducts! {
                    let upc = product["upc"] as! NSString
                    let desc = product["description"] as! NSString
                    //let type = product["type"] as! NSString
                    paginatedProductDetail.itemsToShow.append(["upc":upc,"description":desc, "type":ResultObjectType.Mg.rawValue ])
                }
            
                //var contDetail = IPAProductDetailViewController()
                //contDetail.upc = upc
                //contDetail.name = desc
            
                let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! IPASearchProductCollectionViewCell!
                currentCellSelected = indexPath
                let pontInView = currentCell.convertRect(currentCell!.productImage!.frame, toView:  self.view)
                //let pontInView =  currentCell.productImage?.convertRect(currentCell!.productImage!.frame, toView: self.view)
                paginatedProductDetail.isForSeach = (self.textToSearch != nil && self.textToSearch != "")
                paginatedProductDetail.animationController = ProductDetailNavigatinAnimationController(nav:self.navigationController!)
                paginatedProductDetail.animationController.originPoint =  pontInView
                paginatedProductDetail.animationController.setImage(currentCell!.productImage!.image!)
                currentCell.hideImageView()
            
                self.navigationController?.delegate = paginatedProductDetail
                self.navigationController?.pushViewController(paginatedProductDetail, animated: true)
            
            
            }
        }
    }
    
    func reloadSelectedCell() {
        let currentCell = collection!.cellForItemAtIndexPath(currentCellSelected) as! IPASearchProductCollectionViewCell!
        if currentCell != nil{
            currentCell.showImageView()
        }
        self.collection?.reloadData()
    }
    
    override func apply(order:String, filters:[String:AnyObject]?, isForGroceries flag:Bool) {
        super.apply(order, filters: filters, isForGroceries: flag)
        self.filterButton?.setTitle(NSLocalizedString("Restaurar", comment:"" ) , forState: .Normal)
        self.filterButton?.frame = CGRectMake(self.view.bounds.maxX - 90 , (self.header!.frame.size.height - 22)/2 , 70, 22)
        
    }
    
    override func filter(sender:UIButton){
        if self.isAplyFilter {
            print("Resetea filtros")
            self.isAplyFilter =  false
            self.filterButton!.setTitle(NSLocalizedString("filter.button.title", comment:"" ) , forState: .Normal)
            self.results!.resetResult()
            self.getServiceProduct(resetTable: true)
        }
        else{
            if self.filterController == nil {
                self.filterController = FilterProductsViewController()
                self.filterController!.facet = self.facet
                self.filterController!.hiddenBack = true
                self.filterController!.textToSearch = self.textToSearch
                self.filterController!.selectedOrder = self.idSort!
                self.filterController!.delegate = self
                self.filterController!.originalSearchContext = self.originalSearchContextType == nil ? self.searchContextType : self.originalSearchContextType
                self.filterController!.view.frame = CGRectMake(0.0, 0.0, 320.0, 390.0)
                self.filterController!.view.backgroundColor = UIColor.clearColor()
                //self.filterController!.facetGr = self.facetGr
                self.filterController!.successCallBack  = { () in
                    self.sharePopover?.dismissPopoverAnimated(true)
                    return
                }
            }
            self.filterController?.selectedOrder = ""
            self.filterController!.filterOrderViewCell?.resetOrderFilter()
            self.filterController!.sliderTableViewCell?.resetSlider()
            self.filterController!.upcPrices =  nil
            self.filterController!.selectedElementsFacet = [:]
            self.filterController!.facet =  self.facet != nil ? self.facet : nil
            //self.filterController!.facetGr = self.facetGr
            //self.filterController!.isGroceriesSearch = self.btnSuper.selected
            self.filterController!.searchContext = self.searchContextType
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
    }

    
    //MARK: - UIPopoverControllerDelegate
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        self.sharePopover = nil
        //self.filterController = nil
    }
    

    //TODO: VERIFICAR LA VISUALIZACION DE FILTROS EN IPAD - ANAH
    /*
    override func filter(sender:UIButton){
        let widthFilter : CGFloat =  320
        var minFilter = self.header!.frame.maxX - widthFilter
        var frameLabelTo = self.titleLabel!.frame
        var minLabel = frameTitle.minX
        
        if filterView==nil{
            self.filterView = HeaderFilterView (frame: CGRectMake(self.header!.frame.maxX - 16, 0 , widthFilter, self.header!.frame.height))
            self.filterView?.delegate = self
        }//if filterView==nil{
        
        self.header?.addSubview(filterView!)
        var view = UIView(frame:CGRectMake(self.header!.frame.maxX - 16, 0, 16, 46))
        view.backgroundColor = WMColor.light_light_gray
        self.header?.addSubview(view)
        
        self.viewAnimated = true
        
        if  self.frameTitle.maxX > minFilter {
            minLabel =   frameTitle.minX - (self.frameTitle.maxX  - minFilter)
            if minLabel > 46 {
                frameLabelTo = CGRectMake(minLabel , 0 , self.titleLabel!.frame.width, self.titleLabel!.frame.height )
            }else{
                 frameLabelTo = CGRectMake(46 , 0 ,  minFilter - 46 , self.titleLabel!.frame.height )
            }
            
            var headerFrame = self.header!.frame
            
            UIView.animateWithDuration(0.25, animations: {
                self.filterView!.frame = CGRectMake(self.titleLabel!.frame.maxX, headerFrame.minY , 313, headerFrame.height)
                }, completion: {(bool : Bool) in
                    if bool {
                        UIView.animateWithDuration(0.25, animations: {
                            self.filterView!.frame = CGRectMake(minFilter, headerFrame.minY , 313, headerFrame.height)
                            self.titleLabel!.frame  = frameLabelTo
                            }, completion: {(bool : Bool) in
                                if bool {
                                    view.removeFromSuperview()
                                     self.viewAnimated = false
                                }
                        })
                    }
            })
            
        }
        else {
            var headerFrame = self.header!.frame
            UIView.animateWithDuration(0.5, animations: {
                self.filterView!.frame = CGRectMake(minFilter, headerFrame.minY , 313, headerFrame.height)
                self.titleLabel!.frame  = frameLabelTo
                }, completion: {(bool : Bool) in
                    if bool {
                        view.removeFromSuperview()
                        self.viewAnimated = false
                    }
            })
        }
    }

    override func removeFilter(){
        var view = UIView(frame:CGRectMake(self.header!.frame.maxX - 16, 0, 16, 46))
        view.backgroundColor = WMColor.light_light_gray
        self.header?.addSubview(view)
        self.viewAnimated = true
        
        if  self.frameTitle.width > self.titleLabel!.frame.width{
            UIView.animateWithDuration(0.25, animations: {
                    self.filterView!.frame = CGRectMake(self.frameTitle.maxX, 0 , 320, self.header!.frame.height)
                }, completion: {(bool : Bool) in
                    if bool {
                        UIView.animateWithDuration(0.25, animations: {
                            self.filterView!.frame = CGRectMake(self.header!.frame.maxX - 16, 0 , 320, self.header!.frame.height)
                             self.titleLabel!.frame = self.frameTitle
                            }, completion: {(bool : Bool) in
                                if bool {
                                    view.removeFromSuperview()
                                    self.filterView!.removeFromSuperview()
                                    self.viewAnimated = false
                                }
                        })
                    }
            })
        }
        else {
            UIView.animateWithDuration(0.5, animations: {
                self.titleLabel!.frame = self.frameTitle
                self.filterView!.frame = CGRectMake(self.header!.frame.maxX - 16, 0 , 320
                , self.header!.frame.height)
                }, completion: {(bool : Bool) in
                    if bool {
                        view.removeFromSuperview()
                        self.filterView!.removeFromSuperview()
                        self.viewAnimated = false
                    }
            })
        }
        
    }
    */
    
    
    
    override func productCellIdentifier() -> String {
        return "iPAProductSearch"
    }
    
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 && self.searchContextType == SearchServiceContextType.WithCategoryForGR && self.titleHeader ==  "Recomendados"  {
            return CGSizeZero
        }
        
        if section == 0 && self.searchContextType == SearchServiceContextType.WithCategoryForGR && self.searchFromContextType == SearchServiceFromContext.FromLineSearch  {
            return CGSizeZero
        }
        
        
        if section == 0 && self.searchContextType == SearchServiceContextType.WithCategoryForGR && !self.isTextSearch && self.searchFromContextType == SearchServiceFromContext.FromSearchTextSelect {
            return CGSizeZero
        }
        
        if section == 0 && self.searchContextType == SearchServiceContextType.WithCategoryForMG && !self.isTextSearch && self.searchFromContextType == SearchServiceFromContext.FromSearchTextSelect {
            return CGSizeZero
        }
        
        if section == 0 && self.isOriginalTextSearch {
            return CGSizeZero
        }
        
        if section == 0 && self.searchContextType == SearchServiceContextType.WithCategoryForGR && !self.isTextSearch {
            return CGSizeMake(self.view.frame.width, 54)
        }
        
        if section == 0 && self.searchContextType != SearchServiceContextType.WithCategoryForMG  {
            return CGSizeZero
        }
        
        if self.searchContextType == SearchServiceContextType.WithCategoryForMG && self.isTextSearch {
            return CGSizeZero
        }
        
        if section == 0 && self.originalSearchContextType == SearchServiceContextType.WithTextForCamFind {
            return CGSizeZero
        }
        
        if section == 0 && self.searchContextType == SearchServiceContextType.WithCategoryForMG && self.titleHeader ==  "Recomendados"  {
            return CGSizeZero
        }
        
        
        return CGSizeMake(self.view.frame.width, 54)
    }
    
    //MARK: SearchProductCollectionViewCellDelegate
    override func selectGRQuantityForItem(cell: SearchProductCollectionViewCell) {
        let frameDetail = CGRectMake(0,0,320,394)
        self.buildGRSelectQuantityView(cell, viewFrame: frameDetail)
        
        selectQuantityGR?.closeAction = { () in
            self.selectQuantityPopover!.dismissPopoverAnimated(true)
            
        }
        
        let viewController = UIViewController()
        viewController.view = selectQuantityGR
        viewController.view.frame = frameDetail
        selectQuantityPopover = UIPopoverController(contentViewController: viewController)
        selectQuantityPopover!.backgroundColor = WMColor.light_blue.colorWithAlphaComponent(0.9)
        selectQuantityPopover!.setPopoverContentSize(CGSizeMake(320,394), animated: true)
        selectQuantityPopover!.presentPopoverFromRect(cell.addProductToShopingCart!.bounds, inView: cell.addProductToShopingCart!, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
    }
    
    override func selectMGQuantityForItem(cell: SearchProductCollectionViewCell) {
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
                    
                    BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label:"\(cell.upc) - \(cell.desc)")
                    
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
    
    override func apply(order:String, upcs: [String]) {
        super.apply(order, upcs: upcs)
        self.filterButton?.setTitle(NSLocalizedString("Restaurar", comment:"" ) , forState: .Normal)
        self.filterButton?.frame = CGRectMake(self.view.bounds.maxX - 90 , (self.header!.frame.size.height - 22)/2 , 70, 22)
        if upcs.count == 0 {
         self.showEmptyView()
        }
        
    }
    
    override func showEmptyView(){
        self.filterButton?.alpha = 0
        let buidHeader =  self.header!.frame.maxY > 46
        if  self.empty == nil {
            self.empty = IPOGenericEmptyView(frame:CGRectMake(0,46, self.view.bounds.width, self.view.bounds.height - 46))
        }else{
            self.empty.removeFromSuperview()
            self.empty =  nil
            self.empty = IPOGenericEmptyView(frame:CGRectMake(0,46, self.view.bounds.width, self.view.bounds.height - 46))
        }
        
        self.empty.descLabel.text = "No existe ese artículo"
        self.empty.returnAction = { () in
         self.returnBack()
        }
        
        if buidHeader {
            self.emptyViewHeader = UIView()
            self.emptyViewHeader!.frame = CGRectMake(0, 0, self.view.bounds.width, 46)
            self.emptyViewHeader!.backgroundColor = WMColor.light_light_gray
            let backButton = UIButton()
            backButton.setImage(UIImage(named: "BackProduct"), forState: UIControlState.Normal)
            backButton.addTarget(self, action: #selector(NavigationViewController.back), forControlEvents: UIControlEvents.TouchUpInside)
            self.emptyViewHeader!.addSubview(backButton)
            backButton.frame = CGRectMake(0, 0  ,46,46)
            let titleLabel = UILabel()
            titleLabel.textColor =  WMColor.light_blue
            titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
            titleLabel.numberOfLines = 2
            titleLabel.text = self.titleHeader
            titleLabel.textAlignment = .Center
            titleLabel.frame = CGRectMake(46, 0, self.emptyViewHeader!.frame.width - 92, self.emptyViewHeader!.frame.maxY)
            self.emptyViewHeader!.addSubview(titleLabel)
            self.view.addSubview(self.emptyViewHeader!)
        }
        self.view.addSubview(self.empty)
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
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