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
    var openURL : ((url:String) -> Void)!
    
    func setup(text:String) {
        
        self.clipsToBounds = true
        
        
        viewBlurContainer = UIView()
        viewBlurContainer.backgroundColor = UIColor.clearColor()
        viewBlurContainer.clipsToBounds = true
        self.addSubview(viewBlurContainer)
        
        viewBg = UIView()
        viewBg.backgroundColor = WMColor.light_blue.colorWithAlphaComponent(0.7)
        viewBg.frame = self.bounds
        self.addSubview(viewBg)
        
        
        viewText = UITextView()
        //viewText.text = text
        viewText.frame = CGRectMake( 16, 40, self.bounds.width - 32,  self.bounds.height - 50)
        viewText.font = WMFont.fontMyriadProRegularOfSize(14)
        viewText.textColor = UIColor.whiteColor()
        viewText.backgroundColor = UIColor.clearColor()
        viewText.editable = false
        viewText.selectable = false
        
        let terms = text.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "")
        let myString = NSMutableAttributedString(string: terms)
        let test  =  text as NSString
        if test.rangeOfString("<").location < 999 {
            // Set an attribute on part of the string
           
            let startTxt:NSRange  = test.rangeOfString("<")
            var endTxt:NSRange  = test.rangeOfString(">")
            endTxt.length = (endTxt.location - startTxt.location) + 1
            endTxt.location =  startTxt.location
            
            var stringurl = test.substringWithRange(endTxt)
            stringurl = stringurl.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "")
            let termsTest  =  terms as NSString
            let myRange:NSRange  = termsTest.rangeOfString(stringurl)
            test.stringByReplacingOccurrencesOfString("<\(stringurl)>", withString:stringurl)
            
            let myCustomAttribute = [ "URLTERMS": stringurl]
            myString.addAttributes(myCustomAttribute, range: myRange)
            myString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range:NSMakeRange(0,myString.length))
        }

        viewText.attributedText = myString
       
        // Add tap gesture recognizer to Text View
        let tap = UITapGestureRecognizer(target: self, action: Selector("openTermsTap:"))
        tap.delegate = self
        viewText.addGestureRecognizer(tap)
        
        
        viewBg.addSubview(viewText)

        let closeButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        closeButton.setImage(UIImage(named:"close"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "removeFromSuperview", forControlEvents: UIControlEvents.TouchUpInside)
        viewBg.addSubview(closeButton)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_BANNER_TERMS.rawValue, action: WMGAIUtils.ACTION_VIEW_BANNER_TERMS.rawValue, label: "")
    }
    
    func openTermsTap(sender:UITapGestureRecognizer){
        
        let myTextView = sender.view as! UITextView
        let layoutManager = myTextView.layoutManager
        var location = sender.locationInView(myTextView)
        location.x -= myTextView.textContainerInset.left;
        location.y -= myTextView.textContainerInset.top;
        
        let characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if characterIndex < myTextView.textStorage.length {
            
            let attributeName = "URLTERMS"
            let attributeValue = myTextView.attributedText.attribute(attributeName, atIndex: characterIndex, effectiveRange: nil) as? String
            if let value = attributeValue {
                openURL(url: value)
            }
            
        }
    
    }
    
    
    func startAnimating() {
        viewBg.frame = CGRectMake(self.bounds.minX, self.bounds.height, self.bounds.width, 0)
        if imageBlurView != nil {
            viewBlurContainer.frame = CGRectMake(self.bounds.minX, self.bounds.height, self.bounds.width, 0)
            imageBlurView.frame = CGRectMake(self.bounds.minX, -self.bounds.height, self.bounds.width, self.bounds.height)
        }
        //viewText.frame = CGRectMake(self.bounds.minX + 16, self.bounds.height + 16 , self.bounds.width - 32, 0)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.viewBg.frame = self.bounds
            if self.imageBlurView != nil {
                self.viewBlurContainer.frame = self.bounds
                self.imageBlurView.frame = self.bounds
            }
            //self.viewText.frame = CGRectMake(self.bounds.minX + 16, self.bounds.minY + 16, self.bounds.width - 32,  self.bounds.minY - 32)
            }) { (ends:Bool) -> Void in
            
        }
    }
    
    func generateBlurImage(viewBg:UIView,frame:CGRect) {
        var cloneImage : UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1.0);
        viewBg.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        cloneImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        viewBg.layer.contents = nil
        imageBlurView = UIImageView()
        imageBlurView.frame = frame
        imageBlurView.clipsToBounds = true
        imageBlurView.image = cloneImage!.applyLightEffect()
        cloneImage = nil
        
        viewBlurContainer.addSubview(imageBlurView)
        viewBlurContainer.sendSubviewToBack(imageBlurView)
    }
    
    override func removeFromSuperview() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.viewBg.frame = CGRectMake(self.bounds.minX, self.bounds.height, self.bounds.width, 0)
            if self.imageBlurView != nil {
                self.viewBlurContainer.frame = CGRectMake(self.bounds.minX, self.bounds.height, self.bounds.width, 0)
                self.imageBlurView.frame = CGRectMake(self.bounds.minX, -self.bounds.height, self.bounds.width, self.bounds.height)
            }
            }) { (ends:Bool) -> Void in
                self.endRemovView()
        }
    }
    
    func endRemovView() {
        if onClose != nil {
            onClose()
        }
        super.removeFromSuperview()
    }
    
}