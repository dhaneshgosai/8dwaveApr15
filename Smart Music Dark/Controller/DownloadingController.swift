//
//  DownloadingController.swift
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
import DownloadButton

public let doneNotificationName =  "doneNotificationName"


class DownloadingController: UITableViewController, DownloadingCellDelegate {
    
    static var sharedController = DownloadingController()
    fileprivate let cellId = "cellId"
    var songSM: SMSong?

    let alertControllerViewTag: Int = 500
    var selectedIndexPath : IndexPath!
    
    let myDownloadPath = MZUtility.baseFilePath + "/smart-music-dark"
    lazy var downloadManager: MZDownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "app.kristoff.Smart-Music-Dark.BackgroundSession"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var completion = appDelegate.backgroundSessionCompletionHandler
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
        
        }()
    
    let realm = try! Realm()
    var songSMDownloading: Results<SongDownloading>!
    
    init() {
        super.init(style: .plain)
        self.songSMDownloading = self.realm.objects(SongDownloading.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
        tableView?.register(DownloadingCell.self, forCellReuseIdentifier: cellId)
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.showsVerticalScrollIndicator = false
        tableView?.separatorStyle = .none
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.themeBaseColor()
        DownloadingController.sharedController = self
        setupView()
        if !FileManager.default.fileExists(atPath: myDownloadPath) {
            try! FileManager.default.createDirectory(atPath: myDownloadPath, withIntermediateDirectories: true, attributes: nil)
        }
        let aString: NSString = "temp" as NSString
        aString.appendingPathComponent("")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.songSMDownloading = self.realm.objects(SongDownloading.self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.tableView.setEditing(self.isEditing, animated: true)
        }
    }
    
    func addSongDownloading(song: SMSong) {
        let songDownloading = SongDownloading()
        songDownloading.songID = "\(String(describing: song.id!))"
        songDownloading.id = (song.id)!
        songDownloading.title = song.title
        songDownloading.src = song.url!
        songDownloading.poster = song.poster!
        songDownloading.duration = song.duration!
        songDownloading.artistId = (song.artistId)!
        songDownloading.name = song.name!
        try! self.realm.write {
            self.realm.add(songDownloading)
        }
        self.tableView.reloadData()
        let index = self.songSMDownloading.index(of: songDownloading)!
        let indexPathRow = IndexPath(row: index, section: 0)
        let cell = self.tableView.cellForRow(at: indexPathRow) as? DownloadingCell
        if (cell != nil) {
            cell?.downloadButton.state = .downloading
            let fileURL: NSString = song.url! as NSString
            var fileName : NSString = fileURL.lastPathComponent as NSString
            fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(fileName as String) as NSString)
            downloadManager.addDownloadTask(fileName as String, fileURL: fileURL as String, destinationPath: myDownloadPath)
        }
    }
    
    func onHandleReloadTable() {
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

extension DownloadingController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let downloadModel = downloadManager.downloadingArray[indexPath.row]
        self.showAppropriateActionController(downloadModel.status)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! self.realm.write {
                self.downloadManager.cancelTaskAtIndex(indexPath.row)
                self.realm.delete(songSMDownloading[indexPath.row])
            }
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 70
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songSMDownloading.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DownloadingCell
        DispatchQueue.main.async {
            cell.TitleLabel.text = self.songSMDownloading[indexPath.row].title
            cell.NameLabel.text = self.songSMDownloading[indexPath.row].name
            cell.ImageView.sd_setImage(with: URL(string: self.songSMDownloading[indexPath.row].poster!)!, placeholderImage: UIImage(named: "thumbnail"))
        }
        cell.indexPathRow = indexPath.row
        cell.delegate = self
        
        cell.backgroundColor = UIColor.themeBaseColor()
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.selectionStyle = .none
        return cell
        
     }
    
    
    
}
extension DownloadingController {
    
    func showAppropriateActionController(_ requestStatus: String) {
        
        if requestStatus == TaskStatus.downloading.description() {
            self.showAlertControllerForPause()
        } else if requestStatus == TaskStatus.failed.description() {
            self.showAlertControllerForRetry()
        } else if requestStatus == TaskStatus.paused.description() {
            self.showAlertControllerForStart()
        }
    }
    
    
    func refreshCellForIndex(_ downloadModel: MZDownloadModel, index: Int) {
        let indexPath = IndexPath.init(row: index, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath)
        if let cell = cell {
            let downloadCell = cell as! DownloadingCell
            downloadCell.updateCellForRowAtIndexPath(indexPath, downloadModel: downloadModel)
        }
    }
    func showAlertControllerForRetry() {
        
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (alertAction: UIAlertAction) in
            self.downloadManager.retryDownloadTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
            self.onHandleRemoveDownloading()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(retryAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertControllerForPause() {
        let pauseAction = UIAlertAction(title: "Pause", style: .default) { (alertAction: UIAlertAction) in
            self.downloadManager.pauseDownloadTaskAtIndex(self.selectedIndexPath.row)
        }
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
            self.onHandleRemoveDownloading()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(pauseAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func showAlertControllerForStart() {
        let startAction = UIAlertAction(title: "Start", style: .default) { (alertAction: UIAlertAction) in
            self.downloadManager.resumeDownloadTaskAtIndex(self.selectedIndexPath.row)
        }
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
            self.onHandleRemoveDownloading()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(startAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func onHandleRemoveDownloading() {
        if self.songSMDownloading[self.selectedIndexPath.row].id != nil {
            try! self.realm.write {
                self.realm.delete(self.songSMDownloading[self.selectedIndexPath.row])
            }
            tableView.deleteRows(at: [IndexPath(row: self.selectedIndexPath.row, section: 0)], with: .left)
        }
    }
}

extension DownloadingController: MZDownloadManagerDelegate {
    
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
        //print("downloadModel", downloadModel.fileURL)
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [MZDownloadModel]) {
        tableView.reloadData()
    }
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
        print("downloadRequestCanceled==")
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        let songModel = SongDownloaded()
        songModel.songID = "\(songSMDownloading[index].id)"
        songModel.id = songSMDownloading[index].id
        songModel.title = songSMDownloading[index].title!
        songModel.src = songSMDownloading[index].src!
        songModel.poster = songSMDownloading[index].poster!
        songModel.duration = songSMDownloading[index].duration!
        songModel.artistId = songSMDownloading[index].artistId
        songModel.name = songSMDownloading[index].name!
        try! self.realm.write {
            self.realm.add(songModel)
            self.realm.delete(self.songSMDownloading[index])
        }
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
        downloadManager.presentNotificationForDownload("Ok", notifBody: "Download did completed")
        let docDirectoryPath : NSString = (MZUtility.baseFilePath as NSString).appendingPathComponent(downloadModel.fileName) as NSString
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String), object: docDirectoryPath)
    }
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    //Oppotunity to handle destination does not exists error
    func downloadRequestDestinationDoestNotExists(_ downloadModel: MZDownloadModel, index: Int, location: URL) {
        try? FileManager.default.removeItem(at: location)
        print(" handle destination does not exists error")
    }
}

@objc protocol DownloadingCellDelegate {
    
}
