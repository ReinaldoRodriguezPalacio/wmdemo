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
        self.titleLabel?.text = "Walmart Buenavista"
        self.titleLabel?.textAlignment = .Left
        
        colCategories.backgroundColor = WMColor.light_light_gray
        
        loadDepartments()
        
        let svcConfig = ConfigService()
        canfigData = svcConfig.getConfoigContent()
        
    }
    
    func loadDepartments() -> [AnyObject]? {
        let serviceCategory = GRCategoryService()
        self.items = serviceCategory.getCategoriesContent()
        colCategories.delegate = self
        colCategories.dataSource = self
        return self.items
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items!.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = colCategories.dequeueReusableCellWithReuseIdentifier("cellCategory", forIndexPath: indexPath) as! IPAGRCategoryCollectionViewCell
        cell.delegate =  self // new 
        cell.index = indexPath
        
        let item = items![indexPath.row] as! [String:AnyObject]
        let descDepartment = item["description"] as! String
        var bgDepartment = item["idDepto"] as! String
        let families = JSON(item["family"] as! [[String:AnyObject]])
        
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
        return  CGSizeMake(488,313)
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cellSelected = collectionView.cellForItemAtIndexPath(indexPath) as! IPAGRCategoryCollectionViewCell!
        let pontInView = cellSelected.superview!.convertRect(cellSelected!.frame, toView: self.view)
        pontInViewNuew = pontInView

        let item = self.items![indexPath.row] as! [String:AnyObject]
        let idDepartment = item["idDepto"] as! String
        let famArray : AnyObject = item["family"] as AnyObject!
        let itemsFam : [[String:AnyObject]] = famArray as! [[String:AnyObject]]
        let famSelected = itemsFam[0]
        let idFamDefault = famSelected["id"] as! String
        
        let lineArray : AnyObject = famSelected["line"] as AnyObject!
        let itemsLine : [[String:AnyObject]] = lineArray as! [[String:AnyObject]]
        let lineSelected = itemsLine[0]
        let idLineDefault = lineSelected["id"] as! String
        let nameLineDefault = lineSelected["name"] as! String
        
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
                    for line in family["line"].arrayValue {
                        let lineOne = line["id"].stringValue
                        let lineTwo = lineDest["line"].stringValue
                        if lineOne.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                            == lineTwo.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
                                let itemToShow = ["name": line["name"].stringValue,
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
    
    //MARK changeStore
    func changeStore(){
        if titleLabel!.text! == "Sin tienda ￼"{
            let noAddressView = GRAddressNoStoreView(frame: CGRectMake(0,0,338,210))
            noAddressView.newAdressForm = { void in
                let addAddress = GRAddAddressView(frame: CGRectMake(0,49,338,self.view.frame.height - 90))
                addAddress.addressArray = []
                addAddress.onClose = {void in
                    self.newModalView!.closePicker()
                    self.setStoreName()
                }
                self.newModalView!.resizeViewContent("Nueva Dirección",view: addAddress)
            }
            self.newModalView = AlertModalView.initModalWithView("Ver inventario de tienda", innerView: noAddressView)
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
                self.newModalView!.resizeViewContent("Nueva Dirección",view: addAddress)
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
                storeView.onReturn = {void in self.newModalView!.closeNew()}
                self.newModalView!.resizeViewContent("Tiendas \(addressName)",view: storeView)
            }
            self.newModalView = AlertModalView.initModalWithView("Ver inventario de otra tienda", innerView: addressView!)
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
                boldString = NSMutableAttributedString(string:"Sin tienda ", attributes:attrs)
            }
            boldString.appendAttributedString(attachmentString)
            self.titleLabel?.numberOfLines = 2;
            self.titleLabel?.attributedText = boldString;
            self.titleLabel?.textAlignment = .Left
            self.titleLabel?.userInteractionEnabled = true;
            let tapGesture = UITapGestureRecognizer(target: self, action: "changeStore")
            self.titleLabel?.addGestureRecognizer(tapGesture)
            self.titleLabel!.frame = CGRectMake(10, 0, self.header!.frame.width - 110, self.header!.frame.maxY)
        }else{
            self.titleLabel?.text = "Walmart Buenavista"
        }
        
    }


}