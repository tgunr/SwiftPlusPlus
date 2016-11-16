//
//  NSDate+Helpers.swift
//  SwiftPlusPlus
//
//  Created by Andrew J Wagner on 1/4/15.
//  Copyright (c) 2015 Drewag LLC. All rights reserved.
//

import UIKit

extension Date {
    public var isToday: Bool {
        let cal = Calendar.current
        let units = NSCalendar.Unit.era
            .union(.year)
            .union(.month)
            .union(.day)
        var components = (cal as NSCalendar).components(units, from: Date())
        let today = cal.date(from: components)
        components = (cal as NSCalendar).components(units, from: self)
        let otherDate = cal.date(from: components)

        return today == otherDate
    }

    public var isThisYear: Bool {
        let cal = Calendar.current
        let units = NSCalendar.Unit.era
            .union(.year)
        var components = (cal as NSCalendar).components(units, from: Date())
        let today = cal.date(from: components)
        components = (cal as NSCalendar).components(units, from: self)
        let otherDate = cal.date(from: components)

        return today == otherDate
    }

    public var time: dispatch_time_t {
        let seconds = self.timeIntervalSince1970
        let wholeSecsFloor = floor(seconds)
        let nanosOnly = seconds - wholeSecsFloor
        let nanosFloor = floor(nanosOnly * Double(NSEC_PER_SEC))
        let thisStruct = timespec(tv_sec: Int(wholeSecsFloor),
                                  tv_nsec: Int(nanosFloor))
        let dt = DispatchWallTime.init(timespec: thisStruct).rawValue
        return dt
    }
}
