//
//  GRAddressView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 06/04/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class GRAddressView: UIView, UITableViewDelegate, UITableViewDataSource {
    var cancelButton: UIButton?
    var newButton: UIButton?
    var tableAddress: UITableView?
    var titleLabel: UILabel?
    var layerLine: CALayer!
    var addressArray: [Any]! = []
    var viewLoad : WMLoadingView!
    var onCloseAddressView: (() -> Void)?
    var newAdressForm: (() -> Void)?
    var addressSelected: ((_ addressId:String,_ addressName:String,_ selectedStore:String,_ stores:[NSDictionary]) -> Void)?
    var blockRows:Bool = false
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
        
        self.titleLabel = UILabel()
        self.titleLabel!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabel!.text =  "Elige una dirección para cambiar de tienda"
        self.titleLabel!.textColor = WMColor.light_blue
        self.addSubview(self.titleLabel!)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(GRAddressView.close), for: UIControlEvents.touchUpInside)
        self.addSubview(cancelButton!)
        
        self.newButton = UIButton()
        self.newButton!.setTitle("Nueva Dirección", for:UIControlState())
        self.newButton!.titleLabel!.textColor = UIColor.white
        self.newButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.newButton!.backgroundColor = WMColor.light_blue
        self.newButton!.layer.cornerRadius = 17
        self.newButton!.addTarget(self, action: #selector(GRAddressView.new), for: UIControlEvents.touchUpInside)
        self.addSubview(newButton!)
        
        self.tableAddress = UITableView()
        self.tableAddress!.delegate = self
        self.tableAddress!.dataSource = self
        self.tableAddress!.register(GRAddressViewCell.self, forCellReuseIdentifier: "labelCell")
        self.addSubview(tableAddress!)
        self.callServiceAddressGR()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel?.frame = CGRect(x: 16, y: 62,width: self.frame.width, height: 14)
        self.tableAddress?.frame = CGRect(x: 16, y: self.titleLabel!.frame.maxY + 16 ,width: self.frame.width - 16, height: 210)
        self.layerLine.frame = CGRect(x: 0,y: self.tableAddress!.frame.maxY,width: self.frame.width, height: 1)
        self.cancelButton?.frame = CGRect(x: (self.frame.width/2) - 129,y: self.layerLine.frame.maxY + 16, width: 125, height: 34)
        self.newButton?.frame = CGRect(x: (self.frame.width/2) + 4 , y: self.layerLine.frame.maxY + 16, width: 125, height: 34)
    }
    
    /**
     Close the view
     */
    func close(){
        self.onCloseAddressView?()
    }
    
    /**
     Shows the new address form only if the user has less than 12 addresses
     */
    func new(){
        if self.addressArray!.count >= 12 {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(NSLocalizedString("profile.address.error.max",comment:""))
            self.alertView!.showErrorIcon("Ok")
            return
        }
        self.newAdressForm?()
    }
    
    //MARK: TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addressArray!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as? GRAddressViewCell
        var prefered = false
        
        let item = self.addressArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let name = item["name"] as! String
        if let pref = item["preferred"] as? NSNumber{
            if pref.intValue == 1 {
                prefered = true
            }
        }
        
        var addressId = ""
        if let addId =  item["addressID"] as? String {
            addressId = addId
        }
        
        if let addId =  item["id"] as? String {
            addressId = addId
        }
        cell!.selectionStyle = .none
        let textColor = prefered ? WMColor.light_blue : WMColor.reg_gray
        cell!.setValues(name, font: WMFont.fontMyriadProRegularOfSize(14), numberOfLines: 2, textColor: textColor,align:NSTextAlignment.left,addressID: addressId)
        if let isAddressOK = item["isAddressOk"] as? String {
            cell!.showErrorFieldImage(isAddressOK == "False")
        }else{
            cell!.showErrorFieldImage(false)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.blockRows {
            return
        }
        self.blockRows = true
        self.addViewLoad()
        let item = self.addressArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let validStore = item["isAddressOk"] as! String!
        if validStore == "False"{
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
            self.alertView?.setMessage("No hay tiendas cercanas a esta dirección, intenta con otra o crea una nueva.")
            self.alertView?.showErrorIcon("Ok")
            self.blockRows = false
            return
        }
        let serviceAddress = GRAddressesByIDService()
        serviceAddress.addressId = item["id"] as? String
        serviceAddress.callService([:], successBlock: { (result:NSDictionary) -> Void in
            let zipCode = result["zipCode"] as! String!
            let storeID = result["storeID"] as! String!
            let idAddress = result["addressID"] as! String!
            let addressName = result["name"] as! String!
            let serviceZip = GRZipCodeService()
            serviceZip.buildParams(zipCode)
            serviceZip.callService([:], successBlock: { (result:NSDictionary) -> Void in
                var stores = []
                stores = result["stores"] as! [NSDictionary]
                self.addressSelected?(addressId: idAddress,addressName: addressName, selectedStore: storeID, stores: stores as! [NSDictionary])
                self.viewLoad.stopAnnimating()
                }, errorBlock: { (error:NSError) -> Void in
                    print("error:: \(error)")
                    self.viewLoad.stopAnnimating()
                    self.blockRows = false
            })
            }) { (error:NSError) -> Void in
                self.viewLoad.stopAnnimating()
                self.blockRows = false
        }
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 46, width: self.bounds.width, height: self.bounds.height - 46))
            viewLoad.backgroundColor = UIColor.white
            self.addSubview(viewLoad)
            viewLoad.startAnnimating(true)
        }
    }
    
    //MARK: -Service
    /**
     Gets the user addresses
     */
    func callServiceAddressGR(){
        self.addViewLoad()
        let addressService = ShippingAddressByUserService()
        addressService.callService({ (resultCall:NSDictionary) -> Void in
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_GR_UPDATE_ADDRESS.rawValue, label:"")
            
            self.addressArray = []
            
            if  let resultAddress = resultCall["responseArray"] as? [Any] {
                self.addressArray = resultAddress
            }

            self.tableAddress!.reloadData()
            print("sucess")
            self.viewLoad.stopAnnimating()
            
            }, errorBlock: { (error:NSError) -> Void in
                //self.viewLoad.stopAnnimating()
                print("errorBlock")
        })
    }
}
