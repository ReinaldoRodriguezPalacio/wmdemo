//
//  HelpMercuryView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/7/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol HelpMercuryViewDelegate {
    func willCloseHelp()
}

class HelpMercuryView : UIView {
    
    var viewBg : UIView? = nil
    var viewImageBg : UIImageView? = nil
    var labelDesc : UILabel? = nil
    var delegate : HelpMercuryViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    func setup() {
        
        
        let tapHelp = UITapGestureRecognizer(target: self, action: "taponhelpview")
        tapHelp.numberOfTapsRequired = 1
        
        self.viewBg = UIView()
        self.viewBg?.backgroundColor = UIColor.blackColor()
        self.viewBg?.alpha = 0.7
        self.viewBg?.addGestureRecognizer(tapHelp)
        
        self.labelDesc = UILabel()
        self.labelDesc?.backgroundColor = UIColor.clearColor()
        self.labelDesc?.textColor = UIColor.whiteColor()
        self.labelDesc?.font = UIFont.systemFontOfSize(16)
        self.labelDesc?.text = "Rastrea tu pedido aquí"
        
        self.viewImageBg = UIImageView(image: UIImage(named: "help_icon"))
        
        
        
        self.addSubview(self.viewBg!)
        self.addSubview(self.labelDesc!)
        self.addSubview(self.viewImageBg!)
        
    }
    
    
    override func layoutSubviews() {
        self.viewBg?.frame = self.bounds
        self.labelDesc?.frame = CGRectMake(self.frame.width - 214 , self.bounds.maxY - 135, 214, 16)
        self.viewImageBg?.frame = CGRectMake(self.frame.width - 120, self.bounds.maxY - 115, 120, 58)
    }
    
    func taponhelpview() {
        self.removeFromSuperview()
        self.delegate?.willCloseHelp()
    }
    
}