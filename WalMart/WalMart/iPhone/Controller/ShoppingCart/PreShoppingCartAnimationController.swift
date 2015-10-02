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
        let srcViewController = self.sourceViewController 
        let destController = self.destinationViewController 
        
        var yPointOpen : CGFloat  = 50.0
        if let  srcViewControllerPSC = srcViewController as? PreShoppingCartViewController {
            yPointOpen = srcViewControllerPSC.yPointOpen
        }
        
        let image = UIImage(fromView: srcViewController.view)
        let image1 = image.crop(CGRectMake(0, 0, image.size.width, yPointOpen))
        
        let image2 = image.crop(CGRectMake(0, yPointOpen, image.size.width, 400))
        
        let tmpWhiteView = UIView(frame: srcViewController.view.bounds)
        tmpWhiteView.backgroundColor = UIColor.whiteColor()
        
        srcViewController.view.addSubview(tmpWhiteView)
        srcViewController.view.addSubview(destController.view)
       

        
        destController.view.transform = CGAffineTransformMakeScale(0.95, 0.95)
        destController.view.alpha = 0
        

        
        let originalCenter = destController.view!.center
        destController.view!.center = srcViewController.view!.center
        
        
        let tmpImgUp = UIImageView(frame: CGRectMake(0, 0, srcViewController.view.frame.width, yPointOpen))
        tmpImgUp.image = image1
        let tmpImgDown = UIImageView(frame: CGRectMake(0, yPointOpen, srcViewController.view.frame.width, srcViewController.view.frame.height - yPointOpen))
        tmpImgDown.image = image2
        
        srcViewController.navigationController?.view.addSubview(tmpImgUp)
        srcViewController.navigationController?.view.addSubview(tmpImgDown)
        
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            tmpImgUp.frame = CGRectMake(0, -tmpImgUp.frame.height, tmpImgUp.frame.width, tmpImgUp.frame.height)
             tmpImgDown.frame = CGRectMake(0, destController.view.frame.height , tmpImgDown.frame.width, tmpImgDown.frame.height)
            destController.view!.transform = CGAffineTransformMakeScale(1.0, 1.0);
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