//
//  ListSelectorViewCell.swift
//  WalMart
//
//  Created by neftali on 05/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol ListSelectorCellDelegate: class {
    func didShowListDetail(_ cell: ListSelectorViewCell)
    func showKeyboardUpdateQuantity(_ cell: ListSelectorViewCell)
    func didSelectedList(_ cell: ListSelectorViewCell)
}

class ListSelectorViewCell: UITableViewCell {
    
    var indicator: UIButton?
    var openDetail: UIButton?
    var listName: UILabel?
    var articlesTitle: UILabel?
    var separator: UIView?
    var hiddenOpenList : Bool = false
    var pesable : Bool = false
    var productInList =  false
    
    weak var delegate: ListSelectorCellDelegate?
    let viewBg = UIView(frame: CGRect(x: 0, y: 0, width: 100, height:18))

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.indicator = UIButton(type: .custom) as UIButton
        self.indicator!.setBackgroundImage(UIImage(named: "list_selector_indicator.png"), for: UIControlState())
        self.indicator!.setBackgroundImage(UIImage(named: "list_selector_indicator_selected.png"), for: .selected)
        self.indicator!.setTitleColor(UIColor.white, for: UIControlState())
        self.indicator!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
        self.indicator!.titleLabel!.font = WMFont.fontMyriadProSemiboldSize(16)
        self.indicator!.isSelected = false
        self.indicator!.backgroundColor = UIColor.clear
        self.indicator?.addTarget(self, action: #selector(ListSelectorViewCell.selectedList), for: UIControlEvents.touchUpInside)
        //self.indicator!.isUserInteractionEnabled = true
        
        self.contentView.addSubview(self.indicator!)
        
        
        self.listName = UILabel()
        self.listName!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.listName!.textColor = UIColor.white
        self.listName!.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.listName!)
        
        self.articlesTitle = UILabel()
        self.articlesTitle!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.articlesTitle!.textColor = UIColor.white
        self.articlesTitle!.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.articlesTitle!)

        self.openDetail = UIButton(type: .custom) as UIButton
        //self.openDetail!.setTitle(NSLocalizedString("list.selector.openDetail", comment:""), for: UIControlState())
        self.openDetail!.setTitleColor(UIColor.white, for: UIControlState())
        self.openDetail!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.openDetail!.backgroundColor = UIColor.clear
        self.openDetail!.addTarget(self, action: #selector(ListSelectorViewCell.showKeyboardUpdateQuantity), for: .touchUpInside)
        self.openDetail!.isHidden = hiddenOpenList
        self.contentView.addSubview(self.openDetail!)

        self.separator = UIView()
        self.separator!.backgroundColor  = UIColor.white.withAlphaComponent(0.35)
        self.contentView.addSubview(self.separator!)

        let selectionColor = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 320, height: 50.0))
        selectionColor.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        self.selectedBackgroundView = selectionColor
        
    }
    
    func selectedList(){
        print("selectedList")
        if !self.productInList {
            self.delegate?.didSelectedList(self)
            self.indicator!.isSelected = !self.indicator!.isSelected
        }
        
    }
    
    func setListObject(_ object:[String:Any], productIncluded:Bool) {
        self.productInList = productIncluded
        self.indicator!.isSelected = productIncluded
        if let name = object["name"] as? String {
            self.listName!.text = name
            self.setupIcon(title: name, productIncluded: productIncluded)
        }
        self.openDetail!.isHidden = hiddenOpenList
        self.openDetail!.isHidden = !productIncluded
    }
    
    func setListEntity(_ entity:List,_ upc:String, productIncluded:Bool) {
        self.indicator!.isSelected = productIncluded
        self.productInList = productIncluded
        self.listName!.text = entity.name
        self.articlesTitle!.text = String(format: NSLocalizedString("list.articles", comment:""), entity.countItem)
        self.setupIcon(title: entity.name, productIncluded: productIncluded)
        self.openDetail!.isHidden = hiddenOpenList
        
        if productIncluded {
            let productsFound = (entity.products.allObjects as! [Product]).filter { (product) -> Bool in
                return product.upc == upc
            }
            if productsFound.first?.quantity ?? 0 > -1 {
                viewBg.layer.cornerRadius = 9
                viewBg.backgroundColor = WMColor.yellow
                viewBg.isUserInteractionEnabled = false
                openDetail?.addSubview(viewBg)
                openDetail?.sendSubview(toBack: viewBg)
                
                let strQuantity = ShoppingCartButton.quantityString(productsFound.first?.quantity.intValue ?? 0, pesable: self.pesable, orderByPieces:productsFound.first?.orderByPiece.boolValue ?? false, pieces: productsFound.first?.pieces.intValue ?? 0)
                openDetail?.setTitle(strQuantity, for: .normal)
                

            }
        }
        self.openDetail!.isHidden = !productIncluded
        
    }
    
    func setupIcon(title:String, productIncluded:Bool) {
        if productIncluded {
            self.indicator!.isSelected = true
        } else {
            self.indicator!.isSelected = false
        }
    }
//    
//    func showListDetail() {
//        //EVENT
//        //BaseController.sendAnalytics(WMGAIUtils.ACTION_ADD_TO_LIST.rawValue, action:WMGAIUtils.ACTION_OPEN_LIST.rawValue, label: self.listName!.text!)
//        self.delegate?.didShowListDetail(self)
//    }
    
    
    func showKeyboardUpdateQuantity() {
        self.delegate?.showKeyboardUpdateQuantity(self)
    }
    
    func generateCircleImage(_ colorImage:UIColor) -> UIImage {
        var screenShot: UIImage? = nil
        autoreleasepool {
            let tempView = UIView(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
            tempView.backgroundColor = colorImage
            tempView.layer.cornerRadius = 20
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 40.0, height: 40.0), false, 2.0)
            tempView.layer.render(in: UIGraphicsGetCurrentContext()!)
            screenShot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        return screenShot!
    }

    override func layoutSubviews() {
        let frame = self.contentView.frame
        self.indicator!.frame = CGRect(x: 16.0, y: 8.0, width: 40.0, height: 40.0)
        let x = self.indicator!.frame.maxX + 16.0
        self.listName!.frame = CGRect(x: x, y: 16.0, width: frame.width - (x + 72.0), height: 16.0)
        self.articlesTitle!.frame = CGRect(x: x, y: self.listName!.frame.maxY, width: frame.width - (x + 72.0), height: 14.0)
        self.separator!.frame = CGRect(x: x, y: frame.height - 1.0, width: frame.width - x, height: 1.0)
        self.selectedBackgroundView!.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        
        if let sizeButton = openDetail?.titleLabel?.sizeThatFits(CGSize.zero) {
            self.openDetail!.frame = CGRect(x: frame.width - (sizeButton.width + 26), y: 8.0, width: sizeButton.width + 10, height: 40.0)
            viewBg.frame = CGRect(x: 0, y: 0, width: sizeButton.width + 10, height: 18)
            viewBg.center = CGPoint(x: openDetail!.frame.width / 2, y: openDetail!.frame.height / 2)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //self.backgroundColor = selected ? UIColor.whiteColor().colorWithAlphaComponent(0.10) : UIColor.clearColor()
    }

}
