//
//  IPAProductDetailBundleCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/24/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAProductDetailBundleTableViewCell : ProductDetailBundleTableViewCell {
    
    var currentCellSelected : NSIndexPath!
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        super.collectionView(collectionView, didSelectItemAtIndexPath: indexPath)
        currentCellSelected = indexPath
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! ProductCollectionViewCell!
        currentCell.hideImageView()
    }

    
  
    
}