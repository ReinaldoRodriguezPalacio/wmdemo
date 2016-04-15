//
//  IPOGRCategoriesViewController.swift
//  WalMart
//
//  Created by neftali on 22/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class IPOGRCategoriesViewController: NavigationViewController, UITableViewDataSource,UITableViewDelegate,IPOGRDepartmentSpecialTableViewCellDelegate {

    let CELL_HEIGHT : CGFloat = 98
    var viewFamily: UIView!

    @IBOutlet var categoriesTable : UITableView!
    var items : [AnyObject]? = []
    var collapsed = false
    var familyController : FamilyViewController!
    var canfigData : [String:AnyObject]! = [:]
    var newModalView: AlertModalView? = nil
    var addressView: GRAddressView?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PRESHOPPINGCART.rawValue
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if UserCurrentSession.hasLoggedUser() {
            self.setStoreName()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.categoriesTable.registerClass(IPOGRDepartmentSpecialTableViewCell.self, forCellReuseIdentifier: "cellspecials")
        self.categoriesTable.separatorStyle = .None

        
        let buttonCollapse = UIButton(frame: CGRectMake(self.view.frame.width - 69, 10, 72, 24))
        let imageCheckBlue = UIImage(named:"check_blue")
        buttonCollapse.setImage(imageCheckBlue, forState: UIControlState.Normal)
        buttonCollapse.setImage(UIImage(named:"check_blue_empty"), forState: UIControlState.Selected)
        buttonCollapse.setTitle(NSLocalizedString("gr.category.especiales",comment:""), forState: UIControlState.Normal)
        buttonCollapse.setTitle(NSLocalizedString("gr.category.especiales",comment:""), forState: UIControlState.Selected)
        buttonCollapse.addTarget(self, action: "collapse:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonCollapse.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        buttonCollapse.titleLabel!.textColor = WMColor.light_blue
        buttonCollapse.setTitleColor(WMColor.light_blue, forState: UIControlState.Normal)
        buttonCollapse.titleEdgeInsets = UIEdgeInsetsMake(2.0,-72, 0.0, 0.0);
        buttonCollapse.imageEdgeInsets = UIEdgeInsetsMake(2.0,40, 0.0, 0.0);
        buttonCollapse.layer.cornerRadius = 2
        
        self.header?.addSubview(buttonCollapse)
        
        self.titleLabel?.text = "Walmart Buenavista"
        self.titleLabel?.textAlignment = .Left
        
        self.viewFamily = UIView()
        self.viewFamily.backgroundColor = UIColor.whiteColor()
        
        self.familyController = FamilyViewController()
        self.familyController.categoriesType = .CategoryForGR
        self.addChildViewController(self.familyController)
        self.viewFamily.addSubview(self.familyController.view)
        
        
        loadDepartments()

        
        let svcConfig = ConfigService()
        canfigData = svcConfig.getConfoigContent()
    }
    
    override func setup() {
        self.hiddenBack = true
        super.setup()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewFamily.frame = CGRectMake(0, CELL_HEIGHT, self.view.bounds.width, self.view.bounds.height - CELL_HEIGHT)
        familyController.view.frame = viewFamily.bounds
        self.titleLabel!.frame = CGRectMake(10, 0, self.header!.frame.width - 110, self.header!.frame.maxY)
    }
    
    func loadDepartments() -> [AnyObject]? {
        let serviceCategory = GRCategoryService()
        self.items = serviceCategory.getCategoriesContent()
        return self.items
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if collapsed {
            return self.items!.count
        }
        return self.items!.count * 2
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        if indexPath.row % 2 == 0 || collapsed {
            let cellDept = tableView.dequeueReusableCellWithIdentifier("celldepartment", forIndexPath: indexPath) as! GRDepartmentTableViewCell
            var rowforsearch = indexPath.row
            if !collapsed {
                rowforsearch = Int(indexPath.row / 2)
            }
            
            let item = items![rowforsearch] as! [String:AnyObject]
            let descDepartment = item["description"] as! String
            let bgDepartment = (item["idDepto"] as! String).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let scale = UIScreen.mainScreen().scale
            
            cellDept.setValues(descDepartment,imageBackgroundURL:bgDepartment + "@\(Int(scale))x.jpg",imageIconURL:"i_" + bgDepartment + ".@\(Int(scale))x.png")
            cell = cellDept

        } else {
            let cellSpecials = tableView.dequeueReusableCellWithIdentifier("cellspecials", forIndexPath: indexPath) as! IPOGRDepartmentSpecialTableViewCell
            cellSpecials.delegate = self
            
            let rowforsearch = Int(indexPath.row / 2)
            let item = items![rowforsearch] as! [String:AnyObject]
            var bgDepartment = item["idDepto"] as! String
            let families = JSON(item["family"] as! [[String:AnyObject]])
            bgDepartment = bgDepartment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            
            if let resultProducts = fillConfigData(bgDepartment,families:families) {
                cellSpecials.setLines(resultProducts,width:79,index:indexPath)
            }else {
                cellSpecials.withOutProducts()
            }
            
            cell = cellSpecials
            
        }

        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 || collapsed {
            return 102
        }else {
            return 125
        }
    }
    
    
    func collapse(sender:UIButton) {
        sender.selected = !sender.selected
        self.collapsed = !self.collapsed
        if self.collapsed{
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SUPER.rawValue, action: WMGAIUtils.ACTION_HIDE_HIGHLIGHTS.rawValue, label: "")
        }
        self.categoriesTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.categoriesTable.contentInset = UIEdgeInsetsMake(0, 0, self.categoriesTable.frame.height, 0)
        var rowforsearch = indexPath.row
        var newIndex = indexPath
        
        if !(indexPath.row % 2 == 0) && !self.collapsed {
            rowforsearch = indexPath.row - 1
            newIndex = NSIndexPath(forRow:  indexPath.row - 1, inSection: indexPath.section)
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            //self.categoriesTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            self.categoriesTable.scrollToRowAtIndexPath(newIndex, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            }) { (complete:Bool) -> Void in
            //Open Family
               // self.familyController.view.hidden = false
                if rowforsearch % 2 == 0 || self.collapsed {
                    
                    
                    if !self.collapsed {
                        rowforsearch = Int(indexPath.row / 2)
                    }
                    
                    let item = self.items![rowforsearch] as! [String:AnyObject]
                    let famArray : AnyObject = item["family"] as AnyObject!
                    let itemsFam : [[String:AnyObject]] = famArray as! [[String:AnyObject]]
                    let descDepartment = item["description"] as? String
                   
                    self.familyController.departmentId = item["idDepto"] as! String
                    self.familyController.families = itemsFam
                    self.familyController.selectedFamily = nil
                    self.familyController.familyTable.reloadData()
                    
                    let icon = "i_\(self.familyController.departmentId)"
                    let caHeader = self.familyController.departmentId.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    let newView = IPODepartmentCollectionViewCell(frame:CGRectMake(0, 0, self.view.frame.width, self.CELL_HEIGHT))
                    newView.isOpen = true
                    newView.setValues(descDepartment!, imageBackgroundURL: "\(caHeader).png", keyBgUrl: "WalmartMG.GRHeaderCategory", imageIconURL: icon, keyIconUrl: "WalmartMG.GRCategoryIcon", hideImage: false)
                   newView.customCloseDep = true
                    
                    newView.imageBackground.alpha = 0
                    newView.buttonClose.alpha = 0
                    newView.imageIcon.alpha = 0


                    self.view.addSubview(newView)
                    
                    newView.onclose = {() in
                        print("Close")
                        
                        if self.collapsed {
                            
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                
                                newView.imageBackground.alpha = 0
                                newView.imageIcon.alpha = 0
                                newView.buttonClose.alpha = 0
                                self.viewFamily.alpha = 0
                                
                                }, completion: { (complete:Bool) -> Void in
                                    
                                    newView.removeFromSuperview()
                                    self.categoriesTable.contentInset = UIEdgeInsetsZero

                            })
                            
                        } else {
                        
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                
                                newView.imageBackground.alpha = 0
                                newView.imageIcon.alpha = 0
                                newView.buttonClose.alpha = 0
                                self.viewFamily.alpha = 0
                                
                                }, completion: { (complete:Bool) -> Void in
                                    
                                    newView.removeFromSuperview()
                                    self.categoriesTable.contentInset = UIEdgeInsetsZero
                                    
                            })
                        }
                        BaseController.sendAnalytics(WMGAIUtils.GR_CATEGORY_ACCESSORY_AUTH.rawValue, categoryNoAuth: WMGAIUtils.GR_CATEGORY_ACCESSORY_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_CANCEL.rawValue, label: "")
                    }
                    
                    newView.startFrame = newView.bounds
                    newView.imageBackground.frame = newView.bounds
                    newView.imageIcon.frame = CGRectMake((newView.bounds.width / 2) - 14,  newView.imageIcon.frame.minY ,  newView.imageIcon.frame.width,  newView.imageIcon.frame.height)
                    newView.buttonClose.frame = CGRectMake(0, 0, 40, 40)
                    newView.buttonClose.alpha = 0
                    newView.imageBackground.alpha = 0
                    newView.imageIcon.alpha = 0
                    
                    newView.addGestureTiImage()

                    newView.titleLabel.attributedText!.boundingRectWithSize(CGSizeMake(self.view.frame.width, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                    
                    //newView.titleLabel.frame = CGRectMake(46, newView.titleLabel.frame.minY, rectSize.width, newView.titleLabel.frame.height)
                    newView.titleLabel.frame = CGRectMake((newView.bounds.width / 2) - (newView.titleLabel.frame.width / 2), newView.titleLabel.frame.minY, newView.titleLabel.frame.width, newView.titleLabel.frame.height)
                    self.viewFamily.alpha = 0
                    
                    self.familyController.familyTable.reloadData()
                    self.view.addSubview(self.viewFamily)
                    
                    
                    if self.collapsed {
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            newView.titleLabel.textColor = UIColor.whiteColor()
                            self.viewFamily.alpha = 1
                            newView.imageBackground.alpha = 1
                            newView.imageIcon.alpha = 1
                            newView.buttonClose.alpha = 1
                            newView.alpha = 1
                                    
                        })
                    } else {
                    
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            newView.titleLabel.textColor = UIColor.whiteColor()
                            self.viewFamily.alpha = 1
                            newView.imageBackground.alpha = 1
                            newView.imageIcon.alpha = 1
                            newView.buttonClose.alpha = 1
                            newView.alpha = 1
                            
                        })
                    }
                    //EVENT
                    let label = item["description"] as! String
                    let labelCategory = label.uppercaseString.stringByReplacingOccurrencesOfString(" ", withString: "_")
                    BaseController.sendAnalytics("GR_\(labelCategory)_VIEW_AUTH", categoryNoAuth: "GR_\(labelCategory)_VIEW_NO_AUTH", action: WMGAIUtils.ACTION_SHOW_FAMILIES.rawValue, label: label)
                    print("End")
                    self.view.addSubview(newView)
                }
                
        }
        
    }
    
    
    //MARK: Delegate
    
    func didTapLine(name:String,department:String,family:String,line:String) {
        
        let controller = SearchProductViewController()
        controller.searchContextType = .WithCategoryForGR
        
        controller.titleHeader = name
        controller.idDepartment = department
        controller.idFamily = family
        controller.idLine = line
        
        self.navigationController!.pushViewController(controller, animated: true)
        //EVENT
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SUPER.rawValue, action: WMGAIUtils.ACTION_VIEW_RECOMMENDED.rawValue, label: name)
    }

    
    func didTapProduct(upcProduct:String,descProduct:String){
        
    }
    
    func didTapMore(index: NSIndexPath) {
        self.tableView(self.categoriesTable, didSelectRowAtIndexPath: index)
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
    
    //MARK changeStore
    func changeStore(){
        if titleLabel!.text! == "Sin tienda ￼" && UserCurrentSession.sharedInstance().addressId == nil {
            let noAddressView = GRAddressNoStoreView(frame: CGRectMake(0,0,288,210))
            noAddressView.newAdressForm = { void in
                let addAddress = GRAddAddressView(frame: CGRectMake(0,49,288,self.view.frame.height - 90))
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
            self.addressView = GRAddressView(frame: CGRectMake(0,0,288,365))
            self.addressView?.onCloseAddressView = {void in self.newModalView!.closePicker()}
            self.addressView?.newAdressForm = { void in
                let addAddress = GRAddAddressView(frame: CGRectMake(0,49,288,self.view.frame.height - 90))
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
                let storeView = GRAddressStoreView(frame: CGRectMake(0,49,288,min(storeViewHeight,270)))
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
                self.newModalView!.resizeViewContent("Tiendas \(addressName)",view: storeView)
            }
            self.newModalView = AlertModalView.initModalWithView("Ver inventario de otra tienda", innerView: addressView!)
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
                 boldString = NSMutableAttributedString(string:"Sin tienda ", attributes:attrs)
            }
            boldString.appendAttributedString(attachmentString)
            self.titleLabel?.adjustsFontSizeToFitWidth = true
            self.titleLabel?.minimumScaleFactor = 0.2
            self.titleLabel?.numberOfLines = 1
            self.titleLabel?.attributedText = boldString;
            self.titleLabel?.userInteractionEnabled = true;
            let tapGesture = UITapGestureRecognizer(target: self, action: "changeStore")
            self.titleLabel?.addGestureRecognizer(tapGesture)
        }else{
            self.titleLabel?.text = "Walmart Buenavista"
        }
        
    }
}