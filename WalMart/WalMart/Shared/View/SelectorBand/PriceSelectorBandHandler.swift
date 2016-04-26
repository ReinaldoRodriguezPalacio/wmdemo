//
//  PriceSelectorBandHandler.swift
//  WalMart
//
//  Created by neftali on 11/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class PriceSelectorBandHandler: SelectorBandHandler {
    
    var button: UIButton!
    //var price: CurrencyCustomLabel?
    var currencyFmt: NSNumberFormatter?
    var tapGesture: UITapGestureRecognizer!

    override func buildSelector(frame:CGRect) -> UIView? {
        
        self.currencyFmt = NSNumberFormatter()
        self.currencyFmt!.numberStyle = .CurrencyStyle
        self.currencyFmt!.minimumFractionDigits = 2
        self.currencyFmt!.maximumFractionDigits = 2
        self.currencyFmt!.locale = NSLocale(localeIdentifier: "es_MX")

        self.selectorNormalFont = WMFont.fontMyriadProSemiboldOfSize(14)
        self.selectorSelectedFont =  WMFont.fontMyriadProSemiboldOfSize(14)
        
        self.container = UIView(frame: frame)
        //self.container!.layer.cornerRadius = 5
        //self.container!.layer.borderWidth = 1
        self.container!.clipsToBounds = true
        
        self.button = UIButton(type: .Custom)
        self.button!.frame = CGRectMake(frame.width - frame.size.height, 0.0 , frame.size.height, frame.size.height)
        self.button!.addTarget(self, action: #selector(PriceSelectorBandHandler.showBand(_:)), forControlEvents: .TouchUpInside)
        self.button!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.button!.backgroundColor = WMColor.yellow
        self.button!.titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        self.button!.layer.cornerRadius = frame.size.height / 2
        //self.button!.layer.borderWidth = 1
        self.container!.addSubview(self.button!)

        //self.price = CurrencyCustomLabel(frame: CGRectMake(0, 0, 0, 14))
        self.container!.backgroundColor = UIColor.clearColor()
        //self.container!.addSubview(self.price!)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(PriceSelectorBandHandler.didTap));
        self.container!.addGestureRecognizer(self.tapGesture)

        self.bandLayout =  UICollectionViewFlowLayout()
        self.bandLayout!.minimumInteritemSpacing = 0.0
        self.bandLayout!.minimumLineSpacing = 0.0
        self.bandLayout!.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.bandLayout!.scrollDirection = .Horizontal
        self.bandLayout!.itemSize = CGSizeMake(frame.size.height , frame.size.height)
        
        self.band = UICollectionView(frame: CGRectMake(frame.size.width,0.0,frame.size.width, frame.size.height), collectionViewLayout: self.bandLayout!)
        self.band!.layer.cornerRadius = frame.size.height / 2
        //self.band!.layer.borderWidth = 1
        self.band!.backgroundColor = WMColor.yellow
        self.band!.showsHorizontalScrollIndicator = false
        self.band!.showsVerticalScrollIndicator = false
        self.band!.delegate = self
        self.band!.dataSource = self
        self.band!.registerClass(PriceSelectorBandCell.self, forCellWithReuseIdentifier: "Cell")
        self.band!.registerClass(PriceSelectorTrashCell.self, forCellWithReuseIdentifier: "Trash")
        
        self.container!.addSubview(self.band!)
        self.selectedOption = 1
        
        self.numberOfOptions = ShoppingCartAddProductsService.maxItemsInShoppingCart()
        
        return self.container!
    }
    
    func setValues(forQuantity quantity:Int, withPrice value:Double) {
        self.selectedOption = quantity
        self.button!.setTitle("\(quantity)", forState: .Normal)
        let calculated: Double = value * Double(quantity)
        let resultStr = CurrencyCustomLabel.formatString(NSNumber(double: calculated).stringValue)
        self.totalString = resultStr
        //var title = "Añadir \(resultStr)"
        /*self.price!.updateMount(title, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.whiteColor(), interLine: false)
        
        var sizeLabel = self.price!.sizeOfLabel()
        self.price!.frame = CGRectMake((self.container!.frame.size.width / 2) - ((sizeLabel.width + 5.0) / 2), (self.container!.frame.size.height - sizeLabel.height)/2, sizeLabel.width, sizeLabel.height)*/
    }
    
    func showBand(sender:UIButton) {
        
        self.band!.reloadData()
        /*if self.selectedOption > -1 {
            self.band!.scrollToItemAtIndexPath(NSIndexPath(forItem: self.selectedOption, inSection: 0), atScrollPosition: .CenteredHorizontally , animated: false)
        } else {
            self.band!.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .Left , animated: false)
        }*/
        let frame = self.container!.frame
        self.band!.frame = CGRectMake(self.container!.frame.width  ,0.0,0.0, frame.size.height)
        UIView.animateWithDuration(animationSpeed, animations:{
            self.band!.frame = CGRectMake(0.0,0.0,frame.size.width , frame.size.height)
            }, completion: {(completed: Bool) in
                if completed == true {
                    self.isShowingScroll = true
                    self.delegate?.startEdditingQuantity()
                    self.tapGesture.enabled = false
                    self.timer = NSTimer(fireDate:NSDate(timeIntervalSinceNow:10), interval:5.0, target:self, selector:#selector(SelectorBandHandler.removeBand), userInfo:nil, repeats:true)
                    let runner = NSRunLoop.currentRunLoop()
                    runner.addTimer(self.timer!, forMode: NSDefaultRunLoopMode)
                    self.container?.bringSubviewToFront(self.band!)
                }
        })
    }
    
    override func removeBand() {
        if self.isScrolling {
            return
        }
        
        if !self.isShowingScroll {
            self.timer!.invalidate()
            return
        }
        
        UIView.animateWithDuration(animationSpeed, animations:{
            let frame = self.container!.frame
            self.band!.frame = CGRectMake(frame.size.width,0.0,0, frame.size.height)
            },
            completion: {(Bool) in
                self.timer!.invalidate()
                self.tapGesture.enabled = true
                self.isShowingScroll = false
                self.delegate?.endEdditingQuantity()
        })
    }
    
    func closeBand(){
        let frame = self.container!.frame
        self.band!.frame = CGRectMake(frame.size.width,0.0,0, frame.size.height)
        self.tapGesture.enabled = true
        self.isShowingScroll = false
    }

    //MARK: - UICollectionView
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfOptions! + 1
    }
    
    override  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Trash", forIndexPath: indexPath) as! PriceSelectorTrashCell
            return cell
        }
        let cell: PriceSelectorBandCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PriceSelectorBandCell
        cell.normalFont = self.selectorNormalFont
        cell.selectedFont = self.selectorSelectedFont
        cell.setText("\(indexPath.item)", selected: self.selectedOption == indexPath.item)
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0 {
            UIView.animateWithDuration(animationSpeed,
                animations:{
                    let frame = self.container!.frame
                    self.band!.frame = CGRectMake(frame.size.width,0.0,0.0, frame.size.height)
                },
                completion: {(finished:Bool) in
                    if finished {
                        self.isShowingScroll = false
                        self.delegate?.endEdditingQuantity()
                        self.tapGesture.enabled = true
                        self.selectedOption = -1
                        self.delegate?.deleteProduct()
                    }
            })
            return
        }

        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SelectorBandCell {
            cell.setText("\(indexPath.item)", selected: true)
        }
        
        let option = indexPath.item
        if self.isShowingScroll {
            self.button!.setTitle("\(option)", forState: .Normal)
            UIView.animateWithDuration(animationSpeed,
                animations:{
                    let frame = self.container!.frame
                    self.band!.frame = CGRectMake(frame.size.width,0.0,0.0, frame.size.height)
                },
                completion: {(finished:Bool) in
                    if finished {
                        self.isShowingScroll = false
                        self.delegate?.endEdditingQuantity()
                        self.tapGesture.enabled = true
                        if option != self.selectedOption {
                            self.selectedOption = option
                            self.delegate?.addProductQuantity(self.selectedOption)
                        }
                    }
            })
        }
    }
    
    func didTap(){
        if delegate != nil {
            delegate!.tapInPrice(self.selectedOption, total: self.totalString)
        }
    }

}
