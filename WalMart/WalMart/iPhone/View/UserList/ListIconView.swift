//
//  ListIconView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 05/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit


class ListIconView : UIView {
    
    var titleLabel: UILabel?
    var iconImageView: UIImageView?
    var indicator: UIActivityIndicatorView?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.configure()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }
    
    func configure() {
        self.titleLabel = UILabel(frame:CGRectMake(0, 0, self.frame.width, self.frame.height))
        self.titleLabel!.textColor = UIColor.whiteColor()
        self.titleLabel!.textAlignment = .Center
        self.titleLabel!.font = WMFont.fontMyriadProSemiboldSize(16)
        self.titleLabel!.backgroundColor = UIColor.clearColor()

        self.iconImageView = UIImageView(frame:CGRectMake(0, 0, self.frame.width, self.frame.height))
        self.layer.cornerRadius = self.frame.width / 2
    }
    
    func setup(title:String, withColor color:UIColor){
        self.backgroundColor = color
        self.iconImageView?.hidden = true
        if self.titleLabel != nil {
            self.titleLabel!.text = title.listIconString
            self.titleLabel!.hidden = false
            self.addSubview(self.titleLabel!)
            
            var size = self.sizeForLabel(self.titleLabel!)
            self.titleLabel!.frame = CGRectMake(0.0, 0.0, size.width, size.height)
            //Se agregan 1 px para correccion de alineado
            self.titleLabel!.center = CGPointMake(self.frame.width/2, (self.frame.height/2) + 1)
        }
    }

    func setupWithIcon(icon:UIImage, withColor color:UIColor){
        self.backgroundColor = color
        self.titleLabel?.hidden = true

        if self.iconImageView != nil {
            self.iconImageView!.image = icon
            self.iconImageView!.frame = CGRectMake((self.frame.width / 2) - (icon.size.width / 2), (self.frame.height / 2) - (icon.size.height / 2), icon.size.width,icon.size.height)
            self.iconImageView!.hidden = false
            self.addSubview(self.iconImageView!)
        }
    }
    
    func startIndicator(){
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        self.indicator!.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        self.indicator!.startAnimating()
        self.addSubview(self.indicator!)
    }
    
    func stopIndicator(){
        self.indicator?.stopAnimating()
    }

    func sizeForLabel(label:UILabel) -> CGSize {
        var computedRect: CGRect = label.text!.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max),
            options: .UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName:label.font],
            context: nil)
        return CGSizeMake(ceil(computedRect.size.width), ceil(computedRect.size.height))
    }
}