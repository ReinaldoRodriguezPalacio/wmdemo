//
//  ProductDetailCrossSellCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation



class ProductDetailCrossSellTableViewCell : UITableViewCell, UICollectionViewDataSource,UICollectionViewDelegate {
    
    
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    
    func setup() {
        
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
        collection.frame = self.bounds
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
            upcItems.append(["upc":upc,"description":desc])
        }
        
        
        
        
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! ProductCollectionViewCell!
        
         //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BUNDLE_PRODUCT_DETAIL_TAPPED.rawValue, label: "\(currentCell.upcProduct)")
        //currentCell.hideImageView()
        var pontInView = CGRectZero
        if self.superview?.superview?.superview != nil {
            pontInView = currentCell.convertRect(currentCell!.productImage!.frame, toView:  self.superview?.superview?.superview)
        }else{
            pontInView = currentCell.convertRect(currentCell!.productImage!.frame, toView:  self.superview?.superview)
        }
        delegate.goTODetailProduct(upc, items: upcItems,index:indexPath.row,imageProduct: currentCell!.productImage!.image!,point:pontInView,idList: "")
        
    }
    
}