//
//  BannerTermsView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 04/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class BannerTermsView : UIView,UIGestureRecognizerDelegate {
    
    var imageBlurView : UIImageView!
    var viewBg : UIView!
    var viewBlurContainer : UIView!
    var viewText : UITextView!
    var onClose : (() -> Void)!
    var openURL : ((_ url:String) -> Void)!
    
    func setup(_ text:String) {
        
        self.clipsToBounds = true
        
        
        viewBlurContainer = UIView()
        viewBlurContainer.backgroundColor = UIColor.clear
        viewBlurContainer.clipsToBounds = true
        self.addSubview(viewBlurContainer)
        
        viewBg = UIView()
        viewBg.backgroundColor = WMColor.light_blue.withAlphaComponent(0.7)
        viewBg.frame = self.bounds
        self.addSubview(viewBg)
        
        
        viewText = UITextView()
        //viewText.text = text
        viewText.frame = CGRect( x: 16, y: 40, width: self.bounds.width - 32,  height: self.bounds.height - 50)
        viewText.font = WMFont.fontMyriadProRegularOfSize(14)
        viewText.textColor = UIColor.white
        viewText.backgroundColor = UIColor.clear
        viewText.isEditable = false
        viewText.isSelectable = false
        
        let terms = text.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "")
        let myString = NSMutableAttributedString(string: terms)
        let test  =  text as NSString
        if test.range(of: "<").location < 999 {
            // Set an attribute on part of the string
           
            let startTxt:NSRange  = test.range(of: "<")
            var endTxt:NSRange  = test.range(of: ">")
            endTxt.length = (endTxt.location - startTxt.location) + 1
            endTxt.location =  startTxt.location
            
            var stringurl = test.substring(with: endTxt)
            stringurl = stringurl.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "")
            let termsTest  =  terms as NSString
            let myRange:NSRange  = termsTest.range(of: stringurl)
            test.replacingOccurrences(of: "<\(stringurl)>", with:stringurl)
            
            let myCustomAttribute = [ "URLTERMS": stringurl]
            myString.addAttributes(myCustomAttribute, range: myRange)
            myString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range:NSMakeRange(0,myString.length))
        }
        myString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range:NSMakeRange(0,myString.length))

        viewText.attributedText = myString
       
        // Add tap gesture recognizer to Text View
        let tap = UITapGestureRecognizer(target: self, action: #selector(BannerTermsView.openTermsTap(_:)))
        tap.delegate = self
        viewText.addGestureRecognizer(tap)
        
        
        viewBg.addSubview(viewText)

        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        closeButton.setImage(UIImage(named:"close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(UIView.removeFromSuperview), for: UIControlEvents.touchUpInside)
        viewBg.addSubview(closeButton)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_BANNER_TERMS.rawValue, action: WMGAIUtils.ACTION_VIEW_BANNER_TERMS.rawValue, label: "")
    }
    
    func openTermsTap(_ sender:UITapGestureRecognizer){
        
        let myTextView = sender.view as! UITextView
        let layoutManager = myTextView.layoutManager
        var location = sender.location(in: myTextView)
        location.x -= myTextView.textContainerInset.left;
        location.y -= myTextView.textContainerInset.top;
        
        let characterIndex = layoutManager.characterIndex(for: location, in: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if characterIndex < myTextView.textStorage.length {
            
            let attributeName = "URLTERMS"
            let attributeValue = myTextView.attributedText.attribute(attributeName, at: characterIndex, effectiveRange: nil) as? String
            if let value = attributeValue {
                openURL(url: value)
            }
            
        }
    
    }
    
    
    func startAnimating() {
        viewBg.frame = CGRect(x: self.bounds.minX, y: self.bounds.height, width: self.bounds.width, height: 0)
        if imageBlurView != nil {
            viewBlurContainer.frame = CGRect(x: self.bounds.minX, y: self.bounds.height, width: self.bounds.width, height: 0)
            imageBlurView.frame = CGRect(x: self.bounds.minX, y: -self.bounds.height, width: self.bounds.width, height: self.bounds.height)
        }
        //viewText.frame = CGRectMake(self.bounds.minX + 16, self.bounds.height + 16 , self.bounds.width - 32, 0)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.viewBg.frame = self.bounds
            if self.imageBlurView != nil {
                self.viewBlurContainer.frame = self.bounds
                self.imageBlurView.frame = self.bounds
            }
            //self.viewText.frame = CGRectMake(self.bounds.minX + 16, self.bounds.minY + 16, self.bounds.width - 32,  self.bounds.minY - 32)
            }, completion: { (ends:Bool) -> Void in
            
        }) 
    }
    
    func generateBlurImage(_ viewBg:UIView,frame:CGRect) {
        var cloneImage : UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1.0);
        viewBg.layer.render(in: UIGraphicsGetCurrentContext()!)
        cloneImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        viewBg.layer.contents = nil
        imageBlurView = UIImageView()
        imageBlurView.frame = frame
        imageBlurView.clipsToBounds = true
        imageBlurView.image = cloneImage!.applyLightEffect()
        cloneImage = nil
        
        viewBlurContainer.addSubview(imageBlurView)
        viewBlurContainer.sendSubview(toBack: imageBlurView)
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.viewBg.frame = CGRect(x: self.bounds.minX, y: self.bounds.height, width: self.bounds.width, height: 0)
            if self.imageBlurView != nil {
                self.viewBlurContainer.frame = CGRect(x: self.bounds.minX, y: self.bounds.height, width: self.bounds.width, height: 0)
                self.imageBlurView.frame = CGRect(x: self.bounds.minX, y: -self.bounds.height, width: self.bounds.width, height: self.bounds.height)
            }
            }, completion: { (ends:Bool) -> Void in
                self.endRemovView()
        }) 
    }
    
    func endRemovView() {
        if onClose != nil {
            onClose()
        }
        super.removeFromSuperview()
    }
    
}
