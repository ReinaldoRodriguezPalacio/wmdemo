//
//  TmpIPAHomeViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 01/11/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import UIKit

class TmpIPAHomeViewController : BaseController {
    
    @IBOutlet var webview: UIWebView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var supperIndicator: UIImageView!
    @IBOutlet var viewLogo: UIImageView!
    
    var isShowingGroceriesView = true
    

    var viewSuper : IPOGroceriesView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.walmart.com.mx/")!))
        
        viewSuper = IPOGroceriesView(frame: CGRectMake(0, self.headerView.frame.maxY, 1024, 48))
        self.view.addSubview(viewSuper)
        
        let tapGestureLogo =  UITapGestureRecognizer(target: self, action: "logoTap")
        viewLogo.addGestureRecognizer(tapGestureLogo)
        
        self.view.bringSubviewToFront(self.headerView)
        
        
          NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "disapearSuperView", userInfo: nil, repeats: false)
        
    }
    
    func apearSuperView (){
        isShowingGroceriesView = true
        supperIndicator.image = UIImage(named: "home_switch_On")
          NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "disapearSuperView", userInfo: nil, repeats: false)
        self.viewSuper.generateBlurImageWithView(self.webview)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.viewSuper.frame = CGRectMake(0,self.headerView.frame.maxY, self.viewSuper.frame.width, self.viewSuper.frame.height)
            }) { (complete:Bool) -> Void in
                
        }
        
        
    }
    
    func disapearSuperView (){
        isShowingGroceriesView = false
        supperIndicator.image = UIImage(named: "home_switch_Off")
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.viewSuper.frame = CGRectMake(0,-self.viewSuper.frame.height, self.viewSuper.frame.width, self.viewSuper.frame.height)
            }) { (complete:Bool) -> Void in
                
        }
    }
    
    func logoTap(){
        if isShowingGroceriesView {
            disapearSuperView()
        }else{
            apearSuperView()
        }
    }

    
    
}