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
    var quantitySelector: ShoppingCartQuantitySelectorView?
    var upcProduct: String!
    var productDeparment: String!
    var strisPreorderable : String! = "false"
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(endUpdatingShoppingCart), name: .successUpdateItemsInShoppingCart, object: nil)
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.providerTable.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.header!.frame.maxY)
        self.switchButton.frame = CGRect(x:self.view.frame.width - 76,y: 12, width: 60, height: 22)
    }
    
    func endUpdatingShoppingCart() {
        self.providerTable.reloadData()
    }
}

//MARK: UITableViewDelegate
extension ProviderListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
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
        cell.selectionStyle = .none
        cell.delegate = self
        cell.upc = self.upcProduct
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

//MARK: ProviderProductTableViewCellDelegate
extension ProviderListViewController: ProviderProductTableViewCellDelegate {
    func selectQuantityForItem(cell: ProviderProductTableViewCell, productInCart: Cart?) {
        
        if productInCart?.quantity == nil {
            let params = self.buildParamsUpdateShoppingCart("1", orderByPiece: true, pieces: 1,equivalenceByPiece:0, price: cell.productPrice!.stringValue,onHandInventory: cell.onHandInventory.stringValue)
            NotificationCenter.default.post(name: .addUPCToShopingCart, object: self, userInfo: params)
        }
        
        if self.quantitySelector == nil {
            let indexPath = self.providerTable!.indexPath(for: cell)
            if indexPath == nil {
                return
            }
            
            var price: NSNumber? = nil
            price = cell.productPrice
            
            let width:CGFloat = self.view.frame.width
            let height:CGFloat = (self.view.frame.height)
            
            let selectorFrame = CGRect(x: 0, y: self.view.frame.height, width: width, height: height)
            
            self.quantitySelector = ShoppingCartQuantitySelectorView(frame: selectorFrame, priceProduct: price, upcProduct: cell.upc)
            
            self.view.addSubview(self.quantitySelector!)
            self.quantitySelector!.closeAction = { () in
                self.removeSelector()
            }
            
            quantitySelector!.addToCartAction =
                { (quantity:String) in
                    //let quantity : Int = quantity.toInt()!
                    self.quantitySelector?.closeAction()
                    
                    if quantity == "00" {
                        self.deleteFromCart(cell: cell)
                        return
                    }
                    
                    let maxProducts = (cell.onHandInventory.intValue <= 5 || self.productDeparment == "d-papeleria") ? cell.onHandInventory.intValue : 5
                    if maxProducts >= Int(quantity)! {
                        //let params = CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageURL, price: price, quantity: quantity,onHandInventory:self.onHandInventory,)
                        let params = self.buildParamsUpdateShoppingCart(quantity, orderByPiece: true, pieces: Int(quantity)!,equivalenceByPiece:0, price: cell.productPrice!.stringValue,onHandInventory: cell.onHandInventory.stringValue)//equivalenceByPiece
                        NotificationCenter.default.post(name: .addUPCToShopingCart, object: self, userInfo: params)
                    } else {
                        let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                        
                        let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                        let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                        let msgInventory = "\(firstMessage)\(maxProducts) \(secondMessage)"
                        alert!.setMessage(msgInventory)
                        alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                        self.quantitySelector?.first = true
                        self.quantitySelector?.userSelectValue("\(maxProducts)")
                    }
            }
            
            if productInCart?.quantity != nil {
                quantitySelector?.userSelectValue(productInCart!.quantity.stringValue)
                quantitySelector?.first = true
            }
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.quantitySelector!.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            })
            
        }
        else {
            self.removeSelector()
        }
    }
    
    func removeSelector() {
        if   self.quantitySelector != nil {
            UIView.animate(withDuration: 0.5,
                           animations: { () -> Void in
                            let width:CGFloat = self.view.frame.width
                            let height:CGFloat = self.view.frame.height - self.header!.frame.height
                            self.quantitySelector!.frame = CGRect(x: 0.0, y: self.view.frame.height, width: width, height: height)
            },
                           completion: { (finished:Bool) -> Void in
                            if finished {
                                self.quantitySelector?.removeFromSuperview()
                                self.quantitySelector = nil
                            }
            })
        }
    }
    
    func deleteFromCart(cell: ProviderProductTableViewCell) {
        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"remove_cart"), imageDone:UIImage(named:"done"),imageError:UIImage(named:"preCart_mg_icon"))
        alertView?.setMessage(NSLocalizedString("shoppingcart.deleteProductAlert", comment:""))
        self.quantitySelector!.closeAction()
        self.quantitySelector = nil
        
        
        let itemToDelete = self.buildParamsUpdateShoppingCart("0",orderByPiece: false, pieces: 0,equivalenceByPiece:0, price: cell.productPrice!.stringValue,onHandInventory: cell.onHandInventory.stringValue)
        if !UserCurrentSession.hasLoggedUser() {
            BaseController.sendAnalyticsAddOrRemovetoCart([itemToDelete], isAdd: false)
        }
        let upc = itemToDelete["upc"] as! String
        let deleteShoppingCartService = ShoppingCartDeleteProductsService()
        deleteShoppingCartService.callCoreDataService(upc, successBlock: { (response) in
            UserCurrentSession.sharedInstance.loadMGShoppingCart {
                UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
                alertView?.setMessage(NSLocalizedString("shoppingcart.deleteProductDone", comment:""))
                alertView?.showDoneIcon()
                alertView?.afterRemove = {
                    self.providerTable?.reloadData()
                }
            }
        }) { (error) in
            print("delete pressed Errro \(error)")
        }
    }
    
    func buildParamsUpdateShoppingCart(_ quantity:String, orderByPiece: Bool, pieces: Int,equivalenceByPiece:Int,price:String,onHandInventory:String) -> [AnyHashable: Any] {

        return ["upc":self.upcProduct,"desc":self.productDescription!,"imgUrl":self.productImageUrl!,"price":price,"quantity":quantity,"onHandInventory":onHandInventory,"wishlist":false,"type":ResultObjectType.Mg.rawValue,"pesable":"0","isPreorderable":self.strisPreorderable,"category":self.productDeparment,"equivalenceByPiece":equivalenceByPiece]
    }

}
