//
//  IPAFamilyTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAFamilyTableViewCell : IPOFamilyTableViewCell {
    
    var separatorView : UIView!
    
    override func setup() {
        super.setup()
        
        self.titleLabel.textColor = UIColor.white
        
        separatorView = UIView()
        separatorView.backgroundColor = UIColor.white
        self.addSubview(separatorView)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor =  UIColor.white.withAlphaComponent(0.12)
        self.selectedBackgroundView = bgColorView
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.separatorView.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: 1)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.separatorView.isHidden = selected
    }
    

}
