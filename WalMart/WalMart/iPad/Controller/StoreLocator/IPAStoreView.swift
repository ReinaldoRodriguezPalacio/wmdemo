//
//  IPAStoreView.swift
//  WalMart
//
//  Created by neftali on 03/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class IPAStoreView: StoreView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    override func setup() {
        super.setup()
        
        self.addressLabel!.removeFromSuperview()
        self.addressLabel = nil
        self.hoursOpenLabel!.removeFromSuperview()
        self.hoursOpenLabel = nil
        self.phoneLabel!.removeFromSuperview()
        self.phoneLabel = nil
        
        self.titleLabel!.textAlignment = .Center
        self.distanceLabel!.textAlignment = .Center
    }
    
    override func buildToolbar() {
        self.showDirectionsButton = UIButton()
        self.showDirectionsButton!.setImage(UIImage(named: "directions"), forState: .Normal)
        self.showDirectionsButton!.setImage(UIImage(named: "directions_selected"), forState: .Selected)
        self.showDirectionsButton!.setImage(UIImage(named: "directions_selected"), forState: .Highlighted)
        self.showDirectionsButton!.addTarget(self, action: Selector("showCarRoute"), forControlEvents: .TouchUpInside)
        self.footerView!.addSubview(self.showDirectionsButton!)
        self.buttons!.append(self.showDirectionsButton!)
        
        self.shareStoreButton = UIButton()
        self.shareStoreButton!.setImage(UIImage(named: "detail_shareOff"), forState: .Normal)
        self.shareStoreButton!.setImage(UIImage(named: "detail_share"), forState: .Selected)
        self.shareStoreButton!.setImage(UIImage(named: "detail_share"), forState: .Highlighted)
        self.shareStoreButton!.addTarget(self, action: "shareStore", forControlEvents: .TouchUpInside)
        self.footerView!.addSubview(self.shareStoreButton!)
        self.buttons!.append(self.shareStoreButton!)
    }

    override func setValues(store:Store?, userLocation:CLLocation?) {
        self.store = store
        
        var distanceTxt: String? = ""
        if userLocation != nil {
            let storeLocation: CLLocation = CLLocation(latitude: self.store!.latitude!.doubleValue, longitude: self.store!.longitude!.doubleValue)
            let distance: CLLocationDistance = userLocation!.distanceFromLocation(storeLocation)
            distanceTxt = self.distanceFmt!.stringFromNumber(NSNumber(double: distance/1000))
        }
        
        self.titleLabel!.text = "WALMART \(store!.name!)".capitalizedString
        self.distanceLabel!.text = String(format: NSLocalizedString("store.distance", comment:""), distanceTxt!)
        
        self.setNeedsLayout()
    }

    override func retrieveCalculatedHeight() -> CGFloat {
        
        var height = self.sep
        height += self.titleLabel!.frame.height
        height += self.distanceLabel!.frame.height
        height += self.sep
        height += self.footerHeight
        return height
    }

    override func layoutSubviews() {
        let bounds = self.frame.size
        
        self.footerView!.frame = CGRectMake(0.0, bounds.height - self.footerHeight, bounds.width, self.footerHeight)
        
        var w:CGFloat = CGFloat(self.buttons!.count) * 34.0
        w += (CGFloat(self.buttons!.count - 1) * 36.0)
        
        var x: CGFloat = (bounds.width - w)/2
        let y:CGFloat = (self.footerHeight - 34.0)/2
        for button in self.buttons! {
            button.frame = CGRectMake(x, y, 34.0, 34.0)
            x = button.frame.maxX + 36.0
        }
    }

}
