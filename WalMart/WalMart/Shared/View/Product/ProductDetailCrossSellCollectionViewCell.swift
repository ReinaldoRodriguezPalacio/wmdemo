//
//  ProductDetailCrossSellCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation



class ProductDetailCrossSellCollectionViewCell : UICollectionViewCell, UICollectionViewDataSource,UICollectionViewDelegate {
    
    
    var titleLabel = UILabel()
    var collection: UICollectionView!
    var delegate: ProductDetailCrossSellViewDelegate!
    var upc: String = ""
    var itemsUPC: NSArray = [] {
        didSet {
            collection.reloadData()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        
        titleLabel.text = NSLocalizedString("productdetail.related",comment:"")
        titleLabel.frame = CGRectMake(12, 0, self.bounds.width - (12 * 2), 40.0)
        titleLabel.font =  WMFont.fontMyriadProLightOfSize(14)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .Left
        titleLabel.textColor = WMColor.productDetailTitleTextColor
        self.addSubview(titleLabel)
        
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collection = UICollectionView(frame: self.bounds, collectionViewLayout: collectionLayout)
        collection.registerClass(ProductDetailCrossSellItemCollectionViewCell.self, forCellWithReuseIdentifier: "productCrossSellCell")
        
        collection.dataSource = self
        collection.delegate = self
        collection.pagingEnabled = true
        collection.backgroundColor = UIColor.whiteColor()
        
        
        
        self.addSubview(collection)
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collection.frame = CGRectMake(self.bounds.minX, self.bounds.minY + 40.0, self.bounds.width, self.bounds.height - 40.0)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsUPC.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCellWithReuseIdentifier("productCrossSellCell", forIndexPath: indexPath) as! ProductDetailCrossSellItemCollectionViewCell
        
        let itemUPC = itemsUPC[indexPath.row] as! NSDictionary
        
        let desc = itemUPC["description"] as! String
        let price = itemUPC["price"] as! String
        let imageArray = itemUPC["imageUrl"] as! NSArray
        var imageUrl = ""
        if imageArray.count > 0 {
            imageUrl = imageArray.objectAtIndex(0) as! String
        }
        
        cell.setValues(imageUrl, productShortDescription: desc, productPrice: price)
        
        
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return CGSizeMake(106.66, 146)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var upcItems : [[String:String]] = []
        for upcStr in itemsUPC {
            let upc = upcStr["upc"] as! String
            let desc = upcStr["description"] as! String
            let type = ResultObjectType.Mg.rawValue
            
            //Event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue,
                    action:WMGAIUtils.MG_EVENT_PRODUCTDETAIL_RELATEDPRODUCT.rawValue,
                    label: upc,
                    value: nil).build() as [NSObject : AnyObject])
            }
            
            upcItems.append(["upc":upc,"description":desc,"type":type])
        }
        
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! ProductCollectionViewCell!
        //currentCell.hideImageView()
        var pontInView = CGRectZero
        if self.superview?.superview?.superview != nil {
            pontInView = currentCell.convertRect(currentCell!.productImage!.frame, toView:  self.superview?.superview?.superview)
        }else{
            pontInView = currentCell.convertRect(currentCell!.productImage!.frame, toView:  self.superview?.superview)
        }
        
        delegate.goTODetailProduct(upc, items: upcItems,index:indexPath.row,imageProduct: currentCell!.productImage!.image!,point:pontInView)
        
    }
    
}