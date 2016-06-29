//
//  FollowView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 26/10/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import MapKit

class FollowViewController : UIViewController, MKMapViewDelegate, UIAlertViewDelegate {
    
    
    let server : String = "mercury.isol.ws"
    let port : UInt = 61613
    let serverUser : String  = "admin"
    let serverPsw : String  = "Eqb*Q%v9Gp^mGj6Q"
    var idDelivery : String = ""
    var deliveryObject : [String:AnyObject] = [:]

    
    
    
    
    let preferredSize = CGSizeMake(58,58)
    var preferredPoint = CGPointZero
    
    var onOpenFrame : CGRect = CGRectZero
    
    var firstPoint : CGPoint = CGPointZero
    var timmerSleep : NSTimer? = nil
    var viewImage : UIImageView? = nil
    var closeButton : UIButton? = nil
    var headContaimer : UIView? = nil
    var lblTitle : UILabel? = nil
    var backgroundHeader : UIView? = nil
    
    var footerContaimer : UIView? = nil
    var backgroundFooter : UIView? = nil
    var slotDesc : UILabel? = nil
    var address : UILabel? = nil
    var callButton : UIButton? = nil
    
    var mapView : MKMapView? = nil
    
    var closed = true
    var panGesture : UIPanGestureRecognizer? = nil
    var shopperImage : String = ""
    var phoneShoper : String = ""
    let shopperName : String  = ""
    var tapGesture : UITapGestureRecognizer? = nil
    
    var nameShopper : String = ""

    
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.clearColor()
        
        
        self.viewImage = UIImageView(frame: self.view.bounds)
        self.viewImage!.image = UIImage(named: "map_icon")
        self.view.addSubview(viewImage!)
        
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(FollowViewController.move(_:)))
        panGesture?.minimumNumberOfTouches = 1
        panGesture?.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(panGesture!)
        
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(FollowViewController.select as (FollowViewController) -> () -> ()))
        self.view.addGestureRecognizer(tapGesture!)
        
        closeButton = UIButton(frame: CGRectMake(0, 20, 40, 44))
        self.closeButton!.alpha = 0
        self.closeButton!.setImage(UIImage(named: "close_map"), forState: UIControlState.Normal)
        self.closeButton!.contentMode = UIViewContentMode.Center
        self.closeButton!.addTarget(self, action: #selector(FollowViewController.close), forControlEvents: UIControlEvents.TouchUpInside)
       
        //Header
        headContaimer = UIView()
        backgroundHeader = UIView()
        backgroundHeader?.backgroundColor = UIColor(red: 5/255, green: 206/255, blue: 124/255, alpha: 0.9)

        lblTitle = UILabel()
        lblTitle?.text = "Entrega en camino"
        lblTitle?.textColor = UIColor.whiteColor()
        lblTitle?.textAlignment = .Center
        
        headContaimer?.addSubview(backgroundHeader!)
        headContaimer?.addSubview(lblTitle!)
        headContaimer?.addSubview(closeButton!)
        
        self.view.addSubview(headContaimer!)
        
        //Footer
        footerContaimer = UIView()
        backgroundFooter = UIView()
        backgroundFooter?.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        
        slotDesc = UILabel()
        slotDesc?.text = "4:00-6:00 pm"
        slotDesc?.textColor = UIColor(red: 5/255, green: 206/255, blue: 124/255, alpha: 1.0)
        slotDesc?.textAlignment = .Left
        slotDesc?.font = UIFont.systemFontOfSize(20)
        
        address = UILabel()
        address?.text = "Av. Insurgentes Sur #1672 San José Insurgentes Del. Benito Juárez"
        address?.textColor = UIColor.blackColor()
        address?.textAlignment = .Left
        address?.numberOfLines = 2
        address?.font = UIFont.systemFontOfSize(14)
        
        
        
        callButton = UIButton()
        callButton?.setTitle("Llamar a Carlos", forState: UIControlState.Normal)
        callButton?.backgroundColor = UIColor(red: 5/255, green: 206/255, blue: 124/255, alpha: 1.0)
        callButton?.layer.cornerRadius = 16
        callButton?.addTarget(self, action: #selector(FollowViewController.callShopper), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        footerContaimer?.addSubview(backgroundFooter!)
        footerContaimer?.addSubview(slotDesc!)
        footerContaimer?.addSubview(address!)
        footerContaimer?.addSubview(callButton!)
        
        
        self.view.addSubview(footerContaimer!)
        self.headContaimer?.alpha = 0
        self.footerContaimer?.alpha = 0
        
        
        
    }
    
    
    override func viewWillLayoutSubviews() {
        
        if preferredPoint == CGPointZero {
             preferredPoint = CGPointMake(self.view.superview!.frame.maxX - preferredSize.width ,self.view.superview!.frame.maxY - 57 - preferredSize.height)
        }
       
        
        if closed {
            self.view.frame = CGRectMake(preferredPoint.x, preferredPoint.y, preferredSize.width, preferredSize.height)
            self.viewImage!.frame = CGRectMake(0, 0 ,  preferredSize.width, preferredSize.height)
            self.mapView?.frame = CGRectMake(0, 0,0 ,0)
        } else {
//            self.mapView?.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            headContaimer?.frame = CGRectMake(0, 0, self.view.frame.width, 64)
            lblTitle?.frame = CGRectMake(0, 20, self.headContaimer!.frame.width, self.headContaimer!.frame.height - 20)
            footerContaimer?.frame = CGRectMake(0, self.view.frame.height - 140, self.view.frame.width, 140)
            backgroundFooter?.frame =   footerContaimer!.bounds
            backgroundHeader?.frame = headContaimer!.bounds
            slotDesc?.frame = CGRectMake(16, 16, self.view.frame.width - 32, 20)
            address?.frame = CGRectMake(16, slotDesc!.frame.maxY + 8, self.view.frame.width - 32, 36)
            callButton?.frame = CGRectMake((self.view.frame.width / 2) - 95, address!.frame.maxY + 8, 190, 32)
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func move (sender:AnyObject) {
        let panGesture = sender as! UIPanGestureRecognizer
        let senderView = sender.view!
        var translatedPoint = panGesture.translationInView(senderView.superview!)
        
        
        if panGesture.state == UIGestureRecognizerState.Began {
            timmerSleep?.invalidate()
            self.firstPoint = senderView.center
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.alpha = 1
                self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            })
        }
        
        if panGesture.state == UIGestureRecognizerState.Ended {
            
            timmerSleep = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(FollowViewController.sleep), userInfo: nil, repeats: false)
            
            let space : CGFloat = 5.0
            let currentX = self.firstPoint.x + translatedPoint.x
            if currentX > senderView.superview!.center.x {
                translatedPoint = CGPointMake(senderView.superview!.frame.width - ((senderView.frame.width / 2) + space)  , self.firstPoint.y + translatedPoint.y)
            } else {
                translatedPoint = CGPointMake((senderView.frame.width / 2) + space, self.firstPoint.y + translatedPoint.y)
            }
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                senderView.center = translatedPoint
                self.view.transform = CGAffineTransformIdentity
            })
        } else {
            translatedPoint = CGPointMake(self.firstPoint.x + translatedPoint.x, self.firstPoint.y + translatedPoint.y)
            senderView.center = translatedPoint
        }
        
    }
    
    
    func sleep() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.alpha = 0.75
        })
    }
    
    
    func select() {
        self.timmerSleep?.invalidate()
        self.onOpenFrame = self.view.frame
        self.closed = false
        self.panGesture?.enabled = false
        self.tapGesture?.enabled = false
        
        let addressToDelivery = deliveryObject["address"] as! [String:AnyObject]
        address?.text = addressToDelivery["address"] as? String
        
        
        let phoneDeliveryShopper = deliveryObject["shopper"] as! [String:AnyObject]
        shopperImage = phoneDeliveryShopper["picture"] as! String
        
        let personToCall = phoneDeliveryShopper["user"] as! [String:AnyObject]
        let personName = personToCall["person"] as! [String:AnyObject]
        let contactShopper = personName["contact"] as! [[String:AnyObject]]
        let personShoperName = personName["name"] as! String
        let firstContact = contactShopper.first
        callButton?.setTitle("Llamar a \(personShoperName)", forState: UIControlState.Normal)
        let phoneNum = firstContact?["value"]
        if phoneNum != nil {
           self.phoneShoper = phoneNum as! String
        }
        
        self.nameShopper = personShoperName
        
        
        let timeDelivery = deliveryObject["timeSlot"] as! [String:AnyObject]
        if let timeSlot = timeDelivery["timeSlot"] as? String {
            slotDesc?.text = timeSlot
        }
        
        
        
        
        self.view.superview?.bringSubviewToFront(self.view!)
        initMap()
        initUpdatingMap()
        animateOpen()
       
    }
    
    
    func initMap()
    {
        if self.mapView == nil {
        self.mapView = MKMapView(frame: CGRectZero)
        self.mapView?.delegate = self
        
        self.view.addSubview(self.mapView!)
        self.view.sendSubviewToBack(self.mapView!)
        }
    }
  
    
    
    func initUpdatingMap() {
        let client = STOMPClient(host: server, port: port)
        client.connectWithLogin(serverUser, passcode: serverPsw) { (frame:STOMPFrame!, error:NSError!) -> Void in
            if error != nil {
                print("\(error)")
            }
            
            client.subscribeTo("/queue/location.\(self.idDelivery)", messageHandler: { (message:STOMPMessage!) -> Void in
                
                
                do {
                 let parsedObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(message.body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, options: NSJSONReadingOptions.AllowFragments)
                    
                    let latitude = parsedObject!["latitude"] as! NSNumber
                    let longitude = parsedObject!["longitude"] as! NSNumber
                    let idShopper = parsedObject!["idShopper"] as! String
                    self.setCurrentPosition(idShopper, latitud: latitude, longitud: longitude)
                    
                    
                } catch {
                }
            })
            
          
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation.self) {
            return nil
        }
        
        let annotationView = MKAnnotationView()
        
        annotationView.image = UIImage(named: "map_pin")
        let viewShopperFace = UIImageView()
        viewShopperFace.setImageWithURL(NSURL(string: shopperImage))
        viewShopperFace.frame = CGRectMake(10, 7, 24, 24)
        viewShopperFace.layer.cornerRadius = 15
        viewShopperFace.layer.masksToBounds = true
        annotationView.addSubview(viewShopperFace)
        annotationView.canShowCallout = false
        
        return annotationView
        
    }
    
    func setCurrentPosition(idShopper:String,latitud:NSNumber,longitud:NSNumber) {
        let coordinate =  CLLocationCoordinate2D(latitude: latitud.doubleValue , longitude: longitud.doubleValue)
        let shopper = ShopperAnnotation(title: "Un shpper", coordinate: coordinate)
        
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView?.removeAnnotations((self.mapView?.annotations)!)
            self.mapView?.addAnnotation(shopper)
            self.mapView?.showAnnotations([shopper], animated: true)
        })
       
        
    }
    
    func addCurrentAnnotation() {
        
    }
    
    
    func close() {
        self.closed = false
       animateClose()
    }
    
    func callShopper() {
        if let url = NSURL(string: "tel://\(phoneShoper)") {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIAlertView(title: "Llamar a teléfono", message: "\(phoneShoper)", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Llamar").show()
            }
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            let url = NSURL(string: "tel://\(phoneShoper)")
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    
    func animateOpen() {
        self.mapView?.layer.cornerRadius = self.viewImage!.frame.height / 2
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mapView?.layer.cornerRadius = 0
            self.view.frame = self.view.superview!.bounds
            self.viewImage?.center = self.view.center
            self.mapView?.center = self.viewImage!.center
            }) { (complete) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.mapView?.frame  = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
                     self.viewImage?.alpha = 0
                    }, completion: { (complete) -> Void in
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.closeButton?.alpha = 1
                            self.view.alpha = 1
                            self.headContaimer?.alpha = 1
                            self.footerContaimer?.alpha = 1
                            
                            }, completion: { (complete) -> Void in
                                
                        })
                })
        }

    }
    
    func animateClose() {
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.closeButton?.alpha = 0
            self.view.alpha = 1
            self.headContaimer?.alpha = 0
            self.footerContaimer?.alpha = 0
            }) { (complete) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.mapView?.frame  = CGRectMake(0, 0, 0, 0)
                    self.mapView?.center = self.viewImage!.center
                    self.mapView?.layer.cornerRadius = self.viewImage!.frame.height / 2
                    self.viewImage?.alpha = 1
                    }, completion: { (complete) -> Void in
                        UIView.animateWithDuration(0.2, animations: { () -> Void in
                             self.view.frame = self.onOpenFrame
                             self.viewImage?.center = CGPointMake(self.onOpenFrame.width / 2, self.onOpenFrame.height / 2)
                            }, completion: { (complete) -> Void in
                                self.view.frame = self.onOpenFrame
                                self.mapView?.removeFromSuperview()
                                self.mapView = nil
                                self.tapGesture?.enabled = true
                                self.panGesture?.enabled = true
                        })
                })
        }
        
    }
    
    func popView(viewAnimate:UIView,duration:CGFloat) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.values = [1, 1.1, 0.8, 1.1, 1]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunction = getTimingFunction()
        animation.duration = CFTimeInterval(duration)
        animation.additive = true
        animation.beginTime = CACurrentMediaTime() + CFTimeInterval(0)
        viewAnimate.layer.addAnimation(animation, forKey: "pop")
    }
    
    func getTimingFunction() -> CAMediaTimingFunction {
        return CAMediaTimingFunction(controlPoints: 0.5, 1.1+Float(300/3), 1, 1)
    }
    
}

extension String {
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}


