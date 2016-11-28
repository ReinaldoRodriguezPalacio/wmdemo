//
//  ProductDetailNavigatinAnimationController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/14/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

enum AnimationType {
    case present
    case dismiss
}

class ProductDetailNavigatinAnimationController : NSObject, UIViewControllerAnimatedTransitioning{
    
    var type : AnimationType!
    var originPoint : CGRect!   
    var imageTranslate : UIImageView!
    var endPoint : CGRect!
    var navController : UINavigationController!
    
    init(nav navigationcontroller:UINavigationController) {
        navController = navigationcontroller
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4;
    }

    func setImage(_ image:UIImage) {
        if imageTranslate == nil {
            imageTranslate = UIImageView(frame:CGRect.zero)
            imageTranslate.contentMode = UIViewContentMode.scaleAspectFit
            imageTranslate.backgroundColor = UIColor.white
            self.navController.view.addSubview(imageTranslate)
        }
        imageTranslate.image = image
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        var fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        
        
        if (self.type == AnimationType.present) {
            //Add 'to' view to the hierarchy with 0.0 scale
            if let productViewController = toViewController as? IPAProductDetailPageViewController {
                imageTranslate.frame = originPoint
                self.imageTranslate.alpha = 0.0
                productViewController.view.alpha = 1.0
                //toViewController!.view.frame = originPoint
                //toViewController!.view.transform = CGAffineTransformMakeScale(0.2, 0.2);
                containerView.insertSubview(productViewController.view, aboveSubview:fromViewController!.view)
                UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
                    fromViewController!.view.alpha = 0.0
                    //toViewController!.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    self.imageTranslate.frame = CGRect(x: 0, y: 60, width: 682, height: 340)
                    //toViewController!.view.frame = containerView.frame
                    }, completion: { (complete:Bool) -> Void in
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                           
                            productViewController.view.alpha = 1.0
                            }, completion: { (complete:Bool) -> Void in
                                 self.imageTranslate.alpha = 0.0
                            transitionContext.completeTransition(true)
                        })
                        
                })
            }
            
            
        } else if (self.type == AnimationType.dismiss) {
        
            containerView.insertSubview(toViewController!.view, aboveSubview:fromViewController!.view)
            self.imageTranslate.alpha = 1.0
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
                toViewController!.view.alpha = 1.0
                self.imageTranslate.frame = self.originPoint
                
                //fromViewController!.view.transform = CGAffineTransformMakeScale(0.0, 0.0);
                fromViewController!.view.alpha = 0.0
                }, completion: { (complete:Bool) -> Void in
                    
                    if toViewController!.responds(to: Selector("reloadSelectedCell")){
                        Timer.scheduledTimer(timeInterval: 0.0, target: toViewController!, selector: Selector("reloadSelectedCell"), userInfo: nil, repeats: false)
                    }
                    if let contProduct =  toViewController as? IPAProductDetailPageViewController {
                        toViewController?.navigationController?.delegate = contProduct
                    }else{
                        toViewController?.navigationController?.delegate = nil
                    }

                    self.imageTranslate.alpha = 0.0
                    transitionContext.completeTransition(true)
                    fromViewController!.view.removeFromSuperview()
                    fromViewController = nil
            })

        }
        
        
    }
    
    func imageProductDetailLoaded() {
         self.imageTranslate.alpha = 0.0
    }

    
}
