//
//  PreShoppingCartAnimationController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/29/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation



class PreShoppingCartAnimationController : UIStoryboardSegue {
    
    override func perform() {
        let srcViewController = self.source 
        let destController = self.destination 
        
        var yPointOpen : CGFloat  = 50.0
        if let  srcViewControllerPSC = srcViewController as? PreShoppingCartViewController {
            yPointOpen = srcViewControllerPSC.yPointOpen
        }
        
        let image = UIImage(from: srcViewController.view)
        let image1 = image?.crop(CGRect(x: 0, y: 0, width: (image?.size.width)!, height: yPointOpen))
        
        let image2 = image?.crop(CGRect(x: 0, y: yPointOpen, width: (image?.size.width)!, height: 400))
        
        let tmpWhiteView = UIView(frame: srcViewController.view.bounds)
        tmpWhiteView.backgroundColor = UIColor.white
        
        srcViewController.view.addSubview(tmpWhiteView)
        srcViewController.view.addSubview(destController.view)
       

        
        destController.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        destController.view.alpha = 0
        

        
        let originalCenter = destController.view!.center
        destController.view!.center = srcViewController.view!.center
        
        
        let tmpImgUp = UIImageView(frame: CGRect(x: 0, y: 0, width: srcViewController.view.frame.width, height: yPointOpen))
        tmpImgUp.image = image1
        let tmpImgDown = UIImageView(frame: CGRect(x: 0, y: yPointOpen, width: srcViewController.view.frame.width, height: srcViewController.view.frame.height - yPointOpen))
        tmpImgDown.image = image2
        
        srcViewController.navigationController?.view.addSubview(tmpImgUp)
        srcViewController.navigationController?.view.addSubview(tmpImgDown)
        
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            tmpImgUp.frame = CGRect(x: 0, y: -tmpImgUp.frame.height, width: tmpImgUp.frame.width, height: tmpImgUp.frame.height)
             tmpImgDown.frame = CGRect(x: 0, y: destController.view.frame.height , width: tmpImgDown.frame.width, height: tmpImgDown.frame.height)
            destController.view!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0);
            destController.view!.center = originalCenter;
            destController.view.alpha = 1
            
            }) { (complete:Bool) -> Void in
                destController.view!.removeFromSuperview()
                srcViewController.navigationController?.pushViewController(destController, animated: false)
                tmpWhiteView.removeFromSuperview()
                tmpImgUp.removeFromSuperview()
                tmpImgDown.removeFromSuperview()
                
        }
        
        
    }
}
