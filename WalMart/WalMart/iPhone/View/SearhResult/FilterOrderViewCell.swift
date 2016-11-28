//
//  FilterOrderViewCell.swift
//  WalMart
//
//  Created by neftali on 19/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol FilterOrderViewCellDelegate {
    func didChangeOrder(_ order:String)
}

class FilterOrderViewCell: UITableViewCell {
    
    let BUTTON_WIDTH:CGFloat = 55.0
    let POPULARITY_WIDTH:CGFloat = 130.0
    let BUTTON_HEIGHT:CGFloat = 22.0
    
    var descAscButton: UIButton?
    var descDescButton: UIButton?
    var priceAscButton: UIButton?
    var priceDescButton: UIButton?
    var popularityButton: UIButton?
    
    var buttons: [UIButton]?
    var delegate: FilterOrderViewCellDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        if IS_IPAD {
            let oldFrame = self.contentView.frame as CGRect
            self.contentView.frame = CGRect( x: oldFrame.origin.x,y: oldFrame.origin.y,width: oldFrame.size.width,height: oldFrame.size.height + 60)
        }
        self.descAscButton = self.buildButton(FilterType.descriptionAsc)
        self.descDescButton = self.buildButton(FilterType.descriptionDesc)
        self.priceAscButton = self.buildButton(FilterType.priceAsc)
        self.priceDescButton = self.buildButton(FilterType.priceDesc)
        self.popularityButton = self.buildButton(FilterType.popularity)

        self.popularityButton!.isSelected = true
        self.popularityButton!.backgroundColor = WMColor.light_blue

        self.buttons = [self.descAscButton!, self.descDescButton!, self.priceAscButton!, self.priceDescButton!, self.popularityButton!]
    }
    
    override func layoutSubviews() {
        let size = self.frame.size
        let rest = size.width - (CGFloat(self.buttons!.count - 1) * self.BUTTON_WIDTH)
        let separation = rest/CGFloat(self.buttons!.count )
        let y : CGFloat = 20.0
        var x = separation
        for button in self.buttons! {
            if button == self.popularityButton! {
                button.frame = CGRect(x: (self.frame.width / 2) - (self.POPULARITY_WIDTH / 2),y: y + 20 + self.BUTTON_HEIGHT,width: self.POPULARITY_WIDTH, height: self.BUTTON_HEIGHT)
                continue
            }
            button.frame = CGRect(x: x, y: y, width: self.BUTTON_WIDTH, height: self.BUTTON_HEIGHT)
            x = button.frame.maxX + separation
        }
    }
    
    //MARK: - Actions
    
    func setValues(_ order:String) {
        var buttonToSelect:UIButton? = nil
        if let type = FilterType(rawValue: order) {
            switch type {
            case .descriptionAsc: buttonToSelect = self.descAscButton
            case .descriptionDesc: buttonToSelect = self.descDescButton
            case .priceAsc: buttonToSelect = self.priceAscButton
            case .priceDesc: buttonToSelect = self.priceDescButton
            case .popularity: buttonToSelect = self.popularityButton
            default: buttonToSelect = nil
            }
        }
        
        if buttonToSelect != nil {
            for button in self.buttons! {
                if button == buttonToSelect {
                    button.isSelected = true
                    button.backgroundColor = WMColor.light_blue
                }
                else {
                    button.isSelected = false
                    button.backgroundColor = UIColor.white
                }
            }
        }
    }
    
    func filter(_ sender:UIButton) {
        if !sender.isSelected {
            for button in self.buttons! {
                if button == sender {
                    button.isSelected = true
                    button.backgroundColor = WMColor.light_blue
                }
                else {
                    button.isSelected = false
                    button.backgroundColor = UIColor.white
                }
            }
            
            let index = (self.buttons!).index(of: sender)
            
            var order: String? = nil
            //var action = ""
            switch (index!) {
            case 0 : order = FilterType.descriptionAsc.rawValue; //action = WMGAIUtils.ACTION_SORT_BY_A_Z.rawValue
            case 1 : order = FilterType.descriptionDesc.rawValue; //action = WMGAIUtils.ACTION_SORT_BY_Z_A.rawValue
            case 2 : order = FilterType.priceAsc.rawValue; //action = WMGAIUtils.ACTION_SORT_BY_$_$$$.rawValue
            case 3 : order = FilterType.priceDesc.rawValue; //action = WMGAIUtils.ACTION_SORT_BY_$$$_$.rawValue
            case 4 : order =  FilterType.popularity.rawValue ; //action = WMGAIUtils.ACTION_BY_POPULARITY.rawValue
            default: order = FilterType.none.rawValue ; //action = ""
            }
            
//            if action != "" {
//                ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_NO_AUTH.rawValue, action: action, label: "")
//            }
            
            self.delegate?.didChangeOrder(order!)
        }
    }

    //MARK: - Utils
    
    func buildButton(_ type:FilterType) -> UIButton {
        
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString(type.rawValue, comment:""), for: UIControlState())
        button.setTitleColor(WMColor.light_blue, for: UIControlState())
        button.setTitleColor(UIColor.white, for: .selected)
        button.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        button.layer.cornerRadius = self.BUTTON_HEIGHT/2
        button.layer.borderWidth = 1.0
        button.layer.borderColor = WMColor.light_blue.cgColor
        button.addTarget(self, action: #selector(FilterOrderViewCell.filter(_:)), for: .touchUpInside)
        self.contentView.addSubview(button)
        return button
    }
}
