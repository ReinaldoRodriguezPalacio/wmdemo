//
//  IPASearchTiresIniViewController.swift
//  WalMart
//
//  Created by Vantis on 30/03/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

protocol IPASearchTiresIniControllerDelegate {
    func searchTires(family:String, line:String, idDepartment : String, name: String, medida: String)
}

class IPASearchTiresIniViewController :  BaseController, UIDynamicAnimatorDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, AlertPickerViewDelegate{
    
    var delegate : IPAFamilyViewController!
    var viewSearch: UIView!
    var viewBG : UIView!
    
    var viewBackButton: UIView!
    var lbltitle:UILabel!
    var btnCerrarModulo:UIButton!
    
    var viewBgSelectorBtn : UIView!
    var btnModelo : UIButton!
    var btnMedida : UIButton!
    
    var containerView:UIView!
    var listaFiltros:UICollectionView!
    var viewHeader:UIView!
    var titleHeader:UILabel!
    var tituloFooter:UILabel!
    var buttonFooter:UIButton!
    var medidaFooter:UILabel!
    var viewBuscaLlanta:UIView!
    var porMedidaView:UIView!
    let cellReuseIdendifier = "CustomCell"
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
    var searchButton: UIButton!
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
    var alertView : IPOWMAlertViewController? = nil
    
    var loadImage : LoadingIconView!
    
    let screenSizePercent: CGFloat! = 0.7
    let cornerRadiusValue: CGFloat! = 20
    let titlesFontSize: CGFloat! = 20
    
    var finishAnimation : (() -> Void)? = nil
    
    
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.clear
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        viewBG = UIView(frame:CGRect.zero)
        viewBG.alpha = 0
        viewBG.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.view.addSubview(viewBG)
        self.loadAnimation()
        
        viewSearch = UIView(frame: CGRect.zero)
        viewSearch.layer.cornerRadius=cornerRadiusValue
        viewSearch.backgroundColor=UIColor.white
        self.viewBG.addSubview(viewSearch)
       
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadImage.stopAnnimating()
        self.loadImage.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.viewBG.alpha = 1
        }, completion: { (complete:Bool) -> Void in
            
        })
    }
    
    func loadAnimation(){
        
        if loadImage == nil {
            loadImage = LoadingIconView(frame: CGRect(x: 0, y: 0, width: 116, height: 120))
        }
        loadImage.center = self.view.center
        self.view.addSubview(loadImage)
        
        loadImage.startAnnimating()
        loadImage.backgroundColor = UIColor.clear
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let rightPadding = leftRightPadding * 2
         picker = AlertPickerView.initPickerWithDefault()
        viewBG.frame = self.view.bounds
        
        viewSearch.frame =  CGRect(x: self.viewBG.frame.size.width/2 - self.viewBG.frame.size.width*screenSizePercent/2, y: self.viewBG.frame.size.height/2 - self.viewBG.frame.size.height*screenSizePercent/2, width: self.viewBG.frame.size.width*screenSizePercent, height:self.viewBG.frame.size.height*screenSizePercent)
        
        viewBackButton = UIView(frame: CGRect(x: viewSearch.bounds.width/2 - viewSearch.bounds.width*0.8/2,  y: 0, width: viewSearch.bounds.width*0.8, height: 60))
        viewBackButton.backgroundColor=UIColor.clear
        
        lbltitle = UILabel(frame: CGRect(x: 0, y: 10, width: viewBackButton.frame.size.width , height: 40))
        lbltitle.textColor = WMColor.light_blue
        lbltitle.text = "Buscador de llantas"
        lbltitle.textAlignment = .center
        lbltitle.font=WMFont.fontMyriadProRegularOfSize(titlesFontSize+4)
        btnCerrarModulo = UIButton(frame: CGRect(x: viewSearch.frame.width-40, y: 10, width: 30, height: 30))
        btnCerrarModulo.setImage(UIImage(named: "delete_icon"), for: UIControlState.normal)
        btnCerrarModulo.addTarget(self, action: #selector(self.cierraSearch(_:)), for: UIControlEvents.touchUpInside)
        viewBackButton.addSubview(lbltitle)
        self.viewSearch.addSubview(btnCerrarModulo)
        self.viewSearch.addSubview(viewBackButton)
        
        viewBgSelectorBtn = UIView(frame: CGRect(x: 0,  y: viewBackButton.frame.maxY, width: viewSearch.bounds.width, height: 60))
        viewBgSelectorBtn.layer.borderWidth = 1
        viewBgSelectorBtn.layer.borderColor = WMColor.light_gray.cgColor
        
        let titleModelo = NSLocalizedString("llantas.message.modelo",comment:"")
        btnModelo = UIButton(frame: CGRect(x: 1, y: 1, width: (viewBgSelectorBtn.frame.width / 2) , height: viewBgSelectorBtn.frame.height - 2))
        btnModelo.setImage(UIImage(color: UIColor.white, size: btnModelo.frame.size), for: UIControlState())
        btnModelo.setImage(UIImage(color: UIColor(red: 63/255.0, green: 167/255.0, blue: 243/255.0, alpha: 1.0), size: btnModelo.frame.size), for: UIControlState.selected)
        btnModelo.setTitle(titleModelo, for: UIControlState())
        btnModelo.setTitle(titleModelo, for: UIControlState.selected)
        btnModelo.setTitleColor(UIColor.white, for: UIControlState.selected)
        btnModelo.setTitleColor(WMColor.light_blue, for: UIControlState())
        btnModelo.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(titlesFontSize)
        btnModelo.isSelected = true
        btnModelo.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnModelo.frame.size.width + 1, 0, 0.0);
        btnModelo.addTarget(self, action: #selector(self.buscaxModelo(_:)), for: UIControlEvents.touchUpInside)
        
        let titleMedida = NSLocalizedString("llantas.message.medida",comment:"")
        btnMedida = UIButton(frame: CGRect(x: btnModelo.frame.maxX, y: 1, width: viewBgSelectorBtn.frame.width / 2, height: viewBgSelectorBtn.frame.height - 2))
        btnMedida.setImage(UIImage(color: UIColor.white, size: btnModelo.frame.size), for: UIControlState())
        btnMedida.setImage(UIImage(color: UIColor(red: 63/255.0, green: 167/255.0, blue: 243/255.0, alpha: 1.0), size: btnModelo.frame.size), for: UIControlState.selected)
        btnMedida.setTitleColor(UIColor.white, for: UIControlState.selected)
        btnMedida.setTitleColor(WMColor.light_blue, for: UIControlState())
        btnMedida.setTitle(titleMedida, for: UIControlState())
        btnMedida.setTitle(titleMedida, for: UIControlState.selected)
        btnMedida.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(titlesFontSize)
        btnMedida.isSelected = false
        btnMedida.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnModelo.frame.size.width , 0, 0.0);
        btnMedida.addTarget(self, action: #selector(self.buscaxMedida(_:)), for: UIControlEvents.touchUpInside)
 
        viewBgSelectorBtn.clipsToBounds = true
        viewBgSelectorBtn.backgroundColor = UIColor.white
        viewBgSelectorBtn.addSubview(btnModelo)
        viewBgSelectorBtn.addSubview(btnMedida)
        
        self.viewSearch.addSubview(viewBgSelectorBtn)
        
        containerView = UIView(frame: CGRect(x: 0,  y: viewBgSelectorBtn.frame.maxY, width: viewSearch.bounds.width, height: viewSearch.bounds.height-viewBgSelectorBtn.frame.maxY))
        containerView.backgroundColor=UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: filterHeight))
        viewHeader.backgroundColor=WMColor.light_blue
        
        titleHeader = UILabel(frame: CGRect(x: 0, y: 5, width: viewHeader.frame.size.width, height: 30))
        titleHeader.font = WMFont.fontMyriadProRegularOfSize(titlesFontSize-2)
        titleHeader.textColor = UIColor.white
        titleHeader.textAlignment = .center
        viewHeader.tag = -100
        viewHeader.addSubview(titleHeader)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20)
        layout.itemSize = CGSize(width: containerView.frame.size.width/4-10, height: 20)
        layout.scrollDirection = .horizontal
        listaFiltros = UICollectionView(frame: CGRect(x: 0, y: viewHeader.frame.maxY, width: containerView.frame.size.width, height: containerView.frame.size.height-viewHeader.frame.maxY), collectionViewLayout: layout)
        listaFiltros.dataSource = self
        listaFiltros.delegate = self
        listaFiltros.register(IPASearchCustomCell.self, forCellWithReuseIdentifier: cellReuseIdendifier)

        listaFiltros.backgroundColor = UIColor.white
        
        self.containerView.addSubview(viewHeader)
        self.containerView.addSubview(listaFiltros)
        
        viewBuscaLlanta = UIView(frame: CGRect(x: 0,  y: listaFiltros.frame.maxY-100, width: containerView.frame.size.width, height: 100))
        viewBuscaLlanta.backgroundColor=WMColor.light_gray
        
        tituloFooter = UILabel(frame: CGRect(x:0, y: 5, width: viewBuscaLlanta.frame.size.width, height: 20))
        
        medidaFooter = UILabel(frame: CGRect(x:0, y: 30, width: viewBuscaLlanta.frame.size.width, height: 20))
        
        buttonFooter = UIButton(type: .custom)
        
        viewBuscaLlanta.addSubview(tituloFooter)
        viewBuscaLlanta.addSubview(medidaFooter)
        viewBuscaLlanta.addSubview(buttonFooter)
        
        viewBuscaLlanta.isHidden=true
        containerView.addSubview(viewBuscaLlanta)
        
        
        porMedidaView=UIView(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height))
        porMedidaView.accessibilityScroll(.down)
        instruccionesView=UIView(frame: CGRect(x:0, y: 0, width: porMedidaView.frame.size.width , height: 50))
        instruccionesView.backgroundColor=WMColor.blue
        lblInstrucciones = UILabel(frame: CGRect(x:0, y: 10, width: instruccionesView.frame.size.width*0.9 , height: 40))
        lblInstrucciones.numberOfLines=0
        lblInstrucciones.font=UIFont.boldSystemFont(ofSize: 15)
        lblInstrucciones.textColor = .white
        lblInstrucciones.textAlignment = .center
        lblInstrucciones.text=NSLocalizedString("llantas.message.instrucciones",comment:"")
        lblInstrucciones.center = instruccionesView.center
        
        instruccionesView.addSubview(lblInstrucciones)
        
        let image = UIImage(named: "llanta.png")
        imageLlanta = UIImageView(image: image!)
        imageLlanta.frame = CGRect(x: porMedidaView.frame.size.width/2 - porMedidaView.frame.size.width*0.6/2 , y: instruccionesView.frame.maxY, width: porMedidaView.frame.size.width*0.6, height: 120)
        
        medidaLlanta=UILabelX(frame: CGRect(x: 0, y: 35, width: imageLlanta.frame.size.width , height: imageLlanta.frame.size.height*3))
        medidaLlanta.text="---/--R--"
        medidaLlanta.textColor=UIColor.white
        medidaLlanta.font=UIFont.systemFont(ofSize: 17)
        medidaLlanta.clockwise=true
        medidaLlanta.angle=1.6
        imageLlanta.addSubview(medidaLlanta)
        let selectionFrame = UIView(frame: CGRect(x:0, y: imageLlanta.frame.maxY, width: porMedidaView.frame.size.width , height: porMedidaView.frame.size.height-instruccionesView.frame.size.height-imageLlanta.frame.size.height))
        
        let lblAnchura = UILabel(frame: CGRect(x:leftRightPadding, y: 5, width: selectionFrame.frame.size.width/2 - rightPadding , height: 30))
        lblAnchura.text = NSLocalizedString("llantas.message.medida.anchura",comment:"")
        lblAnchura.textColor=WMColor.light_blue
        lblAnchura.font=WMFont.fontMyriadProLightOfSize(17)
        anchura = FormFieldView()
        anchura.isRequired = true
        anchura.setCustomPlaceholder(NSLocalizedString("llantas.message.medida.anchura",comment:""))
        anchura.typeField = TypeField.list
        anchura.nameField = NSLocalizedString("llantas.field.medida.anchura",comment:"")
        anchura.frame = CGRect(x: leftRightPadding, y: lblAnchura.frame.maxY , width: selectionFrame.frame.size.width/2 - rightPadding * 2 + 10 , height: fieldHeight + 10)
        anchura.font=WMFont.fontMyriadProLightOfSize(17)
        
        let lblAspecto = UILabel(frame: CGRect(x:leftRightPadding, y: anchura.frame.maxY + 10, width: selectionFrame.frame.size.width - rightPadding , height: 30))
        lblAspecto.text = NSLocalizedString("llantas.message.medida.aspecto",comment:"")
        lblAspecto.textColor=WMColor.light_blue
        lblAspecto.font=WMFont.fontMyriadProLightOfSize(17)
        aspecto = FormFieldView()
        aspecto.isRequired = true
        aspecto.setCustomPlaceholder(NSLocalizedString("llantas.message.medida.aspecto",comment:""))
        aspecto.typeField = TypeField.list
        aspecto.nameField = NSLocalizedString("llantas.field.medida.aspecto",comment:"")
        aspecto.frame = CGRect(x: leftRightPadding, y: lblAspecto.frame.maxY , width: selectionFrame.frame.size.width/2 - rightPadding * 2 + 10 , height: fieldHeight + 10)
        aspecto.font=WMFont.fontMyriadProLightOfSize(17)
        
        let lblDiametro = UILabel(frame: CGRect(x:leftRightPadding + selectionFrame.frame.size.width/2, y: 5, width: selectionFrame.frame.size.width/2 - rightPadding , height: 30))
        lblDiametro.text = NSLocalizedString("llantas.message.medida.diametro",comment:"")
        lblDiametro.textColor=WMColor.light_blue
        lblDiametro.font=WMFont.fontMyriadProLightOfSize(17)
        diametro = FormFieldView()
        diametro.isRequired = true
        diametro.setCustomPlaceholder(NSLocalizedString("llantas.message.medida.diametro",comment:""))
        diametro.typeField = TypeField.list
        diametro.nameField = NSLocalizedString("llantas.field.medida.diametro",comment:"")
        diametro.frame = CGRect(x: leftRightPadding + selectionFrame.frame.size.width/2, y: lblDiametro.frame.maxY, width: selectionFrame.frame.size.width/2 - rightPadding * 2 + 10 , height: fieldHeight + 10)
        diametro.font=WMFont.fontMyriadProLightOfSize(17)
        
        searchButton = UIButton(type: .custom)
        searchButton!.addTarget(self, action: #selector(SearchTiresBySize(_:)), for: .touchUpInside)
        searchButton.tintColor = UIColor.white
        searchButton.setTitle("Buscar" , for: UIControlState.normal)
        searchButton.backgroundColor = WMColor.light_blue
        searchButton.setTitleColor(WMColor.gray, for: UIControlState.disabled)
        searchButton.layer.cornerRadius = 14.0
        
        searchButton.setTitleColor(UIColor.white, for: UIControlState())
        searchButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0)
        searchButton.frame = CGRect(x: selectionFrame.frame.size.width/2 - 60 , y: aspecto.frame.maxY + 30, width: 120, height:28)
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
                self.picker!.showPickerOverModal(viewBase: self.viewBG)
                
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
                self.picker!.showPickerOverModal(viewBase: self.viewBG)
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
                self.picker!.showPickerOverModal(viewBase: self.viewBG)
            }
        }
        
        porMedidaView.addSubview(instruccionesView)
        porMedidaView.addSubview(imageLlanta)
        porMedidaView.addSubview(selectionFrame)

        
        
        
        
        self.viewSearch.addSubview(containerView)
        
        self.invokeTiresMarcasService()
    }
    
    func cierraSearch(_ sender:UIButton){
        self.delegate=nil
        dismiss(animated: true, completion: nil)
        
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        
        self.view.isUserInteractionEnabled = true
        self.finishAnimation?()
        
    }
    
    func saveReplaceViewSelected() {
    }
    
    func buttomViewSelected(_ sender: UIButton) {
        
    }

    
    func buscaxModelo(_ sender:UIButton) {
        porMedidaView.removeFromSuperview()
        countFilter=0
        headerNew=0
        items=marcas
        viewHeader.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: filterHeight)
        
        listaFiltros.frame = CGRect(x: 0, y: viewHeader.frame.maxY, width: containerView.frame.size.width, height: containerView.frame.size.height-viewHeader.frame.maxY)
        titleHeader.text="Marca"
        viewBuscaLlanta.frame = CGRect(x: 0,  y: listaFiltros.frame.maxY-100, width: containerView.frame.size.width, height: 100)
        
    
        viewBuscaLlanta.isHidden=true
        

        listaFiltros.reloadData()
        containerView.addSubview(viewBuscaLlanta)
        containerView.addSubview(viewHeader)
        containerView.addSubview(listaFiltros)
        sender.isSelected=true
        btnMedida.isSelected=false
    }
    
    func buscaxMedida(_ sender:UIButton) {
        for views in containerView.subviews{
            views.removeFromSuperview()
        }
        
        containerView.addSubview(porMedidaView)
        if anchura!.text != "" && aspecto!.text != "" && diametro!.text != ""{
            self.searchButton.isEnabled = true
            searchButton.backgroundColor = WMColor.blue
        }else{
            self.searchButton.isEnabled = false
        }
        searchButton.backgroundColor = WMColor.light_light_gray
        self.invokeTiresSizeSearchService()
        sender.isSelected=true
        btnModelo.isSelected=false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdendifier, for: indexPath) as! IPASearchCustomCell
        cell.btnLista.frame = CGRect(x: 0 , y: 0, width: cell.frame.size.width, height: cell.frame.size.height)
        cell.btnLista.setTitle(items[indexPath.row], for: UIControlState.normal)
        cell.btnLista.setTitleColor(WMColor.light_blue, for: UIControlState.normal)
        cell.btnLista.titleLabel?.font = WMFont.fontMyriadProLightOfSize(20)
        cell.btnLista.contentHorizontalAlignment = .left
        cell.btnLista.titleEdgeInsets=UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        cell.btnLista.setImage(UIImage(named: "filter_check_blue"), for: UIControlState.normal)
        cell.btnLista.tag=indexPath.row
        cell.btnLista.addTarget(self, action: #selector(self.btnSelectedTapped(_:)), for: UIControlEvents.touchUpInside)
        return cell
    }
    
    func showLoadingView() {
        
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height))
        self.containerView.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(true)
    }
    
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }

    
    func btnSelectedTapped(_ sender: UIButton) {
       
        
        var boldText=""
        
        switch countFilter {
        case 0:
            boldText = "Marca: "
            marcaSelectionFilter = sender.titleLabel?.text
            break
        case 1:
            boldText = "Modelo: "
            modeloSelectionFilter = sender.titleLabel?.text
            break
        case 2:
            boldText = "Año: "
            anioSelectionFilter = sender.titleLabel?.text
            break
        case 3:
            boldText = "Versión: "
            versionSelectionFilter = sender.titleLabel?.text
            break
        case 4:
            medidaSelectionFilter = sender.titleLabel?.text
            break
        default:
            boldText = "Marca: "
        }

        
        if countFilter < 4 {
            let newFilter = UIView(frame: CGRect(x: 0,  y: headerNew, width: containerView.frame.size.width, height: filterHeight))
            newFilter.backgroundColor=UIColor (red: 247/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1.0)
            lblTitle = UILabel(frame: CGRect(x:0, y: 5, width: newFilter.frame.size.width , height: 30))
            lblTitle.textAlignment = .center
            
            let attrs = [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(titlesFontSize-2)]
            let attrsNormal = [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(titlesFontSize-2)]
            let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
            let normalText = sender.titleLabel?.text
            let normalString = NSMutableAttributedString(string:normalText!, attributes:attrsNormal)
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
                self.viewHeader.frame = CGRect(x: 0, y: self.headerNew, width: rect.size.width, height:self.filterHeight)
                self.listaFiltros.frame = CGRect(x : 0, y : self.viewHeader.frame.maxY, width : rect.size.width, height: rect.size.height-self.filterHeight)
            })
        }
        
        countFilter += 1
        
        switch countFilter {
        case 1:
            self.invokeTiresModelsService(marca: marcas[sender.tag])
            break
        case 2:
            self.invokeTiresAniosService(marca: marcaSelectionFilter!, modelo: modelos[sender.tag])
            break
        case 3:
            self.invokeTiresVersionesService(marca: marcaSelectionFilter!, modelo: modeloSelectionFilter!, anio: anios[sender.tag])
            break
        case 4:
            self.invokeTiresMedidasService(marca: marcaSelectionFilter!, modelo: modeloSelectionFilter!, anio: anioSelectionFilter!, version: versiones[sender.tag])
            break
        case 5:
            if viewBuscaLlanta.isHidden{
            var rect:CGRect!
            rect = listaFiltros.frame
            UIView.animate(withDuration: 0.5, animations: {
                
                self.listaFiltros.frame = CGRect(x : 0, y : self.viewHeader.frame.maxY, width : rect.size.width, height: rect.size.height - 100)
            })
            }
            viewBuscaLlanta.isHidden=false
            tituloFooter.text="El tamaño de tu llanta es:"
            tituloFooter.font=WMFont.fontMyriadProRegularOfSize(titlesFontSize-1)
            tituloFooter.textAlignment = .center
            
            medidaFooter.text = medidaSelectionFilter
            medidaFooter.font = WMFont.fontMyriadProBoldOfSize(titlesFontSize)
            medidaFooter.textColor=WMColor.light_blue
            medidaFooter.textAlignment = .center

            buttonFooter.addTarget(self, action: #selector(cargaBusqueda(_:)), for: .touchUpInside)
            buttonFooter.tintColor = UIColor.white
            buttonFooter.setTitle("Ver productos" , for: UIControlState.normal)
            buttonFooter.backgroundColor = WMColor.green
            buttonFooter.layer.cornerRadius = 10.0
            
            buttonFooter.setTitleColor(UIColor.white, for: UIControlState())
            buttonFooter.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0)
            buttonFooter.frame = CGRect(x: viewBuscaLlanta.frame.size.width/2 - 120 , y: 60, width: 240, height:30)
            buttonFooter.titleLabel?.font=UIFont.systemFont(ofSize: 12)
            countFilter=4
            
            break
        default:
            boldText = "Marca: "
        }

        sender.setImage(UIImage(named: "filter_check_blue_selected"), for: .normal)
        for boton in listaFiltros.visibleCells{
            let item : IPASearchCustomCell = boton as! IPASearchCustomCell
            if item.btnLista.tag != sender.tag{
                item.btnLista.setImage(UIImage(named: "filter_check_blue"), for: .normal)
            }
        }
    }
    
    
    
    func quitaFiltro(_ sender:UIButton) {
        var cuenta:Int = 0
        var aumento : CGFloat = 0
        if !viewBuscaLlanta.isHidden{
            viewBuscaLlanta.isHidden=true
        var rect:CGRect!
        rect = listaFiltros.frame
        UIView.animate(withDuration: 0.5, animations: {
            
            self.listaFiltros.frame = CGRect(x : 0, y : self.viewHeader.frame.maxY, width : rect.size.width, height: rect.size.height + 100)
        })}

        if sender.tag > 0{
            
            print(countFilter)
            let viewWithTag = self.containerView.viewWithTag(sender.tag)
            for views in containerView.subviews{
                if views.tag >= (viewWithTag?.tag)! && view.tag <= countFilter {
                views.removeFromSuperview()
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
                titleHeader.text = "Marca"
                items=marcas
                break
            case 1:
                titleHeader.text = "Modelo"
                items=modelos
                break
            case 2:
                titleHeader.text = "Año"
                items=anios
                break
            case 3:
                titleHeader.text = "Versión"
                items=versiones
                break
            case 4:
                titleHeader.text = "Medida"
                items=medidas
                break
            default:
                items=marcas
            }
            
            listaFiltros.reloadData()
            viewBuscaLlanta.isHidden=true
            var rect:CGRect!
            rect = listaFiltros.frame
            UIView.animate(withDuration: 0.5, animations: {
                
                
                self.viewHeader.frame = CGRect(x: 0, y: self.headerNew, width: rect.size.width, height:self.filterHeight)
                self.listaFiltros.frame = CGRect(x : 0, y : self.viewHeader.frame.maxY, width : rect.size.width, height: rect.size.height+aumento)
                
            })
        }else{
            
            countFilter=0
            headerNew=0
            items=marcas
            containerView.removeFromSuperview()
            
            containerView = UIView(frame: CGRect(x: 0,  y: viewBgSelectorBtn.frame.maxY, width: viewSearch.bounds.width, height: viewSearch.bounds.height-viewBgSelectorBtn.frame.maxY))
            containerView.backgroundColor=UIColor.white
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: filterHeight))
            viewHeader.backgroundColor=WMColor.light_blue
            
            titleHeader = UILabel(frame: CGRect(x: 0, y: 5, width: viewHeader.frame.size.width, height: 30))
            titleHeader.font = WMFont.fontMyriadProRegularOfSize(titlesFontSize-2)
            titleHeader.textColor = UIColor.white
            titleHeader.textAlignment = .center
            titleHeader.text = "Marca"
            viewHeader.tag = -100
            viewHeader.addSubview(titleHeader)
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20)
            layout.itemSize = CGSize(width: containerView.frame.size.width/4-10, height: 20)
            layout.scrollDirection = .horizontal
            listaFiltros = UICollectionView(frame: CGRect(x: 0, y: viewHeader.frame.maxY, width: containerView.frame.size.width, height: containerView.frame.size.height-viewHeader.frame.maxY), collectionViewLayout: layout)
            listaFiltros.dataSource = self
            listaFiltros.delegate = self
            listaFiltros.register(IPASearchCustomCell.self, forCellWithReuseIdentifier: cellReuseIdendifier)
            
            listaFiltros.backgroundColor = UIColor.white
            
            self.containerView.addSubview(viewHeader)
            self.containerView.addSubview(listaFiltros)
            
            viewBuscaLlanta = UIView(frame: CGRect(x: 0,  y: listaFiltros.frame.maxY-100, width: containerView.frame.size.width, height: 100))
            viewBuscaLlanta.backgroundColor=WMColor.light_gray
            
            tituloFooter = UILabel(frame: CGRect(x:0, y: 5, width: viewBuscaLlanta.frame.size.width, height: 20))
            
            medidaFooter = UILabel(frame: CGRect(x:0, y: 30, width: viewBuscaLlanta.frame.size.width, height: 20))
            
            buttonFooter = UIButton(type: .custom)
            
            viewBuscaLlanta.addSubview(tituloFooter)
            viewBuscaLlanta.addSubview(medidaFooter)
            viewBuscaLlanta.addSubview(buttonFooter)
            
            viewBuscaLlanta.isHidden=true
            containerView.addSubview(viewBuscaLlanta)
            self.viewSearch.addSubview(containerView)
            
        }
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
                                    
        }
        )
    }

    
    func getMarcasArray(arrayMarcas:[String]){
        marcas=[]
        titleHeader.text="Marca"
        if arrayMarcas.count > 0 {
            for marca in arrayMarcas {
                marcas.append(marca)
            }
        }
        listaFiltros.delegate=self
        listaFiltros.dataSource=self
        listaFiltros.reloadData()
        
    }

    func getModelsArray(arrayModels:[String]){
        modelos=[]
        titleHeader.text="Modelo"
        if arrayModels.count > 0 {
            for modelo in arrayModels {
                modelos.append(modelo)
            }
        }
        listaFiltros.delegate=self
        listaFiltros.dataSource=self
        listaFiltros.reloadData()
        
    }

    func getAniosArray(arrayAnios:[String]){
        anios=[]
        titleHeader.text="Año"
        if arrayAnios.count > 0 {
            for anio in arrayAnios {
                anios.append(anio)
            }
        }
        listaFiltros.delegate=self
        listaFiltros.dataSource=self
        listaFiltros.reloadData()
    }

    func getVersionesArray(arrayVersions:[String]){
        versiones=[]
        titleHeader.text="Versión"
        if arrayVersions.count > 0 {
            for ver in arrayVersions {
                versiones.append(ver)
            }
        }
        listaFiltros.delegate=self
        listaFiltros.dataSource=self
        listaFiltros.reloadData()
    }

    func getMedidasArray(arrayMedidas:[String]){
        medidas=[]
        titleHeader.text="Medida"
        if arrayMedidas.count > 0 {
            for ver in arrayMedidas {
                medidas.append(ver)
            }
        }
        listaFiltros.delegate=self
        listaFiltros.dataSource=self
        listaFiltros.reloadData()
    }
    
    func cargaBusqueda(_ sender:UIButton){
        self.invokeTiresbySizeService(medida: medidaSelectionFilter)
    }
    
    func invokeTiresbySizeService(medida:String) {
        
        self.buscaLlantas(medida: medida)
        
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
            if anchura!.text != "" && aspecto!.text != "" && diametro!.text != ""{
                self.searchButton.isEnabled = true
                searchButton.backgroundColor = WMColor.blue
            }
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
        if anchura!.text == "" && aspecto!.text == "" && diametro!.text == ""{
            self.searchButton.isEnabled=false
            searchButton.backgroundColor = WMColor.light_blue
        }
    }
    
    func viewReplaceContent(_ frame:CGRect) -> UIView! {
        return UIView()
    }
    
    func SearchTiresBySize(_ sender:UIButton) {
                let medida : String = anchura.text! + "/" + aspecto.text! + "R" + diametro.text!
            self.invokeTiresbySizeService(medida: medida)
        
        
    }
    
    func buscaLlantas(medida:String){
        
        
        let diam: [String] = medida.components(separatedBy: "R")
        
        delegate.searchTires(family: "f-autos-motos-llantas-rines", line: "l-llantas-rines-" + diam[1], idDepartment: "d-autos", name: "Llantas " + medida, medida : medida)
        
    }

}

