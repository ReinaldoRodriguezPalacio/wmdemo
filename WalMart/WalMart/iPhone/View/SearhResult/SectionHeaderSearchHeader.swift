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
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.title?.frame = self.bounds
        self.title?.center = CGPointMake(self.center.x,20)
    }
    
    
}