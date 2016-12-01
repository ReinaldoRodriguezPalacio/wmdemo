//
//  SectionHeaderSearchHeader.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 14/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


class SectionHeaderSearchHeader : UICollectionReusableView {
    
    
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
