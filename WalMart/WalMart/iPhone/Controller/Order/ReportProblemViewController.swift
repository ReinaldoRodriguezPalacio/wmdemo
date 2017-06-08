//
//  ReportProblemViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 07/06/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class ReportProblemViewController: NavigationViewController {
    
    var orderItems: [[String:Any]]? = nil
    var tableProducts: UITableView!
    var mesageLabel: UILabel!
    var reasonLabel: UILabel!
    var reasonField: FormFieldView!
    var saveButton: UIButton!
    var cancelButton: UIButton!
    var layerLineMessage: CALayer!
    var layerLinefooter: CALayer!

    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREVIOUSORDERS.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.titleLabel!.text = "Reportar un problema"
        
        self.mesageLabel = UILabel()
        self.mesageLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.mesageLabel.textColor = WMColor.gray
        self.mesageLabel.text = "Selecciona un motivo por el cuál requieres reportar un problema con este envío."
        self.mesageLabel.numberOfLines = 2
        self.mesageLabel.textAlignment = .left
        
        self.reasonLabel = UILabel()
        self.reasonLabel.font = WMFont.fontMyriadProLightOfSize(14)
        self.reasonLabel.textColor = WMColor.light_blue
        self.reasonLabel.text = "Motivo"
        self.reasonLabel.textAlignment = .left
        
        self.reasonField = FormFieldView(frame: CGRect(x:16, y: self.header!.frame.maxY + 110, width:self.view.frame.width - 32, height: 40))
        self.reasonField.setCustomPlaceholder("Seleciona una opción")
        self.reasonField.typeField = .list
        self.reasonField.setImageTypeField()
        
        self.tableProducts = UITableView()
        self.tableProducts.backgroundColor = UIColor.white
        self.tableProducts.delegate = self
        self.tableProducts.dataSource = self
        self.tableProducts.separatorStyle = .none
        self.tableProducts.register(ProductReportProblemTableViewCell.self, forCellReuseIdentifier: "orderCell")
        
        self.layerLineMessage = CALayer()
        layerLineMessage.backgroundColor = WMColor.light_light_gray.cgColor
        self.view.layer.insertSublayer(layerLineMessage, at: 1000)
        
        self.layerLinefooter = CALayer()
        layerLinefooter.backgroundColor = WMColor.light_light_gray.cgColor
        self.view.layer.insertSublayer(layerLinefooter, at: 999)
        
        self.cancelButton = UIButton()
        self.cancelButton.setTitle(NSLocalizedString("productdetail.cancel", comment:""), for:UIControlState())
        self.cancelButton.titleLabel!.textColor = WMColor.light_blue
        self.cancelButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton.layer.cornerRadius = 17
        self.cancelButton.addTarget(self, action: Selector("back"), for: UIControlEvents.touchUpInside)
        
        self.saveButton = UIButton()
        self.saveButton.setTitle("Enviar", for:UIControlState())
        self.saveButton.titleLabel!.textColor = UIColor.white
        self.saveButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton.backgroundColor = WMColor.green
        self.saveButton.layer.cornerRadius = 17
       // self.saveButton.addTarget(self, action: #selector(nextStep), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(self.mesageLabel)
        self.view.addSubview(self.reasonLabel)
        self.view.addSubview(self.reasonField)
        self.view.addSubview(self.tableProducts)
        self.view.addSubview(self.cancelButton)
        self.view.addSubview(self.saveButton)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.mesageLabel.frame = CGRect(x:16, y: self.header!.frame.maxY, width:self.view.frame.width - 32, height: 64)
        self.layerLineMessage.frame = CGRect(x:0, y: self.mesageLabel.frame.maxY, width: self.view.frame.width, height: 1)
        self.reasonLabel.frame = CGRect(x:16, y: self.mesageLabel.frame.maxY, width:self.view.frame.width - 32, height: 46)
        self.reasonField.frame = CGRect(x:16, y: self.reasonLabel.frame.maxY, width:self.view.frame.width - 32, height: 40)
        self.tableProducts.frame = CGRect(x:0, y: self.reasonField.frame.maxY + 16, width:self.view.frame.width, height: self.view.frame.height - ( self.reasonField.frame.maxY + 126))
        self.layerLinefooter.frame = CGRect(x:0, y: self.tableProducts.frame.maxY, width: self.view.frame.width, height: 1)
        self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - (172), y: self.layerLinefooter.frame.maxY + 16, width: 164, height: 34)
        self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.layerLinefooter.frame.maxY + 16, width: 164, height: 34)
        
    }
    
}

//MARK: - UITableViewDelegate
extension ReportProblemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orderItems!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        let cellOrderProduct = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! ProductReportProblemTableViewCell
        cellOrderProduct.frame = CGRect(x: 0, y: 0, width: self.tableProducts.frame.width, height: cellOrderProduct.frame.height)
        
        let dictProduct = self.orderItems![indexPath.row] 
        
        let descript = dictProduct["description"] as! String
        var quantityStr = ""
        if let quantityProd = dictProduct["quantity"] as? String {
            quantityStr = quantityProd
        }
        if let quantityProd = dictProduct["quantity"] as? NSNumber {
            quantityStr = quantityProd.stringValue
        }
        var urlImage = ""
        if let imageURLArray = dictProduct["imageUrl"] as? [Any] {
            if imageURLArray.count > 0 {
                urlImage = imageURLArray[0] as! String
            }
        }
        if let imageURLArray = dictProduct["imageUrl"] as? NSString {
            urlImage = imageURLArray as String
        }
        var priceStr = ""
        if let price = dictProduct["price"] as? NSString {
            priceStr = price as String
        }
        if let price = dictProduct["price"] as? NSNumber {
            priceStr = price.stringValue
        }
    
        cellOrderProduct.setValues(productImageURL:urlImage,productShortDescription:descript,productPrice:priceStr,quantity:quantityStr as NSString,provider: "ACME")
        cell = cellOrderProduct
        cell!.selectionStyle = UITableViewCellSelectionStyle.none

        return cell!

    }
}

//MARK: - UITableViewDataSource
extension ReportProblemViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
}

