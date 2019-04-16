//
//  CreateMusicController.swift
//  8DWave
//
//  Created by VasylChekun on 18.03.19.
//  Copyright © 2019 Abraham Sameer. All rights reserved.
//

import UIKit

class CreateMusicController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.setupNavigationTitle(title: "Create 8D Music", navigationItem: self.navigationItem)
        self.setupView()
        view.backgroundColor = UIColor.themeBaseColor()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.roundCorners([.topLeft, .topRight], radius: 25)
    }
    
    lazy var tryItOutLabel = { () -> UILabel in
        let label = UILabel()
        label.textColor = UIColor.themeNavbarColor()
        label.font = AppStateHelper.shared.defaultFontBold(size: 38)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.text = "Try it Out Now for FREE!"
        return label
    }()
    
    lazy var instantlyCreateLabel = { () -> UILabel in
        let label = UILabel()
        label.textColor = UIColor.themeNavbarColor()
        label.font = AppStateHelper.shared.defaultFontBold(size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "Instantly Create and Upload 8D Music with our world class 8DWave Audio Converter"
        return label
    }()
    
    lazy var onYourComputerLabel = { () -> UILabel in
        let label = UILabel()
        label.textColor = UIColor.themeNavbarColor()
        label.font = AppStateHelper.shared.defaultFontBold(size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "On your Computer, please visit\n create.8dwave.com"
        return label
    }()
    
    func setupView() {
        self.view.backgroundColor = UIColor.themeTabarColor()
        self.setupTryItOutLabel()
        self.setupOnYourComputerLabel()
        self.setupInstantlyCreateLabel()
        self.setupMusicImage()
        self.setupComputerImage()
    }
    
    func setupComputerImage(){
        let imageView = UIImageView(image: UIImage(named: "Create_Computer"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.topAnchor.constraint(equalTo: tryItOutLabel.bottomAnchor, constant: 40).isActive = true
        imageView.bottomAnchor.constraint(equalTo: onYourComputerLabel.topAnchor, constant: 0).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
    }
    
    func setupMusicImage(){
        let imageView = UIImageView(image: UIImage(named: "Create_Music"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        imageView.bottomAnchor.constraint(equalTo: instantlyCreateLabel.topAnchor, constant: 0).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
    }
    
    func setupTryItOutLabel(){
        view.addSubview(tryItOutLabel)
        tryItOutLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tryItOutLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tryItOutLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -60).isActive = true
    }
    
    func setupOnYourComputerLabel(){
        view.addSubview(onYourComputerLabel)
        onYourComputerLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35).isActive = true
        onYourComputerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        onYourComputerLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -60).isActive = true
    }
    
    func setupInstantlyCreateLabel(){
        view.addSubview(instantlyCreateLabel)
        instantlyCreateLabel.bottomAnchor.constraint(equalTo: tryItOutLabel.topAnchor, constant: 0).isActive = true
        instantlyCreateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        instantlyCreateLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -60).isActive = true
    }

}
