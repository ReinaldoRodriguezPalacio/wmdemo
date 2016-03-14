//
//  BarCodeViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 10/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import AVFoundation
import QuartzCore
import CoreData

@objc protocol BarCodeViewControllerDelegate{
    func barcodeCaptured(value:String?)
    optional func barcodeCapturedWithType(value:String?,isUpcSearch:Bool)
}

class BarCodeViewController : BaseController, AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate {
    
    var captureSession : AVCaptureSession? = nil
    var videoDevice : AVCaptureDevice? = nil
    var videoInput : AVCaptureDeviceInput? = nil
    var previewLayer : AVCaptureVideoPreviewLayer? = nil
    var running : Bool = false
    var metadataOutput : AVCaptureMetadataOutput? = nil
    var previewView : UIView = UIView()
    var allowedBarcodeTypes : [String] = []
    var delegate : BarCodeViewControllerDelegate? = nil
    var helpLabel : UILabel? = nil
    var bgImage : UIImageView!
    var close : UIButton!
    var helpText: String?
    var searchProduct = false
    var useDelegate = false
    var isAnyActionFromCode =  false
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SCANBARCODE.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCaptureSession()
        
        if previewLayer != nil {
            previewLayer!.frame =  self.view.frame
            self.view.layer.addSublayer(previewLayer!)
        }
        
        bgImage = UIImageView(frame: self.view.frame)
        bgImage.image = UIImage(named: "signIn_scanner_bg")
        self.view.addSubview(bgImage)
        
        self.helpLabel = UILabel(frame: CGRectMake(40 , 160 ,self.view.frame.width - 80 ,30 ))
        self.helpLabel!.text =  NSLocalizedString("product.searh.help.barcode",comment:"")
        if self.helpText != nil {
            self.helpLabel!.text =  self.helpText
        }
        self.helpLabel!.textColor = UIColor.whiteColor()
        self.helpLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.helpLabel!.textAlignment = .Center
        self.helpLabel!.numberOfLines = 2
        self.view.addSubview(helpLabel!)
        
        close = UIButton(frame: CGRectMake((self.view.frame.width) - 48,16,48,48))
        close.setImage(UIImage(named: "closeScan"), forState: UIControlState.Normal)
        close.addTarget(self, action: "closeAlert", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(close)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startRunning", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopRunning", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        allowedBarcodeTypes.append("org.iso.QRCode")
        allowedBarcodeTypes.append("org.iso.PDF417")
        allowedBarcodeTypes.append("org.gs1.UPC-E")
        allowedBarcodeTypes.append("org.iso.Aztec")
        allowedBarcodeTypes.append("org.iso.Code39")
        allowedBarcodeTypes.append("org.iso.Code39Mod43")
        allowedBarcodeTypes.append("org.gs1.EAN-13")
        allowedBarcodeTypes.append("org.gs1.EAN-8")
        allowedBarcodeTypes.append("org.iso.Code128")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if previewLayer != nil {
            previewLayer!.frame =  self.view.frame
        }
        self.bgImage.frame = self.view.bounds
        self.helpLabel!.frame = CGRectMake( (self.view.bounds.width - 200) / 2  , (self.view.bounds.height / 2) - 150  , 200 ,30 )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startRunning()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopRunning()
    }
    
    func setupCaptureSession() {
        if captureSession != nil {
            return
        }
        
        videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if videoDevice == nil {
            //AlertController.presentViewController("No se encontro camara", icon: nil)
            return
        }
        
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch(status) {
            case AVAuthorizationStatus.Authorized : // authorized
                print("Authorized")
            break
            case AVAuthorizationStatus.Denied: // denied
                UIAlertView(title: "Permisos", message: "Walmart necesita permiso para accesar a la cámara", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Settings").show()
            return
            case AVAuthorizationStatus.Restricted: // restricted
                print("Restricted")
            return
            case AVAuthorizationStatus.NotDetermined:  // not determined
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted:Bool) -> Void in
                    if granted {
                        
                    }else {
                        return
                    }
                })
            break
        }
        
        
        captureSession = AVCaptureSession()
        videoInput = try? AVCaptureDeviceInput(device: videoDevice)
        if captureSession!.canAddInput(videoInput) == true {
            captureSession!.addInput(videoInput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        metadataOutput = AVCaptureMetadataOutput()
        
        let metadataQueue : dispatch_queue_t = dispatch_queue_create("com.1337labz.featurebuild.metadata", DISPATCH_QUEUE_CONCURRENT)
       metadataOutput!.setMetadataObjectsDelegate(self, queue: metadataQueue)
        
        if captureSession!.canAddOutput(metadataOutput) == true {
            captureSession!.addOutput(metadataOutput)
        }
    }
    
    func startRunning() {
        if running || captureSession == nil {
            return
        }
        captureSession!.startRunning()
        metadataOutput!.metadataObjectTypes = metadataOutput!.availableMetadataObjectTypes
        running = true
    }
    
    func stopRunning() {
        if !running {
            return
        }
        
        captureSession!.stopRunning()
        running = false
    }
    
    //Handle notifications
    func applicationWillEnterForeground(notification:NSNotification) {
        self.startRunning()
    }
    
    func applicationDidEnterBackground(notification:NSNotification) {
        self.stopRunning()
    }
    
    // Delegate AVFoundation
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        for obj in metadataObjects {
            if let metaObj = obj as? AVMetadataMachineReadableCodeObject {
                self.dismissViewControllerAnimated(true, completion:{ (Void) -> Void in
                    if self.isAnyActionFromCode {
                        self.searchProduct(metaObj)
                        return
                    }
                if self.searchProduct {
                    if metaObj.type! == "org.gs1.EAN-13"
                    {
                        self.searchProduct(metaObj)
                    }else if metaObj.type! == "org.iso.Code39"{
                        if UserCurrentSession.hasLoggedUser(){
                            let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"searchScan"),imageDone:UIImage(named:"searchScan"),imageError:UIImage(named:"searchScan"))
                            alertView?.showicon(UIImage(named: "searchScan"))
                            alertView?.setMessage("Este código de barras pertenece a un Ticket, ¿Deseas crear una lista con estos artículos.")
                            alertView?.addActionButtonsWithCustomText(NSLocalizedString("invoice.button.cancel",comment:""), leftAction: {(void) in
                                alertView?.close()
                                }, rightText: NSLocalizedString("invoice.message.continue",comment:""), rightAction: { (void) in
                                    alertView?.close()
                                    self.createList(metaObj)
                            },isNewFrame: false)
                        }else{
                            let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"searchScan"),imageDone:UIImage(named:"searchScan"),imageError:UIImage(named:"searchScan"))
                            alertView?.showicon(UIImage(named: "searchScan"))
                            alertView?.setMessage("Este código de barras pertenece a un Ticket, inicia sesión para crear una lista con estos artículos.")
                            alertView?.addActionButtonsWithCustomText(NSLocalizedString("invoice.button.cancel",comment:""), leftAction: {(void) in
                                alertView?.close()
                                }, rightText: NSLocalizedString("invoice.message.continue",comment:""), rightAction: { (void) in
                                    alertView?.close()
                                    //Show LogIn with regist
                                    let cont = LoginController.showLogin()
                                    cont!.closeAlertOnSuccess = true
                                    cont!.okCancelCallBack = {() in
                                        NSNotificationCenter.defaultCenter().postNotificationName(ProfileNotification.updateProfile.rawValue, object: nil)
                                        cont!.closeAlert(true, messageSucesss:false)
                                    }
                                    cont!.successCallBack = {() in
                                        cont!.closeAlert(true, messageSucesss:false)
                                        NSNotificationCenter.defaultCenter().postNotificationName(ProfileNotification.updateProfile.rawValue, object: nil)
                                        self.createList(metaObj)
                                    }
                            },isNewFrame: false)
                        }
                    }else{
                        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"searchScan"),imageDone:UIImage(named:"searchScan"),imageError:UIImage(named:"searchScan"))
                        alertView!.setMessage("El número de ticket es incorrecto o no pertenece a Walmart")
                        alertView!.showErrorIcon("Ok")
                    }
                }
                else {
                    if metaObj.type! == "org.iso.Code39"
                    {
                       self.createList(metaObj)
                    }else if metaObj.type! == "org.gs1.EAN-13" {
                        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"searchScan"),imageDone:UIImage(named:"searchScan"),imageError:UIImage(named:"searchScan"))
                        alertView?.showicon(UIImage(named: "searchScan"))
                        alertView?.setMessage("Este código de barras no pertenece a una lista, ¿Deseas ver detalle de este producto?")
                        alertView?.addActionButtonsWithCustomText(NSLocalizedString("invoice.button.cancel",comment:""), leftAction: {(void) in
                            alertView?.close()
                            }, rightText: NSLocalizedString("invoice.message.continue",comment:""), rightAction: { (void) in
                                alertView?.close()
                                self.searchProduct(metaObj)
                        },isNewFrame: false)
                    } else {
                          let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"searchScan"),imageDone:UIImage(named:"searchScan"),imageError:UIImage(named:"searchScan"))
                        alertView!.setMessage("El número de ticket es incorrecto o no pertenece a Walmart")
                        alertView!.showErrorIcon("Ok")
                    }
                    
                }
              })
            }
        }
    }
    
    func closeAlert(){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SCAN_BAR_CODE.rawValue, action: WMGAIUtils.ACTION_CANCEL_SEARCH.rawValue, label: "")
            if self.useDelegate {
              self.delegate!.barcodeCaptured(nil)
            }
        })
    }
    
    //MARK: - Orientation
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
    }
    
    //MARK: - Search and Creeate Functions
    func searchProduct(barcode: AVMetadataMachineReadableCodeObject){
        let code = barcode.stringValue!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let character = code.substringToIndex(code.startIndex.advancedBy(code.characters.count-1 ))
        
        if useDelegate{
            if self.isAnyActionFromCode {
                let isUpcSearch =  barcode.type == "org.gs1.EAN-13"
                self.delegate?.barcodeCapturedWithType!(isUpcSearch ? character : barcode.stringValue, isUpcSearch: isUpcSearch)
            }else{
            self.delegate?.barcodeCaptured(character)
            }
            
        }else{
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ScanBarCode.rawValue, object: character, userInfo: nil)
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SCAN_BAR_CODE.rawValue, action: WMGAIUtils.ACTION_BARCODE_SCANNED_UPC.rawValue, label: character)
        }
    }
    

    
    func createList(barcode: AVMetadataMachineReadableCodeObject){
        let barcodeValue = barcode.stringValue!
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SCAN_BAR_CODE.rawValue, action: WMGAIUtils.ACTION_BARCODE_SCANNED_UPC.rawValue, label: barcodeValue)
        if useDelegate{
            self.delegate?.barcodeCaptured(barcodeValue)
        }
        else{
            self.createListWithServices(barcodeValue)
        }
    }
    
    func createListWithServices(barcodeValue: String){
        print("Code \(barcodeValue)")
        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.message.retrieveProductsFromTicket", comment:""))
        let service = GRProductByTicket()
        service.callService(service.buildParams(barcodeValue),
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
                    fmt.dateFormat = "MMM d"
                    var name = fmt.stringFromDate(NSDate())
                    
                    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                    let fetchRequest = NSFetchRequest()
                    fetchRequest.entity = NSEntityDescription.entityForName("List", inManagedObjectContext: context)
                    fetchRequest.predicate = NSPredicate(format:"idList != nil")
                    
                    var number = 0;
                    do{
                        let resultList: [List]? = try context.executeFetchRequest(fetchRequest) as? [List]
                        if resultList != nil && resultList!.count > 0 {
                            for listName: List in resultList!{
                                if listName.name.uppercaseString.hasPrefix(name.uppercaseString) {
                                    number = number+1
                                }
                            }
                        }
                    }
                    catch{
                        print("retrieveListNotSync error")
                    }
                    
                    if number > 0 {
                        name = "\(name) \(number)"
                    }
                    
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
            },  errorBlock: { (error:NSError) -> Void in
                alertView!.setMessage(error.localizedDescription)
                alertView!.showErrorIcon("Ok")
        })
    }

    //MARK: Alert delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if #available(iOS 8.0, *) {
                if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(appSettings)
                }
            }
        } else {
            self.closeAlert()
        }
    }
}
