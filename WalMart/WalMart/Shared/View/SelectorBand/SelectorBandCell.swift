//
//  SelectorBancCell.swift
//  WalMart
//
//  Created by neftali on 28/07/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class SelectorBandCell: UICollectionViewCell {

    var label: UILabel? = nil
    var normalFont: UIFont? = nil
    var selectedFont: UIFont? = nil
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
     
        self.label = UILabel(frame: CGRectMake(0.0, 0.0, frame.size.width, frame.size.height))
        self.label!.textColor = UIColor.whiteColor()
        self.label!.backgroundColor = UIColor.clearColor()
        self.label!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.label!.textAlignment = .Center
        self.contentView.addSubview(self.label!)
    }
    
    func setText(text:NSString, selected:Bool) {
        self.label!.text = text
        if selected {
            self.label!.font = WMFont.fontMyriadProBlackOfSize(14)
        }else{
            self.label!.font = WMFont.fontMyriadProRegularOfSize(14)
        }
    }
    
}
