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
    var delegate: StoreViewDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.backgroundColor = UIColor.whiteColor()
        
        let textColor = WMColor.UIColorFromRGB(0x56595c)
        let sep:CGFloat = 16.0
        let width:CGFloat = frame.size.width - (2*sep)
        
        self.titleLabel = UILabel(frame: CGRectMake(sep, sep, width, 17.0))
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel!.textColor = WMColor.titleTextColor
        self.contentView.addSubview(self.titleLabel)

        self.addressLabel = UILabel(frame: CGRectMake(sep, self.titleLabel.frame.maxY, width, 45.0))
        self.addressLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.addressLabel!.numberOfLines = 0
        self.addressLabel!.textColor = WMColor.productDetailTextColor
        self.contentView.addSubview(self.addressLabel)

        self.hoursOpenLabel = UILabel()
        self.hoursOpenLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.hoursOpenLabel!.textColor = WMColor.productDetailTextColor
        self.contentView.addSubview(self.hoursOpenLabel)
        
        self.phoneLabel = UILabel()
        self.phoneLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.phoneLabel!.textColor = WMColor.productDetailTextColor
        self.contentView.addSubview(self.phoneLabel)

        self.buttonContainer = UIView(frame: CGRectMake(0, frame.size.height - 48.0, frame.size.width, 48.0))
        self.buttonContainer.backgroundColor = WMColor.navigationHeaderBgColor
        self.contentView.addSubview(self.buttonContainer)
        
        self.buildToolbar()
    }
    
    func buildToolbar() {
        let y:CGFloat = (self.buttonContainer.frame.height - 34.0)/2

        let btnLocation = UIButton(frame: CGRectMake(38.0, y, 34.0, 34.0))
        btnLocation.setImage(UIImage(named: "locateInMap"), forState: .Normal)
        btnLocation.setImage(UIImage(named: "locateInMap_selected"), forState: .Selected)
        btnLocation.setImage(UIImage(named: "locateInMap_selected"), forState: .Highlighted)
        btnLocation.addTarget(self, action: "showInMap", forControlEvents: .TouchUpInside)
        self.buttonContainer.addSubview(btnLocation)

        let btnRoute = UIButton(frame: CGRectMake(btnLocation.frame.maxX + 36, y, 34.0, 34.0))
        btnRoute.setImage(UIImage(named: "directions"), forState: .Normal)
        btnRoute.setImage(UIImage(named: "directions_selected"), forState: .Selected)
        btnRoute.setImage(UIImage(named: "directions_selected"), forState: .Highlighted)
        btnRoute.addTarget(self, action: "showRoute", forControlEvents: .TouchUpInside)
        self.buttonContainer.addSubview(btnRoute)

        let btnPhone = UIButton(frame: CGRectMake(btnRoute.frame.maxX + 36, y, 34.0, 34.0))
        btnPhone.setImage(UIImage(named: "call"), forState: .Normal)
        btnPhone.setImage(UIImage(named: "call_selected"), forState: .Selected)
        btnPhone.setImage(UIImage(named: "call_selected"), forState: .Highlighted)
        btnPhone.addTarget(self, action: "makePhoneCall", forControlEvents: .TouchUpInside)
        self.buttonContainer.addSubview(btnPhone)
        
        let btnShare = UIButton(frame: CGRectMake(btnPhone.frame.maxX + 36, y, 34.0, 34.0))
        btnShare.setImage(UIImage(named: "detail_shareOff"), forState: .Normal)
        btnShare.setImage(UIImage(named: "detail_share"), forState: .Selected)
        btnShare.setImage(UIImage(named: "detail_share"), forState: .Highlighted)
        btnShare.addTarget(self, action: "shareStore", forControlEvents: .TouchUpInside)
        self.buttonContainer.addSubview(btnShare)
    }
    
    func setValues(store:Store?, userLocation:CLLocation?) {
        self.store = store

        self.titleLabel.text = store!.name
        self.addressLabel.text = "\(store!.address!) CP: \(store!.zipCode!)"
        self.phoneLabel.text = String(format: NSLocalizedString("store.telephone", comment:""), store!.telephone!)
        self.hoursOpenLabel!.text = String(format: NSLocalizedString("store.opens", comment:""), store!.opens!)

        self.setNeedsLayout()
        
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        let sep:CGFloat = 16.0
        let width:CGFloat = bounds.width - (2*sep)

        let computedRect = self.size(forLabel: self.addressLabel, andSize: CGSizeMake(width, CGFloat.max))
        self.addressLabel.frame = CGRectMake(sep, self.titleLabel.frame.maxY + 16.0, width, computedRect.height)
        self.phoneLabel!.frame = CGRectMake(sep, self.addressLabel.frame.maxY + 16.0, width, 17.0)
        self.hoursOpenLabel!.frame = CGRectMake(sep, self.phoneLabel.frame.maxY, width, 17.0)
        
        self.buttonContainer!.frame = CGRectMake(0.0, bounds.height - 48.0, bounds.width, 48.0)
    }
    
    //MARK: - Actions
    
    func makePhoneCall() {
        //Event
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_LISTS.rawValue,
                action:WMGAIUtils.EVENT_STORELOCATOR_LIST_CALLSTORE.rawValue,
                label: self.store!.name,
                value: nil).build() as [NSObject : AnyObject])
        }
        self.delegate?.makeCallForStore(self.store!)
    }
    
    func shareStore() {
        self.delegate?.shareStore(self.store!)
    }
    
    func showRoute() {
        
        //Event
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_STORELACATION.rawValue,
                action:WMGAIUtils.EVENT_STORELOCATOR_LIST_DIRECTION.rawValue,
                label: self.store!.name,
                value: nil).build() as [NSObject : AnyObject])
        }
        
        self.delegate?.showInstructions(self.store!, forCar: true)
    }
    
    func showInMap() {
        //Event
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_STORELACATION.rawValue,
                action:WMGAIUtils.EVENT_STORELOCATOR_LIST_SHOWSTOREINMAP.rawValue,
                label: self.store!.name,
                value: nil).build() as [NSObject : AnyObject])
        }
        
        self.delegate?.showInMap(self.store!)
    }
    
    func size(forLabel label:UILabel, andSize size:CGSize) -> CGSize {
        return ClubLocatorTableViewCell.size(forText: label.text!, withFont: label.font!, andSize: size)
    }
    
    //MARK: - Size
    
    class func calculateCellHeight(forStore store:Store, width:CGFloat) -> CGSize {
        let width_:CGFloat = width - 30.0

        var height: CGFloat = 16.0 //Separation
        height += 17.0 //Name
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
        height += 48.0 //Toolbar
        return CGSizeMake(width, height)
    }
    
    class func size(forText text:NSString, withFont font:UIFont, andSize size:CGSize) -> CGSize {
        let computedRect: CGRect = text.boundingRectWithSize(size,
            options: .UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName:font],
            context: nil)
        
        return CGSizeMake(computedRect.size.width, computedRect.size.height)
    }

}