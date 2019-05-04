//
//  InAppPurchaser.swift
//  8DWave
//
//  Created by Ky Nguyen on 2/15/19.
//  Copyright © 2019 Abraham Sameer. All rights reserved.
//

import UIKit
import StoreKit

class PremiumController: UIViewController {
    var premiumOption: Subscription?
    
   
    let scrollView = UIScrollView()
    let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc func enrollNow() {
        guard let premiumOption = SubscriptionService.shared.options?.first else { return }
        SubscriptionService.shared.purchase(subscription: premiumOption)
    }
    
    func setupScrollView(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }
    
    func setupViews(){
        
        title = "Premium"
        UIView.setupNavigationTitle(title: "Premium", navigationItem: self.navigationItem)
        view.backgroundColor = .clear

        let labelFree = UILabel()
        labelFree.text = "FREE"
        labelFree.font = AppStateHelper.shared.defaultFontBold(size: 20)
        labelFree.textColor = UIColor.rgba(132, 144, 161, 1)

        contentView.addSubview(labelFree)

        labelFree.translatesAutoresizingMaskIntoConstraints = false
        labelFree.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
        labelFree.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true

        
        let stackView1 = self.makeStackView(elements: [[true:"Free Streaming with ads"],[true:"Create Limited 8D Tracks"],[false:"Downloads"],[false:"Ad-Free Streaming"],[false:"Listen Offline"]])

        contentView.addSubview(stackView1)
        stackView1.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.65).isActive = true
        stackView1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
        stackView1.topAnchor.constraint(equalTo: labelFree.bottomAnchor, constant: 3).isActive = true

        
        let line = UIView()
        line.backgroundColor = .rgba(243,244,245,1)

        contentView.addSubview(line)

        line.translatesAutoresizingMaskIntoConstraints = false
        line.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -35 * 2).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 35).isActive = true
        line.topAnchor.constraint(equalTo: stackView1.bottomAnchor, constant: 10).isActive = true

        
        let labelPremium = UILabel()
        labelPremium.text = "PREMIUM"
        labelPremium.font = AppStateHelper.shared.defaultFontBold(size: 20)
        labelPremium.textColor = UIColor.themeNavbarColor()
        
        contentView.addSubview(labelPremium)
        labelPremium.translatesAutoresizingMaskIntoConstraints = false

        labelPremium.translatesAutoresizingMaskIntoConstraints = false
        labelPremium.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
        labelPremium.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 10).isActive = true

        
        let stackViewWithImages = self.makeStackViewWithImages(names: "premium_headphones", "premium_adfree", "premium_create" )

        contentView.addSubview(stackViewWithImages)
        stackViewWithImages.translatesAutoresizingMaskIntoConstraints = false

        
        stackViewWithImages.widthAnchor.constraint(equalToConstant: 134).isActive = true
        stackViewWithImages.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        stackViewWithImages.topAnchor.constraint(equalTo: labelPremium.bottomAnchor, constant: 10).isActive = true

        
        let stackView = self.makeStackView(elements: [[true:"Premium Streaming"],[true:"Create Unlimited 8D Tracks"],[true:"Listen Offline"],[true:"Ad-Free Streaming"],[true:"Downloads"]])
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.65).isActive = true
        stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: stackViewWithImages.bottomAnchor, constant: 10).isActive = true

        
        let priceView = self.makePriceLabel(price: "$4.99", perDate: "month")
        contentView.addSubview(priceView)
        priceView.translatesAutoresizingMaskIntoConstraints = false

        priceView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -30).isActive = true
        priceView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30).isActive = true
        
        let bottomnote = self.makePriceLabel2(price:
            "<div style='color:black !important'>8DWave Premium <ul><li>This subscription automatically renews for $4.99 per month.</li>" +
                "<li>Payment will be charged to your Apple ID account at the confirmation of purchase.</li>" +
                "<li>Subscription automatically renews unless it is cancelled at least 24 hours before the end of the current period.</li> " +
                "<li>Your account will be charged for renewal within 24 hours prior to the end of the current period.</li> " +
                "<li>You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.</li> " +
                "<li>Any unused portion of a free trial period, if offered, will be forfeited when you purchase a subscription.</li>" +
                
                "<li><div align='center' style='width:100%; text-align:center'><a href='https://www.8dwave.com/toy.html'>Terms of Use</a> - "  +
            "<a href='https://www.8dwave.com/privacy.html'>Privacy Policy</a><a href='https://www.8dwave.com/privacy.html'>Privacy Policy</a><a href='https://www.8dwave.com/privacy.html'>Privacy Policy</a><a href='https://www.8dwave.com/privacy.html'>Privacy Policy</a><a href='https://www.8dwave.com/privacy.html'>Privacy Policy</a><a href='https://www.8dwave.com/privacy.html'>Privacy Policy</a></div></li></ul></div>",perDate: "month")

        contentView.addSubview(bottomnote)
        bottomnote.translatesAutoresizingMaskIntoConstraints = false

        bottomnote.topAnchor.constraint(equalTo: priceView.bottomAnchor, constant: 0).isActive = true
        bottomnote.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        bottomnote.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        bottomnote.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true

        
        contentView.addSubview(enrollButton)

        enrollButton.translatesAutoresizingMaskIntoConstraints = false
        
        enrollButton.topAnchor.constraint(equalTo: bottomnote.bottomAnchor, constant: 0).isActive = true
        enrollButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -24 * 2).isActive = true
        enrollButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        enrollButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        enrollButton.height(48)
        enrollButton.addTarget(self, action: #selector(enrollNow), for: .touchUpInside)


    }
    


    func makeView(flag: Bool, text: String) -> UIView{
        let view = UIView()
        
        let label = UILabel()
        label.text = text
        label.font = AppStateHelper.shared.defaultFontBold(size: 14)
        label.textColor = flag ? UIColor.themeNavbarColor() : UIColor.rgba(132, 144, 161, 1)
        
        let imageView = UIImageView(image: UIImage(named: flag ? "premium_checkmark" :  "premium_cross"))
        imageView.contentMode = .scaleAspectFit
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubviews(views: label,imageView)
        
        view.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -12).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        label.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 5).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }
    
    let enrollButton = { () -> UIButton in
        let button = UIMaker.makeButton(title: "GET PREMIUM",
                                        titleColor: UIColor.themeTabarColor(),
                                        font: AppStateHelper.shared.defaultFontBold(size: 20),
                                        background: UIColor.themeNavbarColor())
        button.layer.cornerRadius = 10
        return button
    }()
    
    func makeStackView(elements: [[Bool:String]]) -> UIStackView{
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .vertical
        for element in elements{
            stackView.addArrangedSubview(self.makeView(flag: (element.first?.key ?? false), text: element.first?.value ?? ""))
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.heightAnchor.constraint(equalToConstant: CGFloat(elements.count * 24)).isActive = true
        return stackView
    }
    
    func makeStackViewWithImages(names: String...) -> UIStackView{
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 22
        for name in names{
            let imageView = UIImageView(image: UIImage(named: name))
            imageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(imageView)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
            
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return stackView
    }

    
    func makePriceLabel(price: String, perDate: String) -> UIView {
        let wrapper = UIView()
        
        let labelPrice = UILabel()
        labelPrice.text = price
        labelPrice.font = AppStateHelper.shared.defaultFontBold(size: 25)
        labelPrice.textColor = UIColor.themeNavbarColor()
        
        let labelPerDate = UILabel()
        labelPerDate.text = "/\(perDate)"
        labelPerDate.font = AppStateHelper.shared.defaultFontBold(size: 14)
        labelPerDate.textColor = UIColor.themeNavbarColor()
        
        wrapper.addSubview(labelPrice)
        wrapper.addSubview(labelPerDate)
        
        
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        labelPrice.translatesAutoresizingMaskIntoConstraints = false
        labelPerDate.translatesAutoresizingMaskIntoConstraints = false
        
        labelPrice.leftAnchor.constraint(equalTo: wrapper.leftAnchor, constant: 0).isActive = true
        labelPrice.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 0).isActive = true
        labelPrice.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: 0).isActive = true
        
        labelPerDate.leftAnchor.constraint(equalTo: labelPrice.rightAnchor, constant: 0).isActive = true
        labelPerDate.rightAnchor.constraint(equalTo: wrapper.rightAnchor, constant: 0).isActive = true
        labelPerDate.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: 0).isActive = true
        return wrapper
    }
    
    func makePriceLabel2(price: String, perDate: String) -> UITextView {
        
        let labelPrice = UITextView()
        labelPrice.attributedText = price.htmlToAttributedString
        labelPrice.font = AppStateHelper.shared.defaultFontBold(size: 8)
        labelPrice.textColor = UIColor.black
        labelPrice.translatesAutoresizingMaskIntoConstraints = true
        labelPrice.sizeToFit()
        labelPrice.isScrollEnabled = false
        labelPrice.textAlignment = NSTextAlignment.left
        labelPrice.isEditable = false
        labelPrice.dataDetectorTypes = UIDataDetectorTypes.all
        
        return labelPrice
    }
    
    

}



extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
