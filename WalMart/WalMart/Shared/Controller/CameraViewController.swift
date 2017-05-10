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

protocol CameraViewControllerDelegate: class{
    func photoCaptured(_ value: String?,upcs:[String]?,done: (() -> Void))
}

enum CameraType {
    case front
    case back
}

class CameraViewController : BaseController, UIAlertViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, IPAWMAlertViewControllerDelegate {
    var imagePickerController: UIImagePickerController? = nil
    var capturedImage: UIImageView!
    var imagePickerCaptured: UIImageView!
    var captureSession : AVCaptureSession? = nil
    var videoDevice : AVCaptureDevice? = nil
    var videoInput : AVCaptureDeviceInput? = nil
    var previewLayer : AVCaptureVideoPreviewLayer? = nil
    var running : Bool = false
    weak var delegate : CameraViewControllerDelegate? = nil
    var popover: UIPopoverController? = nil
    var topBarView: UIView?
    var topBackgroundView: UIView?
    var bottomBarView:UIView?
    var bottomBackgroundView: UIView?
    var IPAPreviewBarView: UIView?
    
    var stillImageOutput: AVCaptureStillImageOutput?
    var cancelButton: UIButton?
    var camButton: UIButton?
    var camFlashButton: UIButton?
    var messageLabel: UILabel?
    var camChangeButton: UIButton?
    var loadImageButton: UIButton?
    
    var repeatButton: UIButton?
    var okButton: UIButton?
    var didChangeCam: Bool? = false
    
    var camera = CameraType.back
    var alertView : IPOWMAlertViewController? = nil
    var continueSearch:Bool = false
    var allowsLibrary:Bool = false
    var searchId: String! = ""
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_TAKEPHOTO.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCaptureSession()
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController?.delegate = self
        self.capturedImage = UIImageView()
        self.imagePickerCaptured = UIImageView()
        self.imagePickerCaptured.isHidden = true
        self.view.addSubview(imagePickerCaptured)
        
        self.topBarView = UIView()
        self.topBackgroundView = UIView()
        self.topBackgroundView?.backgroundColor = WMColor.light_blue
        self.topBackgroundView!.alpha = 0.7
        self.topBarView!.addSubview(topBackgroundView!)
        self.view.addSubview(self.topBarView!)
        
        self.camFlashButton = UIButton(type: .custom)
        self.camFlashButton!.setImage(UIImage(named:"camfind_flash"), for: UIControlState())
        self.camFlashButton!.addTarget(self, action: #selector(CameraViewController.toggleFlash), for: UIControlEvents.touchUpInside)
        self.topBarView!.addSubview(self.camFlashButton!)
        
        self.messageLabel = UILabel()
        self.messageLabel!.textAlignment = .center
        self.messageLabel!.numberOfLines = 1
        self.messageLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.messageLabel!.textColor = UIColor.white
        self.messageLabel!.text = NSLocalizedString("camfind.message.photo",comment:"")
        
        self.camChangeButton = UIButton(type: .custom)
        self.camChangeButton!.tag = 1;
        self.camChangeButton!.setImage(UIImage(named:"camfind_switchCam"), for: UIControlState())
        self.camChangeButton!.addTarget(self, action: #selector(CameraViewController.changeCamera), for: UIControlEvents.touchUpInside)
        self.topBarView!.addSubview(self.camChangeButton!)
        
        self.bottomBarView = UIView()
        self.bottomBackgroundView = UIView()
        self.bottomBackgroundView?.backgroundColor = UIColor.black
        self.bottomBackgroundView!.alpha = 0.2
        self.bottomBarView!.addSubview(bottomBackgroundView!)
        self.view.addSubview(self.bottomBarView!)
        
        
        self.cancelButton = UIButton(type: .custom)
        self.cancelButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.cancelButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.cancelButton!.setTitleColor(WMColor.light_blue, for: UIControlState.highlighted)
        self.cancelButton!.setTitleColor(WMColor.light_blue, for: UIControlState.selected)
        self.cancelButton!.setTitle(NSLocalizedString("product.searh.cancel",  comment: ""), for: UIControlState())
        self.cancelButton!.addTarget(self, action: #selector(CameraViewController.closeCamera), for: UIControlEvents.touchUpInside)
        
        self.camButton = UIButton(type: .custom)
        self.camButton!.setImage(UIImage(named:"camfind_takePhoto"), for: UIControlState())
        self.camButton!.setImage(UIImage(named:"camfind_takePhoto_active"), for: .highlighted)
        self.camButton!.setImage(UIImage(named:"camfind_takePhoto_active"), for: .selected)
        self.camButton!.addTarget(self, action: #selector(CameraViewController.takePhoto), for: UIControlEvents.touchUpInside)
        
        self.getLastImageFromLibrary()
        self.loadImageButton = UIButton(type: .custom)
        self.loadImageButton!.setImage(self.getImageWithColor(UIColor.black, size: CGSize(width: 40.0, height: 40.0)), for: UIControlState())
        self.loadImageButton!.addTarget(self, action: #selector(CameraViewController.loadImageFromLibrary(_:)), for: UIControlEvents.touchUpInside)
        
        self.repeatButton = UIButton(type: .custom)
        self.repeatButton!.setTitle("Repetir Foto", for: UIControlState())
        self.repeatButton!.setTitleColor(WMColor.dark_gray, for: UIControlState.highlighted)
        self.repeatButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.repeatButton!.addTarget(self, action: #selector(CameraViewController.returnCamera), for: UIControlEvents.touchUpInside)
        self.repeatButton!.backgroundColor = WMColor.light_blue
        self.repeatButton!.layer.cornerRadius = 18.0
        self.repeatButton!.alpha = 0
        self.view!.addSubview(self.repeatButton!)
        
        self.okButton = UIButton(type: .custom)
        self.okButton!.setTitle("Ok", for: UIControlState())
        self.okButton!.setTitleColor(WMColor.dark_gray, for: UIControlState.highlighted)
        self.okButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.okButton!.addTarget(self, action: #selector(CameraViewController.sendPhoto), for: UIControlEvents.touchUpInside)
        self.okButton!.backgroundColor = WMColor.green
        self.okButton!.layer.cornerRadius = 18.0
        self.okButton!.alpha = 0
        self.view!.addSubview(self.okButton!)
        
        if IS_IPAD {
            self.IPAPreviewBarView = UIView()
            self.IPAPreviewBarView?.backgroundColor = WMColor.light_blue
            self.IPAPreviewBarView!.alpha = 0.0;
            self.view.addSubview(self.IPAPreviewBarView!)
            
            self.topBarView!.addSubview(self.cancelButton!)
            self.topBackgroundView?.backgroundColor = UIColor.black
            self.topBackgroundView!.alpha = 0.2
            self.IPAPreviewBarView!.addSubview(self.messageLabel!)
            
            self.cancelButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
            self.camFlashButton!.isHidden = true;
            self.IPAPreviewBarView!.addSubview(self.messageLabel!)
            self.topBarView!.addSubview(self.loadImageButton!)
            self.topBarView!.addSubview(self.camButton!)
            
        }
        else{
            self.topBarView!.addSubview(self.messageLabel!)
            self.bottomBarView!.addSubview(self.cancelButton!)
            self.bottomBarView!.addSubview(self.camButton!)
            self.bottomBarView!.addSubview(self.loadImageButton!)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.startRunning), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.stopRunning), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.imagePickerCaptured!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.topBarView!.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: 64)
            self.topBackgroundView!.frame = self.topBarView!.frame
            self.camFlashButton!.frame = CGRect(x: 8, y: 31, width: 28, height: 28)
            self.messageLabel!.frame = CGRect(x: (self.view.bounds.width / 2) - 120, y: 31, width: 240, height: 28)
            self.camChangeButton!.frame = CGRect(x: 284, y: 31, width: 28, height: 28)
            
            self.bottomBarView!.frame = CGRect(x: 0.0, y: self.view.bounds.height - 92, width: self.view.bounds.width, height: 92)
            self.bottomBackgroundView!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 92)
            self.camButton!.frame = CGRect(x: (self.view.bounds.width / 2) - 32, y: 16, width: 64, height: 64)
            self.cancelButton!.frame = CGRect(x: 16, y: self.camButton!.center.y - 16, width: 55.0, height: 32.0)
            self.loadImageButton!.frame = CGRect(x: self.view.bounds.width - 56, y: self.camButton!.center.y - 20, width: 40, height: 40)
            
            self.repeatButton!.frame = CGRect(x: 44, y: self.view.bounds.height - 72, width: 100, height: 36)
            self.okButton!.frame = CGRect(x: (self.view!.frame.width - 144), y: self.view.bounds.height - 72, width: 100, height: 36)
            self.view.bringSubview(toFront: self.bottomBarView!)
        }
        else{
            self.topBarView!.frame = CGRect(x: self.view.bounds.width - 102, y: 0.0, width: 102, height: self.view.bounds.height)
            self.topBackgroundView!.frame = CGRect(x: 0.0, y: 0.0, width: 102, height: self.view.bounds.height)
            self.camChangeButton!.frame = CGRect(x: (self.topBarView!.bounds.width / 2) - 14, y: 32, width: 28, height: 28)
            self.camFlashButton!.frame = CGRect(x: (self.topBarView!.bounds.width / 2) - 14, y: self.camChangeButton!.frame.origin.y + self.camChangeButton!.frame.size.height + 24, width: 28, height: 28)
            self.camButton!.frame = CGRect(x: (self.topBarView!.bounds.width / 2) - 32, y: (self.topBarView!.bounds.height / 2) - 32, width: 64, height: 64)
            self.cancelButton!.frame = CGRect(x: (self.topBarView!.bounds.width / 2) - 32, y: self.view.bounds.height - 64, width: 64.0, height: 32.0)
            self.loadImageButton!.frame = CGRect(x: (self.topBarView!.bounds.width / 2) - 20, y: 620, width: 40.0, height: 40.0)
            
            self.IPAPreviewBarView!.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: 64)
            self.messageLabel!.frame = CGRect(x: (self.IPAPreviewBarView!.bounds.width / 2) - 150, y: 18, width: 300, height: 28)
            self.repeatButton!.frame = CGRect(x: (self.view!.bounds.width / 2) - 141, y: self.view.bounds.height - 68, width: 150, height: 36)
            self.okButton!.frame = CGRect(x: (self.view!.bounds.width / 2) + 41, y: self.view.bounds.height - 68, width: 150, height: 36)
        }
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
        if didChangeCam == true {
            if camera == CameraType.back {
                let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
                for device in videoDevices!{
                    let device = device as! AVCaptureDevice
                    if device.position == AVCaptureDevicePosition.front {
                        videoDevice = device
                        camera = CameraType.front
                        break
                    }
                }
            }
            else {
                videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
                camera = CameraType.back
            }
        }
        else{
            if camera == CameraType.back {
                videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
                camera = CameraType.back
            }
            else{
                let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
                for device in videoDevices!{
                    let device = device as! AVCaptureDevice
                    if device.position == AVCaptureDevicePosition.front {
                        videoDevice = device
                        camera = CameraType.front
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
                  self.closeCamera()
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
        previewLayer!.frame = self.view.frame
        
        if IS_IPAD{
            if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.landscapeLeft;
            }
            else if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight {
                self.previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.landscapeRight;
            }
            
            if IS_RETINA {
                previewLayer!.frame = CGRect(x: 0,y: 0,width: 1024,height: 768)
            }
        }
        
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession!.canAddOutput(stillImageOutput) {
            captureSession!.addOutput(stillImageOutput)
            
            self.view.layer.insertSublayer(previewLayer!, below: topBarView?.layer)
            self.startRunning()
        }
    }
    
    func changeCamera(){
        self.didChangeCam = true
        
        self.reloadCamera()
        if camera == CameraType.front{
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.camFlashButton!.alpha = 0;
            })
        }
        else{
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
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
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
            } catch _ {
            }
            if (device?.torchMode == AVCaptureTorchMode.on) {
                device?.torchMode = AVCaptureTorchMode.off
            } else {
                do {
                    try device?.setTorchModeOnWithLevel(1.0)
                } catch _ {
                }
            }
            device?.unlockForConfiguration()
        }
    }
    
    func takePhoto() {
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    self.capturedImage.image = image
                    self.stopRunning()
                    self.showPreview()
                }
            })
        }
    }
    
    func showPreview(){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            if IS_IPAD {
                self.topBarView!.alpha = 0
            }
            self.camChangeButton!.alpha = 0
            self.camFlashButton!.alpha = 0
            self.cancelButton!.alpha = 0
            self.camButton!.alpha = 0
            self.loadImageButton!.alpha = 0
            self.bottomBarView!.alpha = 0
            }, completion: {(completed : Bool) in
                //if completed {
                self.messageLabel!.text = NSLocalizedString("camfind.message.preview",comment:"")
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    if IS_IPAD {
                        self.IPAPreviewBarView!.alpha = 0.8
                        self.messageLabel!.alpha = 1
                    }
                    self.repeatButton!.alpha = 1
                    self.okButton!.alpha = 1
                })
                //}
        })
    }
    
    func returnCamera(){
        didChangeCam = false
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.reloadCamera()
            if IS_IPAD {
                self.IPAPreviewBarView!.alpha = 0
            }
            self.repeatButton!.alpha = 0
            self.okButton!.alpha = 0
            }, completion: {(completed : Bool) in
                if completed {
                    self.messageLabel!.text = NSLocalizedString("camfind.message.photo",comment:"")
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        if IS_IPAD {
                            self.topBarView!.alpha = 1;
                        }
                        
                        if self.camera == CameraType.front{
                            self.camFlashButton!.alpha = 0
                        }
                        else{
                            self.camFlashButton!.alpha = 1
                        }
                        
                        self.camChangeButton!.alpha = 1
                        self.cancelButton!.alpha = 1
                        self.camButton!.alpha = 1
                        self.loadImageButton!.alpha = 1
                        self.bottomBarView!.alpha = 1
                        self.imagePickerCaptured!.isHidden = true
                        self.previewLayer?.isHidden = false
                    })
                }
        })
    }
    
    func closeCamera(){
        self.dismiss(animated: true, completion: { () -> Void in
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_CANCEL_SEARCH.rawValue, label: "")
            self.delegate!.photoCaptured(nil,upcs:nil, done: { () -> Void in
            })
        })
    }
    
    
    //TODO: Fix
    
    
    var arrayImages = [NSLocalizedString("camfind.search.messageone",comment:""),
        NSLocalizedString("camfind.search.messagetwo",comment:""),
        NSLocalizedString("camfind.search.messagetree",comment:""),
        NSLocalizedString("camfind.search.messagefour",comment:"")]
    var currentItem = 0
    var scheduleTimmer : Timer!
    
    func sendPhoto(){
         let searchId = "\((arc4random() % 1000000) )"
        self.searchId = searchId
        if alertView == nil {
            self.alertView = IPAWMAlertViewController.showAlertWithCancelButton(self, delegate: self,imageWaiting:self.maskRoundedImage(capturedImage.image!), imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
            self.alertView!.setMessage(arrayImages[currentItem])
            scheduleTimmer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(CameraViewController.changeAlertMessage), userInfo: nil, repeats: true)
        }
        self.continueSearch = true
        let service = CamFindService()
        service.callService(service.buildParams(self.capturedImage.image!),
            successBlock: { (response: [String:Any]) -> Void in
                self.checkPhotoStatus(response["token"] as! String, idSearch: searchId)
            }, errorBlock: { (error:NSError) -> Void in
                //ERROR
        })
    }
    
    
    func changeAlertMessage() {
        if currentItem == arrayImages.count - 1 {
            scheduleTimmer.invalidate()
            return
        }
        currentItem += 1
        self.alertView!.setMessage(arrayImages[currentItem])
    }
    
    func checkPhotoStatus(_ token: String, idSearch: String){
       if(self.continueSearch && self.searchId == idSearch){
        let service = CamFindService()
        service.checkImg(token,
            successBlock: { (response: [String:Any]) -> Void in
                let resp = response["status"] as! String
                switch resp {
                case ("completed"):
                    let name = response["name"] as! String
                    var items : [String] = []
                    if let allItems = response["items"] as? [[String:Any]] {
                        for item in allItems {
                            let data = item["data"] as! [String:String]
                            let valueData = data["product_id"]
                            items.append(valueData!)
                        }
                    }
                    self.dismiss(animated: true, completion: nil)
                    
                    // self.delegate!.photoCaptured(name)
                    self.delegate!.photoCaptured(name,upcs:items, done: { () -> Void in
                        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SEARCH_BY_TAKING_A_PHOTO.rawValue, label: name)
                    })

                    break;
                case ("not completed"):
                    self.checkPhotoStatus(token, idSearch: idSearch)
                    break;
                case ("not found"):
                    self.dismiss(animated: true, completion: { () -> Void in
                        self.delegate!.photoCaptured("",upcs:nil, done: { () -> Void in
                        })
                        //self.delegate!.photoCaptured("")
                    })
                    break;
                case ("skipped"):
                    self.dismiss(animated: true, completion: { () -> Void in
                        self.delegate!.photoCaptured("",upcs:nil, done: { () -> Void in
                        })
                    })
                    break;
                case ("timeout"):
                    self.dismiss(animated: true, completion: { () -> Void in
                        self.delegate!.photoCaptured("",upcs:nil, done: { () -> Void in
                        })
                    })
                    break;
                case ("error"):
                    self.dismiss(animated: true, completion: { () -> Void in
                        self.delegate!.photoCaptured("",upcs:nil, done: { () -> Void in
                        })
                    })
                    break;
                default:
                    break;
                }
            }, errorBlock: { (error:NSError) -> Void in
                
        })
       }
    }
    
    func imageResize(_ imageObj: UIImage) -> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0
        
        let sizeChange = CGSize(width: 80, height: 80) as CGSize
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return scaledImage!
    }
    
    func maskRoundedImage(_ image: UIImage) -> UIImage {
        
        let viewBgImage = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        viewBgImage.layer.cornerRadius = viewBgImage.frame.width / 2
        viewBgImage.backgroundColor = UIColor.white
        viewBgImage.clipsToBounds = true
        
        let imageProduct = UIImageView(frame: CGRect(x: -30, y: -30, width: viewBgImage.frame.width + 60 , height: viewBgImage.frame.width  + 60))
        imageProduct.contentMode = UIViewContentMode.scaleAspectFit
        imageProduct.image = image
        viewBgImage.addSubview(imageProduct)
        
        UIGraphicsBeginImageContext(viewBgImage.frame.size)
        viewBgImage.layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage!
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
    func applicationWillEnterForeground(_ notification:Notification) {
        self.startRunning()
    }
    
    func applicationDidEnterBackground(_ notification:Notification) {
        self.stopRunning()
    }
    
    //MARK: - Orientation
    override var shouldAutorotate : Bool {
        if IS_IPAD {
            return true
        }
        else{
            return false
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if IS_IPAD {
            return [UIInterfaceOrientationMask.landscapeLeft, UIInterfaceOrientationMask.landscapeRight]
        }
        else {
            return UIInterfaceOrientationMask.portrait
        }
        
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        if IS_IPAD {
            return UIApplication.shared.statusBarOrientation
        }
        else{
            return UIInterfaceOrientation.portrait
        }
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if IS_IPAD {
            if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft {
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.landscapeLeft;
            }
            else if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight {
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.landscapeRight;
            }
        }
    }
    
    //MARK: - StatusBar
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    //MARK: Alert delegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            if !UIApplicationOpenSettingsURLString.isEmpty {
                   UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
        }
        self.closeCamera()
    }
    
    func loadImageFromLibrary(_ sender: UIButton) {
        imagePickerController!.allowsEditing = false
        imagePickerController!.sourceType = .photoLibrary
        
        if !self.allowsLibrary
        {
            UIAlertView(title: "Permisos", message: "Walmart necesita permiso para accesar a las fotos", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Settings").show()
            return
        }
        
        if IS_IPAD{
            self.popover = UIPopoverController(contentViewController: imagePickerController!)
            self.popover!.present(from: loadImageButton!.frame, in: self.topBarView!, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
        else{
            present(imagePickerController!, animated: true, completion: nil)
        }
        
    }
    
    func getLastImageFromLibrary(){
        let assets = ALAssetsLibrary()
        assets.getLastImage(fromPhotos: {(image:UIImage?, error:Error?) -> Void in
            self.allowsLibrary = (image != nil)
            if self.allowsLibrary {
                self.loadImageButton!.setImage(image, for: UIControlState())
            }
            
        })
    }
    
    func getImageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageResize(_ imageObj:UIImage, sizeChange:CGSize)-> UIImage {
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext() // !!!
        return scaledImage!
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if IS_IPAD{
            self.popover!.dismiss(animated: true)
        }
        else{
            dismiss(animated: true, completion: nil)
        }
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.capturedImage.contentMode = UIViewContentMode.scaleAspectFit
            self.capturedImage.image = pickedImage
            self.stopRunning()
            self.imagePickerCaptured.image = pickedImage
            self.previewLayer?.isHidden = true
            self.imagePickerCaptured.isHidden = false
            self.showPreview()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if IS_IPAD{
            self.popover!.dismiss(animated: true)
        }
        else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - IPAWMAlertViewControllerDelegate
    
    func cancelButtonTapped() {
        self.returnCamera()
        self.continueSearch = false
        self.alertView = nil
        self.scheduleTimmer.invalidate()
    }
}
