//
//  PickInStoreViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 15/08/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

protocol PickInStoreViewControllerDelegate {
    func didSelectStore(_ storeId: String, storeName: String)
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
    var neighbourhoodsDict:[[String:Any]] = []
    var storesDict:[[String:Any]] = []
    var idSuburb: String! = ""
    var storeId:String! = ""
    var selectedNeighborhood: IndexPath?
    var selectedStore: IndexPath?
    var picker : AlertPickerView!
    var delegate: PickInStoreViewControllerDelegate?
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_REMINDER.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = "Recoger en tienda"
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content!.frame = CGRect(x: 0.0, y: 46.0, width: self.view.bounds.width, height: self.view.bounds.height - (46))
        self.content!.delegate = self
        self.content!.scrollDelegate = self
        self.content!.backgroundColor = UIColor.white
        self.view.addSubview(self.content!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.view.layer.insertSublayer(layerLine, at: 1000)
        
        self.view.backgroundColor = UIColor.white
        
        self.zipCodeLabel = UILabel()
        self.zipCodeLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.zipCodeLabel?.textColor = WMColor.light_blue
        self.zipCodeLabel?.textAlignment = .left
        self.zipCodeLabel?.text = "C.P."
        self.content!.addSubview(self.zipCodeLabel!)
        
        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width , height: 44), inputViewStyle: .keyboard , titleSave:"Ok", save: { (field:UITextField?) -> Void in
            self.callServiceZip(field!.text!, showError: true)
        })
        
        self.zipCodeField = FormFieldView(frame: CGRect(x: 16, y: 16,  width: self.view.frame.width - 32, height: 40))
        self.zipCodeField!.isRequired = true
        self.zipCodeField!.setCustomPlaceholder("Codigo postal")
        self.zipCodeField!.typeField = TypeField.number
        self.zipCodeField!.setImageTypeField()
        self.zipCodeField!.nameField = "Codigo postal"
        self.zipCodeField!.minLength = 5
        self.zipCodeField!.maxLength = 5
        self.zipCodeField!.delegate = self
        self.zipCodeField!.keyboardType = UIKeyboardType.numberPad
        self.zipCodeField!.inputAccessoryView = viewAccess
        self.content!.addSubview(self.zipCodeField!)
        
        self.suburbLabel = UILabel()
        self.suburbLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.suburbLabel?.textColor = WMColor.light_blue
        self.suburbLabel?.textAlignment = .left
        self.suburbLabel?.text = "Colonia"
        self.content!.addSubview(self.suburbLabel!)
        
        self.suburbField = FormFieldView(frame: CGRect(x: 16, y: 16,  width: self.view.frame.width - 32, height: 40))
        self.suburbField!.isRequired = true
        self.suburbField!.setCustomPlaceholder("Colonia")
        self.suburbField!.typeField = TypeField.list
        self.suburbField!.setImageTypeField()
        self.suburbField!.nameField = "Colonia"
        self.suburbField!.minLength = 0
        self.suburbField!.maxLength = 25
        self.content!.addSubview(self.suburbField!)
        
        self.storeLabel = UILabel()
        self.storeLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.storeLabel?.textColor = WMColor.light_blue
        self.storeLabel?.textAlignment = .left
        self.storeLabel?.text = "Tiendas donde puedes recoger este articulo"
        self.content!.addSubview(self.storeLabel!)
        
        self.storeField = FormFieldView(frame: CGRect(x: 16, y: 16,  width: self.view.frame.width - 32, height: 40))
        self.storeField!.isRequired = true
        self.storeField!.setCustomPlaceholder("Tienda")
        self.storeField!.typeField = TypeField.list
        self.storeField!.setImageTypeField()
        self.storeField!.nameField = "Tienda"
        self.storeField!.minLength = 0
        self.storeField!.maxLength = 25
        self.content!.addSubview(self.storeField!)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Guardar", for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(PickInStoreViewController.save), for: UIControlEvents.touchUpInside)
        self.view.addSubview(saveButton!)
        
        self.picker = AlertPickerView.initPickerWithDefault()
        
        self.suburbField!.onBecomeFirstResponder = { () in
            if self.neighbourhoods.count > 0 {
                self.view.endEditing(true)
                self.picker!.selected = self.selectedNeighborhood as NSIndexPath?? ?? IndexPath(row: 0, section: 0)
                self.picker!.sender = self.suburbField!
                self.picker!.selectOptionDelegate = self
                self.picker!.setValues(self.suburbField!.nameField as NSString, values: self.neighbourhoods)
                self.picker!.showPicker()
            }
        }
        
        self.storeField!.onBecomeFirstResponder = { () in
            self.view.endEditing(true)
            if (self.stores.count > 0){
                self.picker!.selected = self.selectedStore as NSIndexPath?? ?? IndexPath(row: 0, section: 0)
                self.picker!.sender = self.storeField!
                self.picker!.selectOptionDelegate = self
                self.picker!.setValues(self.storeField!.nameField as NSString, values: self.stores)
                self.picker!.showPicker()
            }
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let lineHeight: CGFloat = TabBarHidden.isTabBarHidden ? 67 : 113
        self.zipCodeLabel!.frame = CGRect(x: 16, y: 16,  width: self.view.frame.width - 32, height: 20)
        self.zipCodeField!.frame = CGRect(x: 16, y: self.zipCodeLabel!.frame.maxY + 8,  width: self.view.frame.width - 32, height: 40)
        self.suburbLabel!.frame = CGRect(x: 16, y: self.zipCodeField!.frame.maxY + 16,  width: self.view.frame.width - 32, height: 20)
        self.suburbField!.frame = CGRect(x: 16, y: self.suburbLabel!.frame.maxY + 8,  width: self.view.frame.width - 32, height: 40)
        self.storeLabel!.frame = CGRect(x: 16, y: self.suburbField!.frame.maxY + 16,  width: self.view.frame.width - 32, height: 20)
        self.storeField!.frame = CGRect(x: 16, y: self.storeLabel!.frame.maxY + 8,  width: self.view.frame.width - 32, height: 40)
        self.content!.frame = CGRect(x: 0.0, y: 46.0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.layerLine.frame = CGRect(x: 0, y: self.view.frame.height - lineHeight,  width: self.view.frame.width, height: 1)
        self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148,y: self.layerLine.frame.maxY + 16, width: 140, height: 34)
        self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.layerLine.frame.maxY + 16, width: 140, height: 34)
    }
    
    func callServiceZip(_ zipCodeUsr: String, showError:Bool){
        
        let zipCode = zipCodeUsr.trimmingCharacters(in: CharacterSet.whitespaces)
        if zipCode.characters.count==0 {
            return
        }
        var padding : String = ""
        if zipCode.characters.count < 5 {
            padding =  padding.padding( toLength: 5 - zipCode.characters.count , withPad: "0", startingAt: 0)
        }
        
        if (padding + zipCode ==  "00000") {
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(self.zipCodeField!, nameField:self.zipCodeField!.nameField, message: "Texto no permitido" , errorView:self.errorView! , becomeFirstResponder: true)
            
            return
        }
        
        if viewLoad == nil{
            viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 46, width: self.view!.frame.width, height: self.view!.frame.height - 46))
            viewLoad.backgroundColor = UIColor.white
        }
        
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
            self.zipCodeField?.layer.borderColor = WMColor.light_light_gray.cgColor
        }
        
        
        let service = GRZipCodeService()
        self.view.addSubview(viewLoad)
        viewLoad.startAnnimating(false)
        
        
        
        service.callService(service.buildParams(padding + zipCode),  successBlock:{ (resultCall:[String:Any]?) in
            self.viewLoad.stopAnnimating()
            if ((resultCall!["city"] as? String) != nil) {
                self.zipCodeField!.text = resultCall!["zipCode"] as? String
                //self.currentZipCode = self.zipcode!.text!
                
                if self.suburbField!.text == "" &&  self.neighbourhoods.count == 0  {
                    for dic in  resultCall!["neighbourhoods"] as! [[String:Any]]{
                        if dic["id"] as? String ==  self.idSuburb{
                            self.suburbField!.text = dic["neighbourhoodName"] as? String
                            //setElement = true
                        }
                    }
                }
                
                self.neighbourhoodsDict =  resultCall!["neighbourhoods"] as! [[String:Any]]
                self.storesDict = resultCall!["stores"] as! [[String:Any]]
                
                for neighbourhood in self.neighbourhoodsDict {
                    self.neighbourhoods.append(neighbourhood["neighbourhoodName"] as! String)
                }
                
                for storeDict in self.storesDict {
                    self.stores.append(storeDict.object(forKey: "storeName") as! String!)
                }
                
                if self.neighbourhoods.count > 0  {
                    self.suburbField?.becomeFirstResponder()
                    self.suburbField!.text = self.neighbourhoodsDict[0].object(forKey: "neighbourhoodName") as? String
                    self.idSuburb = self.neighbourhoodsDict[0].object(forKey: "neighborhoodId") as? String
                }
                
                if  self.stores.count > 0  {
                    //self.selectedStore = NSIndexPath(forRow: 0, inSection: 0)
                    let name = self.storesDict[0].object(forKey: "storeName") as! String!
                    self.storeField!.text = "\(name)"
                    self.storeId = self.storesDict[0].object(forKey: "storeId") as! String!
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
                    let stringToShow : NSString = error.localizedDescription as NSString
                    let withoutName = stringToShow.replacingOccurrences(of: self.zipCodeField!.nameField, with: "")
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
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - AlertPickerSelectOptionDelegate
    func didSelectOptionAtIndex(_ indexPath: IndexPath) {
        if (picker.sender as! FormFieldView) == self.storeField! {
            self.selectedStore = indexPath
            let store = self.storesDict[(indexPath as NSIndexPath).row]
            self.storeField?.text = store.object(forKey: "storeName") as! String!
            self.storeId? = store.object(forKey: "storeId") as! String!
        }
        if (picker.sender as! FormFieldView) == self.suburbField! {
            self.selectedNeighborhood = indexPath
            let suburb = self.neighbourhoodsDict[(indexPath as NSIndexPath).row]
            self.suburbField!.text = suburb.object(forKey: "neighbourhoodName") as? String
            self.idSuburb = suburb.object(forKey: "neighborhoodId") as? String
        }
    }
    
    //MARK: - UITextFiedDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        let keyword = strNSString.replacingCharacters(in: range, with: string)
    
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
    func contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.content!.contentSize.height)
    }
}
