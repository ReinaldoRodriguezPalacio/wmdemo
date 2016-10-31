//
//  IPAProductDetailPageViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/14/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class IPAProductDetailPageViewController : ProductDetailPageViewController,UINavigationControllerDelegate {
    
    var animationController : ProductDetailNavigatinAnimationController!
    
    
    override func getControllerToShow(_ upc:String,descr:String,type:String,saving:String?,sku:String ) -> UIViewController? {
            
        storyBoard = loadStoryboardDefinition()
        switch(type) {
        case ResultObjectType.Mg.rawValue :
            if let vc = storyBoard!.instantiateViewController(withIdentifier: "productDetailVC") as? IPAProductDetailViewController {
                vc.upc = upc as NSString
                vc.sku = sku as NSString
                //vc.indexRowSelected = self.itemSelectedSolar // ixSelected
                vc.name = descr as NSString
                vc.stringSearch = self.stringSearching
                vc.view.tag = ixSelected
                vc.pagerController = self
                return vc
            }
        case ResultObjectType.Groceries.rawValue :
            if let vc = storyBoard!.instantiateViewController(withIdentifier: "productDetailVC") as? IPAProductDetailViewController {
                vc.upc = upc as NSString
                vc.sku = sku as NSString
                vc.indexRowSelected = self.itemSelectedSolar//ixSelected
                vc.stringSearch = self.stringSearching
                vc.name = descr as NSString
                vc.view.tag = ixSelected
                vc.saving = saving == nil ? "" : saving! as NSString
                vc.pagerController = self
                vc.idListSelected =  self.idListSeleted!
               
                
                return vc
            }
        default:
            return nil
        }
        return nil
    }
    
    /* func getControllerToShow(upc:String,descr:String) -> UIViewController? {
        storyBoard = loadStoryboardDefinition()
        if let vc = storyBoard!.instantiateViewControllerWithIdentifier("productDetailVC") as? IPAProductDetailViewController! {
            vc.upc = upc
            vc.name = descr
            vc.view.tag = ixSelected
            vc.pagerController = self
            return vc
        }
        return nil
        
    }*/
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if animationController != nil {
        switch (operation) {
        case UINavigationControllerOperation.push:
            animationController.type = AnimationType.present;
            return  animationController;
        case UINavigationControllerOperation.pop:
            animationController.type = AnimationType.dismiss;
            return animationController;
        default: return nil;
        }
        }
        return nil
        
    }
    
    func reloadSelectedCell() {

        if let ctrlDetail = pageController.viewControllers![0] as? IPAProductDetailViewController {
            ctrlDetail.reloadSelectedCell()
            
        }
    
    }

    
}
