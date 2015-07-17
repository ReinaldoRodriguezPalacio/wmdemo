//
//  FilterOrderViewCell.swift
//  WalMart
//
//  Created by neftali on 19/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol FilterOrderViewCellDelegate {
    func didChangeOrder(order:String)
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

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        
        self.descAscButton = self.buildButton(FilterType.descriptionAsc)
        self.descDescButton = self.buildButton(FilterType.descriptionDesc)
        self.priceAscButton = self.buildButton(FilterType.priceAsc)
        self.priceDescButton = self.buildButton(FilterType.priceDesc)
        self.popularityButton = self.buildButton(FilterType.popularity)

        self.popularityButton!.selected = true
        self.popularityButton!.backgroundColor = WMColor.navigationTilteTextColor

        self.buttons = [self.descAscButton!, self.descDescButton!, self.priceAscButton!, self.priceDescButton!, self.popularityButton!]
    }
    
    override func layoutSubviews() {
        var size = self.frame.size
        var rest = size.width - (CGFloat(self.buttons!.count - 1) * self.BUTTON_WIDTH)
        var separation = rest/CGFloat(self.buttons!.count )
        var y : CGFloat = 20.0
        var x = separation
        for button in self.buttons! {
            if button == self.popularityButton! {
                button.frame = CGRectMake((self.frame.width / 2) - (self.POPULARITY_WIDTH / 2),y + 20 + self.BUTTON_HEIGHT,self.POPULARITY_WIDTH, self.BUTTON_HEIGHT)
                continue
            }
            button.frame = CGRectMake(x, y, self.BUTTON_WIDTH, self.BUTTON_HEIGHT)
            x = button.frame.maxX + separation
        }
    }
    
    //MARK: - Actions
    
    func setValues(order:String) {
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
                    button.selected = true
                    button.backgroundColor = WMColor.navigationTilteTextColor
                }
                else {
                    button.selected = false
                    button.backgroundColor = UIColor.whiteColor()
                }
            }
        }
    }
    
    func filter(sender:UIButton) {
        if !sender.selected {
            for button in self.buttons! {
                if button == sender {
                    button.selected = true
                    button.backgroundColor = WMColor.navigationTilteTextColor
                }
                else {
                    button.selected = false
                    button.backgroundColor = UIColor.whiteColor()
                }
            }
            
            var index = find(self.buttons!, sender)
            
            var order: String? = nil
            switch (index!) {
            case 0 : order = FilterType.descriptionAsc.rawValue
            case 1 : order = FilterType.descriptionDesc.rawValue
            case 2 : order = FilterType.priceAsc.rawValue
            case 3 : order = FilterType.priceDesc.rawValue
            case 4 : order = FilterType.popularity.rawValue
            default: order = FilterType.none.rawValue
            }
            
            self.delegate?.didChangeOrder(order!)
        }
    }

    //MARK: - Utils
    
    func buildButton(type:FilterType) -> UIButton {
        
        var button = UIButton.buttonWithType(.Custom) as? UIButton
        button!.setTitle(NSLocalizedString(type.rawValue, comment:""), forState: .Normal)
        button!.setTitleColor(WMColor.navigationTilteTextColor, forState: .Normal)
        button!.setTitleColor(WMColor.navigationFilterTextColor, forState: .Selected)
        button!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        button!.layer.cornerRadius = self.BUTTON_HEIGHT/2
        button!.layer.borderWidth = 1.0
        button!.layer.borderColor = WMColor.navigationTilteTextColor.CGColor
        button!.addTarget(self, action: "filter:", forControlEvents: .TouchUpInside)
        self.contentView.addSubview(button!)
        return button!
    }
}
