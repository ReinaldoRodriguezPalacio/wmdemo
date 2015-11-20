//
//  IPOGRCategoriesViewController.swift
//  WalMart
//
//  Created by neftali on 22/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class IPOGRCategoriesViewController: NavigationViewController, UITableViewDataSource,UITableViewDelegate,IPOGRDepartmentSpecialTableViewCellDelegate, GRMyAddressViewControllerDelegate {

    let CELL_HEIGHT : CGFloat = 98
    var viewFamily: UIView!

    @IBOutlet var categoriesTable : UITableView!
    var items : [AnyObject]? = []
    var collapsed = false
    var familyController : FamilyViewController!
    var canfigData : [String:AnyObject]! = [:]
    var itemsExclusive : [AnyObject]? = []
    var newModalView: AlertModalView? = nil
    
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
        //self.familyController.categoriesType = .CategoryForGR
        
      
        
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
        buttonCollapse.titleLabel!.textColor = WMColor.navigationFilterBGColor
        buttonCollapse.setTitleColor(WMColor.navigationFilterBGColor, forState: UIControlState.Normal)
        buttonCollapse.titleEdgeInsets = UIEdgeInsetsMake(2.0,-72, 0.0, 0.0);
        buttonCollapse.imageEdgeInsets = UIEdgeInsetsMake(2.0,40, 0.0, 0.0);
        buttonCollapse.layer.cornerRadius = 2
        
        self.header?.addSubview(buttonCollapse)
        
        self.titleLabel?.text = "Súper"
        
        self.viewFamily = UIView()
        self.viewFamily.backgroundColor = UIColor.whiteColor()
        
        self.familyController = FamilyViewController()
        self.familyController.categoriesType = .CategoryForGR
        self.addChildViewController(self.familyController)
        self.viewFamily.addSubview(self.familyController.view)
        
        
        loadDepartments()

        
        let svcConfig = ConfigService()
        let svcExclusive = GRExclusiveItemsService()
        itemsExclusive = svcExclusive.getGrExclusiveContent()
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
            //let bgDepartment = item["idDepto"] as! String
            //let departmentId = item["idDepto"] as! String
            
            cellDept.setValues(descDepartment,collapsed:collapsed)
            if !collapsed {
                cellDept.showLabel(collapsed)
            }
            
            if collapsed {
//                let separator = UIView()
//                separator.backgroundColor = WMColor.lineSaparatorColor
//                let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
//                separator.frame = CGRectMake(0, cellDept.frame.height - widthAndHeightSeparator, cellDept.frame.width, widthAndHeightSeparator)
//                
//                cellDept.addSubview(separator)
            }
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
                cellSpecials.setLines(resultProducts,width:self.view.frame.width / 3)
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
            return 56
        }else {
            return 150
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
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            //self.categoriesTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            let rectRow = self.categoriesTable.rectForRowAtIndexPath(indexPath)
            self.categoriesTable.scrollRectToVisible(CGRectMake(rectRow.minX, rectRow.minY - 49, rectRow.width, rectRow.height) , animated: false)
            }) { (complete:Bool) -> Void in
            //Open Family
               // self.familyController.view.hidden = false
                if indexPath.row % 2 == 0 || self.collapsed {
                    
                    var rowforsearch = indexPath.row
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
                    newView.setValues(descDepartment!, imageBackgroundURL: "\(caHeader).png", keyBgUrl: "WalmartMG.HeaderCategory", imageIconURL: icon, keyIconUrl: "WalmartMG.CategoryIcon", hideImage: false)
                   newView.customCloseDep = true
                    
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell?
                    
                    
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
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            
                            if let cellDep = cell as? GRDepartmentTableViewCell {
                                cellDep.centerButton()
                            }
                            
                            
                            }, completion: { (complete:Bool) -> Void in
                                UIView.animateWithDuration(0.5, animations: { () -> Void in
                                    newView.titleLabel.textColor = UIColor.whiteColor()
                                    self.viewFamily.alpha = 1
                                    newView.imageBackground.alpha = 1
                                    newView.imageIcon.alpha = 1
                                    newView.buttonClose.alpha = 1
                                    newView.alpha = 1
                                    
                                })
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
    
    
    //MArk: Delegate 
    
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
        let myAddress = GRMyAddressViewController()
        myAddress.addCloseButton()
        myAddress.delegate = self
        myAddress.onClosePicker = { () in   self.newModalView?.removeFromSuperview()}
        let navController = UINavigationController(rootViewController: myAddress)
        navController.navigationBarHidden = true
        navController.view.frame = CGRectMake(0, 0, self.view.frame.width - 26, self.view.frame.height - 26)
        newModalView = AlertModalView.initModalWithNavController(navController)
        newModalView!.showPicker()
    }
    
    func setStoreName(){
        if UserCurrentSession.sharedInstance().storeName != nil && UserCurrentSession.sharedInstance().storeName != "" {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "arrow")
            let attachmentString = NSAttributedString(attachment: attachment)
            let myString = NSMutableAttributedString(string: "Tu tienda: ")
            let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(13)]
            let boldString = NSMutableAttributedString(string:"Walmart \(UserCurrentSession.sharedInstance().storeName!.capitalizedString) ", attributes:attrs)
            myString.appendAttributedString(boldString)
            myString.appendAttributedString(attachmentString)
            self.titleLabel?.numberOfLines = 2;
            self.titleLabel?.attributedText = myString;
            self.titleLabel?.textAlignment = .Left
            self.titleLabel?.userInteractionEnabled = true;
            let tapGesture = UITapGestureRecognizer(target: self, action: "changeStore")
            self.titleLabel?.addGestureRecognizer(tapGesture)
            self.titleLabel!.frame = CGRectMake(10, 0, self.header!.frame.width - 110, self.header!.frame.maxY)
        }else{
            self.titleLabel?.text = "Súper"
        }
        
    }
    
    func okAction() {
        self.setStoreName()
    }

}