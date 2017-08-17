//
//  SESugestedRow.swift
//  WalMart
//
//  Created by Vantis on 19/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation
import UIKit

protocol SESugestedRowDelegate {
    func itemSelected(seccion:Int, itemSelected: Int)
    func itemDeSelected(seccion:Int, itemSelected: Int)
}

class SESugestedRow : UITableViewCell, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SESugestedCarViewCellDelegate {
    var collection: UICollectionView?
    var contenido: UIView!
    var productosData: [[String:Any]]? = nil
    var section: Int!
    var delegate: SESugestedCar?
    var selectedItems : [Bool]! = []
    var widthScreen : CGFloat!
    var isNewSection : Bool! = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        
        
        contenido = UIView(frame: CGRect(x: 0, y: 0, width: self.widthScreen, height: 100))
        contenido.backgroundColor = WMColor.light_light_gray
        if !isNewSection{
        
            collection = getCollectionView()
            collection?.register(SESugestedCarViewCell.self, forCellWithReuseIdentifier: "sugestedCarViewCell")
            collection?.allowsMultipleSelection = false
            collection!.dataSource = self
            collection!.delegate = self
            collection!.backgroundColor = WMColor.light_light_gray
            self.contenido.addSubview(collection!)
        }
        
        self.addSubview(self.contenido)
        
    }
    
    func setValues(_ items:[[String:Any]], section:Int, widthScreen: CGFloat, isNewSect: Bool, selectedItems: [Bool]) {
        self.productosData = items
        self.selectedItems = selectedItems
        self.section = section
        self.widthScreen = widthScreen
        isNewSection = isNewSect
        setup()
    }

    func getCollectionView() -> UICollectionView {
        let customlayout = UICollectionViewFlowLayout()
        customlayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.contenido.frame.width, height: self.contenido.frame.size.height), collectionViewLayout: customlayout)
        
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        
        return collectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productosData!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sugestedCarViewCell", for: indexPath) as! SESugestedCarViewCell
        cell.delegate = self
        let upc = productosData![indexPath.row]["upc"] as? String
        let imagen = productosData![indexPath.row]["url"] as! String
        let descripcion = productosData![indexPath.row]["displayName"] as! String
        let precio = productosData![indexPath.row]["field"] as! String
        let isSelected = selectedItems[indexPath.row]
        
        
        cell.setValues(upc!, productImageURL: imagen, productShortDescription: descripcion, productPrice: precio, isSelected: isSelected, index: indexPath.row)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedItems[indexPath.row] = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if IS_IPAD{
            let hardCodedPadding:CGFloat = 3
            let itemWidth = ((self.superview?.frame.width)! * 0.3) - hardCodedPadding
            let itemHeight = collectionView.bounds.height * 0.9 - (2 * hardCodedPadding)
            return CGSize(width: itemWidth, height: itemHeight)
        }
        let hardCodedPadding:CGFloat = 3
        let itemWidth = ((self.superview?.frame.width)! * 0.7) - hardCodedPadding
        let itemHeight = collectionView.bounds.height * 0.9 - (2 * hardCodedPadding)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    //SESugestedCarViewCellDelegate
    func seleccionados(item:Int){
        selectedItems[item] = true
        delegate?.itemSelected(seccion: self.section, itemSelected: item)
    }
    
    func deseleccionados(item:Int){
        selectedItems[item] = false
        delegate?.itemDeSelected(seccion: self.section, itemSelected: item)
    }
    
}
