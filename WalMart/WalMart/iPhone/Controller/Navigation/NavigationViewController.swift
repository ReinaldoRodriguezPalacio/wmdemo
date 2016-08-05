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
            self.backButton!.setImage(UIImage(named: "BackProduct"), forState: UIControlState.Normal)
            self.backButton!.addTarget(self, action: #selector(NavigationViewController.back), forControlEvents: UIControlEvents.TouchUpInside)
            self.header?.addSubview(self.backButton!)
       }//if !hiddenBack{
    
        self.titleLabel?.textAlignment = NSTextAlignment.Center
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if self.titleLabel != nil && self.titleLabel!.frame.width == 0 {
            self.header!.frame = CGRectMake(0, 0, self.view.bounds.width, 46)
            self.titleLabel!.frame = CGRectMake(46, 0, self.header!.frame.width - 92, self.header!.frame.maxY)
        }
        if backButton != nil{
            self.backButton!.frame = CGRectMake(0, 0  ,46,46)
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
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
    
    
    
    
    
    
}
