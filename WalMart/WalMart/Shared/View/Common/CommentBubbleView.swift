//
//  CommentBubbleView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/19/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
protocol CommentBubbleViewDelegate {
    func showBottonAddNote(show : Bool)
}


class CommentBubbleView : UIView, UITextViewDelegate {
    
    var field: UITextView?
    var indicator: UIImageView?
    var showBottonAddNote: UIButton!
    var delegate : CommentBubbleViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.field = UITextView()
        self.field!.layer.cornerRadius = 5.0
        self.field!.returnKeyType = .Default
        self.field!.autocapitalizationType = .None
        self.field!.autocorrectionType = .No
        self.field!.enablesReturnKeyAutomatically = true
        self.field!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.field!.text = "Agrega tu nota aqui";
        self.field!.textColor = UIColor.grayColor()
        self.field!.delegate = self
        
        
        self.backgroundColor = UIColor.clearColor()
        indicator = UIImageView()
        indicator!.image = UIImage(named: "note_indicator")
        self.addSubview(self.field!)
        self.addSubview(indicator!)
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 20, 11);
    }
    
    
    
    override func layoutSubviews() {
        self.indicator!.frame = CGRectMake ((self.bounds.width - 6) / 2, 4,  6, 4)
        self.field!.frame = CGRectMake((self.bounds.width - 288) / 2, 8 , 288, self.bounds.height - 8)
    }
    

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if NSString(string:textView.text).length + (NSString(string:text).length - range.length) ==  0{
            self.delegate?.showBottonAddNote(false)
            textView.text = "Agrega tu nota aqui"
            textView.resignFirstResponder()
            textView.textColor = UIColor.grayColor()
        }else{
            self.delegate?.showBottonAddNote(true)

        }
        
        return NSString(string:textView.text).length + (NSString(string:text).length - range.length) <= 200
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.text == "Agrega tu nota aqui" {
            textView.text = ""
            textView.textColor = WMColor.dark_gray
        }
        return true
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "Agrega tu nota aqui"
            textView.textColor = UIColor.grayColor()
        }
    }
    

}