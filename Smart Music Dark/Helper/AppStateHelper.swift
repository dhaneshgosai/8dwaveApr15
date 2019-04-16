//
//  AppStateHelper.swift
//  8DWave
//
//  Created by Abraham Sameer on 11/30/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import RealmSwift

class AppStateHelper: UIViewController, NVActivityIndicatorViewable {
    
    static let shared = AppStateHelper()
    var alertController = UIAlertController()
    var customTabBarController: CustomTabBarController?
    let realm = try! Realm()
    
    var documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/smart-music-dark/"
    
    
    func defaultFontAwesome(size: CGFloat) -> UIFont {
        return UIFont(name: "FontAwesome", size: size)!
    }
    
    func defaultFontBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Ubuntu-Bold", size: size)!
    }
    
    func defaultFontRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "Ubuntu-Regular", size: size)!
    }
    
    func onHandleHideIndicator(){
        DispatchQueue.main.async {
            self.stopAnimating(nil)
        }
    }
    func onHandleShowIndicator(){
        let size = CGSize(width: 30, height: 30)
        startAnimating(size, message: "Loading...", type: NVActivityIndicatorType.lineSpinFadeLoader, fadeInAnimation: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            NVActivityIndicatorPresenter.sharedInstance.setMessage("Preparing...")
        }
    }
    func onHandleAlertNotifi(title:String){
        customTabBarController?.onHandleAlertNotifi(title: title)
    }
    func onHandleAlertNotifiError(title:String){
        customTabBarController?.onHandleAlertNotifiError(title: title)
    }
    
    func onHandleSongMore(song: SMSong, button: UIButton){
        
        let actionSheetController: UIAlertController = UIAlertController(title: "\n\n\n", message: nil, preferredStyle: .actionSheet)
        actionSheetController.view.tintColor = UIColor.themeNavbarColor()
        
        let imageArtist = UIImageView()
        let titleLable = UILabel()
        let nameLable = UILabel()
        let margin:CGFloat = 10.0
        let rect = CGRect(x: margin, y: margin, width: actionSheetController.view.bounds.size.width - margin * 0.0, height: 0)
        let customView = UIView(frame: rect)
        actionSheetController.view.addSubview(customView)
        customView.addSubview(imageArtist)
        customView.addSubview(titleLable)
        customView.addSubview(nameLable)
        imageArtist.leftAnchor.constraint(equalTo: customView.leftAnchor).isActive = true
        imageArtist.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        imageArtist.translatesAutoresizingMaskIntoConstraints = false
        imageArtist.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageArtist.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageArtist.layer.cornerRadius = 3.0
        imageArtist.clipsToBounds = true
        titleLable.heightAnchor.constraint(equalToConstant: 30).isActive = true
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        titleLable.leftAnchor.constraint(equalTo: imageArtist.leftAnchor, constant: 70).isActive = true
        titleLable.rightAnchor.constraint(equalTo: customView.rightAnchor, constant: -40).isActive = true
        
        titleLable.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        titleLable.textColor = UIColor.themeNavbarColor()
        titleLable.font = AppStateHelper.shared.defaultFontRegular(size: 16)
        
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        nameLable.textColor = UIColor.themeButtonsColor()
        nameLable.font = AppStateHelper.shared.defaultFontRegular(size: 15)
        nameLable.bottomAnchor.constraint(equalTo: titleLable.bottomAnchor, constant: 23).isActive = true
        nameLable.leftAnchor.constraint(equalTo: imageArtist.leftAnchor, constant: 70).isActive = true
        nameLable.widthAnchor.constraint(equalToConstant: actionSheetController.view.bounds.size.width - 70).isActive = true
        nameLable.heightAnchor.constraint(equalToConstant: 25).isActive = true
        DispatchQueue.main.async {
            nameLable.text = song.name
            titleLable.text = song.title
            imageArtist.sd_setImage(with: URL(string: song.poster!)!, placeholderImage: UIImage(named: "thumbnail"))
        }
        
        let downloadAction: UIAlertAction = UIAlertAction(title: "Download", style: .default) { action -> Void in
            if Setting.isPremium {
                self.addDownload(song: song)
            } else {
                self.showPremiumAlert()
            }
        }
        
        let favoriteAction: UIAlertAction = UIAlertAction(title: "Favorites", style: .default) { action -> Void in
            self.onHandleAddToFavorite(song: song)
            
        }
        
        let playlistAction: UIAlertAction = UIAlertAction(title: "Playlists", style: .default) { action -> Void in
            PlayerController.sharedController.onHandleClose()
            self.customTabBarController?.onHandleShowAllPlaylist(song: song)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        downloadAction.setValue(UIImage(named: "download"), forKey: "image")
        favoriteAction.setValue(UIImage(named: "heart"), forKey: "image")
        playlistAction.setValue(UIImage(named: "playlist"), forKey: "image")
        
        
        downloadAction.setValue(0, forKey: "titleTextAlignment")
        playlistAction.setValue(0, forKey: "titleTextAlignment")
        favoriteAction.setValue(0, forKey: "titleTextAlignment")
        
        actionSheetController.addAction(downloadAction)
        actionSheetController.addAction(favoriteAction)
        actionSheetController.addAction(playlistAction)
        
        actionSheetController.addAction(cancelAction)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.makeKeyAndVisible()
        
        if let popoverController = actionSheetController.popoverPresentationController {
            self.view.frame = UIScreen.main.bounds
            popoverController.sourceView = button
            popoverController.sourceRect = CGRect(x: button.bounds.midX, y: button.bounds.midY, width: 0, height: 0)
        }
        alertWindow.rootViewController?.present(actionSheetController, animated: true, completion: nil)
    }
    
    func onHandleAddToFavorite(song: SMSong) {
        let realm = try! Realm()
        let existMusic = realm.object(ofType: SongFavorite.self, forPrimaryKey:"\(song.id!)")
        
        if existMusic != nil {
            onHandleAlertNotifiError(title: "Song already exists")
        }else {
            HomeController.sharedController.onHandleAddToFavorite(song: song)
        }
    }
    
    func addDownload(song: SMSong){
        
        let realm = try! Realm()
        let existMusic = realm.object(ofType: SongDownloaded.self, forPrimaryKey: String(describing: song.id!))
        let existMusicDownloading = realm.object(ofType: SongDownloading.self, forPrimaryKey: String(describing: song.id!))
        if existMusic != nil || existMusicDownloading != nil {
            DispatchQueue.main.async {
                self.onHandleAlertNotifiError(title: "Song already exists")
            }
        }else {
            DownloadingController.sharedController.songSM = song
            DownloadingController.sharedController.addSongDownloading(song: song)
            DispatchQueue.main.async {
                self.onHandleAlertNotifi(title: "Downloading \(song.title!)")
            }
        }
    }
    
    func showPremiumAlert() {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.makeKeyAndVisible()
        
        let alert = UIAlertController(title: "", message: "Upgrade to Premium to use this feature.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        
        alertWindow.rootViewController?.present(alert, animated: true)
    }
    
}

