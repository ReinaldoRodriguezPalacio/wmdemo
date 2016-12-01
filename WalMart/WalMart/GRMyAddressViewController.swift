//
//  GRMyAddressViewController.swift
//  WalMart
//
//  Created by Alonso Salcido on 05/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRMyAddressViewController: MyAddressViewController {
    
    var okButton: UIButton? = nil
    var hasCloseButton: Bool! = false
    var onClosePicker : (() -> Void)?
    var onOkAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewBgSelectorBtn.isHidden = true
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel!.text = NSLocalizedString("gr.address.MyAddress", comment: "")
        
        self.okButton = UIButton(frame: CGRect(x: 0, y: 0, width: 98, height: 34))
        self.okButton!.backgroundColor = WMColor.light_blue
        self.okButton!.layer.cornerRadius = 17
        self.okButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.okButton!.setTitle("Ok", for: UIControlState())
        self.okButton!.center = CGPoint(x: self.view.frame.width / 2, y: 32)
        self.okButton!.addTarget(self, action: #selector(GRMyAddressViewController.okAction), for: UIControlEvents.touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.hasCloseButton! {
            self.addCloseButton()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let buttonWidth: CGFloat = 55.0
        let buttonHeight: CGFloat = 22.0
        let bottomSpace: CGFloat = 65
        
        let bounds = self.view.bounds
        //tamaño
        self.newAddressButton!.frame = CGRect(x: self.view.bounds.width - (buttonWidth + 16.0), y: (header!.bounds.height - buttonHeight)/2, width: buttonWidth, height: buttonHeight)
        self.titleLabel!.frame = CGRect(x: self.newAddressButton!.frame.width - 10 , y: 0, width: self.view.bounds.width - (self.newAddressButton!.frame.width * 2), height: self.header!.frame.maxY)
        self.emptyView!.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
        
        if self.hasCloseButton! {
            self.table!.frame =  CGRect(x: 0,  y: self.header!.frame.maxY, width: bounds.width, height: bounds.height - self.header!.frame.maxY - bottomSpace)
            self.okButton!.frame = CGRect(x: (bounds.width / 2) - 49,  y: self.table!.frame.maxY + 15, width: 98, height: 34)
            let line: CALayer = CALayer()
            line.frame = CGRect(x: 0.0, y: self.table!.frame.maxY, width: bounds.width,height: 1.0)
            line.backgroundColor = WMColor.light_light_gray.cgColor
            self.view.layer.insertSublayer(line, at: 0)
        }
        else{
            self.table!.frame =  CGRect(x: 0,  y: self.header!.frame.maxY, width: bounds.width, height: bounds.height - self.header!.frame.maxY)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.addressController = IPAAddressViewController()
        self.showGRAddressForm = self.hasCloseButton
        super.tableView(tableView, didSelectRowAt:indexPath)
    }
    
    override func deleteAddress(_ idAddress:String){
        self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
        super.deleteAddress(idAddress)
    }

    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let generic : UIView = UIView(frame: CGRect(x: 0,y: 0,width: tableView.frame.width,height: 36))
        let titleView : UILabel = UILabel(frame:CGRect(x: 16,y: 0,width: tableView.frame.width,height: 36))
        titleView.textColor = WMColor.light_blue
        titleView.font = WMFont.fontMyriadProLightOfSize(14)
        titleView.text = NSLocalizedString("gr.address.table.header", comment: "")
        generic.addSubview(titleView)
        generic.backgroundColor = UIColor.white
        return generic
    }
    
    func addCloseButton(){
        self.hasCloseButton = true
        //self.hiddenBack = true
        self.backButton = UIButton()
        self.backButton!.setImage(UIImage(named: "detail_close"), for: UIControlState())
        self.backButton!.addTarget(self, action: #selector(GRMyAddressViewController.closeAddressView), for: UIControlEvents.touchUpInside)
        self.header?.addSubview(self.backButton!)
        self.view.addSubview(self.okButton!)
    }
    
    override func newAddress(){
        self.superAddressController = SuperAddressViewController()
        self.superAddressController!.showGRAddressForm = self.hasCloseButton
        self.superAddressController!.allAddress =  self.arrayAddressShippingGR
         
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action: WMGAIUtils.ACTION_OPEN_ACCOUNT_ADDRES.rawValue, label: "")
        
        self.navigationController!.pushViewController(self.superAddressController, animated: true)
    }
    
    override func deleteAddressGR(_ idAddress:String){
        if self.hasCloseButton!
        {
            self.alertView = IPOWMAlertViewController.showAlert(self,imageWaiting: UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
        }
        else{
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
        }
        
        self.alertView!.setMessage(NSLocalizedString("profile.message.delete",comment:""))
        
        let service = GRAddressAddService()
        let serviceAddress = GRAddressesByIDService()
        serviceAddress.addressId = idAddress
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
            let storeID = result["storeID"] as! String!
            
            let dictSend = service.buildParams(city!, addressID: idAddress, zipCode: zipCode!, street: street!, innerNumber: innerNumber!, state: state!, county: county!, neighborhoodID: neighborhoodID!, phoneNumber: "", outerNumber: outerNumber!, adName: name!, reference1: reference1!, reference2: reference2!, storeID: storeID!,storeName: "", operationType: "B", preferred: false)
            
            service.callService(requestParams: dictSend, successBlock: { (result:[String:Any]) -> Void in
                                
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_GR_DELETE_ADDRESS.rawValue, label:"")
                
                if let message = result["message"] as? String {
                    if self.alertView != nil {
                        self.alertView!.setMessage("\(message)")
                        self.alertView!.showDoneIcon()
                    }
                    let serviceAddress = GRAddressesByIDService()
                    serviceAddress.addressId = result["addressID"] as? String
                    serviceAddress.callService([:], successBlock: { (result:[String:Any]) -> Void in
                        UserCurrentSession.sharedInstance.getStoreByAddress(result)
                        }, errorBlock: { (error:NSError) -> Void in
                    })
                }
                self.alertView = nil
                
                if self.btnSuper.isSelected {
                    self.callServiceAddressGR()
                }else{
                    self.callServiceAddress()
                }
                
                }, errorBlock: { (error:NSError) -> Void in
                    print("error")
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
                    self.alertView = nil
                    
            })
            }, errorBlock: { (error:NSError) -> Void in
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
                self.alertView = nil
        })
    }
    
    func closeAddressView(){
        self.onClosePicker?()
        self.onOkAction?()
    }
    
    func okAction() {
       self.onClosePicker?()
       self.onOkAction?()
    }
}
