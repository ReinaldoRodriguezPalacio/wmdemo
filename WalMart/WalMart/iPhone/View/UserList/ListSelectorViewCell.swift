//
//  ListSelectorViewCell.swift
//  WalMart
//
//  Created by neftali on 05/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol ListSelectorCellDelegate {
    func didShowListDetail(cell: ListSelectorViewCell)
}

class ListSelectorViewCell: UITableViewCell {
    
    var indicator: UIButton?
    var openDetail: UIButton?
    var listName: UILabel?
    var articlesTitle: UILabel?
    var separator: UIView?
    var hiddenOpenList : Bool = false
    
    var delegate: ListSelectorCellDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.indicator = UIButton(type: .Custom) as? UIButton
        self.indicator!.setBackgroundImage(UIImage(named: "list_selector_indicator.png"), forState: .Normal)
        self.indicator!.setBackgroundImage(UIImage(named: "list_selector_indicator_selected.png"), forState: .Selected)
        self.indicator!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.indicator!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
        self.indicator!.titleLabel!.font = WMFont.fontMyriadProSemiboldSize(16)
        self.indicator!.selected = false
        self.indicator!.backgroundColor = UIColor.clearColor()
        self.indicator!.userInteractionEnabled = false
        self.contentView.addSubview(self.indicator!)
        
        self.listName = UILabel()
        self.listName!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.listName!.textColor = UIColor.whiteColor()
        self.listName!.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(self.listName!)
        
        self.articlesTitle = UILabel()
        self.articlesTitle!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.articlesTitle!.textColor = UIColor.whiteColor()
        self.articlesTitle!.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(self.articlesTitle!)

        self.openDetail = UIButton(type: .Custom) as? UIButton
        self.openDetail!.setTitle(NSLocalizedString("list.selector.openDetail", comment:""), forState: .Normal)
        self.openDetail!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.openDetail!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.openDetail!.backgroundColor = UIColor.clearColor()
        self.openDetail!.addTarget(self, action: "showListDetail", forControlEvents: .TouchUpInside)
        self.openDetail!.hidden = hiddenOpenList
        self.contentView.addSubview(self.openDetail!)

        self.separator = UIView()
        self.separator!.backgroundColor  = WMColor.UIColorFromRGB(0xFFFFFF, alpha: 0.35)
        self.contentView.addSubview(self.separator!)

        let selectionColor = UIView(frame: CGRectMake(0.0, 0.0, 320, 50.0))
        selectionColor.backgroundColor = WMColor.UIColorFromRGB(0xFFFFFF, alpha: 0.10)
        self.selectedBackgroundView = selectionColor
        
    }
    
    func setListObject(object:NSDictionary, productIncluded:Bool) {
        self.indicator!.selected = productIncluded
        if let name = object["name"] as? String {
            self.listName!.text = name
            self.setupIcon(title: name, productIncluded: productIncluded)
        }
        self.openDetail!.hidden = hiddenOpenList
    }
    
    func setListEntity(entity:List, productIncluded:Bool) {
        self.indicator!.selected = productIncluded
        self.listName!.text = entity.name
        self.articlesTitle!.text = String(format: NSLocalizedString("list.articles", comment:""), entity.countItem)
        self.setupIcon(title: entity.name, productIncluded: productIncluded)
        self.openDetail!.hidden = hiddenOpenList
    }
    
    func setupIcon(title title:String, productIncluded:Bool) {
        if productIncluded {
            self.indicator!.selected = true
        } else {
            self.indicator!.selected = false
        }
    }
    
    func showListDetail() {
        self.delegate?.didShowListDetail(self)
    }
    
    func generateCircleImage(colorImage:UIColor) -> UIImage {
        var screenShot: UIImage? = nil
        autoreleasepool {
            let tempView = UIView(frame: CGRectMake(0, 0, 40.0, 40.0))
            tempView.backgroundColor = colorImage
            tempView.layer.cornerRadius = 20
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(40.0, 40.0), false, 2.0)
            tempView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            screenShot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        return screenShot!
    }

    override func layoutSubviews() {
        let frame = self.contentView.frame
        self.indicator!.frame = CGRectMake(16.0, 8.0, 40.0, 40.0)
        let x = CGRectGetMaxX(self.indicator!.frame) + 16.0
        self.listName!.frame = CGRectMake(x, 16.0, frame.width - (x + 72.0), 16.0)
        self.articlesTitle!.frame = CGRectMake(x, self.listName!.frame.maxY, frame.width - (x + 72.0), 14.0)
        self.openDetail!.frame = CGRectMake(frame.width - 56.0, 8.0, 40.0, 40.0)
        self.separator!.frame = CGRectMake(x, frame.height - 1.0, frame.width - x, 1.0)
        self.selectedBackgroundView!.frame = CGRectMake(0.0, 0.0, frame.width, frame.height)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //self.backgroundColor = selected ? Color.UIColorFromRGB(0xFFFFFF, alpha: 0.10) : UIColor.clearColor()
    }

}
