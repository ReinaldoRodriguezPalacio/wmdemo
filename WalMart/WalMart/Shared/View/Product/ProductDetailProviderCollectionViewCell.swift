//
//  ProductDetailProviderCollectionViewCell.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 24/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailProviderCollectionViewCell : UICollectionViewCell {
    
    
    var titleLabel = UILabel()
    var switchBtn = UIButton()
    var collection: UICollectionView!
    
    var itemsProvider: [[String:Any]] = [] {
        didSet {
            collection.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.removeSubViews()
        
        titleLabel.text = "Artículo nuevo vendido por" //NSLocalizedString("productdetail.related",comment:"")
        titleLabel.font =  WMFont.fontMyriadProLightOfSize(14)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        titleLabel.textColor = WMColor.light_blue
        self.addSubview(titleLabel)
        
        switchBtn.setTitle("reacondicionados", for: .normal)
        switchBtn.titleLabel?.font =  WMFont.fontMyriadProLightOfSize(12)
        switchBtn.setTitleColor(UIColor.white, for: .normal)
        switchBtn.backgroundColor = WMColor.light_blue
        switchBtn.layer.cornerRadius = 8.0
        switchBtn.addTarget(self, action: #selector(switchProviders), for: .touchUpInside)
        self.bringSubview(toFront: switchBtn)
        self.addSubview(switchBtn)
        
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collection = UICollectionView(frame: self.bounds, collectionViewLayout: collectionLayout)
        collection.register(ProviderViewCell.self, forCellWithReuseIdentifier: "providerViewCell")
        
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        collection.backgroundColor = UIColor.white
        self.addSubview(collection)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switchBtn.frame = CGRect(x: self.bounds.width - 120, y: 16, width: 104, height: 16.0)
        titleLabel.frame = CGRect(x: 16, y: 16, width: self.bounds.width - 32, height: 16)
        collection.frame = CGRect(x: 16, y: 56.0, width: self.bounds.width - 32, height: 92)
    }
    
    func switchProviders() {
        if self.switchBtn.isSelected {
           switchBtn.setTitle("reacondicionados", for: .normal)
           titleLabel.text = "Artículo nuevo vendido por"
        }else{
            switchBtn.setTitle("nuevos", for: .normal)
            titleLabel.text = "Artículo reacondicionado vendido por"
        }
        
        self.switchBtn.isSelected = !self.switchBtn.isSelected
    }
    
    func removeSubViews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
}


extension ProductDetailProviderCollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsProvider.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "providerViewCell", for: indexPath) as! ProviderViewCell
        let provider = itemsProvider[indexPath.row]
        cell.setValues(provider)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        return CGSize(width: 136, height: 92)
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 8
    }

}

extension ProductDetailProviderCollectionViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    }
}

