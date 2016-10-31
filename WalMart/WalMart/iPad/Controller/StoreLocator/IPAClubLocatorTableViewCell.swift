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
        
        self.storeIcon!.frame = CGRect(x: sep, y: sep, width: 16.0, height: 16.0)
        self.titleLabel!.frame = CGRect(x: self.storeIcon!.frame.maxX + sep, y: sep, width: width - (self.storeIcon!.frame.maxX + sep), height: 17.0)
        self.distanceLabel!.frame = CGRect(x: self.storeIcon!.frame.maxX + sep, y: self.titleLabel!.frame.maxY, width: width - (self.storeIcon!.frame.maxX + sep), height: 12.0)
        let computedRect = self.size(forLabel: self.addressLabel, andSize: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        self.addressLabel.frame = CGRect(x: sep, y: self.distanceLabel!.frame.maxY + 16.0, width: width, height: computedRect.height)
        self.phoneLabel!.frame = CGRect(x: sep, y: self.addressLabel.frame.maxY + 16.0, width: width, height: 17.0)
        self.hoursOpenLabel!.frame = CGRect(x: sep, y: self.phoneLabel.frame.maxY, width: width, height: 17.0)
        self.separatorView!.frame = CGRect(x: 0.0, y: bounds.height - 1.0, width: bounds.width, height: 1.0)
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
            let addressSize = ClubLocatorTableViewCell.size(forText: text as NSString, withFont: WMFont.fontMyriadProRegularOfSize(13), andSize: CGSize(width: width_, height: CGFloat.max))
            height += addressSize.height
        }
        height += 16.0
        height += 17.0 //Teléfonos
        height += 17.0 //Horarios
        height += 16.0
        return CGSize(width: width, height: height)
    }

}
