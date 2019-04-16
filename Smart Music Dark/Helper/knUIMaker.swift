//
//  UIMaker.swift
//  knCollection
//
//  Created by Ky Nguyen on 10/12/17.
//  Copyright © 2017 Ky Nguyen. All rights reserved.
//

import UIKit
class UIMaker {
    static func makeHorizontalLine(color: UIColor,
                                   height: CGFloat = 1) -> UIView {
        let view = makeView(background: color)
        view.height(height)
        return view
    }

    static func makeLabel(text: String? = nil,
                          font: UIFont = .systemFont(ofSize: 15),
                          color: UIColor = .black,
                          numberOfLines: Int = 1,
                          alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.textColor = color
        label.text = text
        label.numberOfLines = numberOfLines
        label.textAlignment = alignment
        return label
    }

    static func makeView(background: UIColor? = .clear) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = background
        return view
    }

    static func makeImageView(image: UIImage? = nil,
                              contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImageView {
        let iv = UIImageView(image: image)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = contentMode
        iv.clipsToBounds = true
        return iv
    }

    static func makeTextField(text: String? = nil,
                              placeholder: String? = nil,
                              font: UIFont = .systemFont(ofSize: 15),
                              color: UIColor = .black,
                              alignment: NSTextAlignment = .left) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = font
        tf.textColor = color
        tf.text = text
        tf.placeholder = placeholder
        tf.textAlignment = alignment
        tf.inputAccessoryView = makeKeyboardDoneView()
        return tf
    }

    static func makeButton(title: String? = nil,
                           titleColor: UIColor = .black,
                           font: UIFont? = nil,
                           background: UIColor = .clear,
                           borderWidth: CGFloat = 0,
                           borderColor: UIColor = .clear) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)

        button.setTitleColor(titleColor, for: .normal)
        button.setTitleColor(titleColor.withAlphaComponent(0.4), for: .disabled)
        button.backgroundColor = background

        button.titleLabel?.font = font
        button.setBorder(borderWidth, color: borderColor)
        return button
    }

    static func makeStackView(axis: NSLayoutConstraint.Axis = .vertical,
                              distributon: UIStackView.Distribution = .equalSpacing,
                              alignment: UIStackView.Alignment = .center,
                              space: CGFloat = 16) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.distribution = distributon
        stackView.alignment = alignment
        stackView.spacing = space
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    static func makeButton(image: UIImage? = nil) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        return button
    }

    static func makeKeyboardDoneView(title: String = "Done", doneAction: Selector? = nil, font: UIFont = UIFont.systemFont(ofSize: 15)) -> UIView {
        let screenWidth = UIScreen.main.bounds.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
        let button = makeButton(title: title,
                                titleColor: UIColor(red: 3/255, green: 3/255, blue: 3/255, alpha: 1),
                                font: font)
        if let doneAction = doneAction {
            button.addTarget(self, action: doneAction, for: .touchUpInside)
        }
        else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            button.addTarget(appDelegate, action: #selector(hideKeyboard), for: .touchUpInside)
        }

        view.addSubview(button)
        button.right(toView: view, space: -30)
        button.centerY(toView: view)

        view.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        return view
    }

    @objc private static func hideKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

extension UIView {
    func setBorder(_ width: CGFloat, color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}

extension UITextField {
    enum ViewType {
        case left, right
    }

    @discardableResult
    func setView(_ view: ViewType, space: CGFloat) -> UIView {
        let spaceView = UIView(frame: CGRect(x: 0, y: 0, width: space, height: 1))
        setView(view, with: spaceView)
        return spaceView
    }

    func setView(_ type: ViewType, with view: UIView) {
        if type == ViewType.left {
            leftView = view
            leftViewMode = .always
        } else if type == .right {
            rightView = view
            rightViewMode = .always
        }
    }

    @discardableResult
    func setView(_ view: ViewType, title: String) -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 100)
        button.setTitle(title, for: UIControl.State())
        button.sizeToFit()
        setView(view, with: button)
        return button
    }

    @discardableResult
    func setView(_ view: ViewType, image: UIImage?) -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 100)
        button.setImage(image, for: UIControl.State())
        button.imageView!.contentMode = UIView.ContentMode.scaleAspectFit
        button.contentHorizontalAlignment = .left
        setView(view, with: button)
        return button
    }

    func setPlaceholderColor(_ color: UIColor) {
        guard let placeholder = placeholder else { return }
        let attributes = [NSAttributedString.Key.foregroundColor: color]
        attributedPlaceholder = NSAttributedString(string: placeholder,
                                                   attributes: attributes)
    }

    func toggleSecure() {
        isSecureTextEntry = !isSecureTextEntry
    }

    func selectAllText() {
        selectedTextRange = textRange(from: beginningOfDocument, to: endOfDocument)
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}

extension UIButton {

    func setProcess(visible: Bool,
                    style: UIActivityIndicatorView.Style = .white) {
        if visible {
            titleLabel?.layer.opacity = 0
            isEnabled = false
            let indicator = UIActivityIndicatorView(style: style)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.tag = 10001
            indicator.startAnimating()
            addSubview(indicator)
            indicator.center(toView: self)
        } else {
            titleLabel?.layer.opacity = 1
            isEnabled = true
            let indicator = viewWithTag(10001)
            indicator?.removeFromSuperview()
        }
    }
}
