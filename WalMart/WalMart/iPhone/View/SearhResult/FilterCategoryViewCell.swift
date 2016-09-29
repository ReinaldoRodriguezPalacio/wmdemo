//
//  FilterCategoryViewCell.swift
//  WalMart
//
//  Created by neftali on 19/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

enum CategoryType {
    case department, family, line, facet
}

class FilterCategoryViewCell: UITableViewCell {

    var check: UIImageView?
    var name: UILabel?
    var type: CategoryType = .department
    var upcs: [String]?
    var separator: UIView?
    
    var upperTextColor = WMColor.light_blue
    var lineTextColor = WMColor.reg_gray
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        
        self.check = UIImageView()
        self.contentView.addSubview(self.check!)
        
        self.name = UILabel()
        self.name!.font = WMFont.fontMyriadProLightOfSize(16)
        self.name!.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(self.name!)
        
        self.separator = UIView()
        self.separator!.backgroundColor = WMColor.light_gray
        self.contentView.addSubview(self.separator!)
    }
    
    override func layoutSubviews() {
        let size = self.frame.size
        let separation:CGFloat = 16.0
        
        var x: CGFloat = separation
        if self.type == .family {
            x += 32.0
        }
        else if self.type == .line {
            x += 64.0
        }
        
        self.check!.frame = CGRectMake(x, (size.height - 16.0)/2, 16.0, 16.0)
        self.name!.frame = CGRectMake(self.check!.frame.maxX + separation, 0.0, size.width - (self.check!.frame.maxX + separation), size.height)
        self.separator!.frame = CGRectMake(0.0, size.height - 1, size.width, 1.0)
    }
    
    //MARK: - Actions
    
    func setValues(item:[String:AnyObject], selected:Bool) {
        
        self.type = .department
        if let level = item["level"] as? NSNumber {
            if level.integerValue == 0 {
                self.type = .department
                self.name!.textColor = self.upperTextColor
                self.check!.image = UIImage(named: "filter_check_blue")
                self.check!.highlightedImage = UIImage(named: "filter_check_blue_selected")
                 self.separator!.hidden = false
            }
            else if level.integerValue == 1 {
                self.type = .family
                self.name!.textColor = self.upperTextColor
                self.check!.image = UIImage(named: "filter_check_blue")
                self.check!.highlightedImage = UIImage(named: "filter_check_select_blue")
                self.separator!.hidden = true
            }
            else if level.integerValue == 2 {
                self.type = .line
                self.name!.textColor = self.upperTextColor
                self.check!.image = UIImage(named: "filter_check_blue")
                self.check!.highlightedImage = UIImage(named: "filter_check_select_blue")
                self.separator!.hidden = true
            }
        }

        self.name!.text = item["name"] as? String
        //TEST
        if let type = item["responseType"] as? String {
            if type == ResultObjectType.Mg.rawValue {
                self.name!.text = "\(self.name!.text!)"
            }
        }
        self.check!.highlighted = selected
    }
    
    func setValuesFacets(item:[String:AnyObject]?,nameBrand:String, selected:Bool){
        
        self.type = .facet
        self.name!.textColor = self.upperTextColor
        self.check!.image = UIImage(named: "filter_check_blue")
        self.check!.highlightedImage = UIImage(named: "filter_check_select_blue")
        //self.separator!.hidden = false
        
        if item?["itemName"] as? String == ""{
            self.check!.hidden = true
            
        }
        else{ self.check!.hidden = false
            
        }
        var countItem  =  0
        var name  = ""
        
        if item != nil {
            self.upcs = item!["upcs"] as? [String]
            countItem = self.upcs!.count
            name =  item!["itemName"] as! String
        }
        
        self.name!.text = item != nil ? "\(name) (\(countItem))": nameBrand
        
        self.check!.highlighted = selected
    }
    
     func setValuesSelectAll( selected:Bool, isFacet:Bool){
        
        self.type = .facet
        self.name!.textColor = self.upperTextColor
        self.check!.image = UIImage(named: "filter_check_blue")
        self.check!.highlightedImage = UIImage(named: "radio_full")
        self.separator!.hidden = false
        
         self.name!.text = isFacet ? NSLocalizedString("product.search.filterall", comment: "") : NSLocalizedString("product.search.departments", comment: "")
        self.check!.highlighted = selected
    }
    
    
    
}
