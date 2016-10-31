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
    var currencyFmt: NumberFormatter?
    var tapGesture: UITapGestureRecognizer!

    override func buildSelector(_ frame:CGRect) -> UIView? {
        
        self.currencyFmt = NumberFormatter()
        self.currencyFmt!.numberStyle = .currency
        self.currencyFmt!.minimumFractionDigits = 2
        self.currencyFmt!.maximumFractionDigits = 2
        self.currencyFmt!.locale = Locale(identifier: "es_MX")

        self.selectorNormalFont = WMFont.fontMyriadProSemiboldOfSize(14)
        self.selectorSelectedFont =  WMFont.fontMyriadProSemiboldOfSize(14)
        
        self.container = UIView(frame: frame)
        //self.container!.layer.cornerRadius = 5
        //self.container!.layer.borderWidth = 1
        self.container!.clipsToBounds = true
        
        self.button = UIButton(type: .custom)
        self.button!.frame = CGRect(x: frame.width - frame.size.height, y: 0.0 , width: frame.size.height, height: frame.size.height)
        self.button!.addTarget(self, action: #selector(PriceSelectorBandHandler.showBand(_:)), for: .touchUpInside)
        self.button!.setTitleColor(UIColor.white, for: UIControlState())
        self.button!.backgroundColor = WMColor.yellow
        self.button!.titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        self.button!.layer.cornerRadius = frame.size.height / 2
        //self.button!.layer.borderWidth = 1
        self.container!.addSubview(self.button!)

        //self.price = CurrencyCustomLabel(frame: CGRectMake(0, 0, 0, 14))
        self.container!.backgroundColor = UIColor.clear
        //self.container!.addSubview(self.price!)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(PriceSelectorBandHandler.didTap));
        self.container!.addGestureRecognizer(self.tapGesture)

        self.bandLayout =  UICollectionViewFlowLayout()
        self.bandLayout!.minimumInteritemSpacing = 0.0
        self.bandLayout!.minimumLineSpacing = 0.0
        self.bandLayout!.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.bandLayout!.scrollDirection = .horizontal
        self.bandLayout!.itemSize = CGSize(width: frame.size.height , height: frame.size.height)
        
        self.band = UICollectionView(frame: CGRect(x: frame.size.width,y: 0.0,width: frame.size.width, height: frame.size.height), collectionViewLayout: self.bandLayout!)
        self.band!.layer.cornerRadius = frame.size.height / 2
        //self.band!.layer.borderWidth = 1
        self.band!.backgroundColor = WMColor.yellow
        self.band!.showsHorizontalScrollIndicator = false
        self.band!.showsVerticalScrollIndicator = false
        self.band!.delegate = self
        self.band!.dataSource = self
        self.band!.register(PriceSelectorBandCell.self, forCellWithReuseIdentifier: "Cell")
        self.band!.register(PriceSelectorTrashCell.self, forCellWithReuseIdentifier: "Trash")
        
        self.container!.addSubview(self.band!)
        self.selectedOption = 1
        
        return self.container!
    }
    
    func setValues(forQuantity quantity:Int, withPrice value:Double) {
        self.selectedOption = quantity
        self.button!.setTitle("\(quantity)", for: UIControlState())
        let calculated: Double = value * Double(quantity)
        let resultStr = CurrencyCustomLabel.formatString(NSNumber(value: calculated as Double).stringValue)
        self.totalString = resultStr
        //var title = "Añadir \(resultStr)"
        /*self.price!.updateMount(title, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.whiteColor(), interLine: false)
        
        var sizeLabel = self.price!.sizeOfLabel()
        self.price!.frame = CGRectMake((self.container!.frame.size.width / 2) - ((sizeLabel.width + 5.0) / 2), (self.container!.frame.size.height - sizeLabel.height)/2, sizeLabel.width, sizeLabel.height)*/
    }
    
    func showBand(_ sender:UIButton) {
        
        self.band!.reloadData()
        /*if self.selectedOption > -1 {
            self.band!.scrollToItemAtIndexPath(NSIndexPath(forItem: self.selectedOption, inSection: 0), atScrollPosition: .CenteredHorizontally , animated: false)
        } else {
            self.band!.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .Left , animated: false)
        }*/
        let frame = self.container!.frame
        self.band!.frame = CGRect(x: self.container!.frame.width  ,y: 0.0,width: 0.0, height: frame.size.height)
        UIView.animate(withDuration: animationSpeed, animations:{
            self.band!.frame = CGRect(x: 0.0,y: 0.0,width: frame.size.width , height: frame.size.height)
            }, completion: {(completed: Bool) in
                if completed == true {
                    self.isShowingScroll = true
                    self.delegate?.startEdditingQuantity()
                    self.tapGesture.isEnabled = false
                    self.timer = Timer(fireAt:Date(timeIntervalSinceNow:10), interval:5.0, target:self, selector:#selector(SelectorBandHandler.removeBand), userInfo:nil, repeats:true)
                    let runner = RunLoop.current
                    runner.add(self.timer!, forMode: RunLoopMode.defaultRunLoopMode)
                    self.container?.bringSubview(toFront: self.band!)
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
        
        UIView.animate(withDuration: animationSpeed, animations:{
            let frame = self.container!.frame
            self.band!.frame = CGRect(x: frame.size.width,y: 0.0,width: 0, height: frame.size.height)
            },
            completion: {(Bool) in
                self.timer!.invalidate()
                self.tapGesture.isEnabled = true
                self.isShowingScroll = false
                self.delegate?.endEdditingQuantity()
        })
    }
    
    func closeBand(){
        let frame = self.container!.frame
        self.band!.frame = CGRect(x: frame.size.width,y: 0.0,width: 0, height: frame.size.height)
        self.tapGesture.isEnabled = true
        self.isShowingScroll = false
    }

    //MARK: - UICollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfOptions! + 1
    }
    
    override  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Trash", for: indexPath) as! PriceSelectorTrashCell
            return cell
        }
        let cell: PriceSelectorBandCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PriceSelectorBandCell
        cell.normalFont = self.selectorNormalFont
        cell.selectedFont = self.selectorSelectedFont
        cell.setText("\((indexPath as NSIndexPath).item)", selected: self.selectedOption == (indexPath as NSIndexPath).item)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row == 0 {
            UIView.animate(withDuration: animationSpeed,
                animations:{
                    let frame = self.container!.frame
                    self.band!.frame = CGRect(x: frame.size.width,y: 0.0,width: 0.0, height: frame.size.height)
                },
                completion: {(finished:Bool) in
                    if finished {
                        self.isShowingScroll = false
                        self.delegate?.endEdditingQuantity()
                        self.tapGesture.isEnabled = true
                        self.selectedOption = -1
                        self.delegate?.deleteProduct()
                    }
            })
            return
        }

        if let cell = collectionView.cellForItem(at: indexPath) as? SelectorBandCell {
            cell.setText("\((indexPath as NSIndexPath).item)", selected: true)
        }
        
        let option = (indexPath as NSIndexPath).item
        if self.isShowingScroll {
            self.button!.setTitle("\(option)", for: UIControlState())
            UIView.animate(withDuration: animationSpeed,
                animations:{
                    let frame = self.container!.frame
                    self.band!.frame = CGRect(x: frame.size.width,y: 0.0,width: 0.0, height: frame.size.height)
                },
                completion: {(finished:Bool) in
                    if finished {
                        self.isShowingScroll = false
                        self.delegate?.endEdditingQuantity()
                        self.tapGesture.isEnabled = true
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
