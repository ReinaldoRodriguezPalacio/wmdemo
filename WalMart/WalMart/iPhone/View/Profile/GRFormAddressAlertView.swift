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
    var beforeAddAddress :  ((dictSend:NSDictionary?) -> Void)? = nil
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
        
        self.backgroundColor = UIColor.clearColor()
        
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        
        let viewButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        viewButton.addTarget(self, action: "closeAlertButton", forControlEvents: UIControlEvents.TouchUpInside)
        viewButton.setImage(UIImage(named: "detail_close"), forState: UIControlState.Normal)
    
        
        viewContent = UIView(frame: CGRectMake(8, 40, self.frame.width - 16, self.frame.height - 80))
        viewContent.layer.cornerRadius = 6.0
        viewContent.backgroundColor = UIColor.whiteColor()
        viewContent.clipsToBounds = true
        
        headerView = UIView(frame: CGRectMake(0, 0, viewContent.frame.width, 46))
        headerView.backgroundColor = WMColor.navigationHeaderBgColor
        viewContent.addSubview(headerView)
        
        titleLabel = UILabel(frame: CGRectMake(40,0, headerView.bounds.width - 120 , headerView.bounds.height))
        titleLabel.textColor =  WMColor.navigationTilteTextColor
        titleLabel.textAlignment = .Center
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.numberOfLines = 2
        titleLabel.text = "Es necesario capturar una dirección"
        
        headerView.addSubview(titleLabel)
        
        viewContentOptions = UIView(frame: CGRectMake(0, headerView.frame.height, viewContent.frame.width, viewContent.frame.height))
        
        self.buttonRight = WMRoundButton() // UIButton(frame:CGRectZero)
        self.buttonRight!.setBackgroundColor(WMColor.green, size: CGSizeMake(71, 22), forUIControlState: UIControlState.Normal)
//        self.buttonRight!.setBackgroundImage(UIImage(named:"button_bg"), forState: .Normal)
//        self.buttonRight!.setBackgroundImage(UIImage(named:"button_bg_active"), forState: .Selected)
        self.buttonRight.setTitle(NSLocalizedString("profile.save", comment: ""), forState: UIControlState.Normal)
        self.buttonRight.titleLabel?.textColor = UIColor.whiteColor()
        //self.buttonRight.backgroundColor =   WMColor.badgeTextColor
        self.buttonRight!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        //self.buttonRight!.setTitleColor(WMColor.badgeTextColor, forState: .Normal)
        self.buttonRight!.setTitleColor(WMColor.navigationFilterTextColor, forState: .Normal)
        self.buttonRight.addTarget(self, action: "newItemForm", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonRight.frame = CGRectMake(self.headerView.frame.width - 80, 12, 64, 22)

        
        scrollForm = TPKeyboardAvoidingScrollView()
        self.scrollForm.scrollDelegate = self
        self.scrollForm.frame = viewContentOptions.bounds
        self.scrollForm.contentSize = CGSizeMake(self.viewContent.frame.width, 720)

        
        sAddredssForm = FormSuperAddressView(frame: CGRectMake(viewContentOptions.bounds.minX , viewContentOptions.bounds.minY, viewContentOptions.bounds.width, 720))
       //     viewContentOptions.bounds)
        sAddredssForm.store!.isRequired = false
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
        headerView.frame = CGRectMake(0, 0, viewContent.frame.width, 46)
        
        titleLabel.frame = CGRectMake(headerView.frame.minX + 20 , headerView.frame.minY, headerView.frame.width - 100, headerView.frame.height)
        buttonRight.frame = CGRectMake(self.viewContent.frame.width - 80, 12, 64, 22)
        if buttonRight != nil  {
            buttonRight.frame = CGRectMake(self.viewContent.frame.width - 80, 12, 64, 22)
            buttonRight.layer.cornerRadius =  11
        }
        
    }
    
    
    
    func closeAlertButton() {
        //closePicker()
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_NEW_ADDRESS_AUTH.rawValue, action:WMGAIUtils.ACTION_CANCEL.rawValue , label: "")
        cancelPress?()
    }
    
    func closePicker() {
        alertClose?()
        self.removeFromSuperview()
    }
    
    
    //MARK Show alerts
    
    class func initAddressAlert()  -> GRFormAddressAlertView? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        //var frame = vc!.view.bounds
        if vc != nil {
            return initAddressAlert(vc!)
        }
        return nil
    }
    
    class func initAddressAlert(controller:UIViewController) -> GRFormAddressAlertView? {
        let newAlert = GRFormAddressAlertView(frame:controller.view.bounds)
        controller.view.addSubview(newAlert)
        newAlert.startAnimating()
        return newAlert
    }
    
    class func initAddressAlertWithDefault() -> GRFormAddressAlertView {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let newAlert = GRFormAddressAlertView(frame:vc!.view.bounds)
        return newAlert
    }
    
    func showAddressAlert() {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        vc!.view.addSubview(self)
        self.startAnimating()
    }
    
    
    //MARK: Animated
    
    func startAnimating() {
        
        
        let imgBgView = UIImageView(frame: self.bgView.bounds)
        let imgBack = UIImage(fromView: self.superview!)
        let imgBackBlur = imgBack.applyLightEffect()
        imgBgView.image = imgBackBlur
        self.bgView.addSubview(imgBgView)
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = WMColor.UIColorFromRGB(0x000000, alpha: 0.6)
        self.bgView.addSubview(bgViewAlpha)
        
       
        bgView.alpha = 0
        viewContent.transform = CGAffineTransformMakeTranslation(0,500)
        
        UIView.animateKeyframesWithDuration(0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeCubicPaced, animations: { () -> Void in
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 1.0
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.viewContent.transform = CGAffineTransformIdentity
            })
            
            }) { (complete:Bool) -> Void in
                
        }
        
    }
    
    override func removeFromSuperview() {
        UIView.animateKeyframesWithDuration(0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModePaced, animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 0.0
            })
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.viewContent.transform = CGAffineTransformMakeTranslation(0,500)
            })
            }) { (complete:Bool) -> Void in
                self.removeComplete()
        }
    }
    
    func removeComplete(){
        super.removeFromSuperview()
    }

    // TPKeyboardAvoidingScrollViewDelegate
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        return  CGSizeMake(self.viewContent.frame.width, 720)
    }
    
    func textFieldDidBeginEditing(sender: UITextField!) {
        
    }
    
    func textFieldDidEndEditing(sender: UITextField!) {
        
    }
    
    func textModify(sender: UITextField!) {
//        if self.saveButton!.hidden {
//            self.saveButton!.hidden = false
//            self.sAddredssForm.removeErrorLog()
//            UIView.animateWithDuration(0.4, animations: {
//                self.saveButton!.alpha = 1.0
//                if self.addressId != "" {
//                    self.titleLabel!.frame = CGRectMake(46 , 0, self.titleLabel!.frame.width - 13, self.header!.frame.maxY)
//                }
//                }, completion: {(bool : Bool) in
//                    if bool {
//                        self.saveButton!.alpha = 1.0
//                    }
//            })
//        }
    }
    
    
    func showUpdate() {
        
    }
    
    func newItemForm() {
        let dictSend = sAddredssForm.getAddressDictionary("", delete:false,preferred:true)
        if dictSend != nil {
            if self.beforeAddAddress == nil {
                self.registryAddress(dictSend)
            } else {
                self.beforeAddAddress?(dictSend: dictSend)
        }
        }
        
        self.sAddredssForm.endEditing(true)
    }

    
    func registryAddress(dictSend:NSDictionary?) {
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_NEW_ADDRESS_AUTH.rawValue, action:WMGAIUtils.ACTION_SAVE_NEW_ADDRESS.rawValue , label: "")
        
        
        if dictSend != nil {
            let service = GRAddressAddService()
            let dictSend = sAddredssForm.getAddressDictionary("", delete:false,preferred:true)
            self.scrollForm.resignFirstResponder()
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(NSLocalizedString("profile.message.save",comment:""))
            service.callService(requestParams: dictSend!, successBlock: { (resultCall:NSDictionary) -> Void  in
                print("Se realizo la direccion")
                if let message = resultCall["message"] as? String {
                    self.alertView!.setMessage("\(message)")
                }
                self.alertView!.showDoneIcon()
                
                self.alertSaveSuccess?()
                }) { (error:NSError) -> Void in
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
            }
        }

    }
    
    func setData(addressPreferred:NSDictionary) {
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