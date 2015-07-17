//
//  FormFieldErrorView.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 26/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class FormFieldErrorView: UIView {
    var  imageIcon : UIImageView!
    var  errorLabel : UILabel!
    var viewError : UIView!
    var focusError : UITextField? = nil
    
    override init(){
        super.init()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(){
        viewError = UIView()
        self.viewError!.backgroundColor = WMColor.profileErrorColor
        self.viewError!.alpha = 0.9
        
        imageIcon = UIImageView()
        imageIcon!.image = UIImage(named: "fieldError")
        
        self.errorLabel = UILabel()
        self.errorLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.errorLabel!.textColor = UIColor.whiteColor()

        self.errorLabel!.backgroundColor = UIColor.clearColor()
        
        self.viewError!.layer.cornerRadius = 4
        self.viewError.addSubview(self.errorLabel)
        
        self.addSubview(viewError!)
        self.addSubview(imageIcon!)
    }
    

    func setValues (width:CGFloat, strLabel:String, strValue: String ){
        let attrString =  ProductDetailCharacteristicsCollectionViewCell.buildAttributtedString(strLabel, value: strValue, colorKey:UIColor.whiteColor(), colorValue:UIColor.whiteColor(), size: 12)
        let rectSize = attrString.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        self.bounds = CGRectMake(10, 0, rectSize.width + 20 , rectSize.height + 10 )
        
        self.imageIcon!.frame = CGRectMake (18, self.frame.height - 4,  6, 4)
        self.viewError!.frame = CGRectMake(15, 2, rectSize.width + 10, rectSize.height + 4)
        self.errorLabel!.frame = CGRectMake(5, 2, rectSize.width, rectSize.height)

        self.errorLabel.attributedText = attrString
        self.errorLabel.numberOfLines = 0
        
    }
    
}
