//
//  IPAPreShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/27/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class IPAPreShoppingCartViewController :  BaseController,UIDynamicAnimatorDelegate {
    
    var viewSuper : PreShoppingCartView!
    var viewMG : PreShoppingCartView!
    var viewBG : UIView!

    var gravity: UIGravityBehavior!
    var animator: UIDynamicAnimator!
    var collision: UICollisionBehavior!
    
    var gravity2: UIGravityBehavior!
    var animator2: UIDynamicAnimator!
    var collision2: UICollisionBehavior!
    
    var delegate : ShoppingCartViewControllerDelegate!
    
    var loadImage : LoadingIconView!
    
    let optionsShoppingCart = ["Súper","Tecnología, Hogar y Más"]
    let shoppingCart : UIViewController? = nil
    var emptyView : IPAShoppingCartEmptyView!
    
    var controllerShowing : UIViewController? = nil
    var finishAnimation : (() -> Void)? = nil
    
    override func viewDidLoad() {
        
        //SCREEN
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_PRESHOPPINGCART.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
        
        
        self.view.backgroundColor = UIColor.clearColor()
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        
        viewBG = UIView(frame:CGRectZero)
        viewBG.alpha = 0
        viewBG.backgroundColor = WMColor.UIColorFromRGB(0x000000, alpha: 0.6)
        self.view.addSubview(viewBG)
        
        viewSuper = PreShoppingCartView(frame: CGRectZero)
        self.view.addSubview(viewSuper)
        
        
        
        viewMG = PreShoppingCartView(frame: CGRectZero)
        self.view.addSubview(viewMG)
        
        
        emptyView = IPAShoppingCartEmptyView(frame:CGRectZero)
        emptyView.returnAction = {() in
            self.closeShoppingCart()
        }
        self.view.addSubview(emptyView)
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadpreShopingCard()
    }
    
    func reloadpreShopingCard(){
        if self.controllerShowing != nil {
            if self.controllerShowing!.parentViewController != nil {
                self.controllerShowing?.removeFromParentViewController()
            }
            if self.controllerShowing!.view.superview != nil {
                self.controllerShowing?.view.removeFromSuperview()
            }
            self.controllerShowing = nil
        }

      self.reloadPreShoppingCar()

        /*self.emptyView == nil {
            emptyView = IPAShoppingCartEmptyView(frame:CGRectZero)
            emptyView.returnAction = {() in
                self.closeShoppingCart()
            }
            self.view.addSubview(emptyView)
        }*/
        
    }
    
    
    func reloadPreShoppingCar(){
    
        self.emptyView!.hidden = true
        self.emptyView.frame = CGRectMake(0, -self.view.bounds.height, self.view.bounds.width, self.view.bounds.height - 46)
        
        UserCurrentSession.sharedInstance().loadShoppingCarts({() -> Void in
            
            //let articlesStr = NSLocalizedString("shoppingcart.articles",comment:"")
            
//            if UserCurrentSession.sharedInstance().isEmptyMG() && UserCurrentSession.sharedInstance().isEmptyGR() {
//                //Show emptyView
//                self.emptyView!.hidden = false
//                UIView.animateWithDuration(0.3, animations: { () -> Void in
//                    self.emptyView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
//                    }) { (complete:Bool) -> Void in
//                }
//                
//            } else {
            
                let articlesStr = NSLocalizedString("shoppingcart.articles",comment:"")
                let noArticlesStr = NSLocalizedString("shoppingcart.noarticles",comment:"")
            let noArticlesGrStr = NSLocalizedString("shoppingcart.noarticles.gr",comment:"")
                let totArticlesGR = UserCurrentSession.sharedInstance().numberOfArticlesGR()
                let articlesInCart = totArticlesGR > 0 ? "\(totArticlesGR) \(articlesStr)" : noArticlesGrStr
                self.viewSuper.setValues(WMColor.superBG,imgBgName:"preCart_super_banner", imgIconName: "preCart_super_icon",title:self.optionsShoppingCart[0],articles:articlesInCart,total:"\(UserCurrentSession.sharedInstance().estimateTotalGR())",totalColor:WMColor.superBG, empty: totArticlesGR == 0 )
                
                let totArticlesMG = UserCurrentSession.sharedInstance().numberOfArticlesMG()
            let noArticlesMgStr = NSLocalizedString("shoppingcart.noarticles.mg",comment:"")
                let articlesInCartMG = totArticlesMG > 0 ? "\(totArticlesMG) \(articlesStr)" : noArticlesMgStr
                self.viewMG.setValues(WMColor.mgBG,imgBgName:"preCart_mg_banner", imgIconName: "preCart_super_icon",title:self.optionsShoppingCart[1],articles:articlesInCartMG,total:"\(UserCurrentSession.sharedInstance().estimateTotalMG())",totalColor:WMColor.mgBG,empty:totArticlesMG == 0)
            
            self.viewMG.tapAction =  { () -> Void in
                // self.yPointOpen = self.viewMG.imgBackground.convertRect(self.viewMG.imgBackground.frame, toView: self.view).maxY
                //self.performSegueWithIdentifier("shoppingCartMG", sender: self)
                if totArticlesMG > 0 {
                    self.openViewMG()
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearShoppingCartMG.rawValue, object: nil)
                }
                
            }
            
            
            self.viewSuper.tapAction =  { () -> Void in
                if totArticlesGR > 0 {
                    self.openViewGR()
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearShoppingCartGR.rawValue, object: nil)
                }
            }

            
            
                self.animateViews()
                
                
//            }
            
            UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
            self.loadImage.stopAnnimating()
            self.loadImage.removeFromSuperview()
            //self.loadImage = nil
            
        })
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.viewBG.alpha = 1
            }) { (complete:Bool) -> Void in
                
        }

    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        viewSuper.frame =  CGRectMake(200, -288, 288, 228)
        viewMG.frame =  CGRectMake(536, -288, 288, 228)
        
        self.loadAnimationPreShopping()
        
    }
    
    
    func loadAnimationPreShopping(){
    
        if loadImage == nil {
            loadImage = LoadingIconView(frame: CGRectMake(0, 0, 116, 120))
        }
        loadImage.center = self.view.center
        self.view.addSubview(loadImage)
        
        loadImage.startAnnimating()
        loadImage.backgroundColor = UIColor.clearColor()
        
        shoppingCart?.view.removeFromSuperview()
        shoppingCart?.removeFromParentViewController()

    
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewBG.frame = self.view.bounds
    }
    
    func openShoppingCart(){
        
    }
    
    func animateViews() {

        viewSuper.alpha = 1
        viewMG.alpha = 1
        
        viewSuper.frame =  CGRectMake(200, -288, 288, 228)
        viewMG.frame =  CGRectMake(536, -288, 288, 228)
        
        animator = UIDynamicAnimator(referenceView: self.view)
        animator2 = UIDynamicAnimator(referenceView: self.view)
        animator.delegate = self
        
        gravity = UIGravityBehavior(items: [viewSuper])
        gravity.magnitude = 2.0
        
        gravity2 = UIGravityBehavior(items: [viewMG])
        gravity2.magnitude = 3.0
        animator2.addBehavior(gravity2)
        animator.addBehavior(gravity)
        
        
        collision = UICollisionBehavior(items: [viewSuper])
        collision2 = UICollisionBehavior(items: [viewMG])
        //collision.translatesReferenceBoundsIntoBoundary = true
        collision.addBoundaryWithIdentifier("barrier", fromPoint: CGPointMake(self.view.frame.origin.x, 439), toPoint: CGPointMake(self.view.frame.origin.x + self.view.frame.width, 439))
        collision2.addBoundaryWithIdentifier("barrier", fromPoint: CGPointMake(self.view.frame.origin.x, 439), toPoint: CGPointMake(self.view.frame.origin.x + self.view.frame.width, 439))

        animator.addBehavior(collision)
        animator2.addBehavior(collision2)
        
        
        
    }

    func closeShoppingCart() {
        

        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.frame = CGRectMake(self.view.frame.minX, -self.view.frame.height , self.view.frame.width,  self.view.frame.height)
                }) { (completed:Bool) -> Void in
                    
                    
                   self.viewSuper.frame =  CGRectMake(200, -288, 288, 228)
                    self.viewMG.frame =  CGRectMake(536, -288, 288, 228)
                    
                    
//                    self.controllerShowing?.removeFromParentViewController()
//                    self.controllerShowing?.view.removeFromSuperview()
//                    self.controllerShowing = nil
                  self.navigationController?.popToRootViewControllerAnimated(false)
                //self.view.removeFromSuperview()
                  //NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
                 self.delegate.returnToView()
        }
    }
    
    
    func openViewMG() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.viewMG.frame = CGRectMake((self.view.frame.width / 2) - (self.viewMG.frame.width / 2), self.viewMG.frame.minY, self.viewMG.frame.width, self.viewMG.frame.height)
            self.viewSuper.frame = CGRectMake(-self.viewSuper.frame.width, self.viewSuper.frame.minY, self.viewSuper.frame.width, self.viewSuper.frame.height)
            }) { (complete:Bool) -> Void in
                
                let vcResult = self.storyboard?.instantiateViewControllerWithIdentifier("shoppingCartMGVC") as! IPAShoppingCartViewController
                vcResult.view.frame = CGRectMake(0, -self.view.bounds.height, self.view.bounds.width, self.view.bounds.height)
                vcResult.onClose = {(isClose:Bool) in
                    
                    self.viewMG.alpha = 0
                    self.viewSuper.alpha = 0
                }
                
                self.view.addSubview(vcResult.view)
                self.controllerShowing = vcResult
                self.navigationController?.pushViewController(vcResult, animated: false)
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    vcResult.view.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
                    self.viewMG.frame = CGRectMake((self.view.frame.width / 2) - (self.viewMG.frame.width / 2), self.view.bounds.height, self.viewMG.frame.width, self.viewMG.frame.height)
                    }, completion: { (complete:Bool) -> Void in
                    
                })
        }
    }
    
    func openViewGR() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.viewSuper.frame = CGRectMake((self.view.frame.width / 2) - (self.viewSuper.frame.width / 2), self.viewSuper.frame.minY, self.viewSuper.frame.width, self.viewSuper.frame.height)
            self.viewMG.frame = CGRectMake(1024+self.viewMG.frame.width, self.viewMG.frame.minY, self.viewMG.frame.width, self.viewMG.frame.height)
            }) { (complete:Bool) -> Void in
                
                let vcResult = self.storyboard?.instantiateViewControllerWithIdentifier("shoppingCartGRVC") as! IPAGRShoppingCartViewController
                vcResult.view.frame = CGRectMake(0, -self.view.bounds.height, self.view.bounds.width, self.view.bounds.height)
                
                vcResult.onClose = {(isClose:Bool) in
                    
                    self.viewMG.alpha = 0
                    self.viewSuper.alpha = 0
                }
                
                vcResult.onSuccessOrder = {() in
                    vcResult.removeFromParentViewController()
                    vcResult.view.removeFromSuperview()
                    self.reloadpreShopingCard()
                }
                
                self.view.addSubview(vcResult.view)
                self.controllerShowing = vcResult
                self.navigationController?.pushViewController(vcResult, animated: false)
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    vcResult.view.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
                    self.viewSuper.frame = CGRectMake((self.view.frame.width / 2) - (self.viewSuper.frame.width / 2), self.view.bounds.height, self.viewSuper.frame.width, self.viewSuper.frame.height)
                    }, completion: { (complete:Bool) -> Void in
                        
                })
        }
    }
    
    
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        
        self.view.userInteractionEnabled = true
        
        self.finishAnimation?()
        
    }
    
    
}