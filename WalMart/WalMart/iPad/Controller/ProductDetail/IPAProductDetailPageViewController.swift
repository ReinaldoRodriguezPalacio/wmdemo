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
    
    
    override func getControllerToShow(upc:String,descr:String,type:String,saving:String?) -> UIViewController? {
            
        storyBoard = loadStoryboardDefinition()
        switch(type) {
        case ResultObjectType.Mg.rawValue :
            if let vc = storyBoard!.instantiateViewControllerWithIdentifier("productDetailVC") as? IPAProductDetailViewController {
                vc.upc = upc
                vc.indexRowSelected = self.itemSelectedSolar // ixSelected
                vc.name = descr
                vc.stringSearch = self.stringSearching
                vc.view.tag = ixSelected
                vc.pagerController = self
                vc.detailOf = self.detailOf
                return vc
            }
        case ResultObjectType.Groceries.rawValue :
            if let vc = storyBoard!.instantiateViewControllerWithIdentifier("grProductDetailVC") as? IPAGRProductDetailViewController {
                vc.upc = upc
                vc.indexRowSelected = self.itemSelectedSolar//ixSelected
                vc.stringSearch = self.stringSearching
                vc.name = descr
                vc.view.tag = ixSelected
                vc.saving = saving == nil ? "" : saving!
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
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if animationController != nil {
        switch (operation) {
        case UINavigationControllerOperation.Push:
            animationController.type = AnimationType.Present;
            return  animationController;
        case UINavigationControllerOperation.Pop:
            animationController.type = AnimationType.Dismiss;
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