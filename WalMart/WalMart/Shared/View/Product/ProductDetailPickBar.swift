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
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        self.alpha = 0.9
        
        self.bodyView = UIView()
        self.bodyView.backgroundColor = WMColor.light_gray
        
        self.actionButton = UIButton()
        self.actionButton.setTitleColor(UIColor.white, for: UIControlState())
        self.actionButton.layer.cornerRadius = 11.0
        self.actionButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.actionButton.backgroundColor = WMColor.light_blue
        self.actionButton.addTarget(self, action: #selector(ProductDetailPickBar.pickAction), for: UIControlEvents.touchUpInside)
        
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
        self.setValues()
        self.addSubview(bodyView)
    }
    
    override func layoutSubviews() {
        
        if self.showHeader {
            self.bodyView.frame = CGRect(x: 0, y: 18, width: self.frame.width, height: 46)
            self.titleView.frame = CGRect(x: 8, y: 0, width: 88, height: 18)
        }else{
            self.titleView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.bodyView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 46)
        }
        
        self.titleLabel.frame = CGRect(x: 8, y: 0, width: 60, height: 18)
        self.arrowImage.frame = CGRect(x: 68, y: 3, width: 12, height: 12)
        self.actionButton.frame = CGRect(x: self.frame.width - 104, y: 12, width: 88, height: 22)
        self.selectImage.frame = CGRect(x: 16, y: 16, width: 16, height: 16)
        
         if UserCurrentSession.hasLoggedUser() {
            self.descLabel.frame = CGRect(x: 40, y: 12, width: self.actionButton.frame.minX - 35, height: 25)
         }else{
           self.descLabel.frame = CGRect(x: 16, y: 12, width: self.actionButton.frame.minX - 35, height: 25)
        }
    }
    
    
    func setValues() {
        if UserCurrentSession.hasLoggedUser() {
            self.selectImage.isHidden = false
            self.actionButton.setTitle("cambiar tienda", for: UIControlState())
            self.descLabel.text = "No disponible para recoger en \n\(self.storeName)"
        }else{
            self.selectImage.isHidden = true
            self.actionButton.setTitle("Iniciar Sesión", for: UIControlState())
            self.descLabel.text = "Inicia sesión parac saber si pouedes\n recoger este artículo en tu tienda"
        }
    }
    
    func showPickBar() {
        if self.isShowingBar {
            self.bodyView.alpha = 1.0
            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin = CGPoint(x: self.startPossition.x, y: self.startPossition.y - 46)
                self.frame.size = CGSize(width: self.frame.width, height: 64)
                }, completion: { (complete) in
                self.isShowingBar = false
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                 self.frame.origin = self.startPossition
                 self.frame.size = CGSize(width: self.frame.width, height: 18)
                }, completion: { (complete) in
                    self.isShowingBar = true
                    self.bodyView.alpha = 0.0
                    
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
    
    
    
    class func initDefault(_ possition: CGPoint,width: CGFloat) -> ProductDetailPickBar{
        let pickBar = ProductDetailPickBar()
        pickBar.frame = CGRect(x: possition.x,y: possition.y, width: width, height: 64)
        pickBar.startPossition = possition
        return pickBar
    }
}
