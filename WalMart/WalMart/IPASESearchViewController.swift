//
//  IPASESearchViewController.swift
//  WalMart
//
//  Created by Vantis on 03/08/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class IPASESearchViewController : UIViewController{

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
    var viewSearch: UIView!
    var viewBG : UIView!
    let screenSizePercent: CGFloat! = 0.7
    let cornerRadiusValue: CGFloat! = 20
    let titlesFontSize: CGFloat! = 20

    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.clear
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        viewBG = UIView(frame:CGRect.zero)
        self.view.addSubview(viewBG)
        
        viewSearch = UIView(frame: CGRect.zero)
        self.viewBG.addSubview(viewSearch)

        viewBG.alpha = 0
        viewBG.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.view.addSubview(viewBG)
        
        viewSearch.layer.cornerRadius=cornerRadiusValue
        viewSearch.backgroundColor=UIColor.white
        self.viewBG.addSubview(viewSearch)
        
        
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
        
        viewSearch.frame =  CGRect(x: self.viewBG.frame.size.width/2 - self.viewBG.frame.size.width*screenSizePercent/2, y: self.viewBG.frame.size.height/2 - self.viewBG.frame.size.height*screenSizePercent/2, width: self.viewBG.frame.size.width*screenSizePercent, height:self.viewBG.frame.size.height*screenSizePercent)
    }

}
