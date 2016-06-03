//
//  ListTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 30/07/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol ListTableViewCellDelegate {
    func duplicateList(cell:ListTableViewCell)
    func didListChangeName(cell:ListTableViewCell, text:String?)
    func editCell(cell:SWTableViewCell)
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
    var currencyFmt: NSNumberFormatter? = nil
    var isCopyEnabled = false
    var enableEditing = true
    var canDelete = true
    
    var selectedCell = false
    var lenghtNameList = 0
    
    var viewBgSel : UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None

        self.currencyFmt = NSNumberFormatter()
        self.currencyFmt!.numberStyle = .CurrencyStyle
        self.currencyFmt!.minimumFractionDigits = 2
        self.currencyFmt!.maximumFractionDigits = 2
        self.currencyFmt!.locale = NSLocale(localeIdentifier: "es_MX")
        
        self.iconView = UIImageView(frame: CGRectMake(23.0, 8.0, 40.0, 40.0))
        self.iconView?.contentMode = UIViewContentMode.Center
        self.contentView.addSubview(self.iconView!)
        
        self.textField = ListFieldSearch(frame: CGRectMake(10.0, 0.0, 200.0, 40.0))
        self.textField!.backgroundColor = WMColor.light_light_gray
        self.textField!.layer.cornerRadius = 5.0
        self.textField!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.textField!.delegate =  self
        self.textField!.placeholder = NSLocalizedString("list.new.placeholder", comment:"")
        self.textField!.hidden = true
        self.textField!.alpha = 0.0
        self.contentView.addSubview(self.textField!)

        self.listName = UILabel()
        self.listName!.font = self.listNameFont
        self.listName!.textColor = WMColor.gray
        self.listName!.numberOfLines = 2
        self.contentView.addSubview(self.listName!)
        
        self.articlesTitle = UILabel()
        self.articlesTitle!.font = self.articlesTitleFont
        self.articlesTitle!.textColor = WMColor.gray
        self.articlesTitle!.text = NSLocalizedString("list.articles",comment:"")
        self.contentView.addSubview(self.articlesTitle!)
        
        self.copyBtn = UIButton(type: .Custom)
        self.copyBtn!.setTitle(NSLocalizedString("list.copy", comment:""), forState: .Normal)
        self.copyBtn!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.copyBtn!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.copyBtn!.backgroundColor = WMColor.light_blue
        self.copyBtn!.addTarget(self, action: #selector(ListTableViewCell.duplicate), forControlEvents: .TouchUpInside)
        self.copyBtn!.layer.cornerRadius = 9.0
        self.copyBtn!.alpha = 0.0
        self.copyBtn!.hidden = true
        self.copyBtn!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0);
        self.contentView.addSubview(self.copyBtn!)

        self.separatorView = UIView()
        self.separatorView!.backgroundColor  = WMColor.light_light_gray
        self.contentView.addSubview(self.separatorView!)
        
        var buttonDelete = UIButton()
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete", comment:""), forState: .Normal)
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        
        let buttonDuplicate = UIButton()
        buttonDuplicate.setTitle(NSLocalizedString("list.copy", comment:""), forState: .Normal)
        buttonDuplicate.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDuplicate.backgroundColor = WMColor.light_blue

        self.rightUtilityButtons = [buttonDuplicate,buttonDelete]
        
        buttonDelete = UIButton()
        buttonDelete.setImage(UIImage(named:"myList_delete"), forState: .Normal)
        //buttonDelete.backgroundColor = WMColor.light_gray
        buttonDelete.backgroundColor = UIColor.whiteColor()

        self.setLeftUtilityButtons([buttonDelete], withButtonWidth: self.leftBtnWidth)
        
        viewBgSel = UIView()
        viewBgSel?.backgroundColor = WMColor.light_light_gray
        viewBgSel?.alpha = 1
        self.addSubview(self.viewBgSel!)
        self.sendSubviewToBack(viewBgSel!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.frame.size
        let sep: CGFloat = 16.0
        self.iconView!.frame = CGRectMake(sep, 12, 40.0, 40.0)
        let x = self.iconView!.frame.maxX + sep
        var width = bounds.width - x
        let copyWidth: CGFloat = 55.0

        self.textField!.frame = CGRectMake(x, sep, width - sep, 40.0)
        if self.editing {
            self.textField!.frame = CGRectMake(x, sep, width - (sep + self.leftBtnWidth), 40.0)
        }
        self.copyBtn!.frame = CGRectMake(bounds.width - (copyWidth + sep), (bounds.height - 18.0)/2, 55.0, 18.0)
        self.separatorView!.frame = CGRectMake(16, bounds.height - 1.0, bounds.width, 1.0)

        if self.isCopyEnabled {
            width -= (copyWidth + (2*sep))
        }
        
        self.listName!.frame = CGRectMake(x, sep, width, 20.0)
        self.articlesTitle!.frame = CGRectMake(x, self.listName!.frame.maxY, width, 20.0)
        self.viewBgSel?.frame =  CGRectMake(0.0, 0.0, bounds.width, bounds.height - 1.0)
    }
    
    
    //MARK: - Utils
    
    func setValues(listObject object:NSDictionary) {
        var title = ""
        if let name = object["name"] as? String {
            title = name
        }
        self.listName!.text = title
        self.textField!.text = title
        
        if let countItem = object["countItem"] as? NSNumber {
            self.articlesTitle!.text = String(format: NSLocalizedString("list.articles", comment:""), countItem)
        }
        self.iconView!.image = UIImage(named: "list")
        self.listId = object["id"] as? String
        
        
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
    
    func enableDuplicateListAnimated(flag:Bool) {
        self.copyBtn!.hidden = !flag
        self.isCopyEnabled = flag
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            options: .LayoutSubviews,
            animations: { () -> Void in
                self.copyBtn!.alpha = flag ? 1.0 : 0.0
            },
            completion: { (finished:Bool) -> Void in
                if finished {
                }
            }
        )
    }
    
    func enableDuplicateList(flag:Bool) {
        self.copyBtn!.hidden = !flag
        self.isCopyEnabled = flag
        self.copyBtn!.alpha = flag ? 1.0 : 0.0
        self.setNeedsLayout()
    }

    func enableEditListAnimated(flag:Bool) {
        if self.enableEditing {
            self.textField!.hidden = !flag
            UIView.animateWithDuration(0.25,
                animations: { () -> Void in
                    self.listName!.alpha = flag ? 0.0 : 1.0
                    self.articlesTitle!.alpha = flag ? 0.0 : 1.0
                    self.textField!.alpha = flag ? 1.0 : 0.0
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        self.listName!.hidden = flag
                        self.articlesTitle!.hidden = flag
                        if self.textField!.isFirstResponder() {
                            self.textField!.resignFirstResponder()
                        }
                    }
                }
            )
        }
    }
    
    func enableEditList(flag:Bool) {
        self.textField!.hidden = !flag
        self.textField!.alpha = flag ? 1.0 : 0.0
        self.listName!.hidden = flag
        self.listName!.alpha = flag ? 0.0 : 1.0
        self.articlesTitle!.hidden = flag
        self.articlesTitle!.alpha = flag ? 0.0 : 1.0
        if self.textField!.isFirstResponder() {
            self.textField!.resignFirstResponder()
        }
    }
    
    //MARK: - Actions
    
    func duplicate() {
        self.listDelegate?.duplicateList(self)
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.listDelegate?.editCell(self)
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text!
        let keyword = strNSString.stringByReplacingCharactersInRange(range, withString: string)
        
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        let originalName = self.listName!.text
        if textField.text != nil && originalName != textField.text! {
            if NewListTableViewCell.isValidName(textField) {
                self.listDelegate?.didListChangeName(self, text:textField.text!)
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        viewBgSel?.hidden = !selected
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
    }
    
    

}
