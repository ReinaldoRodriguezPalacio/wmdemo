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
        self.tableView?.register(DefaultListTableViewCell.self, forCellReuseIdentifier: "SuperlistasCell")
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.none
        self.view.addSubview(self.tableView!)
        
        loadDefaultLists()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView!.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.header!.frame.maxY)
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
        let itemList = itemsLists[(indexPath as NSIndexPath).row] as! NSDictionary
        
        let listName = itemList["name"] as? String
        let items = itemList["items"] as? [[String:AnyObject]]
        var totalInList = 0.0
        for itmProduct in items! {
            
            if let typeProd = itmProduct["isWeighable"] as? NSString {
                
                let quantity = itmProduct["quantity"] as! NSNumber
                let price = itmProduct["price"] as! NSNumber
                //piezas
                if typeProd == "N" {
                    totalInList += (quantity.doubleValue * price.doubleValue)
                }
                    //gramos
                else {
                    let kgrams = quantity.doubleValue / 1000.0
                    totalInList += (kgrams * price.doubleValue)
                }
            }
        }
            
        let cellFormatedTotal = CurrencyCustomLabel.formatString("\(totalInList)")
        cellreturn.setValues(listName!, numberItems: "\(items!.count)",total:cellFormatedTotal)

        return cellreturn
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let itemList = itemsLists[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        
        let destDetailList =  DefaultListDetailViewController()
        destDetailList.defaultListName = itemList["name"] as? String
        destDetailList.detailItems = itemList["items"] as? [[String:AnyObject]]
        
        //Event
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA.rawValue, action: WMGAIUtils.ACTION_OPEN_PRACTILISTA.rawValue, label: itemList["name"] as! String)
        
        self.navigationController?.pushViewController(destDetailList, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
    
}
