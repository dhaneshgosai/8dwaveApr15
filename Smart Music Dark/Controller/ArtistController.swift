//
//  ArtistController.swift
//  8DWave
//
//  Created by Abraham Sameer on 12/2/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation
import UIKit

class ArtistController: UITableViewController  {
    
    var artists: [SMArtists] = []
    var next_page = 1
    var last_page = 1
    var url: String = ""
    fileprivate let cellArtistId = "cellArtistId"

    private func setupView(){
        tableView?.register(ArtistCell.self, forCellReuseIdentifier: cellArtistId)
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.showsVerticalScrollIndicator = false
        tableView?.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.themeBaseColor()
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
        
        SMService.onHandleGetArtist(url,next_page,search,{ (artist) in
            self.last_page = artist.count
            DispatchQueue.main.async {
                self.artists = self.artists + artist
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
        return artists.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 75
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artistSingleController = ArtistSingleController()
        artistSingleController.artists = artists
        artistSingleController.currentIndex = indexPath.row
        artistSingleController.title = artists[indexPath.row].title
        navigationController?.pushViewController(artistSingleController, animated: true)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellArtistId, for: indexPath) as! ArtistCell
        DispatchQueue.main.async {
            cell.artist = self.artists[indexPath.row]
        }
        cell.textLabel?.textColor = UIColor.themeNavbarColor()
        cell.backgroundColor = UIColor.themeBaseColor()
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.selectionStyle = .none
        return cell
        
    }
    
    
}
