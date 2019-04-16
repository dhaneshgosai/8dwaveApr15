//
//  PlayerController.swift
//  Samneang
//
//  Created by Abraham Sameer on 6/29/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import StreamingKit
import MarqueeLabel

class SubViewProgress: UIView{
    
    var rewind: ((_ percent: CGFloat) -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        rewind(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        rewind(touches, with: event)
    }
    
    private func rewind(_ touches: Set<UITouch>, with event: UIEvent?){
        let touch = touches.first!
        let location = touch.location(in: self)
        let percent = location.x / bounds.width
        if percent >= 0 && percent < 1{
            rewind?(percent)
        }
        
    }
}

class PlayerController: UITableViewController, PlayerMusicCellCellDelegate{
    
    static var sharedController = PlayerController()
    static weak var playListSongController: PlaylistSongController?
    
    fileprivate let cellId = "cellId"
    var songs: [SMSong] = []
    var indexPlaying:Int = 0
    
    lazy var downButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onHandleClose), for: .touchUpInside)
        return button
    }()
    lazy var progressView: CustomProgressUISlider = {
        let progress = CustomProgressUISlider()
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
    
    lazy var progressLine: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "progress_line"))
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .left
        return imageView
    }()
    
    lazy var progressLineFilled: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "progress_line_filled"))
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .left
        return imageView
    }()
    
    var progressLineFilledConstraint: NSLayoutConstraint?
    
    lazy var playerButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.themeButtonsColor()
        button.addTarget(self, action: #selector(onHandlePlayOrPause), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let CurrentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = UIColor.rgba(10, 34, 67, 1)
        label.font = AppStateHelper.shared.defaultFontRegular(size:10)
        label.textAlignment = .left
        return label
    }()
    
    let CoverView: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.layer.shadowOffset = CGSize.zero
        vw.layer.shadowOpacity = 0.6
        vw.layer.shadowRadius = 50
        return vw
    }()
    
    let ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "thumbnail")
        return imageView
    }()
    
    let TotalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = UIColor.rgba(10, 34, 67, 1)
        label.font = AppStateHelper.shared.defaultFontRegular(size:10)
        label.textAlignment = .right
        return label
    }()
    
    let TitleLabel: MarqueeLabel = {
        let label = MarqueeLabel()
        label.textColor = UIColor.rgba(10, 34, 67, 1)
        label.tag = 101
        label.type = .continuous
        label.animationCurve = .easeInOut
        label.speed = .duration(8.0)
        label.textAlignment = .center
        label.font = AppStateHelper.shared.defaultFontBold(size:24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let NameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rgba(0, 111, 188, 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppStateHelper.shared.defaultFontRegular(size:11)
        label.textAlignment = .center
        return label
    }()
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.themeButtonsColor()
        button.addTarget(self, action: #selector(onHandleNext), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var prveButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.themeButtonsColor()
        button.addTarget(self, action: #selector(onHandlePrevious), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var repeatButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.themeButtonsColor()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onHandleRepeat), for: .touchUpInside)
        return button
    }()
    
    lazy var shuffleButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.themeButtonsColor()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleShuffle), for: .touchUpInside)
        return button
    }()
    
    let subView = UIView()
    var subViewProgress = SubViewProgress()
    var indicatorView = UIActivityIndicatorView()
    let viewTitleAndName = UIView()
    let viewBorder = UIView()
    
    fileprivate func setupView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PlayerController.sharedController = self
        self.view.backgroundColor = UIColor.themeBaseColor()
        setupView()
        subViewProgress.rewind = { percent in
            self.updateProgress(value: percent)
            MusicPlayer.sharedInstance.seekToTime(percent: percent)
        }
    }
    
    func updateProgress(value: CGFloat){
        self.progressLineFilledConstraint = self.progressLineFilledConstraint?.setMultiplier(multiplier: value > 0 ? value : 0.0001)
            self.view.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupViewCheckStatus(){
        if MusicPlayer.sharedInstance.audioPlayer?.state == STKAudioPlayerState.playing {
            playerButton.setImage( UIImage.init(named: "pause_double_with_shadows")?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            playerButton.setImage(UIImage.init(named: "play_double_with_shadows")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        if MusicPlayer.sharedInstance.shuffle == true {
            shuffleButton.tintColor = UIColor.themeNavbarColor()
        }
        if MusicPlayer.sharedInstance.repeatType == .on {
            repeatButton.tintColor = UIColor.themeNavbarColor()
        } else if MusicPlayer.sharedInstance.repeatType == .once {
            let repeatImg = UIImage(named: "repeat-one")
            let repeatedImage = repeatImg?.withRenderingMode(.alwaysTemplate)
            repeatButton.setImage(repeatedImage, for: .normal)
            repeatButton.tintColor = UIColor.themeNavbarColor()
        }else  {
            repeatButton.tintColor = UIColor.themeButtonsColor()
        }
    }
    
    fileprivate func setupViewPlayer() {
        
        downButton.setImage(UIImage.init(named: "Drag handle"), for: .normal)
        downButton.centerXAnchor.constraint(equalTo: subView.centerXAnchor).isActive = true
        downButton.topAnchor.constraint(equalTo: subView.topAnchor, constant: 10).isActive = true
        downButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        downButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        CoverView.centerXAnchor.constraint(equalTo: subView.centerXAnchor).isActive = true
        CoverView.topAnchor.constraint(equalTo: downButton.topAnchor, constant: 40).isActive = true
        CoverView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        CoverView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        ImageView.centerXAnchor.constraint(equalTo: CoverView.centerXAnchor).isActive = true
        ImageView.topAnchor.constraint(equalTo: CoverView.topAnchor).isActive = true
        let width = self.view.frame.width * 0.75
        ImageView.widthAnchor.constraint(equalToConstant: width).isActive = true
        ImageView.heightAnchor.constraint(equalToConstant: width).isActive = true
        
        subViewProgress.translatesAutoresizingMaskIntoConstraints = false
        subViewProgress.centerXAnchor.constraint(equalTo: subView.centerXAnchor).isActive = true
        subViewProgress.topAnchor.constraint(equalTo: self.playerButton.bottomAnchor, constant: 50).isActive = true
        subViewProgress.widthAnchor.constraint(equalToConstant: self.view.bounds.width - 40).isActive = true
        subViewProgress.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        //subViewProgress.addSubview(progressView)
        
        
        progressLine.topAnchor.constraint(equalTo: self.subViewProgress.topAnchor).isActive = true
        progressLine.bottomAnchor.constraint(equalTo: self.subViewProgress.bottomAnchor).isActive = true
        progressLine.rightAnchor.constraint(equalTo: self.subViewProgress.rightAnchor).isActive = true
        progressLine.leftAnchor.constraint(equalTo: self.subViewProgress.leftAnchor).isActive = true
        
        progressLineFilled.topAnchor.constraint(equalTo: self.subViewProgress.topAnchor).isActive = true
        progressLineFilled.bottomAnchor.constraint(equalTo: self.subViewProgress.bottomAnchor).isActive = true
        //progressLineFilled.widthAnchor.constraint(equalTo: self.subViewProgress.widthAnchor, multiplayer: 0.5).isActive = true
        progressLineFilledConstraint?.isActive = false
        progressLineFilledConstraint = progressLineFilled.widthAnchor.constraint(equalTo: self.subViewProgress.widthAnchor, multiplier: 0.0001)
        progressLineFilledConstraint?.isActive = true
        progressLineFilled.leftAnchor.constraint(equalTo: self.subViewProgress.leftAnchor).isActive = true
        
        
        //progressView.translatesAutoresizingMaskIntoConstraints = false
        //progressView.topAnchor.constraint(equalTo: self.subViewProgress.topAnchor).isActive = true
        //progressView.rightAnchor.constraint(equalTo: self.subViewProgress.rightAnchor).isActive = true
        //progressView.leftAnchor.constraint(equalTo: self.subViewProgress.leftAnchor).isActive = true
        
        TotalLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        TotalLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        TotalLabel.rightAnchor.constraint(equalTo: subView.rightAnchor, constant: -20).isActive = true
        TotalLabel.topAnchor.constraint(equalTo: self.subViewProgress.bottomAnchor,constant: -7).isActive = true
        
        CurrentLabel.topAnchor.constraint(equalTo: self.subViewProgress.bottomAnchor,constant: -7).isActive = true
        CurrentLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        CurrentLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        CurrentLabel.leftAnchor.constraint(equalTo: subView.leftAnchor, constant:18).isActive = true
        
        nextButton.setImage( UIImage.init(named: "next-forward"), for: .normal)
        prveButton.setImage( UIImage.init(named: "back-forward"), for: .normal)
        repeatButton.setImage( UIImage.init(named: "repeat"), for: .normal)
        shuffleButton.setImage( UIImage.init(named: "shuffle"), for: .normal)
        
        repeatButton.centerYAnchor.constraint(equalTo: self.shuffleButton.centerYAnchor,constant: 0).isActive = true
        repeatButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        repeatButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        repeatButton.rightAnchor.constraint(equalTo: subView.rightAnchor, constant: -20).isActive = true
        
        shuffleButton.topAnchor.constraint(equalTo: viewTitleAndName.bottomAnchor, constant: 0).isActive = true
        shuffleButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        shuffleButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        shuffleButton.leftAnchor.constraint(equalTo: subView.leftAnchor, constant: 20).isActive = true
        
        playerButton.topAnchor.constraint(equalTo: self.shuffleButton.bottomAnchor, constant: 20).isActive = true
        playerButton.centerXAnchor.constraint(equalTo: self.subView.centerXAnchor).isActive = true
        playerButton.widthAnchor.constraint(equalToConstant: 85).isActive = true
        playerButton.heightAnchor.constraint(equalToConstant: 85).isActive = true
        
        nextButton.rightAnchor.constraint(equalTo: self.playerButton.rightAnchor,constant:  60).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        nextButton.centerYAnchor.constraint(equalTo: self.playerButton.centerYAnchor, constant: 0).isActive = true
        prveButton.centerYAnchor.constraint(equalTo: self.playerButton.centerYAnchor, constant: 0).isActive = true
        
        prveButton.leftAnchor.constraint(equalTo: self.playerButton.leftAnchor,constant: -60).isActive = true
        prveButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        prveButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // set constant viewTitleAndName
        viewTitleAndName.translatesAutoresizingMaskIntoConstraints = false
        viewTitleAndName.heightAnchor.constraint(equalToConstant: 30).isActive = true
        viewTitleAndName.topAnchor.constraint(equalTo: self.ImageView.bottomAnchor, constant: 18).isActive = true
        viewTitleAndName.centerXAnchor.constraint(equalTo: subView.centerXAnchor).isActive = true
        viewTitleAndName.widthAnchor.constraint(equalToConstant: self.view.bounds.width - 100).isActive = true
//        // set indicatorView constant
//        indicatorView.translatesAutoresizingMaskIntoConstraints = false
//        indicatorView.bottomAnchor.constraint(equalTo: self.playerButton.bottomAnchor, constant: 48).isActive = true
//        indicatorView.centerXAnchor.constraint(equalTo: subView.centerXAnchor).isActive = true
//        indicatorView.color = UIColor.white
        
        TitleLabel.translatesAutoresizingMaskIntoConstraints = false
        TitleLabel.topAnchor.constraint(equalTo: self.viewTitleAndName.topAnchor).isActive = true
        
        TitleLabel.widthAnchor.constraint(equalToConstant: self.view.bounds.width - 100).isActive = true
        TitleLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        TitleLabel.centerXAnchor.constraint(equalTo: subView.centerXAnchor).isActive = true
        
        NameLabel.centerXAnchor.constraint(equalTo: subView.centerXAnchor).isActive = true
        NameLabel.translatesAutoresizingMaskIntoConstraints = false
        NameLabel.widthAnchor.constraint(equalToConstant: self.view.bounds.width - 80).isActive = true
        NameLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        NameLabel.topAnchor.constraint(equalTo: self.TitleLabel.bottomAnchor, constant: 0).isActive = true
        viewBorder.translatesAutoresizingMaskIntoConstraints = false
        viewBorder.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        viewBorder.heightAnchor.constraint(equalToConstant: 0).isActive = true
        viewBorder.backgroundColor = .clear
        viewBorder.bottomAnchor.constraint(equalTo: subView.bottomAnchor).isActive = true
    }
    
    @objc func onHandleClose(){
        dismiss(animated: true, completion: nil)
    }
    
    func onHandleChangeUIView(songIndex: Int){
        indexPlaying = songIndex
        DispatchQueue.main.async {
            self.TotalLabel.text = self.songs[songIndex].duration
            self.CurrentLabel.text = "00:00"
            self.TitleLabel.text = self.songs[songIndex].title
            self.NameLabel.text = self.songs[songIndex].name
            self.ImageView.sd_setImage(with: URL(string: self.songs[songIndex].poster!)!, placeholderImage: UIImage(named: "thumbnail"))
            
            let color: UIColor = self.ImageView.image!.getPixelColor(pos: CGPoint(x:2.0,y:3.0))
            self.CoverView.layer.shadowColor = color.cgColor
            self.tableView?.reloadData()
        }
    }
    @objc func onHandleImagePlayerZoomIn(){
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
            self.ImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
        })
    }
    @objc func onHandleImagePlayerZoomOut(){
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
            self.ImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
    }
    @objc func onHandlePlayOrPause(){
        if  MusicPlayer.sharedInstance.audioPlayer?.state == STKAudioPlayerState.playing {
            MusicPlayer.sharedInstance.audioPlayer?.pause()
            DispatchQueue.main.async {
                self.playerButton.setImage(UIImage.init(named: "play_double_with_shadows")?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            onHandleImagePlayerZoomIn()
            
        }else if  MusicPlayer.sharedInstance.audioPlayer?.state == STKAudioPlayerState.paused {
            MusicPlayer.sharedInstance.audioPlayer?.resume()
            onHandleImagePlayerZoomOut()
            ImageView.pulsate()
            DispatchQueue.main.async {
                self.playerButton.setImage(UIImage.init(named: "pause_double_with_shadows")?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        PlayerController.playListSongController?.setupPlayButtonImage()
    }
    @objc func paybackSliderValueDidChange(sender: UISlider!){
        MusicPlayer.sharedInstance.seekToTime(sliderValue: Double(sender.value))
    }
    @objc func onHandleNext(){
        MusicPlayer.sharedInstance.next(completion: self.handleCompletion())
    }
    
    @objc func onHandlePrevious(){
        MusicPlayer.sharedInstance.prev(completion: self.handleCompletion())
    }
    @objc private func onHandleRepeat(){
        if MusicPlayer.sharedInstance.repeated == false {
            MusicPlayer.sharedInstance.repeatTypeSelected = 1
            MusicPlayer.sharedInstance.repeated = true
            repeatButton.tintColor = UIColor.themeNavbarColor()
        }else {
            if MusicPlayer.sharedInstance.repeatTypeSelected == 1 {
                MusicPlayer.sharedInstance.repeated = true
                MusicPlayer.sharedInstance.repeatTypeSelected = 2
                DispatchQueue.main.async {
                    let repeatImg = UIImage(named: "repeat-one")
                    let repeatedImage = repeatImg?.withRenderingMode(.alwaysTemplate)
                    self.repeatButton.setImage(repeatedImage, for: .normal)
                }
                repeatButton.tintColor = UIColor.themeNavbarColor()
            }else{
                MusicPlayer.sharedInstance.repeatTypeSelected = 0
                MusicPlayer.sharedInstance.repeated = false
                DispatchQueue.main.async {
                    let repeatImg = UIImage(named: "repeat")
                    let repeatedImage = repeatImg?.withRenderingMode(.alwaysTemplate)
                    self.repeatButton.setImage(repeatedImage, for: .normal)
                }
                repeatButton.tintColor = UIColor.themeButtonsColor()
            }
        }
    }
    @objc func handleShuffle() {
        if MusicPlayer.sharedInstance.shuffle  == true{
            DispatchQueue.main.async {
                self.shuffleButton.tintColor = UIColor.themeButtonsColor()
            }
            MusicPlayer.sharedInstance.shuffle = false
        }else{
            DispatchQueue.main.async {
                self.shuffleButton.tintColor = UIColor.themeNavbarColor()
            }
            MusicPlayer.sharedInstance.shuffle = true
        }
    }
    func handleCompletion() -> (_ error: NSError) -> Void {
        return { error in
            DispatchQueue.main.async {
                AppStateHelper.shared.onHandleAlertNotifiError(title: alermsg)
            }
        }
    }
}
extension PlayerController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            subView.addSubview(downButton)
            subView.addSubview(CoverView)
            CoverView.addSubview(ImageView)
            subView.addSubview(subViewProgress)
            subViewProgress.addSubviews(views: progressLine, progressLineFilled)
            subView.addSubview(TotalLabel)
            subView.addSubview(CurrentLabel)
            subView.addSubview(playerButton)
            subView.addSubview(prveButton)
            subView.addSubview(nextButton)
            subView.addSubview(repeatButton)
            subView.addSubview(shuffleButton)
            viewTitleAndName.addSubview(TitleLabel)
            viewTitleAndName.addSubview(NameLabel)
            subView.addSubview(viewTitleAndName)
            //subView.addSubview(indicatorView)
            subView.addSubview(viewBorder)
            setupViewPlayer()
            setupViewCheckStatus()
            return subView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return self.view.frame.height
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PlayerMusicCell
        return cell
    }
    
}

@objc protocol PlayerMusicCellCellDelegate {
    
}

