//
//  ListHelpView.swift
//  WalMart
//
//  Created by Joel Juarez on 26/07/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

enum ListHelpContextType {
    case inControllerList
    case inDetailList
    case inReminderList
}

class ListHelpView: UIView,UIGestureRecognizerDelegate {
    
   
    var onClose: ((Void) -> Void)?
    
    var listHelpContextType: ListHelpContextType?
    
    var descriptionHelp :  UILabel?
    var arrowImage : UIImageView?
    var icon : UIImageView?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
     init(frame: CGRect,context : ListHelpContextType) {
        super.init(frame: frame)
        listHelpContextType = context
        setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        let buttonClose = UIButton(frame: CGRect(x: 0, y: 20, width: 44, height: 44))
        buttonClose.setImage(UIImage(named:"tutorial_close"), for: UIControlState())
        buttonClose.addTarget(self, action: #selector(HelpHomeView.closeView), for: UIControlEvents.touchUpInside)
        self.addSubview(buttonClose)
        
    
        if listHelpContextType ==  ListHelpContextType.inControllerList {
            self.helpListController()
        }else if listHelpContextType ==  ListHelpContextType.inDetailList {
            self.detailListController()
        }else{
            self.helpReminder()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ListHelpView.closeHelpview))
        tap.delegate = self
        self.addGestureRecognizer(tap)

    }

    /**
     Close hel view where tap view Help
     */
    func closeHelpview(){
        closeView()
    }
    
    override func layoutSubviews() {
        
        if descriptionHelp != nil {
            let y =  IS_IPAD ? self.frame.maxY - 140  : (self.frame.height -  (TabBarHidden.isTabBarHidden ? 145 : 190))
            
            descriptionHelp?.frame =   CGRect(x: IS_IPAD ? 20 : 16,y: y,width: self.frame.width - 32,height: 28)
            
        if IS_IPHONE_4_OR_LESS || IS_IPOD {
                descriptionHelp!.frame = CGRect(x: descriptionHelp!.frame.origin.x,y: y,width: descriptionHelp!.frame.width ,height: descriptionHelp!.frame.height)
        }
            arrowImage!.frame = CGRect(x: IS_IPAD ? self.bounds.midX + 25 : 65, y: descriptionHelp!.frame.maxY + 5, width: 66, height: 58)
            icon!.frame = CGRect(x: arrowImage!.frame.maxX - 15, y: arrowImage!.frame.maxY , width: 34.0, height: 34.0)
        }

    }
    /**
     Help view when create new list ,the first time
     */
    func helpListController(){
        
        let labelButton =  UIButton(frame: CGRect(x: self.frame.width - 72, y: IS_IPAD ? 121 :75, width: 56, height: 22))
        labelButton.backgroundColor =  WMColor.green
        labelButton.setTitle(NSLocalizedString("list.new", comment: "") , for: UIControlState())
        labelButton.setTitleColor(UIColor.white, for: UIControlState())
        labelButton.titleLabel?.font  = WMFont.fontMyriadProRegularOfSize(11)
        labelButton.layer.cornerRadius = 11.0
        labelButton.titleEdgeInsets = UIEdgeInsetsMake(1.0, 0, 1, 0.0)
        self.addSubview(labelButton)
        
        let arrowImage = UIImageView(frame: CGRect(x: self.frame.midX , y: IS_IPAD ? 121 : 75, width: 66, height: 46))
        arrowImage.image = UIImage(named:"help1")
        arrowImage.contentMode = .center
        self.addSubview(arrowImage)
        
        let descriptionHelp =  UILabel(frame: CGRect(x: self.frame.midX - 100 , y: IS_IPAD ? arrowImage.frame.maxY : 138, width: 200, height: 28))
        descriptionHelp.backgroundColor = UIColor.clear
        descriptionHelp.text = NSLocalizedString("list.message.create.list", comment: "")
        descriptionHelp.textAlignment = .center
        descriptionHelp.font = WMFont.fontMyriadProRegularOfSize(16)
        descriptionHelp.textColor =  UIColor.white
        self.addSubview(descriptionHelp)
    
    }
    /**
     Reminder helpview
     */
    func helpReminder(){
        
        
         descriptionHelp =  UILabel(frame: CGRect(x: IS_IPAD ? self.frame.midX - 20 : 16,
            y: IS_IPAD ? self.frame.maxY - 30  : (self.frame.height -  (TabBarHidden.isTabBarHidden ? 145 : 190)),
            width: self.frame.width - 32,
            height: 28))
    
        
        descriptionHelp!.backgroundColor = UIColor.clear
        descriptionHelp!.text = NSLocalizedString("list.message.create.reminder", comment: "")
        descriptionHelp!.numberOfLines =  2
        descriptionHelp!.textAlignment = .center
        descriptionHelp!.font = WMFont.fontMyriadProRegularOfSize(16)
        descriptionHelp!.textColor =  UIColor.white
        self.addSubview(descriptionHelp!)
        
        arrowImage = UIImageView(frame: CGRect(x: IS_IPAD ? self.bounds.midX + 195 : 65, y: descriptionHelp!.frame.maxY + 5, width: 66, height: 58))
        arrowImage!.image = UIImage(named:"help3")
        arrowImage!.contentMode = .center
        self.addSubview(arrowImage!)
        
        icon = UIImageView(image: UIImage(named: "reminder"))
        icon!.frame = CGRect(x: arrowImage!.frame.maxX - 15, y: arrowImage!.frame.maxY , width: 34.0, height: 34.0)
        self.addSubview(icon!)
    
        
    }
    
    /**
     First help view list
     */
    func detailListController(){
        
        
        let icon = UIImageView(image: UIImage(named: "list_scan_ticket"))
        icon.frame = CGRect(x: 16.0, y: IS_IPAD ? 167: 134, width: 40.0, height: 40.0)
        self.addSubview(icon)
        
        let labelButton =  WMLabel(frame: CGRect(x: 72, y: icon.frame.minY, width: IS_IPAD ?  206: 184, height: 40))
        
        let maskFirst =  UIBezierPath(roundedRect:labelButton.bounds , byRoundingCorners: [.topLeft ,.bottomLeft], cornerRadii:CGSize(width: 4.0,height: 4.0))
        
        let maskFirstLayer =  CAShapeLayer()
        maskFirstLayer.frame = self.bounds
        maskFirstLayer.path = maskFirst.cgPath
        
        
        labelButton.backgroundColor =  UIColor.white
        labelButton.text =   NSLocalizedString("list.message.new.list", comment: "")
        labelButton.font  = WMFont.fontMyriadProLightOfSize(16)
        labelButton.textColor =  WMColor.empty_gray_btn
        labelButton.layer.mask = maskFirstLayer
        
        self.addSubview(labelButton)
        

        let labelCreate =  UILabel(frame: CGRect(x: labelButton.frame.maxX , y: labelButton.frame.minY, width: 48, height: 40))
        let mask =  UIBezierPath(roundedRect:labelCreate.bounds , byRoundingCorners: [.topRight ,.bottomRight], cornerRadii:CGSize(width: 4.0,height: 4.0))
        
        let maskLayer =  CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = mask.cgPath
        
        labelCreate.backgroundColor = WMColor.green
        labelCreate.text = NSLocalizedString("list.new.keyboard.save", comment: "")
        labelCreate.font  = WMFont.fontMyriadProRegularOfSize(11)
        labelCreate.textColor =  UIColor.white
        labelCreate.textAlignment = .center
        labelCreate.layer.mask = maskLayer
        self.addSubview(labelCreate)
       
        
        let arrowImage = UIImageView(frame: CGRect(x: 16 , y: icon.frame.maxY + 16, width: 66, height: 58))
        arrowImage.image = UIImage(named:"help2")
        arrowImage.contentMode = .center
        self.addSubview(arrowImage)
        
       
        let descriptionHelp =  UILabel(frame: CGRect(x: arrowImage.frame.maxX , y: arrowImage.frame.maxY - 5, width: 200, height: 46))
        descriptionHelp.backgroundColor = UIColor.clear
        descriptionHelp.text = NSLocalizedString("list.message.ticket.list", comment: "")
        descriptionHelp.numberOfLines =  2
        descriptionHelp.textAlignment = .center
        descriptionHelp.font = WMFont.fontMyriadProRegularOfSize(16)
        descriptionHelp.textColor =  UIColor.white
        self.addSubview(descriptionHelp)
        
    
    }
    
    class WMLabel: UILabel {
        override func drawText(in rect: CGRect) {
            let newRect = rect.offsetBy(dx: 10, dy: 0)
            super.drawText(in: newRect)
        }
    }
    
    func closeView(){
        if onClose != nil {
            onClose!()
        }
    }
    
    
}
