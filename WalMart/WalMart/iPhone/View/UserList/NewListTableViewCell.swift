//
//  NewListTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 07/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol NewListTableViewCellDelegate {
    func cancelNewList()
    func createNewList(value:String)
    func scanTicket()
}

class NewListTableViewCell : UITableViewCell, UITextFieldDelegate {
    
    var inputNameList: ListFieldSearch?
    var saveButton: UIButton?
    var scanTicketBtn: UIButton?
    var separatorView: UIView?
    var scanning = false

    var delegate: NewListTableViewCellDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        
        self.inputNameList = ListFieldSearch(frame: CGRectMake(16.0, 0.0, 200.0, 40.0))
        self.inputNameList!.backgroundColor = WMColor.light_gray
        self.inputNameList!.layer.cornerRadius = 5.0
        self.inputNameList!.font = WMFont.fontMyriadProLightOfSize(16)
        self.inputNameList!.delegate =  self
        self.inputNameList!.placeholder = NSLocalizedString("list.new.placeholder", comment:"")
        self.contentView.addSubview(self.inputNameList!)
        
        self.saveButton = UIButton(type: .Custom)
        self.saveButton!.frame = CGRectMake(0.0, 0.0, 46.0, 40.0)
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.saveButton!.setTitle(NSLocalizedString("list.new.keyboard.save", comment:""), forState: .Normal)
        self.saveButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.addTarget(self, action: #selector(NewListTableViewCell.save(_:)), forControlEvents: .TouchUpInside)
        self.inputNameList!.rightView = self.saveButton
        self.inputNameList!.rightViewMode = .Always

        self.scanTicketBtn = UIButton(type: .Custom)
        self.scanTicketBtn!.setImage(UIImage(named: "list_scan_ticket"), forState: .Normal)
        self.scanTicketBtn!.addTarget(self, action: #selector(NewListTableViewCell.scanTicket(_:)), forControlEvents: .TouchUpInside)
        self.contentView.addSubview(self.scanTicketBtn!)

        self.separatorView = UIView()
        self.separatorView!.backgroundColor = WMColor.light_light_gray
        self.contentView.addSubview(self.separatorView!)
        
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        if  UserCurrentSession.hasLoggedUser() {
            self.scanTicketBtn!.hidden = false
            self.scanTicketBtn!.frame = CGRectMake(16.0, (bounds.height - 40.0)/2, 40.0, 40.0)
            self.inputNameList!.frame = CGRectMake(self.scanTicketBtn!.frame.maxX + 16.0, (bounds.height - 40.0)/2, bounds.width - 88.0, 40.0)
        }
        else {
            self.inputNameList!.frame = CGRectMake(16.0, (bounds.height - 40.0)/2, bounds.width - 32.0, 40.0)
            self.scanTicketBtn!.hidden = true
        }
        self.separatorView!.frame = CGRectMake(0.0, bounds.height - 1.0, self.contentView.frame.size.width, 1.0)
    }
    
    //MAR: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text!
        let newString = strNSString.stringByReplacingCharactersInRange(range, withString: string)
        
        return (newString.characters.count > 25) ? false : true
    }
    
    //MARK: - Actions
    
    func scanTicket(button:UIButton) {
        self.scanning = true
        if self.inputNameList!.isFirstResponder() {
            self.inputNameList!.resignFirstResponder()
        }
        self.delegate?.scanTicket()
    }
    
    func save(button:UIButton) {
        if NewListTableViewCell.isValidName(self.inputNameList,showAlert: true) {//FRom new
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

    //MARK: - Validaciones
    
    class func isValidName(field:UITextField?,showAlert:Bool) -> Bool {
        if field == nil {
            return false
        }
        let string = field?.text
        if string == nil || string!.isEmpty {
            if showAlert{
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"), imageDone: nil, imageError:
                    UIImage(named:"noAvaliable"))
                alert!.setMessage(NSLocalizedString("list.new.validation.name", comment:""))
                alert!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            }
            return false
        }
        
        let whitespaceset = NSCharacterSet.whitespaceCharacterSet()

        let trimmedString = string!.stringByTrimmingCharactersInSet(whitespaceset)
        let length = trimmedString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        if length == 0 {
            if showAlert {
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"), imageDone: nil, imageError:
                    UIImage(named:"noAvaliable"))
                alert!.setMessage(NSLocalizedString("list.new.validation.name", comment:""))
                alert!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            }
            return false
        }
        if length < 2 {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"), imageDone: nil, imageError:
                UIImage(named:"noAvaliable"))
            alert!.setMessage(NSLocalizedString("list.new.validation.name.tiny", comment:""))
            alert!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            return false
        }
        
        let alphanumericset = NSCharacterSet(charactersInString: "áéíóúÁÉÍÓÚabcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ1234567890 ").invertedSet
        let cleanedName = (trimmedString.componentsSeparatedByCharactersInSet(alphanumericset) as NSArray).componentsJoinedByString("")
        if trimmedString != cleanedName {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"), imageDone: nil, imageError:
                UIImage(named:"noAvaliable"))
            alert!.setMessage(NSLocalizedString("list.new.validation.name.notvalid", comment:""))
            alert!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            return false
        }
        
        //self.inputNameList!.text = trimmedString
        field!.text = trimmedString
        
        return true
    }
}