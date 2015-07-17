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

protocol BarCodeViewControllerDelegate{
    func barcodeCaptured(value:String?)
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
    var applyPadding = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCaptureSession()
        
        if previewLayer != nil {
            previewLayer!.frame =  self.view.frame
            self.view.layer.addSublayer(previewLayer)
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
        
        var status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch(status) {
            case AVAuthorizationStatus.Authorized : // authorized
                println("Authorized")
            break
            case AVAuthorizationStatus.Denied: // denied
                UIAlertView(title: "Permisos", message: "Walmart necesita permiso para accesar a la cámara", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Settings").show()
            return
            case AVAuthorizationStatus.Restricted: // restricted
                println("Restricted")
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
        videoInput = AVCaptureDeviceInput(device: videoDevice, error: nil)
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
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    if self.applyPadding {
                        var code = metaObj.stringValue!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        var character = code.substringToIndex(advance(code.startIndex, countElements(code)-1 ))
                        self.delegate!.barcodeCaptured(character)
                    }
                    else {
                        self.delegate!.barcodeCaptured(metaObj.stringValue!)
                    }
                })
            }
        }
    }
    
    func closeAlert(){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
             self.delegate!.barcodeCaptured(nil)
        })
    }
    
    //MARK: - Orientation
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
    }
    
    //MARK: Alert delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if UIApplicationOpenSettingsURLString != nil {
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }
        } else {
            self.closeAlert()
        }
        
    }
    
    
}
