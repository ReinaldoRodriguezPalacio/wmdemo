//
//  IPASearchCatProductViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/5/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPASearchCatProductViewController : IPASearchProductViewController {
    
    
    var imageBgCategory : UIImage?
    var imageIconCategory : UIImage?
    var titleCategory : String?
    var delegateHeader : IPACategoriesResultViewController!
   
    var delegateImgHeader : IPACatHeaderSearchReusableDelegate!
    //var showHeader: Bool = false

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        collection?.registerClass(IPASectionHeaderSearchReusable.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collection?.registerClass(IPACatHeaderSearchReusable.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage")
        
        if let layoutFlow = collection!.collectionViewLayout as? UICollectionViewFlowLayout {
            layoutFlow.headerReferenceSize = CGSizeMake(1024, 44)
        }
        self.header?.removeFromSuperview()
        
        self.collection!.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        
        
        loading?.stopAnnimating()
        
        self.loading = WMLoadingView(frame: CGRectMake(0, 216, self.view.bounds.width, self.view.bounds.height - 216))
        
        
    }
    
    

    
    override func viewWillLayoutSubviews() {
        contentCollectionOffset = CGPointZero
        self.collection!.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
    }
    
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSizeMake(self.view.frame.width, 54)
    }
 
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let reusableView : UICollectionReusableView? = nil
        
        if kind == CSStickyHeaderParallaxHeader {
            let view = collection?.dequeueReusableSupplementaryViewOfKind(CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage", forIndexPath: indexPath) as! IPACatHeaderSearchReusable
            
            view.setValues(imageBgCategory,imgIcon: imageIconCategory,titleStr: titleCategory!)
            view.delegate = delegateImgHeader
            
            
            return view
        }
        if kind == UICollectionElementKindSectionHeader {
            let view = collection?.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as! IPASectionHeaderSearchReusable
            self.header!.frame = CGRectMake(0, 0, 1024, 44)
            
            self.filterButton!.frame = CGRectMake(1024 - 87, 0 , 87, 46)
            
            view.addSubview(self.header!)
            view.sendSubviewToBack(self.header!)
            view.delegate = delegateHeader
            
            
            view.title!.setTitle(titleHeader, forState: UIControlState.Normal)
            
            
            let attrStringLab = NSAttributedString(string:titleHeader!, attributes: [NSFontAttributeName : view.title!.titleLabel!.font])
            

            let rectSize = attrStringLab.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
            let wTitleSize = rectSize.width + 48
            view.title!.frame = CGRectMake((1024 / 2) -  (wTitleSize / 2), (self.header!.frame.height / 2) - 12, wTitleSize, 24)
            
            viewHeader = view
            
            return view
        }
        
        return reusableView!
        
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
    
    
    override func getCollectionView() -> UICollectionView {
        let customlayout = CSStickyHeaderFlowLayout()
        customlayout.parallaxHeaderReferenceSize = CGSizeMake(1024, 216)
        customlayout.parallaxHeaderMinimumReferenceSize = CGSizeMake(1024, 216)
        customlayout.disableStickyHeaders = false
        //customlayout.parallaxHeaderAlwaysOnTop = true
        return UICollectionView(frame: self.view.bounds, collectionViewLayout: customlayout)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(341.33 , 254);
    }
    
//    override func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
//        return CGSizeMake(self.view.bounds.width / 3, 254);
//    }
    
    override func showLoadingIfNeeded(hidden: Bool ) {
        if hidden {
            self.loading!.stopAnnimating()
        } else {
            
            self.viewHeader.convertPoint(CGPointMake(self.view.frame.width / 2, 216), toView:self.view.superview)
            self.loading = WMLoadingView(frame: CGRectMake(0, 216, self.view.bounds.width, self.view.bounds.height - 216))
            
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(false)
        }
    }

    
    
    override func returnBack() {
        
        if self.empty != nil {
            self.empty.removeFromSuperview()
            self.empty = nil
        }
        
//        self.dismissCategory()
        self.delegateHeader.closeCategory()
    }
    
    
    func setSelectedHeaderCat(){
        self.viewHeader?.setSelected()
    }
    
    func dismissCategory() {
        self.viewHeader?.dismissPopover()
    }
  


}