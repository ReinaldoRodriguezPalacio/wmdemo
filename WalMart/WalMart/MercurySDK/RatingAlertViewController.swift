//
//  RatingAlertViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/7/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


public class RatingAlertViewController : UIViewController ,DraggableViewDelegate {
    
    let MAX_BUFFER_SIZE = 2
    
    var bgView : UIView? = nil
    var imageBgBlur : UIImageView? = nil
    var imageBlur : UIImage? = nil
    var containerView : UIView? = nil
    var imageBgViewContainer : UIImageView? = nil
    var buttonYes : UIButton? = nil
    var buttonNo : UIButton? = nil
    var buttonNotRecived : UIButton? = nil
    var buttonEnd : UIButton? = nil
    var buttonDone : UIButton? = nil
    var buttonCancel : UIButton? = nil
    var kpiDelivery : [AnyObject]? = nil
    var kpiDeliveryResponses : [[String:AnyObject]]? = []
    var objectDelivery :[String:AnyObject]? = nil
    var alertViewNotDeliveried : UndeliveredView!
    
    var allCards: [DraggableView]! = []
    var loadedCards: [DraggableView]! = []
    var cardsLoadedIndex: Int! = 0
    
    var commentView : CommentView? = nil
    
    var onEndRating : (() -> Void)? = nil
    
    var titleView : UILabel!
    var buttonCancelNotDev : UIButton!
    var buttonOkNotDev : UIButton!
    var buttonUndelivered : UIButton!
    
    var isUndeliveriedOrder : Bool = false
    
    public override func viewDidLoad() {
        
        
        
        
        self.bgView = UIView()
        self.bgView?.backgroundColor = UIColor.blackColor()
        self.bgView?.alpha = 0.7
        
        imageBgBlur = UIImageView()
        imageBgBlur?.image = imageBlur
        
        
        self.containerView = UIView()
        self.containerView?.backgroundColor = UIColor.clearColor()
        
        self.imageBgViewContainer = UIImageView(image:UIImage(named: ""))
        
        self.containerView?.addSubview(self.imageBgViewContainer!)
        
        self.buttonNo = UIButton()
        self.buttonNo?.backgroundColor = UIColor(red: 0/255, green: 113/255, blue: 206/255, alpha: 1)
        self.buttonNo?.setTitle("No", forState: UIControlState.Normal)
        self.buttonNo?.layer.cornerRadius = 18
        self.buttonNo?.titleLabel!.font = MercuryFont.fontSFUIRegularOfSize(18)
        self.buttonNo?.addTarget(self, action: "actionNo", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.buttonYes = UIButton()
        self.buttonYes?.backgroundColor = UIColor(red: 0/255, green: 113/255, blue: 206/255, alpha: 1)
        self.buttonYes?.setTitle("Si", forState: UIControlState.Normal)
        self.buttonYes?.layer.cornerRadius = 18
        self.buttonYes?.titleLabel!.font = MercuryFont.fontSFUIRegularOfSize(18)
        self.buttonYes?.addTarget(self, action: "actionYes", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.buttonNotRecived = UIButton()
        self.buttonNotRecived?.titleLabel!.font = MercuryFont.fontSFUIRegularOfSize(18)
        self.buttonNotRecived?.setTitle("¿No recibiste tu orden?", forState: UIControlState.Normal)
        self.buttonNotRecived?.addTarget(self, action: "undeliveriedOrder", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.buttonEnd = UIButton()
        self.buttonEnd?.backgroundColor = UIColor(red: 119/255, green: 188/255, blue: 31/255, alpha: 1)
        self.buttonEnd?.setTitle("Terminar", forState: UIControlState.Normal)
        self.buttonEnd?.layer.cornerRadius = 18
        self.buttonEnd?.addTarget(self, action: "actionEnd", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonEnd?.titleLabel!.font = MercuryFont.fontSFUIRegularOfSize(18)
        self.buttonEnd?.alpha = 0
        
        self.buttonDone = UIButton()
        self.buttonDone?.backgroundColor = UIColor(red: 0/255, green: 113/255, blue: 206/255, alpha: 1)
        self.buttonDone?.setTitle("Ok", forState: UIControlState.Normal)
        self.buttonDone?.layer.cornerRadius = 18
        self.buttonDone?.addTarget(self, action: "actionDone", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonDone?.titleLabel!.font = MercuryFont.fontSFUIRegularOfSize(18)
        self.buttonDone?.alpha = 0
        
        
        self.buttonCancelNotDev = UIButton()
        self.buttonCancelNotDev?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        self.buttonCancelNotDev?.setTitle("Cancelar", forState: UIControlState.Normal)
        self.buttonCancelNotDev?.layer.cornerRadius = 18
        self.buttonCancelNotDev?.addTarget(self, action: "actionCancelNotDeliveried", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonCancelNotDev?.titleLabel!.font = MercuryFont.fontSFUIRegularOfSize(18)
        self.buttonCancelNotDev?.alpha = 0
        
        
        self.buttonOkNotDev = UIButton()
        self.buttonOkNotDev?.backgroundColor = UIColor(red: 0/255, green: 113/255, blue: 206/255, alpha: 1)
        self.buttonOkNotDev?.setTitle("Reportar", forState: UIControlState.Normal)
        self.buttonOkNotDev?.layer.cornerRadius = 18
        self.buttonOkNotDev?.addTarget(self, action: "actionReportNotDeliveried", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonOkNotDev?.titleLabel!.font = MercuryFont.fontSFUIRegularOfSize(18)
        self.buttonOkNotDev?.alpha = 0
        
        
        
        self.view.addSubview(self.imageBgBlur!)
        self.view.addSubview(self.bgView!)
        self.view.addSubview(self.containerView!)
        self.view.addSubview(self.buttonNo!)
        self.view.addSubview(self.buttonYes!)
        self.view.addSubview(self.buttonEnd!)
        self.view.addSubview(self.buttonNotRecived!)
        self.view.addSubview(self.buttonDone!)
        self.view.addSubview(self.buttonCancelNotDev!)
        self.view.addSubview(self.buttonOkNotDev!)
        
        loadCards()
        
        
    }
    
    
    
    public override func viewWillLayoutSubviews() {
        self.imageBgBlur?.frame = self.view.bounds
        if !isUndeliveriedOrder {
            self.bgView?.frame = self.view.bounds
            self.containerView?.frame = CGRectMake( (self.view.frame.width / 2) - 144, 32, 288, 400)
            self.imageBgViewContainer?.frame = self.containerView!.bounds
            
            self.buttonNo?.frame = CGRectMake((self.view.frame.width / 2) - 144 + 37, self.view.frame.maxY - 120, 90, 36)
            self.buttonYes?.frame = CGRectMake(self.buttonNo!.frame.maxX + 36, self.view.frame.maxY - 120, 90, 36)
            self.buttonEnd?.frame = CGRectMake((self.view.frame.width / 2) - 144 + 64, self.view.frame.maxY - 120, 160, 36)
            self.buttonNotRecived?.frame = CGRectMake(0, self.view.frame.maxY - 40, self.view.frame.width, 22)
            self.buttonDone?.frame = CGRectMake((self.view.frame.width / 2) - 144 + 64, self.view.frame.maxY - 220, 160, 36)
            
            
            self.buttonCancelNotDev?.frame = CGRectMake((self.view.frame.width / 2) - 144 , self.view.frame.maxY - 120, 138, 36)
            self.buttonOkNotDev?.frame = CGRectMake(self.buttonCancelNotDev!.frame.maxX + 12, self.view.frame.maxY - 120, 138, 36)
            
        }
        
        
    }
    
    
    func createDraggableViewWithDataAtIndex(index: NSInteger) -> DraggableView {
        let draggableView = DraggableView(frame:CGRectMake(0, 0, 288, 384))
        let ixCard = self.kpiDelivery![index]
        draggableView.cardInfo = ixCard
        if let iconViewUrl = ixCard["icon"] as? String {
            draggableView.imageBackground.setImageWithURL(NSURL(string: iconViewUrl)!, placeholderImage: nil, success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                draggableView.imageBackground.image = image
                }, failure: { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
                    print(error)
            })
        }
        if let date = objectDelivery!["orderDate"] as? String {
            let dateFormat = "dd/MM/yyyy"
            let formatter = NSDateFormatter()
            formatter.dateFormat = dateFormat
            let dateOrder = formatter.dateFromString(date)
            
            formatter.dateFormat = "EEEE d 'de' MMMM"
            let strTitle = formatter.stringFromDate(dateOrder!)
            
            draggableView.information.text = "Califica tu Entrega\ndel \(strTitle)"
        }
        if let descKPI = ixCard["rateDescription"] as? String {
            draggableView.kpiQuestion.text = descKPI
        }
        
        if let descKPI = ixCard["isPhoto"] as? Bool {
            if descKPI {
                let shopperPhoto = objectDelivery!["pictureShopper"] as? String
                let nameShopper = objectDelivery!["nameShopper"] as? String
                draggableView.setShopperPhoto(nameShopper!, shopperImageUrl: shopperPhoto!)
            }
        }
        draggableView.delegate = self
        return draggableView
    }
    
    func loadCards() -> Void {
        if kpiDelivery!.count > 0 {
            let numLoadedCardsCap = kpiDelivery!.count > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : kpiDelivery!.count
            for i in 0 ..< kpiDelivery!.count {
                let newCard: DraggableView = self.createDraggableViewWithDataAtIndex(i)
                allCards.append(newCard)
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)
                }
            }
            
            for i in 0 ..< loadedCards.count {
                if i > 0 {
                    self.containerView!.insertSubview(loadedCards[i], belowSubview: loadedCards[i - 1])
                } else {
                    self.containerView!.addSubview(loadedCards[i])
                }
                cardsLoadedIndex = cardsLoadedIndex + 1
            }
        }
    }
    
    
    //Draggable View Delegate
    
    func cardSwipedLeft(card: UIView) -> Void {
        loadedCards.removeAtIndex(0)
        
        self.buttonNotRecived?.alpha = 0
        
        if card is DraggableView {
            let draggCard = card as! DraggableView
            let userInfo = draggCard.cardInfo!
            let idQuestion  = userInfo["idQuestion"] as! Int
            let descQuestion  = userInfo["rateDescription"] as! String
            kpiDeliveryResponses?.append(["idQuestion":idQuestion,"rate":0.0,"rateDescription":descQuestion])
        }
        
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.containerView!.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
        
        if loadedCards.count == 1 {
            commentView = CommentView(frame:CGRectMake(0, 0, 288, 384))
            commentView?.sendMessageAction = {(message) -> Void in self.actionEnd(false)}
            self.containerView?.addSubview(commentView!)
            self.containerView!.insertSubview(self.commentView!, belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
        
        if loadedCards.count == 0 {
            endAndReportDelivery()
        }
        
        
    }
    
    func cardSwipedRight(card: UIView) -> Void {
        loadedCards.removeAtIndex(0)
        
        self.buttonNotRecived?.alpha = 0
        
        if card is DraggableView {
            let draggCard = card as! DraggableView
            let userInfo = draggCard.cardInfo!
            let idQuestion  = userInfo["idQuestion"] as! Int
            let descQuestion  = userInfo["rateDescription"] as! String
            kpiDeliveryResponses?.append(["idQuestion":idQuestion,"rate":0.0,"rateDescription":descQuestion])
        }
        
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.containerView!.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
        
        if loadedCards.count == 1 {
            commentView = CommentView(frame:CGRectMake(0, 0, 288, 384))
            commentView?.sendMessageAction = {(message) -> Void in self.actionEnd(false)}
            self.containerView?.addSubview(commentView!)
            self.containerView!.insertSubview(self.commentView!, belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
        
        if loadedCards.count == 0 {
            endAndReportDelivery()
        }
    }
    
    func actionNo() {
        if loadedCards.count > 0 {
            let currentView = loadedCards[0]
            currentView.originPoint = currentView.center
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                currentView.dragEffect(-160, yFromCenter: 0)
            })
            currentView.afterSwipeAction()
        }
    }
    
    func actionYes() {
        if loadedCards.count > 0 {
            let currentView = loadedCards[0]
            currentView.originPoint = currentView.center
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                currentView.dragEffect(160, yFromCenter: 0)
            })
            currentView.afterSwipeAction()
        }
    }
    
    
    func endAndReportDelivery() {
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.buttonNo?.alpha = 0
            self.buttonYes?.alpha = 0
            self.buttonEnd?.alpha = 1
            }) { (complete) -> Void in
                
        }
    }
    
    func actionEnd(){
        actionEnd(true)
    }
    
    func actionEnd(closeView:Bool) {
        let idDelivery = objectDelivery!["idDelivery"] as! String
        PostDelivery.postDeliveryRating(idDelivery,message:commentView!.strMessage, rating: self.kpiDeliveryResponses!) { (resultSuccess) -> Void in
            if closeView {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.view.alpha = 0
                    }, completion: { (complete) -> Void in
                        self.view.removeFromSuperview()
                        self.removeFromParentViewController()
                        self.onEndRating?()
                        MercuryService.sharedInstance().startMercuryService()
                })
            } else {
                self.commentView?.actionCancel()
                self.commentView?.thanksUser()
            }
        }
    }
    
    
    func actionDone() {
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.view.alpha = 0
            }, completion: { (complete:Bool) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
                self.onEndRating?()
                MercuryService.sharedInstance().startMercuryService()
        })
    }
    
    func undeliveriedOrder() {
        
        isUndeliveriedOrder = true
        
        alertViewNotDeliveried = UndeliveredView(frame: CGRectMake( (self.view.frame.width / 2) - 144, 32, 288, 400))
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.containerView?.frame =  CGRectMake(self.containerView!.frame.minX, -600, self.containerView!.frame.width, self.containerView!.frame.height)
            self.buttonYes?.alpha = 0
            self.buttonNo?.alpha = 0
            self.buttonNotRecived?.alpha = 0
            }) { (complete) -> Void in
                self.alertViewNotDeliveried.alpha = 0
                self.alertViewNotDeliveried.setEmailForInformation(MercuryService.sharedInstance().username)
                self.view.addSubview(self.alertViewNotDeliveried)
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.alertViewNotDeliveried.alpha = 1
                    self.buttonCancelNotDev.alpha = 1
                    self.buttonOkNotDev.alpha = 1
                })
        }
    }
    
    
    func actionCancelNotDeliveried() {
        isUndeliveriedOrder = false
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.buttonCancelNotDev?.alpha = 0
            self.buttonOkNotDev.alpha = 0
            self.alertViewNotDeliveried.alpha = 0
            }) { (complete) -> Void in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.containerView?.frame =  CGRectMake(self.containerView!.frame.minX, 32, self.containerView!.frame.width, self.containerView!.frame.height)
                    self.buttonYes?.alpha = 1
                    self.buttonNo?.alpha = 1
                    self.buttonNotRecived?.alpha = 1
                    }) { (complete) -> Void in
                        
                }
        }
        
        
    }
    
    
    func actionReportNotDeliveried() {
        let idDelivery = objectDelivery!["idDelivery"] as! String
        PostDelivery.cancelRatingDelivery(idDelivery) { () -> Void in
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.alpha = 0
                }, completion: { (complete) -> Void in
                    self.removeFromParentViewController()
                    self.view.removeFromSuperview()
                    self.onEndRating?()
                    MercuryService.sharedInstance().startMercuryService()
            })
        }
    }
    
    func assignBluredImage(fromView:UIView) {
        imageBlur = createBlurImage(fromView, frame: fromView.bounds)
    }
    
    func createBlurImage(viewBg:UIView, frame:CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0);
        viewBg.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        let blurredImage = cloneImage.applyLightEffectDelivery()
        return blurredImage
    }
    
    
}