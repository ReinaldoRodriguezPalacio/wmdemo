//
//  NavigationViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 01/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class NavigationViewController: IPOBaseController {
    
    var header: UIView? = nil
    var backButton : UIButton? = nil
    var titleLabel: UILabel? = nil
    var hiddenBack = false
    let headerHeight: CGFloat = 46

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    func setup() {
        self.header = UIView()
        self.titleLabel = UILabel()
        self.titleLabel?.textColor =  WMColor.light_blue
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel!.numberOfLines = 2
        self.header?.backgroundColor = WMColor.light_light_gray
        self.header?.addSubview(self.titleLabel!)
        self.view.addSubview(self.header!)
        
        if !hiddenBack{
            self.backButton = UIButton()
            self.backButton!.setImage(UIImage(named: "BackProduct"), for: UIControlState())
            self.backButton!.addTarget(self, action: #selector(NavigationViewController.back), for: UIControlEvents.touchUpInside)
            self.header?.addSubview(self.backButton!)
       }//if !hiddenBack{
    
        self.titleLabel?.textAlignment = NSTextAlignment.center
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if self.titleLabel != nil && self.titleLabel!.frame.width == 0 {
            self.header!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 46)
            self.titleLabel!.frame = CGRect(x: 46, y: 0, width: self.header!.frame.width - 92, height: self.header!.frame.maxY)
        }
        if backButton != nil{
            self.backButton!.frame = CGRect(x: 0, y: 0  ,width: 46,height: 46)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func back(){
        if self.navigationController != nil {
            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearSearch.rawValue), object: nil)
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    
    
    
    
    
}
