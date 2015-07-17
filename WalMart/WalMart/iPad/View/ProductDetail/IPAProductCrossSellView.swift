//
//  IPAProductCrossSellView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/14/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAProductCrossSellView : UIView {
    
    var productCrossSell : ProductDetailCrossSellView!
    var delegate : ProductDetailCrossSellViewDelegate! {
        didSet {
            productCrossSell.delegate = delegate
        }
    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.backgroundColor = UIColor.whiteColor()
        
        let viewSeparator = UIView(frame:CGRectMake(0,0,self.frame.width,1))
        viewSeparator.backgroundColor = WMColor.productDetailBarButtonBorder
        
        let viewTitle = UILabel(frame:CGRectMake(16,viewSeparator.frame.maxY + 11 ,self.frame.width,14))
        viewTitle.font = WMFont.fontMyriadProLightOfSize(14)
        viewTitle.textColor = WMColor.productProductPromotionsTextColor
        viewTitle.text = NSLocalizedString("productdetail.related",comment:"")
        
        productCrossSell = IPAProductDetailCrossSellView(frame: CGRectMake(0, viewTitle.frame.maxY + 4, self.frame.width, 196), cellClass: IPAProductDetailCrossSellItemCollectionViewCell.self, cellIdentifier: "iPACrossSell")
        productCrossSell.itemSize = CGSizeMake(170,176)
        
              
        self.addSubview(viewSeparator)
        self.addSubview(viewTitle)
        self.addSubview(productCrossSell)
        
    }
    
    func reloadWithData(data:NSArray,upc:String) {
        productCrossSell.reloadData(data, upc: upc)
    }
    
    func reloadWithData() {
        productCrossSell.collection.reloadData()
    }

    
   
    
    
}