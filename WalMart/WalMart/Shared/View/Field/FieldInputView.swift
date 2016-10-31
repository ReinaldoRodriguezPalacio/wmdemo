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
    var saveBlock : ((_ field:UITextField?) -> Void)? = nil
    var saveBlockTextView : ((_ field:UITextView?) -> Void)? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        setup()
    }
    
    init(frame: CGRect, inputViewStyle: UIInputViewStyle,titleSave : String,save:((_ field:UITextField?) -> Void)?) {
        super.init(frame: frame, inputViewStyle:  inputViewStyle)
        self.titleSave = titleSave
        setup()
        self.saveBlock = save
    }
    
    init(frame: CGRect, inputViewStyle: UIInputViewStyle,titleSave : String,saveText:((_ field:UITextView?) -> Void)?) {
        super.init(frame: frame, inputViewStyle:  inputViewStyle)
        self.titleSave = titleSave
        setup()
        self.saveBlockTextView = saveText
    }
    
    func setup(){
        self.saveBarButton = UIButton(type: .custom) as UIButton
        self.saveBarButton!.frame = CGRect(x: self.bounds.width - 100 , y: 0, width: 100, height: self.bounds.height)
        self.saveBarButton!.setTitle(self.titleSave, for: UIControlState())
        self.saveBarButton!.backgroundColor = UIColor.clear
        self.saveBarButton!.addTarget(self, action: #selector(FieldInputView.save(_:)), for: .touchUpInside)
        self.addSubview(self.saveBarButton!)
    }
    
    func save(_ button:UIButton) {
        if self.saveBlock != nil {
            self.saveBlock!(textField)
        }
        if self.saveBlockTextView != nil {
            self.saveBlockTextView!(textView)
        }
    }
    
}
