//
//  AudioPlayer.swift
//  Khmer Original Pro
//
//  Created by Abraham Sameer on 1/18/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import MediaPlayer
import SDWebImage
import StreamingKit

let kMusicPlayerErrorDomain = "kMusicPlayerErrorDomain"
let kMusicPlayerRepeatType = "kMusicPlayerRepeatType"
let kMusicPlayerShuffleState = "kMusicPlayerShuffleState"
let kMusicPlayerRepeated = "kMusicPlayerRepeated"

enum MusicPlayerRepeat: Int {
    case off
    case on
    case once
}


@objc protocol MusicPlayerDelegate : NSObjectProtocol {
    
    @objc optional func musicPlayer(player: MusicPlayer, didChangeTrack: SMSong)
    @objc optional func musicPlayerBuffering(player: MusicPlayer)
    @objc optional func musicPlayerPlaying(player: MusicPlayer)
    @objc optional func musicPlayerWillStop(player: MusicPlayer)
    @objc optional func musicPlayer(player: MusicPlayer, isTicking timer: Timer)
    @objc optional func musicPlayer(player: MusicPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode)
    @objc optional func musicPlayer(player: MusicPlayer, didFinishPlayingTrack track: SMSong)
    
}


class MusicPlaying:NSObject{
    
    static let sharedInstance : MusicPlayer = {
        let instance = MusicPlayer()
        return instance
    }()
}

class MusicPlayer: NSObject, STKAudioPlayerDelegate {
    
    var customTabBarController: CustomTabBarController?
    
    var songTimer = Timer()
    var audioPlayer: STKAudioPlayer?
    var delegate: MusicPlayerDelegate?
    var currentDuration: String? = "00:00"
    
    static let sharedInstance : MusicPlayer = {
        let instance = MusicPlayer()
        return instance
    }()
    
    lazy var playerDefaults: UserDefaults = {
        let defaults = UserDefaults.standard
        return defaults
    }()
    
    var shuffle: Bool {
        get {
            return self.playerDefaults.bool(forKey: kMusicPlayerShuffleState)
        }
        set {
            self.playerDefaults.set(newValue, forKey: kMusicPlayerShuffleState)
        }
    }
    var repeated: Bool {
        get {
            return self.playerDefaults.bool(forKey: kMusicPlayerRepeated)
        }
        set {
            self.playerDefaults.set(newValue, forKey: kMusicPlayerRepeated)
        }
    }
    var repeatTypeSelected:Int{
        get{
            return self.playerDefaults.integer(forKey: kMusicPlayerRepeatType)
        }
        set{
            self.playerDefaults.set(newValue, forKey: kMusicPlayerRepeatType)
        }
    }
    
    var repeatType: MusicPlayerRepeat {
        get {
            let repeatValue: Int = self.playerDefaults.integer(forKey: kMusicPlayerRepeatType)
            if repeatValue >= 0 {
                return MusicPlayerRepeat(rawValue: self.playerDefaults.integer(forKey: kMusicPlayerRepeatType))!
            } else {
                return .off
            }
        }
    }
    var repeatCounter: Int = 0
    var imagePoster = UIImageView()
    
    // MARK: Init
    override init() {
        super.init()
        resetAudioPlayer()
    }
    
    private func resetAudioPlayer() {
        var options = STKAudioPlayerOptions()
        options.flushQueueOnSeek = true
        options.enableVolumeMixer = true
        audioPlayer = STKAudioPlayer(options: options)
        audioPlayer?.meteringEnabled = true
        audioPlayer?.volume = 1
        audioPlayer?.delegate = self
    }
    
    var queue: [SMSong]?
    
    private(set) var indexPlaying: Int = -1
    private(set) var currentIndex: Int = 0
    var lastIndex: Int = 0
    
    
    internal func playShuffleQueue(){
        self.queue = queue?.shuffled()
    }
    
    var currentTrack: SMSong? {
        get {
            guard let playlist = self.queue else {
                return nil
            }
            return playlist[self.indexPlaying]
        }
    }
    
    func playTrack(url: String) {
        
        if let trackURL = URL(string: url) {
            self.playTrack(withURL: trackURL)
        }
    }
    
    private func playTrack(withURL url: URL) {
        let fileManager = FileManager.default
        let filePath = URL(fileURLWithPath: AppStateHelper.shared.documents).appendingPathComponent(url.lastPathComponent).path
        if fileManager.fileExists(atPath: filePath) {
            let songUrl = URL(fileURLWithPath: filePath)
            let dataSource = STKAudioPlayer.dataSource(from: songUrl)
            self.audioPlayer?.play(dataSource)
            print("offline")
        } else {
            print("online")
            self.audioPlayer?.play(url)
        }
    }
    
    internal func stop() {
        audioPlayer?.stop()
        queue = []
        indexPlaying = -1
    }
    @objc func setSongProgressTimer() {
        if audioPlayer?.state != .playing {
            return
        }
        self.updateNowPlayingInfoCenter()
        DispatchQueue.main.async {
            PlayerController.sharedController.CurrentLabel.text = "\(self.formatTime(fromSeconds: Int((self.audioPlayer?.progress)!)))"
            self.currentDuration = "\(self.formatTime(fromSeconds: Int((self.audioPlayer?.progress)!)))"
            PlayerController.sharedController.progressView.maximumValue = Float((self.audioPlayer?.duration)!)
            PlayerController.sharedController.progressView.value = Float((self.audioPlayer?.progress)!)
            PlayerController.sharedController.updateProgress(value: CGFloat((self.audioPlayer?.progress)!) / CGFloat((self.audioPlayer?.duration)!))
            self.customTabBarController?.progressView.maximumValue = Float((self.audioPlayer?.duration)!)
            self.customTabBarController?.progressView.value = Float((self.audioPlayer?.progress)!)
        }
    }
    
    func changeTrack(atIndex index: Int, completion: ((_ error: NSError) -> Void)?) {
        guard let playlist = self.queue, playlist.count > 0 else {
            let error = NSError(domain: kMusicPlayerErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey: "No song in playlist"])
            completion?(error)
            return
        }
        indexPlaying = index
        currentIndex = indexPlaying
        if lastIndex != indexPlaying{
            self.audioPlayer?.dispose()
            self.audioPlayer = STKAudioPlayer()
            self.audioPlayer?.delegate = self
            self.audioPlayer?.meteringEnabled = true
            audioPlayer?.clearQueue()
            self.playTrack(url: (queue?[indexPlaying].url)!)
        }else{
            indexPlaying = 0
            DispatchQueue.main.async {
                self.customTabBarController?.songTitle.isHidden = false
                self.customTabBarController?.indicatorView.stopAnimating()
                self.customTabBarController?.indicatorView.isHidden = true
                self.customTabBarController?.btnPlayOrPause.setImage(UIImage.init(named: "play"), for: .normal)
                self.audioPlayer?.stop()
            }
        }
        updateNowPlayingInfoCenter()
        customTabBarController?.indexPlaying = indexPlaying
        customTabBarController?.updateViewWithSongData(snogIndex: indexPlaying)
        PlayerController.sharedController.onHandleChangeUIView(songIndex: indexPlaying)
        
        let debouncer = Debouncer(interval: 0)
        debouncer.call()
        debouncer.callback = {
            let body = ["song_id": "\(self.queue![self.indexPlaying].id ?? 0)"]
            SMService.onHandleTracker("counter-song","POST",body,onSuccess: { (success) in
                print("success here", success)
            })
        }
    }
    func next(completion: (_ error: NSError) -> Void) -> Void {
        guard let playlist = self.queue, playlist.count > 0 else {
            let error = NSError(domain: kMusicPlayerErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey: "No song in playlist"])
            completion(error)
            return
        }
        if shuffle{
            let total = (queue?.count)! - 1
            indexPlaying = Int(arc4random_uniform(UInt32(total)))
            self.changeTrack(atIndex: self.indexPlaying, completion: nil)
        }else{
            if self.indexPlaying + 1 < playlist.count {
                self.indexPlaying = self.indexPlaying + 1
                self.changeTrack(atIndex: self.indexPlaying, completion: nil)
            }
        }

        
    }
    func prev(completion: (_ error: NSError) -> Void) -> Void {
        guard let playlist = self.queue, playlist.count > 0 else {
            let error = NSError(domain: kMusicPlayerErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey: "No song in playlist"])
            completion(error)
            return
        }
        if shuffle{
            let total = (queue?.count)! - 1
            indexPlaying = Int(arc4random_uniform(UInt32(total)))
            self.changeTrack(atIndex: self.indexPlaying, completion: nil)
        }else{
            if self.indexPlaying - 1 > -1 {
                self.indexPlaying = self.indexPlaying - 1
                self.changeTrack(atIndex: self.indexPlaying, completion: nil)
            }
        }
        
    }
    // MARK: Audio Player Delegate
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        
        
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didCancelQueuedItems queuedItems: [Any]) {
        
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        audioPlayer.resume()
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, with stopReason: STKAudioPlayerStopReason,logInfo line: String) {
        if stopReason == .pendingNext{
            
        }
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        
        if state == STKAudioPlayerState.buffering {
            DispatchQueue.main.async {
                
                PlayerController.sharedController.indicatorView.isHidden = false
                PlayerController.sharedController.indicatorView.startAnimating()
                PlayerController.sharedController.viewTitleAndName.isHidden = true
                
                self.customTabBarController?.indicatorView.startAnimating()
                self.customTabBarController?.indicatorView.isHidden = false
                self.customTabBarController?.songTitle.isHidden = true
            }
            
        }else if state == STKAudioPlayerState.playing{
            DispatchQueue.main.async {
                PlayerController.sharedController.playerButton.setImage(UIImage.init(named: "pause_double_with_shadows")?.withRenderingMode(.alwaysOriginal), for: .normal)
                PlayerController.sharedController.indicatorView.isHidden = true
                PlayerController.sharedController.indicatorView.stopAnimating()
                PlayerController.sharedController.viewTitleAndName.isHidden = false
                
                self.customTabBarController?.songTitle.isHidden = false
                self.customTabBarController?.indicatorView.stopAnimating()
                self.customTabBarController?.indicatorView.isHidden = true
                self.customTabBarController?.btnPlayOrPause.setImage(UIImage.init(named: "pause")?.withRenderingMode(.alwaysOriginal), for: .normal)
                self.songTimer.invalidate()
                self.songTimer = Timer.scheduledTimer(timeInterval:0.5, target: self, selector: #selector(self.setSongProgressTimer), userInfo: nil, repeats: true)
            }
        } else if state == STKAudioPlayerState.paused{
            DispatchQueue.main.async {
                PlayerController.sharedController.playerButton.setImage(UIImage.init(named: "play_double_with_shadows")?.withRenderingMode(.alwaysOriginal), for: .normal)
                self.customTabBarController?.btnPlayOrPause.setImage(UIImage.init(named: "play"), for: .normal)
            }
        }
        else if state == STKAudioPlayerState.running {
            
        }else if state == STKAudioPlayerState.error {
            stop()
            resetAudioPlayer()
        } else if state == STKAudioPlayerState.disposed {
            
        }
        
    }
    @objc func checkPlayerRealStopReason() {
        if audioPlayer?.stopReason == .eof {
            customTabBarController?.nextPlay()
        }
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        self.delegate?.musicPlayer!(player: self, didFinishPlayingTrack: self.currentTrack!)
        if stopReason == .none {
            perform(#selector(checkPlayerRealStopReason), with: nil, afterDelay: 0.01)
        }
        if stopReason == .eof {
            let totalTrack = (self.queue?.count)!
            if self.repeatType == .off {
                if self.shuffle {
                    indexPlaying = Int(arc4random()) % totalTrack
                } else {
                    if indexPlaying + 1 < totalTrack {
                        indexPlaying = indexPlaying + 1
                    }else{
                        indexPlaying += 1
                    }
                }
            } else if self.repeatType == .once {
                if !repeated {
                    repeated = !repeated
                } else {
                    if self.shuffle {
                        indexPlaying = Int(arc4random()) % totalTrack
                    } else {
                        indexPlaying = currentIndex
                    }
                }
            } else if self.repeatType == .on {
                if !repeated {
                    repeated = !repeated
                } else {
                    if self.shuffle {
                        indexPlaying = Int(arc4random()) % totalTrack
                    }else{
                        if indexPlaying + 1 < totalTrack {
                            indexPlaying = indexPlaying + 1
                        }else {
                            indexPlaying = 0
                        }
                    }
                }
                
            }
            self.changeTrack(atIndex: indexPlaying, completion: nil)
        } else if stopReason == .error {
            stop()
            resetAudioPlayer()
        }
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        audioPlayer.dispose()
        resetAudioPlayer()
        changeTrack(atIndex: indexPlaying, completion: nil)
    }
    
    func seekToTime(sliderValue:Double){
        self.audioPlayer?.seek(toTime:sliderValue)
        if MusicPlayer.sharedInstance.audioPlayer?.state ==  STKAudioPlayerState.paused{
            self.audioPlayer?.pause()
        }
    }
    
    func seekToTime(percent:CGFloat){
        self.audioPlayer?.seek(toTime:Double(percent) * (self.audioPlayer?.duration ?? 0))
        if MusicPlayer.sharedInstance.audioPlayer?.state ==  STKAudioPlayerState.paused{
            self.audioPlayer?.pause()
        }
    }
    
    func volumeSlider(volumeSlider:Double){
        self.audioPlayer?.volume = Float32(volumeSlider)
    }
    
    
    private func updateNowPlayingInfoCenter() {
        guard let playlist = self.queue, playlist.count > 0 else {
            return
        }
        imagePoster.sd_setImage(with: URL(string: playlist[indexPlaying].poster!), placeholderImage: UIImage(named:"thumbnail")) { ( imageDownloaded, err, cac, url) in
            if let image = imageDownloaded{
                if #available(iOS 10, *) {
                    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                        return image
                    })
                }else{
                    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
                }
            }
        }
        
        let albumArtWork = MPMediaItemArtwork(image: imagePoster.image!)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: playlist[indexPlaying].title ?? "",
            MPMediaItemPropertyArtist: playlist[indexPlaying].name ?? "",
            MPMediaItemPropertyPlaybackDuration: audioPlayer?.duration ?? Double(),
            MPNowPlayingInfoPropertyElapsedPlaybackTime: audioPlayer?.progress ?? Double(),
            MPMediaItemPropertyArtwork: albumArtWork
        ]
    }
    func setupNowPlayingInfoCenter(){
        UIApplication.shared.beginReceivingRemoteControlEvents()
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = true
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            let event = event as! MPChangePlaybackPositionCommandEvent
            self.audioPlayer?.seek(toTime: Double(event.positionTime))
            return .success
        }
        MPRemoteCommandCenter.shared().playCommand.addTarget {event in
            self.audioPlayer?.resume()
            self.updateNowPlayingInfoCenter()
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {event in
            self.audioPlayer?.pause()
            return .success
        }
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget {event in
            self.next(completion: self.handleCompletion())
            return .success
        }
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget {event in
            self.prev(completion: self.handleCompletion())
            return .success
        }
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget {event in
            if self.audioPlayer?.state == .playing {
                self.audioPlayer?.pause()
            } else {
                self.audioPlayer?.resume()
            }
            return .success
        }
    }
    func handleCompletion() -> (_ error: NSError) -> Void {
        return { error in
            print("error===", error)
        }
    }
    
    func formatTime(fromSeconds totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
        //return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}


extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}


