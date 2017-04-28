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

class InvoiceDataViewController: NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate, AlertPickerViewSectionsDelegate{
    
    let headerHeight: CGFloat = 46
    
    var content: TPKeyboardAvoidingScrollView!
    
    var txtAddress: FormFieldView?
    var txtIeps: FormFieldView?
    var txtEmail: FormFieldView?
    
    var lblAddressTitle : UILabel!
    var lblIepsTitle : UILabel!
    var lblEmailTitle : UILabel!
    var lblPrivacyTitle : UILabel!
    
    var btnNoAddress : UIButton?
    var btnNoIeps : UIButton?
    var btnPrivacity : UIButton?
    
    var btnCancel : UIButton?
    var btnFacturar : UIButton?
    var alertView : IPOWMAlertViewController? = nil
    
    var picker: AlertPickerViewSections!
    var delegateFormAdd : FormSuperAddressViewDelegate!
    var direccionesFromApp : [String]! = []
    var direccionesFromService : [String]! = []
    var tipoFacturacion : TypeSend = TypeSend.newInvoice
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_INVOICE.rawValue
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = NSLocalizedString("moreoptions.title.Invoice",comment:"")
        // Do any additional setup after loading the view.
        
        picker = AlertPickerViewSections.initPickerWithDefaultNewAddressButton()
        
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
        
        //SECCION 1
        fheight = (section1Bottom - section1Top)/6
        self.lblAddressTitle = self.buildSectionTitle(NSLocalizedString("invoice.section.addressTitle",comment:""), frame: CGRect(x: margin, y: fheight, width: sectionWidth, height: fheight))
        self.lblAddressTitle.sizeToFit()
        self.content.addSubview(lblAddressTitle)

        //CAPTURA RFC
        self.txtAddress = FormFieldView(frame: CGRect(x: margin, y: lblAddressTitle.frame.maxY + fheight, width: sectionWidth - 2*margin, height: 2*fheight))
        self.txtAddress!.isRequired = true
        let placeholder = NSMutableAttributedString()
        placeholder.append(NSAttributedString(string: NSLocalizedString("invoice.field.address",comment:"")
            , attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
        self.txtAddress!.setCustomAttributedPlaceholder(placeholder)
        self.txtAddress!.typeField = TypeField.string
        self.txtAddress!.nameField = "Direcciones encontradas"
        //self.txtAddress!.maxLength = 13
        self.content.addSubview(self.txtAddress!)
        
        self.btnNoAddress = UIButton(frame: CGRect(x: margin, y: txtAddress!.frame.maxY + fheight/3, width: (sectionWidth - 2*margin), height: 2*fheight))
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
        
        //SECCION 2
        fheight = (section2Bottom - section2Top)/6
        self.lblIepsTitle = self.buildSectionTitle(NSLocalizedString("invoice.section.iepsTitle",comment:""), frame: CGRect(x: margin, y: section2Top + 2*fheight, width: sectionWidth, height: fheight))
        self.lblIepsTitle.sizeToFit()
        self.content.addSubview(lblIepsTitle)
        
        //CAPTURA RFC
        self.txtIeps = FormFieldView(frame: CGRect(x: margin, y: lblIepsTitle.frame.maxY + fheight, width: sectionWidth - 2*margin, height: 2*fheight))
        self.txtIeps!.isRequired = true
        let placeholder2 = NSMutableAttributedString()
        placeholder2.append(NSAttributedString(string: NSLocalizedString("invoice.field.ieps",comment:"")
            , attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
        self.txtIeps!.setCustomAttributedPlaceholder(placeholder2)
        self.txtIeps!.typeField = TypeField.alphanumeric
        self.txtIeps!.nameField = "ieps"
        //self.txtIeps!.maxLength = 13
        self.content.addSubview(self.txtIeps!)
        
        self.btnNoIeps = UIButton(frame: CGRect(x: margin, y: txtIeps!.frame.maxY + fheight/3, width: (sectionWidth - 2*margin), height: 2*fheight))
        btnNoIeps!.setImage(checkEmpty, for: UIControlState())
        btnNoIeps!.setImage(checkFull, for: UIControlState.selected)
        btnNoIeps!.addTarget(self, action: #selector(self.checkSelected(_:)), for: UIControlEvents.touchUpInside)
        btnNoIeps!.setTitle(NSLocalizedString("invoice.button.noieps",comment:""), for: UIControlState())
        btnNoIeps!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        btnNoIeps!.setTitleColor(WMColor.gray, for: UIControlState())
        btnNoIeps!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 10.0, 0, 0.0)
        btnNoIeps!.isSelected = false
        btnNoIeps!.contentHorizontalAlignment = .left
        self.content.addSubview(self.btnNoIeps!)

        
        //SECCION 3
        fheight = (section3Bottom - section3Top)/6
        self.lblEmailTitle = self.buildSectionTitle(NSLocalizedString("invoice.section.emailTitle",comment:""), frame: CGRect(x: margin, y: section3Top + 3*fheight, width: sectionWidth, height: fheight))
        self.lblEmailTitle.sizeToFit()
        self.content.addSubview(lblEmailTitle)
        
        //CAPTURA RFC
        self.txtEmail = FormFieldView(frame: CGRect(x: margin, y: lblEmailTitle.frame.maxY + fheight, width: sectionWidth - 2*margin, height: 2*fheight))
        self.txtEmail!.isRequired = true
        self.txtEmail!.typeField = TypeField.email
        self.txtEmail!.nameField = "email"
        self.txtEmail?.text = UserCurrentSession.sharedInstance.userSigned!.email as String
        self.content.addSubview(self.txtEmail!)
        
        let lblConsulta : UILabel!
        lblConsulta = UILabel(frame: CGRect(x: margin, y: txtEmail!.frame.maxY + fheight, width: sectionWidth/2, height: 20))
        lblConsulta.text = "Consulta nuestro "
        lblConsulta.font=WMFont.fontMyriadProRegularOfSize(14)
        lblConsulta.textColor=WMColor.dark_gray
        lblConsulta.sizeToFit()
        self.content.addSubview(lblConsulta!)
        
        self.btnPrivacity = UIButton(frame: CGRect(x: lblConsulta.frame.maxX, y: txtEmail!.frame.maxY + fheight, width: (sectionWidth - 2*margin - lblConsulta.frame.width), height: 20))
        btnPrivacity!.addTarget(self, action: #selector(self.showPrivacyNotice(_:)), for: UIControlEvents.touchUpInside)
        btnPrivacity!.setTitle(NSLocalizedString("profile.privacy.notice",comment:""), for: UIControlState())
        btnPrivacity!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        btnPrivacity!.setTitleColor(WMColor.dark_blue, for: UIControlState())
        btnPrivacity!.isSelected = false
        btnPrivacity!.contentHorizontalAlignment = .left
        btnPrivacity!.contentVerticalAlignment = .top
        self.content.addSubview(self.btnPrivacity!)

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
        
        self.direccionesFromApp = ["DirApp1","DirApp2"]
        
        self.direccionesFromService = ["DirService1","DirService2","DirService3"]
        
        txtAddress?.onBecomeFirstResponder = { () in
            
                //self.anchura!.text = self.valAnchuras[0]
                //self.selectedAnchura = IndexPath(row: 0, section: 0)

                self.picker!.selected = IndexPath(row: 0, section: 0)
                self.picker!.sender = self.txtAddress!
                self.picker!.delegate = self
            self.picker!.setValues(self.txtAddress!.nameField, values: self.direccionesFromApp, values2: self.direccionesFromService)
                self.picker!.showPicker()
        }

        
        /*"invoice.section.addressTitle" = "Dirección de Facturación";
 "invoice.field.address" = "Agregar nueva dirección de facturación";
 "invoice.button.noaddress" = "Agregar nueva dirección de facturación";*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func buildSectionTitle(_ title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(15)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.white
        return sectionTitle
    }

    func facturar(_ sender:UIButton){
        
        if tipoFacturacion == TypeSend.newInvoice{
            self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(NSLocalizedString("invoice.message.facturaOk",comment:"") + "\n" + (txtEmail?.text)!)
            self.alertView!.showDoneIconWithoutClose()
            self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
        }else{
            self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(NSLocalizedString("invoice.message.facturaResend",comment:"") + "\n\n" + NSLocalizedString("invoice.message.facturaResendEmail",comment:"") + "\n" + (txtEmail?.text)!)
            self.alertView!.showDoneIconWithoutClose()
            self.alertView!.showOkButton("Ok", colorButton: WMColor.green)
        }
        //self.performSegue(withIdentifier: "invoiceDataController", sender: self)
        
        
        /*"invoice.message.facturaOk" = "La factura ha sido enviada a:";
        "invoice.message.facturaResend" = "Factura reenviada con éxito.";
        "invoice.message.facturaResendEmail" = "Te la hemos enviado a";*/
    }
    
    func showPrivacyNotice(_ sender:UIButton){
        let previewHelp = PreviewHelpViewController()
        previewHelp.titleText = NSLocalizedString("help.item.privacy.notice", comment: "") as NSString!
        previewHelp.resource = "privacy"
        previewHelp.type = "pdf"
        self.navigationController!.pushViewController(previewHelp,animated:true)
    }
    
    func checkSelected(_ sender:UIButton) {
        sender.isSelected = !(sender.isSelected)
        
        if sender == self.btnNoAddress{
            txtAddress?.isEnabled = !(sender.isSelected)
            txtAddress?.text = ""
        }else{
            txtIeps?.isEnabled = !(sender.isSelected)
            txtIeps?.text = ""
        }
        
    }

    
    func saveReplaceViewSelected() {
    }
    
    func buttomViewSelected(_ sender: UIButton) {
        
    }
    
    func didSelectOption(_ picker:AlertPickerViewSections, indexPath:IndexPath ,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  txtAddress! {
                txtAddress!.text = selectedStr
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
            }/*
            if formFieldObj ==  aspecto! {
                aspecto!.text = ""
                medidaLlanta.text=anchura.text!+"/--R"+diametro.text!
            }
            if formFieldObj ==  diametro! {
                diametro!.text = ""
                medidaLlanta.text=anchura.text!+"/"+aspecto.text!+"R--"
            }*/
        }
    }
    
    func viewReplaceContent(_ frame:CGRect) -> UIView! {
        return UIView()
    }
    
    func cierraModal(_ sender:UIButton) {
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }


}
