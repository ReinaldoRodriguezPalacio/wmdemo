//
//  SegmentedView.swift
//  WalMart
//
//  Created by Joel Juarez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
protocol SegmentedViewDelegate {
    func tapSelected(index:Int)
}

class SegmentedView : UIView {
    
    
    var segmented: UISegmentedControl?
    var contentSegmented: UIView?
    
    var tapsItems =  []
    var delegate :  SegmentedViewDelegate?
    override init(frame: CGRect) {
         super.init(frame:frame)
    }
    
    init(frame: CGRect,items: [AnyObject]) {
        super.init(frame:frame)
        self.tapsItems = items
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    func setup() {
        
        self.segmented = UISegmentedControl(items:self.tapsItems as [AnyObject])
        self.segmented!.addTarget(self, action: #selector(SegmentedView.segmentedControlAction(_:)), forControlEvents: .ValueChanged)
        self.segmented!.selectedSegmentIndex = 0
        self.segmented!.frame = CGRectMake(0.0, 0.0,self.bounds.width , self.bounds.height)
        self.segmented!.layer.cornerRadius = 10
        
        let segmentedSelectedTitleAttributes = [NSFontAttributeName:WMFont.fontMyriadProLightOfSize(14),
            NSForegroundColorAttributeName:UIColor.whiteColor()]
        let segmentedTitleAttributes = [NSFontAttributeName:WMFont.fontMyriadProLightOfSize(14),
            NSForegroundColorAttributeName:WMColor.dark_gray]
        
        self.segmented!.setTitleTextAttributes(segmentedTitleAttributes, forState: .Normal)
        self.segmented!.setTitleTextAttributes(segmentedSelectedTitleAttributes, forState: .Selected)
        self.segmented!.setTitleTextAttributes(segmentedSelectedTitleAttributes, forState: .Highlighted)
        
        let imageNormal = getImageWithColor(WMColor.light_light_gray, size: CGSizeMake(2, 2))
        let imageSelected = getImageWithColor(WMColor.light_blue, size: CGSizeMake(2, 2))
        
        self.segmented!.setBackgroundImage(imageNormal, forState:.Normal, barMetrics:.Default)
        self.segmented!.setBackgroundImage(imageSelected, forState:.Selected, barMetrics:.Default)
        self.segmented!.setBackgroundImage(imageSelected, forState:.Highlighted, barMetrics:.Default)
        
        
        self.segmented!.setDividerImage(getImageWithColor(WMColor.light_gray, size: CGSizeMake(1, 40)), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
        
        self.contentSegmented = UIView()
        self.contentSegmented!.addSubview(self.segmented!)
        self.contentSegmented!.clipsToBounds = true
        
        
        self.contentSegmented!.frame = CGRectMake(0.0, 0.0, self.bounds.width, self.bounds.height)
        self.addSubview(contentSegmented!)
        
    }
    
    override func layoutSubviews() {
        self.contentSegmented!.frame = CGRectMake(0.0, 0.0, self.bounds.width, self.bounds.height)
        self.segmented! .frame = CGRectMake(0.0, 0.0, self.contentSegmented!.frame.width , self.bounds.height)
    }
    
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
    
    
    func segmentedControlAction(segmentedControl:UISegmentedControl) {
        self.delegate?.tapSelected(segmentedControl.selectedSegmentIndex)
        
    }
    
    
}