//
//  UIView+Extensions.swift
//  8DWave
//
//  Created by Abraham Sameer on 11/30/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1,cornerRadius: CGFloat = 0, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // Top Anchor
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }
    // Bottom Anchor
    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
    // Left Anchor
    var safeAreaLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leftAnchor
        } else {
            return self.leftAnchor
        }
    }
    // Right Anchor
    var safeAreaRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.rightAnchor
        } else {
            return self.rightAnchor
        }
    }
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    public func addSubViewList(_ view: UIView...) {
        view.forEach { self.addSubview($0)}
    }
    
    public func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }
    
    static func setupNavigationTitle(title: String, navigationItem: UINavigationItem){
        let navView = UIView()
        
        // Create the label
        let label = UILabel()
        label.text = title.uppercased()
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = NSTextAlignment.center
        label.textColor = #colorLiteral(red: 0.4392156863, green: 0.5764705882, blue: 0.7333333333, alpha: 1)
        
//        // Create the image view
//        let leftWave = UIImageView()
//        leftWave.image = UIImage(named: "wave_left")
//        // To maintain the image's aspect ratio:
//        let imageAspectLeftWave = leftWave.image!.size.width/leftWave.image!.size.height
//        // Setting the image frame so that it's immediately before the text:
//        leftWave.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspectLeftWave, y: label.frame.origin.y, width: label.frame.size.height*imageAspectLeftWave, height: label.frame.size.height)
//        leftWave.contentMode = UIView.ContentMode.scaleAspectFit
//
//        // Create the image view
//        let rightWave = UIImageView()
//        rightWave.image = UIImage(named: "wave_right")
//        // To maintain the image's aspect ratio:
//        let imageAspectRightWave = rightWave.image!.size.width/rightWave.image!.size.height
//        // Setting the image frame so that it's immediately before the text:
//        rightWave.frame = CGRect(x: label.frame.origin.x+label.frame.size.width, y: label.frame.origin.y, width: label.frame.size.height*imageAspectRightWave, height: label.frame.size.height)
//        rightWave.contentMode = UIView.ContentMode.scaleAspectFit
        
        
        
        
        // Add both the label and image view to the navView
        navView.addSubview(label)
        //navView.addSubview(leftWave)
        //navView.addSubview(rightWave)
        
        // Set the navigation bar's navigation item's titleView to the navView
        navigationItem.titleView = navView
        
        // Set the navView's frame to fit within the titleView
        navView.sizeToFit()
    }
    
    public func anchorToTop(top: NSLayoutYAxisAnchor? = nil,
                            left: NSLayoutXAxisAnchor? = nil,
                            bottom: NSLayoutYAxisAnchor? = nil,
                            right: NSLayoutXAxisAnchor? = nil) {
        anchorWithConstantsToTop(top,
                                 left: left,
                                 bottom: bottom,
                                 right: right,
                                 topConstant: 0,
                                 leftConstant: 0,
                                 bottomConstant: 0,
                                 rightConstant: 0)
    }
    
    public func anchorWithConstantsToTop(_ top: NSLayoutYAxisAnchor? = nil,
                                         left: NSLayoutXAxisAnchor? = nil,
                                         bottom: NSLayoutYAxisAnchor? = nil,
                                         right: NSLayoutXAxisAnchor? = nil,
                                         topConstant: CGFloat = 0,
                                         leftConstant: CGFloat = 0,
                                         bottomConstant: CGFloat = 0,
                                         rightConstant: CGFloat = 0) {
        
        _ = anchor(top: top,
                   left: left,
                   bottom: bottom,
                   right: right,
                   topConstant: topConstant,
                   leftConstant: leftConstant,
                   bottomConstant: bottomConstant,
                   rightConstant: rightConstant)
    }
    
    public func anchor(top: NSLayoutYAxisAnchor? = nil,
                       left: NSLayoutXAxisAnchor? = nil,
                       bottom: NSLayoutYAxisAnchor? = nil,
                       right: NSLayoutXAxisAnchor? = nil,
                       topConstant: CGFloat = 0,
                       leftConstant: CGFloat = 0,
                       bottomConstant: CGFloat = 0,
                       rightConstant: CGFloat = 0,
                       widthConstant: CGFloat = 0,
                       heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        return anchors
    }
    
    func anchorToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
        
        anchorWithConstantsToTop(top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    
    
}

class CustomProgressUISlider : UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: UIScreen.main.bounds.width - 40, height: 7.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
}
class CustomProgressTopUISlider : UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: UIScreen.main.bounds.width + 6, height: 4.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
}


extension UIImageView {
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.8
        pulse.fromValue = 0.98
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: "pulse")
    }
}

extension UIView {
    
    func slideInFromLeft(_ duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromLeft
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    func slideInFromRight(_ duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        let slideInFromRightTransitions = CATransition()
        slideInFromRightTransitions.type = CATransitionType.push
        slideInFromRightTransitions.subtype = CATransitionSubtype.fromRight
        slideInFromRightTransitions.duration = duration
        slideInFromRightTransitions.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromRightTransitions.fillMode = CAMediaTimingFillMode.removed
        self.layer.add(slideInFromRightTransitions, forKey: "slideInFromRightTransitions")
    }
    func slideInFromTop(_ duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        let slideInFromTopTransition = CATransition()
        slideInFromTopTransition.type = CATransitionType.push
        slideInFromTopTransition.subtype = CATransitionSubtype.fromTop
        slideInFromTopTransition.duration = duration
        slideInFromTopTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromTopTransition.fillMode = CAMediaTimingFillMode.removed
        // Add the animation to the View's layer
        self.layer.add(slideInFromTopTransition, forKey: "slideInFromTopTransition")
    }
    func slideInFromBottom(_ duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        let slideInFromBottomTransitions = CATransition()
        slideInFromBottomTransitions.type = CATransitionType.push
        slideInFromBottomTransitions.subtype = CATransitionSubtype.fromBottom
        slideInFromBottomTransitions.duration = duration
        slideInFromBottomTransitions.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromBottomTransitions.fillMode = CAMediaTimingFillMode.removed
        self.layer.add(slideInFromBottomTransitions, forKey: "slideInFromBottomTransitions")
    }
}

extension CALayer {
    func pauseAnimation() {
        let pauseTime : CFTimeInterval = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pauseTime
    }
    func resumeAnimation() {
        let pauseTime : CFTimeInterval = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let timeSincePause : CFTimeInterval = convertTime(CACurrentMediaTime(), from: nil) - pauseTime
        beginTime = timeSincePause
    }
}

extension Bundle {
    var appName: String {
        return infoDictionary?["CFBundleName"] as! String
    }
    var bundleId: String {
        return bundleIdentifier!
    }
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
}


class Debouncer {
    
    // Callback to be debounced
    // Perform the work you would like to be debounced in this callback.
    var callback: (() -> Void)?
    
    private let interval: TimeInterval // Time interval of the debounce window
    init(interval: TimeInterval) {
        self.interval = interval
    }
    private var timer: Timer?
    // Indicate that the callback should be called. Begins the debounce window.
    func call() {
        // Invalidate existing timer if there is one
        timer?.invalidate()
        // Begin a new timer from now
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: false)
    }
    @objc private func handleTimer(_ timer: Timer) {
        if callback == nil {
            NSLog("Debouncer timer fired, but callback was nil")
        } else {
            NSLog("Debouncer timer fired")
        }
        callback?()
        callback = nil
    }
    
}
public extension UISearchBar {
    
    public func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
