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
    func createNewList(_ value:String)
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
        self.selectionStyle = .none
        
        self.inputNameList = ListFieldSearch(frame: CGRect(x: 16.0, y: 0.0, width: 200.0, height: 40.0))
        self.inputNameList!.backgroundColor = WMColor.light_gray
        self.inputNameList!.layer.cornerRadius = 5.0
        self.inputNameList!.font = WMFont.fontMyriadProLightOfSize(16)
        self.inputNameList!.delegate =  self
        self.inputNameList!.placeholder = NSLocalizedString("list.new.placeholder", comment:"")
        self.contentView.addSubview(self.inputNameList!)
        
        self.saveButton = UIButton(type: .custom)
        self.saveButton!.frame = CGRect(x: 0.0, y: 0.0, width: 46.0, height: 40.0)
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.saveButton!.setTitle(NSLocalizedString("list.new.keyboard.save", comment:""), for: UIControlState())
        self.saveButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.addTarget(self, action: #selector(NewListTableViewCell.save(_:)), for: .touchUpInside)
        self.inputNameList!.rightView = self.saveButton
        self.inputNameList!.rightViewMode = .always

        self.scanTicketBtn = UIButton(type: .custom)
        self.scanTicketBtn!.setImage(UIImage(named: "list_scan_ticket"), for: UIControlState())
        self.scanTicketBtn!.addTarget(self, action: #selector(NewListTableViewCell.scanTicket(_:)), for: .touchUpInside)
        self.contentView.addSubview(self.scanTicketBtn!)

        self.separatorView = UIView()
        self.separatorView!.backgroundColor = WMColor.light_light_gray
        self.contentView.addSubview(self.separatorView!)
        
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        if  UserCurrentSession.hasLoggedUser() {
            self.scanTicketBtn!.isHidden = false
            self.scanTicketBtn!.frame = CGRect(x: 16.0, y: (bounds.height - 40.0)/2, width: 40.0, height: 40.0)
            self.inputNameList!.frame = CGRect(x: self.scanTicketBtn!.frame.maxX + 16.0, y: (bounds.height - 40.0)/2, width: bounds.width - 88.0, height: 40.0)
        }
        else {
            self.inputNameList!.frame = CGRect(x: 16.0, y: (bounds.height - 40.0)/2, width: bounds.width - 32.0, height: 40.0)
            self.scanTicketBtn!.isHidden = true
        }
        self.separatorView!.frame = CGRect(x: 72.0, y: bounds.height - 1.0, width: self.contentView.frame.size.width - 72.0, height: 1.0)
    }
    
    //MAR: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        let newString = strNSString.replacingCharacters(in: range, with: string)
        
        return (newString.characters.count > 25) ? false : true
    }
    
    //MARK: - Actions
    
    func scanTicket(_ button:UIButton) {
        self.scanning = true
        if self.inputNameList!.isFirstResponder {
            self.inputNameList!.resignFirstResponder()
        }
        self.delegate?.scanTicket()
    }
    
    func save(_ button:UIButton) {
        if NewListTableViewCell.isValidName(self.inputNameList) {
            self.delegate?.createNewList(self.inputNameList!.text!)
        }
        self.inputNameList!.text = ""
        self.inputNameList!.resignFirstResponder()
    }
    
    func cancel(_ button:UIButton) {
        self.inputNameList!.text = ""
        self.inputNameList!.resignFirstResponder()
        self.delegate?.cancelNewList()
    }

    //MARK: - Validaciones
    
    class func isValidName(_ field:UITextField?) -> Bool {
        if field == nil {
            return false
        }
        let string = field?.text
        if string == nil || string!.isEmpty {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"), imageDone: nil, imageError:
                UIImage(named:"noAvaliable"))
            alert!.setMessage(NSLocalizedString("list.new.validation.name", comment:""))
            alert!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            return false
        }
        
        let whitespaceset = CharacterSet.whitespaces

        let trimmedString = string!.trimmingCharacters(in: whitespaceset)
        let length = trimmedString.lengthOfBytes(using: String.Encoding.utf8)
        if length == 0 {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"), imageDone: nil, imageError:
                UIImage(named:"noAvaliable"))
            alert!.setMessage(NSLocalizedString("list.new.validation.name", comment:""))
            alert!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            return false
        }
        if length < 2 {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"), imageDone: nil, imageError:
                UIImage(named:"noAvaliable"))
            alert!.setMessage(NSLocalizedString("list.new.validation.name.tiny", comment:""))
            alert!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            return false
        }
        
        let alphanumericset = CharacterSet(charactersIn: "áéíóúÁÉÍÓÚabcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ1234567890 ").inverted
        let cleanedName = (trimmedString.components(separatedBy: alphanumericset) as NSArray).componentsJoined(by: "")
        if trimmedString != cleanedName {
           
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"), imageDone: nil, imageError:
                UIImage(named:"noAvaliable"))
            alert!.setMessage(NSLocalizedString("list.new.validation.name.notvalid", comment:""))
            alert!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            field?.becomeFirstResponder()
            field?.resignFirstResponder()
            return false
        }
        
        //self.inputNameList!.text = trimmedString
        field!.text = trimmedString
        
        return true
    }
}
