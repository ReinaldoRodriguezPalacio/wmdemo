//
//  CategorySelectView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


protocol CategoryCollectionViewCellDelegate {
    func didSelectCategory(_ index:Int)
}

class CategoryCollectionViewCell: UICollectionViewCell, iCarouselDataSource, iCarouselDelegate {
    
    var categories: [String] = []
    var categoriesLabel: [Int:CategorySelectorItemView] = [:]
    var selectedCat: CategorySelectorItemView? = nil
    var carousel: iCarousel!
    var selectorIndicator: UIView!
    var delegate: CategoryCollectionViewCellDelegate!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        backgroundColor = WMColor.light_blue
        
        carousel = iCarousel(frame: self.bounds)
        carousel.scrollSpeed = 0.70
        carousel.autoresizingMask = UIViewAutoresizing()
        carousel.type = iCarouselType.linear
        carousel.delegate = self
        carousel.dataSource = self
        carousel.backgroundColor = UIColor.clear
        carousel.clipsToBounds = true
        carousel.bounceDistance = 0.3
        
        let initialW: CGFloat = 75.0
        let initialH: CGFloat = 4.0
        
        selectorIndicator = UIView(frame: CGRect(x: (frame.width / 2) - (initialW / 2), y: frame.height - initialH, width: initialW, height: initialH))
        selectorIndicator.backgroundColor = WMColor.yellow
        
        addSubview(carousel)
        addSubview(selectorIndicator)
        
    }
    
    func setCategoriesAndReloadData(_ cat: [String]) {
        categories = cat
        carousel.reloadData()
    }
    
    // MARK: - iCarouselDataSource
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return categories.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let ix = Int(index)
        let maxStrCat =  "Especiales " + categories[ix]
        let size = maxStrCat.size(attributes: [NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(16)])
        let arrayResult = categoriesLabel.keys.filter {$0 == ix}
        
        var lblView: CategorySelectorItemView? = nil
        
        if Array(arrayResult).count != 0 && categoriesLabel[ix] != nil {
            
            lblView = categoriesLabel[ix]
            lblView!.frame = CGRect(x: 0, y: 0, width: size.width + 10, height: self.frame.height)
            lblView!.title.text = categories[ix]
            lblView!.title.textColor = UIColor.white
            
            if selectedCat != nil && selectedCat == categoriesLabel[ix] {
                lblView!.setTextEspeciales()
                self.selectorIndicator.frame = CGRect(x: (self.frame.width / 2) - ((size.width + 10) / 2) , y: self.selectorIndicator.frame.minY, width: size.width + 10 , height: self.selectorIndicator.frame.height)
            } else {
                lblView!.deleteEspeciales()
            }
            
        } else {
            lblView = CategorySelectorItemView(frame: CGRect(x: 0, y: 0, width: size.width + 10, height: self.frame.height))
            lblView!.clipsToBounds = true
            lblView!.title.text = categories[ix]
            lblView!.title.textColor = UIColor.white
            categoriesLabel[ix] = lblView!
            lblView!.deleteEspeciales()
        }
        
        return lblView!
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        var cvalue: CGFloat? = nil
        
        switch (option) {
        case .wrap:         cvalue = 0.0
        case .tilt:         cvalue = 0.0
        case .spacing:      cvalue = value
        case .visibleItems: cvalue = visibleItems()
        case .fadeMax:      cvalue = 0.0
        case .fadeMin:      cvalue = 0.0
        case .fadeRange:    cvalue = 5.0
        default:            cvalue = value
        
        }
        return cvalue!
    }
    
    func carouselItemWidth(_ carousel: iCarousel) -> CGFloat {
        
        let indicatorWidth: CGFloat = self.selectorIndicator.frame.width + 10
        let maxWidth: CGFloat = 180
        
        if IS_IPAD {
            return 230
        } else if indicatorWidth <= maxWidth {
            return indicatorWidth
        }
        
        return maxWidth
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        changeSizeOfIndicator(carousel.currentItemIndex)
    }
    
    func carousel(_ carousel: iCarousel, shouldSelectItemAt index: Int) -> Bool {
        return true
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
    }
    
    func changeSizeOfIndicator(_ index: Int) {
        
        if categories.count > 0 {
            UserCurrentSession.sharedInstance.nameListToTag = "Especiales " + categories[index]
        }
        
        if selectedCat != nil && self.selectedCat != categoriesLabel[index] {
            self.selectedCat!.deleteEspeciales()
        }
        
        if categoriesLabel.count > 0 {
            if self.selectedCat != categoriesLabel[index] {
                
                if categoriesLabel.count > 0 {
                    self.selectedCat = categoriesLabel[index]
                    self.selectedCat!.setTextEspeciales()
                    delegate.didSelectCategory(index)
                    self.carousel.reloadItem(at: index, animated: false)
                    self.carousel.reloadItem(at: index + 1, animated: false)
                }
                
            }
        }
        
    }
    
    func visibleItems() -> CGFloat {
        let visibleItms : CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 3.0 : 7.0
        return visibleItms
    }
    
}
