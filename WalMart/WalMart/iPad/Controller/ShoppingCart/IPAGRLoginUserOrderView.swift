//
//  IPAGRLoginUserOrderView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 3/17/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol IPAGRLoginUserOrderViewDelegate {
    func showlogin()
}

class IPAGRLoginUserOrderView : UIView {
    
    var imgBgEmptyLogin : UIImageView!
    var lblDesc : UILabel!
    var btnLogin : UIButton!
    var delegate : IPAGRLoginUserOrderViewDelegate? = nil
    var totalsView : IPOCheckOutTotalView!
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        imgBgEmptyLogin = UIImageView(image: UIImage(named: "loginNow"))
        self.addSubview(imgBgEmptyLogin)
        
        lblDesc = UILabel(frame: CGRectZero)
        lblDesc.text = NSLocalizedString("gr.shoppingcart.login", comment: "")
        lblDesc.font = WMFont.fontMyriadProLightOfSize(16)
        lblDesc.textAlignment = .Center
        lblDesc.textColor = WMColor.light_blue
        lblDesc.numberOfLines = 0
        self.addSubview(lblDesc)
        
        
        btnLogin = UIButton(frame: CGRectZero)
        btnLogin.backgroundColor = WMColor.green
        btnLogin.layer.cornerRadius = 20
        btnLogin.setTitle(NSLocalizedString("profile.signIn", comment: ""), forState: UIControlState.Normal)
        btnLogin.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        btnLogin.addTarget(self, action: #selector(IPAGRLoginUserOrderView.showlogin), forControlEvents: UIControlEvents.TouchUpInside)
        btnLogin.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.addSubview(btnLogin)
        
        totalsView = IPOCheckOutTotalView(frame: CGRectZero)
        self.addSubview(totalsView)
    }
    
    
    override func layoutSubviews() {
        imgBgEmptyLogin.frame = CGRectMake(0, 0, imgBgEmptyLogin.image!.size.width, imgBgEmptyLogin.image!.size.height)
        lblDesc.frame = CGRectMake(0, 76, self.frame.width, 36)
        btnLogin.frame = CGRectMake((self.frame.width / 2) - 80 , 486, 160, 40)
        totalsView.frame = CGRectMake(0, imgBgEmptyLogin.frame.maxY, self.frame.width, self.frame.height - imgBgEmptyLogin.frame.maxY)
    }
    
    
    func setValues(numProds: String,subtotal: String,saving:String){
        totalsView.setValues(numProds, subtotal: subtotal, saving: saving)
    }
    
    func showlogin() {
        delegate?.showlogin()
    }
    
    
    
    
    
}