//
//  DetailListViewCell.swift
//  WalMart
//
//  Created by neftali on 11/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

protocol DetailListViewCellDelegate {
    func didChangeQuantity(cell:DetailListViewCell)
    func didDisable(disaable:Bool,cell:DetailListViewCell)
}

class DetailListViewCell: ProductTableViewCell {

    let leftBtnWidth:CGFloat = 48.0

    var promoDescription: UILabel?
    var separator: UIView?
    var quantityIndicator: UIButton?
    var check: UIButton?
    
    
    var equivalenceByPiece: NSNumber? = NSNumber(int:0)
    
    var detailDelegate: DetailListViewCellDelegate?
    
    var imageGrayScale: UIImage? = nil
    var imageNormal: UIImage? = nil
    
    var total: String? = ""
    var upcVal: String? = ""
    
    var defaultList = true
    var hasStock:Bool = true
    
    
    override func setup() {
        super.setup()
        
        self.selectionStyle = .None
        
        self.promoDescription = UILabel()
        self.promoDescription!.textColor = WMColor.green
        self.promoDescription!.font = WMFont.fontMyriadProSemiboldOfSize(12)
        self.promoDescription!.numberOfLines = 2
        self.promoDescription!.textAlignment = .Center
        self.contentView.addSubview(self.promoDescription!)
        
        self.productShortDescriptionLabel!.textColor = WMColor.gray
        self.productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.productShortDescriptionLabel!.numberOfLines = 2
        self.productShortDescriptionLabel!.adjustsFontSizeToFitWidth = true
        self.productShortDescriptionLabel!.minimumScaleFactor = 9 / 12

        self.productPriceLabel!.textAlignment = .Left

        self.quantityIndicator = UIButton(type: .Custom)
        self.quantityIndicator!.setTitle("", forState: .Normal)
        self.quantityIndicator!.setTitle(NSLocalizedString("productdetail.shopna",comment:""), forState: UIControlState.Disabled)
        self.quantityIndicator!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.quantityIndicator!.titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(14.0)
        self.quantityIndicator!.backgroundColor = WMColor.yellow
        self.quantityIndicator!.addTarget(self, action: #selector(DetailListViewCell.changeQuantity), forControlEvents: .TouchUpInside)
        self.quantityIndicator!.layer.cornerRadius = 16.0
        self.contentView.addSubview(self.quantityIndicator!)

        self.separator = UIView(frame:CGRectMake(16, bounds.height - 1.0,self.frame.width - 16, 1.0))
        self.separator!.backgroundColor = WMColor.light_light_gray
        self.contentView.addSubview(self.separator!)
        
        
        self.check = UIButton(frame: CGRectMake(0, 0, 40, 109))
        self.check?.setImage(UIImage(named: "list_check_empty"), forState: UIControlState.Normal)
        self.check?.setImage(UIImage(named: "list_check_full"), forState: UIControlState.Selected)
        self.check?.addTarget(self, action: #selector(DetailListViewCell.checked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.check?.selected = true
        self.contentView.addSubview(self.check!)

        var buttonDelete = UIButton(frame: CGRectMake(0, 0, 64, 109))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), forState: UIControlState.Normal)
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        self.rightUtilityButtons = [buttonDelete]

        buttonDelete = UIButton()
        buttonDelete.setImage(UIImage(named:"myList_delete"), forState: .Normal)
        buttonDelete.backgroundColor = WMColor.light_gray
        
       
        
        self.setLeftUtilityButtons([buttonDelete], withButtonWidth: self.leftBtnWidth)
        
        
    }
    

    func setValuesDictionary(product:[String:AnyObject],disabled:Bool) {
        let imageUrl = product["imageUrl"] as! String
        self.productImage!.contentMode = UIViewContentMode.Center
        self.productImage!.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: imageUrl)!),
            placeholderImage: UIImage(named:"img_default_table"),
            success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                self.productImage!.contentMode = self.contentModeOrig
                self.productImage!.image = image
                self.imageGrayScale = self.convertImageToGrayScale(image)
                self.imageNormal = image
                
            }, failure: nil)
        self.promoDescription!.text = product["promoDescription"] as? String
        self.productShortDescriptionLabel!.text = product["description"] as? String
        self.upcVal = product["upc"] as? String
 
        if let equivalence = product["equivalenceByPiece"] as? NSNumber {
            self.equivalenceByPiece = equivalence
        }
        
        if let equivalence = product["equivalenceByPiece"] as? NSString {
            if equivalence != "" {
                self.equivalenceByPiece =  NSNumber(int: equivalence.intValue)
            }
        }
        
        if let type = product["type"] as? String {
            let quantity = product["quantity"] as! NSNumber
            let price = product["price"] as! NSNumber
            var text: String? = ""
            var total: Double = 0.0
            //Piezas
            if Int(type)! == 0 {
                if quantity.integerValue == 1 {
                    text = String(format: NSLocalizedString("list.detail.quantity.piece", comment:""), quantity)
                }
                else {
                    text = String(format: NSLocalizedString("list.detail.quantity.pieces", comment:""), quantity)
                }
                total = (quantity.doubleValue * price.doubleValue)
            }
                //Gramos
            else {
                let q = quantity.doubleValue
                if q < 1000.0 {
                    text = String(format: NSLocalizedString("list.detail.quantity.gr", comment:""), quantity)
                }
                else {
                    let kg = q/1000.0
                    text = String(format: NSLocalizedString("list.detail.quantity.kg", comment:""), NSNumber(double: kg))
                }
                let kgrams = quantity.doubleValue / 1000.0
                total = (kgrams * price.doubleValue)
            }
            self.quantityIndicator!.setTitle(text!, forState: .Normal)
            
            
            let formatedPrice = CurrencyCustomLabel.formatString("\(total)")
            self.total = formatedPrice
            self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
            
        }
        else {
            self.quantityIndicator!.setTitle("", forState: .Normal)
        }
        
        
       
        checkDisabled(disabled)
        
        if let stock = product["stock"] as? NSString {
            if stock.integerValue == 0 {
                self.quantityIndicator!.enabled = false
                self.quantityIndicator!.backgroundColor = WMColor.light_gray
                self.hasStock = false
            } else {
                self.quantityIndicator!.enabled = true
                self.quantityIndicator!.backgroundColor = WMColor.yellow
                self.hasStock = true
            }
        }
        
        if let stock = product["stock"] as? Bool {
            if stock {
                self.quantityIndicator!.enabled = true
                self.quantityIndicator!.backgroundColor = WMColor.yellow
                self.hasStock = true
            } else {
                self.quantityIndicator!.enabled = false
                self.quantityIndicator!.backgroundColor = WMColor.light_gray
                self.hasStock = false
            }
        }
    }
    
    func setValues(product:Product,disabled:Bool) {
        let imageUrl = product.img
        let description = product.desc
        
        self.productImage!.contentMode = UIViewContentMode.Center
        self.productImage!.setImageWithURLRequest(NSURLRequest(URL:NSURL(string: imageUrl)!),
            placeholderImage: UIImage(named:"img_default_table"),
            success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                self.productImage!.contentMode = self.contentModeOrig
                self.productImage!.image = image
                self.imageGrayScale = self.convertImageToGrayScale(image)
                self.imageNormal = image
                
            }, failure: nil)
        
         self.upcVal = product.upc
        self.promoDescription!.text = ""
        self.productShortDescriptionLabel!.text = description
        
        let quantity = product.quantity
        let price = product.price.doubleValue
        var text: String? = ""
        var total: Double = 0.0
        //Piezas
        if product.type.integerValue == 0 {
            if quantity.integerValue == 1 {
                text = String(format: NSLocalizedString("list.detail.quantity.piece", comment:""), quantity)
            }
            else {
                text = String(format: NSLocalizedString("list.detail.quantity.pieces", comment:""), quantity)
            }
            total = (quantity.doubleValue * price)
        }
        //Gramos
        else {
            let q = quantity.doubleValue
            if q < 1000.0 {
                text = String(format: NSLocalizedString("list.detail.quantity.gr", comment:""), quantity)
            }
            else {
                let kg = q/1000.0
                text = String(format: NSLocalizedString("list.detail.quantity.kg", comment:""), NSNumber(double: kg))
            }
            let kgrams = quantity.doubleValue / 1000.0
            total = (kgrams * price)
        }
        self.quantityIndicator!.setTitle(text!, forState: .Normal)
        let formatedPrice = CurrencyCustomLabel.formatString("\(total)")
        self.total = formatedPrice
        self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        
        checkDisabled(disabled)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.frame.size
        let sep: CGFloat = 16.0

        self.productImage!.frame = CGRectMake(self.check!.frame.maxX, 0.0, 80.0, bounds.height)
        let x:CGFloat = self.productImage!.frame.maxX + sep
        self.productShortDescriptionLabel!.frame = CGRectMake(x, sep, bounds.width - (x + sep), 28.0)
        if self.quantityIndicator!.enabled {
            var size = self.sizeForButton(self.quantityIndicator!)
            size.width = (size.width + (sep*2))
            self.quantityIndicator!.frame = CGRectMake(bounds.width - (sep + size.width), bounds.height - (32.0 + sep), size.width, 32.0)
        }else {
            self.quantityIndicator!.frame = CGRectMake(bounds.width - (sep + 102), bounds.height - (32.0 + sep), 102, 32.0)
        }
        
        self.productPriceLabel!.frame = CGRectMake(x, self.quantityIndicator!.frame.minY, 100.0, 19.0)
        if self.promoDescription!.text == nil || self.promoDescription!.text!.isEmpty {
            self.productPriceLabel!.center = CGPointMake(self.productPriceLabel!.center.x, self.quantityIndicator!.center.y)
            self.promoDescription!.frame = CGRectZero
        }
        else {
            self.promoDescription!.frame = CGRectMake(x, self.productPriceLabel!.frame.maxY, 80.0, 26.0)
        }

        self.separator!.frame = CGRectMake(16, 108,self.frame.width - 16, 1.0)
        
        
    }
    
    func sizeForButton(button:UIButton) -> CGSize {
        let text = button.titleForState(.Normal)
        let font = button.titleLabel!.font
        let computedRect: CGRect = text!.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font],
            context: nil)
        return CGSizeMake(ceil(computedRect.size.width), ceil(computedRect.size.height))
    }

    //MARK: - Actions
    
    func changeQuantity() {
        self.detailDelegate?.didChangeQuantity(self)
        if defaultList {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: "GR_\(WMGAIUtils.ACTION_OPEN_KEYBOARD.rawValue)", label: "\(self.productShortDescriptionLabel!.text!) - \(upcVal)")
        } else {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action: "GR_\(WMGAIUtils.ACTION_OPEN_KEYBOARD.rawValue)", label: "\(self.productShortDescriptionLabel!.text!) - \(upcVal)")
        }
        
    }
    
    func checked(sender:UIButton) {
        if defaultList {
        if sender.selected {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DISABLE_PRODUCT.rawValue, label: "\(self.productShortDescriptionLabel!.text!) - \(upcVal)")
        } else {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ENABLE_PRODUCT.rawValue, label: "\(self.productShortDescriptionLabel!.text!) - \(upcVal)")
        }
        } else {
            if sender.selected {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action: WMGAIUtils.ACTION_DISABLE_PRODUCT.rawValue, label: "\(self.productShortDescriptionLabel!.text!) - \(upcVal)")
            } else {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action: WMGAIUtils.ACTION_ENABLE_PRODUCT.rawValue, label: "\(self.productShortDescriptionLabel!.text!) - \(upcVal)")
            }
        }
        
        sender.selected = !sender.selected
        checkDisabled(!sender.selected)
        detailDelegate?.didDisable(!sender.selected,cell:self)
        
        
    }
    
    func convertImageToGrayScale(image:UIImage) -> UIImage {
        
        let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGBitmapContextCreate(nil, Int(image.size.width),  Int(image.size.height), 8, 0, colorSpace, CGBitmapInfo().rawValue)
        CGContextDrawImage(context, imageRect,image.CGImage)
        let imageRef = CGBitmapContextCreateImage(context)
        let newImage = UIImage(CGImage: imageRef!)
        return newImage
        
    }
    
    
    func checkDisabled(disabled:Bool) {
        self.check!.selected = !disabled
        if disabled {
            self.productShortDescriptionLabel?.textColor = WMColor.empty_gray_btn
            self.productPriceLabel!.updateMount(self.total!, font: WMFont.fontMyriadProSemiboldSize(18), color:WMColor.empty_gray_btn, interLine: false)
            self.productImage!.image = imageGrayScale
            self.quantityIndicator?.backgroundColor = WMColor.light_gray
            self.promoDescription?.textColor = WMColor.empty_gray_btn
        } else {
            self.productShortDescriptionLabel!.textColor = WMColor.gray
            self.productPriceLabel!.updateMount(self.total!, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
            self.productImage!.image = imageNormal
            self.quantityIndicator!.backgroundColor = self.hasStock ? WMColor.yellow : WMColor.light_gray
            self.promoDescription?.textColor = WMColor.green
        }
    }
    
    override func showLeftUtilityButtonsAnimated(animated: Bool) {
        super.showLeftUtilityButtonsAnimated(animated)
        self.check?.alpha = 0.0
    }
    
    override func hideUtilityButtonsAnimated(animated: Bool) {
        super.hideUtilityButtonsAnimated(animated)
        self.check?.alpha = 1.0
    }

}
