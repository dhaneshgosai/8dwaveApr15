//
//  MyPlaylistController.swift
//  8DWave
//
//  Created by Abraham Sameer on 11/30/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class UICollageView: UIView{
    
    var imageViews = [UIImageView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.themeNavbarColor()
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        
        for i in 0..<4 {
            let imageView = UIImageView()
            let question = i % 2 != 0
            imageView.frame = CGRect(x: (question ? frame.size.width / 2.0 : CGFloat(0.0)), y: (i >= 2 ? frame.size.height / 2.0 : CGFloat(0.0)), width: frame.size.width / 2, height: frame.size.height / 2)
            self.imageViews.append(imageView)
            self.addSubview(imageView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup4Images(images: [UIImage]){
        guard images.count <= self.imageViews.count else {return}
        for (i,image) in images.enumerated(){
            self.imageViews[i].image = image
        }
    }
    
}
class MyPlaylistController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = try! Realm()
    static var sharedController = MyPlaylistController()
    fileprivate let cellId = "cellId"
    var playlists: Results<Playlists>!
    var songs : Results<SongPlaylist>!
    let tableView = UITableView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.playlists = self.realm.objects(Playlists.self).sorted(byKeyPath: "createdDate", ascending: true)
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playlists = self.realm.objects(Playlists.self).sorted(byKeyPath: "createdDate", ascending: true)
        // Do any additional setup after loading the view, typically from a nib.
        MyPlaylistController.sharedController = self
        self.view.backgroundColor = UIColor.themeNavbarColor()
        
        self.navigationItem.title = "Playlists"
        UIView.setupNavigationTitle(title: "Playlists", navigationItem: self.navigationItem)
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
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews(views: tableView)
        tableView.fill(toView: view, space: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), isActive: true)
        
        tableView.bounces = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
      
        let buttonColor = #colorLiteral(red: 0.3921568627, green: 0.631372549, blue: 0.8392156863, alpha: 1)
        
        let leftButtomItom = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onHandleShowFormCreate))
        leftButtomItom.tintColor = buttonColor
        self.navigationItem.leftBarButtonItem = leftButtomItom

        self.editButtonItem.tintColor = buttonColor
         self.navigationItem.rightBarButtonItem = self.editButtonItem
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
            self.tableView.reloadData()
        }))
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        DispatchQueue.main.async {
            cell.textLabel?.text = self.playlists[indexPath.row].title
            cell.textLabel?.textColor = UIColor.themeNavbarColor()
            cell.textLabel?.font = AppStateHelper.shared.defaultFontBold(size: 12)
            cell.backgroundColor = UIColor.themeBaseColor()
            let songs = self.realm.objects(SongPlaylist.self).filter("playlist_id == %@",self.playlists[indexPath.row].PID)
            self.setupCollageView(cell: cell, songs: self.random4Songs(songs: Array(songs)))
            self.setupBottomLine(cell: cell)
            self.setupCounterView(cell: cell, count: songs.count)
        }
        cell.separatorInset = UIEdgeInsets(space: 70)
        cell.layoutMargins = .zero
        cell.selectionStyle = .none
        return cell
    }
    
    private func random4Songs(songs: [SongPlaylist]) -> [SongPlaylist]{
        let count = songs.count < 4 ? songs.count : 4
        var random4Songs = [SongPlaylist]()
        while random4Songs.count < count {
            let randomIndex = Int(arc4random_uniform(UInt32(songs.count)))
            if !random4Songs.contains(songs[randomIndex]){
                random4Songs.append(songs[randomIndex])
            }
        }
        return random4Songs
    }
    
    private func setupCollageView(cell: UITableViewCell, songs: [SongPlaylist]){
        if cell.viewWithTag(10) == nil {
            let collageView = UICollageView(frame: CGRect(x: 10, y: 4, width: 50, height: 50))
            collageView.tag = 10
            cell.addSubview(collageView)
        }
        if let collageView = cell.viewWithTag(10) as? UICollageView{
            SMService.getImages(from: songs.map{URL(string: $0.poster!)!}) { (images, error) in
                if error == nil, let images = images{
                    collageView.setup4Images(images: images)
                }
            }
        }
    }
    
    private func setupBottomLine(cell: UITableViewCell){
        if cell.viewWithTag(11) == nil {
            let line = UIView(frame: CGRect(x: 0, y: 57, width:UIScreen.main.bounds.size.width, height: 1))
            line.tag = 11
            line.backgroundColor = .rgba(243,244,245,1)
            cell.addSubview(line)
        }
    }
    
    private func setupCounterView(cell: UITableViewCell, count: Int){
        if cell.viewWithTag(12) == nil {
            let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width - 100, y: 19, width:80, height: 20))
            label.tag = 12
            label.textColor = .rgba(107, 169, 224, 1)
            label.textAlignment = .right
            label.font = AppStateHelper.shared.defaultFontBold(size: 12)
            cell.addSubview(label)
        }
        
        if let label = cell.viewWithTag(12) as? UILabel{
            label.text = "\(count) songs"
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 58
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlistSongController = PlaylistSongController()
        playlistSongController.playlists = playlists
        playlistSongController.currentIndex = indexPath.row
        playlistSongController.title = playlists[indexPath.row].title
        navigationController?.pushViewController(playlistSongController, animated: true)
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            self.onHandleShowFormEdit(currentIndex: indexPath.row)
        }
        editAction.backgroundColor = .gray
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            let playlistObject = self.realm.objects(Playlists.self).filter("PID == %@",self.playlists[indexPath.row].PID)

            self.songs = self.realm.objects(SongPlaylist.self).filter("playlist_id == %@",self.playlists[indexPath.row].PID)

            if playlistObject.count > 0 {
                try! self.realm.write {
                    self.realm.delete(playlistObject)
                    self.realm.delete(self.songs)
                }
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: .left)
                }
            }
        }
        deleteAction.backgroundColor = .red
        return [editAction,deleteAction]
    }
    @objc func onHandleShowFormEdit(currentIndex: Int){
        let alert = UIAlertController(title: "Edit Playlist", message: "Please input playlist name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.playlists[currentIndex].title
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            self.onHandleEditPlaylistName(title: "\(textField.text!)", currentIndex: currentIndex)
        }))
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onHandleEditPlaylistName(title: String, currentIndex: Int){
        let playlist = Playlists()
        playlist.title = title
        playlist.PID = playlists[currentIndex].PID
        try! realm.write {
            realm.add(playlist, update: true)
        }
        self.tableView.reloadData()
    }
    
    func editCommand() {
        DispatchQueue.main.async {
            self.tableView.setEditing(!self.isEditing, animated: true)
        }
    }
    func doneCommand() {
        DispatchQueue.main.async {
            self.tableView.setEditing(self.isEditing, animated: true)
        }
    }
    
}
