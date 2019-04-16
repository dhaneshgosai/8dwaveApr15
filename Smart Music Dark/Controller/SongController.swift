//
//  SongController.swift
//  8DWave
//
//  Created by Abraham Sameer on 12/2/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import UIKit

class SongController: UITableViewController {
    
    fileprivate let cellSongId = "cellSongId"
    var songs: [SMSong] = []
    var next_page = 1
    var last_page = 1
    var url: String = ""
    
    private func setupView(){
        tableView?.register(SongPlaylistCell.self, forCellReuseIdentifier: cellSongId)
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.showsVerticalScrollIndicator = false
        tableView?.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.themeBaseColor()
        setupView()
    }
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let endScrolling:CGFloat = scrollView.contentOffset.y +   scrollView.frame.size.height
        if(endScrolling >= scrollView.contentSize.height){
            // This is the last cell so get more data
            print("next_page", next_page)
            next_page = next_page + 1
            if  last_page != 0  {
                onHandleRequest(next_page: next_page,search: "")
            }
        }
    }
    func onHandleRequest(next_page: Int, search: String){
        
        SMService.onHandleGetSong(url,next_page,search,{ (songs) in
            self.last_page = songs.count
            
            DispatchQueue.main.async {
                self.songs = self.songs + songs
                self.tableView?.reloadData()
            }
            
        }, onError: {(errorString) in
            DispatchQueue.main.async {
                AppStateHelper.shared.onHandleAlertNotifiError(title: errorString)
            }
        })
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 70
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        PlayerController.sharedController.songs = self.songs
        PlayerController.sharedController.indexPlaying = indexPath.row
        (self.tabBarController as? CustomTabBarController)?.songs = self.songs
        (self.tabBarController as? CustomTabBarController)?.indexPlaying = indexPath.row
        (self.tabBarController as? CustomTabBarController)?.setUpShowPlayer()
        (self.tabBarController as? CustomTabBarController)?.handeSetUpPlayer()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellSongId, for: indexPath) as! SongPlaylistCell
        DispatchQueue.main.async {
            cell.song = self.songs[indexPath.row]
            cell.textLabel?.text = self.songs[indexPath.row].title
            cell.detailTextLabel?.text = self.songs[indexPath.row].name
            cell.imageView?.sd_setImage(with: URL(string: self.songs[indexPath.row].poster!)!, placeholderImage: UIImage(named: "thumbnail"))
            cell.duringButton.setTitle( self.songs[indexPath.row].duration, for: .normal)
        }
        cell.backgroundColor = UIColor.themeBaseColor()
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.selectionStyle = .none
        return cell
        
    }
    
    
}
