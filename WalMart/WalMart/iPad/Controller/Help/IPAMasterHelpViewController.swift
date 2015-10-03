//
//  IPAMasterHelpViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 22/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit


class IPAMasterHelpViewController: UISplitViewController, UISplitViewControllerDelegate, IPAMoreOptionsViewControllerDelegate, CameraViewControllerDelegate,BarCodeViewControllerDelegate { // HelpViewControllerDelegate{

    var selected : Int? = nil
    var navigation : UINavigationController!
    var navController = UIViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        self.delegate = self
        self.navigation = UINavigationController()
        
        let storyboard = self.loadStoryboardDefinition()
        let vc = storyboard!.instantiateViewControllerWithIdentifier("ipaMoreVC")
            if let vcRoot = vc as? IPAMoreOptionsViewController {
                vcRoot.delegate = self
                self.navController = vc
                self.viewControllers = [vc, navigation]
            }

        let recent = IPAHelpViewController()
        self.navigation.pushViewController(recent, animated: true)
        selected = 5
        
        if(self.respondsToSelector(Selector("maximumPrimaryColumnWidth")))
        {
            if #available(iOS 8.0, *) {
                self.maximumPrimaryColumnWidth = 342
                self.minimumPrimaryColumnWidth = 342
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    
    func selectedDetail(row: Int) {
        
        if selected == row && selected != 3 && selected != 5 {
            return
        }
    
        if selected == row && selected != 3 && selected != 5 {
            self.navigation.popToRootViewControllerAnimated(true)
            return
        }
        self.navigation = UINavigationController()
        self.navigation!.popViewControllerAnimated(true)
        
        switch row {
        case 0:
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PROFILE.rawValue, action: WMGAIUtils.EVENT_PROFILE_MYADDRESSES.rawValue, label: "", value: nil).build() as [NSObject : AnyObject])
            }
            let myAddres = IPAMyAddressViewController()
            self.navigation.pushViewController(myAddres, animated: true)

        case 1:
            let recent = IPARecentProductsViewController()
            self.navigation.pushViewController(recent, animated: true)
        case 2:
            let order = IPAOrderViewController()
            self.navigation.pushViewController(order, animated: true)
        case 3:
            let cameraController = CameraViewController()
            cameraController.delegate = self
            self.presentViewController(cameraController, animated: true, completion: nil)
            let recent = IPAHelpViewController()
            self.navigation.pushViewController(recent, animated: false)
        case 4:
            scanTicket()
            return
        case 5:
            let webCtrl = IPOWebViewController()
            webCtrl.openURLFactura()
            self.presentViewController(webCtrl,animated:true,completion:nil)
            let recent = IPAHelpViewController()
            self.navigation.pushViewController(recent, animated: false)
        case 6:
            //Notifica
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("notificationVC")
            self.navigation.pushViewController(controller, animated: true)
        case 7:
            let recent = IPAHelpViewController()
            self.navigation.pushViewController(recent, animated: true)
            
        case 8:
            let recent = IPATermViewController()
            self.navigation.pushViewController(recent, animated: true)
        case 9:
            
            let recent = IPASupportViewController()
            self.navigation.pushViewController(recent, animated: true)
        case 10:
            let edit = IPAEditProfileViewController()
            //var indexPath = NSIndexPath(forItem:Int(selected!), inSection:0)
            self.navigation.pushViewController(edit, animated: true)
        default :
            print("other pressed")
        }
        
//        selected = row
//        self.viewControllers = [profile, navigation];
//        switch row {
//        case 0:
//            var recent = IPAHelpViewController()
//            self.navigation.pushViewController(recent, animated: true)
//        case 1:
//            var recent = IPATermViewController()
//            self.navigation.pushViewController(recent, animated: true)
//        case 2:
//            
//            var recent = IPASupportViewController()
//            self.navigation.pushViewController(recent, animated: true)
//            
//        default :
//            println("other pressed")
//        }
        
        selected = row
        self.viewControllers = [self.navController, navigation];
    }
    
    
    func loadStoryboardDefinition() -> UIStoryboard? {
        let storyboardName = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? "Storyboard_iphone" : "Storyboard_ipad"
        let storyboard : UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil);
        return storyboard;
    }
    
    // MARK: - CameraViewControllerDelegate
   func photoCaptured(value: String?,done: (() -> Void)) {
        if value != nil || value == "" {
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_HOME.rawValue, action: WMGAIUtils.EVENT_SEARCHACTION.rawValue, label: value, value: nil).build() as [NSObject : AnyObject])
        }
        
        let controller = IPASearchProductViewController()
        controller.searchContextType = .WithText
        controller.titleHeader = value
        controller.textToSearch = value
        let controllernav = self.navigationController
        if controllernav != nil {
          //  if controllernav!.delegate != nil {
            //    controllernav!.delegate = nil
            //}
            done()
            controllernav?.pushViewController(controller, animated: true)
        }
      }
    }
    
    
    //Ticket
    
    func scanTicket() {
        let barCodeController = IPABarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.delegate = self
        barCodeController.applyPadding = false
        self.presentViewController(barCodeController, animated: true, completion: nil)
    }
    
    //MARK: - BarCodeViewControllerDelegate
    func barcodeCaptured(value:String?) {
        if value == nil {
            return
        }
        print("Code \(value)")
        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.message.retrieveProductsFromTicket", comment:""))
        let service = GRProductByTicket()
        service.callService(service.buildParams(value!),
            successBlock: { (result: NSDictionary) -> Void in
                if let items = result["items"] as? [AnyObject] {
                    
                    if items.count == 0 {
                        alertView!.setMessage(NSLocalizedString("list.message.noProductsForTicket", comment:""))
                        alertView!.showErrorIcon("Ok")
                        return
                    }
                    
                    let saveService = GRSaveUserListService()
                    
                    alertView!.setMessage(NSLocalizedString("list.message.creatingListFromTicket", comment:""))
                    
                    var products:[AnyObject] = []
                    for var idx = 0; idx < items.count; idx++ {
                        var item = items[idx] as! [String:AnyObject]
                        let upc = item["upc"] as! String
                        let quantity = item["quantity"] as! NSNumber
                        let param = saveService.buildBaseProductObject(upc: upc, quantity: quantity.integerValue)
                        products.append(param)
                    }
                    
                    let fmt = NSDateFormatter()
                    fmt.dateFormat = "MMM d hh:mm:ss"
                    let name = fmt.stringFromDate(NSDate())
                    //var number = 0;
                    
                    
                    
                    
                    
                    saveService.callService(saveService.buildParams(name, items: products),
                        successBlock: { (result:NSDictionary) -> Void in
                            //TODO
                            alertView!.setMessage(NSLocalizedString("list.message.listDone", comment: ""))
                            alertView!.showDoneIcon()
                            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowGRLists.rawValue, object: nil)
                        },
                        errorBlock: { (error:NSError) -> Void in
                            alertView!.setMessage(error.localizedDescription)
                            alertView!.showErrorIcon("Ok")
                        }
                    )
                }
            }, errorBlock: { (error:NSError) -> Void in
                alertView!.setMessage(error.localizedDescription)
                alertView!.showErrorIcon("Ok")
            }
        )
    }
    
}
