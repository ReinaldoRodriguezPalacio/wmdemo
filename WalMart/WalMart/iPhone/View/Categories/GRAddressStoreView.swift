//
//  GRAddressStoreView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 07/04/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class GRAddressStoreView: UIView, UITableViewDelegate, UITableViewDataSource {
    var cancelButton: UIButton?
    var saveButton: UIButton?
    var tableStore: UITableView?
    var layerLine: CALayer!
    var storeArray: [Any]! = []
    var viewLoad : WMLoadingView!
    var selectedStore: IndexPath?
    var selectedstoreId: String! = ""
    var addressId: String! = ""
    var onClose: (() -> Void)?
    var onReturn: (() -> Void)?
    var alertView: IPOWMAlertViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_gray.cgColor
        self.layer.insertSublayer(layerLine, at: 0)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Regresar", for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(GRAddressStoreView.close), for: UIControlEvents.touchUpInside)
        self.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Cambiar Tienda", for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(GRAddressStoreView.save), for: UIControlEvents.touchUpInside)
        self.addSubview(saveButton!)
        
        self.tableStore = UITableView()
        self.tableStore!.delegate = self
        self.tableStore!.dataSource = self
        self.tableStore!.backgroundColor = UIColor.white
        self.tableStore!.register(SelectItemTableViewCell.self, forCellReuseIdentifier: "cellSelItem")

        self.addSubview(tableStore!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let minVTableHeigth : CGFloat = (1.5 * 46.0)
        var tableHeight = CGFloat(storeArray.count) * 46.0
        tableHeight = max(minVTableHeigth,tableHeight)
        self.tableStore?.frame = CGRect(x: 16,y: 0,width: self.frame.width - 16, height: min(210,tableHeight))
        self.layerLine.frame = CGRect(x: 0,y: self.tableStore!.frame.maxY,width: self.frame.width, height: 1)
        self.cancelButton?.frame = CGRect(x: (self.frame.width/2) - 129,y: self.layerLine.frame.maxY + 16, width: 125, height: 34)
        self.saveButton?.frame = CGRect(x: (self.frame.width/2) + 4 , y: self.layerLine.frame.maxY + 16, width: 125, height: 34)
    }
    
    /**
     Returns to address list view
     */
    func close(){
     self.onReturn?()
    }
    
    /**
     Save the selected store in address and sets the address as preferred
     */
    func save() {
        self.applyPrefered(self.addressId)
    }
    //MARK: TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storeArray!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSelItem") as! SelectItemTableViewCell!
        let store = self.storeArray[(indexPath as NSIndexPath).row] as! [String:Any]
        cell?.textLabel?.text = store["name"] as? String
        cell?.checkSelected.frame = CGRect(x: 0, y: 0, width: 33, height: 46)
        cell?.selectionStyle = .none
        if selectedstoreId == store["id"] as? String {
            self.selectedStore = self.selectedStore ?? indexPath
        }
        if self.selectedStore != nil {
            cell?.setSelected((indexPath as NSIndexPath).row == (self.selectedStore! as NSIndexPath).row, animated: false)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        self.selectedStore =  self.selectedStore ?? indexPath
        
        if self.selectedStore == indexPath  {
            cell?.setSelected((indexPath as NSIndexPath).row == (self.selectedStore! as NSIndexPath).row, animated: false)
            return
        }
        
        cell?.isSelected = false
        let lastSelected =  self.selectedStore
        self.selectedStore = indexPath
        let store = self.storeArray[(indexPath as NSIndexPath).row] as! [String:Any]
        self.selectedstoreId = store["id"] as! String
        tableView.reloadRows(at: [ self.selectedStore! ,lastSelected!], with: UITableViewRowAnimation.none)
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: CGRect(x: 3, y: 13, width: self.frame.width, height: self.frame.height - 13))
            viewLoad.backgroundColor = UIColor.white
            self.addSubview(viewLoad)
            viewLoad.startAnnimating(true)
        }
    }
    
    /**
     Save the address as preferred and if is necesary changes the store in selected address
     
     - parameter addressID: identifier of the address to save
     */
    func applyPrefered (_ addressID: String){
        //TODO: validar cambio de prefereida
        
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
        self.alertView?.setMessage("Cambiando tienda ...")

        
        //addViewLoad()
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_GR_SET_ADDRESS_PREFERRED.rawValue, label: "")
        
        let service = AddPreferedAddress()
        service.buildParams(addressID)
        service.callService([String:Any]() as! [String : Any],  successBlock:{ (resultCall:[String:Any]?) in
            print("success")
            self.alertView?.setMessage("Hemos guardado esta dirección y tienda como tu favorita.\n\n Únicamente se mostrarán los productos disponibles de esta tienda.")
            self.alertView?.showDoneIconWithoutClose()
            self.alertView?.showOkButton("Ok", colorButton: WMColor.green)
            self.onClose?()
            }, errorBlock: {(error: NSError) in
                self.viewLoad.stopAnnimating()
                self.viewLoad = nil
                print("error")
        })
        
       /* let service = GRAddressAddService()
        let serviceAddress = GRAddressesByIDService()
        serviceAddress.addressId = addressID
        serviceAddress.callService([:], successBlock: { (result:[String:Any]) -> Void in
            let name = result["name"] as! String!
            let outerNumber = result["outerNumber"] as! String!
            let innerNumber = result["innerNumber"] as! String!
            let reference1 = result["reference1"] as! String!
            let reference2 = result["reference2"] as! String!
            let zipCode = result["zipCode"] as! String!
            let street = result["street"] as! String!
            let city = result["city"] as! String!
            let state = result["state"] as! String!
            let county = result["county"] as! String!
            let neighborhoodID = result["neighborhoodID"] as! String!
            let address = ["storeID":self.selectedstoreId,"storeName":"","zipCode":zipCode,"addressID":addressID] as [String:Any]
            
            let dictSendpreferred = service.buildParams(city, addressID: addressID, zipCode: zipCode, street: street, innerNumber: innerNumber, state: state, county: county, neighborhoodID: neighborhoodID, phoneNumber: "", outerNumber: outerNumber, adName: name, reference1: reference1, reference2: reference2, storeID: self.selectedstoreId, storeName: "",operationType: "C", preferred: true)
            
            let dictSend = service.buildParams(city, addressID: addressID, zipCode: zipCode, street: street, innerNumber: innerNumber, state: state, county: county, neighborhoodID: neighborhoodID, phoneNumber: "", outerNumber: outerNumber, adName: name, reference1: reference1, reference2: reference2, storeID: self.selectedstoreId,storeName: "", operationType: "C", preferred: false)
            service.callService(requestParams: dictSend, successBlock: { (result:[String:Any]) -> Void in
                UserCurrentSession.sharedInstance.getStoreByAddress(address)  
                service.callService(requestParams: dictSendpreferred, successBlock: { (result:[String:Any]) -> Void in
                    self.alertView?.setMessage("Hemos guardado esta dirección y tienda como tu favorita.\n\n Únicamente se mostrarán los productos disponibles de esta tienda.")
                    self.alertView?.showDoneIconWithoutClose()
                    self.alertView?.showOkButton("Ok", colorButton: WMColor.green)
                    self.onClose?()
                    }, errorBlock: { (error:NSError) -> Void in
                        print("error")
                })
                }, errorBlock: { (error:NSError) -> Void in
                    print("error")
            })
            }, errorBlock: { (error:NSError) -> Void in
            })*/
        
 
        
    }
    
    

}
