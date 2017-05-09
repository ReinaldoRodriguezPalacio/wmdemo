//
//  IPASearchCatProductViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/5/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPASearchCatProductViewController: IPASearchProductViewController {
    
    var imageBgCategory : UIImage?
    var imageIconCategory : UIImage?
    var titleCategory : String?
    weak var delegateHeader : IPACategoriesResultViewController?
    weak var delegateImgHeader : IPACatHeaderSearchReusableDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection?.register(IPASectionHeaderSearchReusable.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collection?.register(IPACatHeaderSearchReusable.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage")
        
        if let layoutFlow = collection!.collectionViewLayout as? UICollectionViewFlowLayout {
            layoutFlow.headerReferenceSize = CGSize(width: 1024, height: 54)
        }
        
        self.header?.removeFromSuperview()
        self.collection!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        loading?.stopAnnimating()
        self.loading = WMLoadingView(frame: CGRect(x: 0, y: 216, width: self.view.bounds.width, height: self.view.bounds.height - 216))
        
    }
    
    override func viewWillLayoutSubviews() {
        contentCollectionOffset = CGPoint.zero
        self.collection!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.collection!.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reusableView : UICollectionReusableView? = nil
        
        if kind == CSStickyHeaderParallaxHeader {
            let view = collection?.dequeueReusableSupplementaryView(ofKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "headerimage", for: indexPath) as! IPACatHeaderSearchReusable
            
            view.setValues(imageBgCategory,imgIcon: imageIconCategory,titleStr: titleCategory!)
            view.delegate = delegateImgHeader
            
            return view
        }
        
        if kind == UICollectionElementKindSectionHeader {
            
            let view = collection?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! IPASectionHeaderSearchReusable
            self.header!.frame = CGRect(x: 0, y: 0, width: 1024, height: 54)
            self.filterButton!.frame = CGRect(x: self.view.bounds.maxX - 85, y: (self.header!.frame.size.height - 22)/2 , width: 55, height: 22)
            
            view.addSubview(self.header!)
            view.sendSubview(toBack: self.header!)
            view.delegate = delegateHeader
            
            view.title!.setTitle(titleHeader, for: UIControlState())
            
            let attrStringLab = NSAttributedString(string:titleHeader!, attributes: [NSFontAttributeName : view.title!.titleLabel!.font])
            
            let rectSize = attrStringLab.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            let wTitleSize = rectSize.width + 48
            view.title!.frame = CGRect(x: (1024 / 2) -  (wTitleSize / 2), y: (self.header!.frame.height / 2) - 12, width: wTitleSize, height: 24)
            
            viewHeader = view
            
            return view
        }
        
        return reusableView!
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    override func getCollectionView() -> UICollectionView {
        let customlayout = CSStickyHeaderFlowLayout()
        customlayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 216)
        customlayout.parallaxHeaderReferenceSize = CGSize(width: 1024, height: 216)
        customlayout.parallaxHeaderMinimumReferenceSize = CGSize(width: 1024, height: 216)
        customlayout.disableStickyHeaders = false
        //customlayout.parallaxHeaderAlwaysOnTop = true
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: customlayout)
        
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        
        return collectionView
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 341.33 , height: 254);
    }
    
    override func showLoadingIfNeeded(_ hidden: Bool ) {
        if hidden {
            self.loading!.stopAnnimating()
        } else {
            let boundsCenter : CGPoint = self.viewHeader == nil ? CGPoint(x:0 , y: 320)  : self.viewHeader!.superview!.convert(CGPoint(x: self.viewHeader!.frame.maxX,y:self.viewHeader!.frame.maxY), to: self.view)
            self.loading = WMLoadingView(frame: CGRect(x:0, y:boundsCenter.y, width: self.view.bounds.width,height: self.view.bounds.height - boundsCenter.y ))
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(false)
        }
    }
    
    override func returnBack() {
        
        if self.empty != nil {
            self.empty.removeFromSuperview()
            self.empty = nil
        }

        self.delegateHeader?.closeCategory()
    }
    
    override func showEmptyMGGRView() {
        
        if self.empty != nil {
            return
        }
        
        self.filterButton?.alpha = 0
        self.loading?.stopAnnimating()
        
        let maxY: CGFloat = 0
        
        if self.emptyMGGR == nil {
            
            let frameEmpty = CGRect(x: 0, y: maxY, width: self.view.bounds.width, height: self.view.bounds.height - maxY)
            self.emptyMGGR = IPOSearchResultEmptyView(frame: frameEmpty)
            self.emptyMGGR.isLarge = false
            self.emptyMGGR.returnAction = { () in
                self.returnBack()
            }
            
        } else {
            self.emptyMGGR.frame = CGRect(x: 0, y: maxY, width: self.view.bounds.width, height: self.view.bounds.height - maxY)
        }
        
        if self.searchContextType == .withCategoryForGR {
            self.emptyMGGR.descLabel.text = NSLocalizedString("gr.category.message.noGroceries", comment: "")
        } else {
            self.emptyMGGR.descLabel.text = NSLocalizedString("mg.category.message.noTechnology", comment: "")
        }
        
        self.view.addSubview(self.emptyMGGR)
        NotificationCenter.default.post(name: .clearSearch, object: nil)
        
    }
    
    func setSelectedHeaderCat(){
        self.viewHeader?.setSelected()
    }
    
    func dismissCategory() {
        self.viewHeader?.dismissPopover()
    }

}
