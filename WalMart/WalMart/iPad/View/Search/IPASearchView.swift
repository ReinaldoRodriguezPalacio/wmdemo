//
//  IPASearchView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/19/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation



class IPASearchView : UIView,UITextFieldDelegate,BarCodeViewControllerDelegate,UIPopoverControllerDelegate {
    
    var closeanimation : (() -> Void)!
    var field : FormFieldSearch!
    var backButton : UIButton!
    var delegate:SearchViewControllerDelegate!
    var scanButton: UIButton?
    var clearButton: UIButton?
    var errorView : FormFieldErrorView? = nil
    var viewContent : UIView!
    var popover : UIPopoverController?
    var searchctrl : IPASearchLastViewTableViewController!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    func setup() {
        
        field = FormFieldSearch()
        field.returnKeyType = .Search
        field.autocapitalizationType = .None
        field.autocorrectionType = .No
        field.enablesReturnKeyAutomatically = true
        field.delegate = self
        field.frame = CGRectMake( -self.frame.width + 40, (self.frame.height / 2) - 15, self.frame.width - 40,30)
        
        viewContent = UIView()
        viewContent.clipsToBounds = true
        self.addSubview(viewContent)
        
        backButton = UIButton()
        backButton.frame = CGRectMake(0, 0, 40, 40)
        backButton.setImage(UIImage(named: "search_back"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "closeSearch", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backButton)
        
        self.scanButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.scanButton!.frame = CGRectMake(self.field.frame.width - 30, 0.0, 30, 30)
        self.scanButton!.setImage(UIImage(named:"searchScan"), forState: .Normal)
        self.scanButton!.setImage(UIImage(named:"searchScan"), forState: .Highlighted)
        self.scanButton!.setImage(UIImage(named:"searchScan"), forState: .Selected)
        self.scanButton!.addTarget(self, action: "showBarCode:", forControlEvents: UIControlEvents.TouchUpInside)
        self.field.addSubview(self.scanButton!)
        
        self.clearButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.clearButton!.frame = CGRectMake(self.field.frame.width - 30, 0.0, 30, 30)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Normal)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Highlighted)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Selected)
        self.clearButton!.addTarget(self, action: "clearSearch", forControlEvents: UIControlEvents.TouchUpInside)
        self.clearButton!.hidden = true
        self.field.addSubview(self.clearButton!)
        
        viewContent.addSubview(field)
        field.becomeFirstResponder()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if searchctrl != nil {
            self.searchctrl.view.frame = CGRectMake(0,0,474,500)
            self.searchctrl.preferredContentSize = CGSizeMake(474, 500)
        }

    }
    
    
    func closeSearch() {
        self.field.resignFirstResponder()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
           // self.frame =  CGRectMake(-self.frame.width, self.frame.minY, self.frame.width, self.frame.height)
            self.field!.frame = CGRectMake(-self.field!.frame.width, self.field!.frame.minY, self.field!.frame.width, self.field!.frame.height)
            }) { (complete:Bool) -> Void in
               self.removeFromSuperview()
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    if self.closeanimation != nil {
                        self.closeanimation()
                    }
                })
        }
      
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Text.rawValue
        if textField.text != nil && textField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            if self.errorView != nil {
                self.errorView?.removeFromSuperview()
                self.errorView = nil
            }
            let toValidate : NSString = textField.text
            let trimValidate = toValidate.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if trimValidate.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 3 {
                showMessageValidation(NSLocalizedString("product.search.minimum",comment:""))
                return true
            }
            if !validateSearch(textField.text)  {
                showMessageValidation("Texto no permitido")
                return true
            }
            if textField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 50  {
                showMessageValidation("La longitud no puede ser mayor a 50 caractéres")
                return true
            }
            
             if textField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) >= 12 && textField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 16 {
            
                let strFieldValue = textField.text as NSString
                if strFieldValue.integerValue > 0 {
                    var code = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    var character = code
                    if self.isBarCodeUPC(code) {
                        character = code.substringToIndex(advance(code.startIndex, countElements(code)-1 ))
                    }
                    delegate.selectKeyWord("", upc: character, truncate:true)
                    self.field!.resignFirstResponder()
                    closePopOver()
                    return true
                }
                if strFieldValue.substringToIndex(1).uppercaseString == "B" {
                    delegate.selectKeyWord("", upc: textField.text, truncate:false)
                    self.field!.resignFirstResponder()
                    closePopOver()
                    return true
                }

                
                /*let strFieldValue = textField.text as NSString
                if strFieldValue.integerValue > 0 {
                    var character = textField.text
                    if self.isBarCodeUPC(character) {
                        character = character.substringToIndex(advance(character.startIndex, countElements(character)-1 ))
                    }
                    delegate.selectKeyWord("", upc: character, truncate:true)
                    self.field!.resignFirstResponder()
                    closePopOver()
                    return true
                }
                if strFieldValue.substringToIndex(1).uppercaseString == "B" {
                    delegate.selectKeyWord("", upc: textField.text, truncate:false)
                    self.field!.resignFirstResponder()
                    closePopOver()
                    return true
                }*/
            }
            self.field!.resignFirstResponder()
            delegate.selectKeyWord(textField.text, upc: nil, truncate:false)
            closePopOver()
        }
        return false
    }
    
    func textField(textField: UITextField!, shouldChangeCharactersInRange range: NSRange, replacementString string: String!) -> Bool {
        let strNSString : NSString = textField.text
        let keyword = strNSString.stringByReplacingCharactersInRange(range, withString: string)
        self.showClearButtonIfNeeded(forTextValue: keyword)
        addPopover(keyword)
        return true
    }
    
    func showMessageValidation(message:String){
        
        
        if self.errorView == nil{
            self.errorView = FormFieldErrorView()
        }
        
        self.errorView!.frame = CGRectMake(self.field!.frame.minX + 20, 0, self.field!.frame.width, self.field!.frame.height )
        self.errorView!.focusError = self.field!
        if self.field!.frame.minX < 20 {
            self.errorView!.setValues(280, strLabel:"Buscar", strValue: message)
            self.errorView!.frame =  CGRectMake(self.field!.frame.minX + 20, self.field!.frame.minY , self.errorView!.frame.width , self.errorView!.frame.height)
        }
        else{
            self.errorView!.setValues(field!.frame.width, strLabel:"Buscar", strValue: message)
            self.errorView!.frame =  CGRectMake(field!.frame.minX + 20, field!.frame.minY, errorView!.frame.width , errorView!.frame.height)
        }
        var contentView = self.field!.superview!
        contentView.addSubview(self.errorView!)
        UIView.animateWithDuration(0.2, animations: {
            self.clearButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY , 48, 40)
            self.scanButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY , 48, 40)
            
            self.errorView!.frame =  CGRectMake(self.field!.frame.minX + 20 , self.field!.frame.minY - self.errorView!.frame.height , self.errorView!.frame.width , self.errorView!.frame.height)
            
            }, completion: {(bool : Bool) in
                if bool {
                    self.field!.resignFirstResponder()
                }
        })
    }
    
    
    func validateSearch(toValidate:String) -> Bool{
        let regString : String = "^[A-Z0-9a-z._-ñÑÁáÉéÍíÓóÚú ]{0,100}$";
        return validateRegEx(regString,toValidate:toValidate)
    }
    
    func validateRegEx (pattern:String,toValidate:String) -> Bool {
        var error: NSError?
        
        var regExVal = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
        let matches = regExVal!.numberOfMatchesInString(toValidate, options: nil, range: NSMakeRange(0, countElements(toValidate)))
        
        if matches > 0 {
            return true
        }
        return false
    }
    
    func showBarCode(sender:UIButton) {
        if self.field!.isFirstResponder() {
            self.field!.resignFirstResponder()
        }
        self.delegate.searchControllerScanButtonClicked(self)
    }
    
    // MARK: - BarCodeViewControllerDelegate
    func barcodeCaptured(value:String?) {
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Barcode.rawValue
        if value != nil {
            self.delegate.selectKeyWord("", upc: value, truncate:false)
        }
        else if !self.field!.isFirstResponder() {
            self.field!.becomeFirstResponder()
        }
    }
    
    func showClearButtonIfNeeded(forTextValue text:String) {
        if text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0{
            self.clearButton!.hidden = false
            self.scanButton!.hidden = true
        } else {
            self.clearButton!.hidden = true
            self.scanButton!.hidden = false
        }
    }
    
    func clearSearch(){
        //upsSearch = false
        self.field!.text = ""
        //self.elements = nil
        self.showClearButtonIfNeeded(forTextValue: self.field!.text)
    }
    
    func addPopover(keyword:String){
        
        if keyword.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
            if searchctrl == nil {
                searchctrl =  IPASearchLastViewTableViewController()
                searchctrl.view.frame = CGRectMake(0,0,474,500)
                searchctrl.delegate = self.delegate
                searchctrl.modalPresentationStyle = .Popover
                searchctrl.preferredContentSize = CGSizeMake(474, 500)
                searchctrl.afterselect = {() in
                    self.field.resignFirstResponder()
                    self.closePopOver()
                    self.closeSearch()
                }
                searchctrl.endEditing = {() in
                    self.field.resignFirstResponder()
                    self.searchctrl.view.frame = CGRectMake(0,0,474,500)
                    self.searchctrl.preferredContentSize = CGSizeMake(474, 500)
                }
                
            }
            if popover == nil {
                popover = UIPopoverController(contentViewController: searchctrl)
                popover!.delegate = self
                popover!.presentPopoverFromRect(CGRectMake(48, self.frame.maxY - 20 , 0, 0), inView: self, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
            }
          
            searchctrl.searchProductKeywords(keyword)
        }
        
    }
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        popover = nil
    }
    
    func closePopOver (){
        if self.popover != nil {
            self.popover!.dismissPopoverAnimated(true)
            popover = nil
        }
    }
    
    func isBarCodeUPC(codeUPC:NSString) -> Bool {
        var fullBarcode = codeUPC as String
        if codeUPC.length < 14 {
            let toFill = "".stringByPaddingToLength(14 - codeUPC.length, withString: "0", startingAtIndex: 0)
            fullBarcode = "\(toFill)\(codeUPC)"
        }
        
        let firstVal = (fullBarcode.substring(0, length: 1).toInt()! +
            fullBarcode.substring(2, length: 1).toInt()! +
            fullBarcode.substring(4, length: 1).toInt()! +
            fullBarcode.substring(6, length: 1).toInt()! +
            fullBarcode.substring(8, length: 1).toInt()! +
            fullBarcode.substring(10, length: 1).toInt()! +
            fullBarcode.substring(12, length: 1).toInt()!)  * 3
        
        let secondVal = fullBarcode.substring(1, length: 1).toInt()! +
            fullBarcode.substring(3, length: 1).toInt()! +
            fullBarcode.substring(5, length: 1).toInt()! +
            fullBarcode.substring(7, length: 1).toInt()! +
            fullBarcode.substring(9, length: 1).toInt()! +
            fullBarcode.substring(11, length: 1).toInt()!
        
        let verificationInt = fullBarcode.substring(13, length: 1).toInt()!
        
        let result = firstVal + secondVal
        let resultVerInt : Int! = result != 0 ? 10 - (result % 10 ) : 0
        
        return verificationInt == resultVerInt
        
    }


    
}