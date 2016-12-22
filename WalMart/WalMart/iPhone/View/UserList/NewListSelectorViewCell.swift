//
//  NewListSelectorViewCell.swift
//  WalMart
//
//  Created by neftali on 06/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class NewListSelectorViewCell: NewListTableViewCell {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.inputNameList!.returnKeyType = .Default
        
        self.scanTicketBtn?.removeFromSuperview()
        self.scanTicketBtn = nil
        
        self.separatorView?.removeFromSuperview()
        self.separatorView = nil
        
        self.inputNameList!.placeholder = NSLocalizedString("list.selector.new.placeholder", comment:"")

    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        self.inputNameList!.text = ""
        self.inputNameList!.frame = CGRectMake(16.0, 8.0, bounds.width - 32.0, 40.0)
    }
    
    //MARK: - Actions
    
    override func save(button:UIButton) {//Detalle
        if NewListTableViewCell.isValidName(self.inputNameList,showAlert: true) {
            self.delegate?.createNewList(self.inputNameList!.text!)
        }
        self.inputNameList!.text = ""
        self.inputNameList!.resignFirstResponder()
    }

    //MARK: - UITextFieldDelegate
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_ADD_TO_LIST.rawValue, action: WMGAIUtils.ACTION_OPEN_KEYBOARD.rawValue, label: "")
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.delegate?.cancelNewList()
        return true
    }
    
}