//
//  ProductDetailBundleCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/29/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailBundleCollectionViewCell : ProductDetailCrossSellCollectionViewCell {
    var type : String!
    
    override func setup() {
        super.setup()
        collection.register(ProductDetailBundleItemCollectionViewCell.self, forCellWithReuseIdentifier: "productBundleCell")
        titleLabel.text = NSLocalizedString("productdetail.bundleitems",comment:"")
    }
    
    override func layoutSubviews() {
        collection.frame = CGRect(x: self.bounds.minX,y: 40,width: self.bounds.width,height: self.bounds.height - 40)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "productBundleCell", for: indexPath) as! ProductDetailBundleItemCollectionViewCell
        
        let itemUPC = itemsUPC[(indexPath as NSIndexPath).row] as! NSDictionary
        let item = itemUPC["item"] as! [String:Any]
        let parentProducts = item["parentProducts"] as! [[String:Any]]
        let parent = parentProducts.first
        let desc = parent!["description"] as! String
        let imageUrl = parent!["thumbnailImageUrl"] as! String
 
        
        cell.setValues(imageUrl, productShortDescription: desc)
        
        return cell
    }
    
}
