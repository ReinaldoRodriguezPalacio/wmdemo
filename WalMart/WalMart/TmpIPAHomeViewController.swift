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
        webview.loadRequest(URLRequest(url: URL(string: "https://www.walmart.com.mx/")!))
        
        viewSuper = IPOGroceriesView(frame: CGRect(x: 0, y: self.headerView.frame.maxY, width: 1024, height: 48))
        self.view.addSubview(viewSuper)
        
        let tapGestureLogo =  UITapGestureRecognizer(target: self, action: #selector(TmpIPAHomeViewController.logoTap))
        viewLogo.addGestureRecognizer(tapGestureLogo)
        
        self.view.bringSubview(toFront: self.headerView)
        
        
          Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(TmpIPAHomeViewController.disapearSuperView), userInfo: nil, repeats: false)
        
    }
    
    func apearSuperView (){
        isShowingGroceriesView = true
        supperIndicator.image = UIImage(named: "home_switch_On")
          Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(TmpIPAHomeViewController.disapearSuperView), userInfo: nil, repeats: false)
        self.viewSuper.generateBlurImageWithView(self.webview)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.viewSuper.frame = CGRect(x: 0,y: self.headerView.frame.maxY, width: self.viewSuper.frame.width, height: self.viewSuper.frame.height)
            }, completion: { (complete:Bool) -> Void in
                
        }) 
        
        
    }
    
    func disapearSuperView (){
        isShowingGroceriesView = false
        supperIndicator.image = UIImage(named: "home_switch_Off")
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.viewSuper.frame = CGRect(x: 0,y: -self.viewSuper.frame.height, width: self.viewSuper.frame.width, height: self.viewSuper.frame.height)
            }, completion: { (complete:Bool) -> Void in
                
        }) 
    }
    
    func logoTap(){
        if isShowingGroceriesView {
            disapearSuperView()
        }else{
            apearSuperView()
        }
    }

    
    
}
