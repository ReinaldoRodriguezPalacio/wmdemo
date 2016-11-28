//
//  FormFieldSearch.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 13/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class FormFieldSearch: UITextField {

    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        self.layer.cornerRadius = 5
        self.backgroundColor =  UIColor.white
        self.font = WMFont.fontMyriadProRegularOfSize(14)
        self.textColor = WMColor.dark_gray
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX - 15 , y: bounds.minY, width: bounds.size.width, height: bounds.size.height).insetBy(dx: 30, dy: 00);
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX - 15 , y: bounds.minY, width: bounds.size.width, height: bounds.size.height).insetBy(dx: 30, dy: 00);
        //return CGRectInset(bounds, 25 , 00);
    }
    
}
