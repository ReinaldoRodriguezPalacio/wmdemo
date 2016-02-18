//
//  IPAWishlistViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
class IPAWishlistViewController : UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,IPAWishListProductCollectionViewCellDelegate,UIActivityItemSource {
    
    var items : [AnyObject]! = []
    
     var currentCellSelected : NSIndexPath!
    
    var titleLabel : UILabel!
    
    @IBOutlet var wishlist: UICollectionView!
    
    @IBOutlet var shareWishlist: UIButton!
    @IBOutlet var header: UIView!

    @IBOutlet var articlesWishlist: UILabel!
    @IBOutlet var titleWishlist: UILabel!
    @IBOutlet var editWishlist : UIButton!
    @IBOutlet var deleteAllWishlist : UIButton!
    @IBOutlet var buyWishlist: UIButton!
    var customlabel : CurrencyCustomLabel!
    var loading: WMLoadingView? = nil
    var popup : UIPopoverController?
    
    var emptyView : IPAEmptyWishlistView!
    
    var isEditingWishList = false
    var closewl : (() -> Void)!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.wishlist.registerClass(IPAWishListProductCollectionViewCell.self, forCellWithReuseIdentifier: "productwishlist")
        
        self.wishlist.dataSource = self
        self.wishlist.delegate = self
        
        self.editWishlist.addTarget(self, action: "editWishlist:", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.editWishlist)
        
        titleWishlist.font = WMFont.fontMyriadProRegularOfSize(24)
        titleWishlist.textColor = UIColor.whiteColor()
        
        articlesWishlist.font = WMFont.fontMyriadProRegularOfSize(14)
        articlesWishlist.textColor = UIColor.whiteColor()
        
        buyWishlist.backgroundColor = WMColor.shoppingCartShopBgColor
        buyWishlist.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buyWishlist.layer.cornerRadius = self.buyWishlist.frame.height / 2
        buyWishlist.addTarget(self, action: "senditemsToShoppingCart", forControlEvents: UIControlEvents.TouchUpInside)
        
       
        
        header.backgroundColor = WMColor.wishlistHeaderBgColor
        
        titleLabel = UILabel(frame: CGRectMake((header.frame.width/2) - 75, 0, 150, header.frame.height))
        titleLabel.text = NSLocalizedString("wishlist.title",comment:"")
        titleLabel.textAlignment = .Center
        
        titleLabel.numberOfLines = 2
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.textColor = WMColor.navigationTilteTextColor
        self.view.addSubview(titleLabel)
        
        let borderBottom = UIView(frame: CGRectMake(0, self.wishlist.frame.maxY ,self.view.frame.width, AppDelegate.separatorHeigth() ))
        borderBottom.backgroundColor = WMColor.lineSaparatorColor
        self.view.addSubview(borderBottom)
        

        editWishlist.setTitle(NSLocalizedString("wishlist.edit",comment:""), forState: UIControlState.Normal)
        editWishlist.setTitle(NSLocalizedString("wishlist.endedit",comment:""), forState: UIControlState.Selected)
        editWishlist.backgroundColor = WMColor.wishlistEditButtonBgColor
        editWishlist.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        editWishlist.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        editWishlist.layer.cornerRadius = 11
        editWishlist.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
        
        
        deleteAllWishlist.setTitle(NSLocalizedString("wishlist.deleteall",comment:""), forState: UIControlState.Normal)
        deleteAllWishlist.backgroundColor = WMColor.wishlistDeleteButtonBgColor
        deleteAllWishlist.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        deleteAllWishlist.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        deleteAllWishlist.layer.cornerRadius = 11
        deleteAllWishlist.alpha = 0
        deleteAllWishlist.titleEdgeInsets = UIEdgeInsetsMake(2.0, 2.0, 0.0, 0.0)
        
        let closeWL = UIButton(frame: CGRectMake(0, 0, self.header.frame.height, self.header.frame.height))
        closeWL.setImage(UIImage(named: "detail_close"), forState: UIControlState.Normal)
        closeWL.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(closeWL)
        
        if emptyView  != nil{
            emptyView.removeFromSuperview()
        }
        emptyView = IPAEmptyWishlistView(frame: CGRectZero)
        self.view.addSubview(emptyView)
        
        WishlistService.shouldupdate = true
        reloadWishlist()
        
        
        
        

    }
    
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        wishlist.frame = CGRectMake(0, 46, self.view.frame.width, 224)
        header.frame = CGRectMake(0, 0, self.view.frame.width, 46)
        titleLabel.frame = CGRectMake((self.view.frame.width / 2) - 75, 0, 150, header.frame.height)
        editWishlist.frame = CGRectMake(954, 12, 55, 22)
        deleteAllWishlist.frame = CGRectMake(866, 12, 75, 22)
        buyWishlist.frame = CGRectMake((self.view.frame.width / 2) - (buyWishlist.frame.width / 2), buyWishlist.frame.minY, buyWishlist.frame.width, buyWishlist.frame.height)
        titleLabel.frame = CGRectMake((header.frame.width/2) - 75, 0, 150, header.frame.height)
        self.emptyView!.frame = CGRectMake(0, 46, wishlist.frame.width, wishlist.frame.height + 64)
        self.view.frame = CGRectMake(0, 0, self.view.frame.width, 334)
        
    }
    
    
    
    func registerNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadWishlist", name: CustomBarNotification.ReloadWishList.rawValue, object: nil)

        
    }
    func removeNotification(){
         NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadWishlist()
        self.view.frame = CGRectMake(self.view.frame.minX, self.view.frame.minY, self.view.frame.width, 334)


    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    
    func editWishlist(sender:AnyObject) {
        isEditingWishList = !isEditingWishList
        
        if isEditingWishList {
            editWishlist.selected = true
            editWishlist.backgroundColor = WMColor.UIColorFromRGB(0x8EBB36)//WMColor.wishlistEndEditButtonBgColor
            editWishlist.tintColor = WMColor.wishlistEndEditButtonBgColor
            if self.items.count > 0 {
                self.wishlist.reloadData()
            }
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.deleteAllWishlist.alpha = 1
            })
        }else {
            editWishlist.selected = false
            editWishlist.backgroundColor = WMColor.wishlistEditButtonBgColor
            editWishlist.tintColor = WMColor.wishlistEditButtonBgColor
            if self.items.count > 0 {
                self.wishlist.reloadData()
            }
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.deleteAllWishlist.alpha = 0
            })
        }
        
    }
    
    
    func updateShopButton(total:String) {
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: self.buyWishlist.bounds)
            customlabel.backgroundColor = UIColor.clearColor()
            customlabel.setCurrencyUserInteractionEnabled(true)
            buyWishlist.addSubview(customlabel)
            buyWishlist.sendSubviewToBack(customlabel)
        }
        let shopStr = NSLocalizedString("wishlist.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(total)
        let shopStrComplete = "\(shopStr) \(fmtTotal)"
        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.whiteColor(), interLine: false)
        
    }
    
    func reloadWishlist() {
        
        if WishlistService.shouldupdate == true {
        WishlistService.shouldupdate = false
        self.loading = WMLoadingView(frame: CGRectMake(0, 0, 1024, 334))
        self.view.addSubview(self.loading!)
        self.loading!.startAnnimating(false)
        
        let serviceWish = UserWishlistService()
        
        serviceWish.callService({ (wishlist:NSDictionary) -> Void in
            self.items = wishlist["items"] as! [AnyObject]
            
            var total : Double = 0
            for itemWishList in self.items {
                if let priceStrUse = itemWishList["price"] as? String {
                    let price = priceStrUse as NSString
                    total = total + price.doubleValue
                }
            }
            
            let totalStr = String(format: "%.2f",total)
            self.emptyView.hidden = self.items.count > 0
            self.editWishlist.hidden = self.items.count == 0
            self.buyWishlist.hidden = self.items.count == 0
            self.articlesWishlist.hidden = self.items.count == 0
            self.shareWishlist.hidden = self.items.count == 0
            
            let articlesStr = NSLocalizedString("wishlist.articles",comment:"")
            self.articlesWishlist.text = "\(self.items.count) \(articlesStr)"
            
            self.updateShopButton(totalStr)
            
            self.wishlist.reloadData()
            
            self.loading!.stopAnnimating()
            
            }, errorBlock: { (error:NSError) -> Void in
        })
        }
    }
    
    func updateShopButton() {
        var total : Double = 0
        for itemWishList in self.items {
            let price = itemWishList["price"] as! NSString
            total = total + price.doubleValue
        }
        let totalStr = String(format: "%.2f",total)
        self.updateShopButton(totalStr)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.items.count
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let productCell = collectionView.dequeueReusableCellWithReuseIdentifier("productwishlist", forIndexPath: indexPath) as! IPAWishListProductCollectionViewCell
        loadViewCellCollection(productCell,indexPath:indexPath)
        return productCell
        
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return CGSizeMake(256, self.wishlist.frame.height);
    }
    
   
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        let paginatedProductDetail = IPAProductDetailPageViewController()
        paginatedProductDetail.ixSelected = indexPath.row
        paginatedProductDetail.itemsToShow = []
        for productRecomm  in items {
            let upc = productRecomm["upc"] as! NSString
            let desc = productRecomm["description"] as! NSString
            paginatedProductDetail.itemsToShow.append(["upc":upc,"description":desc,"type": ResultObjectType.Mg.rawValue])
        }
        
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! ProductCollectionViewCell!
        currentCellSelected = indexPath
        let pontInView = currentCell.convertRect(currentCell!.productImage!.frame, toView:  self.view)
        paginatedProductDetail.animationController = ProductDetailNavigatinAnimationController(nav:self.navigationController!)
        paginatedProductDetail.animationController.originPoint =  pontInView
        paginatedProductDetail.animationController.setImage(currentCell!.productImage!.image!)
        currentCell.hideImageView()
        
        self.navigationController?.delegate = paginatedProductDetail
        self.navigationController?.pushViewController(paginatedProductDetail, animated: true)
        
    }
    
    func deleteProductWishList(cell:IPAWishListProductCollectionViewCell) {
        
        let indexPath = self.wishlist.indexPathForCell(cell)
        let itemWishlist = items[indexPath!.row] as! [String:AnyObject]
        let upc = itemWishlist["upc"] as! NSString
        let deleteWishListService = DeleteItemWishlistService()
        deleteWishListService.callCoreDataService(upc as String, successBlock: { (result:NSDictionary) -> Void in
            self.items.removeAtIndex(indexPath!.row)
            self.wishlist.deleteItemsAtIndexPaths([indexPath!])
            //self.wishlist.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            //self.wishlist.reloadData()
            self.emptyView.hidden = self.items.count > 0
            self.deleteAllWishlist.hidden = self.items.count == 0 && self.isEditingWishList
            self.updateShopButton()
            self.editWishlist.hidden = self.items.count == 0
            self.editWishlist(self.editWishlist)
            self.deleteAllWishlist.hidden = self.items.count == 0
            if self.items.count == 0 {
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
            }
            }, errorBlock: { (error:NSError) -> Void in
                print("delete pressed Errro \(error)")
        })
    }
    

    func senditemsToShoppingCart() {
        var params : [AnyObject] =  []
        var paramsPreorderable : [AnyObject] =  []

        for itemWishList in self.items {
            
            let upc = itemWishList["upc"] as! String
            let desc = itemWishList["description"] as! String
            let price = itemWishList["price"] as! NSString
            let imageArray = itemWishList["imageUrl"] as! NSArray
            
            let active  = itemWishList["isActive"] as! String
            var isActive = "true" == active
            
            if isActive == true {
                isActive = price.doubleValue > 0
            }
            
            
            var isPreorderable = "true"
            if  let preordeable  = itemWishList["isPreorderable"] as? String {
                isPreorderable = preordeable
            }
            
            //let onHandInventory = itemWishList["onHandInventory"] as NSString
            
            var numOnHandInventory : NSString = "0"
            if let numberOf = itemWishList["onHandInventory"] as? String{
                numOnHandInventory  = numberOf
            }
            
            var imageUrl = ""
            if imageArray.count > 0 {
                imageUrl = imageArray.objectAtIndex(0) as! String
            }
            
            
            
            if isActive == true && numOnHandInventory.integerValue > 0  { //&& isPreorderable == false
                let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc as String)
                if !hasUPC {
                    let paramsItem = CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageUrl, price: price as String , quantity: "1",onHandInventory:numOnHandInventory as String,wishlist:true,type:ResultObjectType.Mg.rawValue,pesable:"0",isPreorderable:isPreorderable)
                    //params.append(paramsItem)
                    if isPreorderable == "true" {
                        paramsPreorderable.append(paramsItem)
                    }else{
                        params.append(paramsItem)
                    }

                }
                
            }
        }//for
        //condiciones
        
        if paramsPreorderable.count == 0 && params.count == 0{
            if self.items.count > 0 {
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"cart_loading"),imageDone:nil,imageError:UIImage(named:"cart_loading"))
                let aleradyMessage = NSLocalizedString("shoppingcart.alreadyincart",comment:"")
                alert!.setMessage(aleradyMessage)
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            }
            return

        }
        
        let totArticlesMG = UserCurrentSession.sharedInstance().numberOfArticlesMG()
        
        if paramsPreorderable.count == 0 &&  totArticlesMG == 0{
            self.sendNewItemsToShoppingCart(params)
        }else{
            
            if paramsPreorderable.count > 1 && params.count == 0  &&  totArticlesMG == 0{
                
                let alert = IPAWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                alert!.spinImage.hidden =  true
                let messagePreorderable = NSLocalizedString("alert.presaletobuyback",comment:"")
                alert!.setMessage(messagePreorderable)
                alert!.addActionButtonsWithCustomText("Cancelar", leftAction: { () -> Void in
                    alert!.close()
                    
                    }, rightText: "Ok", rightAction: { () -> Void in
                        self.sendNewItemsToShoppingCart([paramsPreorderable[0]])
                        alert!.close()
                    }, isNewFrame: false)
                
            } else if paramsPreorderable.count > 0 && params.count > 0 &&  totArticlesMG == 0{
                
                let alert = IPAWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                alert!.spinImage.hidden =  true
                let messagePreorderable = NSLocalizedString("alert.presalewishlist",comment:"")
                alert!.setMessage(messagePreorderable)
                alert!.addActionButtonsWithCustomText("Cancelar", leftAction: { () -> Void in
                    alert!.close()
                    }, rightText: "Ok", rightAction: { () -> Void in
                        self.sendNewItemsToShoppingCart(params)
                        alert!.close()
                    }, isNewFrame: false)
            }else {
                
                if totArticlesMG == 0 {
                    self.sendNewItemsToShoppingCart(paramsPreorderable)
                }else{
                    
                    let alert = IPAWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                    alert!.spinImage.hidden =  true
                    var messagePreorderable = NSLocalizedString("alert.presaleindependent",comment:"")
                    messagePreorderable =  NSLocalizedString("alert.presaleindependent",comment:"")
                    alert!.setMessage(messagePreorderable)
                    
                    alert!.addActionButtonsWithCustomText("Cancelar", leftAction: { () -> Void in
                        print("Cancelar accion")
                        
                        alert!.close()
                        
                        
                        }, rightText: "Vaciar carrito y comprar este artículo", rightAction: { () -> Void in
                            WishListViewController.deleteAllShoppingCart({ () -> Void in
                                //Agregar al carrito
                                if paramsPreorderable.count == 0 {
                                    self.sendNewItemsToShoppingCart(params)
                                }else{
                                    if paramsPreorderable.count > 1 {
                                        self.sendNewItemsToShoppingCart([paramsPreorderable[0]])
                                    }else{
                                        self.sendNewItemsToShoppingCart(paramsPreorderable)
                                    }
                                }
                            })
                            
                            alert!.close()
                            
                        },isNewFrame: true)//Close - addActionButtonsWithCustomText
                }
            }//close else
        }
 
        
    }
    
    func sendNewItemsToShoppingCart(params:[AnyObject]){
        if params.count > 0 {
            let paramsAll = ["allitems":params, "image":"wishlist_addToCart"    ]
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddItemsToShopingCart.rawValue, object: self, userInfo: paramsAll as [NSObject : AnyObject])
        }
       BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_ADD_ALL_WISHLIST.rawValue, label: "")
    }
    
    
    func reloadSelectedCell() {
        if currentCellSelected != nil {
            if let currentCell = wishlist.cellForItemAtIndexPath(currentCellSelected) as? IPAWishListProductCollectionViewCell {
                currentCell.showImageView()
            }
        }
    }
    
    
    
    @IBAction func shareWishList(sender: AnyObject) {
        
        let imgResult = imageToShareWishList()
        var strAllUPCs = ""
        for item in self.items {
            let strItemUpc = item["upc"]
            if strAllUPCs != "" {
                strAllUPCs = "\(strAllUPCs),\(strItemUpc)"
            } else {
                strAllUPCs = "\(strItemUpc)"
            }
        }
        let upcList = "\(strAllUPCs)"
        let urlWmart = UserCurrentSession.urlWithRootPath("http://www.walmart.com.mx/Busqueda.aspx?Text=\(upcList)")
        
        let controller = UIActivityViewController(activityItems: [self,urlWmart!,imgResult], applicationActivities: nil)
        popup = UIPopoverController(contentViewController: controller)
        
        popup!.presentPopoverFromRect(CGRectMake(self.shareWishlist.frame.origin.x + 13, self.shareWishlist.frame.maxY - 120, 10, 120), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        
    }
    
    
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject{
        return "Walmart"
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        if activityType == UIActivityTypeMail {
            return "Hola,\nMira estos productos que encontré en Walmart. ¡Te los recomiendo!"
        }
        return ""
    }
    
    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        if activityType == UIActivityTypeMail {
            if UserCurrentSession.sharedInstance().userSigned == nil {
                return "Hola te quiero enseñar mi lista de www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance().userSigned!.profile.name) \(UserCurrentSession.sharedInstance().userSigned!.profile.lastName) te quiere enseñar su lista de www.walmart.com.mx"
            }
        }
        return ""
    }
    
    func imageToShareWishList() -> UIImage {
        var unifiedImage : UIImage? = nil
        let imageHeader = UIImage(named: "wishlist_shareheaderipad")
        let totalImageSize = self.getImageWislistShareSize(imageHeader!)
        UIGraphicsBeginImageContextWithOptions(totalImageSize, false, 0.0);
        imageHeader?.drawInRect(CGRectMake(0, 0, imageHeader!.size.width, imageHeader!.size.height))
        var ixWidht : CGFloat = 0
        var ixYSpace : CGFloat = imageHeader!.size.height
        for ixItem  in 0...items.count - 1 {
            //var semaphore = dispatch_semaphore_create(0)
            let cellNew = IPAWishListProductCollectionViewCell(frame:CGRectMake(0,0,totalImageSize.width/2, totalImageSize.width/2),loadImage:{() in
                //let val = dispatch_semaphore_signal(semaphore)
            })
            loadViewCellCollection(cellNew,indexPath:NSIndexPath(forRow: ixItem, inSection: 0))
            //dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            cellNew.drawViewHierarchyInRect(CGRectMake(ixWidht, ixYSpace,totalImageSize.width/2, totalImageSize.width/2), afterScreenUpdates: true)
            if ixWidht == 0 {
                ixWidht =  totalImageSize.width/2
            }else{
                ixYSpace = ixYSpace + totalImageSize.width/2
                ixWidht = 0
            }
        }
        unifiedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return unifiedImage!
        
    }
    
    
    func loadViewCellCollection(productCell:IPAWishListProductCollectionViewCell,indexPath:NSIndexPath) {

        productCell.delegate = self
        
        let itemWishlist = items[indexPath.row] as! [String:AnyObject]
        let upc = itemWishlist["upc"] as! String
        
        let desc = itemWishlist["description"] == nil ? "" : itemWishlist["description"] as! String
        let price = itemWishlist["price"] as! NSString
        let imageArray = itemWishlist["imageUrl"] as! NSArray
        var imageUrl = ""
        if imageArray.count > 0 {
            imageUrl = imageArray.objectAtIndex(0) as! String
        }
        
        let savingIndex = itemWishlist.indexForKey("saving")
        var savingVal = "0.0"
        if savingIndex != nil {
            savingVal = itemWishlist["saving"]  as! String
        }
        
        let active  = itemWishlist["isActive"] as! String
        var isActive = "true" == active
        
        if isActive == true {
            isActive = price.doubleValue > 0
        }
        
        var isPreorderable = false
        if  let preordeable  = itemWishlist["isPreorderable"] as? String {
            isPreorderable = "true" == preordeable
        }
        
        let onHandInventory = itemWishlist["onHandInventory"] as! NSString
        
        let isInShoppingCart = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)
        
        productCell.setValues(upc, productImageURL: imageUrl, productShortDescription: desc, productPrice: price as String, productPriceThrough: savingVal,isEditting:self.isEditingWishList, isActive: isActive, onHandInventory: onHandInventory.integerValue, isPreorderable: isPreorderable,isInShoppingCart:isInShoppingCart)
        
    }
    
    
    func getImageWislistShareSize(header:UIImage) -> CGSize {
        let modItems = (self.items.count / 2) + (self.items.count % 2)
        let widthItem : CGFloat = (header.size.width / 2)
        let height : CGFloat = header.size.height + CGFloat(modItems) * widthItem
        return CGSize(width:header.size.width, height: height)
        
    }

    
    @IBAction func deleteAllItems(sender: AnyObject) {
        
        let serviceWishDelete = DeleteItemWishlistService()
        
        for itemWishlist in self.items {
            let upc = itemWishlist["upc"] as! NSString
            serviceWishDelete.callCoreDataService(upc as String, successBlock: { (result:NSDictionary) -> Void in
                }) { (error:NSError) -> Void in
            }
        }
        self.items = []
        self.reloadWishlist()
        self.editWishlist(editWishlist)
    }
    
    func close (){
        if closewl != nil {
            closewl()
        }
    }
    
}