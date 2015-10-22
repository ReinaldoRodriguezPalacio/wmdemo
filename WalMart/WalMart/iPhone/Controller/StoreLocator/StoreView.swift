//
//  StoreView.swift
//  WalMart
//
//  Created by neftali on 04/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol StoreViewDelegate {
    func showInstructions(store:Store, forCar flag:Bool)
    func makeCallForStore(store:Store)
    func shareStore(store:Store)
    func showInMap(store:Store)
}

class StoreView: UIView {

    let footerHeight:CGFloat = 48.0
    let sep:CGFloat = 16.0
    
    var store: Store?
    var delegate: StoreViewDelegate?
    
    var titleLabel: UILabel?
    var distanceLabel: UILabel?
    var addressLabel: UILabel?
    var phoneLabel: UILabel?
    var hoursOpenLabel: UILabel?
    
    var footerView: UIView?
    var showDirectionsButton: UIButton?
    var makeCallButton: UIButton?
    var shareStoreButton: UIButton?
    
    var buttons: [UIButton]?
    var distanceFmt: NSNumberFormatter?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.whiteColor()
        
        self.distanceFmt = NSNumberFormatter()
        self.distanceFmt!.maximumFractionDigits = 2
        self.distanceFmt!.minimumFractionDigits = 2
        self.distanceFmt!.locale = NSLocale.systemLocale()
        
        //let textColor = Color.UIColorFromRGB(0x56595c)
        let width:CGFloat = self.frame.width - (2*sep)
        
        self.titleLabel = UILabel(frame: CGRectMake(sep, sep, width, 17.0))
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel!.textColor = WMColor.titleTextColor
        self.addSubview(self.titleLabel!)
        
        self.distanceLabel = UILabel(frame: CGRectMake(sep, self.titleLabel!.frame.maxY, width, 12.0))
        self.distanceLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.distanceLabel!.textColor = WMColor.titleTextColor
        self.distanceLabel!.text = "A km"
        self.addSubview(self.distanceLabel!)
        
        self.addressLabel = UILabel(frame: CGRectMake(sep, self.distanceLabel!.frame.maxY + sep, width, 45))
        self.addressLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.addressLabel!.numberOfLines = 0
        self.addressLabel!.textColor = WMColor.productDetailTextColor
        self.addSubview(self.addressLabel!)
        
        self.hoursOpenLabel = UILabel(frame: CGRectMake(0.0, 0.0, width, 15.0))
        self.hoursOpenLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.hoursOpenLabel!.textColor = WMColor.productDetailTextColor
        self.addSubview(self.hoursOpenLabel!)
        
        self.phoneLabel = UILabel(frame: CGRectMake(0.0, 0.0, width, 15.0))
        self.phoneLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.phoneLabel!.textColor = WMColor.productDetailTextColor
        self.addSubview(self.phoneLabel!)
        
        self.footerView = UIView()
        self.footerView!.backgroundColor = WMColor.navigationHeaderBgColor
        self.addSubview(self.footerView!)
        
        self.buttons = []
        self.buildToolbar()

    }
    
    func buildToolbar() {
        self.showDirectionsButton = UIButton()
        self.showDirectionsButton!.setImage(UIImage(named: "directions"), forState: .Normal)
        self.showDirectionsButton!.setImage(UIImage(named: "directions_selected"), forState: .Selected)
        self.showDirectionsButton!.setImage(UIImage(named: "directions_selected"), forState: .Highlighted)
        self.showDirectionsButton!.addTarget(self, action: "showCarRoute", forControlEvents: .TouchUpInside)
        self.footerView!.addSubview(self.showDirectionsButton!)
        self.buttons!.append(self.showDirectionsButton!)
        
        self.makeCallButton = UIButton()
        self.makeCallButton!.setImage(UIImage(named: "call"), forState: .Normal)
        self.makeCallButton!.setImage(UIImage(named: "call_selected"), forState: .Selected)
        self.makeCallButton!.setImage(UIImage(named: "call_selected"), forState: .Highlighted)
        self.makeCallButton!.addTarget(self, action: "makePhoneCall", forControlEvents: .TouchUpInside)
        self.footerView!.addSubview(self.makeCallButton!)
        self.buttons!.append(self.makeCallButton!)
        
        self.shareStoreButton = UIButton()
        self.shareStoreButton!.setImage(UIImage(named: "detail_shareOff"), forState: .Normal)
        self.shareStoreButton!.setImage(UIImage(named: "detail_share"), forState: .Selected)
        self.shareStoreButton!.setImage(UIImage(named: "detail_share"), forState: .Highlighted)
        self.shareStoreButton!.addTarget(self, action: "shareStore", forControlEvents: .TouchUpInside)
        self.footerView!.addSubview(self.shareStoreButton!)
        self.buttons!.append(self.shareStoreButton!)
    }

    func setValues(store:Store?, userLocation:CLLocation?) {
        self.store = store
        
        var distanceTxt: String? = ""
        if userLocation != nil {
            let storeLocation: CLLocation = CLLocation(latitude: self.store!.latitude!.doubleValue, longitude: self.store!.longitude!.doubleValue)
            let distance: CLLocationDistance = userLocation!.distanceFromLocation(storeLocation)
            distanceTxt = self.distanceFmt!.stringFromNumber(NSNumber(double: distance/1000))
        }
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_STOREDETAIL.rawValue, label:self.store!.name!)
        self.titleLabel!.text = self.store!.name
        self.distanceLabel!.text = String(format: NSLocalizedString("store.distance", comment:""), distanceTxt!)
        self.addressLabel!.text = "\(self.store!.address!) CP: \(self.store!.zipCode!)"
        self.phoneLabel!.text = String(format: NSLocalizedString("store.telephone", comment:""), self.store!.telephone!)
        self.hoursOpenLabel!.text = String(format: NSLocalizedString("store.opens", comment:""), self.store!.opens!)
        
        self.setNeedsLayout()
    }
    
    func retrieveCalculatedHeight() -> CGFloat {
        let bounds = self.frame.size
        let size = self.sizeForLabel(self.addressLabel!, width: bounds.width - (2*sep))

        var height = self.sep
        height += self.titleLabel!.frame.height
        height += self.distanceLabel!.frame.height
        height += self.sep
        height += size.height
        height += self.sep
        height += self.phoneLabel!.frame.height
        height += self.hoursOpenLabel!.frame.height
        height += self.sep
        height += self.footerHeight
        return height
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        let width:CGFloat = bounds.width - (2*sep)
        
        let size = self.sizeForLabel(self.addressLabel!, width: width)
        self.addressLabel!.frame = CGRectMake(sep, self.distanceLabel!.frame.maxY + sep, width, size.height)

        self.phoneLabel!.frame = CGRectMake(sep, self.addressLabel!.frame.maxY + sep, width, 15.0)
        self.hoursOpenLabel!.frame = CGRectMake(sep, self.phoneLabel!.frame.maxY, width, 15.0)
        
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
    
    //MARK: - Utils
    
    func sizeForLabel(label:UILabel, width:CGFloat) -> CGSize {
        let computedRect: CGRect = label.text!.boundingRectWithSize(CGSizeMake(width, CGFloat.max),
            options: .UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName:label.font],
            context: nil)
        return CGSizeMake(ceil(computedRect.size.width), ceil(computedRect.size.height))
    }

    //MARK: - Actions
    
    func showStepRoute() {
        self.delegate?.showInstructions(self.store!, forCar: false)
    }

    func showCarRoute() {
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue , categoryNoAuth:WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_MAP_ROUTE_STORE.rawValue , label:self.store!.name!)
        self.delegate?.showInstructions(self.store!, forCar: true)
    }
    
    func makePhoneCall() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue , categoryNoAuth:WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_MAP_CALL_STORE.rawValue , label:self.store!.name!)

        self.delegate?.makeCallForStore(self.store!)
    }
    
    func shareStore() {
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue , categoryNoAuth:WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_MAP_SHARE_STORE.rawValue , label:self.store!.name!)
        self.delegate?.shareStore(self.store!)
    }
    
}
