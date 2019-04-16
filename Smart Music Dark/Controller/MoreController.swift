//
//  MoreController.swift
//  8DWave
//
//  Created by Abraham Sameer on 11/30/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//



import Foundation
import UIKit
import CTFeedbackSwift
import FirebaseAuth

class MoreController: UIViewController {
    let LOGOUT_INDEX = 1
    let items = [
        (name:"Support", image:"help"),
        (name:"Log out", image:"logout")]
    
    var tableView = UITableView()
    
    fileprivate let cellId = "cellId"
    
    fileprivate func setupView() {
        self.navigationItem.title = "More"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.bounces = false
        //tableView.roundCorners([.topLeft, .topRight], radius: 25)
        //tableView.clipsToBounds = true
        tableView.backgroundColor = UIColor.themeBaseColor()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(views: tableView)
        tableView.fill(toView: view, space: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), isActive: true)
        //view.layoutIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.setupNavigationTitle(title: "More", navigationItem: self.navigationItem)
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.themeNavbarColor()
        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "More"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = "Back"
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.roundCorners([.topLeft, .topRight], radius: 25)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
}
extension MoreController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            
            let configuration = FeedbackConfiguration(toRecipients: ["support@8dwave.com"], usesHTML: true)
            let controller = FeedbackViewController(configuration: configuration)
            controller.title = "Support"
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == LOGOUT_INDEX {
            showLogoutMessage()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = items[indexPath.row].name
        let image = UIImage(named: items[indexPath.row].image)
        cell.imageView?.image = image?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = UIColor.themeNavbarColor()
        cell.textLabel?.font = AppStateHelper.shared.defaultFontRegular(size: 16)
        cell.textLabel?.textColor = UIColor.themeNavbarColor()
        cell.backgroundColor = UIColor.themeBaseColor()
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }

    func showLogoutMessage() {
        let controller = UIAlertController(title: "", message: "Continue log out?", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Logout", style: .default, handler: { [weak self] _ in
            FirebaseHelper().saveLoginStatus(didLogin: false)
            MusicPlayer.sharedInstance.audioPlayer?.pause()
            MusicPlayer.sharedInstance.audioPlayer = nil
            Setting.isPremium = false

            try? Auth.auth().signOut()
            let loginController = UINavigationController(rootViewController: LoginController())
            self?.present(loginController, animated: true)

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginController
        }))
        controller.addAction(UIAlertAction(title: "No", style: .cancel))
        present(controller, animated: true)
    }
}
