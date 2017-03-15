//
//  ImageLoader.swift
//  WalMart
//
//  Created by Jesus Santa Olalla on 3/10/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class ImageLoader {
    
    var cache = NSCache<AnyObject, AnyObject>()
    
    class var sharedLoader: ImageLoader {
        struct Static {
            static let instance: ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    
    func imageForUrl(url: URL, placeholder: UIImage?, completionHandler: @escaping (_ image: UIImage?) -> ()) {
        
        dispatch.async.bg {
            
            if let data = self.cache.object(forKey: url.absoluteString as AnyObject) as? Data {
                let image = UIImage(data: data)
                dispatch.async.main {
                    completionHandler(image)
                }
                return
            } else {
                dispatch.async.main {
                    completionHandler(placeholder)
                }
            }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200, let mimeType = response?.mimeType, mimeType.hasPrefix("image"), let data = data, error == nil, let image = UIImage(data: data) else {
                    
                    dispatch.async.main {
                        completionHandler(nil)
                    }
                    
                    return
                }
                
                self.cache.setObject(data as AnyObject, forKey: url.absoluteString as AnyObject)
                
                dispatch.async.main {
                    completionHandler(image)
                }
                
                return
                
            }.resume()
            
        }
        
    }
}
