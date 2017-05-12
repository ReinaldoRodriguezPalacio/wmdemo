//
//  DefaultListDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 25/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class DefaultListDetailViewController : NavigationViewController, UITableViewDelegate, UITableViewDataSource,
DetailListViewCellDelegate,UIActivityItemSource {
    
    //MARK: Views
    var tableView : UITableView?
    
    var defaultListName : String? = ""
    var detailItems : [[String:Any]]? = []
    var selectedItems : NSMutableArray? = nil
    var quantitySelector: GRShoppingCartQuantitySelectorView?
    
    var footerSection : UIView? = nil
    var shareButton: UIButton?
    var addToCartButton: UIButton?
    var customLabel: CurrencyCustomLabel?
    var enableScrollUpdateByTabBar = true
    var isSharing: Bool = false
    var duplicateButton: UIButton?
    var lineId: String?
    var schoolName: String! = ""
    var gradeName: String?
    var nameLine: String! = ""
    
    var alertView : IPOWMAlertViewController?
    var preview: PreviewModalView? = nil
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PACTILISTASDETAILS.rawValue
    }
    
    let CELL_ID = "listDefaultCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = defaultListName
        
        if detailItems != nil && defaultListName != nil {
            
            var position = 0
            var positionArray: [Int] = []
            
            for _ in self.detailItems! {
                position += 1
                positionArray.append(position)
            }
            
            let listName = self.defaultListName!
            let subCategory = ""
            let subSubCategory = ""
            BaseController.sendAnalyticsTagImpressions(self.detailItems!, positionArray: positionArray, listName: listName, mainCategory: "", subCategory: subCategory, subSubCategory: subSubCategory)
        }
        
        BaseController.setOpenScreenTagManager(titleScreen: self.defaultListName!, screenName: self.getScreenGAIName())
        UserCurrentSession.sharedInstance.nameListToTag = self.defaultListName!
        
        //The 'view' argument should be the view receiving the 3D Touch.
        if #available(iOS 9.0, *), self.is3DTouchAvailable(){
            registerForPreviewing(with: self, sourceView: tableView!)
        }else if !IS_IPAD{
            addLongTouch(view:tableView!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func setup() {
        super.setup()
        
        tableView  = UITableView(frame: CGRect.zero)
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cellDetailList")
        tableView?.register(DetailListViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        self.view.addSubview(tableView!)
        
        if self.detailItems?.count == 0 || self.detailItems == nil {
            selectedItems = []
        }
        else{
            selectedItems = NSMutableArray()
            for i in 0...self.detailItems!.count - 1 {
                selectedItems?.add(i)
            }
        }
        
        self.footerSection = UIView(frame:CGRect(x: 0,  y: self.view.frame.height - 72 , width: self.view.frame.width, height: 72))
        self.footerSection!.backgroundColor = UIColor.white
        self.view.addSubview(footerSection!)
        
        let y = (self.footerSection!.frame.height - 34.0)/2
        self.duplicateButton = UIButton(frame: CGRect(x: 16.0, y: y, width: 34.0, height: 34.0))
        self.duplicateButton!.setImage(UIImage(named: "list_duplicate"), for: UIControlState())
        self.duplicateButton!.setImage(UIImage(named: "list_active_duplicate"), for: .selected)
        self.duplicateButton!.setImage(UIImage(named: "list_active_duplicate"), for: .highlighted)
        self.duplicateButton!.addTarget(self, action: #selector(DefaultListDetailViewController.duplicate), for: .touchUpInside)
        self.footerSection!.addSubview(self.duplicateButton!)
        
        var x = self.duplicateButton!.frame.maxX + 16.0
        self.shareButton = UIButton(frame: CGRect(x: x, y: y, width: 34.0, height: 34.0))
        self.shareButton!.setImage(UIImage(named: "detail_shareOff"), for: UIControlState())
        self.shareButton!.setImage(UIImage(named: "detail_share"), for: .selected)
        self.shareButton!.setImage(UIImage(named: "detail_share"), for: .highlighted)
        self.shareButton!.addTarget(self, action: #selector(DefaultListDetailViewController.shareList), for: .touchUpInside)
        self.footerSection!.addSubview(self.shareButton!)
        
        x = self.shareButton!.frame.maxX + 16.0
        self.addToCartButton = UIButton(frame: CGRect(x: x, y: y, width: self.footerSection!.frame.width - (x + 16.0), height: 34.0))
        self.addToCartButton!.backgroundColor = WMColor.green
        self.addToCartButton!.layer.cornerRadius = 17.0
        self.addToCartButton!.addTarget(self, action: #selector(DefaultListDetailViewController.addListToCart), for: .touchUpInside)
        self.footerSection!.addSubview(self.addToCartButton!)
        
        self.customLabel = CurrencyCustomLabel(frame: self.addToCartButton!.bounds)
        self.customLabel!.backgroundColor = UIColor.clear
        self.customLabel!.setCurrencyUserInteractionEnabled(true)
        self.addToCartButton!.addSubview(self.customLabel!)
        self.addToCartButton!.sendSubview(toBack: self.customLabel!)
        
        
        self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height , 0)
        self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerSection!.frame.height , 0)
        
        self.isSharing = false
        updateTotalLabel()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        footerSection?.frame = CGRect(x: 0,  y: self.view.frame.height - 116, width: self.view.frame.width, height: 72)
        tableView?.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.header!.frame.maxY - 44)
        let x = self.shareButton!.frame.maxX + 16.0
        let y = (self.footerSection!.frame.height - 34.0)/2
        addToCartButton?.frame = CGRect(x: x, y: y, width: self.footerSection!.frame.width - (x + 16.0), height: 34.0)
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.detailItems == nil { return 0 }
        return self.detailItems!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let listCell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID, for: indexPath) as! DetailListViewCell
        listCell.setValuesDictionary(self.detailItems![indexPath.row],disabled:!self.selectedItems!.contains(indexPath.row))
        listCell.detailDelegate = self
        listCell.hideUtilityButtons(animated: false)
        listCell.setLeftUtilityButtons([], withButtonWidth: 0.0)
        listCell.setRightUtilityButtons([], withButtonWidth: 0.0)
        return listCell 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = self.getDetailController(indexPath: indexPath)
        self.navigationController!.pushViewController(controller!, animated: true)
        
    }
    
    func getDetailController(indexPath:IndexPath) -> ProductDetailPageViewController? {
        let controller = ProductDetailPageViewController()
        var productsToShow:[Any] = []
        for idx in 0 ..< self.detailItems!.count {
            let product = self.detailItems![idx]
            let upc = product["upc"] as! NSString
            let description = product["description"] as! NSString
            
            productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Groceries.rawValue, "saving":""])
        }
        controller.itemsToShow = productsToShow
        controller.ixSelected = indexPath.row
        controller.detailOf = self.defaultListName!
        
        //        let product = self.detailItems![indexPath.row]
        //        let upc = product["upc"] as! NSString
        //        let description = product["description"] as! NSString
        //
        //        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL_PRACTILISTA.rawValue, label: "\(description) - \(upc)")
        return controller
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == self.detailItems!.count ? 56.0 : 109.0
    }
    
    //MARK: Delegate item cell
    func didChangeQuantity(_ cell:DetailListViewCell){
        
        if self.quantitySelector == nil {
            
            let indexPath = self.tableView!.indexPath(for: cell)
            if indexPath == nil {
                return
            }
            
            var isPesable = false
            var price: NSNumber? = nil
            var quantity: NSNumber? = nil
          
            let item = self.detailItems![indexPath!.row]
            if let pesable = item["type"] as? NSString {
                isPesable = pesable.intValue == 1
            }
            price = item["price"] as? NSNumber
            quantity = item["quantity"] as? NSNumber
            
            let width:CGFloat = self.view.frame.width
            let height:CGFloat = (self.view.frame.height)
           
            let selectorFrame = CGRect(x: 0, y: self.view.frame.height, width: width, height: height)
            
            if isPesable {
                self.quantitySelector = GRShoppingCartWeightSelectorView(frame: selectorFrame, priceProduct: price,equivalenceByPiece:cell.equivalenceByPiece!,upcProduct:cell.upcVal!, isSearchProductView: false)
            } else {
                self.quantitySelector = GRShoppingCartQuantitySelectorView(frame: selectorFrame, priceProduct: price,upcProduct:cell.upcVal!)
                self.quantitySelector?.isFromList = true
            }
            
            if let orderByPiece = item["orderByPiece"] as? Bool {
                quantitySelector?.validateOrderByPiece(orderByPiece: orderByPiece, quantity: quantity!.doubleValue, pieces: 0)
                quantitySelector?.userSelectValue(quantity!.stringValue)
            } else {
                quantitySelector?.first = true
                quantitySelector?.userSelectValue(quantity!.stringValue)
                
            }
            
            self.view.addSubview(self.quantitySelector!)
            self.quantitySelector!.closeAction = { () in
                self.removeSelector()
            }
            
         //   self.quantitySelector!.generateBlurImage(self.view, frame:CGRect(x: 0.0, y: 0.0, width: width, height: height))
           
            self.quantitySelector!.addToCartAction = { (quantity:String) in
                var item = self.detailItems![indexPath!.row]
                //var upc = item["upc"] as? String
                item["quantity"] = NSNumber(value: Int(quantity)! as Int)
                item["orderByPiece"] = self.quantitySelector!.orderByPiece
                self.detailItems![indexPath!.row] = item
                self.tableView?.reloadData()
                self.removeSelector()
                self.updateTotalLabel()
                //TODO: Update quantity
            }
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.quantitySelector!.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            })
            
        }
        else {
            self.removeSelector()
        }
    }
    
    func removeSelector() {
        if   self.quantitySelector != nil {
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    let width:CGFloat = self.view.frame.width
                    let height:CGFloat = self.view.frame.height - self.header!.frame.height
                    self.quantitySelector!.frame = CGRect(x: 0.0, y: self.view.frame.height, width: width, height: height)
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

    
    func didDisable(_ disaable:Bool, cell:DetailListViewCell) {
        let indexPath = self.tableView?.indexPath(for: cell)
        if disaable {
            self.selectedItems?.remove(indexPath!.row)
        } else {
            self.selectedItems?.add(indexPath!.row)
        }
        self.updateTotalLabel()
    }
    
    
    //MARK: Actions
    
    func shareList() {
      let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.header!.frame.width, height: 70.0))
      let image = UIImage(named: "detail_HeaderMail")
      imageView.image = image
      let imageHead = UIImage(from: imageView) //(named:"detail_HeaderMail") //
        self.backButton?.isHidden = true
        let headerCapture = UIImage(from: header)
        self.backButton?.isHidden = false
        
        if let image = self.tableView!.screenshot() {
            let imgResult = UIImage.verticalImage(from: [imageHead!, headerCapture!, image])
            
            let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx")
            
            let controller = UIActivityViewController(activityItems: [self, imgResult, urlWmart!], applicationActivities: nil)
            self.navigationController?.present(controller, animated: true, completion: nil)
            
            controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        }
    }
    
    //MARK: activityViewControllerDelegate
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any{
        return "Walmart"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        
     
       let environment =  Bundle.main.object(forInfoDictionaryKey: "WMEnvironment") as! String
        var dominio = "https://www.walmart.com.mx"
        if environment != "PRODUCTION"{
//            dominio = "http://192.168.43.192:8085"
            dominio = "http://192.168.43.192:8095"
        }
        var urlss  = ""
        if self.lineId != nil {
            let name  = self.schoolName!.replacingOccurrences(of: " ", with: "-")
            let desc = self.gradeName!.replacingOccurrences(of: " ", with: "-")
            let namelines = self.nameLine!.replacingOccurrences(of: " ", with: "-")
            
            var  appLink  = UserCurrentSession.urlWithRootPath("\(dominio)/images/m_webParts/banners/Carrusel/linkbts.html?os=1&idLine=\(self.lineId! as String)&nameLine=\(namelines)&name_\(name)&description=\(desc)")
            
            appLink = "\(dominio)/images/m_webParts/banners/Carrusel/linkbts.html?os=1&idLine=\(self.lineId! as String)&nameLine=\(namelines)&name=\(name)&description=\(desc)"
            
            //appLink = "walmartmexicoapp://bussines_mg&type_LIST&value_\(self.lineId! as String)&name_\(name)&description_\(desc)"
            
            urlss = "\n Entra a la aplicación:\n \(appLink!)"
        }
      
        
        if activityType == UIActivityType.mail {
            return "Hola, encontré estos productos en Walmart.¡Te los recomiendo! \n \n Siempre encuentra todo y pagas menos.\(urlss)"
        }else if activityType == UIActivityType.postToTwitter ||  activityType == UIActivityType.postToVimeo ||  activityType == UIActivityType.postToFacebook  {
            return "Checa esta lista de productos:  #walmartapp #wow "
        }
        return "Checa esta lista de productos: \(urlss) "
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        if activityType == UIActivityType.mail {
            if UserCurrentSession.sharedInstance.userSigned == nil {
                return "Encontré estos productos te pueden interesar en www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance.userSigned!.profile.name) encontró unos productos que te pueden interesar en www.walmart.com.mx"
            }
        }
        return ""
    }
    //-----
    
    func buildImageToShare() -> UIImage? {
        
        
        self.tableView!.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
        
        self.isSharing = true
        let oldFrame : CGRect = self.tableView!.frame
        var frame : CGRect = self.tableView!.frame
        frame.size.height = self.tableView!.contentSize.height + 50.0
        self.tableView!.frame = frame
        
        UIGraphicsBeginImageContextWithOptions(self.tableView!.bounds.size, false, 2.0)
        self.tableView!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let saveImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
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
            
            var upcs: [Any] = []
            var totalPrice: Int = 0
            
            for idxVal  in selectedItems! {
                let idx = idxVal as! Int
                var params: [String:Any] = [:]
                let item = self.detailItems![idx]
                params["upc"] = item["upc"] as! String
                params["desc"] = item["description"] as! String
                params["imgUrl"] = item["imageUrl"] as! String
                if let price = item["price"] as? NSNumber {
                    totalPrice += price as Int
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
                params["orderByPiece"] = item["baseUomcd"] as? NSString == "EA"
                
                upcs.append(params as AnyObject)
            }
            if upcs.count > 0 {
                NotificationCenter.default.post(name: .addItemsToShopingCart, object: self, userInfo: ["allitems":upcs, "image":"list_alert_addToCart"])
                BaseController.sendAnalyticsProductsToCart(totalPrice)
            }else{
                self.noProductsAvailableAlert()
                return
            }
        }else{
            self.noProductsAvailableAlert()
            return
        }
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ADD_ALL_TO_SHOPPING_CART.rawValue, label: self.defaultListName!)
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
        
        let fmtTotal = CurrencyCustomLabel.formatString("\(total)" as NSString)
        let amount = String(format: NSLocalizedString("list.detail.buy",comment:""), fmtTotal)
        self.customLabel!.updateMount(amount, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.white, interLine: false)
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
                    count += quantity.intValue
                }
                else {
                    count += 1
                }
            }
        }
        return count
    }

    func duplicate() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DUPLICATE_LIST.rawValue, label: self.defaultListName!)
        self.invokeSaveListToDuplicateService(defaultListName!, successDuplicateList: { () -> Void in
            self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
            self.alertView!.showDoneIcon()
        })
    }
    
    func invokeSaveListToDuplicateService(_ listName:String,successDuplicateList:@escaping (() -> Void)) {
        
        alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.copy.inProcess", comment:""))
        let service = GRUserListService()
        if UserCurrentSession.sharedInstance.userSigned != nil {
            
            service.callService([:], successBlock: { (result:[String:Any]) -> Void in
                
                let  itemsUserList = result["responseArray"] as? [Any]
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
    
    func copyList(_ listName:String,itemsUserList:[Any]?,successDuplicateList:@escaping (() -> Void)) {
        let service = GRSaveUserListService()
        var items: [Any] = []
        if self.detailItems != nil {
            for idx in 0 ..< self.detailItems!.count {
                var product = self.detailItems![idx]
                let quantity = product["quantity"] as! NSNumber
                let imageUrl = product["imageUrl"] as! String
                let price = product["price"] as! NSNumber
                let dsc = product["description"] as! String
                let type = product["type"] as! String
                let baseUomcd = product["baseUomcd"] as! String
                let equivalenceByPiece =  product["equivalenceByPiece"] as? String == "" ? "0" : product["equivalenceByPiece"] as? String
                let stock = product["stock"] as? Bool ?? true
              
                if let upc = product["upc"] as? String {
                    let item = service.buildProductObject(upc: upc, quantity: quantity.intValue, image: imageUrl, description: dsc, price: price.stringValue, type:type,baseUomcd:baseUomcd,equivalenceByPiece: NSNumber(value:Int(equivalenceByPiece!)!),stock:stock )
                    items.append(item as AnyObject)
                    
                    // 360 Event
                    BaseController.sendAnalyticsProductToList(upc, desc: dsc, price: "\(price as Int)")
                }
            }
        }
        
        let copyName = self.buildDuplicateNameList(listName, forListId: "",itemsUserList:itemsUserList)
        //if copyName.length() > 25 {
          //  copyName = (copyName as NSString).substring(to: 24)
        //}
        service.callService(service.buildParams(copyName, items: items),
            successBlock: { (result:[String:Any]) -> Void in
                successDuplicateList()
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at duplicate list")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
            }
        )
    }
    
    func buildDuplicateNameList(_ theName:String, forListId listId:String?,itemsUserList:[Any]?) -> String {
     
        
        var listName = "\(theName)" //Se crea una nueva instancia
        let whitespaceset = CharacterSet.whitespaces
        var arrayOfIndex: [Int] = []
        if let range = listName.range(of: "copia", options: .literal, range: nil, locale: nil) {
            listName = listName.substring(to: range.lowerBound)
        }
        listName = listName.trimmingCharacters(in: whitespaceset)
        if itemsUserList != nil {
            if itemsUserList!.count > 0 {
                for idx in 0 ..< itemsUserList!.count {
                    var name:String? = nil
                    var stringIndex: String? = nil
                    if let innerList = itemsUserList![idx] as? [String:Any] {
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
                        if let range = name!.range(of: "copia", options: .literal, range: nil, locale: nil) {
                            stringIndex = name!.substring(from: range.upperBound)
                            name = name!.substring(to: range.lowerBound)
                        }
                        name = name!.trimmingCharacters(in: whitespaceset)
                        if stringIndex != nil {
                            stringIndex = stringIndex!.trimmingCharacters(in: whitespaceset)
                            if name!.hasPrefix(listName) {
                                stringIndex = stringIndex! == "" ? "1" : stringIndex
                              if stringIndex!.isNumeric() {
                                arrayOfIndex.append(Int(stringIndex!)!)
                              }
                            }
                        }
                    }
                }
            }
        }
        let listIndexes = Set([1,2,3,4,5,6,7,8,9,10,11,12,13])
        let dispinibleIndex = listIndexes.subtracting(arrayOfIndex).min()
        var idxTxt = dispinibleIndex == 1 ? "copia" : "copia \(dispinibleIndex!)"
        
        if self.findListindb("\(listName) \(idxTxt)") {
            idxTxt = "copia \(dispinibleIndex! + 1)"
        }
        
        let returnName =  "\(listName) \(idxTxt)"
       /* if returnName.length() > 25 {
            returnName = (returnName as NSString).substring(to: 24)
            returnName = "\(returnName)\(dispinibleIndex!)"
        }*/
        
        return returnName
        
        
    }
    
    func findListindb(_ newNameList:String) -> Bool{
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let service =  GRSaveUserListService()
        let localList =  service.retrieveListNotSync(name: newNameList, inContext:context)
        
        return localList != nil//true no exsite
        
    }

}

extension DefaultListDetailViewController: UIViewControllerPreviewingDelegate {
    //registerForPreviewingWithDelegate
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView?.indexPathForRow(at: location) {
            //This will show the cell clearly and blur the rest of the screen for our peek.
            if #available(iOS 9.0, *) {
                previewingContext.sourceRect = tableView!.rectForRow(at: indexPath)
            }
            return self.getDetailController(indexPath:indexPath)
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController!.pushViewController(viewControllerToCommit, animated: true)
        //present(viewControllerToCommit, animated: true, completion: nil)
    }
}

extension DefaultListDetailViewController: UIGestureRecognizerDelegate {
    
    func addLongTouch(view:UIView) {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(DefaultListDetailViewController.handleLongPress(gestureReconizer:)))
        longPressGesture.minimumPressDuration = 0.6 // 1 second press
        longPressGesture.allowableMovement = 15 // 15 points
        longPressGesture.delegate = self
        view.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        
        let p = gestureReconizer.location(in: self.tableView)
        let indexPath = tableView!.indexPathForRow(at: p)
        
        if let viewControllerToCommit = self.getDetailController(indexPath: indexPath!) {
            viewControllerToCommit.view.frame.size = CGSize(width: self.view.frame.width - 20, height: self.view.frame.height - 45)
            
            if self.preview == nil {
                let cellFrame =  tableView!.rectForRow(at: indexPath!)
                let cellFrameInSuperview = tableView!.convert(cellFrame, to: tableView!.superview)
                self.preview = PreviewModalView.initPreviewModal(viewControllerToCommit.view)
                self.preview?.cellFrame = cellFrameInSuperview
            }
            
            if gestureReconizer.state == UIGestureRecognizerState.ended {
                self.preview?.closePicker()
                self.preview = nil
            }
            
            if gestureReconizer.state == UIGestureRecognizerState.began {
                if indexPath != nil {
                    self.preview?.showPreview()
                }
            }
        }
    }
}
