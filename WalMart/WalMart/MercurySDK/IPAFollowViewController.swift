//
//  IPAFollowViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/8/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


class IPAFollowViewController : FollowViewController {
    
    var bgView : UIView? = nil
    let preferrredIpadSize = CGSizeMake(600,512)
    
    var lblNameShopper : UILabel? = nil
    var lblPhoneNumber : UILabel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        bgView = UIView()
        bgView?.backgroundColor = UIColor.blackColor()
        bgView?.alpha = 0.0
        self.view.addSubview(bgView!)
        self.view.sendSubviewToBack(bgView!)
        
        callButton?.alpha = 0
        
        lblNameShopper = UILabel()
        lblNameShopper?.text = "4:00-6:00 pm"
        lblNameShopper?.textColor = UIColor(red: 5/255, green: 206/255, blue: 124/255, alpha: 1.0)
        lblNameShopper?.textAlignment = .Left
        lblNameShopper?.font = UIFont.systemFontOfSize(14)
        
        lblPhoneNumber = UILabel()
        lblPhoneNumber?.text = "4:00-6:00 pm"
        lblPhoneNumber?.textColor = UIColor(red: 5/255, green: 206/255, blue: 124/255, alpha: 1.0)
        lblPhoneNumber?.textAlignment = .Left
        lblPhoneNumber?.font = UIFont.systemFontOfSize(20)
        
        footerContaimer?.addSubview(lblNameShopper!)
        footerContaimer?.addSubview(lblPhoneNumber!)
        
    }
    
    override func viewWillLayoutSubviews() {
        self.bgView?.frame = self.view.bounds
        
        if closed {
            self.view.frame = CGRectMake(preferredPoint.x, preferredPoint.y, preferredSize.width, preferredSize.height)
            self.viewImage!.frame = CGRectMake(0, 0 ,  preferredSize.width, preferredSize.height)
            self.mapView?.frame = CGRectMake(0, 0,0 ,0)
        } else {

            self.mapView?.frame = CGRectMake(0, 0,preferrredIpadSize.width, preferrredIpadSize.height)
            self.mapView?.center = self.view.center

            
            if self.mapView != nil {
                headContaimer?.frame = CGRectMake(self.mapView!.frame.minX, self.mapView!.frame.minY, self.mapView!.frame.width, 44)
                closeButton?.frame = CGRectMake(0, 0, 40, 44)
                lblTitle?.frame = headContaimer!.bounds
                footerContaimer?.frame = CGRectMake(self.mapView!.frame.minX, self.mapView!.frame.maxY - 140, self.mapView!.frame.width , 140)
                backgroundFooter?.frame =   footerContaimer!.bounds
                backgroundHeader?.frame = headContaimer!.bounds
                slotDesc?.frame = CGRectMake(16, 16, self.view.frame.width - 32, 20)
                address?.frame = CGRectMake(16, slotDesc!.frame.maxY + 8, footerContaimer!.frame.width - 32, 36)
                callButton?.frame = CGRectMake((self.view.frame.width / 2) - 80, address!.frame.maxY + 8, 160, 32)
                
                lblNameShopper?.frame = CGRectMake(16, address!.frame.maxY + 6, footerContaimer!.frame.width - 32, 16)
                lblPhoneNumber?.frame = CGRectMake(16, lblNameShopper!.frame.maxY + 2, footerContaimer!.frame.width - 32, 20)
                
            }
        }
        
        
        
    }
    
    override func select() {
        super.select()
        self.bgView?.alpha = 0.7
        
        self.lblPhoneNumber?.text = self.phoneShoper
        self.lblNameShopper?.text = self.nameShopper
    
    }
    
    override func close() {
        super.close()
        self.bgView?.alpha = 0.0
    }
    
    override func initMap() {
        super.initMap()
        self.view.sendSubviewToBack(bgView!)
    }
    
}