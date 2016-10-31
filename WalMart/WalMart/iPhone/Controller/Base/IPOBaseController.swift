//
//  IPOBaseController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPOBaseController : BaseController {
    
    var controllerTabStateVisible : Bool = true
    var startContentOffset: CGFloat? = 0
    var originalInset: UIEdgeInsets? = nil
    var lastContentOffset: CGFloat? = 0
    var isVisibleTab: Bool = true
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.startContentOffset = scrollView.contentOffset.y
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset: CGFloat = scrollView.contentOffset.y
        let differenceFromStart: CGFloat = self.startContentOffset! - currentOffset
        let differenceFromLast: CGFloat = self.lastContentOffset! - currentOffset
        lastContentOffset = currentOffset;
        
        if differenceFromStart < 0 && !TabBarHidden.isTabBarHidden && !IS_IPAD {
            
            
            if(scrollView.isTracking && (abs(differenceFromLast)>0.20)) {
                
                var insetToUse : CGFloat = scrollView.contentInset.bottom  - 45
                if insetToUse < 0 {
                    insetToUse = CGFloat(0)
                }
                if let collectionView = scrollView as? UICollectionView {
                    if let layoutFlow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        if originalInset == nil {
                            originalInset = layoutFlow.sectionInset
                        }
                        insetToUse = layoutFlow.sectionInset.bottom  - 45
                        if insetToUse < 0 {
                            insetToUse = layoutFlow.sectionInset.bottom
                        }
                        layoutFlow.sectionInset = UIEdgeInsetsMake(layoutFlow.sectionInset.top, layoutFlow.sectionInset.left,  insetToUse, layoutFlow.sectionInset.right)
                    }
                }
                if let tableView = scrollView as? UITableView {
                    tableView.contentInset = UIEdgeInsetsMake(0, 0, insetToUse, 0)
                }
                if let scroll = scrollView as? TPKeyboardAvoidingScrollView {
                    scroll.contentInset = UIEdgeInsetsMake(0, 0, insetToUse, 0)
                }
                
                willHideTabbar()
                isVisibleTab = false
                TabBarHidden.isTabBarHidden = true
                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.HideBar.rawValue), object: nil)
            }
        }
        if (differenceFromStart > 0 && TabBarHidden.isTabBarHidden) && !IS_IPAD{
            
            
            if(scrollView.isTracking && (abs(differenceFromLast)>0.20)) {
                
                if let collectionView = scrollView as? UICollectionView {
                    if let layoutFlow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        if originalInset == nil {
                            originalInset = layoutFlow.sectionInset
                        }
                        layoutFlow.sectionInset = UIEdgeInsetsMake(layoutFlow.sectionInset.top, layoutFlow.sectionInset.left, originalInset!.bottom + 45, layoutFlow.sectionInset.right)
                    }
                }
                if let tableView = scrollView as? UITableView {
                    tableView.contentInset = UIEdgeInsetsMake(0, 0, scrollView.contentInset.bottom + 45, 0)
                }
                if let scroll = scrollView as? TPKeyboardAvoidingScrollView {
                    scroll.contentInset = UIEdgeInsetsMake(0, 0, scrollView.contentInset.bottom + 45, 0)
                }
                /*if let scroll = scrollView as? UIWebView {
                scroll.contentInset = UIEdgeInsetsMake(0, 0, 45, 0)
                }*/
                willShowTabbar()
                isVisibleTab = true
                TabBarHidden.isTabBarHidden = false
                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ShowBar.rawValue), object: nil)
            }
        }
    }
    
    func willShowTabbar() {
        
    }
    
    func willHideTabbar() {
        
    }
    
}
