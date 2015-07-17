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
    var saveButton: UIButton?
    var deleteButton: UIButton?
    var addressId: String! = ""
    var sAddredssForm : FormSuperAddressView!
    var viewLoad : WMLoadingView!
    var alertView : IPOWMAlertViewController? = nil
    var allAddress: NSArray! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.GR_SCREEN_ADDRESSESDETAIL.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build())
        }
        
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let iconImage = UIImage(named:"button_bg")
        let iconSelected = UIImage(named:"button_bg_active")
        
        self.saveButton = UIButton()
        self.saveButton!.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:"" ) , forState: UIControlState.Normal)
        self.saveButton!.tintColor = WMColor.navigationFilterTextColor
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        self.saveButton!.titleLabel!.textColor = WMColor.navigationFilterTextColor
        self.saveButton!.setImage(iconImage, forState: UIControlState.Normal)
        self.saveButton!.setImage(iconSelected, forState: UIControlState.Highlighted)
        self.saveButton!.titleEdgeInsets = UIEdgeInsetsMake(2.0, -iconImage!.size.width + 1, 0, 0.0);
        self.saveButton!.imageEdgeInsets = UIEdgeInsetsMake(0, (77 - iconImage!.size.width)/2 , 0.0, 0.0)
        self.saveButton!.titleLabel!.frame = self.saveButton!.frame
        self.saveButton!.hidden = true
        self.saveButton!.alpha = 0
        self.saveButton!.tag = 1
        self.header?.addSubview(self.saveButton!)
        
        if addressId != "" {
            deleteButton = UIButton()
            deleteButton?.addTarget(self, action: "deleteAddress:", forControlEvents: .TouchUpInside)
            deleteButton!.setImage(UIImage(named: "deleteAddress"), forState: UIControlState.Normal)
            self.header!.addSubview(self.deleteButton!)
        }
        
        self.titleLabel?.text = NSLocalizedString("gr.address.title", comment: "")
        
        scrollForm = TPKeyboardAvoidingScrollView()
        self.scrollForm.scrollDelegate = self
        scrollForm.contentSize = CGSizeMake( self.view.bounds.width, 720)
        
        sAddredssForm = FormSuperAddressView(frame: CGRectMake(0, 0, self.view.bounds.width, 700))
        sAddredssForm.delegateFormAdd = self
        sAddredssForm.allAddress = self.allAddress
        
        scrollForm.addSubview(sAddredssForm)
        self.view.addSubview(scrollForm)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var left : CGFloat = 87
        var bounds = self.view.bounds
        
         if addressId != "" {
            self.deleteButton!.frame = CGRectMake( bounds.maxX - 54, 0 , 54, self.header!.frame.height)
            left = left + 54
        }

        self.saveButton!.frame = CGRectMake(self.view.bounds.maxX - left , 0 , 87, self.header!.frame.height)
        self.titleLabel!.frame = CGRectMake(87, 0, (bounds.width - self.saveButton!.frame.width * 2), self.header!.frame.maxY)
        
        sAddredssForm.frame = CGRectMake(0, 0,  self.view.bounds.width, 700)
        scrollForm.contentSize = CGSizeMake( self.view.bounds.width, 720)
        scrollForm.frame = CGRectMake(0, self.header!.frame.maxY, self.view.bounds.width, self.view.frame.height - self.header!.frame.maxY)

    }
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        var val = CGSizeMake(self.view.frame.width, 720)
        return val
    }
    
    func textFieldDidBeginEditing(sender: UITextField!) {
        
    }
    
    func textFieldDidEndEditing(sender: UITextField!) {
        
    }
    
    func textModify(sender: UITextField!) {
        if self.saveButton!.hidden {
            self.saveButton!.hidden = false
            self.sAddredssForm.removeErrorLog()
            UIView.animateWithDuration(0.4, animations: {
                self.saveButton!.alpha = 1.0
                if self.addressId != "" {
                    self.titleLabel!.frame = CGRectMake(46 , 0, self.titleLabel!.frame.width - 13, self.header!.frame.maxY)
                }
                }, completion: {(bool : Bool) in
                    if bool {
                        self.saveButton!.alpha = 1.0
                    }
            })
        }
    }
    
    func showUpdate() {
        self.saveButton!.alpha = 1.0
        self.saveButton!.hidden = false
        self.sAddredssForm.removeErrorLog()
    }
    
    func save(sender:UIButton) {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_SCREEN_ADDRESSES.rawValue,
                action: WMGAIUtils.EVENT_PROFILE_MYADDRESSES_CREATE_GR.rawValue,
                label: "", value: nil).build())
        }
        
        let service = GRAddressAddService()
        let dictSend = sAddredssForm.getAddressDictionary(self.addressId, delete:false)
        if dictSend != nil {
            self.view.endEditing(true)
            self.scrollForm.resignFirstResponder()
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:NSDictionary) -> Void  in
                println("Se realizao la direccion")
                self.navigationController?.popViewControllerAnimated(true)
                if let message = resultCall["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                }
                self.alertView!.showDoneIcon()
                }) { (error:NSError) -> Void in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            }
        }
    }
    
    func setValues(addressId:NSString) {
        self.addressId = addressId
        self.viewLoad = WMLoadingView(frame: self.view.bounds)
        self.viewLoad.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(viewLoad)
        self.viewLoad.startAnnimating(true)

        let serviceAddress = GRAddressesByIDService()
        serviceAddress.addressId = addressId
        serviceAddress.callService([:], successBlock: { (result:NSDictionary) -> Void in
          
            if self.viewLoad != nil{
                self.viewLoad.stopAnnimating()
            }
            self.viewLoad = nil
            self.titleLabel?.text = result["name"] as String!
            self.sAddredssForm.addressName.text = result["name"] as String!
            self.sAddredssForm.outdoornumber.text = result["outerNumber"] as String!
            self.sAddredssForm.indoornumber.text = result["innerNumber"] as String!
            self.sAddredssForm.betweenFisrt.text = result["reference1"] as String!
            self.sAddredssForm.betweenSecond.text = result["reference2"] as String!
            self.sAddredssForm.zipcode.text = result["zipCode"] as String!
            self.sAddredssForm.street.text = result["street"] as String!
            //self.sAddredssForm.defaultPrefered = result["prefered"] as String
            //self.sAddredssForm.defaultPrefered = false
            let neighborhoodID = result["neighborhoodID"] as String!
            let storeID = result["storeID"] as String!
            self.sAddredssForm.setZipCodeAnfFillFields(self.sAddredssForm.zipcode.text, neighborhoodID: neighborhoodID, storeID: storeID)
            }) { (error:NSError) -> Void in
        }
    }
    
    func deleteAddress(sender:UIButton){
        
        let service = GRAddressAddService()
        let dictSend = sAddredssForm.getAddressDictionary(self.addressId, delete:true)
        if dictSend != nil {
            self.view.endEditing(true)
            self.scrollForm.resignFirstResponder()
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(NSLocalizedString("profile.message.delete",comment:""))
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:NSDictionary) -> Void  in
                println("Se realizao la direccion")
                self.navigationController?.popViewControllerAnimated(true)
                if let message = resultCall["message"] as? String {
                    self.alertView!.setMessage("\(message)")
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