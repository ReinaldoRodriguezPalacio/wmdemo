//
//  FormFieldSearch.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 13/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class FormFieldSearch: UITextField {

    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        self.layer.cornerRadius = 5
        self.backgroundColor =  UIColor.whiteColor()
        self.font = WMFont.fontMyriadProRegularOfSize(14)
        self.textColor = WMColor.searchProductFieldTextColor
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(CGRectMake(bounds.minX - 15 , bounds.minY, bounds.size.width, bounds.size.height), 30, 00);
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(CGRectMake(bounds.minX - 15 , bounds.minY, bounds.size.width, bounds.size.height), 30, 00);
        //return CGRectInset(bounds, 25 , 00);
    }
    
}
