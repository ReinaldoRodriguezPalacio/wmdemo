//
//  IPADefaultListViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 02/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class IPADefaultListViewController : DefaultListViewController {
  
    var empty : UIImageView!
    var isEmpty =  false
  
    weak var delegate : IPADefaultListDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        self.hiddenBack = true
        self.empty  = UIImageView(image: UIImage(named:"empty_recent"))
        super.viewDidLoad()
    
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let itemList = itemsLists[indexPath.row] as! [String:Any]
        
        let destDetailList =  IPADefaultListDetailViewController()
        destDetailList.delegate = delegate
        destDetailList.defaultListName = itemList["name"] as? String
        destDetailList.detailItems = itemList["items"] as? [[String:Any]]
        
        self.navigationController?.pushViewController(destDetailList, animated: true)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
      self.viewLoad?.center =  CGPoint(x: self.view.center.x, y: self.view.center.y + self.header!.frame.maxY)
      if isEmpty {
        self.empty.frame =  CGRect(x: 0, y: self.header!.frame.maxY , width: self.view.frame.maxX, height: self.view.frame.height - (self.header!.frame.height))
      }
    }
  
  override func showEmptyView(){
    self.isEmpty =  true
    let bounds = self.view.bounds
    self.empty.frame =  CGRect(x: 0, y: self.header!.frame.maxY , width: bounds.maxX, height: bounds.height - (self.header!.frame.height ))

    self.view.addSubview(self.empty!)
    
  }
  
  override func removeEmptyView(){
    self.isEmpty =  false
    self.empty?.removeFromSuperview()
    self.empty =  nil
  }
  
  
  
  
  
}
