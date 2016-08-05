//
//  ListHelpView.swift
//  WalMart
//
//  Created by Joel Juarez on 26/07/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

enum ListHelpContextType {
    case InControllerList
    case InDetailList
    case InReminderList
}

class ListHelpView: UIView {
    
   
    var onClose: ((Void) -> Void)?
    
    var listHelpContextType: ListHelpContextType?

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
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
        let buttonClose = UIButton(frame: CGRectMake(0, 20, 44, 44))
        buttonClose.setImage(UIImage(named:"tutorial_close"), forState: UIControlState.Normal)
        buttonClose.addTarget(self, action: #selector(HelpHomeView.closeView), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(buttonClose)
        
    
        if listHelpContextType ==  ListHelpContextType.InControllerList {
            self.helpListController()
        }else if listHelpContextType ==  ListHelpContextType.InDetailList {
            self.detailListController()
        }else{
            self.helpReminder()
        }

        
    
    }
    
    override func layoutSubviews() {
        
    }
    /**
     Help view when create new list ,the first time
     */
    func helpListController(){
        
        let labelButton =  UIButton(frame: CGRectMake(self.frame.width - 72, IS_IPAD ? 121 :75, 56, 22))
        labelButton.backgroundColor =  WMColor.green
        labelButton.setTitle(NSLocalizedString("list.new", comment: "") , forState: .Normal)
        labelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        labelButton.titleLabel?.font  = WMFont.fontMyriadProRegularOfSize(11)
        labelButton.layer.cornerRadius = 11.0
        labelButton.titleEdgeInsets = UIEdgeInsetsMake(1.0, 0, 1, 0.0)
        self.addSubview(labelButton)
        
        let arrowImage = UIImageView(frame: CGRectMake(self.frame.midX , IS_IPAD ? 121 : 75, 66, 46))
        arrowImage.image = UIImage(named:"help1")
        arrowImage.contentMode = .Center
        self.addSubview(arrowImage)
        
        let descriptionHelp =  UILabel(frame: CGRectMake(self.frame.midX - 100 , IS_IPAD ? arrowImage.frame.maxY : 138, 200, 28))
        descriptionHelp.backgroundColor = UIColor.clearColor()
        descriptionHelp.text = NSLocalizedString("list.message.create.list", comment: "")
        descriptionHelp.textAlignment = .Center
        descriptionHelp.font = WMFont.fontMyriadProRegularOfSize(16)
        descriptionHelp.textColor =  UIColor.whiteColor()
        self.addSubview(descriptionHelp)
    
    }
    /**
     Reminder helpview
     */
    func helpReminder(){
        
        
        let descriptionHelp =  UILabel(frame: CGRectMake(IS_IPAD ? self.frame.midX - 20 : 16,
            IS_IPAD ? self.frame.maxY - 30  : (self.frame.height -  (TabBarHidden.isTabBarHidden ? 145 : 190)),
            self.frame.width - 32,
            28))
        if IS_IPHONE_4_OR_LESS || IS_IPOD {
            descriptionHelp.frame = CGRectMake(descriptionHelp.frame.origin.x,descriptionHelp.frame.maxY + 37,descriptionHelp.frame.width ,descriptionHelp.frame.height)
        }
        
        descriptionHelp.backgroundColor = UIColor.clearColor()
        descriptionHelp.text = NSLocalizedString("list.message.create.reminder", comment: "")
        descriptionHelp.numberOfLines =  2
        descriptionHelp.textAlignment = .Center
        descriptionHelp.font = WMFont.fontMyriadProRegularOfSize(16)
        descriptionHelp.textColor =  UIColor.whiteColor()
        self.addSubview(descriptionHelp)
        
        let arrowImage = UIImageView(frame: CGRectMake(IS_IPAD ? self.bounds.midX + 195 : 65, descriptionHelp.frame.maxY + 5, 66, 58))
        arrowImage.image = UIImage(named:"help3")
        arrowImage.contentMode = .Center
        self.addSubview(arrowImage)
        
        let icon = UIImageView(image: UIImage(named: "reminder"))
        icon.frame = CGRectMake(arrowImage.frame.maxX - 15, arrowImage.frame.maxY , 34.0, 34.0)
        self.addSubview(icon)
    
        
    }
    
    /**
     First help view list
     */
    func detailListController(){
        
        
        let icon = UIImageView(image: UIImage(named: "list_scan_ticket"))
        icon.frame = CGRectMake(16.0, IS_IPAD ? 167: 134, 40.0, 40.0)
        self.addSubview(icon)
        
        let labelButton =  WMLabel(frame: CGRectMake(72, icon.frame.minY, IS_IPAD ?  206: 184, 40))
        
        let maskFirst =  UIBezierPath(roundedRect:labelButton.bounds , byRoundingCorners: [.TopLeft ,.BottomLeft], cornerRadii:CGSizeMake(4.0,4.0))
        
        let maskFirstLayer =  CAShapeLayer()
        maskFirstLayer.frame = self.bounds
        maskFirstLayer.path = maskFirst.CGPath
        
        
        labelButton.backgroundColor =  UIColor.whiteColor()
        labelButton.text =   NSLocalizedString("list.message.new.list", comment: "")
        labelButton.font  = WMFont.fontMyriadProLightOfSize(16)
        labelButton.textColor =  WMColor.empty_gray_btn
        labelButton.layer.mask = maskFirstLayer
        
        self.addSubview(labelButton)
        

        let labelCreate =  UILabel(frame: CGRectMake(labelButton.frame.maxX , labelButton.frame.minY, 48, 40))
        let mask =  UIBezierPath(roundedRect:labelCreate.bounds , byRoundingCorners: [.TopRight ,.BottomRight], cornerRadii:CGSizeMake(4.0,4.0))
        
        let maskLayer =  CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = mask.CGPath
        
        labelCreate.backgroundColor = WMColor.green
        labelCreate.text = NSLocalizedString("list.new.keyboard.save", comment: "")
        labelCreate.font  = WMFont.fontMyriadProRegularOfSize(11)
        labelCreate.textColor =  UIColor.whiteColor()
        labelCreate.textAlignment = .Center
        labelCreate.layer.mask = maskLayer
        self.addSubview(labelCreate)
       
        
        let arrowImage = UIImageView(frame: CGRectMake(16 , icon.frame.maxY + 16, 66, 58))
        arrowImage.image = UIImage(named:"help2")
        arrowImage.contentMode = .Center
        self.addSubview(arrowImage)
        
       
        let descriptionHelp =  UILabel(frame: CGRectMake(arrowImage.frame.maxX , arrowImage.frame.maxY - 5, 200, 46))
        descriptionHelp.backgroundColor = UIColor.clearColor()
        descriptionHelp.text = NSLocalizedString("list.message.ticket.list", comment: "")
        descriptionHelp.numberOfLines =  2
        descriptionHelp.textAlignment = .Center
        descriptionHelp.font = WMFont.fontMyriadProRegularOfSize(16)
        descriptionHelp.textColor =  UIColor.whiteColor()
        self.addSubview(descriptionHelp)
        
    
    }
    
    class WMLabel: UILabel {
        override func drawTextInRect(rect: CGRect) {
            let newRect = CGRectOffset(rect, 10, 0)
            super.drawTextInRect(newRect)
        }
    }
    
    func closeView(){
        if onClose != nil {
            onClose!()
        }
    }
    
    
}