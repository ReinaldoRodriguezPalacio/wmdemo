//
//  AddressViewCell.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 19/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol AddressViewCellDelegate {
    func applyPrefered (addressID:String )
}


class AddressViewCell: SWTableViewCell {
    var titleLabel : UILabel!
    var viewLine : UIView!
    var preferedButton : UIButton!
    var delegateAddres:AddressViewCellDelegate!
    var addressID : String!
    
    var imageDisclousure : UIImageView!
    var imageErrorField: UIImageView!

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
        
        viewLine = UIView()
        preferedButton = UIButton()
        
        imageDisclousure = UIImageView(image: UIImage(named: "disclosure"))
        imageDisclousure.contentMode = UIViewContentMode.Center
        
        imageErrorField = UIImageView(image: UIImage(named: "profile_field_error"))
        imageErrorField.contentMode = UIViewContentMode.Center
        imageErrorField.hidden = true

        self.preferedButton.setImage(UIImage(named:"favorite_empty"), forState: UIControlState.Normal)
        self.preferedButton.setImage(UIImage(named:"favorite_selected"), forState: UIControlState.Selected)
        self.preferedButton.addTarget(self , action: "applyPrefered", forControlEvents:UIControlEvents.TouchUpInside)
        
        self.contentView.addSubview(preferedButton)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(viewLine)
        self.contentView.addSubview(imageDisclousure)
        self.contentView.addSubview(imageErrorField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        preferedButton.frame =  CGRectMake(0 , 1, 48, self.bounds.height - 2)
        titleLabel.frame = CGRectMake(preferedButton.frame.maxX , 1, self.bounds.width - 85  , self.bounds.height - 1)
        imageDisclousure.frame = CGRectMake(self.frame.width - 48 , 1, 48, self.frame.height)
        imageErrorField.frame = CGRectMake(self.frame.width - 72 , 1, 48, self.frame.height)
        
    }
    
    func setValues(title:String,font:UIFont,numberOfLines:Int,textColor:UIColor,padding:CGFloat,align:NSTextAlignment,isViewLine:Bool, isPrefered:Bool,addressID: String ){
        
        viewLine.frame =  CGRectMake(padding, self.bounds.height - AppDelegate.separatorHeigth() , self.bounds.width - padding, AppDelegate.separatorHeigth() )
        titleLabel.text  = title
        titleLabel.font = font
        titleLabel.numberOfLines = numberOfLines
        titleLabel.textAlignment = align
        titleLabel.textColor = textColor
        self.addressID = addressID
        
        if isViewLine{
            viewLine.backgroundColor = WMColor.loginProfileLineColor
        }else{
            viewLine.backgroundColor = UIColor.clearColor()
        }
       
        self.preferedButton.selected = isPrefered
    }
    
    func applyPrefered (){
        if !self.preferedButton.selected {
            delegateAddres.applyPrefered(self.addressID)
        }
    }
    
    func showErrorFieldImage(show:Bool){
        self.imageErrorField.hidden = !show
        
    }
    
}
