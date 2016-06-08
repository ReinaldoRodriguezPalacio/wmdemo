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

class StoreLocatorViewController: NavigationViewController, MKMapViewDelegate, CLLocationManagerDelegate, StoreViewDelegate, UIActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITextFieldDelegate {

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
    var searchView: UIView!
    var clearButton : UIButton?
    var searchField: FormFieldSearch!
    var separator: CALayer!
    
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
        self.segmentedView.layer.borderColor = WMColor.light_blue.CGColor
        
        let titleMap = NSLocalizedString("store.selector.map", comment:"")
        btnMapView = UIButton(frame: CGRectMake(1, 1, (self.segmentedView.frame.width / 2) - 1, self.segmentedView.frame.height - 2))
        btnMapView.setImage(UIImage(color: UIColor.whiteColor(), size: btnMapView.frame.size), forState: UIControlState.Normal)
        btnMapView.setImage(UIImage(color: WMColor.light_blue, size: btnMapView.frame.size), forState: UIControlState.Selected)
        btnMapView.setTitle(titleMap, forState: UIControlState.Normal)
        btnMapView.setTitle(titleMap, forState: UIControlState.Selected)
        btnMapView.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btnMapView.setTitleColor(WMColor.light_blue, forState: UIControlState.Normal)
        btnMapView.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnMapView.selected = true
        btnMapView.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnMapView.frame.size.width + 1, 0, 0.0);
        btnMapView.addTarget(self, action: #selector(StoreLocatorViewController.applyMapViewMemoryHotFix), forControlEvents: UIControlEvents.TouchUpInside)
        
        let titleSat = NSLocalizedString("store.selector.satelite", comment:"")
        btnSatView = UIButton(frame: CGRectMake(btnMapView.frame.maxX, 1, self.segmentedView.frame.width / 2, self.segmentedView.frame.height - 2))
        btnSatView.setImage(UIImage(color: UIColor.whiteColor(), size: btnMapView.frame.size), forState: UIControlState.Normal)
        btnSatView.setImage(UIImage(color: WMColor.light_blue, size: btnMapView.frame.size), forState: UIControlState.Selected)
        btnSatView.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btnSatView.setTitleColor(WMColor.light_blue, forState: UIControlState.Normal)
        btnSatView.setTitle(titleSat, forState: UIControlState.Normal)
        btnSatView.setTitle(titleSat, forState: UIControlState.Selected)
        btnSatView.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnSatView.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnMapView.frame.size.width + 1, 0, 0.0);
        btnSatView.addTarget(self, action: #selector(StoreLocatorViewController.applyMapViewMemoryHotFix), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.segmentedView.clipsToBounds = true
        self.segmentedView.backgroundColor = UIColor.whiteColor()
        self.segmentedView.addSubview(btnMapView)
        self.segmentedView.addSubview(btnSatView)
         self.view.addSubview(self.segmentedView!)
        
        self.toggleViewBtn = WMRoundButton()
        self.toggleViewBtn?.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        self.toggleViewBtn?.setBackgroundColor(WMColor.light_blue, size: CGSizeMake(71, 22), forUIControlState: UIControlState.Normal)
        self.toggleViewBtn!.setTitle(NSLocalizedString("store.showtable",comment:""), forState: .Normal)
        self.toggleViewBtn!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.toggleViewBtn!.addTarget(self, action: #selector(StoreLocatorViewController.showTableView(_:)), forControlEvents: .TouchUpInside)
        self.toggleViewBtn!.backgroundColor = UIColor.clearColor()
        self.header!.addSubview(self.toggleViewBtn!)
        
        self.searchView = UIView(frame: CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, 72))
        self.searchView.hidden = true
        self.searchView.backgroundColor = UIColor.whiteColor()
        
        self.separator = CALayer()
        self.separator.backgroundColor = WMColor.light_light_gray.CGColor
        self.separator.frame = CGRectMake(0, self.searchView!.frame.maxY - 1, self.view.frame.width, 1)
        self.searchView.layer.insertSublayer(separator, atIndex: 0)
        self.view.addSubview(searchView)
    
        self.searchField = FormFieldSearch(frame: CGRectMake(16, 16, self.view.frame.width - 32, 40.0))
        self.searchField!.returnKeyType = .Search
        self.searchField!.autocapitalizationType = .None
        self.searchField!.autocorrectionType = .No
        self.searchField!.enablesReturnKeyAutomatically = true
        self.searchField!.placeholder = NSLocalizedString("store.search.placeholder",comment:"")
        self.searchField!.backgroundColor = WMColor.light_light_gray
        self.searchField!.delegate = self
        self.searchView.addSubview(self.searchField)
        
        self.clearButton = UIButton(type: .Custom)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Normal)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Highlighted)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Selected)
        self.clearButton!.addTarget(self, action: #selector(StoreLocatorViewController.clearSearch), forControlEvents: UIControlEvents.TouchUpInside)
        self.clearButton!.hidden = true
        self.searchField!.addSubview(self.clearButton!)

        self.clubCollectionLayout = UICollectionViewFlowLayout()
        self.clubCollectionLayout!.minimumInteritemSpacing = 0.0
        self.clubCollectionLayout!.minimumLineSpacing = 0.0
        
        self.clubCollection = UICollectionView(frame: CGRectMake(self.clubMap!.frame.minX, self.searchView!.frame.maxY, self.clubMap!.frame.width, self.clubMap!.frame.height - 60), collectionViewLayout: self.clubCollectionLayout!)
        self.clubCollection!.backgroundColor = UIColor.whiteColor()
        self.clubCollection!.registerClass(ClubLocatorTableViewCell.self, forCellWithReuseIdentifier: "club")
        self.clubCollection!.delegate = self
        self.clubCollection!.dataSource = self
        self.clubCollection!.hidden = true
        self.clubCollection!.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.clubCollection!.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.view.addSubview(self.clubCollection!)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StoreLocatorViewController.startRunning), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StoreLocatorViewController.stopRunning), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        self.loadAnnotations()
        self.clubCollection!.reloadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StoreLocatorViewController.hideTabBar), name: CustomBarNotification.HideBar.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StoreLocatorViewController.showTabBar), name: CustomBarNotification.ShowBar.rawValue, object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var bounds = self.view.bounds
        var height = bounds.height - self.header!.frame.height
        
        self.searchView.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, 72)
        self.separator.frame = CGRectMake(0, self.searchView!.bounds.maxY - 1, self.view.frame.width, 1)
        self.searchField.frame = CGRectMake(16, 16, self.view.frame.width - 32, 40.0)
        self.clearButton!.frame = CGRectMake(self.searchField.frame.width - 40 , 0, 48, 40)
        
        self.clubMap!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, height)
        self.clubCollection?.frame = CGRectMake(0.0, self.searchView!.frame.maxY, bounds.width, height - 72)
        if self.segmentedView!.frame.origin.y == 16 {
            self.segmentedView!.frame = CGRectMake(16.0, bounds.height - 84.0, 150.0, 22.0)
        }
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
        
        self.clubCollection?.reloadData()
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
            self.viewBgDetailView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(StoreLocatorViewController.mapViewUserDidTap as (StoreLocatorViewController) -> () -> ())))
            
            self.detailView = StoreView(frame:CGRectMake(0.0, 0.0, 256.0, 200.0))
            self.detailView!.delegate = self
            self.detailView!.setValues(annotation.storeEntity, userLocation: mapView.userLocation.location)
            let height = self.detailView!.retrieveCalculatedHeight()
            self.detailView!.frame = CGRectMake(0.0, 0.0, 256.0, height)
            self.detailView!.center = CGPointMake((self.viewBgDetailView!.frame.width/2), (self.viewBgDetailView!.frame.height/2) - 90.0)
            
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
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView){
        self.searchField.resignFirstResponder()
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
            self.searchView!.hidden = false
            self.isShowingMap = false
            //self.applyMapViewMemoryHotFix()
            
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHOW_LIST_STORE_LOCATOR.rawValue, label: "")
            
            
        }
        else {
            //Event
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
            self.toggleViewBtn?.setTitle(NSLocalizedString("store.showtable",comment:""), forState: .Normal)
            self.clubMap!.hidden = false
            self.clubCollection!.hidden = true
            self.searchView!.hidden = true
            self.searchField.resignFirstResponder()
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
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
        self.viewBgDetailView?.removeFromSuperview()
        self.viewBgDetailView = nil
        self.detailView?.removeFromSuperview()
        self.detailView = nil

        if !self.isShowingMap {
            self.toggleViewBtn?.setTitle(NSLocalizedString("store.showtable",comment:""), forState: .Normal)
            self.clubMap!.hidden = false
            self.clubCollection!.hidden = true
            self.searchView!.hidden = true
            self.searchField.resignFirstResponder()
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
    }
    
    func hideTabBar() {
    }
    
    override func back() {
        super.back()
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
        if self.clubMap!.hidden {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LIST_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_LIST_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BACK.rawValue, label: "")
        } else {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATORMAP_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATORMAP_NOAUTH.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
        }
        
        
    }
    
    //MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate : NSString = textField.text! as String
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        if txtAfterUpdate.length >= 25 {
            return false
        }
        
        self.items = self.searchForItems(txtAfterUpdate as String)
        self.clubCollection!.reloadData()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func searchForItems(textUpdate:String) -> [Store]? {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Store", inManagedObjectContext: context)
        if textUpdate != "" {
             self.clearButton?.hidden = false
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR address CONTAINS[cd] %@ OR telephone CONTAINS[cd] %@",textUpdate,textUpdate,textUpdate)
            self.searchField.layer.borderColor = WMColor.light_blue.CGColor
        }else{
            self.clearButton?.hidden = true
            self.searchField.layer.borderColor = WMColor.light_light_gray.CGColor
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        var result: [Store]? =  nil
        do{
            result =  try context.executeFetchRequest(fetchRequest) as? [Store]
            print(result)
            
        }catch{
            print("searchForItems Error")
        }
        return result
    }
    
    func clearSearch(){
        self.searchField!.text = ""
        self.searchField.layer.borderColor = WMColor.light_light_gray.CGColor
        self.clearButton?.hidden = true
        self.items = self.searchForItems("")
        self.clubCollection!.reloadData()
        self.clubCollection!.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.clubCollection!.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 0.0)
        self.clubCollection?.scrollToItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
    }
    
}
