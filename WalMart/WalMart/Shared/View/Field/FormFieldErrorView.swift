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
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(){
        viewError = UIView()
        self.viewError!.backgroundColor = WMColor.red
        self.viewError!.alpha = 0.9
        
        imageIcon = UIImageView()
        imageIcon!.image = UIImage(named: "fieldError")
        
        self.errorLabel = UILabel()
        self.errorLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.errorLabel!.textColor = UIColor.white

        self.errorLabel!.backgroundColor = UIColor.clear
        
        self.viewError!.layer.cornerRadius = 4
        self.viewError.addSubview(self.errorLabel)
        
        self.addSubview(viewError!)
        self.addSubview(imageIcon!)
    }
    

    func setValues (_ width:CGFloat, strLabel:String, strValue: String ){
        let attrString =  ProductDetailCharacteristicsCollectionViewCell.buildAttributtedString(strLabel, value: strValue, colorKey:UIColor.white, colorValue:UIColor.white, size: 12)
        let rectSize = attrString.boundingRect(with: CGSize(width: width, height: CGFloat.max), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        self.bounds = CGRect(x: 10, y: 0, width: rectSize.width + 20 , height: rectSize.height + 10 )
        
        self.imageIcon!.frame = CGRect (x: 18, y: self.frame.height - 4,  width: 6, height: 4)
        self.viewError!.frame = CGRect(x: 15, y: 2, width: rectSize.width + 10, height: rectSize.height + 4)
        self.errorLabel!.frame = CGRect(x: 5, y: 2, width: rectSize.width, height: rectSize.height)

        self.errorLabel.attributedText = attrString
        self.errorLabel.numberOfLines = 0
        
    }
    
}
