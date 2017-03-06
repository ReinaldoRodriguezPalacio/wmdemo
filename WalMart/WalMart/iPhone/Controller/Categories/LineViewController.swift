//
//  LineViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 2/25/16.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class LineViewController : FamilyViewController {
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PRESHOPPINGCART.rawValue
    }
    
    override func viewDidLoad() {
      
        familyTable = UITableView()
        familyTable.register(IPOLineTableViewCell.self, forCellReuseIdentifier: "lineCell")
        familyTable.separatorStyle = UITableViewCellSeparatorStyle.none
        familyTable.delegate = self
        familyTable.dataSource = self
        familyTable.frame = self.view.bounds
        
        
        self.view.addSubview(familyTable)
    }
    
    override func viewDidLayoutSubviews() {
        if IS_IPAD {
            familyTable.contentSize =  CGSize(width: 322 , height: CGFloat(((self.families.count + 1 ) * 64) + 40))
        }else{
            familyTable.frame = CGRect(x: 0,y: 0,width: familyTable.frame.size.width,height: familyTable.frame.size.height - 80)
            familyTable.contentSize =  CGSize(width: 322 , height: CGFloat(self.families.count * 46))
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return families.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = nil
     
    
            let cellLine = familyTable.dequeueReusableCell(withIdentifier: lineReuseIdentifier(), for: indexPath) as! IPOLineTableViewCell
            let selectedSection = families[(indexPath as NSIndexPath).row]
            let selectedItem = selectedSection["subCategoryId"] as! String
            cellLine.setTitle(selectedSection["subCategoryName"] as! String)
            cellLine.setValues(selectedSection["price"] == nil ? "0" :selectedSection["price"] as! String)
            cellLine.showSeparator =  true
        
            cell = cellLine
            
            if selectedItem == self.departmentId
            {
                cell.backgroundColor = UIColor(red: 236.0/255.0, green: 238.0/255.0, blue: 249.0/255.0, alpha: 1.0)
            }
            else
            {
                cell.backgroundColor = UIColor.white
            }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            let selectedSection = families[(indexPath as NSIndexPath).row]
            let controller = SearchProductViewController()
            controller.searchContextType = .WithCategoryForMG
            if self.categoriesType != nil {
                switch self.categoriesType! {
                case .categoryForGR : controller.searchContextType = .WithCategoryForGR
                case .categoryForMG : controller.searchContextType = .WithCategoryForMG
                //default : print("No se ha indicado tipo de categorias.")
                }
             
            }
            controller.titleHeader = selectedSection["subCategoryName"] as? String
            controller.idDepartment = "_"
            controller.idFamily = "_"
            controller.idLine = selectedSection["subCategoryId"] as? String
            controller.textToSearch = ""
            controller.urlFamily = "/Despensa/Aceites-de-cocina/Aceite-de-ma%C3%ADz/_/N-829"//add url for Search
            controller.originalUrl = "/Despensa/Aceites-de-cocina/Aceite-de-ma%C3%ADz/_/N-829"//add url for Search
            controller.originalText = ""

            self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
}
