//
//  PickInStoreViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 15/08/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

protocol PickInStoreViewControllerDelegate {
    func didSelectStore(storeId: String, storeName: String)
}

class PickInStoreViewController: NavigationViewController,TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, AlertPickerSelectOptionDelegate {
    
    var zipCodeLabel:UILabel?
    var suburbLabel:UILabel?
    var storeLabel:UILabel?
    var zipCodeField: FormFieldView?
    var suburbField: FormFieldView?
    var storeField:FormFieldView?
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var content:TPKeyboardAvoidingScrollView?
    var errorView : FormFieldErrorView? = nil
    var viewLoad : WMLoadingView!
    
    var stores:[String] = []
    var neighbourhoods: [String] = []
    var neighbourhoodsDict:[NSDictionary] = []
    var storesDict:[NSDictionary] = []
    var idSuburb: String! = ""
    var storeId:String! = ""
    var selectedNeighborhood: NSIndexPath?
    var selectedStore: NSIndexPath?
    var picker : AlertPickerView!
    var delegate: PickInStoreViewControllerDelegate?
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_REMINDER.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = "Recoger en tienda"
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content!.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, self.view.bounds.height - (46))
        self.content!.delegate = self
        self.content!.scrollDelegate = self
        self.content!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.view.layer.insertSublayer(layerLine, atIndex: 1000)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.zipCodeLabel = UILabel()
        self.zipCodeLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.zipCodeLabel?.textColor = WMColor.light_blue
        self.zipCodeLabel?.textAlignment = .Left
        self.zipCodeLabel?.text = "C.P."
        self.content!.addSubview(self.zipCodeLabel!)
        
        let viewAccess = FieldInputView(frame: CGRectMake(0, 0, self.view.frame.width , 44), inputViewStyle: .Keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            self.callServiceZip(field!.text!, showError: true)
        })
        
        self.zipCodeField = FormFieldView(frame: CGRectMake(16, 16,  self.view.frame.width - 32, 40))
        self.zipCodeField!.isRequired = true
        self.zipCodeField!.setCustomPlaceholder("Codigo postal")
        self.zipCodeField!.typeField = TypeField.Number
        self.zipCodeField!.setImageTypeField()
        self.zipCodeField!.nameField = "Codigo postal"
        self.zipCodeField!.minLength = 5
        self.zipCodeField!.maxLength = 5
        self.zipCodeField!.delegate = self
        self.zipCodeField!.keyboardType = UIKeyboardType.NumberPad
        self.zipCodeField!.inputAccessoryView = viewAccess
        self.content!.addSubview(self.zipCodeField!)
        
        self.suburbLabel = UILabel()
        self.suburbLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.suburbLabel?.textColor = WMColor.light_blue
        self.suburbLabel?.textAlignment = .Left
        self.suburbLabel?.text = "Colonia"
        self.content!.addSubview(self.suburbLabel!)
        
        self.suburbField = FormFieldView(frame: CGRectMake(16, 16,  self.view.frame.width - 32, 40))
        self.suburbField!.isRequired = true
        self.suburbField!.setCustomPlaceholder("Colonia")
        self.suburbField!.typeField = TypeField.List
        self.suburbField!.setImageTypeField()
        self.suburbField!.nameField = "Colonia"
        self.suburbField!.minLength = 0
        self.suburbField!.maxLength = 25
        self.content!.addSubview(self.suburbField!)
        
        self.storeLabel = UILabel()
        self.storeLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.storeLabel?.textColor = WMColor.light_blue
        self.storeLabel?.textAlignment = .Left
        self.storeLabel?.text = "Tiendas donde puedes recoger este articulo"
        self.content!.addSubview(self.storeLabel!)
        
        self.storeField = FormFieldView(frame: CGRectMake(16, 16,  self.view.frame.width - 32, 40))
        self.storeField!.isRequired = true
        self.storeField!.setCustomPlaceholder("Tienda")
        self.storeField!.typeField = TypeField.List
        self.storeField!.setImageTypeField()
        self.storeField!.nameField = "Tienda"
        self.storeField!.minLength = 0
        self.storeField!.maxLength = 25
        self.content!.addSubview(self.storeField!)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Guardar", forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(PickInStoreViewController.save), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(saveButton!)
        
        self.picker = AlertPickerView.initPickerWithDefault()
        
        self.suburbField!.onBecomeFirstResponder = { () in
            if self.neighbourhoods.count > 0 {
                self.view.endEditing(true)
                self.picker!.selected = self.selectedNeighborhood ?? NSIndexPath(forRow: 0, inSection: 0)
                self.picker!.sender = self.suburbField!
                self.picker!.selectOptionDelegate = self
                self.picker!.setValues(self.suburbField!.nameField, values: self.neighbourhoods)
                self.picker!.showPicker()
            }
        }
        
        self.storeField!.onBecomeFirstResponder = { () in
            self.view.endEditing(true)
            if (self.stores.count > 0){
                self.picker!.selected = self.selectedStore ?? NSIndexPath(forRow: 0, inSection: 0)
                self.picker!.sender = self.storeField!
                self.picker!.selectOptionDelegate = self
                self.picker!.setValues(self.storeField!.nameField, values: self.stores)
                self.picker!.showPicker()
            }
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let lineHeight: CGFloat = TabBarHidden.isTabBarHidden ? 67 : 113
        self.zipCodeLabel!.frame = CGRectMake(16, 16,  self.view.frame.width - 32, 20)
        self.zipCodeField!.frame = CGRectMake(16, self.zipCodeLabel!.frame.maxY + 8,  self.view.frame.width - 32, 40)
        self.suburbLabel!.frame = CGRectMake(16, self.zipCodeField!.frame.maxY + 16,  self.view.frame.width - 32, 20)
        self.suburbField!.frame = CGRectMake(16, self.suburbLabel!.frame.maxY + 8,  self.view.frame.width - 32, 40)
        self.storeLabel!.frame = CGRectMake(16, self.suburbField!.frame.maxY + 16,  self.view.frame.width - 32, 20)
        self.storeField!.frame = CGRectMake(16, self.storeLabel!.frame.maxY + 8,  self.view.frame.width - 32, 40)
        self.content!.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, self.view.bounds.height)
        self.layerLine.frame = CGRectMake(0, self.view.frame.height - lineHeight,  self.view.frame.width, 1)
        self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148,self.layerLine.frame.maxY + 16, 140, 34)
        self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.layerLine.frame.maxY + 16, 140, 34)
    }
    
    func callServiceZip(zipCodeUsr: String, showError:Bool){
        
        let zipCode = zipCodeUsr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if zipCode.characters.count==0 {
            return
        }
        var padding : String = ""
        if zipCode.characters.count < 5 {
            padding =  padding.stringByPaddingToLength( 5 - zipCode.characters.count , withString: "0", startingAtIndex: 0)
        }
        
        if (padding + zipCode ==  "00000") {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(self.zipCodeField!, nameField:self.zipCodeField!.nameField, message: "Texto no permitido" , errorView:self.errorView! , becomeFirstResponder: true)
            
            return
        }
        
        if viewLoad == nil{
            viewLoad = WMLoadingView(frame: CGRectMake(0, 46, self.view!.frame.width, self.view!.frame.height - 46))
            viewLoad.backgroundColor = UIColor.whiteColor()
        }
        
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
            self.zipCodeField?.layer.borderColor = WMColor.light_light_gray.CGColor
        }
        
        
        let service = GRZipCodeService()
        self.view.addSubview(viewLoad)
        viewLoad.startAnnimating(false)
        
        
        
        service.callService(service.buildParams(padding + zipCode),  successBlock:{ (resultCall:NSDictionary?) in
            self.viewLoad.stopAnnimating()
            if ((resultCall!["city"] as? String) != nil) {
                self.zipCodeField!.text = resultCall!["zipCode"] as? String
                //self.currentZipCode = self.zipcode!.text!
                
                if self.suburbField!.text == "" &&  self.neighbourhoods.count == 0  {
                    for dic in  resultCall!["neighbourhoods"] as! [NSDictionary]{
                        if dic["id"] as? String ==  self.idSuburb{
                            self.suburbField!.text = dic["neighbourhoodName"] as? String
                            //setElement = true
                        }
                    }
                }
                
                self.neighbourhoodsDict =  resultCall!["neighbourhoods"] as! [NSDictionary]
                self.storesDict = resultCall!["stores"] as! [NSDictionary]
                
                for neighbourhood in self.neighbourhoodsDict {
                    self.neighbourhoods.append(neighbourhood["neighbourhoodName"] as! String)
                }
                
                for storeDict in self.storesDict {
                    self.stores.append(storeDict.objectForKey("storeName") as! String!)
                }
                
                if self.neighbourhoods.count > 0  {
                    self.suburbField?.becomeFirstResponder()
                    self.suburbField!.text = self.neighbourhoodsDict[0].objectForKey("neighbourhoodName") as? String
                    self.idSuburb = self.neighbourhoodsDict[0].objectForKey("neighbourhoodId") as? String
                }
                
                if  self.stores.count > 0  {
                    //self.selectedStore = NSIndexPath(forRow: 0, inSection: 0)
                    let name = self.storesDict[0].objectForKey("storeName") as! String!
                    self.storeField!.text = "\(name)"
                    self.storeId = self.storesDict[0].objectForKey("storeId") as! String!
                }
                
            }
            }, errorBlock: {(error: NSError) in
                self.neighbourhoods = []
                self.idSuburb = ""
                self.suburbField!.text = ""
                self.viewLoad.stopAnnimating()
                if showError {
                    
                    if self.errorView == nil{
                        self.errorView = FormFieldErrorView()
                    }
                    let stringToShow : NSString = error.localizedDescription
                    let withoutName = stringToShow.stringByReplacingOccurrencesOfString(self.zipCodeField!.nameField, withString: "")
                    SignUpViewController.presentMessage(self.zipCodeField!, nameField:self.zipCodeField!.nameField, message: withoutName , errorView:self.errorView!,  becomeFirstResponder: true )
                }
                else{
                    self.zipCodeField?.resignFirstResponder()
                }
        })
    }
    
    func save(){
        if self.storeId != "" && self.storeField!.text! != "" {
            self.delegate?.didSelectStore(self.storeId, storeName: self.storeField!.text!)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - AlertPickerSelectOptionDelegate
    func didSelectOptionAtIndex(indexPath: NSIndexPath) {
        if (picker.sender as! FormFieldView) == self.storeField! {
            self.selectedStore = indexPath
            let store = self.storesDict[indexPath.row]
            self.storeField?.text = store.objectForKey("storeName") as! String!
            self.storeId? = store.objectForKey("storeId") as! String!
        }
        if (picker.sender as! FormFieldView) == self.suburbField! {
            self.selectedNeighborhood = indexPath
            let suburb = self.neighbourhoodsDict[indexPath.row]
            self.suburbField!.text = suburb.objectForKey("neighbourhoodName") as? String
            self.idSuburb = suburb.objectForKey("neighbourhoodId") as? String
        }
    }
    
    //MARK: - UITextFiedDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text!
        let keyword = strNSString.stringByReplacingCharactersInRange(range, withString: string)
    
        if Int(keyword) == nil && keyword != "" {
            return false
        }
        if keyword.characters.count == 5{
            self.callServiceZip(keyword, showError:true)
        }
        else if keyword.characters.count > 5 {
            return false
        }
        return true
    }

    
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        return CGSizeMake(self.view.frame.width, self.content!.contentSize.height)
    }
}
