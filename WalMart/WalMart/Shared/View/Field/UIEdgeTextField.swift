//
//  UIEdgeTextField.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 17/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol UITextFieldChangeValueProtocol: class {
    func fieldChangeValue(_ value:String)
}

class UIEdgeTextField : UITextField {
    
    var valueDelegate : UITextFieldChangeValueProtocol? = nil
    var customRightView = false
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 11);
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 11);
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        if self.customRightView {
            return CGRect(x: bounds.size.width - 30, y: 12, width: 20, height: 20)
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
            valueDelegate?.fieldChangeValue(self.text!)
        }
        return resign;
    }
    
   
    
}
