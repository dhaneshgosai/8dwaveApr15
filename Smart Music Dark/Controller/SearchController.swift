//
//  SearchController.swift
//  8DWave
//
//  Created by Abraham Sameer on 11/30/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation
import UIKit

class SearchController: UIViewController {
    
    lazy var searchBar:UISearchBar = UISearchBar()
    let searchController = UISearchController(searchResultsController: nil)
    fileprivate let cellId = "cellId"
    fileprivate let cellArtistId = "cellArtistId"
    
    let tableView = UITableView()
    var songs: [SMSong] = []
    var artists: [SMArtists] = []
    var search = ""
    var searchTemp = ""
    
    var headerTitle = ["Artists","Tracks"]
    
    private func setupView(){
        tableView.dataSource = self
        tableView.delegate = self
        
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        tableView.register(SearchTrackCell.self, forCellReuseIdentifier: cellId)
        tableView.register(SearchArtistCell.self, forCellReuseIdentifier: cellArtistId)
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.bounces = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(views: tableView)
        tableView.fill(toView: view, space: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), isActive: true)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: AppStateHelper.shared.defaultFontBold(size: 32), NSAttributedString.Key.foregroundColor: UIColor.white]
            
            self.navigationItem.titleView = searchController.searchBar
            self.navigationItem.hidesSearchBarWhenScrolling = false
            navigationController?.navigationBar.prefersLargeTitles = false
            searchController.hidesNavigationBarDuringPresentation = false

        }else {
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.searchBarStyle = UISearchBar.Style.default
            self.tableView.tableHeaderView = searchController.searchBar
        }
        setupSearchBarStyle()
    }
    
    fileprivate func setupSearchBarStyle(){
        let searchbarTextColor:UIColor = .rgba(151, 190, 232, 1)
        searchController.searchBar.barTintColor = searchbarTextColor
        for view in searchController.searchBar.subviews {
            for subview in view.subviews {
                if let textField = subview as? UITextField, let glassIconView = textField.leftView as? UIImageView {
                    glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                    glassIconView.tintColor = searchbarTextColor
                    textField.backgroundColor = #colorLiteral(red: 0.137254902, green: 0.2235294118, blue: 0.3294117647, alpha: 1)
                    textField.tintColor = searchbarTextColor
                    textField.textColor = searchbarTextColor
                    textField.attributedPlaceholder = NSAttributedString(string: textField.attributedPlaceholder?.string ?? "Search",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: searchbarTextColor])
                }
            }
        }
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): searchbarTextColor], for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "Search"
        self.view.backgroundColor = UIColor.themeNavbarColor()
        setupView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.roundCorners([.topLeft, .topRight], radius: 25)
    }
    
    let debouncer = Debouncer(interval: 0.5)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        searchTemp =  searchBar.text!
        
        if !(searchText.isEmpty) {
            debouncer.call()
            debouncer.callback = {
                self.search = searchBar.text!
                self.onHandleRequest(search: self.search)
            }
        } else {
            DispatchQueue.main.async {
                self.songs = []
                self.artists = []
                self.tableView.separatorStyle = .none
                self.tableView.reloadData()
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text!.isEmpty {
            return
        }
        search = searchBar.text!
        onHandleRequest(search: search)
    }
    func onHandleRequest(search: String){
        if search.isEmpty {
            return
        }
        AppStateHelper.shared.onHandleShowIndicator()
        SMService.onHandleGetSearch("search?search="+search,{ (song,artist) in
            DispatchQueue.main.async {
                AppStateHelper.shared.onHandleHideIndicator()
                self.songs = song
                self.artists = artist
                self.tableView.reloadData()
            }
        }, onError: {(errorString) in
            DispatchQueue.main.async {
                AppStateHelper.shared.onHandleAlertNotifiError(title: alermsg)
            }
            print("error")
        })
    }
    
    
}
extension SearchController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
}

extension SearchController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            let artistSingleController = ArtistSingleController()
            artistSingleController.artists = artists
            artistSingleController.currentIndex = indexPath.row
            artistSingleController.title = artists[indexPath.row].title
            navigationController?.pushViewController(artistSingleController, animated: true)

            
        }else if indexPath.section == 1 {
            
            PlayerController.sharedController.songs = self.songs
            PlayerController.sharedController.indexPlaying = indexPath.row
            (self.tabBarController as? CustomTabBarController)?.songs = self.songs
            (self.tabBarController as? CustomTabBarController)?.indexPlaying = indexPath.row
            (self.tabBarController as? CustomTabBarController)?.setUpShowPlayer()
            (self.tabBarController as? CustomTabBarController)?.handeSetUpPlayer()
            
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 0 {
            return 70
        } else {
            return 70
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        switch section {
        case 0:
            if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                return 42
            }
        case 1:
            if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                return 42
            }
        default:
            return 0
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let subView = UIView()
        let label = UILabel()
        subView.backgroundColor = UIColor.white
        label.text = headerTitle[section]
        label.font = AppStateHelper.shared.defaultFontBold(size:18)
        
        subView.addSubview(label)
        label.textColor = .rgba(4, 16, 32, 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        label.heightAnchor.constraint(equalToConstant: 40).isActive = true
        label.leftAnchor.constraint(equalTo: subView.leftAnchor,constant: 20).isActive = true
        
        return subView
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return headerTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return artists.count
        }else {
            return songs.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier:cellArtistId, for: indexPath) as! SearchArtistCell
            cell.artist = artists[indexPath.row]
            cell.selectionStyle = .none
            cell.separatorInset = .zero
            cell.layoutMargins = .zero
            cell.backgroundColor = UIColor.themeBaseColor()
            return cell
        }else  {
            let cell = tableView.dequeueReusableCell(withIdentifier:cellId, for: indexPath) as! SearchTrackCell
            cell.song = songs[indexPath.row]
            cell.selectionStyle = .none
            cell.separatorInset = .zero
            cell.layoutMargins = .zero
            cell.backgroundColor = UIColor.themeBaseColor()
            return cell
        }
        
    }
    
}
