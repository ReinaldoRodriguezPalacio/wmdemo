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
        
        let desc = itemUPC["description"] as! String
        let imageArray = itemUPC["imageUrl"] as! NSArray
        var imageUrl = ""
        if imageArray.count > 0 {
            imageUrl = imageArray.objectAtIndex(0) as! String
        }

        cell.setValues(imageUrl, productShortDescription: desc)
        
        return cell
    }
    
   override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var upcItems : [[String:String]] = []
        for upcStr in itemsUPC {
            let upc = upcStr["upc"] as! String
            let desc = upcStr["description"] as! String
            upcItems.append(["upc":upc,"description":desc])
        }
        
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! ProductCollectionViewCell!
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BUNDLE_PRODUCT_DETAIL_TAPPED.rawValue, label: "\(currentCell.upcProduct)")
        //currentCell.hideImageView()
        var pontInView = CGRectZero
        if self.superview?.superview?.superview != nil {
            pontInView = currentCell.convertRect(currentCell!.productImage!.frame, toView:  self.superview?.superview?.superview)
        }else{
            pontInView = currentCell.convertRect(currentCell!.productImage!.frame, toView:  self.superview?.superview)
        }
        delegate.goTODetailProduct(upc, items: upcItems,index:indexPath.row,imageProduct: currentCell!.productImage!.image!,point:pontInView,idList: "",isBundle: true)
        
    }
    
}