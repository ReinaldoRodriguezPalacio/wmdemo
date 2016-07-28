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
    
    func helpListController(){
        
        let labelButton =  UIButton(frame: CGRectMake(self.frame.width - 72, 75, 56, 22))
        labelButton.backgroundColor =  WMColor.green
        labelButton.setTitle("nueva", forState: .Normal)
        labelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        labelButton.titleLabel?.font  = WMFont.fontMyriadProRegularOfSize(11)
        labelButton.layer.cornerRadius = 11.0
        labelButton.titleEdgeInsets = UIEdgeInsetsMake(1.0, 0, 1, 0.0)
        self.addSubview(labelButton)
        
        let arrowImage = UIImageView(frame: CGRectMake(self.frame.midX , 75, 66, 46))
        arrowImage.image = UIImage(named:"help1")
        arrowImage.contentMode = .Center
        self.addSubview(arrowImage)
        
        let descriptionHelp =  UILabel(frame: CGRectMake(self.frame.midX - 100 , 138, 200, 28))
        descriptionHelp.backgroundColor = UIColor.clearColor()
        descriptionHelp.text = "Crea una lista nueva aquí."
        descriptionHelp.textAlignment = .Center
        descriptionHelp.font = WMFont.fontMyriadProRegularOfSize(16)
        descriptionHelp.textColor =  UIColor.whiteColor()
        self.addSubview(descriptionHelp)
    
    }
    
    func helpReminder(){
        
        
        let descriptionHelp =  UILabel(frame: CGRectMake(16, self.frame.maxY -  (TabBarHidden.isTabBarHidden ? 80 : 127), self.frame.width - 32, 28))
        descriptionHelp.backgroundColor = UIColor.clearColor()
        descriptionHelp.text = "Crea y edita recordatorios aquí."
        descriptionHelp.numberOfLines =  2
        descriptionHelp.textAlignment = .Center
        descriptionHelp.font = WMFont.fontMyriadProRegularOfSize(16)
        descriptionHelp.textColor =  UIColor.whiteColor()
        self.addSubview(descriptionHelp)
        
        let arrowImage = UIImageView(frame: CGRectMake(65, descriptionHelp.frame.maxY + 5, 66, 58))
        arrowImage.image = UIImage(named:"help3")
        arrowImage.contentMode = .Center
        self.addSubview(arrowImage)
        
        let icon = UIImageView(image: UIImage(named: "reminder"))
        icon.frame = CGRectMake(arrowImage.frame.maxX - 14, arrowImage.frame.maxY , 34.0, 34.0)
        self.addSubview(icon)
    
        
    }
    
    func detailListController(){
        
        
        let icon = UIImageView(image: UIImage(named: "list_scan_ticket"))
        icon.frame = CGRectMake(16.0, 134, 40.0, 40.0)
        self.addSubview(icon)
        
        let labelButton =  UILabel(frame: CGRectMake(72, 134, 184, 40))
        
        let maskFirst =  UIBezierPath(roundedRect:labelButton.bounds , byRoundingCorners: [.TopLeft ,.BottomLeft], cornerRadii:CGSizeMake(4.0,4.0))
        
        let maskFirstLayer =  CAShapeLayer()
        maskFirstLayer.frame = self.bounds
        maskFirstLayer.path = maskFirst.CGPath
        
        
        labelButton.backgroundColor =  UIColor.whiteColor()
        labelButton.text = "Nueva Lista"
        labelButton.font  = WMFont.fontMyriadProRegularOfSize(11)
        labelButton.textColor =  WMColor.gray
        labelButton.layer.mask = maskFirstLayer
        self.addSubview(labelButton)
        

        let labelCreate =  UILabel(frame: CGRectMake(labelButton.frame.maxX , labelButton.frame.minY, 48, 40))
        let mask =  UIBezierPath(roundedRect:labelCreate.bounds , byRoundingCorners: [.TopRight ,.BottomRight], cornerRadii:CGSizeMake(4.0,4.0))
        
        let maskLayer =  CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = mask.CGPath
        
        labelCreate.backgroundColor = WMColor.green
        labelCreate.text = "Crear"
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
        descriptionHelp.text = "¡También puedes crear una lista usando tu ticket!"
        descriptionHelp.numberOfLines =  2
        descriptionHelp.textAlignment = .Center
        descriptionHelp.font = WMFont.fontMyriadProRegularOfSize(16)
        descriptionHelp.textColor =  UIColor.whiteColor()
        self.addSubview(descriptionHelp)
        
    
    }
    
    
    func closeView(){
        if onClose != nil {
            onClose!()
        }
    }
    
    
}