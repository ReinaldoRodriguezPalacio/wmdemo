//
//  CommentView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class CommentView : UIView {
    
    
    var information: UILabel!
    var titleMessage: UILabel!
    var imageBackground: UIImageView!
    var buttonMessage: UIButton!
    var buttonOk: UIButton!
    var textMesage: UITextView!
    var strMessage: String! = ""
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
        self.backgroundColor = UIColor.whiteColor()
        
        information = UILabel(frame: CGRectMake(16, 43, self.frame.size.width - 32, 36))
        information.textAlignment = NSTextAlignment.Center
        information.textColor = WMColor.UIColorFromRGB(0x0071CE)
        information.font = WMFont.fontMyriadProLightOfSize(18)
        information.numberOfLines = 2
        information.text = "¡Gracias!\n¿Tienes algún comentario ?"
       
        
        imageBackground = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        imageBackground.image = UIImage(named: "comments")
       
        
        
        buttonMessage = UIButton(frame: CGRectMake(16, 256, self.frame.width - 32, 40))
        buttonMessage.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        buttonMessage.setTitle("Mensaje", forState: UIControlState.Normal)
        buttonMessage.backgroundColor = UIColor.whiteColor()
        buttonMessage.setTitleColor(WMColor.UIColorFromRGB(0xB0B1B4), forState: UIControlState.Normal)
        buttonMessage.addTarget(self, action: "comment:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonMessage.layer.cornerRadius = 4
        buttonMessage.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonMessage.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 20)
        buttonMessage.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        
        
        //Editing Mode
        textMesage = UITextView(frame: CGRectMake(16, 80, frame.width - 32, frame.height - 216))
        textMesage.alpha = 0
        textMesage.font = WMFont.fontMyriadProRegularOfSize(14)
        textMesage.textColor = WMColor.UIColorFromRGB(0x797C81)
        
        
        titleMessage = UILabel(frame: CGRectMake(16, 43, self.frame.size.width - 32, 18))
        titleMessage.textAlignment = NSTextAlignment.Left
        titleMessage.textColor = WMColor.UIColorFromRGB(0x0071CE)
        titleMessage.font = WMFont.fontMyriadProLightOfSize(18)
        titleMessage.numberOfLines = 2
        titleMessage.text = "Querido Mercury..."
        titleMessage.alpha = 0
        
        buttonOk = UIButton(frame:  CGRectMake(self.frame.width - 56, 43, 40, 18))
        buttonOk.setTitle("Ok", forState: UIControlState.Normal)
        buttonOk.setTitleColor(WMColor.UIColorFromRGB(0x0071CE), forState: UIControlState.Normal)
        buttonOk.addTarget(self, action: "closeMessage", forControlEvents: UIControlEvents.TouchUpInside)
        buttonOk.alpha = 0
        
        self.addSubview(imageBackground)
        self.addSubview(information)
        self.addSubview(buttonMessage)
        self.addSubview(textMesage)
        self.addSubview(titleMessage)
        self.addSubview(buttonOk)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() -> Void {
        self.layer.cornerRadius = 4;
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowOffset = CGSizeMake(1, 1);
    }
    
    func comment(sender:UIButton) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.imageBackground.alpha = 0
            self.information.alpha = 0
            self.buttonMessage.alpha = 0
            }) { (complete) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.textMesage.alpha = 1
                    self.titleMessage.alpha = 1
                    self.buttonOk.alpha = 1
                    }) { (complete) -> Void in
                        self.textMesage.becomeFirstResponder()
                }
                
        }
    }
    
    
    func closeMessage() {
        if !self.textMesage.text.isEmpty {
            self.strMessage = self.textMesage.text
            self.buttonMessage.setTitle(self.strMessage, forState: UIControlState.Normal)
            self.buttonMessage.setTitleColor(WMColor.UIColorFromRGB(0x797C81), forState: UIControlState.Normal)
        } else {
            self.buttonMessage.setTitle("Mensaje", forState: UIControlState.Normal)
            self.buttonMessage.setTitleColor(WMColor.UIColorFromRGB(0xB0B1B4), forState: UIControlState.Normal)
        }
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.textMesage.alpha = 0
            self.titleMessage.alpha = 0
            self.buttonOk.alpha = 0
            }) { (complete) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.imageBackground.alpha = 1
                    self.information.alpha = 1
                    self.buttonMessage.alpha = 1
                    }) { (complete) -> Void in
                        self.endEditing(true)
                }
                
        }
    }

}