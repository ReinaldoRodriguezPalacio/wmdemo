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
     
        self.backgroundColor = WMColor.dark_blue.colorWithAlphaComponent(0.9)
        
        self .imageIcon = UIImageView()
        self.imageIcon?.image = UIImage(named:"search_alert")
        
        self.labelMessage = UILabel()
        self.labelMessage?.textColor = UIColor.whiteColor()
        self.labelMessage?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.labelMessage?.numberOfLines = 1
        
        self.resultsOf = UILabel()
        self.resultsOf?.textColor = UIColor.whiteColor()
        self.resultsOf?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.resultsOf?.numberOfLines = 1
        
        self.addSubview(imageIcon!)
        self.addSubview(labelMessage!)
        self.addSubview(resultsOf!)
    }
    
    func setValues(key:String,correction:String,underline:String?)
    {
        let attrs = [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(12)]
        let attrsBold = [NSFontAttributeName : WMFont.fontMyriadProSemiboldItalicOfSize(12)]
        let attrsOrange = [NSFontAttributeName : WMFont.fontMyriadProSemiboldItalicOfSize(12), NSForegroundColorAttributeName: WMColor.yellow]
        let attrsUnderline = [NSFontAttributeName : WMFont.fontMyriadProSemiboldItalicOfSize(12), NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        
        let messageString = NSMutableAttributedString(string: "No se encontró: ", attributes: attrs)
        let boldString = NSMutableAttributedString(string:"\(key) ", attributes:attrsBold)
        
        messageString.appendAttributedString(boldString)
        
        if underline != nil {
          let underlineString = NSMutableAttributedString(string:" \(underline!)  ", attributes:attrsUnderline)
          messageString.appendAttributedString(underlineString)
        }
        
        self.labelMessage!.attributedText = messageString
        
        let resultsOfString = NSMutableAttributedString(string: "Mostrando resultados de ", attributes: attrs)
        let orangeString = NSMutableAttributedString(string: correction, attributes: attrsOrange)
        
        resultsOfString.appendAttributedString(orangeString)
        self.resultsOf!.attributedText = resultsOfString
        
        self.labelMessage!.sizeToFit()
        self.resultsOf!.sizeToFit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageIcon!.frame = CGRectMake(12, 15, 16, 16)
        self.labelMessage!.frame.size = CGSizeMake( 150, 12)
        self.resultsOf!.frame.size = CGSizeMake(150, 12)
        
        self.labelMessage!.sizeToFit()
        self.resultsOf!.sizeToFit()
        
        let labelMessageOriginY: CGFloat = IS_IPAD ? 18 : 8
        let resultsOfOriginY: CGFloat = IS_IPAD ? 18 : 26
        let resultsOfOriginX: CGFloat = IS_IPAD ? self.labelMessage!.frame.maxX + 12 : self.imageIcon!.frame.maxX + 12
        
        self.labelMessage!.frame.origin = CGPointMake(self.imageIcon!.frame.maxX + 12, labelMessageOriginY)
        self.resultsOf!.frame.origin = CGPointMake(resultsOfOriginX, resultsOfOriginY)
        
    }
}