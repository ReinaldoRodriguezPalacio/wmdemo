//
//  PreviewModalView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 20/02/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation


class PreviewModalView : AlertModalView {
    
    var cellFrame: CGRect = CGRect.zero
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override func setup() {
        
        self.backgroundColor = UIColor.clear
        
        self.tag = 5000
        
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        
        viewContent = UIView(frame: CGRect.zero)
        viewContent.layer.cornerRadius = 8.0
        viewContent.backgroundColor = UIColor.white
        initView = UIView(frame: CGRect.zero)
        initView!.layer.cornerRadius = 8.0
        initView!.backgroundColor = UIColor.white
        self.addSubview(viewContent)
    }
    
    override func setContentView(_ view:UIView){
        let width = view.frame.size.width + 6
        let height = view.frame.size.height + 6
        self.initView = view
        self.viewContent.frame.size = CGSize(width: width, height: height)  //controllerShow.view.frame.size
        self.viewContent.addSubview(self.initView!)
        self.initView!.center =  self.viewContent.center
    }
    
    class func initPreviewWithDefault() -> PreviewModalView {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        let newAlert = PreviewModalView(frame:vc!.view.bounds)
        return newAlert
    }
    
    class func initPreviewModal(_ viewShow:UIView) -> PreviewModalView? {
        let modalView = PreviewModalView.initPreviewWithDefault()
        modalView.setContentView(viewShow)
        return modalView
    }
    
    func showPreview() {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        vc!.view.addSubview(self)
        vc!.view.bringSubview(toFront: self)
        self.startAnimating()
        
    }
    
    
    //MARK: Animated
    
    override func startAnimating() {
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.bgView.addSubview(bgViewAlpha)
        
        
        bgView.alpha = 0
        let finalContentFrame = CGRect(x: viewContent.frame.origin.x, y: viewContent.frame.origin.y, width: 306, height: 436)
        viewContent.frame = cellFrame
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.viewContent.frame = finalContentFrame
            self.bgView.alpha = 1.0
        }, completion: nil)
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.viewContent.frame = CGRect(x: self.cellFrame.origin.x, y: self.cellFrame.origin.y, width: 0, height: 0) 
        },completion: { (complete:Bool) -> Void in
            self.bgView.alpha = 0.0
            self.removeComplete()
        })
        
    }
}
