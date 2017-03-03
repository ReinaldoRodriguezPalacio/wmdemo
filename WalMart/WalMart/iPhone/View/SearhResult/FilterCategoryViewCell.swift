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
        self.selectionStyle = .none
        
        self.check = UIImageView()
        self.contentView.addSubview(self.check!)
        
        self.name = UILabel()
        self.name!.font = WMFont.fontMyriadProLightOfSize(16)
        self.name!.backgroundColor = UIColor.white
        self.contentView.addSubview(self.name!)
        
        self.separator = UIView()
        self.separator!.backgroundColor = WMColor.light_gray
        //self.contentView.addSubview(self.separator!)
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
        
        self.check!.frame = CGRect(x: x, y: (size.height - 16.0)/2, width: 16.0, height: 16.0)
        self.name!.frame = CGRect(x: self.check!.frame.maxX + separation, y: 0.0, width: size.width - (self.check!.frame.maxX + separation), height: size.height)
        self.separator!.frame = CGRect(x: 0.0, y: size.height - 1, width: size.width, height: 1.0)
    }
    
    //MARK: - Actions
    
    func setValues(_ item:[String:Any], selected:Bool) {
        
        self.type = .department
        if let level = item["level"] as? NSNumber {
            if level.intValue == 0 {
                self.type = .department
                self.name!.textColor = self.upperTextColor
                self.check!.image = UIImage(named: "filter_check_blue")
                self.check!.highlightedImage = UIImage(named: "filter_check_blue_selected")
                 self.separator!.isHidden = false
            }
            else if level.intValue == 1 {
                self.type = .family
                self.name!.textColor = self.upperTextColor
                self.check!.image = UIImage(named: "filter_check_blue")
                self.check!.highlightedImage = UIImage(named: "filter_check_select_blue")
                self.separator!.isHidden = true
            }
            else if level.intValue == 2 {
                self.type = .line
                self.name!.textColor = self.upperTextColor
                self.check!.image = UIImage(named: "filter_check_blue")
                self.check!.highlightedImage = UIImage(named: "filter_check_select_blue")
                self.separator!.isHidden = true
            }
        }

        self.name!.text = item["name"] as? String
        //TEST
        if let type = item["responseType"] as? String {
            if type == ResultObjectType.Mg.rawValue {
                self.name!.text = "\(self.name!.text!)"
            }
        }
        self.check!.isHighlighted = selected
    }
    
    func setValuesFacets(_ item:[String:Any]?,nameBrand:String, selected:Bool){
        
        self.type = .facet
        self.name!.textColor = self.upperTextColor
        self.check!.image = UIImage(named: "filter_check_blue")
        self.check!.highlightedImage = UIImage(named: "filter_check_select_blue")
        //self.separator!.hidden = false
        
        if item?["itemName"] as? String == ""{
            self.check!.isHidden = true
            
        }
        else{ self.check!.isHidden = false
            
        }
        var countItem  =  0
        var name  = ""
        
        if item != nil {
            self.upcs = item!["upcs"] as? [String]
            countItem = self.upcs!.count
            name =  item!["itemName"] as! String
        }
        
        self.name!.text = item != nil ? "\(name) (\(countItem))": nameBrand
        
        self.check!.isHighlighted = selected
    }
    
     func setValuesSelectAll( _ selected:Bool, isFacet:Bool){
        
        self.type = .facet
        self.name!.textColor = self.upperTextColor
        self.check!.image = UIImage(named: "filter_check_blue")
        self.check!.highlightedImage = UIImage(named: "radio_full")
        self.separator!.isHidden = false
        
         self.name!.text = isFacet ? NSLocalizedString("product.search.filterall", comment: "") : NSLocalizedString("product.search.departments", comment: "")
        self.check!.isHighlighted = selected
    }
    
    
    
}
