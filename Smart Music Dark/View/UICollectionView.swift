//
//  UICollectionView.swift
//  8DWave
//
//  Created by Abraham Sameer on 11/30/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import UIKit
class NewestArtistsCell: UICollectionViewCell {
    
    var artist: SMArtists? {
        didSet {
            if let _artist = artist {
                self.TitleLabel.text = _artist.title
                self.ImageView.sd_setImage(with: URL(string: (_artist.poster!))!, placeholderImage: nil)
            }
        }
    }
    
    let ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    let TitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppStateHelper.shared.defaultFontBold(size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .left
        label.layer.shadowColor = UIColor.rgba(0, 0, 0, 1).cgColor
        label.layer.shadowRadius = 2.0
        label.layer.shadowOpacity = 0.5
        label.layer.shadowOffset = CGSize.zero
        label.layer.masksToBounds = false
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(ImageView)
        addSubview(TitleLabel)
        
        self.dropShadow(color: .rgba(10, 34, 67, 1), opacity: 0.5, offSet: CGSize.zero, radius: 5,cornerRadius: 20, scale: true)
        NSLayoutConstraint.activate([
            ImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            ImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            ImageView.widthAnchor.constraint(equalTo: self.widthAnchor),

        ])
        NSLayoutConstraint.activate([
            TitleLabel.leftAnchor.constraint(equalTo: ImageView.leftAnchor, constant: 18),
            TitleLabel.bottomAnchor.constraint(equalTo: ImageView.bottomAnchor, constant: -17),
            TitleLabel.widthAnchor.constraint(equalTo: ImageView.widthAnchor, constant: -18*2),
        ])
       
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PopularMusicCell: UICollectionViewCell {
    
    var song: SMSong? {
        didSet {
            if let _song = song {
                TitleLabel.text = _song.title
                NameLabel.text = _song.name
                ImageView.sd_setImage(with: URL(string: _song.poster!)!, placeholderImage: UIImage(named: "thumbnail"))
                DurationLabel.text = _song.duration
            }
        }
    }
    
    let ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let dottedLine: UIView = {
        let dottedLine = UIView()
        dottedLine.translatesAutoresizingMaskIntoConstraints = false
        dottedLine.backgroundColor = .rgba(243,244,245,1)
        return dottedLine
    }()
    
    let TitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppStateHelper.shared.defaultFontRegular(size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .rgba(10, 34, 67, 1)
        return label
    }()
    
    let NameLabel: UILabel = {
        let label = UILabel()
        label.font = AppStateHelper.shared.defaultFontRegular(size: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .rgba(151, 190, 232, 1)
        return label
    }()
    
    let DurationLabel: UILabel = {
        let label = UILabel()
        label.font = AppStateHelper.shared.defaultFontBold(size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .rgba(10, 34, 67, 1)
        label.text = "00:00"
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(ImageView)
        addSubview(TitleLabel)
        addSubview(NameLabel)
        addSubview(DurationLabel)
        addSubview(dottedLine)
        NSLayoutConstraint.activate([
            ImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            ImageView.heightAnchor.constraint(equalToConstant: 50),
            ImageView.widthAnchor.constraint(equalToConstant: 50),
        ])
        NSLayoutConstraint.activate([
            TitleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -8),
            TitleLabel.leftAnchor.constraint(equalTo: ImageView.rightAnchor, constant: 10),
            TitleLabel.widthAnchor.constraint(equalToConstant: 200),
        ])
        NSLayoutConstraint.activate([
            NameLabel.bottomAnchor.constraint(equalTo: TitleLabel.bottomAnchor, constant: 15),
            NameLabel.leftAnchor.constraint(equalTo: ImageView.rightAnchor, constant: 10),
            NameLabel.widthAnchor.constraint(equalToConstant: 200),
        ])
        NSLayoutConstraint.activate([
            DurationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            DurationLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15),
            DurationLabel.widthAnchor.constraint(equalToConstant: 80),
            ])
        NSLayoutConstraint.activate([
            dottedLine.topAnchor.constraint(equalTo: self.topAnchor),
            dottedLine.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            dottedLine.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),
            dottedLine.heightAnchor.constraint(equalToConstant: 1),
            ])
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NewestMusicCell: UICollectionViewCell {
    var song: SMSong? {
        didSet {
            if let _song = song {
                TitleLabel.text = _song.title
                ImageView.sd_setImage(with: URL(string: _song.poster!)!, placeholderImage: UIImage(named: "thumbnail"))
            }
        }
    }
    
    let ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let TitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppStateHelper.shared.defaultFontBold(size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .left
        label.layer.shadowColor = UIColor.rgba(0, 0, 0, 1).cgColor
        label.layer.shadowRadius = 2.0
        label.layer.shadowOpacity = 0.5
        label.layer.shadowOffset = CGSize.zero
        label.layer.masksToBounds = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(ImageView)
        addSubview(TitleLabel)
        
        NSLayoutConstraint.activate([
            ImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            ImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            ImageView.heightAnchor.constraint(equalToConstant: 120),
            ImageView.widthAnchor.constraint(equalToConstant: 120),
        ])
        NSLayoutConstraint.activate([
            TitleLabel.bottomAnchor.constraint(equalTo: ImageView.bottomAnchor, constant: -5),
            TitleLabel.leftAnchor.constraint(equalTo: ImageView.leftAnchor, constant: 10),
            TitleLabel.widthAnchor.constraint(equalTo: ImageView.widthAnchor, constant: -20),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PopularArtistCell: UICollectionViewCell {
    
    
    var artist: SMArtists? {
        didSet {
            if let _artist = artist {
                self.NameLabel.text = _artist.title
                self.ImageView.sd_setImage(with: URL(string: (_artist.poster!))!, placeholderImage: UIImage(named: "thumbnail"))
            }
        }
    }
    
    let ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let NameLabel: UILabel = {
        let label = UILabel()
        label.font = AppStateHelper.shared.defaultFontRegular(size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.themeNavbarColor()
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(ImageView)
        addSubview(NameLabel)
        
        NSLayoutConstraint.activate([
            ImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15),
            ImageView.heightAnchor.constraint(equalToConstant: 60),
            ImageView.widthAnchor.constraint(equalToConstant: 60),
        ])
        
        NSLayoutConstraint.activate([
            NameLabel.leftAnchor.constraint(equalTo: ImageView.leftAnchor, constant: 75),
            NameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            NameLabel.widthAnchor.constraint(equalToConstant: 240),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FavoriteCell: UICollectionViewCell {

    var song: SMSong? {
        didSet {
            if let _song = song {
                NameLabel.text = _song.title
                ImageView.sd_setImage(with: URL(string: _song.poster!)!, placeholderImage: UIImage(named: "thumbnail"))
                DurationLabel.text = _song.duration
            }
        }
    }
    
    let ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let NameLabel: UILabel = {
        let label = UILabel()
        label.font = AppStateHelper.shared.defaultFontRegular(size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    let DurationLabel: UILabel = {
        let label = UILabel()
        label.font = AppStateHelper.shared.defaultFontBold(size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "00:00"
        label.textAlignment = .center
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(ImageView)
        addSubview(NameLabel)
        addSubview(DurationLabel)
        NSLayoutConstraint.activate([
            ImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -15),
            ImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ImageView.heightAnchor.constraint(equalToConstant: 100),
            ImageView.widthAnchor.constraint(equalToConstant: 100),
            ])

        NSLayoutConstraint.activate([
            NameLabel.bottomAnchor.constraint(equalTo: ImageView.bottomAnchor, constant: 25),
            NameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            NameLabel.widthAnchor.constraint(equalToConstant: 100),
            ])
        
        NSLayoutConstraint.activate([
            DurationLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            DurationLabel.bottomAnchor.constraint(equalTo: ImageView.bottomAnchor, constant: -5),
            DurationLabel.widthAnchor.constraint(equalToConstant: 50),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
