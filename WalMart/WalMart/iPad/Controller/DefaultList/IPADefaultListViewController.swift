//
//  IPADefaultListViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 02/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class IPADefaultListViewController : DefaultListViewController {
    
    
    var delegate : IPADefaultListDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        self.hiddenBack = true
        super.viewDidLoad()
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let itemList = itemsLists[indexPath.row] as! [String:AnyObject]
        
        let destDetailList =  IPADefaultListDetailViewController()
        destDetailList.delegate = delegate
        destDetailList.defaultListName = itemList["name"] as? String
        destDetailList.detailItems = itemList["items"] as? [[String:AnyObject]]
        
        self.navigationController?.pushViewController(destDetailList, animated: true)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.viewLoad?.center =  CGPointMake(self.view.center.x, self.view.center.y + self.header!.frame.maxY)
        
    }
    
    
    
    
    
}