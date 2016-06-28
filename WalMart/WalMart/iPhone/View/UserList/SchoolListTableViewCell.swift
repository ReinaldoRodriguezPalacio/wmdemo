//
//  SchoolListTableViewCell.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 25/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class SchoolListTableViewCell : UITableViewCell {

    var schoolNameLabel: UILabel?
    var gradeDescLabel: UILabel?
    var numElementsLabel: UILabel?
    var schoolLogo: UIImageView?
    var separator: CALayer!
    var total: CurrencyCustomLabel?
    var saving: CurrencyCustomLabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func layoutSubviews() {
        self.schoolLogo!.frame = CGRectMake(16, 16, 72, 66)
        self.schoolNameLabel!.frame = CGRectMake(self.schoolLogo!.frame.maxX + 16, 16, self.frame.width - (self.schoolLogo!.frame.maxX + 32), 14)
        self.gradeDescLabel!.frame = CGRectMake(self.schoolLogo!.frame.maxX + 16, self.schoolNameLabel!.frame.maxY + 4, self.frame.width - (self.schoolLogo!.frame.maxX + 32), 12)
        self.numElementsLabel!.frame = CGRectMake(self.schoolLogo!.frame.maxX + 16, self.gradeDescLabel!.frame.maxY + 4, 113, 12)
        self.total!.frame = CGRectMake(self.frame.width - 106, self.numElementsLabel!.frame.maxY - 5, 90, 18)
        self.saving!.frame = CGRectMake(self.frame.width - 106, self.total!.frame.maxY + 4, 90, 14)
        self.separator.frame = CGRectMake(0, 97, self.frame.width, 1)
    }
    
    func setup(){
        self.schoolLogo = UIImageView()
        self.schoolLogo?.image = UIImage(named: "papeleria_list")
        
        self.schoolNameLabel = UILabel()
        self.schoolNameLabel?.font = WMFont.fontMyriadProSemiboldSize(14)
        self.schoolNameLabel?.textColor = WMColor.light_blue
        
        self.gradeDescLabel = UILabel()
        self.gradeDescLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.gradeDescLabel?.textColor = WMColor.dark_gray
        
        self.numElementsLabel = UILabel()
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
        self.separator.frame = CGRectMake(0,97, self.frame.width, 1)
        self.layer.insertSublayer(separator, atIndex: 100)
        
        self.addSubview(schoolNameLabel!)
        self.addSubview(gradeDescLabel!)
        self.addSubview(numElementsLabel!)
        self.addSubview(schoolLogo!)
        self.addSubview(saving!)
        self.addSubview(total!)
    }
    
    func setValues(name:String,grade:String,listPrice:String,numArticles:Int,savingPrice:String)
    {
        self.saving!.hidden = true 
        self.schoolNameLabel?.text = name
        self.gradeDescLabel?.text = grade.trim()
        self.numElementsLabel?.text = "\(numArticles) artículos"
        let totalPrice = CurrencyCustomLabel.formatString("\(listPrice)")
        self.total!.updateMount(totalPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        self.saving!.updateMount(savingPrice, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.green, interLine: false)
    }
    
    
}