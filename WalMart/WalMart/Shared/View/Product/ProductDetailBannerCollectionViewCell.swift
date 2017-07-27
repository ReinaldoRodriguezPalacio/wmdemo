//
//  ProductDetailBannerCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/7/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ProductDetailBannerCollectionViewCell : UICollectionReusableView, UICollectionViewDelegate, UICollectionViewDataSource, ProductDetailColorSizeDelegate, NSCopying {
    
    weak var delegate : ProductDetailBannerCollectionViewDelegate?
    var colorsViewDelegate: ProductDetailColorSizeDelegate?
    var collection: UICollectionView!
    var colorsView: ProductDetailColorSizeView!
    var sizesView: ProductDetailColorSizeView!
    var providerView: ProductDetailProviderView!
    var items: [Any]! = []
    var colors: [Any]? = []
    var sizes: [Any]? = []
    var imagesRef: [UIImage]! = []
    var pointSection: UIView! = nil
    var pointContainer: UIView? = nil
    var pointButtons: [UIButton]? = nil
    var currentItem: Int? = nil
    var freeShippingImage: UIImageView!
    var imageZoom: UIImageView!
    let contentModeOrig = UIViewContentMode.scaleAspectFit
    
    var priceBefore : CurrencyCustomLabel!
    var price : CurrencyCustomLabel!
    var saving : CurrencyCustomLabel!
    
    var presale : UILabel!
    var imagePresale : UIImageView!
    //var imageLowStock : UIImageView!
    var lowStock : UILabel?
    var imageIconView: UIImageView!
    var hasProviders: Bool = false
    var providerInfo: [String:Any]? = nil
    var heightView: CGFloat = 314.0
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("frale:\(frame)")
        setup()
    }
    
    init(frame: CGRect,items:[Any]) {
        super.init(frame: frame)
        self.items = items
        setup()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let detailBanner = ProductDetailBannerCollectionViewCell(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.heightView))
        
        return detailBanner
    }
    
    func setup() {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        collection = UICollectionView(frame: CGRect(x: self.bounds.minX, y: self.bounds.minY, width: self.bounds.width, height: self.bounds.height - 54), collectionViewLayout: collectionLayout)
        collection.register(ProductDetailBannerMediaCollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        collection.backgroundColor = UIColor.white
        collection.showsHorizontalScrollIndicator = false
        
        self.imageZoom = UIImageView(frame: collection.frame)
        self.imageZoom.alpha = 0
        self.imageZoom.contentMode = UIViewContentMode.scaleAspectFit
        
        self.pointSection = UIView()
        self.pointSection?.backgroundColor = UIColor.clear
        self.currentItem = 0
        self.addSubview(collection)
        self.addSubview(self.imageZoom)
        self.addSubview(pointSection!)
        
        self.buildButtonSection()
        self.colorsView = ProductDetailColorSizeView(frame: CGRect(x: 0, y: self.pointSection!.frame.maxY,  width: self.frame.width, height: 60))
        self.colorsView.delegate = self
        self.colorsView.alpha = 0
        self.addSubview(colorsView)
        
        self.sizesView = ProductDetailColorSizeView(frame: CGRect(x: 0, y: self.pointSection!.frame.maxY,  width: self.frame.width, height: 60))
        self.sizesView.delegate = self
        self.sizesView.alpha = 0
        self.addSubview(sizesView)

        
        lowStock = UILabel()
        lowStock!.font = WMFont.fontMyriadProRegularOfSize(12)
        lowStock!.numberOfLines = 1
        lowStock!.textColor =  WMColor.light_red
        lowStock!.isHidden = true
        lowStock!.textAlignment = .center
        lowStock!.text = "Últimas piezas"
        self.addSubview(lowStock!)
        
        
        //presale
        imagePresale =  UIImageView(image: UIImage(named: "preventa_product_detail"))
        imagePresale.isHidden =  true
        self.addSubview(imagePresale)
        
       
    
        priceBefore = CurrencyCustomLabel(frame: CGRect(x: 0, y: self.pointSection!.frame.maxY  , width: self.frame.width, height: 15.0))
        self.addSubview(priceBefore)
        price = CurrencyCustomLabel(frame: CGRect(x: 0, y: self.priceBefore.frame.maxY  , width: self.frame.width, height: 24.0))
        self.addSubview(price)
        saving = CurrencyCustomLabel(frame: CGRect(x: 0, y: self.price.frame.maxY  , width: self.frame.width, height: 15.0))
        self.addSubview(saving)
        
        imageIconView = UIImageView()
        imageIconView.image = UIImage(named:"promocion_detail")
        imageIconView.frame =  CGRect(x: 100, y: 100, width: 70, height: 70)
        self.addSubview(imageIconView)
        
        self.providerView = ProductDetailProviderView(frame: CGRect(x: 0, y: self.pointSection!.frame.maxY,  width: self.frame.width, height: 60))
        self.providerView.alpha = 0.0
        self.addSubview(providerView)
    }
    
    func activePromotions(_ isActive:Bool){
        self.imageIconView.isHidden = !isActive
    }
    
    func setAdditionalValues(_ listPrice:String,price:String,saving:String){
        
       
        
        if price == "" || (price as NSString).doubleValue == 0 {
            self.price.isHidden = true
        } else {
            self.price.isHidden = false
            let formatedValue = "\(CurrencyCustomLabel.formatString(price as NSString))"
            self.price.updateMount(formatedValue, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        }
        
        if listPrice == "" || (listPrice as NSString).doubleValue == 0 || (price as NSString).doubleValue >= (listPrice as NSString).doubleValue  {
            priceBefore.isHidden = true
        } else {
            priceBefore.isHidden = false
            let formatedValue = "\(CurrencyCustomLabel.formatString(listPrice as NSString))"
            self.priceBefore.updateMount(formatedValue, font: WMFont.fontMyriadProLightOfSize(14), color: WMColor.dark_gray, interLine: true)
        }
        
        if saving == "" {
            self.saving.isHidden = true
        } else {
            self.saving.isHidden = false
            let formatedValue = "\(CurrencyCustomLabel.formatString(saving as NSString))"
            self.saving.updateMount(formatedValue, font: WMFont.fontMyriadProSemiboldOfSize(14), color: WMColor.green, interLine: false)
        }
        
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
                point.addTarget(self, action: #selector(ProductDetailBannerCollectionViewCell.pointSelected(_:)), for: .touchUpInside)
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
        let array = self.pointButtons! as [Any]
        if let button = array[self.currentItem!] as? UIButton {
            for inner: UIButton in self.pointButtons! {
                inner.isSelected = button === inner
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var widthNew = self.bounds.width + self.bounds.height - self.heightView
        if widthNew <= self.bounds.width {
            widthNew = self.bounds.width
        }
        
        
        if widthNew > self.bounds.width {
            let heightNew = widthNew - self.bounds.width
            self.collection.alpha = 0
            
            let cellImg = self.collection.cellForItem(at: IndexPath(item: self.currentItem!, section: 0)) as? ProductDetailBannerMediaCollectionViewCell
            if cellImg != nil {
                let originRect = cellImg!.imageView!.frame
                let rectTransform = CGRect(x: originRect.minX - (heightNew / 2), y: originRect.minY, width: originRect.width + heightNew, height: originRect.height + heightNew)
                
                self.imageZoom.image = cellImg!.imageView.image
                UIView.animate(withDuration: 0, animations: { () -> Void in
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
        self.buildProviderView()
        
        self.lowStock?.frame = CGRect(x: 16, y: 8, width: self.frame.width - 32, height: 14.0)
        self.imageIconView.frame =  CGRect(x: self.bounds.width - 86, y: self.bounds.height - 144 ,width: 70 ,height: 70)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.buildButtonSection()
        self.buildColorsAndSizesView()
        self.buildProviderView()
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ProductDetailBannerMediaCollectionViewCell
        let imageURL = items[indexPath.row] as! String
        if imageURL != "" {
            cell.imageView!.contentMode = self.contentModeOrig
            cell.imageView!.setImageWith(URL(string: imageURL)!, placeholderImage: UIImage(named:"img_default_cell"))
        } else {
            cell.imageView!.image = UIImage(named:"img_default_cell")
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.sleectedImage(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        return self.collection.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func buildColorsAndSizesView(){
        let bottomSpace: CGFloat = self.hasProviders ? 124 : 54.0
        
        if colors?.count != 0 || sizes?.count != 0{
            if colors?.count != 0 && sizes?.count != 0{
                self.colorsView.items = self.colors as! [[String:Any]] as [[String : AnyObject]]!
                self.colorsView.alpha = 1.0
                let frame = collection.frame
                self.collection.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 160)
                self.pointSection.frame = CGRect(x: 0, y: self.bounds.height - (bottomSpace + 100), width: self.bounds.width, height: 20)
                self.colorsView.frame =  CGRect(x: 0,  y: self.bounds.height - (bottomSpace + 80), width: self.frame.width, height: 40.0)
                self.colorsView.buildItemsView()
                self.sizesView.items = self.sizes as! [[String:Any]] as [[String : AnyObject]]!
                self.sizesView.alpha = 1.0
                self.sizesView.frame =  CGRect(x: 0,  y: self.bounds.height - (bottomSpace + 40), width: self.frame.width, height: 40.0)
                self.sizesView.buildItemsView()
                self.sizesView.deleteTopBorder()
            }else if colors?.count != 0 && sizes?.count == 0{
                self.sizesView.alpha = 0
                self.colorsView.items = self.colors as! [[String:Any]] as [[String : AnyObject]]!
                self.colorsView.alpha = 1.0
                let frame = collection.frame
                self.collection.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 160)
                self.pointSection.frame = CGRect(x: 0, y: self.bounds.height - (bottomSpace + 60), width: self.bounds.width, height: 20)
                self.colorsView.frame =  CGRect(x: 0,  y: self.bounds.height - (bottomSpace + 40), width: self.frame.width, height: 40.0)
                self.colorsView.buildItemsView()
            }else if colors?.count == 0 && sizes?.count != 0{
                self.colorsView.alpha = 0
                self.sizesView.items = self.sizes as! [[String:Any]] as [[String : AnyObject]]!
                self.sizesView.alpha = 1.0
                let frame = collection.frame
                self.collection.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 160)
                self.pointSection.frame = CGRect(x: 0, y: self.bounds.height - (bottomSpace + 60), width: self.bounds.width, height: 20)
                self.sizesView.frame =  CGRect(x: 0,  y: self.bounds.height - (bottomSpace + 40), width: self.frame.width, height: 40.0)
                self.sizesView.buildItemsView()
            }
        }else{
            self.colorsView.alpha = 0
            self.sizesView.alpha = 0
            let frame = collection.frame
            self.pointSection.frame = CGRect(x: 0, y: self.bounds.height - (bottomSpace + 20), width: self.bounds.width, height: 20)
            self.collection.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: self.bounds.height - (bottomSpace + 30))
        }
    }
    
    func buildProviderView() {
        
        var bottomPossition: CGFloat = 0.0
        if self.hasProviders {
            self.providerView.frame = CGRect(x: 0, y: self.bounds.height - 70, width: self.bounds.width, height: 70)
            self.providerView.alpha = 1.0
            self.providerView.setValues(provider: self.providerInfo!)
            let price = self.providerInfo!["price"] as! String
            let formatedValue = "\(CurrencyCustomLabel.formatString(price as NSString))"
            self.price.updateMount(formatedValue, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
            bottomPossition = 70.0
        }else{
            self.providerView.alpha = 0.0
        }
        
        self.priceBefore.frame = CGRect(x: 0,  y: self.bounds.height - (bottomPossition + 54)   , width: self.frame.width, height: 15.0)
        self.price.frame = CGRect(x: 0, y: self.bounds.height - (bottomPossition + 39)  , width: self.frame.width, height: 24.0)
        self.saving.frame = CGRect(x: 0, y: self.bounds.height - (bottomPossition + 15)  , width: self.frame.width, height: 15.0)
    }

    
    //MARK: ProductDetailColorSizeDelegate
    
    func selectDetailItem(_ selected: String, itemType: String) {
      colorsViewDelegate?.selectDetailItem(selected, itemType: itemType)
    }
}
