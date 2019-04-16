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
    var datasource = [UITableViewCell]() { didSet { tableView.reloadData() }}

    lazy var tableView: UITableView = { [weak self] in
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.separatorStyle = .none
        tb.showsVerticalScrollIndicator = false
        tb.backgroundColor = .clear
        tb.dataSource = self
        tb.delegate = self
        return tb
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.roundCorners([.topLeft, .topRight], radius: 25)
    }
    
    let enrollButton = { () -> UIButton in
        let button = UIMaker.makeButton(title: "GET PREMIUM",
                                        titleColor: UIColor.themeTabarColor(),
                                        font: AppStateHelper.shared.defaultFontBold(size: 20),
                                        background: UIColor.themeNavbarColor())
        button.layer.cornerRadius = 10
        return button
    }()
    
    func setupView() {
        title = "Premium"
        UIView.setupNavigationTitle(title: "Premium", navigationItem: self.navigationItem)
        let color = UIColor.themeNavbarColor()
        view.backgroundColor = color

        let footerView = UIView()
        footerView.backgroundColor = UIColor.themeBaseColor()
        footerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubviews(views: tableView,footerView, enrollButton)
        view.addConstraints(withFormat: "V:|[v0][v1]-30-|", views: tableView, enrollButton)
        
        tableView.horizontal(toView: view)
        tableView.backgroundColor = UIColor.themeBaseColor()
        tableView.bounces = false
        
        
        //enrollButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 30).isActive = true
        //enrollButton.horizontal(toView: view, space: 24)
        enrollButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24 * 2).isActive = true
        enrollButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        enrollButton.height(48)
        enrollButton.addTarget(self, action: #selector(enrollNow), for: .touchUpInside)
        
        footerView.horizontal(toView: view)
        footerView.height(30 + 48)
        footerView.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
    }
    
    @objc func enrollNow() {
        guard let premiumOption = SubscriptionService.shared.options?.first else { return }
        SubscriptionService.shared.purchase(subscription: premiumOption)
    }

    func getData() {
        datasource = [
            makeCell(),
            makeCellSecond()
        ]

        SubscriptionService.shared.loadSubscriptionOptions()
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
        
        stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return stackView
    }
    
    func makeCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let cellWrapper = UIView()
        
        let line = UIView()
        line.backgroundColor = .rgba(243,244,245,1)
        
        let labelFree = UILabel()
        labelFree.text = "FREE"
        labelFree.font = AppStateHelper.shared.defaultFontBold(size: 34)
        labelFree.textColor = UIColor.rgba(132, 144, 161, 1)
        
        let stackView = self.makeStackView(elements: [[true:"Free Streaming with ads"],[true:"Create Limited 8D Tracks"],[false:"Downloads"],[false:"Ad-Free Streaming"],[false:"Listen Offline"]])
        
        cell.addSubviews(views: cellWrapper, line)
        cellWrapper.addSubviews(views: labelFree, stackView)
        
        cellWrapper.translatesAutoresizingMaskIntoConstraints = false
        
        cellWrapper.widthAnchor.constraint(equalTo: cell.widthAnchor, constant: 0).isActive = true
        cellWrapper.centerXAnchor.constraint(equalTo: cell.centerXAnchor, constant: 0).isActive = true
        cellWrapper.centerYAnchor.constraint(equalTo: cell.centerYAnchor, constant: 0).isActive = true
        
        labelFree.translatesAutoresizingMaskIntoConstraints = false
        
        labelFree.centerXAnchor.constraint(equalTo: cellWrapper.centerXAnchor, constant: 0).isActive = true
        labelFree.topAnchor.constraint(equalTo: cellWrapper.topAnchor, constant: 0).isActive = true
        
        stackView.widthAnchor.constraint(equalTo: cellWrapper.widthAnchor, multiplier: 0.65).isActive = true
        stackView.centerXAnchor.constraint(equalTo: cellWrapper.centerXAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: labelFree.bottomAnchor, constant: 3).isActive = true
        stackView.bottomAnchor.constraint(equalTo: cellWrapper.bottomAnchor, constant: 0).isActive = true
        
        line.translatesAutoresizingMaskIntoConstraints = false
        
        line.widthAnchor.constraint(equalTo: cell.widthAnchor, constant: -35 * 2).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 35).isActive = true
        line.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        
        return cell
    }
    
    func makeCellSecond() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let cellWrapper = UIView()
  
        let labelPremium = UILabel()
        labelPremium.text = "PREMIUM"
        labelPremium.font = AppStateHelper.shared.defaultFontBold(size: 34)
        labelPremium.textColor = UIColor.themeNavbarColor()
        
        let stackViewWithImages = self.makeStackViewWithImages(names: "premium_headphones", "premium_adfree", "premium_create" )
        
        let stackView = self.makeStackView(elements: [[true:"Premium Streaming"],[true:"Create Unlimited 8D Tracks"],[true:"Listen Offline"],[true:"Ad-Free Streaming"],[true:"Downloads"]])
        
        let priceView = self.makePriceLabel(price: "$4.99", perDate: "month")
        
        cell.addSubview(cellWrapper)
        cellWrapper.addSubviews(views: labelPremium, stackView, stackViewWithImages, priceView)
        
        cellWrapper.translatesAutoresizingMaskIntoConstraints = false
        
        cellWrapper.widthAnchor.constraint(equalTo: cell.widthAnchor, constant: 0).isActive = true
        cellWrapper.centerXAnchor.constraint(equalTo: cell.centerXAnchor, constant: 0).isActive = true
        cellWrapper.centerYAnchor.constraint(equalTo: cell.centerYAnchor, constant: 0).isActive = true
        
        labelPremium.translatesAutoresizingMaskIntoConstraints = false
        
        labelPremium.centerXAnchor.constraint(equalTo: cellWrapper.centerXAnchor, constant: 0).isActive = true
        labelPremium.topAnchor.constraint(equalTo: cellWrapper.topAnchor, constant: 0).isActive = true
        
        stackViewWithImages.widthAnchor.constraint(equalToConstant: 134).isActive = true
        stackViewWithImages.centerXAnchor.constraint(equalTo: cellWrapper.centerXAnchor).isActive = true
        stackViewWithImages.topAnchor.constraint(equalTo: labelPremium.bottomAnchor, constant: 3).isActive = true
        
        stackView.widthAnchor.constraint(equalTo: cellWrapper.widthAnchor, multiplier: 0.65).isActive = true
        stackView.centerXAnchor.constraint(equalTo: cellWrapper.centerXAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: stackViewWithImages.bottomAnchor, constant: 3).isActive = true
        
        priceView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 15).isActive = true
        priceView.centerXAnchor.constraint(equalTo: cellWrapper.centerXAnchor).isActive = true
        priceView.bottomAnchor.constraint(equalTo: cellWrapper.bottomAnchor).isActive = true

        
        return cell
    }
    
    func makePriceLabel(price: String, perDate: String) -> UIView {
        let wrapper = UIView()
        
        let labelPrice = UILabel()
        labelPrice.text = price
        labelPrice.font = AppStateHelper.shared.defaultFontBold(size: 30)
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
        labelPerDate.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -5).isActive = true
        return wrapper
    }

}

extension PremiumController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { return datasource[indexPath.row] }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return tableView.frame.height * 0.4
        }else{
            return tableView.frame.height * 0.6
        }
        
    }
}
