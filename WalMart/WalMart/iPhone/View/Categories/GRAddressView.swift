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
    var addressArray: [AnyObject]! = []
    var viewLoad : WMLoadingView!
    
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
        
        self.titleLabel = UILabel()
        self.titleLabel!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleLabel!.text =  "Elige una dirección para cambiar de tienda"
        self.titleLabel!.textColor = WMColor.light_blue
        self.addSubview(self.titleLabel!)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(cancelButton!)
        
        self.newButton = UIButton()
        self.newButton!.setTitle("Nueva Dirección", forState:.Normal)
        self.newButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.newButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.newButton!.backgroundColor = WMColor.light_blue
        self.newButton!.layer.cornerRadius = 17
        self.newButton!.addTarget(self, action: "new", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(newButton!)
        
        self.tableAddress = UITableView()
        self.tableAddress!.delegate = self
        self.tableAddress!.dataSource = self
        self.tableAddress!.separatorStyle = .None
        self.tableAddress!.registerClass(AddressViewCell.self, forCellReuseIdentifier: "labelCell")
        self.addSubview(tableAddress!)
        self.callServiceAddressGR()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel?.frame = CGRectMake(16, 62,self.frame.width, 14)
        self.tableAddress?.frame = CGRectMake(16, self.titleLabel!.frame.maxY + 16 ,self.frame.width - 32, 210)
        self.layerLine.frame = CGRectMake(0,self.tableAddress!.frame.maxY,self.frame.width, 1)
        self.cancelButton?.frame = CGRectMake((self.frame.width/2) - 129,self.layerLine.frame.maxY + 16, 125, 34)
        self.newButton?.frame = CGRectMake((self.frame.width/2) + 4 , self.layerLine.frame.maxY + 16, 125, 34)
    }
    
    //MARK: TableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addressArray!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as? AddressViewCell
        var prefered = false
        
        let item = self.addressArray[indexPath.item] as! NSDictionary
        let name = item["name"] as! String
        if let pref = item["preferred"] as? NSNumber{
            if pref.integerValue == 1 {
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
        cell!.showPreferedButton = false
        cell!.setValues(name, font: WMFont.fontMyriadProRegularOfSize(14), numberOfLines: 2, textColor: WMColor.gray, padding: 12,align:NSTextAlignment.Left, isViewLine:false, isPrefered:prefered, addressID: addressId)
        //cell!.delegateAddres = self
        //cell!.delegate = self
        if let isAddressOK = item["isAddressOk"] as? String {
            cell!.showErrorFieldImage(isAddressOK == "False")
        }else{
            cell!.showErrorFieldImage(false)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
    
    //MARK: -Service
    func callServiceAddressGR(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: CGRectMake(0, 46, self.bounds.width, self.bounds.height - 46))
            viewLoad.backgroundColor = UIColor.whiteColor()
            self.addSubview(viewLoad)
            viewLoad.startAnnimating(true)
        }
        
        let addressService = GRAddressByUserService()
        addressService.callService({ (resultCall:NSDictionary) -> Void in
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_GR_UPDATE_ADDRESS.rawValue, label:"")
            
            self.addressArray = []
            
            if  let resultAddress = resultCall["responseArray"] as? [AnyObject] {
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