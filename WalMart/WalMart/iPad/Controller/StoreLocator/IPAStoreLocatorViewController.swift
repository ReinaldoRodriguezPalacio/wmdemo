//
//  IPAStoreLocatorViewController.swift
//  WalMart
//
//  Created by neftali on 03/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class IPAStoreLocatorViewController: StoreLocatorViewController, UIPopoverControllerDelegate {

    var sharePopover: UIPopoverController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clubCollection!.registerClass(IPAClubLocatorTableViewCell.self, forCellWithReuseIdentifier: "club")
        self.clubCollection!.hidden = false
        self.clubCollection!.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.clubCollection!.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)

        self.clubCollection!.reloadData()

        self.toggleViewBtn?.removeFromSuperview()
        self.toggleViewBtn = nil
        self.backButton?.hidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        let height = bounds.height - self.header!.frame.height
        
        self.clubCollection!.frame = CGRectMake(0.0, self.header!.frame.maxY, 342.0, height)
        self.clubMap!.frame = CGRectMake(342.0, self.header!.frame.maxY, bounds.width - 342.0, height)
        
        self.segmentedView!.frame = CGRectMake(self.clubCollection!.frame.maxX + 30.0, bounds.height - 38.0, 150.0, 22.0)
        self.segmentedView!.center = CGPointMake(self.segmentedView!.center.x, self.usrPositionBtn!.center.y)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - MKMapViewDelegate

    override func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !self.localizable {
            self.zoomMapLocation(userLocation)
        }
        
        if self.clubMap!.overlays.count > 0 && self.viewBgDetailView == nil {
            MapKitUtils.zoomMapViewToFitAnnotations(self.clubMap, animated: true)
        }
        self.clubCollection!.reloadData()
    }

    override func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let latResult = view.annotation!.coordinate.latitude + 0.01
        let coordinateMap =  CLLocationCoordinate2DMake(latResult, view.annotation!.coordinate.longitude)
        let pointRect = MKCoordinateRegionMakeWithDistance(coordinateMap, 10000, 10000)
        let isSameCenter = self.currentSelected === view
        self.clubMap!.setRegion(pointRect, animated: true)
        if let annotation = view.annotation as? StoreAnnotation {
            
            if self.viewBgDetailView == nil {
                self.viewBgDetailView = UIView(frame:CGRectMake(342.0, 0.0, self.clubMap!.bounds.width, self.view.bounds.height))
                self.viewBgDetailView!.backgroundColor = UIColor.clearColor()
                self.viewBgDetailView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "mapViewUserDidTap"))
            }
            
            self.detailView = IPAStoreView(frame:CGRectMake(0.0, 0.0, 256.0, 200.0))
            self.detailView!.delegate = self
            self.detailView!.setValues(annotation.storeEntity, userLocation: mapView.userLocation.location)
            let height = self.detailView!.retrieveCalculatedHeight()
            self.detailView!.frame = CGRectMake(0.0, 0.0, 256.0, height)
            self.detailView!.center = CGPointMake((self.viewBgDetailView!.frame.width/2), (self.viewBgDetailView!.frame.height/2) - 10.0)
            self.detailView!.layer.cornerRadius = 5.0
            self.detailView!.clipsToBounds = true
            
            view.image = UIImage(named:"pin_selected")
            
            self.currentSelected = view
            
            self.viewBgDetailView!.addSubview(self.detailView!)
            self.view.addSubview(self.viewBgDetailView!)
            
            self.detailView!.transform = CGAffineTransformMakeScale(0.0, 0.0)
            UIView.animateWithDuration(0.5,
                delay: isSameCenter ? 0.0 : 1.5,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: {
                    self.detailView!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                },
                completion: nil)
            
            if let index = (self.items!).indexOf(annotation.storeEntity!) {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                self.clubCollection!.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .Top)
            }

        }
    }


    //MARK: - UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //return CGSizeMake(collectionView.frame.width, 250.0)
        let store = self.items![indexPath.row]
        return IPAClubLocatorTableViewCell.calculateCellHeight(forStore: store, width: 342.0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        
        let store = self.items![indexPath.row]
        
        //Event
//        //TODOGAI
//        if let tracker = GAI.sharedInstance().defaultTracker {
//            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_STORELACATION.rawValue,
//                action:WMGAIUtils.EVENT_STORELOCATOR_LIST_SHOWSTOREINMAP.rawValue,
//                label: store.name!,
//                value: nil).build() as [NSObject : AnyObject])
//        }
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue , action:WMGAIUtils.ACTION_SHOW_STORE_LOCATOR_IN_MAP.rawValue, label:store.name! )
        
        self.detailView?.removeFromSuperview()
        self.detailView = nil
        
        for annotation in self.clubMap!.annotations {
            if let inner = annotation as? StoreAnnotation {
                if inner.storeEntity!.storeID == store.storeID {
                    self.clubMap!.selectAnnotation(inner, animated: true)
                    break
                }
            }
        }
        
    }

    //MARK: - Actions
    
    override func mapViewUserDidTap(gotoPosition: Bool) {
        if self.viewBgDetailView != nil {
             if self.detailView != nil {
                self.detailView!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                UIView.animateWithDuration(0.5,
                    animations: { () -> Void in
                        self.detailView!.transform = CGAffineTransformMakeScale(0.0, 0.0)
                    },
                    completion: { (finished:Bool) -> Void in
                        if finished {
                            self.viewBgDetailView!.removeFromSuperview()
                            self.viewBgDetailView = nil
                            self.detailView!.removeFromSuperview()
                            self.detailView = nil
                            self.clubMap!.deselectAnnotation(self.currentSelected!.annotation, animated: true)
                            
                            if gotoPosition {
                                self.zoomMapLocation(self.clubMap!.userLocation)
                            }
                            else {
                                if self.clubMap!.overlays.count > 0 {
                                    MapKitUtils.zoomMapViewToFitAnnotations(self.clubMap, animated: true)
                                }
                            }
                            
                            var selected = self.clubCollection!.indexPathsForSelectedItems()
                            for var idx = 0; idx < selected!.count; idx++ {
                                let indexPath = selected![idx]
                                self.clubCollection!.deselectItemAtIndexPath(indexPath, animated: true)
                            }
                        }
                })
            }
        }
    }

    //MARK: - StoreViewDelegate
    
    override func showInstructions(store:Store, forCar flag:Bool) {
        self.selectedStore = store
        let gmapsInstalled = UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!)
        if gmapsInstalled {
            self.viewBgDetailView?.removeFromSuperview()
            self.viewBgDetailView = nil
            self.detailView?.removeFromSuperview()
            self.detailView = nil

            self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.actionSheet!.actionSheetStyle = .Automatic
            self.actionSheetGmaps = self.actionSheet!.addButtonWithTitle("Google Maps")
            self.actionSheetAmaps = self.actionSheet!.addButtonWithTitle("Apple Maps")
            let cancelIdx = self.actionSheet!.addButtonWithTitle("Cancel")
            self.actionSheet!.cancelButtonIndex = cancelIdx
            self.instructionsForCar = flag
            let rect = self.clubMap!.convertRect(self.currentSelected!.frame, toView: self.view.superview)
            self.actionSheet!.showFromRect(rect, inView: self.view.superview!, animated: true)
        }
        else {
            self.openAppleMaps(forCar: flag)
        }
    }

    override func shareStore(store:Store) {
        self.viewBgDetailView?.removeFromSuperview()
        self.viewBgDetailView = nil
        self.detailView?.removeFromSuperview()
        self.detailView = nil

        let telephoneText = String(format: NSLocalizedString("store.telephone", comment:""), store.telephone!)
        let opensText = String(format: NSLocalizedString("store.opens", comment:""), store.opens!)
        let textSend = "\(store.name!)\n\n\(store.address!) CP: \(store.zipCode!)\n\n\(telephoneText)\n\(opensText)"
        
        
        //Event
//        //TODOGAI
//        if let tracker = GAI.sharedInstance().defaultTracker {
//            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_STORELACATION.rawValue,
//                action:WMGAIUtils.EVENT_STORELOCATOR_MAP_SHARESTOREDETAIL.rawValue,
//                label: store.name!,
//                value: nil).build() as [NSObject : AnyObject])
//        }
        
        let controller = UIActivityViewController(activityItems: [textSend], applicationActivities: nil)
        self.sharePopover = UIPopoverController(contentViewController: controller)
        self.sharePopover!.delegate = self
        let rect = self.clubMap!.convertRect(self.currentSelected!.frame, toView: self.view.superview)
        self.sharePopover!.presentPopoverFromRect(rect, inView: self.view.superview!, permittedArrowDirections: .Any, animated: true)
    }

    //MARK: - UIPopoverControllerDelegate
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        self.clubMap!.deselectAnnotation(self.currentSelected!.annotation, animated: true)
        if let index = (self.items!).indexOf((self.currentSelected!.annotation as! StoreAnnotation).storeEntity!) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            self.clubCollection!.deselectItemAtIndexPath(indexPath, animated: true)
        }
        self.currentSelected = nil
        self.sharePopover = nil
    }

    //MARK: - UIActionSheetDelegate
    
    func actionSheetCancel(actionSheet: UIActionSheet) {
        print("Cancel")
    }
    
    override func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        print("Action selected \(buttonIndex)")
        super.actionSheet(actionSheet, didDismissWithButtonIndex: buttonIndex)
        self.clubMap!.deselectAnnotation(self.currentSelected!.annotation, animated: true)
        if let index = (self.items!).indexOf((self.currentSelected!.annotation as! StoreAnnotation).storeEntity!) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            self.clubCollection!.deselectItemAtIndexPath(indexPath, animated: true)
        }
        self.currentSelected = nil
    }
}
