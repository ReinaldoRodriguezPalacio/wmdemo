//
//  FilterProductsViewController.swift
//  WalMart
//
//  Created by neftali on 19/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol FilterProductsViewControllerDelegate {
    func apply(order:String, filters:[String:AnyObject]?, isForGroceries flag:Bool)
    func apply(order:String, upcs: [String])
    func removeFilters()
    func removeSelectedFilters()
    func sendBrandFilter(brandFilter:String)
}

class FilterProductsViewController: NavigationViewController, UITableViewDelegate, UITableViewDataSource, FilterOrderViewCellDelegate,SliderTableViewCellDelegate {

    let ORDERCELL_ID = "orderCellId"
    let CELL_ID = "cellId"
    let sliderCellId = "SliderCellView"
    let JSON_KEY_FACET_ITEMS = "itemsFacet"
    let JSON_KEY_FACET_ITEMNAME = "itemName"
    let JSON_SLIDER = "slider"
    let JSON_KEY_FACET_UPCS = "upcs"
    
    let FILTER_PRICE_ID = "Por Precios"
    
    var applyButton: UIButton?
    var removeButton: UIButton?
    var tableView: UITableView?
    var loading: WMLoadingView?
    
    var textToSearch: String?
    var originalSearchContext: SearchServiceContextType?
    var searchContext: SearchServiceContextType?
    var categories: [AnyObject]?
    var tableElements: [AnyObject]?
    var tableReset: [AnyObject]?
    var selectedElements: [Bool]?
    var selectedElementsFacet: [NSIndexPath:Bool]?
    var selectedOrder: String?
    var isGroceriesSearch: Bool = false
    var facetGr: NSArray? = nil
    var selectedFacetGr: [String:Bool]?

    var delegate:FilterProductsViewControllerDelegate?
    var successCallBack : (() -> Void)? = nil
    var backFilter : (() -> Void)? = nil
    
    var prices: NSArray?
    var upcPrices: NSArray?
    var upcByPrice: NSArray?
    var brandFacets: [String] = []
    var isTextSearch: Bool = false
    var needsToValidateData = true
    var facet: NSArray? = nil
    
    var sliderTableViewCell : SliderTableViewCell?
    var filterOrderViewCell : FilterOrderViewCell?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_FILTER.rawValue
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel!.text = NSLocalizedString("filter.title", comment:"")
        self.titleLabel!.textAlignment =  .Center
        
        let iconImage = UIImage(color: WMColor.green, size: CGSizeMake(55, 22), radius: 11) // UIImage(named:"button_bg")
        let iconSelected = UIImage(color: WMColor.green, size: CGSizeMake(55, 22), radius: 11)
        
        self.applyButton = UIButton(type: .Custom)
        self.applyButton!.setBackgroundImage(iconImage, forState: .Normal)
        self.applyButton!.setBackgroundImage(iconSelected, forState: .Selected)
        self.applyButton!.setTitle(NSLocalizedString("filter.apply", comment:""), forState: .Normal)
        self.applyButton!.setTitleColor(WMColor.light_light_gray, forState: .Normal)
        self.applyButton!.addTarget(self, action: #selector(FilterProductsViewController.applyFilters), forControlEvents: .TouchUpInside)
        self.applyButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        
        self.header!.addSubview(self.applyButton!)

        self.removeButton = UIButton(type: .Custom)
        self.removeButton!.setBackgroundImage(iconImage, forState: .Normal)
        self.removeButton!.setBackgroundImage(iconSelected, forState: .Selected)
        self.removeButton!.setTitle(NSLocalizedString("filter.button.clean", comment:""), forState: .Normal)
        self.removeButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.removeButton!.addTarget(self, action: #selector(FilterProductsViewController.removeFilters), forControlEvents: .TouchUpInside)
        self.removeButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.removeButton!.hidden = true
        self.removeButton!.layer.cornerRadius = 11
        self.header!.addSubview(self.removeButton!)
        
        /*if self.originalSearchContext != nil && self.originalSearchContext == SearchServiceContextType.WithText && self.originalSearchContext != self.searchContext {
            self.removeButton!.hidden = false
        }
        
        self.header!.addSubview(self.removeButton!)
*/
        self.tableView = UITableView(frame: CGRectMake(0.0, 0.0, 320.0, 480.0), style: .Plain)
        self.tableView!.separatorStyle = .None
        self.view.addSubview(self.tableView!)
        
        self.tableView!.registerClass(FilterOrderViewCell.self, forCellReuseIdentifier: self.ORDERCELL_ID)
        self.tableView!.registerClass(FilterCategoryViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        self.tableView!.registerClass(SliderTableViewCell.self, forCellReuseIdentifier: self.sliderCellId)
        
        self.selectedElementsFacet = [:]
        self.selectedFacetGr = [:]
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Solo en el caso de que la busqueda sea con texto o camfind
        self.isTextSearch =  self.originalSearchContext! == SearchServiceContextType.WithText || self.originalSearchContext! == SearchServiceContextType.WithTextForCamFind
        
        if self.originalSearchContext != nil && self.isTextSearch {
            self.loadLinesForSearch()
        }
        else{
            self.tableView!.delegate = self
            self.tableView!.dataSource = self
            self.tableView!.reloadData()
        }
        validateFacetData()
    }
    
    func validateFacetData() {
        if facet != nil {
            var facetEnd : [AnyObject] = []
            for facetItemsCount in facet! {
                let facetitem = facetItemsCount["itemsFacet"] as! [[String:AnyObject]]
                var newItemsFacet : [[String:AnyObject]] = []
                for itemFac in facetitem {
                    if itemFac["itemName"] as! String != ""{
                        newItemsFacet.append(itemFac)
                    }
                }
               
                
                
                if newItemsFacet.count > 0 {
                    facetEnd.append(["itemsFacet":newItemsFacet,"type":facetItemsCount["type"],"name":facetItemsCount["name"],"order":facetItemsCount["order"]])
                }
            }
            facet = facetEnd
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let headerBounds = self.header!.frame.size
        let buttonWidth: CGFloat = 55.0
        let buttonHeight: CGFloat = 22.0
        self.applyButton!.frame = CGRectMake(headerBounds.width - (buttonWidth + 16.0), (headerBounds.height - buttonHeight)/2, buttonWidth, buttonHeight)
        self.removeButton!.frame = CGRectMake(self.applyButton!.frame.minX - (buttonWidth + 16.0), (headerBounds.height - buttonHeight)/2, buttonWidth, buttonHeight)
        if self.originalSearchContext != nil && self.originalSearchContext == SearchServiceContextType.WithText && self.originalSearchContext != self.searchContext {
            //self.titleLabel!.frame = CGRectMake(46.0, 0, self.header!.frame.width - (46.0 + (buttonWidth*2) + 32.0), self.header!.frame.maxY)
        }

        let bounds = self.view.frame
        self.tableView!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, bounds.height - self.header!.frame.height)
    }
    
    //MARK: - Actions
    
    func applyFilters() {
        
        var lastSelected:Int? = nil
        if self.selectedElements != nil && self.selectedElements!.count > 0 {
            for idx in 0 ..< self.selectedElements!.count {
                if self.selectedElements![idx] {
                    lastSelected = idx
                    break
                }
            }
        }
        
        if self.facetGr != nil {
            var filterSelect = false
            for selElement in self.selectedFacetGr!.keys {
                let valSelected =  self.selectedFacetGr?[selElement]
                if (valSelected == true) {
                    self.delegate?.sendBrandFilter(selElement)
                    filterSelect =  !filterSelect
                }
            }
            if !filterSelect {
                self.delegate?.sendBrandFilter("")
            }
        }
        
        
        
        //Filtros de MG Funcionan diferente
        if self.originalSearchContext != nil  && facet != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG {
            //self.successCallBack!()
            
            //var intIx = 0
            var upcs : [String] = []
            for selElement in self.selectedElementsFacet!.keys {
                let valSelected =  self.selectedElementsFacet?[selElement]
                if valSelected! {
                    if selElement.row == 0 && upcByPrice == nil {
                        self.delegate?.apply(self.selectedOrder!, filters: nil, isForGroceries: false)
                        if successCallBack != nil {
                            self.successCallBack!()
                        }else {
                            self.navigationController!.popViewControllerAnimated(true)
                        }
                        return
                    }
                    let itemFacet = self.facet![selElement.section - 1] as! [String:AnyObject]
                    if  let typeFacet = itemFacet["type"] as? String {
                        if typeFacet == "check" {
                            let allnameFacets = itemFacet["itemsFacet"] as! [[String:AnyObject]]
                            
                            if selElement.row  > 0 {
                                let facet = allnameFacets[selElement.row - 1]
                                let allUpcs = facet["upcs"] as! [String]
                                for upcVal in allUpcs {
                                    if upcByPrice != nil {
                                        if  self.upcByPrice!.containsObject(upcVal)  {
                                            upcs.append(upcVal)
                                        }
                                    }else {
                                        upcs.append(upcVal)
                                    }
                                }
                            }
                            else {
                                for upcVal in self.upcByPrice! {
                                      upcs.append(upcVal as! String)
                                }
                            }
                        }
                    }
                }
            }
            
            self.delegate?.apply(self.selectedOrder!, upcs: upcs)
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_APPLY_FILTER.rawValue, label: "")
            if successCallBack != nil {
                self.successCallBack!()
            }else {
                self.navigationController!.popViewControllerAnimated(true)
            }
            return
        }
        
        
        
        var department = ""
        var family = ""
        var line = ""
        var groceriesType = false
        if lastSelected != nil {
            var element = self.tableElements![lastSelected!] as! [String:AnyObject]
            if let path = element["path"] as? String {
                var options = path.componentsSeparatedByString("|")
                department = options[0]
                family = options.count > 1 ? options[1] : ""
                line = options.count > 2 ? options[2] : ""
                if let type = element["responseType"] as? String {
                    if let roType = ResultObjectType(rawValue: type) {
                        groceriesType = ResultObjectType.Groceries == roType
                    }
                }
            }
        }
        
        var filters:[String:AnyObject] = [:]
        if !line.isEmpty {
            filters[JSON_KEY_IDLINE] = line
        }
        if !family.isEmpty {
            filters[JSON_KEY_IDFAMILY] = family
        }
        if !department.isEmpty {
            filters[JSON_KEY_IDDEPARTMENT] = department
        }

        self.delegate?.apply(self.selectedOrder!, filters: filters.count > 0 ? filters : nil, isForGroceries: groceriesType)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_APPLY_FILTER.rawValue, label: "")
        if successCallBack != nil {
            self.successCallBack!()
        }else {
            self.navigationController!.popViewControllerAnimated(true)
        }
       self.delegate?.removeSelectedFilters()
        
    }
    

    
    func removeFilters() {
        self.delegate?.removeFilters()
        if successCallBack != nil {
            self.successCallBack!()
        }else {
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
 
    //MARK: - UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if self.originalSearchContext != nil && self.isTextSearch {
                 return 2
        }
        if self.originalSearchContext != nil  && facet != nil && facet?.count > 0  && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG{
            return 1 + facet!.count
        }
        
        if self.facetGr != nil && self.facetGr?.count > 0 {// new
            return 2
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if self.originalSearchContext != nil && self.isTextSearch {
            return self.tableElements != nil ? self.tableElements!.count + 1 : 0 // + 1
        }
        if self.originalSearchContext != nil  && facet != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG{
            let itemFacet = self.facet![section - 1] as! [String:AnyObject]
            if  let typeFacet = itemFacet["type"] as? String {
                if typeFacet == "check" {
                    let allnameFacets = itemFacet["itemsFacet"] as! [[String:AnyObject]]
                    return allnameFacets.count + 1
                }
                if typeFacet == JSON_SLIDER {
                    return 1
                }
            }
        }
        
        if self.facetGr != nil {
            return self.facetGr != nil ? self.facetGr!.count + 1: 0
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.ORDERCELL_ID, forIndexPath: indexPath) as! FilterOrderViewCell
            cell.delegate = self
            cell.setValues(self.selectedOrder!)
            filterOrderViewCell =  cell
            return cell
        }
        
        if self.facetGr != nil{
            
            let listCell = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID, forIndexPath: indexPath) as! FilterCategoryViewCell
            
            var item :String = ""
            if indexPath.row > 0 {
                item = self.facetGr![indexPath.row - 1] as! String
            }else{
                item = ""//self.facetGr![indexPath.row ] as! String
            }
            
            var selected = false
            let valSelected =  self.selectedFacetGr?[item]
            if ((valSelected) != nil) {
                selected = valSelected!
            }
            
            if indexPath.row > 0 {
                 item = self.facetGr![indexPath.row - 1] as! String
                selectedFacetGr?.updateValue(selected,forKey: item)
                listCell.setValuesFacets(nil,nameBrand:item, selected: selected)
                
            }else{
                
                if self.selectedFacetGr!.count == 0  {
                    self.selectedFacetGr!.updateValue(true, forKey: item)
                    selected = true
                } else {
                    selected = false
                }
                
                listCell.setValuesSelectAll(selected, isFacet: true)
            }
            
            return listCell
        }
        
        if self.originalSearchContext != nil  && facet != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG {
            let facetInfo = facet![indexPath.section - 1] as! NSDictionary
            
            if  let typeFacet = facetInfo["type"] as? String {
                if typeFacet == "check" {
                    let listCell = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID, forIndexPath: indexPath) as! FilterCategoryViewCell

                    var selected = false
                    let valSelected =  self.selectedElementsFacet?[indexPath]
                    if ((valSelected) != nil) {
                        selected = valSelected!
                    }
                    
                    if indexPath.row > 0 {
                        let facetitem = facetInfo["itemsFacet"] as! [[String:AnyObject]]
                        let item = facetitem[indexPath.row - 1]
                        self.addBrandFacet(item["itemName"] as! String)
                        listCell.setValuesFacets(item,nameBrand:"", selected: selected)
                    } else {
                        if self.selectedElementsFacet!.count == 0  {
                            self.selectedElementsFacet!.updateValue(true, forKey: indexPath)
                            selected = true
                        } else {
                            selected = false
                            if ((valSelected) != nil) {
                                selected = valSelected!
                            }
                        }
                        listCell.setValuesSelectAll(selected, isFacet: true)
                    }
                    return listCell
                    
                }
                if typeFacet == JSON_SLIDER {
                    
                    //self.selectedElementsFacet!.updateValue(true, forKey: indexPath)
                    
                    self.processPriceFacet(facetInfo)
                    let cell = tableView.dequeueReusableCellWithIdentifier(self.sliderCellId) as! SliderTableViewCell
                    let sliderCell : SliderTableViewCell = cell as SliderTableViewCell
                    if self.prices != nil {
                        sliderCell.setValuesSlider(self.prices!)
                        sliderCell.delegate = self
                    }
                    sliderTableViewCell = sliderCell
                    //sliderCell.delegate = self
                    return sliderCell
                }
            }
            
        } else {
            let listCell = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID, forIndexPath: indexPath) as! FilterCategoryViewCell
            /*if self.selectedElements != nil {
             let selected = self.selectedElements![indexPath.row]
             let item = self.tableElements![indexPath.row] as! [String:AnyObject]
             listCell.setValues(item, selected:selected)
            }*/
            
            var selected = false
            let valSelected =  self.selectedElementsFacet?[indexPath]
            if ((valSelected) != nil) {
                selected = valSelected!
                }

            if indexPath.row > 0 {
                let selected = self.selectedElements![indexPath.row]
                let item = self.tableElements![indexPath.row - 1] as! [String:AnyObject]
                listCell.setValues(item, selected:selected)
                } else {
                if self.selectedElementsFacet!.count == 0  {
                    self.selectedElementsFacet!.updateValue(true, forKey: indexPath)
                        selected = true
                    } else {
                    selected = false
                    if ((valSelected) != nil) {
                        selected = valSelected!
                        }
                    }
                listCell.setValuesSelectAll(selected, isFacet: false)
            }
            return listCell
        }
        return UITableViewCell()
    }
    
    func processPriceFacet(fitem:NSDictionary) {
        if let itemsFacet = fitem[JSON_KEY_FACET_ITEMS] as? NSArray {
            var array = Array<Double>()
            var mirror = Array<NSArray>()
            for idx in 0 ..< itemsFacet.count {
                let item = itemsFacet[idx] as! NSDictionary
                if let value = item[JSON_KEY_FACET_ITEMNAME] as? NSString {
                    var values = value.componentsSeparatedByString("-")
                    if idx == itemsFacet.count - 1 {
                        let price = values[0] as NSString
                        let lastPrice = values[1] as NSString
                        array.append(price.doubleValue)
                        array.append(lastPrice.doubleValue)
                    }
                    else {
                        let price = values[0] as NSString
                        array.append(price.doubleValue)
                    }
                }
                mirror.append(item[JSON_KEY_FACET_UPCS] as! NSArray)
            }
            self.prices = array
            self.upcPrices = mirror
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 103.0
        }
        if self.originalSearchContext != nil  && facet != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG{
            let itemFacet = self.facet![indexPath.section - 1] as! [String:AnyObject]
            if  let typeFacet = itemFacet["type"] as? String {
                if typeFacet == JSON_SLIDER {
                    return 73.0
                }
            }
        }

        return 36.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        
        if self.facetGr != nil {
            if indexPath.row == 0 {
                self.selectedFacetGr = [:]
                self.tableView?.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
                BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SEARCH_PRODUCT_FILTER.rawValue, action: WMGAIUtils.ACTION_BRAND_SELECTION.rawValue, label: "Seleccionar todos")
                return
            }
            
            let item = self.facetGr![indexPath.row - 1] as? String
            var currentVal = true
            for items in self.selectedFacetGr! {
                if items.1 == true{
                    self.selectedFacetGr!.updateValue(false, forKey: items.0)
                    break
                }
            }
            
            if let savedVal = self.selectedFacetGr![item!] {
                currentVal = !savedVal
            }
            
            self.selectedFacetGr!.updateValue(currentVal, forKey: item!)
            //self.tableView?.reloadRowsAtIndexPaths([indexPath,NSIndexPath(forRow: 0, inSection: indexPath.section)], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView?.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
            return
        }
        
        //Filtros de MG Funcionan diferente
        if self.originalSearchContext != nil && facet != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG {
            //self.selectedElements![indexPath.row] = true
            if indexPath.row == 0 {
                self.selectedElementsFacet = [:]
                self.tableView?.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
                BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SEARCH_PRODUCT_FILTER.rawValue, action: WMGAIUtils.ACTION_BRAND_SELECTION.rawValue, label: "Seleccionar todos")
                return
            }
            
            var currentVal = true
            var countselected = 0
            var ixSelected : NSIndexPath? = nil
            for items in self.selectedElementsFacet! {
                if items.1 == true{
                    countselected += 1
                    ixSelected  = items.0
                }
            }
            
            if countselected == 1 && ixSelected == indexPath {
                return
            }
            
            if let savedVal = self.selectedElementsFacet![indexPath] {
                currentVal = !savedVal
            }
           
            self.selectedElementsFacet!.updateValue(currentVal, forKey: indexPath)
            for keyObj in self.selectedElementsFacet!.keys {
                if keyObj.row == 0 {
                    self.selectedElementsFacet?.updateValue(false, forKey: keyObj)
                }
            }
            BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SEARCH_PRODUCT_FILTER.rawValue, action: WMGAIUtils.ACTION_BRAND_SELECTION.rawValue, label: self.brandFacets[indexPath.row - 1])
            
            self.tableView?.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
            //self.tableView?.reloadRowsAtIndexPaths([indexPath,NSIndexPath(forRow: 0, inSection: indexPath.section)], withRowAnimation: UITableViewRowAnimation.Fade)
            //self.removeButton!.hidden = false
            
            return
        }
        
        //
        if indexPath.row == 0 {
            self.selectedElementsFacet = [:]
                self.tableElements = nil
                self.tableElements = self.tableReset
                self.tableView?.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
                BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SEARCH_PRODUCT_FILTER.rawValue, action: WMGAIUtils.ACTION_BRAND_SELECTION.rawValue, label: "Seleccionar todos")
                self.selectedElements = [Bool](count: (self.tableElements!.count + 1), repeatedValue: false)
                self.selectedElements![0] = true
            return
            }
        
        let isAlreadyOpen = self.selectedElements![indexPath.row] //
        if isAlreadyOpen {
            return
        }
        
        var visibleCells = tableView.visibleCells
        for idx in 0 ..< visibleCells.count {
            if let cell = visibleCells[idx] as? FilterCategoryViewCell {
                cell.check!.highlighted = false
            }
        }
        
        var item = self.tableElements![indexPath.row - 1] as! [String:AnyObject] // - 1
        let itemLevel = (item["level"] as! NSNumber).integerValue
        let itemId = item["id"] as! String
        let itemParentId = item["parentId"] as! String
        
        if itemLevel != 2 {
            var indexes:[NSIndexPath] = []
            var filteredElements:[AnyObject] = []
            for idx in 0 ..< self.tableElements!.count {
                var element = self.tableElements![idx] as! [String:AnyObject]
                let elementId = element["id"] as! String
                let elementParentId = element["parentId"] as! String
                let level = (element["level"] as! NSNumber).integerValue
                
                if level == 0 || itemId == elementId || itemParentId == elementParentId {
                    filteredElements.append(element)
                    continue
                }
                if self.itemIsContained(item, node: element) {
                    filteredElements.append(element)
                    continue
                }
                
                if level > 0 {
                    indexes.append(NSIndexPath(forRow: idx, inSection: 1))
                }
            }
            self.tableElements = filteredElements
            self.selectedElements = [Bool](count: (self.tableElements!.count + 1), repeatedValue: false)
            self.selectedElements![0] = false
            tableView.deleteRowsAtIndexPaths(indexes, withRowAnimation: .Automatic)
            
            var updatedIndex:NSIndexPath? = nil
            for idx in 1 ..< (self.tableElements!.count + 1) {
                var element = self.tableElements![idx - 1] as! [String:AnyObject]
                let elementId = element["id"] as! String
                if self.itemIsContained(item, node: element) {
                    self.selectedElements![idx] = true
                }
                if itemId == elementId {
                    updatedIndex = NSIndexPath(forRow: idx, inSection: 1)
                    self.selectedElements![idx] = true
                }
            }
            
            if let family = item["families"] as? [String:AnyObject] {
                self.insertItems(family, atIndexPath: updatedIndex!)
                 BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SEARCH_PRODUCT_FILTER.rawValue, action: WMGAIUtils.ACTION_OPEN_CATEGORY_DEPARMENT.rawValue, label: "")
            }
                
            else if let line = item["lines"] as? [String:AnyObject] {
                self.insertItems(line, atIndexPath: updatedIndex!)
                BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SEARCH_PRODUCT_FILTER.rawValue, action: WMGAIUtils.ACTION_OPEN_CATEGORY_FAMILY.rawValue, label: "")
            }
        }
        else {
            self.selectedElements![indexPath.row] = true
        
             BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SEARCH_PRODUCT_FILTER.rawValue, action: WMGAIUtils.ACTION_OPEN_CATEGORY_LINE.rawValue, label: "")
            
        }

        for idx in 1 ..< self.selectedElements!.count {
            if self.selectedElements![idx] {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: (idx), inSection: 1)) as? FilterCategoryViewCell {
                    cell.check!.highlighted = true
                }
            }
        }
        //
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRectMake(0.0, 0.0, self.view.frame.width, 36.0))
        header.backgroundColor = WMColor.light_gray
        
        let title = UILabel(frame: CGRectMake(16.0, 0.0, self.view.frame.width - 32.0, 36.0))
        //title.backgroundColor = WMColor.light_light_gray
        title.textColor = WMColor.reg_gray
        title.font = WMFont.fontMyriadProRegularOfSize(11)
        if section == 0 {
            title.text = NSLocalizedString("filter.section.order", comment:"")
        }
        else {
            if self.originalSearchContext != nil && self.isTextSearch {
                title.text = NSLocalizedString("filter.section.categories", comment:"")
            }
            if self.originalSearchContext != nil  && facet != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG {
                let facetName = facet![section - 1] as! NSDictionary
                let nameTitle =  facetName["name"] as! String
                title.text = nameTitle.contains("Precios") ? NSLocalizedString("Rango de Precio", comment: "") : nameTitle
                
            }
            if self.facetGr !=  nil {
                title.text = "Marca"
            }
            
        }
        header.addSubview(title)
        
        return header
    }
    
    //MARK: - Utils
    
    func insertItems(items:[String:AnyObject], atIndexPath indexPath:NSIndexPath) {
        if items.keys.count > 0 {
            var indexes:[NSIndexPath] = []
            var idx = 0
            for key in items.keys {
                let index = indexPath.row + (idx)
                let inner = items[key] as! [String:AnyObject]
                indexes.append(NSIndexPath(forRow: (index + 1), inSection: 1))
                self.tableElements!.insert(inner, atIndex: index)
                self.selectedElements!.insert(false, atIndex: (index + 1))
                idx += 1
            }
            self.tableView!.insertRowsAtIndexPaths(indexes, withRowAnimation: .Automatic)
        }
    }
    
    func deleteItems(items:[AnyObject], atIndexPath indexPath:NSIndexPath) {
        if items.count > 0 {
            var indexes:[AnyObject] = []
            for idx in 0 ..< items.count {
                var itemToDelete = items[idx] as! [String:AnyObject]
                let id = itemToDelete["id"] as! String
                for idxe in 0 ..< self.tableElements!.count {
                    let innerElement:AnyObject = self.tableElements![idxe]
                    let innerId = innerElement["id"] as! String
                    if id == innerId {
                        self.tableElements!.removeAtIndex(idxe)
                        indexes.append(NSIndexPath(forRow: (idxe + 1), inSection: 1))
                        break
                    }
                }
            }
        }
    }
    
    func itemIsContained(item:[String:AnyObject], node:[String:AnyObject]) -> Bool {
        var isContained = false
        let itemLevel = (item["level"] as! NSNumber).integerValue
        let nodeLevel = (node["level"] as! NSNumber).integerValue
        if itemLevel != nodeLevel && itemLevel > nodeLevel {
            let itemId = item["id"] as! String
            //Find as family
            if nodeLevel == 0 {
                let families = node["families"] as! [String:AnyObject]
                for idx in 0 ..< families.keys.count {
                    var family = families[Array(families.keys)[idx]] as! [String:AnyObject]
                    if itemLevel == 1 {
                        let familyId = family["id"] as! String
                        if itemId == familyId {
                            isContained = true
                            break
                        }
                    }
                    else if self.itemIsContained(item, node: family) {
                        isContained = true
                        break
                    }
                }
            }
            else if nodeLevel == 1 {
                let lines = node["lines"] as! [String:AnyObject]
                for idx in 0 ..< Array(lines.keys).count {
                    var line = lines[Array(lines.keys)[idx]] as! [String:AnyObject]
                    let lineId = line["id"] as! String
                    if itemId == lineId {
                        isContained = true
                        break
                    }
                }
            }
        }
        return isContained
    }
    
    //MARK: - Services
    
    func loadLinesForSearch() {
        self.loading = WMLoadingView(frame: CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
        self.loading!.startAnnimating(self.isVisibleTab)
        self.view.addSubview(self.loading!)
        
        self.categories = nil
        self.tableElements = nil
        self.selectedElements = nil

        let success = { () -> Void in
            //Recarga view
            dispatch_async(dispatch_get_main_queue(), {
                NSLog("Recagra view")
                self.loading?.stopAnnimating()
                self.loading = nil
                self.tableView?.delegate = self
                self.tableView?.dataSource = self
                self.tableView?.reloadData()
            })
        }
        
        let errorBlock = { (error:NSError) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                 NSLog("Recagra view2")
                self.tableView!.delegate = self
                self.tableView!.dataSource = self
                self.loading!.stopAnnimating()
                self.loading = nil
                self.tableView!.reloadData()
            })
        }
          self.invokeRetrieveLinesForMG(successBlock: success, errorBlock: errorBlock)
//        if isGroceriesSearch {
//        } else {
//            self.invokeRetrieveLinesForMG(successBlock: success, errorBlock: errorBlock)
//        }
        
//        self.invokeRetrieveLinesForGroceries(
//            successBlock: { () -> Void in
//                self.invokeRetrieveLinesForMG(successBlock: success, errorBlock: errorBlock)
//            }, errorBlock: { (error:NSError) -> Void in
//                self.invokeRetrieveLinesForMG(successBlock: success, errorBlock: errorBlock)
//            }
//        )
    }
    
    func invokeRetrieveLinesForGroceries(successBlock successBlock:(()->Void)?, errorBlock:((NSError)->Void)?) {
        NSLog("self.categories = categories")
        let service = GRLinesForSearchService()
        service.callService(service.buildParams(self.textToSearch!),
            successBlock: { (categories: [AnyObject]) -> Void in
                    NSLog("self.categories = categories")
                    self.categories = categories
                    NSLog("self.tableElements = [AnyObject](categories)")
                    self.tableElements = [AnyObject](categories)
                    NSLog("if self.tableElements?.count > 0 {")
                    if self.tableElements?.count > 0 {
                        NSLog("self.selectedElements = [Bool](count: self.tableElements!.count, repeatedValue: false)")
                        self.selectedElements = [Bool](count: (self.tableElements!.count + 1), repeatedValue: false)
                    }
                    NSLog("successBlock?()")
                    successBlock?()
                    NSLog("End")
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at retrieve lines for groceries")
                errorBlock?(error)
                return
            }
        )
    }
    
    func invokeRetrieveLinesForMG(successBlock successBlock:(()->Void)?, errorBlock:((NSError)->Void)?) {
        let service = LinesForSearchService()
        service.callService(service.buildParams(self.textToSearch!),
            successBlock: { (categories:[AnyObject]) -> Void in
                NSLog("Inicia pintado de datos")
                if self.categories != nil {
                    let array = self.categories! + categories
                    self.categories = array
//                    self.categories!.sort { (objectOne:AnyObject, objectTwo:AnyObject) -> Bool in
//                        var deptoOne = objectOne as [String:AnyObject]
//                        var deptoTwo = objectTwo as [String:AnyObject]
//                        var nameOne = deptoOne["name"] as NSString
//                        var nameTwo = deptoTwo["name"] as NSString
//                        return nameOne.caseInsensitiveCompare(nameTwo) == NSComparisonResult.OrderedAscending
//                    }
                }
                else {
                    self.categories = categories
                }
                
                if self.tableElements != nil {
                    let array = self.tableElements! + categories
                    self.tableElements = array
//                    self.tableElements!.sort { (objectOne:AnyObject, objectTwo:AnyObject) -> Bool in
//                        var deptoOne = objectOne as [String:AnyObject]
//                        var deptoTwo = objectTwo as [String:AnyObject]
//                        var nameOne = deptoOne["name"] as NSString
//                        var nameTwo = deptoTwo["name"] as NSString
//                        return nameOne.caseInsensitiveCompare(nameTwo) == NSComparisonResult.OrderedAscending
//                    }
                }
                else {
                    self.tableElements = [AnyObject](categories)
                    self.tableReset = self.tableElements
                }
                
                if self.tableElements?.count > 0 {
                    self.selectedElements = [Bool](count: (self.tableElements!.count + 1), repeatedValue: false)
                }
                NSLog("Termina pintado de datos")
                successBlock?()
                return
            },
            errorBlock: { (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }
    
    //MARK: - FilterOrderViewCellDelegate
    
    func didChangeOrder(order:String) {
        var result = order
        if (self.originalSearchContext! == SearchServiceContextType.WithCategoryForGR || self.searchContext! == SearchServiceContextType.WithCategoryForGR ) && order == "popularity"{
            result = ""
        }
        self.selectedOrder = result
    }

    
    func rangerSliderDidChangeValues(forLowPrice low:Int, andHighPrice high:Int) {
        self.filterProductsByPrice(forLowPrice: low, andHighPrice: high)
        BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SEARCH_PRODUCT_FILTER.rawValue, action: WMGAIUtils.ACTION_SLIDER_PRICE_RANGE_SELECT.rawValue, label: "\(self.prices![low]) - \(self.prices![high])")
    }
    
    func filterProductsByPrice(forLowPrice low:Int, andHighPrice high:Int) {
        //En caso de que el rango sea completo, no se filtran los upcs
        let count = (self.prices!.count - 1)
        if low == 0 && high == count {
            self.upcByPrice = nil
            return
        }
        var array = Array<String>()
        for idx in low ..< high {
            if let upcs = self.upcPrices![idx] as? NSArray {
                for upc in upcs {
                    if let string = upc as? String {
                        array.append(string)
                        //if  array.count > 100 {
                        //    break
                        //}
                    }
                }
            }
        }
        self.upcByPrice = array
    }
    
    func addBrandFacet(brand:String){
        if !self.brandFacets.contains(brand){
            self.brandFacets.append(brand)
        }
    }
    
    override func back() {
        super.back()
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BACK_SEARCH_PRODUCT.rawValue , label: "")
        self.backFilter?()
    }
    
}
