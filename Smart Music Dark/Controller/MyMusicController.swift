//
//  MyMusicController.swift
//  8DWave
//
//  Created by Abraham Sameer on 11/30/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import UIKit
import CarbonKit

class CustomBarButtonItem:UIBarButtonItem{
    var selfType:WhatVC?
    var isEditting:Bool = false
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
@objc enum WhatVC:Int {
    case downloading,downloaded
}

class MyMusicController: UIViewController, CarbonTabSwipeNavigationDelegate {
    
    var items = NSArray()
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation = CarbonTabSwipeNavigation()
    
    
    fileprivate func setupView(){
        let carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items as [AnyObject], delegate: self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self)
        let color: UIColor =  #colorLiteral(red: 0.5921568627, green: 0.7450980392, blue: 0.9098039216, alpha: 1)
        carbonTabSwipeNavigation.setIndicatorColor(UIColor.themeBaseColor())
        carbonTabSwipeNavigation.setIndicatorHeight(45)
        carbonTabSwipeNavigation.setTabExtraWidth(0)
        carbonTabSwipeNavigation.setTabBarHeight(45)
        
        carbonTabSwipeNavigation.carbonSegmentedControl?.setWidth(self.view.bounds.width/2, forSegmentAt: 0)
        carbonTabSwipeNavigation.carbonSegmentedControl?.setWidth(self.view.bounds.width/2, forSegmentAt: 1)
        
        carbonTabSwipeNavigation.setNormalColor(UIColor.white.withAlphaComponent(1.0))
        carbonTabSwipeNavigation.setSelectedColor(UIColor.themeNavbarColor(), font: UIFont.systemFont(ofSize: 13, weight: .light))
        carbonTabSwipeNavigation.setNormalColor(UIColor.themeButtonsColor(), font: UIFont.systemFont(ofSize: 13, weight: .light))
        carbonTabSwipeNavigation.toolbar.barTintColor = color
        carbonTabSwipeNavigation.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.roundCorners([.topLeft, .topRight], radius: 25)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.themeNavbarColor()
        UIView.setupNavigationTitle(title: "My Music", navigationItem: self.navigationItem)
        self.navigationItem.title = "My Music"
        items = ["Downloading","Downloaded"]
        setupView()

    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        switch index {
        case 0:
            return DownloadingController.sharedController
        default:
            return DownloadedController.sharedController
        }
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAt index: UInt) {
        switch index {
        case 0:
            navigationItem.rightBarButtonItems = []
            break
        default:
            let editListButton = CustomBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onHandleEditList))
            
            editListButton.selfType = .downloaded
            editListButton.tintColor = UIColor.white
            navigationItem.rightBarButtonItems = [editListButton]
            break
        }
        
    }
    
    fileprivate func updateCurrentButton(_ sender:CustomBarButtonItem, _ who: WhatVC){
        
        if sender.isEditting == false {
            if sender.selfType ==  .downloaded {
                DownloadedController.sharedController.editCommand()
            } else if sender.selfType ==  .downloading {
               DownloadingController.sharedController.editCommand()
            }
            self.changeBarbuttonTitle(sender, "Done")
            sender.isEditting = true
        }else {
            
            if sender.selfType ==  .downloaded {
                DownloadedController.sharedController.doneCommand()
            }
            else if sender.selfType ==  .downloading {
                DownloadingController.sharedController.doneCommand()
            }
            self.changeBarbuttonTitle(sender, "Edit")
            sender.isEditting = false
        }
    }
    
    
    fileprivate func changeBarbuttonTitle(_ sender:CustomBarButtonItem , _ title:String){
        sender.title = title
    }
    
    
    @objc func onHandleEditList(sender:CustomBarButtonItem) {
        if sender.selfType == .downloaded{
            self.updateCurrentButton(sender, .downloaded)
        }else if sender.selfType == .downloading {
            self.updateCurrentButton(sender, .downloading)
        } 
    }
    
}
