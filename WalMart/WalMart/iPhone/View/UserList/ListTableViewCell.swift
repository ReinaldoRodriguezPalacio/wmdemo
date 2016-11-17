//
//  ListTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 30/07/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol ListTableViewCellDelegate {
    func duplicateList(_ cell:ListTableViewCell)
    func didListChangeName(_ cell:ListTableViewCell, text:String?)
    func editCell(_ cell:SWTableViewCell)
}

class ListTableViewCell : SWTableViewCell, UITextFieldDelegate {
    
    let listNameFont = WMFont.fontMyriadProLightOfSize(18)
    let articlesTitleFont = WMFont.fontMyriadProRegularOfSize(14)
    let leftBtnWidth:CGFloat = 48.0

    var listId: String?
    
    var listName: UILabel?
    var articlesTitle: UILabel?
    var iconView: UIImageView?
    var copyBtn: UIButton?
    var textField: ListFieldSearch?
    var separatorView: UIView?
    
    
    var listDelegate: ListTableViewCellDelegate?
    var currencyFmt: NumberFormatter? = nil
    var isCopyEnabled = false
    var enableEditing = true
    var canDelete = true
    
    var selectedCell = false
    var lenghtNameList = 0
    
    var viewBgSel : UIView?
    
    var reminderLabel: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none

        self.currencyFmt = NumberFormatter()
        self.currencyFmt!.numberStyle = .currency
        self.currencyFmt!.minimumFractionDigits = 2
        self.currencyFmt!.maximumFractionDigits = 2
        self.currencyFmt!.locale = Locale(identifier: "es_MX")
        
        self.iconView = UIImageView(frame: CGRect(x: 23.0, y: 8.0, width: 40.0, height: 40.0))
        self.iconView?.contentMode = UIViewContentMode.center
        self.contentView.addSubview(self.iconView!)
        
        self.textField = ListFieldSearch(frame: CGRect(x: 10.0, y: 0.0, width: 200.0, height: 40.0))
        self.textField!.backgroundColor = WMColor.light_light_gray
        self.textField!.layer.cornerRadius = 5.0
        self.textField!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.textField!.delegate =  self
        self.textField!.placeholder = NSLocalizedString("list.new.placeholder", comment:"")
        self.textField!.isHidden = true
        self.textField!.alpha = 0.0
        self.contentView.addSubview(self.textField!)

        self.listName = UILabel()
        self.listName!.font = self.listNameFont
        self.listName!.textColor = WMColor.reg_gray
        self.listName!.numberOfLines = 2
        self.contentView.addSubview(self.listName!)
        
        self.articlesTitle = UILabel()
        self.articlesTitle!.font = self.articlesTitleFont
        self.articlesTitle!.textColor = WMColor.reg_gray
        self.articlesTitle!.text = NSLocalizedString("list.articles",comment:"")
        self.contentView.addSubview(self.articlesTitle!)
        
        self.copyBtn = UIButton(type: .custom)
        self.copyBtn!.setTitle(NSLocalizedString("list.copy.new", comment:""), for: UIControlState())
        self.copyBtn!.setTitleColor(UIColor.white, for: UIControlState())
        self.copyBtn!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.copyBtn!.backgroundColor = WMColor.light_blue
        self.copyBtn!.addTarget(self, action: #selector(ListTableViewCell.duplicate), for: .touchUpInside)
        self.copyBtn!.layer.cornerRadius = 9.0
        self.copyBtn!.alpha = 0.0
        self.copyBtn!.isHidden = true
        self.copyBtn!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0);
        self.contentView.addSubview(self.copyBtn!)
        
        self.reminderLabel = UILabel()
        self.reminderLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.reminderLabel!.textColor = WMColor.orange
        self.reminderLabel!.isHidden =  true
        self.reminderLabel?.adjustsFontSizeToFitWidth =  true
        self.reminderLabel?.textAlignment =  .right
        self.contentView.addSubview(self.reminderLabel!)

        self.separatorView = UIView()
        self.separatorView!.backgroundColor  = WMColor.light_light_gray
        self.contentView.addSubview(self.separatorView!)
        
        var buttonDelete = UIButton()
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete", comment:""), for: UIControlState())
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        
        let buttonDuplicate = UIButton()
        buttonDuplicate.setTitle(NSLocalizedString("list.copy", comment:""), for: UIControlState())
        buttonDuplicate.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDuplicate.backgroundColor = WMColor.light_blue

        self.rightUtilityButtons = [buttonDuplicate,buttonDelete]
        
        buttonDelete = UIButton()
        buttonDelete.setImage(UIImage(named:"myList_delete"), for: UIControlState())
        //buttonDelete.backgroundColor = WMColor.light_gray
        buttonDelete.backgroundColor = UIColor.white

        self.setLeftUtilityButtons([buttonDelete], withButtonWidth: self.leftBtnWidth)
        

        
        viewBgSel = UIView()
        viewBgSel?.backgroundColor = WMColor.light_light_gray
        viewBgSel?.alpha = 1
        self.addSubview(self.viewBgSel!)
        self.sendSubview(toBack: viewBgSel!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.frame.size
        let sep: CGFloat = 16.0
        self.iconView!.frame = CGRect(x: sep, y: 12, width: 40.0, height: 40.0)
        let x = self.iconView!.frame.maxX + sep
        var width = bounds.width - x
        let copyWidth: CGFloat = 55.0

        self.textField!.frame = CGRect(x: x, y: sep, width: width - sep, height: 40.0)
        if self.isEditing {
            self.textField!.frame = CGRect(x: x, y: sep, width: width - (sep + self.leftBtnWidth), height: 40.0)
        }
        self.copyBtn!.frame = CGRect(x: bounds.width - (copyWidth + sep), y: (bounds.height - 18.0)/2, width: 55.0, height: 18.0)
        self.separatorView!.frame = CGRect(x: self.iconView!.frame.maxX, y: bounds.height - 1.0, width: bounds.width, height: 1.0)

        if self.isCopyEnabled {
            width -= (copyWidth + (2*sep))
        }
        
        self.listName!.frame = CGRect(x: x, y: sep, width: width, height: 20.0)
        self.articlesTitle!.frame = CGRect(x: x, y: self.listName!.frame.maxY, width: self.frame.midX - x, height: 20.0)
        self.reminderLabel!.frame = CGRect(x: self.articlesTitle!.frame.maxX, y: self.listName!.frame.maxY, width: self.frame.midX - 16, height: 20.0)
        self.viewBgSel?.frame =  CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height - 1.0)
    }
    
    
    //MARK: - Utils
    
    func setValues(listObject object:[String:Any]) {
        var title = ""
        if let name = object["name"] as? String {
            title = name
        }
        self.listName!.text = title
        self.textField!.text = title
        
        if let countItem = object["giftlistItems"] as? [[String:Any]] {
            print(countItem.count)
            self.articlesTitle!.text = String(format: NSLocalizedString("list.articles", comment:""), "\(countItem.count)")
        }
        self.iconView!.image = UIImage(named: "list")
        self.listId = object["repositoryId"] as? String
        if self.listId != nil{
            let reminderService = ReminderNotificationService(listId: self.listId!, listName: title)
            reminderService.findNotificationForCurrentList()
            if reminderService.existNotificationForCurrentList() {
                print("print::: \(reminderService.getNotificationPeriod())")
                self.reminderLabel?.text = "Recordatorio \(reminderService.getNotificationPeriod())"
                self.reminderLabel?.isHidden =  false
            }else{
                print("print::: No tiene recordatorios")
                self.reminderLabel?.isHidden =  true
                self.reminderLabel?.text = ""
            }
        }
        
        let editLenghtList : String = self.listName!.text!
        self.lenghtNameList = editLenghtList.length()
    }
    
    func setValues(listEntity list:List) {
        self.listName!.text = list.name
        self.textField!.text = list.name
        self.listId = list.name
        self.articlesTitle!.text = String(format: NSLocalizedString("list.articles", comment:""), list.countItem)
        self.iconView!.image = UIImage(named: "list")
    }
    
    func setValues(name nameList:String,count:String,icon:UIImage,enableEditing:Bool) {
        self.listName!.text = nameList
        self.textField!.text = nameList
        self.articlesTitle!.text = String(format: NSLocalizedString("list.articles", comment:""), count)
        self.iconView!.image = icon
        self.enableEditing = enableEditing
    }
    
    func setValuesDefaultList(name nameList:String,count:String,icon:UIImage,enableEditing:Bool) {
        self.listName!.text = nameList
        self.textField!.text = nameList
        self.articlesTitle!.text = String(format: NSLocalizedString("list.articles", comment:""), count)
        self.iconView!.image = icon
        self.enableEditing = enableEditing
    }
    
    func enableDuplicateListAnimated(_ flag:Bool) {
        self.copyBtn!.isHidden = !flag
        self.isCopyEnabled = flag
        UIView.animate(withDuration: 0.5,
            delay: 0.0,
            options: .layoutSubviews,
            animations: { () -> Void in
                self.copyBtn!.alpha = flag ? 1.0 : 0.0
            },
            completion: { (finished:Bool) -> Void in
                if finished {
                }
            }
        )
    }
    
    func enableDuplicateList(_ flag:Bool) {
        self.copyBtn!.isHidden = !flag
        self.isCopyEnabled = flag
        self.copyBtn!.alpha = flag ? 1.0 : 0.0
        self.setNeedsLayout()
        self.reminderLabel?.isHidden = flag
    }

    func enableEditListAnimated(_ flag:Bool) {
        if self.enableEditing {
            self.textField!.isHidden = !flag
             self.reminderLabel?.isHidden = flag
            UIView.animate(withDuration: 0.25,
                animations: { () -> Void in
                    self.listName!.alpha = flag ? 0.0 : 1.0
                    self.articlesTitle!.alpha = flag ? 0.0 : 1.0
                    self.textField!.alpha = flag ? 1.0 : 0.0
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        self.listName!.isHidden = flag
                        self.articlesTitle!.isHidden = flag
                        if self.textField!.isFirstResponder {
                            self.textField!.resignFirstResponder()
                        }
                    }
                }
            )
        }
    }
    
    func enableEditList(_ flag:Bool) {
        self.textField!.isHidden = !flag
        self.textField!.alpha = flag ? 1.0 : 0.0
        self.listName!.isHidden = flag
        self.listName!.alpha = flag ? 0.0 : 1.0
        self.articlesTitle!.isHidden = flag
        self.articlesTitle!.alpha = flag ? 0.0 : 1.0
        if self.textField!.isFirstResponder {
            self.textField!.resignFirstResponder()
        }
    }
    
    //MARK: - Actions
    
    func duplicate() {
        self.listDelegate?.duplicateList(self)
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.listDelegate?.editCell(self)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        let keyword = strNSString.replacingCharacters(in: range, with: string)
        
        if lenghtNameList > 26 {
            if (keyword.characters.count <= lenghtNameList + 1) {
                return true
            }
        }

        if (keyword.characters.count > 25) {
            return false
        }
        

        self.listDelegate?.didListChangeName(self, text:keyword)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let originalName = self.listName!.text
        if textField.text != nil && originalName != textField.text! { //Edit cell
            if NewListTableViewCell.isValidName(textField,showAlert: false) {
                self.listDelegate?.didListChangeName(self, text:textField.text!)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        viewBgSel?.isHidden = !selected
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }
    
    

}
