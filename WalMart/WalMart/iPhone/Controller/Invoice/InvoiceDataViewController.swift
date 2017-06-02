//
//  InvoiceDataViewController.swift
//  WalMart
//
//  Created by Vantis on 21/04/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit

enum TypeSend{
    case newInvoice
    case resendInvoice
}

class InvoiceDataViewController: NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate, AlertPickerViewSectionsDelegate,UITextFieldDelegate{
    
    let headerHeight: CGFloat = 46
    
    var content: UIScrollView!
    
    var txtAddress: FormFieldView?
    var txtIeps: FormFieldView?
    var txtEmail: FormFieldView?
    var errorView: FormFieldErrorView?
    var lblAddressTitle : UILabel!
    var lblIepsTitle : UILabel!
    var lblEmailTitle : UILabel!
    var lblPrivacyTitle : UILabel!
    var lblVigencia : UILabel!
    var lblResguardo : UILabel!
    
    var btnNoAddress : UIButton?
    var btnNoIeps : UIButton?
    var btnPrivacity : UIButton?
    
    var btnCancel : UIButton?
    var btnFacturar : UIButton?
    var alertView : IPOWMAlertViewController? = nil
    
    var picker: AlertPickerViewSections!
    var delegateFormAdd : FormSuperAddressViewDelegate!
    var direccionesFromApp : [String]! = []
    var direccionesFromService : [String]! = nil
    var tipoFacturacion : TypeSend = TypeSend.newInvoice
    var RFCEscrito : String! = ""
    var TicketEscrito : String! = ""
    
    var arrayAddressFiscalService : [[String:Any]]! = nil
    var arrayAddressFiscalServiceNotEmpty : [[String:Any]]! = nil
    var viewLoad : WMLoadingView!
    var idClienteSelected : String! = ""
    var idEmptySelected : String! = ""
    
    var isFromPpal : Bool! = false
    var idClienteDefault : String! = ""
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_INVOICE.rawValue
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = NSLocalizedString("moreoptions.title.Invoice",comment:"")
        // Do any additional setup after loading the view.
        
        picker = AlertPickerViewSections.initPickerWithDefaultNewAddressButton()
        
        self.content = UIScrollView()
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
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
        
        //SECCION 1
        fheight = (section1Bottom - section1Top)/6
        self.lblAddressTitle = self.buildSectionTitle(NSLocalizedString("invoice.section.addressTitle",comment:""), frame: CGRect(x: margin, y: fheight, width: sectionWidth, height: fheight))
        self.lblAddressTitle.sizeToFit()
        self.content.addSubview(lblAddressTitle)

        //CAPTURA RFC
        self.txtAddress = FormFieldView(frame: CGRect(x: margin, y: lblAddressTitle.frame.maxY + fheight/2, width: sectionWidth - 2*margin, height: 2*fheight))
        self.txtAddress!.isRequired = true
        let placeholder = NSMutableAttributedString()
        placeholder.append(NSAttributedString(string: NSLocalizedString("invoice.field.address",comment:"")
            , attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
        self.txtAddress!.setCustomAttributedPlaceholder(placeholder)
        self.txtAddress!.typeField = TypeField.list
        self.txtAddress!.setImageTypeField()
        self.txtAddress!.nameField = "Mis direcciones"
        //self.txtAddress!.maxLength = 13
        self.content.addSubview(self.txtAddress!)
        
        self.lblIepsTitle = self.buildSectionTitle(NSLocalizedString("invoice.section.iepsTitle",comment:""), frame: CGRect(x: margin, y: txtAddress!.frame.maxY + fheight/2, width: sectionWidth, height: fheight))
        
        self.lblIepsTitle.sizeToFit()
        self.content.addSubview(lblIepsTitle)
        //SECCION 2
        fheight = (section2Bottom - section2Top)/6
        //CAPTURA RFC
        self.txtIeps = FormFieldView(frame: CGRect(x: margin, y: section2Top, width: sectionWidth - 2*margin, height: 2*fheight))
        
        let placeholder2 = NSMutableAttributedString()
        placeholder2.append(NSAttributedString(string: NSLocalizedString("invoice.field.ieps",comment:"")
            , attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
        self.txtIeps!.setCustomAttributedPlaceholder(placeholder2)
        self.txtIeps!.typeField = TypeField.number
        self.txtIeps!.nameField = "ieps"
        self.txtIeps!.minLength = 14
        self.txtIeps!.maxLength = 14
        self.txtIeps!.isEnabled = false
        self.content.addSubview(self.txtIeps!)
        
        self.btnNoAddress = UIButton(frame: CGRect(x: margin, y: txtIeps!.frame.maxY, width: (sectionWidth - 2*margin), height: 2*fheight))
        btnNoAddress!.setImage(checkEmpty, for: UIControlState())
        btnNoAddress!.setImage(checkFull, for: UIControlState.selected)
        btnNoAddress!.addTarget(self, action: #selector(self.checkSelected(_:)), for: UIControlEvents.touchUpInside)
        btnNoAddress!.setTitle(NSLocalizedString("invoice.button.noaddress",comment:""), for: UIControlState())
        btnNoAddress!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        btnNoAddress!.setTitleColor(WMColor.gray, for: UIControlState())
        btnNoAddress!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 10.0, 0, 0.0)
        btnNoAddress!.isSelected = false
        btnNoAddress!.contentHorizontalAlignment = .left
        self.content.addSubview(self.btnNoAddress!)

        //SECCION 3
        fheight = (section3Bottom - section3Top)/6
        self.lblEmailTitle = self.buildSectionTitle(NSLocalizedString("invoice.section.emailTitle",comment:""), frame: CGRect(x: margin, y: btnNoAddress!.frame.maxY + fheight, width: sectionWidth, height: fheight))
        self.lblEmailTitle.sizeToFit()
        self.content.addSubview(lblEmailTitle)
        
        //CAPTURA RFC
        self.txtEmail = FormFieldView(frame: CGRect(x: margin, y: lblEmailTitle.frame.maxY + fheight, width: sectionWidth - 2*margin, height: 2*fheight + 5))
        self.txtEmail!.isRequired = true
        self.txtEmail!.typeField = TypeField.email
        self.txtEmail!.nameField = "email"
        self.txtEmail!.delegate = self
        self.txtEmail?.text = UserCurrentSession.sharedInstance.userSigned!.email as String
        self.content.addSubview(self.txtEmail!)
        
        
        self.btnPrivacity = UIButton(frame: CGRect(x: margin, y: txtEmail!.frame.maxY + fheight/2, width: fheight, height: fheight))
        btnPrivacity!.setImage(checkEmpty, for: UIControlState())
        btnPrivacity!.setImage(checkFull, for: UIControlState.selected)
        btnPrivacity!.addTarget(self, action: #selector(self.checkSelected(_:)), for: UIControlEvents.touchUpInside)
        btnPrivacity!.isSelected = false
        btnPrivacity!.contentHorizontalAlignment = .left
        btnPrivacity!.contentVerticalAlignment = .top
        self.content.addSubview(self.btnPrivacity!)

        
        self.lblPrivacyTitle = UILabel(frame: CGRect(x: btnPrivacity!.frame.maxX + 5, y: txtEmail!.frame.maxY + fheight/8, width: sectionWidth - 2*margin - btnPrivacity!.frame.size.width, height: 2*fheight))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        //var valueItem = NSMutableAttributedString()
        let valuesDescItem = NSMutableAttributedString()
        let attrStringLab = NSAttributedString(string: "He leído y acepto los términos del " , attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(12), NSForegroundColorAttributeName:WMColor.dark_gray])
        valuesDescItem.append(attrStringLab)
        let attrStringVal = NSAttributedString(string: NSLocalizedString("profile.terms.privacy", comment: "") , attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldSize(12),NSForegroundColorAttributeName:WMColor.light_blue])
        valuesDescItem.append(attrStringVal)
        valuesDescItem.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, valuesDescItem.length))
        lblPrivacyTitle.attributedText = valuesDescItem
        
        
        //viewTap = UIView()
        let tapGestureRecognizer = UITapGestureRecognizer(target:self,action:#selector(self.showPrivacyNotice(_:)))
        lblPrivacyTitle.isUserInteractionEnabled = true
        lblPrivacyTitle.addGestureRecognizer(tapGestureRecognizer)
        
        self.content.addSubview(lblPrivacyTitle)

        
        self.lblResguardo = UILabel(frame: CGRect(x: margin, y: btnPrivacity!.frame.maxY + fheight/2, width: sectionWidth - 2*margin, height: 2*fheight))
        self.lblResguardo.text = NSLocalizedString("invoice.info.guard.desc",comment:"")
        self.lblResguardo.font = WMFont.fontMyriadProRegularOfSize(11)
        self.lblResguardo.textColor = WMColor.dark_gray
        self.lblResguardo.numberOfLines = 0
        self.lblResguardo.sizeToFit()
        self.content.addSubview(lblResguardo)
        
        self.lblVigencia = UILabel(frame: CGRect(x: margin, y: lblResguardo!.frame.maxY + fheight/2, width: sectionWidth - 2*margin, height: 2*fheight))
        self.lblVigencia.text = NSLocalizedString("invoice.info.validity.desc2",comment:"")
        self.lblVigencia.font = WMFont.fontMyriadProRegularOfSize(11)
        self.lblVigencia.textColor = WMColor.dark_gray
        self.lblVigencia.numberOfLines = 0
        self.lblVigencia.sizeToFit()
        self.content.addSubview(lblVigencia)
        
       
        
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
        self.btnFacturar = UIButton(frame: CGRect(x: btnCancel!.frame.maxX + margin, y: section4Top + 2*fheight, width: (sectionWidth - 2*margin)/2 - margin/2, height: fheight))
        self.btnFacturar!.setTitle(NSLocalizedString("invoice.button.facturar",comment:""), for:UIControlState())
        self.btnFacturar!.titleLabel!.textColor = UIColor.white
        self.btnFacturar!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.btnFacturar!.backgroundColor = WMColor.green
        self.btnFacturar!.layer.cornerRadius = fheight/2
        self.btnFacturar!.addTarget(self, action: #selector(self.facturar(_:)), for: UIControlEvents.touchUpInside)
        self.content.addSubview(btnFacturar!)
        
        txtAddress?.onBecomeFirstResponder = { () in
            
                //self.anchura!.text = self.valAnchuras[0]
                //self.selectedAnchura = IndexPath(row: 0, section: 0)
            var indexPath = IndexPath(row: 0, section: 0)
            if self.txtAddress?.text != ""{
                indexPath = IndexPath(row: self.direccionesFromService.index(of: (self.txtAddress?.text)!)!, section: 0)
            }
                self.picker!.selected = indexPath
                self.picker!.sender = self.txtAddress!
                self.picker!.delegate = self
                self.picker!.setValues(self.txtAddress!.nameField, self.RFCEscrito, values: self.direccionesFromService, data: self.arrayAddressFiscalServiceNotEmpty)
                self.picker!.showPicker()
        }
        
        if self.isKeyPresentInUserDefaults(key: "last_idCliente"){
            idClienteDefault = UserDefaults.standard.value(forKey: "last_idCliente") as! String
        }

        /*"invoice.section.addressTitle" = "Dirección de Facturación";
          "invoice.field.address" = "Agregar nueva dirección de facturación";
          "invoice.button.noaddress" = "Agregar nueva dirección de facturación";*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.bounds.height - (headerHeight + 120))
        self.content.contentSize = CGSize(width: self.view.frame.width, height: self.txtEmail!.frame.maxY + 50.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isFromPpal{
        self.callServiceFiscalAddress()
            isFromPpal = false
        }
        
    }

        
    func buildSectionTitle(_ title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(15)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.white
        return sectionTitle
    }

    func facturar(_ sender:UIButton){
        if validateData(){
            if self.errorView != nil{
                self.errorView?.removeFromSuperview()
            }
        viewLoad = WMLoadingView(frame: self.view.bounds)
        viewLoad.backgroundColor = UIColor.white
        self.alertView = nil
        self.view.superview?.addSubview(viewLoad)
        self.viewLoad!.startAnnimating(true)
            
            if idClienteSelected == ""{
                saveEmptyAddress()
            }else{
        UserDefaults.standard.set(idClienteSelected, forKey:"last_idCliente")
        let ticketService = InvoiceResendService()
        ticketService.callService(params: ["ticket":self.TicketEscrito, "email":self.txtEmail?.text, "idCliente":self.idClienteSelected], successBlock: { (resultCall:[String:Any]) -> Void in
            var responseOk : String! = ""
            if let headerData = resultCall["headerResponse"] as? [String:Any]{
                // now val is not nil and the Optional has been unwrapped, so use it
                responseOk = headerData["responseCode"] as! String
                
                if responseOk == "OK"{
                    
                    
                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
                    self.alertView!.setMessage(NSLocalizedString("invoice.message.facturaOk",comment:"") + "\n" + (self.txtEmail?.text)!)
                    self.alertView!.showDoneIconWithoutClose()
                    self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
                    if self.viewLoad != nil{
                        self.viewLoad.stopAnnimating()
                    }
                    self.viewLoad = nil
                    self.back()
                }else{
                    let errorMess = headerData["reasons"] as! [[String:Any]]
                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
                    self.alertView!.setMessage(errorMess[0]["description"] as! String)
                    self.alertView!.showDoneIcon()
                    if self.viewLoad != nil{
                        self.viewLoad.stopAnnimating()
                    }
                    self.viewLoad = nil
                    print("error")
                }
            }
        }, errorBlock: { (error:NSError) -> Void in
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(error.localizedDescription)
            self.alertView!.showDoneIconWithoutClose()
            self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
            if self.viewLoad != nil{
                self.viewLoad.stopAnnimating()
            }
            self.viewLoad = nil
        })
            }
        
        }
        
        
        //self.performSegue(withIdentifier: "invoiceDataController", sender: self)
        
        
        /*"invoice.message.facturaOk" = "La factura ha sido enviada a:";
        "invoice.message.facturaResend" = "Factura reenviada con éxito.";
        "invoice.message.facturaResendEmail" = "Te la hemos enviado a";*/
    }
    
    func showPrivacyNotice(_ sender:UIButton){
        self.view.endEditing(true)
        let previewHelp = PreviewHelpViewController()
        previewHelp.titleText = NSLocalizedString("help.item.privacy.notice", comment: "") as NSString!
        previewHelp.resource = "privacy"
        previewHelp.type = "pdf"
        self.navigationController!.pushViewController(previewHelp,animated:true)
        //present(previewHelp, animated: true, completion: nil)
    }
    
    func checkSelected(_ sender:UIButton) {
        sender.isSelected = !(sender.isSelected)
        
        if sender == self.btnNoAddress{
            txtAddress?.isEnabled = !(sender.isSelected)
            txtIeps?.isEnabled = !(sender.isSelected)
            if sender.isSelected{
                txtAddress?.text = ""
                txtIeps?.text = ""
                idClienteSelected = idEmptySelected
            }
        }else if sender == self.btnPrivacity {
            if sender.isSelected{
                if self.errorView != nil {
                    self.errorView?.removeFromSuperview()
                }
            }
        }
    }

    
    func saveReplaceViewSelected() {
    }
    
    func buttomViewSelected(_ sender: UIButton) {
        
    }
    
    func didSelectOption(_ picker:AlertPickerViewSections, indexPath:IndexPath ,selectedStr:String, newRegister:[String:Any]) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  txtAddress! {
                if self.errorView != nil {
                    self.errorView?.removeFromSuperview()
                }
                txtAddress!.text = selectedStr
                if indexPath.row == self.arrayAddressFiscalServiceNotEmpty.count{
                    self.arrayAddressFiscalServiceNotEmpty.append(newRegister)
                    self.direccionesFromService.append(selectedStr)
                }
                    let selection = self.arrayAddressFiscalServiceNotEmpty[indexPath.row]
                    txtIeps!.text = selection["rfcIeps"] as! String
                    txtEmail!.text = selection["correoElectronico"] as! String
                    idClienteSelected = selection["id"] as! String
                
                //self.selectedAnchxura = indexPath
                if delegateFormAdd != nil {
                    self.delegateFormAdd.showUpdate()
                }
            }
        }
    }
    
    func didDeSelectOption(_ picker:AlertPickerViewSections) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  txtAddress! {
                txtAddress!.text = ""
                //medidaLlanta.text="---/"+aspecto.text!+"R"+diametro.text!
            }
        }
    }
    
    func viewReplaceContent(_ frame:CGRect) -> UIView! {
        return UIView()
    }
    
    func cierraModal(_ sender:UIButton) {
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }

    func callServiceFiscalAddress(){
        if IS_IPAD{
            viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 46, width: 681.5, height: self.view.frame.height - 46))
        }else{
            viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 46, width: self.content.frame.size.width, height: self.view.frame.height - 46))
        }
        
        //self.tableOrders.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 155)
        
        viewLoad.backgroundColor = UIColor.white
        self.view.addSubview(viewLoad)
        viewLoad.startAnnimating(self.isVisibleTab)
        
        let addressService = InvoiceDataClientService()
        addressService.callService(params: ["rfc": self.RFCEscrito], successBlock: { (resultCall:[String:Any]) -> Void in
            
            self.arrayAddressFiscalService = [[:]]
            self.arrayAddressFiscalServiceNotEmpty = [[:]]
            self.direccionesFromService = []
            self.idClienteSelected = ""
            var responseOk : String! = ""
            if let headerData = resultCall["headerResponse"] as? [String:Any]{
                // now val is not nil and the Optional has been unwrapped, so use it
                responseOk = headerData["responseCode"] as! String
                
                if responseOk == "OK"{

                let businessData = resultCall["businessResponse"] as? [String:Any]
            
            if let fiscalAddress = businessData?["clienteList"] as? [[String:Any]] {
                self.arrayAddressFiscalService = fiscalAddress
            }
                
                    
            for register in self.arrayAddressFiscalService{
                
                    let domicilio = register["domicilio"] as! [String:Any]
                    let calle = domicilio["calle"] as! String
                    
                        if calle == ""{
                            self.idEmptySelected = register["id"] as! String
                        }else{
                            self.direccionesFromService.append(calle)
                            self.arrayAddressFiscalServiceNotEmpty.append(register)
                        }
                    if self.idClienteDefault == register["id"] as? String{
                        self.txtAddress?.text = calle
                        self.txtIeps?.text = register["rfcIeps"] as? String
                        self.idClienteSelected = self.idClienteDefault
                        self.txtEmail?.text = register["correoElectronico"] as? String
                    }
                }
                
            self.arrayAddressFiscalServiceNotEmpty.remove(at: 0)
                    if self.idClienteSelected == "" && self.arrayAddressFiscalServiceNotEmpty.count>0{
                        let dir1 = self.arrayAddressFiscalServiceNotEmpty[0]
                        let domicilio = dir1["domicilio"] as! [String:Any]
                        let calle = domicilio["calle"] as! String
                        if calle == ""{
                            self.checkSelected(self.btnNoAddress!)
                            self.idEmptySelected = dir1["id"] as! String
                        }else{
                            self.txtAddress?.text = calle
                            self.txtIeps?.text = dir1["rfcIeps"] as? String
                        }
                        self.idClienteSelected = dir1["id"] as! String
                        self.txtEmail?.text = dir1["correoElectronico"] as? String
                    }else{
                    self.checkSelected(self.btnNoAddress!)
                    }
                    

            print("sucess")
                    if self.viewLoad != nil{
                        self.viewLoad.stopAnnimating()
                    }
                    self.viewLoad = nil
            }else{
                let errorMess = headerData["reasons"] as! [[String:Any]]
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
                self.alertView!.setMessage(errorMess[0]["description"] as! String)
                self.alertView!.showDoneIcon()
                    if self.viewLoad != nil{
                        self.viewLoad.stopAnnimating()
                    }
                    self.viewLoad = nil
                    print("error")
                    self.checkSelected(self.btnNoAddress!)
                }
            }
        }, errorBlock: { (error:NSError) -> Void in
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage("Error en la conexión de datos, por favor intente mas tarde")
            self.alertView!.showDoneIcon()
            if self.viewLoad != nil{
                self.viewLoad.stopAnnimating()
            }
            self.viewLoad = nil
            print("errorBlock")
            self.back()
        })
    }

    func validateData() -> Bool{
        var error = false
        if !error{
            if !btnNoAddress!.isSelected{
                error = viewError(txtAddress!)
            }
        }
        if !error{
            error = viewError(txtEmail!)
        }
        if !error{
            error = validateTerms()
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
    
    func presentMessageTerms(_ view: UIView,  message: String, errorView : FormFieldErrorView){
        errorView.frame =  CGRect(x: 10, y: 0, width: view.frame.width, height: view.frame.height )
        errorView.focusError = nil
        errorView.setValues(280, strLabel:"", strValue: message)
        errorView.frame =  CGRect(x: 10, y: view.frame.minY, width: errorView.frame.width , height: errorView.frame.height)
        let contentView = view.superview!
        contentView.addSubview(errorView)
        contentView.bringSubview(toFront: view)
        UIView.animate(withDuration: 0.2, animations: {
            errorView.frame =  CGRect(x: 10, y: view.frame.minY - errorView.frame.height, width: errorView.frame.width , height: errorView.frame.height)
            contentView.bringSubview(toFront: errorView)
        }, completion: {(bool : Bool) in
            //                if bool {
            //                    self.acceptTerms!.setImage(UIImage(named:"checkTermError"), forState: UIControlState.Normal)
            //                }
        })
    }
    
    func validateTerms() -> Bool {
        
        if !btnPrivacity!.isSelected {
            if self.errorView == nil {
                self.errorView = FormFieldErrorView()
            }
            self.presentMessageTerms(self.btnPrivacity!, message: NSLocalizedString("invoice.validate.terms.conditions", comment: ""), errorView: self.errorView!)
            
            // Event -- Error Registration
            BaseController.sendAnalyticsUnsuccesfulRegistrationWithError("Términos y condiciones no aceptados", stepError: "Información legal")
            
            return true
            
        }
        return false
    }

    func saveEmptyAddress(){
        var paramsAddress : [String:Any]? = nil
        paramsAddress = ["rfc":self.RFCEscrito]
        paramsAddress?.updateValue(self.txtEmail!.text!, forKey: "correoElectronico")
        paramsAddress?.updateValue("true", forKey: "avisoLegalAceptado")
        paramsAddress?.updateValue("2017-04-15T18:23:15.820Z", forKey: "fechaAvisoLegal")
        var domicilioData : [String : Any]
        domicilioData = ["calle":"","ciudadEstado":"","codigoPostal":"","colonia":"","delegacionMunicipio":"","numeroExterior":"","numeroInterior":"","referencia":""]
        paramsAddress?.updateValue(domicilioData, forKey: "domicilio")

        let addresService =  InvoiceSaveRfcService()
        
        if paramsAddress != nil{
            let parametros = ["cliente":paramsAddress] as [String:Any]
            
            addresService.callService(params: parametros, successBlock:{ (resultCall:[String:Any]?) in
                var responseOk : String! = ""
                if let headerData = resultCall?["headerResponse"] as? [String:Any]{
                    // now val is not nil and the Optional has been unwrapped, so use it
                    responseOk = headerData["responseCode"] as! String
                    
                    if responseOk == "OK"{
                        
                        let businessData = resultCall?["businessResponse"] as? [String:Any]
                        
                        self.idClienteSelected = businessData?["clienteId"] as! String
                        
                        let ticketService = InvoiceResendService()
                        ticketService.callService(params: ["ticket":self.TicketEscrito, "email":self.txtEmail?.text, "idCliente":self.idClienteSelected], successBlock: { (resultCall:[String:Any]) -> Void in
                            var responseOk : String! = ""
                            if let headerData = resultCall["headerResponse"] as? [String:Any]{
                                // now val is not nil and the Optional has been unwrapped, so use it
                                responseOk = headerData["responseCode"] as! String
                                
                                if responseOk == "OK"{
                                    
                                    if self.viewLoad != nil{
                                        self.viewLoad.stopAnnimating()
                                    }
                                    self.viewLoad = nil
                                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
                                    self.alertView!.setMessage(NSLocalizedString("invoice.message.facturaOk",comment:"") + "\n" + (self.txtEmail?.text)!)
                                    self.alertView!.showDoneIconWithoutClose()
                                    self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
                                    self.back()
                                }else{
                                    let errorMess = headerData["responseDescription"] as! String
                                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                                    self.alertView!.setMessage(errorMess)
                                    self.alertView!.showErrorIcon("Fallo")
                                    self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
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
                    }else{
                        let errorMess = headerData["responseDescription"] as! String
                        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
                        self.alertView!.setMessage(errorMess)
                        self.alertView!.showErrorIcon("Fallo")
                        self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
                        if self.viewLoad != nil{
                            self.viewLoad.stopAnnimating()
                        }
                        self.viewLoad = nil
                        print("error")
                    }
                }
            }
                , errorBlock: {(error: NSError) in
                    self.alertView?.setMessage(error.localizedDescription)
                    self.alertView?.showErrorIcon("Ok")
            })
        }
    }

    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if IS_IPAD{
        moveTextField(textField, moveDistance: -150, up: true)
        }else{
        moveTextField(textField, moveDistance: -60, up: true)
        }
        
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        if IS_IPAD{
        moveTextField(textField, moveDistance: -150, up: false)
        }else{
        moveTextField(textField, moveDistance: -60, up: false)
        }
        
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
