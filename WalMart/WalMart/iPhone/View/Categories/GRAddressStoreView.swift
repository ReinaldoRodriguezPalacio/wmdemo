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
    var storeArray: [AnyObject]! = []
    var viewLoad : WMLoadingView!
    var selectedStore: NSIndexPath?
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
        layerLine.backgroundColor = WMColor.light_gray.CGColor
        self.layer.insertSublayer(layerLine, atIndex: 0)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Regresar", forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(GRAddressStoreView.close), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Cambiar Tienda", forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(GRAddressStoreView.save), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(saveButton!)
        
        self.tableStore = UITableView()
        self.tableStore!.delegate = self
        self.tableStore!.dataSource = self
        self.tableStore!.backgroundColor = UIColor.whiteColor()
        self.tableStore!.registerClass(SelectItemTableViewCell.self, forCellReuseIdentifier: "cellSelItem")

        self.addSubview(tableStore!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let minVTableHeigth : CGFloat = (1.5 * 46.0)
        var tableHeight = CGFloat(storeArray.count) * 46.0
        tableHeight = max(minVTableHeigth,tableHeight)
        self.tableStore?.frame = CGRectMake(16,0,self.frame.width - 16, min(210,tableHeight))
        self.layerLine.frame = CGRectMake(0,self.tableStore!.frame.maxY,self.frame.width, 1)
        self.cancelButton?.frame = CGRectMake((self.frame.width/2) - 129,self.layerLine.frame.maxY + 16, 125, 34)
        self.saveButton?.frame = CGRectMake((self.frame.width/2) + 4 , self.layerLine.frame.maxY + 16, 125, 34)
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storeArray!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellSelItem") as! SelectItemTableViewCell!
        let store = self.storeArray[indexPath.row] as! [String:AnyObject]
        cell.textLabel?.text = store["name"] as? String
        cell.checkSelected.frame = CGRectMake(0, 0, 33, 46)
        cell.selectionStyle = .None
        if selectedstoreId == store["id"] as? String {
            self.selectedStore = self.selectedStore ?? indexPath
        }
        if self.selectedStore != nil {
            cell.setSelected(indexPath.row == self.selectedStore!.row, animated: false)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        self.selectedStore =  self.selectedStore ?? indexPath
        
        if self.selectedStore == indexPath  {
            cell?.setSelected(indexPath.row == self.selectedStore!.row, animated: false)
            return
        }
        
        cell?.selected = false
        let lastSelected =  self.selectedStore
        self.selectedStore = indexPath
        let store = self.storeArray[indexPath.row] as! [String:AnyObject]
        self.selectedstoreId = store["id"] as! String
        tableView.reloadRowsAtIndexPaths([ self.selectedStore! ,lastSelected!], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: CGRectMake(3, 13, self.frame.width, self.frame.height - 13))
            viewLoad.backgroundColor = UIColor.whiteColor()
            self.addSubview(viewLoad)
            viewLoad.startAnnimating(true)
        }
    }
    
    /**
     Save the address as preferred and if is necesary changes the store in selected address
     
     - parameter addressID: identifier of the address to save
     */
    func applyPrefered (addressID: String){
        //TODO: validar cambio de prefereida
        
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
        self.alertView?.setMessage("Cambiando tienda ...")

        
        //addViewLoad()
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_GR_SET_ADDRESS_PREFERRED.rawValue, label: "")
        
        let service = AddPreferedAddress()
        service.buildParams(addressID)
        service.callService(NSDictionary(),  successBlock:{ (resultCall:NSDictionary?) in
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
        serviceAddress.callService([:], successBlock: { (result:NSDictionary) -> Void in
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
            let address = ["storeID":self.selectedstoreId,"storeName":"","zipCode":zipCode,"addressID":addressID] as NSDictionary
            
            let dictSendpreferred = service.buildParams(city, addressID: addressID, zipCode: zipCode, street: street, innerNumber: innerNumber, state: state, county: county, neighborhoodID: neighborhoodID, phoneNumber: "", outerNumber: outerNumber, adName: name, reference1: reference1, reference2: reference2, storeID: self.selectedstoreId, storeName: "",operationType: "C", preferred: true)
            
            let dictSend = service.buildParams(city, addressID: addressID, zipCode: zipCode, street: street, innerNumber: innerNumber, state: state, county: county, neighborhoodID: neighborhoodID, phoneNumber: "", outerNumber: outerNumber, adName: name, reference1: reference1, reference2: reference2, storeID: self.selectedstoreId,storeName: "", operationType: "C", preferred: false)
            service.callService(requestParams: dictSend, successBlock: { (result:NSDictionary) -> Void in
                UserCurrentSession.sharedInstance().getStoreByAddress(address)  
                service.callService(requestParams: dictSendpreferred, successBlock: { (result:NSDictionary) -> Void in
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
