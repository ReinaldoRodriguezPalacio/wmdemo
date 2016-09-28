//
//  TextboxTableViewCell.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/08/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class TextboxTableViewCell: UITableViewCell{
    
    var textbox: FormFieldView?
    var datePicker: UIDatePicker?
    var useDatePicker: Bool
    required init?(coder aDecoder: NSCoder) {
        self.useDatePicker = false
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.useDatePicker = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        
        self.textLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.textLabel?.textColor = WMColor.reg_gray
        self.textLabel?.numberOfLines = 0
        self.textLabel?.hidden = true
        textbox = FormFieldView(frame: CGRectMake(5,3, self.frame.width - 12, self.frame.height - 6))
        textbox!.isRequired = true;
        textbox!.typeField = TypeField.String
        self.addSubview(textbox!)
        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width , 44),
            inputViewStyle: .Keyboard,
            titleSave: "Ok",
            save: { (field:UITextField?) -> Void in
                field?.resignFirstResponder()
                if field != nil {
                    if (field!.text == nil || field!.text!.isEmpty) && self.useDatePicker {
                        self.dateChanged()
                    }
                }
        })
        
        textbox!.inputAccessoryView = viewAccess
        }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textbox?.frame = CGRectMake(5,3, self.frame.width - 12, self.frame.height - 6)
    }
    
    
    class func sizeText(text:String,width:CGFloat) -> CGFloat {
        let attrString = NSAttributedString(string:text, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(14)])
        let rectSize = attrString.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return rectSize.height + 32
        
    }
    
    func setDatePickerInputView()
    {
        self.datePicker = UIDatePicker()
        self.datePicker!.datePickerMode = .Date
        self.datePicker!.date = NSDate()
        self.datePicker!.maximumDate = NSDate()
        
        self.datePicker!.addTarget(self, action: #selector(TextboxTableViewCell.dateChanged), forControlEvents: .ValueChanged)
        self.textbox!.inputView = self.datePicker!
        self.useDatePicker = true
        

    }
    
    class func parseDateString(dateStr:String, format:String="dd/MM/yyyy") -> String {
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        let date = dateFmt.dateFromString(dateStr)!
        let formatService  = NSDateFormatter()
        formatService.dateFormat = "dd/MM/yyyy"
        return formatService.stringFromDate(date)
    }
    
    //MARK Date picker Delegate
     func dateChanged() {
        let dateFmt = NSDateFormatter()
        dateFmt.dateFormat = "d MMMM yyyy"
        let date = self.datePicker!.date
        self.textbox!.text = dateFmt.stringFromDate(date)
        self.textbox!.delegate?.textFieldDidEndEditing!(self.textbox!)
    }
    
}