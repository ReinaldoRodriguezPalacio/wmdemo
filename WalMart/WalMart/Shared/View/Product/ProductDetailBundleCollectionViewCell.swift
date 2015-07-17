//
//  ProductDetailBundleCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/29/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailBundleCollectionViewCell : ProductDetailCrossSellCollectionViewCell {
    
    var downBorder : UIView!
    
    var type : String!
    
    override func setup() {
        super.setup()
        collection.registerClass(ProductDetailBundleItemCollectionViewCell.self, forCellWithReuseIdentifier: "productBundleCell")
        
        downBorder = UIView(frame: CGRectMake(0, 169, self.frame.width, AppDelegate.separatorHeigth()))
        downBorder.backgroundColor = WMColor.lineSaparatorColor
        
        
        self.addSubview(downBorder)
        
               
        titleLabel.text = NSLocalizedString("productdetail.bundleitems",comment:"")
    }
    
    override func layoutSubviews() {
        collection.frame = CGRectMake(self.bounds.minX,40,self.bounds.width,self.bounds.height - 40)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCellWithReuseIdentifier("productBundleCell", forIndexPath: indexPath) as ProductDetailBundleItemCollectionViewCell
        
        let itemUPC = itemsUPC[indexPath.row] as NSDictionary
        
        let desc = itemUPC["description"] as NSString
        let imageArray = itemUPC["imageUrl"] as NSArray
        var imageUrl = ""
        if imageArray.count > 0 {
            imageUrl = imageArray.objectAtIndex(0) as String
        }
        
        cell.setValues(imageUrl, productShortDescription: desc)
        
        return cell
    }
    
}