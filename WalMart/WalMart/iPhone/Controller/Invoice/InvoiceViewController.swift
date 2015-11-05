//
//  InvoiceViewController.swift
//  
//
//  Created by Alonso Salcido on 26/10/15.
//
//

import Foundation

class InvoiceViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate,UIScrollViewDelegate {
    let secSep: CGFloat = 30.0
    let titleSep: CGFloat = 15.0
    let fieldSep: CGFloat = 10.0
    let headerHeight: CGFloat = 46
    
    var content: TPKeyboardAvoidingScrollView!
    var alertView: IPOWMAlertInfoViewController?
    var rfc: FormFieldView?
    var zipCode: FormFieldView?
    var ticketNumber: FormFieldView?
    var transactionNumber: FormFieldView?
    
    var sectionTitle : UILabel!
    var sectionUserInfo : UILabel!
    var sectionTicketInfo : UILabel!
    var infoMessage: UILabel!
    
    var invoiceSelect: UIButton?
    var consultSelect: UIButton?
    var scanTicketButton: UIButton?
    var nextButton: UIButton?
    var cancelButton: UIButton?
    var infoTCButton: UIButton?
    var infoTRButton: UIButton?
    
    var modalView: AlertModalView?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_INVOICE.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.titleLabel?.text = NSLocalizedString("moreoptions.title.Factura",comment:"")
        self.showInfoAlert()
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRectMake(0.0, headerHeight, self.view.bounds.width, self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content)
        
        let margin: CGFloat = 15.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 40.0
        let lheight: CGFloat = 25.0
        let widthLessMargin = self.view.frame.width - margin
        let checkTermEmpty : UIImage = UIImage(named:"check_empty")!
        let checkTermFull : UIImage = UIImage(named:"check_full")!
        
        
        //Inician secciones
        self.sectionTitle = self.buildSectionTitle("¿Que deseas hacer?", frame: CGRectMake(margin, 5.0, width, lheight))
        self.content.addSubview(sectionTitle)
        
        invoiceSelect = UIButton(frame: CGRectMake(margin,sectionTitle.frame.maxY,80,fheight))
        invoiceSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        invoiceSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        invoiceSelect!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        invoiceSelect!.setTitle("Factura", forState: UIControlState.Normal)
        invoiceSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        invoiceSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        invoiceSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0)
        invoiceSelect!.selected = true
        self.content.addSubview(self.invoiceSelect!)
        
        self.consultSelect = UIButton(frame: CGRectMake(invoiceSelect!.frame.maxX + 31,sectionTitle.frame.maxY,90,fheight))
        consultSelect!.setImage(checkTermEmpty, forState: UIControlState.Normal)
        consultSelect!.setImage(checkTermFull, forState: UIControlState.Selected)
        consultSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        consultSelect!.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        consultSelect!.setTitle("Consultar", forState: UIControlState.Normal)
        consultSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0)
        consultSelect!.setTitleColor(WMColor.loginTermsConditionTextColor, forState: UIControlState.Normal)
        self.content.addSubview(self.consultSelect!)
        
        self.sectionUserInfo = self.buildSectionTitle("Tus Datos", frame: CGRectMake(margin, self.invoiceSelect!.frame.maxY + 5.0, width, lheight))
        self.content.addSubview(sectionUserInfo)
        
        self.rfc = FormFieldView(frame: CGRectMake(margin, self.sectionUserInfo!.frame.maxY + 10.0, width, fheight))
        self.rfc!.isRequired = true
        self.rfc!.setCustomPlaceholder("RFC")
        self.rfc!.typeField = TypeField.String
        self.rfc!.nameField = "RFC"
        self.rfc!.maxLength = 13
        self.content.addSubview(self.rfc!)
        self.zipCode = FormFieldView(frame: CGRectMake(margin, self.rfc!.frame.maxY + 5.0, width, fheight))
        self.zipCode!.isRequired = true
        self.zipCode!.setCustomPlaceholder("Codigo Postal")
        self.zipCode!.typeField = TypeField.String
        self.zipCode!.nameField = "Codigo Postal"
        self.zipCode!.maxLength = 6
        self.content.addSubview(self.zipCode!)
        
        self.sectionTicketInfo = self.buildSectionTitle("Datos de tu compra", frame: CGRectMake(margin, self.zipCode!.frame.maxY + 10.0, width, lheight))
        self.content.addSubview(sectionTicketInfo)
        
        self.scanTicketButton = UIButton(frame: CGRectMake(margin, self.sectionTicketInfo!.frame.maxY + 10.0, width, 30.0))
        self.scanTicketButton!.setTitle("Ingresar datos escaneando tu ticket", forState: UIControlState.Normal)
        self.scanTicketButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 15)
        self.scanTicketButton!.setImage(UIImage(named: "invoice_scan_ticket"), forState: UIControlState.Normal)
        self.scanTicketButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.scanTicketButton!.titleLabel!.textAlignment = NSTextAlignment.Center
        self.scanTicketButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.scanTicketButton!.backgroundColor = WMColor.listAddressHeaderSectionColor
        self.scanTicketButton!.layer.cornerRadius = 12
        self.content.addSubview(self.scanTicketButton!)
        
        self.infoMessage = UILabel(frame:  CGRectMake(margin, self.scanTicketButton!.frame.maxY + 10.0, width, lheight))
        infoMessage!.textColor = UIColor.grayColor()
        infoMessage!.font = WMFont.fontMyriadProLightOfSize(14)
        infoMessage!.text = "O ingresa manualmente los datos"
        infoMessage!.backgroundColor = UIColor.whiteColor()
        self.content.addSubview(infoMessage)
        
        self.ticketNumber = FormFieldView(frame: CGRectMake(margin, infoMessage.frame.maxY + 10.0, width - 24, fheight))
        self.ticketNumber!.isRequired = true
        var placeholder = NSMutableAttributedString()
        placeholder.appendAttributedString(NSAttributedString(string: "Número de ticket - ", attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.loginFieldTextPlaceHolderColor]))
        placeholder.appendAttributedString(NSAttributedString(string: "TC# en tu ticket", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(13),NSForegroundColorAttributeName:WMColor.loginFieldTextPlaceHolderColor]))
        self.ticketNumber!.setCustomAttributedPlaceholder(placeholder)
        self.ticketNumber!.typeField = TypeField.String
        self.ticketNumber!.nameField = "ticketNumber"
        self.ticketNumber!.maxLength = 13
        self.content.addSubview(self.ticketNumber!)
        
        self.transactionNumber = FormFieldView(frame: CGRectMake(margin, self.ticketNumber!.frame.maxY + 5.0, width - 24, fheight))
        self.transactionNumber!.isRequired = true
        placeholder = NSMutableAttributedString()
        placeholder.appendAttributedString(NSAttributedString(string: "Número de transaccion - ", attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.loginFieldTextPlaceHolderColor]))
        placeholder.appendAttributedString(NSAttributedString(string: "TR# en tu ticket", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(13),NSForegroundColorAttributeName:WMColor.loginFieldTextPlaceHolderColor]))
        self.transactionNumber!.setCustomAttributedPlaceholder(placeholder)
        self.transactionNumber!.typeField = TypeField.String
        self.transactionNumber!.nameField = "transactionNumber"
        self.transactionNumber!.maxLength = 13
        self.content.addSubview(self.transactionNumber!)
        
        self.infoTCButton = UIButton(frame: CGRectMake(widthLessMargin - 16, infoMessage.frame.maxY + 20.0, 16, 16))
        self.infoTCButton!.setBackgroundImage(UIImage(named:"invoice_info"), forState: UIControlState.Normal)
        self.infoTCButton!.addTarget(self, action: "infoImage:", forControlEvents: UIControlEvents.TouchUpInside)
        self.content.addSubview(self.infoTCButton!)
        
        self.infoTRButton = UIButton(frame: CGRectMake(widthLessMargin - 16, self.ticketNumber!.frame.maxY + 20.0, 16, 16))
        self.infoTRButton!.setBackgroundImage(UIImage(named:"invoice_info"), forState: UIControlState.Normal)
        self.infoTRButton!.addTarget(self, action: "infoImage:", forControlEvents: UIControlEvents.TouchUpInside)
        self.content.addSubview(self.infoTRButton!)
        
        self.content.contentSize = CGSizeMake(self.view.frame.width, transactionNumber!.frame.maxY + 5.0)
        
        self.cancelButton = UIButton(frame: CGRectMake(margin, self.content!.frame.maxY + 5.0, 140.0, fheight))
        self.cancelButton!.setTitle("Cancelar", forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.listAddressHeaderSectionColor
        self.cancelButton!.layer.cornerRadius = 20
        self.cancelButton!.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.nextButton = UIButton(frame: CGRectMake(widthLessMargin - 140 , self.content!.frame.maxY + 5.0, 140.0, fheight))
        self.nextButton!.setTitle("Siguiente", forState:.Normal)
        self.nextButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.nextButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.nextButton!.backgroundColor = WMColor.loginSignInButonBgColor
        self.nextButton!.layer.cornerRadius = 20
        self.nextButton!.addTarget(self, action: "next", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(nextButton!)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRectMake(0.0, headerHeight, self.view.bounds.width, self.view.bounds.height - (headerHeight + 120))
        
        let margin: CGFloat = 15.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 40.0
        let lheight: CGFloat = 25.0
        let widthLessMargin = self.view.frame.width - margin
        
        //Inician secciones
        self.sectionTitle!.frame = CGRectMake(margin, 5.0, width, lheight)
        self.invoiceSelect!.frame = CGRectMake(margin,sectionTitle.frame.maxY,80,fheight)
        self.consultSelect!.frame = CGRectMake(invoiceSelect!.frame.maxX + 31,sectionTitle.frame.maxY,90,fheight)
        self.sectionUserInfo.frame = CGRectMake(margin, self.invoiceSelect!.frame.maxY + 5.0, width, lheight)
        self.rfc!.frame = CGRectMake(margin, self.sectionUserInfo!.frame.maxY + 10.0, width, fheight)
        self.zipCode!.frame = CGRectMake(margin, self.rfc!.frame.maxY + 5.0, width, fheight)
        self.sectionTicketInfo.frame = CGRectMake(margin, self.zipCode!.frame.maxY + 10.0, width, lheight)
        self.scanTicketButton!.frame = CGRectMake(margin, self.sectionTicketInfo!.frame.maxY + 10.0, width, 30.0)
        self.infoMessage.frame =  CGRectMake(margin, self.scanTicketButton!.frame.maxY + 10.0, width, lheight)
        self.ticketNumber!.frame = CGRectMake(margin, infoMessage.frame.maxY + 10.0, width - 24, fheight)
        self.transactionNumber!.frame = CGRectMake(margin, self.ticketNumber!.frame.maxY + 5.0, width - 24, fheight)
        self.infoTCButton!.frame = CGRectMake(widthLessMargin - 16, infoMessage.frame.maxY + 20.0, 16, 16)
        self.infoTRButton!.frame = CGRectMake(widthLessMargin - 16, self.ticketNumber!.frame.maxY + 20.0, 16, 16)
        self.content.contentSize = CGSizeMake(self.view.frame.width, transactionNumber!.frame.maxY + 5.0)
        //self.cancelButton!.frame = CGRectMake(margin, self.content!.frame.maxY + 5.0, 140.0, fheight)
        //self.nextButton!.frame = CGRectMake(widthLessMargin - 140 , self.content!.frame.maxY + 5.0, 140.0, fheight)
    }

    
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.listAddressHeaderSectionColor
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
    
    func checkSelected(sender:UIButton) {
        if sender.selected{
            return
        }
        if sender == self.invoiceSelect{
            self.consultSelect!.selected = false
        }else{
            self.invoiceSelect!.selected = false
        }
        sender.selected = !(sender.selected)
    }
    
    override func back() {
        self.showCancelAlert()
    }
    
    func infoImage(sender:UIButton){
        var title = ""
        var imageName = ""
        if sender == self.infoTCButton{
            title = "TC# en tu Ticket"
            imageName = "ticket_tc"
        }else{
            title = "TR# en tu Ticket"
            imageName = "ticket_tr"
        }
       self.modalView = AlertModalView.showAlertWithImage(title, contentViewSize: CGSize(width: 288, height: 470), image: UIImage(named: imageName)!)
    }
    
    func showCancelAlert(){
        let message = NSMutableAttributedString()
        message.appendAttributedString(NSAttributedString(string: "¿Seguro que deseas cerrar Facturación Electrónica? \n Los datos no serán guardados", attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(18),NSForegroundColorAttributeName:UIColor.whiteColor()]))
        self.alertView = IPOWMAlertInfoViewController.showAttributedAlert("", message:message)
        self.alertView?.messageLabel.textAlignment = .Center
        self.alertView?.setMessageLabelToCenter(225.0)
        self.alertView?.addActionButtonsWithCustomText("Cancelar", leftAction: {(void) in
            self.alertView?.close() }, rightText: "Continuar", rightAction: { (void) in
            self.alertView?.close()
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
    
    func showInfoAlert(){
        let message = NSMutableAttributedString()
        message.appendAttributedString(NSAttributedString(string: "Vigencia: ", attributes: [NSFontAttributeName : WMFont.fontMyriadProBoldOfSize(15),NSForegroundColorAttributeName:UIColor.whiteColor()]))
        message.appendAttributedString(NSAttributedString(string: "Debe hacerlo en un periodo no mayor a los 7 días naturales después de haber realizado su compra (fecha impresa en el ticket)", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(15),NSForegroundColorAttributeName:UIColor.whiteColor()]))
        message.appendAttributedString(NSAttributedString(string: "\n \n Resguardo: ", attributes: [NSFontAttributeName : WMFont.fontMyriadProBoldOfSize(15),NSForegroundColorAttributeName:UIColor.whiteColor()]))
        message.appendAttributedString(NSAttributedString(string: "Para poder realizar su factura o cualquier modificación o consulta, es importante que siempre conserve su ticket de compra, de lo contrario, no se podrá realizar ningún movimiento o consulta.", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(15),NSForegroundColorAttributeName:UIColor.whiteColor()]))
        
        
        self.alertView = IPOWMAlertInfoViewController.showAttributedAlert("Avisos", message: message)
        self.alertView?.showOkButton("Continuar", colorButton: WMColor.loginSignInButonBgColor)
    }
    
    func next(){
        let invoiceController = InvoiceComplementViewController()
        self.navigationController!.pushViewController(invoiceController, animated: true)
    }
}