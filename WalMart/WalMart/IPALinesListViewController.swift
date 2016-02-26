//
//  IPALinesListViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 26/02/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

protocol IPALinesListViewControllerDelegate {
    func didSelectLineList(department:String,family:String,line:String, name:String)
}

class IPALinesListViewController : LineViewController {
    
      var delegate : IPALinesListViewControllerDelegate!
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
            let lineSelect  = self.families[indexPath.row] as NSDictionary
            let linesId = lineSelect["line"] as! String
            let name = lineSelect["nameLine"] as! String
            delegate.didSelectLineList(departmentId,family: "_",line: linesId, name: name)
        
    }


}