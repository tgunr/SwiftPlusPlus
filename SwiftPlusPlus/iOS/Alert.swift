//
//  Alert.swift
//  SwiftPlusPlus
//
//  Created by Andrew J Wagner on 9/10/15.
//  Copyright © 2015 Drewag LLC. All rights reserved.
//

import UIKit
import ObjectiveC

class Alert: NSObject {
    fileprivate let onButtonClicked: (_ buttonTitle: String?, _ textFieldText: String?) -> ()

    fileprivate init(onButtonClicked: @escaping (_ buttonTitle: String?, _ textFieldText: String?) -> ()) {
        self.onButtonClicked = onButtonClicked

        super.init()
    }
}

public final class AlertAction {
    let name: String
    let handler: (() -> ())?

    init(name: String, handler: (() -> ())?) {
        self.name = name
        self.handler = handler
    }

    public static func action(_ name: String, handler: (() -> ())? = nil) -> AlertAction {
        return AlertAction(name: name, handler: handler)
    }
}

public final class TextAction {
    let name: String
    let handler: ((_ text: String) -> ())?

    init(name: String, handler: ((_ text: String) -> ())?) {
        self.name = name
        self.handler = handler
    }

    public static func action(_ name: String, handler: ((_ text: String) -> ())? = nil) -> TextAction {
        return TextAction(name: name, handler: handler)
    }
}

extension Alert: UIAlertViewDelegate {
    @available(iOS, introduced: 2.0, deprecated: 9.0, message: "Use showAlertController instead")
    func alertView(_ alertView: UIAlertView, clickedButtonAt clickedButtonAtIndex: Int) {
        let title = alertView.buttonTitle(at: clickedButtonAtIndex)
        var textFieldText: String?
        if let textField = alertView.textField(at: 0) {
            textFieldText = textField.text
        }
        self.onButtonClicked(title, textFieldText)
    }
}

extension UIViewController {
    public func showAlert(withError error: UserReportableError) {
        self.showAlert(
            withTitle: error.alertTitle,
            message: error.alertMessage
        )
    }

    public func showAlert(
        withTitle title: String,
        message: String,
        cancel: AlertAction? = nil,
        other: [AlertAction] = []
        )
    {
        func onTapped(_ buttonTitle: String?, textFieldText: String?) {
            if let action = cancel, action.name == buttonTitle {
                action.handler?()
                return
            }
            for action in other {
                if action.name == buttonTitle {
                    action.handler?()
                    return
                }
            }
        }

        var other = other
        if cancel == nil && other.isEmpty {
            other.append(.action("OK"))
        }
        if #available(iOS 8.0, *) {
            Alert.showAlertController(
                title,
                message: message,
                cancelButtonTitle: cancel?.name,
                otherButtonTitles: other.map({$0.name}),
                textFieldPlaceholder: nil,
                textFieldDefault: nil,
                onButtonClicked: onTapped,
                fromViewController: self
            )
        }
        else {
            Alert.showAlertView(
                title,
                message: message,
                cancelButtonTitle: cancel?.name,
                otherButtonTitles: other.map({$0.name}),
                textFieldPlaceholder: nil,
                textFieldDefault: nil,
                onButtonClicked: onTapped
            )
        }
    }

    public func showTextInput(
        withTitle title: String,
        message: String,
        textFieldPlaceholder: String? = nil,
        textFieldDefault: String? = nil,
        cancel: TextAction? = nil,
        other: [TextAction] = []
    )
    {
        func onTapped(_ buttonTitle: String?, textFieldText: String?) {
            if let action = cancel, action.name == buttonTitle {
                action.handler?(textFieldText ?? "")
                return
            }
            for action in other {
                if action.name == buttonTitle {
                    action.handler?(textFieldText ?? "")
                    return
                }
            }
        }

        var other = other
        if cancel == nil && other.isEmpty {
            other.append(.action("OK"))
        }
        if #available(iOS 8.0, *) {
            Alert.showAlertController(
                title,
                message: message,
                cancelButtonTitle: cancel?.name,
                otherButtonTitles: other.map({$0.name}),
                textFieldPlaceholder: textFieldPlaceholder ?? "",
                textFieldDefault: textFieldDefault,
                onButtonClicked: onTapped,
                fromViewController: self
            )
        }
        else {
            Alert.showAlertView(
                title,
                message: message,
                cancelButtonTitle: cancel?.name,
                otherButtonTitles: other.map({$0.name}),
                textFieldPlaceholder: textFieldPlaceholder ?? "",
                textFieldDefault: textFieldDefault,
                onButtonClicked: onTapped
            )
        }
    }
}

private extension Alert {
    struct Keys {
        static var Delegate = "Delegate"
    }

    @available(iOS, introduced: 2.0, deprecated: 9.0, message: "Use showAlertController instead")
    class func showAlertView(
        _ title: String,
        message: String,
        cancelButtonTitle: String?,
        otherButtonTitles: [String]?,
        textFieldPlaceholder: String? = nil,
        textFieldDefault: String? = nil,
        onButtonClicked: ((_ buttonTitle: String?, _ textFieldText: String?) -> ())?
        )
    {
        var delegate: UIAlertViewDelegate?
        if let onButtonClicked = onButtonClicked {
            delegate = Alert(onButtonClicked: onButtonClicked)
        }

        let alert = UIAlertView(title: title, message: message, delegate: delegate, cancelButtonTitle: cancelButtonTitle)

        if textFieldPlaceholder != nil {
            alert.alertViewStyle = .plainTextInput
        }

        for otherButtonTitle in otherButtonTitles ?? [] {
            alert.addButton(withTitle: otherButtonTitle)
        }

        if let delegate = delegate {
            objc_setAssociatedObject(
                alert,
                &Keys.Delegate,
                delegate,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }

        alert.show()
    }

    @available(iOS 8.0, *)
    class func showAlertController(
        _ title: String,
        message: String,
        cancelButtonTitle: String?,
        otherButtonTitles: [String]?,
        textFieldPlaceholder: String?,
        textFieldDefault: String? = nil,
        onButtonClicked: ((_ buttonTitle: String?, _ textFieldText: String?) -> ())?,
        fromViewController: UIViewController
        )
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        var promptTextField: UITextField?
        if let placeholder = textFieldPlaceholder {
            alert.addTextField { textField in
                textField.placeholder = placeholder
                textField.text = textFieldDefault
                promptTextField = textField
            }
        }

        func handler(_ action: UIAlertAction!) {
            if let block = onButtonClicked {
                block(action.title, promptTextField?.text)
            }
        }


        if let cancelButtonTitle = cancelButtonTitle {
            alert.addAction(UIAlertAction(
                title: cancelButtonTitle,
                style: .cancel,
                handler: handler
                ))
        }
        for otherTitle in otherButtonTitles ?? [] {
            alert.addAction(UIAlertAction(
                title: otherTitle,
                style: .default,
                handler: handler
                ))
        }

        fromViewController.present(alert, animated: true, completion: nil)
    }
}
