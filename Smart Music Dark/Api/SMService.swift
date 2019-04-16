//
//  SMService.swift
//  8DWave
//
//  Created by Abraham Sameer on 12/1/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

public var baseUrl = "http://99.79.78.118/api/" //"http://35.183.65.138/api/"

import UIKit

class SMService {
    
    class fileprivate func baseRequest(withURL urlString: String, onSuccess: @escaping (_ data: Data?) -> (), onError: @escaping (_ errorMessage: String) -> ()) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let safeURL = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let urlRequest = URLRequest(url: URL(string: safeURL!)!)
        let session = URLSession.shared
        DispatchQueue.main.async {
            let dataTask = session.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                if error != nil {
                    onError("\(error!)")
                }else {
                    let httpResponse = response as! HTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    if statusCode == 200 {
                        onSuccess(data)
                    }else {
                        let statusCodeObj = HTTPStatusCode.init(statusCode: statusCode)
                        onError(statusCodeObj.statusDescription)
                    }
                }
            })
            dataTask.resume()
        }
    }
    
    
    class func onHandleGetSong(_ url: String,_ next_page: Int, _ search:String, _ onSuccess: @escaping (_ songs: [SMSong]) -> (), onError: @escaping (_ errorMessage: String) -> ()) {
        let urlString = baseUrl+url+"?page=\(next_page)&search=\(search)"
        SMService.baseRequest(withURL: urlString, onSuccess: { (data) in
            var song: [SMSong] = []
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                    if let songDic = json.value(forKey: "data") as? [NSDictionary] {
                        for dic in songDic {
                            let songs = SMSong.init(withDictionary: dic)
                            song.append(songs)
                        }
                        onSuccess(song)
                    }
                }
            }catch {
                DispatchQueue.main.async {
                    AppStateHelper.shared.onHandleAlertNotifiError(title: "Internal Server Error")
                }
            }
        }) { (errorString) in
            onError(errorString)
        }
    }
    
    
    class func onHandleGetArtist(_ url: String ,_ next_page: Int, _ search:String, _ onSuccess: @escaping (_ artists: [SMArtists]) -> (), onError: @escaping (_ errorMessage: String) -> ()) {
        let urlString = baseUrl+url+"?page=\(next_page)&search=\(search)"
        SMService.baseRequest(withURL: urlString, onSuccess: { (data) in
            var artist: [SMArtists] = []
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                    if let songDic = json.value(forKey: "data") as? [NSDictionary] {
                        for dic in songDic {
                            let artists = SMArtists.init(withDictionary: dic)
                            artist.append(artists)
                        }
                        onSuccess(artist)
                    }
                }
            }catch {
                DispatchQueue.main.async {
                  //  AppStateHelper.shared.onHandleAlertNotifiError(title: "Internal Server Error")
                }
            }
        }) { (errorString) in
            onError(errorString)
        }
    }
    
    class func onHandleGetSearch(_ url: String, _ onSuccess: @escaping (
        _ song: [SMSong],
        _ artist: [SMArtists]
        
        ) -> (), onError: @escaping (_ errorMessage: String) -> ()) {
        let urlString = baseUrl+url
        SMService.baseRequest(withURL: urlString, onSuccess: { (data) in
            var song: [SMSong] = []
            var artist: [SMArtists] = []
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                    if let songDic = json.value(forKey: "songs") as? [NSDictionary] {
                        for dic in songDic {
                            let songs = SMSong.init(withDictionary: dic)
                            song.append(songs)
                        }
                    }
                    
                    if let songDic = json.value(forKey: "artists") as? [NSDictionary] {
                        for dic in songDic {
                            let artists = SMArtists.init(withDictionary: dic)
                            artist.append(artists)
                        }
                    }
               
                    onSuccess(song,artist)
                }
            }catch {
                DispatchQueue.main.async {
                   // AppStateHelper.shared.onHandleAlertNotifiError(title: alermsg)
                }
            }
        }) { (errorString) in
            onError(errorString)
        }
    }
    
    class func onHandleGetSongById(_ url: String ,_ id: Int, _ onSuccess: @escaping (_ songs: [SMSong] ) -> (), onError: @escaping (_ errorMessage: String) -> ()) {
        let urlString = baseUrl+url+"/\(id)"
        SMService.baseRequest(withURL: urlString, onSuccess: { (data) in
            var songs: [SMSong] = []
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                    if let songDic = json.value(forKey: "data") as? [NSDictionary] {
                        for dic in songDic {
                            let song = SMSong.init(withDictionary: dic)
                            songs.append(song)
                        }
                        onSuccess(songs)
                    }
                }
            }catch {
                DispatchQueue.main.async {
                 //   AppStateHelper.shared.onHandleAlertNotifiError(title: alermsg)
                }
            }
        }) { (errorString) in
            onError(errorString)
        }
    }
    
    class func onHandleTracker(_ url: String,_ Method: String, _ body: Dictionary<String, String>, onSuccess: @escaping (_ success: Bool) -> () ){
        let session = URLSession.shared
        let ulrString =  NSURL(string: baseUrl + url)
        var request = URLRequest(url:  ulrString! as URL)
        request.httpMethod = Method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch let error {
            print(error)
        }
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil else {
                return
            }
            if data != nil {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        onSuccess(true)
                    }else {
                        onSuccess(false)
                    }
                }
            }
        })
        task.resume()
    }
    

    class func getImages(from urls: [URL], completion: @escaping ([UIImage]?, Error?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            var storedError: Error?
            var images = [UIImage]()
            let group = DispatchGroup()
            for url in urls{
                group.enter()
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if error != nil{
                        storedError = error
                    }else if let data = data, let image = UIImage(data: data){
                        images.append(image)
                    }
                    group.leave()
                }.resume()
            }
            
            group.wait()
            
            DispatchQueue.main.async {
                completion(images, storedError)
            }
        }
    }
}
