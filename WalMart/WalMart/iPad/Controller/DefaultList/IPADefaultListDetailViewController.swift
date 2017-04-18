//
//  IPADefaultListDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 02/07/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol IPADefaultListDetailViewControllerDelegate: class {
    func reloadViewList()
}

class IPADefaultListDetailViewController :  DefaultListDetailViewController, UIPopoverControllerDelegate {
    
    var sharePopover: UIPopoverController?
    weak var delegate : IPADefaultListDetailViewControllerDelegate?
    var isShared =  false
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = IPAProductDetailPageViewController()
        var productsToShow:[Any] = []
        for idx in 0 ..< self.detailItems!.count {
            let product = self.detailItems![idx]
            let upc = product["upc"] as! NSString
            let description = product["description"] as! NSString
            productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Groceries.rawValue, "saving":""])
        }
        controller.itemsToShow = productsToShow
        controller.ixSelected = indexPath.row
        controller.detailOf = self.defaultListName!
        
        if let navCtrl = self.navigationController!.parent as UIViewController! {
            navCtrl.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let shareWidth:CGFloat = 34.0
        let separation:CGFloat = 16.0
        var x = (self.footerSection!.frame.width - (shareWidth + separation + 254.0))/2
        let y = (self.footerSection!.frame.height - shareWidth)/2
        
        if !isShared {
          tableView?.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.header!.frame.maxY)
        }
        
        self.footerSection!.frame = CGRect(x: 0,  y: self.view.frame.maxY - 72 , width: self.view.frame.width, height: 72)
        self.duplicateButton?.frame = CGRect(x: 145, y: y, width: 34.0, height: 34.0)
            
        x = self.duplicateButton!.frame.maxX + 16.0
        self.shareButton!.frame = CGRect(x: x, y: y, width: shareWidth, height: shareWidth)
        x = self.shareButton!.frame.maxX + separation
        addToCartButton?.frame = CGRect(x: x, y: y, width: 256, height: 34.0)//CGRectMake(x, y, self.footerSection!.frame.width - (x + 16.0), 34.0)
        self.customLabel?.frame  = self.addToCartButton!.bounds
      
    }

    
    override func shareList() {
        isShared = true

        if let image = self.buildImageToShare() {
            
            let imageHead = UIImage(named:"detail_HeaderMail")
            self.backButton?.isHidden = true
            let headerCapture = UIImage(from: header)
            self.backButton?.isHidden = false

            let imgResult = UIImage.verticalImage(from: [imageHead!, headerCapture!, image])
            let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx")
            
            let controller = UIActivityViewController(activityItems: [self, imgResult, urlWmart!], applicationActivities: nil)
            self.sharePopover = UIPopoverController(contentViewController: controller)
            self.sharePopover!.delegate = self
            //self.sharePopover!.backgroundColor = UIColor.greenColor()
            let rect = self.footerSection!.convert(self.shareButton!.frame, to: self.view.superview!)
            self.sharePopover!.present(from: rect, in: self.view.superview!, permittedArrowDirections: .any, animated: true)
            
            controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        }
    }
    
    //MARK: activityViewControllerDelegate
    override func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any{
        return "Walmart"
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        
        
        let environment =  Bundle.main.object(forInfoDictionaryKey: "WMEnvironment") as! String
        var dominio = "https://www.walmart.com.mx"
        if environment != "PRODUCTION"{
            //            dominio = "http://192.168.43.192:8085"
            dominio = "http://192.168.43.192:8095"
        }
        var urlss  = ""
        if self.lineId != nil {
            let name  = self.schoolName!.replacingOccurrences(of: " ", with: "-")
            let desc = self.gradeName!.replacingOccurrences(of: " ", with: "-")
            let namelines = self.nameLine!.replacingOccurrences(of: " ", with: "-")
            
            var  appLink  = UserCurrentSession.urlWithRootPath("\(dominio)/images/m_webParts/banners/Carrusel/linkbts.html?os=1&idLine=\(self.lineId! as String)&nameLine=\(namelines)&name_\(name)&description=\(desc)")
            
            appLink = "\(dominio)/images/m_webParts/banners/Carrusel/linkbts.html?os=1&idLine=\(self.lineId! as String)&nameLine=\(namelines)&name=\(name)&description=\(desc)"
            
            //appLink = "walmartmexicoapp://bussines_mg&type_LIST&value_\(self.lineId! as String)&name_\(name)&description_\(desc)"
            
            urlss = "\n Entra a la aplicación:\n \(appLink!)"
        }
        
        
        if activityType == UIActivityType.mail {
            return "Hola, encontré estos productos en Walmart.¡Te los recomiendo! \n \n Siempre encuentra todo y pagas menos.\(urlss)"
        }else if activityType == UIActivityType.postToTwitter ||  activityType == UIActivityType.postToVimeo ||  activityType == UIActivityType.postToFacebook  {
            return "Chequa esta lista de productos:  #walmartapp #wow "
        }
        return "Chequa esta lista de productos: \(urlss) "
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        if activityType == UIActivityType.mail {
            if UserCurrentSession.sharedInstance.userSigned == nil {
                return "Encontré estos productos te pueden interesar en www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance.userSigned!.profile.name) encontró unos productos que te pueden interesar en www.walmart.com.mx"
            }
        }
        return ""
    }
    //-----
    
     //MARK: Delegate item cell
    override func didChangeQuantity(_ cell:DetailListViewCell){
        
        let indexPath = self.tableView!.indexPath(for: cell)
        if indexPath == nil {
            return
        }
        
        var isPesable = false
        var price: NSNumber? = nil
        var quantity: NSNumber? = nil
        
        let item = self.detailItems![indexPath!.row]
        
        if let pesable = item["type"] as? NSString {
            isPesable = pesable.intValue == 1
        }
        
        quantity = item["quantity"] as? NSNumber
        price = item["price"] as? NSNumber
        
        
        let width:CGFloat = self.view.frame.width
        let height:CGFloat = (self.view.frame.height - self.header!.frame.height) + 2.0
      
        _ = CGRect(x: 0, y: self.view.frame.height, width: width, height: height)
        
        if isPesable {
            self.quantitySelector = GRShoppingCartWeightSelectorView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 388.0), priceProduct: price,equivalenceByPiece:cell.equivalenceByPiece!,upcProduct:cell.upcVal!, isSearchProductView: false)
        }
        else {
            self.quantitySelector = GRShoppingCartQuantitySelectorView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 388.0), priceProduct: price,upcProduct:cell.upcVal!)
        }
        
        if let orderByPiece = item["orderByPiece"] as? Bool {
            quantitySelector?.validateOrderByPiece(orderByPiece: orderByPiece, quantity: quantity!.doubleValue, pieces: Int(quantity!))
        } else {
            quantitySelector?.first = true
            quantitySelector?.userSelectValue(quantity!.stringValue)
        }
        
        self.view.addSubview(self.quantitySelector!)
        self.quantitySelector!.closeAction = { () in
            self.sharePopover!.dismiss(animated: true)
            //self.removeSelector()
        }
        self.quantitySelector!.isFromList = true
        self.quantitySelector!.isUpcInList = false
        self.quantitySelector!.addToCartAction = { (quantity:String) in
            var item = self.detailItems![indexPath!.row]
            //var upc = item["upc"] as? String
            item["quantity"] = NSNumber(value: Int(quantity)! as Int)
            item["orderByPiece"] = self.quantitySelector!.orderByPiece
            self.detailItems![indexPath!.row] = item
            self.tableView?.reloadData()
            //self.removeSelector()
            self.updateTotalLabel()
            self.sharePopover!.dismiss(animated: true)
            //TODO: Update quantity
        }
        
        self.quantitySelector!.backgroundColor = UIColor.clear
        self.quantitySelector!.backgroundView!.backgroundColor = UIColor.clear
        let controller = UIViewController()
        controller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 388.0)
        controller.view.addSubview(self.quantitySelector!)
        controller.view.backgroundColor = UIColor.clear
        
        self.sharePopover = UIPopoverController(contentViewController: controller)
        self.sharePopover!.contentSize =  CGSize(width: 320.0, height: 388.0)
        self.sharePopover!.delegate = self
        self.sharePopover!.backgroundColor = WMColor.light_blue
        let rect = cell.convert(cell.quantityIndicator!.frame, to: self.view.superview!)
        self.sharePopover!.present(from: rect, in: self.view.superview!, permittedArrowDirections: .any, animated: true)
        
    }
    
    //MARK: - UIPopoverControllerDelegate
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController) {
        self.sharePopover = nil
    }

    override func duplicate() {
        self.invokeSaveListToDuplicateService(defaultListName!, successDuplicateList: { () -> Void in
            self.delegate?.reloadViewList()
            self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
            self.alertView!.showDoneIcon()
        })
    }
    
}
