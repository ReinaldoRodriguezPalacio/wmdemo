//
//  IPALinesListViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 26/02/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

protocol IPALinesListViewControllerDelegate: class {
    func didSelectLineList(_ department:String,family:String,line:String, name:String)
}

class IPALinesListViewController : LineViewController {
    
      weak var delegate : IPALinesListViewControllerDelegate?
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
            let lineSelect  = self.families[indexPath.row] as [String:Any]
            let linesId = lineSelect["id"] as! String
            let name = lineSelect["name"] as! String
            delegate?.didSelectLineList(departmentId,family: "_",line: linesId, name: name)
        
    }


}
