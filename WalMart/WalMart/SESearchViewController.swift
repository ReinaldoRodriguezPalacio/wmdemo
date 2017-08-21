//
//  SESearchViewController.swift
//  WalMart
//
//  Created by Vantis on 10/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit

class SESearchViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, SESugestedCarDelegate{
    
    var alertView : IPOWMAlertViewController? = nil
    var viewLoad : WMLoadingView!
    var okButton: UIButton!
    
    var titleHeader: String?
    var textToSearch:String?
    var maxResult: Int = 20
    var brandText: String? = ""
    
    var viewBackButton: UIView!
    var lbltitle:UILabel!
    var btnCerrarModulo:UIButton!
    var btnCancelar:UIButton!
    
    var containerView:UIView!
    var listaPalabras:UITableView!
    var viewBuscaLlanta:UIView!
    let cellReuseIdendifier = "cell"
    var selectedItems:[String]! = []
    var allItems:[String]! = []
    var errorView : FormFieldErrorView? = nil
    var fieldHeight  : CGFloat = CGFloat(30)
    var filterHeight :  CGFloat = CGFloat(40)
    var lblTitle:UILabel!
    var countFilter:Int=0
    var instruccionesView:UIView!
    var lblInstrucciones:UILabel!
    var imageLlanta:UIImageView!
    
    var firstOpen  = true
    var isLoading  = false
    var hasEmptyView = false
    
    var idListFromSearch : String? = ""
    var viewEmptyImage =  false
    var sugestedTerms : UIScrollView!
    var listaSuper: UITableView!
    var field: UITextField?
    var myArray : [String]! = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        if IS_IPHONE_4_OR_LESS || IS_IPHONE_5{
            
            viewBackButton = UIView(frame: CGRect(x: 0,  y: 0, width: self.view.bounds.width, height: self.view.bounds.height * 0.25 ))
            viewBackButton.backgroundColor = WMColor.dark_blue
            
            lbltitle = UILabel(frame: CGRect(x: 15, y: 10, width: viewBackButton.frame.size.width-50 , height: 40))
            lbltitle.textColor = UIColor.white
            lbltitle.font = WMFont.fontMyriadProRegularOfSize(11)
            lbltitle.text = NSLocalizedString("superExpress.info.description", comment: "")
            lbltitle.numberOfLines = 0
            
            btnCerrarModulo = UIButton(frame: CGRect(x: viewBackButton.frame.size.width-40, y: 10, width: 30, height: 30))
            btnCerrarModulo.setImage(UIImage(named: "closeScan"), for: UIControlState.normal)
            btnCerrarModulo.addTarget(self, action: #selector(self.cierraModal(_:)), for: UIControlEvents.touchUpInside)

            self.field = FormFieldSearch()
            self.field!.frame = CGRect(x: 15, y: lbltitle.frame.maxY + 10, width: self.view.bounds.width * 0.7, height: 35)
            self.field!.delegate = self
            self.field!.returnKeyType = .done
            self.field!.autocapitalizationType = .none
            self.field!.autocorrectionType = .no
            self.field!.enablesReturnKeyAutomatically = true
            self.field!.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            self.field!.placeholder = NSLocalizedString("superExpress.search.field.placeholder",comment:"")
            
            btnCancelar = UIButton()
            btnCancelar.frame = CGRect(x: field!.frame.maxX, y: lbltitle.frame.maxY + 10 , width: self.view.bounds.width * 0.3 - 15 , height: 35)
            btnCancelar.setTitle("Cancelar", for: UIControlState())
            btnCancelar.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
            btnCancelar.addTarget(self, action: #selector(self.borraTexto(_:)), for: UIControlEvents.touchUpInside)
            viewBackButton.addSubview(btnCancelar)
            
            viewBackButton.addSubview(btnCerrarModulo)
            viewBackButton.addSubview(lbltitle)
            viewBackButton.addSubview(field!)
            self.view.addSubview(viewBackButton)
            
            containerView = UIView(frame: CGRect(x: 0,  y: viewBackButton.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.view.bounds.height * 0.25))
            containerView.translatesAutoresizingMaskIntoConstraints = false
        }else{
        
            viewBackButton = UIView(frame: CGRect(x: 0,  y: 0, width: self.view.bounds.width, height: self.view.bounds.height * 0.20 ))
            viewBackButton.backgroundColor = WMColor.dark_blue
            
            lbltitle = UILabel(frame: CGRect(x: 15, y: 10, width: viewBackButton.frame.size.width-50 , height: 30))
            lbltitle.textColor = UIColor.white
            lbltitle.font = WMFont.fontMyriadProRegularOfSize(12)
            lbltitle.text = NSLocalizedString("superExpress.info.description", comment: "")
            lbltitle.numberOfLines = 0
            
            btnCerrarModulo = UIButton(frame: CGRect(x: viewBackButton.frame.size.width-40, y: 10, width: 30, height: 30))
            btnCerrarModulo.setImage(UIImage(named: "closeScan"), for: UIControlState.normal)
            btnCerrarModulo.addTarget(self, action: #selector(self.cierraModal(_:)), for: UIControlEvents.touchUpInside)
            
            self.field = FormFieldSearch()
            self.field!.frame = CGRect(x: 15, y: lbltitle.frame.maxY + 5, width: self.view.bounds.width * 0.7, height: 40)
            self.field!.delegate = self
            self.field!.returnKeyType = .done
            self.field!.autocapitalizationType = .none
            self.field!.autocorrectionType = .no
            self.field!.enablesReturnKeyAutomatically = true
            self.field!.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            self.field!.placeholder = NSLocalizedString("superExpress.search.field.placeholder",comment:"")
            
            btnCancelar = UIButton()
            btnCancelar.frame = CGRect(x: field!.frame.maxX, y: lbltitle.frame.maxY + 5  , width: self.view.bounds.width * 0.3 - 15 , height: 40)
            btnCancelar.setTitle("Cancelar", for: UIControlState())
            btnCancelar.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
            btnCancelar.addTarget(self, action: #selector(self.borraTexto(_:)), for: UIControlEvents.touchUpInside)
            viewBackButton.addSubview(btnCancelar)
            
            viewBackButton.addSubview(btnCerrarModulo)
            viewBackButton.addSubview(lbltitle)
            viewBackButton.addSubview(field!)
            self.view.addSubview(viewBackButton)
            
            containerView = UIView(frame: CGRect(x: 0,  y: viewBackButton.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.view.bounds.height * 0.20))
            containerView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        containerView.tag=500
        self.view.addSubview(containerView)        // add child view controller view to container
        
        
        
        listaSuper = UITableView()
        listaSuper.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height - 150)
        listaSuper.delegate = self
        listaSuper.dataSource = self
        listaSuper.register(SEListaViewCell.self, forCellReuseIdentifier: "itemListasCell")
        listaSuper.separatorStyle = .none
        listaSuper.allowsSelection = false
        containerView.addSubview(listaSuper)
        
        okButton = UIButton()
        okButton.frame = CGRect(x: self.containerView.frame.size.width / 2 - self.containerView.frame.size.width / 4, y: listaSuper.frame.maxY + 5, width: self.containerView.frame.size.width / 2, height: 30)
        okButton!.addTarget(self, action: #selector(self.createPreferedCar(_:)), for: .touchUpInside)
        okButton.tintColor = UIColor.white
        okButton.setTitle("Listo" , for: UIControlState.normal)
        okButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        okButton.backgroundColor = WMColor.green
        okButton.layer.cornerRadius = 15
        
        containerView.addSubview(okButton)
        
        
        self.initArrays()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        sugestedTerms = UIScrollView(frame: .zero)
        
        sugestedTerms?.delegate = self
        sugestedTerms?.isScrollEnabled = true
        sugestedTerms?.isUserInteractionEnabled = true
        sugestedTerms?.showsHorizontalScrollIndicator = true
        sugestedTerms.frame = CGRect(x: 15, y: (field?.frame.maxY)! + (viewBackButton.frame.maxY - (field?.frame.maxY)!) / 2 - 10, width: viewBackButton.frame.size.width + 200, height: 30)
        sugestedTerms.autoresizingMask = UIViewAutoresizing.flexibleWidth
        
        self.viewBackButton.addSubview(sugestedTerms)
        
        
        self.cargaSugerencias()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SESearchViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /// move scroll view up
    func keyBoardWillShow(notification: Notification) {
        UIView.animate(withDuration: 1.0, animations: { // 3.0 are the seconds
            self.lbltitle.isHidden = true
            self.btnCerrarModulo.isHidden = true
            var decremento = CGFloat(0)
            if IS_IPHONE_4_OR_LESS || IS_IPHONE_5{
                decremento = CGFloat(40)
            }else{
                decremento = CGFloat(35)
            }
            
            self.viewBackButton.frame = CGRect(x: 0,  y: 0, width: self.viewBackButton.frame.width, height: self.viewBackButton.frame.height - decremento)
            self.field!.frame = CGRect(x: 15, y: self.field!.frame.origin.y - decremento, width: self.view.bounds.width * 0.7, height: 35)
            self.containerView.frame = CGRect(x: 0,  y: self.containerView.frame.origin.y - decremento, width: self.view.bounds.width, height: self.containerView.frame.height)
            self.btnCancelar.frame = CGRect(x: self.field!.frame.maxX, y: self.btnCancelar.frame.origin.y - decremento , width: self.view.bounds.width * 0.3 - 15 , height: 35)
            
            self.sugestedTerms.frame = CGRect(x: 15, y: (self.field?.frame.maxY)! + (self.viewBackButton.frame.maxY - (self.field?.frame.maxY)!) / 2 - 10, width: self.viewBackButton.frame.size.width + 200, height: 30)
            self.viewBackButton.layoutIfNeeded()
            
        })
    }
    
    /// move scrollview back down
    func keyBoardWillHide(notification: Notification) {
        UIView.animate(withDuration: 1.0, animations: { // 3.0 are the seconds
            self.lbltitle.isHidden = false
            self.btnCerrarModulo.isHidden = false
            var aumento = CGFloat(0)
            if IS_IPHONE_4_OR_LESS || IS_IPHONE_5{
                aumento = CGFloat(40)
            }else{
                aumento = CGFloat(35)
            }
            
            self.viewBackButton.frame = CGRect(x: 0,  y: 0, width: self.viewBackButton.frame.width, height: self.viewBackButton.frame.height + aumento)
            self.field!.frame = CGRect(x: 15, y: self.field!.frame.origin.y + aumento, width: self.view.bounds.width * 0.7, height: 35)
            self.containerView.frame = CGRect(x: 0,  y: self.containerView.frame.origin.y + aumento, width: self.view.bounds.width, height: self.containerView.frame.height)
            self.btnCancelar.frame = CGRect(x: self.field!.frame.maxX, y: self.btnCancelar.frame.origin.y + aumento , width: self.view.bounds.width * 0.3 - 15 , height: 35)
            
            self.sugestedTerms.frame = CGRect(x: 15, y: (self.field?.frame.maxY)! + (self.viewBackButton.frame.maxY - (self.field?.frame.maxY)!) / 2 - 10, width: self.viewBackButton.frame.size.width + 200, height: 30)
            self.viewBackButton.layoutIfNeeded()
            
        })

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
    
    func cierraModal(_ sender:UIButton) {
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
        }
        _ = self.navigationController?.popViewController(animated: true)
        
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
    
    func addToList(_ sender:UIButton){
        if !selectedItems.contains(myArray[sender.tag].lowercased()){
            selectedItems.append(myArray[sender.tag].lowercased())
            listaSuper.reloadData()
        }
        self.field?.text = ""
        self.myArray = []
        self.cargaSugerencias()
    }
    
    func delFromList(_ sender:UIButton){
        selectedItems.remove(at: sender.tag)
        listaSuper.reloadData()
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
            cellreturn.backgroundColor = UIColor .white
        }
        
        return cellreturn
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        myArray = []
        myArray = allItems.filter { $0.lowercased().hasPrefix(textField.text!.lowercased()) }
        if myArray.count == 0{
            self.invokeTypeAheadService()
        }
        self.cargaSugerencias()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Text.rawValue
        
        if textField.text != nil && textField.text!.lengthOfBytes(using: String.Encoding.utf8) > 2 {
            
            if !validateSearch(textField.text!)  {
                showMessageValidation(NSLocalizedString("field.validate.text",comment:""))
                return true
            }
            //buscaSugerencias(textField.text)
            if !selectedItems.contains(textField.text!.lowercased()){
                selectedItems.append(textField.text!.lowercased())
                listaSuper.reloadData()
            }
            textField.text = ""
            self.myArray = []
            self.cargaSugerencias()
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
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
        }
        return true
    }
    
    func initArrays(){
        self.invokeSEabcService()
        
        
       /*allItems = ["Aceite", "Aceite De Oliva", "Aceitunas", "Agua", "Aguacate", "Ajo", "Apio", "Arroz", "Atun", "Avena", "Azucar", "Brocoli", "Café", "Calabaza", "Camarón", "Carne", "Carne Molida", "Catsup", "Cebolla", "Cereal", "Cerveza", "Cilantro", "Cloro", "Crema", "Detergente", "Elote", "Endulzante", "Ensalada", "Espinacas", "Frijoles", "Galletas", "Gelatina", "Harina", "Jamón", "Jicama", "Jitomate", "Leche", "Lechuga", "Limon", "Limpiador", "Mango", "Mantequilla", "Manzana", "Mayonesa", "Melon", "Naranja", "Nopal", "Nuez", "Nutella", "Pan", "Pan Molido", "Pañales", "Papa", "Papaya", "Papel De Baño", "Papel Higiénico", "Pechuga De Pavo", "Pechuga De Pollo", "Pepino", "Pera", "Perejil", "Pescado", "Pimienta", "Pimiento", "Piña", "Platano", "Pollo", "Puré De Tomate", "Queso", "Queso Crema", "Queso De Cabra", "Queso Manchego", "Queso Oaxaca", "Queso Panela", "Refresco", "Repelente", "Sal", "Salchichas", "Salmón", "Servilletas", "Shampoo", "Suavizante", "Te", "Tocino", "Tomate", "Tortillas", "Vainilla", "Vinagre", "Zanahoria"]*/
        myArray = []
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
        }
        view.endEditing(true)
    }
    
    func createPreferedCar(_ sender:UIButton){
        if selectedItems.count > 0{
            let controller = SESugestedCar()
            controller.titleHeader = "Súper en minutos"
            controller.searchWords = selectedItems
            controller.delegate = self
            self.navigationController!.pushViewController(controller, animated: true)
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
                                    self.getSugerenciasArray(arrayPalabras: [] as! [String])
            }
        )
    }
    
    func invokeTypeAheadService() {
        
        //self.showLoadingView()
        
        if UserCurrentSession.hasLoggedUser(){
            let typeaheadService = SEtypeaheadListService()
            typeaheadService.callService(params: ["pText":field?.text],
                                         successBlock: { (response:[String:Any]) -> Void in
                                            print("Call TypeaheadService success")
                                            self.removeLoadingView()
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
                                            self.removeLoadingView()
                                            self.getSugerenciasBySearch(arrayPalabras: response["searchTerms"] as! [String])
            },
                                         errorBlock: { (error:NSError) -> Void in
                                            print("Call TiresSizeSearchService error \(error)")
                                           // self.removeLoadingView()
            }
            )
        }
        
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
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
        }
    }
    
    func closeViewController(){
        _ = self.navigationController?.popViewController(animated: true)
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
