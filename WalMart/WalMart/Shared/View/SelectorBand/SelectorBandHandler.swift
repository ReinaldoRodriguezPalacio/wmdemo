//
//  SelectorBandDataSource.swift
//  WalMart
//
//  Created by neftali on 25/07/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol SelectorBandDelegate {
    func addProductQuantity(quantity:Int)
    func deleteProduct()
    func tapInPrice(quantity:Int,total:String)
    
    
    func startEdditingQuantity()
    func endEdditingQuantity()

}

class SelectorBandHandler: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {

    let animationSpeed = 0.50
    
    var delegate: SelectorBandDelegate?
    var numberOfOptions: Int?
    var selectedOption: Int = -1
    var totalString: String!
    
    var container: UIView?
    var segmented: UISegmentedControl?
    var bandLayout: UICollectionViewFlowLayout?
    var band: UICollectionView?
    var selectorNormalFont : UIFont? = nil
    var selectorSelectedFont : UIFont? = nil
    
    var timer: NSTimer?
    var isShowingScroll = false
    var isScrolling = false
    
    func buildSelector(frame:CGRect) -> UIView? {
        
        self.selectorNormalFont = WMFont.fontMyriadProRegularOfSize(16)
        self.selectorSelectedFont = WMFont.fontMyriadProRegularOfSize(20)

        var imgInsets = UIEdgeInsetsMake(15, 15, 15, 15)
        var image_normal = UIImage(named:"segmented_normal")!.resizableImageWithCapInsets(imgInsets)
        var image_highlighted = UIImage(named:"segmented_selected")!.resizableImageWithCapInsets(imgInsets)
        
        self.container = UIView(frame: frame)
        self.container!.layer.cornerRadius = 5
        self.container!.clipsToBounds = true
        
        self.bandLayout =  UICollectionViewFlowLayout()
        self.bandLayout!.minimumInteritemSpacing = 0.0
        self.bandLayout!.minimumLineSpacing = 0.0
        self.bandLayout!.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.bandLayout!.scrollDirection = .Horizontal
        self.bandLayout!.itemSize = CGSizeMake(frame.size.height + 5, frame.size.height)
        
        self.band = UICollectionView(frame: CGRectMake(frame.size.width,0.0,frame.size.width, frame.size.height), collectionViewLayout: self.bandLayout!)
        self.band!.layer.borderWidth = 1
        self.band!.layer.borderColor = WMColor.categorySelectorIndicatorHomeBgColor.CGColor
        self.band!.layer.cornerRadius = 5
        self.band!.backgroundView = UIImageView(image:image_normal)
        self.band!.showsHorizontalScrollIndicator = false
        self.band!.showsVerticalScrollIndicator = false
        self.band!.delegate = self
        self.band!.dataSource = self
        self.band!.registerClass(SelectorBandCell.self, forCellWithReuseIdentifier: "Cell")
        
        self.segmented = UISegmentedControl(items: [NSLocalizedString("product.detail.addToCart", comment:""), "1"])
        self.segmented!.frame = CGRectMake(0.0,0.0,frame.size.width, frame.size.height)
        self.segmented!.addTarget(self, action: Selector("segmentedControlAction:"), forControlEvents: .ValueChanged)
        //self.segmented!.setWidth(frame.size.width - frame.size.height, forSegmentAtIndex: 0)
        self.segmented!.setWidth(frame.size.height + 5, forSegmentAtIndex: 1)
        
        var segmentedTitleAttributes = [NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(16),
            NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.segmented!.setTitleTextAttributes(segmentedTitleAttributes, forState: .Normal)
        self.segmented!.setTitleTextAttributes(segmentedTitleAttributes, forState: .Selected)
        self.segmented!.setTitleTextAttributes(segmentedTitleAttributes, forState: .Highlighted)
        
        self.segmented!.setBackgroundImage(image_normal, forState:.Normal, barMetrics:.Default)
        self.segmented!.setBackgroundImage(image_normal, forState:.Selected, barMetrics:.Default)
        self.segmented!.setBackgroundImage(image_highlighted, forState:.Highlighted, barMetrics:.Default)
        
        var sepInsets = UIEdgeInsetsMake(15, 10, 15, 10)
        var bothSelected = UIImage(named:"segmented_bothActive")?.resizableImageWithCapInsets(sepInsets)
        self.segmented!.setDividerImage(bothSelected, forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
        var leftSelected = UIImage(named:"segmented_LActiveRInactive")?.resizableImageWithCapInsets(sepInsets)
        self.segmented!.setDividerImage(leftSelected, forLeftSegmentState:.Normal, rightSegmentState:.Highlighted, barMetrics:.Default)
        self.segmented!.setDividerImage(leftSelected, forLeftSegmentState:.Selected, rightSegmentState:.Highlighted, barMetrics:.Default)
        var rightSelected = UIImage(named:"segmented_RActiveLInactive")?.resizableImageWithCapInsets(sepInsets)
        self.segmented!.setDividerImage(rightSelected, forLeftSegmentState:.Highlighted, rightSegmentState:.Normal, barMetrics:.Default)
        self.segmented!.setDividerImage(rightSelected, forLeftSegmentState:.Highlighted, rightSegmentState:.Selected, barMetrics:.Default)
        
        self.container!.addSubview(self.segmented!)
        self.container!.addSubview(self.band!)
        self.selectedOption = 1
        
        return self.container!
    }
    
    func segmentedControlAction(segmentedControl:UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.delegate?.addProductQuantity(self.selectedOption)
        }
        if segmentedControl.selectedSegmentIndex == 1 && !self.isShowingScroll {
            self.band!.reloadData()
            if self.selectedOption > -1 {
                self.band!.scrollToItemAtIndexPath(NSIndexPath(forItem: self.selectedOption - 1, inSection: 0), atScrollPosition: .CenteredHorizontally , animated: false)
            } else {
                self.band!.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .Left , animated: false)
            }
            UIView.animateWithDuration(animationSpeed, animations:{
                var frame = self.container!.frame
                self.band!.frame = CGRectMake(0.0,0.0,frame.size.width, frame.size.height)
                }, completion: {(completed: Bool) in
                    if completed == true {
                        self.isShowingScroll = true
                        self.delegate?.startEdditingQuantity()
                        self.timer = NSTimer(fireDate:NSDate(timeIntervalSinceNow:10), interval:5.0, target:self, selector:"removeBand", userInfo:nil, repeats:true)
                        var runner = NSRunLoop.currentRunLoop()
                        runner.addTimer(self.timer!, forMode: NSDefaultRunLoopMode)
                    }
                })
        }
        segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    func removeBand() {
        if self.isScrolling {
            return
        }
        
        if !self.isShowingScroll {
            self.timer!.invalidate()
            return
        }
        
        UIView.animateWithDuration(animationSpeed, animations:{
            var frame = self.container!.frame
            self.band!.frame = CGRectMake(frame.size.width,0.0,frame.size.width, frame.size.height)
            },
            completion: {(Bool) in
                self.timer!.invalidate()
                self.isShowingScroll = false
                self.delegate?.endEdditingQuantity()
            })
    }
    
    func setSelectorValue(value:Int) {
        self.selectedOption = value
        self.segmented!.setTitle("\(value)", forSegmentAtIndex: 1)
    }
    
    //MARK: - UICollectionView

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfOptions!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: SelectorBandCell? = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as? SelectorBandCell
        cell!.normalFont = self.selectorNormalFont
        cell!.selectedFont = self.selectorSelectedFont
        cell!.setText("\(indexPath.item + 1)", selected: self.selectedOption == (indexPath.item + 1))
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SelectorBandCell {
            cell.setText("\(indexPath.item + 1)", selected: true)
        }
        
        var option = indexPath.item + 1
        if self.isShowingScroll {
            self.segmented!.setTitle("\(option)", forSegmentAtIndex: 1)
            UIView.animateWithDuration(animationSpeed,
                animations:{
                    var frame = self.container!.frame
                    self.band!.frame = CGRectMake(frame.size.width,0.0,frame.size.width, frame.size.height)
                },
                completion: {(Bool) in
                    self.isShowingScroll = false
                    self.delegate?.endEdditingQuantity()
                    self.selectedOption = option
                })
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SelectorBandCell {
            cell.setText("\(indexPath.item + 1)", selected: false)
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.isScrolling = true
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.isScrolling = false
    }
    
}
