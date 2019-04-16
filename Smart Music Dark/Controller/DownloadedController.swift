//
//  DownloadedController.swift
//  8DWave
//
//  Created by Abraham Sameer on 12/1/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import StreamingKit
import MarqueeLabel

class DownloadedController: UITableViewController {
    
    static var sharedController = DownloadedController()
    
    fileprivate let cellId = "cellId"
    let realm = try! Realm()
    var songs : Results<SongDownloaded>!
    var songSM: [SMSong] = []
    
    private func setupView(){
        tableView?.register(DownloadCell.self, forCellReuseIdentifier: cellId)
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.showsVerticalScrollIndicator = false
        tableView?.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        
    }
    fileprivate func retrieveDataFromDB(){
        self.songs = self.realm.objects(SongDownloaded.self)
        print("songs", songs.count)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        DownloadedController.sharedController = self
        self.view.backgroundColor = UIColor.themeBaseColor()
        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveDataFromDB()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        songSM = []
        DispatchQueue.main.async {
            self.tableView.setEditing(self.isEditing, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view data source
    @objc func onHandleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension DownloadedController{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        PlayerController.sharedController.songs = songSM
        PlayerController.sharedController.indexPlaying = indexPath.row

        (self.tabBarController as? CustomTabBarController)?.songs = songSM
        (self.tabBarController as? CustomTabBarController)?.indexPlaying = indexPath.row
        (self.tabBarController as? CustomTabBarController)?.setUpShowPlayer()
        (self.tabBarController as? CustomTabBarController)?.handeSetUpPlayer()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songSM.count
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let songObject = realm.objects(SongDownloaded.self).filter("id == %@",songSM[indexPath.row].id!)
            if songObject.count > 0 {
                let url = URL(string: songSM[indexPath.row].url!)
                let path = URL(fileURLWithPath: AppStateHelper.shared.documents).appendingPathComponent((url?.lastPathComponent)!).path
                do {
                    try! self.realm.write {
                        self.realm.delete(songObject)
                    }
                    DispatchQueue.main.async {
                        self.songSM.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .left)
                    }
                    let fileManager = FileManager.default
                    try fileManager.removeItem(atPath: path)
                    print("Delete file successfully....")
                } catch {
                    print("Could not clear temp folder:")
                }
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 70
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DownloadCell
        DispatchQueue.main.async {
            cell.textLabel?.text = self.songSM[indexPath.row].title
            cell.detailTextLabel?.text = self.songSM[indexPath.row].name
            cell.imageView?.sd_setImage(with: URL(string: self.songSM[indexPath.row].poster!)!, placeholderImage: UIImage(named: "thumbnail"))
            cell.duringButton.setTitle( self.songSM[indexPath.row].duration, for: .normal)
        }
        cell.backgroundColor = UIColor.themeBaseColor()
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 75
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
    
    func onHanldeSearch() {
        
    }
    
}

