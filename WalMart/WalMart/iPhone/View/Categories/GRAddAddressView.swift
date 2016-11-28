//
//  GRAddAddressView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 08/04/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class GRAddAddressView: UIView, TPKeyboardAvoidingScrollViewDelegate {
    var scrollForm: TPKeyboardAvoidingScrollView?
    var layerLine: CALayer!
    var sAddredssForm: GRFormSuperAddressView?
    var addressArray: [AnyObject]?
    var saveButton: UIButton?
    var alertView: IPOWMAlertViewController?
    var onClose: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_gray.cgColor
        self.layer.insertSublayer(layerLine, at: 0)
        
        self.scrollForm = TPKeyboardAvoidingScrollView()
        self.scrollForm!.scrollDelegate = self
        self.scrollForm!.contentSize = CGSize(width: self.frame.width, height: 720)
        self.addSubview(scrollForm!)
        
        self.sAddredssForm = GRFormSuperAddressView()
        self.sAddredssForm!.allAddress = self.addressArray as NSArray!
        self.sAddredssForm!.idAddress = ""
        self.scrollForm!.addSubview(sAddredssForm!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Guardar", for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(GRAddAddressView.save), for: UIControlEvents.touchUpInside)
        self.addSubview(saveButton!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollForm?.frame = CGRect(x: 0,y: 0,width: self.frame.width,height: self.frame.height - 66)
        self.sAddredssForm?.frame = CGRect(x: self.scrollForm!.frame.minX, y: 0, width: self.scrollForm!.frame.width, height: 700)
        self.layerLine.frame = CGRect(x: 0,y: self.frame.height - 66,width: self.frame.width, height: 1)
        self.saveButton?.frame = CGRect(x: (self.frame.width/2) - 63 , y: self.layerLine.frame.maxY + 16, width: 125, height: 34)
    }
    /**
     Save a new address
     */
    func save(){
        self.endEditing(true)
        self.sAddredssForm!.allAddress = self.addressArray as NSArray!
        let service = GRAddressAddService()
        let dictSend = sAddredssForm!.getAddressDictionary("", delete:false)
        if dictSend != nil {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            dictSend!["preferred"] = true
            let address = ["storeID":dictSend!["StoreID"]!,"storeName":dictSend!["storeName"]!,"zipCode":dictSend!["ZipCode"]!,"addressID":dictSend!["AddressID"]!] as [String:Any]
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:[String:Any]) -> Void  in
                if let message = resultCall["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                }
                UserCurrentSession.sharedInstance().getStoreByAddress(address)
                self.alertView!.showDoneIcon()
                self.onClose?()
                }) { (error:NSError) -> Void in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            }
        }
    }
    
    //MARK: - textFieldDelegate
    func textFieldDidEndEditing(_ sender: UITextField!) {
        if let zipCode = sender as? FormFieldView{
            if zipCode.nameField == NSLocalizedString("gr.address.field.zipcode",comment:"") && zipCode.text! != self.sAddredssForm!.currentZipCode &&  zipCode.text!.characters.count == 5{
                let xipStr = self.sAddredssForm!.zipcode.text! as NSString
                let textZipcode = String(format: "%05d",xipStr.integerValue)
                self.sAddredssForm!.zipcode.text = textZipcode.substring(to: textZipcode.characters.index(textZipcode.startIndex, offsetBy: 5))
                self.sAddredssForm!.store.becomeFirstResponder()
            }
        }
    }
    
    func textModify(_ sender: UITextField!) {
        if let zipCode = sender as? FormFieldView{
            if zipCode.nameField == NSLocalizedString("gr.address.field.zipcode",comment:"") && zipCode.text! != self.sAddredssForm!.currentZipCode {
                self.sAddredssForm!.suburb!.text = ""
                self.sAddredssForm!.selectedNeighborhood = nil
                self.sAddredssForm!.store!.text = ""
                self.sAddredssForm!.selectedStore = nil
            }
            if zipCode.nameField == NSLocalizedString("gr.address.field.zipcode",comment:"") && zipCode.text! != self.sAddredssForm!.currentZipCode &&  zipCode.text!.characters.count == 5{
                if self.sAddredssForm!.zipcode.text!.utf16.count > 0 {
                    let xipStr = self.sAddredssForm!.zipcode.text! as NSString
                    let textZipcode = String(format: "%05d",xipStr.integerValue)
                    self.sAddredssForm!.zipcode.text = textZipcode.substring(to: textZipcode.characters.index(textZipcode.startIndex, offsetBy: 5))
                    self.sAddredssForm!.store.becomeFirstResponder()
                }
            }
        }
    }
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    func contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
        return CGSize(width: self.scrollForm!.frame.width, height: 700)
    }
}
