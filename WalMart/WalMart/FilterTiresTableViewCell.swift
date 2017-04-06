//
//  FilterTiresTableViewCell.swift
//  WalMart
//
//  Created by Vantis on 10/03/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit

class FilterTiresTableViewCell: UITableViewCell {

    var myLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        myLabel.backgroundColor = UIColor.clear
        self.contentView.addSubview(myLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
