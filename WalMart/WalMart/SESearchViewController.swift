//
//  SESearchViewController.swift
//  WalMart
//
//  Created by Vantis on 10/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import UIKit

class SESearchViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate{
    
    var alertView : IPOWMAlertViewController? = nil
    var loading: WMLoadingView?
    var searchButton: UIButton!
    
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
    var field: UITextField?
    var myArray : [String]! = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
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
        self.field!.frame = CGRect(x: 15, y: lbltitle.frame.maxY + 10, width: self.view.bounds.width * 0.7, height: 40)
        self.field!.delegate = self
        self.field!.returnKeyType = .search
        self.field!.autocapitalizationType = .none
        self.field!.autocorrectionType = .no
        self.field!.enablesReturnKeyAutomatically = true
        self.field!.placeholder = NSLocalizedString("superExpress.search.field.placeholder",comment:"")
        
        viewBackButton.addSubview(btnCerrarModulo)
        viewBackButton.addSubview(lbltitle)
        viewBackButton.addSubview(field!)
        self.view.addSubview(viewBackButton)
        
        containerView = UIView(frame: CGRect(x: 0,  y: viewBackButton.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.view.bounds.height * 0.20))
        containerView.backgroundColor=UIColor.red
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        searchButton = UIButton(type: .custom)
        //searchButton!.addTarget(self, action: #selector(SearchTiresBySize(_:)), for: .touchUpInside)
        searchButton.tintColor = UIColor.white
        searchButton.setTitle("Buscar" , for: UIControlState.normal)
        searchButton.backgroundColor = WMColor.light_blue
        searchButton.layer.cornerRadius = 14.0
        
        
        containerView.tag=500
        self.view.addSubview(containerView)        // add child view controller view to container
        
        myArray = ["agua","leche","pan","huevo","pasta de dientes","caramelo","a","b","c","a","b","colorante"]
        
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
            widthAnt += Int(button.frame.size.width) + 15
            
            self.sugestedTerms.addSubview(button)
        }
        sugestedTerms?.contentSize = CGSize(width: CGFloat(widthAnt) + 200 , height: sugestedTerms.frame.size.height)
    }
}
