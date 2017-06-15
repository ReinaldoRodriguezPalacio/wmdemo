//
//  ProviderProductHeaderView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 26/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

protocol ProviderProductHeaderViewDelegate: class {
    func switchProviderValueChanged(showNewItems: Bool)
}

class ProviderProductHeaderView: UIView {
    
    var productImage: UIImageView!
    var productDescriptionLabel: UILabel!
    var productTypeLabel: UILabel!
    var bottomBorder: CALayer!
    var segmentedControl = UISegmentedControl()
    var showSwitchButton: Bool = false
    weak var delegate: ProviderProductHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        self.backgroundColor = UIColor.white
     
        productImage = UIImageView()
        productImage?.contentMode = UIViewContentMode.scaleAspectFit
        self.addSubview(productImage!)
        
        productDescriptionLabel = UILabel()
        productDescriptionLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        productDescriptionLabel.textAlignment = .left
        productDescriptionLabel.textColor = WMColor.dark_gray
        productDescriptionLabel.numberOfLines = 2
        self.addSubview(productDescriptionLabel!)
        
        productTypeLabel = UILabel()
        productTypeLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        productTypeLabel.textAlignment = .left
        productTypeLabel.textColor = WMColor.dark_gray
        self.addSubview(productTypeLabel!)
        
        self.bottomBorder = CALayer()
        self.bottomBorder.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(bottomBorder, at: 99)
        
        let segmentedTitleAttributes = [NSFontAttributeName:WMFont.fontMyriadProLightOfSize(12)] as [String : Any]
        segmentedControl = UISegmentedControl(items: ["Nuevos", "Reacondicionados"])
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.tintColor = WMColor.light_blue
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(switchProviders), for: .valueChanged)
        segmentedControl.layer.cornerRadius = 11
        segmentedControl.layer.borderWidth = 1.0
        segmentedControl.layer.borderColor = WMColor.light_blue.cgColor
        segmentedControl.layer.masksToBounds = true
        segmentedControl.setTitleTextAttributes(segmentedTitleAttributes, for: UIControlState())
        segmentedControl.setTitleTextAttributes(segmentedTitleAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(segmentedTitleAttributes, for: .highlighted)
        self.addSubview(segmentedControl)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        productImage.frame = CGRect(x: 16, y: 16, width: 56, height: 56)
        
        let productDescriptionSize = productDescriptionLabel.text!.size(attributes: [NSFontAttributeName: productDescriptionLabel!.font])
        let productDescriptionWidth: CGFloat = self.frame.width - (productImage.frame.maxX + 32)
        let productDescriptionHeight: CGFloat = (productDescriptionWidth - productDescriptionSize.width) > 0 ? 15 : 30
        
        productDescriptionLabel.frame = CGRect(x: productImage.frame.maxX + 16, y: 22, width: productDescriptionWidth, height: productDescriptionHeight)
        productTypeLabel.frame = CGRect(x: productImage.frame.maxX + 16, y: productDescriptionLabel.frame.maxY + 4, width: self.frame.width - (productImage.frame.maxX + 32), height: 15)
        bottomBorder.frame = CGRect(x: 0.0, y: productImage.frame.maxY + 16, width: self.frame.size.width, height: 1)
        segmentedControl.frame = CGRect(x:self.frame.size.width - 220, y: bottomBorder.frame.maxY + 16, width: 204, height: 22)
        segmentedControl.isHidden = !self.showSwitchButton
    }
    
    
    func setValues(_ productImageURL:String,productShortDescription:String,productType:String) {
        
        
        self.productImage!.setImageWith(URL(string: productImageURL)!, placeholderImage: UIImage(named:"img_default_table"))
        self.productDescriptionLabel!.text = productShortDescription
        self.productTypeLabel!.text = productType
    }
    
    func switchProviders() {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            delegate?.switchProviderValueChanged(showNewItems: true)
        case 1:
            delegate?.switchProviderValueChanged(showNewItems: false)
        default:
            delegate?.switchProviderValueChanged(showNewItems: true)
        }
    }
}
