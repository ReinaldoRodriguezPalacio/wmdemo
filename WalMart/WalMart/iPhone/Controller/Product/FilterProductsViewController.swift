//
//  FilterProductsViewController.swift
//  WalMart
//
//  Created by neftali on 19/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol FilterProductsViewControllerDelegate {
    //func apply(_ order:String, filters:[String:Any]?, isForGroceries flag:Bool)
    //func apply(_ order:String, upcs: [String])
    func apply(_urlSort:String)
    func removeFilters()
    //func removeSelectedFilters()
    //func sendBrandFilter(_ brandFilter:String)
}

class FilterProductsViewController: NavigationViewController, UITableViewDelegate, UITableViewDataSource, FilterOrderViewCellDelegate {

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
    var isLoading  = false
    
    var textToSearch: String?
    var originalSearchContext: SearchServiceContextType?
    var searchContext: SearchServiceContextType?
    var categories: [Any]?
    var tableElements: [Any]?
    var tableReset: [Any]?
    var selectedElements: [Bool]?
    var selectedElementsFacet: [IndexPath:Bool]?
    var selectedOrder: String?
    //var isGroceriesSearch: Bool = false
    //var facetGr: [String]? = nil
    var selectedFacetGr: [String:Bool]?

    var delegate:FilterProductsViewControllerDelegate?
    var successCallBack : (() -> Void)? = nil
    var backFilter : (() -> Void)? = nil
    
    var prices: [Double]?
    var upcPrices: [String]?
    var upcByPrice: [String]?
    var brandFacets: [String] = []
    var isTextSearch: Bool = false
    var needsToValidateData = true
    //var facet: [[String:Any]]? = nil
    var urlAply = ""
    
    
    var filtersAll: NSDictionary? {
        didSet {
            if self.tableView != nil {
                self.tableView!.reloadData()
            }
        }
    }
    var srtArray: NSArray?
    var navigatArray: NSArray?
    
    //var sliderTableViewCell : SliderTableViewCell?
    var filterOrderViewCell : FilterOrderViewCell?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_FILTER.rawValue
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel!.text = NSLocalizedString("filter.title", comment:"")
        self.titleLabel!.textAlignment =  .center
        
        let iconImage = UIImage(color: WMColor.green, size: CGSize(width: 55, height: 22), radius: 11) // UIImage(named:"button_bg")
        let iconImageRest = UIImage(color: WMColor.blue, size: CGSize(width: 55, height: 22), radius: 11) // UIImage(named:"button_bg")
        let iconSelected = UIImage(color: WMColor.green, size: CGSize(width: 55, height: 22), radius: 11)
        
        self.applyButton = UIButton(type: .custom)
        self.applyButton!.setBackgroundImage(iconImage, for: UIControlState())
        self.applyButton!.setBackgroundImage(iconSelected, for: .selected)
        self.applyButton!.setTitle(NSLocalizedString("filter.apply", comment:""), for: UIControlState())
        self.applyButton!.setTitleColor(WMColor.light_light_gray, for: UIControlState())
        self.applyButton!.addTarget(self, action: #selector(FilterProductsViewController.applyFilters), for: .touchUpInside)
        //self.applyButton!.isHidden = true
        self.applyButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        
        self.header!.addSubview(self.applyButton!)

        self.removeButton = UIButton(type: .custom)
        self.removeButton!.setBackgroundImage(iconImageRest, for: UIControlState())
        self.removeButton!.setBackgroundImage(iconSelected, for: .selected)
        self.removeButton!.setTitle(NSLocalizedString("filter.button.clean", comment:""), for: UIControlState())
        self.removeButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.removeButton!.addTarget(self, action: #selector(FilterProductsViewController.removeFilters), for: .touchUpInside)
        self.removeButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.removeButton!.layer.cornerRadius = 11
        self.header!.addSubview(self.removeButton!)
        
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
        //self.tableView!.register(SliderTableViewCell.self, forCellReuseIdentifier: self.sliderCellId)
        
        self.selectedElementsFacet = [:]
        self.selectedFacetGr = [:]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Solo en el caso de que la busqueda sea con texto o camfind
        self.isTextSearch =  self.originalSearchContext! == SearchServiceContextType.WithText || self.originalSearchContext! == SearchServiceContextType.WithTextForCamFind
        self.showLoadingIfNeeded(hidden: true)
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.reloadData()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let headerBounds = self.header!.frame.size
        let buttonWidth: CGFloat = 55.0
        let buttonHeight: CGFloat = 22.0
        self.applyButton!.frame = CGRect(x: headerBounds.width - (buttonWidth + 16.0), y: (headerBounds.height - buttonHeight)/2, width: buttonWidth, height: buttonHeight)
        self.removeButton!.frame = CGRect(x: self.applyButton!.frame.minX - (buttonWidth + 8.0), y: (headerBounds.height - buttonHeight)/2, width: buttonWidth, height: buttonHeight)
        if self.originalSearchContext != nil && self.originalSearchContext == SearchServiceContextType.WithText && self.originalSearchContext != self.searchContext {
            //self.titleLabel!.frame = CGRectMake(46.0, 0, self.header!.frame.width - (46.0 + (buttonWidth*2) + 32.0), self.header!.frame.maxY)
        }

        let bounds = self.view.frame
        self.tableView!.frame = CGRect(x: 0.0, y: self.header!.frame.maxY, width: bounds.width, height: bounds.height - self.header!.frame.height)
    }
    
    //MARK: - Actions
    func applyFilters() {
        if successCallBack != nil {
            self.successCallBack!()
        }else {
            self.navigationController!.popViewController(animated: true)
        }
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
        let navigation = self.filtersAll!["leftArea"] as! NSArray
        return navigation.count + 1 //(1 = sortOption)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // return 1
            self.srtArray = self.filtersAll!["sortOptions"] as? NSArray
            return self.srtArray!.count
        } else {
            self.navigatArray = self.filtersAll!["leftArea"] as? NSArray
            let options = self.navigatArray![section - 1] as? NSDictionary
            if let refinement = options!["refinements"] as? NSArray {
                return refinement.count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listCell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID, for: indexPath) as! FilterCategoryViewCell
        
        if indexPath.section == 0 {
            /*let cell = tableView.dequeueReusableCell(withIdentifier: self.ORDERCELL_ID, for: indexPath) as! FilterOrderViewCell
            cell.delegate = self
            let itemSorts = self.srtArray![indexPath.row] as? NSDictionary
            cell.setValues(itemSorts!["label"] as! String)
            filterOrderViewCell =  cell
            return cell*/
            
            var item :String = ""
            var selected = false
            //var navigationState = ""
            
            if let itemSorts = self.srtArray![indexPath.row] as? NSDictionary {
                item = itemSorts["label"] as! String
                
                let valSelected =  itemSorts["selected"] as! String
                if ((valSelected) != nil) {
                    selected = valSelected == "true"
                }
                //navigationState = itemSorts["navigationState"] as! String
            }
            listCell.setValuesFacets(nil,nameBrand:item, selected: selected, isOrder: true)
            return listCell
        } else {
            
            let navigation = self.navigatArray![indexPath.section - 1] as! NSDictionary
            if let refinements = navigation["refinements"] as? NSArray {
                
                let propert = refinements[indexPath.row] as! NSDictionary
                
                let textLabel = propert["label"] as! String
                //let urlNavigation = propert["navigationState"] as! String
                
                var selected = false
                let valSelected =  propert["multiselect"] as! String
                if ((valSelected) != nil) {
                    selected = valSelected == "true"
                }
                
                listCell.setValuesFacets(nil,nameBrand:textLabel, selected: selected, isOrder: false)
                return listCell
            }
            
            
            /*let listCell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID, for: indexPath) as! FilterCategoryViewCell
            
            let selected = self.selectedElements![(indexPath as NSIndexPath).row]
            let item = self.tableElements![(indexPath as NSIndexPath).row - 1] as! [String:Any]
            listCell.setValues(item, selected:selected)
            //listCell.setValuesSelectAll(selected, isFacet: false)
            return listCell*/
        }
        
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.loading = WMLoadingView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.view.addSubview(self.loading!)
        self.loading!.startAnnimating(true)
        
        if indexPath.section == 0 {
            if let itemSorts = self.srtArray![indexPath.row] as? NSDictionary {
                urlAply = itemSorts["navigationState"] as! String
            }
        } else {
            let navigation = self.navigatArray![indexPath.section - 1] as! NSDictionary
            if let refinements = navigation["refinements"] as? NSArray {
                
                let propert = refinements[indexPath.row] as! NSDictionary
                
                urlAply = propert["navigationState"] as! String
            }
        }
        //print(urlAply)
        self.showLoadingIfNeeded(hidden: false)
        
        if let cell = tableView.cellForRow(at: IndexPath(row: ((indexPath as NSIndexPath).row), section: (indexPath as NSIndexPath).section)) as? FilterCategoryViewCell {
            
            cell.check!.isHighlighted = !cell.check!.isHighlighted
        }
        
        self.delegate?.apply(_urlSort: urlAply)
        
        /*if successCallBack != nil {
            self.successCallBack!()
        }else {
            self.navigationController!.popViewController(animated: true)
        }*/
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 36.0))
        header.backgroundColor = WMColor.light_gray
        
        let title = UILabel(frame: CGRect(x: 16.0, y: 0.0, width: self.view.frame.width - 32.0, height: 36.0))
        //title.backgroundColor = WMColor.light_light_gray
        title.textColor = WMColor.reg_gray
        title.font = WMFont.fontMyriadProRegularOfSize(11)
        if section == 0 {
            title.text = NSLocalizedString("filter.section.order", comment:"")
        } else {
            
            let navigation = self.navigatArray![section - 1] as! NSDictionary
            let name = navigation["displayName"] as? String != nil ? navigation["displayName"] as? String : ""
            title.text = name
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
                let index = (indexPath as NSIndexPath).row + (idx)
                let inner = items[key] as! [String:Any]
                indexes.append(IndexPath(row: (index + 1), section: 1))
                self.tableElements!.insert(inner as AnyObject, at: index)
                self.selectedElements!.insert(false, at: (index + 1))
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
                    let innerElement:AnyObject = self.tableElements![idxe] as AnyObject
                    let innerId = innerElement["id"] as! String
                    if id == innerId {
                        self.tableElements!.remove(at: idxe)
                        indexes.append(IndexPath(row: (idxe + 1), section: 1) as AnyObject)
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
    
    //MARK: - FilterOrderViewCellDelegate
    
    func didChangeOrder(_ order:String) {
        var result = order
        if (self.originalSearchContext! == SearchServiceContextType.WithCategoryForGR || self.searchContext! == SearchServiceContextType.WithCategoryForGR ) && order == "popularity"{
            result = ""
        }
        self.selectedOrder = result
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
    
    func showLoadingIfNeeded(hidden: Bool ) {
        
        if loading == nil {
            self.loading = WMLoadingView(frame: CGRect(x:11, y:0, width:self.view.bounds.width, height:self.view.bounds.height))
            self.loading!.backgroundColor = UIColor.white
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(false)
        }
        
        if hidden {
            self.loading!.stopAnnimating()
        } else {
            //self.loading = WMLoadingView(frame: CGRect(x: 0, y: 11, width: self.view.bounds.width, height: self.view.bounds.height - 11))
            //self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(true)
        }
    }
    
}
