//
//  RSCodeLayer.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/13/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import QuartzCore

open class RSCodeLayer: CALayer {
    var code: UIImage?
    
    override open func draw(in ctx: CGContext) {
        if let image = self.code {
            ctx.saveGState()
            
            ctx.draw(image.cgImage!, in: self.bounds)
            
            ctx.restoreGState()
        }
    }
}
