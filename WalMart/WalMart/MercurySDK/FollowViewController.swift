//
//  FollowView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 26/10/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import MapKit

class FollowViewController : UIViewController, MKMapViewDelegate {
    
    
    let server : String = "mercury.isol.ws"
    let port : UInt = 61613
    let serverUser : String  = "admin"
    let serverPsw : String  = "password"
    var idDelivery : String = ""
    var deliveryObject : [String:AnyObject] = [:]
    
    
    
    let preferredSize = CGSizeMake(58,58)
    let preferredPoint = CGPointMake(200,300)
    
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
    override func viewDidLoad() {
        
        
        self.view.backgroundColor = UIColor.clearColor()
        
        
        self.viewImage = UIImageView(frame: self.view.bounds)
        self.viewImage!.image = UIImage(named: "map_icon")
        self.view.addSubview(viewImage!)
        
        
        panGesture = UIPanGestureRecognizer(target: self, action: "move:")
        panGesture?.minimumNumberOfTouches = 1
        panGesture?.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(panGesture!)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "select")
        self.view.addGestureRecognizer(tapGesture)
        
        closeButton = UIButton(frame: CGRectMake(0, 20, 40, 44))
        self.closeButton!.alpha = 0
        self.closeButton!.setImage(UIImage(named: "close_map"), forState: UIControlState.Normal)
        self.closeButton!.contentMode = UIViewContentMode.Center
        self.closeButton!.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
       
        //Header
        headContaimer = UIView()
        backgroundHeader = UIView()
        backgroundHeader?.backgroundColor = UIColor(red: 116/255, green: 205/255, blue: 128/255, alpha: 0.9)

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
        slotDesc?.textColor = UIColor(red: 116/255, green: 205/255, blue: 128/255, alpha: 1.0)
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
        callButton?.backgroundColor = UIColor(red: 116/255, green: 205/255, blue: 128/255, alpha: 1.0)
        callButton?.layer.cornerRadius = 16
        
        
        footerContaimer?.addSubview(backgroundFooter!)
        footerContaimer?.addSubview(slotDesc!)
        footerContaimer?.addSubview(address!)
        footerContaimer?.addSubview(callButton!)
        
        
        self.view.addSubview(footerContaimer!)
        self.headContaimer?.alpha = 0
        self.footerContaimer?.alpha = 0
    }
    
    func setup() {
        
        
    }
    
    
    override func viewWillLayoutSubviews() {
        if closed {
            self.view.frame = CGRectMake(preferredPoint.x, preferredPoint.y, preferredSize.width, preferredSize.height)
            self.viewImage!.frame = CGRectMake(0, 0 ,  preferredSize.width, preferredSize.height)
            self.mapView?.frame = CGRectMake(0, 0,0 ,0)
        } else {
            self.mapView?.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            headContaimer?.frame = CGRectMake(0, 0, self.view.frame.width, 64)
            lblTitle?.frame = CGRectMake(0, 20, self.headContaimer!.frame.width, self.headContaimer!.frame.height - 20)
            footerContaimer?.frame = CGRectMake(0, self.view.frame.height - 140, self.view.frame.width, 140)
            backgroundFooter?.frame =   footerContaimer!.bounds
            backgroundHeader?.frame = headContaimer!.bounds
            slotDesc?.frame = CGRectMake(16, 16, self.view.frame.width - 32, 20)
            address?.frame = CGRectMake(16, slotDesc!.frame.maxY + 8, self.view.frame.width - 32, 36)
            callButton?.frame = CGRectMake((self.view.frame.width / 2) - 80, address!.frame.maxY + 8, 160, 32)
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func move (sender:AnyObject) {
        let panGesture = sender as! UIPanGestureRecognizer
        let senderView = sender.view!
        var translatedPoint = panGesture.translationInView(senderView!.superview!)
        
        
        if panGesture.state == UIGestureRecognizerState.Began {
            timmerSleep?.invalidate()
            self.firstPoint = senderView!.center
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.alpha = 1
                self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            })
        }
        
        if panGesture.state == UIGestureRecognizerState.Ended {
            
            timmerSleep = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "sleep", userInfo: nil, repeats: false)
            
            let space : CGFloat = 5.0
            let currentX = self.firstPoint.x + translatedPoint.x
            if currentX > senderView!.superview!.center.x {
                translatedPoint = CGPointMake(senderView!.superview!.frame.width - ((senderView!.frame.width / 2) + space)  , self.firstPoint.y + translatedPoint.y)
            } else {
                translatedPoint = CGPointMake((senderView!.frame.width / 2) + space, self.firstPoint.y + translatedPoint.y)
            }
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                senderView?.center = translatedPoint
                self.view.transform = CGAffineTransformIdentity
            })
        } else {
            translatedPoint = CGPointMake(self.firstPoint.x + translatedPoint.x, self.firstPoint.y + translatedPoint.y)
            senderView?.center = translatedPoint
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
        
        let addressToDelivery = deliveryObject["address"] as! [String:AnyObject]
        address?.text = addressToDelivery["address"] as? String
        
        
        let phoneDeliveryShopper = deliveryObject["shopper"] as! [String:AnyObject]
        shopperImage = phoneDeliveryShopper["picture"] as! String
        
        let timeDelivery = deliveryObject["timeSlot"] as! [String:AnyObject]
        if let timeSlot = timeDelivery["timeSlot"] as? String {
            slotDesc?.text = timeSlot
        }
        
        
        
        
        self.view.superview?.bringSubviewToFront(self.view!)
        initMap()
        initUpdatingMap()
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.view.frame = self.view.superview!.bounds
            self.mapView?.frame  = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            self.view.backgroundColor = UIColor.whiteColor()
            self.viewImage?.center = self.view.center
            //self.viewImage?.alpha = 0
            self.closeButton?.alpha = 1
            self.viewImage?.alpha = 0
            self.view.alpha = 1
            self.headContaimer?.alpha = 1
            self.footerContaimer?.alpha = 1
        })
    }
    
    
    func initMap()
    {
        self.mapView = MKMapView(frame: CGRectZero)
        self.mapView?.delegate = self
        
        self.view.addSubview(self.mapView!)
        self.view.sendSubviewToBack(self.mapView!)
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
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
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
        annotationView.canShowCallout = true
        
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
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.view.frame = self.onOpenFrame
            self.view.backgroundColor = UIColor.clearColor()
            self.viewImage!.frame = CGRectMake(0, 0 ,  self.preferredSize.width, self.preferredSize.height)
            self.closeButton?.alpha = 0
            self.mapView?.removeFromSuperview()
            self.viewImage?.alpha = 1
            self.headContaimer?.alpha = 0
            self.footerContaimer?.alpha = 0
            self.panGesture?.enabled = true
        })
    }
    
}

extension String {
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}


