//
//  ProductDetailCrossSellCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation



class ProductDetailCrossSellCollectionViewCell : UICollectionViewCell, UICollectionViewDataSource,UICollectionViewDelegate {
    
    
    var titleLabel = UILabel()
    var collection: UICollectionView!
    var delegate: ProductDetailCrossSellViewDelegate!
    var upc: String = ""
    var idListSelectdFromSearch = ""
    
    var itemsUPC: [[String:Any]] = [] {
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
        
        
        titleLabel.text = NSLocalizedString("productdetail.related",comment:"")
        titleLabel.frame = CGRect(x: 12, y: 0, width: self.bounds.width - (12 * 2), height: 40.0)
        titleLabel.font =  WMFont.fontMyriadProLightOfSize(14)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        titleLabel.textColor = WMColor.light_blue
        self.addSubview(titleLabel)
        
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collection = UICollectionView(frame: self.bounds, collectionViewLayout: collectionLayout)
        collection.register(ProductDetailCrossSellItemCollectionViewCell.self, forCellWithReuseIdentifier: "productCrossSellCell")
        
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        collection.backgroundColor = UIColor.white
        
        
        
        self.addSubview(collection)
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collection.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY + 40.0, width: self.bounds.width, height: self.bounds.height - 40.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsUPC.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "productCrossSellCell", for: indexPath) as! ProductDetailCrossSellItemCollectionViewCell
        
        let itemUPC = itemsUPC[indexPath.row] as! [String:Any]
        
        let desc = itemUPC["description"] as! String
        let price = itemUPC["price"] as! String
        let imageArray = itemUPC["imageUrl"] as! [Any]
        var imageUrl = ""
        if imageArray.count > 0 {
            imageUrl = imageArray[0] as! String
        }
        
        cell.setValues(imageUrl, productShortDescription: desc, productPrice: price)
        
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        return CGSize(width: 106.66, height: 146)
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var upcItems : [[String:String]] = []
        for upcStr in itemsUPC {
            let upc = upcStr["upc"] as! String
            let desc = upcStr["description"] as! String
            let type = ResultObjectType.Mg.rawValue
            upcItems.append(["upc":upc,"description":desc,"type":type])
        }
        
        let currentCell = collectionView.cellForItem(at: indexPath) as! ProductCollectionViewCell!
        
        //currentCell.hideImageView()
        var pontInView = CGRect.zero
        if self.superview?.superview?.superview != nil {
            pontInView = (currentCell?.convert(currentCell!.productImage!.frame, to:  self.superview?.superview?.superview))!
        }else{
            pontInView = (currentCell?.convert(currentCell!.productImage!.frame, to:  self.superview?.superview))!
        }
        
        delegate.goTODetailProduct(upc, items: upcItems,index:indexPath.row,imageProduct: currentCell!.productImage!.image!,point:pontInView,idList: self.idListSelectdFromSearch, isBundle: false)
        
    }
    
}
