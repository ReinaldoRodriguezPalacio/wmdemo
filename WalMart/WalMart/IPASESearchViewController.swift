//
//  IPASESearchViewController.swift
//  WalMart
//
//  Created by Vantis on 03/08/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

protocol IPASESearchViewControllerDelegate{
    func openShoppingCart()
}

class IPASESearchViewController : UIViewController,UIScrollViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{

    var alertView : IPOWMAlertViewController? = nil
    var viewLoad : WMLoadingView!
    var okButton: UIButton!
    var titleHeader: String?
    var textToSearch:String?
    var maxResult: Int = 20
    var brandText: String? = ""
    var viewHeader: UIView!
    var viewTitleBar: UIView!
    var lbltitle:UILabel!
    //var lblSugerencias:UILabel!
    var btnCerrarModulo:UIButton!
    var btnCancelar:UIButton!
      var clearButton: UIButton?
    var delegate: CustomBarViewController!
    var containerView:UIView!
    var listaPalabras:UITableView!
    var viewBuscaLlanta:UIView!
    let cellReuseIdendifier = "cell"
    var selectedItems:[String]! = []
    var allItems:[String]! = []
    
    var fieldHeight  : CGFloat = CGFloat(30)
    var filterHeight :  CGFloat = CGFloat(40)
    var lblTitle:UILabel!
    var lblDescription:UILabel!
    var countFilter:Int=0
    var instruccionesView:UIView!
    var lblInstrucciones:UILabel!
    var imageLlanta:UIImageView!
    var errorView : FormFieldErrorView? = nil
    var firstOpen  = true
    var isLoading  = false
    var hasEmptyView = false
    
    var idListFromSearch : String? = ""
    var viewEmptyImage =  false
    var sugestedTerms : UIScrollView!
    var listaSuper: UITableView!
    var field: UITextField?
    var myArray : [String]! = []
    var viewSearch: UIView!
    var viewBG : UIView!
    let screenSizePercent: CGFloat! = 0.8
    let cornerRadiusValue: CGFloat! = 20
    let titlesFontSize: CGFloat! = 16

    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.clear
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        viewBG = UIView(frame:CGRect.zero)
        viewBG.alpha = 0
        viewBG.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.view.addSubview(viewBG)
        
        viewSearch = UIView(frame: CGRect.zero)
        //viewSearch.layer.cornerRadius=cornerRadiusValue
        viewSearch.backgroundColor=UIColor.white
        self.viewBG.addSubview(viewSearch)
        
        viewTitleBar = UIView(frame: CGRect.zero)
        viewTitleBar.backgroundColor=UIColor.clear
        
        lbltitle = UILabel(frame: CGRect.zero)
        lbltitle.textColor = WMColor.light_blue
        lbltitle.text = "Súper en minutos"
        lbltitle.textAlignment = .center
        lbltitle.font=WMFont.fontMyriadProRegularOfSize(titlesFontSize)

        btnCerrarModulo = UIButton(frame: CGRect.zero)
        btnCerrarModulo.setImage(UIImage(named: "delete_icon"), for: UIControlState.normal)
        btnCerrarModulo.addTarget(self, action: #selector(self.cierraSearch(_:)), for: UIControlEvents.touchUpInside)
        viewTitleBar.addSubview(lbltitle)
        
        self.viewSearch.addSubview(btnCerrarModulo)
        self.viewSearch.addSubview(viewTitleBar)
        
        viewHeader = UIView(frame: CGRect.zero)
        viewHeader.backgroundColor = WMColor.dark_blue
        
        self.field = FormFieldSearch()
        self.field!.delegate = self
        self.field!.returnKeyType = .done
        self.field!.autocapitalizationType = .none
        self.field!.autocorrectionType = .no
        self.field!.enablesReturnKeyAutomatically = true
        self.field!.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.field!.placeholder = NSLocalizedString("superExpress.search.field.placeholder",comment:"")
        
        self.clearButton = UIButton(type: .custom)
        self.clearButton!.setImage(UIImage(named:"searchClear"), for: UIControlState())
        self.clearButton!.setImage(UIImage(named:"searchClear"), for: .highlighted)
        self.clearButton!.setImage(UIImage(named:"searchClear"), for: .selected)
        self.clearButton!.addTarget(self, action: #selector(self.clearSearch), for: UIControlEvents.touchUpInside)
        self.clearButton!.alpha = 0
        self.field!.addSubview(self.clearButton!)
        
        /*btnCancelar = UIButton()
        btnCancelar.frame = CGRect(x: field!.frame.maxX, y: lbltitle.frame.maxY + 5  , width: self.viewHeader.bounds.width * 0.3 - 15 , height: 40)
        btnCancelar.setTitle("Cancelar", for: UIControlState())
        btnCancelar.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)*/
        //btnCancelar.addTarget(self, action: #selector(self.borraTexto(_:)), for: UIControlEvents.touchUpInside)
        //viewHeader.addSubview(btnCancelar)
        //viewHeader.addSubview(lblDescription)
        viewHeader.addSubview(field!)
        self.viewSearch.addSubview(viewHeader)
        
        containerView = UIView(frame: CGRect.zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.viewSearch.addSubview(containerView)
        
        
        listaSuper = UITableView()
        listaSuper.delegate = self
        listaSuper.dataSource = self
        listaSuper.register(SEListaViewCell.self, forCellReuseIdentifier: "itemListasCell")
        listaSuper.separatorStyle = .none
        listaSuper.allowsSelection = false
        containerView.addSubview(listaSuper)
        
        self.initArrays()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        sugestedTerms = UIScrollView(frame: .zero)
        
        sugestedTerms?.delegate = self
        sugestedTerms?.isScrollEnabled = true
        sugestedTerms?.isUserInteractionEnabled = true
        sugestedTerms?.showsHorizontalScrollIndicator = true
        sugestedTerms.autoresizingMask = UIViewAutoresizing.flexibleWidth
        
       /* lblSugerencias = UILabel(frame: CGRect.zero)
        lblSugerencias.textColor = WMColor.light_light_blue
        lblSugerencias.text = "Sugerencias"
        lblSugerencias.textAlignment = .left
        lblSugerencias.font=WMFont.fontMyriadProRegularOfSize(12)*/
        
        lblDescription = UILabel(frame: CGRect.zero)
        lblDescription.textColor = WMColor.light_blue
        lblDescription.font = WMFont.fontMyriadProRegularOfSize(12)
        lblDescription.text = NSLocalizedString("superExpress.info.description", comment: "")
        lblDescription.numberOfLines = 0
        
        okButton = UIButton()
        okButton!.addTarget(self, action: #selector(self.createPreferedCar(_:)), for: .touchUpInside)
        okButton.tintColor = UIColor.white
        okButton.setTitle("Listo" , for: UIControlState.normal)
        okButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        okButton.backgroundColor = WMColor.green
        okButton.layer.cornerRadius = 15
        
        viewHeader.addSubview(sugestedTerms)
        //viewHeader.addSubview(lblSugerencias)
        
        containerView.addSubview(lblDescription)
        containerView.addSubview(okButton)
        
        self.cargaSugerencias()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SESearchViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.viewBG.alpha = 1
        }, completion: { (complete:Bool) -> Void in
            
        })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        viewBG.frame = self.view.bounds
        
        viewSearch.frame =  CGRect(x: self.viewBG.frame.size.width/2 - self.viewBG.frame.size.width*screenSizePercent/2, y: 5, width: self.viewBG.frame.size.width*screenSizePercent, height:self.viewBG.frame.size.height*screenSizePercent)
        
        viewTitleBar.frame = CGRect(x: viewSearch.bounds.width/2 - viewSearch.bounds.width*0.8/2,  y: 0, width: viewSearch.bounds.width*0.8, height: 40)
        
        lbltitle.frame = CGRect(x: 0, y: 5, width: viewTitleBar.frame.size.width , height: 30)
        
        btnCerrarModulo.frame = CGRect(x: 10, y: 5, width: 30, height: 30)
        
        viewHeader.frame = CGRect(x: 0,  y: viewTitleBar.frame.maxY, width: self.viewSearch.bounds.width, height: self.viewSearch.bounds.height * 0.12 )
        
        self.field!.frame = CGRect(x: 15, y: viewHeader.bounds.height * 0.2, width: self.viewHeader.bounds.width * 0.4, height: viewHeader.bounds.height * 0.6)
        
        self.clearButton!.frame = CGRect(x: self.field!.frame.width - viewHeader.bounds.height * 0.6, y: 0.0, width: viewHeader.bounds.height * 0.6, height: viewHeader.bounds.height * 0.6)
        
        //btnCancelar.frame = CGRect(x: field!.frame.maxX, y: lbltitle.frame.maxY + 5  , width: self.viewHeader.bounds.width * 0.3 - 15 , height: 40)
        
        containerView.frame = CGRect(x: 0,  y: viewHeader.frame.maxY, width: self.viewSearch.bounds.width, height: self.viewSearch.bounds.height - self.viewSearch.bounds.height * 0.12)
        
        listaSuper.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height - 100)
        
        sugestedTerms.frame = CGRect(x: (self.field?.frame.maxX)! + 10, y: self.field!.frame.origin.y + sugestedTerms.frame.height / 2, width: viewHeader.frame.size.width * 0.55, height: 30)
        
       // lblSugerencias.frame = CGRect(x: sugestedTerms.frame.origin.x, y: self.field!.frame.origin.y, width: 15, height: 30)
       // lblSugerencias.sizeToFit()
        
        lblDescription.frame = CGRect(x: 15, y: listaSuper.frame.maxY + 10, width: containerView.frame.size.width / 2 , height: 30)
        
        okButton.frame = CGRect(x: 2 * self.containerView.frame.size.width / 3 , y: listaSuper.frame.maxY + 10, width: self.containerView.frame.size.width / 4, height: 30)
        
    }
    
    func cierraSearch(_ sender:UIButton){
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
        }
        dismiss(animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Text.rawValue
        
        if textField.text != nil && textField.text!.lengthOfBytes(using: String.Encoding.utf8) > 2 {
            
            if !validateSearch(textField.text!)  {
                showMessageValidation(NSLocalizedString("field.validate.text",comment:""))
                return true
            }
            
            if !selectedItems.contains(textField.text!.lowercased()){
                selectedItems.append(textField.text!.lowercased())
                listaSuper.reloadData()
            }
            textField.text = ""
            self.myArray = []
            self.cargaSugerencias()
            self.showClearButtonIfNeeded(forTextValue: textField.text!)
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        var  keyword = strNSString.replacingCharacters(in: range, with: string)
        if keyword.length() > 51 {
            return false
        }
        
        if keyword.length() < 1 {
            keyword = ""
            textField.text = ""
            self.myArray = []
            self.cargaSugerencias()
        }
        
        //searchctrl.searchProductKqeywords(keyword) //por peticionwm
        self.showClearButtonIfNeeded(forTextValue: keyword)
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
        }
        return true
    }

    func textFieldDidChange(_ textField: UITextField) {
     myArray = []
     myArray = allItems.filter { $0.lowercased().hasPrefix(textField.text!.lowercased()) }
        if myArray.count == 0{
            self.invokeTypeAheadService()
        }
     self.cargaSugerencias()
     }

    func clearSearch(){
        
        self.field!.text = ""
        myArray = []
        self.cargaSugerencias()
        self.showClearButtonIfNeeded(forTextValue: self.field!.text!)
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
        }
    }
    
    func showClearButtonIfNeeded(forTextValue text:String) {
        if text.lengthOfBytes(using: String.Encoding.utf8) > 0{
            UIView.animate(withDuration: 0.3, animations: {
                self.clearButton!.alpha = 1
            })
        }
        else {
            UIView.animate(withDuration: 0.3, animations: {
                self.clearButton!.alpha = 0
            })
        }
    }
    
    //UITableDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellreturn = tableView.dequeueReusableCell(withIdentifier: "itemListasCell", for: indexPath) as! SEListaViewCell
        
        cellreturn.setValues(selectedItems[indexPath.row])
        cellreturn.deleteItem.tag = indexPath.row
        cellreturn.deleteItem.addTarget(self, action: #selector(self.delFromList(_:)), for: UIControlEvents.touchUpInside)
        
        if (indexPath.row % 2) != 0{
            cellreturn.backgroundColor = WMColor .light_gray
        }else{
            cellreturn.backgroundColor = UIColor.white
        }
        
        return cellreturn
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func viewReplaceContent(_ frame:CGRect) -> UIView! {
        return UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cargaSugerencias(){
        var widthAnt = 0
        for view in self.sugestedTerms.subviews{
            view.removeFromSuperview()
        }
        for i in 0..<myArray.count{
            let button = UIButton()
            button.titleLabel!.font = WMFont.fontMyriadProLightOfSize(12)
            button.backgroundColor = WMColor.light_light_blue
            button.titleLabel!.textColor = UIColor.white
            button.frame = CGRect(x: (widthAnt), y: 0, width: 30, height: 30)
            button.setTitle(myArray[i].lowercased(), for: UIControlState())
            button.layer.cornerRadius = 10
            button.contentEdgeInsets = UIEdgeInsetsMake(5,15,5,15)
            button.sizeToFit()
            button.tag = i
            button.addTarget(self, action: #selector(self.addToList(_:)), for: UIControlEvents.touchUpInside)
            widthAnt += Int(button.frame.size.width) + 15
            
            self.sugestedTerms.addSubview(button)
            if (i == 3){ break }
        }
        sugestedTerms?.contentSize = CGSize(width: CGFloat(widthAnt) + 200 , height: sugestedTerms.frame.size.height)
    }

    func initArrays(){
        self.invokeSEabcService()
        
        /*allItems = ["Aceite", "Aceite De Oliva", "Aceitunas", "Agua", "Aguacate", "Ajo", "Apio", "Arroz", "Atun", "Avena", "Azucar", "Brocoli", "Café", "Calabaza", "Camarón", "Carne", "Carne Molida", "Catsup", "Cebolla", "Cereal", "Cerveza", "Cilantro", "Cloro", "Crema", "Detergente", "Elote", "Endulzante", "Ensalada", "Espinacas", "Frijoles", "Galletas", "Gelatina", "Harina", "Jamón", "Jicama", "Jitomate", "Leche", "Lechuga", "Limon", "Limpiador", "Mango", "Mantequilla", "Manzana", "Mayonesa", "Melon", "Naranja", "Nopal", "Nuez", "Nutella", "Pan", "Pan Molido", "Pañales", "Papa", "Papaya", "Papel De Baño", "Papel Higiénico", "Pechuga De Pavo", "Pechuga De Pollo", "Pepino", "Pera", "Perejil", "Pescado", "Pimienta", "Pimiento", "Piña", "Platano", "Pollo", "Puré De Tomate", "Queso", "Queso Crema", "Queso De Cabra", "Queso Manchego", "Queso Oaxaca", "Queso Panela", "Refresco", "Repelente", "Sal", "Salchichas", "Salmón", "Servilletas", "Shampoo", "Suavizante", "Te", "Tocino", "Tomate", "Tortillas", "Vainilla", "Vinagre", "Zanahoria"]*/
        myArray = []
    }

    func addToList(_ sender:UIButton){
        if !selectedItems.contains(myArray[sender.tag].lowercased()){
            selectedItems.append(myArray[sender.tag].lowercased())
            listaSuper.reloadData()
        }
        self.field?.text = ""
        self.myArray = []
        self.cargaSugerencias()
        self.showClearButtonIfNeeded(forTextValue: self.field!.text!)
    }
    
    func delFromList(_ sender:UIButton){
        selectedItems.remove(at: sender.tag)
        listaSuper.reloadData()
    }

    func dismissKeyboard() {
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
        }
        view.endEditing(true)
        
    }

    func createPreferedCar(_ sender:UIButton){
        if selectedItems.count > 0{
         let controller = IPASESugestedCar()
         controller.titleHeader = "Súper en minutos"
         controller.searchWords = selectedItems
         controller.delegateIPA = self
         self.addChildViewController(controller)
         self.viewSearch.addSubview(controller.view)
         controller.didMove(toParentViewController: self)
         controller.view.frame = self.viewSearch.bounds
         controller.view.layer.cornerRadius = cornerRadiusValue
         //self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func invokeSEabcService() {
        
        self.showLoadingView()
        
        let abcService = SEabcService()
        abcService.callService([:] as! [String:Any], successBlock: { (response:[String:Any]) -> Void in
            print("Call TypeaheadService success")
            self.removeLoadingView()
            self.getSugerenciasArray(arrayPalabras: response["abclist"] as! [String])
        },
                               errorBlock: { (error:NSError) -> Void in
                                print("Call TiresSizeSearchService error \(error)")
                                self.removeLoadingView()
        }
        )
        /*let url = URL(string: "http://a9.g.akamai.net/f/9/303455/1m/walmartmx.download.akamai.com/303455/resources/abc.json")
         let session = URLSession.shared // or let session = URLSession(configuration: URLSessionConfiguration.default)
         if let usableUrl = url {
         let task = session.dataTask(with: usableUrl, completionHandler: { (data, response, error) in
         if let data = data {
         if let stringData = String(data: data, encoding: String.Encoding.utf8) {
         print(stringData) //JSONSerialization
         }
         }
         })
         task.resume()
         }*/
    }

    
    func invokeTypeAheadService() {
        
        //self.showLoadingView()
        
        if UserCurrentSession.hasLoggedUser(){
            let typeaheadService = SEtypeaheadListService()
            typeaheadService.callService(params: ["pText":field?.text],
                                         successBlock: { (response:[String:Any]) -> Void in
                                            print("Call TypeaheadService success")
                                            //self.removeLoadingView()
                                            self.getSugerenciasBySearch(arrayPalabras: response["searchTerms"] as! [String])
            },
                                         errorBlock: { (error:NSError) -> Void in
                                            print("Call TiresSizeSearchService error \(error)")
                                            //self.removeLoadingView()
            }
            )
        }else{
            let typeaheadService = SEtypeaheadService()
            typeaheadService.callService(params: ["pText":field?.text],
                                         successBlock: { (response:[String:Any]) -> Void in
                                            print("Call TypeaheadService success")
                                            //self.removeLoadingView()
                                            self.getSugerenciasBySearch(arrayPalabras: response["searchTerms"] as! [String])
            },
                                         errorBlock: { (error:NSError) -> Void in
                                            print("Call TiresSizeSearchService error \(error)")
                                            //self.removeLoadingView()
            }
            )
        }
        
    }

    func showLoadingView() {
        
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0, y: 0, width: viewSearch.frame.size.width, height: viewSearch.frame.size.height))
        self.viewSearch.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(true)
    }
    
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    func getSugerenciasArray(arrayPalabras:[String]){
        allItems = []
        allItems = arrayPalabras
        myArray = []
    }
    
    func getSugerenciasBySearch(arrayPalabras:[String]){
        myArray = []
        if arrayPalabras.count > 0 {
            myArray = arrayPalabras
        }
        self.cargaSugerencias()
    }
    
    func borraTexto(_ sender:UIButton){
        self.field?.text = ""
        self.myArray = []
        self.cargaSugerencias()
        self.showClearButtonIfNeeded(forTextValue: self.field!.text!)
        
    }

    func closeView(){
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func closeViewandShowCart(){
            delegate?.openShoppingCart()
            self.dismiss(animated: true, completion: nil)
    }
    
    func showMessageValidation(_ message:String){
        if self.errorView == nil{
            self.errorView = FormFieldErrorView()
        }
        
        self.errorView!.frame = CGRect(x: self.field!.frame.minX - 5, y: 0, width: self.field!.frame.width, height: self.field!.frame.height )
        self.errorView!.focusError = self.field!
        if self.field!.frame.minX < 20 {
            self.errorView!.setValues(280, strLabel:"", strValue: message)
            self.errorView!.frame =  CGRect(x: self.field!.frame.minX - 5, y: self.field!.frame.minY , width: self.errorView!.frame.width , height: self.errorView!.frame.height)
        }
        else{
            self.errorView!.setValues(field!.frame.width, strLabel:"", strValue: message)
            self.errorView!.frame =  CGRect(x: field!.frame.minX - 5, y: field!.frame.minY, width: errorView!.frame.width , height: errorView!.frame.height)
        }
        let contentView = self.field!.superview!
        contentView.addSubview(self.errorView!)
        UIView.animate(withDuration: 0.2, animations: {
            
            
            self.errorView!.frame =  CGRect(x: self.field!.frame.minX - 5 , y: self.field!.frame.minY - self.errorView!.frame.height / 2, width: self.errorView!.frame.width , height: self.errorView!.frame.height)
            
        }, completion: {(bool : Bool) in
            if bool {
                self.field!.becomeFirstResponder()
            }
        })
    }

    func validateSearch(_ toValidate:String) -> Bool{
        let regString : String = "^[A-Z0-9a-zñÑÁáÉéÍíÓóÚú& /]{0,100}[._-]{0,2}$";
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
            return true
        }
        return false
    }
    
}

