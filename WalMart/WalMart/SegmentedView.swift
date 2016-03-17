//
//  SegmentedView.swift
//  WalMart
//
//  Created by Joel Juarez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class SegmentedView : UIView {
    
    
    var segmented: UISegmentedControl?
    var contentSegmented: UIView?
    
    var taps =  [NSLocalizedString("En linea", comment:""), NSLocalizedString("Contra entrega", comment:"")]
    
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    func setup() {
        
        self.segmented = UISegmentedControl(items:self.taps as [AnyObject])
        self.segmented!.addTarget(self, action: Selector("segmentedControlAction:"), forControlEvents: .ValueChanged)
        self.segmented!.selectedSegmentIndex = 0
        
        let segmentedSelectedTitleAttributes = [NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(14),
            NSForegroundColorAttributeName:UIColor.whiteColor()]
        let segmentedTitleAttributes = [NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(14),
            NSForegroundColorAttributeName:WMColor.dark_gray]
        
        self.segmented!.setTitleTextAttributes(segmentedTitleAttributes, forState: .Normal)
        self.segmented!.setTitleTextAttributes(segmentedSelectedTitleAttributes, forState: .Selected)
        self.segmented!.setTitleTextAttributes(segmentedSelectedTitleAttributes, forState: .Highlighted)
        
        self.contentSegmented = UIView()
        self.contentSegmented!.addSubview(self.segmented!)
        self.contentSegmented!.clipsToBounds = true
        
        
        self.contentSegmented!.frame = CGRectMake(0.0, 0.0, self.bounds.width, self.bounds.height)
        self.addSubview(contentSegmented!)
        
        
    }
    
    override func layoutSubviews() {
         self.contentSegmented!.frame = CGRectMake(0.0, 0.0, self.bounds.width, self.bounds.height)
    }
    
    
    
    func segmentedControlAction(segmentedControl:UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            
        }
        else {
            
        }
        
    }
    
    
    
    
    
    
}