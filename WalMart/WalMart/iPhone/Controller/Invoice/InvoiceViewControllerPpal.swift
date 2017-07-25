//
//  InvoiceViewControllerPpal.swift
//  WalMart
//
//  Created by Vantis on 19/04/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit
import Foundation

class InvoiceViewControllerPpal: NavigationViewController, BarCodeViewControllerDelegate, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate {
    let headerHeight: CGFloat = 46
    
    var content: TPKeyboardAvoidingScrollView!

    var alertView: IPOWMAlertViewController?
    var txtRfcEmail: FormFieldView?
    var txtTicketNumber: FormFieldView?
    var errorView: FormFieldErrorView?
    var lblSelectionTitle : UILabel!
    var lblRfcEmailTitle : UILabel!
    var lblTicketTitle : UILabel!
    var infoMessage: UILabel!
    var viewLoad : WMLoadingView!
    
    var btnNewInvoice: UIButton?
    var btnResendInvoice: UIButton?
    var btnScanTicket: UIButton?
    var btnNext: UIButton?
    var btnCancel: UIButton?
    var btnInfoTicketButton: UIButton?
    
    var rfcUserDefault : String! = ""
    var emailUserDefault : String! = ""
    var byScan : Bool! = false
    var folioInvoice : Int! = -1
    
    var modalView: AlertModalView?
    var keyboardBar: FieldInputView? {
        didSet {
        }
    }
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_INVOICE.rawValue
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = NSLocalizedString("moreoptions.title.Invoice",comment:"")
        //self.showInfoAlert()
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.white
        self.view.addSubview(self.content)
        
        let section1Top: CGFloat = 0
        let section1Bottom: CGFloat =  self.content.bounds.height/4
        let section2Top: CGFloat = section1Bottom
        let section2Bottom: CGFloat = 2*section1Bottom
        let section3Top: CGFloat = section2Bottom
        let section3Bottom: CGFloat = 3*section1Bottom
        let section4Top: CGFloat = section3Bottom
        let section4Bottom: CGFloat = 4*section1Bottom
        let sectionWidth: CGFloat = self.content.bounds.width
        
        
        let margin: CGFloat = 15.0
        var fheight: CGFloat = 0.0
        let checkEmpty : UIImage = UIImage(named:"check_empty")!
        let checkFull : UIImage = UIImage(named:"check_full")!
        
        
        fheight = (section1Bottom - section1Top)/5
        self.lblSelectionTitle = self.buildSectionTitle(NSLocalizedString("invoice.section.actionToDo",comment:""), frame: CGRect(x: margin, y: fheight, width: sectionWidth, height: fheight))
        self.lblSelectionTitle.sizeToFit()
        self.content.addSubview(lblSelectionTitle)
        
        //CHECK PARA FACTURA NUEVA
        self.btnNewInvoice = UIButton(frame: CGRect(x: margin, y: 3*fheight - 10, width: (sectionWidth - 2*margin)/2, height: fheight))
        btnNewInvoice!.setImage(checkEmpty, for: UIControlState())
        btnNewInvoice!.setImage(checkFull, for: UIControlState.selected)
        btnNewInvoice!.addTarget(self, action: #selector(self.checkSelected(_:)), for: UIControlEvents.touchUpInside)
        btnNewInvoice!.setTitle(NSLocalizedString("invoice.button.invoice",comment:""), for: UIControlState())
        btnNewInvoice!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        btnNewInvoice!.setTitleColor(WMColor.gray, for: UIControlState())
        btnNewInvoice!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 10.0, 0, 0.0)
        btnNewInvoice!.isSelected = true
        btnNewInvoice!.contentHorizontalAlignment = .left
        self.content.addSubview(self.btnNewInvoice!)
        
        //CHECK PARA REENVIAR FACTURA
        self.btnResendInvoice = UIButton(frame: CGRect(x: btnNewInvoice!.frame.maxX, y: 3*fheight - 10, width: (sectionWidth - 2*margin)/2, height: fheight))
        btnResendInvoice!.setImage(checkEmpty, for: UIControlState())
        btnResendInvoice!.setImage(checkFull, for: UIControlState.selected)
        btnResendInvoice!.addTarget(self, action: #selector(self.checkSelected(_:)), for: UIControlEvents.touchUpInside)
        btnResendInvoice!.setTitle(NSLocalizedString("invoice.button.resend",comment:""), for: UIControlState())
        btnResendInvoice!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        btnResendInvoice!.setTitleColor(WMColor.gray, for: UIControlState())
        btnResendInvoice!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 10.0, 0, 0.0)
        btnResendInvoice!.contentHorizontalAlignment = .left
        self.content.addSubview(self.btnResendInvoice!)
        
        fheight = (section2Bottom - section2Top)/6
        //SECCION TICKET
        self.lblTicketTitle = self.buildSectionTitle(NSLocalizedString("invoice.button.ticketInfo",comment:""), frame: CGRect(x: margin, y: section2Top + fheight, width: sectionWidth, height: fheight))
        self.lblTicketTitle.sizeToFit()
        self.content.addSubview(lblTicketTitle)
        
        // BOTON DE INFO
        self.btnInfoTicketButton = UIButton(frame: CGRect(x: self.lblTicketTitle!.frame.maxX + 2 , y: section2Top + fheight-6, width: 23, height: 23))
        self.btnInfoTicketButton!.setBackgroundImage(UIImage(named:"scan_info"), for: UIControlState())
        self.btnInfoTicketButton!.addTarget(self, action: #selector(self.infoImage(_:)), for: UIControlEvents.touchUpInside)
        self.content.addSubview(self.btnInfoTicketButton!)
        
        // BOTON DE ESCANEAR TICKET
        self.btnScanTicket = UIButton(frame: CGRect(x: sectionWidth - 2.5*fheight - 10, y:  lblTicketTitle.frame.maxY + fheight, width: 2.5*fheight, height: 2.5*fheight))
        self.btnScanTicket!.setBackgroundImage(UIImage(named:"invoice_ticket_scan"), for: UIControlState())
        self.btnScanTicket!.addTarget(self, action: #selector(self.scanTicket(_:)), for: UIControlEvents.touchUpInside)
        self.content.addSubview(self.btnScanTicket!)
        
        let viewAccess = FieldInputView(frame: CGRect(x: 0, y: 0, width: self.content.frame.size.width , height: 44), inputViewStyle: .keyboard , titleSave:"Siguiente", save: { (field:UITextField?) -> Void in
            self.view.endEditing(true)
            self.txtRfcEmail?.becomeFirstResponder()
        })
        
        self.keyboardBar = viewAccess
        
        //NUMERO DE TICKET
        self.txtTicketNumber = FormFieldView(frame: CGRect(x: margin, y: lblTicketTitle.frame.maxY + fheight, width: sectionWidth - 2.5*fheight - margin - 20, height: 2.5*fheight))
        self.txtTicketNumber!.isRequired = true
        let placeholder = NSMutableAttributedString()
        placeholder.append(NSAttributedString(string: NSLocalizedString("invoice.field.ticketnumber",comment:"")
            , attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
        self.txtTicketNumber!.setCustomAttributedPlaceholder(placeholder)
        self.txtTicketNumber!.typeField = TypeField.number
        self.txtTicketNumber!.nameField = "ticketNumber"
        self.txtTicketNumber!.minLength = 20
        self.txtTicketNumber!.maxLength = 25
        self.txtTicketNumber!.keyboardType = UIKeyboardType.numberPad
        self.txtTicketNumber!.inputAccessoryView = self.keyboardBar
        //self.txtTicketNumber!.delegate = self
        self.content.addSubview(self.txtTicketNumber!)
        
        //SECCION RFC
        fheight = (section3Bottom - section3Top)/6
        //SECCION RFC EMAIL
        self.lblRfcEmailTitle = self.buildSectionTitle(NSLocalizedString("invoice.field.turfc",comment:""), frame: CGRect(x: margin, y: section3Top + fheight, width: sectionWidth, height: fheight))
        self.lblRfcEmailTitle.sizeToFit()
        self.content.addSubview(lblRfcEmailTitle)
        
        
        //CAPTURA RFC
        self.txtRfcEmail = FormFieldView(frame: CGRect(x: margin, y: lblRfcEmailTitle.frame.maxY + fheight, width: sectionWidth - 2*margin, height: 2.5*fheight))
        self.txtRfcEmail!.isRequired = true
        let placeholder2 = NSMutableAttributedString()
        placeholder2.append(NSAttributedString(string: NSLocalizedString("invoice.field.rfcejemplo",comment:"")
            , attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
        self.txtRfcEmail!.setCustomAttributedPlaceholder(placeholder2)
        self.txtRfcEmail!.typeField = TypeField.rfc
        self.txtRfcEmail!.nameField = "rfc"
        self.txtRfcEmail!.autocapitalizationType = .allCharacters
        //self.txtRfcEmail!.maxLength = 13
        self.content.addSubview(self.txtRfcEmail!)
        
        
        //SECCION DE BOTONES
        fheight = (section4Bottom - section4Top)/3
        //CANCEL
        self.btnCancel = UIButton(frame: CGRect(x: margin, y: section4Top + 2*fheight, width: (sectionWidth - 2*margin)/2 - margin/2, height: fheight))
        self.btnCancel!.setTitle(NSLocalizedString("invoice.button.cancel",comment:""), for:UIControlState())
        self.btnCancel!.titleLabel!.textColor = UIColor.white
        self.btnCancel!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.btnCancel!.backgroundColor = WMColor.light_blue
        self.btnCancel!.layer.cornerRadius = fheight/2
        self.btnCancel!.addTarget(self, action: #selector(NavigationViewController.back), for: UIControlEvents.touchUpInside)
        self.content.addSubview(btnCancel!)
        //NEXT
        self.btnNext = UIButton(frame: CGRect(x: btnCancel!.frame.maxX + margin, y: section4Top + 2*fheight, width: (sectionWidth - 2*margin)/2 - margin/2, height: fheight))
        self.btnNext!.setTitle(NSLocalizedString("invoice.button.next",comment:""), for:UIControlState())
        self.btnNext!.titleLabel!.textColor = UIColor.white
        self.btnNext!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.btnNext!.backgroundColor = WMColor.green
        self.btnNext!.layer.cornerRadius = fheight/2
        self.btnNext!.addTarget(self, action: #selector(self.next(_:)), for: UIControlEvents.touchUpInside)
        self.content.addSubview(btnNext!)

        if self.isKeyPresentInUserDefaults(key: "last_rfc"){
            rfcUserDefault = UserDefaults.standard.value(forKey: "last_rfc") as? String
            txtRfcEmail?.text = rfcUserDefault
        }
        if self.isKeyPresentInUserDefaults(key: "last_email"){
            emailUserDefault = UserDefaults.standard.value(forKey: "last_email") as? String
        }
        // Do any additional setup after loading the view.
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.bounds.height - (headerHeight + 120))
        self.content.contentSize = CGSize(width: self.view.frame.width, height: self.txtRfcEmail!.frame.maxY + 5.0)
    }
    
    /*func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if !byScan{
            viewLoad = WMLoadingView(frame: self.content.bounds)
            viewLoad.backgroundColor = UIColor.white
            self.alertView = nil
            self.content.addSubview(viewLoad)
            self.viewLoad!.startAnnimating(true)
            self.barcodeCaptured(textField.text)
            byScan = false
        }
        return true
    }*/
    
    
   /* func showInfoAlert(){
        let message = NSMutableAttributedString()
        message.append(NSAttributedString(string: NSLocalizedString("invoice.info.validity",comment:""), attributes: [NSFontAttributeName : WMFont.fontMyriadProBoldOfSize(15),NSForegroundColorAttributeName:UIColor.white]))
        message.append(NSAttributedString(string: NSLocalizedString("invoice.info.validity.desc",comment:""), attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(15),NSForegroundColorAttributeName:UIColor.white]))
        message.append(NSAttributedString(string: NSLocalizedString("invoice.info.guard",comment:""), attributes: [NSFontAttributeName : WMFont.fontMyriadProBoldOfSize(15),NSForegroundColorAttributeName:UIColor.white]))
        message.append(NSAttributedString(string: NSLocalizedString("invoice.info.guard.desc",comment:""), attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(15),NSForegroundColorAttributeName:UIColor.white]))
        
        
        self.alertView = IPOWMAlertInfoViewController.showAttributedAlert(NSLocalizedString("invoice.advice",comment:""), message: message)
        self.alertView?.showOkButton(NSLocalizedString("invoice.message.continue",comment:""), colorButton: WMColor.green)
    }*/

    func buildSectionTitle(_ title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(16)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.white
        return sectionTitle
    }

    func checkSelected(_ sender:UIButton) {
        if sender.isSelected{
            return
        }
        if sender == self.btnNewInvoice{
            self.btnResendInvoice!.isSelected = false
           
            self.lblRfcEmailTitle.text = NSLocalizedString("invoice.field.turfc",comment:"")
            self.lblRfcEmailTitle.sizeToFit()
            //CAPTURA RFC
            let placeholder2 = NSMutableAttributedString()
            placeholder2.append(NSAttributedString(string: NSLocalizedString("invoice.field.rfcejemplo",comment:"")
                , attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
            self.txtRfcEmail!.setCustomAttributedPlaceholder(placeholder2)
            self.txtRfcEmail!.typeField = TypeField.rfc
            self.txtRfcEmail!.nameField = "rfc"
            self.txtRfcEmail!.autocapitalizationType = .allCharacters
            self.txtRfcEmail!.minLength = 12
            self.txtRfcEmail!.maxLength = 13
            self.txtRfcEmail?.text = rfcUserDefault
        }else{
            self.btnNewInvoice!.isSelected = false
            self.lblRfcEmailTitle.text = NSLocalizedString("invoice.section.emailTitle",comment:"")
            self.lblRfcEmailTitle.sizeToFit()
            //CAPTURA RFC
            self.txtRfcEmail!.typeField = TypeField.email
            self.txtRfcEmail!.nameField = "email"
            if self.isKeyPresentInUserDefaults(key: "last_email"){
                self.txtRfcEmail?.text = emailUserDefault
            }else{
                self.txtRfcEmail?.text = UserCurrentSession.sharedInstance.userSigned!.email as String
            }
            self.txtRfcEmail!.autocapitalizationType = .none
            self.txtRfcEmail!.placeholder = "Escriba un correo para el envío de la factura"
            self.txtRfcEmail!.maxLength = 45

        }
        if self.errorView != nil{
            self.errorView?.removeFromSuperview()
        }

        sender.isSelected = !(sender.isSelected)
    }
    
    func infoImage(_ sender:UIButton){
        var title = ""
        var imageName = ""
        if sender == self.btnInfoTicketButton{
            title = NSLocalizedString("invoice.field.tc",comment:"")
            imageName = "ticket_tc"
        }
        self.modalView = AlertModalView.showAlertWithImage(title, contentViewSize: CGSize(width: 288, height: 470), image: UIImage(named: imageName)!)
    }
    
    func scanTicket(_ sender:UIButton){
        let barCodeController = BarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.delegate = self
        barCodeController.useDelegate = true
        barCodeController.onlyCreateList = true
        //byScan = true
        self.present(barCodeController, animated: true, completion: nil)
    }
    
    //MARK: BarCodeViewControllerDelegate
    func barcodeCaptured(_ value: String?) {
        if value != nil {
        viewLoad = WMLoadingView(frame: self.view.bounds)
        viewLoad.backgroundColor = UIColor.white
        self.alertView = nil
        self.view.superview?.addSubview(viewLoad)
        viewLoad.startAnnimating(false)

        
        let ticketService = InvoiceFolioService()
        ticketService.callService(params: ["ticket":value], successBlock: { (resultCall:[String:Any]) -> Void in
            var responseOk : String! = ""
            if let headerData = resultCall["headerResponse"] as? [String:Any]{
                // now val is not nil and the Optional has been unwrapped, so use it
                responseOk = headerData["responseCode"] as! String
                
            if responseOk == "OK"{
                    
            let businessData = resultCall["businessResponse"] as? [String:Any]
            

            self.txtTicketNumber?.text = businessData?["ticketTC"] as? String
            
            self.folioInvoice = Int((businessData?["folioInvoice"] as? String)!)
            print("sucess, Folio: \(self.folioInvoice)")
            if self.viewLoad != nil{
                self.viewLoad.stopAnnimating()
            }
            self.viewLoad = nil
            }else{
                let errorMess = headerData["reasons"] as! [[String:Any]]
                if self.viewLoad != nil{
                    self.viewLoad.stopAnnimating()
                }
                self.viewLoad = nil
                print("error")
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
                self.alertView!.setMessage(errorMess[0]["description"] as! String)
                self.alertView!.showDoneIcon()

                }
            }
        }, errorBlock: { (error:NSError) -> Void in
            if self.viewLoad != nil{
                self.viewLoad.stopAnnimating()
            }
            self.viewLoad = nil
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(error.localizedDescription)
            self.alertView!.showDoneIconWithoutClose()
            self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
        })
        }
    }

    func resendInvoice(){
        
            /*viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.white
            self.alertView = nil
            self.view.superview?.addSubview(viewLoad)
            self.viewLoad!.startAnnimating(true)*/
        self.alertView = nil
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"invoice_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage("Reenviando factura...")
        
            let ticketService = InvoiceResendService()
            ticketService.callService(params: ["ticket":self.txtTicketNumber?.text, "email":self.txtRfcEmail?.text], successBlock: { (resultCall:[String:Any]) -> Void in
                var responseOk : String! = ""
                if let headerData = resultCall["headerResponse"] as? [String:Any]{
                    // now val is not nil and the Optional has been unwrapped, so use it
                responseOk = headerData["responseCode"] as! String
                    
                if responseOk == "OK"{
                    UserDefaults.standard.set(self.txtRfcEmail?.text, forKey: "last_email")
                    self.emailUserDefault = self.txtRfcEmail?.text
                if self.viewLoad != nil{
                    self.viewLoad.stopAnnimating()
                }
                self.viewLoad = nil
                self.alertView!.setMessage(NSLocalizedString("invoice.message.facturaResend",comment:"") + "\n\n" + NSLocalizedString("invoice.message.facturaResendEmail",comment:"") + "\n" + (self.txtRfcEmail?.text)!)
                self.alertView!.showDoneIconWithoutClose()
                    self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
                    self.checkSelected(self.btnNewInvoice!)
                    self.txtTicketNumber?.text = ""
                }else{
                    let errorMess = headerData["reasons"] as! [[String:Any]]
                    self.alertView!.setMessage(errorMess[0]["description"] as! String)
                    self.alertView!.showErrorIcon("Fallo")
                    self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
                    if self.viewLoad != nil{
                        self.viewLoad.stopAnnimating()
                    }
                    self.viewLoad = nil
                    print("error")
                    }
                }
            }, errorBlock: { (error:NSError) -> Void in
                if self.viewLoad != nil{
                    self.viewLoad.stopAnnimating()
                }
                self.viewLoad = nil
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Fallo")
                self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
            })
    }
    
    func revisaTicketEscrito(){
        
        viewLoad = WMLoadingView(frame: self.view.bounds)
        viewLoad.backgroundColor = UIColor.white
        self.alertView = nil
        self.view.superview?.addSubview(viewLoad)
        viewLoad.startAnnimating(false)
        
        
        let ticketService = InvoiceFolioService()
        ticketService.callService(params: ["ticket":txtTicketNumber?.text], successBlock: { (resultCall:[String:Any]) -> Void in
            var responseOk : String! = ""
            if let headerData = resultCall["headerResponse"] as? [String:Any]{
                // now val is not nil and the Optional has been unwrapped, so use it
                responseOk = headerData["responseCode"] as! String
                
                if responseOk == "OK"{
                    
                    let businessData = resultCall["businessResponse"] as? [String:Any]
                    
                    
                    //self.txtTicketNumber!.text = businessData?["ticketTC"] as? String
                    
                    self.folioInvoice = Int((businessData?["folioInvoice"] as? String)!)
                    print("sucess, Folio: \(self.folioInvoice)")
                    if self.viewLoad != nil{
                        self.viewLoad.stopAnnimating()
                    }
                    self.viewLoad = nil
                    if self.folioInvoice > 0 {
                        if self.btnNewInvoice!.isSelected{
                            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
                            self.alertView!.setMessage("El ticket ya se encuentra facturado.")
                            self.alertView!.showErrorIcon("Ok")
                        }else{
                        self.resendInvoice()
                        
                        }
                    }else if self.folioInvoice == 0{
                        if self.btnResendInvoice!.isSelected{
                            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
                            self.alertView!.setMessage("El ticket no se ha facturado aún.")
                            self.alertView!.showErrorIcon("Ok")
                            
                        }else{
                            if IS_IPAD{
                                let controller = self.storyboard?.instantiateViewController(withIdentifier: "invoiceDataController") as! IPAInvoiceDataViewController
                                controller.RFCEscrito = self.txtRfcEmail?.text
                                UserDefaults.standard.set(self.txtRfcEmail?.text, forKey: "last_rfc")
                                self.rfcUserDefault = self.txtRfcEmail?.text
                                controller.TicketEscrito = self.txtTicketNumber?.text
                                controller.isFromPpal = true
                                if self.btnResendInvoice!.isSelected{
                                    controller.tipoFacturacion = .resendInvoice
                                }else{
                                    controller.tipoFacturacion = .newInvoice
                                }
                                self.txtTicketNumber?.text = ""
                                self.navigationController?.pushViewController(controller, animated: true)
                                
                            }else{
                                self.performSegue(withIdentifier: "invoiceDataController", sender: self)
                            }
                            
                        }
                        
                    }
                }else{
                    let errorMess = headerData["reasons"] as! [[String:Any]]
                    if self.viewLoad != nil{
                        self.viewLoad.stopAnnimating()
                    }
                    self.viewLoad = nil
                    print("error")
                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
                    self.alertView!.setMessage(errorMess[0]["description"] as! String)
                    self.alertView!.showDoneIcon()
                    
                }
            }
        }, errorBlock: { (error:NSError) -> Void in
            if self.viewLoad != nil{
                self.viewLoad.stopAnnimating()
            }
            self.viewLoad = nil
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(error.localizedDescription)
            self.alertView!.showDoneIconWithoutClose()
            self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
        })
    }
    
    func next(_ sender:UIButton){
        if validateData(){
            if self.errorView != nil{
                self.errorView?.removeFromSuperview()
            }
            revisaTicketEscrito()
        }
    }
    
    
    func validateData() -> Bool{
        var error = viewError(txtTicketNumber!)
        if !error{
            error = viewError(txtRfcEmail!)
            if error{
                txtRfcEmail?.typeField = .rfcm
                error = viewError(txtRfcEmail!)
                txtRfcEmail?.typeField = .rfc
            }
        }
        if error{
            return false
        }
        return true
    }
    
    func viewError(_ field: FormFieldView)-> Bool{
        let message = field.validate()
        if message != nil{
            if self.errorView == nil{
                self.errorView = FormFieldErrorView()
            }
            SignUpViewController.presentMessage(field,  nameField:"" , message: message! ,errorView:self.errorView!,  becomeFirstResponder: true )
            return true
        }
        let _ = field.resignFirstResponder()
        return false
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
            let controller = segue.destination as! InvoiceDataViewController
            controller.RFCEscrito = txtRfcEmail?.text
        UserDefaults.standard.set(txtRfcEmail?.text, forKey: "last_rfc")
        self.rfcUserDefault = self.txtRfcEmail?.text
            controller.TicketEscrito = txtTicketNumber?.text
            controller.isFromPpal = true
            if self.btnResendInvoice!.isSelected{
                controller.tipoFacturacion = .resendInvoice
            }else{
                controller.tipoFacturacion = .newInvoice
            }
        self.txtTicketNumber?.text = ""
        
    }
 
    //MARK: TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(_ sender:Any) -> CGSize {
        let val = CGSize(width: self.view.frame.width, height: self.content.contentSize.height)
        return val
    }

    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }


}
