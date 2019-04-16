//
//  ArtistSingleController.swift
//  Khmer Original Pro
//
//  Created by Abraham Sameer on 1/24/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation
import UIKit
import StreamingKit
import GoogleMobileAds


class ArtistSingleController: UITableViewController{
    
    static var sharedController = ArtistSingleController()
    
    fileprivate let cellId = "cellId"
    
    // is from songs
    var fromSong:  [SMSong] = []
    var isFromSong: Bool = false
    var artistId: Int = 0
    //  is from artist
    var artists: [SMArtists] = []
    var songs: [SMSong] = []
    
    var currentIndex: Int = 0
    var search = ""
    var next_page = 1
    var last_page = 0
    var limit: Int = 200
    var counts: Int = 0
    // endpoint
    var url: String = "artists"
    
    var subView = UIView()
    var isPlaying: Bool = false
    var isIndexPath: Int = 0
    
    lazy var shuffleButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.green
        button.addTarget(self, action: #selector(onHandleshuffle), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.setTitle("shuffle", for: .normal)
        return button
    }()
    let TracksLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = AppStateHelper.shared.defaultFontRegular(size: 18)
        return label
    }()
    private func setupViewAction(){
        
        shuffleButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        shuffleButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        shuffleButton.topAnchor.constraint(equalTo: subView.topAnchor, constant: 7).isActive = true
        shuffleButton.rightAnchor.constraint(equalTo: subView.rightAnchor, constant: -15).isActive = true
        
        shuffleButton.layer.cornerRadius = 3
        shuffleButton.clipsToBounds = true
        
        if MusicPlayer.sharedInstance.shuffle == true{
            shuffleButton.setTitle("Unshuffle", for: .normal)
        } else {
            shuffleButton.setTitle("shuffle", for: .normal)
        }
        
        TracksLabel.text = "Tracklist"
        TracksLabel.translatesAutoresizingMaskIntoConstraints = false
        TracksLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        TracksLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        TracksLabel.topAnchor.constraint(equalTo: subView.topAnchor, constant: 7).isActive = true
        TracksLabel.leftAnchor.constraint(equalTo: subView.leftAnchor, constant: 15).isActive = true
    }

    
    private func setupView(){
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.showsVerticalScrollIndicator = false
        tableView?.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        

        
    }
    var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    let ImageViewCover: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let NameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = AppStateHelper.shared.defaultFontRegular(size:18)
        return label
    }()
    
    let TotalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = AppStateHelper.shared.defaultFontRegular(size:15)
        return label
    }()
    
    var subViewProfile = UIView()
    
    private func setupViewProfile(){
        
        ImageViewCover.translatesAutoresizingMaskIntoConstraints = false
        ImageViewCover.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        ImageViewCover.heightAnchor.constraint(equalToConstant: 120).isActive = true
        ImageViewCover.leftAnchor.constraint(equalTo: subViewProfile.leftAnchor).isActive = true
        ImageViewCover.topAnchor.constraint(equalTo: subViewProfile.topAnchor).isActive = true
        
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        visualEffectView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        visualEffectView.leftAnchor.constraint(equalTo: subViewProfile.leftAnchor).isActive = true
        visualEffectView.topAnchor.constraint(equalTo: subViewProfile.topAnchor).isActive = true
        
        ImageView.translatesAutoresizingMaskIntoConstraints = false
        ImageView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        ImageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        ImageView.leftAnchor.constraint(equalTo: subViewProfile.leftAnchor, constant: 15).isActive = true
        ImageView.topAnchor.constraint(equalTo: subViewProfile.topAnchor, constant: 15).isActive = true
        
        NameLabel.translatesAutoresizingMaskIntoConstraints = false
        NameLabel.widthAnchor.constraint(equalToConstant: self.view.bounds.width - 130).isActive = true
        NameLabel.leftAnchor.constraint(equalTo: self.ImageView.leftAnchor, constant: 100).isActive = true
        NameLabel.topAnchor.constraint(equalTo: subViewProfile.topAnchor, constant: 15).isActive = true
        
        TotalLabel.translatesAutoresizingMaskIntoConstraints = false
        TotalLabel.widthAnchor.constraint(equalToConstant: 260).isActive  = true
        TotalLabel.leftAnchor.constraint(equalTo: self.ImageView.leftAnchor, constant: 100).isActive = true
        TotalLabel.bottomAnchor.constraint(equalTo: NameLabel.bottomAnchor, constant: 24).isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ArtistSingleController.sharedController = self
        self.view.backgroundColor =  UIColor.themeBaseColor()

        setupView()
        onHandleRequestData()
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onHandleRequestData(){
        DispatchQueue.main.async {
            AppStateHelper.shared.onHandleShowIndicator()
        }
        if isFromSong {
            artistId = fromSong[currentIndex].artistId!
        } else {
            artistId = artists[currentIndex].id!
        }
        SMService.onHandleGetSongById(url,artistId,{ (song) in
            DispatchQueue.main.async {
                self.tableView.separatorStyle = .singleLine
                self.songs = song
                self.counts = self.songs.count
                AppStateHelper.shared.onHandleHideIndicator()
                self.tableView.reloadData()
            }
        }, onError: {(errorString) in
            DispatchQueue.main.async {
                AppStateHelper.shared.onHandleAlertNotifiError(title: errorString)
            }
        })
    }
    
    
    @objc func onHandleCancel () {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onHandleshuffle(){
        if MusicPlayer.sharedInstance.shuffle  == true{
            DispatchQueue.main.async {
                self.shuffleButton.setTitle("shuffle", for: .normal)
            }
            MusicPlayer.sharedInstance.shuffle = false
        }else{
            DispatchQueue.main.async {
                self.shuffleButton.setTitle("Unshuffle", for: .normal)
            }
            MusicPlayer.sharedInstance.shuffle = true
        }
    }
   
}

extension ArtistSingleController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 0 {
            return 0
        } else {
            return 45
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 120
        } else {
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if isFromSong {
                DispatchQueue.main.async {
                    self.NameLabel.text = self.fromSong[self.currentIndex].name
                    self.ImageView.sd_setImage(with: URL(string: (self.fromSong[self.currentIndex].poster!))!, placeholderImage: UIImage(named: "thumbnail"))
                    self.ImageViewCover.sd_setImage(with: URL(string: (self.fromSong[self.currentIndex].poster!))!, placeholderImage: UIImage(named: "thumbnail"))
                }
            } else {
                DispatchQueue.main.async {
                    self.NameLabel.text = self.artists[self.currentIndex].title
                    self.ImageView.sd_setImage(with: URL(string: (self.artists[self.currentIndex].poster!))!, placeholderImage: UIImage(named: "thumbnail"))
                    self.ImageViewCover.sd_setImage(with: URL(string: (self.artists[self.currentIndex].poster!))!, placeholderImage: UIImage(named: "thumbnail"))
                }
            }
            TotalLabel.text = "\(songs.count) Songs"
            subViewProfile.addSubview(ImageViewCover)
            ImageViewCover.addSubview(visualEffectView)
            subViewProfile.addSubview(ImageView)
            subViewProfile.addSubview(NameLabel)
            subViewProfile.addSubview(TotalLabel)
            setupViewProfile()
            return subViewProfile
        } else {
            subView.backgroundColor = UIColor.themeHeaderColor()
            subView.addSubview(TracksLabel)
            subView.addSubview(shuffleButton)
            setupViewAction()
            return subView
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            PlayerController.sharedController.songs = songs
            PlayerController.sharedController.indexPlaying = indexPath.row
            (self.tabBarController as? CustomTabBarController)?.songs = songs
            (self.tabBarController as? CustomTabBarController)?.indexPlaying = indexPath.row
            (self.tabBarController as? CustomTabBarController)?.setUpShowPlayer()
            (self.tabBarController as? CustomTabBarController)?.handeSetUpPlayer()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 0
        } else {
            return songs.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        DispatchQueue.main.async {
            cell.textLabel?.text = "\(indexPath.row + 1)"+". "+" "+self.songs[indexPath.row].title!
        }
        cell.textLabel?.font = AppStateHelper.shared.defaultFontRegular(size: 16)
        cell.backgroundColor = UIColor.themeBaseColor()
        cell.textLabel?.textColor = UIColor.themeNavbarColor()
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.selectionStyle = .none
        return cell
    }
    
}





