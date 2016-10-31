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
        
        self.clubCollection!.register(IPAClubLocatorTableViewCell.self, forCellWithReuseIdentifier: "club")
        self.clubCollection!.isHidden = false
        self.clubCollection!.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 0.0)
        self.clubCollection!.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)

        self.clubCollection!.reloadData()

        self.toggleViewBtn?.removeFromSuperview()
        self.toggleViewBtn = nil
        self.backButton?.isHidden = true
        self.searchView.isHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        let height = bounds.height - self.header!.frame.height
        
        self.searchField!.frame = CGRect(x: 16, y: 16,width: 310.0, height: 40.0)
        self.clearButton!.frame = CGRect(x: self.searchField.frame.width - 40 , y: 0, width: 48, height: 40)
        self.searchView!.frame = CGRect(x: 0.0, y: self.header!.frame.maxY, width: 342.0, height: 72)
        self.separator.frame = CGRect(x: 0, y: self.searchView!.bounds.maxY - 1, width: 342.0, height: 1)
        self.clubCollection?.frame = CGRect(x: 0.0, y: self.searchView!.frame.maxY, width: 342.0, height: height - 72)
        self.clubMap!.frame = CGRect(x: 342.0, y: self.header!.frame.maxY, width: bounds.width - 342.0, height: height)
        
        self.segmentedView!.frame = CGRect(x: self.clubCollection!.frame.maxX + 30.0, y: bounds.height - 38.0, width: 150.0, height: 22.0)
        self.segmentedView!.center = CGPoint(x: self.segmentedView!.center.x, y: self.usrPositionBtn!.center.y)
        
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

    override func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !self.localizable {
            self.zoomMapLocation(userLocation)
        }
        
        if self.clubMap!.overlays.count > 0 && self.viewBgDetailView == nil {
            MapKitUtils.zoomMapView(toFitAnnotations: self.clubMap, animated: true)
        }
        self.clubCollection!.reloadData()
    }

    override func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.searchField.resignFirstResponder()
        let latResult = view.annotation!.coordinate.latitude + 0.01
        let coordinateMap =  CLLocationCoordinate2DMake(latResult, view.annotation!.coordinate.longitude)
        let pointRect = MKCoordinateRegionMakeWithDistance(coordinateMap, 10000, 10000)
        let isSameCenter = self.currentSelected === view
        self.clubMap!.setRegion(pointRect, animated: true)
        if let annotation = view.annotation as? StoreAnnotation {
            if self.viewBgDetailView == nil {
                self.viewBgDetailView = UIView(frame:CGRect(x: 342.0, y: 0.0, width: self.clubMap!.bounds.width, height: self.view.bounds.height))
                self.viewBgDetailView!.backgroundColor = UIColor.clear
                self.viewBgDetailView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(StoreLocatorViewController.mapViewUserDidTap as (StoreLocatorViewController) -> () -> ())))
            }
            
            self.detailView = IPAStoreView(frame:CGRect(x: 0.0, y: 0.0, width: 256.0, height: 200.0))
            self.detailView!.delegate = self
            self.detailView!.setValues(annotation.storeEntity, userLocation: mapView.userLocation.location)
            let height = self.detailView!.retrieveCalculatedHeight()
            self.detailView!.frame = CGRect(x: 0.0, y: 0.0, width: 256.0, height: height)
            self.detailView!.center = CGPoint(x: (self.viewBgDetailView!.frame.width/2), y: (self.viewBgDetailView!.frame.height/2) - 10.0)
            self.detailView!.layer.cornerRadius = 5.0
            self.detailView!.clipsToBounds = true
            
            view.image = UIImage(named:"pin_selected")
            
            self.currentSelected = view
            
            self.viewBgDetailView!.addSubview(self.detailView!)
            self.view.addSubview(self.viewBgDetailView!)
            
            self.detailView!.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            UIView.animate(withDuration: 0.5,
                delay: isSameCenter ? 0.0 : 1.5,
                options: UIViewAnimationOptions.beginFromCurrentState,
                animations: {
                    self.detailView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                },
                completion: nil)
            
            if let index = (self.items!).index(of: annotation.storeEntity!) {
                let indexPath = IndexPath(row: index, section: 0)
                if index >= (self.items!.count - 4) {
                    self.clubCollection!.contentInset = UIEdgeInsetsMake(0, 0, 390, 0)
                }else{
                     self.clubCollection!.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                }
                self.clubCollection!.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
            }
        }
    }


    //MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return CGSizeMake(collectionView.frame.width, 250.0)
        let store = self.items![(indexPath as NSIndexPath).row]
        return IPAClubLocatorTableViewCell.calculateCellHeight(forStore: store, width: 342.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        self.searchField.resignFirstResponder()
        let store = self.items![(indexPath as NSIndexPath).row]
         collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        
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
    
    override func mapViewUserDidTap(_ gotoPosition: Bool) {
        if self.viewBgDetailView != nil {
             if self.detailView != nil {
                self.detailView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                UIView.animate(withDuration: 0.5,
                    animations: { () -> Void in
                        self.detailView!.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
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
                                    MapKitUtils.zoomMapView(toFitAnnotations: self.clubMap, animated: true)
                                }
                            }
                            
                            var selected = self.clubCollection!.indexPathsForSelectedItems
                            for idx in 0 ..< selected!.count {
                                let indexPath = selected![idx]
                                self.clubCollection!.deselectItem(at: indexPath, animated: true)
                            }
                        }
                })
            }
        }
    }

    //MARK: - StoreViewDelegate
    
    override func showInstructions(_ store:Store, forCar flag:Bool) {
        self.selectedStore = store
        let gmapsInstalled = UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
        if gmapsInstalled {
            self.viewBgDetailView?.removeFromSuperview()
            self.viewBgDetailView = nil
            self.detailView?.removeFromSuperview()
            self.detailView = nil

            self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.actionSheet!.actionSheetStyle = .automatic
            self.actionSheetGmaps = self.actionSheet!.addButton(withTitle: "Google Maps")
            self.actionSheetAmaps = self.actionSheet!.addButton(withTitle: "Apple Maps")
            let cancelIdx = self.actionSheet!.addButton(withTitle: "Cancel")
            self.actionSheet!.cancelButtonIndex = cancelIdx
            self.instructionsForCar = flag
            let rect = self.clubMap!.convert(self.currentSelected!.frame, to: self.view.superview)
            self.actionSheet!.show(from: rect, in: self.view.superview!, animated: true)
        }
        else {
            self.openAppleMaps(forCar: flag)
        }
    }

    override func shareStore(_ store:Store) {
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
        let rect = self.clubMap!.convert(self.currentSelected!.frame, to: self.view.superview)
        self.sharePopover!.present(from: rect, in: self.view.superview!, permittedArrowDirections: .any, animated: true)
    }

    //MARK: - UIPopoverControllerDelegate
    
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController) {
        self.clubMap!.deselectAnnotation(self.currentSelected!.annotation, animated: true)
        if let index = (self.items!).index(of: (self.currentSelected!.annotation as! StoreAnnotation).storeEntity!) {
            let indexPath = IndexPath(row: index, section: 0)
            self.clubCollection!.deselectItem(at: indexPath, animated: true)
        }
        self.currentSelected = nil
        self.sharePopover = nil
    }

    //MARK: - UIActionSheetDelegate
    
    func actionSheetCancel(_ actionSheet: UIActionSheet) {
        print("Cancel")
    }
    
    override func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        print("Action selected \(buttonIndex)")
        super.actionSheet(actionSheet, didDismissWithButtonIndex: buttonIndex)
        self.clubMap!.deselectAnnotation(self.currentSelected!.annotation, animated: true)
        if let index = (self.items!).index(of: (self.currentSelected!.annotation as! StoreAnnotation).storeEntity!) {
            let indexPath = IndexPath(row: index, section: 0)
            self.clubCollection!.deselectItem(at: indexPath, animated: true)
        }
        self.currentSelected = nil
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        if self.searchField.isFirstResponder {
        self.searchField.resignFirstResponder()
        }
    }
}
