//
//  CategorySelectView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


protocol CategoryCollectionViewCellDelegate {
    func didSelectCategory(index:Int)
}

class CategoryCollectionViewCell : UICollectionViewCell,iCarouselDataSource, iCarouselDelegate {
    
    
    var categories : [String] = []
    var categoriesLabel : [Int:CategorySelectorItemView] = [:]
    var selectedCat : CategorySelectorItemView? = nil
    var carousel : iCarousel!
    var selectorIndicator : UIView!
    var delegate : CategoryCollectionViewCellDelegate!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        self.backgroundColor = WMColor.categorySelectorHomeBgColor
        
        carousel = iCarousel(frame: self.bounds)
        carousel.scrollSpeed = 0.70
        carousel.autoresizingMask = .None
        carousel.type = iCarouselType.Linear
        carousel.delegate = self
        carousel.dataSource = self
        carousel.backgroundColor = UIColor.clearColor()
        carousel.clipsToBounds = true
        carousel.bounceDistance = 0.3
        
        
        var initialW : CGFloat = 75.0
        var initialH : CGFloat = 4.0
        selectorIndicator = UIView(frame: CGRectMake((self.frame.width / 2) - (initialW / 2), self.frame.height - initialH, initialW, initialH))
        selectorIndicator.backgroundColor = WMColor.categorySelectorIndicatorHomeBgColor
        
        self.addSubview(carousel)
        self.addSubview(selectorIndicator)
        
    }
    
    func setCategoriesAndReloadData(cat:[String]){
        categories = cat
        carousel.reloadData()
    }
    
    // MARK: - iCarouselDataSource
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return categories.count
    }
    
    
    
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        let ix = Int(index)//Int(index)
        var lblView : CategorySelectorItemView? = nil
        let maxStrCat =  "Especiales " + categories[ix]
        let size = maxStrCat.sizeWithAttributes([NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(16)])
        //if categoriesLabel.count <= ix || categoriesLabel.count == 0 {
        let arrayResult =  categoriesLabel.keys.filter {$0 == ix}
        if  arrayResult.array.count != 0 && categoriesLabel[ix] != nil {
            lblView = categoriesLabel[ix]
            lblView!.frame = CGRectMake(0, 0, size.width + 15, self.frame.height)
            lblView!.title.text = categories[ix]
            lblView!.title.textColor = UIColor.whiteColor()
            //lblView!.centerText()
            if selectedCat != nil && self.selectedCat == categoriesLabel[ix] {
                lblView!.setTextEspeciales()
                self.selectorIndicator.frame = CGRectMake((self.frame.width / 2) - ((size.width + 10) / 2) , self.selectorIndicator.frame.minY, size.width + 10 , self.selectorIndicator.frame.height)
            } else {
                lblView!.deleteEspeciales()
            }
        }else {
            lblView = CategorySelectorItemView(frame: CGRectMake(0, 0, size.width + 15, self.frame.height))
            lblView!.clipsToBounds = true
            lblView!.title.text = categories[ix]
            lblView!.title.textColor = UIColor.whiteColor()
            categoriesLabel[ix] = lblView!
            lblView!.deleteEspeciales()
        }
        return lblView!
    }
    
    func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        var cvalue: CGFloat? = nil
        switch (option) {
        case .Wrap:         cvalue = 0.0
        case .Tilt:         cvalue = 0.0
        case .Spacing:      cvalue = value
        case .VisibleItems: cvalue = visibleItems()
            //case .Arc:          cvalue = 10.0
        case .FadeMax:      cvalue = 0.0
        case .FadeMin:      cvalue = 0.0
        case .FadeRange:    cvalue = 5.0
        default:            cvalue = value
        }
        return cvalue!
    }
    
    
    func carouselDidEndScrollingAnimation(carousel: iCarousel!) {
        changeSizeOfIndicator(carousel.currentItemIndex)
    }
    
    func carousel(carousel: iCarousel!, shouldSelectItemAtIndex index: Int) -> Bool {
        return true;
    }
    
    
    func carousel(carousel: iCarousel!, didSelectItemAtIndex index: Int)  {
        //changeSizeOfIndicator(index)
    }
    
    
    func changeSizeOfIndicator(index:Int) {
        
        if selectedCat != nil && self.selectedCat !=  categoriesLabel[index] {
            let strEnd = self.selectedCat!.title!.text! as NSString
            //self.selectedCat!.title!.text = strEnd.stringByReplacingOccurrencesOfString("Especiales ", withString: "")
            self.selectedCat!.deleteEspeciales()
        }
        if categoriesLabel.count > 0 {
            if self.selectedCat !=  categoriesLabel[index] {
                if categoriesLabel.count > 0 {
                    
                    
                    self.selectedCat = categoriesLabel[index]
                    //let resultText = "Especiales " + self.selectedCat!.title!.text!
                    
                    
                    
                    //self.selectedCat!.title!.text =  resultText
                    
                    let strCategory = "Especiales " + self.selectedCat!.title!.text!
                    let size = strCategory.sizeWithAttributes([NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(16)])
                    
                    self.selectedCat!.setTextEspeciales()
                    
                    //                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                    //                        self.selectorIndicator.frame = CGRectMake((self.frame.width / 2) - ((size.width + 10) / 2) , self.selectorIndicator.frame.minY, size.width + 5, self.selectorIndicator.frame.height)
                    //                    })
                    
                    
                    //Event
                    if let tracker = GAI.sharedInstance().defaultTracker {
                        tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_HOME.rawValue,
                            action: WMGAIUtils.EVENT_SPECIALCHANGE.rawValue ,
                            label: self.selectedCat!.title!.text!,
                            value: nil).build() as [NSObject : AnyObject])
                    }
                    
                    
                    delegate.didSelectCategory(index)
                    self.carousel.reloadItemAtIndex(index, animated: false)
                    self.carousel.reloadItemAtIndex(index + 1, animated: false)
                }
            }
        }
        
    }
    
    func visibleItems() -> CGFloat {
        let visibleItms : CGFloat = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 3.0 : 7.0
        return visibleItms
    }

    
    
}