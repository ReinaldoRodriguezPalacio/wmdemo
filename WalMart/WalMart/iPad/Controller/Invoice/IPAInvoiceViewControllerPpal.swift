//
//  IPAInvoiceViewControllerPpal.swift
//  WalMart
//
//  Created by Vantis on 10/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class IPAInvoiceViewControllerPpal : InvoiceViewControllerPpal{
    
    
    override func viewDidLoad() {
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        self.hiddenBack = true
        super.viewDidLoad()
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.frame.size.width, height: self.view.bounds.height - (headerHeight + 120))
        self.content.contentSize = CGSize(width: self.view.frame.size.width, height: self.txtRfcEmail!.frame.maxY + 5.0)
        
        let section1Top: CGFloat = 0
        let section1Bottom: CGFloat =  self.content.frame.size.height/4
        let section2Top: CGFloat = section1Bottom
        let section2Bottom: CGFloat = 2*section1Bottom
        let section3Top: CGFloat = section2Bottom
        let section3Bottom: CGFloat = 3*section1Bottom
        let section4Top: CGFloat = section3Bottom
        let section4Bottom: CGFloat = 4*section1Bottom
        let sectionWidth: CGFloat = self.content.frame.size.width
        
        
        let margin: CGFloat = 15.0
        var fheight = (section1Bottom - section1Top)/5
        self.btnNewInvoice?.frame = CGRect(x: margin, y: 3*fheight - 10, width: (sectionWidth - 2*margin)/2, height: fheight)
        self.btnResendInvoice?.frame = CGRect(x: btnNewInvoice!.frame.maxX, y: 3*fheight - 10, width: (sectionWidth - 2*margin)/2, height: fheight)
        
        fheight = (section2Bottom - section2Top)/6
        //SECCION TICKET
        self.lblTicketTitle.frame = CGRect(x: margin, y: section2Top + fheight, width: sectionWidth, height: fheight)
        self.lblTicketTitle.sizeToFit()
        
        // BOTON DE INFO
        self.btnInfoTicketButton?.frame = CGRect(x: self.lblTicketTitle!.frame.maxX , y: section2Top + fheight-6, width: 27, height: 27)
        // BOTON DE ESCANEAR TICKET
        self.btnScanTicket?.frame = CGRect(x: sectionWidth - 2.5*fheight - 10, y:  lblTicketTitle.frame.maxY + fheight, width: 2.5*fheight, height: 2.5*fheight)
        //NUMERO DE TICKET
        self.txtTicketNumber?.frame = CGRect(x: margin, y: lblTicketTitle.frame.maxY + fheight, width: sectionWidth - 2.5*fheight - margin - 20, height: 2.5*fheight)
        
        //SECCION RFC
        fheight = (section3Bottom - section3Top)/6
        //SECCION RFC EMAIL
        self.lblRfcEmailTitle.frame = CGRect(x: margin, y: section3Top + fheight, width: sectionWidth, height: fheight)
        self.lblRfcEmailTitle.sizeToFit()
        
        //CAPTURA RFC
        self.txtRfcEmail?.frame = CGRect(x: margin, y: lblRfcEmailTitle.frame.maxY + fheight, width: sectionWidth - 2*margin, height: 2.5*fheight)
        
        //SECCION DE BOTONES
        fheight = (section4Bottom - section4Top)/3
        //CANCEL
        self.btnCancel?.frame = CGRect(x: margin, y: section4Top + 2*fheight, width: (sectionWidth - 2*margin)/2 - margin/2, height: fheight)
        
        //NEXT
        self.btnNext?.frame = CGRect(x: sectionWidth/2 - (self.btnCancel?.frame.size.width)!/2 , y: section4Top + 2*fheight, width: (sectionWidth - 2*margin)/2 - margin/2, height: fheight)
        self.btnCancel?.removeFromSuperview()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.reloadPreviousOrders()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func scanTicket(_ sender:UIButton){
        let barCodeController = IPABarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.delegate = self
        barCodeController.useDelegate=true
        barCodeController.onlyCreateList=true
        //byScan = true
        self.present(barCodeController, animated: true, completion: nil)
    }
    
}
