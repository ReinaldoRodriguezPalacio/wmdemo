//
//  ProductDetailBannerCollectionView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol ProductDetailBannerCollectionViewDelegate {
    func sleectedImage(_ indexPath: IndexPath)
}

class ProductDetailBannerTableViewCell : UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate  {
    
    var delegate : ProductDetailBannerCollectionViewDelegate!
    var collection: UICollectionView!
    var items: [Any]! = []
    var pointSection: UIView? = nil
    var pointContainer: UIView? = nil
    var pointButtons: [UIButton]? = nil
    var currentItem: Int? = nil
    var freeShippingImage: UIImageView!
    let contentModeOrig = UIViewContentMode.scaleAspectFit

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        collection = UICollectionView(frame: self.bounds, collectionViewLayout: collectionLayout)
        collection.register(ProductDetailBannerMediaCollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        collection.backgroundColor = UIColor.white
        collection.showsHorizontalScrollIndicator = false
        self.pointSection = UIView()
        self.pointSection?.backgroundColor = UIColor.clear
        self.currentItem = 0
        self.addSubview(collection)
        self.addSubview(pointSection!)
        self.buildButtonSection()
       
    }
    
    
    func setFreeShiping(_ freeShipping:Bool) {
        if (freeShipping) {
            if freeShippingImage == nil {
                freeShippingImage = UIImageView(frame: CGRect(x: 16, y: 177, width: 50, height: 50))
                freeShippingImage.image = UIImage(named:"detail_freeShipping")
                self.addSubview(freeShippingImage)
            }
        }else{
            if freeShippingImage != nil {
                freeShippingImage.isHidden = true
            }
        }
    }
    
    
    func buildButtonSection() {
        if let container = self.pointContainer {
            container.removeFromSuperview()
        }
        self.pointContainer = UIView()
        self.pointSection!.addSubview(self.pointContainer!)
        var buttons = Array<UIButton>()
        let size = items?.count
        if size > 0 {
            let bsize: CGFloat = 8.0
            var x: CGFloat = 0.0
            let sep: CGFloat = 2.0
            for idx in 0 ..< size! {
                let point = UIButton(type: .custom)
                point.frame = CGRect(x: x, y: 5, width: bsize, height: bsize)
                point.setImage(UIImage(named: "bannerContentOff"), for: UIControlState())
                point.setImage(UIImage(named: "bannerContentOn"), for: .selected)
                point.setImage(UIImage(named: "bannerContentOn"), for: .highlighted)
                point.addTarget(self, action: #selector(ProductDetailBannerTableViewCell.pointSelected(_:)), for: .touchUpInside)
                point.isSelected = idx == self.currentItem!
                x = point.frame.maxX
                if idx < size {
                    x += sep
                }
                self.pointContainer!.addSubview(point)
                buttons.append(point)
            }
            let pbounds = self.pointSection!.frame
            self.pointContainer!.frame = CGRect(x: (pbounds.size.width - x)/2,  y: (20.0 - bsize)/2, width: x, height: 20.0)
        }
        self.pointButtons = buttons
    }
    
    func pointSelected(_ sender:UIButton) {
        for button: UIButton in self.pointButtons! {
            button.isSelected = button === sender
        }
        if let idx = (self.pointButtons!).index(of: sender) {
            self.collection!.scrollToItem(at: IndexPath(item: idx, section: 0),
                at: .centeredHorizontally, animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = self.collection!.contentOffset.x / self.collection!.frame.size.width
        self.currentItem = Int(currentIndex)
        let nsarray = self.pointButtons! as NSArray
        if let button = nsarray.object(at: self.currentItem!) as? UIButton {
            for inner: UIButton in self.pointButtons! {
                inner.isSelected = button === inner
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collection.frame = self.bounds
        self.pointSection?.frame = CGRect(x: 0, y: self.collection.frame.height - 20 , width: self.collection.frame.width, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.buildButtonSection()
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ProductDetailBannerMediaCollectionViewCell
        let imageURL = items[(indexPath as NSIndexPath).row] as! String
        
        cell.imageView!.contentMode = UIViewContentMode.center
        cell.imageView!.setImageWith(URL(string: imageURL), placeholderImage: UIImage(named:"img_default_cell"), success: { (request:URLRequest?, response:HTTPURLResponse?, image:UIImage?) -> Void in
            cell.imageView!.contentMode = self.contentModeOrig
            cell.imageView!.image = image
            }, failure: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.sleectedImage(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
      return self.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }

   }
