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
        collection.register(ProductDetailBundleItemCollectionViewCell.self, forCellWithReuseIdentifier: "productBundleCell")
        
        downBorder = UIView(frame: CGRect(x: 0, y: 129, width: self.frame.width, height: AppDelegate.separatorHeigth()))
        downBorder.backgroundColor = WMColor.light_light_gray
        
        
        self.addSubview(downBorder)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "productBundleCell", for: indexPath) as! ProductDetailBundleItemCollectionViewCell
        
        let itemUPC = itemsUPC[(indexPath as NSIndexPath).row] 
        let item = itemUPC["item"] as! [String:Any]
        let parentProducts = item["parentProducts"] as! [[String:Any]]
        let parent = parentProducts.first
        let desc = parent!["description"] as! String
        let imageUrl = parent!["thumbnailImageUrl"] as! String
        cell.setValues(imageUrl, productShortDescription: desc)
        
        return cell
    }
    
}
