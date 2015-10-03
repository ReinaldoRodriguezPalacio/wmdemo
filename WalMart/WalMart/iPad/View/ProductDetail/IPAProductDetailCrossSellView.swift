//
//  IPAProductDetailCrossSellView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/14/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAProductDetailCrossSellView : ProductDetailCrossSellView {
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var upcItems : [[String:String]] = []
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ProductCollectionViewCell
        for upcStr in itemsUPC {
            let upc = upcStr["upc"] as! String
            let desc = upcStr["description"] as! String
            
            var typeProdVal :  String = ResultObjectType.Mg.rawValue
            if let myType = upcStr["type"] as?  String {
                typeProdVal = myType
            }
            
            upcItems.append(["upc":upc,"description":desc, "type": typeProdVal ])
        }
        cell.hideImageView()
        let pontInView = cell.convertRect(cell.productImage!.frame, toView:  self.superview?.superview)
        
        //Event
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue,
                action:WMGAIUtils.MG_EVENT_PRODUCTDETAIL_RELATEDPRODUCT.rawValue,
                label: upc,
                value: nil).build() as [NSObject : AnyObject])
        }
        
        delegate.goTODetailProduct(upc, items: upcItems,index:indexPath.row,imageProduct: cell.productImage!.image!,point:pontInView)
    }
    
}