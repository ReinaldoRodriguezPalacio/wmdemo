//
//  CommentBubbleView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/19/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
protocol CommentBubbleViewDelegate: class {
    func showBottonAddNote(_ show : Bool)
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
        self.field!.returnKeyType = .default
        self.field!.autocapitalizationType = .none
        self.field!.autocorrectionType = .no
        self.field!.enablesReturnKeyAutomatically = true
        self.field!.font = WMFont.fontMyriadProRegularOfSize(14)
        //self.field!.text = "Agrega tu nota aqui";
        self.field!.textColor = UIColor.gray
        self.field!.delegate = self
        
        
        self.backgroundColor = UIColor.clear
        indicator = UIImageView()
        indicator!.image = UIImage(named: "note_indicator")
        self.addSubview(self.field!)
        self.addSubview(indicator!)
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     func textRectForBounds(_ bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 11);
    }
    
    
    
    override func layoutSubviews() {
        self.indicator!.frame = CGRect (x: (self.bounds.width - 6) / 2, y: 4,  width: 6, height: 4)
        self.field!.frame = CGRect(x: (self.bounds.width - 288) / 2, y: 8 , width: 288, height: self.bounds.height - 8)
    }
    

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if NSString(string:textView.text).length + (NSString(string:text).length - range.length) ==  0{
            self.delegate?.showBottonAddNote(false)
            textView.text = NSLocalizedString("shoppingcart.AddtexNote", comment: "")
            textView.resignFirstResponder()
            textView.textColor = UIColor.gray
        }else{
            self.delegate?.showBottonAddNote(true)

        }
        
        return NSString(string:textView.text).length + (NSString(string:text).length - range.length) <= 200
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == NSLocalizedString("shoppingcart.AddtexNote", comment: ""){
            textView.text = ""
            textView.textColor = WMColor.dark_gray
        }
        return true
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = NSLocalizedString("shoppingcart.AddtexNote", comment: "")
            textView.textColor = UIColor.gray
        }
    }
    

}
