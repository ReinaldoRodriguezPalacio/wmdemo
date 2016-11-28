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
    var currentCellSelected : IndexPath!
    var titleLabel : UILabel!
    var customlabel : CurrencyCustomLabel!
    var loading: WMLoadingView? = nil
    var popup : UIPopoverController?
    var position = 0
    
    @IBOutlet var wishlist: UICollectionView!
    @IBOutlet var shareWishlist: UIButton!
    @IBOutlet var header: UIView!
    @IBOutlet var articlesWishlist: UILabel!
    @IBOutlet var titleWishlist: UILabel!
    @IBOutlet var editWishlist : UIButton!
    @IBOutlet var deleteAllWishlist : UIButton!
    @IBOutlet var buyWishlist: UIButton!
    
    var emptyView : IPAEmptyWishlistView!
    var isEditingWishList = false
    var closewl : (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.wishlist.register(IPAWishListProductCollectionViewCell.self, forCellWithReuseIdentifier: "productwishlist")
        
        self.wishlist.dataSource = self
        self.wishlist.delegate = self
        
        self.editWishlist.addTarget(self, action: #selector(IPAWishlistViewController.editWishlist(_:)), for: .touchUpInside)
        self.view.addSubview(self.editWishlist)
        
        titleWishlist.font = WMFont.fontMyriadProRegularOfSize(24)
        titleWishlist.textColor = UIColor.white
        
        articlesWishlist.font = WMFont.fontMyriadProRegularOfSize(14)
        articlesWishlist.textColor = UIColor.white
        
        buyWishlist.backgroundColor = WMColor.green
        buyWishlist.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buyWishlist.layer.cornerRadius = self.buyWishlist.frame.height / 2
        buyWishlist.addTarget(self, action: #selector(IPAWishlistViewController.senditemsToShoppingCart), for: UIControlEvents.touchUpInside)
        
       
        
        header.backgroundColor = WMColor.light_light_gray
        
        titleLabel = UILabel(frame: CGRect(x: (header.frame.width/2) - 75, y: 0, width: 150, height: header.frame.height))
        titleLabel.text = NSLocalizedString("wishlist.title",comment:"")
        titleLabel.textAlignment = .center
        
        titleLabel.numberOfLines = 2
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.textColor = WMColor.light_blue
        self.view.addSubview(titleLabel)
        
        let borderBottom = UIView(frame: CGRect(x: 0, y: self.wishlist.frame.maxY ,width: self.view.frame.width, height: AppDelegate.separatorHeigth() ))
        borderBottom.backgroundColor = WMColor.light_light_gray
        self.view.addSubview(borderBottom)
        

        editWishlist.setTitle(NSLocalizedString("wishlist.edit",comment:""), for: UIControlState())
        editWishlist.setTitle(NSLocalizedString("wishlist.endedit",comment:""), for: UIControlState.selected)
        editWishlist.backgroundColor = WMColor.light_blue
        editWishlist.setTitleColor(UIColor.white, for: UIControlState())
        editWishlist.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        editWishlist.layer.cornerRadius = 11
        editWishlist.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
        
        
        deleteAllWishlist.setTitle(NSLocalizedString("wishlist.deleteall",comment:""), for: UIControlState())
        deleteAllWishlist.backgroundColor = WMColor.red
        deleteAllWishlist.setTitleColor(UIColor.white, for: UIControlState())
        deleteAllWishlist.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        deleteAllWishlist.layer.cornerRadius = 11
        deleteAllWishlist.alpha = 0
        deleteAllWishlist.titleEdgeInsets = UIEdgeInsetsMake(2.0, 2.0, 0.0, 0.0)
        
        let closeWL = UIButton(frame: CGRect(x: 0, y: 0, width: self.header.frame.height, height: self.header.frame.height))
        closeWL.setImage(UIImage(named: "detail_close"), for: UIControlState())
        closeWL.addTarget(self, action: #selector(IPAWishlistViewController.close), for: UIControlEvents.touchUpInside)
        self.view.addSubview(closeWL)
        
        if emptyView  != nil{
            emptyView.removeFromSuperview()
        }
        emptyView = IPAEmptyWishlistView(frame: CGRect.zero)
        self.view.addSubview(emptyView)
        
        WishlistService.shouldupdate = true
        reloadWishlist()
        
        
        
        

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        wishlist.frame = CGRect(x: 0, y: 46, width: self.view.frame.width, height: 224)
        header.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 46)
        titleLabel.frame = CGRect(x: (self.view.frame.width / 2) - 75, y: 0, width: 150, height: header.frame.height)
        editWishlist.frame = CGRect(x: 954, y: 12, width: 55, height: 22)
        deleteAllWishlist.frame = CGRect(x: 866, y: 12, width: 75, height: 22)
        buyWishlist.frame = CGRect(x: (self.view.frame.width / 2) - (buyWishlist.frame.width / 2), y: buyWishlist.frame.minY, width: buyWishlist.frame.width, height: buyWishlist.frame.height)
        titleLabel.frame = CGRect(x: (header.frame.width/2) - 75, y: 0, width: 150, height: header.frame.height)
        self.emptyView!.frame = CGRect(x: 0, y: 46, width: wishlist.frame.width, height: wishlist.frame.height + 64)
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 334)
        
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(IPAWishlistViewController.reloadWishlist), name: NSNotification.Name(rawValue: CustomBarNotification.ReloadWishList.rawValue), object: nil)

        
    }
    
    func removeNotification(){
         NotificationCenter.default.removeObserver(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadWishlist()
        self.view.frame = CGRect(x: self.view.frame.minX, y: self.view.frame.minY, width: self.view.frame.width, height: 334)


    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    func editWishlist(_ sender:AnyObject) {
   
        isEditingWishList = sender.tag == 1 ? true : !isEditingWishList

        if isEditingWishList {
            editWishlist.isSelected = true
            editWishlist.backgroundColor = WMColor.green
            editWishlist.tintColor = WMColor.dark_blue
            if self.items.count > 0 {
                self.wishlist.reloadData()
            }
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.deleteAllWishlist.alpha = 1
                self.editWishlist.tag = 0
            })
        }else {
            editWishlist.isSelected = false
            editWishlist.backgroundColor = WMColor.light_blue
            editWishlist.tintColor = WMColor.light_blue
            if self.items.count > 0 {
                self.wishlist.reloadData()
            }
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.deleteAllWishlist.alpha = 0
                self.editWishlist.tag = 0
            })
        }
        
        
    }
    
    func updateShopButton(_ total:String) {
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: self.buyWishlist.bounds)
            customlabel.backgroundColor = UIColor.clear
            customlabel.setCurrencyUserInteractionEnabled(true)
            buyWishlist.addSubview(customlabel)
            buyWishlist.sendSubview(toBack: customlabel)
        }
        let shopStr = NSLocalizedString("wishlist.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(total)
        let shopStrComplete = "\(shopStr) \(fmtTotal)"
        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.white, interLine: false)
        
    }
    
    func reloadWishlist() {
        
        if WishlistService.shouldupdate == true {
        WishlistService.shouldupdate = false
        self.loading = WMLoadingView(frame: CGRect(x: 0, y: 0, width: 1024, height: 334))
        self.view.addSubview(self.loading!)
        self.loading!.startAnnimating(false)
        
            
        let serviceWish = UserWishlistService()
        
        serviceWish.callService({ (wishlist:[String:Any]) -> Void in
            self.items = wishlist["items"] as! [AnyObject]
            
            var positionArray: [Int] = []
            var total : Double = 0
            
            for itemWishList in self.items {
                let price = itemWishList["price"] as! NSString
                let active  = itemWishList["isActive"] as! NSString
                if  active == "true"{
                    total = total + price.doubleValue
                }
                self.position += 1
                positionArray.append(self.position)
            }
            
            let totalStr = String(format: "%.2f",total)
            self.emptyView.isHidden = self.items.count > 0
            self.editWishlist.isHidden = self.items.count == 0
            self.buyWishlist.isHidden = self.items.count == 0
            self.articlesWishlist.isHidden = self.items.count == 0
            self.shareWishlist.isHidden = self.items.count == 0
            
            let articlesStr = NSLocalizedString("wishlist.articles",comment:"")
            self.articlesWishlist.text = "\(self.items.count) \(articlesStr)"
            
            self.updateShopButton(totalStr)
            
            self.wishlist.reloadData()
            
            self.loading!.stopAnnimating()
            
            let listName = "Wishlist"
            let subCategory = ""
            let subSubCategory = ""
            BaseController.sendAnalyticsTagImpressions(self.items, positionArray: positionArray, listName: listName, mainCategory: "", subCategory: subCategory, subSubCategory: subSubCategory)
            
            
            }, errorBlock: { (error:NSError) -> Void in
        })
        }
    }
    
    func updateShopButton() {
        var total : Double = 0
        for itemWishList in self.items {
            let price = itemWishList["price"] as! NSString
            let active  = itemWishList["isActive"] as! NSString
            if  active == "true"{
                total = total + price.doubleValue
            }
        }
        let totalStr = String(format: "%.2f",total)
        self.updateShopButton(totalStr)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: "productwishlist", for: indexPath) as! IPAWishListProductCollectionViewCell
        loadViewCellCollection(productCell,indexPath:indexPath)
        return productCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        return CGSize(width: 256, height: self.wishlist.frame.height);
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let paginatedProductDetail = IPAProductDetailPageViewController()
        paginatedProductDetail.ixSelected = indexPath.row
        paginatedProductDetail.itemsToShow = []
        for productRecomm  in items {
            let upc = productRecomm["upc"] as! NSString
            let desc = productRecomm["description"] as! NSString
            paginatedProductDetail.itemsToShow.append(["upc":upc,"description":desc,"type": ResultObjectType.Mg.rawValue])
        }
        
        paginatedProductDetail.detailOf = "Wish List"
        let currentCell = collectionView.cellForItem(at: indexPath) as! ProductCollectionViewCell!
        currentCellSelected = indexPath
        let pontInView = currentCell?.convert(currentCell!.productImage!.frame, to:  self.view)
        paginatedProductDetail.animationController = ProductDetailNavigatinAnimationController(nav:self.navigationController!)
        paginatedProductDetail.animationController.originPoint =  pontInView
        paginatedProductDetail.animationController.setImage(currentCell!.productImage!.image!)
        currentCell?.hideImageView()
        
        self.navigationController?.delegate = paginatedProductDetail
        self.navigationController?.pushViewController(paginatedProductDetail, animated: true)
        
    }
    
    func deleteProductWishList(_ cell:IPAWishListProductCollectionViewCell) {
        
        let indexPath = self.wishlist.indexPath(for: cell)
        let itemWishlist = items[indexPath!.row] as! [String:Any]
        let upc = itemWishlist["upc"] as! NSString
        let deleteWishListService = DeleteItemWishlistService()
        deleteWishListService.callCoreDataService(upc as String, successBlock: { (result:[String:Any]) -> Void in
            self.items.remove(at: indexPath!.row)
            self.wishlist.deleteItems(at: [indexPath!])
            //self.wishlist.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            //self.wishlist.reloadData()
            self.emptyView.isHidden = self.items.count > 0
            self.deleteAllWishlist.isHidden = self.items.count == 0 && self.isEditingWishList
            self.updateShopButton()
            self.editWishlist.isHidden = self.items.count == 0
            //self.isEditingWishList =  true
             self.editWishlist.tag = 1
            self.editWishlist(self.editWishlist)
            self.deleteAllWishlist.isHidden = self.items.count == 0
            if self.items.count == 0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ShowBar.rawValue), object: nil)
            }
            }, errorBlock: { (error:NSError) -> Void in
                print("delete pressed Errro \(error)")
        })
    }
    
    func senditemsToShoppingCart() {
        
        var params : [AnyObject] =  []
        var paramsPreorderable : [AnyObject] =  []
        var hasItemsNotAviable = false
        var wishlistTotalPrice = 0.0

        for itemWishList in self.items {
            
            let upc = itemWishList["upc"] as! String
            let desc = itemWishList["description"] as! String
            let price = itemWishList["price"] as! NSString
            let imageArray = itemWishList["imageUrl"] as! NSArray
            
            let active  = itemWishList["isActive"] as! String
            var isActive = "true" == active
            
            if isActive == true {
                isActive = price.doubleValue > 0
                if isActive {
                    wishlistTotalPrice += price.doubleValue
                }
            }
            
            
            var isPreorderable = "true"
            if  let preordeable  = itemWishList["isPreorderable"] as? String {
                isPreorderable = preordeable
            }
            
            //let onHandInventory = itemWishList["onHandInventory"] as NSString
            
            var numOnHandInventory : NSString = "0"
            if let numberOf = itemWishList["onHandInventory"] as? String{
                numOnHandInventory  = numberOf as NSString
            }
            
            var imageUrl = ""
            if imageArray.count > 0 {
                imageUrl = imageArray.object(at: 0) as! String
            }
            
            var category : String = ""
            if let categoryVal = itemWishList["category"] as? String{
                category  = categoryVal
            }
            
            
            
            if isActive == true && numOnHandInventory.integerValue > 0  { //&& isPreorderable == false
                let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc as String)
                if !hasUPC {
                    let paramsItem = CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageUrl, price: price as String , quantity: "1",onHandInventory:numOnHandInventory as String,wishlist:true,type:ResultObjectType.Mg.rawValue,pesable:"0",isPreorderable:isPreorderable,category:category)
                    //params.append(paramsItem)
                    if isPreorderable == "true" {
                        paramsPreorderable.append(paramsItem)
                    }else{
                        params.append(paramsItem)
                    }

                }
                

                
            } else{
                
            hasItemsNotAviable = true
            }
        }//for
        //condiciones
        
        
        
        if paramsPreorderable.count == 0 && params.count == 0{
            
            if self.items.count > 0 && hasItemsNotAviable {
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"cart_loading"),imageDone:nil,imageError:UIImage(named:"cart_loading"))
                let aleradyMessage = NSLocalizedString("productdetail.notaviable",comment:"")
                
                alert!.setMessage(aleradyMessage)
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                return
            }
            
            
            
            
            
            if self.items.count > 1 {
                for itemWishList in self.items {
                    let upc = itemWishList["upc"] as! NSString
                    let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc as String)
                    if hasUPC {
                        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"done"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"done"))
                        alert!.setMessage(NSLocalizedString("shoppingcart.alreadyincart",comment:""))
                        alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                        
                        return
                    }
                }
                
                
                
            }

        }
        let identicalMG = UserCurrentSession.sharedInstance().identicalMG()
        let totArticlesMG = UserCurrentSession.sharedInstance().numberOfArticlesMG()
        
        if paramsPreorderable.count == 0 && params.count == 0 {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"done"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"done"))
            alert!.setMessage(NSLocalizedString("shoppingcart.alreadyincart",comment:""))
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            return
        }
        if params.count  > 0 && paramsPreorderable.count == 0 && (totArticlesMG == 0 || !identicalMG) {
            self.sendNewItemsToShoppingCart(params)
        }else{
            
            if paramsPreorderable.count > 1 && params.count == 0  &&  totArticlesMG == 0{
               
                let itemImage = paramsPreorderable[0] as! [String:Any]
                let alert = IPAWMAlertViewController.showAlert(WishListViewController.createImage(itemImage["imgUrl"] as! String),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                alert!.spinImage.isHidden =  true
                alert!.viewBgImage.backgroundColor =  UIColor.white
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
                alert!.spinImage.isHidden =  true
                alert!.viewBgImage.backgroundColor =  UIColor.white
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
                    var itemImage =  [String:Any]()
                    if paramsPreorderable.count == 0{
                        itemImage =  params[0] as! [String:Any]
                    }else{
                        itemImage =  paramsPreorderable[0] as! [String:Any]
                    }
                    let alert = IPAWMAlertViewController.showAlert(WishListViewController.createImage(itemImage["imgUrl"] as! String),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                    alert!.spinImage.isHidden =  true
                    alert!.viewBgImage.backgroundColor = UIColor.white

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
        
        // Event
        BaseController.sendAnalyticsProductsToCart(Int(wishlistTotalPrice))
        
    }
    
    func sendNewItemsToShoppingCart(_ params:[AnyObject]){
        if params.count > 0 {
            let paramsAll = ["allitems":params, "image":"wishlist_addToCart"    ] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddItemsToShopingCart.rawValue), object: self, userInfo: paramsAll as [AnyHashable: Any])
        }
//       //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_WISHLIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_WISHLIST.rawValue, action: WMGAIUtils.ACTION_ADD_ALL_WISHLIST.rawValue, label: "")
    }
    
    func reloadSelectedCell() {
        if currentCellSelected != nil {
            if let currentCell = wishlist.cellForItem(at: currentCellSelected) as? IPAWishListProductCollectionViewCell {
                currentCell.showImageView()
            }
        }
    }
    
    @IBAction func shareWishList(_ sender: AnyObject) {
        
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
        let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx/Busqueda.aspx?Text=\(upcList)")
        
        let controller = UIActivityViewController(activityItems: [self,urlWmart!,imgResult], applicationActivities: nil)
        popup = UIPopoverController(contentViewController: controller)
        
        popup!.present(from: CGRect(x: self.shareWishlist.frame.origin.x + 13, y: self.shareWishlist.frame.maxY - 120, width: 10, height: 120), in: self.view, permittedArrowDirections: UIPopoverArrowDirection.up, animated: true)
        
        if #available(iOS 8.0, *) {
            controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
                if completed && !activityType!.contains("com.apple")   {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        } else {
            controller.completionHandler = {(activityType, completed:Bool) in
                if completed && !activityType!.contains("com.apple")   {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        }
        
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any{
        return "Walmart"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        if activityType == UIActivityType.mail {
            return "Hola,\nMira estos productos que encontré en Walmart. ¡Te los recomiendo!"
        }
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        if activityType == UIActivityType.mail {
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
        imageHeader?.draw(in: CGRect(x: 0, y: 0, width: imageHeader!.size.width, height: imageHeader!.size.height))
        var ixWidht : CGFloat = 0
        var ixYSpace : CGFloat = imageHeader!.size.height
        for ixItem  in 0...items.count - 1 {
            //var semaphore = dispatch_semaphore_create(0)
            let cellNew = IPAWishListProductCollectionViewCell(frame:CGRect(x: 0,y: 0,width: totalImageSize.width/2, height: totalImageSize.width/2),loadImage:{() in
                //let val = dispatch_semaphore_signal(semaphore)
            })
            loadViewCellCollection(cellNew,indexPath:IndexPath(row: ixItem, section: 0))
            //dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            cellNew.drawHierarchy(in: CGRect(x: ixWidht, y: ixYSpace,width: totalImageSize.width/2, height: totalImageSize.width/2), afterScreenUpdates: true)
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
    
    func loadViewCellCollection(_ productCell:IPAWishListProductCollectionViewCell,indexPath:IndexPath) {

        productCell.delegate = self
        
        let itemWishlist = items[indexPath.row] as! [String:Any]
        let upc = itemWishlist["upc"] as! String
        
        let desc = itemWishlist["description"] == nil ? "" : itemWishlist["description"] as! String
        let price = itemWishlist["price"] as! NSString
        let imageArray = itemWishlist["imageUrl"] as! NSArray
        var imageUrl = ""
        if imageArray.count > 0 {
            imageUrl = imageArray.object(at: 0) as! String
        }
        
        let savingIndex = itemWishlist.index(forKey: "saving")
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
    
    func getImageWislistShareSize(_ header:UIImage) -> CGSize {
        let modItems = (self.items.count / 2) + (self.items.count % 2)
        let widthItem : CGFloat = (header.size.width / 2)
        let height : CGFloat = header.size.height + CGFloat(modItems) * widthItem
        return CGSize(width:header.size.width, height: height)
        
    }

    @IBAction func deleteAllItems(_ sender: AnyObject) {
        
        let serviceWishDelete = DeleteItemWishlistService()
        
        for itemWishlist in self.items {
            let upc = itemWishlist["upc"] as! NSString
            serviceWishDelete.callCoreDataService(upc as String, successBlock: { (result:[String:Any]) -> Void in
                }) { (error:NSError) -> Void in
            }
        }
        self.items = []
        self.reloadWishlist()
        //self.isEditingWishList =  false
        self.editWishlist.tag = 1
        self.editWishlist(self.editWishlist)
        self.deleteAllWishlist.alpha = 0

    }
    
    func close (){
        if closewl != nil {
            closewl()
        }
    }
    
}
