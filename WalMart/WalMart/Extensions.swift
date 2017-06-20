//
//  Extensions.swift
//  WalMart
//
//  Created by Jesus Santa Olalla on 3/10/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation
import UIKit


class dispatch {
    
    class async {
        
        class func bg(_ block: @escaping ()->()) {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { block() }
        }
        
        class func main(_ block: @escaping ()->()) {
            DispatchQueue.main.async(execute: block)
        }
        
    }
    
}

extension UIImageView {
    
    func setImage(with url: URL, and placeholder: UIImage?, success: @escaping (_ image: UIImage) -> Void, failure: @escaping () -> Void) {
        
        ImageLoader.sharedLoader.imageForUrl(url: url, placeholder: placeholder) { (image) in
            if image != nil {
                self.image = image
                if image != placeholder {
                    success(image!)
                }
            }
        }
        
    }
    
}

extension String {
    
      func findIndex(value:String) -> String {
        
        let range: Range<String.Index> = self.range(of: value)!
        let index: Int = self.distance(from: self.startIndex, to: range.lowerBound)
        
        return self.substring(0, length: index).trim()
    
    }

}
