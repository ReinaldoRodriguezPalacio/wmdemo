//
//  ReferedViewController.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class ReferedViewController: NavigationViewController,UITableViewDataSource,UITableViewDelegate{
    
    let headerHeight: CGFloat = 46
    
    var referedTable: UITableView!
    var selectedRow: NSIndexPath! = nil
    var referedCountLabel: UILabel?
    var referedDescLabel: UILabel?
    var addReferedButton: UIButton?
    var layerLine: CALayer!
    var modalView: AlertModalView?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_REFERED.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.titleLabel?.text = "Mis Referidos"
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.lineSaparatorColor.CGColor
        self.view.layer.insertSublayer(layerLine, atIndex: 0)
        
        referedTable = UITableView()
        referedTable.registerClass(ReferedTableViewCell.self, forCellReuseIdentifier: "referedCell")
        referedTable.registerClass(ReferedDetailTableViewCell.self, forCellReuseIdentifier: "referedDetail")
        referedTable.separatorStyle = UITableViewCellSeparatorStyle.None
        referedTable.delegate = self
        referedTable.dataSource = self
        self.view.addSubview(referedTable!)
        
        referedCountLabel = UILabel()
        referedCountLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        referedCountLabel?.textColor = WMColor.listAddressHeaderSectionColor
        referedCountLabel?.text = "¡Tienes 5 envíos gratis disponibles!"
        referedCountLabel?.textAlignment = .Center
        self.view.addSubview(referedCountLabel!)
        
        referedDescLabel = UILabel()
        referedDescLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        referedDescLabel?.textColor = WMColor.listAddressHeaderSectionColor
        referedDescLabel?.numberOfLines = 3
        referedDescLabel?.text = "Acumula envíos gratis cuando tus referidos \nse registren en Walmart (ellos tambíen recibirán un \nenvío gratis al confirmar)"
        referedDescLabel?.textAlignment = .Center
        self.view.addSubview(referedDescLabel!)
        
        addReferedButton = UIButton()
        addReferedButton?.setTitle("Referir a un amigo", forState:.Normal)
        addReferedButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        addReferedButton?.backgroundColor = WMColor.listAddressHeaderSectionColor
        addReferedButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        addReferedButton?.layer.cornerRadius = 16
        addReferedButton?.addTarget(self, action: "addRefered", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(addReferedButton!)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.referedCountLabel!.frame = CGRectMake(0, headerHeight + 16, self.view.frame.width, 16)
        self.referedDescLabel!.frame = CGRectMake(0, self.referedCountLabel!.frame.maxY + 16, self.view.frame.width, 42)
        self.addReferedButton!.frame = CGRectMake((self.view.frame.width - 132) / 2, self.referedDescLabel!.frame.maxY + 16, 132, 34)
        self.layerLine.frame =  CGRectMake(0, self.addReferedButton!.frame.maxY + 15, self.view.frame.width, 1)
        self.referedTable!.frame = CGRectMake(0, self.addReferedButton!.frame.maxY + 16, self.view.frame.width, self.view.frame.height - self.addReferedButton!.frame.maxY)
    }
    
    //MARK: Tableview Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedRow != nil {
            if selectedRow.section == section {
                return numberOfRowsInSection(section) + 1
            }
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = nil
        if indexPath.row == 0 &&  indexPath.section == 0{
            let referedCell = referedTable.dequeueReusableCellWithIdentifier("referedCell", forIndexPath: indexPath) as! ReferedTableViewCell
            referedCell.setTitleAndCount("Pendientes", count:  "3")
            cell = referedCell
        } else if indexPath.row == 0 &&  indexPath.section == 1 {
            let referedCell = referedTable.dequeueReusableCellWithIdentifier("referedCell", forIndexPath: indexPath) as! ReferedTableViewCell
            referedCell.setTitleAndCount("Confirmados", count:  "2")
            cell = referedCell
        }else {
            let cellDetail = referedTable.dequeueReusableCellWithIdentifier("referedDetail", forIndexPath: indexPath) as! ReferedDetailTableViewCell
            //let selectedRow = families[indexPath.section]
            //let linesArr = selectedSection["line"] as! NSArray
            //let itemLine = linesArr[indexPath.row - 1] as! NSDictionary
            //let selectedItem = itemLine["id"] as! String
            cellDetail.setValues("Luis Alonso Salcido Martinez", email: "alonso.salcido@mail.com")
            cell = cellDetail
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       /* if indexPath.row == 0  {
            let changeSelection = (selectedFamily == nil || (selectedFamily != nil && selectedRow.section != indexPath.section) )
            if selectedRow != nil {
                deSelectSection(selectedRow)
            }
            if changeSelection {
                selectSection(indexPath)
                self.familyTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            }
            let label = families[indexPath.section]["name"] as! String
            let labelCategory = label.uppercaseString.stringByReplacingOccurrencesOfString(" ", withString: "_")
            BaseController.sendAnalytics("\(labelCategory)_AUTH", categoryNoAuth:"MG\(labelCategory)_NO_AUTH", action: WMGAIUtils.ACTION_OPEN_ACCESSORY_LINES.rawValue, label:label)
        }
        else {
            let selectedSection = families[indexPath.section]
            let linesArr = selectedSection["line"] as! NSArray
            let itemLine = linesArr[indexPath.row - 1] as! NSDictionary
            
            let controller = SearchProductViewController()
            controller.searchContextType = .WithCategoryForMG
            if self.categoriesType != nil {
                switch self.categoriesType! {
                case .CategoryForGR : controller.searchContextType = .WithCategoryForGR
                case .CategoryForMG : controller.searchContextType = .WithCategoryForMG
                    //default : print("No se ha indicado tipo de categorias.")
                }
                
            }
            controller.titleHeader = itemLine["name"] as? String
            controller.idDepartment = departmentId
            controller.idFamily = selectedSection["id"] as? String
            controller.idLine = itemLine["id"] as? String
            
            self.navigationController!.pushViewController(controller, animated: true)
            let label = itemLine["name"] as! String
            let labelCategory = label.uppercaseString.stringByReplacingOccurrencesOfString(" ", withString: "_")
            BaseController.sendAnalytics("\(labelCategory)_AUTH", categoryNoAuth:"MG\(labelCategory)_NO_AUTH", action: WMGAIUtils.ACTION_SELECTED_LINE.rawValue, label:label)
        }*/
        if indexPath.row == 0  {
            if selectedRow != nil {
                deSelectSection(selectedRow)
            }
            selectSection(indexPath)
        }
    }
    
    func numberOfRowsInSection(section:Int) -> Int {
        /*if section < families.count {
            let selectedSection = families[section]
            let nameLine = selectedSection["line"] as! NSArray
            return nameLine.count
        }
        return 1*/
        return 3
    }
    
    func selectSection(indexPath: NSIndexPath!) {
        selectedRow = indexPath
        let numberOfItems = numberOfRowsInSection(indexPath.section)
        var arratIndexes : [NSIndexPath] = []
        if numberOfItems > 0 {
            for index in 1...numberOfItems {
                arratIndexes.append(NSIndexPath(forRow: index, inSection: indexPath.section))
            }
            self.referedTable.insertRowsAtIndexPaths(arratIndexes, withRowAnimation: .Automatic)
        }
    }
    
    func deSelectSection(indexPath: NSIndexPath!) {
        selectedRow = nil
        let numberOfItems = numberOfRowsInSection(indexPath.section)
        var arratIndexes : [NSIndexPath] = []
        if numberOfItems > 0 {
            for index in 1...numberOfItems {
                arratIndexes.append(NSIndexPath(forRow: index, inSection: indexPath.section))
            }
            self.referedTable.deleteRowsAtIndexPaths(arratIndexes, withRowAnimation: .Automatic)
        }
    }
    
    func addRefered(){
        let addreferedForm = ReferedForm(frame: CGRectMake(0, 0,  288, 248))
        let modalView = AlertModalView.initModalWithView("Invitar a un Amigo",innerView: addreferedForm)
        modalView.showPicker()
    }

}