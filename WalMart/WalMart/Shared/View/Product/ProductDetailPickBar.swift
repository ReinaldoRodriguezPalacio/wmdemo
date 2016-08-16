//
//  ProductDetailPickBar.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 12/08/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class ProductDetailPickBar: UIView {
    
    var descLabel: UILabel!
    var actionButton: UIButton!
    var selectImage: UIImageView!
    var arrowImage: UIImageView!
    var titleLabel:UILabel!
    var titleView: UIView!
    var bodyView: UIView!
    var isShowingBar: Bool = true
    var startPossition: CGPoint!
    var showHeader: Bool = true
    var loginAction: ((Void) -> Void)?
    var changeStoreAction: ((Void) -> Void)?
    var storeId: String! = ""
    var storeName: String! = "Acueducto de Guadalupe"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.clipsToBounds = false
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor.clearColor()
        self.alpha = 0.9
        
        self.bodyView = UIView()
        self.bodyView.backgroundColor = WMColor.light_gray
        
        self.actionButton = UIButton()
        self.actionButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.actionButton.layer.cornerRadius = 11.0
        self.actionButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.actionButton.backgroundColor = WMColor.light_blue
        self.actionButton.addTarget(self, action: #selector(ProductDetailPickBar.pickAction), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.descLabel = UILabel()
        self.descLabel.font = WMFont.fontMyriadProSemiboldSize(11)
        self.descLabel.textColor = WMColor.dark_gray
        self.descLabel.numberOfLines = 2
        
        self.selectImage = UIImageView()
        self.selectImage.image = UIImage(named: "filter_check_blue") //check_blue
        
        self.titleView = UIView()
        self.titleView.backgroundColor = WMColor.light_gray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProductDetailPickBar.showPickBar))
        self.titleView.addGestureRecognizer(tap)
        
        self.titleLabel = UILabel()
        self.titleLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.titleLabel.textColor = WMColor.light_blue
        self.titleLabel.numberOfLines = 1
        self.titleLabel.text = "Recoger en"
        
        self.arrowImage = UIImageView()
        self.arrowImage.image = UIImage(named:"arrow")
        
        self.titleView.addSubview(self.arrowImage)
        self.titleView.addSubview(self.titleLabel)
        self.bodyView.addSubview(actionButton)
        self.bodyView.addSubview(descLabel)
        self.bodyView.addSubview(selectImage)
        self.addSubview(titleView)
        self.addSubview(bodyView)
        self.setValues()
    }
    
    override func layoutSubviews() {
        
        if self.showHeader {
            self.bodyView.frame = CGRectMake(0, 18, self.frame.width, 46)
            self.titleView.frame = CGRectMake(8, 0, 88, 18)
        }else{
            self.titleView.frame = CGRectMake(0, 0, 0, 0)
            self.bodyView.frame = CGRectMake(0, 0, self.frame.width, 46)
        }
        
        self.titleLabel.frame = CGRectMake(8, 0, 60, 18)
        self.arrowImage.frame = CGRectMake(68, 3, 12, 12)
        self.actionButton.frame = CGRectMake(self.frame.width - 104, 12, 88, 22)
        self.selectImage.frame = CGRectMake(16, 16, 16, 16)
        
         if UserCurrentSession.hasLoggedUser() {
            self.descLabel.frame = CGRectMake(40, 12, self.actionButton.frame.minX - 35, 25)
         }else{
           self.descLabel.frame = CGRectMake(16, 12, self.actionButton.frame.minX - 35, 25)
        }
    }
    
    
    func setValues() {
        if UserCurrentSession.hasLoggedUser() {
            self.selectImage.hidden = false
            self.actionButton.setTitle("cambiar tienda", forState: .Normal)
            self.descLabel.text = "No disponible para recoger en \n\(self.storeName)"
        }else{
            self.selectImage.hidden = true
            self.actionButton.setTitle("Iniciar Sesión", forState: .Normal)
            self.descLabel.text = "Inicia sesión parac saber si pouedes\n recoger este artículo en tu tienda"
        }
    }
    
    func showPickBar() {
        if self.isShowingBar {
            UIView.animateWithDuration(0.3, animations: {
                self.frame.origin = CGPointMake(self.startPossition.x, self.startPossition.y - 46)
                }, completion: { (complete) in
               self.isShowingBar = false
            })
        }else{
            UIView.animateWithDuration(0.3, animations: {
                 self.frame.origin = self.startPossition
                }, completion: { (complete) in
                    self.isShowingBar = true
            })
        }
    }
    
    func pickAction() {
        if UserCurrentSession.hasLoggedUser() {
            self.changeStoreAction?()
        }else{
            self.loginAction?()
        }
    }
    
    
    
    class func initDefault(possition: CGPoint,width: CGFloat) -> ProductDetailPickBar{
        let pickBar = ProductDetailPickBar()
        pickBar.frame = CGRectMake(possition.x,possition.y, width, 64)
        pickBar.startPossition = possition
        return pickBar
    }
}