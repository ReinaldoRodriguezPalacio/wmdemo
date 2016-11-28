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
        
        lblDesc = UILabel(frame: CGRect.zero)
        lblDesc.text = NSLocalizedString("gr.shoppingcart.login", comment: "")
        lblDesc.font = WMFont.fontMyriadProLightOfSize(16)
        lblDesc.textAlignment = .center
        lblDesc.textColor = WMColor.light_blue
        lblDesc.numberOfLines = 0
        self.addSubview(lblDesc)
        
        
        btnLogin = UIButton(frame: CGRect.zero)
        btnLogin.backgroundColor = WMColor.green
        btnLogin.layer.cornerRadius = 20
        btnLogin.setTitle(NSLocalizedString("profile.signIn", comment: ""), for: UIControlState())
        btnLogin.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        btnLogin.addTarget(self, action: #selector(IPAGRLoginUserOrderView.showlogin), for: UIControlEvents.touchUpInside)
        btnLogin.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.addSubview(btnLogin)
        
        totalsView = IPOCheckOutTotalView(frame: CGRect.zero)
        totalsView.backgroundColor = WMColor.light_light_gray
        self.addSubview(totalsView)
        
        self.footer = UIView()
        self.footer!.backgroundColor = UIColor.white
        self.addSubview(self.footer!)
        let bounds = self.frame.size
        let footerHeight:CGFloat = 60.0
        self.buttonShop = UIButton(type: .custom) as UIButton
        self.buttonShop!.frame = CGRect(x: 16, y: (footerHeight / 2) - 17, width: bounds.width - 32, height: 34)
        self.buttonShop!.backgroundColor = WMColor.green
        self.buttonShop!.layer.cornerRadius = 17
        self.buttonShop!.addTarget(self, action: #selector(IPAGRLoginUserOrderView.showlogin), for: UIControlEvents.touchUpInside)
        self.footer!.addSubview(self.buttonShop!)
        
        self.addToListButton = UIButton(frame: CGRect(x: 8 ,y: 0, width: 50, height: footer!.frame.height))
        self.addToListButton!.setImage(UIImage(named: "detail_list"), for: UIControlState())
        self.addToListButton!.setImage(UIImage(named: "detail_list_selected"), for: .selected)
        self.addToListButton!.addTarget(self, action: #selector(IPAGRLoginUserOrderView.addCartToList), for: .touchUpInside)
        
        self.buttonShare = UIButton(frame: CGRect(x: self.addToListButton!.frame.maxX, y: 0, width: 50, height: footer!.frame.height))
        self.buttonShare.setImage(UIImage(named: "detail_shareOff"), for: UIControlState())
        self.buttonShare.addTarget(self, action: #selector(IPAGRLoginUserOrderView.shareShoppingCart), for: UIControlEvents.touchUpInside)
        self.footer!.addSubview(self.addToListButton!)
        self.footer!.addSubview(self.buttonShare)
    }
    
    
    override func layoutSubviews() {
        self.imgBgEmptyLogin.frame = CGRect(x: 0, y: 0, width: imgBgEmptyLogin.image!.size.width, height: imgBgEmptyLogin.image!.size.height)
        self.lblDesc.frame = CGRect(x: 0, y: 76, width: self.frame.width, height: 36)
        self.btnLogin.frame = CGRect(x: (self.frame.width / 2) - 80 , y: 486, width: 160, height: 40)
        self.totalsView.frame = CGRect(x: 0, y: imgBgEmptyLogin.frame.maxY, width: self.frame.width, height: self.frame.height - imgBgEmptyLogin.frame.maxY)
        self.footer!.frame = CGRect(x: 0.0, y: self.bounds.height - 65, width: bounds.width, height: 65)
        self.addToListButton.frame = CGRect(x: 8 ,y: 0, width: 50, height: footer!.frame.height)
        self.buttonShare.frame = CGRect(x: self.addToListButton!.frame.maxX, y: 0, width: 50, height: footer!.frame.height)
        self.buttonShop!.frame = CGRect(x: buttonShare.frame.maxX + 8, y: (footer!.frame.height / 2) - 17, width: self.frame.width - buttonShare.frame.maxX - 24, height: 34)
        self.customlabel!.frame = CGRect(x: 0, y: 0, width: self.frame.width - buttonShare.frame.maxX - 24, height: 34)
    }
    
    
    func setValues(_ numProds: String,subtotal: String,saving:String){
        self.totalsView.setValues(numProds, subtotal: subtotal, saving: saving)
        self.updateShopButton(subtotal)
    }
    
    func updateShopButton(_ total:String) {
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: CGRect(x: 0,y: 0,width: self.buttonShop!.frame.width,height: self.buttonShop!.frame.height))
            customlabel.backgroundColor = UIColor.clear
            customlabel.setCurrencyUserInteractionEnabled(true)
            buttonShop!.addSubview(customlabel)
            buttonShop!.sendSubview(toBack: customlabel)
        }
        let shopStr = NSLocalizedString("shoppingcart.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(total)
        let shopStrComplete = "\(shopStr) \(fmtTotal)"
        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.white, interLine: false)
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
