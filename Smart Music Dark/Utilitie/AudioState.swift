//
//  AudioState.swift
//  8DWave
//
//  Created by Ben Gottlieb on 3/23/19.
//  Copyright © 2019 Abraham Sameer. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AudioState: CustomStringConvertible {
    static let instance = AudioState()
    
    var window: UIWindow!
    var isInMono: Bool { return UIAccessibility.isMonoAudioEnabled }
    var areHeadphonesAttached: Bool {
        for output in AVAudioSession.sharedInstance().currentRoute.outputs {
            if output.isHeadset { return true }
        }
        return false
    }
    
    func setup(with window: UIWindow) {
        self.window = window
        NotificationCenter.default.addObserver(self, selector: #selector(routesChanged), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    weak var audioAlert: UIAlertController?
    func checkForAudioIssues() {
        if self.audioAlert != nil || self.window == nil { return }
        DispatchQueue.main.async {
            if AudioState.instance.isInMono {
                let alert = UIAlertController(title: "Please disable Mono Audio!", message: "Go to Settings > General > Accessibility.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                self.audioAlert = alert
            } else if !AudioState.instance.areHeadphonesAttached {
                let alert = UIAlertController(title: "Please Connect Headphones!", message: "8D Effects only work with headphones", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                self.audioAlert = alert
            }
        }
    }
    
    func clearAudioIssues() {
        self.audioAlert?.dismiss(animated: false, completion: nil)
    }
    
    var description: String {
        return "Headphones: \(self.areHeadphonesAttached), Mono: \(self.isInMono)"
    }
    
    @objc func routesChanged(note: Notification) {
        self.checkForAudioIssues()
    }
}

extension AVAudioSessionPortDescription {
    var isHeadset: Bool {
        if self.portType == .headphones || self.portType == .bluetoothLE || self.portType == .bluetoothHFP { return true }
        
        if self.portType == .bluetoothA2DP { return self.portName.lowercased().contains("airpod") }
        
        return false
    }
}
