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
    
    
    
//    override func getScreenGAIName() -> String {
//        return WMGAIUtils.SCREEN_MGMYADDRESSES.rawValue
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.saveButton = WMRoundButton()
        self.saveButton?.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        self.saveButton?.setBackgroundColor(WMColor.green, size: CGSizeMake(71, 22), forUIControlState: UIControlState.Normal)
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:"" ) , forState: UIControlState.Normal)
        self.saveButton!.addTarget(self, action: #selector(SuperAddressViewController.save(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.saveButton!.hidden = true
        self.saveButton!.alpha = 0
        self.saveButton!.tag = 1
        self.header?.addSubview(self.saveButton!)
        
        self.saveButtonBottom = WMRoundButton()
        self.saveButtonBottom?.setFontTitle(WMFont.fontMyriadProRegularOfSize(13))
        self.saveButtonBottom?.setBackgroundColor(WMColor.green, size: CGSizeMake(98, 34), forUIControlState: UIControlState.Normal)
        self.saveButtonBottom!.setTitle(NSLocalizedString("profile.save", comment:"" ).capitalizedString , forState: UIControlState.Normal)
        self.saveButtonBottom!.addTarget(self, action: #selector(SuperAddressViewController.save(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.saveButtonBottom!.tag = 1
        self.saveButton!.hidden = true
        self.view.addSubview(self.saveButtonBottom!)
        
        if addressId != "" {
            deleteButton = UIButton()
            deleteButton?.addTarget(self, action: #selector(SuperAddressViewController.deleteAddress(_:)), forControlEvents: .TouchUpInside)
            deleteButton!.setImage(UIImage(named: "deleteAddress"), forState: UIControlState.Normal)
            self.header!.addSubview(self.deleteButton!)
        }
        
        self.titleLabel?.text = NSLocalizedString("gr.address.title", comment: "")
        
        scrollForm = TPKeyboardAvoidingScrollView()
        self.scrollForm.scrollDelegate = self
        scrollForm.contentSize = CGSizeMake( self.view.bounds.width, 720)
        if(self.showGRAddressForm){
            sAddredssForm = GRFormSuperAddressView(frame: CGRectMake(0, 0, self.view.bounds.width, 700))
        }else{
            sAddredssForm = FormSuperAddressView(frame: CGRectMake(0, 0, self.view.bounds.width, 700))
        }
        sAddredssForm.delegateFormAdd = self
        sAddredssForm.allAddress = self.allAddress
        scrollForm.addSubview(sAddredssForm)
        self.view.addSubview(scrollForm)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var left : CGFloat = 87
        let bounds = self.view.bounds
        
         if addressId != "" {
            self.deleteButton!.frame = CGRectMake( bounds.maxX - 54, 0 , 54, self.header!.frame.height)
            left = left + 30
        }

        self.saveButton!.frame = CGRectMake(self.view.bounds.maxX - left , 0 , 71, self.header!.frame.height)
        self.titleLabel!.frame = CGRectMake(16, 0, (bounds.width - 32), self.header!.frame.maxY)
        
        sAddredssForm.frame = CGRectMake(0, 0,  self.view.bounds.width, 700)
        scrollForm.contentSize = CGSizeMake( self.view.bounds.width, 720)
        scrollForm.frame = CGRectMake(0, self.header!.frame.maxY, self.view.bounds.width, self.view.frame.height - self.header!.frame.maxY)
        
        if self.showGRAddressForm{
            self.setSaveButtonToBottom()
        }
    }
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        let val = CGSizeMake(self.view.frame.width, 720)
        return val
    }
    
    func textFieldDidBeginEditing(sender: UITextField!) {
        
    }
    
    
    
    func changeTitleLabel(){
        UIView.animateWithDuration(0.4, animations: {
            self.saveButton!.alpha = 1.0
            if self.addressId != "" {
                self.titleLabel!.frame = CGRectMake(37 , 0, self.titleLabel!.frame.width , self.header!.frame.maxY)
                self.titleLabel!.textAlignment = .Left
            }
            }, completion: {(bool : Bool) in
                if bool {
                    self.saveButton!.alpha = 1.0
                }
        })
    }
    
    func showUpdate() {
        self.saveButton!.alpha = 1.0
        self.saveButton!.hidden = false
        self.sAddredssForm.removeErrorLog()
        if !self.showGRAddressForm {
            self.changeTitleLabel()
        }
    }
    
    func textModify(sender: UITextField!) {
        if self.saveButton!.hidden {
            self.saveButton!.hidden = false
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

    func save(sender:UIButton) {
        
        self.view.endEditing(true)
        let service = GRAddressAddService()
        let dictSend = sAddredssForm.getAddressDictionary(self.addressId, delete:false)
        if dictSend != nil {
            self.view.endEditing(true)
            self.scrollForm.resignFirstResponder()
            if showGRAddressForm{
                self.saveButton!.hidden = true
                self.alertView = IPOWMAlertViewController.showAlert(self, imageWaiting: UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            }
            else{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            }
            let address = ["storeID":dictSend!["StoreID"]!,"storeName":dictSend!["storeName"]!,"zipCode":dictSend!["ZipCode"]!,"addressID":dictSend!["AddressID"]!] as NSDictionary
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:NSDictionary) -> Void  in
                print("Se realizao la direccion")
                self.navigationController?.popViewControllerAnimated(true)
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
        scrollForm.frame = CGRectMake(0, self.header!.frame.maxY, self.view.bounds.width, self.view.frame.height - self.header!.frame.height - 60)
        self.saveButtonBottom!.frame = CGRectMake((self.view.frame.width/2) - 49 ,scrollForm.frame.maxY + 15, 98, 34)
        let line: CALayer = CALayer()
        line.frame = CGRectMake(0.0, scrollForm.frame.maxY, self.view.bounds.width,1.0)
        line.backgroundColor = WMColor.light_light_gray.CGColor
        self.view.layer.insertSublayer(line, atIndex: 0)
        self.saveButton!.removeFromSuperview()
        self.saveButtonBottom!.hidden = false
    }
    
    func setValues(addressId:NSString) {
        self.addressId = addressId as String
        self.viewLoad = WMLoadingView(frame: self.view.bounds)
        self.viewLoad.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(viewLoad)
        self.viewLoad.startAnnimating(true)

        let serviceAddress = GRAddressesByIDService()
        serviceAddress.addressId = addressId as String
        serviceAddress.callService([:], successBlock: { (result:NSDictionary) -> Void in
          
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
    
    func deleteAddress(sender:UIButton){
        
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
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:NSDictionary) -> Void  in
                print("Se realizao la direccion")
                self.navigationController?.popViewControllerAnimated(true)
                if let message = resultCall["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                    let serviceAddress = GRAddressesByIDService()
                    serviceAddress.addressId = resultCall["addressID"] as? String
                    serviceAddress.callService([:], successBlock: { (result:NSDictionary) -> Void in
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