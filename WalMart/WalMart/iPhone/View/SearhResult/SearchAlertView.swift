//
//  SearchAlertView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 30/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation



class SearchAlertView: UIView {
    var imageIcon: UIImageView? = nil
    var labelMessage: UILabel? = nil
    var resultsOf: UILabel? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
     
        self.backgroundColor = WMColor.dark_blue.withAlphaComponent(0.9)
        
        self .imageIcon = UIImageView()
        self.imageIcon?.image = UIImage(named:"search_alert")
        
        self.labelMessage = UILabel()
        self.labelMessage?.textColor = UIColor.white
        self.labelMessage?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.labelMessage?.numberOfLines = 1
        
        self.resultsOf = UILabel()
        self.resultsOf?.textColor = UIColor.white
        self.resultsOf?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.resultsOf?.numberOfLines = 1
        
        self.addSubview(imageIcon!)
        self.addSubview(labelMessage!)
        self.addSubview(resultsOf!)
    }
    
    func setValues(_ key:String,correction:String,underline:String?)
    {
        let attrs = [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(12)]
        let attrsBold = [NSFontAttributeName : WMFont.fontMyriadProSemiboldItalicOfSize(12)]
        let attrsOrange = [NSFontAttributeName : WMFont.fontMyriadProSemiboldItalicOfSize(12), NSForegroundColorAttributeName: WMColor.yellow] as [String : Any]
        
        var attrsUnderline: [String:Any] = [:]
        
        if #available(iOS 8.4, *) {
            attrsUnderline = [NSFontAttributeName : WMFont.fontMyriadProSemiboldItalicOfSize(12),NSStrikethroughStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        } else {
            attrsUnderline = [NSFontAttributeName : WMFont.fontMyriadProSemiboldItalicOfSize(12),NSForegroundColorAttributeName: WMColor.gray]
        }
        
        let messageString = NSMutableAttributedString(string: "No se encontró: ", attributes: attrs)
        let boldString = NSMutableAttributedString(string:"\(key) ", attributes:attrsBold)
        
        messageString.append(boldString)
        
        if underline != nil {
          let underlineString = NSMutableAttributedString(string:" \(underline!)  ", attributes:attrsUnderline)
          messageString.append(underlineString)
        }
        
        if messageString.length > 48 && IS_IPHONE {
            let string = NSMutableAttributedString(attributedString: messageString.attributedSubstring(from: NSRange(location: 0, length: 46)))
            let boldString = NSMutableAttributedString(string:"...", attributes:attrsBold)
            string.append(boldString)
            self.labelMessage!.attributedText = string
        }else{
          self.labelMessage!.attributedText = messageString
        }

        let resultsOfString = NSMutableAttributedString(string: "Mostrando resultados de ", attributes: attrs)
        let orangeString = NSMutableAttributedString(string: correction, attributes: attrsOrange)
        
        resultsOfString.append(orangeString)
        self.resultsOf!.attributedText = resultsOfString
        
        self.labelMessage!.sizeToFit()
        self.resultsOf!.sizeToFit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageIcon!.frame = CGRect(x: 12, y: 15, width: 16, height: 16)
        self.labelMessage!.frame.size = CGSize( width: 150, height: 12)
        self.resultsOf!.frame.size = CGSize(width: 150, height: 12)
        
        self.labelMessage!.sizeToFit()
        self.resultsOf!.sizeToFit()
        
        let labelMessageOriginY: CGFloat = IS_IPAD ? 18 : 8
        let resultsOfOriginY: CGFloat = IS_IPAD ? 18 : 26
        let resultsOfOriginX: CGFloat = IS_IPAD ? self.labelMessage!.frame.maxX + 12 : self.imageIcon!.frame.maxX + 12
        
        self.labelMessage!.frame.origin = CGPoint(x: self.imageIcon!.frame.maxX + 12, y: labelMessageOriginY)
        self.resultsOf!.frame.origin = CGPoint(x: resultsOfOriginX, y: resultsOfOriginY)
        
    }
}
