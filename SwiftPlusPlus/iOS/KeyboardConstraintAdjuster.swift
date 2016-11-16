//
//  KeyboardConstraintAdjuster.swift
//  SwiftPlusPlus
//
//  Created by Andrew J Wagner on 11/6/15.
//  Copyright © 2015 Drewag LLC. All rights reserved.
//

import Foundation

open class KeyboardConstraintAdjuster: NSObject {
    @IBOutlet open var constraint: NSLayoutConstraint!
    @IBOutlet open var view: UIView!

    @IBInspectable open var offset: CGFloat = 0

//    private var currentKeyboardHeight = 0

    open var onKeyboardIsBeingShown: (() -> ())?
    open var onKeyboardWasShown: (() -> ())?
    open var onKeyboardIsBeingHidden: (() -> ())?
    open var onKeyboardWasHidden: (() -> ())?

    override open func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    // MARK: Notifications

    func keyboardWillShow(_ notification: Notification) {
        guard let frame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else { return }
        guard let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }
        let options = UIViewAnimationOptions(rawValue: UInt((notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        let keyboard = self.view.convert(frame, from:self.view.window)
        let displayHeight = self.view.frame.height - keyboard.minY

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: { () -> Void in
                self.onKeyboardIsBeingShown?()
                self.constraint.constant = displayHeight + self.offset
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                self.onKeyboardWasShown?()
            }
        )
    }

    func keyboardWillHide(_ notification: Notification) {
        guard let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }
        let options = UIViewAnimationOptions(rawValue: UInt((notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: {
                self.onKeyboardIsBeingHidden?()
                self.constraint.constant = self.offset
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                self.onKeyboardWasHidden?()
            }
        )
    }
}
