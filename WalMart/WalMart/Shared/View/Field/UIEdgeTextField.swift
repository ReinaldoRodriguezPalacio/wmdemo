//
//  UIEdgeTextField.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 17/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol UITextFieldChangeValueProtocol {
    func fieldChangeValue(value:String)
}

class UIEdgeTextField : UITextField {
    
    var valueDelegate : UITextFieldChangeValueProtocol? = nil
    var customRightView = false
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 20, 11);
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 20, 11);
    }
    
    override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        if self.customRightView {
            return CGRectMake(bounds.size.width - 30, 12, 20, 20)
        }
        return bounds
    }
    
    override func becomeFirstResponder() -> Bool {
        if let accesoryView = self.inputAccessoryView as? FieldInputView {
            accesoryView.textField = self
        }
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        let resign =  super.resignFirstResponder()
        if valueDelegate != nil {
            valueDelegate!.fieldChangeValue(self.text!)
        }
        return resign;
    }
    
   
    
}
