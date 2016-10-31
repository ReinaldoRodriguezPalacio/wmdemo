//
//  IPAProductDetailBundleCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/24/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAProductDetailBundleTableViewCell : ProductDetailBundleTableViewCell {
    
    var currentCellSelected : IndexPath!
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        currentCellSelected = indexPath
        let currentCell = collectionView.cellForItem(at: indexPath) as! ProductCollectionViewCell!
        currentCell?.hideImageView()
    }

    
  
    
}
