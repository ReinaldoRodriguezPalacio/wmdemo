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
        
        let Device = UIDevice.current
        if previewLayer != nil {
            if Device.orientation == UIDeviceOrientation.landscapeLeft {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            }
            else {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
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
        self.helpLabel!.frame = CGRect( x: (self.view.frame.width / 2) - 100  , y: 150  , width: 200 ,height: 30 )
        self.close.frame = CGRect(x: (self.view.frame.width) - 48,y: 16,width: 48,height: 48)
    }

    
    
    //MARK: - Orientation
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        let Device = UIDevice.current
        if Device.orientation == UIDeviceOrientation.landscapeLeft {
            return UIInterfaceOrientation.landscapeRight
        }
        else {
            return UIInterfaceOrientation.landscapeLeft
        }
    }
    
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if previewLayer != nil {
            if  toInterfaceOrientation ==  UIInterfaceOrientation.landscapeLeft {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            }
            if  toInterfaceOrientation ==  UIInterfaceOrientation.landscapeRight {
                previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            }
        }
    }
    
    
}
