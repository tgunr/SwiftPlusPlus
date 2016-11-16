//
//  BubbleView.swift
//  SwiftPlusPlus
//
//  Created by Andrew J Wagner on 7/31/16.
//  Copyright © 2016 Drewag LLC. All rights reserved.
//

import UIKit

open class BubbleView: UIView {
    fileprivate class TickView: UIView {
        var color: UIColor = UIColor.black {
            didSet {
                self.setNeedsDisplay()
            }
        }

        override func draw(_ rect: CGRect) {
            let width = rect.maxX - rect.minX
            let top = round(rect.midY - width / 2)
            let middle = round(rect.midY)
            let bottom = round(rect.midY + width / 2)

            let left = rect.minX
            let center = round(rect.width * 2 / 3)
            let right = rect.maxX

            let context = UIGraphicsGetCurrentContext()!
            context.move(to: CGPoint(x: right, y: top))
            context.addLine(to: CGPoint(x: right, y: bottom))

            // CGContextAddCurveToPoint(context, center, middle + width / 4, left, middle, left, middle)
            // CGContextAddCurveToPoint(context, center, middle - width / 4, right, top, right, top)
            // Converted to addCurve
            var cp: CGPoint = CGPoint.init(x: left, y: middle)
            var cp1: CGPoint = CGPoint.init(x: center, y: middle + width / 4)
            var cp2: CGPoint = CGPoint.init(x: left, y: middle)
            context.addCurve(to: cp, control1: cp1, control2: cp2)

            cp.x = right
            cp.y = top
            cp1.y = middle - width / 4
            cp2.x = right
            cp2.y = top
            context.addCurve(to: cp, control1: cp1, control2: cp2)
            self.color.setFill()
            context.fillPath()
        }
    }

    open let subview: UIView
    fileprivate let tickView = TickView()
    open static let tickWidth: CGFloat = 20

    open var color: UIColor = UIColor.black {
        didSet {
            self.tickView.color = color
            self.subview.backgroundColor = color
            self.setNeedsDisplay()
        }
    }

    public init(frame: CGRect, subview: UIView) {
        self.subview = subview

        super.init(frame: frame)

        self.tickView.backgroundColor = UIColor.clear
        self.tickView.color = self.color
        self.subview.backgroundColor = self.color

        subview.layer.cornerRadius = 10
        subview.clipsToBounds = true
        self.addSubview(subview)

        self.addSubview(self.tickView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        self.tickView.frame = CGRect(x: 0, y: 0, width: BubbleView.tickWidth, height: self.bounds.height)
        self.subview.frame = CGRect(x: BubbleView.tickWidth, y: 0, width: self.bounds.width - BubbleView.tickWidth, height: self.bounds.height)
    }
}
