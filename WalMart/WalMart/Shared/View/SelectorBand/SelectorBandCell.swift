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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
     
        self.label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height))
        self.label!.textColor = UIColor.white
        self.label!.backgroundColor = UIColor.clear
        self.label!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.label!.textAlignment = .center
        self.contentView.addSubview(self.label!)
    }
    
    func setText(_ text:NSString, selected:Bool) {
        self.label!.text = text as String
        if selected {
            self.label!.font = WMFont.fontMyriadProBlackOfSize(14)
        }else{
            self.label!.font = WMFont.fontMyriadProRegularOfSize(14)
        }
    }
    
}
