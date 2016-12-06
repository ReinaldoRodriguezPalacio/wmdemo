//
//  RSCodeReaderViewController.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/12/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import AVFoundation

open class RSCodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    open var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    open lazy var output = AVCaptureMetadataOutput()
    open lazy var session = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    open lazy var focusMarkLayer = RSFocusMarkLayer()
    open lazy var cornersLayer = RSCornersLayer()
    
    open var tapHandler: ((CGPoint) -> Void)?
    open var barcodesHandler: ((Array<AVMetadataMachineReadableCodeObject>) -> Void)?
    
    var ticker: Timer?
    
    open var isCrazyMode = true
    var isCrazyModeStarted = false
    var lensPosition: Float = 0
    
    // MARK: Public methods
    
    open func hasFlash() -> Bool {
        if let d = self.device {
            return d.hasFlash
        }
        return false
    }
    
    open func hasTorch() -> Bool {
        if let d = self.device {
            return d.hasTorch
        }
        return false
    }
    
    open func toggleTorch() {
        if self.hasTorch() {
            self.session.beginConfiguration()
            do {
                try self.device?.lockForConfiguration()
            } catch _ {
            }
            
            if self.device?.torchMode == AVCaptureTorchMode.off {
                self.device?.torchMode = AVCaptureTorchMode.on
            } else if self.device?.torchMode == AVCaptureTorchMode.on {
                self.device?.torchMode = AVCaptureTorchMode.off
            }
            
            self.device?.unlockForConfiguration()
            self.session.commitConfiguration()
        }
    }
    
    // MARK: Private methods
    
    class func interfaceOrientationToVideoOrientation(_ orientation : UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch (orientation) {
        case .unknown:
            fallthrough
        case .portrait:
            return AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown:
            return AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft:
            return AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight:
            return AVCaptureVideoOrientation.landscapeRight
        }
    }
    
    func autoUpdateLensPosition() {
        self.lensPosition += 0.01
        if self.lensPosition > 1 {
            self.lensPosition = 0
        }
        do {
            try device?.lockForConfiguration()
            self.device?.setFocusModeLockedWithLensPosition(self.lensPosition, completionHandler: nil)
            device?.unlockForConfiguration()
        } catch _ {
        }
        if session.isRunning {
            let when = DispatchTime.now() + Double(Int64(10 * Double(USEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: when, execute: {
                self.autoUpdateLensPosition()
            })
        }
    }
    
    func onTick() {
        if let t = self.ticker {
            t.invalidate()
        }
        self.cornersLayer.cornersArray = []
    }
    
    func onTap(_ gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.location(in: self.view)
        let focusPoint = CGPoint(
            x: tapPoint.x / self.view.bounds.size.width,
            y: tapPoint.y / self.view.bounds.size.height)
        
        if let d = self.device {
            do {
                try d.lockForConfiguration()
                if d.isFocusPointOfInterestSupported {
                    d.focusPointOfInterest = focusPoint
                } else {
                    print("Focus point of interest not supported.")
                }
                if self.isCrazyMode {
                    if d.isFocusModeSupported(.locked) {
                        d.focusMode = .locked
                    } else {
                        print("Locked focus not supported.")
                    }
                    if !self.isCrazyModeStarted {
                        self.isCrazyModeStarted = true
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.autoUpdateLensPosition()
                        })
                    }
                } else {
                    if d.isFocusModeSupported(.continuousAutoFocus) {
                        d.focusMode = .continuousAutoFocus
                    } else if d.isFocusModeSupported(.autoFocus) {
                        d.focusMode = .autoFocus
                    } else {
                        print("Auto focus not supported.")
                    }
                }
                if d.isAutoFocusRangeRestrictionSupported {
                    d.autoFocusRangeRestriction = .none
                } else {
                    print("Auto focus range restriction not supported.")
                }
                d.unlockForConfiguration()
                self.focusMarkLayer.point = tapPoint
            } catch _ {
            }
        }
        
        if let h = self.tapHandler {
            h(tapPoint)
        }
    }
    
    func onApplicationWillEnterForeground() {
        self.session.startRunning()
    }
    
    func onApplicationDidEnterBackground() {
        self.session.stopRunning()
    }
    
    // MARK: Deinitialization
    
    deinit {
        print("RSCodeReaderViewController deinit")
    }
    
    // MARK: View lifecycle
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let l = self.videoPreviewLayer {
            let videoOrientation = RSCodeReaderViewController.interfaceOrientationToVideoOrientation(UIApplication.shared.statusBarOrientation)
            if l.connection.isVideoOrientationSupported
                && l.connection.videoOrientation != videoOrientation {
                    l.connection.videoOrientation = videoOrientation
            }
        }
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if let l = self.videoPreviewLayer {
            l.frame = frame
        }
//        if let l = self.focusMarkLayer {
//            l.frame = frame
//        }
//        if let l = self.cornersLayer {
//            l.frame = frame
//        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        var error : NSError?
        let input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: self.device)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        if let e = error {
            print(e.description)
            return
        }
        
        if let d = self.device {
            do {
                try d.lockForConfiguration()
                if (self.device?.isFocusModeSupported(.continuousAutoFocus))! {
                    self.device?.focusMode = .continuousAutoFocus
                }
                if (self.device?.isAutoFocusRangeRestrictionSupported)! {
                    self.device?.autoFocusRangeRestriction = .near
                }
                self.device?.unlockForConfiguration()
            } catch _ {
            }
        }
        
        if self.session.canAddInput(input) {
            self.session.addInput(input)
        }
        
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        if let l = self.videoPreviewLayer {
            l.videoGravity = AVLayerVideoGravityResizeAspectFill
            l.frame = self.view.bounds
            self.view.layer.addSublayer(l)
        }
        
        let queue = DispatchQueue(label: "com.pdq.rsbarcodes.metadata", attributes: DispatchQueue.Attributes.concurrent)
        self.output.setMetadataObjectsDelegate(self, queue: queue)
        if self.session.canAddOutput(self.output) {
            self.session.addOutput(self.output)
            self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RSCodeReaderViewController.onTap(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.focusMarkLayer.frame = self.view.bounds
        self.view.layer.addSublayer(self.focusMarkLayer)
        
        self.cornersLayer.frame = self.view.bounds
        self.view.layer.addSublayer(self.cornersLayer)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RSCodeReaderViewController.onApplicationWillEnterForeground), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RSCodeReaderViewController.onApplicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        self.session.startRunning()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        self.session.stopRunning()
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    
    open func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        var barcodeObjects : Array<AVMetadataMachineReadableCodeObject> = []
        var cornersArray : Array<[Any]> = []
        for metadataObject : Any in metadataObjects {
            if let l = self.videoPreviewLayer {
                let transformedMetadataObject = l.transformedMetadataObject(for: metadataObject as! AVMetadataObject)
                if transformedMetadataObject!.isKind(of: AVMetadataMachineReadableCodeObject.self) {
                    let barcodeObject = transformedMetadataObject as! AVMetadataMachineReadableCodeObject
                    barcodeObjects.append(barcodeObject)
                    cornersArray.append(barcodeObject.corners)
                }
            }
        }
        
        self.cornersLayer.cornersArray = cornersArray as Array<[AnyObject]>
        
        if barcodeObjects.count > 0 {
            if let h = self.barcodesHandler {
                h(barcodeObjects)
            }
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            if let t = self.ticker {
                t.invalidate()
            }
            self.ticker = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(RSCodeReaderViewController.onTick), userInfo: nil, repeats: true)
        })
    }
}
