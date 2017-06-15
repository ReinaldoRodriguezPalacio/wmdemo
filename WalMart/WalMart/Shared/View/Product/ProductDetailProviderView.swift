//
//  ProductDetailProviderView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 23/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

protocol ProductDetailProviderViewDelegate: class {
    func showProviderInfoView()
    func showOtherProvidersView()
}


class ProductDetailProviderView: UIView {
    
    var providerRatingView: UIView!
    var providerLabel: UILabel!
    var ratingLabel: UILabel!
    var deliberyLabel:UILabel!
    var otherProvidersLabel: UILabel!
    var bottomBorder: CALayer!
    var topBorder: CALayer!
    var offersCount: Int = 0
    var delegate: ProductDetailProviderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        let infoViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(showProviderInfoView))
        let otherProvidersRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOtherProvidersView))
        
        providerRatingView = UIView()
        providerRatingView.backgroundColor = UIColor.clear
        providerRatingView.isUserInteractionEnabled = true
        providerRatingView.addGestureRecognizer(infoViewRecognizer)
        self.addSubview(providerRatingView!)
        
        providerLabel = UILabel()
        providerLabel.textColor = WMColor.light_blue
        providerLabel.text = ""
        providerLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        providerLabel.textAlignment = .center
        self.providerRatingView.addSubview(providerLabel!)
        
        deliberyLabel = UILabel()
        deliberyLabel.textColor = WMColor.gray
        deliberyLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        deliberyLabel.textAlignment = .center
        self.addSubview(deliberyLabel!)
        
        otherProvidersLabel = UILabel()
        otherProvidersLabel.textColor = WMColor.gray
        otherProvidersLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        otherProvidersLabel.textAlignment = .center
        otherProvidersLabel.isUserInteractionEnabled = true
        otherProvidersLabel.addGestureRecognizer(otherProvidersRecognizer)
        self.addSubview(otherProvidersLabel!)
        
        ratingLabel = UILabel()
        ratingLabel.textColor = UIColor.white
        ratingLabel.font = WMFont.fontMyriadProRegularOfSize(9)
        ratingLabel.backgroundColor = WMColor.light_blue
        ratingLabel.layer.cornerRadius = 2
        ratingLabel.textAlignment = .center
        ratingLabel.clipsToBounds = true
        self.providerRatingView.addSubview(ratingLabel!)
        
        self.bottomBorder = CALayer()
        self.bottomBorder.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(bottomBorder, at: 99)
        
        self.topBorder = CALayer()
        self.topBorder.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(topBorder, at: 99)
        
    }
    
    func setValues(provider: [String:Any]){
        
        if let providerName = provider["name"] as? String {
            providerLabel.text = "Vendido por \(providerName)"
        }
        
        if let delibery = provider["shipping"] as? String {
            deliberyLabel.text = delibery
        }
        
        if let rating = provider["rating"] as? Double {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "rating_star")
            let attachmentString = NSAttributedString(attachment: attachment)
            let attrs = [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(9)]
            var string = NSMutableAttributedString(string:"\(rating) de 5 ", attributes:attrs)
            string.append(attachmentString)
            
            ratingLabel.attributedText = string
            ratingLabel.isHidden = false
        }else {
            ratingLabel.text = ""
            ratingLabel.isHidden = true
        }
        
        let attrs = [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(12)]
        let attrsBlue = [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(12), NSForegroundColorAttributeName: WMColor.light_blue] as [String : Any]
        
        let messageString = NSMutableAttributedString(string: "Disponible en otros precios y otros ", attributes: attrs)
        let boldString = NSMutableAttributedString(string:"\(offersCount) proveedores", attributes:attrsBlue)
        messageString.append(boldString)
        otherProvidersLabel.attributedText = messageString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.topBorder.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 1)
        self.bottomBorder.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.size.width, height: 1)
        
        if ratingLabel.isHidden {
            let providerSize = providerLabel.text!.size(attributes: [NSFontAttributeName: providerLabel!.font])
            let providerWidth = providerSize.width
            providerRatingView.frame = CGRect(x:0, y:0, width: self.frame.width, height: 22)
            providerLabel.frame = CGRect(x: (self.frame.width - providerWidth) / 2.0, y: 4.0, width: providerSize.width, height: 18)
            ratingLabel.frame = CGRect(x: providerLabel.frame.maxX + 16 , y: 5.0, width: 0, height: 0)
        }else{
            let providerSize = providerLabel.text!.size(attributes: [NSFontAttributeName: providerLabel!.font])
            let providerWidth = providerSize.width + 66
            providerRatingView.frame = CGRect(x:0, y:0, width: self.frame.width, height: 22)
            providerLabel.frame = CGRect(x: (self.frame.width - providerWidth) / 2.0, y: 4.0, width: providerSize.width, height: 18)
            ratingLabel.frame = CGRect(x: providerLabel.frame.maxX + 16 , y: 5.0, width: 50, height: 16)
        }
        
        deliberyLabel.frame = CGRect(x: 0.0, y: providerLabel.frame.maxY, width: self.frame.width, height: 16)
        otherProvidersLabel.frame = CGRect(x: 0.0, y: deliberyLabel.frame.maxY, width: self.frame.width, height: 22)
    }
    
    
    func showProviderInfoView() {
        delegate?.showProviderInfoView()
    }
    
    func showOtherProvidersView() {
        delegate?.showOtherProvidersView()
    }

}
