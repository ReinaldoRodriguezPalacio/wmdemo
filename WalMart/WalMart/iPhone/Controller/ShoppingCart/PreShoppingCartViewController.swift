//
//  PreShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 20/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class PreShoppingCartViewController : IPOBaseController,UIDynamicAnimatorDelegate  {

    
    var viewLoad : WMLoadingView!
    
    var viewSuper : PreShoppingCartView!
    var viewMG : PreShoppingCartView!
    
    let optionsShoppingCart = ["Súper","Tecnología, Hogar y Más"]
    
    var yPointOpen : CGFloat = 0.0
    
    
    var delegate : ShoppingCartViewControllerDelegate!
    
    var finishAnimation : (() -> Void)? = nil
    
    var gravity: UIGravityBehavior!
    var animator: UIDynamicAnimator!
    var collision: UICollisionBehavior!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PRESHOPPINGCART.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSuper = PreShoppingCartView(frame: CGRect.zero)
        self.view.addSubview(viewSuper)
        viewSuper.tapAction =  { () -> Void in
            self.yPointOpen = self.viewSuper.imgBackground.convert(self.viewSuper.imgBackground.frame, to: self.view).maxY
            self.performSegue(withIdentifier: "shoppingCartGR", sender: self)
        }

        
        viewMG = PreShoppingCartView(frame: CGRect.zero)
        self.view.addSubview(viewMG)
        viewMG.tapAction =  { () -> Void in
            self.yPointOpen = self.viewMG.imgBackground.convert(self.viewMG.imgBackground.frame, to: self.view).maxY
            self.performSegue(withIdentifier: "shoppingCartMG", sender: self)
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.white
            viewLoad.startAnnimating(false)
            self.view.addSubview(viewLoad)
        }
       // self.navigationController?.view.addSubview(viewLoad)
        
       
    }
    
    
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    
        UserCurrentSession.sharedInstance.loadShoppingCarts({() -> Void in
//            if UserCurrentSession.sharedInstance.isEmptyMG() && !UserCurrentSession.sharedInstance.isEmptyGR() {
//                let vcResult = self.storyboard?.instantiateViewControllerWithIdentifier("shoppingCartGRVC") as GRShoppingCartViewController
//                vcResult.showCloseButton = false
//                self.navigationController?.pushViewController(vcResult, animated: false)
//                
//            }
//            if !UserCurrentSession.sharedInstance.isEmptyMG() && UserCurrentSession.sharedInstance.isEmptyGR() {
//                let vcResult = self.storyboard?.instantiateViewControllerWithIdentifier("shoppingCartMGVC") as ShoppingCartViewController
//                vcResult.showCloseButton = false
//                
//                self.navigationController?.pushViewController(vcResult, animated: false)
//            }
            
//            if UserCurrentSession.sharedInstance.isEmptyMG() && UserCurrentSession.sharedInstance.isEmptyGR() {
//                //Show emptyView
//                self.emptyView!.hidden = false
//                self.emptyView.frame = CGRectMake(0, 0 , self.view.bounds.width, self.view.bounds.height)
//            } else {
            let articlesStr = NSLocalizedString("shoppingcart.articles",comment:"")
            //let noArticlesStr = NSLocalizedString("shoppingcart.noarticles",comment:"")
            let noArticlesGrStr = NSLocalizedString("shoppingcart.noarticles.gr",comment:"")
            let totArticlesGR = UserCurrentSession.sharedInstance.numberOfArticlesGR()
            let articlesInCart = totArticlesGR > 0 ? "\(totArticlesGR) \(articlesStr)" : noArticlesGrStr
            self.viewSuper.setValues(WMColor.green,imgBgName:"preCart_super_banner", imgIconName: "preCart_super_icon",title:self.optionsShoppingCart[0],articles:articlesInCart,total:"\(UserCurrentSession.sharedInstance.estimateTotalGR())",totalColor:WMColor.green,empty:totArticlesGR == 0)
            
            let totArticlesMG = UserCurrentSession.sharedInstance.numberOfArticlesMG()
            let noArticlesMgStr = NSLocalizedString("shoppingcart.noarticles.mg",comment:"")
            let articlesInCartMG = totArticlesMG > 0 ? "\(totArticlesMG) \(articlesStr)" : noArticlesMgStr
            self.viewMG.setValues(WMColor.light_blue,imgBgName:"preCart_mg_banner", imgIconName: "preCart_super_icon",title:self.optionsShoppingCart[1],articles:articlesInCartMG,total:"\(UserCurrentSession.sharedInstance.estimateTotalMG())",totalColor:WMColor.light_blue,empty:totArticlesMG == 0)
//            }
            
            self.viewSuper.tapAction =  { () -> Void in
                if totArticlesGR > 0 {
                    //Event
                    //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRE_SHOPPING_CART.rawValue, action: WMGAIUtils.ACTION_GR_OPEN_SHOPPING_CART.rawValue, label: "")
                    
                    self.yPointOpen = self.viewSuper.imgBackground.convert(self.viewSuper.imgBackground.frame, to: self.view).maxY
                    self.performSegue(withIdentifier: "shoppingCartGR", sender: self)
                } else {
                    //Event
                    //BaseController.sendAnalytics(WMGAIUtils.GR_CATEGORY_EMPTY_SHOPPING_CART.rawValue, action: WMGAIUtils.ACTION_OPEN_SHOPPING_CART_SUPER.rawValue, label: "")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearShoppingCartGR.rawValue), object: nil)
                }
            }
            
            
            self.viewMG.tapAction =  { () -> Void in
                if totArticlesMG > 0 {
                    //Event
                    ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRE_SHOPPING_CART.rawValue, action: WMGAIUtils.ACTION_MG_OPEN_SHOPPING_CART.rawValue, label: "")
                    
                    self.yPointOpen = self.viewMG.imgBackground.convert(self.viewMG.imgBackground.frame, to: self.view).maxY
                    self.performSegue(withIdentifier: "shoppingCartMG", sender: self)
                } else {
                    //Event
                    ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_EMPTY_SHOPPING_CART.rawValue, action: WMGAIUtils.ACTION_OPEN_SHOPPING_CART_MG.rawValue, label: "")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearShoppingCartMG.rawValue), object: nil)
                }
            }
            
            UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
            if self.viewLoad != nil {
                self.viewLoad.stopAnnimating()
                self.viewLoad = nil
            }
        })
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewSuper.frame =  CGRect(x: 16, y: 16, width: self.view.frame.width - 32, height: (self.view.frame.height - 48 - 44) / 2)
        viewMG.frame = CGRect(x: 16, y: viewSuper.frame.maxY + 16, width: self.view.frame.width - 32, height: (self.view.frame.height - 48 - 44) / 2)
    }
    

    //Open from home
    func openShoppingCart(){
        
        UserCurrentSession.sharedInstance.validateUserAssociate(true)
        
        self.view.isUserInteractionEnabled = false
        
        self.navigationController!.view.frame = CGRect(x: self.navigationController!.view.frame.minX,y: -self.navigationController!.view.frame.height , width: self.navigationController!.view.frame.width,  height: self.navigationController!.view.frame.height + 4)
        
        animator = UIDynamicAnimator(referenceView: self.navigationController!.view.superview!)
        gravity = UIGravityBehavior(items: [self.navigationController!.view])
        gravity.magnitude = 2.0
        animator.addBehavior(gravity)
        
        collision = UICollisionBehavior(items: [self.navigationController!.view])
        //collision.translatesReferenceBoundsIntoBoundary = true
        collision.addBoundary(withIdentifier: "barrier" as NSCopying, from: CGPoint(x: self.view.frame.origin.x, y: self.navigationController!.view.frame.height + 62), to: CGPoint(x: self.view.frame.origin.x + self.view.frame.width, y: self.navigationController!.view.frame.height + 62))
        animator.addBehavior(collision)
        
        animator.delegate = self
        
        /*collision = UICollisionBehavior(items: [self.navigationController!.view])
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)*/

        
        /*self.navigationController!.view.frame = CGRectMake(self.navigationController!.view.frame.minX,-self.navigationController!.view.frame.height , self.navigationController!.view.frame.width,  self.navigationController!.view.frame.height)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.navigationController!.view.frame = CGRectMake(self.navigationController!.view.frame.minX,62 , self.navigationController!.view.frame.width,  self.navigationController!.view.frame.height)
            }) { (completed:Bool) -> Void in
        }*/
    }
    
    func closeShoppingCart () {
        //var originalHeight : CGFloat = 0.0
        
        //Event
        self.navigationController!.view.frame = CGRect(x: self.navigationController!.view.frame.minX,y: 62 , width: self.navigationController!.view.frame.width,  height: self.navigationController!.view.frame.height)
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            //originalHeight = self.view.frame.height
            self.navigationController!.view.frame = CGRect(x: self.navigationController!.view.frame.minX, y: -self.navigationController!.view.frame.height , width: self.navigationController!.view.frame.width,  height: self.navigationController!.view.frame.height)
            //self.view.frame = CGRectMake(self.view.frame.minX, self.view.frame.minY,self.view.frame.width, 0)
            }, completion: { (completed:Bool) -> Void in
                self.view.removeFromSuperview()
                self.navigationController!.popToRootViewController(animated: false)
                //self.view.frame = CGRectMake(self.view.frame.minX, self.view.frame.minY,self.view.frame.width,originalHeight)
                self.delegate.returnToView()

        }) 
        
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        
        self.view.isUserInteractionEnabled = true
        
        self.finishAnimation?()
        
    }
    
    
    
}
