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
    var itemsLists : [Any] =  []
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
        self.tableView?.register(DefaultListTableViewCell.self, forCellReuseIdentifier: "SuperlistasCell")
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.none
        self.view.addSubview(self.tableView!)
        
        loadDefaultLists()
        BaseController.setOpenScreenTagManager(titleScreen: "Superlistas", screenName: self.getScreenGAIName())
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView!.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.header!.frame.maxY - 44)
    }
    
    
    func loadDefaultLists() {
       
        self.showLoadingView()
        let defaultListService = DefaultListService()
        self.itemsLists = defaultListService.getDefaultContent()
        self.tableView?.reloadData()
        self.removeLoadingView()
    }
    
    
    func showLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0.0, y: self.header!.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.header!.frame.maxY))
        self.viewLoad!.backgroundColor = UIColor.white
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(self.isVisibleTab)
    }
    
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellreturn = tableView.dequeueReusableCell(withIdentifier: "SuperlistasCell", for: indexPath) as! DefaultListTableViewCell
        let itemList = itemsLists[indexPath.row] as! [String:Any]
        
        let listName = itemList["name"] as? String
        let items = itemList["items"] as? [[String:Any]]
        var totalInList = 0.0
        for itmProduct in items! {
            if let itmPrice = itmProduct["price"] as? NSNumber {
                totalInList +=  itmPrice.doubleValue
            }
        }
            
        let cellFormatedTotal = CurrencyCustomLabel.formatString("\(totalInList)" as NSString)
        cellreturn.setValues(listName!, numberItems: "\(items!.count)",total:cellFormatedTotal)

        return cellreturn
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let itemList = itemsLists[indexPath.row] as! [String:Any]
        
        let destDetailList =  DefaultListDetailViewController()
        destDetailList.defaultListName = itemList["name"] as? String
        destDetailList.detailItems = itemList["items"] as? [[String:Any]]
        
        //Event
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA.rawValue, action: WMGAIUtils.ACTION_OPEN_PRACTILISTA.rawValue, label: itemList["name"] as! String)
        
        self.navigationController?.pushViewController(destDetailList, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
    
}
