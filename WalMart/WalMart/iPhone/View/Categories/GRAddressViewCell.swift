//
//  GRAddressViewCell.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 07/04/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class GRAddressViewCell: UITableViewCell {
    var titleLabel : UILabel!
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
    
    func setup() {
        titleLabel = UILabel()
        self.titleLabel!.numberOfLines = 2
        
        
        imageDisclousure = UIImageView(image: UIImage(named: "disclosure"))
        imageDisclousure.contentMode = UIViewContentMode.center
        
        imageErrorField = UIImageView(image: UIImage(named: "profile_field_error"))
        imageErrorField.contentMode = UIViewContentMode.center
        imageErrorField.isHidden = true
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(imageDisclousure)
        self.contentView.addSubview(imageErrorField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 0 , y: 1, width: self.bounds.width - 41  , height: self.bounds.height - 1)
        imageDisclousure.frame = CGRect(x: self.frame.width - 48 , y: 1, width: 48, height: self.frame.height)
        imageErrorField.frame = CGRect(x: self.frame.width - 72 , y: 1, width: 48, height: self.frame.height)
        
    }
    
    /**
     Sets the cell parameters
     
     - parameter title:         title of the cell
     - parameter font:          font of the cell text
     - parameter numberOfLines: number of lines
     - parameter textColor:     color of text
     - parameter align:         align of text
     - parameter addressID:     address identifier
     */
    func setValues(_ title:String,font:UIFont,numberOfLines:Int,textColor:UIColor,align:NSTextAlignment,addressID: String){
        titleLabel.text  = title
        titleLabel.font = font
        titleLabel.numberOfLines = numberOfLines
        titleLabel.textAlignment = align
        titleLabel.textColor = textColor
        self.addressID = addressID
    }
    
    /**
     Shows or hides an error indicator
     
     - parameter show: indicates if shows or hides the indicator
     */
    func showErrorFieldImage(_ show:Bool){
        self.imageErrorField.isHidden = !show
    }
    
}
