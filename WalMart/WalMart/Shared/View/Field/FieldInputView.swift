//
//  FieldInputView.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 26/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class FieldInputView: UIInputView {
    
    var saveBarButton : UIButton? = nil
    var textField : UITextField? = nil
    var textView : UITextView? = nil
    var titleSave : String? = nil
    var saveBlock : ((field:UITextField?) -> Void)? = nil
    var saveBlockTextView : ((field:UITextView?) -> Void)? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        setup()
    }
    
    init(frame: CGRect, inputViewStyle: UIInputViewStyle,titleSave : String,save:((field:UITextField?) -> Void)?) {
        super.init(frame: frame, inputViewStyle:  inputViewStyle)
        self.titleSave = titleSave
        setup()
        self.saveBlock = save
    }
    
    init(frame: CGRect, inputViewStyle: UIInputViewStyle,titleSave : String,saveText:((field:UITextView?) -> Void)?) {
        super.init(frame: frame, inputViewStyle:  inputViewStyle)
        self.titleSave = titleSave
        setup()
        self.saveBlockTextView = saveText
    }
    
    func setup(){
        self.saveBarButton = UIButton(type: .Custom) as UIButton
        self.saveBarButton!.frame = CGRectMake(self.bounds.width - 100 , 0, 100, self.bounds.height)
        self.saveBarButton!.setTitle(self.titleSave, forState: .Normal)
        self.saveBarButton!.backgroundColor = UIColor.clearColor()
        self.saveBarButton!.addTarget(self, action: #selector(FieldInputView.save(_:)), forControlEvents: .TouchUpInside)
        self.addSubview(self.saveBarButton!)
    }
    
    func save(button:UIButton) {
        if self.saveBlock != nil {
            self.saveBlock!(field:textField)
        }
        if self.saveBlockTextView != nil {
            self.saveBlockTextView!(field:textView)
        }
    }
    
}
