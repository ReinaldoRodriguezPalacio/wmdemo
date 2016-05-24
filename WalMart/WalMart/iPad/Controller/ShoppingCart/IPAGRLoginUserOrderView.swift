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
    func shareCart()
    func addCartProductToList()
}

class IPAGRLoginUserOrderView : UIView {
    
    var imgBgEmptyLogin : UIImageView!
    var lblDesc : UILabel!
    var btnLogin : UIButton!
    var delegate : IPAGRLoginUserOrderViewDelegate? = nil
    var totalsView : IPOCheckOutTotalView!
    var listSelectorController: ListsSelectorViewController?
    var footer: UIView?
    var buttonShop: UIButton?
    var addToListButton: UIButton!
    var buttonShare: UIButton!
    var customlabel : CurrencyCustomLabel!
    
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
        totalsView.backgroundColor = WMColor.light_light_gray
        self.addSubview(totalsView)
        
        self.footer = UIView()
        self.footer!.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.footer!)
        let bounds = self.frame.size
        let footerHeight:CGFloat = 60.0
        self.buttonShop = UIButton(type: .Custom) as UIButton
        self.buttonShop!.frame = CGRectMake(16, (footerHeight / 2) - 17, bounds.width - 32, 34)
        self.buttonShop!.backgroundColor = WMColor.green
        self.buttonShop!.layer.cornerRadius = 17
        self.buttonShop!.addTarget(self, action: #selector(IPAGRLoginUserOrderView.showlogin), forControlEvents: UIControlEvents.TouchUpInside)
        self.footer!.addSubview(self.buttonShop!)
        
        self.addToListButton = UIButton(frame: CGRectMake(8 ,0, 50, footer!.frame.height))
        self.addToListButton!.setImage(UIImage(named: "detail_list"), forState: .Normal)
        self.addToListButton!.setImage(UIImage(named: "detail_list_selected"), forState: .Selected)
        self.addToListButton!.addTarget(self, action: #selector(IPAGRLoginUserOrderView.addCartToList), forControlEvents: .TouchUpInside)
        
        self.buttonShare = UIButton(frame: CGRectMake(self.addToListButton!.frame.maxX, 0, 50, footer!.frame.height))
        self.buttonShare.setImage(UIImage(named: "detail_shareOff"), forState: UIControlState.Normal)
        self.buttonShare.addTarget(self, action: #selector(IPAGRLoginUserOrderView.shareShoppingCart), forControlEvents: UIControlEvents.TouchUpInside)
        self.footer!.addSubview(self.addToListButton!)
        self.footer!.addSubview(self.buttonShare)
    }
    
    
    override func layoutSubviews() {
        self.imgBgEmptyLogin.frame = CGRectMake(0, 0, imgBgEmptyLogin.image!.size.width, imgBgEmptyLogin.image!.size.height)
        self.lblDesc.frame = CGRectMake(0, 76, self.frame.width, 36)
        self.btnLogin.frame = CGRectMake((self.frame.width / 2) - 80 , 486, 160, 40)
        self.totalsView.frame = CGRectMake(0, imgBgEmptyLogin.frame.maxY, self.frame.width, self.frame.height - imgBgEmptyLogin.frame.maxY)
        self.footer!.frame = CGRectMake(0.0, self.bounds.height - 65, bounds.width, 65)
        self.addToListButton.frame = CGRectMake(8 ,0, 50, footer!.frame.height)
        self.buttonShare.frame = CGRectMake(self.addToListButton!.frame.maxX, 0, 50, footer!.frame.height)
        self.buttonShop!.frame = CGRectMake(buttonShare.frame.maxX + 8, (footer!.frame.height / 2) - 17, self.frame.width - buttonShare.frame.maxX - 24, 34)
        self.customlabel!.frame = CGRectMake(0, 0, self.frame.width - buttonShare.frame.maxX - 24, 34)
    }
    
    
    func setValues(numProds: String,subtotal: String,saving:String){
        self.totalsView.setValues(numProds, subtotal: subtotal, saving: saving)
        self.updateShopButton(subtotal)
    }
    
    func updateShopButton(total:String) {
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: CGRectMake(0,0,self.buttonShop!.frame.width,self.buttonShop!.frame.height))
            customlabel.backgroundColor = UIColor.clearColor()
            customlabel.setCurrencyUserInteractionEnabled(true)
            buttonShop!.addSubview(customlabel)
            buttonShop!.sendSubviewToBack(customlabel)
        }
        let shopStr = NSLocalizedString("shoppingcart.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(total)
        let shopStrComplete = "\(shopStr) \(fmtTotal)"
        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.whiteColor(), interLine: false)
    }
    
    func showlogin() {
        delegate?.showlogin()
    }
    
    func shareShoppingCart() {
        delegate?.shareCart()
    }
    
    func addCartToList(){
        delegate?.addCartProductToList()
    }
    
}