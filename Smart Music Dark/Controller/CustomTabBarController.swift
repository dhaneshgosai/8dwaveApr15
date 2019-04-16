//
//  CustomTabBarController.swift
//  8DWave
//
//  Created by Abraham Sameer on 11/30/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import UIKit
import CRNotifications
import MediaPlayer
import StreamingKit
import MarqueeLabel

var alermsg = "We apologise for a system error! Please try again later."


class CustomTabBarController: UITabBarController {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "page1")
        iv.clipsToBounds = true
        return iv
    }()

    var premiumController: UINavigationController?
    var showPrimary = false
    var songs: [SMSong] = []
    var indexPlaying: Int = 0
    // set up view
    let playerView = UIView()
    let artistProfile = UIImageView()
        
    let songTitle: MarqueeLabel = {
        let label = MarqueeLabel()
        label.textColor = UIColor.themeNavbarColor()
        label.tag = 101
        label.type = .continuous
        label.animationCurve = .easeInOut
        label.speed = .duration(8.0)
        label.textAlignment = .left
        label.font = AppStateHelper.shared.defaultFontRegular(size:14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let songDetails: MarqueeLabel = {
        let label = MarqueeLabel()
        label.textColor = UIColor.rgb(151, green: 190, blue: 232, alpha: 1)
        label.tag = 102
        label.type = .continuous
        label.animationCurve = .easeInOut
        label.speed = .duration(8.0)
        label.textAlignment = .left
        label.font = AppStateHelper.shared.defaultFontRegular(size:12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let CoverView: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    lazy var btnClose: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closePlayer), for: .touchUpInside)
        button.setImage(UIImage(named: "close_player"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var btnPlayOrPause: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.white, for: .focused)
        button.tintColor = .white
        button.addTarget(self, action: #selector(playerOrPause), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var indicatorView = UIActivityIndicatorView()
    lazy var progressView: CustomProgressTopUISlider = {
        let progress = CustomProgressTopUISlider()
        progress.minimumValue = 0
        progress.maximumValue = 100
        progress.isContinuous = true
        progress.addTarget(self,action: #selector(paybackSliderValueDidChange),for: .valueChanged)
        progress.isUserInteractionEnabled = true
        progress.setThumbImage(UIImage(named: "progress"), for: .highlighted)
        progress.setThumbImage(UIImage(named: "circle"), for: .normal)
        progress.minimumTrackTintColor = UIColor.themeMinimumTrackTintColor()
        progress.maximumTrackTintColor = UIColor.themeMaximumTrackTintColor()
        return progress
    }()
    
    fileprivate func setupViewPlayer() {
        view.addSubview(playerView)
        playerView.addSubview(CoverView)
        CoverView.addSubview(artistProfile)
        playerView.addSubview(songTitle)
        playerView.addSubview(songDetails)
        playerView.addSubview(btnClose)
        playerView.addSubview(btnPlayOrPause)
        playerView.addSubview(indicatorView)
        
        playerView.isHidden = true
        //playerView.addSubview(progressView)
        //progressView.translatesAutoresizingMaskIntoConstraints = false
        //progressView.leftAnchor.constraint(equalTo: self.playerView.leftAnchor).isActive = true
        //progressView.rightAnchor.constraint(equalTo: self.playerView.rightAnchor).isActive = true
        //progressView.topAnchor.constraint(equalTo: self.playerView.topAnchor).isActive = true
        playerView.backgroundColor = UIColor.themeNavbarColor()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.layer.shadowOpacity = 0.1
        playerView.layer.shadowOffset = CGSize.zero
        playerView.layer.shadowRadius = 1
        playerView.layer.cornerRadius = 20
        
        
        CoverView.leftAnchor.constraint(equalTo: self.playerView.leftAnchor, constant: 20).isActive = true
        CoverView.topAnchor.constraint(equalTo: self.playerView.topAnchor, constant: 11).isActive = true
        CoverView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        CoverView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        artistProfile.image = UIImage(named: "thumbnail")
        artistProfile.layer.cornerRadius = 5
        artistProfile.layer.masksToBounds = true
        artistProfile.translatesAutoresizingMaskIntoConstraints = false
        artistProfile.widthAnchor.constraint(equalToConstant: 50).isActive = true
        artistProfile.heightAnchor.constraint(equalToConstant: 50).isActive = true
        artistProfile.leftAnchor.constraint(equalTo: self.playerView.leftAnchor, constant: 20).isActive = true
        artistProfile.centerYAnchor.constraint(equalTo: self.playerView.centerYAnchor, constant: 0).isActive = true
        let tapOnImage = UITapGestureRecognizer(target: self, action: #selector(handlePlayer))
        tapOnImage.numberOfTapsRequired = 1
        playerView.isUserInteractionEnabled = true
        playerView.addGestureRecognizer(tapOnImage)
        
        //btnNext.setImage( UIImage.init(named: "next-forward")?.withRenderingMode(.alwaysTemplate), for: .normal)
        //btnNext.tintColor = UIColor.themeButtonsColor()
        btnPlayOrPause.setImage( UIImage.init(named: "play")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnPlayOrPause.tintColor = UIColor.themeButtonsColor()
        btnPlayOrPause.translatesAutoresizingMaskIntoConstraints = false
        btnPlayOrPause.centerYAnchor.constraint(equalTo: self.playerView.centerYAnchor).isActive = true
        btnPlayOrPause.rightAnchor.constraint(equalTo: self.playerView.rightAnchor, constant:-20).isActive = true
        btnPlayOrPause.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btnPlayOrPause.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        btnClose.translatesAutoresizingMaskIntoConstraints = false
        btnClose.centerYAnchor.constraint(equalTo: self.playerView.centerYAnchor).isActive = true
        btnClose.rightAnchor.constraint(equalTo: self.playerView.rightAnchor, constant: -55).isActive = true
        btnClose.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btnClose.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        songDetails.translatesAutoresizingMaskIntoConstraints = false
        songDetails.centerYAnchor.constraint(equalTo: self.playerView.centerYAnchor, constant: 10).isActive = true
        songDetails.leftAnchor.constraint(equalTo: self.artistProfile.rightAnchor, constant: 10).isActive = true
        songDetails.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 160).isActive = true
        
        songTitle.translatesAutoresizingMaskIntoConstraints = false
        songTitle.centerYAnchor.constraint(equalTo: self.playerView.centerYAnchor, constant: -10).isActive = true
        songTitle.leftAnchor.constraint(equalTo: self.artistProfile.rightAnchor, constant: 10).isActive = true
        songTitle.textColor = UIColor.white
        songTitle.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 160).isActive = true
        songTitle.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height >= 2436 || UIScreen.main.nativeBounds.height == 1792.0{
                playerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: (-82 - 10)).isActive = true
            }else{
                playerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: (-49 - 10)).isActive = true
            }
        } else if UIDevice().userInterfaceIdiom == .pad {
            playerView.safeAreaBottomAnchor.constraint(equalTo: self.view.safeAreaBottomAnchor, constant: -49).isActive = true
        }
        playerView.widthAnchor.constraint(equalToConstant: self.view.bounds.width - 15 * 2).isActive = true
        playerView.heightAnchor.constraint(equalToConstant:90).isActive = true
        playerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.color = UIColor.themeNavbarColor()
        indicatorView.centerYAnchor.constraint(equalTo: self.playerView.centerYAnchor).isActive = true
        indicatorView.centerXAnchor.constraint(equalTo: self.playerView.centerXAnchor).isActive = true
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        
        imageView.anchorToTop(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    fileprivate func setupViews() {
       
        let homeNavigationController = UINavigationController(rootViewController: HomeController())
        homeNavigationController.title = "Home"
        homeNavigationController.tabBarItem.image = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
        homeNavigationController.navigationBar.shadowImage = UIImage()
        homeNavigationController.view.backgroundColor = UIColor.themeNavbarColor()
        
        let searchController = UINavigationController(rootViewController: SearchController())
        searchController.title = "Search"
        searchController.tabBarItem.image = UIImage(named: "search")?.withRenderingMode(.alwaysTemplate)
        searchController.navigationBar.shadowImage = UIImage()
        
        let myPlaylistController = UINavigationController(rootViewController: MyPlaylistController())
        myPlaylistController.title = "Playlists"
        myPlaylistController.tabBarItem.image = UIImage(named: "playlist")?.withRenderingMode(.alwaysTemplate)
        myPlaylistController.navigationBar.shadowImage = UIImage()

        var controllers = [homeNavigationController, searchController, myPlaylistController]

        if Setting.isPremium {
            let myMusicController = UINavigationController(rootViewController: MyMusicController())
            myMusicController.title = "My Music"
            myMusicController.tabBarItem.image = UIImage(named: "mymusic")?.withRenderingMode(.alwaysTemplate)
            myMusicController.navigationBar.shadowImage = UIImage()
            myMusicController.view.backgroundColor = UIColor.themeNavbarColor()
            controllers.append(myMusicController)
        } else {
            premiumController = UINavigationController(rootViewController: PremiumController())
            premiumController!.title = "Premium"
            premiumController!.tabBarItem.image = UIImage(named: "diamond")?.withRenderingMode(.alwaysTemplate)
            premiumController!.navigationBar.shadowImage = UIImage()
            controllers.append(premiumController!)
        }


        let moreController = UINavigationController(rootViewController: MoreController())
        moreController.title = "More"
        moreController.tabBarItem.image = UIImage(named: "more")
        moreController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        moreController.navigationBar.shadowImage = UIImage()

        controllers.append(moreController)

        viewControllers = controllers
        
        tabBar.isTranslucent = false
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 2)
        topBorder.backgroundColor = UIColor.themeTopBorder().cgColor
        UITabBar.appearance().tintColor = UIColor.rgb(10, green: 34, blue: 67, alpha: 1)
        UITabBar.appearance().barTintColor = UIColor.themeTabarColor()
        UITabBar.appearance().unselectedItemTintColor = UIColor.themeButtonsColor()
        
        tabBar.layer.addSublayer(topBorder)
        tabBar.clipsToBounds = true
    }
    
    fileprivate func isOffline() -> Bool {
        return UserDefaults.standard.isOffline()
    }
    
    func switchTabBarOffline() {
        if isOffline() {
            viewControllers?.remove(at: 1)
            viewControllers?.remove(at: 0)
        }else {
            let myNavigationController = UINavigationController(rootViewController: MyMusicController())
            myNavigationController.title = "My Music"
            myNavigationController.tabBarItem.image = UIImage(named: "mymusic")
            viewControllers?.insert(myNavigationController, at: 3)
        
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        setupViews()
        setupViewPlayer()
        self.view.backgroundColor = .white
        MusicPlayer.sharedInstance.customTabBarController = self
        AppStateHelper.shared.customTabBarController = self

        NotificationCenter.default.addObserver(self, selector: #selector(didPurchaseSuccess), name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
    }

    @objc func didPurchaseSuccess() {
        Setting.isPremium = true
        guard let premiumController = premiumController, let index = viewControllers?.firstIndex(of: premiumController) else { return }

        viewControllers?.remove(at: index)


        let myMusicController = UINavigationController(rootViewController: MyMusicController())
        myMusicController.title = "My Music"
        myMusicController.tabBarItem.image = UIImage(named: "mymusic")
        viewControllers?.insert(myMusicController, at: index)
    }

    func onHandleAlertNotifi(title:String){
        CRNotifications.showNotification(type: CRNotifications.success, title:"8DWave", message: title, dismissDelay: 3)
    }
    func onHandleAlertNotifiError(title:String){
        CRNotifications.showNotification(type: CRNotifications.error, title:"8DWave", message: title, dismissDelay: 3)
    }

}

extension CustomTabBarController {
    
    func onHandleHideLaunch(){
        DispatchQueue.main.async {
            self.imageView.isHidden = true
        }
    }
    
    func handeSetUpPlayer(){
        playMusiceAt(indexPath: indexPlaying)
        MusicPlayer.sharedInstance.setupNowPlayingInfoCenter()
    }
    func playMusiceAt(indexPath:Int){
        MusicPlayer.sharedInstance.lastIndex = songs.count
        MusicPlayer.sharedInstance.queue = songs
        MusicPlayer.sharedInstance.changeTrack(atIndex: indexPath, completion: nil)
    }
    func updateViewWithSongData(snogIndex: Int) {
        DispatchQueue.main.async {
            self.progressView.value = 0
            self.songTitle.text = self.songs[snogIndex].title!
            self.songDetails.text = self.songs[snogIndex].name!
            self.artistProfile.sd_setImage(with: URL(string: self.songs[snogIndex].poster!)!, placeholderImage: UIImage(named: "thumbnail"))
            let color: UIColor = self.artistProfile.image!.getPixelColor(pos: CGPoint(x:2.0,y:3.0))
            self.CoverView.layer.shadowColor = color.cgColor
        }
    }
    @objc func playerOrPause(){
        if  MusicPlayer.sharedInstance.audioPlayer?.state == STKAudioPlayerState.playing {
            MusicPlayer.sharedInstance.audioPlayer?.pause()
            btnPlayOrPause.setImage( UIImage.init(named: "play")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }else if  MusicPlayer.sharedInstance.audioPlayer?.state == STKAudioPlayerState.paused {
            MusicPlayer.sharedInstance.audioPlayer?.resume()
            btnPlayOrPause.setImage( UIImage.init(named: "pause")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        PlayerController.playListSongController?.setupPlayButtonImage()
    }
    
    @objc func nextPlay(){
        MusicPlayer.sharedInstance.next(completion: self.handleCompletion())
    }
    
    @objc func closePlayer(){
        MusicPlayer.sharedInstance.stop()
        setUpHidePlayer()
        PlayerController.playListSongController?.setupPlayButtonImage()
    }
    
    func setUpHidePlayer(){
        if showPrimary == true{
            showPrimary = false
            playerView.slideInFromBottom()
            self.playerView.isHidden = true
        }
    }
    
    func setUpShowPlayer(){
        if showPrimary == false{
            showPrimary = true
            playerView.slideInFromTop()
            playerView.isHidden = false
        }
    }
    
    @objc func paybackSliderValueDidChange(sender: UISlider!){
        MusicPlayer.sharedInstance.seekToTime(sliderValue: Double(sender.value))
    }
    @objc func handlePlayer(){
        let playerController = PlayerController()
        playerController.songs = songs
        playerController.indexPlaying = indexPlaying
        playerController.onHandleChangeUIView(songIndex: indexPlaying)
        present(playerController, animated: true, completion: nil)
    }
    
    func handleCompletion() -> (_ error: NSError) -> Void {
        return { error in
            DispatchQueue.main.async {
                AppStateHelper.shared.onHandleAlertNotifiError(title: alermsg)
            }
        }
    }
    
    
    func onHandleShowAllPlaylist(song: SMSong){
        let playlistListController = PlaylistListController()
        playlistListController.navigationItem.title = "My Playlists"
        playlistListController.songSM = song
        let NavplaylistListController = UINavigationController(rootViewController: playlistListController)
        present(NavplaylistListController, animated: true, completion: nil)
    }
    
    
}

extension UserDefaults {
    
    enum UserDefaultsKeys: String {
        case isLoggedIn
        case isOffline
    }
    
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    // offline mode
    func setIsOffline(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isOffline.rawValue)
        synchronize()
    }
    
    func isOffline() -> Bool {
        return bool(forKey: UserDefaultsKeys.isOffline.rawValue)
    }
    
}
