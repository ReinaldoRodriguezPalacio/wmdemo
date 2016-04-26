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
        layerLine.backgroundColor = WMColor.light_gray.CGColor
        self.layer.insertSublayer(layerLine, atIndex: 0)
        
        self.scrollForm = TPKeyboardAvoidingScrollView()
        self.scrollForm!.scrollDelegate = self
        self.scrollForm!.contentSize = CGSizeMake(self.frame.width, 720)
        self.addSubview(scrollForm!)
        
        self.sAddredssForm = GRFormSuperAddressView()
        self.sAddredssForm!.allAddress = self.addressArray
        self.sAddredssForm!.idAddress = ""
        self.scrollForm!.addSubview(sAddredssForm!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Guardar", forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(GRAddAddressView.save), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(saveButton!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollForm?.frame = CGRectMake(0,0,self.frame.width,self.frame.height - 66)
        self.sAddredssForm?.frame = CGRectMake(self.scrollForm!.frame.minX, 0, self.scrollForm!.frame.width, 700)
        self.layerLine.frame = CGRectMake(0,self.frame.height - 66,self.frame.width, 1)
        self.saveButton?.frame = CGRectMake((self.frame.width/2) - 63 , self.layerLine.frame.maxY + 16, 125, 34)
    }
    
    func save(){
        self.endEditing(true)
        self.sAddredssForm!.allAddress = self.addressArray
        let service = GRAddressAddService()
        let dictSend = sAddredssForm!.getAddressDictionary("", delete:false)
        if dictSend != nil {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            dictSend!["preferred"] = true
            let address = ["storeID":dictSend!["StoreID"]!,"storeName":dictSend!["storeName"]!,"zipCode":dictSend!["ZipCode"]!,"addressID":dictSend!["AddressID"]!] as NSDictionary
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:NSDictionary) -> Void  in
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
    
    func textFieldDidEndEditing(sender: UITextField!) {
        if let zipCode = sender as? FormFieldView{
            if zipCode.nameField == NSLocalizedString("gr.address.field.zipcode",comment:"") && zipCode.text! != self.sAddredssForm!.currentZipCode &&  zipCode.text!.characters.count == 5{
                let xipStr = self.sAddredssForm!.zipcode.text! as NSString
                let textZipcode = String(format: "%05d",xipStr.integerValue)
                self.sAddredssForm!.zipcode.text = textZipcode.substringToIndex(textZipcode.startIndex.advancedBy(5))
                self.sAddredssForm!.store.becomeFirstResponder()
            }
        }
    }
    
    func textModify(sender: UITextField!) {
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
                    self.sAddredssForm!.zipcode.text = textZipcode.substringToIndex(textZipcode.startIndex.advancedBy(5))
                    self.sAddredssForm!.store.becomeFirstResponder()
                }
            }
        }
    }
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        return CGSizeMake(self.scrollForm!.frame.width, 700)
    }
}