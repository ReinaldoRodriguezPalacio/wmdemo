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
    
    required init?(coder aDecoder: NSCoder) {
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
        self.titleLabel = UILabel(frame:CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.titleLabel!.textColor = UIColor.white
        self.titleLabel!.textAlignment = .center
        self.titleLabel!.font = WMFont.fontMyriadProSemiboldSize(16)
        self.titleLabel!.backgroundColor = UIColor.clear

        self.iconImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.layer.cornerRadius = self.frame.width / 2
    }
    
    func setup(_ title:String, withColor color:UIColor){
        self.backgroundColor = color
        self.iconImageView?.isHidden = true
        if self.titleLabel != nil {
            self.titleLabel!.text = title.listIconString
            self.titleLabel!.isHidden = false
            self.addSubview(self.titleLabel!)
            
            let size = self.sizeForLabel(self.titleLabel!)
            self.titleLabel!.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
            //Se agregan 1 px para correccion de alineado
            self.titleLabel!.center = CGPoint(x: self.frame.width/2, y: (self.frame.height/2) + 1)
        }
    }

    func setupWithIcon(_ icon:UIImage, withColor color:UIColor){
        self.backgroundColor = color
        self.titleLabel?.isHidden = true

        if self.iconImageView != nil {
            self.iconImageView!.image = icon
            self.iconImageView!.frame = CGRect(x: (self.frame.width / 2) - (icon.size.width / 2), y: (self.frame.height / 2) - (icon.size.height / 2), width: icon.size.width,height: icon.size.height)
            self.iconImageView!.isHidden = false
            self.addSubview(self.iconImageView!)
        }
    }
    
    func startIndicator(){
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.indicator!.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.indicator!.startAnimating()
        self.addSubview(self.indicator!)
    }
    
    func stopIndicator(){
        self.indicator?.stopAnimating()
    }

    func sizeForLabel(_ label:UILabel) -> CGSize {
        let computedRect: CGRect = label.text!.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSFontAttributeName:label.font],
            context: nil)
        return CGSize(width: ceil(computedRect.size.width), height: ceil(computedRect.size.height))
    }
}
