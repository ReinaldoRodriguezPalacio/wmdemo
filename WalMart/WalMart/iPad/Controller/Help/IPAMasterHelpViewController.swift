//
//  IPAMasterHelpViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 22/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import CoreData


class IPAMasterHelpViewController: UISplitViewController, UISplitViewControllerDelegate, IPAMoreOptionsViewControllerDelegate, CameraViewControllerDelegate { // HelpViewControllerDelegate{

    var selected : Int? = nil
    var navigation : UINavigationController!
    var navController = UIViewController()
    var showPromos: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        self.delegate = self
        self.navigation = UINavigationController()
        
        let storyboard = self.loadStoryboardDefinition()
        let vc = storyboard!.instantiateViewController(withIdentifier: "ipaMoreVC")
            if let vcRoot = vc as? IPAMoreOptionsViewController {
                vcRoot.delegate = self
                self.navController = vc
                self.viewControllers = [vc, navigation]
            }

        let recent = IPAHelpViewController()
        self.navigation.pushViewController(recent, animated: true)
        selected = 8 // 7
        
        if(self.responds(to: #selector(getter: UISplitViewController.maximumPrimaryColumnWidth)))
        {
            self.maximumPrimaryColumnWidth = 342
            self.minimumPrimaryColumnWidth = 342
        }
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    func selectedDetail(_ row: Int) {
        
        if selected == row && selected != 3 && selected != 5 && selected != 6  {//add
            return
        }
    
        if selected == row && selected != 3 && selected != 5 && selected != 6  {
            self.navigation.popToRootViewController(animated: true)
            return
        }
        self.navigation = UINavigationController()
        self.navigation!.popViewController(animated: true)
        
        switch row {
        case 0:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_ACCOUNT_ADDRES.rawValue, label: "")

            let myAddres = IPAMyAddressViewController()
            self.navigation.pushViewController(myAddres, animated: true)

        case 1:
              //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_MORE_ITEMES_PURCHASED.rawValue, label: "")
            let recent = IPARecentProductsViewController()
            self.navigation.pushViewController(recent, animated: true)
        case 2:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PREVIOUS_ORDERS.rawValue, label: "")
            let order = IPAOrderViewController()
            self.navigation.pushViewController(order, animated: true)
        /*case 3:
            let refered = ReferedViewController()
            self.navigation.pushViewController(refered, animated: true)
            refered.navigationController!.setNavigationBarHidden(true, animated: true)
            refered.hiddenBack = true*/
        case 3:
            //Promotios
            print("Open promotions")
            self.openPromotios()
            let recent = IPAHelpViewController()
            self.navigation.pushViewController(recent, animated: false)
        case 4:
              //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue , action:WMGAIUtils.ACTION_OPEN_SEARCH_BY_TAKING_A_PHOTO.rawValue , label: "" )
            let cameraController = CameraViewController()
            cameraController.delegate = self
            self.present(cameraController, animated: true, completion: nil)
            let recent = IPAHelpViewController()
            self.navigation.pushViewController(recent, animated: false)
        case 5:
             //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_SCANNED_TICKET.rawValue, label: "")
            scanTicket()
            return
        case 6:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_ELECTRONIC_BILLING.rawValue, label: "")
            let webCtrl = IPOWebViewController()
            webCtrl.openURLFactura()
            self.present(webCtrl,animated:true,completion:nil)
            let recent = IPAHelpViewController()
            self.navigation.pushViewController(recent, animated: false)
      
            
        case 7:
            //Notifica
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_NOTIFICATIONS.rawValue, label: "")
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "notificationVC")
            self.navigation.pushViewController(controller, animated: true)
        case 8:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_HELP.rawValue, label: "")
            let recent = IPAHelpViewController()
            self.navigation.pushViewController(recent, animated: true)
        case 9:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_TERMS_AND_CONDITIONS.rawValue, label: "")
            let recent = IPATermViewController()
            self.navigation.pushViewController(recent, animated: true)
        case 10:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_SUPPORT.rawValue, label: "")
            let recent = IPASupportViewController()
            self.navigation.pushViewController(recent, animated: true)
        case 11:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action:WMGAIUtils.ACTION_OPEN_EDIT_PROFILE.rawValue, label:"")
            let edit = IPAEditProfileViewController()
            //var indexPath = NSIndexPath(forItem:Int(selected!), inSection:0)
            self.navigation.pushViewController(edit, animated: true)
            
            
        default :
            print("other pressed")
            
        }

        if row == 4 {
            selected = -1
        } else {
            selected  = row
        }
        
        //if row != 3 && row != 5 {
        
        //}
        
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
        
        self.viewControllers = [self.navController, navigation];
    }
    
    
    func loadStoryboardDefinition() -> UIStoryboard? {
        let storyboardName = UIDevice.current.userInterfaceIdiom == .phone ? "Storyboard_iphone" : "Storyboard_ipad"
        let storyboard : UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil);
        return storyboard;
    }
    
    // MARK: - CameraViewControllerDelegate
   func photoCaptured(_ value: String?,upcs:[String]?,done: (() -> Void)) {
        if value != nil && value?.trim() != "" {
          //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SEARCH_BY_TAKING_A_PHOTO.rawValue, label: "")
            var upcArray = upcs
            if upcArray == nil{
                upcArray = []
            }
            let params = ["upcs": upcArray!, "keyWord":value!] as [String : Any]
            NotificationCenter.default.post(name: .camFindSearch, object: params, userInfo: nil)
            done()
      }
    }
    
    
    /**
     Open scan barcode Controller
     */
    func scanTicket() {
        let barCodeController = IPABarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.searchProduct = false
        self.present(barCodeController, animated: true, completion: nil)
    }
    
    var openPromotions  =  false
    func openPromotios(){
        if self.showPromos {
            self.showPromos = false
            NSLog("Inicia llamado de  Servicios:::::")
            self.loadGRServices { (bussines:String) in
            NSLog("termina llamado de Servicios:::")
            let window = UIApplication.shared.keyWindow
                if let customBar = window!.rootViewController as? CustomBarViewController {
                     NotificationCenter.default.addObserver(self, selector: #selector(IPAMasterHelpViewController.validatePromotions), name: NSNotification.Name(rawValue: "CENTER_PROMOS"), object: nil)
                    if self.openPromotions == false {
                        let _ = customBar.handleNotification("LIN",name:"CP",value: bussines == "gr" ? "cl-promociones-mobile" :"l-lp-app-promociones",bussines:bussines)
                        self.openPromotions =  true
                    }else{
                         self.openPromotions =  false
                    }
                     self.showPromos = true
                }
            }
        }else{
            self.showPromos = !self.showPromos
            self.openPromotions =  false
        }
    }
    
    func validatePromotions(){
    self.openPromotions =  false
    }
    /**
     validate number items line contains
     
     - parameter successBlock: finish service an retun bussines
     */
    func loadGRServices(_ successBlock:((String) -> Void)?){
        
        let signalsDictionary : [String:Any] = ["signals" : GRBaseService.getUseSignalServices()]
        let service = GRProductBySearchService(dictionary: signalsDictionary)
        let params = service.buildParamsForSearch(text: "", family: "_", line: "cl-promociones-mobile", sort: "", departament: "_", start: 0, maxResult: 20,brand:"")
        service.callService(params!, successBlock: { (respose:[[String:Any]],resultDic:[String:Any]) in
            print("temina")
            if respose.count > 0 {
                successBlock!("gr")
            }else{
                successBlock!("mg")
            }
            
            }, errorBlock: { (error:NSError) in
                successBlock!("mg")
                print("llama al mg")
        })
    }
    
    
}
