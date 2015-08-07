//
//  IPADefaultListViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 02/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class IPADefaultListViewController : DefaultListViewController {
    
    
    override func viewDidLoad() {
        self.hiddenBack = true
        super.viewDidLoad()
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let itemList = itemsLists[indexPath.row] as! [String:AnyObject]
        
        let destDetailList =  IPADefaultListDetailViewController()
        destDetailList.defaultListName = itemList["name"] as? String
        destDetailList.detailItems = itemList["items"] as? [[String:AnyObject]]
        
        self.navigationController?.pushViewController(destDetailList, animated: true)
    }
    
    
    
    
}