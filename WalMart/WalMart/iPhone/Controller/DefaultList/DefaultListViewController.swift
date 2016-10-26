 //
//  DefaultListViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 23/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class DefaultListViewController : NavigationViewController, UITableViewDataSource, UITableViewDelegate {
     
    var tableView: UITableView?
    var itemsLists : [AnyObject] =  []
    var viewLoad: WMLoadingView?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PRACTILISTA.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = "Superlistas"
        
        self.tableView = UITableView()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.registerClass(DefaultListTableViewCell.self, forCellReuseIdentifier: "SuperlistasCell")
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(self.tableView!)
        
        loadDefaultLists()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView!.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, self.view.frame.height - self.header!.frame.maxY)
    }
    
    
    func loadDefaultLists() {
       
        self.showLoadingView()
       
        let svcDefaulLists = DefaultListService()
        svcDefaulLists.callService({ (result:NSDictionary) -> Void in
                self.itemsLists = result[JSON_KEY_RESPONSEARRAY] as! [[String:AnyObject]]
                self.tableView?.reloadData()
                self.removeLoadingView()
            }, errorBlock: { (error:NSError) -> Void in
                self.itemsLists = []
                self.removeLoadingView()
        })
        
    }
    
    
    func showLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRectMake(0.0, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY))
        self.viewLoad!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(self.isVisibleTab)
    }
    
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsLists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellreturn = tableView.dequeueReusableCellWithIdentifier("SuperlistasCell", forIndexPath: indexPath) as! DefaultListTableViewCell
        let itemList = itemsLists[indexPath.row] as! NSDictionary
        
        let listName = itemList["name"] as? String
        let items = itemList["items"] as? [[String:AnyObject]]
        var totalInList = 0.0
        for itmProduct in items! {
            if let itmPrice = itmProduct["price"] as? NSNumber {
                totalInList +=  itmPrice.doubleValue
            }
        }
            
        let cellFormatedTotal = CurrencyCustomLabel.formatString("\(totalInList)")
        cellreturn.setValues(listName!, numberItems: "\(items!.count)",total:cellFormatedTotal)

        return cellreturn
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let itemList = itemsLists[indexPath.row] as! [String:AnyObject]
        
        let destDetailList =  DefaultListDetailViewController()
        destDetailList.defaultListName = itemList["name"] as? String
        destDetailList.detailItems = itemList["items"] as? [[String:AnyObject]]
        
        //Event
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA.rawValue, action: WMGAIUtils.ACTION_OPEN_PRACTILISTA.rawValue, label: itemList["name"] as! String)
        
        self.navigationController?.pushViewController(destDetailList, animated: true)
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 108
    }
    
}
