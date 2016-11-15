//
//  ProductDetailCrossSellCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation



class ProductDetailCrossSellTableViewCell : UITableViewCell, UICollectionViewDataSource,UICollectionViewDelegate {
    
    
    var collection: UICollectionView!
    var delegate: ProductDetailCrossSellViewDelegate!
    var upc: String = ""
    var itemsUPC: NSArray = [] {
        didSet {
            collection.reloadData()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    
    func setup() {
        
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
        collection.frame = self.bounds
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsUPC.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "productCrossSellCell", for: indexPath) as! ProductDetailCrossSellItemCollectionViewCell
        
        let itemUPC = itemsUPC[(indexPath as NSIndexPath).row] as! [String:Any]
        
        let desc = itemUPC["description"] as! String
        let price = itemUPC["price"] as! String
        let imageArray = itemUPC["imageUrl"] as! NSArray
        var imageUrl = ""
        if imageArray.count > 0 {
            imageUrl = imageArray.object(at: 0) as! String
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
            let upc = upcStr["id"] as! String
            let desc = upcStr["displayName"] as! String
            upcItems.append(["upc":upc,"description":desc])
        }
        
        
        
        
        let currentCell = collectionView.cellForItem(at: indexPath) as! ProductCollectionViewCell!
        
         BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BUNDLE_PRODUCT_DETAIL_TAPPED.rawValue, label: "\(currentCell?.upcProduct)")
        //currentCell.hideImageView()
        var pontInView = CGRect.zero
        if self.superview?.superview?.superview != nil {
            pontInView = (currentCell?.convert(currentCell!.productImage!.frame, to:  self.superview?.superview?.superview))!
        }else{
            pontInView = (currentCell?.convert(currentCell!.productImage!.frame, to:  self.superview?.superview))!
        }
        delegate.goTODetailProduct(upc, items: upcItems,index:(indexPath as NSIndexPath).row,imageProduct: currentCell!.productImage!.image!,point:pontInView,idList: "")
        
    }
    
}
