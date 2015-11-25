//
//  IPASearchView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/19/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPASearchView : UIView,UITextFieldDelegate,BarCodeViewControllerDelegate,CameraViewControllerDelegate,UIPopoverControllerDelegate {
    
    var closeanimation : (() -> Void)!
    var field : FormFieldSearch!
    var backButton : UIButton!
    var delegate: SearchViewControllerDelegate!
    var clearButton: UIButton?
    var errorView : FormFieldErrorView? = nil
    var viewContent : UIView!
    var popover : UIPopoverController?
    var searchctrl : IPASearchLastViewTableViewController!
    
    var camButton: UIButton?
    var camLabel: UILabel?
    var scanButton: UIButton?
    var scanLabel: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        self.field!.addTarget(self, action: "setPopOver", forControlEvents: UIControlEvents.EditingDidBegin)
        
        viewContent = UIView()
        viewContent.clipsToBounds = true
        self.addSubview(viewContent)
        
        backButton = UIButton()
        backButton.frame = CGRectMake(0, 0, 40, 40)
        backButton.setImage(UIImage(named: "search_back"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "closeSearch", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backButton)
        
        self.clearButton = UIButton(type: .Custom)
        self.clearButton!.frame = CGRectMake(self.field.frame.width - 30, 0.0, 30, 30)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Normal)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Highlighted)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Selected)
        self.clearButton!.addTarget(self, action: "clearSearch", forControlEvents: UIControlEvents.TouchUpInside)
        self.clearButton!.alpha = 0
        self.field.addSubview(self.clearButton!)
        
        viewContent.addSubview(field)
        field.becomeFirstResponder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setPopOver()
    }
    
    func setPopOver() {
        if searchctrl == nil {
            searchctrl =  IPASearchLastViewTableViewController()
            searchctrl.view.frame = CGRectMake(0,0,474,500)
            searchctrl.delegate = self.delegate
            if #available(iOS 8.0, *) {
                searchctrl.modalPresentationStyle = .Popover
            } else {
                searchctrl.modalPresentationStyle = .FormSheet
            }
            searchctrl.preferredContentSize = CGSizeMake(474, 500)
            searchctrl.table.alpha = 0
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
            
            let startY : CGFloat = 110.0
            
            self.camButton = UIButton(type: .Custom)
            self.camButton!.frame = CGRectMake(128, startY, 64, 64)
            self.camButton!.setImage(UIImage(named:"search_by_photo"), forState: .Normal)
            self.camButton!.setImage(UIImage(named:"search_by_photo_active"), forState: .Highlighted)
            self.camButton!.setImage(UIImage(named:"search_by_photo"), forState: .Selected)
            self.camButton!.addTarget(self, action: "showCamera:", forControlEvents: UIControlEvents.TouchUpInside)
            searchctrl.view!.addSubview(self.camButton!)
            
            self.camLabel = UILabel()
            self.camLabel!.frame = CGRectMake(self.camButton!.frame.origin.x - 28,  self.camButton!.frame.maxY + 16, 120, 34)
            self.camLabel!.textAlignment = .Center
            self.camLabel!.numberOfLines = 2
            self.camLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.camLabel!.textColor = UIColor.whiteColor()
            self.camLabel!.text = NSLocalizedString("search.info.button.camera",comment:"")
            searchctrl.view!.addSubview(self.camLabel!)
            
            self.scanButton = UIButton(type: .Custom)
            self.scanButton!.frame = CGRectMake(282, startY, 64, 64)
            self.scanButton!.setImage(UIImage(named:"search_by_code"), forState: .Normal)
            self.scanButton!.setImage(UIImage(named:"search_by_code_active"), forState: .Highlighted)
            self.scanButton!.setImage(UIImage(named:"search_by_code"), forState: .Selected)
            self.scanButton!.addTarget(self, action: "showBarCode:", forControlEvents: UIControlEvents.TouchUpInside)
            searchctrl.view!.addSubview(self.scanButton!)
            
            self.scanLabel = UILabel()
            self.scanLabel!.frame = CGRectMake(self.scanButton!.frame.origin.x - 28, self.camButton!.frame.maxY + 16, 120, 34)
            self.scanLabel!.textAlignment = .Center
            self.scanLabel!.numberOfLines = 2
            self.scanLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.scanLabel!.textColor = UIColor.whiteColor()
            self.scanLabel!.text = NSLocalizedString("search.info.button.barcode",comment:"")
            searchctrl.view!.addSubview(self.scanLabel!)
        }
        
        if popover == nil {
            popover = UIPopoverController(contentViewController: searchctrl)
            popover!.delegate = self
            popover!.backgroundColor = WMColor.productAddToCartBg
            popover!.presentPopoverFromRect(CGRectMake(48, self.frame.maxY - 20 , 0, 0), inView: self, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        }
        
        self.showClearButtonIfNeeded(forTextValue: field.text!)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Text.rawValue
        if textField.text != nil && textField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            
            if !(validateText()) {
                return false
            }
            
            self.errorView?.removeFromSuperview()
            
            if textField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) >= 12 && textField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 16 {
                
                let strFieldValue = textField.text! as NSString
                if strFieldValue.integerValue > 0 {
                    let code = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    var character = code
                    if self.isBarCodeUPC(code) {
                        character = code.substringToIndex(code.startIndex.advancedBy(code.characters.count-1 ))
                    }
                    delegate.selectKeyWord("", upc: character, truncate:true,upcs:nil)
                    closePopOver()
                    closeSearch()
                    return true
                }
                if strFieldValue.substringToIndex(1).uppercaseString == "B" {
                    let validateNumeric: NSString = strFieldValue.substringFromIndex(1)
                    if validateNumeric.doubleValue > 0 {
                        delegate.selectKeyWord("", upc: textField.text!.uppercaseString, truncate:false,upcs:nil)
                        closePopOver()
                        closeSearch()
                        return true 
                    }
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
//            self.field!.resignFirstResponder()
            delegate.selectKeyWord(textField.text!, upc: nil, truncate:false,upcs:nil)
            closePopOver()
            closeSearch()
        }
        
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text!
        let keyword = strNSString.stringByReplacingCharactersInRange(range, withString: string)
        if keyword.length() > 51{
            return false
        }
        self.field!.text = keyword;
        searchctrl.searchProductKeywords(keyword)
        self.showClearButtonIfNeeded(forTextValue: keyword)
        return false
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
        let contentView = self.field!.superview!
        contentView.addSubview(self.errorView!)
        UIView.animateWithDuration(0.2, animations: {
            self.clearButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY , 48, 40)
            //            self.scanButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY , 48, 40)
            
            self.errorView!.frame =  CGRectMake(self.field!.frame.minX + 20 , self.field!.frame.minY - self.errorView!.frame.height , self.errorView!.frame.width , self.errorView!.frame.height)
            
            }, completion: {(bool : Bool) in
                if bool {
                    //self.field!.resignFirstResponder()
                }
        })
    }
    
    
    func validateSearch(toValidate:String) -> Bool{
        let regString : String = "^[A-Z0-9a-z._-ñÑÁáÉéÍíÓóÚú ]{0,100}$";
        return validateRegEx(regString,toValidate:toValidate)
    }
    
    func validateRegEx (pattern:String,toValidate:String) -> Bool {
        
        var regExVal: NSRegularExpression?
        do {
            regExVal = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
        } catch {
            regExVal = nil
        }
        let matches = regExVal!.numberOfMatchesInString(toValidate, options: [], range: NSMakeRange(0, toValidate.characters.count))
        
        if matches > 0 {
            return true
        }
        return false
    }
    
    func showBarCode(sender:UIButton) {
        if self.field!.isFirstResponder() {
            self.field!.resignFirstResponder()
        }
        closePopOver()
        self.delegate.searchControllerScanButtonClicked(self)
    }
    
    // MARK: - BarCodeViewControllerDelegate
    func barcodeCaptured(value:String?) {
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Barcode.rawValue
        if value != nil {
            self.delegate.selectKeyWord("", upc: value, truncate:false,upcs:nil)
        }
        else if !self.field!.isFirstResponder() {
            self.field!.becomeFirstResponder()
        }
    }
    
    func showCamera(sender:UIButton) {
        if self.field!.isFirstResponder() {
            self.field!.resignFirstResponder()
        }
        
        self.closePopOver()
        self.delegate.searchControllerCamButtonClicked(self)
    }
    
    // MARK: - CameraViewControllerDelegate
    func photoCaptured(value: String?,upcs:[String]?,done: (() -> Void)) {
        if value != nil && value?.trim() != "" {
            var upcArray = upcs
            if upcArray == nil{
                upcArray = []
            }
            let params = ["upcs": upcArray!, "keyWord":value!]
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.CamFindSearch.rawValue, object: params, userInfo: nil)
            done()
        }
        self.closeSearch()
        self.closePopOver()
        self.field!.resignFirstResponder()
    }
    
    func showClearButtonIfNeeded(forTextValue text:String) {
        if text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0{
            UIView.animateWithDuration(0.5, animations: {
                self.clearButton!.alpha = 1
                self.camButton!.alpha = 0
                self.scanButton!.alpha = 0
                self.camLabel!.alpha = 0
                self.scanLabel!.alpha = 0
                
                self.popover!.backgroundColor = UIColor.whiteColor()
                self.searchctrl!.table.alpha = 0.8
            })
        }
        else {
            UIView.animateWithDuration(0.5, animations: {
                self.clearButton!.alpha = 0
                self.camButton!.alpha = 1
                self.scanButton!.alpha = 1
                self.camLabel!.alpha = 1
                self.scanLabel!.alpha = 1
                
                if self.popover != nil {
                    self.popover!.backgroundColor = WMColor.productAddToCartBg
                }
                self.searchctrl!.table.alpha = 0
            })
        }
    }
    
    func clearSearch(){
        //        //upsSearch = false
        //        self.field!.text = ""
        //        //self.elements = nil
        //        self.showClearButtonIfNeeded(forTextValue: self.field!.text)
        
        self.field!.text = ""
        searchctrl.elements = nil
        searchctrl.elementsCategories = nil
        self.showClearButtonIfNeeded(forTextValue: self.field!.text!)
        searchctrl.showTableIfNeeded()
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
        }
    }
    
    //    func addPopover(keyword:String){
    //
    //        if keyword.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
    //            if searchctrl == nil {
    //                searchctrl =  IPASearchLastViewTableViewController()
    //                searchctrl.view.frame = CGRectMake(0,0,474,500)
    //                searchctrl.delegate = self.delegate
    //                searchctrl.modalPresentationStyle = .Popover
    //                searchctrl.preferredContentSize = CGSizeMake(474, 500)
    //                searchctrl.afterselect = {() in
    //                    self.field.resignFirstResponder()
    //                    self.closePopOver()
    //                    self.closeSearch()
    //                }
    //                searchctrl.endEditing = {() in
    //                    self.field.resignFirstResponder()
    //                    self.searchctrl.view.frame = CGRectMake(0,0,474,500)
    //                    self.searchctrl.preferredContentSize = CGSizeMake(474, 500)
    //                }
    //
    //            }
    //            if popover == nil {
    //                popover = UIPopoverController(contentViewController: searchctrl)
    //                popover!.delegate = self
    //                popover!.presentPopoverFromRect(CGRectMake(48, self.frame.maxY - 20 , 0, 0), inView: self, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
    //            }
    //
    //            searchctrl.searchProductKeywords(keyword)
    //        }
    //
    //    }
    
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
        
        var firstVal = (Int(fullBarcode.substring(0, length: 1))! +
            Int(fullBarcode.substring(2, length: 1))! +
            Int(fullBarcode.substring(4, length: 1))! +
            Int(fullBarcode.substring(6, length: 1))! +
            Int(fullBarcode.substring(8, length: 1))! +
            Int(fullBarcode.substring(10, length: 1))! +
            Int(fullBarcode.substring(12, length: 1))!)
        firstVal *= 3
        
        let secondVal = Int(fullBarcode.substring(1, length: 1))! +
            Int(fullBarcode.substring(3, length: 1))! +
            Int(fullBarcode.substring(5, length: 1))! +
            Int(fullBarcode.substring(7, length: 1))! +
            Int(fullBarcode.substring(9, length: 1))! +
            Int(fullBarcode.substring(11, length: 1))!
        
        let verificationInt = Int(fullBarcode.substring(13, length: 1))!
        
        let result = firstVal + secondVal
        let resultVerInt : Int! = result != 0 ? 10 - (result % 10 ) : 0
        
        return verificationInt == resultVerInt
        
    }
    
    func popoverControllerShouldDismissPopover(popoverController: UIPopoverController) -> Bool {
        self.closeSearch()
        
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if validateText() {
            self.closeSearch()
            if popover != nil{
                self.closePopOver()
            }
            return true;
        }
        return true
        
    }
    
    func validateText() -> Bool {
        let toValidate : NSString = field.text!
        let trimValidate = toValidate.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if toValidate.isEqualToString(""){
            return false
        }
        if trimValidate.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 3 {
            showMessageValidation(NSLocalizedString("product.search.minimum",comment:""))
            return false
        }
        if !validateSearch(field.text!)  {
            showMessageValidation("Texto no permitido")
            return false
        }
        if field.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 50  {
            showMessageValidation("La longitud no puede ser mayor a 50 caracteres")
            return false
        }
        return true
    }
}