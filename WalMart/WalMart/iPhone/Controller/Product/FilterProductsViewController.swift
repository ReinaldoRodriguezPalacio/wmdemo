//
//  FilterProductsViewController.swift
//  WalMart
//
//  Created by neftali on 19/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol FilterProductsViewControllerDelegate: class {
    func apply(_ order:String, filters:[String:Any]?, isForGroceries flag:Bool)
    func apply(_ order:String, upcs: [String])
    func removeFilters()
    func removeSelectedFilters()
    func sendBrandFilter(_ brandFilter:String)
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
    var isFromTiresSearch: Bool! = false
    
    var textToSearch: String?
    var originalSearchContext: SearchServiceContextType?
    var searchContext: SearchServiceContextType?
    var categories: [[String:Any]]?
    var tableElements: [[String:Any]]?
    var selectedElements: [Bool]?
    var selectedElementsFacet: [IndexPath:Bool]?
    var selectedOrder: String?
    var isGroceriesSearch: Bool = true
    var facetGr: [Any]? = nil
    var selectedFacetGr: [String:Bool]?

    weak var delegate:FilterProductsViewControllerDelegate?
    var successCallBack : (() -> Void)? = nil
    var backFilter : (() -> Void)? = nil
    
    var prices: [Double]?
    var upcPrices: [[String]]?
    var upcByPrice: [String]?
    var brandFacets: [String] = []
    var isTextSearch: Bool = false
    var needsToValidateData = true
    var facet: [[String:Any]]? = nil

    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_FILTER.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel!.text = NSLocalizedString("filter.title", comment:"")
        self.titleLabel!.textAlignment =  .center
        
        let iconImage = UIImage(color: WMColor.green, size: CGSize(width: 55, height: 22), radius: 11) // UIImage(named:"button_bg")
        let iconSelected = UIImage(color: WMColor.green, size: CGSize(width: 55, height: 22), radius: 11)
        
        self.applyButton = UIButton(type: .custom)
        self.applyButton!.setBackgroundImage(iconImage, for: UIControlState())
        self.applyButton!.setBackgroundImage(iconSelected, for: .selected)
        self.applyButton!.setTitle(NSLocalizedString("filter.apply", comment:""), for: UIControlState())
        self.applyButton!.setTitleColor(WMColor.light_light_gray, for: UIControlState())
        self.applyButton!.addTarget(self, action: #selector(FilterProductsViewController.applyFilters), for: .touchUpInside)
        self.applyButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        
        self.header!.addSubview(self.applyButton!)

        self.removeButton = UIButton(type: .custom)
        self.removeButton!.setBackgroundImage(iconImage, for: UIControlState())
        self.removeButton!.setBackgroundImage(iconSelected, for: .selected)
        self.removeButton!.setTitle(NSLocalizedString("filter.button.clean", comment:""), for: UIControlState())
        self.removeButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.removeButton!.addTarget(self, action: #selector(FilterProductsViewController.removeFilters), for: .touchUpInside)
        self.removeButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.removeButton!.isHidden = true
        self.removeButton!.layer.cornerRadius = 11
        
        /*if self.originalSearchContext != nil && self.originalSearchContext == SearchServiceContextType.WithText && self.originalSearchContext != self.searchContext {
            self.removeButton!.hidden = false
        }
        
        self.header!.addSubview(self.removeButton!)
*/
        self.tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0), style: .plain)
        self.tableView!.separatorStyle = .none
        self.view.addSubview(self.tableView!)
        
        self.tableView!.register(FilterOrderViewCell.self, forCellReuseIdentifier: self.ORDERCELL_ID)
        self.tableView!.register(FilterCategoryViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        self.tableView!.register(SliderTableViewCell.self, forCellReuseIdentifier: self.sliderCellId)
        
        self.selectedElementsFacet = [:]
        self.selectedFacetGr = [:]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Solo en el caso de que la busqueda sea con texto o camfind
        BaseController.setOpenScreenTagManager(titleScreen: "Filtros", screenName: self.getScreenGAIName())
        self.isTextSearch =  self.originalSearchContext! == SearchServiceContextType.withText || self.originalSearchContext! == SearchServiceContextType.withTextForCamFind
        
        if self.originalSearchContext != nil && self.isTextSearch {
            self.loadLinesForSearch()
        }
        else {
            self.tableView!.delegate = self
            self.tableView!.dataSource = self
            self.tableView!.reloadData()
        }
        validateFacetData()
    }
    
    func validateFacetData() {
        if facet != nil {
            var facetEnd : [[String:Any]] = []
            for facetItemsCount in facet! {
                let facetitem = facetItemsCount["itemsFacet"] as! [[String:Any]]
                var newItemsFacet : [[String:Any]] = []
                for itemFac in facetitem {
                    if itemFac["itemName"] as! String != ""{
                        newItemsFacet.append(itemFac)
                    }
                }
               
                
                
                if newItemsFacet.count > 0 {
                    facetEnd.append(["itemsFacet":newItemsFacet,"type":facetItemsCount["type"]!,"name":facetItemsCount["name"]!,"order":facetItemsCount["order"]!])
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
        self.applyButton!.frame = CGRect(x: headerBounds.width - (buttonWidth + 16.0), y: (headerBounds.height - buttonHeight)/2, width: buttonWidth, height: buttonHeight)
        self.removeButton!.frame = CGRect(x: self.applyButton!.frame.minX - (buttonWidth + 16.0), y: (headerBounds.height - buttonHeight)/2, width: buttonWidth, height: buttonHeight)

        let bounds = self.view.frame
        self.tableView!.frame = CGRect(x: 0.0, y: self.header!.frame.maxY, width: bounds.width, height: bounds.height - self.header!.frame.height)
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
        if self.originalSearchContext != nil && (self.originalSearchContext! == SearchServiceContextType.withCategoryForMG || self.originalSearchContext! == SearchServiceContextType.withCategoryForTiresSearch) && facet != nil {
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
                            self.navigationController!.popViewController(animated: true)
                        }
                        return
                    }
                    let itemFacet = self.facet![selElement.section - 1] 
                    if  let typeFacet = itemFacet["type"] as? String {
                        if typeFacet == "check" {
                            let allnameFacets = itemFacet["itemsFacet"] as! [[String:Any]]
                            
                            if selElement.row  > 0 {
                                let facet = allnameFacets[selElement.row - 1]
                                let allUpcs = facet["upcs"] as! [String]
                                for upcVal in allUpcs {
                                    if upcByPrice != nil {
                                        if  self.upcByPrice!.contains(where: {return $0 == upcVal})  {
                                            upcs.append(upcVal)
                                        }
                                    }else {
                                        upcs.append(upcVal)
                                    }
                                }
                            }
                            else {
                                for upcVal in self.upcByPrice! {
                                      upcs.append(upcVal )
                                }
                            }
                        }
                    }
                }
            }
            
            self.delegate?.apply(self.selectedOrder!, upcs: upcs)
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_APPLY_FILTER.rawValue, label: "")
            if successCallBack != nil {
                self.successCallBack!()
            }else {
                self.navigationController!.popViewController(animated: true)
            }
            return
        }
        
        var groceriesType = self.searchContext == SearchServiceContextType.withCategoryForGR
        if lastSelected != nil {
            var element = self.tableElements![lastSelected!] 
            if (element["path"] as? String) != nil {
                if let type = element["responseType"] as? String {
                    if let roType = ResultObjectType(rawValue: type) {
                        groceriesType = ResultObjectType.Groceries == roType
                    }
                }
            }
        }
        
        var filters:[String:Any] = [:]
        if self.filterLine != "" {
            filters[JSON_KEY_IDLINE] = self.filterLine//line
        }
        if  self.filterFamily != "" {
            filters[JSON_KEY_IDFAMILY] = self.filterFamily//family
        }
        if self.filterDepto != "" {
            filters[JSON_KEY_IDDEPARTMENT] = self.filterDepto//department
        }
        
        print("Departamento::\(self.filterDepto) -- Familia::\(self.filterFamily) -- Linea::\(self.filterLine)")
        
        self.delegate?.apply(self.selectedOrder!, filters: filters.count > 0 ? filters : nil, isForGroceries: groceriesType)
        if successCallBack != nil {
            self.successCallBack!()
        }else {
            self.navigationController!.popViewController(animated: true)
        }
       self.delegate?.removeSelectedFilters()
        
    }
    

    
    func removeFilters() {
        self.delegate?.removeFilters()
        if successCallBack != nil {
            self.successCallBack!()
        }else {
            self.navigationController!.popViewController(animated: true)
        }
    }
 
    //MARK: - UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if self.originalSearchContext != nil && self.isTextSearch {
                 return 2
        }
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.withCategoryForMG && facet != nil && facet?.count > 0 && !isFromTiresSearch {
            return 1 + facet!.count
        }
        
        if self.facetGr != nil && self.facetGr?.count > 0 {// new
            return 2
        }
        return 1
        

        
    }


   
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if self.originalSearchContext != nil && self.isTextSearch {
            return self.tableElements != nil ? self.tableElements!.count : 0
        }
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.withCategoryForMG && facet != nil {
            let itemFacet = self.facet![section - 1] 
            if  let typeFacet = itemFacet["type"] as? String {
                if typeFacet == "check" {
                    let allnameFacets = itemFacet["itemsFacet"] as! [[String:Any]]
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.ORDERCELL_ID, for: indexPath) as! FilterOrderViewCell
            cell.delegate = self
            cell.setValues(self.selectedOrder!)
            return cell
        }
        
        
        if self.facetGr != nil{
            
            let listCell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID, for: indexPath) as! FilterCategoryViewCell
            
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
                let _ = selectedFacetGr?.updateValue(selected,forKey: item)
                listCell.setValuesFacets(nil,nameBrand:item, selected: selected)
                
            }else{
                
                if self.selectedFacetGr!.count == 0  {
                    self.selectedFacetGr!.updateValue(true, forKey: item)
                    selected = true
                } else {
                    selected = false
                }
                
                listCell.setValuesSelectAll(selected)
            }
            
            return listCell
        }
        
        
        
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.withCategoryForMG && facet != nil {
            let facetInfo = facet![indexPath.section - 1] 
            
            if  let typeFacet = facetInfo["type"] as? String {
                if typeFacet == "check" {
                    let listCell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID, for: indexPath) as! FilterCategoryViewCell

                    var selected = false
                    let valSelected =  self.selectedElementsFacet?[indexPath]
                    if ((valSelected) != nil) {
                        selected = valSelected!
                    }
                    
                    if indexPath.row > 0 {
                        let facetitem = facetInfo["itemsFacet"] as! [[String:Any]]
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
                        listCell.setValuesSelectAll(selected)
                    }
                    return listCell
                    
                }
                if typeFacet == JSON_SLIDER {
                    
                    //self.selectedElementsFacet!.updateValue(true, forKey: indexPath)
                    
                    self.processPriceFacet(facetInfo)
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.sliderCellId) as! SliderTableViewCell
                    let sliderCell : SliderTableViewCell = cell as SliderTableViewCell
                    if self.prices != nil {
                        sliderCell.setValuesSlider(self.prices!)
                        sliderCell.delegate = self
                    }
                    //sliderCell.delegate = self
                    return sliderCell
                }
            }
            
        } else {
            let listCell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID, for: indexPath) as! FilterCategoryViewCell
            if self.selectedElements != nil {
                let selected = self.selectedElements![indexPath.row]
                let item = self.tableElements![indexPath.row] 
                listCell.setValues(item, selected:selected)
            }
            return listCell
        }
        return UITableViewCell()
    }
    
    
    func processPriceFacet(_ fitem:[String:Any]) {
        if let itemsFacet = fitem[JSON_KEY_FACET_ITEMS] as? [Any] {
            var array = Array<Double>()
            var mirror = Array<[String]>()
            for idx in 0 ..< itemsFacet.count {
                let item = itemsFacet[idx] as! [String:Any]
                if let value = item[JSON_KEY_FACET_ITEMNAME] as? NSString {
                    var values = value.components(separatedBy: "-")
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
                mirror.append(item[JSON_KEY_FACET_UPCS] as! [String])
            }
            self.prices = array
            self.upcPrices = mirror
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 103.0
        }
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.withCategoryForMG && facet != nil {
            let itemFacet = self.facet![indexPath.section - 1] 
            if  let typeFacet = itemFacet["type"] as? String {
                if typeFacet == JSON_SLIDER {
                    return 73.0
                }
            }
            
        }



        return 36.0
    }
    
    var filterDepto  = ""
    var filterFamily  = ""
    var filterLine  = ""
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        
        if self.facetGr != nil {
            if indexPath.row == 0 {
                self.selectedFacetGr = [:]
                self.tableView?.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.fade)
                ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SEARCH_PRODUCT_FILTER.rawValue, action: WMGAIUtils.ACTION_BRAND_SELECTION.rawValue, label: "Seleccionar todos")
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
            self.tableView?.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
            return
        }
        
        //Filtros de MG Funcionan diferente
        if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.withCategoryForMG && facet != nil {
            //self.selectedElements![indexPath.row] = true
            if indexPath.row == 0 {
                self.selectedElementsFacet = [:]
                self.tableView?.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.fade)
                ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SEARCH_PRODUCT_FILTER.rawValue, action: WMGAIUtils.ACTION_BRAND_SELECTION.rawValue, label: "Seleccionar todos")
                return
            }
            
            var currentVal = true
            var countselected = 0
            var ixSelected : IndexPath? = nil
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
                    let _ = self.selectedElementsFacet?.updateValue(false, forKey: keyObj)
                }
            }
            ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SEARCH_PRODUCT_FILTER.rawValue, action: WMGAIUtils.ACTION_BRAND_SELECTION.rawValue, label: self.brandFacets[indexPath.row - 1])
            
            self.tableView?.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
            //self.tableView?.reloadRowsAtIndexPaths([indexPath,NSIndexPath(forRow: 0, inSection: indexPath.section)], withRowAnimation: UITableViewRowAnimation.Fade)
            //self.removeButton!.hidden = false
            
            return
        }
        
        let isAlreadyOpen = self.selectedElements![indexPath.row]
        if isAlreadyOpen {
            return
        }
        
        var visibleCells = tableView.visibleCells
        for idx in 0 ..< visibleCells.count {
            if let cell = visibleCells[idx] as? FilterCategoryViewCell {
                cell.check!.isHighlighted = false
            }
        }
        
        var item = self.tableElements![indexPath.row] 
        let itemLevel = (item["level"] as! NSNumber).intValue
        let itemId = item["id"] as! String
        let itemIdNew = " \(item["id"] as! String)"
        let itemParentId = item["parentId"] as! String
       
        
        if itemLevel == 0 {
            self.filterDepto = itemId
            self.filterFamily = ""
        }
      
        if itemIdNew.contains(" f-") ||  itemLevel == 1{
            self.filterFamily = itemId
             self.filterLine = ""
        }
        if itemIdNew.contains(" l-") ||  itemLevel == 2{
            self.filterLine = itemId
        }
        
         print(" \(self.filterDepto) -- \(self.filterFamily) \(self.filterLine)")
        
        if itemLevel != 2 {
            var indexes:[IndexPath] = []
            var filteredElements:[[String:Any]] = []
            for idx in 0 ..< self.tableElements!.count {
                var element = self.tableElements![idx] 
                let elementId = element["id"] as! String
                let elementParentId = element["parentId"] as! String
                let level = (element["level"] as! NSNumber).intValue
                
                if level == 0 || itemId == elementId || itemParentId == elementParentId {
                    filteredElements.append(element)
                    continue
                }
                if self.itemIsContained(item, node: element) {
                    filteredElements.append(element)
                    continue
                }
                
                if level > 0 {
                    indexes.append(IndexPath(row: idx, section: 1))
                }
            }
            self.tableElements = filteredElements
            
            self.selectedElements = [Bool](repeating: false, count: self.tableElements!.count)
            tableView.deleteRows(at: indexes, with: .automatic)
            
            var updatedIndex:IndexPath? = nil
            for idx in 0 ..< self.tableElements!.count {
                var element = self.tableElements![idx] 
                let elementId = element["id"] as! String
                if self.itemIsContained(item, node: element) {
                    self.selectedElements![idx] = true
                }
                if itemId == elementId {
                    updatedIndex = IndexPath(row: idx, section: 1)
                    self.selectedElements![idx] = true
                }
            }
            
            if let family = item["families"] as? [String:Any] {
                self.insertItems(family, atIndexPath: updatedIndex!)
            }
                
            else if let line = item["lines"] as? [String:Any] {
                self.insertItems(line, atIndexPath: updatedIndex!)
            }
        }
        else {
            self.selectedElements![indexPath.row] = true
        }

        for idx in 0 ..< self.selectedElements!.count {
            if self.selectedElements![idx] {
                if let cell = tableView.cellForRow(at: IndexPath(row: idx, section: 1)) as? FilterCategoryViewCell {
                    cell.check!.isHighlighted = true
                }
            }
        }

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 36.0))
        header.backgroundColor = WMColor.light_gray
        
        let title = UILabel(frame: CGRect(x: 16.0, y: 0.0, width: self.view.frame.width - 32.0, height: 36.0))
        //title.backgroundColor = WMColor.light_light_gray
        title.textColor = WMColor.gray
        title.font = WMFont.fontMyriadProRegularOfSize(11)
        if section == 0 {
            title.text = NSLocalizedString("filter.section.order", comment:"")
        }
        else {
            if self.originalSearchContext != nil && self.isTextSearch {
                title.text = NSLocalizedString("filter.section.categories", comment:"")
            }
            if self.originalSearchContext != nil && self.originalSearchContext! == SearchServiceContextType.withCategoryForMG && facet != nil {
                let facetName = facet![section - 1] 
                title.text = facetName["name"] as? String
            }
            if self.facetGr !=  nil {
                title.text = "Marca"
            }
            
        }
        header.addSubview(title)
        
        return header
    }
    
    //MARK: - Utils
    
    func insertItems(_ items:[String:Any], atIndexPath indexPath:IndexPath) {
        if items.keys.count > 0 {
            var indexes:[IndexPath] = []
            var idx = 0
            for key in items.keys {
                let index = indexPath.row + (idx + 1)
                let inner = items[key] as! [String:Any]
                indexes.append(IndexPath(row: index, section: 1))
                self.tableElements!.insert(inner, at: index)
                self.selectedElements!.insert(false, at: index)
                idx += 1
            }
            self.tableView!.insertRows(at: indexes, with: .automatic)
        }
    }
    
    func deleteItems(_ items:[Any], atIndexPath indexPath:IndexPath) {
        if items.count > 0 {
            var indexes:[Any] = []
            for idx in 0 ..< items.count {
                var itemToDelete = items[idx] as! [String:Any]
                let id = itemToDelete["id"] as! String
                for idxe in 0 ..< self.tableElements!.count {
                    let innerElement = self.tableElements![idxe]
                    let innerId = innerElement["id"] as! String
                    if id == innerId {
                        self.tableElements!.remove(at: idxe)
                        indexes.append(IndexPath(row: idxe, section: 1) as AnyObject)
                        break
                    }
                }
            }
        }
    }
    
    func itemIsContained(_ item:[String:Any], node:[String:Any]) -> Bool {
        var isContained = false
        let itemLevel = (item["level"] as! NSNumber).intValue
        let nodeLevel = (node["level"] as! NSNumber).intValue
        if itemLevel != nodeLevel && itemLevel > nodeLevel {
            let itemId = item["id"] as! String
            //Find as family
            if nodeLevel == 0 {
                let families = node["families"] as! [String:Any]
                for idx in 0 ..< families.keys.count {
                    var family = families[Array(families.keys)[idx]] as! [String:Any]
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
                let lines = node["lines"] as! [String:Any]
                for idx in 0 ..< Array(lines.keys).count {
                    var line = lines[Array(lines.keys)[idx]] as! [String:Any]
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
        self.loading = WMLoadingView(frame: CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46))
        self.loading!.startAnnimating(self.isVisibleTab)
        self.view.addSubview(self.loading!)
        
        self.categories = nil
        self.tableElements = nil
        self.selectedElements = nil

        let success = { () -> Void in
            //Recarga view
            DispatchQueue.main.async(execute: {
                NSLog("Recagra view")
                self.loading?.stopAnnimating()
                self.loading = nil
                self.tableView?.delegate = self
                self.tableView?.dataSource = self
                self.tableView?.reloadData()
            })
        }
        
        let errorBlock = { (error:NSError) -> Void in
            DispatchQueue.main.async(execute: {
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
    
    func invokeRetrieveLinesForGroceries(successBlock:(()->Void)?, errorBlock:((NSError)->Void)?) {
        NSLog("self.categories = categories")
        let service = GRLinesForSearchService()
        service.callService(service.buildParams(self.textToSearch!),
                            successBlock: { (categories: [[String:Any]]) -> Void in
                    NSLog("self.categories = categories")
                    self.categories = categories
                    NSLog("self.tableElements = [Any](categories)")
                    self.tableElements = categories
                    NSLog("if self.tableElements?.count > 0 {")
                    if self.tableElements?.count > 0 {
                        NSLog("self.selectedElements = [Bool](count: self.tableElements!.count, repeatedValue: false)")
                        self.selectedElements = [Bool](repeating: false, count: self.tableElements!.count)
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
    
    func invokeRetrieveLinesForMG(successBlock:(()->Void)?, errorBlock:((NSError)->Void)?) {
        let service = LinesForSearchService()
        service.callService(service.buildParams(self.textToSearch!),
                            successBlock: { (categories:[[String:Any]]) -> Void in
                NSLog("Inicia pintado de datos")
                if self.categories != nil {
                    let array = self.categories! + categories
                    self.categories = array
//                    self.categories!.sort { (objectOne:AnyObject, objectTwo:AnyObject) -> Bool in
//                        var deptoOne = objectOne as [String:Any]
//                        var deptoTwo = objectTwo as [String:Any]
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
//                        var deptoOne = objectOne as [String:Any]
//                        var deptoTwo = objectTwo as [String:Any]
//                        var nameOne = deptoOne["name"] as NSString
//                        var nameTwo = deptoTwo["name"] as NSString
//                        return nameOne.caseInsensitiveCompare(nameTwo) == NSComparisonResult.OrderedAscending
//                    }
                }
                else {
                    self.tableElements = categories
                }
                
                if self.tableElements?.count > 0 {
                    self.selectedElements = [Bool](repeating: false, count: self.tableElements!.count)
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
    
    func didChangeOrder(_ order:String) {
        var result = order
        if (self.originalSearchContext! == SearchServiceContextType.withCategoryForGR || self.searchContext! == SearchServiceContextType.withCategoryForGR ) && order == "popularity"{
            result = ""
        }
        self.selectedOrder = result
    }

    
    func rangerSliderDidChangeValues(forLowPrice low:Int, andHighPrice high:Int) {
        self.filterProductsByPrice(forLowPrice: low, andHighPrice: high)
        ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SEARCH_PRODUCT_FILTER.rawValue, action: WMGAIUtils.ACTION_SLIDER_PRICE_RANGE_SELECT.rawValue, label: "\(self.prices![low]) - \(self.prices![high])")
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
            let upcs = self.upcPrices![idx]
            for upc in upcs {
                let string = upc
                array.append(string)
                //if  array.count > 100 {
                //    break
                //}
            }
        }
        self.upcByPrice = array
    }
    
    func addBrandFacet(_ brand:String){
        if !self.brandFacets.contains(brand){
            self.brandFacets.append(brand)
        }
    }
    
    override func back() {
        super.back()
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SEARCH_PRODUCT_FILTER_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BACK_SEARCH_PRODUCT.rawValue , label: "")
        self.backFilter?()
    }
    
}
