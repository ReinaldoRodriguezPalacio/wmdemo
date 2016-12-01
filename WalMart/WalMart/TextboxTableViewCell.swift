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
        self.textLabel?.textColor = WMColor.gray
        self.textLabel?.numberOfLines = 0
        self.textLabel?.isHidden = true
        textbox = FormFieldView(frame: CGRect(x: 5,y: 3, width: self.frame.width - 12, height: self.frame.height - 6))
        textbox!.isRequired = true;
        textbox!.typeField = TypeField.string
        self.addSubview(textbox!)
        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width , height: 44),
            inputViewStyle: .keyboard,
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
        self.textbox?.frame = CGRect(x: 5,y: 3, width: self.frame.width - 12, height: self.frame.height - 6)
    }
    
    
    class func sizeText(_ text:String,width:CGFloat) -> CGFloat {
        let attrString = NSAttributedString(string:text, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(14)])
        let rectSize = attrString.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        return rectSize.height + 32
        
    }
    
    func setDatePickerInputView()
    {
        self.datePicker = UIDatePicker()
        self.datePicker!.datePickerMode = .date
        self.datePicker!.date = Date()
        self.datePicker!.maximumDate = Date()
        
        self.datePicker!.addTarget(self, action: #selector(TextboxTableViewCell.dateChanged), for: .valueChanged)
        self.textbox!.inputView = self.datePicker!
        self.useDatePicker = true
        

    }
    
    class func parseDateString(_ dateStr:String, format:String="dd/MM/yyyy") -> String {
        let dateFmt = DateFormatter()
        dateFmt.timeZone = TimeZone.current
        dateFmt.dateFormat = format
        let date = dateFmt.date(from: dateStr)!
        let formatService  = DateFormatter()
        formatService.dateFormat = "dd/MM/yyyy"
        return formatService.string(from: date)
    }
    
    //MARK Date picker Delegate
     func dateChanged() {
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "d MMMM yyyy"
        let date = self.datePicker!.date
        self.textbox!.text = dateFmt.string(from: date)
        self.textbox!.delegate?.textFieldDidEndEditing!(self.textbox!)
    }
    
}
