//
//  GRFormAddressAlertView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 3/6/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class GRFormAddressAlertView : UIView, TPKeyboardAvoidingScrollViewDelegate,FormSuperAddressViewDelegate {
    
    
    var itemsToShow : [String] = []
    
    var viewContent : UIView!
    var viewContentOptions : UIView!
    var viewHeader: UIView!
    var titleLabel : UILabel!
    var bgView : UIView!
    var headerView : UIView!
    
    var sender : AnyObject? = nil
    
    var viewButtonClose : UIButton!
    var buttonRight : WMRoundButton!
    var viewReplace : UIView!
    
    var scrollForm : TPKeyboardAvoidingScrollView!
    var sAddredssForm : FormSuperAddressView!
    var alertView : IPOWMAlertViewController? = nil
    
    
    var alertSaveSuccess : (() -> Void)? = nil
    var alertClose : (() -> Void)? = nil
    var cancelPress : (() -> Void)? = nil
    var beforeAddAddress :  ((_ dictSend:[String:Any]?) -> Void)? = nil
    var showMessageCP : (() -> Void)? = nil
    
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    func setup() {
        
        self.backgroundColor = UIColor.clear
        
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        
        let viewButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        viewButton.addTarget(self, action: #selector(GRFormAddressAlertView.closeAlertButton), for: UIControlEvents.touchUpInside)
        viewButton.setImage(UIImage(named: "detail_close"), for: UIControlState())
    
        
        viewContent = UIView(frame: CGRect(x: 8, y: 40, width: self.frame.width - 16, height: self.frame.height - 80))
        viewContent.layer.cornerRadius = 6.0
        viewContent.backgroundColor = UIColor.white
        viewContent.clipsToBounds = true
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: viewContent.frame.width, height: 46))
        headerView.backgroundColor = WMColor.light_light_gray
        viewContent.addSubview(headerView)
        
        titleLabel = UILabel(frame: CGRect(x: 40,y: 0, width: headerView.bounds.width - 120 , height: headerView.bounds.height))
        titleLabel.textColor =  WMColor.light_blue
        titleLabel.textAlignment = .center
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.numberOfLines = 2
        titleLabel.text = "Es necesario capturar una dirección"
        
        headerView.addSubview(titleLabel)
        
        viewContentOptions = UIView(frame: CGRect(x: 0, y: headerView.frame.height, width: viewContent.frame.width, height: viewContent.frame.height))
        
        self.buttonRight = WMRoundButton()
        self.buttonRight!.setBackgroundColor(WMColor.green, size: CGSize(width: 71, height: 22), forUIControlState: UIControlState())
        self.buttonRight.setTitle(NSLocalizedString("profile.save", comment: ""), for: UIControlState())
        self.buttonRight.titleLabel?.textColor = UIColor.white
        self.buttonRight!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.buttonRight!.setTitleColor(UIColor.white, for: UIControlState())
        self.buttonRight.addTarget(self, action: #selector(GRFormAddressAlertView.newItemForm), for: UIControlEvents.touchUpInside)
        self.buttonRight.frame = CGRect(x: self.headerView.frame.width - 80, y: 12, width: 64, height: 22)

        
        scrollForm = TPKeyboardAvoidingScrollView()
        self.scrollForm.scrollDelegate = self
        self.scrollForm.frame = viewContentOptions.bounds
        self.scrollForm.contentSize = CGSize(width: self.viewContent.frame.width, height: 720)

        
        sAddredssForm = FormSuperAddressView(frame: CGRect(x: viewContentOptions.bounds.minX , y: viewContentOptions.bounds.minY, width: viewContentOptions.bounds.width, height: 720))
       //     viewContentOptions.bounds)
        sAddredssForm.store!.isRequired = true
        sAddredssForm.suburb.isRequired =  true
        sAddredssForm.store!.setCustomPlaceholder(NSLocalizedString("gr.address.field.store",comment:""))
        sAddredssForm.delegateFormAdd = self
        scrollForm.addSubview(sAddredssForm)
        viewContentOptions.addSubview(scrollForm)
        
        
        self.viewContent.addSubview(self.viewContentOptions)
        self.headerView.addSubview(viewButton)
        self.headerView.addSubview(buttonRight)
        self.addSubview(viewContent)
        
        
    }
    
    override func layoutSubviews() {
        viewContent.center = self.center
        self.scrollForm.frame = viewContentOptions.bounds
        headerView.frame = CGRect(x: 0, y: 0, width: viewContent.frame.width, height: 46)
        
        titleLabel.frame = CGRect(x: headerView.frame.minX + 20 , y: headerView.frame.minY, width: headerView.frame.width - 100, height: headerView.frame.height)
        buttonRight.frame = CGRect(x: self.viewContent.frame.width - 80, y: 12, width: 64, height: 22)
        if buttonRight != nil  {
            buttonRight.frame = CGRect(x: self.viewContent.frame.width - 80, y: 12, width: 64, height: 22)
            buttonRight.layer.cornerRadius =  11
        }
        
    }
    
    
    
    func closeAlertButton() {
        //closePicker()
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_NEW_ADDRESS_AUTH.rawValue, action:WMGAIUtils.ACTION_CANCEL.rawValue , label: "")
        cancelPress?()
    }
    
    func closePicker() {
        alertClose?()
        self.removeFromSuperview()
    }
    
    
    //MARK Show alerts
    
    class func initAddressAlert()  -> GRFormAddressAlertView? {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        //var frame = vc!.view.bounds
        if vc != nil {
            return initAddressAlert(vc!)
        }
        return nil
    }
    
    class func initAddressAlert(_ controller:UIViewController) -> GRFormAddressAlertView? {
        let newAlert = GRFormAddressAlertView(frame:controller.view.bounds)
        controller.view.addSubview(newAlert)
        newAlert.startAnimating()
        return newAlert
    }
    
    class func initAddressAlertWithDefault() -> GRFormAddressAlertView {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        let newAlert = GRFormAddressAlertView(frame:vc!.view.bounds)
        return newAlert
    }
    
    func showAddressAlert() {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        vc!.view.addSubview(self)
        self.startAnimating()
    }
    
    
    //MARK: Animated
    
    func startAnimating() {
        
        
        let imgBgView = UIImageView(frame: self.bgView.bounds)
        let imgBack = UIImage(from: self.superview!)
        let imgBackBlur = imgBack?.applyLightEffect()
        imgBgView.image = imgBackBlur
        self.bgView.addSubview(imgBgView)
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.bgView.addSubview(bgViewAlpha)
        
       
        bgView.alpha = 0
        viewContent.transform = CGAffineTransform(translationX: 0,y: 500)
        
        UIView.animateKeyframes(withDuration: 0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.calculationModeCubicPaced, animations: { () -> Void in
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.viewContent.transform = CGAffineTransform.identity
            })
            
            }) { (complete:Bool) -> Void in
                
        }
        
    }
    
    override func removeFromSuperview() {
        UIView.animateKeyframes(withDuration: 0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.calculationModePaced, animations: { () -> Void in
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 0.0
            })
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.viewContent.transform = CGAffineTransform(translationX: 0,y: 500)
            })
            }) { (complete:Bool) -> Void in
                self.removeComplete()
        }
    }
    
    func removeComplete(){
        super.removeFromSuperview()
    }

    // TPKeyboardAvoidingScrollViewDelegate
    func contentSizeForScrollView(_ sender:Any) -> CGSize {
        return  CGSize(width: self.viewContent.frame.width, height: 720)
    }
    
    func textFieldDidBeginEditing(_ sender: UITextField!) {
        
    }
    
    func textFieldDidEndEditing(_ sender: UITextField!) {
        if let zipCode = sender as? FormFieldView{
            if zipCode.nameField == NSLocalizedString("gr.address.field.zipcode",comment:"") && zipCode.text! != self.sAddredssForm.currentZipCode &&  zipCode.text!.characters.count == 5{
                let _ = self.sAddredssForm.store.becomeFirstResponder()
            }
        }
    }
    
    func textModify(_ sender: UITextField!) {
        if let zipCode = sender as? FormFieldView{
            if zipCode.nameField == NSLocalizedString("gr.address.field.zipcode",comment:"") && zipCode.text! != self.sAddredssForm.currentZipCode {
                self.sAddredssForm.suburb!.text = ""
                self.sAddredssForm.selectedNeighborhood = nil
                self.sAddredssForm.store!.text = ""
                self.sAddredssForm.selectedStore = nil
            }
            if zipCode.nameField == NSLocalizedString("gr.address.field.zipcode",comment:"") && zipCode.text! != self.sAddredssForm!.currentZipCode &&  zipCode.text!.characters.count == 5{
                if self.sAddredssForm!.zipcode.text!.utf16.count > 0 {
                    let xipStr = self.sAddredssForm!.zipcode.text! as NSString
                    let textZipcode = String(format: "%05d",xipStr.integerValue)
                    self.sAddredssForm!.zipcode.text = textZipcode.substring(to: textZipcode.characters.index(textZipcode.startIndex, offsetBy: 5))
                    let _ = self.sAddredssForm!.store.becomeFirstResponder()
                }
            }
        }

    }


    func showUpdate() {
        
    }
    
    func newItemForm() {
        let dictSend = sAddredssForm.getAddressDictionary("", delete:false,preferred:true)
        if dictSend != nil {
            if self.beforeAddAddress == nil {
                self.registryAddress(dictSend)
            } else {
                self.beforeAddAddress?(dictSend)
        }
        }
        
        self.sAddredssForm.endEditing(true)
    }

    
    func registryAddress(_ dictSend:[String:Any]?) {
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_NEW_ADDRESS_AUTH.rawValue, action:WMGAIUtils.ACTION_SAVE_NEW_ADDRESS.rawValue , label: "")
        
        if dictSend != nil {
            let service = GRAddressAddService()
            let dictSend = sAddredssForm.getAddressDictionary("", delete:false,preferred:true)
            self.scrollForm.resignFirstResponder()
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:[String:Any]) -> Void  in
                print("Se realizo la direccion")
                if let message = resultCall["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                }
                self.alertView!.showDoneIcon()
                
                self.alertSaveSuccess?()
                }) { (error:NSError) -> Void in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
                    BaseController.sendAnalyticsUnsuccesfulRegistrationWithError(error.localizedDescription, stepError: "Direcciones")
            }
        }

    }
    
    func setData(_ addressPreferred:[String:Any]) {
        self.sAddredssForm.addressName.text = addressPreferred["name"] as! String!
        self.sAddredssForm.outdoornumber.text = addressPreferred["outerNumber"] as! String!
        self.sAddredssForm.indoornumber.text = addressPreferred["innerNumber"] as! String!
        self.sAddredssForm.zipcode.text = addressPreferred["zipCode"] as! String!
        self.sAddredssForm.street.text = addressPreferred["street"] as! String!
        self.sAddredssForm.setZipCodeAnfFillFields(self.sAddredssForm.zipcode.text!, neighborhoodID: "", storeID: "")
    }
    
    
    func showNoCPWarning() {
        self.showMessageCP?()
    }
}
