//
//  IPAClubLocatorTableViewCell.swift
//  WalMart
//
//  Created by neftali on 03/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class IPAClubLocatorTableViewCell: ClubLocatorTableViewCell {

    var storeIcon: UIImageView?
    var separatorView: UIView?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = WMColor.light_light_gray
        self.selectedBackgroundView = backgroundColorView

        self.storeIcon = UIImageView(image: UIImage(named: "sparkle"))
        self.contentView.addSubview(self.storeIcon!)

        self.separatorView = UIView()
        self.separatorView!.backgroundColor  = WMColor.light_light_gray
        self.contentView.addSubview(self.separatorView!)

        self.buttonContainer!.removeFromSuperview()
        self.buttonContainer = nil
    }

    override func layoutSubviews() {
        let bounds = self.frame.size
        let sep:CGFloat = 16.0
        let width:CGFloat = bounds.width - (2*sep)
        
        self.storeIcon!.frame = CGRectMake(sep, sep, 16.0, 16.0)
        self.titleLabel!.frame = CGRectMake(self.storeIcon!.frame.maxX + sep, sep, width - (self.storeIcon!.frame.maxX + sep), 17.0)
        self.distanceLabel!.frame = CGRectMake(self.storeIcon!.frame.maxX + sep, self.titleLabel!.frame.maxY, width - (self.storeIcon!.frame.maxX + sep), 12.0)
        let computedRect = self.size(forLabel: self.addressLabel, andSize: CGSizeMake(width, CGFloat.max))
        self.addressLabel.frame = CGRectMake(sep, self.distanceLabel!.frame.maxY + 16.0, width, computedRect.height)
        self.phoneLabel!.frame = CGRectMake(sep, self.addressLabel.frame.maxY + 16.0, width, 17.0)
        self.hoursOpenLabel!.frame = CGRectMake(sep, self.phoneLabel.frame.maxY, width, 17.0)
        self.separatorView!.frame = CGRectMake(0.0, bounds.height - 1.0, bounds.width, 1.0)
    }

    //MARK: - Size
    
    override class func calculateCellHeight(forStore store:Store, width:CGFloat) -> CGSize {
        let width_:CGFloat = width - 30.0
        
        var height: CGFloat = 16.0 //Separation
        height += 17.0 //Name
        height += 12.0 //Distance
        height += 16.0
        if let address = store.address {
            let text = "\(address) CP: \(store.zipCode!)"
            let addressSize = ClubLocatorTableViewCell.size(forText: text, withFont: WMFont.fontMyriadProRegularOfSize(13), andSize: CGSizeMake(width_, CGFloat.max))
            height += addressSize.height
        }
        height += 16.0
        height += 17.0 //Teléfonos
        height += 17.0 //Horarios
        height += 16.0
        return CGSizeMake(width, height)
    }

}
