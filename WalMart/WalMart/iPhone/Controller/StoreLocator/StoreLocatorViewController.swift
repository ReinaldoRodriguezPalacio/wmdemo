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
    var errorView: FormFieldErrorView?
    var separator: CALayer!
    var viewLoad : WMLoadingView!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_STORELOCATORMAP.rawValue
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clubMap!.showsUserLocation = true
        self.clubMap!.delegate = self
        
        self.titleLabel?.text = NSLocalizedString("moreoptions.title.StoreLocator",comment:"")
        
        self.coreLocationManager = CLLocationManager()
        if #available(iOS 8.0, *) {
            if(CLLocationManager.instancesRespond(to: #selector(CLLocationManager.requestWhenInUseAuthorization)))
            {
                self.coreLocationManager.requestWhenInUseAuthorization()
            }
        }
        
        self.segmentedView = UIView(frame: CGRect(x: 16,  y: self.header!.frame.maxY + 16,  width: 150.0, height: 22.0))
        self.segmentedView.layer.borderWidth = 1
        self.segmentedView.layer.cornerRadius = 11
        self.segmentedView.layer.borderColor = WMColor.light_blue.cgColor
        
        let titleMap = NSLocalizedString("store.selector.map", comment:"")
        btnMapView = UIButton(frame: CGRect(x: 1, y: 1, width: (self.segmentedView.frame.width / 2) - 1, height: self.segmentedView.frame.height - 2))
        btnMapView.setImage(UIImage(color: UIColor.white, size: btnMapView.frame.size), for: UIControlState())
        btnMapView.setImage(UIImage(color: WMColor.light_blue, size: btnMapView.frame.size), for: UIControlState.selected)
        btnMapView.setTitle(titleMap, for: UIControlState())
        btnMapView.setTitle(titleMap, for: UIControlState.selected)
        btnMapView.setTitleColor(UIColor.white, for: UIControlState.selected)
        btnMapView.setTitleColor(WMColor.light_blue, for: UIControlState())
        btnMapView.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnMapView.isSelected = true
        btnMapView.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnMapView.frame.size.width + 1, 0, 0.0);
        btnMapView.addTarget(self, action: #selector(StoreLocatorViewController.applyMapViewMemoryHotFix), for: UIControlEvents.touchUpInside)
        
        let titleSat = NSLocalizedString("store.selector.satelite", comment:"")
        btnSatView = UIButton(frame: CGRect(x: btnMapView.frame.maxX, y: 1, width: self.segmentedView.frame.width / 2, height: self.segmentedView.frame.height - 2))
        btnSatView.setImage(UIImage(color: UIColor.white, size: btnMapView.frame.size), for: UIControlState())
        btnSatView.setImage(UIImage(color: WMColor.light_blue, size: btnMapView.frame.size), for: UIControlState.selected)
        btnSatView.setTitleColor(UIColor.white, for: UIControlState.selected)
        btnSatView.setTitleColor(WMColor.light_blue, for: UIControlState())
        btnSatView.setTitle(titleSat, for: UIControlState())
        btnSatView.setTitle(titleSat, for: UIControlState.selected)
        btnSatView.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnSatView.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnMapView.frame.size.width + 1, 0, 0.0);
        btnSatView.addTarget(self, action: #selector(StoreLocatorViewController.applyMapViewMemoryHotFix), for: UIControlEvents.touchUpInside)
        
        self.segmentedView.clipsToBounds = true
        self.segmentedView.backgroundColor = UIColor.white
        self.segmentedView.addSubview(btnMapView)
        self.segmentedView.addSubview(btnSatView)
        self.view.addSubview(self.segmentedView!)
        
        self.toggleViewBtn = WMRoundButton()
        self.toggleViewBtn?.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        self.toggleViewBtn?.setBackgroundColor(WMColor.light_blue, size: CGSize(width: 71, height: 22), forUIControlState: UIControlState())
        self.toggleViewBtn!.setTitle(NSLocalizedString("store.showtable",comment:""), for: UIControlState())
        self.toggleViewBtn!.setTitleColor(UIColor.white, for: UIControlState())
        self.toggleViewBtn!.addTarget(self, action: #selector(StoreLocatorViewController.showTableView(_:)), for: .touchUpInside)
        self.toggleViewBtn!.backgroundColor = UIColor.clear
        self.header!.addSubview(self.toggleViewBtn!)
        
        self.searchView = UIView(frame: CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: 72))
        self.searchView.isHidden = true
        self.searchView.backgroundColor = UIColor.white
        
        self.separator = CALayer()
        self.separator.backgroundColor = WMColor.light_light_gray.cgColor
        self.separator.frame = CGRect(x: 0, y: self.searchView!.frame.maxY - 1, width: self.view.frame.width, height: 1)
        self.searchView.layer.insertSublayer(separator, at: 0)
        self.view.addSubview(searchView)
    
        self.searchField = FormFieldSearch(frame: CGRect(x: 16, y: 16, width: self.view.frame.width - 32, height: 40.0))
        self.searchField!.returnKeyType = .search
        self.searchField!.autocapitalizationType = .none
        self.searchField!.autocorrectionType = .no
        self.searchField!.enablesReturnKeyAutomatically = true
        self.searchField!.placeholder = NSLocalizedString("store.search.placeholder",comment:"")
        self.searchField!.backgroundColor = WMColor.light_light_gray
        self.searchField!.delegate = self
        self.searchView.addSubview(self.searchField)
        
        self.clearButton = UIButton(type: .custom)
        self.clearButton!.setImage(UIImage(named:"searchClear"), for: UIControlState())
        self.clearButton!.setImage(UIImage(named:"searchClear"), for: .highlighted)
        self.clearButton!.setImage(UIImage(named:"searchClear"), for: .selected)
        self.clearButton!.addTarget(self, action: #selector(StoreLocatorViewController.clearSearch), for: UIControlEvents.touchUpInside)
        self.clearButton!.isHidden = true
        self.searchField!.addSubview(self.clearButton!)

        self.clubCollectionLayout = UICollectionViewFlowLayout()
        self.clubCollectionLayout!.minimumInteritemSpacing = 0.0
        self.clubCollectionLayout!.minimumLineSpacing = 0.0
        
        self.clubCollection = UICollectionView(frame: CGRect(x: self.clubMap!.frame.minX, y: self.searchView!.frame.maxY, width: self.clubMap!.frame.width, height: self.clubMap!.frame.height - 60), collectionViewLayout: self.clubCollectionLayout!)
        self.clubCollection!.backgroundColor = UIColor.white
        self.clubCollection!.register(ClubLocatorTableViewCell.self, forCellWithReuseIdentifier: "club")
        self.clubCollection!.delegate = self
        self.clubCollection!.dataSource = self
        self.clubCollection!.isHidden = true
        self.clubCollection!.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.clubCollection!.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.view.addSubview(self.clubCollection!)

        NotificationCenter.default.addObserver(self, selector: #selector(StoreLocatorViewController.startRunning), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StoreLocatorViewController.stopRunning), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        self.invokeStoreLocatorService()
        
        NotificationCenter.default.addObserver(self, selector: #selector(StoreLocatorViewController.hideTabBar), name: NSNotification.Name(rawValue: CustomBarNotification.HideBar.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StoreLocatorViewController.showTabBar), name: NSNotification.Name(rawValue: CustomBarNotification.ShowBar.rawValue), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ShowBar.rawValue), object: nil)
        BaseController.setOpenScreenTagManager(titleScreen: NSLocalizedString("moreoptions.title.StoreLocator", comment: ""), screenName: WMGAIUtils.SCREEN_STORELOCATORMAP.rawValue)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var bounds = self.view.bounds
        var height = bounds.height - self.header!.frame.height
        
        self.searchView.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: 72)
        self.separator.frame = CGRect(x: 0, y: self.searchView!.bounds.maxY - 1, width: self.view.frame.width, height: 1)
        self.searchField.frame = CGRect(x: 16, y: 16, width: self.view.frame.width - 32, height: 40.0)
        self.clearButton!.frame = CGRect(x: self.searchField.frame.width - 40 , y: 0, width: 48, height: 40)
        
        self.clubMap!.frame = CGRect(x: 0.0, y: self.header!.frame.maxY, width: bounds.width, height: height)
        self.clubCollection?.frame = CGRect(x: 0.0, y: self.searchView!.frame.maxY, width: bounds.width, height: height - 72)
        if self.segmentedView!.frame.origin.y == 16 {
            self.segmentedView!.frame = CGRect(x: 16.0, y: bounds.height - 84.0, width: 150.0, height: 22.0)
        }
        if self.toggleViewBtn != nil {
            bounds = self.header!.frame
            height = bounds.height - 20.0
            self.toggleViewBtn!.frame = CGRect(x: bounds.width - 87.0, y: 10.0, width: 71.0, height: height)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.memoryHotFix()
        self.coreLocationManager.startUpdatingLocation()
        if !self.localizable {
            self.zoomMapLocation(self.clubMap!.userLocation)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.actionSheet != nil && self.actionSheet!.isVisible {
            let cancelIdx = self.actionSheet!.cancelButtonIndex
            self.actionSheet!.dismiss(withClickedButtonIndex: cancelIdx, animated: false)
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
    
    //MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !self.localizable {
            self.zoomMapLocation(userLocation)
        }
        if self.clubMap!.overlays.count > 0 && self.viewBgDetailView == nil {
            MapKitUtils.zoomMapView(toFitAnnotations: self.clubMap, animated: true)
        }
        
        self.clubCollection?.reloadData()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let storeAnnotation = annotation as? StoreAnnotation {
            var view =  mapView.dequeueReusableAnnotationView(withIdentifier: self.annotationIdentifier)
            if view == nil {
                view = MKAnnotationView(annotation: storeAnnotation, reuseIdentifier: self.annotationIdentifier)
                view!.isEnabled = true
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let latResult = view.annotation!.coordinate.latitude + 0.01
        let coordinateMap =  CLLocationCoordinate2DMake(latResult, view.annotation!.coordinate.longitude)
        let pointRect = MKCoordinateRegionMakeWithDistance(coordinateMap, 10000, 10000)
        let isSameCenter = self.currentSelected === view
        self.clubMap!.setRegion(pointRect, animated: true)
        if let annotation = view.annotation as? StoreAnnotation {
            
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATORMAP_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATORMAP_NOAUTH.rawValue, action:WMGAIUtils.ACTION_STOREDETAIL.rawValue, label: annotation.storeEntity!.name!)
            
        
            self.viewBgDetailView = UIView(frame:CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height))
            self.viewBgDetailView!.backgroundColor = UIColor.clear
            self.viewBgDetailView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(StoreLocatorViewController.mapViewUserDidTap as (StoreLocatorViewController) -> () -> ())))
            
            self.detailView = StoreView(frame:CGRect(x: 0.0, y: 0.0, width: 256.0, height: 200.0))
            self.detailView!.delegate = self
            self.detailView!.setValues(annotation.storeEntity, userLocation: mapView.userLocation.location)
            let height = self.detailView!.retrieveCalculatedHeight()
            self.detailView!.frame = CGRect(x: 0.0, y: 0.0, width: 256.0, height: height)
            self.detailView!.center = CGPoint(x: (self.viewBgDetailView!.frame.width/2), y: (self.viewBgDetailView!.frame.height/2) - 90.0)
            
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
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.image = UIImage(named: "pin")
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool){
        if !self.touchPosition {
            self.usrPositionBtn!.isSelected = false
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        self.touchPosition = false
    }
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items != nil ? self.items!.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "club", for: indexPath) as! ClubLocatorTableViewCell
        cell.setValues(self.items![indexPath.row], userLocation: self.clubMap!.userLocation.location)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return CGSizeMake(collectionView.frame.width, 250.0)
        let store = self.items![indexPath.row]
        return ClubLocatorTableViewCell.calculateCellHeight(forStore: store, width: collectionView.frame.width)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        self.searchField.resignFirstResponder()
    }

    //MARK: - Actions
    
    func mapViewUserDidTap() {
        self.mapViewUserDidTap(false)
    }
    
    func mapViewUserDidTap(_ gotoPosition: Bool) {
        
        if self.viewBgDetailView != nil {
            
            //Event
            
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
                    }
            })
        }
    }

    @IBAction func segmentedControlAction(_ segmentedControl:UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            
            //Event
           
            self.clubMap!.mapType = MKMapType.standard
        }
        if segmentedControl.selectedSegmentIndex == 1 {
            
            //Event
            
            self.clubMap!.mapType = MKMapType.hybrid
        }
    }

    @IBAction func showUserPosition() {
        self.usrPositionBtn!.isSelected = true
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATORMAP_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATORMAP_NOAUTH.rawValue, action: WMGAIUtils.ACTION_USER_CURRENT_LOCATION.rawValue , label:"")
        
        if self.viewBgDetailView != nil {
            self.mapViewUserDidTap(true)
        }else {
            self.zoomMapLocation(self.clubMap!.userLocation)
        }
    }

    @IBAction func showTableView(_ sender: AnyObject) {
        if self.isShowingMap {
            //Event

            self.toggleViewBtn?.setTitle(NSLocalizedString("store.showmap",comment:""), for: UIControlState())
            self.clubMap!.isHidden = true
            self.clubCollection!.isHidden = false
            self.searchView!.isHidden = false
            self.isShowingMap = false
            //self.applyMapViewMemoryHotFix()
            
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHOW_LIST_STORE_LOCATOR.rawValue, label: "")
            
            
        }
        else {
            //Event
            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ShowBar.rawValue), object: nil)
            self.toggleViewBtn?.setTitle(NSLocalizedString("store.showtable",comment:""), for: UIControlState())
            self.clubMap!.isHidden = false
            self.clubCollection!.isHidden = true
            self.searchView!.isHidden = true
            self.searchField.resignFirstResponder()
            self.isShowingMap = true
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SHOW_MAP_STORE_LOCATOR.rawValue, label: "")
        }
    }

    //MARK: - Utils
    
    func invokeStoreLocatorService() {
        
        self.showLoadingView()
        
        let storeService = StoreLocatorService()
        storeService.callService(
            { (response:[String:Any]) -> Void in
                print("Call StoreLocatorService success")
                self.removeLoadingView()
                self.updateAnnotations()
            },
            errorBlock: { (error:NSError) -> Void in
                print("Call StoreLocatorService error \(error)")
                self.removeLoadingView()
                self.updateAnnotations()
            }
        )
        
    }
    
    func updateAnnotations() {
        self.loadAnnotations()
        self.clubCollection!.reloadData()
    }
    
    func memoryHotFix() {
        if !self.btnMapView.isSelected {
            self.clubMap!.mapType = MKMapType.standard
            self.clubMap!.mapType = MKMapType.hybrid
        } else {
            self.clubMap!.mapType = MKMapType.hybrid
            self.clubMap!.mapType = MKMapType.standard
        }
    }
    
    func applyMapViewMemoryHotFix(){
        if !self.btnMapView.isSelected {
            self.btnMapView.isSelected = !self.btnMapView.isSelected
            self.btnSatView.isSelected = !self.btnSatView.isSelected


            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATORMAP_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATORMAP_NOAUTH.rawValue, action: WMGAIUtils.ACTION_MAP_TYPE.rawValue , label:"Satelite")

        } else {
            self.btnMapView.isSelected = !self.btnMapView.isSelected
            self.btnSatView.isSelected = !self.btnSatView.isSelected
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATORMAP_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATORMAP_NOAUTH.rawValue, action: WMGAIUtils.ACTION_MAP_TYPE.rawValue , label:"Map")

            
        }
        memoryHotFix()
    }
    
    func zoomMapLocation(_ userLocation: MKUserLocation! ){
        if userLocation.location != nil {
            self.usrPositionBtn?.isSelected = true
            self.touchPosition = true
            if self.localizable {
                let coordinateMap =  CLLocationCoordinate2DMake(userLocation.coordinate.latitude
                    + 0.01, userLocation.coordinate.longitude)
                let pointRect = MKCoordinateRegionMakeWithDistance(coordinateMap, userLocation.location!.horizontalAccuracy + 20001 , userLocation.location!.horizontalAccuracy + 20000 )
                self.clubMap!.setRegion(pointRect, animated: true)
            }
            self.localizable = true
            let delay = 0.8 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                let coordinateMap =  CLLocationCoordinate2DMake(userLocation.coordinate.latitude
                    + 0.01, userLocation.coordinate.longitude)
                let pointRect = MKCoordinateRegionMakeWithDistance(coordinateMap, userLocation.location!.horizontalAccuracy + 20000 , userLocation.location!.horizontalAccuracy + 20000 )
                self.clubMap!.setRegion(pointRect, animated: true)
                
                self.usrPositionBtn?.isSelected = true
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

        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Store", in: context)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let result: [Store] = (try! context.fetch(fetchRequest)) as! [Store]
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
                launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving as AnyObject]
            }
            else {
                launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking as AnyObject]
            }
            // Get the "Current User Location" MKMapItem
            let currentLocationMapItem = MKMapItem.forCurrentLocation()
            // Pass the current location and destination map items to the Maps app
            // Set the direction mode in the launchOptions dictionary
            MKMapItem.openMaps(with: [currentLocationMapItem, mapItem], launchOptions: launchOptions!)
            self.selectedStore = nil
        }
    }
    
    func openGoogleMaps(forCar flag:Bool) {
        //comgooglemaps://?saddr=2025+Garcia+Ave,+Mountain+View,+CA,+USA&daddr=Google,+1600+Amphitheatre+Parkway,+Mountain+View,+CA,+United+States&center=37.423725,-122.0877&directionsmode=walking&zoom=17
        // driving, transit, bicycling or walking.
        if self.selectedStore != nil {
            let gmapsInstalled = UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
            if gmapsInstalled {
                let coordinate = CLLocationCoordinate2DMake(self.selectedStore!.latitude!.doubleValue, self.selectedStore!.longitude!.doubleValue)
                let mode = flag ? "driving" : "walking"
                var string = String(format: "comgooglemaps://?daddr=%f,%f&directionsmode=%@", coordinate.latitude, coordinate.longitude, mode) as NSString
                string = string.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
                let url = URL(string: string as String)
                UIApplication.shared.openURL(url!)
            }
            self.selectedStore = nil
        }
    }
    
    func showLoadingView() {
        
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0.0, y: self.header!.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.header!.frame.maxY))
        self.viewLoad!.backgroundColor = UIColor.white
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(self.isVisibleTab)
    }
    
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }

    //MARK: - StoreViewDelegate
    
    func showInstructions(_ store:Store, forCar flag:Bool) {
        self.selectedStore = store
        //Event
        
        
        let gmapsInstalled = UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
        if gmapsInstalled {
            self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.actionSheet!.actionSheetStyle = .automatic
            self.actionSheetGmaps = self.actionSheet!.addButton(withTitle: "Google Maps")
            self.actionSheetAmaps = self.actionSheet!.addButton(withTitle: "Apple Maps")
            let cancelIdx = self.actionSheet!.addButton(withTitle: "Cancel")
            self.actionSheet!.cancelButtonIndex = cancelIdx
            self.instructionsForCar = flag
            self.actionSheet!.show(in: self.view)
       }
        else {
            self.openAppleMaps(forCar: flag)
        }
    }
    
    func makeCallForStore(_ store:Store) {
        if let phone = store.telephone {
            
            let values = phone.components(separatedBy: "/")
            if values.count > 0 {
                var telephoneString = values[0] as String
                if !telephoneString.isEmpty {
                    if let range = telephoneString.range(of: "AL", options: .caseInsensitive, range: nil, locale: nil) {
                        telephoneString = telephoneString.substring(to: range.lowerBound)
                    }
                    let phoneStr = telephoneString.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789-+()").inverted) as NSString
                    print(phoneStr)
                    let resultStr = phoneStr.addingPercentEscapes(using: String.Encoding.utf8.rawValue)
                    let strTel = "telprompt://\(resultStr!)"
                    if UIApplication.shared.canOpenURL(URL(string: strTel)!) {
                        UIApplication.shared.openURL(URL(string: strTel)!)
                    }
                }
            }
        }
    }

    func shareStore(_ store:Store) {
        let telephoneText = String(format: NSLocalizedString("store.telephone", comment:""), store.telephone!)
        let opensText = String(format: NSLocalizedString("store.opens", comment:""), store.opens!)
        let textSend = "\(store.name!)\n\n\(store.address!) CP: \(store.zipCode!)\n\n\(telephoneText)\n\(opensText)"
        
        let controller = UIActivityViewController(activityItems: [textSend], applicationActivities: nil)
        self.navigationController?.present(controller, animated: true, completion: nil)
        
        if #available(iOS 8.0, *) {
            controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        } else {
            controller.completionHandler = {(activityType, completed:Bool) in
                if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                    BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
                }
            }
        }
    }

    func showInMap(_ store:Store) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ShowBar.rawValue), object: nil)
        self.viewBgDetailView?.removeFromSuperview()
        self.viewBgDetailView = nil
        self.detailView?.removeFromSuperview()
        self.detailView = nil

        if !self.isShowingMap {
            self.toggleViewBtn?.setTitle(NSLocalizedString("store.showtable",comment:""), for: UIControlState())
            self.clubMap!.isHidden = false
            self.clubCollection!.isHidden = true
            self.searchView!.isHidden = true
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
    
    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int){
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ShowBar.rawValue), object: nil)
        if self.clubMap!.isHidden {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_LIST_STORELOCATOR_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_LIST_STORELOCATOR_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BACK.rawValue, label: "")
        } else {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_STORELOCATORMAP_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_STORELOCATORMAP_NOAUTH.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate : NSString = textField.text! as String as NSString
        txtAfterUpdate = txtAfterUpdate.replacingCharacters(in: range, with: string) as NSString
        if txtAfterUpdate.length >= 25 {
            return false
        }
        
        if self.validateSearch(txtAfterUpdate  as String){
            self.items = self.searchForItems(txtAfterUpdate as String)
            self.clubCollection!.reloadData()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func searchForItems(_ textUpdate:String) -> [Store]? {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Store", in: context)
        if textUpdate != "" && "walmart ".lowercased().range(of: textUpdate) == nil {
            var textToSearch = textUpdate.lowercased()
            textToSearch = textToSearch.replacingOccurrences(of: "walmart ", with: "")
            self.clearButton?.isHidden = false
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR address CONTAINS[cd] %@ OR telephone CONTAINS[cd] %@ OR zipCode CONTAINS[cd] %@",textToSearch,textToSearch,textToSearch,textToSearch)
            self.searchField.layer.borderColor = WMColor.light_blue.cgColor
        }else{
            self.clearButton?.isHidden = true
            self.searchField.layer.borderColor = WMColor.light_light_gray.cgColor
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        var result: [Store]? =  nil
        do{
            result =  try context.fetch(fetchRequest) as? [Store]
            print(result!)
            
        }catch{
            print("searchForItems Error")
        }
        return result
    }
    
    func validateSearch(_ toValidate:String) -> Bool{
        let regString : String = "^[A-Z0-9a-zñÑÁáÉéÍíÓóÚú ]{0,100}[._-]{0,2}$";
        return validateRegEx(regString,toValidate:toValidate)
    }
    
    func validateRegEx(_ pattern:String,toValidate:String) -> Bool {
        
        var regExVal: NSRegularExpression?
        do {
            regExVal = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        } catch {
            regExVal = nil
        }
        let matches = regExVal!.numberOfMatches(in: toValidate, options: [], range: NSMakeRange(0, toValidate.characters.count))
        
        if matches > 0 {
            if self.errorView?.superview != nil {
                self.errorView?.removeFromSuperview()
            }
            self.errorView?.focusError = nil
            self.errorView = nil
            return true
        }
        
        if self.errorView == nil{
            self.errorView = FormFieldErrorView()
        }
        SignUpViewController.presentMessage(self.searchField!, nameField:"Busqueda", message: "Texto no permitido" , errorView:self.errorView! , becomeFirstResponder: true)
        
        return false
    }
    
    func clearSearch(){
        self.searchField!.text = ""
        self.searchField.layer.borderColor = WMColor.light_light_gray.cgColor
        self.clearButton?.isHidden = true
        self.items = self.searchForItems("")
        self.clubCollection!.reloadData()
        self.clubCollection!.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.clubCollection!.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 0.0)
        self.clubCollection?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
}
