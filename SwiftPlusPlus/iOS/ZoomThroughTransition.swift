//
//  ZoomThroughTransition.swift
//  Speller
//
//  Created by Andrew J Wagner on 10/13/15.
//  Copyright © 2015 Learn Brigade, LLC. All rights reserved.
//

import UIKit

class ZoomThroughTransition: ViewControllerTransition {
    let zoomThroughView: UIView
    var shouldZoomOut = true

    init(zoomThroughView: UIView) {
        self.zoomThroughView = zoomThroughView
        super.init()
    }

    override func performAnimated(_ animated: Bool, onComplete: (() -> Void)?) {
        let zoomThroughFrame = zoomThroughView.frame
        let sourceView = self.sourceViewController.view
        let destinationView = self.destinationViewController.view
        let windowBounds = UIApplication.shared.keyWindow!.bounds

        destinationView?.frame = (sourceView?.frame)!
        sourceView?.superview!.insertSubview(destinationView!, belowSubview: sourceView!)

        UIView.animate(withDuration: 0.3,
            animations: {
                let scale = windowBounds.height / zoomThroughFrame.height
                let yInView: CGFloat
                if #available(iOS 8.0, *) {
                    yInView = (sourceView?.convert(zoomThroughFrame.origin, from: self.zoomThroughView.superview!).y)!
                } else {
                    yInView = (sourceView?.convert(zoomThroughFrame.origin, from: self.zoomThroughView.superview!).y)!
                }
                let translateForTop = (sourceView?.bounds.height)! * (scale - 1) / 2
                let translateForButton = -yInView * scale
                let translate = translateForTop + translateForButton

                var transform = CGAffineTransform(translationX: 0, y: translate)
                transform = transform.scaledBy(x: scale, y: scale)

                sourceView?.transform = transform
                sourceView?.alpha = 0
            },
            completion: { _ in
                self.sourceViewController.present(self.destinationViewController, animated: false, completion: onComplete)
            }
        )
    }

    override func reverse(_ animated: Bool, onComplete: (() -> Void)?) {
        guard self.shouldZoomOut else {
            super.reverse(animated, onComplete: onComplete)
            return
        }

        let sourceView = self.sourceViewController.view
        let destinationView = self.destinationViewController.view

        UIApplication.shared.keyWindow!.insertSubview(sourceView!, aboveSubview: destinationView!)

        UIView.animate(withDuration: 0.3,
            animations: {
                sourceView?.transform = CGAffineTransform.identity
                sourceView?.alpha = 1
            },
            completion: { completed in
                self.destinationViewController.dismiss(animated: false, completion: nil)
            }
        )
    }
}
