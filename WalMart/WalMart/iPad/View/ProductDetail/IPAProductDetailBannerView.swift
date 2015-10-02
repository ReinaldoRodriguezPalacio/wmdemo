//
//  IPAProductDetailBannerView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation



class IPAProductDetailBannerView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {
    
    var delegate : ProductDetailBannerCollectionViewDelegate!
    var collection: UICollectionView!
    var items: [AnyObject]! = []
    var pointSection: UIView? = nil
    var pointContainer: UIView? = nil
    var pointButtons: [UIButton]? = nil
    var currentItem: Int? = nil
    var freeShippingImage: UIImageView!
    let contentModeOrig = UIViewContentMode.ScaleAspectFit
    var presale : UILabel!
    var widthPresale : CGFloat = 56
    
    var imagePresale : UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collection = UICollectionView(frame: self.bounds, collectionViewLayout: collectionLayout)
        collection.registerClass(ProductDetailBannerMediaCollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        collection.dataSource = self
        collection.delegate = self
        collection.pagingEnabled = true
        collection.backgroundColor = UIColor.whiteColor()
        collection.showsHorizontalScrollIndicator = false
        self.pointSection = UIView()
        self.pointSection?.backgroundColor = UIColor.clearColor()
        self.currentItem = 0
        self.addSubview(collection)
        self.addSubview(pointSection!)
        self.buildButtonSection()
        
        //presale
        imagePresale =  UIImageView(image: UIImage(named: "preventa_product_detail"))
        imagePresale.hidden =  true
        self.addSubview(imagePresale)

    }
    
    
    func setFreeShiping(freeShipping:Bool) {
        if (freeShipping) {
            if freeShippingImage == nil {
                freeShippingImage = UIImageView(frame: CGRectMake(16, 177, 50, 50))
                freeShippingImage.image = UIImage(named:"detail_freeShipping")
                self.addSubview(freeShippingImage)
            }
        }else{
            if freeShippingImage != nil {
                freeShippingImage.hidden = true
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
            for var idx = 0; idx < size; ++idx {
                let point = UIButton(type: .Custom)
                point.frame = CGRectMake(x, 5, bsize, bsize)
                point.setImage(UIImage(named: "bannerContentOff"), forState: .Normal)
                point.setImage(UIImage(named: "bannerContentOn"), forState: .Selected)
                point.setImage(UIImage(named: "bannerContentOn"), forState: .Highlighted)
                point.addTarget(self, action: "pointSelected:", forControlEvents: .TouchUpInside)
                point.selected = idx == self.currentItem!
                x = CGRectGetMaxX(point.frame)
                if idx < size {
                    x += sep
                }
                self.pointContainer!.addSubview(point)
                buttons.append(point)
            }
            let pbounds = self.pointSection!.frame
            self.pointContainer!.frame = CGRectMake((pbounds.size.width - x)/2,  0, x, 20.0)
        }
        self.pointButtons = buttons
    }
    
    func pointSelected(sender:UIButton) {
        for button: UIButton in self.pointButtons! {
            button.selected = button === sender
        }
        if let idx = (self.pointButtons!).indexOf(sender) {
            self.collection!.scrollToItemAtIndexPath(NSIndexPath(forItem: idx, inSection: 0),
                atScrollPosition: .CenteredHorizontally, animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentIndex = self.collection!.contentOffset.x / self.collection!.frame.size.width
        self.currentItem = Int(currentIndex)
        let nsarray = self.pointButtons! as NSArray
        if let button = nsarray.objectAtIndex(self.currentItem!) as? UIButton {
            for inner: UIButton in self.pointButtons! {
                inner.selected = button === inner
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collection.frame  = self.bounds
        self.pointSection?.frame = CGRectMake(0, self.collection.frame.height - 20 , self.collection.frame.width, 20)
        self.presale.frame =  CGRectMake((self.collection.frame.width / 2) - (widthPresale / 2), self.collection.frame.height-20, widthPresale, 14)
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.buildButtonSection()
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ProductDetailBannerMediaCollectionViewCell
        
        var imageURL = items[indexPath.row] as! String
        
        var imgLarge = NSString(string: imageURL)
        imgLarge = imgLarge.stringByReplacingOccurrencesOfString("img_small", withString: "img_large")
        let pathExtention = imgLarge.pathExtension
        imageURL = imgLarge.stringByReplacingOccurrencesOfString("s.\(pathExtention)", withString: "l.\(pathExtention)")
        
        cell.imageView!.contentMode = UIViewContentMode.Center
        cell.imageView!.setImageWithURL(NSURL(string: imageURL), placeholderImage: UIImage(named:"img_default_cell"), success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            cell.imageView!.contentMode = self.contentModeOrig
            cell.imageView!.image = image
            }, failure: nil)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if delegate != nil{
            delegate.sleectedImage(indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return self.bounds.size
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }

    
}