//
//  IPAListTableViewCell.swift
//  WalMart
//
//  Created by neftali on 26/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class IPAListTableViewCell: ListTableViewCell {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .Default

        var backgroundColorView = UIView()
        backgroundColorView.backgroundColor = WMColor.UIColorFromRGB(0xEEEEEE)
        self.selectedBackgroundView = backgroundColorView
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        if let text = self.iconView!.titleLabel!.text {
//            self.iconView?.setup(text, withColor: WMColor.UIColorFromRGB(0x0071CE))
//        }
    }
    
}
