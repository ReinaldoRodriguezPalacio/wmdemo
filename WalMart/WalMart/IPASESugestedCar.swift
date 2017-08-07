//
//  IPASESugestedCar.swift
//  WalMart
//
//  Created by Vantis on 04/08/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation


class IPASESugestedCar : SESugestedCar{

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.cornerRadius = 20

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func back(){
            self.willMove(toParentViewController: nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
    }
    
    override func showLoadingView() {
        
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 0, width: (self.parent?.view.frame.width)!, height: (self.parent?.view.frame.width)!))
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(true)
    }

    
}
