//
//  NSLayoutContraint+Factory.swift
//  SwiftPlusPlus
//
//  Created by Andrew J Wagner on 9/14/15.
//  Copyright © 2015 Drewag LLC. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    public class func fullWidthConstraintsWithView(_ view: UIView) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
            options: NSLayoutFormatOptions.directionLeftToRight,
            metrics: nil,
            views:["view": view]
        )
    }

    public class func fullHeightConstraintsWithView(_ view: UIView) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
            options: NSLayoutFormatOptions.directionLeftToRight,
            metrics: nil,
            views:["view": view]
        )
    }

    public class func fillConstraintsWithView(_ view: UIView) -> [NSLayoutConstraint] {
        return self.fullWidthConstraintsWithView(view) + self.fullHeightConstraintsWithView(view)
    }

    public class func centerConstraintsWithView(_ view1: UIView, inView view2: UIView, withOffset offset: CGPoint) -> [NSLayoutConstraint] {
        return [
            NSLayoutConstraint(item: view1, attribute: .centerX, relatedBy: .equal, toItem: view2, attribute: .centerX, multiplier: 1, constant: offset.x),
            NSLayoutConstraint(item: view1, attribute: .centerY, relatedBy: .equal, toItem: view2, attribute: .centerY, multiplier: 1, constant: offset.y),
        ]
    }

    public convenience init(sameWidthForView view1: UIView, andView view2: UIView, difference: CGFloat = 0) {
        self.init(
            item: view1,
            attribute: .width,
            relatedBy: .equal,
            toItem: view2,
            attribute: .width,
            multiplier: 1,
            constant: difference
        )
    }

    public convenience init(sameHeightForView view1: UIView, andView view2: UIView, difference: CGFloat = 0) {
        self.init(
            item: view1,
            attribute: .height,
            relatedBy: .equal,
            toItem: view2,
            attribute: .height,
            multiplier: 1,
            constant: difference
        )
    }

    public convenience init(rightOfView view1: UIView, toView view2: UIView, distance: CGFloat = 0) {
        self.init(
            item: view2,
            attribute: .right,
            relatedBy: .equal,
            toItem: view1,
            attribute: .right,
            multiplier: 1,
            constant: distance
        )
    }

    public convenience init(rightOfView view1: UIView, toLeftOfView view2: UIView, distance: CGFloat = 0) {
        self.init(
            item: view1,
            attribute: .right,
            relatedBy: .equal,
            toItem: view2,
            attribute: .left,
            multiplier: 1,
            constant: distance
        )
    }

    public convenience init(leftOfView view1: UIView, toView view2: UIView, distance: CGFloat = 0) {
        self.init(
            item: view1,
            attribute: .left,
            relatedBy: .equal,
            toItem: view2,
            attribute: .left,
            multiplier: 1,
            constant: distance
        )
    }

    public convenience init(topOfView view1: UIView, toView view2: UIView, distance: CGFloat = 0) {
        self.init(
            item: view2,
            attribute: .top,
            relatedBy: .equal,
            toItem: view1,
            attribute: .top,
            multiplier: 1,
            constant: distance
        )
    }

    public convenience init(leftOfView view1: UIView, toRightOfView view2: UIView, distance: CGFloat = 0) {
        self.init(
            item: view1,
            attribute: .left,
            relatedBy: .equal,
            toItem: view2,
            attribute: .right,
            multiplier: 1,
            constant: distance
        )
    }

    public convenience init(bottomOfView view1: UIView, toView view2: UIView, distance: CGFloat = 0) {
        self.init(
            item: view1,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view2,
            attribute: .bottom,
            multiplier: 1,
            constant: distance
        )
    }
}
