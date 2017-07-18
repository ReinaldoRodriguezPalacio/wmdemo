//
//  SESugestedCar.swift
//  WalMart
//
//  Created by Vantis on 17/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class SESugestedCar: NavigationViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    var collection: UICollectionView?
    var loading: WMLoadingView?
    var empty: IPOGenericEmptyView!
    var emptyMGGR: IPOSearchResultEmptyView!
    
    var allProducts: [[String:Any]]? = []
    var productsBySection : [String:Any]? = [:]
    var searchWordBySection : [String]? = []

    var titleHeader: String?
    
    var firstOpen  = true
    var isLoading  = false
    var hasEmptyView = false
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SESEARCHRESULT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = WMColor.light_light_gray
        
        self.titleLabel?.text = titleHeader
        
        
        collection = getCollectionView()
        collection?.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: "SEproductSearch")
        collection?.register(SESectionHeaderCel.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collection?.allowsMultipleSelection = false
        
        collection!.dataSource = self
        collection!.delegate = self
        collection!.backgroundColor = UIColor.white
        
        
        
        self.view.addSubview(collection!)
        
        BaseController.setOpenScreenTagManager(titleScreen: self.titleHeader!, screenName: self.getScreenGAIName())
        
        cargaProductos()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        /*if loading == nil {
            self.loading = WMLoadingView(frame: CGRect(x: 11, y: 11, width: self.view.bounds.width, height: self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.white
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(true)
        }*/
        
        var startPoint = self.header!.frame.maxY
        
        var heightCollection = self.view.bounds.height - startPoint
        if !IS_IPAD {
            heightCollection -= 44
        }
        self.collection!.frame = CGRect(x: 0, y:startPoint, width:self.view.bounds.width, height: heightCollection)
        self.loading?.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
        
    }
    
    override func back(){
        if self.navigationController != nil {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func getCollectionView() -> UICollectionView {
        let customlayout = CSStickyHeaderFlowLayout()
            customlayout.disableStickyHeaders = false
            customlayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 56.0)
    //        let customlayout = UICollectionViewFlowLayout()
    //        customlayout.headerReferenceSize = CGSizeMake(0, 44);
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: customlayout)
    
            if #available(iOS 10.0, *) {
                collectionView.isPrefetchingEnabled = false
            }
    
        return collectionView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (searchWordBySection?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SESectionHeaderCel
            
            view.title = UILabel()
            view.title?.textAlignment = .center
            view.title?.text = searchWordBySection?[indexPath.section]
            view.addSubview(view.title!)
            view.backgroundColor = WMColor.light_gray
            
            return view
        }
        return UICollectionReusableView(frame: CGRect.zero)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: self.view.frame.width, height: 30)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 4
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Show loading cell and invoke service
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SEproductSearch", for: indexPath) as! ProductCollectionViewCell
        
        //cell.productShortDescriptionLabel?.text = "HOLA"
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:self.view.bounds.maxX/2, height:40)
    }
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    

    func cargaProductos(){
        
        let respuestaSESEarch = "{\"responseArray\":[{\"term\":\"agua\",\"products\":[{\"field\":\"19.0\",\"displayName\":\"Agua Gerber  4 l\",\"upc\":\"00750100098477\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100098477s.jpg\"},{\"field\":\"17.3\",\"displayName\":\"Agua Bonafont  6 l\",\"upc\":\"00075810400317\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00075810400317s.jpg\"},{\"field\":\"8.0\",\"displayName\":\"Agua Bonafont  1.5 l\",\"upc\":\"00075810400015\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00075810400015s.jpg\"},{\"field\":\"10.0\",\"displayName\":\"Agua Bonafont  2 l\",\"upc\":\"00075810400197\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00075810400197s.jpg\"},{\"field\":\"6.8\",\"displayName\":\"Agua Bonafont  1 l\",\"upc\":\"00075810410042\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00075810410042s.jpg\"},{\"field\":\"23.0\",\"displayName\":\"Agua Evian  1.5 l\",\"upc\":\"00006131400001\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00006131400001s.jpg\"},{\"field\":\"13.0\",\"displayName\":\"Agua Evian  500 ml\",\"upc\":\"00006131400003\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00006131400003s.jpg\"},{\"field\":\"18.0\",\"displayName\":\"Agua Evian  1 l\",\"upc\":\"00006131400007\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00006131400007s.jpg\"},{\"field\":\"53.0\",\"displayName\":\"TermÃ³metro Digital Omron  Contra Agua\",\"upc\":\"00007379624594\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00007379624594s.jpg\"},{\"field\":\"38.0\",\"displayName\":\"Agua Fiji  1 l\",\"upc\":\"00063256500002\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00063256500002s.jpg\"}]},{\"term\":\"pollo\",\"products\":[{\"field\":\"134.0\",\"displayName\":\"Alitas de pollo Tyson  sabor BBQ 700 g\",\"upc\":\"00750110069682\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750110069682s.jpg\"},{\"field\":\"92.0\",\"displayName\":\"Pechuga de pollo Tyson  sin hueso y sin piel 700 g\",\"upc\":\"00750110060603\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750110060603s.jpg\"},{\"field\":\"13.0\",\"displayName\":\"Caldo de pollo Knorr Suiza con cilantro 8 cubos\",\"upc\":\"00750100511987\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100511987s.jpg\"},{\"field\":\"17.9\",\"displayName\":\"Caldo de pollo Knorr Suiza 12 cubos\",\"upc\":\"00750100519649\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100519649s.jpg\"},{\"field\":\"17.0\",\"displayName\":\"Caldo de pollo Iberia  450 g\",\"upc\":\"00750100511234\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100511234s.jpg\"},{\"field\":\"14.0\",\"displayName\":\"Consomate  con pollo sabor original 12 cubos\",\"upc\":\"00750105921671\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750105921671s.jpg\"},{\"field\":\"29.0\",\"displayName\":\"Caldo de pollo Knorr Suiza 24 cubos\",\"upc\":\"00750100519929\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750100519929s.jpg\"},{\"field\":\"72.0\",\"displayName\":\"Flautas de pollo El Cazo  24 pzas\",\"upc\":\"00750104001741\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750104001741s.jpg\"},{\"field\":\"89.5\",\"displayName\":\"Tenders de pollo Tyson  empanizados 700 g\",\"upc\":\"00750110064796\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750110064796s.jpg\"},{\"field\":\"62.0\",\"displayName\":\"Taquitos de pollo Alamesa  congelados 24 pzas\",\"upc\":\"00750300491139\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750300491139s.jpg\"}]},{\"term\":\"leche\",\"products\":[{\"field\":\"15.2\",\"displayName\":\"Leche Lala Light 1 l\",\"upc\":\"00750102051535\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00750102051535s.jpg\"},{\"field\":\"7.2\",\"displayName\":\"Leche Alpura  sabor fresa 250 ml\",\"upc\":\"00000007500208\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007500208s.jpg\"},{\"field\":\"7.2\",\"displayName\":\"Leche Alpura  sabor vainilla 250 ml\",\"upc\":\"00000007500209\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007500209s.jpg\"},{\"field\":\"7.2\",\"displayName\":\"Leche Alpura  sabor chocolate 250 ml\",\"upc\":\"00000007500210\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007500210s.jpg\"},{\"field\":\"5.0\",\"displayName\":\"Gelatina de leche Danette  sabor fresa 100 g\",\"upc\":\"00000007503639\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007503639s.jpg\"},{\"field\":\"5.0\",\"displayName\":\"Gelatina de leche Danette  sabor vainilla 100 g\",\"upc\":\"00000007503640\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007503640s.jpg\"},{\"field\":\"6.0\",\"displayName\":\"Leche Lala entera 250 ml\",\"upc\":\"00000007504266\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007504266s.jpg\"},{\"field\":\"6.5\",\"displayName\":\"Leche Lala Yomi sabor chocolate 250 ml\",\"upc\":\"00000007504267\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007504267s.jpg\"},{\"field\":\"6.5\",\"displayName\":\"Leche Lala Yomi sabor fresa 250 ml\",\"upc\":\"00000007504268\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007504268s.jpg\"},{\"field\":\"6.5\",\"displayName\":\"Leche Lala Yomi sabor vainilla 250 ml\",\"upc\":\"00000007504269\",\"url\":\"https://super.walmart.com.mx/images/product-images/img_small/00000007504269s.jpg\"}]}]}"
        
        do{
        let jsonString = try JSONSerialization.jsonObject(with: respuestaSESEarch.data(using: .utf8)!, options: .allowFragments) as! [String:Any]
        
            allProducts = jsonString["responseArray"] as! [[String : Any]]
        
            searchWordBySection = []
            
            
            for i in 0..<allProducts!.count{
                for (key, value) in allProducts![i] {
                    // access all key / value pairs in dictionary
                    if key == "term"{
                        self.searchWordBySection?.append(String(describing: value))
                    }
                    if key == "products"{
                        let productos = allProducts![i]["products"] as! [[String:Any]]
                        for a in 0..<productos.count{
                            for (key,value) in productos[a]{
                                print(key)
                                print(value)
                            }
                        }
                    }
                }
            }
            
            
        }catch{
        print("Error en el Json")
        }
        
       /* if loading != nil{
            self.loading?.stopAnnimating()
            self.loading?.removeFromSuperview()
        }*/

        
    }
    
    


}
