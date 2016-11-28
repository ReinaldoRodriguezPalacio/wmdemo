//
//  IPASupportViewController.swift
//  WalMart
//
//  Created by ISOL Ingenieria de Soluciones on 11/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class IPASupportViewController: SupportViewController {
    
    override func viewDidLoad()
    {
       
        self.hiddenBack = true
        if  self.navigationController != nil {
            self.navigationController!.setNavigationBarHidden(true, animated: true)
        }
        super.viewDidLoad()
        
        imgConfirm.image = UIImage(named: "support-empty")
        
        let attrStringLab = NSAttributedString(string:NSLocalizedString("help.buttom.title.callto", comment: ""),
            attributes: [NSFontAttributeName : WMFont.fontMyriadProLightOfSize(18),
                NSForegroundColorAttributeName:WMColor.light_blue])
        
        let attrStringVal = NSAttributedString(string:PHONE_SUPPORT,
            attributes: [NSFontAttributeName : WMFont.fontMyriadProBoldCondOfSize(18),
                NSForegroundColorAttributeName:WMColor.light_blue])
        
        let valuesDescItem = NSMutableAttributedString()
        valuesDescItem.append(attrStringLab)
        valuesDescItem.append(attrStringVal)
        
        self.labelQuestion1.text = NSLocalizedString("Support.label.question.comment" , comment: "")
        self.labelQuestion2.attributedText = valuesDescItem
        
        self.callme.text = NSLocalizedString("help.buttom.title.call" , comment: "")
        
        self.callmeNumber.text = PHONE_SUPPORT
        
        self.sendmeMail.text = NSLocalizedString("help.buttom.title.text" , comment: "")
        
        
        self.labelQuestion1!.font = WMFont.fontMyriadProLightOfSize(18)
        self.labelQuestion1!.textColor = WMColor.light_blue
        self.labelQuestion1!.backgroundColor = UIColor.clear
        self.labelQuestion1!.textAlignment = .center
        
        //self.labelQuestion2!.font = WMFont.fontMyriadProLightOfSize(18)
        self.labelQuestion2!.textColor = WMColor.light_blue
        self.labelQuestion2!.backgroundColor = UIColor.clear
        self.labelQuestion2!.textAlignment = .center
        
        self.callme!.font = WMFont.fontMyriadProRegularOfSize(18)
        self.callme!.textColor = WMColor.gray
        self.callme!.backgroundColor = UIColor.clear
        self.callme!.textAlignment = .center
        
        self.callmeNumber!.font = WMFont.fontMyriadProBoldItOfSize(18)
        self.callmeNumber!.textColor = WMColor.gray
        self.callmeNumber!.backgroundColor = UIColor.clear
        self.callmeNumber!.textAlignment = .center
        
        self.sendmeMail!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.sendmeMail!.textColor = WMColor.gray
        self.sendmeMail!.backgroundColor = UIColor.clear
        self.sendmeMail!.textAlignment = .center
        
        
        self.buttomCall.setImage(UIImage(named:"support-call"), for: UIControlState())
        self.buttomCall.setImage(UIImage(named:"support-call."), for: UIControlState.selected)
        self.buttomCall.addTarget(self , action: Selector("selectecButton:"), for:UIControlEvents.touchUpInside)
        self.buttomCall.backgroundColor = UIColor.clear
        
        self.buttomMail.setImage(UIImage(named:"support-email-iPad"), for: UIControlState())
        self.buttomMail.setImage(UIImage(named:"support-email-iPad"), for: UIControlState.selected)
        self.buttomMail.addTarget(self , action: Selector("selectecButton:"), for:UIControlEvents.touchUpInside)
        self.buttomMail.backgroundColor = UIColor.clear
        
        self.view.addSubview(imgConfirm)
        
        self.view.addSubview(labelQuestion1)
        self.view.addSubview(labelQuestion2)

        self.view.addSubview(buttomMail)

        self.view.addSubview(sendmeMail)
        self.stores = []
        
        self.stores.append(NSLocalizedString("Support.label.list.reason.fail", comment:""))
        self.stores.append(NSLocalizedString("Support.label.list.reason.close", comment:""))
        self.stores.append(NSLocalizedString("Support.label.list.reason.other", comment:""))
        
//        var margin: CGFloat = 15.0
//        var width = self.view.frame.width - (2*margin)
//        var fheight: CGFloat = 44.0
//        var lheight: CGFloat = 25.0
        
        self.selectedType = IndexPath(row: 0, section: 0)

        self.pikerBtn!.delegate = self
        self.pikerBtn!.setValues(NSLocalizedString("Support.label.write.to", comment:""), values: self.stores)
        self.pikerBtn.setNameBtn(NSLocalizedString("Support.label.super", comment:""), titleBtnDown:NSLocalizedString("Support.label.home.more", comment:"") )
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bounds = self.view.bounds
        
        self.labelQuestion1.frame = CGRect(x: 0,  y: self.header!.frame.maxY + 48 , width: bounds.width, height: 18 )
        self.labelQuestion2.frame = CGRect(x: 0,  y: self.labelQuestion1.frame.maxY + 5  , width: bounds.width, height: 15 )
        
       // callmeNumber.frame =  CGRectMake(32 , bounds.maxY - 114 , 130, 15)
        sendmeMail.frame =  CGRect(x: bounds.midX - 43 , y: bounds.maxY - 100 , width: 85, height: 15)//label
        buttomMail.frame =  CGRect(x: bounds.midX - 43 , y: sendmeMail.frame.midY - 100 , width: 85, height: 85)//btn
    
        
    }
    
    
    
    
}
