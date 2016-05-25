//
//  SchoolListViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 25/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class SchoolListViewController : DefaultListDetailViewController {
    
    var schoolName: String! = ""
    var gradeDesc: String! = ""
    var schoolNameLabel: UILabel?
    var gradeDescLabel: UILabel?
    var numElementsLabel: UILabel?
    var schoolLogo: UIImageView?
    var separator: CALayer!
    var total: CurrencyCustomLabel?
    var saving: CurrencyCustomLabel?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SCHOOLLIST.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel?.text = self.schoolName
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomBarNotification.TapBarFinish.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(DefaultListDetailViewController.tabBarActions),name:CustomBarNotification.TapBarFinish.rawValue, object: nil)
        self.tabBarActions()
    }
    
    override func setup() {
        super.setup()
        
        self.schoolLogo = UIImageView()
        
        self.schoolNameLabel = UILabel()
        self.schoolNameLabel?.text = self.schoolName
        self.schoolNameLabel?.font = WMFont.fontMyriadProSemiboldSize(14)
        self.schoolNameLabel?.textColor = WMColor.light_blue
        
        self.gradeDescLabel = UILabel()
        self.gradeDescLabel?.text = "1º Grado de primaria"
        self.gradeDescLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.gradeDescLabel?.textColor = WMColor.dark_gray
        
        self.numElementsLabel = UILabel()
        self.numElementsLabel?.text = "16 productos"
        self.numElementsLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.numElementsLabel?.textColor = WMColor.dark_gray
        
        self.total = CurrencyCustomLabel()
        self.total!.backgroundColor = UIColor.clearColor()
        self.total!.textAlignment = .Right
        self.total!.updateMount("199.00", font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        
        self.saving = CurrencyCustomLabel()
        self.saving!.backgroundColor = UIColor.clearColor()
        self.saving!.textAlignment = .Right
        self.saving!.updateMount("Ahorras $217.70", font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.green, interLine: false)
        
        self.separator = CALayer()
        self.separator.backgroundColor = WMColor.light_light_gray.CGColor
        self.separator.frame = CGRectMake(0,self.header!.frame.maxY + 97, self.view.frame.width, 1)
        self.view.layer.insertSublayer(separator, atIndex: 0)
        
        self.view.addSubview(schoolNameLabel!)
        self.view.addSubview(gradeDescLabel!)
        self.view.addSubview(numElementsLabel!)
        self.view.addSubview(schoolLogo!)
        self.view.addSubview(saving!)
        self.view.addSubview(total!)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
       
        self.schoolLogo!.frame = CGRectMake(16,self.header!.frame.maxY + 16, 72, 66)
        self.schoolNameLabel!.frame = CGRectMake(self.schoolLogo!.frame.maxX + 16, self.header!.frame.maxY + 16, 113, 15)
        self.gradeDescLabel!.frame = CGRectMake(self.schoolLogo!.frame.maxX + 16, self.schoolNameLabel!.frame.maxY + 4, 113, 13)
        self.numElementsLabel!.frame = CGRectMake(self.schoolLogo!.frame.maxX + 16, self.gradeDescLabel!.frame.maxY + 4, 113, 13)
        self.total!.frame = CGRectMake(self.view.frame.width - 106, self.numElementsLabel!.frame.maxY + 4, 90, 19)
        self.saving!.frame = CGRectMake(self.view.frame.width - 106, self.total!.frame.maxY + 4, 90, 15)
        self.separator.frame = CGRectMake(0,self.header!.frame.maxY + 97, self.view.frame.width, 1)
        self.tableView!.frame = CGRectMake(0, self.header!.frame.maxY + 98, self.view.frame.width, self.view.frame.height - (self.header!.frame.maxY + 98))
    }
}