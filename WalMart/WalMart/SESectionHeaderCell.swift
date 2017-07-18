//
//  SESectionHeaderCell.swift
//  WalMart
//
//  Created by Vantis on 18/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class SESectionHeaderCel : UICollectionReusableView {
    
    
    var title : UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        self.backgroundColor = WMColor.light_gray
        self.title?.lineBreakMode = .byTruncatingTail
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frameTitle = self.title?.frame
        self.title?.frame = self.bounds
        
        if frameTitle?.size.width != 0{
            self.title?.frame = CGRect(x: frameTitle!.origin.x,y: self.bounds.origin.y ,width: frameTitle!.width ,height: self.bounds.size.height )
        }
        
        self.title?.center = CGPoint(x: self.center.x,y: 20)
    }
    
    
}
