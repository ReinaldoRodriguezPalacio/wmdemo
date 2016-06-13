//
//  DefaultListDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 25/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class DefaultListDetailViewController : NavigationViewController, UITableViewDelegate, UITableViewDataSource,
DetailListViewCellDelegate,UIActivityItemSource {
    
    //MARK: Views
    var tableView : UITableView?
    
    var defaultListName : String? = ""
    var detailItems : [[String:AnyObject]]? = []
    var selectedItems : NSMutableArray? = nil
    var quantitySelector: GRShoppingCartQuantitySelectorView?
    
    var footerSection : UIView? = nil
    var shareButton: UIButton?
    var addToCartButton: UIButton?
    var customLabel: CurrencyCustomLabel?
    var enableScrollUpdateByTabBar = true
    var isShowingTabBar : Bool = true
    var isSharing: Bool = false
    var duplicateButton: UIButton?
    var lineId: String?
    
    var alertView : IPOWMAlertViewController?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PACTILISTASDETAILS.rawValue
    }
    
    let CELL_ID = "listDefaultCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = defaultListName
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomBarNotification.TapBarFinish.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(DefaultListDetailViewController.tabBarActions),name:CustomBarNotification.TapBarFinish.rawValue, object: nil)
         self.tabBarActions()
    }
    
    override func setup() {
        super.setup()
        
        tableView  = UITableView(frame: CGRectZero)
        tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellDetailList")
        tableView?.registerClass(DetailListViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .None
        self.view.addSubview(tableView!)
        
        if self.detailItems?.count == 0 || self.detailItems == nil {
            selectedItems = []
        }
        else{
            selectedItems = NSMutableArray()
            for i in 0...self.detailItems!.count - 1 {
                selectedItems?.addObject(i)
            }
        }
        
        if TabBarHidden.isTabBarHidden {
            self.footerSection = UIView(frame:CGRectMake(0,  self.view.frame.maxY - 132 , self.view.frame.width, 72))
        }
        else{
            self.footerSection = UIView(frame:CGRectMake(0,  self.view.frame.maxY - 180 , self.view.frame.width, 72))
        }
        self.footerSection!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(footerSection!)
        
        let y = (self.footerSection!.frame.height - 34.0)/2
        self.duplicateButton = UIButton(frame: CGRectMake(16.0, y, 34.0, 34.0))
        self.duplicateButton!.setImage(UIImage(named: "list_duplicate"), forState: .Normal)
        self.duplicateButton!.setImage(UIImage(named: "list_active_duplicate"), forState: .Selected)
        self.duplicateButton!.setImage(UIImage(named: "list_active_duplicate"), forState: .Highlighted)
        self.duplicateButton!.addTarget(self, action: #selector(DefaultListDetailViewController.duplicate), forControlEvents: .TouchUpInside)
        self.footerSection!.addSubview(self.duplicateButton!)
        
        var x = self.duplicateButton!.frame.maxX + 16.0
        self.shareButton = UIButton(frame: CGRectMake(x, y, 34.0, 34.0))
        self.shareButton!.setImage(UIImage(named: "detail_shareOff"), forState: .Normal)
        self.shareButton!.setImage(UIImage(named: "detail_share"), forState: .Selected)
        self.shareButton!.setImage(UIImage(named: "detail_share"), forState: .Highlighted)
        self.shareButton!.addTarget(self, action: #selector(DefaultListDetailViewController.shareList), forControlEvents: .TouchUpInside)
        self.footerSection!.addSubview(self.shareButton!)
        
        x = self.shareButton!.frame.maxX + 16.0
        self.addToCartButton = UIButton(frame: CGRectMake(x, y, self.footerSection!.frame.width - (x + 16.0), 34.0))
        self.addToCartButton!.backgroundColor = WMColor.green
        self.addToCartButton!.layer.cornerRadius = 17.0
        self.addToCartButton!.addTarget(self, action: #selector(DefaultListDetailViewController.addListToCart), forControlEvents: .TouchUpInside)
        self.footerSection!.addSubview(self.addToCartButton!)
        
        self.customLabel = CurrencyCustomLabel(frame: self.addToCartButton!.bounds)
        self.customLabel!.backgroundColor = UIColor.clearColor()
        self.customLabel!.setCurrencyUserInteractionEnabled(true)
        self.addToCartButton!.addSubview(self.customLabel!)
        self.addToCartButton!.sendSubviewToBack(self.customLabel!)
        
        self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)
        self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height, 0)
        
        if self.enableScrollUpdateByTabBar && !TabBarHidden.isTabBarHidden {
            let tabBarHeight:CGFloat = 45.0
            self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height + tabBarHeight, 0)
            self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height + tabBarHeight, 0)
        }
        
        self.isSharing = false
        updateTotalLabel()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !self.isSharing {
            tableView?.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, self.view.frame.height - self.header!.frame.maxY)
        }
        let x = self.shareButton!.frame.maxX + 16.0
        let y = (self.footerSection!.frame.height - 34.0)/2
        addToCartButton?.frame = CGRectMake(x, y, self.footerSection!.frame.width - (x + 16.0), 34.0)
    
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.detailItems == nil { return 0 }
        return self.detailItems!.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let listCell = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID, forIndexPath: indexPath) as! DetailListViewCell
        listCell.setValuesDictionary(self.detailItems![indexPath.row],disabled:!self.selectedItems!.containsObject(indexPath.row))
        listCell.detailDelegate = self
        listCell.hideUtilityButtonsAnimated(false)
        listCell.setLeftUtilityButtons([], withButtonWidth: 0.0)
        listCell.setRightUtilityButtons([], withButtonWidth: 0.0)
        return listCell 
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = ProductDetailPageViewController()
        var productsToShow:[AnyObject] = []
        for idx in 0 ..< self.detailItems!.count {
            let product = self.detailItems![idx]
            let upc = product["upc"] as! NSString
            let description = product["description"] as! NSString

            productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Groceries.rawValue, "saving":""])
        }
        controller.itemsToShow = productsToShow
        controller.ixSelected = indexPath.row
        
        let product = self.detailItems![indexPath.row]
        let upc = product["upc"] as! NSString
        let description = product["description"] as! NSString
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL_PRACTILISTA.rawValue, label: "\(description) - \(upc)")
        
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == self.detailItems!.count ? 56.0 : 109.0
    }
    
    //MARK: Delegate item cell
    func didChangeQuantity(cell:DetailListViewCell){
        
        if self.quantitySelector == nil {
            
            let indexPath = self.tableView!.indexPathForCell(cell)
            if indexPath == nil {
                return
            }
            var isPesable = false
            var price: NSNumber? = nil
          
                let item = self.detailItems![indexPath!.row]
                if let pesable = item["type"] as? NSString {
                    isPesable = pesable.intValue == 1
                }
                price = item["price"] as? NSNumber
            
            
            let width:CGFloat = self.view.frame.width
            var height:CGFloat = (self.view.frame.height - self.header!.frame.height) + 2.0
            if TabBarHidden.isTabBarHidden {
                height += 45.0
            }
            let selectorFrame = CGRectMake(0, self.view.frame.height, width, height)
            
            if isPesable {
                self.quantitySelector = GRShoppingCartWeightSelectorView(frame: selectorFrame, priceProduct: price,equivalenceByPiece:cell.equivalenceByPiece!,upcProduct:cell.upcVal!)
            }
            else {
                self.quantitySelector = GRShoppingCartQuantitySelectorView(frame: selectorFrame, priceProduct: price,upcProduct:cell.upcVal!)
            }
            self.view.addSubview(self.quantitySelector!)
            self.quantitySelector!.closeAction = { () in
                self.removeSelector()
            }
            self.quantitySelector!.generateBlurImage(self.view, frame:CGRectMake(0.0, 0.0, width, height))
            self.quantitySelector!.addToCartAction = { (quantity:String) in
                var item = self.detailItems![indexPath!.row]
                //var upc = item["upc"] as? String
                item["quantity"] = NSNumber(integer:Int(quantity)!)
                self.detailItems![indexPath!.row] = item
                self.tableView?.reloadData()
                self.removeSelector()
                self.updateTotalLabel()
                //TODO: Update quantity
            }
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.quantitySelector!.frame = CGRectMake(0.0, 0.0, width, height)
            })
            
        }
        else {
            self.removeSelector()
        }
    }
    
    func removeSelector() {
        if   self.quantitySelector != nil {
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    let width:CGFloat = self.view.frame.width
                    let height:CGFloat = self.view.frame.height - self.header!.frame.height
                    self.quantitySelector!.frame = CGRectMake(0.0, self.view.frame.height, width, height)
                },
                completion: { (finished:Bool) -> Void in
                    if finished {
                        self.quantitySelector!.removeFromSuperview()
                        self.quantitySelector = nil
                    }
                }
            )
        }
    }

    
    func didDisable(disaable:Bool, cell:DetailListViewCell) {
        let indexPath = self.tableView?.indexPathForCell(cell)
        if disaable {
            self.selectedItems?.removeObject(indexPath!.row)
        } else {
            self.selectedItems?.addObject(indexPath!.row)
        }
        self.updateTotalLabel()
    }
    
    
    //MARK: Actions
    
    func shareList() {

        if let image = self.tableView!.screenshot() {
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHARE.rawValue, label: self.defaultListName!)
            let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx")
            
            let controller = UIActivityViewController(activityItems: [self,image,urlWmart!], applicationActivities: nil)
            self.navigationController?.presentViewController(controller, animated: true, completion: nil)
            
        }
    }
    
    //MARK: activityViewControllerDelegate
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject{
        return "Walmart"
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        
     
        let url  = NSURL(string: "itms-apps://itunes.apple.com/mx/app/walmart-mexico/id823947897?mt=8")
       
        var urlss  = ""
        if self.lineId != nil {
            let appLink  = NSURL(string: "walmartmexicoapp://bussines_mg&type_LIST&value_\(self.lineId! as String)")// NSURL(string: "walmartmexicoapp://bussines_mg/type_LIN/value_l-lp-colegio-montesori-primero")
            urlss = "\n Entra a la aplicación:\n \(appLink!)"
        }
        
        let urlapp  = url?.absoluteURL
        
        if activityType == UIActivityTypeMail {
            return "Hola, encontré estos productos en Walmart.¡Te los recomiendo! \n \n Siempre encuentra todo y pagas menos.\(urlss) \n-Descarga la aplicación en : \n\(urlapp!) \n \n"
        }else if activityType == UIActivityTypePostToTwitter ||  activityType == UIActivityTypePostToVimeo ||  activityType == UIActivityTypePostToFacebook  {
            return "Chequa esta lista de productos:  #walmartapp #wow "
        }
        return "Chequa esta lista de productos: \(urlss) \n -Descarga la aplicación en : \n \(urlapp!)"
    }
    
    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        if activityType == UIActivityTypeMail {
            if UserCurrentSession.sharedInstance().userSigned == nil {
                return "Encontré estos productos te pueden interesar en www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance().userSigned!.profile.name) encontró unos productos que te pueden interesar en www.walmart.com.mx"
            }
        }
        return ""
    }
    //-----
    
    func buildImageToShare() -> UIImage? {
        
        
        self.tableView!.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        
        self.isSharing = true
        let oldFrame : CGRect = self.tableView!.frame
        var frame : CGRect = self.tableView!.frame
        frame.size.height = self.tableView!.contentSize.height + 50.0
        self.tableView!.frame = frame
        
        UIGraphicsBeginImageContextWithOptions(self.tableView!.bounds.size, false, 2.0)
        self.tableView!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let saveImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.isSharing = false
        self.tableView!.frame = oldFrame
        return saveImage
    }
    
    func addListToCart() {
        
        
        //ValidateActives
        var hasActive = false
        for product in self.detailItems! {
            let item = product
            let stock = item["stock"] as! Bool
            let active = item["isActive"] as! String
            if stock && active == "true" {
                hasActive = true
                break
            }
        }
 
    
        if !hasActive {
            self.noProductsAvailableAlert()
            return
        }
        
        if self.selectedItems != nil && self.selectedItems!.count > 0 {
            var upcs: [AnyObject] = []
            for idxVal  in selectedItems! {
                let idx = idxVal as! Int
                var params: [String:AnyObject] = [:]
                let item = self.detailItems![idx]
                params["upc"] = item["upc"] as! String
                params["desc"] = item["description"] as! String
                params["imgUrl"] = item["imageUrl"] as! String
                if let price = item["price"] as? NSNumber {
                    params["price"] = "\(price)"
                }
                if let quantity = item["quantity"] as? NSNumber {
                    params["quantity"] = "\(quantity)"
                }
                
                params["pesable"] = item["type"] as? NSString
                params["wishlist"] = false
                params["type"] = ResultObjectType.Groceries.rawValue
                params["comments"] = ""
                if let type = item["type"] as? String {
                    if Int(type)! == 0 { //Piezas
                        params["onHandInventory"] = "99"
                    }
                    else { //Gramos
                        params["onHandInventory"] = "20000"
                    }
                }
                upcs.append(params)
            }
            if upcs.count > 0 {
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddItemsToShopingCart.rawValue, object: self, userInfo: ["allitems":upcs, "image":"list_alert_addToCart"])
            }else{
                self.noProductsAvailableAlert()
                return
            }
        }else{
            self.noProductsAvailableAlert()
            return
        }
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ADD_ALL_TO_SHOPPING_CART.rawValue, label: self.defaultListName!)
    }

    func noProductsAvailableAlert(){
        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
        let msgInventory = "No existen productos disponibles para agregar al carrito"
        alert!.setMessage(msgInventory)
        alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
    }
    
    func updateTotalLabel() {
        var total: Double = 0.0
        if self.selectedItems != nil && self.selectedItems!.count > 0 {
            total = self.calculateTotalAmount()
        }
        
        let fmtTotal = CurrencyCustomLabel.formatString("\(total)")
        let amount = String(format: NSLocalizedString("list.detail.buy",comment:""), fmtTotal)
        self.customLabel!.updateMount(amount, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.whiteColor(), interLine: false)
    }
    
    func calculateTotalAmount() -> Double {
        var total: Double = 0.0
        for idxVal  in selectedItems! {
            let idx = idxVal as! Int
            let item = self.detailItems![idx]
            if let typeProd = item["type"] as? NSString {
                let quantity = item["quantity"] as! NSNumber
                let price = item["price"] as! NSNumber
                
                if typeProd.integerValue == 0 {
                    total += (quantity.doubleValue * price.doubleValue)
                }
                else {
                    let kgrams = quantity.doubleValue / 1000.0
                    total += (kgrams * price.doubleValue)
                }
            }
        }
        return total
    }
    
    func calculateTotalCount() -> Int {
        var count = 0
        for idxVal  in selectedItems! {
            let idx = idxVal as! Int
            let item = self.detailItems![idx]
            if let typeProd = item["type"] as? NSString {
                if typeProd.integerValue == 0 {
                    let quantity = item["quantity"] as! NSNumber
                    count += quantity.integerValue
                }
                else {
                    count += 1
                }
            }
        }
        return count
    }
    
    
    
    
    override func willShowTabbar() {
        isShowingTabBar = true
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.footerSection!.frame = CGRectMake(0,  self.view.frame.maxY - 117 , self.view.frame.width, 72)
        })
    }
    
    override func willHideTabbar() {
        isShowingTabBar = false
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.footerSection!.frame = CGRectMake(0,  self.view.frame.maxY - 72, self.view.frame.width, 72)
        })
    }
    

    func duplicate() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DUPLICATE_LIST.rawValue, label: self.defaultListName!)
        self.invokeSaveListToDuplicateService(defaultListName!, successDuplicateList: { () -> Void in
            self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
            self.alertView!.showDoneIcon()
        })
    }
    
    
    func invokeSaveListToDuplicateService(listName:String,successDuplicateList:(() -> Void)) {
        
        alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.copy.inProcess", comment:""))
        let service = GRUserListService()
        if UserCurrentSession.sharedInstance().userSigned != nil {
            
            service.callService([:], successBlock: { (result:NSDictionary) -> Void in
                
                let  itemsUserList = result["responseArray"] as? [AnyObject]
                self.copyList(listName, itemsUserList: itemsUserList, successDuplicateList: successDuplicateList)
                
                
                }) { (error:NSError) -> Void in
                    
                    print("Error at retrieve list detail")
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                    
            }
        } else {
            let itemsUserList = service.retrieveUserList()
            if itemsUserList?.count >= 12{
                self.alertView!.setMessage(NSLocalizedString("list.error.validation.max",comment:""))
                self.alertView!.showErrorIcon("Ok")
            }else{
                self.copyList(listName, itemsUserList: itemsUserList, successDuplicateList: successDuplicateList)
            }
        }

        
    }
    
    
    
    func copyList(listName:String,itemsUserList:[AnyObject]?,successDuplicateList:(() -> Void)) {
        let service = GRSaveUserListService()
        var items: [AnyObject] = []
        if self.detailItems != nil {
            for idx in 0 ..< self.detailItems!.count {
                var product = self.detailItems![idx]
                let quantity = product["quantity"] as! NSNumber
                let imageUrl = product["imageUrl"] as! String
                let price = product["price"] as! NSNumber
                let dsc = product["description"] as! String
                let type = product["type"] as! String
                
                if let upc = product["upc"] as? String {
                    let item = service.buildProductObject(upc: upc, quantity: quantity.integerValue, image: imageUrl, description: dsc, price: price.stringValue, type:type)
                    items.append(item)
                }
            }
        }
        
        var copyName = self.buildDuplicateNameList(listName, forListId: "",itemsUserList:itemsUserList)
        if copyName.length() > 25 {
            copyName = (copyName as NSString).substringToIndex(24)
        }
        service.callService(service.buildParams(copyName, items: items),
            successBlock: { (result:NSDictionary) -> Void in
                successDuplicateList()
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at duplicate list")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            }
        )
    }
    
    func buildDuplicateNameList(theName:String, forListId listId:String?,itemsUserList:[AnyObject]?) -> String {
     
        
        var listName = "\(theName)" //Se crea una nueva instancia
        let whitespaceset = NSCharacterSet.whitespaceCharacterSet()
        var arrayOfIndex: [Int] = []
        if let range = listName.rangeOfString("copia", options: .LiteralSearch, range: nil, locale: nil) {
            listName = listName.substringToIndex(range.startIndex)
        }
        listName = listName.stringByTrimmingCharactersInSet(whitespaceset)
        if itemsUserList != nil {
            if itemsUserList!.count > 0 {
                for idx in 0 ..< itemsUserList!.count {
                    var name:String? = nil
                    var stringIndex: String? = nil
                    if let innerList = itemsUserList![idx] as? [String:AnyObject] {
                        let innerListId = innerList["id"] as! String
                        if innerListId == listId! {
                            continue
                        }
                        name = innerList["name"] as? String
                    }
                    else if let listEntity = itemsUserList![idx] as? List {
                        name = listEntity.name
                    }
                    
                    if name != nil {
                        if let range = name!.rangeOfString("copia", options: .LiteralSearch, range: nil, locale: nil) {
                            stringIndex = name!.substringFromIndex(range.endIndex)
                            name = name!.substringToIndex(range.startIndex)
                        }
                        name = name!.stringByTrimmingCharactersInSet(whitespaceset)
                        if stringIndex != nil {
                            stringIndex = stringIndex!.stringByTrimmingCharactersInSet(whitespaceset)
                            if name!.hasPrefix(listName) {
                                stringIndex = stringIndex! == "" ? "1" : stringIndex
                                arrayOfIndex.append(Int(stringIndex!)!)
                            }
                        }
                    }
                }
            }
        }
        let listIndexes = Set([1,2,3,4,5,6,7,8,9,10,11,12])
        let dispinibleIndex = listIndexes.subtract(arrayOfIndex).minElement()
        var idxTxt = dispinibleIndex == 1 ? "copia" : "copia \(dispinibleIndex!)"
        
        if self.findListindb("\(listName) \(idxTxt)") {
            idxTxt = "copia \(dispinibleIndex! + 1)"
        }
        
        var returnName =  "\(listName) \(idxTxt)"
        if returnName.length() > 25 {
            returnName = (returnName as NSString).substringToIndex(24)
            returnName = "\(returnName)\(dispinibleIndex!)"
        }
        
        return returnName
        
        
    }
    
    func findListindb(newNameList:String) -> Bool{
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let service =  GRSaveUserListService()
        let localList =  service.retrieveListNotSync(name: newNameList, inContext:context)
        
        return localList != nil//true no exsite
        
    }

    func tabBarActions(){
        if TabBarHidden.isTabBarHidden {
            self.willHideTabbar()
        }else{
            self.willShowTabbar()
        }
    }
}