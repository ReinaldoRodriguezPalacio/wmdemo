//
//  DetailListViewCell.swift
//  WalMart
//
//  Created by neftali on 11/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol DetailListViewCellDelegate {
    func didChangeQuantity(_ cell:DetailListViewCell)
    func didDisable(_ disaable:Bool,cell:DetailListViewCell)
}

class DetailListViewCell: ProductTableViewCell {

    let leftBtnWidth:CGFloat = 48.0

    var promoDescription: UILabel?
    var separator: UIView?
    var quantityIndicator: UIButton?
    var check: UIButton?
    var equivalenceByPiece: NSNumber? = NSNumber(value: 0 as Int32)
    var detailDelegate: DetailListViewCellDelegate?
    var viewIpad : UIView?
    var imageGrayScale: UIImage? = nil
    var imageNormal: UIImage? = nil
    var total: String? = ""
    var upcVal: String? = ""
    var defaultList = true
    var hasStock:Bool = true
    var onHandInventory: Int = 0
    var productDeparment: String = ""
    
    var imagePresale : UIImageView!
    var promotiosView  : PLPLegendView?
    
    override func setup() {
        super.setup()
        
        self.selectionStyle = .none
        
        self.promoDescription = UILabel()
        self.promoDescription!.textColor = WMColor.green
        self.promoDescription!.font = WMFont.fontMyriadProSemiboldOfSize(12)
        self.promoDescription!.numberOfLines = 2
        self.promoDescription!.textAlignment = .left
        self.promoDescription!.backgroundColor =  UIColor.white
        self.contentView.addSubview(self.promoDescription!)
        
        self.productShortDescriptionLabel!.textColor = WMColor.reg_gray
        self.productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.productShortDescriptionLabel!.numberOfLines = 2
        self.productShortDescriptionLabel!.adjustsFontSizeToFitWidth = true
        self.productShortDescriptionLabel!.minimumScaleFactor = 9 / 12

        self.productPriceLabel!.textAlignment = .left

        self.quantityIndicator = UIButton(type: .custom)
        self.quantityIndicator!.setTitle("", for: UIControlState())
        self.quantityIndicator!.setTitle(NSLocalizedString("productdetail.shopna",comment:""), for: UIControlState.disabled)
        self.quantityIndicator!.setTitleColor(UIColor.white, for: UIControlState())
        self.quantityIndicator!.titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(14.0)
        self.quantityIndicator!.backgroundColor = WMColor.yellow
        self.quantityIndicator!.addTarget(self, action: #selector(DetailListViewCell.changeQuantity), for: .touchUpInside)
        self.quantityIndicator!.layer.cornerRadius = 16.0
        self.contentView.addSubview(self.quantityIndicator!)

        self.separator = UIView(frame:CGRect(x: 16, y: bounds.height - 1.0,width: self.frame.width - 16, height: 1.0))
        self.separator!.backgroundColor = WMColor.light_light_gray
        self.contentView.addSubview(self.separator!)
        
        self.check = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 109))
        self.check?.setImage(UIImage(named: "list_check_empty"), for: UIControlState())
        self.check?.setImage(UIImage(named: "list_check_full"), for: UIControlState.selected)
        self.check?.addTarget(self, action: #selector(DetailListViewCell.checked(_:)), for: UIControlEvents.touchUpInside)
        self.check?.isSelected = true
        self.contentView.addSubview(self.check!)

        var buttonDelete = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 109))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), for: UIControlState())
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        self.rightUtilityButtons = [buttonDelete]

        buttonDelete = UIButton()
        buttonDelete.setImage(UIImage(named:"myList_delete"), for: UIControlState())
        buttonDelete.backgroundColor = WMColor.light_gray
        
       
        
        self.setLeftUtilityButtons([buttonDelete], withButtonWidth: self.leftBtnWidth)
        
        imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
        imagePresale.isHidden =  true
        self.addSubview(imagePresale)
    }
    
    func setValueArray(_ plpArray:NSArray){
        if plpArray.count > 0 {
            promotiosView = PLPLegendView(isvertical: false, PLPArray: plpArray, viewPresentLegend: IS_IPAD ? self.viewIpad! : self)
            self.contentView.addSubview(self.promotiosView!)
        }
    }

    /**
      Values from listedailviewcontroller, validate type product and if is checket,
      and if present promotios, type keyboards
     
     - parameter product:  array products
     - parameter disabled: validate if row is active
     */
    func setValuesDictionary(_ product:[String:Any],disabled:Bool, productPriceThrough:String, isMoreArts:Bool) {
        var imageUrl = ""
        var descriptionItem = ""
        var upcItem = ""
        var weighable = ""
        
        if let sku = product["sku"] as? [String:Any] {
            if let parentProducts = sku.object(forKey: "parentProducts") as? NSArray{
                if let item =  parentProducts.object(at: 0) as? [String:Any] {
                    imageUrl = item["largeImageUrl"] as! String
                    descriptionItem = item["description"] as! String
                    upcItem = item["repositoryId"] as! String
                }
            }
            weighable = sku["weighable"] as! String
        }
        
        
        self.productImage!.contentMode = UIViewContentMode.center
        self.productImage!.setImageWith(URLRequest(url: URL(string: imageUrl)!),
            placeholderImage: UIImage(named:"img_default_table"),
            success: { (request:URLRequest!, response:HTTPURLResponse!, image:UIImage!) -> Void in
                self.productImage!.contentMode = self.contentModeOrig
                self.productImage!.image = image
                self.imageGrayScale = self.convertImageToGrayScale(image)
                self.imageNormal = image
                
            }, failure: nil)
        //self.promoDescription!.text = product["promoDescription"] as? String
        var savingPrice = ""
        if productPriceThrough != "" { //&& type == ResultObjectType.Groceries.rawValue
            self.promoDescription!.textColor = WMColor.green
            if isMoreArts {
                let doubleVaule = NSString(string: productPriceThrough).doubleValue
                if doubleVaule > 0.1 {
                    let savingStr = NSLocalizedString("price.saving",comment:"")
                    let formated = CurrencyCustomLabel.formatString("\(productPriceThrough)" as NSString)
                    savingPrice = "\(savingStr) \(formated)"
                }
            } else {
                savingPrice = productPriceThrough
            }
        }
        
        if savingPrice != ""{
            self.promoDescription!.isHidden = false
            self.promoDescription!.text = savingPrice
            self.promoDescription!.font = WMFont.fontMyriadProSemiboldOfSize(12)
        } else{
            self.promoDescription!.isHidden = true
        }
        
        self.productShortDescriptionLabel!.text = descriptionItem // product["description"] as? String
        self.upcVal = upcItem// product["upc"] as? String
 
        //TODO Pendiente como llgara parametro
        if let equivalence = product["equivalenceByPiece"] as? NSNumber {
            self.equivalenceByPiece = equivalence
        }
        
        if let equivalence = product["equivalenceByPiece"] as? NSString {
            if equivalence != "" {
                self.equivalenceByPiece =  NSNumber(value: equivalence.intValue as Int32)
            }
        }
        
        if  weighable != "" {
            
            let quantity =  product["quantityDesired"] as! String
            let price = product["specialPrice"]  as! String
            var text: String? = ""
            var total: Double = 0.0
            
            //Piezas
            if weighable  == "N" {
                if Int(quantity) == 1 {
                    text = String(format: NSLocalizedString("list.detail.quantity.piece", comment:""), quantity)
                }
                else {
                    text = String(format: NSLocalizedString("list.detail.quantity.pieces", comment:""), quantity)
                }
                total = (Double(quantity)! * Double(price)!)
            }
                //Gramos
            else {
                let q = Double(quantity)
                if q < 1000.0 {
                    text = String(format: NSLocalizedString("list.detail.quantity.gr", comment:""), quantity)
                }
                else {
                    let kg = q!/1000.0
                    text = String(format: NSLocalizedString("list.detail.quantity.kg", comment:""), NSNumber(value: kg as Double))
                }
                let kgrams = Double(quantity)! / 1000.0
                total = (kgrams * Double(price)!)
            }
            self.quantityIndicator!.setTitle(text!, for: UIControlState())
            
            
            let formatedPrice = CurrencyCustomLabel.formatString("\(total)" as NSString)
            self.total = formatedPrice
            self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
            
        }
        else {
            self.quantityIndicator!.setTitle("", for: UIControlState())
        }
        
        
        if let stock = product["stock"] as? NSString {
            if stock.integerValue == 0 {
                self.quantityIndicator!.isEnabled = false
                self.quantityIndicator!.backgroundColor = WMColor.light_gray
                self.hasStock = false
            } else {
                self.quantityIndicator!.isEnabled = true
                self.quantityIndicator!.backgroundColor = WMColor.yellow
                self.hasStock = true
            }
        }
        
        if let stock = product["stock"] as? Bool {
            if stock {
                self.quantityIndicator!.isEnabled = true
                self.quantityIndicator!.backgroundColor = WMColor.yellow
                self.hasStock = true
            } else {
                self.quantityIndicator!.isEnabled = false
                self.quantityIndicator!.backgroundColor = WMColor.light_gray
                self.hasStock = false
            }
        }
        var isPreorderable = false
        if  let preordeable  = product["isPreorderable"] as? Bool {
            isPreorderable = preordeable
        }
        
        imagePresale.isHidden = !isPreorderable
        
         checkDisabled(disabled)
    }
    
    /**
     Values from listedailviewcontroller, validate type product and if is checket
     
     - parameter product:  entity product
     - parameter disabled: validate if row is active
     */
    func setValues(_ product:Product,disabled:Bool) {
        let imageUrl = product.img
        let description = product.desc
        
        self.productImage!.contentMode = UIViewContentMode.center
        self.productImage!.setImageWith(URLRequest(url:URL(string: imageUrl)!),
            placeholderImage: UIImage(named:"img_default_table"),
            success: { (request:URLRequest!, response:HTTPURLResponse!, image:UIImage!) -> Void in
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
        if product.type == 0 { //mustang
            if quantity.intValue == 1 {
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
                text = String(format: NSLocalizedString("list.detail.quantity.kg", comment:""), NSNumber(value: kg as Double))
            }
            let kgrams = quantity.doubleValue / 1000.0
            total = (kgrams * price)
            
        }
        self.quantityIndicator!.setTitle(text!, for: UIControlState())
        let formatedPrice = CurrencyCustomLabel.formatString("\(total)" as NSString)
        self.total = formatedPrice
        self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        
        checkDisabled(disabled)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.frame.size
        let sep: CGFloat = 16.0

        self.productImage!.frame = CGRect(x: self.check!.frame.maxX, y: 0.0, width: 80.0, height: bounds.height)
        let x:CGFloat = self.productImage!.frame.maxX + sep
        self.productShortDescriptionLabel!.frame = CGRect(x: x, y: sep, width: bounds.width - (x + sep), height: 28.0)
        if self.quantityIndicator!.isEnabled {
            var size = self.sizeForButton(self.quantityIndicator!)
            size.width = (size.width + (sep*2))
            self.quantityIndicator!.frame = CGRect(x: bounds.width - (sep + size.width), y: productShortDescriptionLabel!.frame.maxY + 8, width: size.width, height: 32.0)
        }else {
            self.quantityIndicator!.frame = CGRect(x: bounds.width - (sep + 102), y: productShortDescriptionLabel!.frame.maxY + 8, width: 102, height: 32.0)
        }
        
        if self.promoDescription!.text == nil || self.promoDescription!.text!.isEmpty {
            self.productPriceLabel!.frame = CGRect(x: x, y: self.quantityIndicator!.frame.minY, width: 100.0, height: 30.0)
            self.productPriceLabel!.center = CGPoint(x: self.productPriceLabel!.center.x, y: self.quantityIndicator!.center.y)
            self.promoDescription!.frame = CGRect.zero
            self.promotiosView?.frame =  CGRect(x: self.productPriceLabel!.frame.minX,y: self.quantityIndicator!.frame.maxY + 1, width: bounds.width - (x + sep), height: 23)
        }
        else {
            self.productPriceLabel!.frame = CGRect(x: x, y: self.quantityIndicator!.frame.minY, width: 100.0, height: 20.0)
            self.promoDescription!.frame = CGRect(x: x, y: self.productPriceLabel!.frame.maxY, width: 90.0, height: 12.0)
            self.promotiosView?.frame =  CGRect(x: self.promoDescription!.frame.minX,y: self.quantityIndicator!.frame.maxY + 1, width: bounds.width - (x + sep), height: 23)
        }

        self.separator!.frame = CGRect(x: x, y: 113,width: self.frame.width - 16, height: 1.0)
    }
    
    /**
     calculate size button from text resent
     
     - parameter button: buttom change
     - returns: new size button
     */
    func sizeForButton(_ button:UIButton) -> CGSize {
        let text = button.title(for: UIControlState())
        let font = button.titleLabel!.font
        let computedRect: CGRect = text!.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName:font],
            context: nil)
        return CGSize(width: ceil(computedRect.size.width), height: ceil(computedRect.size.height))
    }

    //MARK: - Actions
    /**
     Open keboard to change quantity in product
     */
    func changeQuantity() {
        self.detailDelegate?.didChangeQuantity(self)
        if defaultList {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: "GR_\(WMGAIUtils.ACTION_OPEN_KEYBOARD.rawValue)", label: "\(self.productShortDescriptionLabel!.text!) - \(upcVal)")
        } else {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action: "GR_\(WMGAIUtils.ACTION_OPEN_KEYBOARD.rawValue)", label: "\(self.productShortDescriptionLabel!.text!) - \(upcVal)")
        }
        
    }
    /**
     Action check button and send analitycs if list or default list
     
     - parameter sender: action button
     */
    func checked(_ sender:UIButton) {
        if defaultList {
        if sender.isSelected {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DISABLE_PRODUCT.rawValue, label: "\(self.productShortDescriptionLabel!.text!) - \(upcVal)")
        } else {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ENABLE_PRODUCT.rawValue, label: "\(self.productShortDescriptionLabel!.text!) - \(upcVal)")
        }
        } else {
            if sender.isSelected {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action: WMGAIUtils.ACTION_DISABLE_PRODUCT.rawValue, label: "\(self.productShortDescriptionLabel!.text!) - \(upcVal)")
            } else {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action: WMGAIUtils.ACTION_ENABLE_PRODUCT.rawValue, label: "\(self.productShortDescriptionLabel!.text!) - \(upcVal)")
            }
        }
        
        sender.isSelected = !sender.isSelected
        checkDisabled(!sender.isSelected)
        detailDelegate?.didDisable(!sender.isSelected,cell:self)
        
        
    }
    
    /**
     Convert image from cell to grayScale
     
     - parameter image: image to change
     - returns: image in grayScale
     */
    func convertImageToGrayScale(_ image:UIImage) -> UIImage {
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil, width: Int(image.size.width),  height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGBitmapInfo().rawValue)
        context?.draw(image.cgImage!, in: imageRect)
        let imageRef = context?.makeImage()
        let newImage = UIImage(cgImage: imageRef!)
        return newImage
        
    }
    
    /**
     Change colors to row properties if check button
     
     - parameter disabled: enable or disable value
     */
    func checkDisabled(_ disabled:Bool) {
        self.check!.isSelected = !disabled
        if disabled {
            self.productShortDescriptionLabel?.textColor = WMColor.empty_gray_btn
            self.productPriceLabel!.updateMount(self.total!, font: WMFont.fontMyriadProSemiboldSize(18), color:WMColor.empty_gray_btn, interLine: false)
            self.productImage!.image = imageGrayScale
            self.quantityIndicator?.backgroundColor = WMColor.light_gray
            self.promoDescription?.textColor = WMColor.empty_gray_btn
        } else {
            self.productShortDescriptionLabel!.textColor = WMColor.reg_gray
            self.productPriceLabel!.updateMount(self.total!, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
            self.productImage!.image = imageNormal
            self.quantityIndicator!.backgroundColor = self.hasStock ? WMColor.yellow : WMColor.light_gray
            self.promoDescription?.textColor = WMColor.green
        }
    }
    
    override func showLeftUtilityButtons(animated: Bool) {
        super.showLeftUtilityButtons(animated: animated)
        self.check?.alpha = 0.0
    }
    
    override func hideUtilityButtons(animated: Bool) {
        super.hideUtilityButtons(animated: animated)
        self.check?.alpha = 1.0
    }

}
