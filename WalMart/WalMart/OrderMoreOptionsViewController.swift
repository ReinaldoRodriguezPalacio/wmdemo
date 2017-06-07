//
//  OrderMoreOptionsViewController.swift
//  WalMart
//
//  Created by Daniel V on 07/06/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit

class OrderMoreOptionsViewController: NavigationViewController {
  
  var tableOptions : UITableView!
  var itemsOptions = ["Enviar Factura","Refacturar", "Contactar al proveedor", "Reportar un problema","Devolver estos artículos"]
  var orderItems:[[String:Any]]! = []
  
  override func getScreenGAIName() -> String {
    return WMGAIUtils.SCREEN_PREVIOUSORDERS.rawValue
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor.white
    self.titleLabel!.text = "Más opciones"//NSLocalizedString("profile.myOrders", comment: "")
    
    tableOptions = UITableView()
    tableOptions.dataSource = self
    tableOptions.delegate = self
    tableOptions.register(OrderOptionsTableViewCell.self, forCellReuseIdentifier: "optionsOrder")
    tableOptions.separatorStyle = UITableViewCellSeparatorStyle.none
    
    self.view.addSubview(tableOptions)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    self.tableOptions.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 92)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func back() {
    //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
    super.back()
  }
  
}

//MARK: UITableViewDataSource
extension OrderMoreOptionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableOptions.dequeueReusableCell(withIdentifier: "optionsOrder") as! OrderOptionsTableViewCell
        cell.selectionStyle = .none
        cell.setValues(self.itemsOptions[indexPath.row])
        
        return cell
    }
    
}

//MARK: UITableViewDelegate
extension OrderMoreOptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemsOptions[indexPath.row]
        
        if item == "Reportar un problema" {
            let controller = ReportProblemViewController()
            controller.orderItems = self.orderItems
            self.navigationController?.pushViewController(controller, animated: true)
        }
      
      if item == "Contactar al proveedor" {
        let controller = ContactProviderViewController()
        self.navigationController!.pushViewController(controller, animated: true)
      }
    }
}
