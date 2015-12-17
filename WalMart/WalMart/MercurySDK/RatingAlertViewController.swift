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
    var kpiDelivery : [AnyObject]? = nil
    var kpiDeliveryResponses : [[String:AnyObject]]? = []
    var objectDelivery :[String:AnyObject]? = nil
    
    var allCards: [DraggableView]! = []
    var loadedCards: [DraggableView]! = []
    var cardsLoadedIndex: Int! = 0
    
    var commentView : CommentView? = nil
    
    var onEndRating : (() -> Void)? = nil
    
    var titleView : UILabel!
    var buttonCancel : UIButton!
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
        self.buttonNo?.backgroundColor = UIColor(red: 232/255, green: 51/255, blue: 19/255, alpha: 1)
        self.buttonNo?.setTitle("No", forState: UIControlState.Normal)
        self.buttonNo?.layer.cornerRadius = 18
        self.buttonNo?.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(18)
        self.buttonNo?.addTarget(self, action: "actionNo", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonNo?.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        
        self.buttonYes = UIButton()
        self.buttonYes?.backgroundColor = UIColor(red: 5/255, green: 206/255, blue: 124/255, alpha: 1)
        self.buttonYes?.setTitle("Si", forState: UIControlState.Normal)
        self.buttonYes?.layer.cornerRadius = 18
        self.buttonYes?.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(18)
        self.buttonYes?.addTarget(self, action: "actionYes", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonYes?.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        
        self.buttonNotRecived = UIButton()
        self.buttonNotRecived?.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(18)
        self.buttonNotRecived?.setTitle("¿No recibiste tu orden?", forState: UIControlState.Normal)
        self.buttonNotRecived?.addTarget(self, action: "undeliveriedOrder", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.buttonEnd = UIButton()
        self.buttonEnd?.backgroundColor = UIColor(red: 5/255, green: 206/255, blue: 124/255, alpha: 1)
        self.buttonEnd?.setTitle("Terminar", forState: UIControlState.Normal)
        self.buttonEnd?.layer.cornerRadius = 18
        self.buttonEnd?.addTarget(self, action: "actionEnd", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonEnd?.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(18)
        self.buttonEnd?.alpha = 0
        self.buttonEnd?.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        
        self.buttonDone = UIButton()
        self.buttonDone?.backgroundColor = UIColor(red: 0/255, green: 113/255, blue: 206/255, alpha: 1)
        self.buttonDone?.setTitle("Ok", forState: UIControlState.Normal)
        self.buttonDone?.layer.cornerRadius = 18
        self.buttonDone?.addTarget(self, action: "actionDone", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonDone?.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(18)
        self.buttonDone?.alpha = 0
        self.buttonDone?.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        
        

        self.view.addSubview(self.imageBgBlur!)
        self.view.addSubview(self.bgView!)
        self.view.addSubview(self.containerView!)
        self.view.addSubview(self.buttonNo!)
        self.view.addSubview(self.buttonYes!)
        self.view.addSubview(self.buttonEnd!)
        self.view.addSubview(self.buttonNotRecived!)
        self.view.addSubview(self.buttonDone!)
        
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
            
            draggableView.information.text = "Califica tu Entrega del\n \(strTitle)"
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
            for var i = 0; i < kpiDelivery!.count; i++ {
                let newCard: DraggableView = self.createDraggableViewWithDataAtIndex(i)
                allCards.append(newCard)
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)
                }
            }
            
            for var i = 0; i < loadedCards.count; i++ {
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
            self.containerView?.addSubview(commentView!)
            self.containerView!.insertSubview(self.commentView!, belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
        
        if loadedCards.count == 0 {
            endAndReportDelivery()
        }
       
        
    }
    
    func cardSwipedRight(card: UIView) -> Void {
        loadedCards.removeAtIndex(0)

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
    
   
    
    func actionEnd() {
        let idDelivery = objectDelivery!["idDelivery"] as! String
       PostDelivery.postDeliveryRating(idDelivery,message:commentView!.strMessage, rating: self.kpiDeliveryResponses!) { (resultSuccess) -> Void in
            

            let doneViewImage = DoneView(frame:CGRectMake(0, 888, 288, 239))
            self.containerView?.addSubview(doneViewImage)
            
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.commentView?.alpha = 0
                }, completion: { (completed) -> Void in
                   UIView.animateWithDuration(0.4, animations: { () -> Void in
                        doneViewImage.frame = CGRectMake(0, 40, 288, 239)
                        self.buttonEnd?.alpha = 0
                    
                        self.buttonNotRecived?.alpha = 0
                    }, completion: { (completed) -> Void in
                       doneViewImage.animate()
                        UIView.animateWithDuration(0.1, animations: { () -> Void in
                             self.buttonDone?.alpha = 1
                        })
                   })
            })
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
        
        titleView = UILabel(frame: CGRectMake(0,160,241,46))
        titleView.textAlignment = .Center
        titleView.numberOfLines = 2
        titleView.textColor = UIColor.whiteColor()
        titleView.font = WMFont.fontMyriadProRegularOfSize(22)
        titleView.text = "¿El shopper no te ha entregado tu orden?"
        titleView.center = CGPointMake(self.view.frame.width / 2, titleView.center.y)
        titleView.alpha = 0
        
        buttonCancel = UIButton(frame: CGRectMake(41,256,110,36))
        buttonCancel.setTitle("Cancel", forState: UIControlState.Normal)
        buttonCancel.backgroundColor = UIColor.blackColor()
        buttonCancel.layer.cornerRadius = 18
        buttonCancel.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(18)
        buttonCancel.addTarget(self, action: "cancelrating", forControlEvents: UIControlEvents.TouchUpInside)
        buttonCancel.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        buttonCancel.alpha = 0
            
        buttonUndelivered = UIButton(frame: CGRectMake(buttonCancel.frame.maxX + 20 ,256,110,36))
        buttonUndelivered.setTitle("No", forState: UIControlState.Normal)
        buttonUndelivered.backgroundColor = WMColor.UIColorFromRGB(0xE43313)
        buttonUndelivered.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(18)
        buttonUndelivered.layer.cornerRadius = 18
        buttonUndelivered.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        buttonUndelivered.addTarget(self, action: "undeliveredOrder", forControlEvents: UIControlEvents.TouchUpInside)
        buttonUndelivered.alpha = 0
        
        self.view.addSubview(titleView)
        self.view.addSubview(buttonCancel)
        self.view.addSubview(buttonUndelivered)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.containerView?.frame =  CGRectMake(self.containerView!.frame.minX, -600, self.containerView!.frame.width, self.containerView!.frame.height)
            self.buttonYes?.alpha = 0
            self.buttonNo?.alpha = 0
            self.buttonNotRecived?.alpha = 0
            }) { (complete) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.titleView.alpha = 1
                    self.buttonCancel.alpha = 1
                    self.buttonUndelivered.alpha = 1
                })
        }
    }
    
    
    func cancelrating() {
        isUndeliveriedOrder = false
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.titleView.alpha = 0
            self.buttonCancel.alpha = 0
            self.buttonUndelivered.alpha = 0
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
    
    
    func undeliveredOrder() {
        let idDelivery = objectDelivery!["idDelivery"] as! String
        PostDelivery.cancelRatingDelivery(idDelivery) { () -> Void in
            let alertViewNotDeliveried = UndeliveredView(frame: CGRectMake( 320, 32, 288, 400))
            alertViewNotDeliveried.setEmailForInformation(MercuryService.sharedInstance().username)
            self.view.addSubview(alertViewNotDeliveried)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.titleView.frame = CGRectMake(-320, self.titleView.frame.minY, self.titleView.frame.width, self.titleView.frame.height)
                self.buttonCancel.frame = CGRectMake(-320, self.buttonCancel.frame.minY, self.buttonCancel.frame.width, self.buttonCancel.frame.height)
                self.buttonUndelivered.frame = CGRectMake(-320, self.buttonUndelivered.frame.minY, self.buttonUndelivered.frame.width, self.buttonUndelivered.frame.height)
                alertViewNotDeliveried.frame = CGRectMake( (self.view.frame.width / 2) - 144, 32, 288, 400)
                
                }) { (completed) -> Void in
                    self.buttonDone?.frame = CGRectMake(96, self.view.frame.maxY - 120, 128, 36)
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.buttonDone?.alpha = 1
                    })
            }
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