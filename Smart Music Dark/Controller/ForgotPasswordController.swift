//
//  ForgotPassword.swift
//  8DWave
//
//  Created by Ky Nguyen on 2/13/19.
//  Copyright © 2019 Abraham Sameer. All rights reserved.
//

import UIKit
import FirebaseAuth
import PKHUD

class ForgotPasswordController: UIViewController {
    var datasource = [UITableViewCell]() { didSet { tableView.reloadData() }}
    let validation = Validator()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
    }

    func fillList(space: UIEdgeInsets = .zero) {
        view.addSubviews(views: tableView)
        tableView.fill(toView: view, space: space)
        setupKeyboardNotifcationListenerForScrollView(scrollView: tableView)
    }

    func setupView() {
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100


        let bgImageView = UIMaker.makeView(background: UIColor(red: 43/255, green: 47/255, blue: 56/255, alpha: 1))
        view.addSubview(bgImageView)
        bgImageView.fillSuperview()


        fillList()
        tableView.backgroundColor = .clear
        datasource = [ui.setupView()]

        ui.sendButton.addTarget(self, action: #selector(sendForgotPassword), for: .touchUpInside)
        ui.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }

    @objc func sendForgotPassword() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.hideKeyboard()

        validation.email = ui.emailTextField.text
        if let message = validation.validate() {
            showError(message)
            return
        }

        HUD.show(.progress)
        Auth.auth().sendPasswordReset(withEmail: validation.email!) { [weak self] (err) in
            if let message = err?.localizedDescription {
                self?.showError(message)
                return
            }

            HUD.hide()
            self?.goBack()
        }
    }

    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }

    func showError(_ message: String) {
        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        present(controller, animated: true)
    }

    lazy var tableView: UITableView = { [weak self] in
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.separatorStyle = .none
        tb.showsVerticalScrollIndicator = false
        tb.dataSource = self
        tb.delegate = self
        return tb
        }()

    let ui = UI()
}

extension ForgotPasswordController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { return datasource[indexPath.row] }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return UITableView.automaticDimension }
}

extension ForgotPasswordController {
    class UI {
        let padding: CGFloat = 24

        lazy var sendButton = makeMainButton()
        lazy var emailTextField = makeTextField(icon: UIImage(named: "email"),
                                                placeholder: "Email")
        let backButton = UIMaker.makeButton(image: UIImage(named: "back_arrow"))

        func setupView() -> UITableViewCell {
            emailTextField.autocapitalizationType = .none
            emailTextField.autocorrectionType = .no

            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none


            let view = UIMaker.makeView()


            let font14 = AppStateHelper.shared.defaultFontRegular(size: 20)
            let appNameLabel = UIMaker.makeLabel(text: "8DWave",
                                                 font: font14,
                                                 color: .white)


            let boldFont = AppStateHelper.shared.defaultFontBold(size: 32)
            let loginLabel = UIMaker.makeLabel(text: "Forgot Password",
                                               font: boldFont,
                                               color: .white)



            let bar = UIMaker.makeHorizontalLine(color: .white, height: 5)

            view.addSubViewList(appNameLabel, loginLabel, bar, emailTextField, sendButton, backButton)

            appNameLabel.left(toView: view, space: padding)

            loginLabel.left(toView: appNameLabel)
            loginLabel.verticalSpacing(toView: appNameLabel, space: padding)

            bar.left(toView: view, space: padding * 3)
            bar.width(150)
            bar.verticalSpacing(toView: loginLabel, space: padding * 2)
            bar.centerY(toView: view, space: -padding * 2)

            emailTextField.horizontal(toView: view, space: padding)
            emailTextField.verticalSpacing(toView: bar, space: padding * 3)

            sendButton.horizontal(toView: emailTextField)
            sendButton.verticalSpacing(toView: emailTextField, space: padding * 2)

            let image = backButton.imageView?.image
            backButton.imageView?.image = image?.withRenderingMode(.alwaysTemplate)
            backButton.imageView?.tintColor = .white
            backButton.square(edge: 44)
            backButton.topLeft(toView: view, top: 32, left: 0)

            cell.addSubview(view)
            view.fillSuperview()
            view.height(UIScreen.main.bounds.height)
            return cell
        }

        func makeTextField(icon: UIImage?, placeholder: String) -> UITextField {
            let font = AppStateHelper.shared.defaultFontRegular(size: 18)
            let tf = UIMaker.makeTextField(placeholder: placeholder,
                                           font: font,
                                           color: .white)
            tf.setPlaceholderColor(.white)
            let view = tf.setView(.left, image: icon?.withRenderingMode(.alwaysTemplate))
            view.tintColor = .white
            tf.height(54)

            let line = UIMaker.makeHorizontalLine(color: .white)
            tf.addSubview(line)
            line.horizontal(toView: tf)
            line.bottom(toView: tf)
            return tf
        }

        func makeMainButton() -> UIButton {
            let barWidth: CGFloat = 3
            let bar = UIMaker.makeHorizontalLine(color: .white, height: barWidth)
            bar.isUserInteractionEnabled = false

            let font = AppStateHelper.shared.defaultFontBold(size: 20)
            let label = UIMaker.makeLabel(text: "SEND INSTRUCTION",
                                          font: font,
                                          color: .white)
            let button = UIMaker.makeButton(background: .clear,
                                            borderWidth: barWidth,
                                            borderColor: .white)

            button.addSubview(bar)
            button.addSubview(label)

            button.addConstraints(withFormat: "H:|-16-[v0]-16-[v1]-16-|", views: bar, label)
            bar.centerY(toView: button)
            label.centerY(toView: button)

            button.height(66)
            return button
        }
    }

    class Validator {
        var email: String?
        func validate() -> String? {
            if email == nil || email?.isEmpty == true { return "Email can't be blank" }
            if email!.isValidEmail() == false { return "Invalid email" }
            return nil
        }

    }
}


