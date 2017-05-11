//
//  TutorialHelpView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 18/05/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class TutorialHelpView: UIView, UIScrollViewDelegate {
    
    var onClose: (() -> Void)!
    var pointSection: UIView? = nil
    var pointContainer: UIView? = nil
    var labelTitle: UILabel! = nil
    var pointButtons: [UIButton]? = nil
    var items: [[String:String]]? = nil
    var currentItem: Int? = nil
    var scrollHelp: UIScrollView!
    var logoImage: UIImageView!
    var buttonClose: UIButton!
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    init(frame: CGRect, properties: [[String:String]]) {
        super.init(frame:frame)
        items = properties
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        buttonClose = UIButton(frame: CGRect(x: 0, y: 20, width: 44, height: 44))
        buttonClose.setImage(UIImage(named:"tutorial_close"), for: UIControlState())
        buttonClose.addTarget(self, action: #selector(TutorialHelpView.removeHelp), for: UIControlEvents.touchUpInside)
        addSubview(buttonClose)
        
        logoImage = UIImageView(frame: CGRect(x: (frame.width / 2) - 55, y: 0, width: 110, height: 44))
        logoImage.image = UIImage(named:"navBar_logo")
        logoImage.contentMode = .center
        addSubview(logoImage)
        
        labelTitle = UILabel()
        labelTitle.font = WMFont.fontMyriadProLightOfSize(16)
        labelTitle.textAlignment = .center
        labelTitle.textColor = UIColor.white
        labelTitle.text = ""
        labelTitle.numberOfLines = 2
        addSubview(labelTitle)
        
        scrollHelp = UIScrollView()
        addSubview(scrollHelp)
        
        pointSection = UIView()
        pointSection?.backgroundColor = UIColor.clear
        addSubview(pointSection!)

        let first = items![0]
        labelTitle.text = first["details"] as String!
        currentItem = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(TutorialHelpView.removeHelp), name: NSNotification.Name(rawValue: "OPEN_TUTORIAL"), object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if scrollHelp != nil && buttonClose != nil   {
            
            let yPosition: CGFloat = (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) ? 0 : 20
            
            logoImage.frame = CGRect(x: (frame.width / 2) - 55, y: 20, width: 110, height: 44)
            labelTitle.frame = CGRect(x: 30, y: logoImage.frame.maxY + yPosition, width: frame.width - 60, height: 44)
            pointSection?.frame = CGRect(x: 0, y: frame.height - (40 + yPosition), width: frame.width, height: 20)
            
            let scrollHeight = (pointSection!.frame.minY - 20) - (labelTitle.frame.maxY + yPosition) - 20
            scrollHelp.frame = CGRect(x: 0, y: labelTitle.frame.maxY + 20, width: bounds.width, height: scrollHeight)
            
            buildViewImages()
            
        }
    }

    func buildViewImages() {
        
        if buttonClose != nil {
            
            for imageView in scrollHelp.subviews {
                imageView.removeFromSuperview()
            }
            
            scrollHelp.delegate = self
            var currentX: CGFloat = 0.0
            
            for itemTutorial in items! {
                let imgHelp = UIImage(named: itemTutorial["image"] as String!)
                let imageForHelp = UIImageView(image: imgHelp)
                imageForHelp.contentMode = UIViewContentMode.center
                imageForHelp.frame = CGRect(x: currentX , y: (scrollHelp!.frame.height - imgHelp!.size.height) / 2, width: frame.width , height: imgHelp!.size.height)
                scrollHelp.addSubview(imageForHelp)
                scrollHelp.isPagingEnabled = true
                currentX = currentX + frame.width
            }
            
            let viewFinish = UIView()
            viewFinish.frame = CGRect(x: currentX , y: 0,width: frame.width , height: 400)
            viewFinish.backgroundColor = UIColor.clear
            
            let labelDesc = UILabel(frame: CGRect(x: 30, y: 84, width: frame.width - 60, height: 44))
            labelDesc.font = WMFont.fontMyriadProLightOfSize(16)
            labelDesc.textAlignment = .center
            labelDesc.textColor = UIColor.white
            labelDesc.text = "Consulta este tutorial en cualquier \nmomento desde el menú de Ayuda."
            labelDesc.numberOfLines = 2
            viewFinish.addSubview(labelDesc)
            
            let buttonFinish = UIButton(frame: CGRect(x: (frame.width / 2) - 80, y: 160, width: 160, height: 36))
            buttonFinish.setTitle("Ok", for: UIControlState())
            buttonFinish.layer.cornerRadius = 18
            buttonFinish.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
            buttonFinish.backgroundColor = WMColor.green
            buttonFinish.addTarget(self, action: #selector(TutorialHelpView.finishRemoveHelp), for: UIControlEvents.touchUpInside)
            viewFinish.addSubview(buttonFinish)

            scrollHelp.addSubview(viewFinish)
            currentX = currentX + frame.width
            
            scrollHelp.contentSize = CGSize(width: currentX, height: scrollHelp.frame.height)
            scrollHelp.showsHorizontalScrollIndicator = false
            
            
            buildButtonSection()
        }
        
    }
    
    func removeHelp() {
        if onClose != nil {
              NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "OPEN_TUTORIAL"), object: nil)
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TUTORIAL_AUTH.rawValue,categoryNoAuth:WMGAIUtils.CATEGORY_TUTORIAL_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_CLOSE_TUTORIAL.rawValue, label: "")
            onClose()
        }
    }
    
    func finishRemoveHelp() {
        if onClose != nil {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TUTORIAL_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_TUTORIAL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_CLOSE_END_TUTORIAL.rawValue, label: "")
            onClose()
        }
    }
    
    func buildButtonSection() {
        
        if let container = pointContainer {
            container.removeFromSuperview()
        }
        
        pointContainer = UIView()
        pointSection!.addSubview(pointContainer!)
        
        var buttons = Array<UIButton>()
        let size = items!.count + 1
        
        if size > 0 {
            
            let bsize: CGFloat = 8.0
            let sep: CGFloat = 5.0
            var x: CGFloat = 0.0
            
            for idx in 0 ..< size {
                
                let point = UIButton(type: .custom)
                point.frame = CGRect(x: x, y: 0, width: bsize, height: bsize)
                point.setImage(UIImage(named: "control_help_inactivo"), for: UIControlState())
                point.setImage(UIImage(named: "control_help_activo"), for: .selected)
                point.setImage(UIImage(named: "control_help_activo"), for: .highlighted)
                point.addTarget(self, action: #selector(TutorialHelpView.pointSelected(_:)), for: .touchUpInside)
                point.isSelected = idx == currentItem!
                
                x = point.frame.maxX
                
                if idx < size {
                    x += sep
                }
                
                pointContainer!.addSubview(point)
                buttons.append(point)
            }
            
            let pbounds = pointSection!.frame
            pointContainer!.frame = CGRect(x: (pbounds.size.width - x)/2,  y: (20.0 - bsize)/2, width: x, height: 20.0)
        }
        
        pointButtons = buttons
    }
    
    func pointSelected(_ sender: UIButton) {
        
        for button: UIButton in pointButtons! {
            button.isSelected = button === sender
        }
        
        if (pointButtons!).index(of: sender) != nil {
            scrollHelp!.scrollRectToVisible(CGRect(x: 0, y: 0, width: frame.width, height: scrollHelp!.frame.height), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let currentIndex = scrollHelp!.contentOffset.x / scrollHelp!.frame.size.width
        currentItem = Int(currentIndex)
        let array = pointButtons! as [Any]
        
        if let button = array[currentItem!] as? UIButton {
            for inner: UIButton in pointButtons! {
                inner.isSelected = button === inner
            }
        }
        
        if items?.count == currentItem! {
            labelTitle!.text = ""
        } else {
            let first = items![currentItem!]
            labelTitle!.text = first["details"] as String!
        }
        
    }
    
}
