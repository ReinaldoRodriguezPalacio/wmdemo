//
//  IPAFamilyViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol IPAFamilyViewControllerDelegate: class {
    func didSelectLine(_ department:String,family:String,line:String, name:String)
    var filterMedida: Bool! {get set}
    var medidaToSearch:String! {get set}
}

class IPAFamilyViewController : FamilyViewController {

    weak var delegate : IPAFamilyViewControllerDelegate?
    
    override func viewDidLoad() {
      super.viewDidLoad()
     
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0  {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }else
        {
            let selectedSection = families[indexPath.section]
            let linesArr = selectedSection["line"] as! [Any]
            let itemLine = linesArr[indexPath.row - 1] as! [String:Any]
            let name = itemLine["name"] as! String
            
            if itemLine["id"] as! String == "l-serarching-llantas-solr"{
                self.showTiresSearch()
                
            }
            else{
            
            
            let selectedSection = families[indexPath.section]
            let linesArr = selectedSection["line"] as! [Any]
            let itemLine = linesArr[indexPath.row - 1] as! [String:Any]
            let name = itemLine["name"] as! String
            delegate?.filterMedida=false
            delegate?.medidaToSearch=""
            delegate?.didSelectLine(departmentId,family: selectedSection["id"] as! String,line: itemLine["id"] as! String, name: name)
            
        }
    }
    
    }
    
    func showTiresSearch() {
        
        let controller = IPASearchTiresIniViewController()
        controller.delegate=self
        present(controller, animated: true, completion: nil)
        
    }

    func searchTires(family:String, line:String, idDepartment : String, name: String, medida : String){
        delegate?.filterMedida=true
        delegate?.medidaToSearch=medida
        delegate?.didSelectLine(idDepartment, family: family, line: line, name: name)
        
    }
    
}
