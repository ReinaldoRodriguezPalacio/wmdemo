//
//  AddressViewCell.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 19/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol AddressViewCellDelegate {
    func applyPrefered (_ addressID:String , isFisicalAddress: Bool)
}


class AddressViewCell: SWTableViewCell {
    var titleLabel : UILabel!
    var layerLine : CALayer!
    var preferedButton : UIButton!
    var delegateAddres:AddressViewCellDelegate!
    var addressID : String!
    
    var imageDisclousure : UIImageView!
    var imageErrorField: UIImageView!
    var showPreferedButton: Bool = true
    var isFisicalAddress: Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    //override init(frame: CGRect) {
      //  super.init(frame: frame)
      //  setup()
    //}
    
    func setup() {
        titleLabel = UILabel()
        self.titleLabel!.numberOfLines = 2
        
        layerLine = CALayer()
        preferedButton = UIButton()
        
        imageDisclousure = UIImageView(image: UIImage(named: "disclosure"))
        imageDisclousure.contentMode = UIViewContentMode.center
        
        imageErrorField = UIImageView(image: UIImage(named: "profile_field_error"))
        imageErrorField.contentMode = UIViewContentMode.center
        imageErrorField.isHidden = true

        self.preferedButton.setImage(UIImage(named:"favorite_empty"), for: UIControlState())
        self.preferedButton.setImage(UIImage(named:"favorite_selected"), for: UIControlState.selected)
        self.preferedButton.addTarget(self , action: #selector(AddressViewCell.applyPrefered), for:UIControlEvents.touchUpInside)
        
        self.contentView.addSubview(preferedButton)
        self.contentView.addSubview(titleLabel)
        self.contentView.layer.addSublayer(layerLine)
        self.contentView.addSubview(imageDisclousure)
        self.contentView.addSubview(imageErrorField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if(self.showPreferedButton) {
            preferedButton.alpha = 1
            preferedButton.frame =  CGRect(x: 0 , y: 1, width: 48, height: self.bounds.height - 2)
            titleLabel.frame = CGRect(x: preferedButton.frame.maxX , y: 1, width: self.bounds.width - 85  , height: self.bounds.height - 1)
        }else{
            preferedButton.alpha = 0
            titleLabel.frame = CGRect(x: 0 , y: 1, width: self.bounds.width - 41  , height: self.bounds.height - 1)
        }
        imageDisclousure.frame = CGRect(x: self.frame.width - 48 , y: 1, width: 48, height: self.frame.height)
        imageErrorField.frame = CGRect(x: self.frame.width - 72 , y: 1, width: 48, height: self.frame.height)
        
    }
    
    func setValues(_ title:String,font:UIFont,numberOfLines:Int,textColor:UIColor,padding:CGFloat,align:NSTextAlignment, isPrefered:Bool,addressID: String , isFisicalAddress: Bool){
        
        layerLine.frame =  CGRect(x: padding, y: self.bounds.height - AppDelegate.separatorHeigth() , width: self.bounds.width - padding, height: AppDelegate.separatorHeigth() )
        titleLabel.text  = title
        titleLabel.font = font
        titleLabel.numberOfLines = numberOfLines
        titleLabel.textAlignment = align
        titleLabel.textColor = textColor
        self.addressID = addressID
        self.layerLine.backgroundColor = WMColor.light_gray.cgColor
        self.isFisicalAddress = isFisicalAddress
        self.preferedButton.isSelected = isPrefered
    }
    
    func applyPrefered (){
        if !self.preferedButton.isSelected {
            delegateAddres.applyPrefered(self.addressID, isFisicalAddress: self.isFisicalAddress)
        }
    }
    
    func showErrorFieldImage(_ show:Bool){
        self.imageErrorField.isHidden = !show
        
    }
    
}
