//
//  SESugestedRowTitleViewCell.swift
//  WalMart
//
//  Created by Vantis on 20/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class SESugestedRowTitleViewCell: UITableViewCell,UITextFieldDelegate {
    
    
    var itemView : UILabel!
    var itemViewTxt : UITextField!
    var deleteItem: UIButton!
    var editItem: UIButton!
    var section: Int!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        
        self.editItem.frame = CGRect(x: 15, y: self.frame.height / 2 - self.frame.height * 0.7 / 2, width: self.frame.height * 0.7 , height: self.frame.height * 0.7)
        self.itemView.frame = CGRect(x: self.editItem.frame.maxX + 5, y: 0, width: self.frame.width - 50, height: self.frame.height)
        self.itemViewTxt.frame = CGRect(x: self.editItem.frame.maxX + 5, y: 0, width: self.frame.width - 50, height: self.frame.height)
        self.deleteItem.frame = CGRect(x: self.frame.width - 40, y: 0, width: 30, height: self.frame.height)
        
    }
    
    func setup(){
        
        self.editItem = UIButton(frame:CGRect(x: 15, y: self.frame.height / 2 - self.frame.height * 0.7 / 2, width: self.frame.height * 0.7 , height: self.frame.height * 0.7))
        self.editItem.addTarget(self, action: #selector(self.editSection(_:)), for: UIControlEvents.touchUpInside)
        self.editItem.setImage(UIImage(named: "wishlist_edit_active"), for: UIControlState())
        self.addSubview(self.editItem)
        
        self.itemView = UILabel(frame: CGRect(x: self.editItem.frame.maxX + 5, y: 0, width: self.frame.width - 50, height: self.frame.height))
        self.itemView!.font =  WMFont.fontMyriadProRegularOfSize(14)
        self.itemView!.isHidden = false
        self.addSubview(self.itemView)
        
        self.itemViewTxt = UITextField(frame: CGRect(x: self.editItem.frame.maxX + 5, y: 0, width: self.frame.width - 50, height: self.frame.height))
        self.itemViewTxt!.font =  WMFont.fontMyriadProRegularOfSize(14)
        self.itemViewTxt!.isHidden = true
        self.itemViewTxt!.delegate = self
        self.itemViewTxt!.returnKeyType = .done
        self.itemViewTxt!.autocapitalizationType = .none
        self.itemViewTxt!.autocorrectionType = .no
        self.itemViewTxt!.enablesReturnKeyAutomatically = true
        //self.itemViewTxt!.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.addSubview(self.itemViewTxt)
        
        self.deleteItem = UIButton(frame:CGRect(x: self.frame.width - 40, y: 0,width: 30, height: self.frame.height))
        self.deleteItem.setImage(UIImage(named: "termsClose"), for: UIControlState())
        self.addSubview(self.deleteItem)
        
    }
    
    func setValues(_ itemNameList:String, section: Int) {
        self.itemView!.text = itemNameList
        self.section = section
    }
    
    func editSection(_ sender:UIButton){
        sender.isEnabled = false
        self.deleteItem.isEnabled = false
        self.itemView!.isHidden = true
        self.itemViewTxt!.isHidden = false
        self.itemViewTxt!.text = self.itemView!.text
        self.itemViewTxt!.becomeFirstResponder()
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        //myArray = []
        //myArray = allItems.filter { $0.lowercased().contains(textField.text!.lowercased()) }
        //self.invokeTypeAheadService()
        //self.cargaSugerencias()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Text.rawValue
        
        if textField.text != nil && textField.text!.lengthOfBytes(using: String.Encoding.utf8) > 2 {
            
            //buscaSugerencias(textField.text)
            
            /*selectedItems.append(textField.text!)
            listaSuper.reloadData()
            textField.text = ""
            self.myArray = []
            self.cargaSugerencias()*/
            
            self.editItem.isEnabled = true
            self.deleteItem.isEnabled = true
            self.itemView!.isHidden = false
            self.itemViewTxt!.isHidden = true
            self.itemView!.text = self.itemViewTxt!.text
            
            return true
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        var  keyword = strNSString.replacingCharacters(in: range, with: string)
        if keyword.length() > 51 {
            return false
        }
        
        if keyword.length() < 1 {
            keyword = ""
        }
        
        return true
    }

    
}
