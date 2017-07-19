//
//  SESugestedRow.swift
//  WalMart
//
//  Created by Vantis on 19/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation
import UIKit

class SESugestedRow : UITableViewCell, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    var collection: UICollectionView?
    var contenido: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setup() {
        
        contenido = UIView(frame: CGRect(x: 5, y: 0, width: self.bounds.width + 50, height: 100))
        contenido.backgroundColor = UIColor.blue
        collection = getCollectionView()
        collection?.register(SESugestedCarViewCell.self, forCellWithReuseIdentifier: "sugestedCarViewCell")
        collection?.allowsMultipleSelection = false
        collection!.dataSource = self
        collection!.delegate = self
        collection!.backgroundColor = WMColor.light_light_gray
        self.contenido.addSubview(collection!)
        
        self.addSubview(self.contenido)
        
        
    }
    
    
    
    func getCollectionView() -> UICollectionView {
        let customlayout = UICollectionViewFlowLayout()
        customlayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.contenido.frame.width, height: self.contenido.frame.size.height), collectionViewLayout: customlayout)
        
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        
        return collectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sugestedCarViewCell", for: indexPath) as! SESugestedCarViewCell
        cell.setValues("0303030303", productImageURL: "https://super.walmart.com.mx/images/product-images/img_small/00000007504268s.jpg", productShortDescription: "Producto Demo", productPrice: "12")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let hardCodedPadding:CGFloat = 5
        let itemWidth = ((self.superview?.frame.width)! * 0.6) - hardCodedPadding
        let itemHeight = collectionView.bounds.height * 0.8 - (2 * hardCodedPadding)
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
