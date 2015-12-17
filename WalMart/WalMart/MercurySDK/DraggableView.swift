//
//  DraggableView.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

let ACTION_MARGIN: Float = 120      //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
let SCALE_STRENGTH: Float = 4       //%%% how quickly the card shrinks. Higher = slower shrinking
let SCALE_MAX:Float = 0.93          //%%% upper bar for how much the card shrinks. Higher = shrinks less
let ROTATION_MAX: Float = 1         //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
let ROTATION_STRENGTH: Float = 320  //%%% strength of rotation. Higher = weaker rotation
let ROTATION_ANGLE: Float = 3.14/8  //%%% Higher = stronger rotation angle

protocol DraggableViewDelegate {
    func cardSwipedLeft(card: UIView) -> Void
    func cardSwipedRight(card: UIView) -> Void
}

class DraggableView: UIView {
    var delegate: DraggableViewDelegate!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var originPoint: CGPoint!
    var overlayView: OverlayView!
    var information: UILabel!
    var kpiQuestion: UILabel!
    
    var imageBackground: UIImageView!
    var shopperDesc: UILabel!
    var shopperPhoto: UIImageView!
    var xFromCenter: Float!
    var yFromCenter: Float!
    var cardInfo: AnyObject? = nil

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()

        self.backgroundColor = UIColor.whiteColor()
        
        imageBackground = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        self.addSubview(imageBackground)
        
        information = UILabel(frame: CGRectMake(16, 43, self.frame.size.width - 32, 36))
        information.textAlignment = NSTextAlignment.Center
        information.textColor = WMColor.UIColorFromRGB(0x0071CE)
        information.font = WMFont.fontMyriadProLightOfSize(18)
        information.numberOfLines = 2
        
        kpiQuestion = UILabel(frame: CGRectMake(16, 264, self.frame.size.width - 32, 75))
        kpiQuestion.textAlignment = NSTextAlignment.Center
        kpiQuestion.textColor = WMColor.UIColorFromRGB(0x0071CE)
        kpiQuestion.font = WMFont.fontMyriadProLightOfSize(25)
        kpiQuestion.numberOfLines = 3

        

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "beingDragged:")
        self.addGestureRecognizer(panGestureRecognizer)
        self.addSubview(information)
        self.addSubview(kpiQuestion)

        overlayView = OverlayView(frame: CGRectMake(self.frame.size.width/2 - 48, 110, 96, 96))
        overlayView.alpha = 0
        self.addSubview(overlayView)

        xFromCenter = 0
        yFromCenter = 0
    }

    func setupView() -> Void {
        self.layer.cornerRadius = 8;
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowOffset = CGSizeMake(1, 1);
    }

    func beingDragged(gestureRecognizer: UIPanGestureRecognizer) -> Void {
        xFromCenter = Float(gestureRecognizer.translationInView(self).x)
        yFromCenter = Float(gestureRecognizer.translationInView(self).y)
        
        switch gestureRecognizer.state {
        case UIGestureRecognizerState.Began:
            
            self.bringSubviewToFront(overlayView)
            
            self.originPoint = self.center
        case UIGestureRecognizerState.Changed:
            let rotationStrength: Float = min(xFromCenter/ROTATION_STRENGTH, ROTATION_MAX)
            let rotationAngle = ROTATION_ANGLE * rotationStrength
            let scale = max(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX)

            self.center = CGPointMake(self.originPoint.x + CGFloat(xFromCenter), self.originPoint.y + CGFloat(yFromCenter))

            let transform = CGAffineTransformMakeRotation(CGFloat(rotationAngle))
            let scaleTransform = CGAffineTransformScale(transform, CGFloat(scale), CGFloat(scale))
            self.transform = scaleTransform
            self.updateOverlay(CGFloat(xFromCenter))
        case UIGestureRecognizerState.Ended:
            self.afterSwipeAction()
        case UIGestureRecognizerState.Possible:
            fallthrough
        case UIGestureRecognizerState.Cancelled:
            fallthrough
        case UIGestureRecognizerState.Failed:
            fallthrough
        default:
            break
        }
    }
    
    func dragEffect(xFromCenter:Float,yFromCenter:Float) {
        self.xFromCenter = xFromCenter
        let rotationStrength: Float = min(xFromCenter/ROTATION_STRENGTH, ROTATION_MAX)
        let rotationAngle = ROTATION_ANGLE * rotationStrength
        let scale = max(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX)
        
        self.center = CGPointMake(self.originPoint.x + CGFloat(xFromCenter), self.originPoint.y + CGFloat(yFromCenter))
        
        let transform = CGAffineTransformMakeRotation(CGFloat(rotationAngle))
        let scaleTransform = CGAffineTransformScale(transform, CGFloat(scale), CGFloat(scale))
        self.transform = scaleTransform
        self.updateOverlay(CGFloat(xFromCenter))
    }
    

    func updateOverlay(distance: CGFloat) -> Void {
        if distance > 0 {
            overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeRight)
        } else {
            overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeLeft)
        }
        overlayView.alpha = CGFloat(min(fabsf(Float(distance))/100, 1))
    }

    func afterSwipeAction() -> Void {
        let floatXFromCenter = Float(xFromCenter)
        if floatXFromCenter > ACTION_MARGIN {
            self.rightAction()
        } else if floatXFromCenter < -ACTION_MARGIN {
            self.leftAction()
        } else {
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.center = self.originPoint
                self.transform = CGAffineTransformMakeRotation(0)
                self.overlayView.alpha = 0
            })
        }
    }
    
    func rightAction() -> Void {
        let finishPoint: CGPoint = CGPointMake(500, 2 * CGFloat(yFromCenter) + self.originPoint.y)
        UIView.animateWithDuration(0.3,
            animations: {
                self.center = finishPoint
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedRight(self)
    }

    func leftAction() -> Void {
        let finishPoint: CGPoint = CGPointMake(-500, 2 * CGFloat(yFromCenter) + self.originPoint.y)
        UIView.animateWithDuration(0.3,
            animations: {
                self.center = finishPoint
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedLeft(self)
    }

    func rightClickAction() -> Void {
        let finishPoint = CGPointMake(600, self.center.y)
        UIView.animateWithDuration(0.3,
            animations: {
                self.center = finishPoint
                self.transform = CGAffineTransformMakeRotation(1)
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedRight(self)
    }

    func leftClickAction() -> Void {
        let finishPoint: CGPoint = CGPointMake(-600, self.center.y)
        UIView.animateWithDuration(0.3,
            animations: {
                self.center = finishPoint
                self.transform = CGAffineTransformMakeRotation(1)
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        delegate.cardSwipedLeft(self)
    }
    
    func setShopperPhoto(shopperName:String,shopperImageUrl:String) {
        
        shopperPhoto = UIImageView(frame: CGRectMake(104, 132, 80, 80))
        shopperPhoto.setImageWithURL(NSURL(string:shopperImageUrl)!)
        shopperPhoto.layer.masksToBounds = true
        shopperPhoto.layer.cornerRadius = 40
        shopperPhoto.clipsToBounds = true
        self.addSubview(shopperPhoto)
        
        
        kpiQuestion.text = "El servicio de \(shopperName) fue impecable"
    }
    
}