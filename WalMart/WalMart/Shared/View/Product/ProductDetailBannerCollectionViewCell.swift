//
//  ProductDetailBannerCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/7/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailBannerCollectionViewCell : UICollectionReusableView, UICollectionViewDelegate, UICollectionViewDataSource, ProductDetailColorSizeDelegate {
    
    var delegate : ProductDetailBannerCollectionViewDelegate!
    var colorsViewDelegate: ProductDetailColorSizeDelegate?
    var collection: UICollectionView!
    var colorsView: ProductDetailColorSizeView!
    var sizesView: ProductDetailColorSizeView!
    var items: [AnyObject]! = []
    var colors: [AnyObject]? = []
    var sizes: [AnyObject]? = []
    var imagesRef: [UIImage]! = []
    var pointSection: UIView! = nil
    var pointContainer: UIView? = nil
    var pointButtons: [UIButton]? = nil
    var currentItem: Int? = nil
    var freeShippingImage: UIImageView!
    var imageZoom: UIImageView!
    let contentModeOrig = UIViewContentMode.ScaleAspectFit
    
    var priceBefore : CurrencyCustomLabel!
    var price : CurrencyCustomLabel!
    var saving : CurrencyCustomLabel!
    
    var presale : UILabel!
    var imagePresale : UIImageView!
    var imageLowStock : UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("frale:\(frame)")
        setup()
    }
    
    init(frame: CGRect,items:[AnyObject]) {
        super.init(frame: frame)
        self.items = items
        setup()
    }
    
    func setup() {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collection = UICollectionView(frame: CGRectMake(self.bounds.minX, self.bounds.minY, self.bounds.width, self.bounds.height - 54), collectionViewLayout: collectionLayout)
        collection.registerClass(ProductDetailBannerMediaCollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        collection.dataSource = self
        collection.delegate = self
        collection.pagingEnabled = true
        collection.backgroundColor = UIColor.whiteColor()
        collection.showsHorizontalScrollIndicator = false
        
        self.imageZoom = UIImageView(frame: collection.frame)
        self.imageZoom.alpha = 0
        self.imageZoom.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.pointSection = UIView()
        self.pointSection?.backgroundColor = UIColor.clearColor()
        self.currentItem = 0
        self.addSubview(collection)
        self.addSubview(self.imageZoom)
        self.addSubview(pointSection!)
        
        self.buildButtonSection()
        self.colorsView = ProductDetailColorSizeView(frame: CGRectMake(0, self.pointSection!.frame.maxY,  self.frame.width, 60))
        self.colorsView.delegate = self
        self.colorsView.alpha = 0
        self.addSubview(colorsView)
        
        self.sizesView = ProductDetailColorSizeView(frame: CGRectMake(0, self.pointSection!.frame.maxY,  self.frame.width, 60))
        self.sizesView.delegate = self
        self.sizesView.alpha = 0
        self.addSubview(sizesView)
        
        
        imageLowStock =  UIImageView(image: UIImage(named: "ultimas_detail"))
        imageLowStock.hidden =  true
        self.addSubview(imageLowStock)
        
        //presale
        imagePresale =  UIImageView(image: UIImage(named: "preventa_product_detail"))
        imagePresale.hidden =  true
        self.addSubview(imagePresale)
        
       
    
        priceBefore = CurrencyCustomLabel(frame: CGRectMake(0, self.pointSection!.frame.maxY  , self.frame.width, 15.0))
        self.addSubview(priceBefore)
        price = CurrencyCustomLabel(frame: CGRectMake(0, self.priceBefore.frame.maxY  , self.frame.width, 24.0))
        self.addSubview(price)
        saving = CurrencyCustomLabel(frame: CGRectMake(0, self.price.frame.maxY  , self.frame.width, 15.0))
        self.addSubview(saving)
        
    }
    
    func setAdditionalValues(listPrice:String,price:String,saving:String){
        
       
        
        if price == "" || (price as NSString).doubleValue == 0 {
            self.price.hidden = true
        } else {
            self.price.hidden = false
            let formatedValue = "\(CurrencyCustomLabel.formatString(price))"
            self.price.updateMount(formatedValue, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        }
        
        if listPrice == "" || (listPrice as NSString).doubleValue == 0 || (price as NSString).doubleValue >= (listPrice as NSString).doubleValue  {
            priceBefore.hidden = true
        } else {
            priceBefore.hidden = false
            let formatedValue = "\(CurrencyCustomLabel.formatString(listPrice))"
            self.priceBefore.updateMount(formatedValue, font: WMFont.fontMyriadProLightOfSize(14), color: WMColor.dark_gray, interLine: true)
        }
        
        if saving == "" {
            self.saving.hidden = true
        } else {
            self.saving.hidden = false
            let formatedValue = "\(CurrencyCustomLabel.formatString(saving))"
            self.saving.updateMount(formatedValue, font: WMFont.fontMyriadProSemiboldOfSize(14), color: WMColor.green, interLine: false)
        }
        
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
            for var idx = 0; idx < size; idx += 1 {
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
            self.pointContainer!.frame = CGRectMake((pbounds.size.width - x)/2,  (20.0 - bsize)/2, x, 20.0)
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

        var widthNew = self.bounds.width + self.bounds.height - 314
        if widthNew <= self.bounds.width {
            widthNew = self.bounds.width
        }
        
     
            if widthNew > 320 {
                let heightNew = widthNew  - 320
                self.collection.alpha = 0
                
                let cellImg = self.collection.cellForItemAtIndexPath(NSIndexPath(forItem: self.currentItem!, inSection: 0)) as? ProductDetailBannerMediaCollectionViewCell
            if cellImg != nil {
                let originRect = cellImg!.imageView!.frame
                let rectTransform = CGRectMake(originRect.minX - (heightNew / 2), originRect.minY, originRect.width + heightNew, originRect.height + heightNew)
                
                self.imageZoom.image = cellImg!.imageView.image
                UIView.animateWithDuration(0, animations: { () -> Void in
                    self.imageZoom.frame = rectTransform
                    self.imageZoom.alpha = 1
                })
            }
            } else {
                self.collection.alpha = 1
                self.imageZoom.alpha = 0
                self.imageZoom.frame = collection.frame
            }
        
        
        self.buildColorsAndSizesView()
        
        self.priceBefore.frame = CGRectMake(0,  self.bounds.height - 54   , self.frame.width, 15.0)
        self.price.frame = CGRectMake(0, self.bounds.height - 39  , self.frame.width, 24.0)
        self.saving.frame = CGRectMake(0, self.bounds.height - 15  , self.frame.width, 15.0)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.buildButtonSection()
        self.buildColorsAndSizesView()
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ProductDetailBannerMediaCollectionViewCell
        let imageURL = items[indexPath.row] as! String
        
        cell.imageView!.contentMode = UIViewContentMode.Center
        cell.imageView!.setImageWithURL(NSURL(string: imageURL), placeholderImage: UIImage(named:"img_default_cell"), success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            cell.imageView!.contentMode = self.contentModeOrig
            cell.imageView!.image = image
            self.imagesRef.insert(image, atIndex: indexPath.row)
            }, failure: nil)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate.sleectedImage(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return self.collection.frame.size
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func buildColorsAndSizesView(){
        if colors?.count != 0 || sizes?.count != 0{
            if colors?.count != 0 && sizes?.count != 0{
                self.colorsView.items = self.colors
                self.colorsView.buildViewForColors(self.colors as! [[String:AnyObject]])
                self.colorsView.alpha = 1.0
                let frame = collection.frame
                self.collection.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, 160)
                self.pointSection.frame = CGRectMake(0, self.bounds.height - 174, self.bounds.width, 20)
                self.colorsView.frame =  CGRectMake(0,  self.bounds.height - 154, self.frame.width, 40.0)
                self.colorsView.buildItemsView()
                self.sizesView.items = self.sizes
                self.sizesView.buildViewForColors(self.sizes as! [[String:AnyObject]])
                self.sizesView.alpha = 1.0
                self.sizesView.frame =  CGRectMake(0,  self.bounds.height - 114, self.frame.width, 40.0)
                self.sizesView.buildItemsView()
                self.sizesView.deleteTopBorder()
            }else if colors?.count != 0 && sizes?.count == 0{
                self.sizesView.alpha = 0
                self.colorsView.items = self.colors
                self.colorsView.buildViewForColors(self.colors as! [[String:AnyObject]])
                self.colorsView.alpha = 1.0
                let frame = collection.frame
                self.collection.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, 200)
                self.pointSection.frame = CGRectMake(0, self.bounds.height - 134, self.bounds.width, 20)
                self.colorsView.frame =  CGRectMake(0,  self.bounds.height - 114, self.frame.width, 40.0)
                self.colorsView.buildItemsView()
            }else if colors?.count == 0 && sizes?.count != 0{
                self.colorsView.alpha = 0
                self.sizesView.items = self.sizes
                self.sizesView.buildViewForColors(self.sizes as! [[String:AnyObject]])
                self.sizesView.alpha = 1.0
                let frame = collection.frame
                self.collection.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, 200)
                self.pointSection.frame = CGRectMake(0, self.bounds.height - 134, self.bounds.width, 20)
                self.sizesView.frame =  CGRectMake(0,  self.bounds.height - 114, self.frame.width, 40.0)
                self.sizesView.buildItemsView()
            }
        }else{
            self.colorsView.alpha = 0
            self.sizesView.alpha = 0
            self.pointSection.frame = CGRectMake(0, self.bounds.height - 74   , self.bounds.width, 20)
        }
    }
    
    //MARK: ProductDetailColorSizeDelegate
    
    func selectDetailItem(selected: String, itemType: String) {
      colorsViewDelegate?.selectDetailItem(selected, itemType: itemType)
    }
}
