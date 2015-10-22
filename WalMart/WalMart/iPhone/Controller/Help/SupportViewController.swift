//
//  SupportViewController.swift
//  WalMart
//
//  Created by ISOL Ingenieria de Soluciones on 05/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import MessageUI

    let EMAIL_GROSERIES = "Atencionaclientes@wal-mart.com"
    let EMAIL_MG = "Atencionaclientes@wal-mart.com"
    let PHONE_SUPPORT = "01800 925 6278"

class SupportViewController :  NavigationViewController, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, AlertPickerViewDelegate, MFMailComposeViewControllerDelegate{
    
    var imgConfirm : UIImageView!
    var labelQuestion1 : UILabel!
    var labelQuestion2 : UILabel!
    
    var callme : UILabel!
    var callmeNumber : UILabel!
    
    var sendmeMail : UILabel!
    
    var buttomCall : UIButton!
    var buttomMail : UIButton!
    //var picker : AlertPickerView!
    var stores : [String]! = []
    var suportHelp : FormFieldView?
    var selectedType : NSIndexPath!
    
    var paymentOptionsPicker: UIPickerView?
    var scrollForm : TPKeyboardAvoidingScrollView!
    
    var pikerBtn : AlertButtomView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //picker = AlertPickerView.initPickerWithDefault()
        pikerBtn = AlertButtomView.initPickerWithDefault()
        
        
        self.titleLabel!.text = NSLocalizedString("moreoptions.title.Contact", comment: "")
        self.imgConfirm = UIImageView()
        self.labelQuestion1 = UILabel()
        self.labelQuestion2 = UILabel()
        self.callme = UILabel()
        self.callmeNumber = UILabel()
        
        self.sendmeMail = UILabel()
        
        
        self.buttomCall = UIButton()
        self.buttomMail = UIButton()
        
        imgConfirm.image = UIImage(named: "support-bg")
        
        let attrStringLab = NSAttributedString(string:NSLocalizedString("help.buttom.title.callto", comment: ""),
            attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(14),
                NSForegroundColorAttributeName:WMColor.loginProfileSaveBGColor])
        
        let attrStringVal = NSAttributedString(string:PHONE_SUPPORT,
            attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(14),
                NSForegroundColorAttributeName:WMColor.loginProfileSaveBGColor])
        
        let valuesDescItem = NSMutableAttributedString()
        valuesDescItem.appendAttributedString(attrStringLab)
         valuesDescItem.appendAttributedString(attrStringVal)
        
        self.labelQuestion1.text = NSLocalizedString("Support.label.question.comment" , comment: "")
        self.labelQuestion2.attributedText = valuesDescItem
        
        self.callme.text = NSLocalizedString("help.buttom.title.call" , comment: "")
        
        self.callmeNumber.text = PHONE_SUPPORT
        
        self.sendmeMail.text = NSLocalizedString("help.buttom.title.text" , comment: "")
        
        
        self.labelQuestion1!.font = WMFont.fontMyriadProLightOfSize(14)
        self.labelQuestion1!.textColor = WMColor.loginProfileSaveBGColor
        self.labelQuestion1!.backgroundColor = UIColor.clearColor()
        self.labelQuestion1!.textAlignment = .Center
        
        self.labelQuestion2!.font = WMFont.fontMyriadProLightOfSize(14)
        self.labelQuestion2!.textColor = WMColor.loginProfileSaveBGColor
        self.labelQuestion2!.backgroundColor = UIColor.clearColor()
        self.labelQuestion2!.textAlignment = .Center
        
        self.callme!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.callme!.textColor = WMColor.listAddressTextColor
        self.callme!.backgroundColor = UIColor.clearColor()
        self.callme!.textAlignment = .Center
        
        self.callmeNumber!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.callmeNumber!.textColor = WMColor.listAddressTextColor
        self.callmeNumber!.backgroundColor = UIColor.clearColor()
        self.callmeNumber!.textAlignment = .Center
        
        self.sendmeMail!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.sendmeMail!.textColor = WMColor.listAddressTextColor
        self.sendmeMail!.backgroundColor = UIColor.clearColor()
        self.sendmeMail!.textAlignment = .Center
        
        
        self.buttomCall.setImage(UIImage(named:"support-call"), forState: UIControlState.Normal)
        self.buttomCall.setImage(UIImage(named:"support-call."), forState: UIControlState.Selected)
        self.buttomCall.addTarget(self , action: "selectecButton:", forControlEvents:UIControlEvents.TouchUpInside)
        self.buttomCall.backgroundColor = UIColor.clearColor()
        
        self.buttomMail.setImage(UIImage(named:"support-email"), forState: UIControlState.Normal)
        self.buttomMail.setImage(UIImage(named:"support-email"), forState: UIControlState.Selected)
        self.buttomMail.addTarget(self , action: "selectecButton:", forControlEvents:UIControlEvents.TouchUpInside)
        self.buttomMail.backgroundColor = UIColor.clearColor()
      
        self.view.addSubview(imgConfirm)
        
        self.view.addSubview(labelQuestion1)
        self.view.addSubview(labelQuestion2)
        self.view.addSubview(buttomCall)
        self.view.addSubview(buttomMail)
        
        self.view.addSubview(callme)
        self.view.addSubview(callmeNumber)
        self.view.addSubview(sendmeMail)
        self.stores = []
        
        self.stores.append(NSLocalizedString("Support.label.list.reason.fail", comment:""))
        self.stores.append(NSLocalizedString("Support.label.list.reason.close", comment:""))
        self.stores.append(NSLocalizedString("Support.label.list.reason.other", comment:""))
        
        //let margin: CGFloat = 15.0
        //var width = self.view.frame.width - (2*margin)
        //var fheight: CGFloat = 44.0
        //var lheight: CGFloat = 25.0
        
        self.selectedType = NSIndexPath(forRow: 0, inSection: 0)
        
        /*self.picker!.selected = self.selectedType
        self.picker!.delegate = self
        self.picker!.setValues(NSLocalizedString("Support.label.title.by", comment:""), values: self.stores)
        */
        
        //self.picker!.selected = self.selectedType
        self.pikerBtn!.delegate = self
        self.pikerBtn!.setValues(NSLocalizedString("Support.label.write.to", comment:""), values: self.stores)
        self.pikerBtn.setNameBtn(NSLocalizedString("Support.label.super", comment:""), titleBtnDown:NSLocalizedString("Support.label.home.more", comment:"") )
        
    
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bounds = self.view.bounds
        self.imgConfirm.frame =  CGRectMake(0,  self.header!.frame.maxY , bounds.width, bounds.height - self.header!.frame.maxY )
        self.labelQuestion1.frame = CGRectMake(0,  self.header!.frame.maxY + 28 , bounds.width, 15 )
        self.labelQuestion2.frame = CGRectMake(0,  self.labelQuestion1.frame.maxY  , bounds.width, 15 )
        
        callmeNumber.frame =  CGRectMake(32 , bounds.maxY - 114 , 130, 15)
        
        callme.frame =  CGRectMake(64 , callmeNumber.frame.midY - 20  , 64, 15)
        sendmeMail.frame =   CGRectMake(callme.frame.maxX + 64 , callmeNumber.frame.midY - 20 , 64, 15)
                
        buttomCall.frame =  CGRectMake(64 , callme.frame.midY - 78 , 64, 64)
        buttomMail.frame =  CGRectMake(buttomCall.frame.maxX + 64 , callme.frame.midY - 78 , 64, 64)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
   
    }
    
    
    func selectecButton(sender:UIButton){
        if sender == self.buttomCall{
            self.buttomMail.selected = false
            print("Selected call", terminator: "")
         if IS_IPHONE == true {
                let strTel = "telprompt://018009256278"
                if UIApplication.sharedApplication().canOpenURL(NSURL(string: strTel)!) {
                    UIApplication.sharedApplication().openURL(NSURL(string: strTel)!)
                }
         }
            
        }else{
            self.buttomCall.selected = false
            self.pikerBtn!.showPicker()
        }
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SUPPORT_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_SUPPORT_NO_AUTH.rawValue , action: sender == self.buttomCall ? WMGAIUtils.ACTION_CALL_SUPPORT.rawValue :WMGAIUtils.ACTION_EMAIL_SUPPORT.rawValue, label:"")
        
    }
    
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.listAddressHeaderSectionColor
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
    
    //Marck: select Picker
    func didSelectOption(picker: AlertPickerView, indexPath: NSIndexPath, selectedStr: String) {
        /*print(selectedStr)
        self.selectedType = indexPath
        self.pikerBtn!.showPicker()*/
    }
    
    func didDeSelectOption(picker: AlertPickerView) {
       
    }
    
    func viewReplaceContent(frame: CGRect) -> UIView! {
        scrollForm = TPKeyboardAvoidingScrollView(frame: frame)
        scrollForm.contentSize = CGSizeMake(frame.width, 600)
        return scrollForm
    }
    
    func saveReplaceViewSelected() {
        
    }
    
    func buttomViewSelected(sender: UIButton) {
        
        let majorVersion =  NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let minorVersion =  NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        let ver  = "(IOS \(UIDevice.currentDevice().systemVersion), V App \(majorVersion) \(minorVersion))"
        let device = UIDevice.currentDevice().model.lowercaseString.uppercaseString
        let status = AFNetworkReachabilityManager.sharedManager().reachableViaWiFi ? "Wifi" : "WWAN"
        
        UIDevice.currentDevice().localizedModel
        
        if sender.tag == 1{//groceries
            print("btn Groceries", terminator: "")

            let subject = "walmart super dispositivo\(ver)"
        
            if  MFMailComposeViewController.canSendMail(){
                let mc: MFMailComposeViewController = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.setSubject(subject)//Titulo de ,correo
                mc.setMessageBody("\n\n\nwalmart super\ndispositivo: IOS \(UIDevice.currentDevice().systemVersion)\nV App: \(majorVersion) \(minorVersion)\nDevice: \(device)\nConectado via: \(status)", isHTML: false)
                mc.setToRecipients([EMAIL_MG])
            
                self.presentViewController(mc, animated: true, completion: nil)
            }
            else{
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noRed"),imageDone: nil, imageError: nil)
                alert!.setMessage("No se encontro una cuenta de correo configurada")
            }
            
        }else
        {
            print("btn MG", terminator: "")
            let subject = "walmart MG dispositivo\(ver)"
               if  MFMailComposeViewController.canSendMail(){
                    let mc: MFMailComposeViewController = MFMailComposeViewController()
                    mc.mailComposeDelegate = self
                    mc.setSubject(subject)//Titulo de ,correo
                    mc.setMessageBody("\n\n\nwalmart MG\ndispositivo: IOS \(UIDevice.currentDevice().systemVersion)\nV App: \(majorVersion) \(minorVersion)\nDevice: \(device)\nConectado via: \(status)", isHTML: false)
                    mc.setToRecipients([EMAIL_MG])
                    self.presentViewController(mc, animated: true, completion: nil)
                }
                else{
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noRed"),imageDone: nil, imageError: nil)
                //alert.setMessage("contact.mail.configure")
                alert!.setMessage("No se encontro una cuenta de correo configurada")
                }
            //}
        }
        
        self.pikerBtn!.closePicker()
    }
    
       //MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
}


