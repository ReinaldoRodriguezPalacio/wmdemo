//
//  IPAGRCategoriesViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/26/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class IPAGRCategoriesViewController :  NavigationViewController, UICollectionViewDataSource, UICollectionViewDelegate,IPAGRCategoryCollectionViewCellDelegate
{
    
    var items : [AnyObject]? = []
    @IBOutlet var colCategories : UICollectionView!
    var canfigData : [String:AnyObject]! = [:]
    var animateView : UIView!
    var controllerAnimateView : IPACategoriesResultViewController!
    var newModalView: AlertModalView? = nil
    var addressView: GRAddressView?
    var landingItem : [String:String]? = nil
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SUPER.rawValue
    }
    
    var pontInViewNuew = CGRectZero
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if UserCurrentSession.hasLoggedUser() {
           self.setStoreName()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton?.hidden = true
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.titleLabel?.text = NSLocalizedString("profile.default.store", comment: "")
        self.titleLabel?.textAlignment = .Center
        
        colCategories.backgroundColor = WMColor.light_light_gray
        
        loadDepartments()
        
        let svcConfig = ConfigService()
        canfigData = svcConfig.getConfoigContent()
        colCategories.registerClass(IPACategoryCollectionViewClass.self, forCellWithReuseIdentifier: "cellLanding")
        
        let serviceBanner = BannerService()
        if let landingUse = serviceBanner.getLanding() {
            if landingUse.count > 0 {
                for landing in landingUse {
                    let landingType = landing["type"]
                    if landingType != nil && landingType! == "groceries" {
                        landingItem = landing
                    }
                }
            }
        }
    }
    
    func loadDepartments() -> [AnyObject]? {
        let serviceCategory = CategoryService()
        self.items = serviceCategory.getCategoriesContent(from: "gr")
        colCategories.delegate = self
        colCategories.dataSource = self
        return self.items
    }
    
    //MARK: - collectionViewDelegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return ((landingItem != nil) ? 2: 1)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (landingItem != nil && section == 0) {
            return 1
        }
        return self.items!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 && landingItem != nil  {
            let cellLanding = colCategories.dequeueReusableCellWithReuseIdentifier("cellLanding", forIndexPath: indexPath) as! IPACategoryCollectionViewClass
            let itemBannerPhone = landingItem!["bannerUrlTablet"]
            cellLanding.setValuesLanding("https://\(itemBannerPhone!)")
            return cellLanding
        }
        
        let cell = colCategories.dequeueReusableCellWithReuseIdentifier("cellCategory", forIndexPath: indexPath) as! IPAGRCategoryCollectionViewCell
        cell.delegate =  self // new 
        cell.index = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)
        
        let item = items![indexPath.row] as! [String:AnyObject]
        let descDepartment = item["DepartmentName"] as! String
        var bgDepartment = item["idDept"] as! String
        let families = JSON(item["familyContent"] as! [[String:AnyObject]])
        cell.descLabel!.text = "Lo más destacado de \(descDepartment)"
        bgDepartment = bgDepartment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        
        if let resultProducts = fillConfigData(bgDepartment,families:families) {
            cell.setValues(bgDepartment, categoryTitle: descDepartment,products:resultProducts)
        }else {
            cell.setValues(bgDepartment, categoryTitle: descDepartment)
        }
        return cell
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        if landingItem != nil && indexPath.section == 0 {
            return CGSizeMake(self.view.frame.width - 32, 216)
        }
        return  CGSizeMake(488,313)
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0  && landingItem != nil  {
            let eventUrl = landingItem!["eventUrl"]
            self.handleLandingEvent(eventUrl!)
            return
        }
        
        let cellSelected = collectionView.cellForItemAtIndexPath(indexPath) as! IPAGRCategoryCollectionViewCell!
        let pontInView = cellSelected.superview!.convertRect(cellSelected!.frame, toView: self.view)
        pontInViewNuew = pontInView

        let item = self.items![indexPath.row] as! [String:AnyObject]
        let idDepartment = item["idDept"] as! String
        let famArray : AnyObject = item["familyContent"] as AnyObject!
        let itemsFam : [[String:AnyObject]] = famArray as! [[String:AnyObject]]
        let famSelected = itemsFam[0]
        let idFamDefault = famSelected["familyId"] as! String
        
        let lineArray : AnyObject = famSelected["fineContent"] as AnyObject!
        let itemsLine : [[String:AnyObject]] = lineArray as! [[String:AnyObject]]
        let lineSelected = itemsLine[0]
        let idLineDefault = lineSelected["id"] as! String
        let nameLineDefault = lineSelected["displayName"] as! String
        
        CategoryShouldShowFamily.shouldshowfamily = true
        controllerAnimateView = IPACategoriesResultViewController()
        controllerAnimateView.setValues(idDepartment, family: idFamDefault, line: idLineDefault, name:nameLineDefault)
        
        NSLog("%@", (idDepartment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString))
        
        controllerAnimateView.frameStart = CGRectMake(cellSelected.frame.minX, 0, 330, 216)
        controllerAnimateView.frameEnd = self.view.bounds
        controllerAnimateView.titleStr = cellSelected.buttonDepartment.titleLabel!.text
        controllerAnimateView.families = itemsFam
        controllerAnimateView.name = nameLineDefault
        controllerAnimateView.searchContextType = SearchServiceContextType.WithCategoryForGR
        controllerAnimateView.closeAnimated = false
        
        controllerAnimateView.actionClose = {() in
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.controllerAnimateView.view.alpha = 0
                }, completion: { (complete:Bool) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.animateView.frame =  pontInView
                        self.animateView.alpha = 0
                        }, completion: { (complete:Bool) -> Void in
                            self.animateView.removeFromSuperview()
                            self.controllerAnimateView = nil
                    })
            })
            
            
        }
        
        self.addChildViewController(controllerAnimateView)
        self.view.addSubview(controllerAnimateView.view)
        
        animateView = UIView(frame: pontInView)
        animateView.backgroundColor = UIColor.whiteColor()
        animateView.alpha = 0
        controllerAnimateView.view.alpha = 0
        self.view.addSubview(animateView)
        self.animateView.addSubview(controllerAnimateView.view)
        self.controllerAnimateView.searchProduct.imageBgCategory = cellSelected.imageBackground.image
        self.controllerAnimateView.searchProduct.imageIconCategory = cellSelected.iconCategory.image
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
             self.animateView.alpha = 1
            }) { (complete:Bool) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.animateView.frame = self.view.bounds
                    }, completion: { (complete:Bool) -> Void in
                        
                        if self.controllerAnimateView.searchProduct != nil {
                            self.controllerAnimateView.searchProduct.view.frame = CGRectMake(0, 0,  self.controllerAnimateView.frameEnd.width,  self.controllerAnimateView.frameEnd.height)
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                self.controllerAnimateView.searchProduct.view.alpha = 1
                                }) { (complete:Bool) -> Void in
                                    if self.controllerAnimateView.viewImageContent != nil {
                                        self.controllerAnimateView.addPopover()
                                    }
                            }
                        }

                        
                        
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.controllerAnimateView.view.alpha = 1
                    })
                })
            
        }
        
    }
 
    
    func didTapProduct(upcProduct: String, descProduct: String,imageProduct :UIImageView) {
        

        let controller = IPAProductDetailPageViewController()
        
        controller.itemsToShow = [["upc":upcProduct,"description":descProduct,"type":ResultObjectType.Groceries.rawValue]]
        controller.animationController = ProductDetailNavigatinAnimationController(nav:self.navigationController!)
        controller.animationController.setImage(imageProduct.image!)
        pontInViewNuew = imageProduct.superview!.convertRect(imageProduct.frame, toView: self.view)
        
        controller.animationController.originPoint =  pontInViewNuew
        self.navigationController?.delegate = controller
        self.navigationController?.pushViewController(controller, animated: true)

    }
   
    
    func fillConfigData(depto:String,families:JSON) -> [[String:AnyObject]]? {
        var resultDict : [AnyObject] = []
        if Array(canfigData.keys.filter {$0 == depto }).count > 0 {
            let linesToShow = JSON(canfigData[depto] as! [[String:String]])
            for lineDest in linesToShow.arrayValue {
                for family in families.arrayValue {
                    for line in family["fineContent"].arrayValue {
                        let lineOne = line["fineLineId"].stringValue
                        let lineTwo = lineDest["line"].stringValue
                        if lineOne.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                            == lineTwo.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
                                let itemToShow = ["fineLineName": line["fineLineName"].stringValue,
                                    "imageUrl": lineDest["imageUrl"].stringValue,
                                    "line": lineTwo ,
                                    "family": family["id"].stringValue ,
                                    "department":depto]
                                resultDict.append(itemToShow)
                                
                        }
                    }
                }
            }
        }
        
        return resultDict as? [[String:AnyObject]]
    }
    
    func didTapLine(name:String,department:String,family:String,line:String) {
        let controller = IPASearchProductViewController()
        controller.searchContextType = SearchServiceContextType.WithCategoryForGR
        controller.idFamily  = family
        controller.idDepartment = department
        controller.idLine = line
        controller.titleHeader = name
        controller.searchFromContextType = SearchServiceFromContext.FromLineSearch
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapMore(index:NSIndexPath) {
        self.colCategories.delegate?.collectionView!(colCategories, didSelectItemAtIndexPath: index)
    }
    
    func handleLandingEvent(strAction:String) {
        var components = strAction.componentsSeparatedByString("_")
        if(components.count > 1){
            let window = UIApplication.sharedApplication().keyWindow
            if let customBar = window!.rootViewController as? IPACustomBarViewController {
                let cmpStr  = components[0] as String
                let strValue = strAction.stringByReplacingOccurrencesOfString("\(cmpStr)_", withString: "")
                var strAction = ""
                switch components[0] {
                case "f":
                    strAction =  "FAM"
                case "c":
                    strAction =  "CAT"
                case "l":
                    strAction =  "LIN"
                case "UPC":
                    strAction =  "UPC"
                default:
                    return
                }
                
                
                customBar.handleNotification(strAction,name:"",value:strValue,bussines:"gr")
            }
        }
    }
    
    //MARK changeStore
    func changeStore(){
        if titleLabel!.text! == NSLocalizedString("profile.default.store", comment: "")  && UserCurrentSession.sharedInstance().addressId == nil{
            let noAddressView = AddressNoStoreView(frame: CGRectMake(0,0,338,210))
            noAddressView.newAdressForm = { void in
                let addAddress = GRAddAddressView(frame: CGRectMake(0,49,338,self.view.frame.height - 90))
                addAddress.addressArray = []
                addAddress.onClose = {void in
                    self.newModalView!.closePicker()
                    self.setStoreName()
                }
                self.newModalView!.resizeViewContent(NSLocalizedString("gr.address.title", comment: ""),view: addAddress)
            }
            self.newModalView = AlertModalView.initModalWithView(NSLocalizedString("gr.category.view.inventory", comment: ""), innerView: noAddressView)
            self.newModalView!.showPicker()
        }else{
            self.addressView = GRAddressView(frame: CGRectMake(0,0,338,365))
            self.addressView?.onCloseAddressView = {void in self.newModalView!.closePicker()}
            self.addressView?.newAdressForm = { void in
                let addAddress = GRAddAddressView(frame: CGRectMake(0,49,338,self.view.frame.height - 90))
                addAddress.addressArray = self.addressView!.addressArray
                addAddress.onClose = {void in
                    self.newModalView!.closePicker()
                    self.setStoreName()
                }
                self.newModalView!.resizeViewContent(NSLocalizedString("gr.address.title", comment: ""),view: addAddress)
            }
            
            self.addressView?.addressSelected = {(addressId:String,addressName:String,selectedStore:String,stores:[NSDictionary]) in
                let minViewHeigth : CGFloat = (1.5 * 46.0) + 67.0
                var storeViewHeight: CGFloat = (CGFloat(stores.count) * 46.0) + 67.0
                storeViewHeight = max(minViewHeigth,storeViewHeight)
                let storeView = GRAddressStoreView(frame: CGRectMake(0,49,338,min(storeViewHeight,270)))
                storeView.selectedstoreId = selectedStore
                storeView.storeArray = stores
                storeView.addressId = addressId
                storeView.onClose = {void in
                    self.newModalView!.closePicker()
                    self.setStoreName()
                }
                storeView.onReturn = {void in
                    self.addressView!.blockRows = false
                    self.newModalView!.closeNew()
                }
                self.newModalView!.resizeViewContent("\(NSLocalizedString("gr.category.title", comment: "")) \(addressName)",view: storeView)
            }
            self.newModalView = AlertModalView.initModalWithView(NSLocalizedString("profile.view.inventory", comment: ""), innerView: addressView!)
            self.newModalView!.onReturnPicker = { void in
                self.addressView!.blockRows = false
            }
            self.newModalView!.showPicker()
        }
    }
    
    func setStoreName(){
        if UserCurrentSession.sharedInstance().storeName != nil {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "arrow")
            let attachmentString = NSAttributedString(attachment: attachment)
            let attrs = [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(14)]
            var boldString = NSMutableAttributedString(string:"Walmart \(UserCurrentSession.sharedInstance().storeName!.capitalizedString)  ", attributes:attrs)
            if UserCurrentSession.sharedInstance().storeName == "" {
                boldString = NSMutableAttributedString(string:NSLocalizedString("profile.default.store", comment: ""), attributes:attrs)
            }
            boldString.appendAttributedString(attachmentString)
            self.titleLabel?.numberOfLines = 2;
            self.titleLabel?.attributedText = boldString;
            self.titleLabel?.userInteractionEnabled = true;
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(IPAGRCategoriesViewController.changeStore))
            self.titleLabel?.addGestureRecognizer(tapGesture)
            self.titleLabel!.frame = CGRectMake(0, 0, self.header!.frame.width, self.header!.frame.maxY)
        }else{
            self.titleLabel?.text = NSLocalizedString("profile.default.store", comment: "")
            self.titleLabel!.frame = CGRectMake(0, 0, self.header!.frame.width, self.header!.frame.maxY)
        }
        
    }


}