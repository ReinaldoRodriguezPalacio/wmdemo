//
//  IPASectionHeaderSearchReusable.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/5/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol IPASectionHeaderSearchReusableDelegate {
        func showFamilyController()
}


class IPASectionHeaderSearchReusable : UICollectionReusableView {
    
    var title : UIButton!
    var titleImage : UIImageView!
    var delegate : IPASectionHeaderSearchReusableDelegate!
    
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        
        
        title = UIButton(frame: CGRect(x: (self.frame.width / 2) - 200, y: (self.frame.height / 2) - 12, width: 400, height: 24))
        title.backgroundColor = WMColor.light_blue
        title.addTarget(self, action: #selector(IPASectionHeaderSearchReusable.didTapInTitle), for: UIControlEvents.touchUpInside)
        title.setTitleColor(UIColor.white, for: UIControlState())
        title.titleLabel!.font =  WMFont.fontMyriadProRegularOfSize(16)
        title.titleLabel!.textAlignment = .left
        title.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        title.titleEdgeInsets = UIEdgeInsetsMake(2.0, 10, 0, 0.0);
        title.layer.cornerRadius = 4
        
        let imageDown = UIImage(named: "categories_title_down")
        titleImage = UIImageView(frame: CGRect(x: 0, y: 0, width: imageDown!.size.width, height: imageDown!.size.height))
        titleImage.image = imageDown
        
        title.addSubview(titleImage)

        self.addSubview(title)
        

    }
    
    
    func didTapInTitle() {
        title.backgroundColor = WMColor.blue
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.titleImage.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        })
        
        if delegate != nil {
            delegate.showFamilyController()
        }
    }
    
    
    func setSelected(){
        title.backgroundColor = WMColor.blue
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.titleImage.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        })
    }
    
    
    func dismissPopover() {
        DispatchQueue.main.async(execute: {
            self.title.backgroundColor = WMColor.light_blue
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.titleImage.transform = CGAffineTransform(rotationAngle: CGFloat(0))
            })
        })
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleImage.frame = CGRect(x: self.title.frame.width - titleImage.frame.width - 10 ,y: (self.title.frame.height / 2) - (titleImage.frame.height / 2), width: titleImage.frame.width, height: titleImage.frame.height)
    }
    
}
