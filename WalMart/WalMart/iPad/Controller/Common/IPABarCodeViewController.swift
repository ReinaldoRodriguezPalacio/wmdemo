//
//  IPABarCodeViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 01/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import QuartzCore

class IPABarCodeViewController: BarCodeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let Device = UIDevice.currentDevice()
        if previewLayer != nil {
            if Device.orientation == UIDeviceOrientation.LandscapeLeft {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            }
            else {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        if running || captureSession == nil {
            return
        }
        super.viewWillLayoutSubviews()
        if previewLayer != nil {
            previewLayer!.frame =  self.view.bounds
        }
        self.helpLabel!.frame = CGRectMake( (self.view.frame.width / 2) - 100  , 150  , 200 ,30 )
        self.close.frame = CGRectMake((self.view.frame.width) - 48,16,48,48)
    }

    
    
    //MARK: - Orientation
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        let Device = UIDevice.currentDevice()
        if Device.orientation == UIDeviceOrientation.LandscapeLeft {
            return UIInterfaceOrientation.LandscapeRight
        }
        else {
            return UIInterfaceOrientation.LandscapeLeft
        }
    }
    
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if previewLayer != nil {
            if  toInterfaceOrientation ==  UIInterfaceOrientation.LandscapeLeft {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            }
            if  toInterfaceOrientation ==  UIInterfaceOrientation.LandscapeRight {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            }
        }
    }
    
    
}
