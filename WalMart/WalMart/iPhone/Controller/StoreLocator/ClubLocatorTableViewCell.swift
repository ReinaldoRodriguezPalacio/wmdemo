//
//  ClubLocatorTableViewCell.swift
//  SAMS
//
//  Created by Gerardo Ramirez on 9/11/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ClubLocatorTableViewCell : UICollectionViewCell {
    
    var store: Store!
    var titleLabel: UILabel!
    var addressLabel: UILabel!
    var phoneLabel: UILabel!
    var hoursOpenLabel: UILabel!
    var buttonContainer: UIView!
    var distanceLabel: UILabel?
    var delegate: StoreViewDelegate!
    var distanceFmt: NumberFormatter?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.backgroundColor = UIColor.white
        
        let sep:CGFloat = 16.0
        let width:CGFloat = frame.size.width - (2*sep)
        
        self.titleLabel = UILabel(frame: CGRect(x: sep, y: sep, width: width, height: 17.0))
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel!.textColor = WMColor.light_blue
        self.contentView.addSubview(self.titleLabel)

        self.addressLabel = UILabel(frame: CGRect(x: sep, y: self.titleLabel.frame.maxY, width: width, height: 45.0))
        self.addressLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.addressLabel!.numberOfLines = 0
        self.addressLabel!.textColor = WMColor.gray
        self.contentView.addSubview(self.addressLabel)

        self.hoursOpenLabel = UILabel()
        self.hoursOpenLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.hoursOpenLabel!.textColor = WMColor.gray
        self.contentView.addSubview(self.hoursOpenLabel)
        
        self.phoneLabel = UILabel()
        self.phoneLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.phoneLabel!.textColor = WMColor.gray
        self.contentView.addSubview(self.phoneLabel)

        self.buttonContainer = UIView(frame: CGRect(x: 0, y: frame.size.height - 48.0, width: frame.size.width, height: 48.0))
        self.buttonContainer.backgroundColor = WMColor.light_light_gray
        self.contentView.addSubview(self.buttonContainer)
        
        self.distanceLabel = UILabel()
        self.distanceLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.distanceLabel!.textColor = WMColor.light_blue
        self.distanceLabel!.text = "A km"
        self.contentView.addSubview(self.distanceLabel!)
        
        self.distanceFmt = NumberFormatter()
        self.distanceFmt!.maximumFractionDigits = 2
        self.distanceFmt!.minimumFractionDigits = 2
        self.distanceFmt!.locale = Locale.system
        
        self.buildToolbar()
    }
    
    func buildToolbar() {
        let y:CGFloat = (self.buttonContainer.frame.height - 34.0)/2

        let btnLocation = UIButton(frame: CGRect(x: 38.0, y: y, width: 34.0, height: 34.0))
        btnLocation.setImage(UIImage(named: "locateInMap"), for: UIControlState())
        btnLocation.setImage(UIImage(named: "locateInMap_selected"), for: .selected)
        btnLocation.setImage(UIImage(named: "locateInMap_selected"), for: .highlighted)
        btnLocation.addTarget(self, action: #selector(ClubLocatorTableViewCell.showInMap), for: .touchUpInside)
        self.buttonContainer.addSubview(btnLocation)

        let btnRoute = UIButton(frame: CGRect(x: btnLocation.frame.maxX + 36, y: y, width: 34.0, height: 34.0))
        btnRoute.setImage(UIImage(named: "directions"), for: UIControlState())
        btnRoute.setImage(UIImage(named: "directions_selected"), for: .selected)
        btnRoute.setImage(UIImage(named: "directions_selected"), for: .highlighted)
        btnRoute.addTarget(self, action: #selector(ClubLocatorTableViewCell.showRoute), for: .touchUpInside)
        self.buttonContainer.addSubview(btnRoute)

        var nexButtonX = btnRoute.frame.maxX
        if IS_IPHONE {
            let btnPhone = UIButton(frame: CGRect(x: btnRoute.frame.maxX + 36, y: y, width: 34.0, height: 34.0))
            btnPhone.setImage(UIImage(named: "call"), for: UIControlState())
            btnPhone.setImage(UIImage(named: "call_selected"), for: .selected)
            btnPhone.setImage(UIImage(named: "call_selected"), for: .highlighted)
            btnPhone.addTarget(self, action: #selector(ClubLocatorTableViewCell.makePhoneCall), for: .touchUpInside)
            self.buttonContainer.addSubview(btnPhone)
            nexButtonX = btnPhone.frame.maxX
        }
        
        let btnShare = UIButton(frame: CGRect(x: nexButtonX + 36, y: y, width: 34.0, height: 34.0))
        btnShare.setImage(UIImage(named: "detail_shareOff"), for: UIControlState())
        btnShare.setImage(UIImage(named: "detail_share"), for: .selected)
        btnShare.setImage(UIImage(named: "detail_share"), for: .highlighted)
        btnShare.addTarget(self, action: #selector(ClubLocatorTableViewCell.shareStore), for: .touchUpInside)
        self.buttonContainer.addSubview(btnShare)
    }
    
    func setValues(_ store:Store?, userLocation:CLLocation?) {
        self.store = store

        self.titleLabel.text = "WALMART \(store!.name!)".capitalized
        self.addressLabel.text = "\(store!.address!.capitalized) CP: \(store!.zipCode!)"
        self.phoneLabel.text = String(format: NSLocalizedString("store.telephone", comment:""), store!.telephone!)
        self.hoursOpenLabel!.text = String(format: NSLocalizedString("store.opens", comment:""), store!.opens!)
        
        var distanceTxt: String? = ""
        if userLocation != nil {
            let storeLocation: CLLocation = CLLocation(latitude: self.store!.latitude!.doubleValue, longitude: self.store!.longitude!.doubleValue)
            let distance: CLLocationDistance = userLocation!.distance(from: storeLocation)
            distanceTxt = self.distanceFmt!.string(from: NSNumber(value: distance/1000 as Double))
        }
        
        self.distanceLabel!.text = String(format: NSLocalizedString("store.distance", comment:""), distanceTxt!)

        self.setNeedsLayout()
        
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        let sep:CGFloat = 16.0
        let width:CGFloat = bounds.width - (2*sep)

        let computedRect = self.size(forLabel: self.addressLabel, andSize: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        self.distanceLabel!.frame = CGRect(x: sep, y: self.titleLabel!.frame.maxY, width: width - sep, height: 12.0)
        self.addressLabel.frame = CGRect(x: sep, y: self.distanceLabel!.frame.maxY + 16.0, width: width, height: computedRect.height)
        self.phoneLabel!.frame = CGRect(x: sep, y: self.addressLabel.frame.maxY + 16.0, width: width, height: 17.0)
        self.hoursOpenLabel!.frame = CGRect(x: sep, y: self.phoneLabel.frame.maxY, width: width, height: 17.0)
        
        self.buttonContainer!.frame = CGRect(x: 0.0, y: bounds.height - 48.0, width: bounds.width, height: 48.0)
        
    }
    
    //MARK: - Actions
    
    func makePhoneCall() {
        //Event
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LIST_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_LIST_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_LOCATOR_CALL_STORE.rawValue, label: self.store!.name!)

        self.delegate?.makeCallForStore(self.store!)
    }
    
    func shareStore() {
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LIST_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_LIST_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_LOCATOR_SHARE_STORE.rawValue, label: self.store!.name!)
        
        self.delegate?.shareStore(self.store!)
    }
    
    func showRoute() {
        
        //Event
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LIST_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_LIST_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_LOCATOR_ROUTE_STORE.rawValue, label: self.store!.name!)

        self.delegate?.showInstructions(self.store!, forCar: true)
    }
    
    func showInMap() {
        //Event
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LIST_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_LIST_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_LIST_SHOW_ON_MAP.rawValue, label: self.store!.name!)

        self.delegate?.showInMap(self.store!)
    }
    
    func size(forLabel label:UILabel, andSize size:CGSize) -> CGSize {
        return ClubLocatorTableViewCell.size(forText: label.text! as NSString, withFont: label.font!, andSize: size)
    }
    
    //MARK: - Size
    
    class func calculateCellHeight(forStore store:Store, width:CGFloat) -> CGSize {
        let width_:CGFloat = width - 30.0
        
        var height: CGFloat = 16.0 //Separation
        height += 17.0 //Name
        height += 16.0
        if let address = store.address {
            let text = "\(address) CP: \(store.zipCode!)"
            let addressSize = ClubLocatorTableViewCell.size(forText: text as NSString, withFont: WMFont.fontMyriadProRegularOfSize(13), andSize: CGSize(width: width_, height: CGFloat.greatestFiniteMagnitude))
            height += addressSize.height
        }
        height += 16.0
        height += 17.0 //Teléfonos
        height += 17.0 //Horarios
        height += 16.0
        height += 48.0 //Toolbar
        return CGSize(width: width, height: height)
    }
    
    class func size(forText text:NSString, withFont font:UIFont, andSize size:CGSize) -> CGSize {
        let computedRect: CGRect = text.boundingRect(with: size,
            options: .usesLineFragmentOrigin,
            attributes: [NSFontAttributeName:font],
            context: nil)
        
        return CGSize(width: computedRect.size.width, height: computedRect.size.height)
    }

    
    
}
