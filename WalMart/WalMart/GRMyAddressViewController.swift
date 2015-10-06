//
//  GRMyAddressViewController.swift
//  WalMart
//
//  Created by Alonso Salcido on 05/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import UIKit

protocol GRMyAddressViewControllerDelegate{
    func okAction()
}

class GRMyAddressViewController: MyAddressViewController {
    
    var delegate: GRMyAddressViewControllerDelegate?
    var okButton: UIButton? = nil
    var hasCloseButton: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewBgSelectorBtn.hidden = true
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel!.text = NSLocalizedString("gr.address.MyAddress", comment: "")
        
        self.okButton = UIButton(frame: CGRectMake(0, 0, 98, 34))
        self.okButton!.backgroundColor = WMColor.UIColorFromRGB(0x2970ca)
        self.okButton!.layer.cornerRadius = 17
        self.okButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.okButton!.setTitle("Ok", forState: UIControlState.Normal)
        self.okButton!.center = CGPointMake(self.view.frame.width / 2, 32)
        self.okButton!.addTarget(self, action: "okAction", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
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
        self.newAddressButton!.frame = CGRectMake(self.view.bounds.width - (buttonWidth + 16.0), (header!.bounds.height - buttonHeight)/2, buttonWidth, buttonHeight)
        self.titleLabel!.frame = CGRectMake(self.newAddressButton!.frame.width , 0, self.view.bounds.width - (self.newAddressButton!.frame.width * 2), self.header!.frame.maxY)
        self.emptyView!.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        
        if self.hasCloseButton! {
            self.table!.frame =  CGRectMake(0,  self.header!.frame.maxY, bounds.width, bounds.height - self.header!.frame.maxY - bottomSpace)
            self.okButton!.frame = CGRectMake((bounds.width / 2) - 49,  self.table!.frame.maxY + 15, 98, 34)
            let line: CALayer = CALayer()
            line.frame = CGRectMake(0.0, self.table!.frame.maxY, bounds.width,1.0)
            line.backgroundColor = WMColor.UIColorFromRGB(0xF6F6F6, alpha: 0.7).CGColor
            self.view.layer.insertSublayer(line, atIndex: 0)
        }
        else{
            self.table!.frame =  CGRectMake(0,  self.header!.frame.maxY, bounds.width, bounds.height - self.header!.frame.maxY)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.addressController = IPAAddressViewController()
        self.showGRAddressForm = self.hasCloseButton
        super.tableView(tableView, didSelectRowAtIndexPath:indexPath)
    }
    
    override func deleteAddress(idAddress:String){
        self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
        super.deleteAddress(idAddress)
    }

    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let generic : UIView = UIView(frame: CGRectMake(0,0,tableView.frame.width,36))
        let titleView : UILabel = UILabel(frame:CGRectMake(16,0,tableView.frame.width,36))
        titleView.textColor = WMColor.listAddressHeaderSectionColor
        titleView.font = WMFont.fontMyriadProLightOfSize(14)
        titleView.text = NSLocalizedString("gr.address.table.header", comment: "")
        generic.addSubview(titleView)
        generic.backgroundColor = UIColor.whiteColor()
        return generic
    }
    
    func addCloseButton(){
        self.hasCloseButton = true
        //self.hiddenBack = true
        self.backButton = UIButton()
        self.backButton!.setImage(UIImage(named: "detail_close"), forState: UIControlState.Normal)
        self.backButton!.addTarget(self, action: "closeAddressView", forControlEvents: UIControlEvents.TouchUpInside)
        self.header?.addSubview(self.backButton!)
        self.view.addSubview(self.okButton!)
    }
    
    func closeAddressView(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        delegate?.okAction()
    }
    
    func okAction() {
       self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
       delegate?.okAction()
    }
}
