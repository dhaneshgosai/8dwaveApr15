//
//  CoreModel.swift
//  8DWave
//
//  Created by Abraham Sameer on 12/1/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation
import Realm
import RealmSwift


class SongFavorite: Object{
    
    @objc dynamic var songID = UUID().uuidString
    override static func primaryKey() -> String? {
        return "songID"
    }
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var poster: String?
    @objc dynamic var name: String?
    @objc dynamic var duration: String?
    @objc dynamic var src: String?
    @objc dynamic var artistId: Int = 0
    @objc dynamic var destination:String?
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String:Any]()
        dictionary["id"] = id
        dictionary["title"] = title
        dictionary["thumbnail"] = poster
        dictionary["name"] = name
        dictionary["duration"] = duration
        dictionary["url"] = src
        dictionary["artistId"] = artistId
        return dictionary
    }
}

class SongDownloaded: Object{
    
    @objc dynamic var songID = UUID().uuidString
    override static func primaryKey() -> String? {
        return "songID"
    }
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var poster: String?
    @objc dynamic var name: String?
    @objc dynamic var duration: String?
    @objc dynamic var src: String?
    @objc dynamic var artistId: Int = 0
    @objc dynamic var destination:String?
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String:Any]()
        dictionary["id"] = id
        dictionary["title"] = title
        dictionary["thumbnail"] = poster
        dictionary["name"] = name
        dictionary["duration"] = duration
        dictionary["url"] = src
        dictionary["artistId"] = artistId
        return dictionary
    }
}

class SongDownloading: Object{
    
    @objc dynamic var songID = UUID().uuidString
    override static func primaryKey() -> String? {
        return "songID"
    }
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var poster: String?
    @objc dynamic var name: String?
    @objc dynamic var duration: String?
    @objc dynamic var src: String?
    @objc dynamic var artistId: Int = 0
    @objc dynamic var destination:String?
    
}

class Playlists: Object{
    
    @objc dynamic var PID = UUID().uuidString
    @objc dynamic var title = ""
    @objc dynamic var createdDate = Date()
    
    override static func primaryKey() -> String? {
        return "PID"
    }
    
    
}



class SongPlaylist: Object{
    
    @objc dynamic var songID = UUID().uuidString
    override static func primaryKey() -> String? {
        return "songID"
    }
    
    @objc dynamic var id: Int = 0
    @objc dynamic var playlist_id: String?
    @objc dynamic var title: String?
    @objc dynamic var poster: String?
    @objc dynamic var name: String?
    @objc dynamic var duration: String?
    @objc dynamic var src: String?
    @objc dynamic var artistId: Int = 0
    @objc dynamic var destination:String?
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String:Any]()
        dictionary["id"] = id
        dictionary["title"] = title
        dictionary["thumbnail"] = poster
        dictionary["name"] = name
        dictionary["duration"] = duration
        dictionary["url"] = src
        dictionary["artistId"] = artistId
        return dictionary
    }
}
