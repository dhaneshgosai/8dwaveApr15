//
//  PlaylistSongController.swift
//  Khmer Music
//
//  Created by Abraham Sameer on 11/2/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import StreamingKit
import MarqueeLabel

class PlaylistSongController: UIViewController {
    
    static var sharedController = PlaylistSongController()
    
    let playImage = UIImage(named: "play_with_shadows")
    let pauseImage = UIImage(named: "pause_with_shadows")
    
    fileprivate let cellId = "cellId"
    let realm = try! Realm()
    let tableView = UITableView()
    var songs : Results<SongPlaylist>! {
        didSet{
            if let poster = self.songs.randomElement()?.poster{
                imageView.sd_setImage(with: URL(string: poster)!, placeholderImage: UIImage(named: "thumbnail"))
            }
        }
    }
    var songSM: [SMSong] = []
    var playlists: Results<Playlists>!
    var currentIndex: Int = 0
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var headerView: UIView = {
        let view = UIImageView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.height(60).isActive = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 10).isActive = true
        label.font = AppStateHelper.shared.defaultFontBold(size: 27)
        label.textColor = UIColor.themeNavbarColor()
        
        label.text = self.title
        self.title = nil
        
        return view
    }()
    
    lazy var playButton: UIButton = {
        let playButton = UIButton()
        playButton.setImage(playImage, for: .normal)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(playTapped), for: .touchDown)
        return playButton
    }()
    
    private func setupView(){
        view.addSubview(imageView)
        imageView.fill(toView: view, space: UIEdgeInsets(top: 0, left: 0, bottom: self.view.frame.height *  (1 - 0.366), right: 0))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SongPlaylistCell.self, forCellReuseIdentifier: cellId)
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.themeBaseColor()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bounces = false
        view.addSubviews(views: tableView)
        tableView.fill(toView: view, space: UIEdgeInsets(top: self.view.frame.height * 0.366, left: 0, bottom: 0, right: 0), isActive: true)
        
        view.addSubview(playButton)
        playButton.height(80)
        playButton.width(80)
        playButton.top(toView: tableView, space: -40, isActive: true)
        playButton.centerX(toView: tableView, space: view.frame.width / 4)
    }
    
    fileprivate func retrieveDataFromDB(){
        self.songs = self.realm.objects(SongPlaylist.self).filter("playlist_id == %@",playlists[currentIndex].PID)
        
        for object in songs.reversed() {
            let dictionary = object.toDictionary() as NSDictionary
            let song = SMSong.init(withDictionary: dictionary)
            songSM.append(song)
        }
        DispatchQueue.main.async {
            if self.songSM.count > 0 {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.roundCorners([.topLeft, .topRight], radius: 25)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.themeNavbarColor()

        PlaylistSongController.sharedController = self
        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PlayerController.playListSongController = self
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        retrieveDataFromDB()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isTranslucent = false
        songSM = []
        DispatchQueue.main.async {
            self.tableView.setEditing(self.isEditing, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func playTapped(){
        let paused = self.playButton.image(for: .normal) == playImage
        if songSM.count > 0 && paused{
            self.playWithIndexPath(index: 0)
        }else if !paused{
            MusicPlayer.sharedInstance.audioPlayer?.pause()
            self.playButton.setImage(playImage, for: .normal)
        }
    }
    
    func setupPlayButtonImage(){
        self.playButton.setImage(MusicPlayer.sharedInstance.audioPlayer?.state == STKAudioPlayerState.playing ? pauseImage : playImage, for: .normal)
    }
    
    func playWithIndexPath(index: Int){
        PlayerController.sharedController.songs = songSM
        PlayerController.sharedController.indexPlaying = index
        
        (self.tabBarController as? CustomTabBarController)?.songs = songSM
        (self.tabBarController as? CustomTabBarController)?.indexPlaying = index
        (self.tabBarController as? CustomTabBarController)?.setUpShowPlayer()
        (self.tabBarController as? CustomTabBarController)?.handeSetUpPlayer()
        MusicPlayer.sharedInstance.audioPlayer?.resume()
        self.playButton.setImage(pauseImage, for: .normal)
    }
}

extension PlaylistSongController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.playWithIndexPath(index: indexPath.row)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songSM.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let songObject = realm.objects(SongPlaylist.self).filter("id == %@",songSM[indexPath.row].id!)
            if songObject.count > 0 {
                do {
                    try! self.realm.write {
                        self.realm.delete(songObject)
                    }
                    DispatchQueue.main.async {
                        self.songSM.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .left)
                    }
                    print("Delete file successfully....")
                } catch {
                    print("Could not clear temp folder:")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SongPlaylistCell
        DispatchQueue.main.async {
            cell.song = self.songSM[indexPath.row]
        }
        cell.backgroundColor = UIColor.themeBaseColor()
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 70
    }

    
}

