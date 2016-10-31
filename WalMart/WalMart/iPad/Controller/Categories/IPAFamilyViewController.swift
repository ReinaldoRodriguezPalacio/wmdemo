//
//  IPAFamilyViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol IPAFamilyViewControllerDelegate {
    func didSelectLine(_ department:String,family:String,line:String, name:String)
}

class IPAFamilyViewController : FamilyViewController {

    var delegate : IPAFamilyViewControllerDelegate!
    
    override func viewDidLoad() {
      super.viewDidLoad()
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0  {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }else
        {
            let selectedSection = families[(indexPath as NSIndexPath).section]
            let linesArr = selectedSection["fineContent"] as! NSArray
            let itemLine = linesArr[(indexPath as NSIndexPath).row - 1] as! NSDictionary
            let nameLine = itemLine["displayName"] as! String
            delegate.didSelectLine(departmentId,family: selectedSection["familyId"] as! String,line: itemLine["id"] as! String, name: nameLine)
        }
    }
    
  
    
}
