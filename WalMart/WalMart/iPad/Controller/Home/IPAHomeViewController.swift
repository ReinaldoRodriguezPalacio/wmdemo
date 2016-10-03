//
//  IPAHomeViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAHomeViewController : HomeViewController {
    
    var currentCellSelected : NSIndexPath!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.registerClass(IPABannerCollectionViewCell.self, forCellWithReuseIdentifier: "iPABannerHome")
        collection.registerClass(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "iPACategoryHome")
        collection.registerClass(IPAProductHomeCollectionViewCell.self, forCellWithReuseIdentifier: "iPAProductHome")
        
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowHomeSelected.rawValue, object: nil)
    }
    
    override func showPleca(){
        print("::::showPleca:::")
        if plecaItems !=  nil  && plecaItems!.count > 0{
            if alertBank ==  nil {
                alertBank = UIView(frame:CGRectMake(0, 0, self.view.frame.width, 0))
                alertBank!.backgroundColor = WMColor.dark_blue.colorWithAlphaComponent(0.9)
                self.view.addSubview(alertBank!)
            }
            let maxStrCat =  plecaItems?["terms"] as? String
            let size = maxStrCat!.sizeWithAttributes([NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(12)])
            
            if titleView ==  nil {
                titleView =  UILabel(frame: CGRectMake((self.view.frame.width/2) - (size.width / 2), 0, size.width, alertBank!.frame.height))
            }
            titleView!.font = WMFont.fontMyriadProRegularOfSize(12)
            titleView!.textColor = UIColor.whiteColor()
            titleView!.text = plecaItems?["terms"] as? String
            titleView!.textAlignment = .Left
            titleView?.alpha = 0
            self.alertBank!.addSubview(titleView!)
            if detailsButton ==  nil{
                detailsButton = UIButton(frame: CGRectMake(titleView!.frame.maxX + 5, 12, 55, 22))
            }
            detailsButton.backgroundColor = WMColor.green
            detailsButton!.layer.cornerRadius = 11.0
            detailsButton!.setTitle("Detalles", forState:.Normal)
            detailsButton!.addTarget(self, action: #selector(HomeViewController.openDetailPleca), forControlEvents: .TouchUpInside)
            detailsButton!.setTitleColor(WMColor.light_light_gray, forState: .Normal)
            detailsButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
            detailsButton.alpha = 0
            self.alertBank!.addSubview(detailsButton!)
            if imageNotification ==  nil {
                self.imageNotification = UIImageView(frame:CGRectMake(self.titleView!.frame.minX - 17 ,alertBank!.frame.midY-6,12,12))
            }
            self.imageNotification?.image = UIImage(named: "notification_icon")
            imageNotification?.alpha =  0
            self.alertBank!.addSubview(imageNotification!)
            
     
            
    
            
            UIView.animateWithDuration(0.2, animations: {
                self.alertBank?.frame = CGRectMake(0, 0, self.view.frame.width, 46)
                self.titleView!.frame = CGRectMake((self.view.frame.width/2) - (size.width / 2), 0,size.width, self.alertBank!.frame.height)
                self.detailsButton.frame = CGRectMake(self.titleView!.frame.maxX + 5, 12, 55, 22)
                self.imageNotification?.frame = CGRectMake(self.titleView!.frame.minX - 17 ,self.alertBank!.frame.midY-6,12,12)

                }, completion: {(bool : Bool) in
                        self.alertBank?.alpha = 1
                        self.titleView?.alpha = 1
                        self.detailsButton?.alpha = 1
                        self.imageNotification?.alpha = 1
                        self.startTimmerPleca()
                    
                    
            })
            
        }
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            return CGSizeMake(1024, 274)
        case (0,1):
            return CGSizeMake(1024, 46)
        default:
            return CGSizeMake(self.view.frame.width / 4, 192)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            
            let catNameFilter = self.categories[selectedIndexCategory]
            let arrayItems : AnyObject = self.recommendCategoryItems[catNameFilter]!
            let arrayItemsResult =  arrayItems as! [AnyObject]
          
            let paginatedProductDetail = IPAProductDetailPageViewController()
            paginatedProductDetail.ixSelected = indexPath.row
            paginatedProductDetail.itemsToShow = []
            for productRecomm  in arrayItemsResult {
                
                var desc = ""
                var upc = ""
                
                if let sku = productRecomm["sku"] as? NSDictionary {
                    if let parentProducts = sku.objectForKey("parentProducts") as? NSArray{
                        if let item =  parentProducts.objectAtIndex(0) as? NSDictionary {
                            upc = item["id"] as? String ?? ""
                            desc = item["longDescription"] as! String
                        }
                    }
                }
            
                
                let type = self.categoryType[catNameFilter]! == "gr" ? "groceries" : "mg"

                paginatedProductDetail.itemsToShow.append(["upc":upc,"description":desc,"type":type])
                
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SPECIAL_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SPECIAL_DETAILS.rawValue, action: WMGAIUtils.ACTION_SHOW_PRODUCT_DETAIL.rawValue, label: "\(desc) - \(upc)")
                
            }
            
            let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! IPAProductHomeCollectionViewCell!
            currentCellSelected = indexPath
            let pontInView = currentCell.convertRect(currentCell!.productImage!.frame, toView:  self.view)
            paginatedProductDetail.animationController = ProductDetailNavigatinAnimationController(nav:self.navigationController!)
            paginatedProductDetail.animationController.originPoint =  pontInView
            paginatedProductDetail.animationController.setImage(currentCell!.productImage!.image!)
            currentCell.hideImageView()
           
            self.navigationController?.delegate = paginatedProductDetail
            self.navigationController?.pushViewController(paginatedProductDetail, animated: true)
           
        }
    }
    
    override func openLandinCampaign(urlTicer:String,idFamily:String){
        
        let controller = IPALinesViewController()
        controller.urlTicer = urlTicer
        controller.familyId = idFamily
        controller.searchContextType =  .WithCategoryForMG
        controller.frameStart =  CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        controller.frameEnd =  CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        

        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func showFindUpc(upcs:NSArray,type:String){
        let controller = IPASearchProductViewController()
        if type == "mg" {
            controller.searchContextType = .WithCategoryForMG
        }else {
            controller.searchContextType = .WithCategoryForGR
        }
        controller.findUpcsMg = upcs as? [String]
        controller.titleHeader = "Recomendados"
        self.navigationController!.pushViewController(controller, animated: true)
        
        
    }
    
    func reloadSelectedCell() {
        if currentCellSelected != nil {
            if let currentCell = collection.cellForItemAtIndexPath(currentCellSelected) as? IPAProductHomeCollectionViewCell {
                currentCell.showImageView()
            }
        }
        
    }
    
    override func bannerCellIdentifier() -> String {
        return "iPABannerHome"
    }
    
    override func productCellIdentifier() -> String {
        return "iPAProductHome"
    }
    
    override func showProductDetail(upcProduct:String,type:String){
        let controller = IPAProductDetailPageViewController()
        controller.itemsToShow = [["upc":upcProduct,"description":"","type":type]]
        
        willHideTabbar()
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.HideBar.rawValue, object: nil)
        
        self.navigationController!.delegate = nil
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func showProducts(forDepartmentId depto: String?, andFamilyId family: String?, andLineId line: String?,type:String){
        let controller = IPASearchProductViewController()
        if type == "mg" {
            controller.searchContextType = .WithCategoryForMG
        }else {
            controller.searchContextType = .WithCategoryForGR
        }
        controller.idFamily  = family == nil ? "_" :  family
        controller.idDepartment = depto == nil ? "_" :  depto
        controller.idLine = line
        controller.titleHeader = "Recomendados"
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     Open BackToSchoolCategory
     */
   override func openBackToSchoolCategory(urlTicer:String,idFamily:String){
        let controller = IPABackToSchoolContainerViewController()
        controller.urlTicer = urlTicer
        controller.departmentId = idFamily
        self.navigationController!.pushViewController(controller, animated: true)
    }

}