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

    var alertView: IPOWMAlertInfoViewController?
    var txtRfc: FormFieldView?
    var txtTicketNumber: FormFieldView?
    
    var lblSelectionTitle : UILabel!
    var lblRfcTitle : UILabel!
    var lblTicketTitle : UILabel!
    var infoMessage: UILabel!
    
    var btnNewInvoice: UIButton?
    var btnResendInvoice: UIButton?
    var btnScanTicket: UIButton?
    var btnNext: UIButton?
    var btnCancel: UIButton?
    var btnInfoTicketButton: UIButton?
    
    var modalView: AlertModalView?
    
    
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
        self.btnInfoTicketButton = UIButton(frame: CGRect(x: self.lblTicketTitle!.frame.maxX , y: section2Top + fheight-6, width: 27, height: 27))
        self.btnInfoTicketButton!.setBackgroundImage(UIImage(named:"scan_info"), for: UIControlState())
        self.btnInfoTicketButton!.addTarget(self, action: #selector(self.infoImage(_:)), for: UIControlEvents.touchUpInside)
        self.content.addSubview(self.btnInfoTicketButton!)
        
        // BOTON DE ESCANEAR TICKET
        self.btnScanTicket = UIButton(frame: CGRect(x: sectionWidth - 2.5*fheight - 10, y:  lblTicketTitle.frame.maxY + fheight, width: 2.5*fheight, height: 2.5*fheight))
        self.btnScanTicket!.setBackgroundImage(UIImage(named:"invoice_ticket_scan"), for: UIControlState())
        self.btnScanTicket!.addTarget(self, action: #selector(self.scanTicket(_:)), for: UIControlEvents.touchUpInside)
        self.content.addSubview(self.btnScanTicket!)
        
        //NUMERO DE TICKET
        self.txtTicketNumber = FormFieldView(frame: CGRect(x: margin, y: lblTicketTitle.frame.maxY + fheight, width: sectionWidth - 2.5*fheight - margin - 20, height: 2.5*fheight))
        self.txtTicketNumber!.isRequired = true
        let placeholder = NSMutableAttributedString()
        placeholder.append(NSAttributedString(string: NSLocalizedString("invoice.field.ticketnumber",comment:"")
            , attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
        self.txtTicketNumber!.setCustomAttributedPlaceholder(placeholder)
        self.txtTicketNumber!.typeField = TypeField.string
        self.txtTicketNumber!.nameField = "ticketNumber"
        //self.txtTicketNumber!.maxLength = 13
        self.content.addSubview(self.txtTicketNumber!)
        
        //SECCION RFC
        fheight = (section3Bottom - section3Top)/6
        //SECCION TICKET
        self.lblRfcTitle = self.buildSectionTitle(NSLocalizedString("invoice.field.turfc",comment:""), frame: CGRect(x: margin, y: section3Top + fheight, width: sectionWidth, height: fheight))
        self.lblRfcTitle.sizeToFit()
        self.content.addSubview(lblRfcTitle)
        
        
        //CAPTURA RFC
        self.txtRfc = FormFieldView(frame: CGRect(x: margin, y: lblRfcTitle.frame.maxY + fheight, width: sectionWidth - 2*margin, height: 2.5*fheight))
        self.txtRfc!.isRequired = true
        let placeholder2 = NSMutableAttributedString()
        placeholder2.append(NSAttributedString(string: NSLocalizedString("invoice.field.rfcejemplo",comment:"")
            , attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(13),NSForegroundColorAttributeName:WMColor.dark_gray]))
        self.txtRfc!.setCustomAttributedPlaceholder(placeholder2)
        self.txtRfc!.typeField = TypeField.rfc
        self.txtRfc!.nameField = "rfc"
        //self.txtRfc!.maxLength = 13
        self.content.addSubview(self.txtRfc!)
        
        
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

        self.content.contentSize = CGSize(width: self.view.frame.width, height: self.txtRfc!.frame.maxY + 5.0)

}
    
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
        }else{
            self.btnNewInvoice!.isSelected = false
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
        barCodeController.useDelegate=true
        barCodeController.onlyCreateList=true
        self.present(barCodeController, animated: true, completion: nil)
    }
    
    //MARK: BarCodeViewControllerDelegate
    func barcodeCaptured(_ value: String?) {
        self.txtTicketNumber!.text = value
    }

    func next(_ sender:UIButton){
        self.performSegue(withIdentifier: "invoiceDataController", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let controller = segue.destination as! InvoiceDataViewController
        if self.btnResendInvoice!.isSelected{
            controller.tipoFacturacion = .resendInvoice
        }else{
            controller.tipoFacturacion = .newInvoice
        }
        
        
    }
 
    //MARK: TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(_ sender:Any) -> CGSize {
        let val = CGSize(width: self.view.frame.width, height: self.content.contentSize.height)
        return val
    }

}
