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

@objc protocol BarCodeViewControllerDelegate: class{
    func barcodeCaptured(_ value:String?)
    @objc optional func barcodeCapturedWithType(_ value:String?,isUpcSearch:Bool)
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
    weak var delegate : BarCodeViewControllerDelegate? = nil
    var helpLabel : UILabel? = nil
    var bgImage : UIImageView!
    var close : UIButton!
    var helpText: String?
    var searchProduct = false
    var useDelegate = false
    var isAnyActionFromCode =  false
    var onlyCreateList = false
    
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
        
        self.helpLabel = UILabel(frame: CGRect(x: 40 , y: 160 ,width: self.view.frame.width - 80 ,height: 30 ))
        self.helpLabel!.text =  NSLocalizedString("product.searh.help.barcode",comment:"")
        if self.helpText != nil {
            self.helpLabel!.text =  self.helpText
        }
        self.helpLabel!.textColor = UIColor.white
        self.helpLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.helpLabel!.textAlignment = .center
        self.helpLabel!.numberOfLines = 2
        self.view.addSubview(helpLabel!)
        
        close = UIButton(frame: CGRect(x: (self.view.frame.width) - 48,y: 16,width: 48,height: 48))
        close.setImage(UIImage(named: "closeScan"), for: UIControlState())
        close.addTarget(self, action: #selector(BarCodeViewController.closeAlert), for: UIControlEvents.touchUpInside)
        self.view.addSubview(close)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BarCodeViewController.startRunning), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BarCodeViewController.stopRunning), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
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
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if previewLayer != nil {
            previewLayer!.frame =  self.view.frame
        }
        self.bgImage.frame = self.view.bounds
        self.helpLabel!.frame = CGRect( x: (self.view.bounds.width - 200) / 2  , y: (self.view.bounds.height / 2) - 150  , width: 200 ,height: 30 )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startRunning()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRunning()
    }
    
    func setupCaptureSession() {
        if captureSession != nil {
            return
        }
        
        videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if videoDevice == nil {
            //AlertController.presentViewController("No se encontro camara", icon: nil)
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch(status) {
            case AVAuthorizationStatus.authorized : // authorized
                print("Authorized")
            break
            case AVAuthorizationStatus.denied: // denied
                UIAlertView(title: "Permisos", message: "Walmart necesita permiso para accesar a la cámara", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Settings").show()
            return
            case AVAuthorizationStatus.restricted: // restricted
                print("Restricted")
            return
            case AVAuthorizationStatus.notDetermined:  // not determined
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted:Bool) -> Void in
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
        
        let metadataQueue : DispatchQueue = DispatchQueue(label: "com.1337labz.featurebuild.metadata", attributes: DispatchQueue.Attributes.concurrent)
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
    func applicationWillEnterForeground(_ notification:Notification) {
        self.startRunning()
    }
    
    func applicationDidEnterBackground(_ notification:Notification) {
        self.stopRunning()
    }
    
    // Delegate AVFoundation
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        for obj in metadataObjects {
            if let metaObj = obj as? AVMetadataMachineReadableCodeObject {
                self.dismiss(animated: true, completion:{ (Void) -> Void in
                if self.isAnyActionFromCode {
                    self.searchProduct(metaObj)
                    return
                }
                if self.onlyCreateList {
                    self.createList(metaObj)
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
                            alertView?.setMessage("Este código de barras pertenece a un Ticket, ¿Deseas crear una lista con estos artículos?.")
                            //Tag Manager
                            BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError: "Este código de barras pertenece a un Ticket, ¿Deseas crear una lista con estos artículos?.")
                            
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
                            //Tag Manager
                            BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError:"Este código de barras pertenece a un Ticket, inicia sesión para crear una lista con estos artículos.")
                            alertView?.addActionButtonsWithCustomText(NSLocalizedString("invoice.button.cancel",comment:""), leftAction: {(void) in
                                alertView?.close()
                                }, rightText: NSLocalizedString("invoice.message.continue",comment:""), rightAction: { (void) in
                                    alertView?.close()
                                    //Show LogIn with regist
                                    let cont = LoginController.showLogin()
                                    cont!.closeAlertOnSuccess = true
                                    cont!.okCancelCallBack = {() in
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: ProfileNotification.updateProfile.rawValue), object: nil)
                                        cont!.closeAlert(true, messageSucesss:false)
                                    }
                                    cont!.successCallBack = {() in
                                        cont!.closeAlert(true, messageSucesss:false)
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: ProfileNotification.updateProfile.rawValue), object: nil)
                                        self.createList(metaObj)
                                    }
                            },isNewFrame: false)
                        }
                    }else{
                        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"searchScan"),imageDone:UIImage(named:"searchScan"),imageError:UIImage(named:"searchScan"))
                        alertView!.setMessage("El número de ticket es incorrecto o no pertenece a Walmart")
                        //Tag Manager
                        BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError:"El número de ticket es incorrecto o no pertenece a Walmart")
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
                        //Tag Manager
                        BaseController.sendTagManagerErrors("ErrorEventBusiness", detailError:"El número de ticket es incorrecto o no pertenece a Walmart")
                        alertView!.showErrorIcon("Ok")
                    }
                    
                }
              })
            }
        }
    }
    
    func closeAlert(){
        self.dismiss(animated: true, completion: { () -> Void in
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SCAN_BAR_CODE.rawValue, action: WMGAIUtils.ACTION_CANCEL_SEARCH.rawValue, label: "")
            if self.useDelegate {
              self.delegate!.barcodeCaptured(nil)
            }
        })
    }
    
    //MARK: - Orientation
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
    }
    
    //MARK: - Search and Creeate Functions
    func searchProduct(_ barcode: AVMetadataMachineReadableCodeObject){
        let code = barcode.stringValue!.trimmingCharacters(in: CharacterSet.whitespaces)
        let character = code.substring(to: code.characters.index(code.startIndex, offsetBy: code.characters.count-1))
        
        if useDelegate{
            if self.isAnyActionFromCode {
                let isUpcSearch =  barcode.type == "org.gs1.EAN-13"
                self.delegate?.barcodeCapturedWithType!(isUpcSearch ? character : barcode.stringValue, isUpcSearch: isUpcSearch)
            }else{
            self.delegate?.barcodeCaptured(character)
            }
            
        }else{
            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ScanBarCode.rawValue), object: character, userInfo: nil)
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SCAN_BAR_CODE.rawValue, action: WMGAIUtils.ACTION_BARCODE_SCANNED_UPC.rawValue, label: character)
        }
    }
    

    
    func createList(_ barcode: AVMetadataMachineReadableCodeObject){
        let barcodeValue = barcode.stringValue!
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SCAN_BAR_CODE.rawValue, action: WMGAIUtils.ACTION_BARCODE_SCANNED_UPC.rawValue, label: barcodeValue)
        if useDelegate{
            self.delegate?.barcodeCaptured(barcodeValue)
        }
        else{
            self.createListWithServices(barcodeValue)
        }
    }
    
    func createListWithServices(_ barcodeValue: String){
        print("Code \(barcodeValue)")
        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.message.retrieveProductsFromTicket", comment:""))
        let service = GRProductByTicket()
        service.callService(service.buildParams(barcodeValue),
            successBlock: { (result: [String:Any]) -> Void in
                if let items = result["items"] as? [Any] {
                    
                    if items.count == 0 {
                        alertView!.setMessage(NSLocalizedString("list.message.noProductsForTicket", comment:""))
                        alertView!.showErrorIcon("Ok")
                        return
                    }
                    
                    let saveService = GRSaveUserListService()
                    
                    alertView!.setMessage(NSLocalizedString("list.message.creatingListFromTicket", comment:""))
                    
                    var products:[Any] = []
                    for idx in 0 ..< items.count {
                        var item = items[idx] as! [String:Any]
                        let upc = item["upc"] as! String
                        let quantity = item["quantity"] as! NSNumber
                        var baseUomcd = "EA"
                        if let baseUcd = item["baseUomcd"] as? String {
                            baseUomcd = baseUcd
                        }
                        let param = saveService.buildBaseProductObject(upc: upc, quantity: quantity.intValue,baseUomcd:baseUomcd)// send baseUomcd
                        products.append(param)
                    }
                    
                    let fmt = DateFormatter()
                    fmt.dateFormat = "MMM d"
                    var name = fmt.string(from: Date())
                    
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context: NSManagedObjectContext = appDelegate.managedObjectContext!
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
                    fetchRequest.entity = NSEntityDescription.entity(forEntityName: "List", in: context)
                    fetchRequest.predicate = NSPredicate(format:"idList != nil")
                    
                    var number = 0;
                    do{
                        let resultList: [List]? = try context.fetch(fetchRequest) as? [List]
                        if resultList != nil && resultList!.count > 0 {
                            for listName: List in resultList!{
                                if listName.name.uppercased().hasPrefix(name.uppercased()) {
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
                        successBlock: { (result:[String:Any]) -> Void in
                            //TODO
                            alertView!.setMessage(NSLocalizedString("list.message.listDone", comment: ""))
                            alertView!.showDoneIcon()
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CustomBarNotification.ShowGRLists.rawValue), object: nil)
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
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(appSettings)
            }
        } else {
            self.closeAlert()
        }
    }
}
