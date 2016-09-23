//
//  ProductDetailBundleCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/29/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailBundleTableViewCell : ProductDetailCrossSellTableViewCell {
    
    var downBorder : UIView!
    
    override func setup() {
        super.setup()
        collection.registerClass(ProductDetailBundleItemCollectionViewCell.self, forCellWithReuseIdentifier: "productBundleCell")
        
        downBorder = UIView(frame: CGRectMake(0, 129, self.frame.width, AppDelegate.separatorHeigth()))
        downBorder.backgroundColor = WMColor.light_light_gray
        
        
        self.addSubview(downBorder)
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCellWithReuseIdentifier("productBundleCell", forIndexPath: indexPath) as! ProductDetailBundleItemCollectionViewCell
        
        let itemUPC = itemsUPC[indexPath.row] as! NSDictionary
        let item = itemUPC["item"] as! [String:AnyObject]
        let parentProducts = item["parentProducts"] as! [[String:AnyObject]]
        let parent = parentProducts.first
        let desc = parent!["description"] as! String
        let imageUrl = parent!["thumbnailImageUrl"] as! String
        cell.setValues(imageUrl, productShortDescription: desc)
        
        return cell
    }
    
}