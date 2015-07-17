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

    }
    
    override func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            return CGSizeMake(1024, 274)
        case (0,1):
            return CGSizeMake(1024, 46)
        default:
            return CGSizeMake(self.view.frame.width / 4, 192)
        }
    }
    
    override func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        if indexPath.section == 1 {
            
            let catNameFilter = self.categories[selectedIndexCategory]
            let arrayItems : AnyObject = self.recommendCategoryItems[catNameFilter]!
            let arrayItemsResult =  arrayItems as [AnyObject]
          
            var paginatedProductDetail = IPAProductDetailPageViewController()
            paginatedProductDetail.ixSelected = indexPath.row
            paginatedProductDetail.itemsToShow = []
            for productRecomm  in arrayItemsResult {
                let upc = productRecomm["upc"] as NSString
                let desc = productRecomm["description"] as NSString
                let type = productRecomm["type"] as NSString
                paginatedProductDetail.itemsToShow.append(["upc":upc,"description":desc,"type":type])
                
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_HOME.rawValue , action:(type == ResultObjectType.Groceries.rawValue ? WMGAIUtils.GR_EVENT_SPECIALPRESS.rawValue : WMGAIUtils.MG_EVENT_SPECIALPRESS.rawValue), label: upc , value: nil).build())
                }
            }
            
            let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as IPAProductHomeCollectionViewCell!
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


}