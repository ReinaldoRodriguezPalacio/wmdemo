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
    var landingItem : [String:String]? = nil

    @IBOutlet var categoriesTable : UITableView!
    var items : [Any]? = []
    var collapsed = false
    var familyController : FamilyViewController!
    var canfigData : [String:Any]! = [:]
    var newModalView: AlertModalView? = nil
    var addressView: GRAddressView?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PRESHOPPINGCART.rawValue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserCurrentSession.hasLoggedUser() {
            self.setStoreName()
        }
    }
    
    override func viewDidLoad() {
        
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
        
        super.viewDidLoad()

        self.categoriesTable.register(IPOGRDepartmentSpecialTableViewCell.self, forCellReuseIdentifier: "cellspecials")
        self.categoriesTable.separatorStyle = .none

        
        let buttonCollapse = UIButton(frame: CGRect(x: self.view.frame.width - 69, y: 10, width: 72, height: 24))
        let imageCheckBlue = UIImage(named:"check_blue")
        buttonCollapse.setImage(imageCheckBlue, for: UIControlState())
        buttonCollapse.setImage(UIImage(named:"check_blue_empty"), for: UIControlState.selected)
        buttonCollapse.setTitle(NSLocalizedString("gr.category.especiales",comment:""), for: UIControlState())
        buttonCollapse.setTitle(NSLocalizedString("gr.category.especiales",comment:""), for: UIControlState.selected)
        buttonCollapse.addTarget(self, action: #selector(IPOGRCategoriesViewController.collapse(_:)), for: UIControlEvents.touchUpInside)
        buttonCollapse.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11);
        buttonCollapse.titleLabel!.textColor = WMColor.light_blue
        buttonCollapse.setTitleColor(WMColor.light_blue, for: UIControlState())
        buttonCollapse.titleEdgeInsets = UIEdgeInsetsMake(2.0,-72, 0.0, 0.0);
        buttonCollapse.imageEdgeInsets = UIEdgeInsetsMake(2.0,40, 0.0, 0.0);
        buttonCollapse.layer.cornerRadius = 2
        
        self.header?.addSubview(buttonCollapse)
        
        self.titleLabel?.text = "Súper"
        self.titleLabel?.textAlignment = .left
        
        self.viewFamily = UIView()
        self.viewFamily.backgroundColor = UIColor.white
        
        self.familyController = FamilyViewController()
        self.familyController.categoriesType = .categoryForGR
        self.addChildViewController(self.familyController)
        self.viewFamily.addSubview(self.familyController.view)
        self.header?.removeFromSuperview()
        
        let _ = loadDepartments()

        
        let svcConfig = ConfigService()
        canfigData = svcConfig.getConfoigContent()
    }
    
    override func setup() {
        self.hiddenBack = true
        super.setup()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewFamily.frame = CGRect(x: 0, y: CELL_HEIGHT, width: self.view.bounds.width, height: self.view.bounds.height - CELL_HEIGHT)
        familyController.view.frame = viewFamily.bounds
        self.titleLabel!.frame.origin = CGPoint(x: 10, y: 0)
    }
    
    func loadDepartments() -> [Any]? {
        let serviceCategory = GRCategoryService()
        self.items = serviceCategory.getCategoriesContent() as [Any]?
        return self.items
    }
    
    //MARK: TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if landingItem != nil {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if landingItem != nil && section == 1 {
            return self.header
        }else if landingItem == nil && section == 0 {
            return self.header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if landingItem != nil && section == 1 {
            return 46.0
        }else if landingItem == nil && section == 0 {
            return 46.0
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if landingItem != nil && section == 0 {
            return 1
        }
        return collapsed ? self.items!.count : self.items!.count * 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell
                let model =  UIDevice.current.modelName
        if indexPath.section == 0 && landingItem != nil  {
            let cellDept = tableView.dequeueReusableCell(withIdentifier: "celldepartment", for: indexPath) as! GRDepartmentTableViewCell
            let scale =  model.contains("Plus") ? 3 : UIScreen.main.scale
            var itemBannerPhone = landingItem!["bannerUrlPhone"]
            itemBannerPhone = itemBannerPhone!.replacingOccurrences(of: "@2x.jpg", with: ".jpg" )
            itemBannerPhone = itemBannerPhone!.replacingOccurrences(of: ".jpg", with: "@\(Int(scale))x.jpg" )
            cellDept.setValuesLanding("https://\(itemBannerPhone!)")
            return cellDept
        }
        
        if indexPath.row % 2 == 0 || collapsed {
            let cellDept = tableView.dequeueReusableCell(withIdentifier: "celldepartment", for: indexPath) as! GRDepartmentTableViewCell
            var rowforsearch = indexPath.row
            if !collapsed {
                rowforsearch = Int(indexPath.row / 2)
            }
            
            let item = items![rowforsearch] as! [String:Any]
            let descDepartment = item["description"] as! String
            let bgDepartment = (item["idDepto"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let scale =  model.contains("Plus") ? 3 : UIScreen.main.scale
            
            cellDept.setValues(descDepartment,imageBackgroundURL:bgDepartment + "@\(Int(scale))x.jpg",imageIconURL:"i_" + bgDepartment + ".@\(Int(scale))x.png")
            cell = cellDept

        } else {
            let cellSpecials = tableView.dequeueReusableCell(withIdentifier: "cellspecials", for: indexPath) as! IPOGRDepartmentSpecialTableViewCell
            cellSpecials.delegate = self
            
            let rowforsearch = Int(indexPath.row / 2)
            let item = items![rowforsearch] as! [String:Any]
            var bgDepartment = item["idDepto"] as! String
            let families = JSON(item["family"] as! [[String:Any]])
            let descDepartment = item["description"] as! String
            bgDepartment = bgDepartment.trimmingCharacters(in: CharacterSet.whitespaces)
            
            
            if let resultProducts = fillConfigData(bgDepartment,families:families) {
                cellSpecials.setLines(resultProducts,width:79,index:indexPath)
            }else {
                cellSpecials.withOutProducts()
            }
            
            cellSpecials.descLabel?.text = "Lo más destacado de \(descDepartment)"
            cell = cellSpecials
            
        }

        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if landingItem != nil && indexPath.section == 0 {
            return 215
        }
        
        if indexPath.row % 2 == 0 || collapsed {
            return 102
        }else {
            return 125
        }
    }
    
    
    func collapse(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        self.collapsed = !self.collapsed
        if self.collapsed{
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SUPER.rawValue, action: WMGAIUtils.ACTION_HIDE_HIGHLIGHTS.rawValue, label: "")
        }
        
        if landingItem != nil  {
            self.categoriesTable.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.automatic)
        }else{
            self.categoriesTable.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.automatic)
        }
      
    }


    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        categoriesTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom:0 , right:0 )
    }
 
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.categoriesTable.contentInset = UIEdgeInsetsMake(0, 0, self.categoriesTable.frame.height, 0)
        if indexPath.section == 0  && landingItem != nil  {
            let eventUrl = landingItem!["eventUrl"]
            self.handleLandingEvent(eventUrl!)
            return
        }
        
        var rowforsearch = indexPath.row
        var newIndex = indexPath
        
        if !(indexPath.row % 2 == 0) && !self.collapsed {
            rowforsearch = indexPath.row - 1
            newIndex = IndexPath(row:  indexPath.row - 1, section: indexPath.section)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            //self.categoriesTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            self.categoriesTable.scrollToRow(at: newIndex, at: UITableViewScrollPosition.top, animated: false)
            }, completion: { (complete:Bool) -> Void in
            //Open Family
               // self.familyController.view.hidden = false
                if rowforsearch % 2 == 0 || self.collapsed {
                    if !self.collapsed {
                        rowforsearch = Int(indexPath.row / 2)
                    }
                    
                    let item = self.items![rowforsearch] as! [String:Any]
                    let famArray : AnyObject = item["family"] as AnyObject!
                    let itemsFam : [[String:Any]] = famArray as! [[String:Any]]
                    let descDepartment = item["description"] as? String
                   
                    self.familyController.departmentId = item["idDepto"] as! String
                    self.familyController.families = itemsFam
                    self.familyController.selectedFamily = nil
                    self.familyController.familyTable.reloadData()
                    
                    let icon = "i_\(self.familyController.departmentId.trim())"
                    let caHeader = self.familyController.departmentId.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    let newView = IPODepartmentCollectionViewCell(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.CELL_HEIGHT))
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
                            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                                newView.imageBackground.alpha = 0
                                newView.imageIcon.alpha = 0
                                newView.buttonClose.alpha = 0
                                self.viewFamily.alpha = 0
                                }, completion: { (complete:Bool) -> Void in
                                    newView.removeFromSuperview()
                                    self.categoriesTable.contentInset = UIEdgeInsets.zero

                            })
                            
                        } else {
                            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                                newView.imageBackground.alpha = 0
                                newView.imageIcon.alpha = 0
                                newView.buttonClose.alpha = 0
                                self.viewFamily.alpha = 0
                                }, completion: { (complete:Bool) -> Void in
                                    newView.removeFromSuperview()
                                    self.categoriesTable.contentInset = UIEdgeInsets.zero
                                    
                            })
                        }
                        //BaseController.sendAnalytics(WMGAIUtils.GR_CATEGORY_ACCESSORY_AUTH.rawValue, categoryNoAuth: WMGAIUtils.GR_CATEGORY_ACCESSORY_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_CANCEL.rawValue, label: "")
                    }
                    
                    newView.startFrame = newView.bounds
                    newView.imageBackground.frame = newView.bounds
                    newView.imageIcon.frame = CGRect(x: (newView.bounds.width / 2) - 14,  y: newView.imageIcon.frame.minY ,  width: newView.imageIcon.frame.width,  height: newView.imageIcon.frame.height)
                    newView.buttonClose.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                    newView.buttonClose.alpha = 0
                    newView.imageBackground.alpha = 0
                    newView.imageIcon.alpha = 0
                    
                    newView.addGestureTiImage()

                    newView.titleLabel.attributedText!.boundingRect(with: CGSize(width: self.view.frame.width, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                    newView.titleLabel.frame = CGRect(x: (newView.bounds.width / 2) - (newView.titleLabel.frame.width / 2), y: newView.titleLabel.frame.minY, width: newView.titleLabel.frame.width, height: newView.titleLabel.frame.height)
                    self.viewFamily.alpha = 0
                    
                    self.familyController.familyTable.reloadData()
                    self.view.addSubview(self.viewFamily)
                    
                    
                    if self.collapsed {
                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                            newView.titleLabel.textColor = UIColor.white
                            self.viewFamily.alpha = 1
                            newView.imageBackground.alpha = 1
                            newView.imageIcon.alpha = 1
                            newView.buttonClose.alpha = 1
                            newView.alpha = 1
                                    
                        })
                    } else {
                    
                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                            newView.titleLabel.textColor = UIColor.white
                            self.viewFamily.alpha = 1
                            newView.imageBackground.alpha = 1
                            newView.imageIcon.alpha = 1
                            newView.buttonClose.alpha = 1
                            newView.alpha = 1
                            
                        })
                    }
                    //EVENT
                    //let label = item["description"] as! String
                    //let labelCategory = label.uppercased().replacingOccurrences(of: " ", with: "_")
//                    BaseController.sendAnalytics("GR_\(labelCategory)_VIEW_AUTH", categoryNoAuth: "GR_\(labelCategory)_VIEW_NO_AUTH", action: WMGAIUtils.ACTION_SHOW_FAMILIES.rawValue, label: label)
                    print("End")
                    self.view.addSubview(newView)
                }
                
        }) 
        
    }
    
    func handleLandingEvent(_ strAction:String) {
        var components = strAction.components(separatedBy: "_")
        if(components.count > 1){
            let window = UIApplication.shared.keyWindow
            if let customBar = window!.rootViewController as? CustomBarViewController {
                let cmpStr  = components[0] as String
                let strValue = strAction.replacingOccurrences(of: "\(cmpStr)_", with: "")
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
                let _ = customBar.handleNotification(strAction,name:"",value:strValue,bussines:"gr")
            }
        }
    }
    
    
    //MARK: Delegate
    
    func didTapLine(_ name:String,department:String,family:String,line:String) {
        
        let controller = SearchProductViewController()
        controller.searchContextType = .withCategoryForGR
        
        controller.titleHeader = name
        controller.idDepartment = department
        controller.idFamily = family
        controller.idLine = line
        
        self.navigationController!.pushViewController(controller, animated: true)
        //EVENT
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SUPER.rawValue, action: WMGAIUtils.ACTION_VIEW_RECOMMENDED.rawValue, label: name)
    }

    
    func didTapProduct(_ upcProduct:String,descProduct:String){
        
    }
    
    func didTapMore(_ index: IndexPath) {
        self.tableView(self.categoriesTable, didSelectRowAt: index)
    }
    
    func fillConfigData(_ depto:String,families:JSON) -> [[String:Any]]? {
        var resultDict : [Any] = []
        if Array(canfigData.keys.filter {$0 == depto }).count > 0 {
            let linesToShow = JSON(canfigData[depto] as! [[String:String]])
            for lineDest in linesToShow.arrayValue {
                for family in families.arrayValue {
                    for line in family["line"].arrayValue {
                        let lineOne = line["id"].stringValue
                        let lineTwo = lineDest["line"].stringValue
                        if lineOne.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                            == lineTwo.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
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
        
        return resultDict as? [[String:Any]]
    }
    
    //MARK changeStore
    func changeStore(){
        if titleLabel!.text! == "Súper ￼" && UserCurrentSession.sharedInstance.addressId == nil {
            let noAddressView = GRAddressNoStoreView(frame: CGRect(x: 0,y: 0,width: 288,height: 210))
            noAddressView.newAdressForm = { void in
                let addAddress = GRAddAddressView(frame: CGRect(x: 0,y: 49,width: 288,height: self.view.frame.height - 90))
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
            self.addressView = GRAddressView(frame: CGRect(x: 0,y: 0,width: 288,height: 365))
            self.addressView?.onCloseAddressView = {void in self.newModalView!.closePicker()}
            self.addressView?.newAdressForm = { void in
                let addAddress = GRAddAddressView(frame: CGRect(x: 0,y: 49,width: 288,height: self.view.frame.height - 90))
                addAddress.addressArray = self.addressView!.addressArray
                addAddress.onClose = {void in
                    self.newModalView!.closePicker()
                    self.setStoreName()
                }
                self.newModalView!.resizeViewContent("Nueva Dirección",view: addAddress)
            }
        
            self.addressView?.addressSelected = {(addressId:String,addressName:String,selectedStore:String,stores:[[String:Any]]) in
                let minViewHeigth : CGFloat = (1.5 * 46.0) + 67.0
                var storeViewHeight: CGFloat = (CGFloat(stores.count) * 46.0) + 67.0
                storeViewHeight = max(minViewHeigth,storeViewHeight)
                let storeView = GRAddressStoreView(frame: CGRect(x: 0,y: 49,width: 288,height: min(storeViewHeight,270)))
                storeView.selectedstoreId = selectedStore
                storeView.storeArray = stores as [Any]!
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
        if UserCurrentSession.sharedInstance.storeName != nil {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "arrow")
            let attachmentString = NSAttributedString(attachment: attachment)
            let attrs = [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(14)]
            var boldString = NSMutableAttributedString(string:"Walmart \(UserCurrentSession.sharedInstance.storeName!.capitalized)  ", attributes:attrs)
            if UserCurrentSession.sharedInstance.storeName == "" {
                 boldString = NSMutableAttributedString(string:"Súper ", attributes:attrs)
            }
            boldString.append(attachmentString)
            self.titleLabel?.adjustsFontSizeToFitWidth = true
            self.titleLabel?.minimumScaleFactor = 0.2
            self.titleLabel?.numberOfLines = 1
            self.titleLabel?.attributedText = boldString;
            self.titleLabel?.isUserInteractionEnabled = true;
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(IPOGRCategoriesViewController.changeStore))
            self.titleLabel?.addGestureRecognizer(tapGesture)
        }else{
            self.titleLabel?.text = "Súper"
        }
        
    }
}
