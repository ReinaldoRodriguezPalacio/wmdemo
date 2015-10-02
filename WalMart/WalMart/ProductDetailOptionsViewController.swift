//
//  ProductDetailOptionsViewController.swift
//  WalMart
//
//  Created by Alonso Salcido on 14/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailOptionsViewController: ImageDisplayCollectionViewController, ProductDetailColorSizeDelegate{
    
    var colorItems: [AnyObject]? = nil
    var sizeItems: [AnyObject]? = nil
    var otherItems: [AnyObject]? = nil
    var colorsView: ProductDetailColorSizeView? = nil
    var sizesView: ProductDetailColorSizeView? = nil
    var otherOptionsView: ProductDetailColorSizeView? = nil
    var selectQuantity : ShoppingCartQuantitySelectorView? = nil
    var priceBefore : CurrencyCustomLabel!
    var price : CurrencyCustomLabel!
    var saving : CurrencyCustomLabel!
    var detailProductCart: Cart?
    var optionsLabel : UILabel!
    var buttonShop : UIButton!
    var upc : String = ""
    var onHandInventory : NSString = "0"
    var savingStr : NSString = ""
    var priceStr : NSString = ""
    var listPriceStr : NSString = ""
    var strIsPreorderable : String! = "false"
    var facets: [String:AnyObject]? = nil
    var facetsDetails: [String:AnyObject]? = nil
    var detailsOrder: [AnyObject]? = nil
    var selectedDetailItem: [String:String]? = nil
    var itemsSelected: [String:String]? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.colorsView = ProductDetailColorSizeView()
        self.colorsView?.delegate = self
        self.view.addSubview(self.colorsView!)
        
        self.sizesView = ProductDetailColorSizeView()
         self.sizesView?.delegate = self
        self.view.addSubview(self.sizesView!)
        
        self.otherOptionsView = ProductDetailColorSizeView()
         self.otherOptionsView?.delegate = self
        self.view.addSubview(self.otherOptionsView!)
        
        optionsLabel = UILabel(frame: CGRectMake(0, self.pointSection!.frame.maxY  , self.view.frame.width, 15.0))
        optionsLabel.textColor = WMColor.navigationTilteTextColor
        optionsLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        optionsLabel.textAlignment = NSTextAlignment.Center
        optionsLabel.text =  NSLocalizedString("productdetail.options",comment:"")
        self.view.addSubview(optionsLabel)
        priceBefore = CurrencyCustomLabel(frame: CGRectMake(0, self.optionsLabel.frame.maxY  , self.view.frame.width, 15.0))
        self.view.addSubview(priceBefore)
        price = CurrencyCustomLabel(frame: CGRectMake(0, self.priceBefore.frame.maxY  , self.view.frame.width, 24.0))
        self.view.addSubview(price)
        saving = CurrencyCustomLabel(frame: CGRectMake(0, self.price.frame.maxY  , self.view.frame.width, 15.0))
        self.view.addSubview(saving)
        
        buttonShop = UIButton(frame: CGRectMake(0, self.price.frame.maxY , 60, 34))
        buttonShop.setTitle(NSLocalizedString("productdetail.shop",comment:""), forState: UIControlState.Normal)
        buttonShop.setTitle(NSLocalizedString("productdetail.shop",comment:""), forState: UIControlState.Disabled)
        buttonShop.backgroundColor = WMColor.disabled_light_gray
        buttonShop.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonShop.layer.cornerRadius = 17
        buttonShop.enabled = false
        buttonShop.addTarget(self, action: "addProductToShoppingCart", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonShop)
        
        self.getItemsFromFacetsDetails()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.selectedDetailItem != nil {
            let selectedItem = self.selectedDetailItem!["selected"]
            let selectedType = self.selectedDetailItem!["itemType"]
            self.selectDetailButton(selectedItem!, itemType: selectedType!)
        }
    }
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.frame.size
        let frame = self.view.frame
        var itemsHeight = CGFloat(141)
        self.header!.frame = CGRectMake(0, 0, self.view.bounds.maxX, 66)
        self.close!.frame = CGRectMake(0.0, 20, 40.0, 40.0)
        self.titleLabel!.frame =  CGRectMake(40.0 , 20, bounds.width - 40 , 46)
        
        if otherItems?.count > 0{
            self.otherOptionsView!.items = self.otherItems
            self.otherOptionsView!.buildforColors = false
            itemsHeight += 40
            self.otherOptionsView!.frame =  CGRectMake(0,  bounds.height - itemsHeight   , frame.width, 40.0)
            self.addBottomBorder(self.otherOptionsView!.viewToInsert!)
        }
        
        if sizeItems?.count > 0{
            self.sizesView!.items = self.sizeItems
            self.sizesView!.buildforColors = false
            itemsHeight += 40
            self.sizesView!.frame =  CGRectMake(0,  bounds.height - itemsHeight   , frame.width, 40.0)
            self.addBottomBorder(self.sizesView!.viewToInsert!)
        }
        
        if colorItems?.count > 0{
            self.colorsView!.items = self.colorItems
            self.colorsView!.buildforColors = true
            self.colorsView!.alpha = 1.0
            itemsHeight += 40
            self.colorsView!.frame =  CGRectMake(0,  bounds.height - itemsHeight   , frame.width, 40.0)
            self.addBottomBorder(self.colorsView!.viewToInsert!)
        }else{
            self.colorsView!.alpha = 0
        }
        
        itemsHeight += 20
        self.optionsLabel.frame = CGRectMake((frame.width / 2) - 100, bounds.height - itemsHeight   , 200, 30)
        itemsHeight += 30
        self.pointSection!.frame = CGRectMake(0, bounds.height - itemsHeight   , bounds.width, 20)
        itemsHeight += 50
        self.collectionView!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, bounds.height - itemsHeight)
        
        self.priceBefore.frame = CGRectMake(0,  bounds.height - 129   , frame.width, 15.0)
        self.price.frame = CGRectMake(0, bounds.height - 114 , frame.width, 24.0)
        self.saving.frame = CGRectMake(0, bounds.height - 90  , frame.width, 15.0)
        self.buttonShop.frame = CGRectMake((frame.width / 2) - 51 , bounds.height - 47  , 102, 32.0)
        
        let line: CALayer = CALayer()
        line.frame = CGRectMake(0.0, bounds.height - 65, frame.size.width, 0.8);
        line.backgroundColor = WMColor.UIColorFromRGB(0xF6F6F6, alpha: 0.7).CGColor
        self.view.layer.insertSublayer(line, atIndex: 0)
        self.updateShopButton()
    }
    
    func setAdditionalValues(listPrice:String,price:String,saving:String){
        if price == "" || (price as NSString).doubleValue == 0 {
            self.price.hidden = true
        } else {
            self.price.hidden = false
            let formatedValue = "\(CurrencyCustomLabel.formatString(price))"
            self.price.updateMount(formatedValue, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.priceDetailProductTextColor, interLine: false)
            self.priceStr = price
        }
        
        if listPrice == "" || (listPrice as NSString).doubleValue == 0 || (price as NSString).doubleValue >= (listPrice as NSString).doubleValue  {
            priceBefore.hidden = true
        } else {
            priceBefore.hidden = false
            let formatedValue = "\(CurrencyCustomLabel.formatString(listPrice))"
            self.priceBefore.updateMount(formatedValue, font: WMFont.fontMyriadProLightOfSize(14), color: WMColor.productDetailPriceListText, interLine: true)
            self.listPriceStr = listPrice
        }
        
        if saving == "" {
            self.saving.hidden = true
        } else {
            self.saving.hidden = false
            let formatedValue = "\(CurrencyCustomLabel.formatString(saving))"
            self.saving.updateMount(formatedValue, font: WMFont.fontMyriadProSemiboldOfSize(14), color: WMColor.savingTextColor, interLine: false)
            self.savingStr = saving
        }
        
    }
    
    func updateShopButton(){
        var buttonText = NSLocalizedString("productdetail.shop",comment:"")
        if detailProductCart != nil{
            if detailProductCart!.quantity.integerValue == 1 {
                buttonText = String(format: NSLocalizedString("list.detail.quantity.piece", comment:""), detailProductCart!.quantity)
            }
            else {
                buttonText = String(format: NSLocalizedString("list.detail.quantity.pieces", comment:""), detailProductCart!.quantity)
            }
        }
        self.buttonShop.setTitle(buttonText, forState: UIControlState.Normal)
    }
    
    func addBottomBorder(view:UIView){
        let bottomBorder: CALayer = CALayer()
        bottomBorder.frame = CGRectMake(0.0, view.frame.height - 1.1, view.frame.size.width, 1.1);
        
        bottomBorder.backgroundColor = WMColor.UIColorFromRGB(0xF6F6F6, alpha: 1.0).CGColor
        view.layer.insertSublayer(bottomBorder, atIndex: 0)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    func addProductToShoppingCart(){
        let finalFrameOfQuantity = self.view.frame
        selectQuantity = ShoppingCartQuantitySelectorView(frame:self.view.frame,priceProduct:NSNumber(double:self.priceStr.doubleValue),upcProduct:upc)
        selectQuantity!.priceProduct = NSNumber(double:self.priceStr.doubleValue)
        selectQuantity!.frame = self.view.frame
        selectQuantity!.closeAction =
                { () in
                    self.selectQuantity?.removeFromSuperview()
                }
            selectQuantity!.generateBlurImage(self.view,frame:finalFrameOfQuantity)
            selectQuantity!.addToCartAction =
                { (quantity:String) in
                    //let quantity : Int = quantity.toInt()!
                    if self.onHandInventory.integerValue >= Int(quantity) {
                        let params = self.buildParamsUpdateShoppingCart(quantity)
                        
                        //Event
                        if let tracker = GAI.sharedInstance().defaultTracker {
                            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue, action: WMGAIUtils.MG_EVENT_PRODUCTDETAIL_ADDTOSHOPPINGCART.rawValue , label: "\(self.upc) - \(self.name)", value: nil).build() as [NSObject : AnyObject])
                        }
                        
                        
                        UIView.animateWithDuration(0.2,
                            animations: { () -> Void in
                                self.selectQuantity!.frame = CGRectMake(0, 360, 320, 0	)
                                self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
                            },
                            completion: { (animated:Bool) -> Void in
                                self.selectQuantity!.removeFromSuperview()
                                self.selectQuantity = nil
                                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                    }
                    else {
                        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                        
                        let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                        let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                        let msgInventory = "\(firstMessage)\(self.onHandInventory) \(secondMessage)"
                        alert!.setMessage(msgInventory)
                        alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                    }
            }
             self.selectQuantity!.imageBlurView.frame = finalFrameOfQuantity
             self.selectQuantity!.clipsToBounds = true
             self.view.addSubview(self.selectQuantity!)
    }
    
    func getItemsFromFacetsDetails()
    {
        if self.facetsDetails != nil{
            var count = 0
            if self.detailsOrder == nil {self.detailsOrder = []}
            for detail in self.facetsDetails! {
                if detail.0 != "itemDetails" && detail.0 == "Color" {
                    self.detailsOrder!.append(["itemsView":self.colorsView!,"position":1, "itemType": detail.0])
                }
                if detail.0 != "Color" && detail.0 != "itemDetails" && count == 2{
                    self.sizeItems = detail.1 as? [AnyObject]
                    self.detailsOrder!.append(["itemsView":self.sizesView!,"position":2,"itemType": detail.0])
                }
                if detail.0 != "Color" && detail.0 != "itemDetails" && count == 3{
                    self.otherItems = detail.1 as? [AnyObject]
                     self.detailsOrder!.append(["itemsView":self.otherOptionsView!,"position":3,"itemType": detail.0])
                }
                count++
            }
        }
    }
    
    func getDetailsWithKey(key: String, value: String, keyToFind: String) -> [String]{
        let itemDetails = self.facetsDetails!["itemDetails"] as? [AnyObject]
        var findObj: [String] = []
        for item in itemDetails!{
            if(item[key] as! String == value)
            {
                findObj.append(item[keyToFind] as! String)
            }
        }
        
        return findObj
    }
    
    func getNextDetailItem(itemType: String) -> AnyObject?{
        var position = self.detailsOrder!.count + 1
        var nextItem: AnyObject? = nil
        for item in self.detailsOrder! {
            if item["itemType"] as! String == itemType{
                position = item["position"] as! Int + 1
            }
            if item["position"] as! Int == position{
                nextItem = item
                break;
            }
        }
        return nextItem
    }
    
    //MARK: ProductDetailColorSizeDelegate
    func selectDetailItem(selected:String, itemType: String){
        if self.itemsSelected == nil{
            self.itemsSelected = [:]
        }
        if itemType == "Color"{
           self.itemsSelected = [:]
        }
        self.itemsSelected![itemType] = selected
        if self.itemsSelected!.count == self.detailsOrder!.count
        {
            let upc = self.getUpc(self.itemsSelected!)
            self.reloadViewWithUPC(upc)
            self.updateButtonShop(true)
        }
        if let nextItem = self.getNextDetailItem(itemType) as? [String: AnyObject]{
            let detailView = nextItem["itemsView"] as? ProductDetailColorSizeView
            let details = self.getDetailsWithKey(itemType,value:selected,keyToFind: nextItem["itemType"] as! String)
            detailView?.enableButtonWhithTitles(details)
        }
    }
    
    func getUpc(itemsSelected: [String:String]) -> String
    {
        var upc = ""
        var isSelected = false
        let details = self.facetsDetails!["itemDetails"] as? [AnyObject]
        for item in details! {
            for selectItem in self.itemsSelected!{
                if item[selectItem.0] as! String == selectItem.1{
                    isSelected = true
                }
                else{
                    isSelected = false
                }
            }
            if isSelected{
                upc = item["upc"] as! String
            }
        }
        return upc
    }
    
    func updateButtonShop(enabled: Bool){
        self.buttonShop.enabled = enabled
        if self.buttonShop.enabled{
            self.buttonShop.backgroundColor = WMColor.yellow
        }else {
            self.buttonShop.backgroundColor = WMColor.disabled_light_gray
        }
    }
    
    func reloadViewWithUPC(upc:String){
        var facet = self.facets![upc] as! [String: AnyObject]
        self.onHandInventory = facet["onHandInventory"] as! String
        self.strIsPreorderable = facet["isPreorderable"] as! String
        self.upc = facet["upc"] as! String
        self.name! = facet["description"] as! String
        self.imagesToDisplay = facet["imageUrl"] as? [AnyObject]
        self.collectionView?.reloadData()
        self.selectFirstPoint()
        self.buildButtonSection()
        self.setAdditionalValues(facet["original_listprice"] as! String, price: facet["price"] as! String, saving: facet["saving"] as! String)
    }
    
    func selectDetailButton(selected:String, itemType: String){
        self.colorsView!.selectButton(selected)
    }
    //MARK: Shopping cart
    func buildParamsUpdateShoppingCart(quantity:String) -> [NSObject:AnyObject] {
        var imageUrlSend = ""
        if self.imagesToDisplay!.count > 0 {
            imageUrlSend = self.imagesToDisplay![0] as! String
        }
        return ["upc":self.upc,"desc":self.name!,"imgUrl":imageUrlSend,"price":self.priceStr,"quantity":quantity,"onHandInventory":self.onHandInventory as String,"wishlist":false,"type":"mg","pesable":"0","isPreorderable":self.strIsPreorderable]
    }
}