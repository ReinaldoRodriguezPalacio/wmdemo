//
//  SESugestedCarViewCell.swift
//  WalMart
//
//  Created by Reinaldo Rodriguez Palacio on 19/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

protocol SESugestedCarViewCellDelegate {
    func seleccionados(seccion:Int, item:Int)
    func deseleccionados(seccion:Int, item:Int)
}


class SESugestedCarViewCell : UICollectionViewCell {
    
    var upc : String!
    var desc : String!
    var price : String!
    var imageURL : String!
    var section: Int!
    var leftView : UIView!
    var rightView : UIView!
    
    var productImage : UIImageView? = nil
    var productShortDescriptionLabel : UILabel? = nil
    var productPriceLabel : CurrencyCustomLabel? = nil
    var check: UIButton?
    
    var delegate: SESugestedRow?
    
    let contentModeOrig = UIViewContentMode.scaleAspectFit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(frame: CGRect,loadImage:@escaping (() -> Void)) {
        super.init(frame: frame)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        leftView = UIView(frame: .zero)
        rightView = UIView(frame: .zero)
    
        self.contentView.addSubview(leftView)
        self.contentView.addSubview(rightView)
        
        self.productPriceLabel = CurrencyCustomLabel(frame:CGRect.zero)
        self.productShortDescriptionLabel = UILabel(frame:.zero)
        
        self.rightView.addSubview(self.productShortDescriptionLabel!)
        self.rightView.addSubview(self.productPriceLabel!)
        
        productImage = UIImageView()
        
        self.check = UIButton(frame:.zero)
        self.check?.setImage(UIImage(named: "list_check_empty"), for: UIControlState())
        self.check?.setImage(UIImage(named: "list_check_full"), for: UIControlState.selected)
        self.check?.addTarget(self, action: #selector(self.checked(_:)), for: UIControlEvents.touchUpInside)
        self.check?.isSelected = true
        
        self.leftView.addSubview(self.check!)
        self.leftView.addSubview(self.productImage!)

        self.leftView.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width*0.4, height: self.contentView.frame.height)
        self.rightView.frame = CGRect(x: self.leftView.frame.maxX, y: 0, width: self.contentView.frame.width*0.6, height: self.contentView.frame.height)
        
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 0.6
        self.layer.borderColor = WMColor.light_light_gray.cgColor
        self.backgroundColor = UIColor.white
        
        self.check?.frame = CGRect(x: 0, y: leftView.frame.size.height / 2 - (leftView.frame.size.width * 0.3)/2, width: leftView.frame.size.width * 0.3, height: leftView.frame.size.width * 0.3)
        
        self.productImage!.frame = CGRect(x: (check?.frame.maxX)!, y:leftView.frame.size.height / 2 - (leftView.frame.size.width * 0.7)/2, width: leftView.frame.size.width * 0.7 , height: leftView.frame.size.width * 0.7)
        
        self.productShortDescriptionLabel!.frame = CGRect(x: 5, y: 4 , width: self.rightView.frame.size.width, height: 33)
        
        if IS_IPHONE_4_OR_LESS || IS_IPHONE_5{
        self.productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        }else{
        self.productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        }
        
        
        self.productShortDescriptionLabel!.numberOfLines = 3
        self.productShortDescriptionLabel!.textColor =  WMColor.gray
        self.productShortDescriptionLabel!.adjustsFontSizeToFitWidth = true
        self.productShortDescriptionLabel!.minimumScaleFactor = 9 / 12
        self.productShortDescriptionLabel?.textAlignment = NSTextAlignment.left
        self.productShortDescriptionLabel?.lineBreakMode =  .byTruncatingTail
        
        self.productPriceLabel!.frame = CGRect(x: 0, y: self.productShortDescriptionLabel!.frame.maxY + 5  , width: self.rightView.frame.size.width , height: 14)
        self.productPriceLabel!.textAlignment = NSTextAlignment.center
        
    }
    
    func setValues(_ upc:String,productImageURL:String,productShortDescription:String,productPrice:String,isSelected:Bool, section:Int, index:Int) {
        
        let formatedPrice = CurrencyCustomLabel.formatString(productPrice as NSString)
        self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color:WMColor.orange, interLine: false)
        
        self.productImage!.contentMode = self.contentModeOrig

        if productImageURL != "" {
            self.productImage!.setImageWith(URL(string: productImageURL)!, placeholderImage: UIImage(named:"img_default_cell"))
        } else {
            self.productImage!.image = UIImage(named:"img_default_cell")
        }
        
        productShortDescriptionLabel!.text = productShortDescription
        
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(14), color: WMColor.orange, interLine: false)
        
        self.upc = upc
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.check?.isSelected = isSelected
        self.check?.tag = index
        self.section = section
    }
    
    func checked(_ sender:UIButton){
    sender.isSelected = !sender.isSelected
        
        if sender.isSelected{
            delegate?.seleccionados(seccion: self.section, item: sender.tag)
        }else{
            delegate?.deseleccionados(seccion: self.section, item: sender.tag)
        }
    }
    
}

