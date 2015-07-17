//
//  LoadingProductCollectionViewCell.swift
//  WalMart
//
//  Created by neftali on 23/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class LoadingProductCollectionViewCell: UICollectionViewCell {
    
    var loading: LoadingIconView?

    var title: UILabel?
    var activityIndicator: UIActivityIndicatorView?
    
    let margin: CGFloat = 15.0

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    func setup() {
        self.contentView.backgroundColor = UIColor.whiteColor()
//        self.loading = WMLoadingView(frame: frame)
//        self.loading!.startAnnimating(false)
//        self.contentView.addSubview(self.loading!)

        self.title = UILabel()
        self.title!.textColor = WMColor.searchProductDescriptionTextColors
        self.title!.textAlignment = .Center
        self.title!.backgroundColor = UIColor.clearColor()
        self.title!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.title!.text = NSLocalizedString("product.search.loading", comment:"")
        self.contentView.addSubview(self.title!)

        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.activityIndicator!.startAnimating()
        self.contentView.addSubview(self.activityIndicator!)
        
//        self.loading = LoadingIconView(frame: CGRectMake(0, 0, 30.0, 30.0))
//        self.loading!.center = CGPointMake(frame.width/2, frame.height/2)
//        self.loading!.startAnnimating()
//        self.contentView.addSubview(self.loading!)

    }

    override func layoutSubviews() {
        var bounds = self.frame
        var width: CGFloat = bounds.width - (self.margin*2.0)
        
        var computedRect: CGRect = self.title!.text!.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:self.title!.font], context: nil)
        
        self.title!.frame = CGRectMake(self.margin, self.margin, width, computedRect.size.height)
        var size = self.activityIndicator!.frame.size
        self.activityIndicator!.center = CGPointMake(bounds.size.width/2, CGRectGetMaxY(self.title!.frame) + 10.0 + (size.height/2))
        
    }

}
