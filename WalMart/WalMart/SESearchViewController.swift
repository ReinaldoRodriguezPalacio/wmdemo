//
//  SESearchViewController.swift
//  WalMart
//
//  Created by Vantis on 10/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit

class SESearchViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource{
    
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
    
    var containerView:UIView!
    var listaPalabras:UITableView!
    var viewBuscaLlanta:UIView!
    let cellReuseIdendifier = "cell"
    var selectedItems:[String]! = []
    var allItems:[String]! = []
    
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
            button.setTitle(myArray[i], for: UIControlState())
            button.layer.cornerRadius = 10
            button.contentEdgeInsets = UIEdgeInsetsMake(5,15,5,15)
            button.sizeToFit()
            button.tag = i
            button.addTarget(self, action: #selector(self.addToList(_:)), for: UIControlEvents.touchUpInside)
            widthAnt += Int(button.frame.size.width) + 15
            
            self.sugestedTerms.addSubview(button)
        }
        sugestedTerms?.contentSize = CGSize(width: CGFloat(widthAnt) + 200 , height: sugestedTerms.frame.size.height)
    }
    
    func addToList(_ sender:UIButton){
        selectedItems.append(myArray[sender.tag])
        listaSuper.reloadData()
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
            cellreturn.backgroundColor = WMColor .light_light_gray
            
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
        myArray = allItems.filter { $0.lowercased().contains(textField.text!.lowercased()) }
        self.cargaSugerencias()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Text.rawValue
        
        if textField.text != nil && textField.text!.lengthOfBytes(using: String.Encoding.utf8) > 2 {
            
            //buscaSugerencias(textField.text)
            
            selectedItems.append(textField.text!)
            listaSuper.reloadData()
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
            self.myArray = []
            self.cargaSugerencias()
        }
        
        return true
    }
    
    func initArrays(){
        //self.invokeSEabcService()
        
        
       allItems = ["Aceite", "Aceite De Oliva", "Aceitunas", "Agua", "Aguacate", "Ajo", "Apio", "Arroz", "Atun", "Avena", "Azucar", "Brocoli", "Café", "Calabaza", "Camarón", "Carne", "Carne Molida", "Catsup", "Cebolla", "Cereal", "Cerveza", "Cilantro", "Cloro", "Crema", "Detergente", "Elote", "Endulzante", "Ensalada", "Espinacas", "Frijoles", "Galletas", "Gelatina", "Harina", "Jamón", "Jicama", "Jitomate", "Leche", "Lechuga", "Limon", "Limpiador", "Mango", "Mantequilla", "Manzana", "Mayonesa", "Melon", "Naranja", "Nopal", "Nuez", "Nutella", "Pan", "Pan Molido", "Pañales", "Papa", "Papaya", "Papel De Baño", "Papel Higiénico", "Pechuga De Pavo", "Pechuga De Pollo", "Pepino", "Pera", "Perejil", "Pescado", "Pimienta", "Pimiento", "Piña", "Platano", "Pollo", "Puré De Tomate", "Queso", "Queso Crema", "Queso De Cabra", "Queso Manchego", "Queso Oaxaca", "Queso Panela", "Refresco", "Repelente", "Sal", "Salchichas", "Salmón", "Servilletas", "Shampoo", "Suavizante", "Te", "Tocino", "Tomate", "Tortillas", "Vainilla", "Vinagre", "Zanahoria"]
        myArray = []
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func createPreferedCar(_ sender:UIButton){
        let controller = SESugestedCar()
        controller.titleHeader = "Súper Express"
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func invokeSEabcService() {
        
        self.showLoadingView()
        
        /*let storeService = SEabcService()
        storeService.callService(
            { (response:[String:Any]) -> Void in
                print("Call SEabcService success")
                self.removeLoadingView()
                self.getSugerenciasArray(arrayPalabras: response["abclist"] as! [String])
        },
            errorBlock: { (error:NSError) -> Void in
                print("Call SEabcService error \(error)")
                self.removeLoadingView()
        }
        )*/
        
        let url = URL(string: "http://a9.g.akamai.net/f/9/303455/1m/walmartmx.download.akamai.com/303455/resources/abc.json")
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
    if arrayPalabras.count > 0 {
        allItems = arrayPalabras
    }
    
    }

}
