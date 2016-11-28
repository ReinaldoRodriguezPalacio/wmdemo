//
//  SuperAddressViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/16/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class SuperAddressViewController : NavigationViewController ,TPKeyboardAvoidingScrollViewDelegate,FormSuperAddressViewDelegate {
    
    var scrollForm : TPKeyboardAvoidingScrollView!
    var saveButton: WMRoundButton?
    var deleteButton: UIButton?
    var addressId: String! = ""
    var sAddredssForm : FormSuperAddressView!
    var viewLoad : WMLoadingView!
    var alertView : IPOWMAlertViewController? = nil
    var allAddress: NSArray! = []
    var showGRAddressForm: Bool = false
    var isPreferred: Bool = false
    var saveButtonBottom: WMRoundButton?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MGMYADDRESSES.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        self.view.backgroundColor = UIColor.white
        
        self.saveButton = WMRoundButton()
        self.saveButton?.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        self.saveButton?.setBackgroundColor(WMColor.green, size: CGSize(width: 71, height: 22), forUIControlState: UIControlState())
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:"" ) , for: UIControlState())
        self.saveButton!.addTarget(self, action: #selector(SuperAddressViewController.save(_:)), for: UIControlEvents.touchUpInside)
        self.saveButton!.isHidden = true
        self.saveButton!.alpha = 0
        self.saveButton!.tag = 1
        self.header?.addSubview(self.saveButton!)
        
        self.saveButtonBottom = WMRoundButton()
        self.saveButtonBottom?.setFontTitle(WMFont.fontMyriadProRegularOfSize(13))
        self.saveButtonBottom?.setBackgroundColor(WMColor.green, size: CGSize(width: 98, height: 34), forUIControlState: UIControlState())
        self.saveButtonBottom!.setTitle(NSLocalizedString("profile.save", comment:"" ).capitalized , for: UIControlState())
        self.saveButtonBottom!.addTarget(self, action: #selector(SuperAddressViewController.save(_:)), for: UIControlEvents.touchUpInside)
        self.saveButtonBottom!.tag = 1
        self.saveButton!.isHidden = true
        self.view.addSubview(self.saveButtonBottom!)
        
        if addressId != "" {
            deleteButton = UIButton()
            deleteButton?.addTarget(self, action: #selector(SuperAddressViewController.deleteAddress(_:)), for: .touchUpInside)
            deleteButton!.setImage(UIImage(named: "deleteAddress"), for: UIControlState())
            self.header!.addSubview(self.deleteButton!)
        }
        
        self.titleLabel?.text = NSLocalizedString("gr.address.title", comment: "")
        
        scrollForm = TPKeyboardAvoidingScrollView()
        self.scrollForm.scrollDelegate = self
        scrollForm.contentSize = CGSize( width: self.view.bounds.width, height: 720)
        if(self.showGRAddressForm){
            sAddredssForm = GRFormSuperAddressView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 700))
        }else{
            sAddredssForm = FormSuperAddressView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 700))
        }
        sAddredssForm.delegateFormAdd = self
        sAddredssForm.allAddress = self.allAddress
        scrollForm.addSubview(sAddredssForm)
        self.view.addSubview(scrollForm)
        
        BaseController.setOpenScreenTagManager(titleScreen: self.titleLabel!.text! , screenName: self.getScreenGAIName())
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var left : CGFloat = 87
        let bounds = self.view.bounds
        
         if addressId != "" {
            self.deleteButton!.frame = CGRect( x: bounds.maxX - 54, y: 0 , width: 54, height: self.header!.frame.height)
            left = left + 30
        }

        self.saveButton!.frame = CGRect(x: self.view.bounds.maxX - left , y: 0 , width: 71, height: self.header!.frame.height)
        self.titleLabel!.frame = CGRect(x: 16, y: 0, width: (bounds.width - 32), height: self.header!.frame.maxY)
        
        sAddredssForm.frame = CGRect(x: 0, y: 0,  width: self.view.bounds.width, height: 700)
        scrollForm.contentSize = CGSize( width: self.view.bounds.width, height: 720)
        scrollForm.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.bounds.width, height: self.view.frame.height - self.header!.frame.maxY)
        
        if self.showGRAddressForm{
            self.setSaveButtonToBottom()
        }
    }
    
    func contentSizeForScrollView(_ sender:AnyObject) -> CGSize {
        let val = CGSize(width: self.view.frame.width, height: 720)
        return val
    }
    
    func textFieldDidBeginEditing(_ sender: UITextField!) {
        
    }
    
    
    
    func changeTitleLabel(){
        UIView.animate(withDuration: 0.4, animations: {
            self.saveButton!.alpha = 1.0
            if self.addressId != "" {
                self.titleLabel!.frame = CGRect(x: 37 , y: 0, width: self.titleLabel!.frame.width , height: self.header!.frame.maxY)
                self.titleLabel!.textAlignment = .left
            }
            }, completion: {(bool : Bool) in
                if bool {
                    self.saveButton!.alpha = 1.0
                }
        })
    }
    
    func showUpdate() {
        self.saveButton!.alpha = 1.0
        self.saveButton!.isHidden = false
        self.sAddredssForm.removeErrorLog()
        if !self.showGRAddressForm {
            self.changeTitleLabel()
        }
    }
    
    func textModify(_ sender: UITextField!) {
        if self.saveButton!.isHidden {
            self.saveButton!.isHidden = false
            self.sAddredssForm.removeErrorLog()
            if !self.showGRAddressForm {
                self.changeTitleLabel()
            }
        }
        if let zipCode = sender as? FormFieldView{
            if zipCode.nameField == NSLocalizedString("gr.address.field.zipcode",comment:"") && zipCode.text! != self.sAddredssForm.currentZipCode {
                self.sAddredssForm.suburb!.text = ""
                self.sAddredssForm.selectedNeighborhood = nil
                self.sAddredssForm.store!.text = ""
                self.sAddredssForm.selectedStore = nil
            }
            if zipCode.nameField == NSLocalizedString("gr.address.field.zipcode",comment:"") && zipCode.text! != self.sAddredssForm.currentZipCode &&  zipCode.text!.characters.count == 5{
                self.sAddredssForm.store.becomeFirstResponder()
            }
        }
    }

    func save(_ sender:UIButton) {
        
        self.view.endEditing(true)
        let service = GRAddressAddService()
        let dictSend = sAddredssForm.getAddressDictionary(self.addressId, delete:false)
        if dictSend != nil {
            self.view.endEditing(true)
            self.scrollForm.resignFirstResponder()
            if showGRAddressForm{
                self.saveButton!.isHidden = true
                self.alertView = IPOWMAlertViewController.showAlert(self, imageWaiting: UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            }
            else{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            }
            let address = ["storeID":dictSend!["StoreID"]!,"storeName":dictSend!["storeName"]!,"zipCode":dictSend!["ZipCode"]!,"addressID":dictSend!["AddressID"]!] as [String:Any]
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:[String:Any]) -> Void  in
                print("Se realizao la direccion")
                self.navigationController?.popViewController(animated: true)
                if let message = resultCall["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                }
                if self.isPreferred {
                    UserCurrentSession.sharedInstance().getStoreByAddress(address)
                }
                self.alertView!.showDoneIcon()
                }) { (error:NSError) -> Void in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            }
        }
    }
    
    func setSaveButtonToBottom(){
        scrollForm.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.bounds.width, height: self.view.frame.height - self.header!.frame.height - 60)
        self.saveButtonBottom!.frame = CGRect(x: (self.view.frame.width/2) - 49 ,y: scrollForm.frame.maxY + 15, width: 98, height: 34)
        let line: CALayer = CALayer()
        line.frame = CGRect(x: 0.0, y: scrollForm.frame.maxY, width: self.view.bounds.width,height: 1.0)
        line.backgroundColor = WMColor.light_light_gray.cgColor
        self.view.layer.insertSublayer(line, at: 0)
        self.saveButton!.removeFromSuperview()
        self.saveButtonBottom!.isHidden = false
    }
    
    func setValues(_ addressId:NSString) {
        self.addressId = addressId as String
        self.viewLoad = WMLoadingView(frame: self.view.bounds)
        self.viewLoad.backgroundColor = UIColor.white
        
        self.view.addSubview(viewLoad)
        self.viewLoad.startAnnimating(true)

        let serviceAddress = GRAddressesByIDService()
        serviceAddress.addressId = addressId as String
        serviceAddress.callService([:], successBlock: { (result:[String:Any]) -> Void in
          
            if self.viewLoad != nil{
                self.viewLoad.stopAnnimating()
            }
            self.viewLoad = nil
            self.titleLabel?.text = result["name"] as! String!
            self.sAddredssForm.addressName.text = result["name"] as! String!
            self.sAddredssForm.outdoornumber.text = result["outerNumber"] as! String!
            self.sAddredssForm.indoornumber.text = result["innerNumber"] as! String!
            self.sAddredssForm.betweenFisrt.text = result["reference1"] as! String!
            self.sAddredssForm.betweenSecond.text = result["reference2"] as! String!
            self.sAddredssForm.zipcode.text = result["zipCode"] as! String!
            self.sAddredssForm.street.text = result["street"] as! String!
            //self.sAddredssForm.defaultPrefered = result["prefered"] as String
            //self.sAddredssForm.defaultPrefered = false
            let neighborhoodID = result["neighborhoodID"] as! String!
            let storeID = result["storeID"] as! String!
            self.sAddredssForm.setZipCodeAnfFillFields(self.sAddredssForm.zipcode.text!, neighborhoodID: neighborhoodID, storeID: storeID)
            }) { (error:NSError) -> Void in
        }
    }
    
    func deleteAddress(_ sender:UIButton){
        
        let service = GRAddressAddService()
        let dictSend = sAddredssForm.getAddressDictionary(self.addressId, delete:true)
        if dictSend != nil {
            self.view.endEditing(true)
            self.scrollForm.resignFirstResponder()
            if showGRAddressForm{
                self.alertView = IPOWMAlertViewController.showAlert(self, imageWaiting: UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            }
            else{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            }
            self.alertView!.setMessage(NSLocalizedString("profile.message.delete",comment:""))
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:[String:Any]) -> Void  in
                print("Se realizao la direccion")
                self.navigationController?.popViewController(animated: true)
                if let message = resultCall["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                    let serviceAddress = GRAddressesByIDService()
                    serviceAddress.addressId = resultCall["addressID"] as? String
                    serviceAddress.callService([:], successBlock: { (result:[String:Any]) -> Void in
                        UserCurrentSession.sharedInstance().getStoreByAddress(result)
                        }, errorBlock: { (error:NSError) -> Void in
                    })
                }
                self.alertView!.showDoneIcon()
                }) { (error:NSError) -> Void in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            }
        }
    }
    
    func showNoCPWarning() {
        
    }

    
}
