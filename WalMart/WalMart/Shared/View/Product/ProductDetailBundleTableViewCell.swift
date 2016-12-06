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
        
        let itemUPC = itemsUPC[indexPath.row] 
        
        let desc = itemUPC["description"] as! String
        let imageArray = itemUPC["imageUrl"] as! [Any]
        var imageUrl = ""
        if imageArray.count > 0 {
            imageUrl = imageArray[0] as! String
        }

        cell.setValues(imageUrl, productShortDescription: desc)
        
        return cell
    }
    
   override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var upcItems : [[String:String]] = []
        for upcStr in itemsUPC {
            let upc = upcStr["upc"] as! String
            let desc = upcStr["description"] as! String
            upcItems.append(["upc":upc,"description":desc])
        }
        
        let currentCell = collectionView.cellForItem(at: indexPath) as! ProductCollectionViewCell!
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BUNDLE_PRODUCT_DETAIL_TAPPED.rawValue, label: "\(currentCell.upcProduct)")
        //currentCell.hideImageView()
        var pontInView = CGRect.zero
        if self.superview?.superview?.superview != nil {
            pontInView = (currentCell?.convert(currentCell!.productImage!.frame, to:  self.superview?.superview?.superview))!
        }else{
            pontInView = (currentCell?.convert(currentCell!.productImage!.frame, to:  self.superview?.superview))!
        }
        delegate.goTODetailProduct(upc, items: upcItems,index:indexPath.row,imageProduct: currentCell!.productImage!.image!,point:pontInView,idList: "",isBundle: true)
        
    }
    
}
