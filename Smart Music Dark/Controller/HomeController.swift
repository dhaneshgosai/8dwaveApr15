//
//  HomeController.swift
//  8DWave
//
//  Created by Abraham Sameer on 11/30/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

let kShowAdsAfterDelaySec = 10
let kAppTestInterFullScreenAdId = "ca-app-pub-3940256099942544/4411468910"
let kAppInterFullScreenAdId = "ca-app-pub-4228875950631290/5725119459"


class HomeController: UITableViewController {
    
    static var sharedController = HomeController()

    var interstitial: GADInterstitial!
    
    var data = ["Popular Artists", "Popular Music", "Newest Music", "Newest Artists", "Favorites"]
    var search = ""
    var next_page = 1
    var last_page = 0
    var limit: Int = 25
    var songs: [SMSong] = []
    
    var newSongs: [SMSong] = []
    var artists: [SMArtists] = []
    var popluaArtist: [SMArtists] = []
    let realm = try! Realm()
    
    static let insetsTop:CGFloat = 40

    var favoriteSong: [SMSong] = []
    var favorites : Results<SongFavorite>!

    fileprivate let cellFavoriteId = "cellFavoriteId"
    fileprivate let cellPopularMusicId = "cellPopularMusicId"
    fileprivate let cellNewestMusicId = "cellNewestMusicId"
    fileprivate let cellPopularArtistsId = "cellPopularArtistsId"
    fileprivate let cellNewestArtistsId = "cellNewestArtistsId"

    fileprivate var FavoriteCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top:15, left: 15, bottom: 10, right: 15)
        layout.itemSize = CGSize(width: 100, height: 120)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = true
        cv.collectionViewLayout.invalidateLayout()
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    fileprivate var PopularMusicCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        layout.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 70)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = false
        cv.collectionViewLayout.invalidateLayout()
        cv.showsVerticalScrollIndicator = false
        
        return cv
    }()
    
    fileprivate var NewestMusicCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top:10, left: 20, bottom: 10, right: 20)
        layout.itemSize = CGSize(width: 120, height: 120)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = true
        cv.collectionViewLayout.invalidateLayout()
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    fileprivate var PopularArtistCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        layout.sectionInset = UIEdgeInsets(top:15, left: 15, bottom: 10, right: 15)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 70)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = false
        cv.collectionViewLayout.invalidateLayout()
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    fileprivate var NewestArtistsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top:10, left: 20, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: 275, height: 150)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = true
        cv.collectionViewLayout.invalidateLayout()
        cv.showsHorizontalScrollIndicator = false
        cv.clipsToBounds = false
        return cv
    }()
    
    fileprivate let headphonesView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.height(140 + HomeController.insetsTop).isActive = true
        view.width(UIScreen.main.bounds.width).isActive = true
        
        let button = UIButton()
        
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.height(40).isActive = true
        button.width(40).isActive = true
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: HomeController.insetsTop + 20).isActive = true
        button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        button.setImage(UIImage(named: "home_create_music"), for: .normal)
        button.addTarget(self, action: #selector(leftButtonTapped), for: .touchDown)
        
        let label = UILabel()
        label.textColor = UIColor.themeNavbarColor()
        label.numberOfLines = 2
        label.text = "Welcome \rTO 8D AUDIO"
        label.font = AppStateHelper.shared.defaultFontRegular(size:27)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        
        
        let imageView = UIImageView(image: UIImage(named: "headphones"))
        imageView.contentMode = .bottom
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20).isActive = true
        
        return view
    }()
    
    private func setupView(){
        
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellFavoriteId)
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellPopularMusicId)
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellNewestMusicId)
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellPopularArtistsId)
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellNewestArtistsId)
        
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.showsVerticalScrollIndicator = false
        tableView?.separatorStyle = .none
        tableView.tableHeaderView = headphonesView
        
        tableView.contentInset = UIEdgeInsets(top: -HomeController.insetsTop, left: 0, bottom: 0, right: 0)
  
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIView.setupNavigationTitle(title: "8DWave", navigationItem: self.navigationItem)
        self.navigationItem.title = ""
        self.addLeftButton()
        self.view.backgroundColor = UIColor.themeBaseColor()
        HomeController.sharedController = self
        setupView()
        onHandleGetData()
        
        if !Setting.isPremium {
        
        //Add Observer for Become Active Notifier
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
            object: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        retrieveDataFromDB()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        favoriteSong = []
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
       // self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func applicationDidBecomeActive() {
        // handle show ads event
        let current_active_count = UserDefaults.standard.integer(forKey: "kAppOpenCount")
        if  current_active_count == 2 {
            self.interstitial = GADInterstitial(adUnitID: kAppTestInterFullScreenAdId) //Replace Actual ID while publish this app kAppInterFullScreenAdId
            self.interstitial.delegate = self
            let request = GADRequest()
            request.testDevices = [ kGADSimulatorID ];
            self.interstitial.load(request)
            //Show Ads after 10 dealy
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(kShowAdsAfterDelaySec)) {
                
                if self.interstitial.isReady {
                    let appdelegate = UIApplication.shared.delegate as? AppDelegate
                    if let rootVC = appdelegate?.window?.rootViewController {
                        self.interstitial.present(fromRootViewController: rootVC)
                    }
                    
                } else {
                    print("Ad wasn't ready")
                }
            }
        }
    }
    
    fileprivate func addLeftButton(){
        let image = UIImage(named: "home_create_music")!.withRenderingMode(.alwaysOriginal)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(leftButtonTapped))
        self.navigationItem.leftBarButtonItem = button
    }
    
    @objc fileprivate func leftButtonTapped(){
        self.navigationController?.pushViewController(CreateMusicController(), animated: true)
    }
    
    fileprivate func retrieveDataFromDB(){
        self.favorites = self.realm.objects(SongFavorite.self)
        for object in favorites.reversed() {
            let dictionary = object.toDictionary() as NSDictionary
            let song = SMSong.init(withDictionary: dictionary)
            favoriteSong.append(song)
        }
        DispatchQueue.main.async {
            if self.favoriteSong.count > 0 {
                self.FavoriteCollectionView.reloadData()
                self.tableView.reloadData()
            }
        }
    }
    
    func onHandleAddToFavorite(song: SMSong) {
        let realm = try! Realm()
        let existMusic = realm.object(ofType: SongFavorite.self, forPrimaryKey:"\(song.id!)")
        
        if existMusic != nil {
            DispatchQueue.main.async {
                AppStateHelper.shared.onHandleAlertNotifiError(title: "Song already exists")
            }
        }else {
                let songFavorite = SongFavorite()
                songFavorite.songID = "\(song.id!)"
                songFavorite.id = song.id!
                songFavorite.title = song.title!
                songFavorite.src = song.url!
                songFavorite.poster = song.poster!
                songFavorite.duration = song.duration!
                songFavorite.artistId = song.artistId!
                songFavorite.name = song.name!
                try! self.realm.write {
                    self.realm.add(songFavorite)
                }
                DispatchQueue.main.async {
                    self.FavoriteCollectionView.reloadData()
                    AppStateHelper.shared.onHandleAlertNotifi(title: "Saving \(song.title!) to Favorite")
                }
        }
    }
    
    
    
}

extension HomeController {
    
    func onHandleGetData(){
        DispatchQueue.main.async {
            AppStateHelper.shared.onHandleShowIndicator()
        }
        SMService.onHandleGetArtist("artists",next_page,search,{ (artists) in
            DispatchQueue.main.async {
                self.popluaArtist = artists
                self.PopularArtistCollectionView.reloadData()
//                self.artists = artists
//                self.NewestArtistsCollectionView.reloadData()
                 UserDefaults.standard.setIsOffline(value: false)
            }
            
        }, onError: {(errorString) in
            DispatchQueue.main.async {
                 UserDefaults.standard.setIsOffline(value: true)
                AppStateHelper.shared.onHandleHideIndicator()
                (self.tabBarController as? CustomTabBarController)?.onHandleHideLaunch()
                (self.tabBarController as? CustomTabBarController)?.switchTabBarOffline()
            }
        })

        SMService.onHandleGetSong("popular-songs",next_page,search,{ (songs) in
            DispatchQueue.main.async {
                self.songs = songs
                self.PopularMusicCollectionView.reloadData()
                self.tableView.reloadSections([1], with: .automatic)
            }

        }, onError: {(errorString) in
            DispatchQueue.main.async {
                AppStateHelper.shared.onHandleHideIndicator()
            }
        })

        SMService.onHandleGetSong("songs",next_page,search,{ (songs) in
            DispatchQueue.main.async {
                self.newSongs = songs
                self.NewestMusicCollectionView.reloadData()
            }

        }, onError: {(errorString) in
            DispatchQueue.main.async {
                AppStateHelper.shared.onHandleHideIndicator()

            }
        })

        SMService.onHandleGetArtist("popular-artists",next_page,search,{ (artists) in
            DispatchQueue.main.async {
//                self.popluaArtist = artists
//                self.PopularArtistCollectionView.reloadData()
                self.artists = artists
                self.NewestArtistsCollectionView.reloadData()
                (self.tabBarController as? CustomTabBarController)?.onHandleHideLaunch()
                AppStateHelper.shared.onHandleHideIndicator()

            }
        }, onError: {(errorString) in
            DispatchQueue.main.async {
                AppStateHelper.shared.onHandleHideIndicator()
            }
        })
    }
}

extension HomeController{
    
    @objc func onHandleSeeMore(sender: UIButton!) {
        if sender.tag == 0 {
            let artistController = ArtistController()
            artistController.title = "Popular Artists"
            artistController.artists = artists
            artistController.url = "popular-artists"
            navigationController?.pushViewController(artistController, animated: true)
        } else if sender.tag == 1 {
            let songController = SongController()
            songController.title = "Popular Music"
            songController.url = "popular-songs"
            songController.songs = newSongs
            navigationController?.pushViewController(songController, animated: true)
        } else if sender.tag == 3 {
            let artistController = ArtistController()
            artistController.title = "Newest Artists"
            artistController.url = "artists"
            artistController.artists = popluaArtist
            navigationController?.pushViewController(artistController, animated: true)
        } else if sender.tag ==  2 {
            let songController = SongController()
            songController.title = "Newest Music"
            songController.url = "songs"
            songController.songs = songs
            navigationController?.pushViewController(songController, animated: true)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let subView = UIView()
        let label = UILabel()
        subView.backgroundColor = UIColor.white
        label.text = data[section]
        label.font = AppStateHelper.shared.defaultFontBold(size:18)
        subView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.leftAnchor.constraint(equalTo: subView.leftAnchor,constant: 20).isActive = true
        label.centerYAnchor.constraint(equalTo: subView.centerYAnchor).isActive = true
        label.textColor = .rgba(10, 34, 67, 1)
        if section != 4 {
            let button = UIButton()
            button.setTitleColor(.rgba(117, 176, 229, 1), for: UIControl.State())
            button.titleLabel?.font = AppStateHelper.shared.defaultFontRegular(size:15)
            button.setTitle("More >", for: .normal)
            button.alpha = 1.0
            button.tag = section
            button.addTarget(self, action: #selector(onHandleSeeMore), for: .touchUpInside)
            subView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 70).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.rightAnchor.constraint(equalTo: subView.rightAnchor, constant: -20 ).isActive = true
            button.centerYAnchor.constraint(equalTo: subView.centerYAnchor).isActive = true
        }
    
        return subView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 4 {
            if favoriteSong.count > 0 {
                return 40
            }else {
                return 0
            }
        }else {
            return 40
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
       
        if indexPath.section == 0 {
            return 170
        } else if indexPath.section == 2 {
            return CGFloat(70 * songs.count)
        } else if indexPath.section == 1{
            return 140
        }else if indexPath.section == 3{
            return 340
        }else {
            if favoriteSong.count > 0 {
                return 140
            }else {
                return 0
            }
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellNewestArtistsId, for: indexPath)
            if !cell.subviews.contains(NewestMusicCollectionView){
                cell.addSubview(NewestArtistsCollectionView)
                NewestArtistsCollectionView.dataSource = self
                NewestArtistsCollectionView.delegate = self
                NewestArtistsCollectionView.register(NewestArtistsCell.self, forCellWithReuseIdentifier: "cellNewestArtistsId")
                NewestArtistsCollectionView.translatesAutoresizingMaskIntoConstraints = false
                NewestArtistsCollectionView.backgroundColor = UIColor.themeBaseColor()
                NewestArtistsCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
                NewestArtistsCollectionView.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive =  true
                NewestArtistsCollectionView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
                NewestArtistsCollectionView.heightAnchor.constraint(equalToConstant: 170).isActive = true
            }
            return cell
            
        } else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellPopularMusicId, for: indexPath)
            if !cell.subviews.contains(PopularMusicCollectionView){
                cell.addSubview(PopularMusicCollectionView)
                PopularMusicCollectionView.dataSource = self
                PopularMusicCollectionView.delegate = self
                PopularMusicCollectionView.register(PopularMusicCell.self, forCellWithReuseIdentifier: "cellPopularMusicId")
                PopularMusicCollectionView.translatesAutoresizingMaskIntoConstraints = false
                PopularMusicCollectionView.backgroundColor = UIColor.themeBaseColor()
                PopularMusicCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
                PopularMusicCollectionView.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive =  true
                PopularMusicCollectionView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
                PopularMusicCollectionView.heightAnchor.constraint(equalTo: cell.heightAnchor).isActive = true
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                cell.selectionStyle = .none
            }
            
            return cell
            
        } else if  indexPath.section == 1 {

            let cell = tableView.dequeueReusableCell(withIdentifier: cellNewestMusicId, for: indexPath)
            NewestMusicCollectionView.dataSource = self
            NewestMusicCollectionView.delegate = self
            NewestMusicCollectionView.register(NewestMusicCell.self, forCellWithReuseIdentifier: "cellNewestMusicId")
            NewestMusicCollectionView.translatesAutoresizingMaskIntoConstraints = false
            NewestMusicCollectionView.backgroundColor = UIColor.themeBaseColor()
            cell.addSubview(NewestMusicCollectionView)
            NewestMusicCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
            NewestMusicCollectionView.heightAnchor.constraint(equalToConstant: 140).isActive = true
            NewestMusicCollectionView.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive =  true
            NewestMusicCollectionView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            cell.selectionStyle = .none
            return cell
        } else if  indexPath.section == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellPopularArtistsId, for: indexPath)
            PopularArtistCollectionView.dataSource = self
            PopularArtistCollectionView.delegate = self
            PopularArtistCollectionView.register(PopularArtistCell.self, forCellWithReuseIdentifier: "cellPopularArtistsId")
            PopularArtistCollectionView.translatesAutoresizingMaskIntoConstraints = false
            PopularArtistCollectionView.backgroundColor = UIColor.themeBaseColor()
            cell.addSubview(PopularArtistCollectionView)
            PopularArtistCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
            PopularArtistCollectionView.heightAnchor.constraint(equalToConstant: 340).isActive = true
            PopularArtistCollectionView.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive =  true
            PopularArtistCollectionView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellFavoriteId, for: indexPath)
            FavoriteCollectionView.dataSource = self
            FavoriteCollectionView.delegate = self
            FavoriteCollectionView.register(FavoriteCell.self, forCellWithReuseIdentifier: "cellFavoriteId")
            FavoriteCollectionView.translatesAutoresizingMaskIntoConstraints = false
            FavoriteCollectionView.backgroundColor = UIColor.themeBaseColor()
            cell.addSubview(FavoriteCollectionView)
            FavoriteCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
            FavoriteCollectionView.heightAnchor.constraint(equalToConstant: 140).isActive = true
            FavoriteCollectionView.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive =  true
            FavoriteCollectionView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
}

extension HomeController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == NewestArtistsCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellNewestArtistsId", for: indexPath) as! NewestArtistsCell
            DispatchQueue.main.async {
                cell.artist = self.artists[indexPath.row]
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            }
            return cell
        }else if collectionView == PopularMusicCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPopularMusicId", for: indexPath) as! PopularMusicCell
            DispatchQueue.main.async {
                cell.song = self.songs[indexPath.row]
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            }
            return cell
        }
        else if collectionView == NewestMusicCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellNewestMusicId", for: indexPath) as! NewestMusicCell
            DispatchQueue.main.async {
                cell.song = self.newSongs[indexPath.row]
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            }
            return cell
        } else if collectionView == PopularArtistCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPopularArtistsId", for: indexPath) as! PopularArtistCell
            DispatchQueue.main.async {
                cell.artist = self.popluaArtist[indexPath.row]

                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellFavoriteId", for: indexPath) as! FavoriteCell
            DispatchQueue.main.async {
                cell.song = self.favoriteSong[indexPath.row]
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            }
            return cell

        }
    }
        
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        if collectionView == PopularMusicCollectionView{
            
            PlayerController.sharedController.songs = self.songs
            PlayerController.sharedController.indexPlaying = indexPath.row
            (self.tabBarController as? CustomTabBarController)?.songs = self.songs
            (self.tabBarController as? CustomTabBarController)?.indexPlaying = indexPath.row
            (self.tabBarController as? CustomTabBarController)?.setUpShowPlayer()
            (self.tabBarController as? CustomTabBarController)?.handeSetUpPlayer()
        
       } else if collectionView == NewestMusicCollectionView {
            
            PlayerController.sharedController.songs = self.newSongs
            PlayerController.sharedController.indexPlaying = indexPath.row
            (self.tabBarController as? CustomTabBarController)?.songs = self.newSongs
            (self.tabBarController as? CustomTabBarController)?.indexPlaying = indexPath.row
            (self.tabBarController as? CustomTabBarController)?.setUpShowPlayer()
            (self.tabBarController as? CustomTabBarController)?.handeSetUpPlayer()
            
        } else if collectionView == FavoriteCollectionView {
            PlayerController.sharedController.songs = self.favoriteSong
            PlayerController.sharedController.indexPlaying = indexPath.row
            (self.tabBarController as? CustomTabBarController)?.songs = self.favoriteSong
            (self.tabBarController as? CustomTabBarController)?.indexPlaying = indexPath.row
            (self.tabBarController as? CustomTabBarController)?.setUpShowPlayer()
            (self.tabBarController as? CustomTabBarController)?.handeSetUpPlayer()
            
        }else if collectionView  == NewestArtistsCollectionView{
            
            let artistSingleController = ArtistSingleController()
            artistSingleController.artists = artists
            artistSingleController.currentIndex = indexPath.row
            artistSingleController.title = artists[indexPath.row].title
            navigationController?.pushViewController(artistSingleController, animated: true)
            
        } else if collectionView  == PopularArtistCollectionView{
            
            let artistSingleController = ArtistSingleController()
            artistSingleController.artists = popluaArtist
            artistSingleController.currentIndex = indexPath.row
            artistSingleController.title = artists[indexPath.row].title
            navigationController?.pushViewController(artistSingleController, animated: true)
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == NewestArtistsCollectionView {
            return artists.count
        }else if collectionView == PopularMusicCollectionView {
            return songs.count
        }else if collectionView == NewestMusicCollectionView {
            return newSongs.count
        } else if  collectionView == PopularArtistCollectionView {
            return popluaArtist.count
        } else {
            return favoriteSong.count
        }
    }
    
  
}

extension HomeController : GADInterstitialDelegate{
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}
