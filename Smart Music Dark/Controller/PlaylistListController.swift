//
//  PlaylistListController.swift
//  8DWave
//
//  Created by Abraham Sameer on 12/2/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class PlaylistListController: UIViewController {
    
    let realm = try! Realm()
    static var sharedController = PlaylistListController()
    
    var songSM: SMSong?
    
    var songPlaylist: Results<SongPlaylist>!
    
    let tableView = UITableView()
    
    fileprivate let cellId = "cellId"
    var playlists: Results<Playlists>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playlists = self.realm.objects(Playlists.self).sorted(byKeyPath: "createdDate", ascending: true)
        // Do any additional setup after loading the view, typically from a nib.
        PlaylistListController.sharedController = self
        self.view.backgroundColor = UIColor.themeNavbarColor()
        setupView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.roundCorners([.topLeft, .topRight], radius: 25)
    }
    
    private func setupView(){
        view.addSubviews(views: tableView)
        view.addConstraints(withFormat: "V:|[v0]|", views: tableView)
        
        tableView.horizontal(toView: view)
        tableView.backgroundColor = UIColor.themeBaseColor()
        tableView.bounces = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: .zero)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onHandleClose))
        
        
    }
    func onHandleCreateNewPlaylist(title: String){
        let playlists = Playlists()
        playlists.title = title
        playlists.createdDate =  Calendar.current.startOfDay(for: Date())
        try! self.realm.write {
            self.realm.add(playlists)
        }
        self.tableView.reloadData()
    }
    
    @objc func onHandleShowFormCreate (){
        let alert = UIAlertController(title: "New Playlist", message: "Please input playlist name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            let playlists = Playlists()
            playlists.title = textField.text!
            playlists.createdDate =  Calendar.current.startOfDay(for: Date())
            try! self.realm.write {
                self.realm.add(playlists)
            }
            self.playlists = self.realm.objects(Playlists.self).sorted(byKeyPath: "createdDate", ascending: true)
            self.tableView.reloadData()
        }))
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
extension PlaylistListController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 55
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        cell.textLabel?.font = AppStateHelper.shared.defaultFontBold(size: 16)
        cell.textLabel?.textColor = UIColor.themeNavbarColor()
        cell.backgroundColor = UIColor.themeBaseColor()
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.selectionStyle = .none
        if indexPath.row == self.playlists.count{
            cell.textLabel?.text = "+ Create a New Playlist"
            cell.textLabel?.textAlignment = .center
        }else{
            DispatchQueue.main.async {
                cell.textLabel?.text = self.playlists[indexPath.row].title
            }
            cell.textLabel?.textAlignment = .left
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == self.playlists.count{
            onHandleShowFormCreate()
        }else{
            let realm = try! Realm()
            
            let existMusic = realm.object(ofType: SongPlaylist.self, forPrimaryKey:"\(songSM!.id!)")
            
            if existMusic != nil {
                DispatchQueue.main.async {
                    AppStateHelper.shared.onHandleAlertNotifiError(title: "\(self.songSM!.title!) already exists")
                }
            }else {
                
                let songModel = SongPlaylist()
                songModel.songID = "\(songSM!.id!)"
                songModel.id = songSM!.id!
                songModel.title = songSM!.title
                songModel.src = songSM!.url
                songModel.poster = songSM!.poster
                songModel.duration = songSM!.duration
                songModel.artistId = songSM!.artistId!
                songModel.name = songSM!.name
                songModel.playlist_id = playlists[indexPath.row].PID
                try! self.realm.write {
                    self.realm.add(songModel)
                }
                DispatchQueue.main.async {
                    AppStateHelper.shared.onHandleAlertNotifi(title: "Saving \(self.songSM!.title!) to \(self.playlists[indexPath.row].title)")
                }
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func onHandleClose(){
        dismiss(animated: true, completion: nil)
    }
}
