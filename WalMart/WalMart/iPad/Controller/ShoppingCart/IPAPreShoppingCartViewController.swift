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
        
        self.view.backgroundColor = UIColor.clear
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        viewBG = UIView(frame:CGRect.zero)
        viewBG.alpha = 0
        viewBG.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.view.addSubview(viewBG)
        
        viewSuper = PreShoppingCartView(frame: CGRect.zero)
        self.view.addSubview(viewSuper)
        
        
        
        viewMG = PreShoppingCartView(frame: CGRect.zero)
        self.view.addSubview(viewMG)
        
        
        emptyView = IPAShoppingCartEmptyView(frame:CGRect.zero)
        emptyView.returnAction = {() in
            self.closeShoppingCart()
        }
        self.view.addSubview(emptyView)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadpreShopingCard()
    }
    
    func reloadpreShopingCard(){
        if self.controllerShowing != nil {
            if self.controllerShowing!.parent != nil {
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
    
        self.emptyView!.isHidden = true
        self.emptyView.frame = CGRect(x: 0, y: -self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height - 46)
        
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
                //let noArticlesStr = NSLocalizedString("shoppingcart.noarticles",comment:"")
                let noArticlesGrStr = NSLocalizedString("shoppingcart.noarticles.gr",comment:"")
                let totArticlesGR = UserCurrentSession.sharedInstance().numberOfArticlesGR()
                let articlesInCart = totArticlesGR > 0 ? "\(totArticlesGR) \(articlesStr)" : noArticlesGrStr
                self.viewSuper.setValues(WMColor.green,imgBgName:"preCart_super_banner", imgIconName: "preCart_super_icon",title:self.optionsShoppingCart[0],articles:articlesInCart,total:"\(UserCurrentSession.sharedInstance().estimateTotalGR())",totalColor:WMColor.green, empty: totArticlesGR == 0 )
                
                let totArticlesMG = UserCurrentSession.sharedInstance().numberOfArticlesMG()
            let noArticlesMgStr = NSLocalizedString("shoppingcart.noarticles.mg",comment:"")
                let articlesInCartMG = totArticlesMG > 0 ? "\(totArticlesMG) \(articlesStr)" : noArticlesMgStr
                self.viewMG.setValues(WMColor.light_blue,imgBgName:"preCart_mg_banner", imgIconName: "preCart_super_icon",title:self.optionsShoppingCart[1],articles:articlesInCartMG,total:"\(UserCurrentSession.sharedInstance().estimateTotalMG())",totalColor:WMColor.light_blue,empty:totArticlesMG == 0)
            
            self.viewMG.tapAction =  { () -> Void in
                // self.yPointOpen = self.viewMG.imgBackground.convertRect(self.viewMG.imgBackground.frame, toView: self.view).maxY
                //self.performSegueWithIdentifier("shoppingCartMG", sender: self)
                if totArticlesMG > 0 {
                    self.openViewMG()
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearShoppingCartMG.rawValue), object: nil)
                }
                
            }
            
            
            self.viewSuper.tapAction =  { () -> Void in
                if totArticlesGR > 0 {
                    self.openViewGR()
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearShoppingCartGR.rawValue), object: nil)
                }
            }

            
            
                self.animateViews()
                
                
//            }
            
            UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
            self.loadImage.stopAnnimating()
            self.loadImage.removeFromSuperview()
            //self.loadImage = nil
            
        })
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.viewBG.alpha = 1
            }, completion: { (complete:Bool) -> Void in
                
        }) 

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        viewSuper.frame =  CGRect(x: 200, y: -288, width: 288, height: 228)
        viewMG.frame =  CGRect(x: 536, y: -288, width: 288, height: 228)
        
        self.loadAnimationPreShopping()
        
    }
    
    
    func loadAnimationPreShopping(){
    
        if loadImage == nil {
            loadImage = LoadingIconView(frame: CGRect(x: 0, y: 0, width: 116, height: 120))
        }
        loadImage.center = self.view.center
        self.view.addSubview(loadImage)
        
        loadImage.startAnnimating()
        loadImage.backgroundColor = UIColor.clear
        
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
        
        viewSuper.frame =  CGRect(x: 200, y: -288, width: 288, height: 228)
        viewMG.frame =  CGRect(x: 536, y: -288, width: 288, height: 228)
        
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
        collision.addBoundary(withIdentifier: "barrier" as NSCopying, from: CGPoint(x: self.view.frame.origin.x, y: 439), to: CGPoint(x: self.view.frame.origin.x + self.view.frame.width, y: 439))
        collision2.addBoundary(withIdentifier: "barrier" as NSCopying, from: CGPoint(x: self.view.frame.origin.x, y: 439), to: CGPoint(x: self.view.frame.origin.x + self.view.frame.width, y: 439))

        animator.addBehavior(collision)
        animator2.addBehavior(collision2)
        
        
        
    }

    func closeShoppingCart() {
        

        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.frame = CGRect(x: self.view.frame.minX, y: -self.view.frame.height , width: self.view.frame.width,  height: self.view.frame.height)
                }, completion: { (completed:Bool) -> Void in
                    
                    
                   self.viewSuper.frame =  CGRect(x: 200, y: -288, width: 288, height: 228)
                    self.viewMG.frame =  CGRect(x: 536, y: -288, width: 288, height: 228)
                    
                    
//                    self.controllerShowing?.removeFromParentViewController()
//                    self.controllerShowing?.view.removeFromSuperview()
//                    self.controllerShowing = nil
                  self.navigationController?.popToRootViewController(animated: false)
                //self.view.removeFromSuperview()
                  //NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
                 self.delegate.returnToView()
        }) 
    }
    
    
    func openViewMG() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.viewMG.frame = CGRect(x: (self.view.frame.width / 2) - (self.viewMG.frame.width / 2), y: self.viewMG.frame.minY, width: self.viewMG.frame.width, height: self.viewMG.frame.height)
            self.viewSuper.frame = CGRect(x: -self.viewSuper.frame.width, y: self.viewSuper.frame.minY, width: self.viewSuper.frame.width, height: self.viewSuper.frame.height)
            }, completion: { (complete:Bool) -> Void in
                
                let vcResult = self.storyboard?.instantiateViewController(withIdentifier: "shoppingCartMGVC") as! IPAShoppingCartViewController
                vcResult.view.frame = CGRect(x: 0, y: -self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
                vcResult.onClose = {(isClose:Bool) in
                    
                    self.viewMG.alpha = 0
                    self.viewSuper.alpha = 0
                }
                
                self.view.addSubview(vcResult.view)
                self.controllerShowing = vcResult
                self.navigationController?.pushViewController(vcResult, animated: false)
                
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    vcResult.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
                    self.viewMG.frame = CGRect(x: (self.view.frame.width / 2) - (self.viewMG.frame.width / 2), y: self.view.bounds.height, width: self.viewMG.frame.width, height: self.viewMG.frame.height)
                    }, completion: { (complete:Bool) -> Void in
                    
                })
        }) 
    }
    
    func openViewGR() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.viewSuper.frame = CGRect(x: (self.view.frame.width / 2) - (self.viewSuper.frame.width / 2), y: self.viewSuper.frame.minY, width: self.viewSuper.frame.width, height: self.viewSuper.frame.height)
            self.viewMG.frame = CGRect(x: 1024+self.viewMG.frame.width, y: self.viewMG.frame.minY, width: self.viewMG.frame.width, height: self.viewMG.frame.height)
            }, completion: { (complete:Bool) -> Void in
                
                let vcResult = self.storyboard?.instantiateViewController(withIdentifier: "shoppingCartGRVC") as! IPAGRShoppingCartViewController
                vcResult.view.frame = CGRect(x: 0, y: -self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
                
                vcResult.onClose = {(isClose:Bool) in
                    
                    self.viewMG.alpha = 0
                    self.viewSuper.alpha = 0
                }
                
                vcResult.onSuccessOrder = {() in
                    vcResult.removeFromParentViewController()
                    vcResult.view.removeFromSuperview()
                    self.reloadpreShopingCard()
                    self.closeShoppingCart()
                }
                
                self.view.addSubview(vcResult.view)
                self.controllerShowing = vcResult
                self.navigationController?.pushViewController(vcResult, animated: false)
                
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    vcResult.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
                    self.viewSuper.frame = CGRect(x: (self.view.frame.width / 2) - (self.viewSuper.frame.width / 2), y: self.view.bounds.height, width: self.viewSuper.frame.width, height: self.viewSuper.frame.height)
                    }, completion: { (complete:Bool) -> Void in
                        
                })
        }) 
    }
    
    
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        
        self.view.isUserInteractionEnabled = true
        
        self.finishAnimation?()
        
    }
    
    
}
