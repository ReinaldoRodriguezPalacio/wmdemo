//
//  StoreView.swift
//  WalMart
//
//  Created by neftali on 04/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol StoreViewDelegate {
    func showInstructions(_ store:Store, forCar flag:Bool)
    func makeCallForStore(_ store:Store)
    func shareStore(_ store:Store)
    func showInMap(_ store:Store)
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
    var distanceFmt: NumberFormatter?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.white
        
        self.distanceFmt = NumberFormatter()
        self.distanceFmt!.maximumFractionDigits = 2
        self.distanceFmt!.minimumFractionDigits = 2
        self.distanceFmt!.locale = nil

        let width:CGFloat = self.frame.width - (2*sep)
        
        self.titleLabel = UILabel(frame: CGRect(x: sep, y: sep, width: width, height: 17.0))
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel!.textColor = WMColor.light_blue
        self.addSubview(self.titleLabel!)
        
        self.distanceLabel = UILabel(frame: CGRect(x: sep, y: self.titleLabel!.frame.maxY, width: width, height: 12.0))
        self.distanceLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.distanceLabel!.textColor = WMColor.light_blue
        self.distanceLabel!.text = "A km"
        self.addSubview(self.distanceLabel!)
        
        self.addressLabel = UILabel(frame: CGRect(x: sep, y: self.distanceLabel!.frame.maxY + sep, width: width, height: 45))
        self.addressLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.addressLabel!.numberOfLines = 0
        self.addressLabel!.textColor = WMColor.gray
        self.addSubview(self.addressLabel!)
        
        self.hoursOpenLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: width, height: 15.0))
        self.hoursOpenLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.hoursOpenLabel!.textColor = WMColor.gray
        self.addSubview(self.hoursOpenLabel!)
        
        self.phoneLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: width, height: 15.0))
        self.phoneLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.phoneLabel!.textColor = WMColor.gray
        self.addSubview(self.phoneLabel!)
        
        self.footerView = UIView()
        self.footerView!.backgroundColor = WMColor.light_light_gray
        self.addSubview(self.footerView!)
        
        self.buttons = []
        self.buildToolbar()

    }
    
    func buildToolbar() {
        self.showDirectionsButton = UIButton()
        self.showDirectionsButton!.setImage(UIImage(named: "directions"), for: UIControlState())
        self.showDirectionsButton!.setImage(UIImage(named: "directions_selected"), for: .selected)
        self.showDirectionsButton!.setImage(UIImage(named: "directions_selected"), for: .highlighted)
        self.showDirectionsButton!.addTarget(self, action: #selector(StoreView.showCarRoute), for: .touchUpInside)
        self.footerView!.addSubview(self.showDirectionsButton!)
        self.buttons!.append(self.showDirectionsButton!)
        
        self.makeCallButton = UIButton()
        self.makeCallButton!.setImage(UIImage(named: "call"), for: UIControlState())
        self.makeCallButton!.setImage(UIImage(named: "call_selected"), for: .selected)
        self.makeCallButton!.setImage(UIImage(named: "call_selected"), for: .highlighted)
        self.makeCallButton!.addTarget(self, action: #selector(StoreView.makePhoneCall), for: .touchUpInside)
        self.footerView!.addSubview(self.makeCallButton!)
        
        if IS_IPHONE && !IS_IPOD {
            self.buttons!.append(self.makeCallButton!)
        }
        
        self.shareStoreButton = UIButton()
        self.shareStoreButton!.setImage(UIImage(named: "detail_shareOff"), for: UIControlState())
        self.shareStoreButton!.setImage(UIImage(named: "detail_share"), for: .selected)
        self.shareStoreButton!.setImage(UIImage(named: "detail_share"), for: .highlighted)
        self.shareStoreButton!.addTarget(self, action: #selector(StoreView.shareStore), for: .touchUpInside)
        self.footerView!.addSubview(self.shareStoreButton!)
        self.buttons!.append(self.shareStoreButton!)
    }

    func setValues(_ store:Store?, userLocation:CLLocation?) {
        self.store = store
        
        var distanceTxt: String? = ""
        if userLocation != nil {
            let storeLocation: CLLocation = CLLocation(latitude: self.store!.latitude!.doubleValue, longitude: self.store!.longitude!.doubleValue)
            let distance: CLLocationDistance = userLocation!.distance(from: storeLocation)
            distanceTxt = self.distanceFmt!.string(from: NSNumber(value: distance/1000 as Double))
        }
        
        //Event
//        //TODOGAI
//        if let tracker = GAI.sharedInstance().defaultTracker {
//            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_STORELACATION.rawValue,
//                action:WMGAIUtils.EVENT_STORELOCATOR_MAP_SHOWSTOREDETAIL.rawValue,
//                label: self.store!.name,
//                value: nil).build() as [NSObject : AnyObject])
//        }
        
        self.titleLabel!.text = "WALMART \(store!.name!)".capitalized
        self.distanceLabel!.text = String(format: NSLocalizedString("store.distance", comment:""), distanceTxt!)
        self.addressLabel!.text = "\(store!.address!.capitalized) CP: \(store!.zipCode!)"
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
        self.addressLabel!.frame = CGRect(x: sep, y: self.distanceLabel!.frame.maxY + sep, width: width, height: size.height)

        self.phoneLabel!.frame = CGRect(x: sep, y: self.addressLabel!.frame.maxY + sep, width: width, height: 15.0)
        self.hoursOpenLabel!.frame = CGRect(x: sep, y: self.phoneLabel!.frame.maxY, width: width, height: 15.0)
        
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
    
    //MARK: - Utils
    
    func sizeForLabel(_ label:UILabel, width:CGFloat) -> CGSize {
        let computedRect: CGRect = label.text!.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSFontAttributeName:label.font],
            context: nil)
        return CGSize(width: ceil(computedRect.size.width), height: ceil(computedRect.size.height))
    }

    //MARK: - Actions
    
    func showStepRoute() {
        //Event
        //TODOGAI
//        if let tracker = GAI.sharedInstance().defaultTracker {
//            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_STORELACATION.rawValue,
//                action:WMGAIUtils.EVENT_STORELOCATOR_MAP_DIRECTION.rawValue,
//                label: self.store!.name,
//                value: nil).build() as [NSObject : AnyObject])
//        }

        self.delegate?.showInstructions(self.store!, forCar: false)
    }

    func showCarRoute() {
        //Event
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_MAP_ROUTE_STORE.rawValue, label: self.store!.name!)
        self.delegate?.showInstructions(self.store!, forCar: true)
    }
    
    func makePhoneCall() {
        //Event
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_MAP_CALL_STORE.rawValue, label: self.store!.name!)
        self.delegate?.makeCallForStore(self.store!)
    }
    
    func shareStore() {
        //Event
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_MAP_SHARE_STORE.rawValue, label: self.store!.name!)
        self.delegate?.shareStore(self.store!)
    }
    
}
