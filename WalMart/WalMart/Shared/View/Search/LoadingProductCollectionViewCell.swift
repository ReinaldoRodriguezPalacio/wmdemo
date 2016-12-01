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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    func setup() {
        self.contentView.backgroundColor = UIColor.white
//        self.loading = WMLoadingView(frame: frame)
//        self.loading!.startAnnimating(false)
//        self.contentView.addSubview(self.loading!)

        self.title = UILabel()
        self.title!.textColor = WMColor.gray
        self.title!.textAlignment = .center
        self.title!.backgroundColor = UIColor.clear
        self.title!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.title!.text = NSLocalizedString("product.search.loading", comment:"")
        self.title!.numberOfLines = 2
        self.contentView.addSubview(self.title!)

        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.activityIndicator!.startAnimating()
        self.contentView.addSubview(self.activityIndicator!)
        
//        self.loading = LoadingIconView(frame: CGRectMake(0, 0, 30.0, 30.0))
//        self.loading!.center = CGPointMake(frame.width/2, frame.height/2)
//        self.loading!.startAnnimating()
//        self.contentView.addSubview(self.loading!)

    }

    override func layoutSubviews() {
        let bounds = self.frame
        let width: CGFloat = bounds.width - (self.margin*2.0)
        
        let computedRect: CGRect = self.title!.text!.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName:self.title!.font], context: nil)
        
        self.title!.frame = CGRect(x: self.margin, y: self.margin, width: width, height: computedRect.size.height)
        let size = self.activityIndicator!.frame.size
        self.activityIndicator!.center = CGPoint(x: bounds.size.width/2, y: self.title!.frame.maxY + 10.0 + (size.height/2))
        
    }

}
