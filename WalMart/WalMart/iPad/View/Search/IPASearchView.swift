//
//  IPASearchView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/19/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPASearchView : UIView,UITextFieldDelegate,CameraViewControllerDelegate,UIPopoverControllerDelegate {
    
    var closeanimation : (() -> Void)!
    var field : FormFieldSearch!
    var backButton : UIButton!
    weak var delegate: SearchViewControllerDelegate?
    var clearButton: UIButton?
    var errorView : FormFieldErrorView? = nil
    var viewContent : UIView!
    var popover : UIPopoverController?
    var searchctrl : IPASearchLastViewTableViewController!
    
    var camButton: UIButton?
    var camLabel: UILabel?
    var scanButton: UIButton?
    var scanLabel: UILabel?
    var superExpressButton: UIButton?
    var superExpressLabel: UILabel?
    var tiresBarView: SearchTiresBarView?
    var camfine: Bool = false
    
    var vcWishlist : IPAWishlistViewController!
    var viewBgWishlist : UIView!
    
    var selectedBeforeWishlistIx : Int = 0
    
    var isOpenWishlist : Bool = false
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        field = FormFieldSearch()
        field.returnKeyType = .search
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.enablesReturnKeyAutomatically = true
        field.delegate = self
        field.placeholder = NSLocalizedString("search.info.placeholder",comment:"")
        field.frame = CGRect( x: -self.frame.width + 40, y: (self.frame.height / 2) - 15, width: self.frame.width - 40,height: 30)
        self.field!.addTarget(self, action: #selector(IPASearchView.setPopOver), for: UIControlEvents.editingDidBegin)
        
        viewContent = UIView()
        viewContent.clipsToBounds = true
        self.addSubview(viewContent)
        
        backButton = UIButton()
        backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        backButton.setImage(UIImage(named: "search_back"), for: UIControlState())
        backButton.addTarget(self, action: #selector(IPASearchView.closeSearch), for: UIControlEvents.touchUpInside)
        self.addSubview(backButton)
        
        self.clearButton = UIButton(type: .custom)
        self.clearButton!.frame = CGRect(x: self.field.frame.width - 30, y: 0.0, width: 30, height: 30)
        self.clearButton!.setImage(UIImage(named:"searchClear"), for: UIControlState())
        self.clearButton!.setImage(UIImage(named:"searchClear"), for: .highlighted)
        self.clearButton!.setImage(UIImage(named:"searchClear"), for: .selected)
        self.clearButton!.addTarget(self, action: #selector(IPASearchView.clearSearch), for: UIControlEvents.touchUpInside)
        self.clearButton!.alpha = 0
        self.field.addSubview(self.clearButton!)
        
        viewContent.addSubview(field)
        field.becomeFirstResponder()
        
        self.tiresBarView = SearchTiresBarView()
        self.tiresBarView?.delegate = self
        self.tiresBarView?.isHidden = !self.tiresBarView!.tiresSearch
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var showCamFind = Bundle.main.object(forInfoDictionaryKey: "showCamFind") as! Bool
        self.camButton!.isHidden = !showCamFind
        self.camLabel!.isHidden = !showCamFind
        let widthPopover = 474
        let heightPopover = 500
        
        if showCamFind {
            self.camButton!.frame = CGRect(x: (widthPopover / 4) - 60, y: heightPopover/4 - 32, width: 64, height: 64)
            self.scanButton!.frame = CGRect(x: (widthPopover / 2) - 28 , y: heightPopover/4 - 32, width: 64, height: 64)
            self.superExpressButton!.frame = CGRect(x: 3 * (widthPopover / 4), y: heightPopover/4 - 32, width: 64, height: 64)
            
            self.camLabel!.frame = CGRect(x: self.camButton!.frame.origin.x - 28, y: self.camButton!.frame.origin.y + self.camButton!.frame.height + 16, width: 120, height: 34)
            self.scanLabel!.frame = CGRect(x: self.scanButton!.frame.origin.x - 28, y: self.scanButton!.frame.origin.y + self.scanButton!.frame.height + 16, width: 120, height: 34)
            self.superExpressLabel!.frame = CGRect(x: self.superExpressButton!.frame.origin.x - 28, y: self.superExpressButton!.frame.origin.y + self.superExpressButton!.frame.height + 16, width: 120, height: 34)
        }else{
            self.camButton!.frame = CGRect(x: (widthPopover / 3) - 32, y: heightPopover/4 - 32, width: 64, height: 64)
            self.superExpressButton!.frame = CGRect(x: 2 * (widthPopover / 3) - 32, y: heightPopover/4 - 32, width: 64, height: 64)
            
            self.camLabel!.frame = CGRect(x: self.camButton!.frame.origin.x - 28, y: self.camButton!.frame.origin.y + self.camButton!.frame.height + 16, width: 120, height: 34)
            self.superExpressLabel!.frame = CGRect(x: self.superExpressButton!.frame.origin.x - 28, y: self.superExpressButton!.frame.origin.y + self.superExpressButton!.frame.height + 16, width: 120, height: 34)
        }
        
        self.tiresBarView!.frame = CGRect(x: 0, y: self.scanLabel!.frame.maxY + 13, width: 474, height: 46)
    }
    
    func setPopOver() {
        if searchctrl == nil {
            searchctrl =  IPASearchLastViewTableViewController()
            searchctrl.view.frame = CGRect(x: 0,y: 0,width: 474,height: 500)
            searchctrl.delegate = self.delegate
            searchctrl.modalPresentationStyle = .popover
            searchctrl.preferredContentSize = CGSize(width: 474, height: 500)
            searchctrl.table.alpha = 0
            searchctrl.view.clipsToBounds = true
            searchctrl.afterselect = {() in
                self.field.resignFirstResponder()
                self.closePopOver()
                self.closeSearch()
            }
            searchctrl.endEditing = {() in
                self.field.resignFirstResponder()
                self.searchctrl.view.frame = CGRect(x: 0,y: 0,width: 474,height: 500)
                self.searchctrl.preferredContentSize = CGSize(width: 474, height: 500)
            }
            
            self.superExpressButton = UIButton(type: .custom)
            self.superExpressButton!.setImage(UIImage(named:"superExpress"), for: UIControlState())
            self.superExpressButton!.addTarget(self, action: #selector(SearchViewController.showSuperExpressSearch(_:)), for: UIControlEvents.touchUpInside)
            searchctrl.view!.addSubview(self.superExpressButton!)
            
            self.superExpressLabel = UILabel()
            self.superExpressLabel!.textAlignment = .center
            self.superExpressLabel!.numberOfLines = 2
            self.superExpressLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.superExpressLabel!.textColor = UIColor.white
            self.superExpressLabel!.text = NSLocalizedString("superExpress.search.info.button",comment:"")
            searchctrl.view!.addSubview(self.superExpressLabel!)
            
            self.camButton = UIButton(type: .custom)
            self.camButton!.setImage(UIImage(named:"search_by_photo"), for: UIControlState())
            self.camButton!.setImage(UIImage(named:"search_by_photo_active"), for: .highlighted)
            self.camButton!.setImage(UIImage(named:"search_by_photo"), for: .selected)
            self.camButton!.addTarget(self, action: #selector(IPASearchView.showCamera(_:)), for: UIControlEvents.touchUpInside)
            searchctrl.view!.addSubview(self.camButton!)
            
            self.camLabel = UILabel()
            self.camLabel!.textAlignment = .center
            self.camLabel!.numberOfLines = 2
            self.camLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.camLabel!.textColor = UIColor.white
            self.camLabel!.text = NSLocalizedString("search.info.button.camera",comment:"")
            searchctrl.view!.addSubview(self.camLabel!)
            
            self.scanButton = UIButton(type: .custom)
            self.scanButton!.setImage(UIImage(named:"search_by_code"), for: UIControlState())
            self.scanButton!.setImage(UIImage(named:"search_by_code_active"), for: .highlighted)
            self.scanButton!.setImage(UIImage(named:"search_by_code"), for: .selected)
            self.scanButton!.addTarget(self, action: #selector(IPASearchView.showBarCode(_:)), for: UIControlEvents.touchUpInside)
            searchctrl.view!.addSubview(self.scanButton!)
            
            self.scanLabel = UILabel()
            self.scanLabel!.textAlignment = .center
            self.scanLabel!.numberOfLines = 2
            self.scanLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.scanLabel!.textColor = UIColor.white
            self.scanLabel!.text = NSLocalizedString("search.info.button.barcode",comment:"")
            searchctrl.view!.addSubview(self.scanLabel!)
            
            searchctrl.view!.addSubview(self.tiresBarView!)
        }
        
        if popover == nil {
            popover = UIPopoverController(contentViewController: searchctrl)
            popover!.delegate = self
            popover!.backgroundColor = WMColor.light_blue
            popover!.present(from: CGRect(x: 48, y: self.frame.maxY - 20 , width: 0, height: 0), in: self, permittedArrowDirections: UIPopoverArrowDirection.up, animated: true)
        }
        
        self.showClearButtonIfNeeded(forTextValue: field.text!)
    }
    
    func closeSearch() {
        self.field.resignFirstResponder()
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            // self.frame =  CGRectMake(-self.frame.width, self.frame.minY, self.frame.width, self.frame.height)
            self.field!.frame = CGRect(x: -self.field!.frame.width, y: self.field!.frame.minY, width: self.field!.frame.width, height: self.field!.frame.height)
            }, completion: { (complete:Bool) -> Void in
                self.removeFromSuperview()
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    if self.closeanimation != nil {
                        self.closeanimation()
                    }
                })
        }) 
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Text.rawValue
        
        if textField.text != nil && textField.text!.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            
            if !(validateText()) {
                return false
            }
            
            self.errorView?.removeFromSuperview()
            
            if textField.text!.lengthOfBytes(using: String.Encoding.utf8) >= 12 && textField.text!.lengthOfBytes(using: String.Encoding.utf8) <= 16 {
                
                let strFieldValue = textField.text! as NSString
                if strFieldValue.integerValue > 0 && textField.text!.isNumeric() {
                    let code = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
                    var character = code
                    if self.isBarCodeUPC(code as NSString) {
                        character = code.substring(to: code.characters.index(code.startIndex, offsetBy: code.characters.count-1))
                    }
                    delegate?.selectKeyWord("", upc: character, truncate:true,upcs:nil)
                    closePopOver()
                    closeSearch()
                    return true
                }
                
                if strFieldValue.substring(to: 1).uppercased() == "B" {
                    let validateNumeric: NSString = strFieldValue.substring(from: 1) as NSString
                    if validateNumeric.doubleValue > 0 {
                        delegate?.selectKeyWord("", upc: textField.text!.uppercased(), truncate:false,upcs:nil)
                        closePopOver()
                        closeSearch()
                        return true 
                    }
                }
                
            }
            
            delegate?.selectKeyWord(textField.text!, upc: nil, truncate:false,upcs:nil)
            closePopOver()
            closeSearch()
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        let keyword = strNSString.replacingCharacters(in: range, with: string)
        if keyword.length() >= 2 {
            //setPopOver() //por peticionwm
        }
        if !camfine{
        if keyword.length() > 51{
            return false
            }
        }
        self.field!.text = keyword;
        self.closePopOver()
        //searchctrl.searchProductKeywords(keyword) //por peticionwm
        self.showClearButtonIfNeeded(forTextValue: keyword)
        return false
    }
    
    func showMessageValidation(_ message:String){
        
        
        if self.errorView == nil{
            self.errorView = FormFieldErrorView()
        }
        
        self.errorView!.frame = CGRect(x: self.field!.frame.minX + 20, y: 0, width: self.field!.frame.width, height: self.field!.frame.height )
        self.errorView!.focusError = self.field!
        if self.field!.frame.minX < 20 {
            self.errorView!.setValues(280, strLabel:"Buscar", strValue: message)
            self.errorView!.frame =  CGRect(x: self.field!.frame.minX + 20, y: self.field!.frame.minY , width: self.errorView!.frame.width , height: self.errorView!.frame.height)
        }
        else{
            self.errorView!.setValues(field!.frame.width, strLabel:"Buscar", strValue: message)
            self.errorView!.frame =  CGRect(x: field!.frame.minX + 20, y: field!.frame.minY, width: errorView!.frame.width , height: errorView!.frame.height)
        }
        let contentView = self.field!.superview!
        contentView.addSubview(self.errorView!)
        UIView.animate(withDuration: 0.2, animations: {
            
            // self.clearButton!.frame = CGRect(x: self.field!.frame.maxX - 49 , y: self.field!.frame.midY , width: 48, height: 40)
            // self.scanButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY , 48, 40)
            
            self.errorView!.frame =  CGRect(x: self.field!.frame.minX + 20 , y: self.field!.frame.minY - self.errorView!.frame.height , width: self.errorView!.frame.width , height: self.errorView!.frame.height)
            
            }, completion: {(bool : Bool) in
                if bool {
                    //self.field!.resignFirstResponder()
                }
        })
    }
    
    
    func validateSearch(_ toValidate:String) -> Bool{
        let regString : String = "^[A-Z0-9a-z._-ñÑÁáÉéÍíÓóÚú& /]{0,100}$";
        return IPASearchView.validateRegEx(regString,toValidate:toValidate)
    }
    
    class func validateRegEx (_ pattern:String,toValidate:String) -> Bool {
        
        var regExVal: NSRegularExpression?
        do {
            regExVal = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        } catch {
            regExVal = nil
        }
        let matches = regExVal!.numberOfMatches(in: toValidate, options: [], range: NSMakeRange(0, toValidate.characters.count))
        
        if matches > 0 {
            return true
        }
        return false
    }
    
    func showBarCode(_ sender:UIButton) {
        if self.field!.isFirstResponder {
            self.field!.resignFirstResponder()
        }
        self.closeSearch()
        closePopOver()
        self.delegate?.searchControllerScanButtonClicked()
    }
    
    func showCamera(_ sender:UIButton) {
        if self.field!.isFirstResponder {
            self.field!.resignFirstResponder()
        }
        
        self.closePopOver()
        self.delegate?.searchControllerCamButtonClicked(self)
    }
    
    // MARK: - CameraViewControllerDelegate
    func photoCaptured(_ value: String?,upcs:[String]?,done: (() -> Void)) {
        if value != nil && value?.trim() != "" {
            var upcArray = upcs
            if upcArray == nil{
                upcArray = []
            }
            let params = ["upcs": upcArray!, "keyWord":value!] as [String : Any]
            NotificationCenter.default.post(name: .camFindSearch, object: params, userInfo: nil)
            done()
        }
        self.closeSearch()
        self.closePopOver()
        self.field!.resignFirstResponder()
    }
    
    func showClearButtonIfNeeded(forTextValue text:String) {
        if text.lengthOfBytes(using: String.Encoding.utf8) > 0{
            UIView.animate(withDuration: 0.5, animations: {
                self.clearButton!.alpha = 1
                self.camButton!.alpha = 0
                self.scanButton!.alpha = 0
                self.camLabel!.alpha = 0
                self.scanLabel!.alpha = 0
                
                self.popover?.backgroundColor = UIColor.white
                self.searchctrl!.table.alpha = 0.8
            })
        }
        else {
            UIView.animate(withDuration: 0.5, animations: {
                self.clearButton!.alpha = 0
                self.camButton!.alpha = 1
                self.scanButton!.alpha = 1
                self.camLabel!.alpha = 1
                self.scanLabel!.alpha = 1
                
                if self.popover != nil {
                    self.popover?.backgroundColor = WMColor.light_blue
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
    
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController) {
        popover = nil
    }
    
    func closePopOver (){
        if self.popover != nil {
            self.popover!.dismiss(animated: true)
            popover = nil
        }
    }
    
    func isBarCodeUPC(_ codeUPC: NSString) -> Bool {
        
        var fullBarcode = codeUPC as String
        
        if codeUPC.length == 14 {
            return false
        }
        
        if codeUPC.length < 14 {
            let toFill = "".padding(toLength: 14 - codeUPC.length, withPad: "0", startingAt: 0)
            fullBarcode = "\(toFill)\(codeUPC)"
        }
        
        if Int(fullBarcode) == nil {
            return false
        }
        
        var firstVal = (Int(fullBarcode.substring(0, length: 1))! +
            Int(fullBarcode.substring(2, length: 1))! +
            Int(fullBarcode.substring(4, length: 1))! +
            Int(fullBarcode.substring(6, length: 1))! +
            Int(fullBarcode.substring(8, length: 1))! +
            Int(fullBarcode.substring(10, length: 1))! +
            Int(fullBarcode.substring(12, length: 1))!)
        firstVal = firstVal * 3
        
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
    
    func popoverControllerShouldDismissPopover(_ popoverController: UIPopoverController) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if validateText() {
            self.closeSearch()
            if popover != nil{
                self.closePopOver()
            }
            return true
        }
        return true
        
    }
   
    func validateText() -> Bool {
        let toValidate : NSString = field.text! as NSString
        let trimValidate = toValidate.trimmingCharacters(in: CharacterSet.whitespaces)
        if toValidate.isEqual(to: ""){
            return false
        }
        if trimValidate.lengthOfBytes(using: String.Encoding.utf8) < 2 {
            showMessageValidation(NSLocalizedString("product.search.minimum",comment:""))
            return false
        }
        if !validateSearch(field.text!)  {
            showMessageValidation("Texto no permitido")
            return false
        }
        if field.text!.lengthOfBytes(using: String.Encoding.utf8) > 50  {
            showMessageValidation("La longitud no puede ser mayor a 50 caracteres")
            return false
        }
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.tiresBarView!.frame = CGRect(x: 0, y: self.scanLabel!.frame.maxY + 13, width: 474, height: 46)
        if self.tiresBarView!.tiresSearch {
            self.tiresBarView!.isHidden = false
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tiresBarView!.frame = CGRect(x: 0, y: 454, width: 474, height: 46)
        if self.tiresBarView!.tiresSearch {
            self.tiresBarView!.isHidden = false
        }
    }
    
    
    func showSuperExpressSearch(_ sender: UIButton){
        delegate?.showSuperExpressSearch()
        self.closeSearch()
        closePopOver()
    }
}

extension IPASearchView: SearchTiresBarViewDelegate {
    func showTiresSearch() {
        delegate?.showTiresSearch()
        self.closeSearch()
        closePopOver()
    }
}
