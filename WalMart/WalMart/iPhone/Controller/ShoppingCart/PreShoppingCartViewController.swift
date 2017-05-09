//
//  PreShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 20/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class PreShoppingCartViewController: IPOBaseController, UIDynamicAnimatorDelegate  {

    let optionsShoppingCart = ["Súper","Tecnología, Hogar y Más"]
    
    var viewLoad: WMLoadingView!
    var viewSuper: PreShoppingCartView!
    var viewMG: PreShoppingCartView!
    var yPointOpen: CGFloat = 0.0
    var delegate: ShoppingCartViewControllerDelegate!
    var finishAnimation: (() -> Void)? = nil
    var gravity: UIGravityBehavior!
    var animator: UIDynamicAnimator!
    var collision: UICollisionBehavior!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PRESHOPPINGCART.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSuper = PreShoppingCartView(frame: CGRect.zero)
        viewSuper.tapAction =  { () -> Void in
            self.yPointOpen = self.viewSuper.imgBackground.convert(self.viewSuper.imgBackground.frame, to: self.view).maxY
            self.performSegue(withIdentifier: "shoppingCartGR", sender: self)
        }

        viewMG = PreShoppingCartView(frame: CGRect.zero)
        viewMG.tapAction =  { () -> Void in
            self.yPointOpen = self.viewMG.imgBackground.convert(self.viewMG.imgBackground.frame, to: self.view).maxY
            self.performSegue(withIdentifier: "shoppingCartMG", sender: self)
        }
        
        view.addSubview(viewSuper)
        view.addSubview(viewMG)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.white
            viewLoad.startAnnimating(false)
            view.addSubview(viewLoad)
        }
        
        UserCurrentSession.sharedInstance.loadShoppingCarts {
            self.updateShoppingCarts()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewSuper.frame =  CGRect(x: 16, y: 16, width: self.view.frame.width - 32, height: (self.view.frame.height - 48 - 44) / 2)
        viewMG.frame = CGRect(x: 16, y: viewSuper.frame.maxY + 16, width: self.view.frame.width - 32, height: (self.view.frame.height - 48 - 44) / 2)
    }
    
    func openShoppingCart() {
        
        UserCurrentSession.sharedInstance.validateUserAssociate(true)
        
        view.isUserInteractionEnabled = false
        navigationController!.view.frame = CGRect(x: self.navigationController!.view.frame.minX,y: -self.navigationController!.view.frame.height , width: self.navigationController!.view.frame.width,  height: self.navigationController!.view.frame.height + 4)
        
        animator = UIDynamicAnimator(referenceView: self.navigationController!.view.superview!)
        gravity = UIGravityBehavior(items: [self.navigationController!.view])
        gravity.magnitude = 5.0
        animator.addBehavior(gravity)
        
        collision = UICollisionBehavior(items: [self.navigationController!.view])
        collision.addBoundary(withIdentifier: "barrier" as NSCopying, from: CGPoint(x: self.view.frame.origin.x, y: self.navigationController!.view.frame.height + 62), to: CGPoint(x: self.view.frame.origin.x + self.view.frame.width, y: self.navigationController!.view.frame.height + 62))
        animator.addBehavior(collision)
        animator.delegate = self
        
    }
    
    func closeShoppingCart () {

        navigationController!.view.frame = CGRect(x: self.navigationController!.view.frame.minX, y: 62 , width: self.navigationController!.view.frame.width,  height: self.navigationController!.view.frame.height)
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.navigationController!.view.frame = CGRect(x: self.navigationController!.view.frame.minX, y: -self.navigationController!.view.frame.height , width: self.navigationController!.view.frame.width,  height: self.navigationController!.view.frame.height)
        }, completion: { (completed:Bool) -> Void in
                self.view.removeFromSuperview()
                self.navigationController!.popToRootViewController(animated: false)
                self.delegate.returnToView()
        }) 
        
    }
    
    func updateShoppingCarts() {
        
        let articlesStr = NSLocalizedString("shoppingcart.articles",comment:"")
        let noArticlesGrStr = NSLocalizedString("shoppingcart.noarticles.gr",comment:"")
        let totArticlesGR = UserCurrentSession.sharedInstance.numberOfArticlesGR()
        let articlesInCart = totArticlesGR > 0 ? "\(totArticlesGR) \(articlesStr)" : noArticlesGrStr
        viewSuper.setValues(WMColor.green,imgBgName:"preCart_super_banner", imgIconName: "preCart_super_icon",title:self.optionsShoppingCart[0],articles:articlesInCart,total:"\(UserCurrentSession.sharedInstance.estimateTotalGR())",totalColor:WMColor.green,empty:totArticlesGR == 0)
        
        let totArticlesMG = UserCurrentSession.sharedInstance.numberOfArticlesMG()
        let noArticlesMgStr = NSLocalizedString("shoppingcart.noarticles.mg",comment:"")
        let articlesInCartMG = totArticlesMG > 0 ? "\(totArticlesMG) \(articlesStr)" : noArticlesMgStr
        viewMG.setValues(WMColor.light_blue,imgBgName:"preCart_mg_banner", imgIconName: "preCart_super_icon",title:self.optionsShoppingCart[1],articles:articlesInCartMG,total:"\(UserCurrentSession.sharedInstance.estimateTotalMG())",totalColor:WMColor.light_blue,empty:totArticlesMG == 0)
        
        viewSuper.tapAction =  { () -> Void in
            if totArticlesGR > 0 {
                self.yPointOpen = self.viewSuper.imgBackground.convert(self.viewSuper.imgBackground.frame, to: self.view).maxY
                self.performSegue(withIdentifier: "shoppingCartGR", sender: self)
            } else {
                NotificationCenter.default.post(name:.clearShoppingCartGR, object: nil)
            }
        }
        
        viewMG.tapAction =  { () -> Void in
            if totArticlesMG > 0 {
                self.yPointOpen = self.viewMG.imgBackground.convert(self.viewMG.imgBackground.frame, to: self.view).maxY
                self.performSegue(withIdentifier: "shoppingCartMG", sender: self)
            } else {
                NotificationCenter.default.post(name: .clearShoppingCartMG, object: nil)
            }
        }
        
        if viewLoad != nil {
            viewLoad.stopAnnimating()
            viewLoad = nil
        }
        
        UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        self.view.isUserInteractionEnabled = true
        self.finishAnimation?()
    }
    
}
