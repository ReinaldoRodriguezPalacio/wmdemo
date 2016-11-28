//
//  ProductDetailCrossSellView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/14/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol ProductDetailCrossSellViewDelegate {
    
    func goTODetailProduct(_ upc:String,items:[[String:String]],index:Int,imageProduct:UIImage?,point:CGRect,idList:String,isBundle:Bool)
    
}

class ProductDetailCrossSellView :UIView,UICollectionViewDataSource,UICollectionViewDelegate  {
    
    var collection: UICollectionView!
    var delegate: ProductDetailCrossSellViewDelegate!
    var itemSize :CGSize! = CGSize(width: 106.66, height: 146)
    var upc: String = ""
    var itemsUPC: NSArray = []
    var cellClass: AnyClass? = nil
    
    var cellReuseid: String = ""
    var idListSeletSearch = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init(frame: CGRect,cellClass: AnyClass?,cellIdentifier:String) {
        super.init(frame: frame)
        self.cellReuseid = cellIdentifier
        self.cellClass = cellClass
        setup()
    }
    
    func setup() {
        
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collection = UICollectionView(frame: self.bounds, collectionViewLayout: collectionLayout)
        collection.register(self.cellClass, forCellWithReuseIdentifier: self.cellReuseid)
        
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        collection.backgroundColor = UIColor.white
        
        
        
        self.addSubview(collection)
    }
    
    func reloadData(_ itemsUPC: NSArray,upc:String){
        self.itemsUPC = itemsUPC
        self.upc = upc
        collection.reloadData()
    }
    
    
    override func layoutSubviews() {
        collection.frame = self.bounds
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsUPC.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: self.cellReuseid, for: indexPath) as! ProductCollectionViewCell
        
        let itemUPC = itemsUPC[indexPath.row] as! [String:Any]
        
        let desc = itemUPC["description"] as! NSString
        
        var price : NSString = ""
        
        if let value = itemUPC["price"] as? NSString {
            price = value
        }
        else if let value = itemUPC["price"] as? NSNumber {
            price = "\(value)" as NSString
        }
    
        var imageUrl = ""

        
        if let imageArray = itemUPC["imageUrl"] as? NSArray{
            if imageArray.count > 0 {
                imageUrl = imageArray.object(at: 0) as! String
            }
        }
        else
        if let imageArray = itemUPC["imageUrl"] as? NSString{
            imageUrl = imageArray as String
        }
    
        
        cell.setValues(imageUrl, productShortDescription: desc as String, productPrice: price as String)
        
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var upcItems : [[String:String]] = []
        let cell = collectionView.cellForItem(at: indexPath) as! ProductCollectionViewCell
        for upcStr in itemsUPC {
            let upc = upcStr["upc"] as! String
            let desc = upcStr["description"] as! String
   
            upcItems.append(["upc":upc,"description":desc])
        }
        //Event
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_RELATED_PRODUCT.rawValue, label: "\(cell.upcProduct)")
        
        
        delegate.goTODetailProduct(upc, items: upcItems,index:indexPath.row,imageProduct: cell.productImage!.image!,point:CGRect.zero,idList: self.idListSeletSearch, isBundle: false)
    }
    
    
}
