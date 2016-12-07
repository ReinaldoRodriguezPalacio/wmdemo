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
        self.view.backgroundColor = UIColor.white
        self.titleLabel?.text = NSLocalizedString("moreoptions.title.Invoice",comment:"")
        self.showInfoAlert()
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.white
        self.view.addSubview(self.content)
        
        let margin: CGFloat = 15.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 40.0
        let lheight: CGFloat = 25.0
        let widthLessMargin = self.view.frame.width - margin
        let checkTermEmpty : UIImage = UIImage(named:"check_empty")!
        let checkTermFull : UIImage = UIImage(named:"check_full")!
        
        
        //Inician secciones
        self.sectionTitle = self.buildSectionTitle(NSLocalizedString("invoice.section.actionToDo",comment:""), frame: CGRect(x: margin, y: 5.0, width: width, height: lheight))
        self.content.addSubview(sectionTitle)
        
        invoiceSelect = UIButton(frame: CGRect(x: margin,y: sectionTitle.frame.maxY,width: 80,height: fheight))
        invoiceSelect!.setImage(checkTermEmpty, for: UIControlState())
        invoiceSelect!.setImage(checkTermFull, for: UIControlState.selected)
        invoiceSelect!.addTarget(self, action: #selector(InvoiceViewController.checkSelected(_:)), for: UIControlEvents.touchUpInside)
        invoiceSelect!.setTitle(NSLocalizedString("invoice.button.invoice",comment:""), for: UIControlState())
        invoiceSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        invoiceSelect!.setTitleColor(WMColor.gray, for: UIControlState())
        invoiceSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0)
        invoiceSelect!.isSelected = true
        self.content.addSubview(self.invoiceSelect!)
        
        self.consultSelect = UIButton(frame: CGRect(x: invoiceSelect!.frame.maxX + 31,y: sectionTitle.frame.maxY,width: 90,height: fheight))
        consultSelect!.setImage(checkTermEmpty, for: UIControlState())
        consultSelect!.setImage(checkTermFull, for: UIControlState.selected)
        consultSelect!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        consultSelect!.addTarget(self, action: #selector(InvoiceViewController.checkSelected(_:)), for: UIControlEvents.touchUpInside)
        consultSelect!.setTitle(NSLocalizedString("invoice.button.consult",comment:""), for: UIControlState())
        consultSelect!.titleEdgeInsets = UIEdgeInsetsMake(4.0, 15.0, 0, 0.0)
        consultSelect!.setTitleColor(WMColor.gray, for: UIControlState())
        self.content.addSubview(self.consultSelect!)
        
        self.sectionUserInfo = self.buildSectionTitle(NSLocalizedString("invoice.section.yourdata",comment:""), frame: CGRect(x: margin, y: self.invoiceSelect!.frame.maxY + 5.0, width: width, height: lheight))
        self.content.addSubview(sectionUserInfo)
        
        self.rfc = FormFieldView(frame: CGRect(x: margin, y: self.sectionUserInfo!.frame.maxY + 10.0, width: width, height: fheight))
        self.rfc!.isRequired = true
        self.rfc!.setCustomPlaceholder(NSLocalizedString("invoice.field.rfc",comment:""))
        self.rfc!.typeField = TypeField.string
        self.rfc!.nameField = "rfc"
        self.rfc!.maxLength = 13
        self.content.addSubview(self.rfc!)
        self.zipCode = FormFieldView(frame: CGRect(x: margin, y: self.rfc!.frame.maxY + 5.0, width: width, height: fheight))
        self.zipCode!.isRequired = true
        self.zipCode!.setCustomPlaceholder(NSLocalizedString("invoice.field.zipcode",comment:""))
        self.zipCode!.typeField = TypeField.string
        self.zipCode!.nameField = "zipCodce"
        self.zipCode!.maxLength = 6
        self.content.addSubview(self.zipCode!)
        
        self.sectionTicketInfo = self.buildSectionTitle(NSLocalizedString("invoice.section.purchase.data",comment:""), frame: CGRect(x: margin, y: self.zipCode!.frame.maxY + 10.0, width: width, height: lheight))
        self.content.addSubview(sectionTicketInfo)
        
        self.scanTicketButton = UIButton(frame: CGRect(x: margin, y: self.sectionTicketInfo!.frame.maxY + 10.0, width: width, height: 30.0))
        self.scanTicketButton!.setTitle(NSLocalizedString("invoice.button.scan",comment:""), for: UIControlState())
        self.scanTicketButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 15)
        self.scanTicketButton!.setImage(UIImage(named: "invoice_scan_ticket"), for: UIControlState())
        self.scanTicketButton!.titleLabel!.textColor = UIColor.white
        self.scanTicketButton!.titleLabel!.textAlignment = NSTextAlignment.center
        self.scanTicketButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.scanTicketButton!.backgroundColor = WMColor.light_blue
        self.scanTicketButton!.layer.cornerRadius = 12
        self.content.addSubview(self.scanTicketButton!)
        
        self.infoMessage = UILabel(frame:  CGRect(x: margin, y: self.scanTicketButton!.frame.maxY + 10.0, width: width, height: lheight))
        infoMessage!.textColor = UIColor.gray
        infoMessage!.font = WMFont.fontMyriadProLightOfSize(14)
        infoMessage!.text = NSLocalizedString("invoice.section.write",comment:"")
        infoMessage!.backgroundColor = UIColor.white
        self.content.addSubview(infoMessage)
        
        self.ticketNumber = FormFieldView(frame: CGRect(x: margin, y: infoMessage.frame.maxY + 10.0, width: width - 24, height: fheight))
        self.ticketNumber!.isRequired = true
        var placeholder = NSMutableAttributedString()
        placeholder.append(NSAttributedString(string: NSLocalizedString("invoice.field.ticketnumber",comment:"")
, attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
        placeholder.append(NSAttributedString(string:NSLocalizedString("invoice.field.tc",comment:""), attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
        self.ticketNumber!.setCustomAttributedPlaceholder(placeholder)
        self.ticketNumber!.typeField = TypeField.string
        self.ticketNumber!.nameField = "ticketNumber"
        self.ticketNumber!.maxLength = 13
        self.content.addSubview(self.ticketNumber!)
        
        self.transactionNumber = FormFieldView(frame: CGRect(x: margin, y: self.ticketNumber!.frame.maxY + 5.0, width: width - 24, height: fheight))
        self.transactionNumber!.isRequired = true
        placeholder = NSMutableAttributedString()
        placeholder.append(NSAttributedString(string: NSLocalizedString("invoice.field.transactionnumber",comment:""), attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
        placeholder.append(NSAttributedString(string: NSLocalizedString("invoice.field.tr",comment:""), attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
        self.transactionNumber!.setCustomAttributedPlaceholder(placeholder)
        self.transactionNumber!.typeField = TypeField.string
        self.transactionNumber!.nameField = "transactionNumber"
        self.transactionNumber!.maxLength = 13
        self.content.addSubview(self.transactionNumber!)
        
        self.infoTCButton = UIButton(frame: CGRect(x: widthLessMargin - 16, y: infoMessage.frame.maxY + 20.0, width: 16, height: 16))
        self.infoTCButton!.setBackgroundImage(UIImage(named:"invoice_info"), for: UIControlState())
        self.infoTCButton!.addTarget(self, action: #selector(InvoiceViewController.infoImage(_:)), for: UIControlEvents.touchUpInside)
        self.content.addSubview(self.infoTCButton!)
        
        self.infoTRButton = UIButton(frame: CGRect(x: widthLessMargin - 16, y: self.ticketNumber!.frame.maxY + 20.0, width: 16, height: 16))
        self.infoTRButton!.setBackgroundImage(UIImage(named:"invoice_info"), for: UIControlState())
        self.infoTRButton!.addTarget(self, action: #selector(InvoiceViewController.infoImage(_:)), for: UIControlEvents.touchUpInside)
        self.content.addSubview(self.infoTRButton!)
        
        self.content.contentSize = CGSize(width: self.view.frame.width, height: transactionNumber!.frame.maxY + 5.0)
        
        self.cancelButton = UIButton(frame: CGRect(x: margin, y: self.content!.frame.maxY + 5.0, width: 140.0, height: fheight))
        self.cancelButton!.setTitle(NSLocalizedString("invoice.button.cancel",comment:""), for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.light_blue
        self.cancelButton!.layer.cornerRadius = 20
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.nextButton = UIButton(frame: CGRect(x: widthLessMargin - 140 , y: self.content!.frame.maxY + 5.0, width: 140.0, height: fheight))
        self.nextButton!.setTitle(NSLocalizedString("invoice.button.next",comment:""), for:UIControlState())
        self.nextButton!.titleLabel!.textColor = UIColor.white
        self.nextButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.nextButton!.backgroundColor = WMColor.green
        self.nextButton!.layer.cornerRadius = 20
        self.nextButton!.addTarget(self, action: #selector(getter: InvoiceViewController.next), for: UIControlEvents.touchUpInside)
        self.view.addSubview(nextButton!)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.bounds.width, height: self.view.bounds.height - (headerHeight + 120))
        
        let margin: CGFloat = 15.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 40.0
        let lheight: CGFloat = 25.0
        let widthLessMargin = self.view.frame.width - margin
        
        //Inician secciones
        self.sectionTitle!.frame = CGRect(x: margin, y: 5.0, width: width, height: lheight)
        self.invoiceSelect!.frame = CGRect(x: margin,y: sectionTitle.frame.maxY,width: 80,height: fheight)
        self.consultSelect!.frame = CGRect(x: invoiceSelect!.frame.maxX + 31,y: sectionTitle.frame.maxY,width: 90,height: fheight)
        self.sectionUserInfo.frame = CGRect(x: margin, y: self.invoiceSelect!.frame.maxY + 5.0, width: width, height: lheight)
        self.rfc!.frame = CGRect(x: margin, y: self.sectionUserInfo!.frame.maxY + 10.0, width: width, height: fheight)
        self.zipCode!.frame = CGRect(x: margin, y: self.rfc!.frame.maxY + 5.0, width: width, height: fheight)
        self.sectionTicketInfo.frame = CGRect(x: margin, y: self.zipCode!.frame.maxY + 10.0, width: width, height: lheight)
        self.scanTicketButton!.frame = CGRect(x: margin, y: self.sectionTicketInfo!.frame.maxY + 10.0, width: width, height: 30.0)
        self.infoMessage.frame =  CGRect(x: margin, y: self.scanTicketButton!.frame.maxY + 10.0, width: width, height: lheight)
        self.ticketNumber!.frame = CGRect(x: margin, y: infoMessage.frame.maxY + 10.0, width: width - 24, height: fheight)
        self.transactionNumber!.frame = CGRect(x: margin, y: self.ticketNumber!.frame.maxY + 5.0, width: width - 24, height: fheight)
        self.infoTCButton!.frame = CGRect(x: widthLessMargin - 16, y: infoMessage.frame.maxY + 20.0, width: 16, height: 16)
        self.infoTRButton!.frame = CGRect(x: widthLessMargin - 16, y: self.ticketNumber!.frame.maxY + 20.0, width: 16, height: 16)
        self.content.contentSize = CGSize(width: self.view.frame.width, height: transactionNumber!.frame.maxY + 5.0)
        //self.cancelButton!.frame = CGRectMake(margin, self.content!.frame.maxY + 5.0, 140.0, fheight)
        //self.nextButton!.frame = CGRectMake(widthLessMargin - 140 , self.content!.frame.maxY + 5.0, 140.0, fheight)
    }

    
    func buildSectionTitle(_ title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.white
        return sectionTitle
    }
    
    func checkSelected(_ sender:UIButton) {
        if sender.isSelected{
            return
        }
        if sender == self.invoiceSelect{
            self.consultSelect!.isSelected = false
        }else{
            self.invoiceSelect!.isSelected = false
        }
        sender.isSelected = !(sender.isSelected)
    }
    
    override func back() {
        self.showCancelAlert()
    }
    
    func infoImage(_ sender:UIButton){
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
        message.append(NSAttributedString(string: NSLocalizedString("invoice.message.exit",comment:""), attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(18),NSForegroundColorAttributeName:UIColor.white]))
        self.alertView = IPOWMAlertInfoViewController.showAttributedAlert("", message:message)
        self.alertView?.messageLabel.textAlignment = .center
        self.alertView?.setMessageLabelToCenter(225.0)
        self.alertView?.addActionButtonsWithCustomText(NSLocalizedString("invoice.button.cancel",comment:""), leftAction: {(void) in
            self.alertView?.close() }, rightText: NSLocalizedString("invoice.message.continue",comment:""), rightAction: { (void) in
            self.alertView?.close()
            let _ = self.navigationController?.popViewController(animated: true)
        },isNewFrame: false)
    }
    
    func showInfoAlert(){
        let message = NSMutableAttributedString()
        message.append(NSAttributedString(string: NSLocalizedString("invoice.info.validity",comment:""), attributes: [NSFontAttributeName : WMFont.fontMyriadProBoldOfSize(15),NSForegroundColorAttributeName:UIColor.white]))
        message.append(NSAttributedString(string: NSLocalizedString("invoice.info.validity.desc",comment:""), attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(15),NSForegroundColorAttributeName:UIColor.white]))
        message.append(NSAttributedString(string: NSLocalizedString("invoice.info.guard",comment:""), attributes: [NSFontAttributeName : WMFont.fontMyriadProBoldOfSize(15),NSForegroundColorAttributeName:UIColor.white]))
        message.append(NSAttributedString(string: NSLocalizedString("invoice.info.guard.desc",comment:""), attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(15),NSForegroundColorAttributeName:UIColor.white]))
        
        
        self.alertView = IPOWMAlertInfoViewController.showAttributedAlert(NSLocalizedString("invoice.advice",comment:""), message: message)
        self.alertView?.showOkButton(NSLocalizedString("invoice.message.continue",comment:""), colorButton: WMColor.green)
    }
    
    func next(){
        let invoiceController = InvoiceComplementViewController()
        self.navigationController!.pushViewController(invoiceController, animated: true)
    }
    
    //MARK: TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(_ sender:Any) -> CGSize {
        let val = CGSize(width: self.view.frame.width, height: self.content.contentSize.height)
        return val
    }
}
