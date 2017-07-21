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
  var itemsOptions = ["Refacturar", "Contactar al proveedor","Devolver estos artículos"]
  var orderItems:[[String:Any]]! = []
  var alertView : IPOWMAlertViewController? = nil
  var sellerId: String = ""
  var sellerName: String = ""
  
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
  
  
  func returnItems() {
    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"alert_returnItems"),imageDone:UIImage(named:"alert_returnItems"),imageError:UIImage(named:"alert_returnItems"))
    self.alertView?.btnFrame = true
    self.alertView?.showicon(UIImage(named: "alert_returnItems"))
    self.alertView?.setMessage("Para solicitar la devolución de tus artículos ponte en contacto con el vendedor.")
    
    self.alertView?.addActionButtonsWithCustomText("Contactar vendedor", leftAction: {(void) in
      self.alertView?.close()
      let controller = ContactProviderViewController()
        controller.sellerId = self.sellerId
      self.navigationController!.pushViewController(controller, animated: true)
    }, rightText: NSLocalizedString("list.endedit",comment:""), rightAction: { (void) in
      self.alertView?.close()
    },isNewFrame: false)
  }
  
  
  func sendInvoice() {
    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"alert_done"),imageError:UIImage(named:"alert_done"))
    
    //Service
    /*
    let service = GRAddressAddService()
    service.callService(requestParams: dictSend!, successBlock: { (resultCall:[String:Any]) -> Void  in
      print("Se envia factura")
      //let _ = self.navigationController?.popViewController(animated: true)
      
      self.alertView!.showDoneIcon()
      
    }) { (error:NSError) -> Void in
      self.alertView!.setMessage(error.localizedDescription)
      self.alertView!.showErrorIcon("Ok")
    }*/
    
    self.alertView!.showDoneIconWithoutClose()
    //self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"), imageDone: nil, imageError:
      //UIImage(named:"noAvaliable"))
    self.alertView?.showicon(UIImage(named: "alert_done"))
    self.alertView?.btnFrame = true
    self.alertView?.setMessage("La factura ha sido enviada a: contacto_acme@gmail.com")
    self.alertView?.showErrorIcon(NSLocalizedString("Ok", comment:""))
  }
  
  
  func refill(){
    let webCtrl = IPOWebViewController()
    webCtrl.openURLFactura()
    self.present(webCtrl,animated:true,completion:nil)
  }
  
 
  func reportProblem() {
    let controller = ReportProblemViewController()
    controller.orderItems = self.orderItems
    self.navigationController?.pushViewController(controller, animated: true)
  }
    
}

//MARK: UITableViewDataSource
extension OrderMoreOptionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsOptions.count
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
        
        switch indexPath.row {
        case 0:
            print("Refacturar")
            self.refill()
        case 1:
            print("Contactar al proveedor")
            let controller = ContactProviderViewController()
            controller.sellerId = self.sellerId
            self.navigationController!.pushViewController(controller, animated: true)
        case 2:
            print("Devolver estos articulos")
            self.returnItems()
        default:
            print("")
        }
    }
}
