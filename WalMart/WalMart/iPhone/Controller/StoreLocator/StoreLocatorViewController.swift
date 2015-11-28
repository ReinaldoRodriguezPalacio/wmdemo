//
//  StoreLocatorViewController.swift
//  WalMart
//
//  Created by neftali on 03/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class StoreLocatorViewController: NavigationViewController, MKMapViewDelegate, CLLocationManagerDelegate, StoreViewDelegate, UIActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let annotationIdentifier = "StoreAnnotation"

    var coreLocationManager: CLLocationManager!

    @IBOutlet var bottomSpaceMap: NSLayoutConstraint!
    @IBOutlet weak var bottomSpaceButton: NSLayoutConstraint!
    @IBOutlet var clubMap: MKMapView?
    @IBOutlet var usrPositionBtn: UIButton?
    
    //var segmented: UISegmentedControl?
    var currentSelected: MKAnnotationView?
    var viewBgDetailView: UIView?
    var detailView : StoreView?
    var actionSheet: UIActionSheet?
    var segmentedView : UIView!
    var btnMapView : UIButton!
    var btnSatView : UIButton!
    
    
    var toggleViewBtn: WMRoundButton?
    var clubCollection: UICollectionView?
    var clubCollectionLayout: UICollectionViewFlowLayout?

    var actionSheetGmaps: Int?
    var actionSheetAmaps: Int?

    var localizable = false
    var touchPosition = false
    var isShowingMap = true

    var items: [Store]?
    var selectedStore: Store? //Only for maps directions
    var instructionsForCar = false
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_STORELOCATORMAP.rawValue
    }

    override func viewDidLoad() {
        super.viewDidLoad()

      
        
        self.clubMap!.showsUserLocation = true
        self.clubMap!.delegate = self
        
        self.titleLabel?.text = NSLocalizedString("moreoptions.title.StoreLocator",comment:"")
        
        self.coreLocationManager = CLLocationManager()
        if(CLLocationManager.instancesRespondToSelector(Selector("requestWhenInUseAuthorization")))
        {
            if #available(iOS 8.0, *) {
                self.coreLocationManager.requestWhenInUseAuthorization()
            } else {
                // Fallback on earlier versions
            }
        }
        
        
        self.segmentedView = UIView(frame: CGRectMake(16,  self.header!.frame.maxY + 16,  150.0, 22.0))
        self.segmentedView.layer.borderWidth = 1
        self.segmentedView.layer.cornerRadius = 11
        self.segmentedView.layer.borderColor = WMColor.addressSelectorColor.CGColor
        
        let titleMap = NSLocalizedString("store.selector.map", comment:"")
        btnMapView = UIButton(frame: CGRectMake(1, 1, (self.segmentedView.frame.width / 2) - 1, self.segmentedView.frame.height - 2))
        btnMapView.setImage(UIImage(color: UIColor.whiteColor(), size: btnMapView.frame.size), forState: UIControlState.Normal)
        btnMapView.setImage(UIImage(color: WMColor.addressSelectorColor, size: btnMapView.frame.size), forState: UIControlState.Selected)
        btnMapView.setTitle(titleMap, forState: UIControlState.Normal)
        btnMapView.setTitle(titleMap, forState: UIControlState.Selected)
        btnMapView.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btnMapView.setTitleColor(WMColor.addressSelectorColor, forState: UIControlState.Normal)
        btnMapView.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnMapView.selected = true
        btnMapView.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnMapView.frame.size.width + 1, 0, 0.0);
        btnMapView.addTarget(self, action: "applyMapViewMemoryHotFix", forControlEvents: UIControlEvents.TouchUpInside)
        
        let titleSat = NSLocalizedString("store.selector.satelite", comment:"")
        btnSatView = UIButton(frame: CGRectMake(btnMapView.frame.maxX, 1, self.segmentedView.frame.width / 2, self.segmentedView.frame.height - 2))
        btnSatView.setImage(UIImage(color: UIColor.whiteColor(), size: btnMapView.frame.size), forState: UIControlState.Normal)
        btnSatView.setImage(UIImage(color: WMColor.addressSelectorColor, size: btnMapView.frame.size), forState: UIControlState.Selected)
        btnSatView.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btnSatView.setTitleColor(WMColor.addressSelectorColor, forState: UIControlState.Normal)
        btnSatView.setTitle(titleSat, forState: UIControlState.Normal)
        btnSatView.setTitle(titleSat, forState: UIControlState.Selected)
        btnSatView.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnSatView.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnMapView.frame.size.width + 1, 0, 0.0);
        btnSatView.addTarget(self, action: "applyMapViewMemoryHotFix", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.segmentedView.clipsToBounds = true
        self.segmentedView.backgroundColor = UIColor.whiteColor()
        self.segmentedView.addSubview(btnMapView)
        self.segmentedView.addSubview(btnSatView)
         self.view.addSubview(self.segmentedView!)
        
//        self.segmented = UISegmentedControl(items: [NSLocalizedString("store.selector.map", comment:""), NSLocalizedString("store.selector.satelite", comment:"")])
//        self.segmented!.addTarget(self, action: Selector("segmentedControlAction:"), forControlEvents: .ValueChanged)
//        self.segmented!.selectedSegmentIndex = 0
//        self.view.addSubview(self.segmented!)
//        //self.segmented!.momentary = true
//        
//        var segmentedTitleAttributes = [NSFontAttributeName: WMFont.fontMyriadProRegularOfSize(14),
//            NSForegroundColorAttributeName:WMColor.productDetailPriceText]
//        self.segmented!.setTitleTextAttributes(segmentedTitleAttributes, forState: .Normal)
//        
//        segmentedTitleAttributes = [NSFontAttributeName: WMFont.fontMyriadProRegularOfSize(14),
//            NSForegroundColorAttributeName:UIColor.whiteColor()]
//        self.segmented!.setTitleTextAttributes(segmentedTitleAttributes, forState: .Selected)
//        self.segmented!.setTitleTextAttributes(segmentedTitleAttributes, forState: .Highlighted)
//        
//        var imgInsets = UIEdgeInsetsMake(15, 15, 15, 15)
//        var image_normal = UIImage(named:"store_segmented_normal")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal).resizableImageWithCapInsets(imgInsets)
//        var image_selected = UIImage(named:"store_segmented_selected")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal).resizableImageWithCapInsets(imgInsets)
//        self.segmented!.setBackgroundImage(image_normal, forState:.Normal, barMetrics:.Default)
//        self.segmented!.setBackgroundImage(image_selected, forState:.Selected, barMetrics:.Default)
//        self.segmented!.setBackgroundImage(image_selected, forState:.Highlighted, barMetrics:.Default)
//
//        var sepInsets = UIEdgeInsetsMake(15, 10, 15, 10)
//        var bothSelected = UIImage(named:"store_segmented_bothActive")!.resizableImageWithCapInsets(sepInsets)
//        self.segmented!.setDividerImage(bothSelected, forLeftSegmentState: .Selected, rightSegmentState: .Highlighted, barMetrics: .Default)
//        self.segmented!.setDividerImage(bothSelected, forLeftSegmentState: .Highlighted, rightSegmentState: .Selected, barMetrics: .Default)
//        
//        var leftSelected = UIImage(named:"store_segmented_LActiveRInactive.png")!.resizableImageWithCapInsets(sepInsets)
//        self.segmented!.setDividerImage(leftSelected, forLeftSegmentState:.Highlighted, rightSegmentState:.Normal, barMetrics:.Default)
//        self.segmented!.setDividerImage(leftSelected, forLeftSegmentState:.Selected, rightSegmentState:.Normal, barMetrics:.Default)
//        
//        var rightSelected = UIImage(named:"store_segmented_RActiveLInactive.png")!.resizableImageWithCapInsets(sepInsets)
//        self.segmented!.setDividerImage(rightSelected, forLeftSegmentState:.Normal, rightSegmentState:.Highlighted, barMetrics:.Default)
//        self.segmented!.setDividerImage(rightSelected, forLeftSegmentState:.Normal, rightSegmentState:.Selected, barMetrics:.Default)
        
        

        
        self.toggleViewBtn = WMRoundButton()
        self.toggleViewBtn?.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        self.toggleViewBtn?.setBackgroundColor(WMColor.light_blue, size: CGSizeMake(71, 22), forUIControlState: UIControlState.Normal)
        self.toggleViewBtn!.setTitle(NSLocalizedString("store.showtable",comment:""), forState: .Normal)
        self.toggleViewBtn!.setTitleColor(WMColor.navigationFilterTextColor, forState: .Normal)
        self.toggleViewBtn!.addTarget(self, action: "showTableView:", forControlEvents: .TouchUpInside)
        self.toggleViewBtn!.backgroundColor = UIColor.clearColor()
        self.header!.addSubview(self.toggleViewBtn!)

        self.clubCollectionLayout = UICollectionViewFlowLayout()
        self.clubCollectionLayout!.minimumInteritemSpacing = 0.0
        self.clubCollectionLayout!.minimumLineSpacing = 0.0
        
        self.clubCollection = UICollectionView(frame: self.clubMap!.frame, collectionViewLayout: self.clubCollectionLayout!)
        self.clubCollection!.backgroundColor = UIColor.whiteColor()
        self.clubCollection!.registerClass(ClubLocatorTableViewCell.self, forCellWithReuseIdentifier: "club")
        self.clubCollection!.delegate = self
        self.clubCollection!.dataSource = self
        self.clubCollection!.hidden = true
        self.clubCollection!.contentInset = UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0)
        self.clubCollection!.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0)
        self.view.addSubview(self.clubCollection!)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startRunning", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopRunning", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        self.loadAnnotations()
        self.clubCollection!.reloadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideTabBar", name: CustomBarNotification.HideBar.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showTabBar", name: CustomBarNotification.ShowBar.rawValue, object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var bounds = self.view.bounds
        var height = bounds.height - self.header!.frame.height
        
        self.clubMap!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, height)
        self.clubCollection?.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, height)

        if self.segmentedView!.frame.origin.y == 16 {
            self.segmentedView!.frame = CGRectMake(16.0, bounds.height - 38.0, 150.0, 22.0)
        }
//        var space : CGFloat = 0
//        if bottomSpaceButton != nil  {
//            space = bottomSpaceButton!.constant
//        }
//        self.segmentedView!.center = CGPointMake(self.segmentedView!.center.x, self.usrPositionBtn!.center.y -  (space - 16))

        if self.toggleViewBtn != nil {
            bounds = self.header!.frame
            height = bounds.height - 20.0
            self.toggleViewBtn!.frame = CGRectMake(bounds.width - 87.0, 10.0, 71.0, height)
        }

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.memoryHotFix()
        self.coreLocationManager.startUpdatingLocation()
        if !self.localizable {
            self.zoomMapLocation(self.clubMap!.userLocation)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if self.actionSheet != nil && self.actionSheet!.visible {
            let cancelIdx = self.actionSheet!.cancelButtonIndex
            self.actionSheet!.dismissWithClickedButtonIndex(cancelIdx, animated: false)
        }
        self.memoryHotFix()
        self.coreLocationManager.stopUpdatingLocation()
    }
    
    func startRunning() {
        self.coreLocationManager.startUpdatingLocation()
        if !self.localizable{
            self.zoomMapLocation(self.clubMap!.userLocation)
        }
    }
    
    func stopRunning() {
        self.memoryHotFix()
        self.coreLocationManager.stopUpdatingLocation()
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

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !self.localizable {
            self.zoomMapLocation(userLocation)
        }
        if self.clubMap!.overlays.count > 0 && self.viewBgDetailView == nil {
            MapKitUtils.zoomMapViewToFitAnnotations(self.clubMap, animated: true)
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let storeAnnotation = annotation as? StoreAnnotation {
            var view =  mapView.dequeueReusableAnnotationViewWithIdentifier(self.annotationIdentifier)
            if view == nil {
                view = MKAnnotationView(annotation: storeAnnotation, reuseIdentifier: self.annotationIdentifier)
                view!.enabled = true
                view!.canShowCallout = false
                view!.image = UIImage(named: "pin")
            }
            else {
                view!.annotation = storeAnnotation
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let latResult = view.annotation!.coordinate.latitude + 0.01
        let coordinateMap =  CLLocationCoordinate2DMake(latResult, view.annotation!.coordinate.longitude)
        let pointRect = MKCoordinateRegionMakeWithDistance(coordinateMap, 10000, 10000)
        let isSameCenter = self.currentSelected === view
        self.clubMap!.setRegion(pointRect, animated: true)
        if let annotation = view.annotation as? StoreAnnotation {
            
  
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATORMAP_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATORMAP_NOAUTH.rawValue, action:WMGAIUtils.ACTION_STOREDETAIL.rawValue, label: annotation.storeEntity!.name!)
            
        
            self.viewBgDetailView = UIView(frame:CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height))
            self.viewBgDetailView!.backgroundColor = UIColor.clearColor()
            self.viewBgDetailView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "mapViewUserDidTap"))
            
            self.detailView = StoreView(frame:CGRectMake(0.0, 0.0, 256.0, 200.0))
            self.detailView!.delegate = self
            self.detailView!.setValues(annotation.storeEntity, userLocation: mapView.userLocation.location)
            let height = self.detailView!.retrieveCalculatedHeight()
            self.detailView!.frame = CGRectMake(0.0, 0.0, 256.0, height)
            self.detailView!.center = CGPointMake((self.viewBgDetailView!.frame.width/2), (self.viewBgDetailView!.frame.height/2) - 100.0)
            
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
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        view.image = UIImage(named: "pin")
    }

    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool){
        if !self.touchPosition {
            self.usrPositionBtn!.selected = false
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        self.touchPosition = false
    }
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items != nil ? self.items!.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("club", forIndexPath: indexPath) as! ClubLocatorTableViewCell
        cell.setValues(self.items![indexPath.row], userLocation: self.clubMap!.userLocation.location)
        cell.delegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //return CGSizeMake(collectionView.frame.width, 250.0)
        let store = self.items![indexPath.row]
        return ClubLocatorTableViewCell.calculateCellHeight(forStore: store, width: collectionView.frame.width)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
    }

    //MARK: - Actions
    func mapViewUserDidTap() {
        self.mapViewUserDidTap(false)
    }
    
    func mapViewUserDidTap(gotoPosition: Bool) {
        
        if self.viewBgDetailView != nil {
            
            //Event
            
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
                    }
            })
        }
    }

    @IBAction func segmentedControlAction(segmentedControl:UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            
            //Event
           
            self.clubMap!.mapType = MKMapType.Standard
        }
        if segmentedControl.selectedSegmentIndex == 1 {
            
            //Event
            
            self.clubMap!.mapType = MKMapType.Hybrid
        }
    }

    @IBAction func showUserPosition() {
        self.usrPositionBtn!.selected = true
        
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATORMAP_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATORMAP_NOAUTH.rawValue, action: WMGAIUtils.ACTION_USER_CURRENT_LOCATION.rawValue , label:"")
        
        if self.viewBgDetailView != nil {
            self.mapViewUserDidTap(true)
        }else {
            self.zoomMapLocation(self.clubMap!.userLocation)
        }
    }

    @IBAction func showTableView(sender: AnyObject) {
        if self.isShowingMap {
            //Event

            self.toggleViewBtn?.setTitle(NSLocalizedString("store.showmap",comment:""), forState: .Normal)
            self.clubMap!.hidden = true
            self.clubCollection!.hidden = false
            self.isShowingMap = false
            //self.applyMapViewMemoryHotFix()
            
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHOW_LIST_STORE_LOCATOR.rawValue, label: "")
            
            
        }
        else {
            //Event
            
            self.toggleViewBtn?.setTitle(NSLocalizedString("store.showtable",comment:""), forState: .Normal)
            self.clubMap!.hidden = false
            self.clubCollection!.hidden = true
            self.isShowingMap = true
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHOW_MAP_STORE_LOCATOR.rawValue, label: "")
        }
    }

    //MARK: - Utils
    
    func memoryHotFix() {
        if !self.btnMapView.selected {
            self.clubMap!.mapType = MKMapType.Standard
            self.clubMap!.mapType = MKMapType.Hybrid
        } else {
            self.clubMap!.mapType = MKMapType.Hybrid
            self.clubMap!.mapType = MKMapType.Standard
        }
    }
    
    func applyMapViewMemoryHotFix(){
        if !self.btnMapView.selected {
            self.btnMapView.selected = !self.btnMapView.selected
            self.btnSatView.selected = !self.btnSatView.selected


            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATORMAP_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATORMAP_NOAUTH.rawValue, action: WMGAIUtils.ACTION_MAP_TYPE.rawValue , label:"Satelite")

        } else {
            self.btnMapView.selected = !self.btnMapView.selected
            self.btnSatView.selected = !self.btnSatView.selected
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATORMAP_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATORMAP_NOAUTH.rawValue, action: WMGAIUtils.ACTION_MAP_TYPE.rawValue , label:"Map")

            
        }
        memoryHotFix()
    }
    
    func zoomMapLocation(userLocation: MKUserLocation! ){
        if userLocation.location != nil {
            self.usrPositionBtn?.selected = true
            self.touchPosition = true
            if self.localizable {
                let coordinateMap =  CLLocationCoordinate2DMake(userLocation.coordinate.latitude
                    + 0.01, userLocation.coordinate.longitude)
                let pointRect = MKCoordinateRegionMakeWithDistance(coordinateMap, userLocation.location!.horizontalAccuracy + 20001 , userLocation.location!.horizontalAccuracy + 20000 )
                self.clubMap!.setRegion(pointRect, animated: true)
            }
            self.localizable = true
            let delay = 0.8 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                let coordinateMap =  CLLocationCoordinate2DMake(userLocation.coordinate.latitude
                    + 0.01, userLocation.coordinate.longitude)
                let pointRect = MKCoordinateRegionMakeWithDistance(coordinateMap, userLocation.location!.horizontalAccuracy + 20000 , userLocation.location!.horizontalAccuracy + 20000 )
                self.clubMap!.setRegion(pointRect, animated: true)
                
                self.usrPositionBtn?.selected = true
                self.touchPosition = true
            })
        }
    }

    func loadAnnotations() {
        for annotation in self.clubMap!.annotations {
            if let clubAnnotation = annotation as? StoreAnnotation {
                self.clubMap!.removeAnnotation(clubAnnotation)
            }
        }

        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Store", inManagedObjectContext: context)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let result: [Store] = (try! context.executeFetchRequest(fetchRequest)) as! [Store]
        self.items = result
        if result.count > 0 {
            for store in result {
                let coordinate = CLLocationCoordinate2DMake(store.latitude!.doubleValue, store.longitude!.doubleValue)
                let annotation = StoreAnnotation(coordinate: coordinate)
                annotation.storeEntity = store
                self.clubMap!.addAnnotation(annotation)
            }
        }
    }
    
    func openAppleMaps(forCar flag:Bool) {
        if self.selectedStore != nil {
            let coordinate = CLLocationCoordinate2DMake(self.selectedStore!.latitude!.doubleValue, self.selectedStore!.longitude!.doubleValue)
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = self.selectedStore!.name
            
            // Set the directions mode to "Walking"
            // Can use MKLaunchOptionsDirectionsModeDriving instead
            var launchOptions: [String : AnyObject]?
            if flag {
                launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            }
            else {
                launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking]
            }
            // Get the "Current User Location" MKMapItem
            let currentLocationMapItem = MKMapItem.mapItemForCurrentLocation()
            // Pass the current location and destination map items to the Maps app
            // Set the direction mode in the launchOptions dictionary
            MKMapItem.openMapsWithItems([currentLocationMapItem, mapItem], launchOptions: launchOptions!)
            self.selectedStore = nil
        }
    }
    
    func openGoogleMaps(forCar flag:Bool) {
        //comgooglemaps://?saddr=2025+Garcia+Ave,+Mountain+View,+CA,+USA&daddr=Google,+1600+Amphitheatre+Parkway,+Mountain+View,+CA,+United+States&center=37.423725,-122.0877&directionsmode=walking&zoom=17
        // driving, transit, bicycling or walking.
        if self.selectedStore != nil {
            let gmapsInstalled = UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!)
            if gmapsInstalled {
                let coordinate = CLLocationCoordinate2DMake(self.selectedStore!.latitude!.doubleValue, self.selectedStore!.longitude!.doubleValue)
                let mode = flag ? "driving" : "walking"
                var string = String(format: "comgooglemaps://?daddr=%f,%f&directionsmode=%@", coordinate.latitude, coordinate.longitude, mode) as NSString
                string = string.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                let url = NSURL(string: string as String)
                UIApplication.sharedApplication().openURL(url!)
            }
            self.selectedStore = nil
        }
    }

    //MARK: - StoreViewDelegate
    
    func showInstructions(store:Store, forCar flag:Bool) {
        self.selectedStore = store
        
        //Event
        
        
        let gmapsInstalled = UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!)
        if gmapsInstalled {
            self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.actionSheet!.actionSheetStyle = .Automatic
            self.actionSheetGmaps = self.actionSheet!.addButtonWithTitle("Google Maps")
            self.actionSheetAmaps = self.actionSheet!.addButtonWithTitle("Apple Maps")
            let cancelIdx = self.actionSheet!.addButtonWithTitle("Cancel")
            self.actionSheet!.cancelButtonIndex = cancelIdx
            self.instructionsForCar = flag
            self.actionSheet!.showInView(self.view)
       }
        else {
            self.openAppleMaps(forCar: flag)
        }
    }
    
    func makeCallForStore(store:Store) {
        if let phone = store.telephone {
            
            let values = phone.componentsSeparatedByString("/")
            if values.count > 0 {
                var telephoneString = values[0] as String
                if !telephoneString.isEmpty {
                    if let range = telephoneString.rangeOfString("AL", options: .CaseInsensitiveSearch, range: nil, locale: nil) {
                        telephoneString = telephoneString.substringToIndex(range.startIndex)
                    }
                    let phoneStr = telephoneString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "0123456789-+()").invertedSet) as NSString
                    print(phoneStr)
                    let resultStr = phoneStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                    let strTel = "telprompt://\(resultStr!)"
                    if UIApplication.sharedApplication().canOpenURL(NSURL(string: strTel)!) {
                        UIApplication.sharedApplication().openURL(NSURL(string: strTel)!)
                    }
                }
            }
        }
    }

    func shareStore(store:Store) {
        let telephoneText = String(format: NSLocalizedString("store.telephone", comment:""), store.telephone!)
        let opensText = String(format: NSLocalizedString("store.opens", comment:""), store.opens!)
        let textSend = "\(store.name!)\n\n\(store.address!) CP: \(store.zipCode!)\n\n\(telephoneText)\n\(opensText)"
        
        let controller = UIActivityViewController(activityItems: [textSend], applicationActivities: nil)
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }

    func showInMap(store:Store) {
        self.viewBgDetailView?.removeFromSuperview()
        self.viewBgDetailView = nil
        self.detailView?.removeFromSuperview()
        self.detailView = nil

        if !self.isShowingMap {
            self.toggleViewBtn?.setTitle(NSLocalizedString("store.showtable",comment:""), forState: .Normal)
            self.clubMap!.hidden = false
            self.clubCollection!.hidden = true
            self.isShowingMap = true
            //self.gotoPosition?.hidden = false
        }
        
        for annotation in self.clubMap!.annotations {
            if let inner = annotation as? StoreAnnotation {
                if inner.storeEntity!.storeID == store.storeID {
                    self.clubMap!.selectAnnotation(inner, animated: true)
                    break
                }
            }
        }
    }

    // MARK: - UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int){
        if buttonIndex == self.actionSheetGmaps! {
            self.openGoogleMaps(forCar: self.instructionsForCar)
        }
        else if buttonIndex == self.actionSheetAmaps! {
            self.openAppleMaps(forCar: self.instructionsForCar)
        }
    }

    
    func showTabBar() {
        bottomSpaceMap?.constant = 44
        bottomSpaceButton?.constant = 60
        if bottomSpaceButton != nil  {
            self.segmentedView!.center = CGPointMake(self.segmentedView!.center.x, self.usrPositionBtn!.center.y -  (bottomSpaceButton!.constant - 16))
        }
        
    }
    
    func hideTabBar() {
        bottomSpaceMap?.constant = 0
        bottomSpaceButton?.constant = 16
        if bottomSpaceButton != nil  {
           self.segmentedView!.center = CGPointMake(self.segmentedView!.center.x, self.usrPositionBtn!.center.y -  (bottomSpaceButton!.constant - 16))
        }
    }
    
    override func back() {
        super.back()
        if self.clubMap!.hidden {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LIST_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_LIST_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BACK.rawValue, label: "")
        } else {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATORMAP_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATORMAP_NOAUTH.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTION.rawValue, label: "")
        }
        
        
    }
    
}
