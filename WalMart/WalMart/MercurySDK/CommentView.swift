//
//  CommentView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class CommentView : UIView {
    
    var viewBack : UIView?
    var information: UILabel!
    var questionmessage : UILabel!
    var titleMessage: UILabel!
    var imageBackground: UIImageView!
    var buttonMessage: UIButton!
    var buttonOk: UIButton!
    var buttonCancel: UIButton!
    
    var textMesage: UITextView!
    var strMessage: String! = ""
    var originalFrame : CGRect!
    
    
    var sendMessageAction : ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
        
        self.backgroundColor = UIColor.clearColor()
        
        viewBack = UIView(frame: self.bounds)
        viewBack?.frame = frame
        viewBack?.layer.cornerRadius = 4
        viewBack?.backgroundColor = UIColor.whiteColor()
        
        information = UILabel(frame: CGRectMake(16, 43, self.frame.size.width - 32, 36))
        information.textAlignment = NSTextAlignment.Center
        information.textColor = WMColor.UIColorFromRGB(0x0071CE)
        information.font = MercuryFont.fontSFUIRegularOfSize(25)
        information.numberOfLines = 2
        information.text = "¡Listo!"
        
        
        imageBackground = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        imageBackground.image = UIImage(named: "comments")
        
        
        questionmessage = UILabel(frame: CGRectMake(16, 270, self.frame.size.width - 32, 36))
        questionmessage.textAlignment = NSTextAlignment.Center
        questionmessage.textColor = WMColor.UIColorFromRGB(0x0071CE)
        questionmessage.font = MercuryFont.fontSFUILightOfSize(18)
        questionmessage.numberOfLines = 2
        questionmessage.text = "¿Tienes algún comentario?"
        
        
        buttonMessage = UIButton(frame: CGRectMake(16, questionmessage.frame.maxY + 7, self.frame.width - 32, 40))
        buttonMessage.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        buttonMessage.setTitle("Mensaje", forState: UIControlState.Normal)
        buttonMessage.backgroundColor = UIColor.whiteColor()
        buttonMessage.setTitleColor(WMColor.UIColorFromRGB(0xB0B1B4), forState: UIControlState.Normal)
        buttonMessage.addTarget(self, action: "comment:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonMessage.layer.cornerRadius = 4
        buttonMessage.titleLabel?.font = MercuryFont.fontSFUIRegularOfSize(14)
        buttonMessage.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 20)
        buttonMessage.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        
        
        //Editing Mode
        textMesage = UITextView(frame: CGRectMake(16, 60, frame.width - 32, frame.height - 210))
        textMesage.alpha = 0
        textMesage.font = MercuryFont.fontSFUIRegularOfSize(14)
        textMesage.textColor = WMColor.UIColorFromRGB(0x797C81)
        
        
        titleMessage = UILabel(frame: CGRectMake(16, 23, self.frame.size.width - 32, 18))
        titleMessage.textAlignment = NSTextAlignment.Left
        titleMessage.textColor = WMColor.UIColorFromRGB(0x0071CE)
        titleMessage.font = MercuryFont.fontSFUILightOfSize(18)
        titleMessage.numberOfLines = 2
        titleMessage.text = "Comentarios"
        titleMessage.alpha = 0
        
        
        buttonCancel = UIButton(frame:  CGRectMake(0,  self.viewBack!.frame.height - 140,  138, 36))
        self.buttonCancel?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        self.buttonCancel?.setTitle("Cancelar", forState: UIControlState.Normal)
        self.buttonCancel?.layer.cornerRadius = 18
        self.buttonCancel?.addTarget(self, action: "actionCancel", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonCancel?.titleLabel!.font = MercuryFont.fontSFUIRegularOfSize(18)
        self.buttonCancel?.alpha = 0
        
        buttonOk = UIButton(frame:  CGRectMake(self.buttonCancel.frame.maxX + 12, buttonCancel.frame.minY,  138, 36))
        self.buttonOk?.backgroundColor = UIColor(red: 0/255, green: 113/255, blue: 206/255, alpha: 1)
        self.buttonOk?.setTitle("Enviar", forState: UIControlState.Normal)
        self.buttonOk?.layer.cornerRadius = 18
        self.buttonOk?.addTarget(self, action: "actionDone", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonOk?.titleLabel!.font = MercuryFont.fontSFUIRegularOfSize(18)
        self.buttonOk?.alpha = 0
        
        
        
        self.addSubview(viewBack!)
        self.addSubview(imageBackground)
        self.addSubview(information)
        self.addSubview(buttonMessage)
        self.addSubview(textMesage)
        self.addSubview(titleMessage)
        self.addSubview(buttonOk)
        self.addSubview(buttonCancel)
        self.addSubview(questionmessage)
        
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
        
        self.originalFrame = viewBack?.frame
        self.viewBack?.frame = CGRectMake(self.viewBack!.frame.minX, self.viewBack!.frame.minY, self.viewBack!.frame.width, self.viewBack!.frame.height - 150 )
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.imageBackground.alpha = 0
            self.information.alpha = 0
            self.buttonMessage.alpha = 0
            self.questionmessage.alpha = 0
            }) { (complete) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.textMesage.alpha = 1
                    self.titleMessage.alpha = 1
                    self.buttonOk.alpha = 1
                    self.buttonCancel.alpha = 1
                    
                    }) { (complete) -> Void in
                        self.textMesage.becomeFirstResponder()
                }
                
        }
    }
    
    func actionDone() {
        self.endEditing(true)
        self.thanksUser()
    }
    
    
    func actionCancel() {
        self.viewBack?.frame = self.originalFrame
        self.buttonMessage.setTitle("Mensaje", forState: UIControlState.Normal)
        self.buttonMessage.setTitleColor(WMColor.UIColorFromRGB(0xB0B1B4), forState: UIControlState.Normal)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.textMesage.alpha = 0
            self.titleMessage.alpha = 0
            self.buttonOk.alpha = 0
            self.buttonCancel.alpha = 0
            }) { (complete) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.imageBackground.alpha = 1
                    self.information.alpha = 1
                    self.buttonMessage.alpha = 1
                    self.questionmessage.alpha = 1
                    }) { (complete) -> Void in
                        self.endEditing(true)
                }
                
        }
    }
    
    
    func thanksUser() {
        self.imageBackground.image = UIImage(named: "comments_thanks")
        self.information.text = "¡Gracias!"
        self.questionmessage.frame = CGRectMake(16, 100, self.frame.size.width - 32, 36)
        self.questionmessage.numberOfLines = 2
        self.questionmessage.text = "Tus comentarios nos ayudan a mejorar nuestro servicio."
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.textMesage.alpha = 0
            self.titleMessage.alpha = 0
            self.buttonOk.alpha = 0
            self.buttonCancel.alpha = 0
            }) { (complete) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.imageBackground.alpha = 1
                    self.information.alpha = 1
                    self.questionmessage.alpha = 1
                    self.buttonMessage.alpha = 0
                    }) { (complete) -> Void in
                        self.endEditing(true)
                }
                
        }
        
        
    }
    
}