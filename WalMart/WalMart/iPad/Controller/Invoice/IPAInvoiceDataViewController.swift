//
//  IPAInvoiceDataViewController.swift
//  WalMart
//
//  Created by Vantis on 11/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class IPAInvoiceDataViewController : InvoiceDataViewController{

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.reloadPreviousOrders()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRect(x: 0.0, y: headerHeight, width: self.view.frame.size.width, height: self.view.bounds.height - (headerHeight + 120))
        self.content.contentSize = CGSize(width: self.view.frame.size.width, height: self.txtEmail!.frame.maxY + 5.0)
        
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
        var fheight: CGFloat = 0.0
        
        //SECCION 1
        fheight = (section1Bottom - section1Top)/6
        self.lblAddressTitle.frame = CGRect(x: margin, y: fheight, width: sectionWidth, height: fheight)
        self.lblAddressTitle.sizeToFit()
        
        //CAPTURA RFC
        self.txtAddress!.frame = CGRect(x: margin, y: lblAddressTitle.frame.maxY + fheight, width: sectionWidth - 2*margin, height: 2*fheight)
        self.btnNoAddress?.frame = CGRect(x: margin, y: txtIeps!.frame.maxY, width: (sectionWidth - 2*margin), height: 2*fheight)
        
        //SECCION 2
        fheight = (section2Bottom - section2Top)/6
        self.lblIepsTitle.frame = CGRect(x: margin, y: txtAddress!.frame.maxY + fheight, width: sectionWidth, height: fheight)
        self.lblIepsTitle.sizeToFit()
        
        //CAPTURA RFC
        self.txtIeps!.frame = CGRect(x: margin, y: section2Top + fheight, width: sectionWidth - 2*margin, height: 2*fheight)
        
        self.btnNoIeps?.frame = CGRect(x: margin, y: txtIeps!.frame.maxY + fheight/3, width: (sectionWidth - 2*margin), height: 2*fheight)
        
        //SECCION 3
        fheight = (section3Bottom - section3Top)/6
        self.lblEmailTitle.frame = CGRect(x: margin, y: section3Top, width: sectionWidth, height: fheight)
        self.lblEmailTitle.sizeToFit()
        
        //CAPTURA RFC
        self.txtEmail!.frame = CGRect(x: margin, y: lblEmailTitle.frame.maxY + fheight, width: sectionWidth - 2*margin, height: 2*fheight)
        
        self.btnPrivacity?.frame = CGRect(x: margin, y: txtEmail!.frame.maxY + fheight/2, width: fheight, height: fheight)
        
        self.lblPrivacyTitle.frame = CGRect(x: btnPrivacity!.frame.maxX + 4, y: txtEmail!.frame.maxY + fheight/2, width: sectionWidth - 2*margin - btnPrivacity!.frame.size.width, height: 2*fheight)
        self.lblPrivacyTitle.sizeToFit()
        
        self.lblResguardo.frame = CGRect(x: margin, y: btnPrivacity!.frame.maxY + fheight/2, width: sectionWidth - 2*margin, height: 2*fheight)
        self.lblResguardo.numberOfLines = 0
        self.lblResguardo.sizeToFit()
        
        self.lblVigencia.frame = CGRect(x: margin, y: lblResguardo!.frame.maxY + fheight/2, width: sectionWidth - 2*margin, height: 2*fheight)
        self.lblVigencia.numberOfLines = 0
        self.lblVigencia.sizeToFit()
        
        //SECCION DE BOTONES
        fheight = (section4Bottom - section4Top)/3
        //CANCEL
        self.btnCancel?.frame = CGRect(x: margin, y: section4Top + 2*fheight, width: (sectionWidth - 2*margin)/2 - margin/2, height: fheight)
        //NEXT
        self.btnFacturar?.frame = CGRect(x: btnCancel!.frame.maxX + margin, y: section4Top + 2*fheight, width: (sectionWidth - 2*margin)/2 - margin/2, height: fheight)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
}
