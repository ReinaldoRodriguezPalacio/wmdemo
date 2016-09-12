//
//  CheckOutShippingSelectionController.swift
//  WalMart
//
//  Created by Everardo Garcia on 06/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

protocol CheckOutShippingSelectionDelegate {
    func selectDataTypeShipping(envio: String, util: String, date: String, rowSelected: Int)
}


class CheckOutShippingSelectionController: NavigationViewController, UITableViewDelegate,UITableViewDataSource {

    var tableShippingSelection : UITableView!
    var saveButton : UIButton?
    var arrayTypeSelect : NSMutableArray?
    var titleString : String?
    var delegate: CheckOutShippingSelectionDelegate?
    var rowSelected : Int? = -1
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        if IS_IPAD {
            self.backButton?.hidden = true
        }
        
        self.titleLabel?.text = titleString
        
        tableShippingSelection = UITableView(frame:CGRectMake(0, 46 , self.view.frame.width, self.view.frame.height - 46))
        tableShippingSelection.clipsToBounds = true
        tableShippingSelection.backgroundColor =  WMColor.light_light_gray
        tableShippingSelection.backgroundColor =  UIColor.whiteColor()
        tableShippingSelection.layoutMargins = UIEdgeInsetsZero
        tableShippingSelection.separatorInset = UIEdgeInsetsZero
        tableShippingSelection.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        tableShippingSelection.delegate = self
        tableShippingSelection.dataSource = self
        tableShippingSelection.separatorStyle = .None
        tableShippingSelection.registerClass(CheckOutShippingSelectionCell.self, forCellReuseIdentifier: "CheckOutShippingSelection")
         tableShippingSelection.reloadData()
        
        self.view.addSubview(tableShippingSelection)
     
        self.saveButton = UIButton(frame: CGRect(x:16 , y:16 , width: (self.view.frame.width - 40) / 2  , height:34))
        self.saveButton!.setTitle("Guardar", forState: .Normal)
        self.saveButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.saveButton!.addTarget(self, action: #selector(CheckOutShippingSelectionController.save), forControlEvents: .TouchUpInside)
        self.saveButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor =  WMColor.green
        self.saveButton!.layer.cornerRadius =  17
        self.view.addSubview(self.saveButton!)
        
        let shippingNormal = ["type":"Envío normal" ,"util":"Hasta 7 días" ,"date":"(Fecha estimada de entrega 15/03/2016)" ]
        let shippingEstandar = ["type":"Envío estandar" ,"util":"Hasta 5 días" ,"date":"(Fecha estimada de entrega 13/03/2016)" ]
        let shippingExpress = ["type":"Envío express" ,"util":"Hasta 1 días" ,"date":"(Fecha estimada de entrega 08/03/2016)" ]

        arrayTypeSelect = NSMutableArray()
        
        arrayTypeSelect?.addObject(shippingNormal)
        arrayTypeSelect?.addObject(shippingEstandar)
        arrayTypeSelect?.addObject(shippingExpress)
     
        if rowSelected >= 0 {
            var indexPath = NSIndexPath(forItem: rowSelected!, inSection: 0)
            tableShippingSelection.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Top)
        }
        
        self.tableShippingSelection.bringSubviewToFront(self.view)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableShippingSelection.frame = CGRectMake(0, 46 , self.view.frame.width, self.view.frame.height - 46 - 62)
        self.saveButton!.frame =  CGRectMake(12 , self.view.frame.height - 52 , self.view.frame.width - 24 , 34)
       
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let content : UIView = UIView(frame: CGRectMake(0.0, 0.0 , self.view.frame.width, 32))
        content.backgroundColor = UIColor.whiteColor()
        
        let titleLabel = UILabel(frame: CGRectMake(15.0, 15.0, self.view.frame.width, 16))
        titleLabel.text = "Selecciona un tipo de Envío"
        titleLabel.textColor = WMColor.light_blue
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        
        
        content.addSubview(titleLabel)
        
        return content
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellText = tableShippingSelection.dequeueReusableCellWithIdentifier("CheckOutShippingSelection", forIndexPath: indexPath) as! CheckOutShippingSelectionCell
        
        let dic = self.arrayTypeSelect![indexPath.row] as? NSDictionary
        
        let type = dic!["type"] as! String
        let util = dic!["util"] as! String
        let date = dic!["date"] as! String
        
        cellText .setValues(type, util: util, date: date)
        cellText.selectionStyle = UITableViewCellSelectionStyle.None
        
        if indexPath.row == rowSelected {
            cellText.setSelected(true, animated: true)
            cellText.selectedButton!.selected = true
        }else {
            cellText.setSelected(false, animated: true)
             cellText.selectedButton!.selected = false
            
        }
        return cellText
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        rowSelected = indexPath.row
    }
    
    
    func save () {
        //Seleccionar un Tipo de envio
        if self.rowSelected! != -1  {
            let dic = self.arrayTypeSelect![self.rowSelected!] as? NSDictionary
            
            let type = dic!["type"] as! String
            let util = dic!["util"] as! String
            let date = dic!["date"] as! String
            self.delegate?.selectDataTypeShipping(type, util: util, date: date, rowSelected:self.rowSelected!)
        }
        self.navigationController!.popViewControllerAnimated(true)

        
    }
    
}