//
//  IPAFamilyViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol IPAFamilyViewControllerDelegate {
    func didSelectLine(department:String,family:String,line:String, name:String)
}

class IPAFamilyViewController : FamilyViewController {

    var delegate : IPAFamilyViewControllerDelegate!
    
    override func viewDidLoad() {
      super.viewDidLoad()
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0  {
            super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }else
        {
            let selectedSection = families[indexPath.section]
            let linesArr = selectedSection["fineContent"] as! NSArray
            let itemLine = linesArr[indexPath.row - 1] as! NSDictionary
            let nameLine = itemLine["displayName"] as! String
            delegate.didSelectLine(departmentId,family: selectedSection["familyId"] as! String,line: itemLine["id"] as! String, name: nameLine)
        }
    }
    
  
    
}