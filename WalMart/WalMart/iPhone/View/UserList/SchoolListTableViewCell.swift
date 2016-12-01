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
        self.schoolLogo!.frame = CGRect(x: 16, y: 16, width: 72, height: 66)
        self.schoolNameLabel!.frame = CGRect(x: self.schoolLogo!.frame.maxX + 16, y: 16, width: self.frame.width - (self.schoolLogo!.frame.maxX + 32), height: 14)
        self.gradeDescLabel!.frame = CGRect(x: self.schoolLogo!.frame.maxX + 16, y: self.schoolNameLabel!.frame.maxY + 4, width: self.frame.width - (self.schoolLogo!.frame.maxX + 32), height: 12)
        self.numElementsLabel!.frame = CGRect(x: self.schoolLogo!.frame.maxX + 16, y: self.gradeDescLabel!.frame.maxY + 4, width: 113, height: 12)
        self.total!.frame = CGRect(x: self.frame.width - 106, y: self.numElementsLabel!.frame.maxY - 5, width: 90, height: 18)
        self.saving!.frame = CGRect(x: self.frame.width - 106, y: self.total!.frame.maxY + 4, width: 90, height: 14)
        self.separator.frame = CGRect(x: 0, y: 97, width: self.frame.width, height: 1)
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
        self.total!.backgroundColor = UIColor.clear
        self.total!.textAlignment = .right
        self.total!.updateMount("199.00", font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        
        self.saving = CurrencyCustomLabel()
        self.saving!.backgroundColor = UIColor.clear
        self.saving!.textAlignment = .right
        self.saving!.updateMount("Ahorras $217.70", font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.green, interLine: false)
        
        self.separator = CALayer()
        self.separator.backgroundColor = WMColor.light_light_gray.cgColor
        self.separator.frame = CGRect(x: 0,y: 97, width: self.frame.width, height: 1)
        self.layer.insertSublayer(separator, at: 100)
        
        self.addSubview(schoolNameLabel!)
        self.addSubview(gradeDescLabel!)
        self.addSubview(numElementsLabel!)
        self.addSubview(schoolLogo!)
        self.addSubview(saving!)
        self.addSubview(total!)
    }
    
    func setValues(_ name:String,grade:String,listPrice:String,numArticles:Int,savingPrice:String)
    {
        self.saving!.isHidden = true 
        self.schoolNameLabel?.text = name
        self.gradeDescLabel?.text = grade.trim()
        self.numElementsLabel?.text = "\(numArticles) artículos"
        let totalPrice = CurrencyCustomLabel.formatString("\(listPrice)" as NSString)
        self.total!.updateMount(totalPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        self.saving!.updateMount(savingPrice, font: WMFont.fontMyriadProRegularOfSize(14), color: WMColor.green, interLine: false)
    }
    
    
}
