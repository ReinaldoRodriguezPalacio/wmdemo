//
//  ProviderListViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 26/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation


class ProviderListViewController: NavigationViewController {
    var providerTable: UITableView!
    var switchButton: UIButton!
    var providerItems: [[String:Any]]! = []
    var viewLoad: WMLoadingView?
    var productImageUrl: String?
    var productDescription: String?
    var productType:String?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PROVIDERSLIST.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = "Otros proveedores"
        self.titleLabel?.textAlignment = .left
        
        self.providerTable = UITableView()
        self.providerTable.delegate = self
        self.providerTable.dataSource = self
        self.providerTable.separatorStyle = .none
        self.providerTable.register(ProviderProductTableViewCell.self, forCellReuseIdentifier: "providerProductCell")
        self.view.addSubview(providerTable)
        
        self.switchButton = UIButton()
        self.switchButton.backgroundColor = WMColor.light_blue
        self.switchButton.layer.cornerRadius = 11
        self.switchButton.setTitleColor(UIColor.white, for: .normal)
        self.switchButton.setTitle("nuevos", for: .normal)
        self.switchButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(switchButton)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.providerTable.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.header!.frame.maxY)
        self.switchButton.frame = CGRect(x:self.view.frame.width - 76,y: 12, width: 60, height: 22)
    }
}

//MARK: UITableViewDelegate
extension ProviderListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//MARK: UITableViewDataSource
extension ProviderListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.providerItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "providerProductCell", for: indexPath) as! ProviderProductTableViewCell
        
        let providerInfo = self.providerItems[indexPath.row]
        cell.setValues(providerInfo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = ProviderProductHeaderView()
        headerView.setValues(self.productImageUrl!, productShortDescription: self.productDescription!, productType: self.productType!)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 88
    }
}
