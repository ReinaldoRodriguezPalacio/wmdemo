//
//  SearchTiresIniViewController.swift
//  WalMart
//
//  Created by Vantis on 09/03/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit

class SearchTiresIniViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,AlertPickerViewDelegate,UITextFieldDelegate, UIScrollViewDelegate {
    


    var contentCollectionOffset: CGPoint?
    var collection: UICollectionView?
    var loading: WMLoadingView?
    var searchButton: UIButton!
    var empty: IPOGenericEmptyView!
    var emptyMGGR: IPOSearchResultEmptyView!
    lazy var mgResults: SearchResult? = SearchResult()
    lazy var grResults: SearchResult? = SearchResult()
    var allProducts: [[String:Any]]? = []
    var upcsToShow : [String]? = []
    var upcsToShowApply : [String]? = []
    var flagtest = true
    var eventCode: String?
    
    var titleHeader: String?
    var originalSort: String?
    var originalSearchContextType: SearchServiceContextType?
    var searchContextType: SearchServiceContextType?
    var searchFromContextType: SearchServiceFromContext?
    var textToSearch:String?
    var idDepartment:String?
    var idFamily :String?
    var idLine:String?
    var idSort:String?
    var maxResult: Int = 20
    var brandText: String? = ""
    var alertView : IPOWMAlertViewController? = nil
    
    var bannerView : UIImageView!
    var maxYBanner: CGFloat = 46.0
    var isLandingPage = false
    var landingPageMG : [String:Any]?
    var landingPageGR : [String:Any]?
    var controllerLanding : LandingPageViewController?
    
    var viewBackButton: UIView!
    var lbltitle:UILabel!
    var btnCerrarModulo:UIButton!
    
    var containerView:UIView!
    var listaFiltros:UITableView!
    var viewBuscaLlanta:UIView!
    var porMedidaView:UIView!
    let cellReuseIdendifier = "cell"
    var headerNew:CGFloat = 0
    var items:[String]!
    var anios:[String]! = []
    var marcas:[String]! = []
    var modelos:[String]! = []
    var versiones:[String]! = []
    var medidas:[String]! = []
    var medidaLlanta:UILabelX!
    var marcaSelectionFilter:String!
    var modeloSelectionFilter:String!
    var anioSelectionFilter:String!
    var versionSelectionFilter:String!
    var medidaSelectionFilter:String!
    
    var picker : AlertPickerView!
    var anchura : FormFieldView!
    var valAnchuras : [String]! = []
    var selectedAnchura : IndexPath!
    var aspecto : FormFieldView!
    var valAspectos : [String]! = []
    var selectedAspecto : IndexPath!
    var diametro : FormFieldView!
    var valDiametros : [String]! = []
    var selectedDiametro : IndexPath!
    
    var leftRightPadding  : CGFloat = CGFloat(16)
     var fieldHeight  : CGFloat = CGFloat(30)
    var filterHeight :  CGFloat = CGFloat(40)
    var lblTitle:UILabel!
    var countFilter:Int=0
    var instruccionesView:UIView!
    var lblInstrucciones:UILabel!
    var imageLlanta:UIImageView!
    var delegateFormAdd : FormSuperAddressViewDelegate!
    var viewLoad : WMLoadingView!
    
    var viewBgSelectorBtn : UIView!
    var btnModelo : UIButton!
    var btnMedida : UIButton!
    var facet : [[String:Any]]!
    var facetGr : [Any]? = nil
    
    var firstOpen  = true
    var isLoading  = false
    var hasEmptyView = false
    
    var itemsUPCMG: [[String:Any]]? = []
    var itemsUPCGR: [[String:Any]]? = []
    var itemsUPCMGBk: [[String:Any]]? = []
    var itemsUPCGRBk: [[String:Any]]? = []
    
    var didSelectProduct =  false
    var finsihService =  false
    
    var selectQuantityGR : GRShoppingCartQuantitySelectorView!
    var selectQuantity : ShoppingCartQuantitySelectorView!
    var isTextSearch: Bool = false
    var isOriginalTextSearch: Bool = false
    
    var findUpcsMg: [Any]? = []
    
    var idListFromSearch : String? = ""
    var invokeServiceInError = false
    var viewEmptyImage =  false
    
    var selectQuantityOpen = false
    var isAplyFilter : Bool =  false
    var removeEmpty =  false
    var searchAlertView: SearchAlertView? = nil
    var showAlertView = false
    var mgResponceDic: [String:Any] = [:]
    var grResponceDic: [String:Any] = [:]
    var position = 0
    
    var changebtns  =  false
    var validate = false
    var mgServiceIsInvike =  false
    //tap Priority
    var priority = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker = AlertPickerView.initPickerWithDefault()
        self.view.backgroundColor = UIColor.white
        let rightPadding = leftRightPadding * 2

        viewBackButton = UIView(frame: CGRect(x: 0,  y: 0, width: self.view.bounds.width, height: 50))
        viewBackButton.backgroundColor=UIColor (red: 40/255.0, green: 112/255.0, blue: 201/255.0, alpha: 0.8)
        
        lbltitle = UILabel(frame: CGRect(x: 15, y: 10, width: viewBackButton.frame.size.width-50 , height: 30))
        lbltitle.textColor = UIColor.white
        lbltitle.text = "Buscador de Llantas"
        
        btnCerrarModulo = UIButton(frame: CGRect(x: viewBackButton.frame.size.width-40, y: 10, width: 30, height: 30))
        btnCerrarModulo.setImage(UIImage(named: "closeScan"), for: UIControlState.normal)
        btnCerrarModulo.addTarget(self, action: #selector(self.cierraModal(_:)), for: UIControlEvents.touchUpInside)
        
        viewBackButton.addSubview(btnCerrarModulo)
        viewBackButton.addSubview(lbltitle)
        self.view.addSubview(viewBackButton)
        
        viewBgSelectorBtn = UIView(frame: CGRect(x: 16,  y: 60, width: 288, height: 28))
        viewBgSelectorBtn.layer.borderWidth = 1
        viewBgSelectorBtn.layer.cornerRadius = 14
        viewBgSelectorBtn.layer.borderColor = WMColor.light_blue.cgColor
        
        let titleModelo = NSLocalizedString("llantas.message.modelo",comment:"")
        btnModelo = UIButton(frame: CGRect(x: 1, y: 1, width: (viewBgSelectorBtn.frame.width / 2) , height: viewBgSelectorBtn.frame.height - 2))
        btnModelo.setImage(UIImage(color: UIColor.white, size: btnModelo.frame.size), for: UIControlState())
        btnModelo.setImage(UIImage(color: WMColor.light_blue, size: btnModelo.frame.size), for: UIControlState.selected)
        btnModelo.setTitle(titleModelo, for: UIControlState())
        btnModelo.setTitle(titleModelo, for: UIControlState.selected)
        btnModelo.setTitleColor(UIColor.white, for: UIControlState.selected)
        btnModelo.setTitleColor(WMColor.light_blue, for: UIControlState())
        btnModelo.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnModelo.isSelected = true
        btnModelo.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnModelo.frame.size.width + 1, 0, 0.0);
        btnModelo.addTarget(self, action: #selector(self.buscaxModelo(_:)), for: UIControlEvents.touchUpInside)
        
        let titleMedida = NSLocalizedString("llantas.message.medida",comment:"")
        btnMedida = UIButton(frame: CGRect(x: btnModelo.frame.maxX, y: 1, width: viewBgSelectorBtn.frame.width / 2, height: viewBgSelectorBtn.frame.height - 2))
        btnMedida.setImage(UIImage(color: UIColor.white, size: btnModelo.frame.size), for: UIControlState())
        btnMedida.setImage(UIImage(color: WMColor.light_blue, size: btnModelo.frame.size), for: UIControlState.selected)
        btnMedida.setTitleColor(UIColor.white, for: UIControlState.selected)
        btnMedida.setTitleColor(WMColor.light_blue, for: UIControlState())
        btnMedida.setTitle(titleMedida, for: UIControlState())
        btnMedida.setTitle(titleMedida, for: UIControlState.selected)
        btnMedida.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnMedida.isSelected = false
        btnMedida.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnModelo.frame.size.width , 0, 0.0);
        btnMedida.addTarget(self, action: #selector(self.buscaxMedida(_:)), for: UIControlEvents.touchUpInside)
        
        viewBgSelectorBtn.clipsToBounds = true
        viewBgSelectorBtn.backgroundColor = UIColor.white
        viewBgSelectorBtn.addSubview(btnModelo)
        viewBgSelectorBtn.addSubview(btnMedida)
        if self.idListFromSearch == ""{
            self.view.addSubview(viewBgSelectorBtn)
        }
        
        // Do any additional setup after loading the view.
    //anios=["2017","2016","2015","2014","2013","2012","2011","2010","2009","2008","2007","2006","2005","2004","2003","2002","2001","2000"]
        //marcas=["Susuki","Toyota","Chevrolet"]
        //modelos=["A8","Campirano","737"]
        //versiones=["familiar","robusta","indicada"]
        
        
        containerView = UIView(frame: CGRect(x: 0,  y: 100, width: self.view.bounds.width, height: self.view.bounds.height-210))
        containerView.backgroundColor=UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        
        //BUSQUEDA POR FILTRADO
        listaFiltros=UITableView(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height))
        listaFiltros.register(FilterTiresTableViewCell.self, forCellReuseIdentifier: cellReuseIdendifier)
        listaFiltros.backgroundColor=WMColor.light_gray
        
        listaFiltros.tag=1000
        
        
        //BUSQUEDA POR MEDIDA
        porMedidaView=UIView(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height))
        porMedidaView.accessibilityScroll(.down)
        instruccionesView=UIView(frame: CGRect(x:0, y: 0, width: porMedidaView.frame.size.width , height: 50))
        instruccionesView.backgroundColor=WMColor.blue
        lblInstrucciones = UILabel(frame: CGRect(x:0, y: 10, width: instruccionesView.frame.size.width*0.9 , height: 40))
        lblInstrucciones.numberOfLines=0
        lblInstrucciones.font=UIFont.boldSystemFont(ofSize: 12)
        lblInstrucciones.textColor = .white
        lblInstrucciones.textAlignment = .center
        lblInstrucciones.text=NSLocalizedString("llantas.message.instrucciones",comment:"")
        lblInstrucciones.center = instruccionesView.center
        
        instruccionesView.addSubview(lblInstrucciones)
        
        let image = UIImage(named: "llanta.png")
        imageLlanta = UIImageView(image: image!)
        imageLlanta.frame = CGRect(x: 0, y: 50, width: porMedidaView.frame.size.width, height: 90)
        
        medidaLlanta=UILabelX(frame: CGRect(x: 0, y: 35, width: imageLlanta.frame.size.width , height: imageLlanta.frame.size.height*3))
        medidaLlanta.text="---/--R--"
        medidaLlanta.textColor=UIColor.white
        medidaLlanta.font=UIFont.systemFont(ofSize: 14)
        medidaLlanta.clockwise=true
        medidaLlanta.angle=1.6
        imageLlanta.addSubview(medidaLlanta)
        let selectionFrame = UIView(frame: CGRect(x:0, y: 140, width: porMedidaView.frame.size.width , height: porMedidaView.frame.size.height-instruccionesView.frame.size.height-imageLlanta.frame.size.height))
        
        let lblAnchura = UILabel(frame: CGRect(x:leftRightPadding, y: 5, width: selectionFrame.frame.size.width - rightPadding , height: 15))
        lblAnchura.text = NSLocalizedString("llantas.message.medida.anchura",comment:"")
        lblAnchura.textColor=WMColor.light_blue
        lblAnchura.font=WMFont.fontMyriadProLightOfSize(14)
        anchura = FormFieldView()
        anchura.isRequired = true
        anchura.setCustomPlaceholder(NSLocalizedString("llantas.message.medida.anchura",comment:""))
        anchura.typeField = TypeField.list
        anchura.nameField = NSLocalizedString("llantas.field.medida.anchura",comment:"")
        anchura.frame = CGRect(x: leftRightPadding, y: 25 , width: selectionFrame.frame.size.width - rightPadding , height: fieldHeight)
        
        
        let lblAspecto = UILabel(frame: CGRect(x:leftRightPadding, y: anchura.frame.origin.y+anchura.frame.size.height+fieldHeight/2, width: selectionFrame.frame.size.width - rightPadding , height: 15))
        lblAspecto.text = NSLocalizedString("llantas.message.medida.aspecto",comment:"")
        lblAspecto.textColor=WMColor.light_blue
        lblAspecto.font=WMFont.fontMyriadProLightOfSize(14)
        aspecto = FormFieldView()
        aspecto.isRequired = true
        aspecto.setCustomPlaceholder(NSLocalizedString("llantas.message.medida.aspecto",comment:""))
        aspecto.typeField = TypeField.list
        aspecto.nameField = NSLocalizedString("llantas.field.medida.aspecto",comment:"")
        aspecto.frame = CGRect(x: leftRightPadding, y: anchura.frame.origin.y + anchura.frame.size.height + fieldHeight , width: selectionFrame.frame.size.width - rightPadding , height: fieldHeight)
        
        
        let lblDiametro = UILabel(frame: CGRect(x:leftRightPadding, y: aspecto.frame.origin.y+aspecto.frame.size.height+fieldHeight/2, width: selectionFrame.frame.size.width - rightPadding , height: 15))
        lblDiametro.text = NSLocalizedString("llantas.message.medida.diametro",comment:"")
        lblDiametro.textColor=WMColor.light_blue
        lblDiametro.font=WMFont.fontMyriadProLightOfSize(14)
        diametro = FormFieldView()
        diametro.isRequired = true
        diametro.setCustomPlaceholder(NSLocalizedString("llantas.message.medida.diametro",comment:""))
        diametro.typeField = TypeField.list
        diametro.nameField = NSLocalizedString("llantas.field.medida.diametro",comment:"")
        diametro.frame = CGRect(x: leftRightPadding, y: aspecto.frame.origin.y + aspecto.frame.size.height + fieldHeight , width: selectionFrame.frame.size.width - rightPadding , height: fieldHeight)
        
        searchButton = UIButton(type: .custom)
        searchButton!.addTarget(self, action: #selector(SearchTiresBySize(_:)), for: .touchUpInside)
        searchButton.tintColor = UIColor.white
        searchButton.setTitle("Buscar" , for: UIControlState.normal)
        searchButton.backgroundColor = WMColor.light_blue
        searchButton.layer.cornerRadius = 14.0
        
        searchButton.setTitleColor(UIColor.white, for: UIControlState())
        searchButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0)
        searchButton.frame = CGRect(x: selectionFrame.frame.size.width/2 - 60 , y: diametro.frame.origin.y + diametro.frame.size.height + fieldHeight/3, width: 120, height:28)
        searchButton.titleLabel?.font=UIFont.systemFont(ofSize: 12)
        
        selectionFrame.addSubview(lblAnchura)
        selectionFrame.addSubview(anchura)
        selectionFrame.addSubview(lblAspecto)
        selectionFrame.addSubview(aspecto)
        selectionFrame.addSubview(lblDiametro)
        selectionFrame.addSubview(diametro)
        selectionFrame.addSubview(searchButton)
        
        
        anchura.onBecomeFirstResponder = { () in
            
                    if self.valAnchuras.count > 0 {
                        //self.anchura!.text = self.valAnchuras[0]
                        self.selectedAnchura = IndexPath(row: 0, section: 0)
                        self.picker!.selected = self.selectedAnchura
                        self.picker!.sender = self.anchura!
                        self.picker!.delegate = self
                        self.picker!.setValues(self.anchura!.nameField, values: self.valAnchuras)
                        self.picker!.showPicker()
                    }
        }
        
        aspecto.onBecomeFirstResponder = { () in
            
            if self.valAspectos.count > 0 {
               // self.aspecto!.text = self.valAspectos[0]
                self.selectedAspecto = IndexPath(row: 0, section: 0)
                self.picker!.selected = self.selectedAspecto
                self.picker!.sender = self.aspecto!
                self.picker!.delegate = self
                self.picker!.setValues(self.aspecto!.nameField, values: self.valAspectos)
                self.picker!.showPicker()
            }
        }
        
        diametro.onBecomeFirstResponder = { () in
            
            if self.valDiametros.count > 0 {
               // self.diametro!.text = self.valDiametros[0]
                self.selectedDiametro = IndexPath(row: 0, section: 0)
                self.picker!.selected = self.selectedDiametro
                self.picker!.sender = self.diametro!
                self.picker!.delegate = self
                self.picker!.setValues(self.diametro!.nameField, values: self.valDiametros)
                self.picker!.showPicker()
            }
        }
        
        porMedidaView.addSubview(instruccionesView)
        porMedidaView.addSubview(imageLlanta)
        porMedidaView.addSubview(selectionFrame)
        
        containerView.addSubview(listaFiltros)
        
        containerView.tag=500
        self.view.addSubview(containerView)        // add child view controller view to container
        
        self.invokeTiresMarcasService()
        //self.invokeTiresSizeSearchService()
        
    }
    
    func didSelectOption(_ picker:AlertPickerView, indexPath:IndexPath ,selectedStr:String) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  anchura! {
                anchura!.text = selectedStr
                self.selectedAnchura = indexPath
                if delegateFormAdd != nil {
                    self.delegateFormAdd.showUpdate()
                }
            }
            if formFieldObj ==  aspecto! {
                aspecto!.text = selectedStr
                self.selectedAspecto = indexPath
                if delegateFormAdd != nil {
                    self.delegateFormAdd.showUpdate()
                }
            }
            if formFieldObj ==  diametro! {
                diametro!.text = selectedStr
                self.selectedAspecto = indexPath
                if delegateFormAdd != nil {
                    self.delegateFormAdd.showUpdate()
                }
            }
            medidaLlanta.text=anchura.text!+"/"+aspecto.text!+"R"+diametro.text!
        }
    }
    
    func didDeSelectOption(_ picker:AlertPickerView) {
        if let formFieldObj = picker.sender as? FormFieldView {
            if formFieldObj ==  anchura! {
                anchura!.text = ""
                medidaLlanta.text="---/"+aspecto.text!+"R"+diametro.text!
            }
            if formFieldObj ==  aspecto! {
                aspecto!.text = ""
                medidaLlanta.text=anchura.text!+"/--R"+diametro.text!
            }
            if formFieldObj ==  diametro! {
                diametro!.text = ""
                medidaLlanta.text=anchura.text!+"/"+aspecto.text!+"R--"
            }
        }
    }

    func viewReplaceContent(_ frame:CGRect) -> UIView! {
        return UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func cierraModal(_ sender:UIButton) {
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    
    func buscaxModelo(_ sender:UIButton) {
        porMedidaView.removeFromSuperview()
        countFilter=0
        headerNew=0
        items=marcas
        listaFiltros.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height)
        listaFiltros.reloadData()
        listaFiltros.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.none, animated: true)
        listaFiltros.backgroundColor=WMColor.light_gray
        
        containerView.addSubview(listaFiltros)
        sender.isSelected=true
        btnMedida.isSelected=false
    }
    
    func buscaxMedida(_ sender:UIButton) {
        for views in containerView.subviews{
            views.removeFromSuperview()
        }
        containerView.addSubview(porMedidaView)
        self.invokeTiresSizeSearchService()
        sender.isSelected=true
        btnModelo.isSelected=false
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Do any additional setup after loading the view, typically from a nib.
        
        var boldText=""
        
        switch countFilter {
        case 0:
            boldText = "Marca: "
            marcaSelectionFilter = marcas[indexPath.row]
            break
        case 1:
            boldText = "Modelo: "
            modeloSelectionFilter = modelos[indexPath.row]
            break
        case 2:
            boldText = "Año: "
            anioSelectionFilter = anios[indexPath.row]
            break
        case 3:
            boldText = "Versión: "
            versionSelectionFilter = versiones[indexPath.row]
            break
        case 4:
            medidaSelectionFilter = medidas[indexPath.row]
            break
        default:
            boldText = "Marca: "
        }
        if countFilter < 4 {
            let newFilter = UIView(frame: CGRect(x: 0,  y: headerNew, width: containerView.frame.size.width, height: filterHeight))
            newFilter.backgroundColor=UIColor (red: 247/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1.0)
            lblTitle = UILabel(frame: CGRect(x:0, y: 5, width: newFilter.frame.size.width , height: 30))
            lblTitle.textAlignment = .center
            
            

        let attrs = [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(13)]
        let attrsNormal = [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(13)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
        let normalText = items[indexPath.row]
        let normalString = NSMutableAttributedString(string:normalText, attributes:attrsNormal)
        attributedString.append(normalString)
        
        lblTitle.attributedText = attributedString
        let btnQuitaFiltro = UIButton(frame: CGRect(x: newFilter.frame.size.width-40, y: 10, width: 20, height: 20))
        btnQuitaFiltro.setImage(UIImage(named: "cancelFilter"), for: UIControlState.normal)
        //btnQuitaFiltro.setTitle("X", for: UIControlState.normal)
        btnQuitaFiltro.setTitleColor(UIColor.black, for: .normal)
        btnQuitaFiltro.addTarget(self, action: #selector(self.quitaFiltro(_:)), for: UIControlEvents.touchUpInside)
        btnQuitaFiltro.tag=countFilter
        newFilter.tag=countFilter
        newFilter.addSubview(btnQuitaFiltro)
        newFilter.addSubview(lblTitle)
        headerNew+=filterHeight
        self.containerView.addSubview(newFilter)
            var rect:CGRect!
            rect = listaFiltros.frame
            UIView.animate(withDuration: 0.5, animations: {
                
                self.listaFiltros.frame = CGRect(x : 0, y : self.headerNew, width : rect.size.width, height: rect.size.height-self.filterHeight)
                
            })

        }
        countFilter += 1
        
        switch countFilter {
        case 1:
            self.invokeTiresModelsService(marca: marcas[indexPath.row])
            break
        case 2:
            self.invokeTiresAniosService(marca: marcaSelectionFilter!, modelo: modelos[indexPath.row])
            break
        case 3:
            self.invokeTiresVersionesService(marca: marcaSelectionFilter!, modelo: modeloSelectionFilter!, anio: anios[indexPath.row])
            break
        case 4:
            self.invokeTiresMedidasService(marca: marcaSelectionFilter!, modelo: modeloSelectionFilter!, anio: anioSelectionFilter!, version: versiones[indexPath.row])
            break
        case 5:
            viewBuscaLlanta = UIView(frame: CGRect(x: 0,  y: 0, width: listaFiltros.frame.size.width, height: 100))
            viewBuscaLlanta.backgroundColor=WMColor.light_gray
            
            let tituloFooter = UILabel(frame: CGRect(x:0, y: 5, width: viewBuscaLlanta.frame.size.width, height: 20))
            tituloFooter.text="El tamaño de tu llanta es:"
            tituloFooter.font=WMFont.fontMyriadProRegularOfSize(15)
            tituloFooter.textAlignment = .center
            
            let medidaFooter = UILabel(frame: CGRect(x:0, y: 30, width: viewBuscaLlanta.frame.size.width, height: 20))
            medidaFooter.text = medidas[indexPath.row]
            medidaFooter.font = WMFont.fontMyriadProBoldOfSize(15)
            medidaFooter.textColor=WMColor.light_blue
            medidaFooter.textAlignment = .center
            
            let buttonFooter = UIButton(type: .custom)
            buttonFooter.addTarget(self, action: #selector(cargaBusqueda(_:)), for: .touchUpInside)
            buttonFooter.tintColor = UIColor.white
            buttonFooter.setTitle("Ver productos" , for: UIControlState.normal)
            buttonFooter.backgroundColor = WMColor.green
            buttonFooter.layer.cornerRadius = 10.0
            
            buttonFooter.setTitleColor(UIColor.white, for: UIControlState())
            buttonFooter.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0)
            buttonFooter.frame = CGRect(x: viewBuscaLlanta.frame.size.width/2 - 120 , y: 60, width: 240, height:30)
            buttonFooter.titleLabel?.font=UIFont.systemFont(ofSize: 12)

            viewBuscaLlanta.addSubview(tituloFooter)
            viewBuscaLlanta.addSubview(medidaFooter)
            viewBuscaLlanta.addSubview(buttonFooter)
            listaFiltros.tableFooterView = viewBuscaLlanta
            
            countFilter=4
            break
        default:
            boldText = "Marca: "
        }
    }
    
    func cargaBusqueda(_ sender:UIButton){
        self.invokeTiresbySizeService(medida: medidaSelectionFilter)
    }

    func quitaFiltro(_ sender:UIButton) {
        var cuenta:Int = 0
        var aumento : CGFloat = 0
        if sender.tag > 0{
            
            print(countFilter)
            let viewWithTag = self.view.viewWithTag(sender.tag)
            for index in 0...countFilter-1 {
                let viewsTags = self.view.viewWithTag(index)
                print(viewsTags?.tag ?? index)
                print(viewWithTag?.tag ?? sender.tag)
                if (viewsTags?.tag)! >= (viewWithTag?.tag)!{
                    viewsTags?.removeFromSuperview()
                    headerNew-=filterHeight
                    cuenta+=1
                    aumento = aumento + filterHeight
                }
            }
            if countFilter==5{
                    aumento = aumento + filterHeight
            }
            countFilter-=cuenta
            print(countFilter)
            switch countFilter {
            case 0:
                items=marcas
                break
            case 1:
                items=modelos
                break
            case 2:
                items=anios
                break
            case 3:
                items=versiones
                break
            case 4:
                items=medidas
                break
            default:
                items=marcas
            }
            
            listaFiltros.reloadData()
            listaFiltros.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.none, animated: true)
            listaFiltros.tableFooterView?.isHidden=true
            var rect:CGRect!
            rect = listaFiltros.frame
            UIView.animate(withDuration: 0.5, animations: {
                
                self.listaFiltros.frame = CGRect(x : 0, y : self.headerNew, width : rect.size.width, height: rect.size.height + aumento)
                
            })
        }else{
            
            countFilter=0
            headerNew=0
            items=marcas
            containerView.removeFromSuperview()
            
            containerView = UIView(frame: CGRect(x: 0,  y: 100, width: self.view.bounds.width, height: self.view.bounds.height-110))
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            listaFiltros=UITableView(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height))
            listaFiltros.register(FilterTiresTableViewCell.self, forCellReuseIdentifier: cellReuseIdendifier)
            
            listaFiltros.delegate=self
            listaFiltros.dataSource=self
            listaFiltros.reloadData()
            listaFiltros.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.none, animated: true)
            listaFiltros.tag=1000
            listaFiltros.backgroundColor=WMColor.light_gray
            viewBuscaLlanta = UIView(frame: CGRect(x: 0,  y: 0, width: listaFiltros.frame.size.width, height: 100))
            viewBuscaLlanta.backgroundColor=WMColor.light_gray
            
            listaFiltros.tableFooterView = viewBuscaLlanta
            listaFiltros.tableFooterView?.isHidden=false
            containerView.addSubview(listaFiltros)
            containerView.tag=500
            self.view.addSubview(containerView)
            
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch countFilter {
        case 0:
            items=marcas
            break
        case 1:
            items=modelos
            break
        case 2:
            items=anios
            break
        case 3:
            items=versiones
            break
        case 4:
            items=medidas
            break
        default:
            items=marcas
        }
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! FilterTiresTableViewCell
        cell.myLabel.frame = CGRect(x: 0, y: 5, width: view.frame.size.width, height: 30)
        cell.myLabel.textAlignment = .center
        cell.myLabel.text = items[indexPath.row]
        cell.myLabel.font=WMFont.fontMyriadProRegularOfSize(13)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return filterHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        headerView.backgroundColor=UIColor (red: 34/255.0, green: 110/255.0, blue: 204/255.0, alpha: 1.0)
        
        let lblTitulo=UILabel(frame: CGRect(x: 0, y: 5, width: tableView.bounds.size.width, height: 30))
        lblTitulo.textColor=UIColor.white
        lblTitulo.textAlignment = .center
        lblTitulo.font = UIFont.systemFont(ofSize: 13)
        switch countFilter {
        case 0:
            lblTitulo.text="Marca"
            break
        case 1:
            lblTitulo.text="Modelo"
            break
        case 2:
            lblTitulo.text="Año"
            break
        case 3:
            lblTitulo.text="Versión"
            break
        case 4:
            lblTitulo.text="Medida"
            break
        default:
            lblTitulo.text="Marca"
        }
        headerView.addSubview(lblTitulo)
        return headerView
    }

    func saveReplaceViewSelected() {
    }
    
    func buttomViewSelected(_ sender: UIButton) {
        
    }
    
    func invokeTiresSizeSearchService() {
        
        self.showLoadingView()
        
        let storeService = TiresSizeSearchService()
        storeService.callService(
            { (response:[String:Any]) -> Void in
                print("Call TiresSizeSearchService success")
                self.removeLoadingView()
                self.getVersionsArray(arrayVersions: UserDefaults.standard.value(forKey: "medidas") as! [String])
        },
            errorBlock: { (error:NSError) -> Void in
                print("Call TiresSizeSearchService error \(error)")
                self.removeLoadingView()
        }
        )
    }

    func invokeTiresMarcasService() {
        
        self.showLoadingView()
        
        let marcaService = TiresMarcasService()
        marcaService.callService(
            { (response:[String:Any]) -> Void in
                print("Call TiresMarcasService success")
                self.removeLoadingView()
                self.getMarcasArray(arrayMarcas: UserDefaults.standard.value(forKey: "marcas") as! [String])
        },
            errorBlock: { (error:NSError) -> Void in
                print("Call TiresMarcasService error \(error)")
                self.removeLoadingView()
        }
        )
    }

    func invokeTiresModelsService(marca:String) {
        
        self.showLoadingView()
        
        let modelService = TiresModelsService()
        modelService.callService(params: ["marca": marca],
                                 successBlock: { (response:[String:Any]) -> Void in
                print("Call TiresModelsService success")
                self.removeLoadingView()
                self.getModelsArray(arrayModels: UserDefaults.standard.value(forKey: "modelos") as! [String])
        },
            errorBlock: { (error:NSError) -> Void in
                print("Call TiresModelssService error \(error)")
                self.removeLoadingView()
        }
        )
    }

    func invokeTiresAniosService(marca:String, modelo:String) {
        
        self.showLoadingView()
        
        let anioService = TiresAniosService()
        anioService.callService(params: ["marca": marca,"modelo":modelo],
                                 successBlock: { (response:[String:Any]) -> Void in
                                    print("Call TiresAniosService success")
                                    self.removeLoadingView()
                                    self.getAniosArray(arrayAnios: UserDefaults.standard.value(forKey: "anios") as! [String])
        },
                                 errorBlock: { (error:NSError) -> Void in
                                    print("Call TiresAniosService error \(error)")
                                    self.removeLoadingView()
        }
        )
    }

    func invokeTiresVersionesService(marca:String, modelo:String, anio:String) {
        
        self.showLoadingView()
        
        let versionService = TiresVersionsService()
        versionService.callService(params: ["marca": marca, "modelo":modelo, "ano":anio],
                                successBlock: { (response:[String:Any]) -> Void in
                                    print("Call TiresVersionesService success")
                                    self.removeLoadingView()
                                    self.getVersionesArray(arrayVersions: UserDefaults.standard.value(forKey: "versiones") as! [String])
        },
                                errorBlock: { (error:NSError) -> Void in
                                    print("Call TiresVersionesService error \(error)")
                                    self.removeLoadingView()
                                    //QUITAR CUANDO EL SERVICIO ESTE BIEN
        }
        )
    }

    func invokeTiresMedidasService(marca:String, modelo:String, anio:String, version: String) {
        
        self.showLoadingView()
        
        let versionService = TiresMedidasSearchService()
        versionService.callService(params: ["marca": marca, "modelo":modelo, "ano":anio, "version":version],
                                   successBlock: { (response:[String:Any]) -> Void in
                                    print("Call TiresMedidasService success")
                                    self.removeLoadingView()
                                    self.getMedidasArray(arrayMedidas: UserDefaults.standard.value(forKey: "medidas") as! [String])
        },
                                   errorBlock: { (error:NSError) -> Void in
                                    print("Call TiresMedidasService error \(error)")
                                    self.removeLoadingView()
                                    //QUITAR CUANDO EL SERVICIO ESTE BIEN
        }
        )
    }

    
    func SearchTiresBySize(_ sender:UIButton) {
        if (anchura.text == "") || (aspecto.text == "") || (diametro.text == ""){
             self.alertView=IPAWMAlertViewController.showAlert(UIImage(named:"invoice_info"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"alert_ups"))
            self.alertView?.setMessage(NSLocalizedString("llantas.message.medida.required",comment:""))
            self.alertView?.showErrorIcon("OK")
            return
        }else{
            let medida : String = anchura.text! + "/" + aspecto.text! + "R" + diametro.text!
            self.invokeTiresbySizeService(medida: medida)
        }
        
    }
    
    func invokeTiresbySizeService(medida:String) {
        
        self.buscaLlantas(medida: medida)
        
    }
    
    
    func showLoadingView() {
        
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(true)
    }
    
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    func getVersionsArray(arrayVersions:[String]){
        
        if arrayVersions.count > 0 {
            for version in arrayVersions {
                let width = version.components(separatedBy: "/")
                let serie = width[1].components(separatedBy: "R")
                
                if !valAnchuras.contains(width[0]){
                    self.valAnchuras.append(width[0])
                }
                
                self.valAnchuras.sort(by: { (before, after) -> Bool in
                    let priceB = before
                    let priceA = after
                    return priceB < priceA
                })
                
                if !valAspectos.contains(serie[0]){
                    self.valAspectos.append(serie[0])
                }
                self.valAspectos.sort(by: { (before, after) -> Bool in
                    let priceB = before
                    let priceA = after
                    return priceB < priceA
                })
                
                if !valDiametros.contains(serie[1]){
                    self.valDiametros.append(serie[1] )
                }
                self.valDiametros.sort(by: { (before, after) -> Bool in
                    let priceB = before
                    let priceA = after
                    return priceB < priceA
                })
                
            }
        }
    }
    
    func getMarcasArray(arrayMarcas:[String]){
        marcas=[]
        if arrayMarcas.count > 0 {
            for marca in arrayMarcas {
                marcas.append(marca)
        }
        }
        listaFiltros.delegate=self
        listaFiltros.dataSource=self
        listaFiltros.reloadData()
        listaFiltros.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.none, animated: true)
        listaFiltros.tableFooterView?.isHidden=true
    }

    func getModelsArray(arrayModels:[String]){
        modelos=[]
        if arrayModels.count > 0 {
            for modelo in arrayModels {
                modelos.append(modelo)
            }
        }
        listaFiltros.delegate=self
        listaFiltros.dataSource=self
        listaFiltros.reloadData()
        listaFiltros.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.none, animated: true)
        listaFiltros.tableFooterView?.isHidden=true
    }

    func getAniosArray(arrayAnios:[String]){
        anios=[]
        if arrayAnios.count > 0 {
            for anio in arrayAnios {
                anios.append(anio)
            }
        }
        listaFiltros.delegate=self
        listaFiltros.dataSource=self
        listaFiltros.reloadData()
        listaFiltros.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.none, animated: true)
        listaFiltros.tableFooterView?.isHidden=true
    }
    
    func getVersionesArray(arrayVersions:[String]){
        versiones=[]
        if arrayVersions.count > 0 {
            for ver in arrayVersions {
                versiones.append(ver)
            }
        }
        listaFiltros.delegate=self
        listaFiltros.dataSource=self
        listaFiltros.reloadData()
        listaFiltros.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.none, animated: true)
        listaFiltros.tableFooterView?.isHidden=true
    }
    
    func getMedidasArray(arrayMedidas:[String]){
        medidas=[]
        if arrayMedidas.count > 0 {
            for ver in arrayMedidas {
                medidas.append(ver)
            }
        }
        listaFiltros.delegate=self
        listaFiltros.dataSource=self
        listaFiltros.reloadData()
        listaFiltros.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.none, animated: true)
        listaFiltros.tableFooterView?.isHidden=true
    }

    func buscaLlantas(medida:String){
        let controller = SearchProductViewController()
        
        controller.searchContextType = .withCategoryForTiresSearch
        
        let diam: [String] = medida.components(separatedBy: "R")
        
        controller.titleHeader = medida
        controller.idDepartment = "d-autos"
        controller.idFamily = "f-autos-motos-llantas-rines"
        controller.idLine = "l-llantas-rines-" + diam[1]
        controller.textToSearch=medida
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
}

