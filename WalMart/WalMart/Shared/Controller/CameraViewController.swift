//
//  CameraViewController.swift
//  WalMart
//
//  Created by Ingenieria de soluciones on 7/14/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import AVFoundation
import QuartzCore

protocol CameraViewControllerDelegate{
    func photoCaptured(value: String?)
}

enum CameraType {
    case Front
    case Back
}

class CameraViewController : BaseController, UIAlertViewDelegate {
    var capturedImage: UIImageView!
    var captureSession : AVCaptureSession? = nil
    var videoDevice : AVCaptureDevice? = nil
    var videoInput : AVCaptureDeviceInput? = nil
    var previewLayer : AVCaptureVideoPreviewLayer? = nil
    var running : Bool = false
    var delegate : CameraViewControllerDelegate? = nil
    var topBarView: UIView?
    var IPAPreviewBarView: UIView?
    
    var stillImageOutput: AVCaptureStillImageOutput?
    var cancelButton: UIButton?
    var camButton: UIButton?
    var camFlashButton: UIButton?
    var messageLabel: UILabel?
    var camChangeButton: UIButton?
    
    var repeatButton: UIButton?
    var okButton: UIButton?
    var didChangeCam: Bool? = false
    
    var camera = CameraType.Back
    var alertView : IPOWMAlertViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCaptureSession()
        
        self.capturedImage = UIImageView()
        
        self.topBarView = UIView()
        self.topBarView?.backgroundColor = WMColor.productAddToCartBg
        self.topBarView!.alpha = 0.8
        self.view.addSubview(self.topBarView!)
        
        self.camFlashButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.camFlashButton!.setImage(UIImage(named:"camfind_flash"), forState: .Normal)
        self.camFlashButton!.addTarget(self, action: "toggleFlash", forControlEvents: UIControlEvents.TouchUpInside)
        self.topBarView!.addSubview(self.camFlashButton!)
        
        self.messageLabel = UILabel()
        self.messageLabel!.textAlignment = .Center
        self.messageLabel!.numberOfLines = 1
        self.messageLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.messageLabel!.textColor = UIColor.whiteColor()
        self.messageLabel!.text = NSLocalizedString("camfind.message.photo",comment:"")
        
        self.camChangeButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.camChangeButton!.tag = 1;
        self.camChangeButton!.setImage(UIImage(named:"camfind_switchCam"), forState: .Normal)
        self.camChangeButton!.addTarget(self, action: "changeCamera", forControlEvents: UIControlEvents.TouchUpInside)
        self.topBarView!.addSubview(self.camChangeButton!)
        
        self.cancelButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.cancelButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.cancelButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.cancelButton!.setTitleColor(WMColor.productAddToCartBg, forState: UIControlState.Highlighted)
        self.cancelButton!.setTitleColor(WMColor.productAddToCartBg, forState: UIControlState.Selected)
        self.cancelButton!.setTitle(NSLocalizedString("product.searh.cancel",  comment: ""), forState: UIControlState.Normal)
        self.cancelButton!.addTarget(self, action: "closeCamera", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.camButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.camButton!.setImage(UIImage(named:"camfind_takePhoto"), forState: .Normal)
        self.camButton!.setImage(UIImage(named:"camfind_takePhoto_active"), forState: .Highlighted)
        self.camButton!.setImage(UIImage(named:"camfind_takePhoto_active"), forState: .Selected)
        self.camButton!.addTarget(self, action: "takePhoto", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.repeatButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.repeatButton!.setTitle("Repetir Foto", forState: UIControlState.Normal)
        self.repeatButton!.setTitleColor(WMColor.UIColorFromRGB(0x807E7E), forState: UIControlState.Highlighted)
        self.repeatButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.repeatButton!.addTarget(self, action: "returnCamera", forControlEvents: UIControlEvents.TouchUpInside)
        self.repeatButton!.backgroundColor = WMColor.productAddToCartBg
        self.repeatButton!.layer.cornerRadius = 18.0
        self.repeatButton!.alpha = 0
        self.view!.addSubview(self.repeatButton!)
        
        self.okButton = UIButton.buttonWithType(.Custom) as? UIButton
        self.okButton!.setTitle("Ok", forState: UIControlState.Normal)
        self.okButton!.setTitleColor(WMColor.UIColorFromRGB(0x807E7E), forState: UIControlState.Highlighted)
        self.okButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.okButton!.addTarget(self, action: "sendPhoto", forControlEvents: UIControlEvents.TouchUpInside)
        self.okButton!.backgroundColor = WMColor.UIColorFromRGB(0x8EBB37)
        self.okButton!.layer.cornerRadius = 18.0
        self.okButton!.alpha = 0
        self.view!.addSubview(self.okButton!)
        
        if IS_IPAD {
            self.IPAPreviewBarView = UIView()
            self.IPAPreviewBarView?.backgroundColor = WMColor.productAddToCartBg
            self.IPAPreviewBarView!.alpha = 0;
            self.view.addSubview(self.IPAPreviewBarView!)
            
            self.topBarView!.addSubview(self.cancelButton!)
            self.IPAPreviewBarView!.addSubview(self.messageLabel!)
            
            self.cancelButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            self.camFlashButton!.hidden = true;
            self.IPAPreviewBarView!.addSubview(self.messageLabel!)
            self.topBarView!.addSubview(self.camButton!)

        }
        else{
            self.topBarView!.addSubview(self.messageLabel!)
            self.view!.addSubview(self.cancelButton!)
            self.view!.addSubview(self.camButton!)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startRunning", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopRunning", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.topBarView!.frame = CGRectMake(0.0, 0.0, self.view.bounds.width, 64)
            self.camFlashButton!.frame = CGRectMake(8, 18, 28, 28)
            self.messageLabel!.frame = CGRectMake((self.view.bounds.width / 2) - 120, 18, 240, 28)
            self.camChangeButton!.frame = CGRectMake(284, 18, 28, 28)
            self.camButton!.frame = CGRectMake((self.view.bounds.width / 2) - 32, self.view.bounds.height - 80, 64, 64)
            self.cancelButton!.frame = CGRectMake(40.0, self.camButton!.frame.origin.y + 16, 55.0, 32.0)
            
            self.repeatButton!.frame = CGRectMake(44, self.view.bounds.height - 72, 100, 36)
            self.okButton!.frame = CGRectMake((self.view!.frame.width / 2) + 16, self.view.bounds.height - 72, 100, 36)
        }
        else{
            self.topBarView!.frame = CGRectMake(self.view.bounds.width - 102, 0.0, 102, self.view.bounds.height)
            self.camChangeButton!.frame = CGRectMake((self.topBarView!.bounds.width / 2) - 14, 32, 28, 28)
            self.camFlashButton!.frame = CGRectMake((self.topBarView!.bounds.width / 2) - 14, self.camChangeButton!.frame.origin.y + self.camChangeButton!.frame.size.height + 24, 28, 28)
            self.camButton!.frame = CGRectMake((self.topBarView!.bounds.width / 2) - 32, (self.topBarView!.bounds.height / 2) - 32, 64, 64)
            self.cancelButton!.frame = CGRectMake((self.topBarView!.bounds.width / 2) - 32, self.view.bounds.height - 64, 64.0, 32.0)

            self.IPAPreviewBarView!.frame = CGRectMake(0.0, 0.0, self.view.bounds.width, 64)
            self.messageLabel!.frame = CGRectMake((self.IPAPreviewBarView!.bounds.width / 2) - 150, 18, 300, 28)
            self.repeatButton!.frame = CGRectMake((self.view!.bounds.width / 2) - 116, self.view.bounds.height - 68, 100, 36)
            self.okButton!.frame = CGRectMake((self.view!.bounds.width / 2) + 16, self.view.bounds.height - 68, 100, 36)
        }
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
        if didChangeCam == true {
            if camera == CameraType.Back {
                let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
                for device in videoDevices{
                    let device = device as AVCaptureDevice
                    if device.position == AVCaptureDevicePosition.Front {
                        videoDevice = device
                        camera = CameraType.Front
                        break
                    }
                }
            }
            else {
                videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                camera = CameraType.Back
            }
        }
        else{
            if camera == CameraType.Back {
                videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                camera = CameraType.Back
            }
            else{
                let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
                for device in videoDevices{
                    let device = device as AVCaptureDevice
                    if device.position == AVCaptureDevicePosition.Front {
                        videoDevice = device
                        camera = CameraType.Front
                        break
                    }
                }
            }
        }
    
        // videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
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
        
        if IS_IPAD{
            if self.interfaceOrientation == UIInterfaceOrientation.LandscapeLeft {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft;
            }
            else if self.interfaceOrientation == UIInterfaceOrientation.LandscapeRight {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight;
            }
            
            if IS_RETINA {
                previewLayer!.frame = CGRectMake(0,0,1024,768)
            }
        }
        else{
            previewLayer!.frame = self.view.frame
        }
        
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession!.canAddOutput(stillImageOutput) {
            captureSession!.addOutput(stillImageOutput)
            
            self.view.layer.insertSublayer(previewLayer, below: topBarView?.layer)
            self.startRunning()
        }
    }
    
    func changeCamera(){
        self.didChangeCam = true
        
        self.reloadCamera()
        if camera == CameraType.Front{
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.camFlashButton!.alpha = 0;
            })
        }
        else{
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.camFlashButton!.alpha = 1;
            })
        }
    }
    
    func reloadCamera() {
        self.stopRunning()
//        previewLayer?.removeFromSuperlayer()
        captureSession = nil
        videoDevice = nil
        videoInput = nil
        previewLayer = nil
        stillImageOutput = nil
        
        self.setupCaptureSession()
    }
    
    func toggleFlash() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            device.lockForConfiguration(nil)
            if (device.torchMode == AVCaptureTorchMode.On) {
                device.torchMode = AVCaptureTorchMode.Off
            } else {
                device.setTorchModeOnWithLevel(1.0, error: nil)
            }
            device.unlockForConfiguration()
        }
    }
    
    func takePhoto() {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)
                    
                    var image = UIImage(CGImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.capturedImage.image = image
                    
                    self.stopRunning()
                    self.showPreview()
                }
            })
        }
    }
    
    func showPreview(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            if IS_IPAD {
                self.topBarView!.alpha = 0
            }
            self.camChangeButton!.alpha = 0
            self.camFlashButton!.alpha = 0
            self.cancelButton!.alpha = 0
            self.camButton!.alpha = 0
            }, completion: {(completed : Bool) in
                if completed {
                    self.messageLabel!.text = NSLocalizedString("camfind.message.preview",comment:"")
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        if IS_IPAD {
                            self.IPAPreviewBarView!.alpha = 0.8
                            self.messageLabel!.alpha = 1
                        }
                        self.repeatButton!.alpha = 1
                        self.okButton!.alpha = 1
                    })
                }
        })
    }
    
    func returnCamera(){
        didChangeCam = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.reloadCamera()
            if IS_IPAD {
                self.IPAPreviewBarView!.alpha = 0
            }
            self.repeatButton!.alpha = 0
            self.okButton!.alpha = 0
            }, completion: {(completed : Bool) in
                if completed {
                    self.messageLabel!.text = NSLocalizedString("camfind.message.photo",comment:"")
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        if IS_IPAD {
                            self.topBarView!.alpha = 0.8;
                        }
                        
                        if self.camera == CameraType.Front{
                            self.camFlashButton!.alpha = 0
                        }
                        else{
                            self.camFlashButton!.alpha = 1
                        }
                        
                        self.camChangeButton!.alpha = 1
                        self.cancelButton!.alpha = 1
                        self.camButton!.alpha = 1
                    })
                }
        })
    }
    
    func closeCamera(){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.delegate!.photoCaptured(nil)
        })
    }
    
    func sendPhoto(){
        if alertView == nil {
            var imgTempRound = self.imageResize(capturedImage.image!) as UIImage
            self.alertView = IPAWMAlertViewController.showAlert(self, imageWaiting:self.maskRoundedImage(imgTempRound), imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage("Buscando imagen")
        }
        
        let service = CamFindService()
        service.callService(service.buildParams(self.capturedImage.image!),
            successBlock: { (response: NSDictionary) -> Void in
                let resp = response.objectForKey("status") as String
                switch resp {
                    case ("completed"):
                        let name = response.objectForKey("name") as String
                        self.alertView!.setMessage("Imagen encontrada\n: \(name)")
                        self.alertView!.showDoneIcon()
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.delegate!.photoCaptured(name)
                        })
                        break;
                    case ("not completed"):
                        self.sendPhoto()
                        break;
                    case ("not found"):
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.delegate!.photoCaptured("")
                        })
                        break;
                    case ("skipped"):
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.delegate!.photoCaptured("")
                        })
                        break;
                    case ("timeout"):
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.delegate!.photoCaptured("")
                        })
                        break;
                    case ("error"):
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.delegate!.photoCaptured("")
                        })
                        break;
                    default:
                        break;
                }
            }, errorBlock: { (error:NSError) -> Void in
                
        })
    }

    func imageResize(imageObj: UIImage) -> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0
        
        var sizeChange : CGSize
        if IS_IPHONE_4_OR_LESS {
            sizeChange = CGSizeMake(80, 80)
        }
        else {
            sizeChange = CGSizeMake(160, 160)
        }
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return scaledImage
    }
    
    func maskRoundedImage(image: UIImage) -> UIImage {
        var imageView: UIImageView = UIImageView(image: image)
        var layer: CALayer = CALayer()
        var rad: Float = 0.0
        layer = imageView.layer
        
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(imageView.bounds.width / 2)
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext())
        var roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
    
    func startRunning() {
        if running || captureSession == nil {
            return
        }
        captureSession!.startRunning()
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
    
    //MARK: - Orientation
    override func shouldAutorotate() -> Bool {
        if IS_IPAD {
            return true
        }
        else{
            return false
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if IS_IPAD {
            return Int(UIInterfaceOrientationMask.LandscapeLeft.rawValue) | Int(UIInterfaceOrientationMask.LandscapeRight.rawValue)
        }
        else {
            return Int(UIInterfaceOrientationMask.Portrait.rawValue)
        }
        
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        if IS_IPAD {
            return self.interfaceOrientation
        }
        else{
            return UIInterfaceOrientation.Portrait
        }
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if IS_IPAD {
            if self.interfaceOrientation == UIInterfaceOrientation.LandscapeLeft {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft;
            }
            else if self.interfaceOrientation == UIInterfaceOrientation.LandscapeRight {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight;
            }
        }
    }
    
    //MARK: - StatusBar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    //MARK: Alert delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if UIApplicationOpenSettingsURLString != nil {
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }
        } else {
            self.closeCamera()
        }
        
    }
}
