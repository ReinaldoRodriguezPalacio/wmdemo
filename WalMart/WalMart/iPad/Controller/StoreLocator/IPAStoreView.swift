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
        
        self.titleLabel!.textAlignment = .center
        self.distanceLabel!.textAlignment = .center
    }
    
    override func buildToolbar() {
        self.showDirectionsButton = UIButton()
        self.showDirectionsButton!.setImage(UIImage(named: "directions"), for: UIControlState())
        self.showDirectionsButton!.setImage(UIImage(named: "directions_selected"), for: .selected)
        self.showDirectionsButton!.setImage(UIImage(named: "directions_selected"), for: .highlighted)
        self.showDirectionsButton!.addTarget(self, action: Selector("showCarRoute"), for: .touchUpInside)
        self.footerView!.addSubview(self.showDirectionsButton!)
        self.buttons!.append(self.showDirectionsButton!)
        
        self.shareStoreButton = UIButton()
        self.shareStoreButton!.setImage(UIImage(named: "detail_shareOff"), for: UIControlState())
        self.shareStoreButton!.setImage(UIImage(named: "detail_share"), for: .selected)
        self.shareStoreButton!.setImage(UIImage(named: "detail_share"), for: .highlighted)
        self.shareStoreButton!.addTarget(self, action: "shareStore", for: .touchUpInside)
        self.footerView!.addSubview(self.shareStoreButton!)
        self.buttons!.append(self.shareStoreButton!)
    }

    override func setValues(_ store:Store?, userLocation:CLLocation?) {
        self.store = store
        
        var distanceTxt: String? = ""
        if userLocation != nil {
            let storeLocation: CLLocation = CLLocation(latitude: self.store!.latitude!.doubleValue, longitude: self.store!.longitude!.doubleValue)
            let distance: CLLocationDistance = userLocation!.distance(from: storeLocation)
            distanceTxt = self.distanceFmt!.string(from: NSNumber(value: distance/1000 as Double))
        }
        
        self.titleLabel!.text = "WALMART \(store!.name!)".capitalized
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
        
        self.footerView!.frame = CGRect(x: 0.0, y: bounds.height - self.footerHeight, width: bounds.width, height: self.footerHeight)
        
        var w:CGFloat = CGFloat(self.buttons!.count) * 34.0
        w += (CGFloat(self.buttons!.count - 1) * 36.0)
        
        var x: CGFloat = (bounds.width - w)/2
        let y:CGFloat = (self.footerHeight - 34.0)/2
        for button in self.buttons! {
            button.frame = CGRect(x: x, y: y, width: 34.0, height: 34.0)
            x = button.frame.maxX + 36.0
        }
    }

}
