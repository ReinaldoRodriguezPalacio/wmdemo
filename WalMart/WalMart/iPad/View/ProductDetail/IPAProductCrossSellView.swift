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
    
    weak var delegate : ProductDetailCrossSellViewDelegate? {
        didSet {
            productCrossSell.delegate = delegate
        }
    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.backgroundColor = UIColor.white
        
        let viewSeparator = UIView(frame:CGRect(x: 0,y: 0,width: self.frame.width,height: 1))
        viewSeparator.backgroundColor = WMColor.light_gray
        
        let viewTitle = UILabel(frame:CGRect(x: 16,y: viewSeparator.frame.maxY + 11 ,width: self.frame.width,height: 14))
        viewTitle.font = WMFont.fontMyriadProLightOfSize(14)
        viewTitle.textColor = WMColor.light_blue
        viewTitle.text = NSLocalizedString("productdetail.related",comment:"")
        
        productCrossSell = IPAProductDetailCrossSellView(frame: CGRect(x: 0, y: viewTitle.frame.maxY + 4, width: self.frame.width, height: 196), cellClass: IPAProductDetailCrossSellItemCollectionViewCell.self, cellIdentifier: "iPACrossSell")
        productCrossSell.itemSize = CGSize(width: 170,height: 176)
        
              
        self.addSubview(viewSeparator)
        self.addSubview(viewTitle)
        self.addSubview(productCrossSell)
        
    }
    
    func reloadWithData(_ data:[[String:Any]],upc:String) {
        productCrossSell.reloadData(data, upc: upc)
    }
    
    func reloadWithData() {
        productCrossSell.collection.reloadData()
    }
    
    func setIdList(_ idList:String){
        productCrossSell.idListSeletSearch = idList//
    }

    
   
    
    
}
