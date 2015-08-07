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
    var distanceLabel: UILabel?
    var separatorView: UIView?

    var distanceFmt: NSNumberFormatter?

    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        var backgroundColorView = UIView()
        backgroundColorView.backgroundColor = WMColor.UIColorFromRGB(0xEEEEEE)
        self.selectedBackgroundView = backgroundColorView

        self.distanceFmt = NSNumberFormatter()
        self.distanceFmt!.maximumFractionDigits = 2
        self.distanceFmt!.minimumFractionDigits = 2
        self.distanceFmt!.locale = NSLocale.systemLocale()

        self.storeIcon = UIImageView(image: UIImage(named: "sparkle"))
        self.contentView.addSubview(self.storeIcon!)
        
        self.distanceLabel = UILabel()
        self.distanceLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.distanceLabel!.textColor = WMColor.titleTextColor
        self.distanceLabel!.text = "A km"
        self.contentView.addSubview(self.distanceLabel!)

        self.separatorView = UIView()
        self.separatorView!.backgroundColor  = WMColor.UIColorFromRGB(0xEEEEEE)
        self.contentView.addSubview(self.separatorView!)

        self.buttonContainer!.removeFromSuperview()
        self.buttonContainer = nil
    }
    
    override func buildToolbar() {
    }
    
    override func setValues(store:Store?, userLocation:CLLocation?) {
        super.setValues(store, userLocation: userLocation)
        var distanceTxt: String? = ""
        if userLocation != nil {
            var storeLocation: CLLocation = CLLocation(latitude: self.store!.latitude!.doubleValue, longitude: self.store!.longitude!.doubleValue)
            var distance: CLLocationDistance = userLocation!.distanceFromLocation(storeLocation)
            distanceTxt = self.distanceFmt!.stringFromNumber(NSNumber(double: distance/1000))
        }
        
        self.distanceLabel!.text = String(format: NSLocalizedString("store.distance", comment:""), distanceTxt!)

    }

    override func layoutSubviews() {
        var bounds = self.frame.size
        let sep:CGFloat = 16.0
        let width:CGFloat = bounds.width - (2*sep)
        
        self.storeIcon!.frame = CGRectMake(sep, sep, 16.0, 16.0)
        self.titleLabel!.frame = CGRectMake(self.storeIcon!.frame.maxX + sep, sep, width - (self.storeIcon!.frame.maxX + sep), 17.0)
        self.distanceLabel!.frame = CGRectMake(self.storeIcon!.frame.maxX + sep, self.titleLabel!.frame.maxY, width - (self.storeIcon!.frame.maxX + sep), 12.0)
        var computedRect = self.size(forLabel: self.addressLabel, andSize: CGSizeMake(width, CGFloat.max))
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
            var text = "\(address) CP: \(store.zipCode!)"
            var addressSize = ClubLocatorTableViewCell.size(forText: text, withFont: WMFont.fontMyriadProRegularOfSize(13), andSize: CGSizeMake(width_, CGFloat.max))
            height += addressSize.height
        }
        height += 16.0
        height += 17.0 //Teléfonos
        height += 17.0 //Horarios
        height += 16.0
        return CGSizeMake(width, height)
    }

}
