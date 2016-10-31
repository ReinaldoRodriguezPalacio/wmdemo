//
//  SelectorBandDataSource.swift
//  WalMart
//
//  Created by neftali on 25/07/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol SelectorBandDelegate {
    func addProductQuantity(_ quantity:Int)
    func deleteProduct()
    func tapInPrice(_ quantity:Int,total:String)
    
    
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
    
    var timer: Timer?
    var isShowingScroll = false
    var isScrolling = false
    
    func buildSelector(_ frame:CGRect) -> UIView? {
        
        self.selectorNormalFont = WMFont.fontMyriadProRegularOfSize(16)
        self.selectorSelectedFont = WMFont.fontMyriadProRegularOfSize(20)

        let imgInsets = UIEdgeInsetsMake(15, 15, 15, 15)
        let image_normal = UIImage(named:"segmented_normal")!.resizableImage(withCapInsets: imgInsets)
        let image_highlighted = UIImage(named:"segmented_selected")!.resizableImage(withCapInsets: imgInsets)
        
        self.container = UIView(frame: frame)
        self.container!.layer.cornerRadius = 5
        self.container!.clipsToBounds = true
        
        self.bandLayout =  UICollectionViewFlowLayout()
        self.bandLayout!.minimumInteritemSpacing = 0.0
        self.bandLayout!.minimumLineSpacing = 0.0
        self.bandLayout!.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.bandLayout!.scrollDirection = .horizontal
        self.bandLayout!.itemSize = CGSize(width: frame.size.height + 5, height: frame.size.height)
        
        self.band = UICollectionView(frame: CGRect(x: frame.size.width,y: 0.0,width: frame.size.width, height: frame.size.height), collectionViewLayout: self.bandLayout!)
        self.band!.layer.borderWidth = 1
        self.band!.layer.borderColor = WMColor.yellow.cgColor
        self.band!.layer.cornerRadius = 5
        self.band!.backgroundView = UIImageView(image:image_normal)
        self.band!.showsHorizontalScrollIndicator = false
        self.band!.showsVerticalScrollIndicator = false
        self.band!.delegate = self
        self.band!.dataSource = self
        self.band!.register(SelectorBandCell.self, forCellWithReuseIdentifier: "Cell")
        
        self.segmented = UISegmentedControl(items: [NSLocalizedString("product.detail.addToCart", comment:""), "1"])
        self.segmented!.frame = CGRect(x: 0.0,y: 0.0,width: frame.size.width, height: frame.size.height)
        self.segmented!.addTarget(self, action: #selector(SelectorBandHandler.segmentedControlAction(_:)), for: .valueChanged)
        //self.segmented!.setWidth(frame.size.width - frame.size.height, forSegmentAtIndex: 0)
        self.segmented!.setWidth(frame.size.height + 5, forSegmentAt: 1)
        
        let segmentedTitleAttributes = [NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(16),
            NSForegroundColorAttributeName:UIColor.white]
        self.segmented!.setTitleTextAttributes(segmentedTitleAttributes, for: UIControlState())
        self.segmented!.setTitleTextAttributes(segmentedTitleAttributes, for: .selected)
        self.segmented!.setTitleTextAttributes(segmentedTitleAttributes, for: .highlighted)
        
        self.segmented!.setBackgroundImage(image_normal, for:UIControlState(), barMetrics:.default)
        self.segmented!.setBackgroundImage(image_normal, for:.selected, barMetrics:.default)
        self.segmented!.setBackgroundImage(image_highlighted, for:.highlighted, barMetrics:.default)
        
        let sepInsets = UIEdgeInsetsMake(15, 10, 15, 10)
        let bothSelected = UIImage(named:"segmented_bothActive")?.resizableImage(withCapInsets: sepInsets)
        self.segmented!.setDividerImage(bothSelected, forLeftSegmentState: UIControlState(), rightSegmentState: UIControlState(), barMetrics: .default)
        let leftSelected = UIImage(named:"segmented_LActiveRInactive")?.resizableImage(withCapInsets: sepInsets)
        self.segmented!.setDividerImage(leftSelected, forLeftSegmentState:UIControlState(), rightSegmentState:.highlighted, barMetrics:.default)
        self.segmented!.setDividerImage(leftSelected, forLeftSegmentState:.selected, rightSegmentState:.highlighted, barMetrics:.default)
        let rightSelected = UIImage(named:"segmented_RActiveLInactive")?.resizableImage(withCapInsets: sepInsets)
        self.segmented!.setDividerImage(rightSelected, forLeftSegmentState:.highlighted, rightSegmentState:UIControlState(), barMetrics:.default)
        self.segmented!.setDividerImage(rightSelected, forLeftSegmentState:.highlighted, rightSegmentState:.selected, barMetrics:.default)
        
        self.container!.addSubview(self.segmented!)
        self.container!.addSubview(self.band!)
        self.selectedOption = 1
        
        return self.container!
    }
    
    func segmentedControlAction(_ segmentedControl:UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.delegate?.addProductQuantity(self.selectedOption)
        }
        if segmentedControl.selectedSegmentIndex == 1 && !self.isShowingScroll {
            self.band!.reloadData()
            if self.selectedOption > -1 {
                self.band!.scrollToItem(at: IndexPath(item: self.selectedOption - 1, section: 0), at: .centeredHorizontally , animated: false)
            } else {
                self.band!.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left , animated: false)
            }
            UIView.animate(withDuration: animationSpeed, animations:{
                let frame = self.container!.frame
                self.band!.frame = CGRect(x: 0.0,y: 0.0,width: frame.size.width, height: frame.size.height)
                }, completion: {(completed: Bool) in
                    if completed == true {
                        self.isShowingScroll = true
                        self.delegate?.startEdditingQuantity()
                        self.timer = Timer(fireAt:Date(timeIntervalSinceNow:10), interval:5.0, target:self, selector:#selector(SelectorBandHandler.removeBand), userInfo:nil, repeats:true)
                        let runner = RunLoop.current
                        runner.add(self.timer!, forMode: RunLoopMode.defaultRunLoopMode)
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
        
        UIView.animate(withDuration: animationSpeed, animations:{
            let frame = self.container!.frame
            self.band!.frame = CGRect(x: frame.size.width,y: 0.0,width: frame.size.width, height: frame.size.height)
            },
            completion: {(Bool) in
                self.timer!.invalidate()
                self.isShowingScroll = false
                self.delegate?.endEdditingQuantity()
            })
    }
    
    func setSelectorValue(_ value:Int) {
        self.selectedOption = value
        self.segmented!.setTitle("\(value)", forSegmentAt: 1)
    }
    
    //MARK: - UICollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfOptions!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SelectorBandCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? SelectorBandCell
        cell!.normalFont = self.selectorNormalFont
        cell!.selectedFont = self.selectorSelectedFont
        cell!.setText("\((indexPath as NSIndexPath).item + 1)", selected: self.selectedOption == ((indexPath as NSIndexPath).item + 1))
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectorBandCell {
            cell.setText("\((indexPath as NSIndexPath).item + 1)", selected: true)
        }
        
        let option = (indexPath as NSIndexPath).item + 1
        if self.isShowingScroll {
            self.segmented!.setTitle("\(option)", forSegmentAt: 1)
            UIView.animate(withDuration: animationSpeed,
                animations:{
                    let frame = self.container!.frame
                    self.band!.frame = CGRect(x: frame.size.width,y: 0.0,width: frame.size.width, height: frame.size.height)
                },
                completion: {(Bool) in
                    self.isShowingScroll = false
                    self.delegate?.endEdditingQuantity()
                    self.selectedOption = option
                })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectorBandCell {
            cell.setText("\((indexPath as NSIndexPath).item + 1)", selected: false)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isScrolling = false
    }
    
}
