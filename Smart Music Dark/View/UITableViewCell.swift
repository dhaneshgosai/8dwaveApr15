//
//  UITableViewCell.swift
//  8DWave
//
//  Created by Abraham Sameer on 12/1/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import UIKit
import DownloadButton
import SDWebImage

class MusicCell: UITableViewCell {
    
    override func layoutSubviews(){
        super.layoutSubviews()
        textLabel?.textColor = .white
        textLabel?.frame = CGRect(x: 85, y: textLabel!.frame.origin.y, width: 200, height: textLabel!.frame.height)
        textLabel?.text = "Beautiful Company Photos"
        detailTextLabel?.frame = CGRect(x: 85, y: detailTextLabel!.frame.origin.y, width: 90, height: detailTextLabel!.frame.height)
        detailTextLabel?.text = "Abraham Sameer"
        detailTextLabel?.textColor = .lightGray
        self.textLabel?.font = AppStateHelper.shared.defaultFontRegular(size:16)
        self.detailTextLabel?.font = AppStateHelper.shared.defaultFontRegular(size:14)
        self.imageView?.frame = CGRect(x: 15.0,y: 7.0,width: 60.0,height: 60.0)
        self.imageView?.layer.cornerRadius = 30.0
        self.imageView?.clipsToBounds = true
        self.imageView?.image = UIImage(named: "example")
    }
    lazy var duringButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("00:00", for: .normal)
        button.titleLabel?.font = AppStateHelper.shared.defaultFontRegular(size:16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.lightGray, for: UIControl.State())
        return button
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(duringButton)
        duringButton.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -10).isActive = true
        duringButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        duringButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        duringButton.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class DownloadingCell: UITableViewCell {
    
    var delegate: DownloadingCellDelegate?
    var indexPathRow: Int = 0
    
    let ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "thumbnail")
        imageView.layer.cornerRadius = 25
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let TitleLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = UIColor.rgba(10, 34, 67, 1)
        label.font = AppStateHelper.shared.defaultFontBold(size:13)
        return label
    }()
    
    let NameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = UIColor.rgba(151, 190, 232, 1)
        label.font = AppStateHelper.shared.defaultFontBold(size:11)
        return label
    }()
    
    let sizeDownloading: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.textAlignment = .right
        label.font =  AppStateHelper.shared.defaultFontBold(size: 9)
        return label
    }()
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = .rgba(243,244,245,1)
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    var downloadButton = PKDownloadButton()
    
    func setupViews() {
        addSubview(ImageView)
        addSubview(TitleLabel)
        addSubview(NameLabel)
        addSubview(downloadButton)
        addSubview(lineView)
        
        TitleLabel.translatesAutoresizingMaskIntoConstraints = false
        TitleLabel.leftAnchor.constraint(equalTo: self.ImageView.leftAnchor,constant:75).isActive = true
        TitleLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100).isActive =  true
        TitleLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        TitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        
        NameLabel.translatesAutoresizingMaskIntoConstraints = false
        NameLabel.bottomAnchor.constraint(equalTo: TitleLabel.bottomAnchor,constant: 15).isActive = true
        NameLabel.leftAnchor.constraint(equalTo: self.ImageView.leftAnchor,constant: 75).isActive = true
        NameLabel.widthAnchor.constraint(equalToConstant: 240).isActive = true
        
        ImageView.translatesAutoresizingMaskIntoConstraints = false
        ImageView.widthAnchor.constraint(equalToConstant: 50).isActive =  true
        ImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        ImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        ImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        addSubview(sizeDownloading)
        sizeDownloading.translatesAutoresizingMaskIntoConstraints = false
        sizeDownloading.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -55).isActive = true
        sizeDownloading.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 5).isActive = true
        sizeDownloading.text = "Calculating..."
        sizeDownloading.heightAnchor.constraint(equalToConstant: 35).isActive = true
        sizeDownloading.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.stopDownloadButton.tintColor = UIColor.white
        let attributedString =
            NSAttributedString(string: " \u{f0ed} ", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: AppStateHelper.shared.defaultFontAwesome(size: 16)])
        downloadButton.startDownloadButton!.setAttributedTitle(attributedString, for: .normal)
        downloadButton.startDownloadButton.tintColor = UIColor.white
        downloadButton.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -10).isActive = true
        downloadButton.tintColor = UIColor.white
        downloadButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        downloadButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        downloadButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        downloadButton.state = .startDownload
        
        lineView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    override func layoutSubviews(){
        super.layoutSubviews()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCellForRowAtIndexPath(_ indexPath : IndexPath, downloadModel: MZDownloadModel) {
        self.downloadButton.stopDownloadButton.progress = CGFloat(downloadModel.progress)
        
        var speed = ""
        if let _ = downloadModel.speed?.speed {
            speed = String(format: "%.2f %@/sec", (downloadModel.speed?.speed)!, (downloadModel.speed?.unit)!)
        }
        
        var fileSize = ""
        if let _ = downloadModel.file?.size {
            fileSize = String(format: "%.2f %@", (downloadModel.file?.size)!, (downloadModel.file?.unit)!)
        }
        
        var downloadedFileSize = "Calculating..."
        if let _ = downloadModel.downloadedFile?.size {
            downloadedFileSize = String(format: "%.2f %@", (downloadModel.downloadedFile?.size)!, (downloadModel.downloadedFile?.unit)!)
        }
        let detailLabelText = NSMutableString()
        detailLabelText.appendFormat("\(downloadedFileSize)/\(fileSize)\nSpeed: \(speed)" as NSString)
        self.sizeDownloading.text = detailLabelText as String
    }
    
}

class DownloadCell: UITableViewCell {
    
    override func layoutSubviews(){
        super.layoutSubviews()
        textLabel?.textColor = UIColor.rgba(10, 34, 67, 1)
        
        textLabel?.frame = CGRect(x: 80, y: textLabel!.frame.origin.y, width: 200, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 80, y: detailTextLabel!.frame.origin.y, width: 90, height: detailTextLabel!.frame.height)
        
        detailTextLabel?.textColor = .rgba(151, 190, 232, 1)
        self.textLabel?.font = AppStateHelper.shared.defaultFontBold(size:13)
        self.detailTextLabel?.font = AppStateHelper.shared.defaultFontBold(size:11)
        self.imageView?.frame = CGRect(x: 20,y: 10,width: 50,height: 50)
        self.imageView?.layer.cornerRadius = 25
        self.imageView?.clipsToBounds = true
    }
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = .rgba(243,244,245,1)
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    lazy var duringButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("00:00", for: .normal)
        button.titleLabel?.font = AppStateHelper.shared.defaultFontBold(size:12)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.rgba(10, 34, 67, 1), for: UIControl.State())
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(duringButton)
        addSubview(lineView)
        
        duringButton.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -10).isActive = true
        duringButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        duringButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        duringButton.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        lineView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class PlayerMusicCell: UITableViewCell {
    
    var delegate: PlayerMusicCellCellDelegate?
    var indexPath: Int = 0
    
    let musicIndicator = ESTMusicIndicatorView()
    var state: ESTMusicIndicatorViewState = .stopped {
        didSet {
            musicIndicator.state = state
        }
    }
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = .rgba(243,244,245,1)
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("\u{f142}", for: .normal)
        button.titleLabel?.font = AppStateHelper.shared.defaultFontAwesome(size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.rgba(10, 34, 67, 1), for: UIControl.State())
        button.addTarget(self, action: #selector(handleMoreIfo), for: .touchUpInside)
        return button
    }()
    
    lazy var duringButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("00:00", for: .normal)
        button.titleLabel?.font = AppStateHelper.shared.defaultFontBold(size:12)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.rgba(10, 34, 67, 1), for: UIControl.State())
        return button
    }()
    
    var song: SMSong? {
        didSet {
            if let _song = song {
                self.textLabel?.text = _song.title
                self.detailTextLabel?.text = _song.name
                self.imageView?.sd_setImage(with: URL(string: _song.poster!)!, placeholderImage: UIImage(named: "thumbnail"))
                duringButton.setTitle(_song.duration, for: .normal)
            }
        }
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        
        detailTextLabel?.textColor = .rgba(151, 190, 232, 1)
        self.textLabel?.frame = CGRect(x: 80, y: textLabel!.frame.origin.y, width: UIScreen.main.bounds.width - 165, height: textLabel!.frame.height)
        self.detailTextLabel?.frame = CGRect(x: 80, y: detailTextLabel!.frame.origin.y, width:90, height: detailTextLabel!.frame.height)
        
        self.textLabel?.textColor = UIColor.rgba(10, 34, 67, 1)
        self.textLabel?.font = AppStateHelper.shared.defaultFontBold(size:13)
        self.detailTextLabel?.font = AppStateHelper.shared.defaultFontBold(size:11)
        self.imageView?.frame = CGRect(x: 20.0,y: 10,width: 50.0,height: 50.0)
        self.imageView?.layer.cornerRadius = 25
        self.imageView?.clipsToBounds = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(duringButton)
        addSubview(musicIndicator)
        addSubview(lineView)
        addSubview(moreButton)
        
        duringButton.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -40).isActive = true
        duringButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        duringButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        duringButton.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        moreButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        moreButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lineView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        lineView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        musicIndicator.tintColor = .white
        musicIndicator.translatesAutoresizingMaskIntoConstraints = false
        musicIndicator.widthAnchor.constraint(equalToConstant: 20).isActive = true
        musicIndicator.heightAnchor.constraint(equalToConstant: 20).isActive = true
        musicIndicator.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 34).isActive = true
        musicIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 24).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleMoreIfo () {
        AppStateHelper.shared.onHandleSongMore(song: song!, button: moreButton)
    }
    
}


class SearchTrackCell: UITableViewCell {
    var song: SMSong? {
        didSet {
            if let _song = song {
                self.textLabel?.text = _song.title
                self.detailTextLabel?.text = _song.name
                self.imageView?.sd_setImage(with: URL(string: _song.poster!)!, placeholderImage: UIImage(named: "thumbnail"))
                duringButton.setTitle(_song.duration, for: .normal)
            }
        }
    }
    override func layoutSubviews(){
        super.layoutSubviews()
        
        self.textLabel?.textColor = .rgba(10, 34, 67, 1)
        detailTextLabel?.textColor = .rgba(151, 190, 232, 1)
        
        self.textLabel?.frame = CGRect(x: 80, y: textLabel!.frame.origin.y, width: UIScreen.main.bounds.width - 165, height: textLabel!.frame.height)
        self.detailTextLabel?.frame = CGRect(x: 80, y: detailTextLabel!.frame.origin.y, width:90, height: detailTextLabel!.frame.height)
        self.textLabel?.font = AppStateHelper.shared.defaultFontBold(size:13)
        self.detailTextLabel?.font = AppStateHelper.shared.defaultFontBold(size:11)
        
        self.imageView?.frame = CGRect(x: 20.0,y: 10,width: 50,height: 50)
        self.imageView?.layer.cornerRadius = 25
        self.imageView?.clipsToBounds = true
        self.imageView?.contentMode = .scaleAspectFill
    }
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = .rgba(243,244,245,1)
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    lazy var duringButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("00:00", for: .normal)
        button.titleLabel?.font = AppStateHelper.shared.defaultFontBold(size:12)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.rgba(10, 34, 67, 1), for: UIControl.State())
        return button
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("\u{f142}", for: .normal)
        button.titleLabel?.font = AppStateHelper.shared.defaultFontAwesome(size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.rgba(10, 34, 67, 1), for: UIControl.State())
        button.addTarget(self, action: #selector(handleMoreIfo), for: .touchUpInside)
        return button
    }()
    
    @objc func handleMoreIfo () {
        AppStateHelper.shared.onHandleSongMore(song: song!, button: moreButton)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(duringButton)
        addSubview(moreButton)
        addSubview(lineView)
        
        duringButton.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -40).isActive = true
        duringButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        duringButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        duringButton.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        moreButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        moreButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lineView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        lineView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class SearchArtistCell: UITableViewCell{
    
    var artist: SMArtists? {
        didSet {
            if let _artist = artist {
                self.textLabel?.text = _artist.title
                self.imageView?.sd_setImage(with: URL(string: (_artist.poster!))!, placeholderImage: UIImage(named: "thumbnail"))
            }
        }
    }
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = .rgba(243,244,245,1)
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    override func layoutSubviews(){
        super.layoutSubviews()
        textLabel?.textColor = .rgba(10, 34, 67, 1)
        textLabel?.frame = CGRect(x: 80,y:20, width: 300, height: 30)
        textLabel?.font = AppStateHelper.shared.defaultFontRegular(size: 15)
        self.imageView?.frame = CGRect(x:20.0,y: 10,width: 50,height: 50)
        self.imageView?.layer.cornerRadius = 10.0
        self.imageView?.clipsToBounds = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(lineView)
        
        lineView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        lineView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SongPlaylistCell: UITableViewCell {
    
    var song: SMSong? {
        didSet {
            if let _song = song {
                self.textLabel?.text = _song.title
                self.detailTextLabel?.text = _song.name
                self.imageView?.sd_setImage(with: URL(string: _song.poster!)!, placeholderImage: UIImage(named: "thumbnail"))
                duringButton.setTitle(_song.duration, for: .normal)
            }
        }
    }
    
    lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("\u{f142}", for: .normal)
        button.titleLabel?.font = AppStateHelper.shared.defaultFontAwesome(size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.rgba(10, 34, 67, 1), for: UIControl.State())
        button.addTarget(self, action: #selector(handleMoreIfo), for: .touchUpInside)
        return button
    }()
    
    @objc func handleMoreIfo () {
        AppStateHelper.shared.onHandleSongMore(song: song!, button: moreButton)
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        textLabel?.textColor = UIColor.rgba(10, 34, 67, 1)
        self.textLabel?.frame = CGRect(x: 80, y: textLabel!.frame.origin.y, width: UIScreen.main.bounds.width - 165, height: textLabel!.frame.height)
        self.detailTextLabel?.frame = CGRect(x: 80, y: detailTextLabel!.frame.origin.y, width:90, height: detailTextLabel!.frame.height)
        detailTextLabel?.textColor = .rgba(151, 190, 232, 1)
        self.textLabel?.font = AppStateHelper.shared.defaultFontBold(size:13)
        self.detailTextLabel?.font = AppStateHelper.shared.defaultFontBold(size:11)
        self.imageView?.frame = CGRect(x: 20.0,y: 10,width: 50,height: 50)
        self.imageView?.layer.cornerRadius = 25
        self.imageView?.clipsToBounds = true
        self.imageView?.contentMode = .scaleAspectFill
    }
    
    lazy var duringButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("00:00", for: .normal)
        button.titleLabel?.font = AppStateHelper.shared.defaultFontBold(size:12)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.rgba(10, 34, 67, 1), for: UIControl.State())
        return button
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(moreButton)
        addSubview(duringButton)
        duringButton.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -40).isActive = true
        duringButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        duringButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        duringButton.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        moreButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        moreButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ArtistCell: UITableViewCell {
    
    var artist: SMArtists? {
        didSet {
            if let _artist = artist {
                self.textLabel?.text = _artist.title
                self.imageView?.sd_setImage(with: URL(string: (_artist.poster!))!, placeholderImage: UIImage(named: "thumbnail"))
            }
        }
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        textLabel?.textColor = UIColor.themeNavbarColor()
        textLabel?.frame = CGRect(x: 85, y: textLabel!.frame.origin.y, width: 200, height: textLabel!.frame.height)
        self.textLabel?.font = AppStateHelper.shared.defaultFontRegular(size:16)
        self.imageView?.frame = CGRect(x: 15.0,y: 7.0,width: 60.0,height: 60.0)
        self.imageView?.layer.cornerRadius = 5.0
        self.imageView?.clipsToBounds = true
        self.imageView?.contentMode = .scaleAspectFill
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
