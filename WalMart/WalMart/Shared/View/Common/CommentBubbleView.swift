//
//  CommentBubbleView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/19/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class CommentBubbleView : UIView, UITextViewDelegate {
    
    var field: UITextView?
    var indicator: UIImageView?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.field = UITextView()
        //self.field!.delegate = self
        self.field!.layer.cornerRadius = 5.0
        self.field!.returnKeyType = .Default
        self.field!.autocapitalizationType = .None
        self.field!.autocorrectionType = .No
        self.field!.enablesReturnKeyAutomatically = true
        self.field!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.field!.textColor = WMColor.searchProductFieldTextColor
        self.field!.delegate = self
        self.backgroundColor = UIColor.clearColor()
        
        indicator = UIImageView()
        indicator!.image = UIImage(named: "note_indicator")
        self.addSubview(self.field!)
        self.addSubview(indicator!)
        
        self.field!.becomeFirstResponder()
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func layoutSubviews() {
        self.indicator!.frame = CGRectMake ((self.bounds.width - 6) / 2, 4,  6, 4)
        self.field!.frame = CGRectMake((self.bounds.width - 288) / 2, 8 , 288, self.bounds.height - 8)
    }
    

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        return NSString(string:textView.text).length + (NSString(string:text).length - range.length) <= 200
    }
    
    
}