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
    var selectedType : IndexPath!
    
    var paymentOptionsPicker: UIPickerView?
    var scrollForm : TPKeyboardAvoidingScrollView!
    
    var pikerBtn : AlertButtomView!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SUPPORT.rawValue
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //picker = AlertPickerView.initPickerWithDefault()
        pikerBtn = AlertButtomView.initPickerWithDefault()
        
        
        self.titleLabel!.text = NSLocalizedString("moreoptions.title.Contact", comment: "")

        self.imgConfirm  = UIImageView(image: UIImage(named:"support-empty"))
        self.labelQuestion1 = UILabel()
        self.labelQuestion2 = UILabel()
        self.callme = UILabel()
        self.callmeNumber = UILabel()
        
        self.sendmeMail = UILabel()
        
        
        self.buttomCall = UIButton()
        self.buttomMail = UIButton()
        
        
        
        let attrStringLab = NSAttributedString(string:NSLocalizedString("help.buttom.title.callto", comment: ""),
                                               attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(14),
                                                NSForegroundColorAttributeName:WMColor.light_blue])
        
        let attrStringVal = NSAttributedString(string:PHONE_SUPPORT,
                                               attributes: [NSFontAttributeName : WMFont.fontMyriadProBoldOfSize(14),
                                                NSForegroundColorAttributeName:WMColor.light_blue])
        
        self.callme.text = NSLocalizedString("help.buttom.title.call" , comment: "")
        
        self.callmeNumber.text = PHONE_SUPPORT
        
        self.sendmeMail.text = NSLocalizedString("help.buttom.title.text" , comment: "")
        
        
        self.labelQuestion1!.font = WMFont.fontMyriadProLightOfSize(14)
        self.labelQuestion1!.textColor = WMColor.light_blue
        self.labelQuestion1!.backgroundColor = UIColor.clear
        self.labelQuestion1!.textAlignment = .center
        
        self.labelQuestion2!.font = WMFont.fontMyriadProLightOfSize(14)
        self.labelQuestion2!.textColor = WMColor.light_blue
        self.labelQuestion2!.backgroundColor = UIColor.clear
        self.labelQuestion2!.textAlignment = .center
        
        let valuesDescItem = NSMutableAttributedString()
        valuesDescItem.append(attrStringLab)
        valuesDescItem.append(attrStringVal)
        
        self.labelQuestion1.text = NSLocalizedString("Support.label.question.comment" , comment: "")
        self.labelQuestion2.attributedText = valuesDescItem
        
        self.callme!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.callme!.textColor = WMColor.reg_gray
        self.callme!.backgroundColor = UIColor.clear
        self.callme!.textAlignment = .center
        
        self.callmeNumber!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.callmeNumber!.textColor = WMColor.reg_gray
        self.callmeNumber!.backgroundColor = UIColor.clear
        self.callmeNumber!.textAlignment = .center
        
        self.sendmeMail!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.sendmeMail!.textColor = WMColor.reg_gray
        self.sendmeMail!.backgroundColor = UIColor.clear
        self.sendmeMail!.textAlignment = .center
        
        
        self.buttomCall.setImage(UIImage(named:"support-call"), for: UIControlState())
        self.buttomCall.setImage(UIImage(named:"support-call."), for: UIControlState.selected)
        self.buttomCall.addTarget(self , action: #selector(SupportViewController.selectecButton(_:)), for:UIControlEvents.touchUpInside)
        self.buttomCall.backgroundColor = UIColor.clear
        
        self.buttomMail.setImage(UIImage(named:"support-email"), for: UIControlState())
        self.buttomMail.setImage(UIImage(named:"support-email"), for: UIControlState.selected)
        self.buttomMail.addTarget(self , action: #selector(SupportViewController.selectecButton(_:)), for:UIControlEvents.touchUpInside)
        self.buttomMail.backgroundColor = UIColor.clear
      
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
        
        self.selectedType = IndexPath(row: 0, section: 0)
        
        /*self.picker!.selected = self.selectedType
        self.picker!.delegate = self
        self.picker!.setValues(NSLocalizedString("Support.label.title.by", comment:""), values: self.stores)
        */
        
        //self.picker!.selected = self.selectedType
        self.pikerBtn!.delegate = self
        self.pikerBtn!.setValues(NSLocalizedString("Support.label.write.to", comment:"") as NSString, values: self.stores)
        self.pikerBtn.setNameBtn(NSLocalizedString("Support.label.super", comment:"") as NSString, titleBtnDown:NSLocalizedString("Support.label.home.more", comment:"") as NSString )
        
    
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
        self.imgConfirm.frame =  CGRect(x: 0,  y: self.header!.frame.maxY , width: self.imgConfirm.image!.size.width, height: self.imgConfirm.image!.size.height)
        self.labelQuestion1.frame = CGRect(x: 0,  y: self.header!.frame.maxY + 28 , width: bounds.width, height: 15 )
        self.labelQuestion2.frame = CGRect(x: 0,  y: self.labelQuestion1.frame.maxY  , width: bounds.width, height: 15 )
        
        if IS_IPHONE {
            let referenceHeight = IS_IPHONE_4_OR_LESS ? bounds.midY + 30 : bounds.midY
            callmeNumber.frame =  CGRect(x: 32 , y: referenceHeight + 120 , width: 131, height: 15)
            callme.frame =  CGRect(x: 64 , y: referenceHeight + 106  , width: 64, height: 15)
            sendmeMail.frame =   CGRect(x: callme.frame.maxX + 67 , y: referenceHeight + 106 , width: 64, height: 15)
            buttomCall.frame =  CGRect(x: 64 , y: referenceHeight + 40 , width: 64, height: 64)
            buttomMail.frame =  CGRect(x: buttomCall.frame.maxX + 64 , y: referenceHeight + 40 , width: 64, height: 64)
        }else{
            callmeNumber.isHidden = true
            callme.isHidden = true
            buttomCall.isHidden = true
            sendmeMail.frame =  CGRect(x: (bounds.width - 64) / 2 , y: bounds.maxY - 134 , width: 64, height: 15)
            buttomMail.frame =  CGRect(x: (bounds.width - 64) / 2 , y: sendmeMail.frame.midY - 78 , width: 64, height: 64)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
    }
    
    
    func selectecButton(_ sender:UIButton){
        if sender == self.buttomCall{
            self.buttomMail.isSelected = false
            print("Selected call", terminator: "")
         if IS_IPHONE == true {
                let strTel = "telprompt://018009256278"
                if UIApplication.shared.canOpenURL(URL(string: strTel)!) {
                    UIApplication.shared.openURL(URL(string: strTel)!)
                }
         }
            
        }else{
            self.buttomCall.isSelected = false
            self.pikerBtn!.showPicker()
        }
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SUPPORT_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_SUPPORT_NO_AUTH.rawValue , action: sender == self.buttomCall ? WMGAIUtils.ACTION_CALL_SUPPORT.rawValue :WMGAIUtils.ACTION_EMAIL_SUPPORT.rawValue, label:"")
        
    }
    
    func buildSectionTitle(_ title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.white
        return sectionTitle
    }
    
    //Marck: select Picker
    func didSelectOption(_ picker: AlertPickerView, indexPath: IndexPath, selectedStr: String) {
        /*print(selectedStr)
        self.selectedType = indexPath
        self.pikerBtn!.showPicker()*/
    }
    
    func didDeSelectOption(_ picker: AlertPickerView) {
       
    }
    
    func viewReplaceContent(_ frame: CGRect) -> UIView! {
        scrollForm = TPKeyboardAvoidingScrollView(frame: frame)
        scrollForm.contentSize = CGSize(width: frame.width, height: 600)
        return scrollForm
    }
    
    func saveReplaceViewSelected() {
        
    }
    
    func buttomViewSelected(_ sender: UIButton) {
        
        let majorVersion =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let minorVersion =  Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let ver  = "(IOS \(UIDevice.current.systemVersion), V App \(majorVersion) \(minorVersion))"
        let device = UIDevice.current.model.lowercased().uppercased()
        let status = AFNetworkReachabilityManager.shared().isReachableViaWiFi ? "Wifi" : "WWAN"
        
        UIDevice.current.localizedModel
        
        if sender.tag == 1{//groceries
            print("btn Groceries", terminator: "")

            let subject = "walmart super dispositivo\(ver)"
        
            if  MFMailComposeViewController.canSendMail(){
                let mc: MFMailComposeViewController = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.setSubject(subject)//Titulo de ,correo
                mc.setMessageBody("\n\n\nwalmart super\ndispositivo: IOS \(UIDevice.current.systemVersion)\nV App: \(majorVersion) \(minorVersion)\nDevice: \(device)\nConectado via: \(status)", isHTML: false)
                mc.setToRecipients([EMAIL_MG])
            
                self.present(mc, animated: true, completion: nil)
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
                    mc.setMessageBody("\n\n\nwalmart MG\ndispositivo: IOS \(UIDevice.current.systemVersion)\nV App: \(majorVersion) \(minorVersion)\nDevice: \(device)\nConectado via: \(status)", isHTML: false)
                    mc.setToRecipients([EMAIL_MG])
                    self.present(mc, animated: true, completion: nil)
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
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    override func back() {
         //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SUPPORT_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_SUPPORT_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label:"")
        super.back()
    }
  
    
}


