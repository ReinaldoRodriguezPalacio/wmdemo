//
//  IPASearchProductViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
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
    
    override func viewDidLoad() {
        self.maxResult = 23
        super.viewDidLoad()
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        collection?.register(IPASearchProductCollectionViewCell.self, forCellWithReuseIdentifier: "iPAProductSearch")
        collection?.frame = self.view.bounds
    }

    override func viewWillLayoutSubviews() {
        self.loading!.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentCellSelected != nil {
            self.reloadSelectedCell()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width / 3, height: 254);
    }
    
   // override func returnBack() {
   //    viewHeader.dismissPopover()
   // }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       print("Articulo seleccionado \((indexPath as NSIndexPath).row)")
        
        let cell = self.collection?.cellForItem(at: indexPath)
        if cell!.isKind(of: SearchProductCollectionViewCell.self){
            if (indexPath as NSIndexPath).row < self.allProducts!.count {

                let paginatedProductDetail = IPAProductDetailPageViewController()
                paginatedProductDetail.idListSeleted = self.idListFromSearch
                paginatedProductDetail.ixSelected = (indexPath as NSIndexPath).row
                paginatedProductDetail.itemSelectedSolar = self.isAplyFilter ? "" : "\((indexPath as NSIndexPath).row)"
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
            
                let currentCell = collectionView.cellForItem(at: indexPath) as! IPASearchProductCollectionViewCell!
                currentCellSelected = indexPath
                let pontInView = currentCell?.convert(currentCell!.productImage!.frame, to:  self.view)
                //let pontInView =  currentCell.productImage?.convertRect(currentCell!.productImage!.frame, toView: self.view)
                paginatedProductDetail.isForSeach = (self.textToSearch != nil && self.textToSearch != "")
                paginatedProductDetail.animationController = ProductDetailNavigatinAnimationController(nav:self.navigationController!)
                paginatedProductDetail.animationController.originPoint =  pontInView
                paginatedProductDetail.animationController.setImage(currentCell!.productImage!.image!)
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
    
    /*override func apply(_ order:String, filters:[String:Any]?, isForGroceries flag:Bool) {
        super.apply(order, filters: filters, isForGroceries: flag)
        self.filterButton?.setTitle(NSLocalizedString("restaurar", comment:"" ) , for: UIControlState())
        self.filterButton?.frame = CGRect(x: self.view.bounds.maxX - 90 , y: (self.header!.frame.size.height - 22)/2 , width: 70, height: 22)
        
    }*/
    
    override func filter(_ sender:UIButton){
        if self.filterController == nil {
            self.filterController = FilterProductsViewController()
            self.filterController!.hiddenBack = true
            self.filterController!.textToSearch = self.textToSearch
            self.filterController!.selectedOrder = self.idSort!
            self.filterController!.delegate = self
            self.filterController!.originalSearchContext = self.originalSearchContextType == nil ? self.searchContextType : self.originalSearchContextType
            self.filterController!.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 390.0)
            self.filterController!.view.backgroundColor = UIColor.clear
            self.filterController!.successCallBack  = { () in
                self.sharePopover?.dismiss(animated: true)
                return
            }
        }
        self.filterController?.selectedOrder = ""
        self.filterController!.filtersAll = self.facet
        self.filterController!.filterOrderViewCell?.resetOrderFilter()
        self.filterController!.upcPrices =  nil
        self.filterController!.selectedElementsFacet = [:]
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
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 && self.searchContextType == SearchServiceContextType.WithCategoryForGR && self.titleHeader ==  "Recomendados"  {
            return CGSize.zero
        }
        
        if section == 0 && self.searchContextType == SearchServiceContextType.WithCategoryForGR && self.searchFromContextType == SearchServiceFromContext.FromLineSearch  {
            return CGSize.zero
        }
        
        
        if section == 0 && self.searchContextType == SearchServiceContextType.WithCategoryForGR && !self.isTextSearch && self.searchFromContextType == SearchServiceFromContext.FromSearchTextSelect {
            return CGSize.zero
        }
        
        if section == 0 && self.searchContextType == SearchServiceContextType.WithCategoryForMG && !self.isTextSearch && self.searchFromContextType == SearchServiceFromContext.FromSearchTextSelect {
            return CGSize.zero
        }
        
        if section == 0 && self.isOriginalTextSearch {
            return CGSize.zero
        }
        
        if section == 0 && self.searchContextType == SearchServiceContextType.WithCategoryForGR && !self.isTextSearch {
            return CGSize(width: self.view.frame.width, height: 54)
        }
        
        if section == 0 && self.searchContextType != SearchServiceContextType.WithCategoryForMG  {
            return CGSize.zero
        }
        
        if self.searchContextType == SearchServiceContextType.WithCategoryForMG && self.isTextSearch {
            return CGSize.zero
        }
        
        if section == 0 && self.originalSearchContextType == SearchServiceContextType.WithTextForCamFind {
            return CGSize.zero
        }
        
        if section == 0 && self.searchContextType == SearchServiceContextType.WithCategoryForMG && self.titleHeader ==  "Recomendados"  {
            return CGSize.zero
        }
        
        
        return CGSize(width: self.view.frame.width, height: 54)
    }
    
    //MARK: SearchProductCollectionViewCellDelegate
    override func selectGRQuantityForItem(_ cell: SearchProductCollectionViewCell) {
        let frameDetail = CGRect(x: 0,y: 0,width: 320,height: 394)
        self.buildGRSelectQuantityView(cell: cell, viewFrame: frameDetail)
        
        selectQuantityGR?.closeAction = { () in
            self.selectQuantityPopover!.dismiss(animated: true)
            
        }
        
        let viewController = UIViewController()
        viewController.view = selectQuantityGR
        viewController.view.frame = frameDetail
        selectQuantityPopover = UIPopoverController(contentViewController: viewController)
        selectQuantityPopover!.backgroundColor = WMColor.light_blue.withAlphaComponent(0.9)
        selectQuantityPopover!.setContentSize(CGSize(width: 320,height: 394), animated: true)
        selectQuantityPopover!.present(from: cell.addProductToShopingCart!.bounds, in: cell.addProductToShopingCart!, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
    }
    
    override func selectMGQuantityForItem(_ cell: SearchProductCollectionViewCell) {
        let frameDetail = CGRect(x: 0,y: 0,width: 320,height: 394)
        self.buildMGSelectQuantityView(cell: cell, viewFrame: frameDetail)
        
        selectQuantity?.closeAction = { () in
            self.selectQuantityPopover!.dismiss(animated: true)
            
        }
        
        selectQuantity!.addToCartAction =
            { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                let maxProducts = (cell.onHandInventory.integerValue <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory.integerValue : 5
                if maxProducts >= Int(quantity) {
                    let params = self.buildParamsUpdateShoppingCart(cell: cell,quantity: quantity,position:cell.positionSelected)//position
                    
                    //BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label:"\(cell.upc) - \(cell.desc)")
                    
                    UIView.animate(withDuration: 0.2,
                        animations: { () -> Void in
                            self.selectQuantity!.closeAction()
                        },
                        completion: { (animated:Bool) -> Void in
                            self.selectQuantity = nil
                            //CAMBIA IMAGEN CARRO SELECCIONADO
                            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
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
    
    override func apply(_urlSort: String) {
        print("aply filter")
        self.isAplyFilter = true
        self.urlFamily = _urlSort
        self.textToSearch = ""
        self.collection!.reloadData()
        self.showLoadingIfNeeded(hidden: false)
        
        //reset table
        self.getServiceProduct(resetTable: false)
        
        if self.filterController != nil {
            self.filterController!.selectedOrder! =  ""
            self.filterController!.filtersAll = self.facet
            self.filterController!.filterOrderViewCell?.resetOrderFilter()
            self.filterController!.upcPrices =  nil
            self.filterController!.selectedElementsFacet = [:]
            self.filterController!.showLoadingIfNeeded(hidden: true)
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
        
        self.empty.descLabel.text = "No existe ese artículo"
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
