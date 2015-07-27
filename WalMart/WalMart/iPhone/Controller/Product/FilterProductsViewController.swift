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
    var selectedElements: [Bool]?
    var selectedElementsFacet: [NSIndexPath:Bool]?
    var selectedOrder: String?
    var isGroceriesSearch: Bool = true
    var facet: NSArray? = nil

    var delegate:FilterProductsViewControllerDelegate?
    var successCallBack : (() -> Void)? = nil
    
    var prices: NSArray?
    var upcPrices: NSArray?
    var upcByPrice: NSArray?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel!.text = NSLocalizedString("filter.title", comment:"")
        
        
        let iconImage = UIImage(color: WMColor.green, size: CGSizeMake(55, 22), radius: 11) // UIImage(named:"button_bg")
        let iconSelected = UIImage(color: WMColor.green, size: CGSizeMake(55, 22), radius: 11)
        
        self.applyButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.applyButton!.setBackgroundImage(iconImage, forState: .Normal)
        self.applyButton!.setBackgroundImage(iconSelected, forState: .Selected)
        self.applyButton!.setTitle(NSLocalizedString("filter.apply", comment:""), forState: .Normal)
        self.applyButton!.setTitleColor(WMColor.navigationHeaderBgColor, forState: .Normal)
        self.applyButton!.addTarget(self, action: "applyFilters", forControlEvents: .TouchUpInside)
        self.applyButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        
        self.header!.addSubview(self.applyButton!)

        self.removeButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.removeButton!.setBackgroundImage(iconImage, forState: .Normal)
        self.removeButton!.setBackgroundImage(iconSelected, forState: .Selected)
        self.removeButton!.setTitle(NSLocalizedString("filter.button.clean", comment:""), forState: .Normal)
        self.removeButton!.setTitleColor(WMColor.navigationFilterTextColor, forState: .Normal)
        self.removeButton!.addTarget(self, action: "removeFilters", forControlEvents: .TouchUpInside)
        self.removeButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.removeButton!.hidden = true
        self.removeButton!.layer.cornerRadius = 11
        
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
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Solo en el caso de que la busqueda sea con texto
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.WithText {
            self.loadLinesForSearch()
        }
        else {
            self.tableView!.delegate = self
            self.tableView!.dataSource = self
            self.tableView!.reloadData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var headerBounds = self.header!.frame.size
        var buttonWidth: CGFloat = 55.0
        var buttonHeight: CGFloat = 22.0
        self.applyButton!.frame = CGRectMake(headerBounds.width - (buttonWidth + 16.0), (headerBounds.height - buttonHeight)/2, buttonWidth, buttonHeight)
        self.removeButton!.frame = CGRectMake(self.applyButton!.frame.minX - (buttonWidth + 16.0), (headerBounds.height - buttonHeight)/2, buttonWidth, buttonHeight)
        if self.originalSearchContext != nil && self.originalSearchContext == SearchServiceContextType.WithText && self.originalSearchContext != self.searchContext {
            self.titleLabel!.frame = CGRectMake(46.0, 0, self.header!.frame.width - (46.0 + (buttonWidth*2) + 32.0), self.header!.frame.maxY)
        }

        var bounds = self.view.frame
        self.tableView!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, bounds.height - self.header!.frame.height)
    }
    
    //MARK: - Actions
    
    func applyFilters() {

        var lastSelected:Int? = nil
        if self.selectedElements != nil && self.selectedElements!.count > 0 {
            for var idx = self.selectedElements!.count - 1; idx >= 0; idx-- {
                if self.selectedElements![idx] {
                    lastSelected = idx
                    break
                }
            }
        }
        
        //Filtros de MG Funcionan diferente
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG && facet != nil {
            //self.successCallBack!()
            
            var intIx = 0
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
                    let itemFacet = self.facet![selElement.section - 1] as [String:AnyObject]
                    if  let typeFacet = itemFacet["type"] as? String {
                        if typeFacet == "check" {
                            let allnameFacets = itemFacet["itemsFacet"] as [[String:AnyObject]]
                            
                            if selElement.row  > 0 {
                                let facet = allnameFacets[selElement.row - 1]
                                let allUpcs = facet["upcs"] as [String]
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
                                      upcs.append(upcVal as String)
                                }
                            }
                        }
                    }
                }
            }
            
            self.delegate?.apply(self.selectedOrder!, upcs: upcs)
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
            var element = self.tableElements![lastSelected!] as [String:AnyObject]
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
        
        if successCallBack != nil {
            self.successCallBack!()
        }else {
            self.navigationController!.popViewControllerAnimated(true)
        }
        
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
        
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.WithText {
            return 2
        }
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG && facet != nil {
            return 1 + facet!.count
        }
        return 1
       // return self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.WithText ? 2 : 1
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.WithText {
            return self.tableElements != nil ? self.tableElements!.count : 0
        }
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG && facet != nil {
            let itemFacet = self.facet![section - 1] as [String:AnyObject]
            if  let typeFacet = itemFacet["type"] as? String {
                if typeFacet == "check" {
                    let allnameFacets = itemFacet["itemsFacet"] as [[String:AnyObject]]
                    return allnameFacets.count + 1
                }
                if typeFacet == JSON_SLIDER {
                    return 1
                }
            }
           
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.ORDERCELL_ID, forIndexPath: indexPath) as FilterOrderViewCell
            cell.delegate = self
            cell.setValues(self.selectedOrder!)
            return cell
        }
        
        
        
        
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG && facet != nil {
            
                
            let facetInfo = facet![indexPath.section - 1] as NSDictionary
            
            if  let typeFacet = facetInfo["type"] as? String {
                if typeFacet == "check" {
                    let listCell = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID, forIndexPath: indexPath) as FilterCategoryViewCell

                    var selected = false
                    let valSelected =  self.selectedElementsFacet?[indexPath]
                    if ((valSelected) != nil) {
                        selected = valSelected!
                    }
                    
                    if indexPath.row > 0 {
                        let facetitem = facetInfo["itemsFacet"] as [[String:AnyObject]]
                        var item = facetitem[indexPath.row - 1]
                        listCell.setValuesFacets(item, selected: selected)
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
                        listCell.setValuesSelectAll(selected)
                    }
                    return listCell
                    
                }
                if typeFacet == JSON_SLIDER {
                    
                    //self.selectedElementsFacet!.updateValue(true, forKey: indexPath)
                    
                    self.processPriceFacet(facetInfo)
                    let cell = tableView.dequeueReusableCellWithIdentifier(self.sliderCellId) as SliderTableViewCell
                    var sliderCell : SliderTableViewCell = cell as SliderTableViewCell
                    if self.prices != nil {
                        sliderCell.setValues(self.prices!)
                        sliderCell.delegate = self
                    }
                    //sliderCell.delegate = self
                    return sliderCell
                }
            }
            
        } else {
            let listCell = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID, forIndexPath: indexPath) as FilterCategoryViewCell
            var selected = self.selectedElements![indexPath.row]
            var item = self.tableElements![indexPath.row] as [String:AnyObject]
            listCell.setValues(item, selected:selected)
            return listCell
        }
        return UITableViewCell()
    }
    
    func processPriceFacet(fitem:NSDictionary) {
        if let itemsFacet = fitem[JSON_KEY_FACET_ITEMS] as? NSArray {
            var array = Array<Double>()
            var mirror = Array<NSArray>()
            for var idx = 0; idx < itemsFacet.count; idx++ {
                var item = itemsFacet[idx] as NSDictionary
                if let value = item[JSON_KEY_FACET_ITEMNAME] as? NSString {
                    var values = value.componentsSeparatedByString("-")
                    if idx == itemsFacet.count - 1 {
                        var price = values[0] as NSString
                        var lastPrice = values[1] as NSString
                        array.append(price.doubleValue)
                        array.append(lastPrice.doubleValue)
                    }
                    else {
                        var price = values[0] as NSString
                        array.append(price.doubleValue)
                    }
                }
                mirror.append(item[JSON_KEY_FACET_UPCS] as NSArray)
            }
            self.prices = array
            self.upcPrices = mirror
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 103.0
        }
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG && facet != nil {
            let itemFacet = self.facet![indexPath.section - 1] as [String:AnyObject]
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
        
        //Filtros de MG Funcionan diferente
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG && facet != nil {
            //self.selectedElements![indexPath.row] = true
            if indexPath.row == 0 {
                self.selectedElementsFacet = [:]
                self.tableView?.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
                return
            }
            
            var currentVal = true
            if let savedVal = self.selectedElementsFacet![indexPath] {
                currentVal = !savedVal
            }
            
           
            self.selectedElementsFacet!.updateValue(currentVal, forKey: indexPath)
            for keyObj in self.selectedElementsFacet!.keys {
                if keyObj.row == 0 {
                    self.selectedElementsFacet?.updateValue(false, forKey: keyObj)
                }
            }
            self.tableView?.reloadRowsAtIndexPaths([indexPath,NSIndexPath(forRow: 0, inSection: indexPath.section)], withRowAnimation: UITableViewRowAnimation.Fade)
            //self.removeButton!.hidden = false
            
            return
        }
        
        var isAlreadyOpen = self.selectedElements![indexPath.row]
        if isAlreadyOpen {
            return
        }
        
        var visibleCells = tableView.visibleCells()
        for var idx = 0; idx < visibleCells.count; idx++ {
            if let cell = visibleCells[idx] as? FilterCategoryViewCell {
                cell.check!.highlighted = false
            }
        }
        
        var item = self.tableElements![indexPath.row] as [String:AnyObject]
        var itemLevel = (item["level"] as NSNumber).integerValue
        var itemId = item["id"] as String
        var itemParentId = item["parentId"] as String
        
        if itemLevel != 2 {
            var indexes:[AnyObject] = []
            var filteredElements:[AnyObject] = []
            for var idx = 0; idx < self.tableElements!.count; idx++ {
                var element = self.tableElements![idx] as [String:AnyObject]
                var elementId = element["id"] as String
                var elementParentId = element["parentId"] as String
                var level = (element["level"] as NSNumber).integerValue
                
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
            self.selectedElements = [Bool](count: self.tableElements!.count, repeatedValue: false)
            tableView.deleteRowsAtIndexPaths(indexes, withRowAnimation: .Automatic)
            
            var updatedIndex:NSIndexPath? = nil
            for var idx = 0; idx < self.tableElements!.count; idx++ {
                var element = self.tableElements![idx] as [String:AnyObject]
                var elementId = element["id"] as String
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
            }
                
            else if let line = item["lines"] as? [String:AnyObject] {
                self.insertItems(line, atIndexPath: updatedIndex!)
            }
        }
        else {
            self.selectedElements![indexPath.row] = true
        }

        for var idx = 0; idx < self.selectedElements!.count; idx++ {
            if self.selectedElements![idx] {
                if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: idx, inSection: 1)) as? FilterCategoryViewCell {
                    cell.check!.highlighted = true
                }
            }
        }

    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header = UIView(frame: CGRectMake(0.0, 0.0, self.view.frame.width, 36.0))
        header.backgroundColor = WMColor.UIColorFromRGB(0xEEEEEE)
        
        var title = UILabel(frame: CGRectMake(16.0, 0.0, self.view.frame.width - 32.0, 36.0))
        title.backgroundColor = WMColor.UIColorFromRGB(0xEEEEEE)
        title.textColor = WMColor.UIColorFromRGB(0x797F89)
        title.font = WMFont.fontMyriadProRegularOfSize(11)
        if section == 0 {
            title.text = NSLocalizedString("filter.section.order", comment:"")
        }
        else {
            if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.WithText {
                title.text = NSLocalizedString("filter.section.categories", comment:"")
            }
            if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.WithCategoryForMG && facet != nil {
                let facetName = facet![section - 1] as NSDictionary
                title.text = facetName["name"] as String!
            }
            
        }
        header.addSubview(title)
        
        return header
    }
    
    //MARK: - Utils
    
    func insertItems(items:[String:AnyObject], atIndexPath indexPath:NSIndexPath) {
        if items.keys.array.count > 0 {
            var indexes:[AnyObject] = []
            var idx = 0
            for key in items.keys {
                var index = indexPath.row + (idx + 1)
                var inner = items[key] as [String:AnyObject]
                indexes.append(NSIndexPath(forRow: index, inSection: 1))
                self.tableElements!.insert(inner, atIndex: index)
                self.selectedElements!.insert(false, atIndex: index)
                idx++
            }
            self.tableView!.insertRowsAtIndexPaths(indexes, withRowAnimation: .Automatic)
        }
    }
    
    func deleteItems(items:[AnyObject], atIndexPath indexPath:NSIndexPath) {
        if items.count > 0 {
            var indexes:[AnyObject] = []
            for var idx = 0; idx < items.count; idx++ {
                var itemToDelete = items[idx] as [String:AnyObject]
                var id = itemToDelete["id"] as String
                for var idxe = 0; idxe < self.tableElements!.count; idxe++ {
                    var innerElement:AnyObject = self.tableElements![idxe]
                    var innerId = innerElement["id"] as String
                    if id == innerId {
                        self.tableElements!.removeAtIndex(idxe)
                        indexes.append(NSIndexPath(forRow: idxe, inSection: 1))
                        break
                    }
                }
            }
        }
    }
    
    func itemIsContained(item:[String:AnyObject], node:[String:AnyObject]) -> Bool {
        var isContained = false
        var itemLevel = (item["level"] as NSNumber).integerValue
        var nodeLevel = (node["level"] as NSNumber).integerValue
        if itemLevel != nodeLevel && itemLevel > nodeLevel {
            var itemId = item["id"] as String
            //Find as family
            if nodeLevel == 0 {
                let families = node["families"] as [String:AnyObject]
                for var idx = 0; idx < families.keys.array.count; idx++ {
                    var family = families[families.keys.array[idx]] as [String:AnyObject]
                    if itemLevel == 1 {
                        var familyId = family["id"] as String
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
                let lines = node["lines"] as [String:AnyObject]
                for var idx = 0; idx < lines.keys.array.count; idx++ {
                    var line = lines[lines.keys.array[idx]] as [String:AnyObject]
                    var lineId = line["id"] as String
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

        var success = { () -> Void in
            //Recarga view
            dispatch_async(dispatch_get_main_queue(), {
                NSLog("Recagra view")
                self.loading!.stopAnnimating()
                self.loading = nil
                self.tableView!.delegate = self
                self.tableView!.dataSource = self
                self.tableView!.reloadData()
            })
        }
        
        var errorBlock = { (error:NSError) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                 NSLog("Recagra view2")
                self.tableView!.delegate = self
                self.tableView!.dataSource = self
                self.loading!.stopAnnimating()
                self.loading = nil
                self.tableView!.reloadData()
            })
        }
        
        if isGroceriesSearch {
            self.invokeRetrieveLinesForGroceries(successBlock:success, errorBlock: errorBlock)
        } else {
            self.invokeRetrieveLinesForMG(successBlock: success, errorBlock: errorBlock)
        }
        
//        self.invokeRetrieveLinesForGroceries(
//            successBlock: { () -> Void in
//                self.invokeRetrieveLinesForMG(successBlock: success, errorBlock: errorBlock)
//            }, errorBlock: { (error:NSError) -> Void in
//                self.invokeRetrieveLinesForMG(successBlock: success, errorBlock: errorBlock)
//            }
//        )
    }
    
    func invokeRetrieveLinesForGroceries(#successBlock:(()->Void)?, errorBlock:((NSError)->Void)?) {
        NSLog("self.categories = categories")
        var service = GRLinesForSearchService()
        service.callService(service.buildParams(self.textToSearch!),
            successBlock: { (categories: [AnyObject]) -> Void in
                    NSLog("self.categories = categories")
                    self.categories = categories
                    NSLog("self.tableElements = [AnyObject](categories)")
                    self.tableElements = [AnyObject](categories)
                    NSLog("if self.tableElements?.count > 0 {")
                    if self.tableElements?.count > 0 {
                        NSLog("self.selectedElements = [Bool](count: self.tableElements!.count, repeatedValue: false)")
                        self.selectedElements = [Bool](count: self.tableElements!.count, repeatedValue: false)
                    }
                    NSLog("successBlock?()")
                    successBlock?()
                    NSLog("End")
            },
            errorBlock: { (error:NSError) -> Void in
                println("Error at retrieve lines for groceries")
                errorBlock?(error)
                return
            }
        )
    }
    
    func invokeRetrieveLinesForMG(#successBlock:(()->Void)?, errorBlock:((NSError)->Void)?) {
        var service = LinesForSearchService()
        service.callService(service.buildParams(self.textToSearch!),
            successBlock: { (categories:[AnyObject]) -> Void in
                NSLog("Inicia pintado de datos")
                if self.categories != nil {
                    var array = self.categories! + categories
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
                    var array = self.tableElements! + categories
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
                }
                
                if self.tableElements?.count > 0 {
                    self.selectedElements = [Bool](count: self.tableElements!.count, repeatedValue: false)
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
        self.selectedOrder = order
    }

    
    func rangerSliderDidChangeValues(forLowPrice low:Int, andHighPrice high:Int) {
        self.filterProductsByPrice(forLowPrice: low, andHighPrice: high)
    }
    
    func filterProductsByPrice(forLowPrice low:Int, andHighPrice high:Int) {
        //En caso de que el rango sea completo, no se filtran los upcs
        let count = (self.prices!.count - 1)
        if low == 0 && high == count {
            self.upcByPrice = nil
            return
        }
        var array = Array<String>()
        for var idx = low; idx < high; idx++ {
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
    
}
