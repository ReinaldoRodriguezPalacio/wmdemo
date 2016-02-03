//
//  NewListView.swift
//  WalMart
//
//  Created by neftali on 06/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class NewListView: UIControl, UITextFieldDelegate {
    
    var inputNameList: ListFieldSearch?
    var cancelBarButton: UIButton?
    var saveBarButton: UIButton?
    var saveButton: UIButton?

    var delegate: NewListTableViewCellDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        self.inputNameList = ListFieldSearch(frame: CGRectMake(16.0, 8.0, frame.width - 36.0, 40.0))
        self.inputNameList!.backgroundColor = WMColor.light_gray
        self.inputNameList!.layer.cornerRadius = 10.0
        self.inputNameList!.font = WMFont.fontMyriadProLightOfSize(16)
        self.inputNameList!.delegate =  self
        self.inputNameList!.placeholder = NSLocalizedString("list.selector.new.placeholder", comment:"")
        self.addSubview(self.inputNameList!)
        
//        var inputView = UIInputView(frame: CGRectMake(0, 0, 320, 44), inputViewStyle: .Default)
//        self.inputNameList!.inputAccessoryView = inputView
//        
//        self.cancelBarButton = UIButton.buttonWithType(.Custom) as? UIButton
//        self.cancelBarButton!.frame = CGRectMake(15.0, 11.0, 80.0, 33.0)
//        self.cancelBarButton!.backgroundColor = UIColor.clearColor()
//        self.cancelBarButton!.contentHorizontalAlignment = .Left
//        self.cancelBarButton!.titleLabel!.font = WMFont.fontMyriadProLightOfSize(16)
//        self.cancelBarButton!.setTitle(NSLocalizedString("list.new.keyboard.cancel", comment:""), forState: .Normal)
//        self.cancelBarButton!.setTitleColor(WMColor.UIColorFromRGB(0x999999), forState: .Normal)
//        self.cancelBarButton!.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
//        inputView.addSubview(self.cancelBarButton!)
//        
//        self.saveBarButton = UIButton.buttonWithType(.Custom) as? UIButton
//        self.saveBarButton!.frame = CGRectMake(225.0, 11.0, 80.0, 33.0)
//        //self.saveBarButton!.setBackgroundImage(bgImage, forState: .Normal)
//        self.saveBarButton!.titleLabel!.font = WMFont.fontMyriadProLightOfSize(16)
//        self.saveBarButton!.setTitle(NSLocalizedString("list.new.keyboard.save", comment:""), forState: .Normal)
//        self.saveBarButton!.setTitleColor(WMColor.UIColorFromRGB(0x999999), forState: .Normal)
//        self.saveBarButton!.addTarget(self, action: "save:", forControlEvents: .TouchUpInside)
//        inputView.addSubview(self.saveBarButton!)

        self.saveButton = UIButton(type: .Custom)
        self.saveButton!.frame = CGRectMake(0.0, 0.0, 46.0, 40.0)
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProLightOfSize(12)
        self.saveButton!.setTitle(NSLocalizedString("list.new.save", comment:""), forState: .Normal)
        self.saveButton!.setTitleColor(WMColor.gray, forState: .Normal)
        self.saveButton!.backgroundColor = WMColor.UIColorFromRGB(0xF6F6F6)
        self.saveButton!.addTarget(self, action: "save:", forControlEvents: .TouchUpInside)
        self.inputNameList!.rightView = self.saveButton
        self.inputNameList!.rightViewMode = .Always
        
    }

    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.delegate?.cancelNewList()
        return true
    }
    
    //MARK: - Actions
    
    func save(button:UIButton) {
        if NewListTableViewCell.isValidName(self.inputNameList) {
            self.delegate?.createNewList(self.inputNameList!.text!)
        }
        self.inputNameList!.text = ""
        self.inputNameList!.resignFirstResponder()
    }
    
    func cancel(button:UIButton) {
        self.inputNameList!.text = ""
        self.inputNameList!.resignFirstResponder()
        self.delegate?.cancelNewList()
    }

}

class ListFieldSearch: UITextField {
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
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
    }
    
    override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(bounds.size.width - 46.0, 0.0, 46.0, 40.0)
    }
    
}
