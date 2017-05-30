//
//  ProducDetailProviderTableViewCell.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 30/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class ProducDetailProviderTableViewCell : UITableViewCell {
    
    
    var titleLabel = UILabel()
    var switchBtn = UIButton()
    var collection: UICollectionView!
    var border: CALayer!
    
    var itemsProvider: [[String:Any]] = [] {
        didSet {
            collection.reloadData()
            let cell = collection.cellForItem(at: IndexPath(row: 0, section: 0))
            cell?.isSelected = true
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        switchBtn.frame = CGRect(x: self.bounds.width - 120, y: 16, width: 104, height: 16.0)
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
        
        self.border = CALayer()
        self.border.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(border, at: 99)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 16, y: 16, width: self.bounds.width - 32, height: 16)
        collection.frame = CGRect(x: 16, y: 56.0, width: self.bounds.width - 32, height: 92)
        border.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.size.width, height: 1)
    }
    
    func switchProviders() {
        if self.switchBtn.isSelected {
            switchBtn.setTitle("reacondicionados", for: .normal)
            titleLabel.text = "Artículo nuevo vendido por"
            switchBtn.frame = CGRect(x: self.bounds.width - 120, y: 16, width: 104, height: 16.0)
        }else{
            switchBtn.setTitle("nuevos", for: .normal)
            titleLabel.text = "Artículo reacondicionado vendido por"
            switchBtn.frame = CGRect(x: self.bounds.width - 76, y: 16, width: 60, height: 16.0)
        }
        
        self.switchBtn.isSelected = !self.switchBtn.isSelected
    }
    
    func removeSubViews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
}


extension ProducDetailProviderTableViewCell: UICollectionViewDataSource {
    
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

extension ProducDetailProviderTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

